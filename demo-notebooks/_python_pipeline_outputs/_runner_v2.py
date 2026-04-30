"""
Python pipeline v2 runner — produces the v2 artifacts that align this demo with
the latest 00.1-Full-empirical-analysis-skill_Python skill (Step -1 PAP, Step 0
sample log + 5-check contract, Step 2.5 strategy.md, Step 3.5 ID graphics, Step 6
Pattern H robustness master + spec curve, Step 8 reproducibility stamp).

This script is idempotent and standalone. Re-running overwrites artifacts/figures.
The companion notebook has matching cells; either route produces the same files.
"""
from __future__ import annotations

from pathlib import Path
import hashlib
import json
import sys
import warnings

import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import statsmodels.api as sm
import statsmodels.formula.api as smf
from statsmodels.stats.power import TTestIndPower
from sklearn.linear_model import LogisticRegression
from sklearn.pipeline import make_pipeline
from sklearn.preprocessing import StandardScaler

warnings.filterwarnings("ignore")
SEED = 20260425
np.random.seed(SEED)

# ─── Paths ─────────────────────────────────────────────────────────────────────
ROOT = Path(__file__).resolve().parent
TBL  = ROOT / "tables"
FIG  = ROOT / "figures"
ART  = ROOT / "artifacts"
DATA = ROOT / "data" / "lalonde.csv"
for p in (TBL, FIG, ART):
    p.mkdir(parents=True, exist_ok=True)


# ════════════════════════════════════════════════════════════════════════════════
# §-1 Pre-Analysis Plan — solve MDE for the analytic sample at 80% power, α=0.05
# ════════════════════════════════════════════════════════════════════════════════
df = pd.read_csv(DATA)
df["black"]  = (df["race"] == "black").astype(int)
df["hispan"] = (df["race"] == "hispan").astype(int)

n_treat = int(df["treat"].eq(1).sum())
n_ctrl  = int(df["treat"].eq(0).sum())
ratio   = n_ctrl / n_treat

analysis = TTestIndPower()
mde_d = analysis.solve_power(effect_size=None, nobs1=n_treat, ratio=ratio,
                              alpha=0.05, power=0.80)
sd_re78 = float(df["re78"].std(ddof=1))
mde_dollars = float(mde_d * sd_re78)

pap = {
    "design":            "selection on observables (Lalonde NSW)",
    "population":        "Lalonde NSW treated workers + PSID comparison sample, 1976–78",
    "outcome":           "re78 (1978 real earnings, USD)",
    "treatment":         "treat (NSW assignment, 0/1)",
    "estimand":          "ATT",
    "n_treated_planned": n_treat,
    "n_control_planned": n_ctrl,
    "alpha":             0.05,
    "power_target":      0.80,
    "mde_cohens_d":      float(mde_d),
    "mde_in_dollars":    mde_dollars,
    "sd_re78":           sd_re78,
    "frozen_at":         "2026-04-29",
    "note":              ("MDE solved by statsmodels.stats.power.TTestIndPower with "
                          "ratio = N_ctrl / N_treated, two-sided. Convert d → dollars "
                          "via SD(re78) on the analytic sample."),
}
(ART / "pap.json").write_text(json.dumps(pap, indent=2))
print(f"[§-1 PAP]  MDE Cohen's d = {mde_d:.3f}  →  ≈ ${mde_dollars:,.0f}")

# ════════════════════════════════════════════════════════════════════════════════
# §0.1 Sample-construction log (footnote 4)
# ════════════════════════════════════════════════════════════════════════════════
sample_log: list[tuple[str, int]] = []
raw = pd.read_csv(DATA)
sample_log.append(("0. raw rdatasets csv", len(raw)))

df0 = raw.drop(columns=["rownames"], errors="ignore").dropna()
sample_log.append(("1. drop rownames + dropna", len(df0)))

df1 = df0.copy()
df1["black"]  = (df1["race"] == "black").astype(int)
df1["hispan"] = (df1["race"] == "hispan").astype(int)
sample_log.append(("2. recode race -> black/hispan", len(df1)))

df2 = df1[df1["treat"].isin([0, 1])].copy()
sample_log.append(("3. enforce treat in {0,1}", len(df2)))
df = df2

(ART / "sample_construction.json").write_text(json.dumps(sample_log, indent=2))
print("[§0.1 Sample log]")
for stage, n in sample_log:
    print(f"  {stage:<35s}  N = {n:>4d}")

# ════════════════════════════════════════════════════════════════════════════════
# §0.2 Five-check data contract — go/no-go gate
# ════════════════════════════════════════════════════════════════════════════════
covariates = ["age", "educ", "black", "hispan", "married", "nodegree", "re74", "re75"]
keys = ["re78", "treat"] + covariates
contract = {
    "n_obs":             int(len(df)),
    "dtypes":            df[keys].dtypes.astype(str).to_dict(),
    "n_missing":         {k: int(v) for k, v in df[keys].isna().sum().to_dict().items()},
    "n_dupes_on_keys":   int(df.duplicated().sum()),  # cross-section: row-level dup
    "y_range":           [float(df["re78"].min()), float(df["re78"].max())],
    "treatment_share":   float(df["treat"].mean()),
    "treatment_levels":  sorted(df["treat"].unique().tolist()),
    "panel_balanced":    None,  # cross-section
    "mcar_hint":         "vacuously OK (no missing y after Step 0.1 dropna)",
}
assert contract["n_obs"] > 0
assert all(v == 0 for v in contract["n_missing"].values()), \
    f"NaNs on keys: {contract['n_missing']}"
assert contract["treatment_levels"] == [0, 1], \
    f"treat must be 0/1: {contract['treatment_levels']}"
(ART / "data_contract.json").write_text(json.dumps(contract, indent=2, default=str))
print(f"[§0.2 Contract] N={contract['n_obs']}, treat share={contract['treatment_share']:.3f}, "
      f"y range = [${contract['y_range'][0]:,.0f}, ${contract['y_range'][1]:,.0f}]")

# ════════════════════════════════════════════════════════════════════════════════
# §2.5 Empirical strategy — write strategy.md (pre-registration)
# ════════════════════════════════════════════════════════════════════════════════
strategy_md = f"""# Empirical Strategy — Lalonde NSW (pre-registration)

**Frozen at**: 2026-04-29
**Population**: Lalonde NSW treated workers + PSID comparison sample, 1976–78
**Treatment**: `treat` (binary, NSW assignment)
**Outcome**:   `re78` (1978 real earnings, USD)
**Estimand**:  ATT — average treatment effect on the program's actual participants
**Design**:    selection on observables (cross-sectional X-adjustment)

## Estimating equation (paste from §2.5 row matching the design)

```
re78_i = α + β · treat_i + X_i' γ + ε_i
X_i = (age, educ, black, hispan, married, nodegree, re74, re75)
```

## Identifying assumption

1. **Conditional unconfoundedness**: `Y(0), Y(1) ⊥ D | X` — outside the NSW experiment,
   PSID comparison units differ on observables; conditioning on `X` closes the back door.
2. **Overlap**: 0 < Pr(D=1 | X) < 1 for all X in the joint support — verified in §3
   via the propensity-score overlap plot.

## Auto-flagged threats (must defend in §6 robustness)

- **Selection on unobservables** (motivation, skill not in X) → **Oster δ** in §6
- **Functional-form sensitivity** (linear vs flexible) → progressive M1→M6 + spec curve
- **Outcome scale** (levels vs IHS / log) → robustness rows
- **PSID comparison group choice** (PSID-1 vs CPS-1) → out-of-scope here; flagged

## Fallback estimators (§6 / §7 robustness gauntlet)

- IPW (HC3-corrected) on logistic propensity
- AIPW / DR-Learner (selection-on-observables doubly robust)
- Entropy balancing (matches first 3 moments exactly)
- DML (econml.LinearDML) — partials out X via cross-fitted ML

## Reporting checklist (Step 8)

- Report β̂(ATT) under M1→M6 progressive controls (Pattern A)
- Show convergent evidence: OLS / IPW / PSM / Entropy balancing (Pattern B)
- Attach Oster δ, spec curve, sensitivity dashboard
- Persist `result.json` reproducibility stamp with dataset SHA256 + version pins
"""
(ART / "strategy.md").write_text(strategy_md)
print(f"[§2.5 Strategy] wrote {ART / 'strategy.md'}")

# ════════════════════════════════════════════════════════════════════════════════
# §3.5 Identification graphics — love plot (SMD pre vs post matching) + PS overlap
# ════════════════════════════════════════════════════════════════════════════════
ps_pipe = make_pipeline(StandardScaler(), LogisticRegression(max_iter=2000, random_state=SEED))
ps_pipe.fit(df[covariates], df["treat"])
df["ps"] = ps_pipe.predict_proba(df[covariates])[:, 1]

# 1:1 nearest-neighbour matching on |Δps| within caliper 0.2 SD(ps)
treated  = df[df["treat"] == 1].copy()
controls = df[df["treat"] == 0].copy()
caliper  = 0.2 * df["ps"].std(ddof=1)

matched_idx = []
ctrl_pool = controls.copy()
for _, t in treated.iterrows():
    if ctrl_pool.empty:
        break
    diffs = (ctrl_pool["ps"] - t["ps"]).abs()
    j = diffs.idxmin()
    if diffs.loc[j] <= caliper:
        matched_idx.append(j)
        matched_idx.append(t.name)
        ctrl_pool = ctrl_pool.drop(j)
matched = df.loc[matched_idx].copy()

def smd(a: pd.Series, b: pd.Series) -> float:
    pooled_sd = float(np.sqrt((a.var(ddof=1) + b.var(ddof=1)) / 2))
    return float((a.mean() - b.mean()) / pooled_sd) if pooled_sd > 0 else 0.0

pre_smd  = {c: smd(df.loc[df.treat == 1, c], df.loc[df.treat == 0, c]) for c in covariates}
post_smd = {c: smd(matched.loc[matched.treat == 1, c],
                    matched.loc[matched.treat == 0, c]) for c in covariates}
love = pd.DataFrame({"covariate": covariates,
                     "pre_smd_abs":  [abs(pre_smd[c])  for c in covariates],
                     "post_smd_abs": [abs(post_smd[c]) for c in covariates]})
love = love.sort_values("pre_smd_abs", ascending=True).reset_index(drop=True)

fig, ax = plt.subplots(figsize=(7.5, 4.5))
ypos = np.arange(len(love))
ax.scatter(love["pre_smd_abs"],  ypos, s=70, marker="o", color="#cc4444",
           label="Before matching")
ax.scatter(love["post_smd_abs"], ypos, s=70, marker="D", color="#1f77b4",
           label="After 1:1 PSM")
for i, _ in enumerate(love.itertuples()):
    ax.plot([love["pre_smd_abs"][i], love["post_smd_abs"][i]],
            [i, i], color="gray", alpha=0.4, lw=0.8)
ax.axvline(0.10, ls="--", color="gray", lw=1, alpha=0.6, label="|SMD| = 0.10")
ax.set_yticks(ypos)
ax.set_yticklabels(love["covariate"])
ax.set_xlabel("|Standardized mean difference|")
ax.set_title("Figure 2c. Love plot — covariate balance pre vs post 1:1 PSM")
ax.legend(loc="lower right")
plt.tight_layout()
fig.savefig(FIG / "fig2c_love_plot.pdf")
fig.savefig(FIG / "fig2c_love_plot.png", dpi=300)
plt.close(fig)
print(f"[§3.5] love plot → {FIG / 'fig2c_love_plot.png'}")

# Propensity score overlap
fig, ax = plt.subplots(figsize=(7.5, 4.5))
ax.hist(df.loc[df.treat == 1, "ps"], bins=25, alpha=0.6, density=True,
        color="#1f77b4", label=f"Treated (N={int(df.treat.sum())})")
ax.hist(df.loc[df.treat == 0, "ps"], bins=25, alpha=0.6, density=True,
        color="#cc4444", label=f"Control (N={int((df.treat == 0).sum())})")
ax.set_xlabel("Estimated propensity score Pr(treat=1 | X)")
ax.set_ylabel("Density")
ax.set_title("Figure 2c-bis. Propensity-score overlap (positivity diagnostic)")
ax.legend()
plt.tight_layout()
fig.savefig(FIG / "fig2c2_overlap.pdf")
fig.savefig(FIG / "fig2c2_overlap.png", dpi=300)
plt.close(fig)
print(f"[§3.5] PS overlap → {FIG / 'fig2c2_overlap.png'}")

# ════════════════════════════════════════════════════════════════════════════════
# §4 Main result (re78 in dollars; β̂_OLS with full controls = our anchor)
# ════════════════════════════════════════════════════════════════════════════════
spec_full = ("re78 ~ treat + age + educ + black + hispan + married + nodegree "
             "+ re74 + re75")
m_main = smf.ols(spec_full, data=df).fit(cov_type="HC3")
b_main  = float(m_main.params["treat"])
se_main = float(m_main.bse["treat"])
ci_main = (b_main - 1.96 * se_main, b_main + 1.96 * se_main)
print(f"[§4 Main] β̂(treat) = ${b_main:,.0f}  (HC3 SE = ${se_main:,.0f}, "
      f"95% CI [${ci_main[0]:,.0f}, ${ci_main[1]:,.0f}])")

# ════════════════════════════════════════════════════════════════════════════════
# §6 Pattern H — Robustness master Table A1
# ════════════════════════════════════════════════════════════════════════════════
specs = {
    "(1) Baseline (HC3)":  smf.ols(spec_full, data=df).fit(cov_type="HC3"),
    "(2) HC1 SE":           smf.ols(spec_full, data=df).fit(cov_type="HC1"),
    "(3) Drop top 1% re78": smf.ols(spec_full,
                                     data=df[df["re78"] < df["re78"].quantile(0.99)]
                                     ).fit(cov_type="HC3"),
    "(4) Common support":   smf.ols(spec_full,
                                     data=df[(df["ps"] > 0.05) & (df["ps"] < 0.95)]
                                     ).fit(cov_type="HC3"),
    "(5) Add age² + educ²": smf.ols(spec_full + " + I(age**2) + I(educ**2)",
                                     data=df).fit(cov_type="HC3"),
    "(6) Add re74² + re75²": smf.ols(spec_full + " + I(re74**2) + I(re75**2)",
                                     data=df).fit(cov_type="HC3"),
    "(7) Drop u74 strata":  smf.ols(spec_full,
                                     data=df[df["re74"] > 0]).fit(cov_type="HC3"),
    "(8) Earners only":     smf.ols(spec_full,
                                     data=df[df["re78"] > 0]).fit(cov_type="HC3"),
    "(9) IHS outcome":      smf.ols("I(np.arcsinh(re78)) ~ treat + age + educ + black + hispan + married + nodegree + re74 + re75",
                                     data=df).fit(cov_type="HC3"),
    "(10) Log outcome":     smf.ols("I(np.log1p(re78)) ~ treat + age + educ + black + hispan + married + nodegree + re74 + re75",
                                     data=df).fit(cov_type="HC3"),
}

rob_rows = []
for label, fit in specs.items():
    b = float(fit.params["treat"])
    se = float(fit.bse["treat"])
    p = float(fit.pvalues["treat"])
    rob_rows.append({"spec": label, "beta": b, "se": se, "p": p,
                      "n": int(fit.nobs), "ci_lo": b - 1.96 * se, "ci_hi": b + 1.96 * se})
rob = pd.DataFrame(rob_rows)
rob.to_csv(TBL / "tableA1_robustness.csv", index=False)

# Render LaTeX (book-tab style)
def _star(p: float) -> str:
    return ("$^{***}$" if p < 0.01 else "$^{**}$" if p < 0.05
            else "$^{*}$" if p < 0.10 else "")

lines = [
    "\\begin{tabular}{lrrrrrr}",
    "\\toprule",
    "Spec & $\\hat\\beta_{\\rm treat}$ & SE & $p$ & N & CI lo & CI hi \\\\",
    "\\midrule",
]
for r in rob_rows:
    lines.append(
        f"{r['spec']:<24s} & {r['beta']:>+8.1f}{_star(r['p'])} & {r['se']:>6.1f} & "
        f"{r['p']:.3f} & {r['n']} & {r['ci_lo']:>+8.1f} & {r['ci_hi']:>+8.1f} \\\\"
    )
lines += [
    "\\bottomrule",
    "\\end{tabular}",
]
(TBL / "tableA1_robustness.tex").write_text("\n".join(lines) + "\n")
print(f"[§6 Pattern H] Table A1 → {TBL / 'tableA1_robustness.tex'}  ({len(rob)} rows)")

# Spec-curve figure (sorted β̂ ± 1.96 SE)
ord_rob = rob.sort_values("beta").reset_index(drop=True)
fig, ax = plt.subplots(figsize=(9, 4.5))
ax.errorbar(np.arange(len(ord_rob)), ord_rob["beta"],
            yerr=1.96 * ord_rob["se"], fmt="o", capsize=3,
            color="#1f77b4", ms=5)
ax.axhline(0, ls="--", color="gray", lw=1)
ax.set_xticks(np.arange(len(ord_rob)))
ax.set_xticklabels(ord_rob["spec"], rotation=35, ha="right", fontsize=8)
ax.set_ylabel(r"$\hat\beta_{\rm treat}$  on  re78  ($)")
ax.set_title("Figure 5. Specification curve — β̂(treat) across robustness checks (95% CI)")
plt.tight_layout()
fig.savefig(FIG / "fig5_spec_curve.pdf")
fig.savefig(FIG / "fig5_spec_curve.png", dpi=300)
plt.close(fig)
print(f"[§6 Pattern H] spec curve → {FIG / 'fig5_spec_curve.png'}")

# ════════════════════════════════════════════════════════════════════════════════
# §8 Reproducibility stamp
# ════════════════════════════════════════════════════════════════════════════════
import pyfixest as _pf
import statsmodels as _sm
import sklearn as _sk

dataset_sha256 = hashlib.sha256(
    pd.util.hash_pandas_object(df, index=True).values.tobytes()
).hexdigest()[:16]

stamp = {
    "python_version":     sys.version.split()[0],
    "statsmodels_version": _sm.__version__,
    "pyfixest_version":   _pf.__version__,
    "sklearn_version":    _sk.__version__,
    "seed":               SEED,
    "dataset_sha256_16":  dataset_sha256,
    "n_obs":              int(m_main.nobs),
    "estimand":           "ATT (selection on observables)",
    "estimator":          "OLS with HC3 SE, full covariate set",
    "headline_estimate":  b_main,
    "headline_se":        se_main,
    "headline_ci95":      list(ci_main),
    "pre_registration":   "artifacts/pap.json + artifacts/strategy.md",
    "data_contract":      "artifacts/data_contract.json",
    "sample_log":         "artifacts/sample_construction.json",
    "robustness_master":  "tables/tableA1_robustness.tex",
    "spec_curve":         "figures/fig5_spec_curve.png",
    "love_plot":          "figures/fig2c_love_plot.png",
    "ps_overlap":         "figures/fig2c2_overlap.png",
    "frozen_at":          "2026-04-29",
}
(ART / "result.json").write_text(json.dumps(stamp, indent=2))
print(f"[§8 Stamp] {ART / 'result.json'}  (β̂={b_main:+.1f}, "
      f"95% CI [{ci_main[0]:+.1f}, {ci_main[1]:+.1f}])")

print("\n✓ All v2 artifacts written under", ROOT)

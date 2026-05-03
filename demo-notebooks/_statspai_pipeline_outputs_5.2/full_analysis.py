"""
StatsPAI Full Empirical Analysis — LaLonde (1986) NSW Job Training Data
=======================================================================
Design: IV-2SLS (primary) + OLS + PSM (comparison)
Data:   https://vincentarelbundock.github.io/Rdatasets/csv/MatchIt/lalonde.csv
Output: _statspai_pipeline_outputs_5.2/{figures,tables,artifacts,replication}/

NOTE on IV strategy: The LaLonde data has no natural instrument. We use pre-treatment
earnings (re74, re75) as instruments for training participation — these capture
pre-program labor-market conditions that affect enrollment but are plausibly excluded
from the 1978 earnings equation conditional on covariates. This is a commonly
demonstrated IV approach in the replication literature but should be interpreted
with caution given the well-known weakness of these instruments.
"""

import pandas as pd
import numpy as np
import os, json, warnings, textwrap
from pathlib import Path
warnings.filterwarnings("ignore")

import statspai as sp

# ── Paths ──────────────────────────────────────────────────────────────────────
BASE = Path("/Users/brycewang/Documents/GitHub/Awesome-Agent-Skills-for-Empirical-Research/demo-notebooks/_statspai_pipeline_outputs_5.2")
for d in ["figures", "tables", "artifacts", "replication"]:
    (BASE / d).mkdir(parents=True, exist_ok=True)

SEED = 42
np.random.seed(SEED)

# ═══════════════════════════════════════════════════════════════════════════════
# STEP 0 — Load & Prepare Data
# ═══════════════════════════════════════════════════════════════════════════════
print("=" * 70)
print("STEP 0: Data loading & preparation")
print("=" * 70)

df_raw = pd.read_csv('/tmp/lalonde.csv')
print(f"Raw shape: {df_raw.shape}")

# Sample construction log
sample_log = []
df0 = df_raw.copy();                           sample_log.append(("0. raw", len(df0)))
df = df0.dropna();                              sample_log.append(("1. drop any NaN", len(df)))

# Create derived variables
df['age_sq']    = df['age'] ** 2
df['re74_pos']  = (df['re74'] > 0).astype(int)
df['re75_pos']  = (df['re75'] > 0).astype(int)
df['log_re74']  = np.log1p(df['re74'])
df['log_re75']  = np.log1p(df['re75'])
df['log_re78']  = np.log1p(df['re78'])

# Create race dummies (int 0/1 for IV compatibility)
race_dummies = pd.get_dummies(df['race'], prefix='race', drop_first=False).astype(int)
df = pd.concat([df, race_dummies], axis=1)
print(f"  Race dummies created: {list(race_dummies.columns)}")

with open(BASE / "artifacts" / "sample_construction.json", "w") as f:
    json.dump(sample_log, f, indent=2)
print("Sample construction log saved.")
for step, n in sample_log:
    print(f"  {step}: n={n}")

# ── Data Contract ──────────────────────────────────────────────────────────────
print("\n--- Data Contract ---")
contract = {
    "n_obs":       len(df),
    "n_treated":   int(df['treat'].sum()),
    "n_control":   int((1 - df['treat']).sum()),
    "treatment_share": float(df['treat'].mean()),
    "y_range":     (float(df['re78'].min()), float(df['re78'].max())),
    "y_mean":      float(df['re78'].mean()),
    "columns":     list(df.columns),
    "dtypes":      df.dtypes.astype(str).to_dict(),
    "n_missing":   df.isna().sum().to_dict(),
}
assert contract["n_missing"]["re78"] == 0, "NaN in outcome!"
with open(BASE / "artifacts" / "data_contract.json", "w") as f:
    json.dump(contract, f, indent=2, default=str)
print(f"  n={contract['n_obs']}, treated={contract['n_treated']}, control={contract['n_control']}")
print("  Data contract saved.")

footnote4 = textwrap.dedent(f"""\
    Sample construction (LaLonde 1986, MatchIt R package):
    - Source: NSW experimental treated + CPS/PSID comparison
    - Final analysis sample: {len(df)} individuals
    - Treated (NSW job training): {int(df['treat'].sum())}
    - Control (CPS/PSID comparison): {int((1-df['treat']).sum())}
    - Pre-treatment earnings (1974) mean: ${df['re74'].mean():.0f}
    - Pre-treatment earnings (1975) mean: ${df['re75'].mean():.0f}
    - Outcome: real earnings in 1978
""")
with open(BASE / "artifacts" / "footnote4_sample.txt", "w") as f:
    f.write(footnote4)
print(footnote4)

# ═══════════════════════════════════════════════════════════════════════════════
# STEP 1 — Descriptive Statistics & Table 1
# ═══════════════════════════════════════════════════════════════════════════════
print("=" * 70)
print("STEP 1: Descriptive statistics (Table 1)")
print("=" * 70)

sum_vars = ["re78", "age", "educ", "married", "nodegree", "re74", "re75"]
print(sp.sumstats(df, vars=sum_vars, by="treat", output="text",
                  title="Table 1. Summary statistics by treatment status"))

# AER-style balance table
mc = sp.mean_comparison(
    df, sum_vars, group="treat", test="ttest",
    title="Table 1. Summary statistics by treatment status"
)
mc.to_word(str(BASE / "tables" / "table1_summary.docx"))
mc.to_excel(str(BASE / "tables" / "table1_summary.xlsx"))
with open(BASE / "tables" / "table1_summary.tex", "w") as f:
    f.write(mc.to_latex())
print("  Table 1 exported.")

# Multi-panel Table 1
panels = {
    "A. Outcome":             ["re78", "log_re78"],
    "B. Demographics":        ["age", "educ", "married", "nodegree"],
    "C. Pre-treatment earnings": ["re74", "re75", "log_re74", "log_re75"],
}
c1 = sp.collect("Table 1. Summary statistics (multi-panel)", template="aer")
for label, vs in panels.items():
    c1.add_heading(f"Panel {label}", level=2)
    c1.add_summary(df, vars=vs, stats=["mean", "sd", "n"])
c1.save(str(BASE / "tables" / "table1_panels.docx"))
c1.save(str(BASE / "tables" / "table1_panels.xlsx"))
c1.save(str(BASE / "tables" / "table1_panels.tex"))
print("  Multi-panel Table 1 exported.")

# Figure 1: Earnings distributions
import matplotlib as mpl
mpl.use("Agg")
import matplotlib.pyplot as plt

fig, axes = plt.subplots(1, 3, figsize=(14, 4.5))
for i, (yr, col) in enumerate([("1974", "re74"), ("1975", "re75"), ("1978", "re78")]):
    ax = axes[i]
    for label, grp, color in [("Control (treat=0)", 0, "#3182bd"), ("Treated (treat=1)", 1, "#e6550d")]:
        s = df[df["treat"] == grp][col]
        ax.hist(s, bins=40, alpha=0.55, color=color, label=label, density=True)
    ax.set_xlabel(f"Real earnings {yr} ($)")
    ax.set_ylabel("Density")
    ax.set_title(f"Earnings {yr}")
    ax.legend(fontsize=8)
fig.suptitle("Figure 1. Distribution of earnings by treatment status", fontsize=13, y=1.02)
plt.tight_layout()
fig.savefig(BASE / "figures" / "fig1_earnings_dist.png", dpi=300, bbox_inches="tight")
plt.close()
print("  Figure 1 saved.")

# ═══════════════════════════════════════════════════════════════════════════════
# STEP 2 — Empirical Strategy
# ═══════════════════════════════════════════════════════════════════════════════
print("=" * 70)
print("STEP 2: Empirical strategy")
print("=" * 70)

q = sp.causal_question(
    treatment="treat", outcome="re78", data=df,
    population="low-income males in the US National Supported Work demonstration, 1970s",
    estimand="ATT", design="auto",
    covariates=["age", "educ", "married", "nodegree", "re74", "re75"],
)
plan = q.identify()
print(plan.summary())

eq_str = """Y_i = α + β·D_i + X'γ + ε_i          (OLS)
D_i = π·Z_i + X'δ + u_i             (First stage)
  where Z = [re74, re75], D = treat (training), Y = re78 (earnings)

Identifying assumption: conditional on X, pre-treatment earnings (re74, re75)
affect training participation (relevance) but do not directly affect 1978 earnings
(exclusion restriction, conditional on X).

Fallback: OLS with progressive controls, PSM, and DML for robustness."""

Path(BASE / "artifacts" / "empirical_strategy.md").write_text(
    f"# Empirical Strategy (pre-registration)\n\n"
    f"**Population**: {q.population}\n"
    f"**Treatment**: `{q.treatment}`    **Outcome**: `{q.outcome}`\n"
    f"**Estimand**: ATT\n\n"
    f"## Primary design: IV-2SLS\n```\n{eq_str}\n```\n\n"
    f"## Identification story\n{plan.identification_story}\n\n"
    f"## Fallback estimators\n- OLS with progressive controls\n"
    f"- Propensity-score matching (PSM)\n- Double/debiased ML (DML)\n"
)
Path(BASE / "artifacts" / "causal_question.yaml").write_text(
    q.to_yaml() if hasattr(q, 'to_yaml') else str(q)
)
print("  Empirical strategy saved.")

# ═══════════════════════════════════════════════════════════════════════════════
# STEP 3 — Identification graphics
# ═══════════════════════════════════════════════════════════════════════════════
print("=" * 70)
print("STEP 3: Identification graphics")
print("=" * 70)

from sklearn.linear_model import LogisticRegression

covs = ["age", "educ", "married", "nodegree", "re74", "re75"]

# Figure 2a: Standardized mean differences
treated = df[df["treat"] == 1]
control = df[df["treat"] == 0]
smd = {}
for c in covs:
    m_t, m_c = treated[c].mean(), control[c].mean()
    s_t, s_c = treated[c].std(), control[c].std()
    smd[c] = (m_t - m_c) / np.sqrt((s_t**2 + s_c**2) / 2)

fig, ax = plt.subplots(figsize=(8, 5))
y_pos = range(len(covs))
ax.barh(list(y_pos), [smd[c] for c in covs], color="#3182bd", alpha=0.7)
ax.axvline(0, color="black", linewidth=0.8)
ax.axvline(0.25, color="red", linestyle="--", linewidth=0.8, label="|SMD|=0.25 threshold")
ax.axvline(-0.25, color="red", linestyle="--", linewidth=0.8)
ax.set_yticks(list(y_pos))
ax.set_yticklabels(covs)
ax.set_xlabel("Standardized Mean Difference")
ax.set_title("Figure 2a. Pre-treatment covariate balance")
ax.legend(fontsize=9)
fig.tight_layout()
fig.savefig(BASE / "figures" / "fig2a_balance.png", dpi=300)
plt.close()
print("  Figure 2a (balance) saved.")

# Figure 2b: Propensity score overlap
ps_model = LogisticRegression(C=1e6, max_iter=1000).fit(df[covs], df["treat"])
df["pscore"] = ps_model.predict_proba(df[covs])[:, 1]

fig, ax = plt.subplots(figsize=(8, 5))
for label, grp, color in [("Control", 0, "#3182bd"), ("Treated", 1, "#e6550d")]:
    s = df[df["treat"] == grp]["pscore"]
    ax.hist(s, bins=35, alpha=0.5, density=True, color=color, label=label)
ax.set_xlabel("Estimated propensity score")
ax.set_ylabel("Density")
ax.set_title("Figure 2b. Propensity score overlap")
ax.legend()
fig.tight_layout()
fig.savefig(BASE / "figures" / "fig2b_ps_overlap.png", dpi=300)
plt.close()
print("  Figure 2b (PS overlap) saved.")

# ═══════════════════════════════════════════════════════════════════════════════
# STEP 4 — Main results
# ═══════════════════════════════════════════════════════════════════════════════
print("=" * 70)
print("STEP 4: Main results")
print("=" * 70)

# ── Primary: IV-2SLS (using race dummies, not C(race)) ────────────────────────
print("\n--- IV-2SLS ---")
IV_WORKED = False
try:
    iv_main = sp.ivreg(
        "re78 ~ (treat ~ log_re74 + log_re75) + age + educ + married + nodegree + race_hispan + race_white",
        data=df, robust="hc1"
    )
    print(iv_main.summary())
    IV_WORKED = True
except Exception as e:
    print(f"IV with log_re74/log_re75 failed: {e}")
    try:
        iv_main = sp.ivreg(
            "re78 ~ (treat ~ re74 + re75) + age + educ + married + nodegree + race_hispan + race_white",
            data=df, robust="hc1"
        )
        print(iv_main.summary())
        IV_WORKED = True
    except Exception as e2:
        print(f"IV also failed: {e2}")

# ── OLS: progressive controls ─────────────────────────────────────────────────
print("\n--- OLS progressive controls ---")
M1 = sp.regress("re78 ~ treat",                                          data=df, robust="hc1")
M2 = sp.regress("re78 ~ treat + age + educ + married",                   data=df, robust="hc1")
M3 = sp.regress("re78 ~ treat + age + educ + married + nodegree + re74 + re75", data=df, robust="hc1")
M4 = sp.regress("re78 ~ treat + age + educ + married + nodegree + re74 + re75 + race_hispan + race_white",
                data=df, robust="hc1")

for i, m in enumerate([M1, M2, M3, M4], 1):
    print(f"\n  M{i}: {m.summary()}")

# ── PSM ────────────────────────────────────────────────────────────────────────
print("\n--- Propensity Score Matching ---")
try:
    psm = sp.match(df, y="re78", treat="treat",
                   covariates=["age", "educ", "married", "nodegree", "re74", "re75"],
                   method="nearest")
    print("PSM result:")
    print(psm)
    PSM_WORKED = True
except Exception as e:
    print(f"PSM failed: {e}")
    PSM_WORKED = False

# ── Table 2: Main results ─────────────────────────────────────────────────────
print("\n--- Table 2: Main results regtable ---")
try:
    models_main = [M1, M4]
    model_labels = ["(1) OLS (no controls)", "(2) OLS (full controls)"]
    stats_list = ["N", "R-squared", "DV mean"]

    if IV_WORKED:
        models_main.append(iv_main)
        model_labels.append("(3) IV-2SLS")
        stats_list.append("First-stage F")

    rt = sp.regtable(
        *models_main, template="aer",
        coef_labels={"treat": "Job training (NSW)"},
        model_labels=model_labels, stats=stats_list,
        title="Table 2. Effect of NSW job training on 1978 earnings"
    )
    rt.to_word(str(BASE / "tables" / "table2_main.docx"))
    rt.to_excel(str(BASE / "tables" / "table2_main.xlsx"))
    with open(BASE / "tables" / "table2_main.tex", "w") as f:
        f.write(rt.to_latex())
    print("  Table 2 exported.")
except Exception as e:
    print(f"  Table 2 failed: {e}")
    import traceback; traceback.print_exc()

# ── Figure 3: Coefficient plot ─────────────────────────────────────────────────
print("\n--- Figure 3: Coefficient plot ---")
try:
    fig3, ax3 = sp.coefplot(
        *models_main, model_names=model_labels, variables=["treat"],
        title="Figure 3. Effect of NSW training on earnings — comparison across estimators"
    )
    fig3.savefig(BASE / "figures" / "fig3_coefplot.png", dpi=300)
    plt.close(fig3)
    print("  Figure 3 saved.")
except Exception as e:
    print(f"  coefplot failed: {e}")
    plt.close()

# ═══════════════════════════════════════════════════════════════════════════════
# STEP 5 — Heterogeneity
# ═══════════════════════════════════════════════════════════════════════════════
print("=" * 70)
print("STEP 5: Heterogeneity analysis")
print("=" * 70)

slices = {
    "(1) Full sample":   df,
    "(2) Married":       df[df["married"] == 1],
    "(3) Not married":   df[df["married"] == 0],
    "(4) No degree":     df[df["nodegree"] == 1],
    "(5) Has degree":    df[df["nodegree"] == 0],
}

gmodels, slice_labels = [], []
for label, d in slices.items():
    if len(d) < 50:
        continue
    try:
        m = sp.regress("re78 ~ treat + age + educ + married + nodegree + re74 + re75",
                       data=d, robust="hc1")
        gmodels.append(m)
        slice_labels.append(label)
    except Exception as e:
        print(f"  {label} failed: {e}")

if len(gmodels) >= 2:
    rt = sp.regtable(*gmodels, template="aer",
                     coef_labels={"treat": "Training"},
                     model_labels=slice_labels, stats=["N", "R-squared"],
                     title="Table 3. Heterogeneous effects of NSW training")
    rt.to_word(str(BASE / "tables" / "table3_heterogeneity.docx"))
    rt.to_excel(str(BASE / "tables" / "table3_heterogeneity.xlsx"))
    with open(BASE / "tables" / "table3_heterogeneity.tex", "w") as f:
        f.write(rt.to_latex())
    print("  Table 3 exported.")
else:
    print("  Not enough subgroups for Table 3.")

# Figure 4: Treatment effect by education
fig, ax = plt.subplots(figsize=(8, 5))
for edu_lvl in sorted(df['educ'].unique()):
    sub = df[df['educ'] == edu_lvl]
    if len(sub) < 10:
        continue
    m_t = sub[sub['treat'] == 1]['re78'].mean()
    m_c = sub[sub['treat'] == 0]['re78'].mean()
    ax.scatter(edu_lvl, m_t - m_c, s=60, color="#3182bd", zorder=5)

ax.set_xlabel("Years of education")
ax.set_ylabel("Treatment effect (ATE per education level)")
ax.set_title("Figure 4. Treatment effect heterogeneity by education")
ax.axhline(0, color="gray", linestyle="--", alpha=0.5)
fig.tight_layout()
fig.savefig(BASE / "figures" / "fig4_heterogeneity.png", dpi=300)
plt.close()
print("  Figure 4 saved.")

# ═══════════════════════════════════════════════════════════════════════════════
# STEP 6 — Mechanisms
# ═══════════════════════════════════════════════════════════════════════════════
print("=" * 70)
print("STEP 6: Mechanisms")
print("=" * 70)
print("  LaLonde data has limited mediation variables — skipped.")
print("  (No post-treatment mediator available in this dataset.)")

# ═══════════════════════════════════════════════════════════════════════════════
# STEP 7 — Robustness Gauntlet
# ═══════════════════════════════════════════════════════════════════════════════
print("=" * 70)
print("STEP 7: Robustness gauntlet")
print("=" * 70)

rob_models = {}
try:
    rob_models["(1) Baseline"] = M4
    rob_models["(2) Drop top 1% earnings"] = sp.regress(
        "re78 ~ treat + age + educ + married + nodegree + re74 + re75 + race_hispan + race_white",
        data=df[df["re78"] < df["re78"].quantile(0.99)], robust="hc1")
    rob_models["(3) White only"] = sp.regress(
        "re78 ~ treat + age + educ + married + nodegree + re74 + re75",
        data=df[df["race"] == "white"], robust="hc1")
    rob_models["(4) Non-white only"] = sp.regress(
        "re78 ~ treat + age + educ + married + nodegree + re74 + re75",
        data=df[df["race"] != "white"], robust="hc1")
    rob_models["(5) Drop zero earners"] = sp.regress(
        "re78 ~ treat + age + educ + married + nodegree + re74 + re75 + race_hispan + race_white",
        data=df[df["re78"] > 0], robust="hc1")
    rob_models["(6) Log outcome"] = sp.regress(
        "log_re78 ~ treat + age + educ + married + nodegree + log_re74 + log_re75 + race_hispan + race_white",
        data=df, robust="hc1")

    print(f"  Robustness: {len(rob_models)} specs estimated.")
    for name, m in rob_models.items():
        if hasattr(m, 'params') and 'treat' in m.params:
            idx = list(m.params.index).index('treat')
            print(f"    {name}: β={m.params['treat']:.2f} (p={m.pvalues[idx]:.3f})")

    # Table A1
    rt_rob = sp.regtable(*rob_models.values(), template="aer",
                         coef_labels={"treat": "Training", "log_re78": "Training"},
                         model_labels=list(rob_models),
                         stats=["N", "R-squared"],
                         title="Table A1. Robustness — effect of NSW training")
    rt_rob.to_word(str(BASE / "tables" / "tableA1_robustness.docx"))
    rt_rob.to_excel(str(BASE / "tables" / "tableA1_robustness.xlsx"))
    with open(BASE / "tables" / "tableA1_robustness.tex", "w") as f:
        f.write(rt_rob.to_latex())
    print("  Table A1 exported.")
except Exception as e:
    print(f"  Robustness table failed: {e}")
    import traceback; traceback.print_exc()

# 7.1 Oster bounds
print("\n--- Oster bounds ---")
try:
    oster = sp.oster_bounds(
        data=df, y="re78", treat="treat",
        controls=["age", "educ", "married", "nodegree", "re74", "re75"],
        r_max=1.3
    )
    print(f"  Oster bounds: {oster}")
    with open(BASE / "tables" / "oster_bounds.txt", "w") as f:
        f.write(str(oster))
except Exception as e:
    print(f"  Oster bounds failed: {e}")

# 7.2 E-value
print("\n--- E-value ---")
try:
    if hasattr(M4, 'params') and 'treat' in M4.params:
        ev = sp.evalue(
            estimate=M4.params["treat"],
            ci=tuple(M4.conf_int().loc["treat"]),
            measure="RR"
        )
        print(f"  E-value: {ev}")
        with open(BASE / "tables" / "evalue.txt", "w") as f:
            f.write(str(ev))
except Exception as e:
    print(f"  E-value failed: {e}")

# 7.3 Figure 5: Robustness forest
print("\n--- Figure 5: Robustness forest ---")
try:
    rob_list = list(rob_models.values())
    rob_labels = list(rob_models.keys())
    fig5, ax5 = sp.coefplot(*rob_list, model_names=rob_labels, variables=["treat"],
                            title="Figure 5. Robustness forest — β̂ across specifications")
    fig5.savefig(BASE / "figures" / "fig5_robustness_forest.png", dpi=300)
    plt.close(fig5)
    print("  Figure 5 saved.")
except Exception as e:
    print(f"  coefplot forest failed: {e}")
    # manual fallback
    fig, ax = plt.subplots(figsize=(9, 6))
    coefs_r, ses_r, labs_r = [], [], []
    for name, m in rob_models.items():
        if hasattr(m, 'params') and 'treat' in m.params:
            coefs_r.append(m.params['treat'])
            ses_r.append(m.bse['treat'])
            labs_r.append(name)
    if coefs_r:
        yp = range(len(coefs_r))
        ax.errorbar(coefs_r, yp, xerr=1.96*np.array(ses_r), fmt='o', capsize=5, markersize=8)
        ax.axvline(0, color='red', linestyle='--', alpha=0.5)
        ax.set_yticks(list(yp)); ax.set_yticklabels(labs_r)
        ax.set_xlabel("Treatment effect (β̂)")
        ax.set_title("Figure 5. Robustness forest")
        fig.tight_layout()
        fig.savefig(BASE / "figures" / "fig5_robustness_forest.png", dpi=300)
    plt.close()
    print("  Figure 5 saved (manual fallback).")

# ═══════════════════════════════════════════════════════════════════════════════
# STEP 8 — Replication Package
# ═══════════════════════════════════════════════════════════════════════════════
print("=" * 70)
print("STEP 8: Replication package")
print("=" * 70)

c = sp.collect("LaLonde NSW Training — Replication Package", template="aer")

c.add_heading("§1. Descriptive statistics", level=1)
c.add_summary(df, vars=sum_vars, stats=["mean", "sd", "n"],
              title="Table 1. Summary statistics")
c.add_balance(df, treatment="treat", variables=sum_vars,
              title="Table 1b. Balance by treatment status")

c.add_heading("§2. Main results", level=1)
try:
    c.add_regression(*models_main, model_labels=model_labels,
                     stats=stats_list,
                     title="Table 2. Effect of NSW training on 1978 earnings")
except Exception:
    pass

c.add_heading("§3. Heterogeneity", level=1)
if gmodels:
    c.add_regression(*gmodels, model_labels=slice_labels,
                     title="Table 3. Heterogeneous effects")

c.add_heading("§4. Robustness", level=1)
if rob_models:
    c.add_regression(*rob_models.values(), model_labels=list(rob_models),
                     title="Table A1. Robustness")

c.add_text("Standard errors: HC1 robust. *** p<0.01, ** p<0.05, * p<0.10. "
           "Data: LaLonde (1986) via MatchIt R package. "
           "Analysis generated with StatsPAI.", title="Notes")

try:
    c.save(str(BASE / "replication" / "paper.docx"))
    c.save(str(BASE / "replication" / "paper.xlsx"))
    c.save(str(BASE / "replication" / "paper.tex"))
    c.save(str(BASE / "replication" / "paper.md"))
    print("  Replication bundle saved.")
except Exception as e:
    print(f"  Replication partial: {e}")

# Reproducibility stamp
rep_stamp = {
    "statspai":          sp.__version__,
    "seed":              SEED,
    "n_obs":             len(df),
    "n_treated":         int(df['treat'].sum()),
    "n_control":         int((1-df['treat']).sum()),
    "y_mean_ctrl":       float(df[df['treat']==0]['re78'].mean()),
    "y_mean_treated":    float(df[df['treat']==1]['re78'].mean()),
    "estimand":          "ATT",
    "estimate_ols":      float(M4.params['treat']),
    "pre_registration":  "artifacts/empirical_strategy.md",
    "data_contract":     "artifacts/data_contract.json",
    "sample_log":        "artifacts/sample_construction.json",
}
if IV_WORKED and hasattr(iv_main, 'params') and 'treat' in iv_main.params:
    rep_stamp["estimate_iv"] = float(iv_main.params['treat'])

with open(BASE / "artifacts" / "result_reproducibility.json", "w") as f:
    json.dump(rep_stamp, f, indent=2)
print("  Reproducibility stamp saved.")

# ═══════════════════════════════════════════════════════════════════════════════
# SUMMARY
# ═══════════════════════════════════════════════════════════════════════════════
print("\n" + "=" * 70)
print("ANALYSIS COMPLETE — Output Inventory")
print("=" * 70)
all_files = []
for root, dirs, files in os.walk(BASE):
    for f in files:
        if f.endswith('.py'):
            continue
        rel = os.path.relpath(os.path.join(root, f), BASE)
        all_files.append(f"  {rel}")
all_files.sort()
print("\n".join(all_files))
print("\n" + "=" * 70)

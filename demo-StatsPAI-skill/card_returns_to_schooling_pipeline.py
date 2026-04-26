"""
Card (1995) — Returns to schooling, full StatsPAI empirical pipeline
====================================================================

A one-file reproduction of the Card (1995) "Geographic Variation in
College Proximity to Estimate the Return to Schooling" study, organized
around the AER-style empirical pipeline described in StatsPAI's
``00-Full-empirical-analysis-skill_StatsPAI`` skill.

Outcome     : lwage   (log of hourly wage, 1976)
Treatment   : educ    (years of completed schooling)
Instrument  : nearc4  (grew up in county with a 4-year college)
Controls    : exper, expersq, black, south, smsa, smsa66, region dummies

Pipeline sections (each writes artifacts under ``demo-StatsPAI-skill/``):

    Step 0      Data contract + sample-construction log
    Step 1      Table 1 summary statistics
    Step 2      Empirical strategy (estimand-first DSL + identification plan)
    Step 3      Identification graphics (first-stage scatter, IV diagnostics)
    Step 4      Main results — OLS progressive controls, IV reporting triplet,
                design horse race, multi-outcome, coefficient plot
    Step 5      Heterogeneity (Table 3 by race / region / SMSA + CATE)
    Step 7      Robustness gauntlet (Oster, sensitivity, spec curve, master table)
    Step 8      Replication bundle + reproducibility stamp

Run:
    python card_returns_to_schooling_pipeline.py

The script is deterministic given the bundled ``data/card.csv``.
"""

from __future__ import annotations

import json
import os
import warnings
from pathlib import Path

import matplotlib
matplotlib.use("Agg")  # headless safe
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import statspai as sp

warnings.filterwarnings("ignore")

# --------------------------------------------------------------------------
# Paths
# --------------------------------------------------------------------------
ROOT = Path(__file__).resolve().parent
DATA = ROOT / "data" / "card.csv"
FIG = ROOT / "figures"
TAB = ROOT / "tables"
ART = ROOT / "artifacts"
REP = ROOT / "replication"
for p in (FIG, TAB, ART, REP):
    p.mkdir(parents=True, exist_ok=True)


def _save(obj, path):
    """Save whatever a StatsPAI plotter returned (Figure, Axes, or tuple)."""
    fig = None
    if hasattr(obj, "savefig"):
        fig = obj
    elif hasattr(obj, "figure"):
        fig = obj.figure
    elif isinstance(obj, tuple):
        for x in obj:
            if hasattr(x, "savefig"):
                fig = x
                break
            if hasattr(x, "figure"):
                fig = x.figure
                break
    if fig is None:
        fig = plt.gcf()
    fig.savefig(path, dpi=200, bbox_inches="tight")
    plt.close("all")


# ==========================================================================
# Step 0 — Sample construction & data contract
# ==========================================================================
print("\n[Step 0] Data contract & sample construction")
df_raw = pd.read_csv(DATA)

REGION_DUMMIES = [f"reg66{i}" for i in range(2, 10)]  # reg662-reg669 (reg661 = base)
CONTROLS_CORE = ["exper", "expersq", "black", "south", "smsa"]
CONTROLS_FULL = CONTROLS_CORE + ["smsa66"] + REGION_DUMMIES

sample_log = []
df0 = df_raw.copy()
sample_log.append(("0. raw NLSYM extract", len(df0)))

df1 = df0.dropna(subset=["lwage", "educ", "nearc4"])
sample_log.append(("1. drop missing lwage / educ / nearc4", len(df1)))

df2 = df1.dropna(subset=CONTROLS_CORE)
sample_log.append(("2. drop missing core controls", len(df2)))

df3 = df2[df2["educ"].between(1, 18)]
sample_log.append(("3. keep educ in [1, 18]", len(df3)))

df = df3.reset_index(drop=True)
sample_log.append(("4. final analysis sample", len(df)))

# Persist the sample log (footnote 4)
(ART / "sample_construction.json").write_text(json.dumps(sample_log, indent=2))
for label, n in sample_log:
    print(f"  {label:<45s} n = {n}")


def data_contract(df, *, y, treatment, covariates, instrument=None):
    keys = [y, treatment] + list(covariates) + ([instrument] if instrument else [])
    c = {
        "n_obs": len(df),
        "dtypes": df[keys].dtypes.astype(str).to_dict(),
        "n_missing": df[keys].isna().sum().to_dict(),
        "y_range": [float(df[y].min()), float(df[y].max())],
        "treatment_range": [float(df[treatment].min()), float(df[treatment].max())],
    }
    if instrument is not None:
        c["instrument_share"] = float(df[instrument].mean())
        c["instrument_y_corr"] = float(df[[instrument, y]].corr().iloc[0, 1])
        c["instrument_t_corr"] = float(df[[instrument, treatment]].corr().iloc[0, 1])
    return c


contract = data_contract(
    df, y="lwage", treatment="educ",
    covariates=CONTROLS_FULL, instrument="nearc4",
)
(ART / "data_contract.json").write_text(json.dumps(contract, indent=2, default=str))
assert all(v == 0 for v in contract["n_missing"].values()), contract["n_missing"]
print(f"  contract OK — n={contract['n_obs']}, "
      f"corr(nearc4, lwage)={contract['instrument_y_corr']:+.3f}, "
      f"corr(nearc4, educ)={contract['instrument_t_corr']:+.3f}")


# ==========================================================================
# Step 1 — Descriptive statistics (Table 1)
# ==========================================================================
print("\n[Step 1] Table 1 — Summary statistics by college proximity")

table1_vars = [
    "lwage", "wage", "educ", "exper", "age",
    "black", "south", "smsa", "smsa66",
    "fatheduc", "motheduc", "IQ",
]

# Plain-text preview for the log
print(sp.sumstats(df, vars=["lwage", "educ", "exper", "black"],
                  by="nearc4", output="text"))

mc = sp.mean_comparison(
    df, table1_vars,
    group="nearc4", test="ttest",
    title="Table 1. Summary statistics by college proximity (Card, 1995)",
)
mc.to_word(str(TAB / "table1_summary.docx"))
mc.to_excel(str(TAB / "table1_summary.xlsx"))
(TAB / "table1_summary.tex").write_text(mc.to_latex())

# Auto-codebook for the appendix
sp.describe(df).to_markdown(str(ART / "codebook.md"))

# Figure 1 — distribution of education by college-proximity group
fig, axes = plt.subplots(1, 2, figsize=(11, 4))
for k, (label, ax) in enumerate(zip(["Far from 4-yr college", "Near 4-yr college"], axes)):
    ax.hist(df.loc[df["nearc4"] == k, "educ"], bins=range(1, 20),
            edgecolor="white", color=("#4C72B0" if k == 0 else "#DD8452"))
    ax.set_title(f"{label}  (n = {(df['nearc4'] == k).sum():,})")
    ax.set_xlabel("Years of completed schooling")
    ax.set_ylabel("Frequency")
    ax.axvline(df.loc[df["nearc4"] == k, "educ"].mean(),
               color="black", linestyle="--", linewidth=1.0,
               label=f"mean = {df.loc[df['nearc4'] == k, 'educ'].mean():.2f}")
    ax.legend(loc="upper left")
fig.suptitle("Figure 1. Education distribution by 4-year college proximity",
             fontsize=12, y=1.02)
fig.tight_layout()
_save(fig, FIG / "fig1_education_by_proximity.png")
print("  wrote tables/table1_summary.{docx,xlsx,tex} and figures/fig1_education_by_proximity.png")


# ==========================================================================
# Step 2 — Empirical strategy
# ==========================================================================
print("\n[Step 2] Empirical strategy & identification plan")

q = sp.causal_question(
    treatment="educ", outcome="lwage", data=df,
    population="NLSYM men aged 24-34 in 1976, with non-missing wage and education",
    estimand="LATE",
    design="iv",
    instruments=["nearc4"],
    covariates=CONTROLS_FULL,
)
plan = q.identify()
plan_text = ""
try:
    plan_text = plan.summary()
except Exception:
    plan_text = repr(plan)
print(plan_text[:1200])

bullets = lambda xs: "\n".join(f"- {x}" for x in (xs or [])) or "- (none)"
strategy_md = f"""# Empirical Strategy (pre-registration)

**Population**: {q.population}
**Treatment** : `educ` (years of schooling, continuous, 1-18)
**Outcome**   : `lwage` (log hourly wage, 1976)
**Instrument**: `nearc4` (1 if grew up in county with 4-yr college)
**Estimand**  : LATE — return to one extra year of schooling for the
sub-population whose schooling decision was changed by the proximity instrument.
**Estimator** : `sp.ivreg` (2SLS with cluster-robust SE)

## Estimating equation

First stage  : educ_i = pi_0 + pi_1 nearc4_i + X_i' gamma + u_i
Second stage : lwage_i = beta_0 + beta_1 educ_i_hat + X_i' delta + e_i

Controls X: exper, expersq, black, south, smsa, smsa66, region dummies (reg662-reg669).

## Identification story

College proximity (`nearc4`) is assumed to shift the cost of acquiring
education without affecting wages directly, so it identifies a LATE among
"compliers" whose schooling decision is sensitive to college access. Card
(1995) defends this exclusion restriction by conditioning on region,
SMSA-66 residence and family-background controls.

## Identifying assumptions (must defend in §2)

- Relevance: cov(nearc4, educ | X) != 0 — verified in the first stage F-stat.
- Exclusion: nearc4 affects lwage only through educ, conditional on X.
- Independence: nearc4 is as-good-as-randomly assigned conditional on X.
- Monotonicity: no defiers (proximity weakly increases schooling).

## Auto-flagged warnings

{bullets(getattr(plan, "warnings", []))}

## Fallback estimators (Step 7 robustness)

- OLS with progressive controls (selection-on-observables benchmark).
- DML — partially-linear regression with random forest nuisance models.
- Oster (2019) bound — proportional selection on unobservables.
- Cinelli-Hazlett sensitivity contour for the OLS estimate.
"""
(ART / "empirical_strategy.md").write_text(strategy_md)
try:
    (ART / "causal_question.yaml").write_text(q.to_yaml())
except Exception as e:
    (ART / "causal_question.yaml").write_text(f"# could not serialize: {e}\n")
print("  wrote artifacts/empirical_strategy.md and artifacts/causal_question.yaml")


# ==========================================================================
# Step 3 — Identification graphics
# ==========================================================================
print("\n[Step 3] Identification graphics")

# 3.1 First-stage binscatter: nearc4 → educ (after partialling out controls)
try:
    bs = sp.binscatter(
        df, y="educ", x="nearc4",
        controls=CONTROLS_CORE,
        n_bins=10, ci=True,
    )
    _save(bs, FIG / "fig2a_first_stage_binscatter.png")
except Exception as e:
    print(f"  [warn] binscatter: {e} — falling back to bar chart")
    means = df.groupby("nearc4")["educ"].agg(["mean", "std", "count"])
    means["se"] = means["std"] / np.sqrt(means["count"])
    fig, ax = plt.subplots(figsize=(6, 4))
    ax.bar(["Far", "Near"], means["mean"], yerr=1.96 * means["se"],
           color=["#4C72B0", "#DD8452"], capsize=8)
    ax.set_ylabel("Years of schooling")
    ax.set_title("First stage: educ by college proximity (95% CI)")
    _save(fig, FIG / "fig2a_first_stage_binscatter.png")

# 3.2 First-stage regression
fs = sp.regress(
    "educ ~ nearc4 + " + " + ".join(CONTROLS_FULL),
    df, robust="hc1",
)
print("  first-stage on nearc4 (with controls):")
print(f"    coef = {fs.params['nearc4']:+.4f}")
fs_se = float(fs.std_errors["nearc4"])
fs_t = fs.params["nearc4"] / fs_se
print(f"    se   = {fs_se:.4f}")
print(f"    t    = {fs_t:+.3f}   (≈ first-stage F = {fs_t**2:.2f})")

# 3.3 Reduced form: nearc4 → lwage
rf = sp.regress(
    "lwage ~ nearc4 + " + " + ".join(CONTROLS_FULL),
    df, robust="hc1",
)
print(f"  reduced-form effect of nearc4 on lwage = {rf.params['nearc4']:+.4f} "
      f"(se = {float(rf.std_errors['nearc4']):.4f})")

# Wald-ratio sanity check
wald = float(rf.params["nearc4"] / fs.params["nearc4"])
print(f"  Wald-ratio implied 2SLS coefficient on educ = {wald:+.4f}")

# 3.4 Lwage by education — visual identification
fig, ax = plt.subplots(figsize=(7, 4.5))
agg = df.groupby("educ")["lwage"].agg(["mean", "count"]).reset_index()
agg = agg[agg["count"] >= 20]  # cells with enough obs
ax.scatter(agg["educ"], agg["mean"], s=20 + agg["count"] / 5,
           color="#4C72B0", alpha=0.85)
m, b = np.polyfit(df["educ"], df["lwage"], 1)
xs = np.linspace(df["educ"].min(), df["educ"].max(), 100)
ax.plot(xs, m * xs + b, color="#DD8452", linewidth=2,
        label=f"OLS fit: slope = {m:.3f}")
ax.set_xlabel("Years of completed schooling")
ax.set_ylabel("Mean log wage")
ax.set_title("Figure 2b. Mincer wage equation — raw data")
ax.legend()
_save(fig, FIG / "fig2b_mincer.png")
print("  wrote figures/fig2a_first_stage_binscatter.png and figures/fig2b_mincer.png")


# ==========================================================================
# Step 4 — Main results
# ==========================================================================
print("\n[Step 4] Main results — Table 2")

# 4.1 Pattern A: progressive controls (OLS Mincer)
M1 = sp.regress("lwage ~ educ", df, robust="hc1")
M2 = sp.regress("lwage ~ educ + exper + expersq", df, robust="hc1")
M3 = sp.regress("lwage ~ educ + exper + expersq + black + south + smsa",
                df, robust="hc1")
M4 = sp.regress("lwage ~ educ + " + " + ".join(CONTROLS_FULL),
                df, robust="hc1")

rt2 = sp.regtable(
    M1, M2, M3, M4,
    template="aer",
    coef_labels={"educ": "Years of schooling"},
    model_labels=["(1) Bivariate", "(2) +Mincer", "(3) +Demog.", "(4) +Region FE"],
    stats=["N", "R2"],
    title="Table 2. OLS Mincer wage equation — progressive controls",
)
rt2.to_word(str(TAB / "table2_main_ols.docx"))
rt2.to_excel(str(TAB / "table2_main_ols.xlsx"))
(TAB / "table2_main_ols.tex").write_text(rt2.to_latex())

# 4.2 Pattern E: IV reporting triplet (first stage / reduced form / 2SLS)
iv = sp.ivreg(
    "lwage ~ exper + expersq + black + south + smsa + smsa66 + "
    + " + ".join(REGION_DUMMIES) + " + (educ ~ nearc4)",
    df, robust="hc1",
)

rt2e = sp.regtable(
    fs, rf, iv,
    template="aer",
    keep=["nearc4", "educ"],
    coef_labels={"nearc4": "Near 4-yr college", "educ": "Years of schooling"},
    dep_var_labels=["educ", "lwage", "lwage"],
    model_labels=["(1) First stage", "(2) Reduced form", "(3) 2SLS"],
    stats=["N", "R2"],
    title="Table 2-bis. IV reporting triplet — Card (1995)",
)
rt2e.to_word(str(TAB / "table2b_iv_triplet.docx"))
rt2e.to_excel(str(TAB / "table2b_iv_triplet.xlsx"))
(TAB / "table2b_iv_triplet.tex").write_text(rt2e.to_latex())

# 4.3 Pattern B: design horse race (OLS / IV / DML)
ols = M4
try:
    dml = sp.dml(df, y="lwage", treat="educ",
                 covariates=CONTROLS_FULL, model="plr")
except Exception as e:
    print(f"  [warn] DML failed: {e}")
    dml = None

models_for_horserace = [m for m in (ols, iv, dml) if m is not None]
labels_for_horserace = [lbl for lbl, m in zip(
    ["(1) OLS+Region FE", "(2) 2SLS (nearc4)", "(3) DML-PLR"],
    (ols, iv, dml),
) if m is not None]
rt2c = sp.regtable(
    *models_for_horserace,
    template="aer",
    coef_labels={"educ": "Years of schooling (β̂)"},
    model_labels=labels_for_horserace,
    stats=["N"],
    title="Table 2-ter. Convergent evidence across designs",
)
rt2c.to_word(str(TAB / "table2c_design_horserace.docx"))
rt2c.to_excel(str(TAB / "table2c_design_horserace.xlsx"))
(TAB / "table2c_design_horserace.tex").write_text(rt2c.to_latex())

# 4.4 Pattern C: multi-outcome (lwage levels & wage levels)
ys = ["lwage", "wage"]
multi_y = [
    sp.regress(f"{y} ~ educ + " + " + ".join(CONTROLS_FULL),
               df, robust="hc1") for y in ys
]
rt2d = sp.regtable(
    *multi_y,
    template="aer",
    coef_labels={"educ": "Years of schooling"},
    dep_var_labels=ys,
    model_labels=[f"({i+1})" for i in range(len(ys))],
    stats=["N", "R2"],
    title="Table 2-quater. Effect on log-wage and wage levels",
)
rt2d.to_word(str(TAB / "table2d_multi_outcome.docx"))
rt2d.to_excel(str(TAB / "table2d_multi_outcome.xlsx"))
(TAB / "table2d_multi_outcome.tex").write_text(rt2d.to_latex())

# 4.5 Coefficient plot (Figure 3)
try:
    cp = sp.coefplot(
        M1, M2, M3, M4, iv,
        model_names=["(1)", "(2)", "(3)", "(4)", "IV"],
        variables=["educ"],
        title="Figure 3. β̂ on years of schooling across specifications",
        alpha=0.05,
    )
    _save(cp, FIG / "fig3_coefplot_main.png")
except Exception as e:
    print(f"  [warn] coefplot: {e} — falling back to manual errorbar")
    fig, ax = plt.subplots(figsize=(8, 4.5))
    specs = ["(1) Bivar.", "(2) +Mincer", "(3) +Demog.", "(4) +RegFE", "(5) 2SLS"]
    betas = [M1.params["educ"], M2.params["educ"], M3.params["educ"],
             M4.params["educ"], iv.params["educ"]]
    ses = [float(M1.std_errors["educ"]), float(M2.std_errors["educ"]),
           float(M3.std_errors["educ"]), float(M4.std_errors["educ"]),
           float(iv.std_errors["educ"])]
    y = np.arange(len(specs))
    ax.errorbar(betas, y, xerr=1.96 * np.array(ses), fmt="o",
                color="#4C72B0", capsize=4)
    ax.axvline(0, color="black", linewidth=0.8)
    ax.set_yticks(y, specs)
    ax.invert_yaxis()
    ax.set_xlabel("β̂ on educ (95% CI)")
    ax.set_title("Figure 3. β̂ on years of schooling across specifications")
    _save(fig, FIG / "fig3_coefplot_main.png")
print("  wrote tables/table2_main_ols, table2b_iv_triplet, "
      "table2c_design_horserace, table2d_multi_outcome and figures/fig3_coefplot_main.png")


# ==========================================================================
# Step 5 — Heterogeneity (Table 3 + CATE)
# ==========================================================================
print("\n[Step 5] Heterogeneity — Table 3")

slices = {
    "(1) All": df,
    "(2) Black": df[df["black"] == 1],
    "(3) Non-black": df[df["black"] == 0],
    "(4) South": df[df["south"] == 1],
    "(5) Non-south": df[df["south"] == 0],
    "(6) SMSA": df[df["smsa"] == 1],
    "(7) Non-SMSA": df[df["smsa"] == 0],
}

g_models = [
    sp.regress("lwage ~ educ + " + " + ".join(CONTROLS_CORE), d, robust="hc1")
    for d in slices.values()
]
rt3 = sp.regtable(
    *g_models,
    template="aer",
    coef_labels={"educ": "Years of schooling"},
    model_labels=list(slices),
    stats=["N", "R2"],
    title="Table 3. Heterogeneous returns to schooling",
)
rt3.to_word(str(TAB / "table3_heterogeneity.docx"))
rt3.to_excel(str(TAB / "table3_heterogeneity.xlsx"))
(TAB / "table3_heterogeneity.tex").write_text(rt3.to_latex())

# Interaction-form heterogeneity
H1 = sp.regress("lwage ~ educ*black + exper + expersq + south + smsa", df, robust="hc1")
H2 = sp.regress("lwage ~ educ*south + exper + expersq + black + smsa", df, robust="hc1")
H3 = sp.regress("lwage ~ educ*smsa + exper + expersq + black + south", df, robust="hc1")
rt3b = sp.regtable(
    H1, H2, H3,
    template="aer",
    keep=["educ", "educ:black", "educ:south", "educ:smsa"],
    model_labels=["(1) ×Black", "(2) ×South", "(3) ×SMSA"],
    stats=["N", "R2"],
    title="Table 3-bis. Interaction-form heterogeneity",
)
rt3b.to_word(str(TAB / "table3b_interactions.docx"))
rt3b.to_excel(str(TAB / "table3b_interactions.xlsx"))
(TAB / "table3b_interactions.tex").write_text(rt3b.to_latex())

# Subgroup dispatcher (one-liner)
try:
    sub = sp.subgroup_analysis(
        df,
        formula="lwage ~ educ + exper + expersq + black + south + smsa",
        x="educ",
        by={"black": "black", "south": "south", "smsa": "smsa"},
        robust="hc1",
    )
    if hasattr(sub, "to_csv"):
        sub.to_csv(str(TAB / "table3c_subgroup_dispatcher.csv"), index=False)
    else:
        (TAB / "table3c_subgroup_dispatcher.txt").write_text(str(sub))
except Exception as e:
    print(f"  [warn] subgroup_analysis: {e}")

# CATE via meta-learner (treat educ as binarised "completed college")
try:
    df_b = df.copy()
    df_b["college"] = (df_b["educ"] >= 16).astype(int)
    ml = sp.metalearner(
        df_b, y="lwage", treat="college",
        covariates=["exper", "expersq", "black", "south", "smsa", "smsa66",
                    "fatheduc", "motheduc"],
        learner="dr",
    )
    cp_hist = sp.cate_plot(
        ml, kind="hist",
        title="Figure 4a. Distribution of conditional ATE — completed college vs not",
    )
    _save(cp_hist, FIG / "fig4a_cate_hist.png")

    g = sp.cate_by_group(ml, df_b.assign(black=df_b["black"]),
                         by="black", n_groups=2)
    if hasattr(g, "to_csv"):
        g.to_csv(str(TAB / "table4_cate_by_black.csv"), index=False)
    cp_grp = sp.cate_group_plot(g, title="Figure 4b. CATE by race")
    _save(cp_grp, FIG / "fig4b_cate_by_group.png")
except Exception as e:
    print(f"  [warn] CATE block skipped: {e}")
print("  wrote tables/table3_heterogeneity, table3b_interactions and figures/fig4a_cate_hist.png")


# ==========================================================================
# Step 7 — Robustness gauntlet
# ==========================================================================
print("\n[Step 7] Robustness gauntlet")

baseline = M4

# 7.1 Oster (2019) selection bound for the OLS estimate
oster_text = ""
try:
    ob = sp.oster_bounds(
        data=df, y="lwage", treat="educ",
        controls=CONTROLS_FULL, r_max=1.3,
    )
    oster_text += f"Oster β* (δ=1, R̃²=1.3·R²): {ob}\n"
except Exception as e:
    oster_text += f"oster_bounds failed: {e}\n"
try:
    od = sp.oster_delta(
        data=df, y="lwage",
        x_base=["educ"], x_controls=CONTROLS_FULL, r_max=1.3,
    )
    oster_text += f"Oster δ (β=0): {od}\n"
except Exception as e:
    oster_text += f"oster_delta failed: {e}\n"
(ART / "oster.txt").write_text(oster_text)
print("  Oster:\n", oster_text)

# 7.2 Cinelli–Hazlett unified sensitivity
try:
    sens = sp.unified_sensitivity(
        baseline, r2_treated=0.05, r2_controlled=0.10, include_oster=True,
    )
    (ART / "unified_sensitivity.txt").write_text(str(sens))
except Exception as e:
    print(f"  [warn] unified_sensitivity: {e}")

try:
    dash = sp.sensitivity_dashboard(baseline)
    _save(dash, FIG / "fig6_sensitivity_dashboard.png")
except Exception as e:
    print(f"  [warn] sensitivity_dashboard: {e}")

# 7.3 E-value
try:
    ev = sp.evalue(
        estimate=float(baseline.params["educ"]),
        ci=tuple(baseline.conf_int().loc["educ"]),
        measure="OLS",
    )
    (ART / "evalue.txt").write_text(str(ev))
except Exception as e:
    (ART / "evalue.txt").write_text(f"evalue failed: {e}\n")

# 7.4 Spec curve
try:
    sc = sp.spec_curve(
        df, y="lwage", x="educ",
        controls=[
            ["exper", "expersq"],
            ["exper", "expersq", "black"],
            ["exper", "expersq", "black", "south"],
            ["exper", "expersq", "black", "south", "smsa"],
            CONTROLS_FULL,
        ],
        se_types=["robust"],
        subsets={
            "all": None,
            "south": df["south"].eq(1),
            "non_south": df["south"].eq(0),
            "smsa": df["smsa"].eq(1),
            "non_smsa": df["smsa"].eq(0),
        },
    )
    sc_fig = sc.plot(title="Figure 5. Specification curve — return to schooling")
    _save(sc_fig, FIG / "fig5_spec_curve.png")
except Exception as e:
    print(f"  [warn] spec_curve: {e}")

# 7.5 Robustness master table (Table A1)
rob_models = {}
rob_models["(1) Baseline OLS"] = baseline
rob_models["(2) +Family bg"] = sp.regress(
    "lwage ~ educ + " + " + ".join(CONTROLS_FULL + ["fatheduc", "motheduc"]),
    df.dropna(subset=["fatheduc", "motheduc"]), robust="hc1",
)
rob_models["(3) Drop top 1% wage"] = sp.regress(
    "lwage ~ educ + " + " + ".join(CONTROLS_FULL),
    df[df["wage"] < df["wage"].quantile(0.99)], robust="hc1",
)
rob_models["(4) Drop bottom 1% wage"] = sp.regress(
    "lwage ~ educ + " + " + ".join(CONTROLS_FULL),
    df[df["wage"] > df["wage"].quantile(0.01)], robust="hc1",
)
rob_models["(5) Black only"] = sp.regress(
    "lwage ~ educ + " + " + ".join(CONTROLS_CORE),
    df[df["black"] == 1], robust="hc1",
)
rob_models["(6) Non-black"] = sp.regress(
    "lwage ~ educ + " + " + ".join(CONTROLS_CORE),
    df[df["black"] == 0], robust="hc1",
)
rob_models["(7) IQ-controlled"] = sp.regress(
    "lwage ~ educ + IQ + " + " + ".join(CONTROLS_FULL),
    df.dropna(subset=["IQ"]), robust="hc1",
)
rob_models["(8) 2SLS (nearc4)"] = iv
try:
    rob_models["(9) 2SLS (nearc2+nearc4)"] = sp.ivreg(
        "lwage ~ exper + expersq + black + south + smsa + smsa66 + "
        + " + ".join(REGION_DUMMIES) + " + (educ ~ nearc2 + nearc4)",
        df, robust="hc1",
    )
except Exception as e:
    print(f"  [warn] 2SLS w/ both instruments: {e}")
if dml is not None:
    rob_models["(10) DML-PLR"] = dml

rob_keys = list(rob_models.keys())
rob_vals = list(rob_models.values())
rt_rob = sp.regtable(
    *rob_vals,
    template="aer",
    coef_labels={"educ": "Years of schooling"},
    model_labels=rob_keys,
    stats=["N"],
    title="Table A1. Robustness of the return-to-schooling estimate",
)
rt_rob.to_word(str(TAB / "tableA1_robustness.docx"))
rt_rob.to_excel(str(TAB / "tableA1_robustness.xlsx"))
(TAB / "tableA1_robustness.tex").write_text(rt_rob.to_latex())

# Forest plot of every robustness β̂
try:
    fp = sp.coefplot(
        *rob_vals, model_names=rob_keys, variables=["educ"],
        title="Figure 5-bis. β̂ on educ across robustness specifications",
        alpha=0.05,
    )
    _save(fp, FIG / "fig5b_robustness_forest.png")
except Exception as e:
    print(f"  [warn] coefplot for robustness: {e} — falling back")
    fig, ax = plt.subplots(figsize=(8, 0.4 * len(rob_vals) + 1.5))
    betas = [m.params["educ"] for m in rob_vals]
    ses = [float(m.std_errors["educ"]) for m in rob_vals]
    y = np.arange(len(rob_vals))
    ax.errorbar(betas, y, xerr=1.96 * np.array(ses), fmt="o",
                color="#4C72B0", capsize=4)
    ax.axvline(0, color="black", linewidth=0.8)
    ax.set_yticks(y, rob_keys)
    ax.invert_yaxis()
    ax.set_xlabel("β̂ on educ (95% CI)")
    ax.set_title("Figure 5-bis. Robustness forest plot")
    _save(fig, FIG / "fig5b_robustness_forest.png")
print(f"  wrote tableA1_robustness.{{docx,xlsx,tex}} and fig5b_robustness_forest.png "
      f"({len(rob_vals)} specs)")


# ==========================================================================
# Step 8 — Replication bundle
# ==========================================================================
print("\n[Step 8] Replication bundle")

c = sp.collect("Card (1995) — Returns to schooling, replication", template="aer")
c.add_heading("§1. Descriptive statistics", level=1)
c.add_summary(
    df, vars=table1_vars, stats=["mean", "sd", "n"],
    title="Table 1. Summary statistics",
)
c.add_balance(
    df, treatment="nearc4",
    variables=["educ", "exper", "black", "south", "smsa",
               "smsa66", "fatheduc", "motheduc"],
    title="Table 1b. Balance by college proximity",
)
c.add_heading("§2-3. Empirical strategy", level=1)
c.add_text(
    "We estimate the Mincer wage equation by OLS and instrument years of "
    "schooling with a binary indicator for growing up in a county with a "
    "4-year college (Card, 1995). All controls and region dummies follow "
    "Card's Table 2.",
    title="Methods",
)
c.add_heading("§4. Main results", level=1)
c.add_regression(
    M1, M2, M3, M4,
    model_labels=["(1)", "(2)", "(3)", "(4)"],
    stats=["N", "R2"],
    title="Table 2. OLS Mincer wage equation",
)
c.add_regression(
    fs, rf, iv,
    keep=["nearc4", "educ"],
    model_labels=["First stage", "Reduced form", "2SLS"],
    title="Table 2-bis. IV reporting triplet",
)
c.add_heading("§5. Heterogeneity", level=1)
c.add_regression(
    *g_models,
    model_labels=list(slices),
    title="Table 3. Heterogeneous effects",
)
c.add_heading("§7. Robustness", level=1)
c.add_regression(
    *rob_vals,
    model_labels=rob_keys,
    title="Table A1. Robustness gauntlet",
)
c.add_text(
    "Heteroskedasticity-robust standard errors (HC1) in parentheses. "
    "*** p<0.01, ** p<0.05, * p<0.10. Sample restrictions and variable "
    "definitions documented in artifacts/sample_construction.json and "
    "artifacts/data_contract.json.",
    title="Notes",
)
for ext in ("docx", "xlsx", "tex", "md"):
    try:
        c.save(str(REP / f"paper.{ext}"))
    except Exception as e:
        print(f"  [warn] could not save paper.{ext}: {e}")

# Reproducibility stamp
stamp = {
    "statspai": sp.__version__,
    "n_obs": len(df),
    "estimand_OLS": float(M4.params["educ"]),
    "estimand_OLS_ci95": [float(x) for x in M4.conf_int().loc["educ"]],
    "estimand_2SLS": float(iv.params["educ"]),
    "estimand_2SLS_ci95": [float(x) for x in iv.conf_int().loc["educ"]],
    "first_stage_F_approx": float(fs_t ** 2),
    "wald_ratio": wald,
    "pre_registration": "artifacts/empirical_strategy.md",
    "data_contract": "artifacts/data_contract.json",
    "sample_log": "artifacts/sample_construction.json",
    "paper_bundle": "replication/paper.docx",
}
(ART / "result.json").write_text(json.dumps(stamp, indent=2))
print(json.dumps(stamp, indent=2))

print("\nAll artifacts written under demo-StatsPAI-skill/.")

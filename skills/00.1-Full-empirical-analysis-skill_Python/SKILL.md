---
name: Full-empirical-analysis-skill
description: Classical end-to-end empirical analysis workflow in the traditional Python econometric stack — pandas + numpy + scipy + statsmodels + linearmodels + pyfixest + rdrobust + econml + causalml + matplotlib/seaborn. **Defaults to economics empirical-paper style** — every run produces a publication-ready output set with a multi-column regression table (M1→M6 progressive controls/FE) as the centerpiece, plus Table 1 (descriptives), mechanism / heterogeneity / robustness tables, and event-study + coefficient + trend figures. Covers the full 8-step pipeline an applied economist or quantitative social scientist runs on every paper — (1) data cleaning, (2) variable construction & transformation, (3) descriptive statistics & Table 1, (4) statistical diagnostic tests, (5) baseline empirical modeling, (6) robustness battery, (7) further analysis (mechanism, heterogeneity, mediation, moderation), (8) publication-ready tables & figures. Prescribes which library to reach for at each step, shows the canonical code, and links to deeper `references/` files for variant-specific patterns. Use when the user asks for a **complete empirical analysis** in Python, wants to replicate an applied-economics paper from scratch, needs a reproducible workflow that is NOT opinionated on any single vertical package (contrast with StatsPAI), wants explicit control over every estimator and diagnostic, or asks "how do I write a full empirical pipeline in Python?". Also triggers when the user names a specific classical step in isolation — "winsorize at 1/99%", "run Breusch-Pagan", "build a Table 1 balance table", "do a placebo test", "event study plot", "mediation analysis" — and wants it wired into the broader pipeline.
triggers:
  - full empirical analysis in Python
  - classical econometrics pipeline
  - traditional Python econometrics
  - end-to-end empirical workflow
  - pandas statsmodels linearmodels workflow
  - replicate an applied economics paper
  - data cleaning empirical
  - winsorize and standardize
  - variable construction
  - Table 1 summary statistics
  - balance table
  - correlation matrix
  - normality test
  - heteroskedasticity test
  - autocorrelation test
  - stationarity test
  - multicollinearity VIF
  - endogeneity test
  - baseline regression
  - panel fixed effects
  - DID workflow Python
  - event study
  - instrumental variables regression
  - regression discontinuity
  - propensity score matching
  - synthetic control python
  - double machine learning
  - robustness checks
  - placebo test
  - specification curve
  - alternative clustering
  - heterogeneity analysis
  - mechanism analysis
  - mediation analysis
  - moderation analysis
  - publication-ready regression table
  - coefplot
  - binscatter
  - event study plot
---

# Full Empirical Analysis — Classical Python Workflow

This skill is the *canonical* 8-step pipeline an applied economist runs on every empirical paper, written in the **traditional Python ecosystem** — no opinionated one-stop wrapper. Every step calls libraries directly (`pandas`, `numpy`, `scipy`, `statsmodels`, `linearmodels`, `pyfixest`, `rdrobust`, `econml`, `causalml`, `matplotlib`, `seaborn`), so the agent — or the user reading the agent's code — has full visibility and can swap any component.

**Companion skill**: if the user prefers a single-import agent-native DSL (`import statspai as sp`), route to `00-StatsPAI_skill` instead. **This skill is the opposite philosophy**: everything explicit, everything inspectable, every diagnostic run by hand, every plot shaped by the user.

## Philosophy

1. **Traditional stack, no magic.** Agents should be able to read every line and know exactly which library / estimator / standard error family is at work.
2. **Full pipeline, not just estimation.** 80% of the time on a real paper is steps 1–4 and 6–8. This skill treats them as first-class, not an afterthought.
3. **Rich outputs.** Every step produces at least one table or figure — never a single point estimate in isolation.
4. **Progressive disclosure.** SKILL.md gives the canonical call at each step; `references/` holds variant-specific depth (dozens of tests, estimator-specific diagnostics, plot recipes).
5. **Reproducible.** Every code block is runnable after `pip install -r requirements.txt` and `df = pd.read_csv(...)`.

---

## Default Output Spec — Economics Empirical Paper

This skill defaults to the **applied-economics paper convention**. Unless the user explicitly asks for a single point estimate, every run produces the full publication-ready output set below. Treat it as the contract of Step 8 — **mandatory**, not opt-in.

### Required tables (always produced)

| # | Table | Source / library | Saves to |
|---|---|---|---|
| **T1** | Summary statistics & balance (treated vs control, with SMD / p-values) | `pandas.describe` + custom `table1()` (Step 3) | `tables/table1_balance.tex` (+ `.docx`) |
| **T2** ★ | **Main results — multi-column regression M1→M6** (progressive controls + FE) | `pyfixest.feols` × 6 specs → `pf.etable()` / `Stargazer` (Step 5–6) | `tables/table2_main.tex` (+ `.docx`) |
| **T3** | Mechanism / outcome ladder — same treatment, 3+ outcomes side-by-side | `feols` looped over `y ∈ {Y1, Y2, Y3, Y_main}` → `pf.etable` | `tables/table3_mechanism.tex` |
| **T4** | Heterogeneity — subgroup × main coef (gender, age, region, …) | subgroup `feols` × Wald → `pf.etable` (Step 7) | `tables/table4_heterogeneity.tex` |
| **T5** | Robustness battery — alt SE / alt cluster / alt sample / placebo, in **one** table | `feols` × variants → `pf.etable` (Step 6) | `tables/table5_robustness.tex` |

> **★ Table 2 is the centerpiece of every economics paper.** It is the multi-column regression table that walks the reader from raw correlation (M1) to the fully-specified design (M6: 2-way FE + interacted FE + cluster-robust SE). Do **not** collapse it into a single column. Do **not** report only the headline coefficient. The progression *is* the credibility argument: if M1→M6 is monotone and stable, the design is plausibly identifying; if it collapses on adding FE, that *is* the result.
>
> **Canonical 6 columns, in order:**
> 1. **M1** raw bivariate (`y ~ treat`)
> 2. **M2** + demographics (`+ age + edu`)
> 3. **M3** + sector controls (`+ tenure / firm_size / industry`)
> 4. **M4** + unit FE (`| worker_id`)
> 5. **M5** + 2-way FE (`| worker_id + year`)
> 6. **M6** + interacted FE (`| worker_id + year + industry^year`) with cluster-robust SE

### Required figures (always produced)

| # | Figure | Source / library | Saves to |
|---|---|---|---|
| **F1** | Trend / motivation — treated vs control over time, with policy line | `df.groupby([year, treat])[y].mean().unstack().plot()` (Step 3) | `figures/fig1_trend.pdf` (+ `.png`) |
| **F2** | Event-study coefficients with 95% CI, base period at –1 | `pf.feols(... ~ i(rel_time, ref=-1) ...)` → `pf.iplot()` (Step 5) | `figures/fig2_event_study.pdf` |
| **F3** | Coefficient plot across specs M1→M6 | `matplotlib.errorbar` over the 6 fitted models (Step 8) | `figures/fig3_coefplot.pdf` |
| **F4** | Robustness / sensitivity curve — spec curve, HonestDiD, or cluster-comparison | spec_curve loop or `honest_did` plot (Step 6) | `figures/fig4_sensitivity.pdf` |

### Output file layout (default)

```
project/
├── tables/    table1_balance.{tex,docx}    table2_main.{tex,docx}
│              table3_mechanism.tex         table4_heterogeneity.tex
│              table5_robustness.tex
└── figures/   fig1_trend.{pdf,png}         fig2_event_study.{pdf,png}
               fig3_coefplot.{pdf,png}      fig4_sensitivity.{pdf,png}
```

Every table → `.tex` (LaTeX `booktabs`) **and** `.docx`. Every figure → `.pdf` (vector for LaTeX) **and** `.png` at ≥300 dpi.

### When to deviate

- **Single quick estimate** — produce only the relevant cell, but warn that the standard deliverable is the full set above and offer to run it.
- **Design does not support a figure** (cross-section → no event study) — skip with a printed note explaining why; do **not** silently drop.
- **N=1 treated unit (synthetic control)** — replace F1/F2 with the SCM trajectory + placebo distribution; T1–T5 still apply.

---

## Required Libraries

```bash
pip install pandas numpy scipy matplotlib seaborn \
            statsmodels linearmodels pyfixest \
            rdrobust rddensity \
            econml causalml \
            stargazer  # publication-ready regression tables
# Optional but commonly needed:
pip install missingno   # missing-data visualization
pip install pyreadstat  # Stata .dta / SPSS .sav import
pip install arch        # GARCH, unit-root tests, HAC
pip install pingouin    # clean stats tests wrapper
pip install pysynth     # synthetic control (N=1 treated)
```

---

## The 8 Steps — Canonical Pipeline

```
┌──────────────────────────────────────────────────────────────────────┐
│ Step 1  Data cleaning              missing / outliers / dtype / join │
│ Step 2  Variable construction      log / winsorize / std / encode    │
│ Step 3  Descriptive statistics     Table 1 / corr / distribution     │
│ Step 4  Diagnostic tests           normality / hetero / autocorr / VIF│
│ Step 5  Baseline modeling          OLS / panel / IV / DID / RD / SC  │
│ Step 6  Robustness battery         placebo / subsample / spec curve  │
│ Step 7  Further analysis           mechanism / heterogeneity / mediation│
│ Step 8  Tables & figures           stargazer / coefplot / event study│
└──────────────────────────────────────────────────────────────────────┘
```

Below is the canonical code at each step. **All examples share one running narrative** — a labor-economics panel where `training` (treatment) affects `log_wage` (outcome), with covariates `age`, `edu`, `tenure`, panel keys `worker_id` / `firm_id` / `year`. Column names and parameter values are **illustrative** — substitute the real ones from the user's DataFrame. Only library names and call shapes are normative.

> **When a step has many variants** (e.g. staggered DID has five different estimators; heteroskedasticity has four classic tests), SKILL.md shows the one you reach for first and links to `references/NN-<topic>.md` for the rest. **Read the reference file when the user's case doesn't fit the default.**

---

### Step 1 — Data cleaning

Deeper patterns: [references/01-data-cleaning.md](references/01-data-cleaning.md) — missing-value strategies (MCAR/MAR/MNAR), outlier detection (IQR / z-score / Mahalanobis), dtype coercion, merging gotchas, panel-structure validation, deduplication.

```python
import pandas as pd
import numpy as np

df = pd.read_csv("raw.csv")

# 1a. Inspect — always do this first
df.info()                          # dtypes + non-null counts
df.describe(include="all").T       # numeric + categorical
df.isna().mean().sort_values(ascending=False)  # missingness share per column

# 1b. Fix dtypes (strings-that-should-be-numeric are the #1 silent bug)
df["year"]   = pd.to_numeric(df["year"],   errors="coerce")
df["wage"]   = pd.to_numeric(df["wage"],   errors="coerce")
df["gender"] = df["gender"].astype("category")
df["date"]   = pd.to_datetime(df["date"],  errors="coerce")

# 1c. Missing values — decide PER VARIABLE, never blanket-drop
key_vars = ["wage", "training", "worker_id", "year"]
df = df.dropna(subset=key_vars)                       # drop rows missing on keys
df["tenure"] = df["tenure"].fillna(df["tenure"].median())  # median-impute numeric covariate
df["union"]  = df["union"].fillna("unknown")               # explicit "unknown" for categorical

# 1d. Outliers — flag first, winsorize in Step 2
df["wage_z"] = (df["wage"] - df["wage"].mean()) / df["wage"].std()
outlier_mask = df["wage_z"].abs() > 4
print(f"{outlier_mask.sum()} rows flagged as |z|>4 on wage")

# 1e. Deduplicate on the panel key
dupes = df.duplicated(subset=["worker_id", "year"], keep=False)
assert dupes.sum() == 0, f"{dupes.sum()} duplicate (worker_id, year) pairs"

# 1f. Merge auxiliary data — use validate= to catch silent m:m blowups
df = df.merge(firm_chars, on="firm_id", how="left", validate="many_to_one")

# 1g. Panel structure check — balanced vs. unbalanced
panel_summary = df.groupby("worker_id")["year"].agg(["count", "min", "max"])
print(panel_summary.describe())
is_balanced = (panel_summary["count"] == panel_summary["count"].max()).all()
print(f"Balanced: {is_balanced}")
```

**Key principle**: `pandas` + explicit decisions. **Never** silently drop rows inside an estimator — all row exclusions happen in Step 1 with a printed count.

---

### Step 2 — Variable construction & transformation

Deeper patterns: [references/02-data-transformation.md](references/02-data-transformation.md) — log/ihs/Box–Cox, winsorizing vs. trimming, within-group standardization, one-hot vs. ordinal vs. target encoding, interaction terms, lag/lead operators, first differences, deflation with CPI.

```python
# 2a. Log / IHS transform (skewed positive variables)
df["log_wage"] = np.log(df["wage"].clip(lower=1))             # floor at 1 to avoid -inf
df["ihs_assets"] = np.arcsinh(df["assets"])                    # handles zero / negative

# 2b. Winsorize (top/bottom 1%) — reduces outlier influence without dropping rows
from scipy.stats.mstats import winsorize
df["wage_w"] = winsorize(df["wage"], limits=[0.01, 0.01]).data

# 2c. Standardize (z-score) — for interpretability or ML
df["age_std"] = (df["age"] - df["age"].mean()) / df["age"].std()

# 2d. Categorical encoding
df = pd.get_dummies(df, columns=["industry"], prefix="ind", drop_first=True)

# 2e. Interaction & polynomial
df["age_sq"]          = df["age"] ** 2
df["training_x_edu"]  = df["training"] * df["edu"]

# 2f. Panel operators — first difference, lag, lead, within-group mean
df = df.sort_values(["worker_id", "year"])
df["wage_l1"]   = df.groupby("worker_id")["log_wage"].shift(1)      # lag
df["wage_f1"]   = df.groupby("worker_id")["log_wage"].shift(-1)     # lead
df["d_wage"]    = df.groupby("worker_id")["log_wage"].diff()        # Δy_it
df["wage_mean"] = df.groupby("worker_id")["log_wage"].transform("mean")  # within-unit mean

# 2g. Treatment timing variables for staggered DID
df["first_treat_year"] = df.groupby("worker_id")["training"] \
                           .transform(lambda s: s.idxmax() if s.any() else np.nan)
df["rel_time"] = df["year"] - df["first_treat_year"]
```

---

### Step 3 — Descriptive statistics & Table 1

Deeper patterns: [references/03-descriptive-stats.md](references/03-descriptive-stats.md) — stratified Table 1 with SMDs, weighted descriptives, distributional comparison (ECDF, QQ), correlation heatmaps + clustering, panel balance checks, time-series seasonality plots.

```python
import seaborn as sns
import matplotlib.pyplot as plt

# 3a. Full-sample summary — classic "Table 1, column 1"
stats = df[["log_wage","age","edu","tenure","training"]].describe().T
stats["N"] = df[["log_wage","age","edu","tenure","training"]].notna().sum()
print(stats[["N","mean","std","min","25%","50%","75%","max"]])

# 3b. Stratified Table 1 (treated vs. control + t-test / SMD)
from scipy import stats as sps
def table1(df, by, cols):
    rows = []
    for c in cols:
        t, ctrl = df.loc[df[by]==1, c], df.loc[df[by]==0, c]
        smd = (t.mean() - ctrl.mean()) / np.sqrt((t.var()+ctrl.var())/2)
        p = sps.ttest_ind(t.dropna(), ctrl.dropna(), equal_var=False).pvalue
        rows.append([c, t.mean(), t.std(), ctrl.mean(), ctrl.std(), smd, p])
    return pd.DataFrame(rows, columns=["var","treat_mean","treat_sd",
                                       "ctrl_mean","ctrl_sd","SMD","p"])
t1 = table1(df, by="training", cols=["log_wage","age","edu","tenure"])
print(t1.round(3))

# 3c. Correlation heatmap
corr = df[["log_wage","age","edu","tenure","training"]].corr()
sns.heatmap(corr, annot=True, cmap="RdBu_r", center=0, vmin=-1, vmax=1)
plt.tight_layout(); plt.savefig("fig_corr.pdf")

# 3d. Distribution plot — density by treatment status
fig, ax = plt.subplots(figsize=(6,4))
for g, sub in df.groupby("training"):
    sub["log_wage"].plot.kde(ax=ax, label=f"training={g}")
ax.set_xlabel("log wage"); ax.legend(); plt.savefig("fig_dist.pdf")

# 3e. Time trends — treated vs. control (the DID motivation plot)
trend = df.groupby(["year","training"])["log_wage"].mean().unstack()
trend.plot(marker="o"); plt.ylabel("mean log wage"); plt.savefig("fig_trend.pdf")

# 3f. Panel balance diagnostic — how many units observed each year?
df.groupby("year")["worker_id"].nunique().plot(kind="bar")
plt.ylabel("# unique workers"); plt.savefig("fig_panel_balance.pdf")
```

---

### Step 4 — Diagnostic statistical tests

Deeper patterns: [references/04-statistical-tests.md](references/04-statistical-tests.md) — every classical test with its null/alternative/decision rule (Shapiro–Wilk, Kolmogorov–Smirnov, Jarque–Bera, Breusch–Pagan, White, Goldfeld–Quandt, Durbin–Watson, Breusch–Godfrey, Ljung–Box, ADF, KPSS, Phillips–Perron, VIF, condition number, Hausman, Wu–Hausman, Sargan–Hansen).

Run diagnostics **before** taking estimates at face value. The 5 classes below cover 90% of applied work.

```python
import statsmodels.api as sm
from statsmodels.stats.diagnostic import (
    het_breuschpagan, het_white, acorr_breusch_godfrey, acorr_ljungbox,
)
from statsmodels.stats.outliers_influence import variance_inflation_factor
from statsmodels.stats.stattools import durbin_watson, jarque_bera
from scipy import stats as sps

# Fit a baseline OLS to get residuals for diagnostics
X = sm.add_constant(df[["training","age","edu","tenure"]])
y = df["log_wage"]
ols = sm.OLS(y, X, missing="drop").fit()

# 4a. Normality of residuals (informative but NOT required for OLS — CLT handles large N)
jb_stat, jb_p, skew, kurt = jarque_bera(ols.resid)
sw_stat, sw_p = sps.shapiro(ols.resid.sample(min(5000, len(ols.resid))))
print(f"Jarque-Bera p={jb_p:.3f}   Shapiro p={sw_p:.3f}   skew={skew:.2f}  kurt={kurt:.2f}")

# 4b. Heteroskedasticity — Breusch-Pagan + White
bp = het_breuschpagan(ols.resid, ols.model.exog)
wh = het_white        (ols.resid, ols.model.exog)
print(f"Breusch-Pagan p={bp[1]:.3f}   White p={wh[1]:.3f}")
# → if p<0.05, use robust / cluster-robust SEs (you already should)

# 4c. Autocorrelation (time-series / panel) — Durbin-Watson + Breusch-Godfrey + Ljung-Box
dw = durbin_watson(ols.resid)                                # ~2 = no AR(1)
bg = acorr_breusch_godfrey(ols, nlags=4)                     # general AR(p)
lb = acorr_ljungbox(ols.resid, lags=[4,8], return_df=True)
print(f"Durbin-Watson={dw:.2f}   Breusch-Godfrey p={bg[1]:.3f}")
print(lb)

# 4d. Multicollinearity — VIF + condition number
vif = pd.DataFrame({
    "var":  X.columns,
    "VIF":  [variance_inflation_factor(X.values, i) for i in range(X.shape[1])]
})
print(vif)                              # VIF > 10 is the classic red flag
cond_number = np.linalg.cond(X.values)  # > 30 = potential collinearity
print(f"Condition number = {cond_number:.1f}")

# 4e. Stationarity (time-series) — ADF + KPSS (dual test: ADF rejects unit root, KPSS accepts stationarity)
from statsmodels.tsa.stattools import adfuller, kpss
adf_stat, adf_p, *_       = adfuller(df["log_wage"].dropna(), autolag="AIC")
kpss_stat, kpss_p, *_     = kpss   (df["log_wage"].dropna(), regression="c", nlags="auto")
print(f"ADF p={adf_p:.3f}   KPSS p={kpss_p:.3f}")
```

**Decision table** (classic rules of thumb):

| Test | Null | Action if rejected |
|------|------|-------------------|
| Jarque–Bera / Shapiro | residuals ~ Normal | usually ignore when N large; bootstrap CIs if small-N inference matters |
| Breusch–Pagan / White | homoskedastic errors | use `cov_type="HC3"` or cluster SEs |
| Durbin–Watson / Breusch–Godfrey | no autocorrelation | use HAC (Newey–West) or cluster by unit |
| VIF > 10 / cond# > 30 | — | drop / combine collinear regressors |
| ADF rejects + KPSS fails to reject | series is stationary | fit levels |
| ADF fails to reject | unit root | first-difference or cointegration test |

---

### Step 5 — Baseline empirical modeling

Deeper patterns: [references/05-modeling.md](references/05-modeling.md) — every classical estimator with API: OLS, WLS, GLS, logit/probit, panel FE / RE / PO, clustered SEs, 2SLS / LIML / GMM, DID (2×2, TWFE, event study, CS, SA, BJS, SDiD), RD (sharp, fuzzy, kink, multi-cutoff), Synthetic Control, PSM / IPW / EB, DML / causal forest / DR-Learner.

**Pick the estimator by identification strategy** (not by "what's trendy"):

```
Observational cross-section, selection on observables  →  OLS + controls  |  PSM / IPW / DML
Observational panel, policy shock, parallel trends     →  DID (TWFE / CS / SA / BJS / SDiD)
Exogenous instrument for endogenous X                  →  2SLS / LIML / GMM (linearmodels / pyfixest)
Discontinuity in assignment rule                       →  Sharp / Fuzzy / Kink RD (rdrobust)
N=1 treated unit, long panel                           →  Synthetic Control (pysynth / SDiD)
High-dim controls or heterogeneous effects             →  DML / Causal Forest (econml)
Binary outcome                                         →  Logit / Probit (statsmodels)
Count outcome                                          →  Poisson / NegBin (pyfixest / statsmodels)
```

Canonical calls (details in [references/05-modeling.md](references/05-modeling.md)):

```python
import statsmodels.formula.api as smf
import pyfixest as pf
from linearmodels.iv import IV2SLS
from rdrobust import rdrobust

# 5a. OLS with cluster-robust SEs (use when no FE or just one FE)
ols = smf.ols("log_wage ~ training + age + edu + tenure", data=df).fit(
    cov_type="cluster", cov_kwds={"groups": df["firm_id"]})
print(ols.summary())

# 5b. Panel FE (unit + time) — reach for pyfixest first; fastest & mirrors R's fixest
fe = pf.feols("log_wage ~ training + age + edu + tenure | worker_id + year",
              data=df, vcov={"CRV1": "worker_id"})
fe.summary()

# 5c. 2×2 DID
did = smf.ols("log_wage ~ treated * post + age + edu", data=df).fit(
    cov_type="cluster", cov_kwds={"groups": df["worker_id"]})

# 5d. Event study (dynamic DID, base period = −1)
es = pf.feols("log_wage ~ i(rel_time, ref=-1) | worker_id + year",
              data=df, vcov={"CRV1": "worker_id"})
pf.iplot(es)

# 5e. Staggered DID — Callaway–Sant'Anna (via diff-diff) OR Sun–Abraham (via pyfixest interactions)
#     See references/05-modeling.md §5.4 for the full staggered DID playbook.

# 5f. IV / 2SLS
iv = IV2SLS.from_formula(
    "log_wage ~ 1 + age + edu + [training ~ draft_lottery]", data=df
).fit(cov_type="clustered", clusters=df["firm_id"])
print(iv.first_stage)    # first-stage F > 10 (ideally > 104)
print(iv.summary)

# 5g. Sharp RD
rd = rdrobust(y=df["outcome"], x=df["running_var"], c=0,
              kernel="triangular", bwselect="mserd")
print(rd)

# 5h. Binary outcome
logit = smf.logit("employed ~ training + age + edu", data=df).fit()
print(logit.summary())
print(logit.get_margeff().summary())   # marginal effects — the interpretable quantity
```

---

### Step 6 — Robustness battery

Deeper patterns: [references/06-robustness.md](references/06-robustness.md) — alternative specifications (add/drop controls), subsample splits, alternative clustering levels, alternative outcome definitions, placebo tests (fake treatment / fake timing / permutation), specification curve, Oster δ\*, randomization inference, leave-one-out, winsorization sensitivity.

Every headline result in the paper needs a robustness appendix. The canonical 6:

```python
# 6a. Alternative specifications — progressive controls (M1 → M6)
specs = [
    "log_wage ~ training",                                               # M1 raw
    "log_wage ~ training + age + edu",                                   # M2 +covariates
    "log_wage ~ training + age + edu + tenure",                          # M3 +tenure
    "log_wage ~ training + age + edu + tenure | worker_id",              # M4 +unit FE
    "log_wage ~ training + age + edu + tenure | worker_id + year",       # M5 +time FE
    "log_wage ~ training + age + edu + tenure | worker_id + year + industry^year",  # M6 +industry×year
]
results = [pf.feols(f, data=df, vcov={"CRV1":"worker_id"}) for f in specs]
pf.etable(results)          # side-by-side publication table

# 6b. Alternative cluster levels
for cl in ["worker_id", "firm_id", "industry", "state"]:
    r = pf.feols("log_wage ~ training | worker_id+year", data=df, vcov={"CRV1": cl})
    print(cl, r.coef()["training"], r.se()["training"])

# 6c. Subsample splits
for col in ["male", "has_college", "high_tenure"]:
    for val in [0, 1]:
        sub = df[df[col]==val]
        r = pf.feols("log_wage ~ training | worker_id+year", data=sub)
        print(col, val, r.coef()["training"], r.se()["training"])

# 6d. Placebo — fake timing (treat 3 years before actual policy; should be ~0)
df["fake_post"] = (df["year"] >= df["first_treat_year"] - 3).astype(int)
placebo = pf.feols("log_wage ~ fake_post | worker_id + year", data=df)
placebo.summary()

# 6e. Placebo — permutation / randomization inference (500 draws)
obs_coef = pf.feols("log_wage ~ training | worker_id+year", data=df).coef()["training"]
draws = []
for s in range(500):
    df_s = df.copy()
    df_s["training_perm"] = df_s.groupby("worker_id")["training"].transform(
        lambda x: x.sample(frac=1, random_state=s).values)
    r = pf.feols("log_wage ~ training_perm | worker_id+year", data=df_s)
    draws.append(r.coef()["training_perm"])
p_perm = (np.abs(draws) >= abs(obs_coef)).mean()
print(f"Permutation p = {p_perm:.3f}")

# 6f. Oster (2019) δ* — selection on unobservables
# See references/06-robustness.md §6.6 for the exact formula and its implementation.
```

---

### Step 7 — Further analysis (mechanism / heterogeneity / mediation / moderation)

Deeper patterns: [references/07-further-analysis.md](references/07-further-analysis.md) — subgroup + Wald interaction test, triple-difference (DDD) for effect heterogeneity, Baron–Kenny / Imai mediation, causal mediation with sensitivity, moderated mediation, outcome ladder (short → intermediate → final), dose-response curves, CATE via causal forest.

```python
# 7a. Heterogeneity via full interaction (cleanest: lets you test the interaction coefficient)
het = pf.feols("log_wage ~ training + training:female + age + edu | worker_id + year",
               data=df, vcov={"CRV1": "worker_id"})
het.summary()     # the interaction coefficient IS the heterogeneity test

# 7b. Subgroup estimation with Wald test of equality
from scipy.stats import chi2
male_r   = pf.feols("log_wage ~ training | worker_id+year", data=df[df.female==0])
female_r = pf.feols("log_wage ~ training | worker_id+year", data=df[df.female==1])
diff  = male_r.coef()["training"] - female_r.coef()["training"]
se    = np.sqrt(male_r.se()["training"]**2 + female_r.se()["training"]**2)
wald  = (diff/se)**2
print(f"Wald = {wald:.2f},  p = {1-chi2.cdf(wald,1):.3f}")

# 7c. Triple-difference (DDD) — heterogeneity by a THIRD dimension
ddd = pf.feols(
    "log_wage ~ treated*post*high_exposure | worker_id + year",
    data=df, vcov={"CRV1":"firm_id"})

# 7d. Mechanism — "outcome ladder" (same treatment, three sequential outcomes)
for out in ["hours_worked", "productivity", "log_wage"]:
    r = pf.feols(f"{out} ~ training | worker_id + year", data=df)
    print(out, r.coef()["training"], r.se()["training"])

# 7e. Mediation — Baron-Kenny (ok for simple linear setting; use Imai for rigor)
#     Total:     Y = a + c·T + ε
#     Step 1:    M = a1 + b·T + ε      (does T affect M?)
#     Step 2:    Y = a2 + c'·T + d·M + ε   (direct effect of T holding M fixed)
#     Mediated effect = b · d
b_coef = smf.ols("hours_worked ~ training + age+edu", data=df).fit().params["training"]
d_coef = smf.ols("log_wage    ~ training + hours_worked + age+edu", data=df) \
             .fit().params["hours_worked"]
print(f"Indirect effect via hours = {b_coef*d_coef:.3f}")

# 7f. Moderation — add interaction + marginal-effect plot; see references/07 for the full recipe.

# 7g. Heterogeneous treatment effects via causal forest (high-dim moderators)
from econml.dml import CausalForestDML
cf = CausalForestDML(n_estimators=1000, min_samples_leaf=5)
cf.fit(df["log_wage"], df["training"], X=df[["age","edu","tenure","firm_size"]])
tau = cf.effect(df[["age","edu","tenure","firm_size"]])      # per-unit CATE
cf.feature_importances_    # which X drives heterogeneity
```

---

### Step 8 — Publication tables & figures

> **This step is mandatory** — every analysis run produces all 5 required tables (T1–T5) and all 4 required figures (F1–F4) defined in the *Default Output Spec* at the top of this skill. Do not skip Step 8 because "the regression already ran". A coefficient without a table and a figure is not how applied economics communicates a result.

Deeper patterns: [references/08-tables-plots.md](references/08-tables-plots.md) — `stargazer` and `pf.etable()` for regression tables; coefficient plots with CIs; event-study plots (pre/post coefficients with reference line); binscatter; forest plots for subgroup analysis; RD plots; LaTeX / Word / Excel export.

```python
# ============================================================
# 8a. ★ TABLE 2 — Main results, multi-column regression M1→M6
#     (the centerpiece of every economics paper)
# ============================================================
from stargazer.stargazer import Stargazer
table = Stargazer([r.fit for r in [ols_m1, ols_m2, ols_m3, ols_m4, ols_m5, ols_m6]])
table.title("Effect of training on log wage")
table.custom_columns(["(1)","(2)","(3)","(4)","(5)","(6)"], [1]*6)
open("tables/table2_main.tex","w").write(table.render_latex())

# Or pyfixest's etable — handles FE indicators automatically (preferred):
pf.etable([m1, m2, m3, m4, m5, m6],
          type="tex",   file="tables/table2_main.tex",
          headers=["(1) Raw","(2) +Demog","(3) +Tenure",
                   "(4) +Unit FE","(5) +2-way FE","(6) +Ind×Year FE"],
          digits=3, signif_code=[0.1, 0.05, 0.01],
          notes="Cluster-robust SE in parentheses, clustered at worker_id.")
pf.etable([m1, m2, m3, m4, m5, m6], type="docx", file="tables/table2_main.docx")

# ============================================================
# 8b. TABLE 1 — Summary statistics & balance
# ============================================================
# Built in Step 3 as `t1` (DataFrame). Export both formats:
t1.to_latex("tables/table1_balance.tex", float_format="%.3f", index=False)
t1.to_excel("tables/table1_balance.xlsx", index=False)
# .docx version via python-docx or pandas → docx through tabulate

# ============================================================
# 8c. TABLE 3 — Mechanism / outcome ladder (3+ outcomes)
# ============================================================
ladder = [pf.feols(f"{y} ~ training + age + edu + tenure | worker_id + year",
                   data=df, vcov={"CRV1":"worker_id"})
          for y in ["hours_worked", "productivity", "log_wage"]]
pf.etable(ladder, type="tex", file="tables/table3_mechanism.tex",
          headers=["Hours worked", "Productivity", "Log wage"],
          notes="Each column is a separate regression on the labelled outcome.")

# ============================================================
# 8d. TABLE 4 — Heterogeneity (subgroup × main coef)
# ============================================================
het_specs = {
    "All":           df,
    "Female=0":      df[df.female==0],
    "Female=1":      df[df.female==1],
    "Age<40":        df[df.age<40],
    "Age>=40":       df[df.age>=40],
    "Manufacturing": df[df.industry.eq("manufacturing")],
}
het_models = [pf.feols("log_wage ~ training + age + edu + tenure | worker_id + year",
                       data=d, vcov={"CRV1":"worker_id"})
              for d in het_specs.values()]
pf.etable(het_models, type="tex", file="tables/table4_heterogeneity.tex",
          headers=list(het_specs.keys()),
          notes="Cluster-robust SE at worker_id. Wald p-values for cross-subgroup equality "
                "should accompany this table — see references/07.")

# ============================================================
# 8e. TABLE 5 — Robustness battery (alt SE / cluster / sample / placebo)
# ============================================================
rob = {
    "Baseline":      pf.feols("log_wage ~ training | worker_id + year", df,
                              vcov={"CRV1":"worker_id"}),
    "Cluster=firm":  pf.feols("log_wage ~ training | worker_id + year", df,
                              vcov={"CRV1":"firm_id"}),
    "Two-way clust": pf.feols("log_wage ~ training | worker_id + year", df,
                              vcov={"CRV3x1":["worker_id","firm_id"]}),
    "Winsor 1/99":   pf.feols("log_wage ~ training | worker_id + year",
                              df.assign(log_wage=df.log_wage.clip(*df.log_wage.quantile([.01,.99]))),
                              vcov={"CRV1":"worker_id"}),
    "Drop manuf":    pf.feols("log_wage ~ training | worker_id + year",
                              df[df.industry!="manufacturing"], vcov={"CRV1":"worker_id"}),
    "Placebo (-3)":  pf.feols("log_wage ~ fake_post | worker_id + year",
                              df, vcov={"CRV1":"worker_id"}),
}
pf.etable(list(rob.values()), type="tex", file="tables/table5_robustness.tex",
          headers=list(rob.keys()))

# ============================================================
# 8f. ★ FIGURE 3 — Coefficient plot across M1→M6
# ============================================================
fig, ax = plt.subplots(figsize=(6, 3.5))
labels, betas, lows, highs = [], [], [], []
for name, r in [("(1)",m1),("(2)",m2),("(3)",m3),("(4)",m4),("(5)",m5),("(6)",m6)]:
    b  = r.coef()["training"]; se = r.se()["training"]
    labels.append(name); betas.append(b)
    lows.append(b-1.96*se); highs.append(b+1.96*se)
betas = np.array(betas); lows = np.array(lows); highs = np.array(highs)
ax.errorbar(labels, betas, yerr=[betas-lows, highs-betas], fmt="o", capsize=3, color="navy")
ax.axhline(0, ls="--", color="gray", alpha=.6)
ax.set_ylabel("ATT on log wage"); ax.set_xlabel("Specification")
plt.tight_layout()
plt.savefig("figures/fig3_coefplot.pdf"); plt.savefig("figures/fig3_coefplot.png", dpi=300)

# ============================================================
# 8g. FIGURE 2 — Event-study plot (dynamic DID, base period = -1)
# ============================================================
fig, ax = plt.subplots(figsize=(7, 4))
pf.iplot(es, ax=ax)
ax.axhline(0, ls="--", color="gray"); ax.axvline(-0.5, ls=":", color="gray")
ax.set_xlabel("Years relative to treatment"); ax.set_ylabel("Coefficient (ATT)")
plt.tight_layout()
plt.savefig("figures/fig2_event_study.pdf"); plt.savefig("figures/fig2_event_study.png", dpi=300)

# ============================================================
# 8h. FIGURE 4 — Sensitivity / robustness curve (spec curve)
# ============================================================
# Loop over 32 spec combinations and rank by point estimate
specs_curve = []
for fe in ["", "| worker_id", "| worker_id + year", "| worker_id + year + industry^year"]:
    for ctrl in [[], ["age"], ["age","edu"], ["age","edu","tenure"]]:
        f = "log_wage ~ training" + ("+" + "+".join(ctrl) if ctrl else "") + " " + fe
        try:
            r = pf.feols(f, df, vcov={"CRV1":"worker_id"})
            specs_curve.append({"spec": f.strip(), "b": r.coef()["training"],
                                "se": r.se()["training"]})
        except Exception:
            pass
sc = pd.DataFrame(specs_curve).sort_values("b").reset_index(drop=True)
fig, ax = plt.subplots(figsize=(7, 4))
ax.errorbar(range(len(sc)), sc["b"], yerr=1.96*sc["se"], fmt="o", ms=3, color="navy", alpha=.7)
ax.axhline(0, ls="--", color="gray")
ax.set_xlabel("Specification rank (sorted by point estimate)")
ax.set_ylabel("Coefficient on training")
plt.tight_layout()
plt.savefig("figures/fig4_sensitivity.pdf"); plt.savefig("figures/fig4_sensitivity.png", dpi=300)

# ============================================================
# 8i. FIGURE 1 — Trend / motivation (treated vs control over time)
# ============================================================
# Already built in Step 3; re-export with paper-grade styling.
fig, ax = plt.subplots(figsize=(7, 4))
trend = df.groupby(["year","training"])["log_wage"].mean().unstack()
trend.plot(ax=ax, marker="o", color={0:"darkred", 1:"navy"})
ax.axvline(policy_year, ls="--", color="gray", label="Policy")
ax.set_ylabel("Mean log wage"); ax.set_xlabel("Year")
ax.legend(["Control","Treated","Policy"])
plt.tight_layout()
plt.savefig("figures/fig1_trend.pdf"); plt.savefig("figures/fig1_trend.png", dpi=300)

# ============================================================
# 8j. Auxiliary plots (optional — produce when relevant)
# ============================================================
from binsreg import binsreg                                  # binscatter
binsreg(y=df["log_wage"], x=df["tenure"], w=df[["age","edu"]], nbins=20)
plt.savefig("figures/figA_binscatter.pdf")

from rdrobust import rdplot                                  # RD plot (only when running_var exists)
# rdplot(y=df["outcome"], x=df["running_var"], c=0); plt.savefig("figures/figA_rdplot.pdf")

# Forest plot for subgroups → see references/08-tables-plots.md §8.6 for the full recipe.
```

**Deliverables checklist** (verify before declaring the run complete):

```
[ ] tables/table1_balance.tex     [ ] figures/fig1_trend.pdf
[ ] tables/table2_main.tex   ★    [ ] figures/fig2_event_study.pdf
[ ] tables/table3_mechanism.tex   [ ] figures/fig3_coefplot.pdf
[ ] tables/table4_heterogeneity.tex
[ ] tables/table5_robustness.tex  [ ] figures/fig4_sensitivity.pdf
```

---

## Library selection cheat-sheet

| Step | Task | Go-to library | Fallback |
|------|------|---------------|----------|
| 1 | Data cleaning | `pandas` | `polars` for >10M rows |
| 1 | Missing-data viz | `missingno` | manual heatmap |
| 2 | Transformations | `numpy`, `pandas`, `scipy.stats.mstats.winsorize` | `sklearn.preprocessing` |
| 3 | Summary stats + Table 1 | `pandas`, `scipy.stats` | `tableone` |
| 3 | Plots | `matplotlib`, `seaborn` | `plotly` for interactive |
| 4 | Normality / hetero / autocorr | `statsmodels.stats.*`, `scipy.stats` | `pingouin` |
| 4 | Stationarity | `statsmodels.tsa.stattools`, `arch` | — |
| 5 | OLS / panel FE | `pyfixest` | `statsmodels`, `linearmodels` |
| 5 | IV | `linearmodels` | `pyfixest` (panel IV) |
| 5 | DID (2×2, event study, TWFE) | `pyfixest` (+ `diff-diff` for CS/SA/BJS/SDiD) | `statsmodels` with interactions |
| 5 | RD | `rdrobust`, `rddensity` | — |
| 5 | Synthetic Control | `pysynth`, `sdid` | manual `scipy.optimize` |
| 5 | Matching / IPW / EB | `causalml`, `econml`, `ebal` | `pymatch` |
| 5 | DML / Causal Forest | `econml` | `doubleml` |
| 6 | Specification curve | custom loop over formulas | `specurve` |
| 7 | Mediation | `pingouin.mediation_analysis` | manual Baron–Kenny |
| 7 | CATE | `econml` causal forest | — |
| 8 | Regression tables | `stargazer`, `pyfixest.etable` | `summary_col` (statsmodels) |
| 8 | Coefplot / event study | `pyfixest.iplot`, `matplotlib.errorbar` | `forestplot` |
| 8 | Binscatter | `binsreg` | manual quantile cut |

---

## Common mistakes (and what to do instead)

| Mistake | Correct approach |
|---------|------------------|
| Running OLS on panel data without any FE | Use `pyfixest.feols(... \| unit + time, ...)` |
| Default (iid) SEs on clustered / panel / few-cluster data | `vcov={"CRV1":"cluster_var"}`; wild bootstrap if clusters < 50 |
| TWFE with staggered adoption | Use CS / SA / BJS to avoid negative-weight bias |
| Dropping rows silently inside model fit | Do Step 1 cleaning explicitly; print counts |
| Blanket-mean-imputing covariates with high missingness | Consider MICE (`statsmodels.imputation`) or dropping the variable |
| Reporting only the coefficient, not the CI | Always report point + 95% CI + N; plot coefplot |
| One specification, no robustness | Ship progressive specs (M1–M6) + alternative SEs |
| Reporting only the headline coefficient (no Table 2) | **Always** ship the multi-column M1→M6 main table — that is the centerpiece of an economics paper, not the abstract sentence |
| Coefficient table without any figures | An economics result needs **at least** F1 trend + F2 event study + F3 coefplot + F4 sensitivity — see the Default Output Spec |
| RD with a single bandwidth | Show bandwidth sensitivity + `rdbwselect` |
| IV without first-stage F | Always print `.first_stage` (F > 10, ideally > 104) |
| PSM without SMD balance table | Report pre/post SMDs, target \|SMD\| < 0.1 |
| Interpreting mediation without Imai sensitivity | For causal mediation, never stop at Baron–Kenny in a serious paper |
| "Table 1 in Excel after pipeline finishes" | Build Table 1 in Step 3 **before** any regression |
| p-hacking via specification selection | Disclose the **full** specification curve, not the favorite cell |

---

## Typical agent execution pattern

```python
# 1. Clean
df = load_and_clean(raw_path)                    # Step 1

# 2. Transform
df = construct_vars(df)                          # Step 2

# 3. Describe
table1 = build_table1(df, by="training")         # Step 3
save_corr_heatmap(df, cols)                      # Step 3

# 4. Diagnose
run_diagnostics(df, y="log_wage", x=covariates)  # Step 4

# 5. Model
results_main = fit_baseline(df)                  # Step 5

# 6. Robustify
results_robust = robustness_battery(df)          # Step 6

# 7. Extend
results_het   = heterogeneity_analysis(df)       # Step 7
results_mech  = mechanism_analysis(df)           # Step 7

# 8. Export
export_latex_tables(results_main, results_robust, results_het)  # Step 8
save_all_figures()                                              # Step 8
```

The deliverable for every run is the **economics empirical-paper output set** defined in the Default Output Spec:

- **5 tables** — `tables/table1_balance.{tex,docx}`, `tables/table2_main.{tex,docx}` ★, `tables/table3_mechanism.tex`, `tables/table4_heterogeneity.tex`, `tables/table5_robustness.tex`
- **4 figures** — `figures/fig1_trend.{pdf,png}`, `figures/fig2_event_study.{pdf,png}`, `figures/fig3_coefplot.{pdf,png}`, `figures/fig4_sensitivity.{pdf,png}`
- **A diagnostic log** with every Step 4 test result printed and every row exclusion counted
- **A reproducible script / notebook** that regenerates the entire output set from the raw data

If any deliverable is missing or skipped, print **why** (e.g. "F2 event study omitted: design is cross-sectional"). Do not silently drop.

---

## When to hand off to other skills

- **Agent-native single-import workflow** (`import statspai as sp`) → `00-StatsPAI_skill`.
- **Causal Inference: The Mixtape style code templates** (Python/R/Stata side-by-side) → `10-Jill0099-causal-inference-mixtape`.
- **DSGE / HANK numerical macro** → `20-wenddymacro-python-econ-skill`.
- **Pure pyfixest reference** (every `feols` kwarg) → `40-py-econometrics-pyfixest`.
- **Paper writing / LaTeX drafting** after the analysis is done → the writing-oriented skills in this repo (`04-*-scientific-writer`, `08-*-web-latex`, etc.).

This skill's remit **ends at Step 8** — polished tables and figures. Paper drafting is out of scope.

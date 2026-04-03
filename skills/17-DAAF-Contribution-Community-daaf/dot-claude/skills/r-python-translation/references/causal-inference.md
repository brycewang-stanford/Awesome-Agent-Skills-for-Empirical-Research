# Causal Inference: R to Python Translation

R has been the primary language for causal inference in quantitative social
science for over a decade. Most influential causal methods papers (DiD, RD,
synthetic control, matching) ship reference implementations as R packages first,
with Python ports following months to years later. This gap has narrowed
considerably: pyfixest now mirrors R fixest's DiD capabilities almost exactly,
and several R package authors (Cattaneo for rdrobust, Arel-Bundock for
marginaleffects) have released official Python ports of their own tools.

DAAF's Python stack provides strong coverage for the most common causal designs:
- **Difference-in-differences:** pyfixest (TWFE, did2s, lpdid, Sun-Abraham)
- **Event studies:** pyfixest (i() operator, iplot)
- **Regression discontinuity:** rdrobust (installable; same authors as R version)
- **Instrumental variables:** pyfixest (with FE) and linearmodels (LIML, GMM)
- **Marginal effects:** marginaleffects (same author as R version)

Some causal methods remain gaps in Python: matching/weighting (no MatchIt/WeightIt
equivalent in DAAF), generalized random forests (no grf port), and multiple
imputation (no mice equivalent). These are documented honestly in this reference.

> **Versions referenced:**
> Python: pyfixest 0.40.0, marginaleffects (unpinned), rdrobust (unpinned)
> R: fixest 0.14.0, marginaleffects 0.32.0, rdrobust 3.0.0, did 2.3.0, did2s 1.2.1
> See SKILL.md § Library Versions for the complete version table.

> **Sources:** Cunningham, *Causal Inference: The Mixtape* (Yale, 2021);
> Huntington-Klein, *The Effect* (CRC Press, 2021);
> Berge, Butts, & McDermott, *fixest* (CRAN, v0.13);
> Fischer et al., *pyfixest* (pyfixest.org, v0.40.0, accessed 2026-03-28);
> Cattaneo, Idrobo, & Titiunik, *rdrobust* (rdpackages.github.io);
> Arel-Bundock, Greifer, & Heiss, "How to Interpret Statistical Models Using
> marginaleffects for R and Python" (JSS, 2024)

---

## 1. Difference-in-Differences

### Traditional TWFE DiD

The simplest DiD design: all treated units adopt simultaneously, effects are
homogeneous.

**R (fixest):**
```r
library(fixest)

# Binary treatment indicator × post-treatment interaction
fit <- feols(y ~ treat:post | unit + time, data = df, vcov = ~unit)
summary(fit)

# Or with an explicit treatment variable
fit <- feols(y ~ treated | unit + time, data = df, vcov = ~unit)
```

**Python (pyfixest):**
```python
import pyfixest as pf

# Binary treatment indicator x post-treatment interaction
fit = pf.feols("y ~ treat:post | unit + time", data=df, vcov={"CRV1": "unit"})
fit.summary()

# Or with an explicit treatment variable
fit = pf.feols("y ~ treated | unit + time", data=df, vcov={"CRV1": "unit"})
```

The formula syntax is identical. The only difference is the clustering syntax
(`~unit` vs `{"CRV1": "unit"}`).

**When TWFE fails:** With staggered treatment timing and heterogeneous effects,
TWFE can produce severely biased estimates including sign reversals (Goodman-Bacon,
2021; de Chaisemartin & D'Haultfoeuille, 2020). Use one of the modern estimators
below for staggered designs.

### Two-Stage DiD (Gardner, 2022)

did2s imputes the counterfactual using only untreated observations, then estimates
treatment effects in a second stage.

**R (did2s):**
```r
library(did2s)

fit <- did2s(
  data = df,
  yname = "y",
  first_stage = ~ 0 | unit + time,        # FE from untreated obs
  second_stage = ~ i(rel_time, ref = -1),  # Treatment effect spec
  treatment = "treated",
  cluster_var = "unit"
)
summary(fit)
iplot(fit)
```

**Python (pyfixest):**
```python
fit = pf.did2s(
    data=df,
    yname="y",
    first_stage="~ 0 | unit + time",         # FE from untreated obs
    second_stage="~ i(rel_time, ref=-1)",     # Treatment effect spec
    treatment="treated",
    cluster="unit",
)
fit.summary()
fit.iplot()
```

**Key differences:**
- R argument is `cluster_var`; Python is `cluster`
- R returns a fixest object; Python returns a Feols object (both support etable/iplot)
- Formula syntax within `first_stage` and `second_stage` is identical

**Pooled ATT** (single treatment effect):
```r
# R
fit <- did2s(df, "y", ~ 0 | unit + time, ~ treated, "treated", "unit")
```
```python
# Python
fit = pf.did2s(df, "y", "~ 0 | unit + time", "~ treated", "treated", "unit")
```

### Callaway-Sant'Anna (2021)

Group-time ATTs that properly handle staggered adoption.

**R (did):**
```r
library(did)

out <- att_gt(
  yname = "y",
  tname = "year",
  idname = "unit_id",
  gname = "first_treat",      # Year unit first treated (0 = never)
  data = df,
  control_group = "nevertreated",
  est_method = "dr"           # Doubly robust
)
summary(out)
ggdid(out)                    # Event study plot

# Aggregate to overall ATT
agg <- aggte(out, type = "simple")
summary(agg)

# Dynamic (event study) aggregation
agg_dyn <- aggte(out, type = "dynamic")
summary(agg_dyn)
ggdid(agg_dyn)
```

**Python (csdid):**
```python
# Requires: pip install csdid
from csdid import att_gt

out = att_gt(
    yname="y",
    tname="year",
    idname="unit_id",
    gname="first_treat",
    data=df,
    control_group="nevertreated",
    est_method="dr",
)
# API mirrors R did package; check csdid documentation for
# current aggregation and plotting methods
```

**Coverage note:** The Python `csdid` package is a community port (d2cml-ai), not
an official release by the original authors. It aims to replicate the R `did`
package API, but may lag behind on features and bug fixes. Verify results against
R when using for published research.

### Sun-Abraham Saturated Estimator

Fully saturates the model with cohort-by-period indicators, then aggregates.

**R (fixest):**
```r
# sunab() is a special function within feols
fit <- feols(y ~ sunab(cohort, period) | unit + period, data = df,
             vcov = ~unit)
summary(fit)
iplot(fit)

# Aggregate to ATT
summary(fit, agg = "ATT")

# Aggregate by cohort
summary(fit, agg = "cohort")
```

**Python (pyfixest):**
```python
# Via event_study() with estimator="saturated"
fit = pf.event_study(
    data=df,
    yname="y",
    idname="unit",
    tname="period",
    gname="cohort",           # Year of treatment adoption
    estimator="saturated",
    att=False,                # False = dynamic event study
    cluster="unit",
)
fit.summary()
fit.iplot()

# Aggregate to overall ATT
agg = fit.aggregate(weighting="shares")
```

**Key difference:** R uses `sunab()` as a formula function inside `feols()`.
Python uses a separate `event_study()` function with `estimator="saturated"`.
The underlying estimator is identical.

### Local Projections DiD (Dube et al., 2023)

Flexible dynamics without assuming a specific functional form for treatment
effects over time.

**R:** No widely adopted standalone R package; typically implemented manually
using local projections (Jorda, 2005) applied to a DiD setting.

**Python (pyfixest):**
```python
result = pf.lpdid(
    data=df,
    yname="y",
    idname="unit",
    tname="year",
    gname="treatment_year",
    att=True,                 # True = pooled ATT, False = period-specific
    pre_window=5,
    post_window=10,
    never_treated=0,          # Value of gname for never-treated units
)
# Note: lpdid() returns a DataFrame, NOT a Feols object
# result.summary() and result.iplot() will NOT work
```

This is a rare case where Python (pyfixest) has a more convenient implementation
than R.

**Important:** `lpdid()` returns a pandas DataFrame with columns for period,
estimate, std_error, ci_lower, ci_upper, etc. It cannot be passed to
`pf.etable()` or use `.iplot()`. Plot results manually with matplotlib or
plotnine.

---

## 2. Event Studies

### Manual Event Study with i()

**R (fixest):**
```r
# Create relative-time variable
df$rel_year <- df$year - df$treatment_year

# Event study with i() — omit t=-1 as reference
fit <- feols(y ~ i(rel_year, ref = -1) | unit + year, data = df,
             vcov = ~unit)

# Plot
iplot(fit)

# With joint confidence bands
iplot(fit, joint = TRUE)  # Bonferroni bands
```

**Python (pyfixest):**
```python
# Create relative-time variable
df["rel_year"] = df["year"] - df["treatment_year"]

# Event study with i() — omit t=-1 as reference
fit = pf.feols("y ~ i(rel_year, ref=-1) | unit + year", data=df,
               vcov={"CRV1": "unit"})

# Plot
fit.iplot()

# With joint confidence bands
fit.iplot(joint="both")   # Bonferroni + Scheffe bands
```

**Key differences:**

| Feature | R fixest | pyfixest |
|---------|----------|----------|
| Reference level | `i(var, ref = -1)` (space after `=`) | `i(var, ref=-1)` (no space required) |
| iplot call | `iplot(fit)` (standalone function) | `fit.iplot()` (method on Feols) |
| Joint bands | `iplot(fit, joint = TRUE)` | `fit.iplot(joint="both")` |
| Band types | Bonferroni (default TRUE) | `"bonferroni"`, `"scheffe"`, or `"both"` |

### Unified Event Study Interface

**R (fixest):** Does not have a single unified function; uses `sunab()` or manual
`i()` specification within `feols()`.

**Python (pyfixest):**
```python
# pf.event_study() provides a clean unified interface
fit = pf.event_study(
    data=df,
    yname="y",
    idname="unit",
    tname="year",
    gname="treatment_year",
    estimator="twfe",         # "twfe", "did2s", or "saturated"
    att=False,                # False = dynamic event study
    cluster="unit",
)
```

This unified interface is a Python advantage over R, where you must choose between
different function calls (`feols` + `i()`, `did2s`, `sunab`) for different
estimators.

### Comparing Estimators Visually

**R (fixest):**
```r
fit_twfe <- feols(y ~ i(rel_year, ref = -1) | unit + year, data = df)
# did2s returns fixest object, can overlay
fit_d2s <- did2s(df, "y", ~ 0 | unit + year,
                 ~ i(rel_year, ref = -1), "treated", "unit")

coefplot(list(fit_twfe, fit_d2s))
```

**Python (pyfixest):**
```python
fit_twfe = pf.event_study(data=df, yname="y", idname="unit",
                          tname="year", gname="g", estimator="twfe", att=False)
fit_did2s = pf.event_study(data=df, yname="y", idname="unit",
                           tname="year", gname="g", estimator="did2s", att=False)

pf.coefplot([fit_twfe, fit_did2s])
```

### Treatment Pattern Visualization

**R:** No built-in equivalent in fixest. Typically uses custom ggplot2 heatmaps.

**Python (pyfixest):**
```python
pf.panelview(data=df, unit="unit", time="year", treat="treated")
```

`panelview()` produces a heatmap showing treatment assignment across units and
time. This is a pyfixest feature without a direct fixest equivalent.

---

## 3. Regression Discontinuity

Both R and Python implementations are maintained by the same authors (Cattaneo,
Idrobo, Titiunik), ensuring very high fidelity across languages.

### Sharp RD

**R (rdrobust):**
```r
library(rdrobust)

# Point estimate with robust bias-corrected CI
rd <- rdrobust(Y, X, c = cutoff)
summary(rd)

# RD plot
rdplot(Y, X, c = cutoff)

# Bandwidth selection
bw <- rdbwselect(Y, X, c = cutoff)
summary(bw)
```

**Python (rdrobust):**
```python
# Requires: pip install rdrobust
from rdrobust import rdrobust, rdplot, rdbwselect

# Point estimate with robust bias-corrected CI
rd = rdrobust(Y, X, c=cutoff)
print(rd)

# RD plot
rdplot(Y, X, c=cutoff)

# Bandwidth selection
bw = rdbwselect(Y, X, c=cutoff)
print(bw)
```

### Fuzzy RD

**R:**
```r
rd <- rdrobust(Y, X, c = cutoff, fuzzy = T)  # T = treatment indicator
```

**Python:**
```python
rd = rdrobust(Y, X, c=cutoff, fuzzy=T)
```

### Key Parameters

| Parameter | R | Python | Notes |
|-----------|---|--------|-------|
| Outcome | `y` (1st positional) | `y` (1st positional) | Numpy array or Series |
| Running variable | `x` (2nd positional) | `x` (2nd positional) | Numpy array or Series |
| Cutoff | `c = 0` | `c=0` | Default is 0 |
| Kernel | `kernel = "tri"` | `kernel="tri"` | `"tri"`, `"uni"`, `"epa"` |
| Bandwidth | `h = c(left, right)` | `h=[left, right]` | R uses `c()`, Python uses list |
| Polynomial order | `p = 1` | `p=1` | Local linear is default |
| Fuzzy | `fuzzy = T` | `fuzzy=T` | Treatment indicator for fuzzy RD |
| Covariates | `covs = cbind(c1, c2)` | `covs=covs_array` | Matrix/array of covariates |
| Clustering | `cluster = cl` | `cluster=cl` | Cluster variable |

The API is virtually identical. The main syntactic differences are R's `c()` vs
Python's `[]` for paired values, and R's `cbind()` vs numpy arrays for
covariates.

### Additional RD Packages

| Tool | R Package | Python Package | Install |
|------|-----------|----------------|---------|
| Local polynomial RD | `rdrobust` | `rdrobust` | `pip install rdrobust` |
| RD plots | `rdrobust::rdplot()` | `rdrobust.rdplot()` | Included |
| Bandwidth selection | `rdrobust::rdbwselect()` | `rdrobust.rdbwselect()` | Included |
| Manipulation testing | `rddensity` | `rddensity` | `pip install rddensity` |
| Multi-cutoff/score | `rdmulti` | `rdmulti` | `pip install rdmulti` |
| Power calculations | `rdpower` | `rdpower` | `pip install rdpower` |

All packages in the `rdpackages` suite are maintained by the same team across
R, Python, and Stata.

---

## 4. Instrumental Variables

See also Section 3 of the companion `regression-modeling.md` reference for
formula syntax details. This section focuses on the causal inference aspects.

### IV with Fixed Effects

**R (fixest):**
```r
# Classic IV: education instrumented by college proximity
fit <- feols(log_wage ~ experience | state + year | education ~ college_prox,
             data = df, vcov = ~state)

# First-stage results
summary(fit, stage = 1)

# Diagnostics
fitstat(fit, type = "ivf")   # First-stage F
```

**Python (pyfixest):**
```python
fit = pf.feols("log_wage ~ experience | state + year | education ~ college_prox",
               data=df, vcov={"CRV1": "state"})

# First-stage results
fit._model_1st_stage.summary()

# Comprehensive diagnostics (effective F, Cragg-Donald, Kleibergen-Paap)
fit.IV_Diag()
```

### IV without Fixed Effects

**R (ivreg):**
```r
library(ivreg)
fit <- ivreg(log_wage ~ experience + education | experience + college_prox,
             data = df)
summary(fit, diagnostics = TRUE)  # Includes weak instrument tests
```

**Python (linearmodels):**
```python
from linearmodels.iv import IV2SLS

fit = IV2SLS.from_formula(
    "log_wage ~ 1 + experience + [education ~ college_prox]", data=df
).fit(cov_type="robust")
print(fit.summary)

# First-stage diagnostics
print(fit.first_stage)
```

### IV Diagnostic Comparison

| Diagnostic | R (fixest) | R (ivreg) | pyfixest | linearmodels |
|-----------|-----------|-----------|----------|--------------|
| First-stage F | `fitstat(, "ivf")` | `summary(, diag=T)` | `fit.IV_Diag()` | `fit.first_stage` |
| Weak instrument | `fitstat(, "ivwald")` | Cragg-Donald F | Effective F (Olea-Pflueger) | Cragg-Donald F |
| Sargan/Hansen | `fitstat(, "sargan")` | `summary(, diag=T)` | Not built-in | `fit.sargan` |
| Wu-Hausman | `fitstat(, "wh")` | `summary(, diag=T)` | Not built-in | `fit.wu_hausman()` |

### LIML and GMM (Beyond 2SLS)

**R:** No standard LIML/GMM package in base fixest. The `ivreg` package supports
LIML via `method = "LIML"`.

```r
fit <- ivreg(y ~ x + endo | x + z1 + z2, data = df, method = "LIML")
```

**Python (linearmodels):**
```python
from linearmodels.iv import IVLIML, IVGMM

# LIML — better finite-sample properties than 2SLS
fit_liml = IVLIML.from_formula("y ~ 1 + x + [endo ~ z1 + z2]", data=df).fit()

# GMM — efficient with heteroskedasticity and overidentification
fit_gmm = IVGMM.from_formula("y ~ 1 + x + [endo ~ z1 + z2]", data=df).fit()
```

This is a case where Python (linearmodels) has broader coverage than the standard
R toolkit for IV estimation methods.

---

## 5. Marginal Effects and Post-Estimation Interpretation

Both R and Python implementations are by the same author (Vincent Arel-Bundock),
ensuring consistent methodology and API design.

### Average Marginal Effects (AME)

**R (marginaleffects):**
```r
library(marginaleffects)

fit <- glm(y ~ x1 * x2 + x3, data = df, family = binomial)

# Average marginal effect of x1 (accounts for interaction with x2)
avg_slopes(fit, variables = "x1")

# All variables
avg_slopes(fit)
```

**Python (marginaleffects):**
```python
# Requires: pip install marginaleffects
from marginaleffects import avg_slopes

fit = smf.logit("y ~ x1 * x2 + x3", data=df).fit()

# Average marginal effect of x1
avg_slopes(fit, variables="x1")

# All variables
avg_slopes(fit)
```

### Predictions at Specific Values

**R:**
```r
predictions(fit, newdata = datagrid(x1 = c(0, 1), x2 = mean))
```

**Python:**
```python
from marginaleffects import predictions, datagrid

predictions(fit, newdata=datagrid(x1=[0, 1], x2="mean", model=fit))
```

### Comparisons (Contrasts)

**R:**
```r
# Average effect of a one-unit change in x1
avg_comparisons(fit, variables = "x1")

# Specific contrast
avg_comparisons(fit, variables = list(x1 = c(0, 1)))
```

**Python:**
```python
from marginaleffects import avg_comparisons

avg_comparisons(fit, variables="x1")
avg_comparisons(fit, variables={"x1": [0, 1]})
```

### Hypothesis Testing (Delta Method)

**R:**
```r
hypotheses(fit, "x1 = x2")
hypotheses(fit, "(x1 / x2 - 1) * 100 = 0")  # Nonlinear
```

**Python:**
```python
from marginaleffects import hypotheses

hypotheses(fit, "x1 = x2")
hypotheses(fit, "(x1 / x2 - 1) * 100 = 0")
```

### Compatibility

| Model Source | R marginaleffects | Python marginaleffects |
|-------------|------------------|----------------------|
| Base R lm/glm | Yes | N/A |
| fixest feols/fepois | Yes | N/A |
| statsmodels OLS/GLM | N/A | Yes |
| pyfixest Feols/Fepois | N/A | Yes |
| lme4 mixed models | Yes | N/A |
| brms Bayesian | Yes | N/A |
| scikit-learn | N/A | Yes |

The R version supports 100+ model classes. The Python version supports
statsmodels, pyfixest, scikit-learn, and a growing list of other packages.

**Caveat:** The Python `marginaleffects` package is described by its author as an
alpha release. There are known numerical discrepancies between R and Python
results in some edge cases. For published research, verify critical marginal
effects calculations against the R implementation.

---

## 6. Matching and Weighting

This is a **significant gap** in the Python ecosystem. R has mature,
well-documented packages; Python alternatives are fragmented.

### R Packages (Mature)

```r
library(MatchIt)

# Propensity score matching
m.out <- matchit(treat ~ x1 + x2 + x3, data = df, method = "nearest")
summary(m.out)
matched_df <- match.data(m.out)

# Optimal full matching
m.out <- matchit(treat ~ x1 + x2 + x3, data = df, method = "full")

# Coarsened exact matching
m.out <- matchit(treat ~ x1 + x2 + x3, data = df, method = "cem")
```

```r
library(WeightIt)

# Inverse probability weighting
w.out <- weightit(treat ~ x1 + x2 + x3, data = df, method = "ps")
summary(w.out)
# Use weights in outcome model
fit <- lm(y ~ treat, data = df, weights = w.out$weights)
```

### Python Alternatives (Fragmented)

| R Package | Python Equivalent | Fidelity | Notes |
|-----------|------------------|----------|-------|
| `MatchIt` | `pymatchit-causal` | Low-Medium | Community port; limited method coverage |
| `MatchIt` | Manual with scikit-learn | Low | Build propensity model + manual matching |
| `WeightIt` | No direct equivalent | N/A | Manual IPW with statsmodels/sklearn |
| `cobalt` (balance) | No direct equivalent | N/A | Manual balance tables |

**Recommended workaround for DAAF projects:** Implement propensity score matching
manually using scikit-learn for the propensity model and pandas/polars for the
matching algorithm. For published work requiring formal matching diagnostics,
consider running the matching step in R and importing the matched dataset.

```python
# Manual PSM sketch (not a full replacement for MatchIt)
from sklearn.linear_model import LogisticRegression
from sklearn.neighbors import NearestNeighbors

# Estimate propensity scores
ps_model = LogisticRegression().fit(X, treatment)
ps = ps_model.predict_proba(X)[:, 1]

# Nearest-neighbor matching on propensity score
nn = NearestNeighbors(n_neighbors=1)
nn.fit(ps[treatment == 0].reshape(-1, 1))
distances, indices = nn.kneighbors(ps[treatment == 1].reshape(-1, 1))
```

This lacks MatchIt's balance diagnostics, caliper options, exact matching
constraints, and variance ratio checks. The gap is real and consequential.

---

## 7. Synthetic Control

### R Packages

```r
# Classic synthetic control (Abadie, Diamond, Hainmueller)
library(Synth)
synth_out <- synth(dataprep.out)
path.plot(synth_out, dataprep.out)

# Generalized synthetic control (Xu, 2017)
library(gsynth)
out <- gsynth(y ~ treat + x1, data = df, index = c("unit", "year"),
              force = "two-way", r = c(0, 5))

# Augmented synthetic control (Ben-Michael, Feller, Rothstein)
library(augsynth)
aug <- augsynth(y ~ treat, unit = unit, time = year, data = df)
summary(aug)
plot(aug)
```

### Python Alternatives

| R Package | Python Equivalent | Install | Fidelity |
|-----------|------------------|---------|----------|
| `Synth` | `SyntheticControlMethods` | `pip install SyntheticControlMethods` | Medium |
| `gsynth` | No direct equivalent | N/A | Gap |
| `augsynth` | No direct equivalent | N/A | Gap |
| N/A | `CausalPy` (Bayesian SC) | `pip install CausalPy` | Different methodology |
| N/A | `synthdid` | `pip install synthdid` | Medium (synthetic DiD) |

**CausalPy** (by PyMC Labs) provides a Bayesian approach to synthetic control
with full uncertainty quantification via PyMC. It is methodologically different
from the frequentist `Synth` package but achieves similar goals:

```python
# Requires: pip install CausalPy
import causalpy as cp

result = cp.SyntheticControl(
    df,
    treatment_time=treatment_time,
    formula="y ~ 0 + x1 + x2",
    model=cp.pymc_models.WeightedSumFitter(),
)
result.plot()
```

The Python synthetic control ecosystem is less mature than R's. For research
requiring the exact Abadie-Diamond-Hainmueller estimator, consider running the
analysis in R.

---

## 8. Other Causal Tools

### Survival Analysis / Duration Models

**R:**
```r
library(survival)
fit <- coxph(Surv(time, event) ~ x1 + x2 + strata(group), data = df)
summary(fit)
```

**Python:**
```python
# Requires: pip install lifelines
from lifelines import CoxPHFitter

cph = CoxPHFitter()
cph.fit(df, duration_col="time", event_col="event", formula="x1 + x2 + strata(group)")
cph.print_summary()
```

`lifelines` is mature and well-maintained. It covers Cox PH, Kaplan-Meier,
Nelson-Aalen, and parametric survival models. Good Python coverage.

### Bayesian Causal Impact (Time Series Intervention)

**R:**
```r
library(CausalImpact)
impact <- CausalImpact(data, pre.period, post.period)
summary(impact)
plot(impact)
```

**Python:**
```python
# Requires: pip install CausalPy
import causalpy as cp

result = cp.InterruptedTimeSeries(
    df,
    treatment_time=treatment_time,
    formula="y ~ 1 + t",
    model=cp.pymc_models.LinearRegression(),
)
result.plot()
```

`CausalPy`'s interrupted time series is the closest Python analog to R's
`CausalImpact`, though the underlying methodology differs (Bayesian structural
time series in R vs. Bayesian regression in CausalPy).

### Generalized Random Forests (GRF)

**R:**
```r
library(grf)
cf <- causal_forest(X, Y, W)
ate <- average_treatment_effect(cf)
cate <- predict(cf)
```

**Python:** No direct equivalent in the DAAF stack. The `econml` package
(Microsoft) provides causal forest implementations:

```python
# Requires: pip install econml
from econml.dml import CausalForestDML

cf = CausalForestDML(model_y="auto", model_t="auto")
cf.fit(Y, T, X=X, W=W)
cate = cf.effect(X)
```

`econml` is a different implementation from `grf` and may produce different
results. The `grf` R package remains the reference implementation for
Athey-Imbens-Wager causal forests.

### Multiple Imputation

**R:**
```r
library(mice)
imp <- mice(df, m = 5, method = "pmm")
fit <- with(imp, lm(y ~ x1 + x2))
pooled <- pool(fit)
summary(pooled)
```

**Python:** **No equivalent in the DAAF stack.** This is a significant gap.
Partial alternatives exist:

| Approach | Package | Limitation |
|----------|---------|-----------|
| Single imputation | `sklearn.impute.IterativeImputer` | No Rubin's rules; single imputation only |
| Manual MI | statsmodels + sklearn | Must implement Rubin's pooling rules manually |
| `miceforest` | `pip install miceforest` | Community package; less validated than R mice |

For research requiring proper multiple imputation with Rubin's pooling rules,
R's `mice` remains the gold standard. Consider running imputation in R and
exporting the completed datasets.

---

## 9. Ecosystem Mapping Table

| Method | R Package | Python Equivalent | Fidelity | Install | Key Difference |
|--------|-----------|------------------|----------|---------|----------------|
| **OLS + FE** | `fixest::feols()` | `pf.feols()` | Very High | Pre-installed | Cluster SE syntax differs |
| **Poisson + FE** | `fixest::fepois()` | `pf.fepois()` | Very High | Pre-installed | Identical formula syntax |
| **GLM + FE** | `fixest::feglm()` | **Not supported** | N/A | N/A | **Major gap** |
| **TWFE DiD** | `fixest::feols()` | `pf.feols()` | Very High | Pre-installed | Cluster SE syntax only |
| **did2s** | `did2s::did2s()` | `pf.did2s()` | Very High | Pre-installed | `cluster_var` vs `cluster` |
| **Sun-Abraham** | `fixest::sunab()` | `pf.event_study(est="saturated")` | High | Pre-installed | Different API, same estimator |
| **Callaway-Sant'Anna** | `did::att_gt()` | `csdid.att_gt()` | Medium | `pip install csdid` | Community port |
| **LP-DiD** | Manual/emerging | `pf.lpdid()` | N/A | Pre-installed | Python has better wrapper |
| **Event study (iplot)** | `fixest::iplot()` | `fit.iplot()` | Very High | Pre-installed | Method vs function syntax |
| **RD (sharp/fuzzy)** | `rdrobust::rdrobust()` | `rdrobust.rdrobust()` | Very High | `pip install rdrobust` | Same authors |
| **RD plots** | `rdrobust::rdplot()` | `rdrobust.rdplot()` | Very High | `pip install rdrobust` | Same authors |
| **RD density test** | `rddensity::rddensity()` | `rddensity.rddensity()` | Very High | `pip install rddensity` | Same authors |
| **IV + FE** | `fixest::feols()` | `pf.feols()` | Very High | Pre-installed | Identical 3-part formula |
| **IV (2SLS, no FE)** | `ivreg::ivreg()` | `linearmodels.IV2SLS()` | High | Pre-installed | Formula syntax differs |
| **LIML** | `ivreg(method="LIML")` | `linearmodels.IVLIML()` | High | Pre-installed | |
| **GMM-IV** | Limited | `linearmodels.IVGMM()` | N/A | Pre-installed | Python has broader coverage |
| **Panel FE** | `plm::plm(model="within")` | `linearmodels.PanelOLS()` | High | Pre-installed | MultiIndex vs pdata.frame |
| **Panel RE** | `plm::plm(model="random")` | `linearmodels.RandomEffects()` | High | Pre-installed | MultiIndex vs pdata.frame |
| **Marginal effects** | `marginaleffects` | `marginaleffects` | High | `pip install marginaleffects` | Same author; Python is alpha |
| **Matching (PSM)** | `MatchIt::matchit()` | `pymatchit-causal` | Low | `pip install pymatchit-causal` | **Significant gap** |
| **Weighting (IPW)** | `WeightIt::weightit()` | No equivalent | N/A | N/A | **Significant gap** |
| **Synthetic control** | `Synth`, `augsynth` | `CausalPy` (Bayesian) | Low | `pip install CausalPy` | Different methodology |
| **Causal impact** | `CausalImpact` | `CausalPy` (ITS) | Medium | `pip install CausalPy` | Different methodology |
| **Causal forests** | `grf` | `econml` | Medium | `pip install econml` | Different implementation |
| **Survival/Cox** | `survival::coxph()` | `lifelines.CoxPHFitter()` | High | `pip install lifelines` | Good Python coverage |
| **Multiple imputation** | `mice::mice()` | No equivalent | N/A | N/A | **Significant gap** |

### Fidelity Legend

- **Very High:** Same or near-identical API, same authors, or results match to high precision
- **High:** Reliable port with minor syntax differences; results match
- **Medium:** Community port or different implementation; verify results for published work
- **Low:** Partial coverage; significant feature gaps
- **N/A:** No equivalent available; gap in the ecosystem

> **Sources:** Cunningham, *Causal Inference: The Mixtape* (Yale, 2021), ch. 5-9;
> Huntington-Klein, *The Effect* (CRC Press, 2021), ch. 16-21;
> Gardner, "Two-Stage Differences in Differences" (arXiv:2207.05943, 2022);
> Callaway & Sant'Anna, "Difference-in-Differences with Multiple Time Periods"
> (*J. Econometrics*, 2021);
> Sun & Abraham, "Estimating Dynamic Treatment Effects in Event Studies with
> Heterogeneous Treatment Effects" (*J. Econometrics*, 2021);
> Dube, Girardi, Jorda, & Taylor, "A Local Projections Approach to
> Difference-in-Differences" (NBER WP 31184, 2023);
> Cattaneo, Idrobo, & Titiunik, *A Practical Introduction to Regression
> Discontinuity Designs* (Cambridge, 2020);
> Arel-Bundock, "marginaleffects" (marginaleffects.com, accessed 2026-03-28);
> Goodman-Bacon, "Difference-in-Differences with Variation in Treatment Timing"
> (*J. Econometrics*, 2021);
> de Chaisemartin & D'Haultfoeuille, "Two-Way Fixed Effects Estimators with
> Heterogeneous Treatment Effects" (*AER*, 2020)

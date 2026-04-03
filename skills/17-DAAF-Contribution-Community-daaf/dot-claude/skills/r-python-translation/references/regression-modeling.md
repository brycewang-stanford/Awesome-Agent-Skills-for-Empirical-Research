# Regression Modeling: R to Python Translation

Regression modeling is where the R-to-Python translation gap is most visible. R
provides a unified modeling interface: `lm()`, `glm()`, and formula-driven
estimation work identically across base R and most extension packages. Python
fragments this functionality across multiple libraries, each with its own API
conventions, formula engines, and SE computation patterns.

DAAF's Python modeling stack has three tiers:
- **pyfixest** (primary): Closest to R fixest syntax; handles OLS, Poisson, IV, and FE regression
- **statsmodels** (general): R-style formula API for GLM, logit/probit, time series, and diagnostics
- **linearmodels** (panel/IV/system): Panel RE/FE, LIML, GMM, SUR, Fama-MacBeth

This reference provides side-by-side translations for every major regression task.

> **Versions referenced:**
> Python: pyfixest 0.40.0, statsmodels 0.14.6, linearmodels (unpinned)
> R: fixest 0.14.0, lmtest 0.9-40, sandwich 3.1-1, plm 2.6-7, lme4 2.0-1
> See SKILL.md § Library Versions for the complete version table.

> **Sources:** Berge, Butts, & McDermott, *fixest* (CRAN, v0.13);
> Fischer et al., *pyfixest* (pyfixest.org, v0.40.0, accessed 2026-03-28);
> Seabold & Perktold, *statsmodels* (v0.14.6);
> Sheppard, *linearmodels* (v7.0);
> Croissant & Millo, *plm: Linear Models for Panel Data* (CRAN, v2.6)

---

## 1. OLS Regression

### Basic OLS (No Fixed Effects)

**R (base):**
```r
fit <- lm(y ~ x1 + x2, data = df)
summary(fit)
coef(fit)                # Named vector of coefficients
summary(fit)$r.squared   # R-squared
```

**R (fixest):**
```r
library(fixest)
fit <- feols(y ~ x1 + x2, data = df)
summary(fit)
coef(fit)
r2(fit, type = "r2")
```

**Python (statsmodels):**
```python
import statsmodels.formula.api as smf

fit = smf.ols("y ~ x1 + x2", data=df).fit()  # Note: .fit() required
fit.summary()
fit.params                # Series of coefficients
fit.rsquared              # R-squared
```

**Python (pyfixest):**
```python
import pyfixest as pf

fit = pf.feols("y ~ x1 + x2", data=df)  # No .fit() needed
fit.summary()
fit.coef()                # Series of coefficients
fit._r2                   # R-squared
```

### Key Differences

| Aspect | R | Python (statsmodels) | Python (pyfixest) |
|--------|---|---------------------|-------------------|
| Estimation call | `lm(y ~ x, data)` | `smf.ols("y ~ x", data).fit()` | `pf.feols("y ~ x", data)` |
| Requires `.fit()` | No | **Yes** | No |
| Formula quoting | Unquoted | String | String |
| Coefficients | `coef(fit)` | `fit.params` | `fit.coef()` |
| Standard errors | `summary(fit)$coefficients[,2]` | `fit.bse` | `fit.se()` |
| Confidence intervals | `confint(fit)` | `fit.conf_int()` | `fit.confint()` |
| Predictions | `predict(fit, newdata)` | `fit.predict(newdata)` | `fit.predict(newdata)` |
| Residuals | `residuals(fit)` | `fit.resid` | `fit.resid()` |
| R-squared | `summary(fit)$r.squared` | `fit.rsquared` | `fit._r2` |

---

## 2. Fixed Effects Regression

### One-Way and Multi-Way FE

**R (fixest):**
```r
# One-way FE
fit <- feols(y ~ x1 + x2 | entity, data = df)

# Two-way FE
fit <- feols(y ~ x1 + x2 | entity + year, data = df)

# Three-way FE
fit <- feols(y ~ x1 + x2 | entity + year + industry, data = df)

# Interacted FE (entity-by-year)
fit <- feols(y ~ x1 | entity^year, data = df)
```

**Python (pyfixest):**
```python
# One-way FE
fit = pf.feols("y ~ x1 + x2 | entity", data=df)

# Two-way FE
fit = pf.feols("y ~ x1 + x2 | entity + year", data=df)

# Three-way FE
fit = pf.feols("y ~ x1 + x2 | entity + year + industry", data=df)

# Interacted FE (entity-by-year)
fit = pf.feols("y ~ x1 | entity ^ year", data=df)
```

The formula syntax is nearly identical. Both use `|` to separate regressors from
absorbed fixed effects, `+` for additive FE, and `^` for interacted FE.

### Clustered Standard Errors with FE

**R (fixest):**
```r
# Cluster by entity
fit <- feols(y ~ x1 | entity + year, data = df, vcov = ~entity)

# Two-way clustering
fit <- feols(y ~ x1 | entity + year, data = df, vcov = ~entity + year)

# Switch SE post-estimation
summary(fit, vcov = "hetero")
summary(fit, vcov = ~state)
```

**Python (pyfixest):**
```python
# Cluster by entity
fit = pf.feols("y ~ x1 | entity + year", data=df, vcov={"CRV1": "entity"})

# Two-way clustering
fit = pf.feols("y ~ x1 | entity + year", data=df, vcov={"CRV1": "entity+year"})

# Switch SE post-estimation
fit.vcov("hetero")
fit.vcov({"CRV1": "state"})
```

### Syntax Differences for Clustered SEs

| Operation | R fixest | pyfixest |
|-----------|----------|----------|
| One-way cluster | `vcov = ~entity` | `vcov={"CRV1": "entity"}` |
| Two-way cluster | `vcov = ~entity + year` | `vcov={"CRV1": "entity+year"}` |
| Heteroskedastic | `vcov = "hetero"` | `vcov="hetero"` |
| IID | `vcov = "iid"` | `vcov="iid"` |
| Newey-West | `vcov = "NW"` | `vcov="NW"` |
| Driscoll-Kraay | `vcov = "DK"` | `vcov="DK"` |
| Conley spatial | `vcov = conley(...)` | Not supported |

The most notable difference is the clustering syntax: R uses a one-sided formula
(`~entity`), while pyfixest uses a dictionary (`{"CRV1": "entity"}`). The CRV1
key specifies the cluster variance estimator type (CRV1 = sandwich, CRV3 =
jackknife).

### Varying Slopes

**R (fixest):**
```r
# Entity-specific slopes on x1
fit <- feols(y ~ x2 | entity[x1], data = df)
```

**Python (pyfixest):**
```python
# Entity-specific slopes on x1
fit = pf.feols("y ~ x2 | entity[x1]", data=df)
```

### Extracting Fixed Effects

**R (fixest):**
```r
fe <- fixef(fit)  # Returns list of FE vectors
fe$entity         # Entity-level FE estimates
```

**Python (pyfixest):**
```python
fe = fit.fixef()  # Returns dict of Series
fe["entity"]      # Entity-level FE estimates
```

---

## 3. Instrumental Variables / 2SLS

### fixest / pyfixest Three-Part Formula

**R (fixest):**
```r
# Y ~ exogenous | FE | endogenous ~ instruments
fit <- feols(y ~ x_exog | entity + year | x_endog ~ z_inst, data = df)

# IV without FE (use 0 for FE slot)
fit <- feols(y ~ x_exog | 0 | x_endog ~ z1 + z2, data = df)

# IV with only endogenous regressor (use 1 for exogenous)
fit <- feols(y ~ 1 | entity | x_endog ~ z_inst, data = df)
```

**Python (pyfixest):**
```python
# Y ~ exogenous | FE | endogenous ~ instruments
fit = pf.feols("y ~ x_exog | entity + year | x_endog ~ z_inst", data=df)

# IV without FE
fit = pf.feols("y ~ x_exog | 0 | x_endog ~ z1 + z2", data=df)

# IV with only endogenous regressor
fit = pf.feols("y ~ 1 | entity | x_endog ~ z_inst", data=df)
```

The three-part formula is identical in both languages.

### ivreg / linearmodels Two-Part Formula

**R (ivreg):**
```r
library(ivreg)
# Two-part formula: outcome ~ exog + endog | exog + instruments
fit <- ivreg(y ~ x_exog + x_endog | x_exog + z_inst, data = df)

# Three-part formula (alternative): outcome ~ exog | endog | instruments
fit <- ivreg(y ~ x_exog | x_endog | z_inst, data = df)
```

**Python (linearmodels):**
```python
from linearmodels.iv import IV2SLS

# Bracket notation: outcome ~ exog + [endog ~ instruments]
fit = IV2SLS.from_formula("y ~ 1 + x_exog + [x_endog ~ z_inst]", data=df).fit()
```

### IV Formula Notation Comparison

| Feature | fixest (R) | pyfixest | ivreg (R) | linearmodels |
|---------|-----------|----------|-----------|--------------|
| Basic IV | `y ~ 1 \| 0 \| x ~ z` | `"y ~ 1 \| 0 \| x ~ z"` | `y ~ x \| z` | `"y ~ 1 + [x ~ z]"` |
| IV + FE | `y ~ 1 \| fe \| x ~ z` | `"y ~ 1 \| fe \| x ~ z"` | N/A | N/A (no panel IV) |
| Multiple inst. | `y ~ 1 \| fe \| x ~ z1 + z2` | `"y ~ 1 \| fe \| x ~ z1 + z2"` | `y ~ x \| z1 + z2` | `"y ~ 1 + [x ~ z1 + z2]"` |
| Exog included | After first `~` | After first `~` | Both sides of `\|` | Before brackets |

### First-Stage Diagnostics

**R (fixest):**
```r
fit <- feols(y ~ 1 | fe | x_endog ~ z1 + z2, data = df)
fitstat(fit, type = "ivf")       # First-stage F
fitstat(fit, type = "ivwald")    # Wald statistic
summary(fit, stage = 1)          # First-stage results
```

**Python (pyfixest):**
```python
fit = pf.feols("y ~ 1 | fe | x_endog ~ z1 + z2", data=df)
fit.IV_Diag()                    # Comprehensive diagnostics
first_stage = fit._model_1st_stage
first_stage.summary()
```

---

## 4. Panel Data Models

### Fixed Effects (Within Estimator)

**R (plm):**
```r
library(plm)
pdata <- pdata.frame(df, index = c("entity", "year"))
fit <- plm(y ~ x1 + x2, data = pdata, model = "within")
summary(fit)
```

**Python (linearmodels):**
```python
from linearmodels.panel import PanelOLS
import pandas as pd

# Critical: linearmodels requires a pandas MultiIndex (entity, time)
df_panel = df.set_index(["entity", "year"])
fit = PanelOLS.from_formula("y ~ x1 + x2 + EntityEffects", data=df_panel).fit()
print(fit.summary)
```

### Random Effects (GLS Estimator)

**R (plm):**
```r
fit <- plm(y ~ x1 + x2, data = pdata, model = "random")
# Or specify RE method
fit <- plm(y ~ x1 + x2, data = pdata, model = "random", random.method = "swar")
```

**Python (linearmodels):**
```python
from linearmodels.panel import RandomEffects

df_panel = df.set_index(["entity", "year"])
fit = RandomEffects.from_formula("y ~ 1 + x1 + x2", data=df_panel).fit()
```

### Other Panel Models

| Model | R (plm) | Python (linearmodels) |
|-------|---------|----------------------|
| Within (FE) | `plm(..., model="within")` | `PanelOLS.from_formula("y ~ x + EntityEffects", data)` |
| Random effects | `plm(..., model="random")` | `RandomEffects.from_formula("y ~ 1 + x", data)` |
| Between | `plm(..., model="between")` | `BetweenOLS.from_formula("y ~ 1 + x", data)` |
| First difference | `plm(..., model="fd")` | `FirstDifferenceOLS.from_formula("y ~ x", data)` |
| Pooled OLS | `plm(..., model="pooling")` | `PooledOLS.from_formula("y ~ 1 + x", data)` |
| Two-way FE | `plm(..., effect="twoways")` | `PanelOLS.from_formula("y ~ x + EntityEffects + TimeEffects", data)` |
| Fama-MacBeth | Not in plm | `FamaMacBeth.from_formula("y ~ 1 + x", data)` |

### Key Difference: Data Preparation

The most significant translation gap is data preparation. R uses `pdata.frame()`
which accepts an `index` argument. Python requires setting a pandas MultiIndex
manually. In DAAF pipelines using Polars, the conversion pattern is:

```python
import polars as pl
import pandas as pd

# Polars → pandas with MultiIndex for linearmodels
df_polars = pl.read_parquet("data/processed/analysis.parquet")
df_panel = df_polars.to_pandas().set_index(["entity_id", "year"])
```

### Hausman Test (FE vs RE)

**R (plm):**
```r
fe <- plm(y ~ x1 + x2, data = pdata, model = "within")
re <- plm(y ~ x1 + x2, data = pdata, model = "random")
phtest(fe, re)  # Hausman specification test
```

**Python (linearmodels):**
```python
from linearmodels.panel import compare

fe_res = PanelOLS.from_formula("y ~ x1 + x2 + EntityEffects", data=df_panel).fit()
re_res = RandomEffects.from_formula("y ~ 1 + x1 + x2", data=df_panel).fit()
comparison = compare({"FE": fe_res, "RE": re_res})
print(comparison)
# Note: linearmodels does not have a built-in phtest() equivalent;
# the Hausman test must be constructed manually from coefficient differences
```

---

## 5. GLM / Logit / Probit

### Logit and Probit

**R:**
```r
# Logit
fit <- glm(y ~ x1 + x2, data = df, family = binomial(link = "logit"))

# Probit
fit <- glm(y ~ x1 + x2, data = df, family = binomial(link = "probit"))

# Marginal effects
library(margins)
margins(fit)
```

**Python (statsmodels):**
```python
import statsmodels.formula.api as smf

# Logit
fit = smf.logit("y ~ x1 + x2", data=df).fit()

# Probit
fit = smf.probit("y ~ x1 + x2", data=df).fit()

# Marginal effects (built-in)
fit.get_margeff(at="overall").summary()
```

### Poisson Regression

**R (base):**
```r
fit <- glm(count_y ~ x1 + x2, data = df, family = poisson)
```

**R (fixest, with FE):**
```r
fit <- fepois(count_y ~ x1 + x2 | entity + year, data = df)
```

**Python (statsmodels):**
```python
fit = smf.poisson("count_y ~ x1 + x2", data=df).fit()
```

**Python (pyfixest, with FE):**
```python
fit = pf.fepois("count_y ~ x1 + x2 | entity + year", data=df)
```

### Negative Binomial

**R:**
```r
library(MASS)
fit <- glm.nb(count_y ~ x1 + x2, data = df)
```

**Python (statsmodels):**
```python
import statsmodels.api as sm
fit = smf.glm("count_y ~ x1 + x2", data=df,
              family=sm.families.NegativeBinomial()).fit()
```

### GLM Family/Link Mapping

| Model | R `glm()` | Python `statsmodels` |
|-------|-----------|---------------------|
| Logit | `family=binomial(link="logit")` | `smf.logit()` or `family=Binomial()` |
| Probit | `family=binomial(link="probit")` | `smf.probit()` or `family=Binomial(link=probit())` |
| Poisson | `family=poisson` | `smf.poisson()` or `family=Poisson()` |
| Neg. binomial | `MASS::glm.nb()` | `family=NegativeBinomial()` |
| Gamma | `family=Gamma` | `family=Gamma()` |
| Inverse Gaussian | `family=inverse.gaussian` | `family=InverseGaussian()` |

### The feglm Gap: GLM with Fixed Effects

R fixest provides `feglm()` which supports logit, probit, and other GLMs with
absorbed high-dimensional fixed effects:

```r
# R: works perfectly
fit <- feglm(y ~ x1 | entity + year, data = df, family = binomial)
```

**pyfixest `feglm()` does NOT support fixed effects.** Attempting
`pf.feglm("y ~ x | fe", ...)` raises `NotImplementedError`. This is the single
largest feature gap between R fixest and pyfixest.

**Workarounds:**

| Approach | Code | When to Use |
|----------|------|-------------|
| Linear probability model | `pf.feols("binary_y ~ x \| fe", data=df)` | Most cases; interpret coefficients as pp changes |
| Manual dummies + statsmodels | `smf.logit("y ~ x + C(entity)", data=df).fit()` | Small/moderate number of FE levels |
| Conditional logit | `sm.discrete.ConditionalLogit(...)` | Binary outcome with entity FE |
| Poisson pseudo-ML | `pf.fepois("binary_y ~ x \| fe", data=df)` | If log-linear approximation acceptable |

---

## 6. Robust and Clustered Standard Errors

### The R Pattern (sandwich + lmtest)

R's standard approach for robust SEs on base models uses two packages:

```r
library(sandwich)
library(lmtest)

fit <- lm(y ~ x1 + x2, data = df)

# HC1 (Stata-equivalent "robust")
coeftest(fit, vcov = vcovHC(fit, type = "HC1"))

# HC3 (conservative, good for small samples)
coeftest(fit, vcov = vcovHC(fit, type = "HC3"))

# Clustered SEs
coeftest(fit, vcov = vcovCL(fit, cluster = df$state))
```

### The R Pattern (fixest — integrated)

fixest provides SEs as a first-class feature without needing separate packages:

```r
fit <- feols(y ~ x1 + x2, data = df, vcov = "hetero")
fit <- feols(y ~ x1 + x2, data = df, vcov = ~state)

# Switch post-estimation
summary(fit, vcov = "HC1")
summary(fit, vcov = ~state + year)
```

### Python (pyfixest)

```python
fit = pf.feols("y ~ x1 + x2", data=df, vcov="hetero")
fit = pf.feols("y ~ x1 + x2", data=df, vcov={"CRV1": "state"})

# Switch post-estimation
fit.vcov("hetero")
fit.vcov({"CRV1": "state"})
fit.vcov({"CRV1": "state+year"})
```

### Python (statsmodels)

```python
# At estimation time
fit = smf.ols("y ~ x1 + x2", data=df).fit(cov_type="HC1")

# Or post-estimation
fit = smf.ols("y ~ x1 + x2", data=df).fit()
robust = fit.get_robustcov_results(cov_type="HC1")

# Clustered SEs
fit = smf.ols("y ~ x1 + x2", data=df).fit(
    cov_type="cluster", cov_kwds={"groups": df["state"]}
)
```

### Comprehensive SE Type Mapping

| SE Type | R (sandwich) | R (fixest) | pyfixest | statsmodels |
|---------|-------------|-----------|----------|-------------|
| IID | Default | `"iid"` | `"iid"` | Default |
| HC0 (White) | `vcovHC(type="HC0")` | N/A | N/A | `cov_type="HC0"` |
| HC1 | `vcovHC(type="HC1")` | `"hetero"` or `"HC1"` | `"hetero"` or `"HC1"` | `cov_type="HC1"` |
| HC2 | `vcovHC(type="HC2")` | N/A | `"HC2"` (no FE/IV) | `cov_type="HC2"` |
| HC3 | `vcovHC(type="HC3")` | N/A | `"HC3"` (no FE/IV) | `cov_type="HC3"` |
| 1-way cluster | `vcovCL(cluster=...)` | `vcov = ~g` | `{"CRV1": "g"}` | `cov_type="cluster"` |
| 2-way cluster | `vcovCL(cluster=cbind(...))` | `vcov = ~g1 + g2` | `{"CRV1": "g1+g2"}` | Not built-in |
| Cluster jackknife | N/A | N/A | `{"CRV3": "g"}` | N/A |
| Newey-West (HAC) | `vcovHAC(fit)` | `"NW"` | `"NW"` | `cov_type="HAC"` |
| Driscoll-Kraay | N/A | `"DK"` | `"DK"` | N/A (use linearmodels) |

**Driscoll-Kraay in linearmodels:**
```python
fit = PanelOLS.from_formula("y ~ x + EntityEffects", data=df_panel).fit(
    cov_type="kernel", kernel="bartlett", bandwidth=5
)
```

### Important Notes

- **HC2 and HC3 in pyfixest** are only available for models without fixed effects
  or IV. With FE, use HC1 or clustered SEs.
- **Two-way clustering in statsmodels** is not directly supported. Use pyfixest or
  linearmodels instead.
- **Default SE changed in pyfixest v0.40**: Both R fixest 0.13 and pyfixest 0.40
  now default to `"iid"`. Older code that relied on automatic clustering by the
  first FE will silently produce different results.

---

## 7. Model Diagnostics

### Diagnostic Function Mapping

| Diagnostic | R | Python |
|-----------|---|--------|
| Summary | `summary(fit)` | `fit.summary()` (sm) / `fit.summary()` (pf) |
| Diagnostic plots | `plot(fit)` | `sm.graphics.plot_regress_exog(fit)` |
| VIF | `car::vif(fit)` | `variance_inflation_factor()` from `statsmodels.stats.outliers_influence` |
| Breusch-Pagan | `lmtest::bptest(fit)` | `sm.stats.diagnostic.het_breuschpagan(fit.resid, fit.model.exog)` |
| White test | `skedastic::white_lm(fit)` | `sm.stats.diagnostic.het_white(fit.resid, fit.model.exog)` |
| RESET test | `lmtest::resettest(fit)` | `sm.stats.diagnostic.linear_reset(fit)` |
| Durbin-Watson | `lmtest::dwtest(fit)` | `sm.stats.stattools.durbin_watson(fit.resid)` |
| Breusch-Godfrey | `lmtest::bgtest(fit)` | `sm.stats.diagnostic.acorr_breusch_godfrey(fit)` |
| Jarque-Bera | `tseries::jarque.bera.test(resid)` | `sm.stats.stattools.jarque_bera(fit.resid)` |
| Cook's distance | `cooks.distance(fit)` | `sm.OLSResults.get_influence().cooks_distance` |
| F-test (linear hyp.) | `car::linearHypothesis(fit, ...)` | `fit.f_test(r_matrix)` or `marginaleffects.hypotheses()` |

### VIF Example

**R:**
```r
library(car)
fit <- lm(y ~ x1 + x2 + x3, data = df)
vif(fit)
```

**Python:**
```python
from statsmodels.stats.outliers_influence import variance_inflation_factor
import numpy as np

fit = smf.ols("y ~ x1 + x2 + x3", data=df).fit()
exog = fit.model.exog
vif_values = [variance_inflation_factor(exog, i) for i in range(exog.shape[1])]
print(dict(zip(fit.model.exog_names, vif_values)))
```

Note that R's `vif()` is a single function call; Python requires a loop over
columns. This pattern — where R wraps complexity in one function and Python
requires manual assembly — recurs throughout diagnostics.

### Heteroskedasticity Test Example

**R:**
```r
library(lmtest)
bptest(fit)  # Breusch-Pagan test
```

**Python:**
```python
import statsmodels.api as sm

bp_stat, bp_pval, _, _ = sm.stats.diagnostic.het_breuschpagan(
    fit.resid, fit.model.exog
)
print(f"BP statistic: {bp_stat:.4f}, p-value: {bp_pval:.4f}")
```

---

## 8. Model Comparison Tables

### R Options

```r
# fixest etable (for fixest models)
library(fixest)
etable(fit1, fit2, fit3)
etable(fit1, fit2, tex = TRUE)    # LaTeX output

# modelsummary (for any model type)
library(modelsummary)
modelsummary(list(fit1, fit2, fit3))

# stargazer (legacy, widely used)
library(stargazer)
stargazer(fit1, fit2, fit3, type = "text")
```

### Python Options

```python
# pyfixest etable (for pyfixest models — closest to R fixest)
pf.etable([fit1, fit2, fit3])                  # Default GT table
pf.etable([fit1, fit2, fit3], type="md")       # Markdown
pf.etable([fit1, fit2, fit3], type="tex")      # LaTeX
pf.etable([fit1, fit2, fit3], type="df")       # DataFrame

# With customization
pf.etable(
    [fit1, fit2, fit3],
    labels={"X1": "Education", "X2": "Experience"},
    felabels={"entity": "Entity FE", "year": "Year FE"},
    keep=["X1", "X2"],
    signif_code=[0.001, 0.01, 0.05],
)

# Descriptive statistics table
pf.dtable(data, vars=["Y", "X1", "X2"])
```

### Comparison Table Tool Mapping

| Feature | R etable (fixest) | R modelsummary | pyfixest etable |
|---------|-------------------|----------------|-----------------|
| FE checkmarks | Yes | Yes | Yes |
| LaTeX output | `tex = TRUE` | `output = "latex"` | `type="tex"` |
| Markdown | `"markdown"` | `output = "markdown"` | `type="md"` |
| Custom labels | `dict` argument | `coef_map` | `labels` dict |
| Significance stars | Default | Configurable | `signif_code` |
| Model types | fixest only | 100+ model classes | pyfixest + statsmodels (via maketables) |

**Note:** pyfixest's `etable()` now uses the `maketables` package internally,
which also supports `statsmodels` and `linearmodels` result objects. The
`maketables.ETable()` function provides a unified interface across Python
modeling libraries.

---

## 9. Formula Syntax Reference Table

| Feature | R formula | patsy (statsmodels) | formulaic (pyfixest) | Notes |
|---------|-----------|--------------------|--------------------|-------|
| Intercept | Included by default | Included by default | Included by default | |
| No intercept | `y ~ x - 1` | `"y ~ x - 1"` | `"y ~ x - 1"` | `y ~ 0 + x` also works in all |
| Interaction only | `y ~ x1:x2` | `"y ~ x1:x2"` | `"y ~ x1:x2"` | |
| Full cross | `y ~ x1*x2` | `"y ~ x1*x2"` | `"y ~ x1*x2"` | Expands to `x1 + x2 + x1:x2` |
| Fixed effects | `y ~ x \| fe` (fixest) | N/A (use dummies) | `"y ~ x \| fe"` | statsmodels has no FE absorption |
| Categorical (default ref) | `factor(x)` | `C(x)` | `C(x)` | |
| Categorical (set ref) | `relevel(factor(x), ref="a")` | `C(x, Treatment('a'))` | `i(x, ref='a')` | Different syntax per system |
| Polynomial | `poly(x, 2)` | `I(x**2)` | `I(x**2)` | R's `poly()` is orthogonal; `I(x^2)` is raw |
| Log transform | `log(x)` | `np.log(x)` | `np.log(x)` | Python requires numpy import |
| Multiple depvars | `c(y1, y2) ~ x` (fixest) | N/A | `"y1 + y2 ~ x"` | **Syntax differs** |
| Stepwise | `fixest::sw(x1, x2)` | N/A | `"sw(x1, x2)"` | pyfixest-only feature |
| Cumulative stepwise | `fixest::csw0(x1, x2)` | N/A | `"csw0(x1, x2)"` | pyfixest-only feature |
| IV (fixest style) | `y ~ x1 \| fe \| x2 ~ z` | N/A | `"y ~ x1 \| fe \| x2 ~ z"` | Three-part formula |
| IV (linearmodels) | N/A | N/A | `"y ~ 1 + x1 + [x2 ~ z]"` | Bracket notation |

### Formula Engine Comparison

| Engine | Used By | Key Differences |
|--------|---------|----------------|
| R formula | Base R, fixest, plm | `factor()`, `poly()`, unquoted names |
| patsy | statsmodels | `C()` for categorical, `I()` protects operators, Python expressions OK |
| formulaic | pyfixest, linearmodels | `C()` and `i()` for categorical, `\|` for FE, supports `sw()`/`csw()` |

**Common pitfall:** R's `x^2` in a formula means interaction (`x:x`), not
squaring. Use `I(x^2)` in R for polynomial terms. Python's patsy and formulaic
have the same convention — `I(x**2)` is required for squaring.

**Categorical reference levels** are the biggest syntax divergence:
- R: `relevel(factor(x), ref = "baseline")` or fixest's `i(x, ref = "baseline")`
- patsy: `C(x, Treatment('baseline'))`
- formulaic: `i(x, ref='baseline')` or `C(x)` (default reference is first level)

> **Sources:** Berge, *fixest* reference manual (lrberge.github.io/fixest/);
> pyfixest documentation (pyfixest.org, accessed 2026-03-28);
> statsmodels documentation (statsmodels.org, v0.14.6);
> Sheppard, *linearmodels* documentation (bashtage.github.io/linearmodels/, v7.0);
> Croissant & Millo, "Panel Data Econometrics in R: the plm Package" (JSS, 2008);
> Zeileis, "Object-Oriented Computation of Sandwich Estimators" (JSS, 2006);
> Arel-Bundock, Greifer, & Heiss, "How to Interpret Statistical Models Using
> marginaleffects for R and Python" (JSS, 2024)

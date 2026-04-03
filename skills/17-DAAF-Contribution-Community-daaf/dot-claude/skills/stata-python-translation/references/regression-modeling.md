# Regression Modeling: Stata to Python Translation

Stata's estimation interface is unified and consistent: every model follows the
pattern `command depvar indepvars, options`. Post-estimation commands (`test`,
`lincom`, `margins`, `predict`) work identically regardless of the estimation
command that preceded them, and results live in global `e()` return values.

Python fragments this across multiple libraries, each with its own API:
- **pyfixest** (primary): Closest to Stata `regress`/`reghdfe`/`ivreghdfe` syntax; handles OLS, Poisson, IV, and FE regression with fast high-dimensional FE absorption
- **statsmodels** (general): R-style formula API for GLM, logit/probit, ordered/multinomial models, and diagnostics
- **linearmodels** (panel/IV/system): Panel RE/FE, LIML, GMM, SUR, Fama-MacBeth
- **marginaleffects** (post-estimation): Closest to Stata `margins`/`marginsplot`; same author as the R version

The most important mental model shift: Stata has one active estimation result at
a time, stored in `e()`. Python produces independent model objects that coexist
as variables. There is no `estimates store` / `estimates restore` — every
`pf.feols()` or `smf.ols().fit()` already returns a persistent object.

> **Versions referenced:**
> Python: pyfixest 0.40.0, statsmodels 0.14.6, linearmodels (unpinned), marginaleffects (unpinned)
> Stata: Stata 18 (SE/MP)
> See SKILL.md for the complete version table.

> **Sources:** Fischer et al., *pyfixest* (pyfixest.org, v0.40.0, accessed 2026-03-28);
> Seabold & Perktold, *statsmodels* (v0.14.6);
> Sheppard, *linearmodels* (bashtage.github.io/linearmodels, v7.0);
> Correia, "reghdfe" (scorreia.com);
> Turrell, "Coming from Stata" in *Coding for Economists* (aeturrell.github.io);
> pyfixest PR #897, "Show how to replicate Stata results";
> Arel-Bundock, Greifer, & Heiss, "marginaleffects for R and Python" (JSS, 2024)

---

## 1. OLS Regression

### Basic OLS

**Stata:**
```stata
regress y x1 x2
```

**Python (pyfixest — preferred):**
```python
import pyfixest as pf

fit = pf.feols("y ~ x1 + x2", data=df)  # No .fit() needed
fit.summary()
```

**Python (statsmodels):**
```python
import statsmodels.formula.api as smf

fit = smf.ols("y ~ x1 + x2", data=df).fit()  # Note: .fit() required
fit.summary()
```

### OLS with Robust Standard Errors

**Stata:**
```stata
regress y x1 x2, robust
regress y x1 x2, vce(hc3)
```

**Python (pyfixest):**
```python
fit = pf.feols("y ~ x1 + x2", data=df, vcov="hetero")  # HC1 (Stata default)
fit = pf.feols("y ~ x1 + x2", data=df, vcov="HC3")     # HC3
```

**Python (statsmodels):**
```python
fit = smf.ols("y ~ x1 + x2", data=df).fit(cov_type="HC1")  # Must specify HC1 explicitly
fit = smf.ols("y ~ x1 + x2", data=df).fit(cov_type="HC3")
```

Stata's `robust` option produces HC1 standard errors (small-sample adjusted
White SEs). pyfixest's `vcov="hetero"` defaults to HC1, matching Stata.
statsmodels defaults to IID, so you must specify `cov_type="HC1"` to match.

### OLS with Clustered Standard Errors

**Stata:**
```stata
regress y x1 x2, vce(cluster state)
regress y x1 x2, vce(cluster state year)
```

**Python (pyfixest):**
```python
fit = pf.feols("y ~ x1 + x2", data=df, vcov={"CRV1": "state"})
fit = pf.feols("y ~ x1 + x2", data=df, vcov={"CRV1": "state+year"})  # Two-way
```

**Python (statsmodels):**
```python
fit = smf.ols("y ~ x1 + x2", data=df).fit(
    cov_type="cluster", cov_kwds={"groups": df["state"]}
)
# Note: statsmodels does not support two-way clustering natively
```

### Accessing Results

| Stata | pyfixest | statsmodels | Notes |
|-------|----------|-------------|-------|
| `_b[x1]` | `fit.coef()["x1"]` | `fit.params["x1"]` | Coefficient |
| `_se[x1]` | `fit.se()["x1"]` | `fit.bse["x1"]` | Standard error |
| `e(N)` | `fit._N` | `fit.nobs` | Observation count |
| `e(r2)` | `fit._r2` | `fit.rsquared` | R-squared |
| `e(r2_a)` | `fit._adj_r2` | `fit.rsquared_adj` | Adjusted R-squared |
| `e(F)` | (not directly stored) | `fit.fvalue` | F-statistic |
| `predict yhat, xb` | `fit.predict()` | `fit.predict()` | Fitted values |
| `predict resid, residuals` | `fit.resid()` | `fit.resid` | Residuals |
| `matrix list e(b)` | `fit.coef()` | `fit.params` | Coefficient vector |
| `matrix list e(V)` | `fit.vcov()` | `fit.cov_params()` | Variance-covariance matrix |
| `ereturn list` | (inspect object attributes) | `dir(fit)` | List all stored results |
| `confint` (not built-in) | `fit.confint()` | `fit.conf_int()` | Confidence intervals |

### Key Differences

| Aspect | Stata | pyfixest | statsmodels |
|--------|-------|----------|-------------|
| Estimation call | `regress y x1 x2` | `pf.feols("y ~ x1 + x2", data=df)` | `smf.ols("y ~ x1 + x2", data=df).fit()` |
| Requires `.fit()` | No | No | **Yes** |
| Formula quoting | Unquoted | String | String |
| Default SE | IID | IID (since v0.40) | IID |
| `robust` shortcut | `, robust` | `vcov="hetero"` | `cov_type="HC1"` |
| Auto-prints results | Yes | No | No |

---

## 2. Fixed Effects Regression

### One-Way and Multi-Way FE

**Stata (`areg`):**
```stata
areg y x1 x2, absorb(state)
```

**Stata (`xtreg`):**
```stata
xtset entity year
xtreg y x1 x2, fe
xtreg y x1 x2, fe vce(cluster entity)
```

**Stata (`reghdfe` — most common for applied work):**
```stata
reghdfe y x1 x2, absorb(state)
reghdfe y x1 x2, absorb(state year)
reghdfe y x1 x2, absorb(state year industry)
reghdfe y x1 x2, absorb(state#year)
```

**Python (pyfixest):**
```python
# One-way FE (matches areg or reghdfe with single absorb)
fit = pf.feols("y ~ x1 + x2 | state", data=df)

# Two-way FE
fit = pf.feols("y ~ x1 + x2 | state + year", data=df)

# Three-way FE
fit = pf.feols("y ~ x1 + x2 | state + year + industry", data=df)

# Interacted FE (state-by-year)
fit = pf.feols("y ~ x1 + x2 | state^year", data=df)
```

### FE with Clustered Standard Errors

**Stata:**
```stata
reghdfe y x1 x2, absorb(state year) cluster(state)
reghdfe y x1 x2, absorb(state year) cluster(state year)
```

**Python (pyfixest):**
```python
fit = pf.feols("y ~ x1 + x2 | state + year", data=df, vcov={"CRV1": "state"})
fit = pf.feols("y ~ x1 + x2 | state + year", data=df, vcov={"CRV1": "state+year"})
```

### Interacted FE and Interactions with Categoricals

**Stata:**
```stata
reghdfe y x1 c.x2#i.category, absorb(state)
reghdfe y x1, absorb(state#year)
```

**Python (pyfixest):**
```python
fit = pf.feols("y ~ x1 + x2:C(category) | state", data=df)
fit = pf.feols("y ~ x1 | state^year", data=df)
```

### FE Syntax Mapping

| Stata | pyfixest | Notes |
|-------|----------|-------|
| `areg y x, absorb(fe)` | `"y ~ x \| fe"` | Single FE |
| `xtreg y x, fe` | `"y ~ x \| entity"` | Panel FE |
| `reghdfe y x, absorb(fe1 fe2)` | `"y ~ x \| fe1 + fe2"` | Multi-way FE |
| `reghdfe y x, absorb(fe1#fe2)` | `"y ~ x \| fe1^fe2"` | Interacted FE |
| `reghdfe ..., cluster(cl)` | `vcov={"CRV1": "cl"}` | Cluster SE |
| `reghdfe ..., cluster(cl1 cl2)` | `vcov={"CRV1": "cl1+cl2"}` | Two-way cluster |

### Extracting Fixed Effects

**Stata:**
```stata
reghdfe y x, absorb(state, savefe)
predict fe_state, d
```

**Python (pyfixest):**
```python
fit = pf.feols("y ~ x | state", data=df)
fe = fit.fixef()       # Returns dict of Series
fe["state"]            # State-level FE estimates
```

pyfixest uses the same iterative demean algorithm as `reghdfe` (Correia, 2016)
and produces numerically equivalent results. pyfixest is generally faster for
datasets with many FE levels.

---

## 3. Random Effects

### Panel Random Effects

**Stata:**
```stata
xtset entity year
xtreg y x1 x2, re
```

**Python (linearmodels):**
```python
from linearmodels.panel import RandomEffects

# Critical: linearmodels requires a pandas MultiIndex (entity, time)
df_panel = df.to_pandas().set_index(["entity", "year"])
fit = RandomEffects.from_formula("y ~ 1 + x1 + x2", data=df_panel).fit()
print(fit.summary)
```

### Panel Setup: `xtset` vs MultiIndex

| Stata | Python | Notes |
|-------|--------|-------|
| `xtset entity year` | `df.to_pandas().set_index(["entity", "year"])` | Stata declares panel structure globally; Python requires MultiIndex |
| `L.var` (lag) | `pl.col("var").shift(1).over("entity")` | Must sort by time first in polars |
| `F.var` (lead) | `pl.col("var").shift(-1).over("entity")` | |
| `D.var` (first difference) | `(pl.col("var") - pl.col("var").shift(1)).over("entity")` | |

### Hausman Test (FE vs RE)

**Stata:**
```stata
xtreg y x1 x2, fe
estimates store fe
xtreg y x1 x2, re
estimates store re
hausman fe re
```

**Python (linearmodels):**
```python
from linearmodels.panel import PanelOLS, RandomEffects, compare

df_panel = df.to_pandas().set_index(["entity", "year"])
fe_res = PanelOLS.from_formula("y ~ x1 + x2 + EntityEffects", data=df_panel).fit()
re_res = RandomEffects.from_formula("y ~ 1 + x1 + x2", data=df_panel).fit()
comparison = compare({"FE": fe_res, "RE": re_res})
print(comparison)
# Note: linearmodels does not have a built-in hausman test;
# the test must be constructed manually from coefficient differences
```

---

## 4. Instrumental Variables

### Two-Stage Least Squares (2SLS)

**Stata:**
```stata
ivregress 2sls y x_exog (x_endog = z1 z2)
ivregress 2sls y x_exog (x_endog = z1 z2), robust
```

**Python (pyfixest — three-part formula):**
```python
# Y ~ exogenous | FE (0 = none) | endogenous ~ instruments
fit = pf.feols("y ~ x_exog | 0 | x_endog ~ z1 + z2", data=df)
fit = pf.feols("y ~ x_exog | 0 | x_endog ~ z1 + z2", data=df, vcov="hetero")
```

### IV with Fixed Effects

**Stata:**
```stata
ivreghdfe y x_exog (x_endog = z1), absorb(state year)
ivreghdfe y x_exog (x_endog = z1), absorb(state year) cluster(state)
```

**Python (pyfixest):**
```python
fit = pf.feols("y ~ x_exog | state + year | x_endog ~ z1", data=df)
fit = pf.feols("y ~ x_exog | state + year | x_endog ~ z1", data=df,
               vcov={"CRV1": "state"})
```

### IV without FE (linearmodels)

**Stata:**
```stata
ivregress 2sls y x_exog (x_endog = z1 z2)
ivregress liml y x_exog (x_endog = z1 z2)
ivregress gmm y x_exog (x_endog = z1 z2)
```

**Python (linearmodels):**
```python
from linearmodels.iv import IV2SLS, IVLIML, IVGMM

# 2SLS — bracket notation: [endogenous ~ instruments]
fit = IV2SLS.from_formula("y ~ 1 + x_exog + [x_endog ~ z1 + z2]", data=df).fit()

# LIML — better finite-sample properties
fit = IVLIML.from_formula("y ~ 1 + x_exog + [x_endog ~ z1 + z2]", data=df).fit()

# GMM — efficient with heteroskedasticity
fit = IVGMM.from_formula("y ~ 1 + x_exog + [x_endog ~ z1 + z2]", data=df).fit()
```

### IV Formula Notation Comparison

| Feature | Stata | pyfixest | linearmodels |
|---------|-------|----------|--------------|
| Basic IV | `y x_exog (x_endog = z)` | `"y ~ x_exog \| 0 \| x_endog ~ z"` | `"y ~ 1 + x_exog + [x_endog ~ z]"` |
| IV + FE | `ivreghdfe ..., absorb(fe)` | `"y ~ x_exog \| fe \| x_endog ~ z"` | Not supported |
| Multiple instruments | `(x_endog = z1 z2)` | `"x_endog ~ z1 + z2"` | `"[x_endog ~ z1 + z2]"` |
| Exogenous controls | Before parentheses | After first `~`, before first `\|` | Before brackets |

### First-Stage Diagnostics

**Stata:**
```stata
ivregress 2sls y x_exog (x_endog = z1 z2), first
estat firststage
estat overid
estat endogeneity
```

**Python (pyfixest):**
```python
fit = pf.feols("y ~ x_exog | 0 | x_endog ~ z1 + z2", data=df)
fit.IV_Diag()                        # Comprehensive diagnostics (effective F, etc.)
fit._model_1st_stage.summary()       # First-stage results
```

**Python (linearmodels):**
```python
fit = IV2SLS.from_formula("y ~ 1 + x_exog + [x_endog ~ z1 + z2]", data=df).fit()
print(fit.first_stage)               # First-stage results
print(fit.sargan)                    # Overidentification test
print(fit.wu_hausman())              # Endogeneity test
```

### IV Diagnostic Mapping

| Stata | pyfixest | linearmodels |
|-------|----------|--------------|
| `estat firststage` | `fit.IV_Diag()` | `fit.first_stage` |
| `estat overid` | Not built-in | `fit.sargan` |
| `estat endogeneity` | Not built-in | `fit.wu_hausman()` |
| First-stage F | `fit.IV_Diag()` (effective F) | Cragg-Donald F |

---

## 5. GLM: Logit, Probit, Poisson, Negative Binomial

### Binary Choice Models

**Stata:**
```stata
logit y x1 x2
logit y x1 x2, or
probit y x1 x2
logit y x1 x2, vce(robust)
```

**Python (statsmodels):**
```python
import statsmodels.formula.api as smf
import numpy as np

# Logit
fit = smf.logit("y ~ x1 + x2", data=df).fit()

# Odds ratios (Stata: logit ..., or)
np.exp(fit.params)

# Probit
fit = smf.probit("y ~ x1 + x2", data=df).fit()

# Robust SEs
fit = smf.logit("y ~ x1 + x2", data=df).fit(cov_type="HC1")
```

### Ordered and Multinomial Models

**Stata:**
```stata
ologit y x1 x2
oprobit y x1 x2
mlogit y x1 x2
```

**Python (statsmodels):**
```python
from statsmodels.miscmodels.ordinal_model import OrderedModel
import statsmodels.api as sm

# Ordered logit
fit = OrderedModel(df["y"], df[["x1", "x2"]], distr="logit").fit()

# Ordered probit
fit = OrderedModel(df["y"], df[["x1", "x2"]], distr="probit").fit()

# Multinomial logit
fit = sm.MNLogit(df["y"], sm.add_constant(df[["x1", "x2"]])).fit()
```

### Count Models

**Stata:**
```stata
poisson y x1 x2
poisson y x1 x2, robust
ppmlhdfe y x1 x2, absorb(state year)
nbreg y x1 x2
```

**Python:**
```python
# Poisson (statsmodels)
fit = smf.poisson("y ~ x1 + x2", data=df).fit()
fit = smf.poisson("y ~ x1 + x2", data=df).fit(cov_type="HC1")  # Robust

# Poisson pseudo-ML with FE (pyfixest — matches ppmlhdfe)
fit = pf.fepois("y ~ x1 + x2 | state + year", data=df)

# Negative binomial
fit = sm.NegativeBinomial(
    df["y"], sm.add_constant(df[["x1", "x2"]]), loglike_method="nb2"
).fit()
# Or via GLM:
fit = smf.glm("y ~ x1 + x2", data=df,
              family=sm.families.NegativeBinomial()).fit()
```

Stata's `nbreg` uses the NB2 parameterization by default (variance = mu +
alpha*mu^2). statsmodels' `NegativeBinomial` supports `"nb2"`, `"nb1"`, and
`"geometric"` via the `loglike_method` parameter.

### GLM with Fixed Effects: The Major Gap

Stata can absorb high-dimensional FE in GLM models via `ppmlhdfe` (Poisson) or
manual dummies with `logit y x i.fe_var`. R fixest has `feglm()`.

**pyfixest's `feglm()` does NOT support fixed effects absorption.** This is the
single largest feature gap between Stata/R and the DAAF Python stack for GLM
estimation.

**Workarounds:**

| Approach | Code | When to Use |
|----------|------|-------------|
| Linear probability model | `pf.feols("binary_y ~ x \| fe", data=df)` | Most cases; interpret coefficients as pp changes |
| Manual dummies + statsmodels | `smf.logit("y ~ x + C(fe_var)", data=df).fit()` | Small/moderate number of FE levels |
| Conditional logit | `sm.discrete.ConditionalLogit(...)` | Binary outcome with entity FE |
| Poisson pseudo-ML | `pf.fepois("binary_y ~ x \| fe", data=df)` | If log-linear approximation acceptable |

### GLM Family/Link Mapping

| Stata Command | statsmodels | Notes |
|---------------|-------------|-------|
| `logit y x` | `smf.logit("y ~ x", data=df).fit()` | Binary logistic |
| `probit y x` | `smf.probit("y ~ x", data=df).fit()` | Binary probit |
| `ologit y x` | `OrderedModel(y, X, distr="logit").fit()` | Ordered logistic |
| `oprobit y x` | `OrderedModel(y, X, distr="probit").fit()` | Ordered probit |
| `mlogit y x` | `sm.MNLogit(y, X).fit()` | Multinomial logistic |
| `poisson y x` | `smf.poisson("y ~ x", data=df).fit()` | Poisson |
| `nbreg y x` | `sm.NegativeBinomial(y, X, loglike_method="nb2").fit()` | Negative binomial |
| `glm y x, family(gamma)` | `smf.glm("y ~ x", data=df, family=sm.families.Gamma()).fit()` | Gamma |

---

## 6. Post-Estimation

### 6a. Hypothesis Testing

**Stata:**
```stata
regress y x1 x2 x3
test x1 x2                        * Joint F-test: x1 = x2 = 0
test x1 = x2                      * Equality test: x1 == x2
test x1 + x2 = 1                  * Linear restriction
```

**Python (pyfixest):**
```python
fit = pf.feols("y ~ x1 + x2 + x3", data=df)
fit.wald_test("x1 = 0, x2 = 0")       # Joint F-test
fit.wald_test("x1 - x2 = 0")          # Equality test
```

**Python (statsmodels):**
```python
fit = smf.ols("y ~ x1 + x2 + x3", data=df).fit()
fit.f_test("x1 = 0, x2 = 0")          # Joint F-test
fit.t_test("x1 - x2 = 0")             # Equality test
```

**Python (marginaleffects):**
```python
from marginaleffects import hypotheses
hypotheses(fit, "x1 = x2")            # Equality test
```

### 6b. Linear and Nonlinear Combinations

**Stata:**
```stata
lincom x1 + x2
lincom x1 - 2*x2
nlcom _b[x1] / _b[x2]
nlcom (_b[x1] / _b[x2] - 1) * 100
```

**Python (marginaleffects):**
```python
from marginaleffects import hypotheses

hypotheses(fit, "x1 + x2 = 0")                    # lincom x1 + x2
hypotheses(fit, "x1 - 2*x2 = 0")                  # lincom x1 - 2*x2
hypotheses(fit, "x1 / x2 = 0")                    # nlcom _b[x1]/_b[x2]
hypotheses(fit, "(x1 / x2 - 1) * 100 = 0")        # nlcom with transformation
```

The `marginaleffects.hypotheses()` function handles both linear and nonlinear
combinations using the delta method, unifying Stata's `lincom` and `nlcom` in
a single function.

### 6c. Marginal Effects

**Stata:**
```stata
logit y x1 x2 x3
margins, dydx(*)                              * AME for all variables
margins, dydx(x1)                             * AME for x1 only
margins, at(x1=(0 1))                         * Predictions at specific values
margins, at(x1=(0 1)) dydx(x2)               * Conditional AME
margins group, dydx(x1)                       * Group-specific AME
marginsplot
```

**Python (marginaleffects):**
```python
from marginaleffects import avg_slopes, predictions, avg_comparisons, datagrid

fit = smf.logit("y ~ x1 + x2 + x3", data=df).fit()

# AME for all variables (margins, dydx(*))
avg_slopes(fit)

# AME for x1 only (margins, dydx(x1))
avg_slopes(fit, variables="x1")

# Predictions at specific values (margins, at(x1=(0 1)))
predictions(fit, newdata=datagrid(x1=[0, 1], model=fit))

# Conditional AME (margins, at(x1=(0 1)) dydx(x2))
avg_slopes(fit, variables="x2", newdata=datagrid(x1=[0, 1], model=fit))

# Group-specific AME (margins group, dydx(x1))
avg_slopes(fit, variables="x1", by="group")

# Discrete change (margins, dydx(x1) contrast(ar))
avg_comparisons(fit, variables={"x1": [0, 1]})
```

There is no built-in `marginsplot` equivalent. Extract results from
`marginaleffects` output and plot with plotnine or matplotlib.

### Marginal Effects Mapping

| Stata | Python (marginaleffects) | Notes |
|-------|--------------------------|-------|
| `margins, dydx(*)` | `avg_slopes(fit)` | All variables |
| `margins, dydx(x1)` | `avg_slopes(fit, variables="x1")` | Single variable |
| `margins, at(x1=(0 1))` | `predictions(fit, newdata=datagrid(x1=[0, 1], model=fit))` | Predictive margins |
| `margins, dydx(x1) at(x2=(0 1))` | `avg_slopes(fit, variables="x1", newdata=datagrid(x2=[0, 1], model=fit))` | Conditional AME |
| `margins group` | `avg_slopes(fit, by="group")` or `predictions(fit, by="group")` | By group |
| `marginsplot` | Manual with plotnine | No built-in equivalent |

**Caveat:** The Python `marginaleffects` package is described by its author as an
alpha release. There are known numerical discrepancies in some edge cases. For
published research, verify critical marginal effects calculations against Stata.

### 6d. Predictions

**Stata:**
```stata
regress y x1 x2
predict yhat, xb
predict resid, residuals
predict leverage, leverage
predict cooksd, cooksd
```

**Python (pyfixest):**
```python
fit = pf.feols("y ~ x1 + x2", data=df)
yhat = fit.predict()           # Fitted values (returns Series)
resid = fit.resid()            # Residuals (returns Series)
```

**Python (statsmodels):**
```python
fit = smf.ols("y ~ x1 + x2", data=df).fit()
yhat = fit.predict()           # Fitted values
resid = fit.resid              # Residuals (note: attribute, not method)
infl = fit.get_influence()     # Influence diagnostics object
leverage = infl.hat_matrix_diag
cooksd = infl.cooks_distance[0]
```

Stata's `predict` adds a new column to the in-memory dataset. Python returns
arrays that must be explicitly added to the DataFrame:
```python
df = df.with_columns(pl.Series("yhat", fit.predict()))
```

---

## 7. Estimation Tables

### Building Comparison Tables

**Stata:**
```stata
eststo clear
eststo: regress y x1
eststo: regress y x1 x2
eststo: regress y x1 x2 x3
esttab, se star(* 0.10 ** 0.05 *** 0.01) r2 label
esttab using "table.tex", replace tex
```

**Python (pyfixest):**
```python
fit1 = pf.feols("y ~ x1", data=df)
fit2 = pf.feols("y ~ x1 + x2", data=df)
fit3 = pf.feols("y ~ x1 + x2 + x3", data=df)

# Default table (GT format for notebooks)
pf.etable([fit1, fit2, fit3])

# Markdown output
pf.etable([fit1, fit2, fit3], type="md")

# LaTeX output
pf.etable([fit1, fit2, fit3], type="tex")

# With customization
pf.etable(
    [fit1, fit2, fit3],
    labels={"x1": "Education", "x2": "Experience", "x3": "Tenure"},
    felabels={"state": "State FE", "year": "Year FE"},
    keep=["x1", "x2", "x3"],
    signif_code=[0.001, 0.01, 0.05],
)
```

### Table Option Mapping

| Stata (`esttab`) | pyfixest (`etable`) | Notes |
|------------------|---------------------|-------|
| `se` | Default (SEs shown) | |
| `star(* 0.10 ** 0.05 *** 0.01)` | `signif_code=[0.01, 0.05, 0.10]` | Note reversed order |
| `r2` | Included by default | |
| `label` | `labels={"x1": "Education"}` | Dictionary mapping |
| `indicate(FE=*)` | `felabels={"state": "State FE"}` | FE checkmark rows |
| `keep(x1 x2)` | `keep=["x1", "x2"]` | Show only selected vars |
| `using "table.tex"` | `type="tex"` | Returns LaTeX string |
| `using "table.md", md` | `type="md"` | Markdown format |

**`etable()` output types:**
- `type="gt"` — default, returns a Great Tables object (renders in notebooks)
- `type="md"` — Markdown string
- `type="tex"` — LaTeX string
- `type="df"` — pandas DataFrame (for custom formatting)

pyfixest's `etable()` uses the `maketables` package internally, which also
supports `statsmodels` and `linearmodels` result objects.

### Descriptive Statistics Table

**Stata:**
```stata
summarize y x1 x2 x3
```

**Python (pyfixest):**
```python
pf.dtable(df, vars=["y", "x1", "x2", "x3"])
```

---

## 8. Standard Errors: Comprehensive Reference

This section is critical for replication. Stata users are trained to be explicit
about their SE choice, and getting the wrong SE type silently produces different
results, different p-values, and potentially different conclusions.

### SE Type Mapping

| Stata | pyfixest | statsmodels | Notes |
|-------|----------|-------------|-------|
| (default, no option) | `vcov="iid"` | default | IID (classical) |
| `, robust` | `vcov="hetero"` | `cov_type="HC1"` | HC1 (Stata's robust default) |
| `, vce(hc2)` | `vcov="HC2"` | `cov_type="HC2"` | HC2 (no FE/IV in pyfixest) |
| `, vce(hc3)` | `vcov="HC3"` | `cov_type="HC3"` | HC3 (no FE/IV in pyfixest) |
| `, vce(cluster cl)` | `vcov={"CRV1": "cl"}` | `cov_type="cluster"` | One-way cluster |
| `, vce(cluster cl1 cl2)` | `vcov={"CRV1": "cl1+cl2"}` | Not supported | Two-way cluster |
| `, vce(bootstrap)` | Wild bootstrap (pyfixest) | `cov_type="hac-panel"` | Bootstrap |
| (Newey-West HAC) | `vcov="NW"` | `cov_type="HAC"` | Time series |
| (Driscoll-Kraay) | `vcov="DK"` | Not supported | Panel; use linearmodels |

### Switching SEs Post-Estimation

**Stata:**
```stata
regress y x1 x2
* Default IID results shown
regress y x1 x2, robust
* Now shows HC1 results
```

**Python (pyfixest):**
```python
fit = pf.feols("y ~ x1 + x2", data=df)
fit.summary()                          # IID
fit.vcov("hetero")                     # Switch to HC1
fit.vcov({"CRV1": "state"})           # Switch to clustered
fit.vcov({"CRV1": "state+year"})      # Switch to two-way clustered
fit.summary()                          # Now shows new SEs
```

### Important Notes

- **HC2 and HC3 in pyfixest** are only available for models without fixed effects
  or IV. With FE, use HC1 or clustered SEs.
- **Two-way clustering in statsmodels** is not directly supported. Use pyfixest or
  linearmodels instead.
- **Default SE changed in pyfixest v0.40**: Both R fixest 0.13 and pyfixest 0.40
  now default to `"iid"`. Older pyfixest code that relied on automatic clustering
  by the first FE variable will silently produce different results.
- **Stata's `robust` = HC1**: When a Stata do-file uses `, robust`, the Python
  equivalent is `vcov="hetero"` (pyfixest) or `cov_type="HC1"` (statsmodels). Do
  not use HC0 or HC3 when replicating Stata results unless the Stata code
  explicitly specifies those.

### Driscoll-Kraay in linearmodels

```python
from linearmodels.panel import PanelOLS

df_panel = df.to_pandas().set_index(["entity", "year"])
fit = PanelOLS.from_formula(
    "y ~ x1 + x2 + EntityEffects", data=df_panel
).fit(cov_type="kernel", kernel="bartlett", bandwidth=5)
```

### Wild Bootstrap (Cluster-Robust Inference)

**Stata:**
```stata
boottest x1, cluster(state) noci
```

**Python (pyfixest):**
```python
fit = pf.feols("y ~ x1 + x2", data=df, vcov={"CRV1": "state"})
fit.wildboottest(param="x1", reps=9999)
```

---

## 9. Stored Results and the `e()` / `r()` System

### The Fundamental Difference

Stata maintains one active estimation result at a time in `e()`:

```stata
regress y x1 x2          /* e() now holds OLS results */
display e(r2)             /* works */
regress y x1              /* OVERWRITES e() with new results */
display e(r2)             /* now shows R2 from the second regression */
```

Python model objects coexist independently:

```python
fit1 = pf.feols("y ~ x1 + x2", data=df)
fit2 = pf.feols("y ~ x1", data=df)
# Both fit1 and fit2 are fully accessible simultaneously
print(fit1._r2)           # R2 from first model
print(fit2._r2)           # R2 from second model
```

### Result Storage Mapping

| Stata | pyfixest | statsmodels | Notes |
|-------|----------|-------------|-------|
| `e(b)` — coefficient vector | `fit.coef()` | `fit.params` | |
| `e(V)` — variance-covariance | `fit.vcov()` | `fit.cov_params()` | |
| `e(N)` — observations | `fit._N` | `fit.nobs` | |
| `e(r2)` — R-squared | `fit._r2` | `fit.rsquared` | |
| `e(r2_a)` — adjusted R2 | `fit._adj_r2` | `fit.rsquared_adj` | |
| `e(df_r)` — residual df | `fit._df_resid` | `fit.df_resid` | |
| `e(rmse)` — root MSE | `fit._rmse` | `fit.mse_resid ** 0.5` | |
| `r(mean)` after `summarize` | `df["var"].mean()` | `df["var"].mean()` | r-class from summarize |
| `r(sd)` after `summarize` | `df["var"].std()` | `df["var"].std()` | |
| `r(N)` after `summarize` | `df.height` | `len(df)` | |
| `estimates store m1` | `m1 = pf.feols(...)` | `m1 = smf.ols(...).fit()` | Already stored as variable |
| `estimates restore m1` | Just use `m1` | Just use `m1` | No restore needed |

### Model Storage for Comparison

**Stata pattern:**
```stata
regress y x1
estimates store m1
regress y x1 x2
estimates store m2
estimates table m1 m2, star stats(N r2)
```

**Python equivalent:**
```python
m1 = pf.feols("y ~ x1", data=df)
m2 = pf.feols("y ~ x1 + x2", data=df)
pf.etable([m1, m2])  # Already stored; no estimates store needed
```

### Formula Syntax Quick Reference

| Feature | Stata | pyfixest | statsmodels (patsy) |
|---------|-------|----------|---------------------|
| Intercept | Included by default | Included by default | Included by default |
| No intercept | `regress y x, nocons` | `"y ~ x - 1"` | `"y ~ x - 1"` |
| Interaction | `c.x1#c.x2` | `"x1:x2"` | `"x1:x2"` |
| Full cross | `c.x1##c.x2` | `"x1*x2"` | `"x1*x2"` |
| Factor variable | `i.group` | `C(group)` or `i(group)` | `C(group)` |
| Reference level | `ib3.group` | `i(group, ref=3)` | `C(group, Treatment(3))` |
| Fixed effects | `absorb(fe)` (reghdfe) | `"\| fe"` after regressors | Not supported (use dummies) |
| Polynomial | `c.x#c.x` | `I(x**2)` | `I(x**2)` |
| Log transform | `ln(x)` in gen, then use | `np.log(x)` in formula | `np.log(x)` in formula |
| Multiple depvars | Not in base regress | `"y1 + y2 ~ x"` | Not supported |
| Stepwise vars | Not native | `"sw(x1, x2)"` | Not supported |

### SUR (Seemingly Unrelated Regressions)

**Stata:**
```stata
sureg (eq1: y1 x1 x2) (eq2: y2 x3 x4)
```

**Python (linearmodels):**
```python
from linearmodels.system import SUR
import statsmodels.api as sm

system = {
    "eq1": {"dependent": df["y1"], "exog": sm.add_constant(df[["x1", "x2"]])},
    "eq2": {"dependent": df["y2"], "exog": sm.add_constant(df[["x3", "x4"]])},
}
sur = SUR(system)
result = sur.fit()
print(result.summary)
```

---

## 10. Model Diagnostics

### Diagnostic Function Mapping

| Diagnostic | Stata | Python | Notes |
|-----------|-------|--------|-------|
| VIF | `estat vif` | `variance_inflation_factor()` from `statsmodels.stats.outliers_influence` | Must loop over columns |
| Breusch-Pagan | `estat hettest` | `sm.stats.diagnostic.het_breuschpagan(fit.resid, fit.model.exog)` | |
| White test | `estat imtest, white` | `sm.stats.diagnostic.het_white(fit.resid, fit.model.exog)` | |
| RESET test | `estat ovtest` | `sm.stats.diagnostic.linear_reset(fit)` | |
| Durbin-Watson | `estat dwatson` | `sm.stats.stattools.durbin_watson(fit.resid)` | |
| Breusch-Godfrey | `estat bgodfrey` | `sm.stats.diagnostic.acorr_breusch_godfrey(fit)` | |
| Cook's distance | `predict cooksd, cooksd` | `fit.get_influence().cooks_distance[0]` | |
| Leverage | `predict leverage, leverage` | `fit.get_influence().hat_matrix_diag` | |
| Jarque-Bera | `sktest resid` | `sm.stats.stattools.jarque_bera(fit.resid)` | |

### VIF Example

**Stata:**
```stata
regress y x1 x2 x3
estat vif
```

**Python:**
```python
from statsmodels.stats.outliers_influence import variance_inflation_factor

fit = smf.ols("y ~ x1 + x2 + x3", data=df).fit()
exog = fit.model.exog
vif_values = [variance_inflation_factor(exog, i) for i in range(exog.shape[1])]
print(dict(zip(fit.model.exog_names, vif_values)))
```

R's `vif()` and Stata's `estat vif` are single function calls; Python requires
a manual loop. This pattern recurs throughout diagnostics — where Stata wraps
complexity in one command, Python requires manual assembly.

> **Sources:** Fischer et al., *pyfixest* (pyfixest.org, v0.40.0);
> Seabold & Perktold, *statsmodels* (v0.14.6);
> Sheppard, *linearmodels* (bashtage.github.io/linearmodels, v7.0);
> Correia, "reghdfe" (scorreia.com);
> Turrell, "Coming from Stata" (aeturrell.github.io);
> Arel-Bundock, Greifer, & Heiss, "marginaleffects for R and Python" (JSS, 2024);
> Cunningham, *Causal Inference: The Mixtape* (Yale, 2021);
> Huntington-Klein, *The Effect* (CRC Press, 2021)

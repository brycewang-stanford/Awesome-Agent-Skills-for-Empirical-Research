# statsmodels Linear Models Reference

statsmodels v0.14.6 — syntax and library guidance only.

---

## Contents

1. [OLS (Ordinary Least Squares)](#ols-ordinary-least-squares)
2. [WLS (Weighted Least Squares)](#wls-weighted-least-squares)
3. [GLS (Generalized Least Squares)](#gls-generalized-least-squares)
4. [Robust Regression (RLM)](#robust-regression-rlm)
5. [Quantile Regression (QuantReg)](#quantile-regression-quantreg)
6. [Polynomial and Spline Regression](#polynomial-and-spline-regression)
7. [Interaction Terms](#interaction-terms)
8. [Mixed Effects / Multilevel Models (MixedLM)](#mixed-effects--multilevel-models-mixedlm)
9. [References and Further Reading](#references-and-further-reading)

---

## OLS (Ordinary Least Squares)

### Formula API

```python
import statsmodels.formula.api as smf

results = smf.ols("y ~ x1 + x2 + x3", data=df).fit()
print(results.summary())
```

### Array API

```python
import statsmodels.api as sm

X = sm.add_constant(df[["x1", "x2", "x3"]])
results = sm.OLS(df["y"], X).fit()
print(results.summary())
```

`sm.add_constant()` prepends a column of ones to the design matrix. Without it, the model has no intercept. The constant column is named `"const"` by default.

### Accessing Coefficients

```python
# Point estimates
results.params          # Series indexed by variable name

# P-values (two-tailed)
results.pvalues

# Confidence intervals (default alpha=0.05)
results.conf_int()              # 95% CI — returns DataFrame with columns [0.025, 0.975]
results.conf_int(alpha=0.01)    # 99% CI
```

Example — extract a single coefficient with its CI:

```python
coef = results.params["x1"]
ci_lo, ci_hi = results.conf_int().loc["x1"]
print(f"x1: {coef:.4f} [{ci_lo:.4f}, {ci_hi:.4f}]")
```

### Model Fit Statistics

```python
results.rsquared        # R²
results.rsquared_adj    # Adjusted R²
results.aic             # Akaike Information Criterion
results.bic             # Bayesian Information Criterion
results.fvalue          # F-statistic (overall model significance)
results.f_pvalue        # p-value for F-test
results.nobs            # Number of observations
results.df_resid        # Residual degrees of freedom
results.df_model        # Model degrees of freedom (excl. constant)
results.mse_resid       # Mean squared error of residuals (= σ²)
```

### Fitted Values and Residuals

```python
results.fittedvalues    # ŷ — Series, same index as training data
results.resid           # ε = y - ŷ (raw residuals)
results.resid_pearson   # Pearson (standardized) residuals for OLS same as resid / RMSE
```

Studentized residuals (externally studentized, for outlier detection):

```python
influence = results.get_influence()
student_resid = influence.resid_studentized_external  # values > |2| flag potential outliers
```

### Prediction

In-sample fitted values:

```python
results.fittedvalues
```

Out-of-sample point prediction:

```python
new_data = pd.DataFrame({"x1": [1.5, 2.0], "x2": [3.0, 4.5], "x3": [0.1, 0.2]})
y_pred = results.predict(new_data)   # returns Series
```

Out-of-sample prediction with confidence and prediction intervals:

```python
pred = results.get_prediction(new_data)
frame = pred.summary_frame(alpha=0.05)
# Columns: mean, mean_se, mean_ci_lower, mean_ci_upper, obs_ci_lower, obs_ci_upper
# mean_ci_*: confidence interval for the mean response
# obs_ci_*: prediction interval for an individual observation
print(frame)
```

Array API — pass an array with the same column structure as the training X:

```python
X_new = sm.add_constant(pd.DataFrame({"x1": [1.5], "x2": [3.0], "x3": [0.1]}))
y_pred = results.predict(X_new)
```

### Saving and Reloading Results

```python
import pickle

# Save
with open("ols_results.pkl", "wb") as f:
    pickle.dump(results, f)

# Load
with open("ols_results.pkl", "rb") as f:
    results = pickle.load(f)
```

---

## WLS (Weighted Least Squares)

Use when errors have non-constant variance (heteroskedasticity) but the variance structure is known or estimable. Observations with smaller error variance receive higher weight.

### Formula API

```python
# weight = 1 / variance: high variance → low weight → less influence
results = smf.wls("y ~ x1 + x2", data=df, weights=1/df["variance"]).fit()
```

### Array API

```python
X = sm.add_constant(df[["x1", "x2"]])
results = sm.WLS(df["y"], X, weights=1/df["variance"]).fit()
```

### Common Weight Specifications

```python
# Population-weighted regression (each obs represents pop_i people)
results = smf.wls("y ~ x1 + x2", data=df, weights=df["population"]).fit()

# Precision weights from measurement error variance
results = smf.wls("y ~ x1", data=df, weights=1/df["meas_var"]).fit()

# Inverse of squared fitted standard deviations (feasible WLS)
ols_resid = smf.ols("y ~ x1", data=df).fit().resid
df["abs_resid"] = ols_resid.abs()
aux = smf.ols("abs_resid ~ x1", data=df).fit()
fitted_sd = aux.fittedvalues
results = smf.wls("y ~ x1", data=df, weights=1/fitted_sd**2).fit()
```

The `weights` parameter in statsmodels WLS is the **inverse of the error variance**, not the square root. Larger weight = observation is more reliable.

### Accessing Results

All standard OLS result attributes apply: `.params`, `.pvalues`, `.conf_int()`, `.fittedvalues`, `.resid`, `.rsquared`, etc.

The R² in WLS is weighted; interpret with care relative to OLS R².

---

## GLS (Generalized Least Squares)

Use when errors are correlated or have non-constant variance and the full covariance structure of errors is known (or estimable).

### Array API

```python
import statsmodels.api as sm
import numpy as np

X = sm.add_constant(df[["x1", "x2"]])
y = df["y"]

# sigma: covariance matrix of errors (n x n)
results = sm.GLS(y, X, sigma=covariance_matrix).fit()
```

`sigma` can be:
- A full `(n, n)` covariance matrix
- A 1-d array of length `n` for diagonal (heteroskedastic only, equivalent to WLS)
- `None` (falls back to OLS)

### GLSAR for AR(p) Error Structure

When errors follow an autoregressive process, `GLSAR` is more practical than specifying the full covariance matrix:

```python
# AR(1) errors
results = sm.GLSAR(y, X, rho=1).fit()

# AR(2) errors
results = sm.GLSAR(y, X, rho=2).fit()
```

Iterative estimation (Cochrane-Orcutt / Prais-Winsten style):

```python
from statsmodels.regression.linear_model import GLSAR

model = GLSAR(y, X, rho=1)
results = model.iterative_fit(maxiter=10)
print(f"Estimated rho: {model.rho}")
print(results.summary())
```

### GLS vs. WLS vs. GLSAR

| Situation | Recommended |
|-----------|-------------|
| Known variance weights only | `sm.WLS` |
| Known full error covariance matrix | `sm.GLS` |
| AR(p) error autocorrelation | `sm.GLSAR` |
| Unknown heteroskedasticity | `sm.OLS` + robust standard errors |

---

## Robust Regression (RLM)

M-estimators that iteratively downweight influential observations (outliers). Use when OLS residual diagnostics show influential outliers but removing them is not justified.

### Basic Usage

```python
import statsmodels.api as sm

X = sm.add_constant(df[["x1", "x2"]])
y = df["y"]

# Default: Huber's T norm
results = sm.RLM(y, X).fit()
print(results.summary())
```

Formula API (via `smf`):

```python
import statsmodels.formula.api as smf

results = smf.rlm("y ~ x1 + x2", data=df).fit()
```

### M-Estimator Norms

All norms are in `sm.robust.norms`:

```python
# Huber's T (default, tuning constant 1.345)
results = sm.RLM(y, X, M=sm.robust.norms.HuberT()).fit()

# Tukey's biweight (fully rejects extreme outliers)
results = sm.RLM(y, X, M=sm.robust.norms.TukeyBiweight()).fit()

# Andrew's wave (sinusoidal redescending)
results = sm.RLM(y, X, M=sm.robust.norms.AndrewWave()).fit()

# Hampel (three-part influence function)
results = sm.RLM(y, X, M=sm.robust.norms.Hampel()).fit()

# LeastSquares (equivalent to OLS — comparison baseline)
results = sm.RLM(y, X, M=sm.robust.norms.LeastSquares()).fit()
```

| Norm | Behavior | Use When |
|------|----------|----------|
| `HuberT()` | Default; tuning constant 1.345 | General robustness |
| `TukeyBiweight()` | Fully rejects extreme outliers | Known heavy outliers |
| `AndrewWave()` | Sinusoidal redescending | Moderate outlier resistance |
| `Hampel()` | Three-part influence function | Flexible outlier handling |
| `LeastSquares()` | Equivalent to OLS | Comparison baseline |

### Accessing Weights and Diagnostics

```python
results.weights         # Per-observation weights (0 = completely downweighted)
results.params          # Coefficient estimates
results.pvalues         # P-values
results.conf_int()      # Confidence intervals
```

Identifying downweighted observations:

```python
import pandas as pd

weight_df = pd.DataFrame({
    "weight": results.weights,
    "resid": results.resid
}, index=df.index)

# Observations with weight below 0.5 are substantially downweighted
outliers = weight_df[weight_df["weight"] < 0.5]
print(f"{len(outliers)} observations downweighted below 0.5")
print(outliers.sort_values("weight"))
```

### Comparing OLS and RLM

```python
ols_res = sm.OLS(y, X).fit()
rlm_res = sm.RLM(y, X).fit()

comparison = pd.DataFrame({
    "OLS": ols_res.params,
    "RLM": rlm_res.params,
    "diff": rlm_res.params - ols_res.params
})
print(comparison)
# Large differences signal that outliers are influencing OLS estimates
```

---

## Quantile Regression (QuantReg)

Models conditional quantiles of y rather than the conditional mean. Useful for understanding distributional effects, heterogeneous treatment effects, and when outliers make OLS mean-unstable.

### Basic Usage

```python
# Formula API — median regression
results = smf.quantreg("y ~ x1 + x2", data=df).fit(q=0.5)

# 25th percentile
results = smf.quantreg("y ~ x1 + x2", data=df).fit(q=0.25)

# 90th percentile
results = smf.quantreg("y ~ x1 + x2", data=df).fit(q=0.90)

# Array API
results = sm.QuantReg(y, X).fit(q=0.75)
```

The `q` parameter is the quantile to estimate (0 < q < 1). `q=0.5` is least absolute deviations (LAD) regression, equivalent to median regression.

### Standard Errors

By default, sparsity-based asymptotic standard errors are used. Bootstrap standard errors are often preferred in practice:

```python
# Kernel-based robust standard errors (default)
results = smf.quantreg("y ~ x1 + x2", data=df).fit(
    q=0.5,
    vcov="robust",    # default; kernel-based (Powell sandwich)
    kernel="epa",     # Epanechnikov kernel for sparsity estimation
    bandwidth="hsheather"  # bandwidth selection method
)
```

Available kernels for bandwidth: `"epa"` (Epanechnikov), `"cos"`, `"gau"` (Gaussian), `"par"` (Parzen), `"tri"` (triangular).

### Fitting Multiple Quantiles

```python
quantiles = [0.10, 0.25, 0.50, 0.75, 0.90]
qr_results = {}

for q in quantiles:
    qr_results[q] = smf.quantreg("y ~ x1 + x2", data=df).fit(q=q)

# Compare x1 coefficient across quantiles
x1_coefs = pd.Series(
    {q: qr_results[q].params["x1"] for q in quantiles},
    name="x1_coef"
)
print(x1_coefs)
```

### Accessing Results

All standard result attributes apply:

```python
results.params
results.pvalues
results.conf_int()
results.fittedvalues
results.resid
results.predict(new_data)
```

Pseudo R² (Koenker-Machado):

```python
results.prsquared   # 1 - sum(check_loss) / sum(check_loss_null)
```

---

## Polynomial and Spline Regression

### Polynomial Terms via `I()`

The `I()` wrapper in patsy formulas passes the expression through as raw Python, bypassing formula operator interpretation:

```python
# Quadratic (degree 2)
results = smf.ols("y ~ x1 + I(x1**2)", data=df).fit()

# Cubic (degree 3)
results = smf.ols("y ~ x1 + I(x1**2) + I(x1**3)", data=df).fit()

# Interaction with polynomial
results = smf.ols("y ~ x1 + I(x1**2) + x2 + x1:x2", data=df).fit()
```

In the array API, add polynomial columns to the DataFrame manually:

```python
X = pd.DataFrame({
    "x1": df["x1"],
    "x1_sq": df["x1"] ** 2,
    "x1_cu": df["x1"] ** 3,
    "x2": df["x2"]
})
X = sm.add_constant(X)
results = sm.OLS(df["y"], X).fit()
```

### B-Spline Basis via patsy `bs()`

```python
from patsy import bs

# Cubic B-spline with 4 degrees of freedom (1 intercept + 3 basis functions)
results = smf.ols("y ~ bs(x1, df=4, degree=3)", data=df).fit()

# Natural spline with knots at specific values
results = smf.ols("y ~ bs(x1, knots=[25, 50, 75], degree=3)", data=df).fit()

# Spline without intercept (no separate constant in the spline)
results = smf.ols("y ~ bs(x1, df=5, degree=3, include_intercept=False)", data=df).fit()
```

`df` (degrees of freedom): number of basis functions, equal to `degree + number_of_interior_knots`. Knot locations default to quantiles of x1.

`degree`:
- 1 = piecewise linear
- 2 = piecewise quadratic
- 3 = cubic (most common, C2 continuity)

Generating the spline basis for prediction or inspection:

```python
from patsy import dmatrix

# Fit on training data
basis_train = dmatrix("bs(x1, df=4, degree=3)", data=df, return_type="dataframe")
results = sm.OLS(df["y"], basis_train).fit()

# Apply same transformation to new data
basis_new = dmatrix("bs(x1, df=4, degree=3)", data=new_df, return_type="dataframe")
y_pred = results.predict(basis_new)
```

Using `dmatrix` ensures knot locations from training are reused at prediction time.

---

## Interaction Terms

### Formula API Operators

| Operator | Meaning | Equivalent to |
|----------|---------|---------------|
| `x1 * x2` | Full interaction (main effects + interaction) | `x1 + x2 + x1:x2` |
| `x1 : x2` | Interaction term only (no main effects) | product of x1 and x2 |
| `(x1 + x2 + x3)**2` | All pairwise interactions | `x1 + x2 + x3 + x1:x2 + x1:x3 + x2:x3` |

```python
# Full interaction
results = smf.ols("y ~ x1 * x2", data=df).fit()

# Interaction term only (suppresses main effects)
results = smf.ols("y ~ x1:x2", data=df).fit()

# Categorical interaction — C() marks a column as categorical
results = smf.ols("y ~ x1 * C(group)", data=df).fit()

# Three-way interaction (all lower-order terms included)
results = smf.ols("y ~ x1 * x2 * x3", data=df).fit()

# All pairwise interactions among three variables
results = smf.ols("y ~ (x1 + x2 + x3)**2", data=df).fit()
```

### Categorical Reference Level

By default, patsy uses the first category alphabetically as the reference level. Override:

```python
# Set "control" as the reference level
results = smf.ols("y ~ x1 * C(group, Treatment('control'))", data=df).fit()
```

### Array API — Manual Interaction Columns

```python
X = df[["x1", "x2"]].copy()
X["x1_x2"] = X["x1"] * X["x2"]   # continuous × continuous

# Continuous × categorical (dummy)
X["treat"] = (df["group"] == "treatment").astype(int)
X["x1_treat"] = X["x1"] * X["treat"]

X = sm.add_constant(X)
results = sm.OLS(df["y"], X).fit()
```

### Interpreting Interaction Coefficients

```python
results = smf.ols("y ~ x1 * x2", data=df).fit()

# Coefficient on x1:x2 is the marginal effect of x1 on y
# per unit increase in x2 (and vice versa)
print(results.params)
print(results.conf_int())

# For categorical interactions: the coefficient on x1:C(group)[T.treated]
# is the difference in the x1 slope between treated and reference groups
```

---

## Mixed Effects / Multilevel Models (MixedLM)

For hierarchical/nested data (e.g., students in schools, repeated measures):

```python
import statsmodels.formula.api as smf

# Random intercept model (varying intercept by group)
results = smf.mixedlm(
    "score ~ ses + school_type",
    data=df,
    groups=df["school_id"]
).fit()
print(results.summary())

# Random intercept + random slope
results = smf.mixedlm(
    "score ~ ses + school_type",
    data=df,
    groups=df["school_id"],
    re_formula="~ses"           # ses has a random slope by school
).fit()
```

Array API:
```python
import statsmodels.api as sm

model = sm.MixedLM(
    endog=y,
    exog=X,                     # fixed effects design matrix
    groups=groups,              # grouping variable
    exog_re=Z                   # random effects design matrix
)
results = model.fit()
```

Key parameters:
- `groups`: grouping variable defining the clusters (e.g., school ID, subject ID)
- `re_formula`: formula for random effects (default: random intercept only, `"~1"`)
- `vc_formula`: variance components formula for crossed random effects

Results attributes:
- `results.fe_params` — fixed effects coefficients
- `results.random_effects` — dict of random effects by group
- `results.cov_re` — random effects covariance matrix
- `results.bse_fe` — standard errors for fixed effects
- `results.bse_re` — standard errors for random effects variance components

Prediction:
```python
# Fixed effects prediction (population average)
pred = results.predict(new_data)

# Group-specific prediction (includes random effects)
pred = results.predict(new_data, exog_re=new_Z)
```

Common use cases in education research:
- Students nested in classrooms nested in schools (two-level or three-level)
- Repeated test scores for the same student over time (longitudinal)
- Schools nested in districts with district-level predictors

Convergence: MixedLM uses gradient-based optimization by default (BFGS, L-BFGS-B, CG sequence). For convergence issues, try:
```python
results = model.fit(method=["powell"])     # Powell optimizer
results = model.fit(maxiter=200)           # Increase max iterations
results = model.fit(reml=False)            # ML instead of REML
```

---

## References and Further Reading

- statsmodels OLS documentation: https://www.statsmodels.org/stable/regression.html
- statsmodels WLS documentation: https://www.statsmodels.org/stable/regression.html#wls
- statsmodels GLS documentation: https://www.statsmodels.org/stable/regression.html#gls
- statsmodels RLM documentation: https://www.statsmodels.org/stable/rlm.html
- statsmodels QuantReg documentation: https://www.statsmodels.org/stable/generated/statsmodels.regression.quantile_regression.QuantReg.html
- patsy formula language: https://patsy.readthedocs.io/en/latest/formulas.html
- patsy splines: https://patsy.readthedocs.io/en/latest/spline-regression.html
- Greene, W.H. (2018). *Econometric Analysis*, 8th ed. — Chapters 4-9 (OLS, GLS, WLS, robust)
- Wooldridge, J.M. (2019). *Introductory Econometrics*, 7th ed. — Chapters 4, 8 (OLS inference, heteroskedasticity)
- Koenker, R. (2005). *Quantile Regression*. Cambridge University Press.
- Maronna, R.A., Martin, R.D., Yohai, V.J., & Salibian-Barrera, M. (2019). *Robust Statistics: Theory and Methods*, 2nd ed.

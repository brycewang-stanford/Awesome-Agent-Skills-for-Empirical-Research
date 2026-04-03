# statsmodels Quickstart Reference

A technical reference for using statsmodels v0.14.6 in Python. Covers installation,
the two main APIs, model fitting, reading output, and key library patterns. No
methodology content — syntax and library guidance only.

## Contents

- [Installation](#installation)
- [Formula API vs Array API](#formula-api-vs-array-api)
- [Your First Model (Formula API)](#your-first-model-formula-api)
- [Your First Model (Array API)](#your-first-model-array-api)
- [Reading the Summary Output](#reading-the-summary-output)
- [Key Results Attributes](#key-results-attributes)
- [Robust Standard Errors](#robust-standard-errors)
- [Formula Syntax Overview](#formula-syntax-overview)
- [Quick Comparison: statsmodels vs pyfixest](#quick-comparison-statsmodels-vs-pyfixest)
- [References and Further Reading](#references-and-further-reading)

---

## Installation

```bash
pip install statsmodels
```

Key dependencies (installed automatically):

| Package | Role |
|---------|------|
| `numpy` | Array operations and linear algebra |
| `scipy` | Statistical distributions and optimization |
| `pandas` | DataFrame input/output and index handling |
| `patsy` | R-style formula parsing for the Formula API |

Verify installation:

```python
import statsmodels
print(statsmodels.__version__)  # Should print 0.14.x
```

---

## Formula API vs Array API

statsmodels exposes two parallel interfaces. You will use both in different
situations — understanding the distinction upfront prevents the most common errors.

### Formula API

```python
import statsmodels.formula.api as smf
```

- Accepts R-style formula strings: `"y ~ x1 + x2"`
- Uses **patsy** to parse formulas and build design matrices
- **Automatically adds an intercept** (constant term) — no manual step needed
- Categorical variables handled via `C(var)` in the formula
- Variable names come from a `data=` DataFrame argument

### Array API

```python
import statsmodels.api as sm
```

- Accepts numpy arrays or pandas DataFrames directly
- **Does NOT add an intercept automatically** — you must add it manually
- More verbose but gives full control over design matrices
- Useful when building matrices programmatically

### Same Model, Both Ways

```python
import statsmodels.formula.api as smf
import statsmodels.api as sm
import pandas as pd
import numpy as np

df = pd.DataFrame({
    "y":  [1, 2, 3, 4, 5],
    "x1": [2, 4, 5, 7, 8],
    "x2": [1, 3, 2, 5, 4],
})

# --- Formula API ---
results_f = smf.ols("y ~ x1 + x2", data=df).fit()

# --- Array API ---
y = df["y"].values
X = df[["x1", "x2"]].values
X = sm.add_constant(X)   # CRITICAL: adds a leading column of ones for the intercept
results_a = sm.OLS(y, X).fit()

# Both produce identical coefficient estimates
print(results_f.params)
print(results_a.params)
```

### When to Prefer Each

| Situation | Preferred API | Reason |
|-----------|---------------|--------|
| Exploratory analysis | Formula API | Readable, concise, close to R syntax |
| Categorical variables | Formula API | patsy handles encoding and reference levels automatically |
| Polynomial terms | Formula API | `I(x**2)` keeps syntax clean |
| Programmatic model building | Array API | Loop over columns, build matrices in code |
| Custom design matrices | Array API | Full control; no formula parsing overhead |
| Interaction with sklearn pipelines | Array API | Consistent numpy/array interface |

---

## Your First Model (Formula API)

```python
import statsmodels.formula.api as smf
import pandas as pd

df = pd.DataFrame({
    "y":  [1, 2, 3, 4, 5],
    "x1": [2, 4, 5, 7, 8],
    "x2": [1, 3, 2, 5, 4],
})

results = smf.ols("y ~ x1 + x2", data=df).fit()
print(results.summary())
```

The `.fit()` call runs OLS and returns a `RegressionResultsWrapper`. The object
holds all estimated parameters, test statistics, and diagnostics. The original
model specification is accessible via `results.model`.

---

## Your First Model (Array API)

```python
import statsmodels.api as sm
import numpy as np

y = np.array([1, 2, 3, 4, 5])
X = np.array([[2, 1],
              [4, 3],
              [5, 2],
              [7, 5],
              [8, 4]])
X = sm.add_constant(X)  # CRITICAL: adds intercept column as the first column

results = sm.OLS(y, X).fit()
print(results.summary())
```

`sm.add_constant(X)` prepends a column of ones. Without it, the model has no
intercept and coefficient estimates will be incorrect.

---

## Reading the Summary Output

`results.summary()` prints a three-panel text table. Here is what each section
contains.

### Panel 1: Model Information

```
OLS Regression Results
==============================================================================
Dep. Variable:                      y   R-squared:                       0.986
Model:                            OLS   Adj. R-squared:                  0.972
Method:                 Least Squares   F-statistic:                     70.84
Date:                ...               Prob (F-statistic):              0.0137
Time:                ...               Log-Likelihood:                 -1.3485
No. Observations:                   5   AIC:                             8.697
Df Residuals:                       2   BIC:                             7.883
Df Model:                           2
Covariance Type:            nonrobust
```

Key fields:

| Field | Meaning |
|-------|---------|
| `R-squared` | Proportion of variance in y explained by the model |
| `Adj. R-squared` | R² penalized for number of predictors |
| `F-statistic` | Joint test that all slope coefficients are zero |
| `Prob (F-statistic)` | p-value for the F-test |
| `AIC` / `BIC` | Information criteria for model comparison (lower is better) |
| `Log-Likelihood` | Value of the log-likelihood at estimated parameters |
| `No. Observations` | N used in fitting (rows with NaN are dropped by formula API) |
| `Df Residuals` | N minus number of estimated parameters |
| `Df Model` | Number of slope parameters (excludes intercept) |
| `Covariance Type` | `nonrobust` = standard OLS; changes when robust SEs requested |

### Panel 2: Coefficient Table

```
==============================================================================
                 coef    std err          t      P>|t|      [0.025      0.975]
------------------------------------------------------------------------------
Intercept     -0.3125      0.593     -0.527      0.653      -2.864       2.239
x1             0.5781      0.095      6.092      0.026       0.169       0.987
x2            -0.1563      0.165     -0.947      0.445      -0.867       0.554
==============================================================================
```

| Column | Meaning |
|--------|---------|
| `coef` | Estimated coefficient |
| `std err` | Standard error of the coefficient |
| `t` | t-statistic = coef / std err |
| `P>\|t\|` | Two-sided p-value for H0: coef = 0 |
| `[0.025, 0.975]` | 95% confidence interval |

### Panel 3: Diagnostic Statistics

```
==============================================================================
Omnibus:                        0.276   Durbin-Watson:                   2.499
Prob(Omnibus):                  0.871   Jarque-Bera (JB):                0.370
Skew:                          -0.266   Prob(JB):                        0.831
Kurtosis:                       1.812   Cond. No.                         33.2
==============================================================================
```

| Field | What It Tests |
|-------|---------------|
| `Omnibus` | Normality of residuals (D'Agostino & Pearson test) |
| `Durbin-Watson` | Serial autocorrelation; near 2.0 = no autocorrelation |
| `Jarque-Bera (JB)` | Normality of residuals via skewness and kurtosis |
| `Skew` | Skewness of residuals |
| `Kurtosis` | Kurtosis of residuals |
| `Cond. No.` | Condition number of design matrix; large values suggest multicollinearity |

### summary2()

`results.summary2()` returns a `Summary2` object with a different layout. Access
its tables programmatically:

```python
s2 = results.summary2()
print(s2.tables[0])   # Model info table
print(s2.tables[1])   # Coefficient table as a DataFrame
```

For automated extraction of coefficients and p-values, prefer direct attribute
access (`results.params`, `results.pvalues`) over parsing summary text.

---

## Key Results Attributes

All attributes listed below are available on the `RegressionResultsWrapper`
returned by `.fit()`.

| Attribute | Type | Description |
|-----------|------|-------------|
| `results.params` | Series/array | Estimated coefficients |
| `results.bse` | Series/array | Standard errors of coefficients |
| `results.tvalues` | Series/array | t-statistics for each coefficient |
| `results.pvalues` | Series/array | Two-sided p-values for each coefficient |
| `results.rsquared` | float | R-squared |
| `results.rsquared_adj` | float | Adjusted R-squared |
| `results.fvalue` | float | F-statistic for overall model significance |
| `results.f_pvalue` | float | p-value for F-statistic |
| `results.aic` | float | Akaike Information Criterion |
| `results.bic` | float | Bayesian Information Criterion |
| `results.llf` | float | Log-likelihood at estimated parameters |
| `results.resid` | Series/array | Residuals (y - fitted values) |
| `results.fittedvalues` | Series/array | Fitted values (y-hat) |
| `results.nobs` | float | Number of observations used |
| `results.df_resid` | float | Residual degrees of freedom |
| `results.df_model` | float | Model degrees of freedom (excludes intercept) |
| `results.conf_int()` | DataFrame | Confidence intervals; default 95%, pass `alpha=0.01` for 99% |
| `results.cov_params()` | DataFrame | Variance-covariance matrix of parameters |

```python
# Accessing attributes directly
print(results.params)
print(results.pvalues)
print(results.rsquared)
print(results.conf_int())           # 95% CI by default
print(results.conf_int(alpha=0.01)) # 99% CI
```

---

## Robust Standard Errors

Pass `cov_type` to `.fit()` to override the default OLS standard errors.

```python
import statsmodels.formula.api as smf

# HC1 — White's heteroskedasticity-consistent (good default for cross-sectional data)
results = smf.ols("y ~ x1 + x2", data=df).fit(cov_type='HC1')

# HC3 — bias-corrected; preferred for small samples
results = smf.ols("y ~ x1 + x2", data=df).fit(cov_type='HC3')

# Clustered standard errors
results = smf.ols("y ~ x1", data=df).fit(
    cov_type='cluster',
    cov_kwds={'groups': df['cluster_var']}
)

# HAC — Newey-West heteroskedasticity and autocorrelation consistent (time series)
results = smf.ols("y ~ x1", data=df).fit(
    cov_type='HAC',
    cov_kwds={'maxlags': 4}
)
```

Covariance types available:

| `cov_type` | Description | Common Use |
|------------|-------------|------------|
| `'nonrobust'` | Standard OLS (default) | Homoskedastic errors assumed |
| `'HC0'` | White (1980) | Cross-sectional heteroskedasticity |
| `'HC1'` | White with df correction | Cross-sectional heteroskedasticity (preferred) |
| `'HC2'` | Leverage-adjusted | Cross-sectional heteroskedasticity |
| `'HC3'` | Jackknife-approximation | Small-sample cross-sectional |
| `'cluster'` | One-way clustered | Panel/grouped data, `cov_kwds={'groups': var}` required |
| `'HAC'` | Newey-West | Time series with autocorrelation |

The `cov_type` only changes standard errors and test statistics — point estimates
(coefficients) are unaffected.

---

## Formula Syntax Overview

statsmodels uses **patsy** to parse formula strings. Patsy syntax closely follows
R's formula notation.

### Common Patterns

| Formula | Meaning |
|---------|---------|
| `"y ~ x1 + x2"` | Additive model with intercept |
| `"y ~ x1 * x2"` | Main effects plus interaction: `x1 + x2 + x1:x2` |
| `"y ~ x1 : x2"` | Interaction term only (no main effects) |
| `"y ~ C(region)"` | Treat `region` as categorical; first level dropped as reference |
| `"y ~ C(region, Treatment(reference='West'))"` | Set explicit reference level |
| `"y ~ x1 + I(x1**2)"` | Polynomial; `I()` protects the `**` operator from patsy |
| `"y ~ x1 - 1"` | No intercept (suppress constant) |
| `"y ~ np.log(x1)"` | Apply numpy transformation inside formula |
| `"y ~ x1 + x2 + x1:x2"` | Equivalent to `x1 * x2` written explicitly |
| `"y ~ (x1 + x2)**2"` | All main effects and two-way interactions |

### Intercept Behavior

- Intercept is included by default: `"y ~ x1"` fits `y = a + b*x1`
- Suppress with `-1` or `+0`: `"y ~ x1 - 1"` fits `y = b*x1` through origin
- The array API never adds an intercept — use `sm.add_constant(X)` explicitly

### Categorical Variables in Formulas

```python
import statsmodels.formula.api as smf

# Default: first alphabetical level dropped as reference
results = smf.ols("y ~ C(region)", data=df).fit()

# Explicit reference level
results = smf.ols("y ~ C(region, Treatment(reference='West'))", data=df).fit()

# All levels, no intercept (for a cell-means parameterization)
results = smf.ols("y ~ C(region) - 1", data=df).fit()
```

### In-Formula Transformations

```python
import numpy as np
import statsmodels.formula.api as smf

# Log transformation — numpy functions work directly in patsy formulas
results = smf.ols("y ~ np.log(income) + age", data=df).fit()

# Polynomial — use I() to protect ** from patsy interpretation
results = smf.ols("y ~ age + I(age**2)", data=df).fit()

# Standardize inline (center and scale)
results = smf.ols("y ~ scale(income)", data=df).fit()
```

---

## Quick Comparison: statsmodels vs pyfixest

| Task | statsmodels | pyfixest |
|------|-------------|----------|
| Basic OLS | `smf.ols("y ~ x", data=df).fit()` | `pf.feols("y ~ x", data=df)` |
| OLS with fixed effects | Not recommended (use dummies) | `pf.feols("y ~ x \| fe1 + fe2", data=df)` |
| Heteroskedasticity-robust SE | `.fit(cov_type='HC1')` | `.vcov("hetero")` |
| Clustered SE | `.fit(cov_type='cluster', cov_kwds={'groups': var})` | `.vcov({"CRV1": "cluster_var"})` |
| GLM (logit, Poisson, etc.) | `smf.glm(..., family=...)` | Limited (`feglm` only) |
| Time series models | Full support (ARIMA, VAR, etc.) | Not available |
| Diagnostic tests | Full test suite | Not available |
| IV regression with FE | Awkward | Built-in, fast |
| Difference-in-differences | Manual | Modern DiD estimators built in |
| Wild bootstrap SE | Not available | Built-in |

### When to Use Which

**Use statsmodels when:**
- Fitting GLMs (logit, probit, Poisson, negative binomial, gamma, etc.)
- Working with time series (ARIMA, VAR, state space models)
- Running diagnostic tests (heteroskedasticity, normality, autocorrelation)
- Estimating discrete choice models (MNLogit, ordered logit)
- You need marginal effects from nonlinear models
- The model does not involve multi-way fixed effects

**Use pyfixest when:**
- Multi-way fixed effects are required (absorbs FE via demeaning — much faster)
- Running IV regressions with fixed effects
- Implementing difference-in-differences or event study designs
- You need CRV3 or wild bootstrap clustered standard errors
- Estimating many models in a loop over panel data

Both libraries support heteroskedasticity-robust and clustered standard errors for
OLS. For plain OLS without FE, either works — statsmodels has more post-estimation
diagnostics.

---

## References and Further Reading

- statsmodels official documentation: https://www.statsmodels.org/stable/
- statsmodels GitHub repository: https://github.com/statsmodels/statsmodels
- Seabold, S. & Perktold, J. (2010). "statsmodels: Econometric and Statistical
  Modeling with Python." Proceedings of the 9th Python in Science Conference.
- patsy formula documentation: https://patsy.readthedocs.io/
- patsy formula language reference: https://patsy.readthedocs.io/en/latest/formulas.html
- statsmodels regression example gallery: https://www.statsmodels.org/stable/examples/index.html#regression

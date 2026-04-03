# statsmodels Gotchas and Common Pitfalls

A reference for known sharp edges, silent failures, and library-specific
behaviors in statsmodels v0.14.6. Each section describes a problem, why it
happens, and how to fix it. No methodology content — syntax and library
guidance only.

---

## Contents

1. [Constant Term Not Auto-Added in Array API](#1-constant-term-not-auto-added-in-array-api)
2. [patsy vs formulaic Formula Parsing](#2-patsy-vs-formulaic-formula-parsing)
3. [Convergence Warnings in MLE Models](#3-convergence-warnings-in-mle-models)
4. [summary() vs summary2()](#4-summary-vs-summary2)
5. [Large-Sample vs Exact Tests](#5-large-sample-vs-exact-tests)
6. [results.predict() Requires exog in Array API](#6-resultspredict-requires-exog-in-array-api)
7. [statsmodels vs pyfixest: When to Use Which](#7-statsmodels-vs-pyfixest-when-to-use-which)
8. [DataFrame Index Issues](#8-dataframe-index-issues)
9. [Categorical Variable Gotchas](#9-categorical-variable-gotchas)
10. [NaN/Missing Data Handling](#10-nanmissing-data-handling)

---

## 1. Constant Term Not Auto-Added in Array API

**This is the most common statsmodels error.** The Array API (`sm.OLS`) never
adds an intercept. If you forget `sm.add_constant()`, the model is fit through
the origin and all coefficient estimates will be wrong — there is no warning.

```python
import statsmodels.api as sm
import numpy as np

y = np.array([1, 2, 3, 4, 5])
X = np.array([[2, 1], [4, 3], [5, 2], [7, 5], [8, 4]])

# WRONG — missing intercept, coefficients will be incorrect
results = sm.OLS(y, X).fit()

# CORRECT — add constant column first
X_with_const = sm.add_constant(X)  # prepends a column of 1s
results = sm.OLS(y, X_with_const).fit()
```

`sm.add_constant(X)` prepends a column of ones named `const`. The column appears
first in `results.params`.

**The Formula API never has this problem** — it adds an intercept automatically.
To suppress it in the formula API, use `"y ~ x - 1"`.

**Edge case:** If `X` already contains a column of constants, `sm.add_constant()`
will detect this. Behavior is controlled by the `has_constant` parameter:
`'skip'` (default) silently skips, `'raise'` raises an error, `'add'` adds
regardless. When in doubt:

```python
# Check whether constant is present before adding
import numpy as np
if not np.any(np.all(X == X[0, :], axis=0)):
    X = sm.add_constant(X)
```

---

## 2. patsy vs formulaic Formula Parsing

statsmodels and pyfixest use **different formula parsing libraries**. If you
are mixing both packages in the same analysis, the formula dialects are not
interchangeable.

| Feature | statsmodels (patsy) | pyfixest (formulaic) |
|---------|--------------------|-----------------------|
| Library | `patsy` | `formulaic` |
| Categorical encoding | `C(var)` | `C(var)` (similar but not identical options) |
| Numpy transforms in formula | Allowed: `np.log(x)` | Not allowed — transform before fitting |
| Explicit reference level | `C(var, Treatment(reference='a'))` | `C(var, contr.treatment(base=1))` (R-style) |
| Fixed effects syntax | Not supported | `y ~ x \| fe1 + fe2` |
| Interaction operator | `x1:x2`, `x1*x2` | `x1:x2`, `x1*x2` |

### patsy-specific patterns (statsmodels only)

```python
import statsmodels.formula.api as smf

# Numpy transformations work directly in patsy formulas
results = smf.ols("y ~ np.log(x1) + np.sqrt(x2)", data=df).fit()

# I() protects operators that patsy would otherwise interpret
results = smf.ols("y ~ x1 + I(x1**2)", data=df).fit()

# Explicit reference level for Treatment coding
results = smf.ols("y ~ C(region, Treatment(reference='West'))", data=df).fit()

# Sum coding (deviation from grand mean)
results = smf.ols("y ~ C(region, Sum)", data=df).fit()

# Helmert coding
results = smf.ols("y ~ C(region, Helmert)", data=df).fit()
```

### What does NOT work in patsy (unlike formulaic)

- patsy does not support the `|` operator for fixed effects — `"y ~ x | fe"` will
  error. Use pyfixest for fixed-effects absorption.
- Some R contrast functions (`contr.treatment`, `contr.sum`) are not directly
  available; patsy has its own equivalents (`Treatment`, `Sum`, `Helmert`).

**Rule of thumb:** If transforming a variable before the formula (outside the
string), the dialect difference doesn't matter. Conflicts arise only when using
advanced formula features — check which library is active before assuming syntax
will transfer.

---

## 3. Convergence Warnings in MLE Models

Models fit by maximum likelihood — Logit, Probit, MNLogit, GLM, ARIMA, and
others — can fail to converge. statsmodels reports this as:

```
ConvergenceWarning: Maximum Likelihood optimization failed to converge.
Check mle_retvals
```

The `results` object is still returned but estimates are unreliable.

### Common Causes and Fixes

**Perfect or quasi-perfect separation** (Logit/Probit)

A predictor perfectly or near-perfectly separates outcomes. The log-likelihood
has no maximum — the coefficient diverges toward infinity.

Signs: very large coefficient values (e.g., `1e8`), extremely small standard
errors or extremely large ones, `ConvergenceWarning`.

```python
# Check: look at coefficient magnitudes
print(results.params)

# Check: examine optimization return values
print(results.mle_retvals)
# 'converged': False indicates the problem
```

Fixes: remove the separating variable, use Firth's penalized logistic regression
(not built into statsmodels — use `logistf` in R or a third-party package), or
collect more data.

**Scale issues**

Predictors on vastly different scales make the likelihood surface poorly
conditioned.

```python
import pandas as pd
from sklearn.preprocessing import StandardScaler

# Standardize predictors before fitting
scaler = StandardScaler()
df_scaled = df.copy()
df_scaled[['x1', 'x2']] = scaler.fit_transform(df[['x1', 'x2']])
results = smf.logit("y ~ x1 + x2", data=df_scaled).fit()
```

**Too many parameters relative to N**

Reduce model complexity: drop variables, combine categories, or use
regularization.

**Optimizer settings**

```python
# Try a different optimizer
results = smf.logit("y ~ x1 + x2", data=df).fit(method='bfgs')
results = smf.logit("y ~ x1 + x2", data=df).fit(method='nm')       # Nelder-Mead
results = smf.logit("y ~ x1 + x2", data=df).fit(method='powell')

# Increase iteration limit
results = smf.logit("y ~ x1 + x2", data=df).fit(maxiter=1000)

# Provide starting values to help the optimizer
import numpy as np
start = np.zeros(len(results.params))  # or use OLS coefficients as starting point
results = smf.logit("y ~ x1 + x2", data=df).fit(start_params=start)
```

Available `method` values: `'newton'` (default), `'nm'`, `'bfgs'`, `'lbfgs'`,
`'powell'`, `'cg'`, `'ncg'`, `'basinhopping'`.

**GLM-specific:** For GLM models, convergence failure can also indicate a poor
choice of link function or variance structure for the data. Check that the
family/link combination makes sense for the response variable.

---

## 4. summary() vs summary2()

Both methods describe the same model but have different layouts and programmatic
accessibility.

### summary()

Returns a `Summary` object. Calling `print(results.summary())` renders three
panels of formatted text. This is the standard output format widely shown in
documentation.

```python
results = smf.ols("y ~ x1 + x2", data=df).fit()
print(results.summary())       # Three-panel text layout
```

Extracting data from the text output is fragile. Prefer direct attribute access.

### summary2()

Returns a `Summary2` object. The layout differs — one table for model info, one
for coefficients. The coefficient table is returned as a pandas DataFrame, making
programmatic access easier.

```python
s2 = results.summary2()
print(s2.tables[0])   # Model info as DataFrame
print(s2.tables[1])   # Coefficients, SEs, t-stats, p-values as DataFrame

# Access coefficient table directly
coef_table = s2.tables[1]
print(coef_table['Coef.'])
print(coef_table['P>|t|'])
```

### Recommended: Direct Attribute Access

For any programmatic extraction of results, skip both summary methods and read
attributes directly:

```python
params    = results.params        # Coefficients (Series with variable names)
pvalues   = results.pvalues       # p-values
conf      = results.conf_int()    # CI as DataFrame, columns [0.025, 0.975]
bse       = results.bse           # Standard errors
rsq       = results.rsquared
rsq_adj   = results.rsquared_adj
aic       = results.aic
n         = results.nobs
```

This approach is robust to formatting changes across statsmodels versions and
is not affected by display width or locale settings.

---

## 5. Large-Sample vs Exact Tests

statsmodels mostly uses **asymptotic** (large-sample) theory for inference.
This matters in small samples where asymptotic approximations can be poor.

### What is exact vs asymptotic in statsmodels OLS

| Test | Type | Notes |
|------|------|-------|
| t-test on OLS coefficients | **Exact** (under normality assumption) | F and t distributions used |
| F-test for overall model | **Exact** (under normality assumption) | |
| Wald tests on nonlinear hypotheses | Asymptotic (chi-squared) | `results.wald_test()` |
| Likelihood Ratio test | Asymptotic (chi-squared) | Manual: `-2 * (llf_restricted - llf_full)` |
| Lagrange Multiplier / Score test | Asymptotic (chi-squared) | |
| GLM inference | Asymptotic | t and F used as approximations |
| Time series inference | Asymptotic | |

### Practical implication

With N < 50 and many parameters, Wald tests, LR tests, and robust-SE-based
inference may diverge meaningfully from exact p-values. Consider:

- Bootstrapping for inference in small samples
- Exact permutation tests
- Being cautious about borderline p-values (e.g., 0.04 vs 0.06 is not
  meaningfully different when N is small)

```python
# Check N relative to parameters before interpreting results
print(f"N = {int(results.nobs)}, K = {len(results.params)}, ratio = {results.nobs/len(results.params):.1f}")
# Asymptotic tests are more reliable when N/K >> 10
```

---

## 6. results.predict() Requires exog in Array API

### Formula API: pass a DataFrame, variable names handled automatically

```python
results = smf.ols("y ~ x1 + x2", data=df).fit()

new_df = pd.DataFrame({"x1": [3, 6], "x2": [2, 4]})
predictions = results.predict(new_df)   # Works — patsy builds design matrix
```

### Array API: you must replicate the exact design matrix structure

```python
y = df["y"].values
X = df[["x1", "x2"]].values
X_with_const = sm.add_constant(X)
results = sm.OLS(y, X_with_const).fit()

# WRONG — missing constant
new_X = np.array([[3, 2], [6, 4]])
predictions = results.predict(new_X)   # Dimension mismatch error

# CORRECT — add constant to prediction data too
new_X = np.array([[3, 2], [6, 4]])
new_X_with_const = sm.add_constant(new_X)
predictions = results.predict(new_X_with_const)
```

### get_prediction() for confidence and prediction intervals

`results.predict()` returns point predictions only. To get confidence intervals
(interval around the conditional mean) or prediction intervals (interval for
individual observations), use `results.get_prediction()`:

```python
# Formula API
pred = results.get_prediction(new_df)
frame = pred.summary_frame(alpha=0.05)  # Returns DataFrame

print(frame.columns)
# ['mean', 'mean_se', 'mean_ci_lower', 'mean_ci_upper',
#  'obs_ci_lower', 'obs_ci_upper']

# mean_ci_*: confidence interval for E[y | x]
# obs_ci_*: prediction interval for individual y
```

The `obs_ci_*` columns give the prediction interval, which is always wider than
the confidence interval because it accounts for irreducible residual variance.

---

## 7. statsmodels vs pyfixest vs linearmodels: When to Use Which

| Scenario | Recommendation | Reason |
|----------|----------------|--------|
| OLS with multi-way fixed effects | **pyfixest** | Absorbs FE via demeaning — much faster and memory-efficient than dummies |
| OLS without fixed effects | **statsmodels** | Full diagnostics suite; linearmodels `IV2SLS` also works |
| Logit / probit | **statsmodels** | Full GLM framework, marginal effects, convergence diagnostics |
| Logit with fixed effects | **pyfixest** (LPM via `feols`) or **statsmodels** (dummies) | pyfixest: use `feols()` on binary outcome (linear probability model); statsmodels: include dummies directly but slow at scale |
| Poisson regression | **statsmodels** | Full GLM: NegBin, zero-inflated, hurdle models all available |
| Poisson with FE | **pyfixest** | `fepois()` for Poisson with absorbed FE (note: `feglm` does NOT support FE) |
| Time series (ARIMA, VAR, ARCH) | **statsmodels** | pyfixest and linearmodels have no time series support |
| IV / 2SLS without FE | **linearmodels** | `IV2SLS`, `IVLIML`, `IVGMM` — richer estimator set than pyfixest for non-FE IV |
| IV / 2SLS with FE | **pyfixest** | Three-part formula syntax; linearmodels has no Panel IV |
| LIML / k-class IV | **linearmodels** | `IVLIML` with Fuller's alpha — not available in pyfixest or statsmodels |
| GMM-IV | **linearmodels** | `IVGMM`, `IVGMMCUE` — not available elsewhere |
| Random effects (panel) | **linearmodels** | `RandomEffects` — not available in pyfixest or statsmodels |
| Between / first difference | **linearmodels** | `BetweenOLS`, `FirstDifferenceOLS` |
| Fama-MacBeth | **linearmodels** | `FamaMacBeth` with HAC covariance |
| SUR / 3SLS (system) | **linearmodels** | `SUR`, `IV3SLS`, `IVSystemGMM` — not available elsewhere |
| Diagnostic tests | **statsmodels** | Comprehensive suite: heteroskedasticity, normality, autocorrelation |
| DiD / event studies | **pyfixest** | `did2s`, `sunab`, `gardner` estimators built in |
| Robust / clustered SE | **Any** | All three support HC and one-way clustered |
| Driscoll-Kraay SE | **linearmodels** or **pyfixest** | linearmodels has more kernel options; pyfixest has basic DK |
| CRV3 or wild bootstrap SE | **pyfixest** | Not available in statsmodels or linearmodels |
| Marginal effects | **statsmodels** | `.get_margeff()` method on GLM results |
| Mixed/multilevel models | **statsmodels** | `MixedLM`, `BinomialBayesMixedGLM` |
| Asset pricing factor models | **linearmodels** | `LinearFactorModel`, `TradedFactorModel` |

### Summary rule

- **statsmodels** for: GLMs, time series, diagnostic tests, mixed models,
  discrete choice, models without fixed effects or panel structure
- **pyfixest** for: fixed effects absorption, IV with FE, DiD, fast panel
  estimation, modern robust SE options (CRV3, wild bootstrap)
- **linearmodels** for: random effects, between/FD estimation, Fama-MacBeth,
  IV without FE (LIML, GMM), system estimation (SUR, 3SLS), asset pricing,
  Driscoll-Kraay SEs

---

## 8. DataFrame Index Issues

statsmodels aligns inputs by DataFrame index. Non-default or non-contiguous
indices can produce unexpected behavior.

### Symptoms

- Predictions or residuals contain `NaN` unexpectedly
- Wrong number of observations after merging DataFrames
- `IndexError` or shape mismatch when passing new data to `predict()`

### Fix: reset index before fitting

```python
df = df.reset_index(drop=True)
results = smf.ols("y ~ x1 + x2", data=df).fit()
```

### When this bites you most often

```python
# Subsetting a DataFrame preserves original index
subset = df[df['year'] >= 2010]   # index is NOT 0, 1, 2, ...
results = smf.ols("y ~ x1", data=subset).fit()  # May cause issues

# Fix: reset after subsetting
subset = df[df['year'] >= 2010].reset_index(drop=True)
results = smf.ols("y ~ x1", data=subset).fit()
```

This is especially important when constructing prediction DataFrames that need
to align with training data index.

---

## 9. Categorical Variable Gotchas

### Default reference level

`C(var)` in a patsy formula drops the **first level in sorted order** as the
reference (baseline). This is Treatment coding.

```python
# If region has levels ['East', 'North', 'South', 'West'],
# 'East' is dropped as reference by default
results = smf.ols("y ~ C(region)", data=df).fit()
print(results.params)
# Intercept          ...
# C(region)[T.North] ...
# C(region)[T.South] ...
# C(region)[T.West]  ...
```

### Setting an explicit reference level

```python
# Set 'West' as the reference category
results = smf.ols("y ~ C(region, Treatment(reference='West'))", data=df).fit()
```

### All levels with no intercept (cell-means parameterization)

```python
# Drops intercept; each coefficient is the mean of y for that category
results = smf.ols("y ~ C(region) - 1", data=df).fit()
```

### High-cardinality categoricals

Including a categorical with many levels as dummies is slow and memory-intensive.
If the variable has more than ~50 levels and you want to control for it as a
fixed effect, use pyfixest instead:

```python
import pyfixest as pf
results = pf.feols("y ~ x1 | region", data=df)
```

### Numeric variables accidentally treated as categorical (or vice versa)

```python
# If 'year' is stored as int but you want it as categorical:
results = smf.ols("y ~ C(year)", data=df).fit()

# If 'code' is stored as string but you want it as numeric:
df['code'] = df['code'].astype(float)
results = smf.ols("y ~ code", data=df).fit()
```

---

## 10. NaN/Missing Data Handling

### Formula API behavior

The formula API drops rows with `NaN` in any variable used in the formula
(complete case analysis). A warning is issued if rows are dropped:

```
MissingDataError: No missing values in data, check formula
```
or, if values are dropped:
```
/path/to/statsmodels/...: n observations dropped due to missing values
```

Always verify:

```python
print(f"Input rows: {len(df)}")
print(f"Observations used in model: {int(results.nobs)}")
# If these differ, rows were dropped due to NaN
```

### Array API behavior

The array API does **not** handle `NaN` automatically. NaN values in `y` or `X`
will propagate through linear algebra operations and produce `NaN` coefficients
with no warning.

```python
# WRONG — NaN in array silently corrupts results
results = sm.OLS(y, X).fit()
print(results.params)  # May show NaN for all coefficients

# CORRECT — clean data before fitting
mask = ~(np.isnan(y) | np.any(np.isnan(X), axis=1))
results = sm.OLS(y[mask], X[mask]).fit()
```

### Diagnosing missing data before fitting

```python
import pandas as pd

# Formula API: check which variables have NaN
print(df[['y', 'x1', 'x2']].isna().sum())

# Array API: check arrays directly
print(f"NaN in y: {np.isnan(y).sum()}")
print(f"NaN in X: {np.isnan(X).sum()}")

# After fitting with formula API: confirm row count
print(f"Rows used: {int(results.nobs)} of {len(df)}")
```

### Imputation

statsmodels does not do imputation. If you need to impute before fitting,
use `sklearn.impute` or `pandas` operations before passing data to statsmodels.

---

## References and Further Reading

- statsmodels official documentation: https://www.statsmodels.org/stable/
- statsmodels FAQ: https://www.statsmodels.org/stable/faq.html
- patsy formula language reference: https://patsy.readthedocs.io/en/latest/formulas.html
- patsy categorical coding reference: https://patsy.readthedocs.io/en/latest/categorical-coding.html
- statsmodels regression diagnostics: https://www.statsmodels.org/stable/stats.html#regression-diagnostics
- statsmodels GLM reference: https://www.statsmodels.org/stable/glm.html

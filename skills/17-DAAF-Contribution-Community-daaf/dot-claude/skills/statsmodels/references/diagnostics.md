# statsmodels Diagnostics Reference

Regression diagnostics for OLS and GLM models using statsmodels v0.14.6. All
examples assume a fitted OLS results object unless otherwise noted.

---

## Contents

1. [Heteroskedasticity Tests](#heteroskedasticity-tests)
2. [Normality Tests](#normality-tests)
3. [Specification Tests](#specification-tests)
4. [Multicollinearity](#multicollinearity)
5. [Influence Measures](#influence-measures)
6. [Residual Analysis](#residual-analysis)
7. [Serial Correlation](#serial-correlation)
8. [Comprehensive Diagnostic Checklist](#comprehensive-diagnostic-checklist)
9. [References and Further Reading](#references-and-further-reading)

---

## Heteroskedasticity Tests

### Breusch-Pagan Test

```python
from statsmodels.stats.diagnostic import het_breuschpagan

# Fit OLS first
results = smf.ols("y ~ x1 + x2", data=df).fit()

# Run test (uses residuals and regressors)
lm_stat, lm_pvalue, f_stat, f_pvalue = het_breuschpagan(
    results.resid, results.model.exog
)
```

- H0: homoskedasticity (constant variance)
- Reject if p-value < 0.05 → heteroskedasticity present
- Returns four values: LM statistic, LM p-value, F-statistic, F p-value
- The LM test assumes normal errors; the F-statistic is more robust to
  non-normality. Use the F variant (3rd and 4th return values) as the default

### White Test

```python
from statsmodels.stats.diagnostic import het_white

lm_stat, lm_pvalue, f_stat, f_pvalue = het_white(
    results.resid, results.model.exog
)
```

- More general than Breusch-Pagan (doesn't assume specific functional form)
- Tests for heteroskedasticity AND specification error simultaneously
- Adds squared terms and cross-products of regressors to the auxiliary regression
- Can lose power with many regressors because the auxiliary regression grows large

### What to Do If Heteroskedasticity Is Detected

- Use robust standard errors: `.fit(cov_type='HC1')` or `'HC3'` (HC3 preferred
  in small samples)
- Use WLS (`sm.WLS`) if the variance structure is known or estimable
- Consider transforming the dependent variable (log, sqrt) if the relationship
  is multiplicative

---

## Normality Tests

### Jarque-Bera

Tests skewness and kurtosis jointly:

```python
from statsmodels.stats.stattools import jarque_bera

jb_stat, jb_pvalue, skew, kurtosis = jarque_bera(results.resid)
```

- H0: residuals are normally distributed
- Also available directly in `results.summary()` diagnostics section
- Returns four values: JB statistic, p-value, skewness, kurtosis

### Omnibus Test (D'Agostino-Pearson)

```python
from statsmodels.stats.stattools import omni_normtest

stat, pvalue = omni_normtest(results.resid)
```

- Also reported in `results.summary()` output
- Combines skewness and kurtosis tests using chi-squared distribution

### Shapiro-Wilk (scipy)

```python
from scipy.stats import shapiro

stat, pvalue = shapiro(results.resid)
```

- More powerful than Jarque-Bera for small samples
- For N > 5000, scipy issues a warning that p-values may not be accurate
- H0: sample is drawn from a normal distribution

### Anderson-Darling (scipy)

```python
from scipy.stats import anderson

result = anderson(results.resid, dist='norm')
# result.statistic — the test statistic
# result.critical_values — array of critical values
# result.significance_level — corresponding significance levels [15, 10, 5, 2.5, 1]
```

- Returns critical values at multiple significance levels rather than a single
  p-value
- Reject H0 when `result.statistic > result.critical_values[idx]` for the
  chosen significance level

### Practical Note on Large Samples

In large samples, normality tests almost always reject because any minor
departure from normality becomes statistically detectable. Focus on the
degree of non-normality — examine QQ plots, skewness, and kurtosis values
numerically — rather than relying solely on p-values. OLS inference is
robust to moderate non-normality when N is large.

---

## Specification Tests

### RESET Test (Ramsey)

Ramsey's Regression Equation Specification Error Test:

```python
from statsmodels.stats.diagnostic import linear_reset

reset_result = linear_reset(results, power=3, use_f=True)
print(reset_result.fvalue)   # F-statistic
print(reset_result.pvalue)   # p-value
print(reset_result.df_denom) # denominator df
```

- H0: model is correctly specified
- `power=3` adds ŷ² and ŷ³ as auxiliary regressors (default behavior)
- `use_f=True` returns F-statistic; `use_f=False` returns chi-squared
- Rejection suggests omitted variables, wrong functional form, or omitted
  interactions — but does not identify which

### Harvey-Collier Test (Linearity)

```python
from statsmodels.stats.diagnostic import linear_harvey_collier

t_stat, pvalue = linear_harvey_collier(results)
```

- H0: relationship is linear
- Tests using recursive residuals — sensitive to structural breaks as well as
  nonlinearity

---

## Multicollinearity

### Variance Inflation Factor (VIF)

```python
from statsmodels.stats.outliers_influence import variance_inflation_factor

# X must include a constant column
X = sm.add_constant(df[["x1", "x2", "x3"]])

vif_data = pd.DataFrame({
    "Variable": X.columns,
    "VIF": [variance_inflation_factor(X.values, i) for i in range(X.shape[1])]
})
print(vif_data)
```

Interpretation thresholds:
- VIF = 1: no collinearity
- VIF > 5: moderate concern
- VIF > 10: serious multicollinearity

The constant's VIF is meaningless — exclude it from display or interpretation.
`variance_inflation_factor` takes the full design matrix (as a numpy array)
and a column index; loop over column indices to compute VIF for each variable.

### Condition Number

```python
# Available directly from results object
print(results.condition_number)

# Or compute manually
import numpy as np
cond = np.linalg.cond(results.model.exog)
```

- Condition number > 30: potential multicollinearity concern
- Also reported in the bottom section of `results.summary()` output

---

## Influence Measures

### OLSInfluence (Comprehensive)

```python
from statsmodels.stats.outliers_influence import OLSInfluence

influence = OLSInfluence(results)

# Cook's distance
cooks_d, pvalues = influence.cooks_distance
# Rule of thumb: Cook's D > 4/n is influential

# Leverage (hat matrix diagonal)
leverage = influence.hat_matrix_diag
# Rule of thumb: leverage > 2*(k+1)/n is high leverage

# DFFITS
dffits = influence.dffits[0]
# Rule of thumb: |DFFITS| > 2*sqrt((k+1)/n)

# DFBETAS (influence on each coefficient separately)
dfbetas = influence.dfbetas
# Shape: (n_obs, n_params)
# Rule of thumb: |DFBETAS| > 2/sqrt(n)

# Externally studentized residuals
student_resid = influence.resid_studentized_external
# |studentized resid| > 2 is a potential outlier
```

Where k = number of predictors (excluding constant) and n = number of
observations.

### Summary Frame (All Metrics at Once)

```python
summary = influence.summary_frame()
print(summary.columns.tolist())
# Includes: dfb_Intercept, dfb_x1, ..., cooks_d, standard_resid,
#           hat_diag, dffits_internal, student_resid
```

The summary frame is the most efficient way to flag observations that exceed
multiple thresholds simultaneously. Filter on `cooks_d` and `hat_diag` in
combination to distinguish high-influence from high-leverage points.

---

## Residual Analysis

### Residual Types

```python
results.resid                              # Raw residuals (y - ŷ)
results.resid_pearson                      # Pearson residuals (for GLM)
influence.resid_studentized_external       # Externally studentized
influence.resid_studentized_internal       # Internally studentized
```

Externally studentized residuals delete observation i before estimating
variance — they follow a t-distribution under H0 and are preferred for
outlier detection.

### Partial Regression Plots (Added Variable Plots)

```python
from statsmodels.graphics.regressionplots import plot_partregress_grid

fig = plot_partregress_grid(results)
fig.tight_layout()
fig.savefig("partial_regression.png", dpi=300, bbox_inches='tight')
plt.close()
```

Each panel shows the marginal relationship between one predictor and the
outcome after removing the linear effect of all other predictors. Useful for
spotting nonlinearity and influential points for individual coefficients.

### Residual-vs-Fitted Plot

```python
import matplotlib.pyplot as plt

fig, ax = plt.subplots(figsize=(8, 6))
ax.scatter(results.fittedvalues, results.resid, alpha=0.5)
ax.axhline(y=0, color='r', linestyle='--')
ax.set_xlabel("Fitted Values")
ax.set_ylabel("Residuals")
ax.set_title("Residuals vs Fitted")
fig.savefig("resid_vs_fitted.png", dpi=300, bbox_inches='tight')
plt.close()
```

Look for: random scatter around zero (good), funnel pattern (heteroskedasticity),
curved pattern (nonlinearity).

### QQ Plot

```python
from statsmodels.graphics.gofplots import qqplot

fig = qqplot(results.resid, line='45', fit=True)
fig.savefig("qq_plot.png", dpi=300, bbox_inches='tight')
plt.close()
```

`line='45'` draws the 45-degree reference line. `fit=True` fits location and
scale parameters before plotting. Heavy tails appear as S-shaped departure
from the line; skewness appears as systematic curvature.

---

## Serial Correlation

### Durbin-Watson Statistic

```python
from statsmodels.stats.stattools import durbin_watson

dw = durbin_watson(results.resid)
```

- DW ≈ 2: no autocorrelation
- DW < 2: positive autocorrelation (values closer to 0 = stronger)
- DW > 2: negative autocorrelation (values closer to 4 = stronger)
- Also reported in `results.summary()` output
- Cannot be used when the model contains a lagged dependent variable

### Breusch-Godfrey Test

More general than Durbin-Watson; works with lagged dependent variables:

```python
from statsmodels.stats.diagnostic import acorr_breusch_godfrey

lm_stat, lm_pvalue, f_stat, f_pvalue = acorr_breusch_godfrey(
    results, nlags=4
)
```

- H0: no serial correlation up to lag `nlags`
- `nlags` should be set based on data frequency (e.g., 4 for quarterly, 12
  for monthly)
- Returns LM statistic, LM p-value, F-statistic, F p-value

### Ljung-Box Test

```python
from statsmodels.stats.diagnostic import acorr_ljungbox

lb_result = acorr_ljungbox(results.resid, lags=10, return_df=True)
print(lb_result)
# DataFrame with columns: lb_stat, lb_pvalue
# One row per lag
```

- H0: residuals are independently distributed up to the specified lag
- `return_df=True` returns results as a DataFrame indexed by lag number
- Primarily used for time series residuals from ARIMA models, but applicable
  to any regression residuals when serial correlation is a concern

---

## Comprehensive Diagnostic Checklist

| Assumption | Test | Code |
|---|---|---|
| Homoskedasticity | Breusch-Pagan | `het_breuschpagan(resid, exog)` |
| Homoskedasticity | White | `het_white(resid, exog)` |
| Normality | Jarque-Bera | `jarque_bera(resid)` |
| Normality | Omnibus | `omni_normtest(resid)` |
| Normality | Shapiro-Wilk | `shapiro(resid)` (scipy) |
| Correct specification | RESET | `linear_reset(results)` |
| Linearity | Harvey-Collier | `linear_harvey_collier(results)` |
| No multicollinearity | VIF | `variance_inflation_factor(X, i)` |
| No multicollinearity | Condition number | `results.condition_number` |
| No serial correlation | Durbin-Watson | `durbin_watson(resid)` |
| No serial correlation | Breusch-Godfrey | `acorr_breusch_godfrey(results)` |
| No serial correlation | Ljung-Box | `acorr_ljungbox(resid, lags=10)` |
| Influential observations | Cook's D | `OLSInfluence(results).cooks_distance` |
| High leverage | Hat matrix | `OLSInfluence(results).hat_matrix_diag` |
| Outliers | Studentized resid | `OLSInfluence(results).resid_studentized_external` |

---

## References and Further Reading

- statsmodels diagnostic tests: https://www.statsmodels.org/stable/diagnostic.html
- statsmodels influence measures: https://www.statsmodels.org/stable/generated/statsmodels.stats.outliers_influence.OLSInfluence.html
- statsmodels graphics: https://www.statsmodels.org/stable/graphics.html
- Greene, W.H. (2018). *Econometric Analysis*, 8th ed. — Chapters 4-5
  (diagnostics)
- Belsley, Kuh, & Welsch (1980). *Regression Diagnostics*. Wiley.

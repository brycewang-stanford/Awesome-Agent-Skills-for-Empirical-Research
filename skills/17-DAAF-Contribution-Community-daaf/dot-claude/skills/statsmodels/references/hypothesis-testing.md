# statsmodels Hypothesis Testing Reference

Hypothesis testing for regression coefficients, model comparisons, and multiple
testing corrections using statsmodels v0.14.6. All examples assume a fitted OLS
results object unless otherwise noted.

---

## Contents

1. [t-Tests on Individual Coefficients](#t-tests-on-individual-coefficients)
2. [F-Tests on Groups of Coefficients](#f-tests-on-groups-of-coefficients)
3. [Wald Tests](#wald-tests)
4. [Likelihood Ratio Tests](#likelihood-ratio-tests)
5. [Multiple Comparison Corrections](#multiple-comparison-corrections)
6. [Chi-Squared Tests](#chi-squared-tests)
7. [Comparing Nested Models](#comparing-nested-models)
8. [Joint Significance Tests](#joint-significance-tests)
9. [References and Further Reading](#references-and-further-reading)

---

## t-Tests on Individual Coefficients

Standard coefficient tests are reported automatically in `results.summary()`.
To access them programmatically or test non-zero hypotheses:

```python
results = smf.ols("y ~ x1 + x2 + x3", data=df).fit()

# Individual coefficient t-statistics and p-values (all coefficients)
print(results.tvalues)   # Series indexed by variable name
print(results.pvalues)   # Two-sided p-values

# Custom hypothesis on a single coefficient
# H0: beta_x1 = 0
t_test = results.t_test("x1 = 0")
print(t_test)

# H0: beta_x1 = 1
t_test = results.t_test("x1 = 1")
print(t_test)

# Access specific attributes from the test result
print(t_test.tvalue)     # t-statistic
print(t_test.pvalue)     # two-sided p-value
print(t_test.conf_int()) # confidence interval
```

The string syntax in `t_test()` uses the variable names from the formula
interface. For models fit with `sm.OLS(y, X)` (array interface), use the
R-matrix form described in the Wald Tests section.

---

## F-Tests on Groups of Coefficients

### Joint Significance of Multiple Coefficients

```python
# H0: beta_x2 = beta_x3 = 0
f_test = results.f_test("x2 = 0, x3 = 0")
print(f_test)            # Prints F-statistic, p-value, df numerator

# Access attributes directly
print(f_test.fvalue)     # F-statistic (scalar or array)
print(f_test.pvalue)     # p-value
print(f_test.df_num)     # numerator degrees of freedom
print(f_test.df_denom)   # denominator degrees of freedom
```

### R-Matrix Notation (Array API)

For models fit without formula interface or when constructing hypotheses
programmatically:

```python
import numpy as np

# Coefficient order matches results.params index
# Intercept, x1, x2, x3 → indices 0, 1, 2, 3

R = np.array([[0, 0, 1, 0],   # coefficient on x2 = 0
              [0, 0, 0, 1]])   # coefficient on x3 = 0
f_test = results.f_test(R)
```

### Testing Equality of Coefficients

```python
# H0: beta_x1 = beta_x2
f_test = results.f_test("x1 = x2")
# Equivalent: "x1 - x2 = 0"
f_test = results.f_test("x1 - x2 = 0")
```

---

## Wald Tests

General linear hypothesis testing using asymptotic chi-squared or F
distribution:

```python
import numpy as np

# Wald test (chi-squared by default)
wald = results.wald_test("x1 = 0, x2 = 0")
print(wald)

# Wald test with F-distribution (preferred for OLS in finite samples)
wald = results.wald_test("x1 = 0, x2 = 0", use_f=True)

# Complex linear restrictions
# H0: beta_x1 + beta_x2 = 1 AND beta_x3 = 0
wald = results.wald_test("x1 + x2 = 1, x3 = 0")

# R-matrix form with constraint vector q (Rβ = q)
R = np.array([[0, 1, 1, 0],   # x1 + x2 = 1
              [0, 0, 0, 1]])   # x3 = 0
q = np.array([1, 0])
wald = results.wald_test((R, q))

# Access attributes
print(wald.statistic)   # chi-squared or F statistic
print(wald.pvalue)
print(wald.df_num)      # degrees of freedom (numerator for F)
```

Key distinction between `f_test` and `wald_test`:
- `f_test` always returns an F-statistic
- `wald_test` returns chi-squared by default; use `use_f=True` for F
- For OLS, `f_test` and `wald_test(..., use_f=True)` give identical results
- Wald tests are asymptotic — use F-version for finite samples when available

---

## Likelihood Ratio Tests

Compare nested models using the log-likelihood ratio. The LR statistic
(-2 × log-likelihood ratio) follows a chi-squared distribution with degrees
of freedom equal to the number of restrictions.

### For OLS Models

LR tests are not directly available as a statsmodels function for OLS; compute
manually:

```python
from scipy.stats import chi2

# Fit restricted and unrestricted models
results_full = smf.ols("y ~ x1 + x2 + x3", data=df).fit()
results_restricted = smf.ols("y ~ x1", data=df).fit()

# Compute LR statistic
lr_stat = -2 * (results_restricted.llf - results_full.llf)
df_diff = results_full.df_model - results_restricted.df_model

lr_pvalue = chi2.sf(lr_stat, df_diff)

print(f"LR statistic: {lr_stat:.4f}")
print(f"p-value:      {lr_pvalue:.4f}")
print(f"df:           {df_diff}")
```

`results.llf` is the log-likelihood value (available on all statsmodels results
objects that support MLE).

### For MLE Models (Logit, Probit, GLM, ARIMA)

The same pattern applies — all MLE results objects expose `.llf`:

```python
results_full = smf.logit("y ~ x1 + x2 + x3", data=df).fit()
results_restricted = smf.logit("y ~ x1", data=df).fit()

lr_stat = -2 * (results_restricted.llf - results_full.llf)
df_diff = (results_full.df_model - results_restricted.df_model)
lr_pvalue = chi2.sf(lr_stat, df_diff)
```

LR tests require models to be fit on exactly the same observations. Verify
with `results.nobs` before computing.

---

## Multiple Comparison Corrections

### `multipletests` — Adjust P-Values for Multiple Testing

```python
from statsmodels.stats.multitest import multipletests

pvals = [0.01, 0.04, 0.03, 0.15, 0.50]

# Returns: (reject array, corrected p-values, corrected alpha sidak, corrected alpha bonf)
reject, pvals_corrected, alphac_sidak, alphac_bonf = multipletests(
    pvals, alpha=0.05, method='fdr_bh'
)

print(reject)           # Boolean array: True where H0 is rejected after correction
print(pvals_corrected)  # Adjusted p-values
```

### Available Methods

| Method | Key | Type | Description |
|---|---|---|---|
| Bonferroni | `'bonferroni'` | FWER | Conservative; multiplies p by m |
| Holm-Bonferroni | `'holm'` | FWER | Step-down; uniformly more powerful than Bonferroni |
| Sidak | `'sidak'` | FWER | 1-(1-p)^m; slightly less conservative than Bonferroni |
| Holm-Sidak | `'holm-sidak'` | FWER | Step-down version of Sidak |
| Benjamini-Hochberg | `'fdr_bh'` | FDR | Controls false discovery rate; most commonly used for many tests |
| Benjamini-Yekutieli | `'fdr_by'` | FDR | Conservative FDR; valid under arbitrary dependence |

FWER (Family-Wise Error Rate): controls probability of any false positive.
FDR (False Discovery Rate): controls expected proportion of false positives
among rejections.

### Choosing a Method

- Few tests (< 20): Holm-Bonferroni (`'holm'`) is a safe default — step-down
  procedure dominates Bonferroni without additional assumptions
- Many tests (> 20): Benjamini-Hochberg (`'fdr_bh'`) is the standard choice —
  valid under independence or positive dependence (PRDS condition)
- Unknown or arbitrary dependence structure: Benjamini-Yekutieli (`'fdr_by'`)
  is conservative but guaranteed valid
- Very conservative needed (confirmatory single-family): Bonferroni
  (`'bonferroni'`)

### Extracting Corrected P-Values Into a DataFrame

```python
results_df = pd.DataFrame({
    'variable': ['x1', 'x2', 'x3', 'x4', 'x5'],
    'pvalue_raw': pvals
})

reject, pvals_corrected, _, _ = multipletests(
    results_df['pvalue_raw'], alpha=0.05, method='fdr_bh'
)

results_df['pvalue_corrected'] = pvals_corrected
results_df['reject_h0'] = reject
print(results_df)
```

---

## Chi-Squared Tests

These tests come from scipy but are commonly used alongside statsmodels
analyses.

### Goodness of Fit

```python
from scipy.stats import chisquare

# Compare observed frequencies to expected
stat, pvalue = chisquare(observed_freq, f_exp=expected_freq)
# H0: observed frequencies match expected distribution
# If f_exp is omitted, tests for uniform distribution
```

### Independence (Contingency Table)

```python
from scipy.stats import chi2_contingency

table = pd.crosstab(df['var1'], df['var2'])
chi2, p, dof, expected = chi2_contingency(table)

# expected: array of expected cell counts under independence
# Rule of thumb: chi2_contingency is unreliable if any expected cell < 5
```

For 2x2 tables with small expected counts, use Fisher's exact test instead:

```python
from scipy.stats import fisher_exact

odds_ratio, pvalue = fisher_exact(table_2x2)
```

---

## Comparing Nested Models

### Using AIC and BIC

AIC and BIC are available on all statsmodels results objects. Lower values
indicate better fit (penalizing for model complexity):

```python
model1 = smf.ols("y ~ x1", data=df).fit()
model2 = smf.ols("y ~ x1 + x2", data=df).fit()
model3 = smf.ols("y ~ x1 + x2 + x3", data=df).fit()

comparison = pd.DataFrame({
    'Model': ['x1', 'x1+x2', 'x1+x2+x3'],
    'AIC': [m.aic for m in [model1, model2, model3]],
    'BIC': [m.bic for m in [model1, model2, model3]],
    'R2_adj': [m.rsquared_adj for m in [model1, model2, model3]],
    'nparams': [m.df_model + 1 for m in [model1, model2, model3]]
})
print(comparison)
```

AIC vs BIC: BIC penalizes complexity more heavily (penalty = log(n) per
parameter vs 2 per parameter for AIC) — BIC is preferred when model selection
for inference is the goal; AIC when predictive accuracy is the goal.

### Using ANOVA (Nested OLS Models)

```python
from statsmodels.stats.anova import anova_lm

# Models must be fit with formula API (smf.ols)
# Pass models in order from most restricted to least restricted
anova_table = anova_lm(model1, model2, model3)
print(anova_table)
# Columns: df_resid, ssr, df_diff, ss_diff, F, Pr(>F)
```

Each row tests the improvement from adding the variables in the current model
relative to the previous model. Significant F indicates the added variables
improve fit beyond chance.

Requirements for `anova_lm`:
- Models must be nested (each model is a restriction of the next)
- Models must be fit on the same observations (`nobs` must match)
- Models must be fit using the formula interface

---

## Joint Significance Tests

The overall model F-test (H0: all slope coefficients = 0) is always reported
in `results.summary()`. Access it programmatically:

```python
# Overall F-test: H0 is that all slopes jointly equal zero
print(f"F-statistic: {results.fvalue:.4f}")
print(f"F p-value:   {results.f_pvalue:.6f}")
print(f"df model:    {results.df_model}")    # numerator df
print(f"df resid:    {results.df_resid}")    # denominator df

# Test a specific subset of variables jointly
# H0: coefficients on x2 AND x3 are jointly zero
f_test = results.f_test("x2 = 0, x3 = 0")
print(f"F: {f_test.fvalue:.4f}, p: {f_test.pvalue:.4f}")
```

For interaction models, testing the joint significance of an interaction term
and its constituent main effects:

```python
# Model with interaction
results_int = smf.ols("y ~ x1 + x2 + x1:x2", data=df).fit()

# H0: x2 and x1:x2 are jointly zero (testing whether x2 matters at all)
f_test = results_int.f_test("x2 = 0, x1:x2 = 0")
print(f_test)
```

Note: In formula syntax, interaction terms use `:` notation in `f_test` and
`wald_test` strings, matching how they appear in `results.params`.

---

## References and Further Reading

- statsmodels hypothesis tests: https://www.statsmodels.org/stable/stats.html
- statsmodels multitest: https://www.statsmodels.org/stable/generated/statsmodels.stats.multitest.multipletests.html
- statsmodels contrast and test documentation: https://www.statsmodels.org/stable/contrasts.html
- Greene, W.H. (2018). *Econometric Analysis*, 8th ed. — Chapters 5-6
  (hypothesis testing)
- Wooldridge, J.M. (2019). *Introductory Econometrics*, 7th ed. — Chapter 4
  (multiple regression: inference)
- Benjamini & Hochberg (1995). "Controlling the False Discovery Rate." JRSS-B.

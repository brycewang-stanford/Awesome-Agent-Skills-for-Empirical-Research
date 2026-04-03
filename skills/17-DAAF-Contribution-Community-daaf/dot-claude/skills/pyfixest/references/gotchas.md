# Common Gotchas and Troubleshooting

## Contents

- [v0.40 Breaking Changes](#v040-breaking-changes)
- [feglm Does NOT Support Fixed Effects](#feglm-does-not-support-fixed-effects)
- [numba Dependency](#numba-dependency)
- [Formula Parsing](#formula-parsing)
- [CRV3 Memory Usage](#crv3-memory-usage)
- [Convergence in fepois](#convergence-in-fepois)
- [Singleton Fixed Effects](#singleton-fixed-effects)
- [lpdid Returns a DataFrame](#lpdid-returns-a-dataframe)
- [HC2/HC3 Restrictions](#hc2hc3-restrictions)
- [fixest (R) vs pyfixest Differences](#fixest-r-vs-pyfixest-differences)
- [Matching Stata Results](#matching-stata-results)

## v0.40 Breaking Changes

Version 0.40.0 aligned pyfixest with R fixest 0.13, introducing several breaking changes that **silently change results**:

### Default Standard Errors Changed

**Before v0.40:** Default SE was cluster-robust by the first fixed effect variable.
**After v0.40:** Default SE is `"iid"`.

```python
# Old behavior: fit.vcov was auto-set to {"CRV1": "f1"}
# New behavior: fit.vcov is "iid"

# If you want the old behavior, specify explicitly:
fit = pf.feols("Y ~ X | f1", data=df, vcov={"CRV1": "f1"})
```

**Impact:** Code that relied on the old default will produce **different standard errors, t-statistics, and p-values** without any error or warning. Always specify `vcov` explicitly to avoid ambiguity.

### ssc() Arguments Renamed

| Old Name (pre-0.40) | New Name (0.40+) |
|----------------------|-------------------|
| `adj` | `k_adj` |
| `fixef_k` | `k_fixef` |
| `cluster_adj` | `G_adj` |
| `cluster_df` | `G_df` |

```python
# Old (will error in v0.40+)
pf.ssc(adj=True, fixef_k="nested", cluster_adj=True)

# New
pf.ssc(k_adj=True, k_fixef="nonnested", G_adj=True)
```

Note: the option value `"nested"` was also renamed to `"nonnested"`.

### Singleton Removal Default Changed

**Before v0.40:** `fixef_rm="none"` — singletons kept by default.
**After v0.40:** `fixef_rm="singleton"` — singletons dropped by default.

Singleton fixed effects are groups with only one observation. Keeping them can inflate degrees of freedom and produce misleading inference.

```python
# To preserve old behavior (not recommended):
fit = pf.feols("Y ~ X | fe", data=df, fixef_rm="none")
```

### Multicollinearity Tolerance

Default `collin_tol` changed from 1e-10 to 1e-09. This may cause some near-collinear variables to be dropped that were previously kept.

## feglm Does NOT Support Fixed Effects

This is the most common source of confusion. `feglm()` (logit, probit, Gaussian GLM) does **not** currently support FE demeaning:

```python
# This RAISES NotImplementedError:
pf.feglm("binary_Y ~ X | entity", data=df, family="logit")
```

### Workarounds

| Approach | When to Use |
|----------|-------------|
| Linear probability model: `pf.feols("binary_Y ~ X \| fe", data=df)` | Most cases; coefficients are percentage-point changes |
| Manual dummies with statsmodels | Small/moderate number of FE levels |
| Conditional logit (statsmodels) | Binary outcome with entity FE |
| `pf.fepois()` for count-like binary | If log-linear is acceptable |

The linear probability model with heteroskedasticity-robust or clustered SEs is the most common approach in applied economics when FE are needed with a binary outcome.

## numba Dependency

pyfixest uses numba for the default FE demeaning backend. numba can be tricky to install:

### Common Issues

**Problem:** numba fails to install (especially on M-series Macs or minimal environments).

```python
# Error: ModuleNotFoundError: No module named 'numba'
# Or: numba compilation errors on first use
```

**Fix:** Use the scipy fallback backend:

```python
fit = pf.feols("Y ~ X | fe", data=df, demeaner_backend="scipy")
```

**Problem:** First call is very slow (numba JIT compilation).

**Fix:** This is expected — numba compiles on first use, then caches. Subsequent calls are fast. For scripts, this is a one-time cost.

## Formula Parsing

pyfixest uses **formulaic** (not patsy) for formula parsing. This produces some syntax differences from statsmodels:

### Categorical Variables

```python
# pyfixest (formulaic)
"Y ~ C(state)"              # Basic categorical
"Y ~ i(state, ref='CA')"    # With reference level (preferred)

# statsmodels (patsy)
"Y ~ C(state, Treatment('CA'))"   # Reference via Treatment() — NOT supported in pyfixest
```

### Interactions

```python
# Both pyfixest and statsmodels
"Y ~ X1 * X2"      # Main effects + interaction
"Y ~ X1 : X2"      # Interaction only (no main effects)

# pyfixest-specific: i() for categorical interactions
"Y ~ i(group, X1, ref='control')"  # Group-specific slopes
```

### Common Parsing Errors

```python
# Error: variable names with spaces or special characters
# Fix: rename columns before estimation
df = df.rename(columns={"my variable": "my_variable"})

# Error: transformations not recognized
# formulaic supports: C(), np.log(), np.sqrt(), etc.
# Use numpy explicitly:
import numpy as np
"Y ~ np.log(X1) + X2"
```

## CRV3 Memory Usage

CRV3 (cluster jackknife) standard errors require storing a G × k matrix where G = number of clusters and k = number of parameters.

**Problem:** With many clusters and many parameters, this can exhaust memory.

```python
# Example: 1000 clusters × 500 parameters = large matrix
fit = pf.feols("Y ~ X1 + ... + X500 | fe", data=df)
fit.vcov({"CRV3": "cluster"})  # May run out of memory
```

**Fix:** Use CRV1 or wild bootstrap instead:

```python
fit.vcov({"CRV1": "cluster"})  # Much less memory
# Or for few clusters:
fit.wildboottest(param="X1", cluster="cluster", reps=9999)
```

## Convergence in fepois

### Symptoms

```python
# Warning: Maximum number of iterations reached
# Warning: Separation detected
```

### Causes and Fixes

**Slow convergence (many FE with sparse data):**

```python
fit = pf.fepois("Y ~ X | f1 + f2 + f3", data=df,
                iwls_maxiter=100,     # Increase from default 25
                iwls_tol=1e-06,       # Relax tolerance slightly
                )
```

**Separation (FE levels that perfectly predict zero):**

Some combinations of FE levels may have zero counts in all observations. These separated observations have infinite likelihood and must be removed. pyfixest can detect separation, but you may need to investigate which FE levels are problematic.

```python
# Check for zero-count FE groups
print(df.groupby(["f1", "f2"])["Y"].sum().value_counts())
```

## Singleton Fixed Effects

Singletons are FE groups with exactly one observation. Since v0.40, pyfixest drops them by default (`fixef_rm="singleton"`).

### Why Singletons Are Dropped

A singleton FE perfectly fits that observation's residual, contributing nothing to parameter estimation while consuming a degree of freedom. Keeping singletons inflates R² and can bias standard errors.

### Warning Messages

```python
# "X singleton observations removed"
# This is expected and correct behavior
```

If many singletons are removed, investigate whether your panel is very unbalanced or whether your FE specification is too fine-grained.

## lpdid Returns a DataFrame

Unlike `feols()`, `did2s()`, and `event_study()`, the `lpdid()` function returns a **pandas DataFrame**, not a `Feols` object:

```python
result = pf.lpdid(data=df, yname="Y", idname="entity",
                  tname="year", gname="treatment_year")

# result is a DataFrame with columns like:
# period, estimate, std_error, ci_lower, ci_upper, etc.

# This does NOT work:
# result.summary()     # AttributeError
# result.iplot()       # AttributeError
# pf.etable([result])  # TypeError
```

To visualize `lpdid()` results, use the returned DataFrame directly with matplotlib or plotnine.

## HC2/HC3 Restrictions

HC2 and HC3 standard errors are **not supported** with fixed effects or instrumental variables:

```python
# These will error:
fit = pf.feols("Y ~ X | fe", data=df)
fit.vcov("HC2")  # Error: HC2 not supported with FE

fit = pf.feols("Y ~ 1 | 0 | X ~ Z", data=df)
fit.vcov("HC3")  # Error: HC3 not supported with IV
```

**Why:** HC2 and HC3 require the hat matrix, which is expensive to compute when FE are absorbed via demeaning. Use HC1 ("hetero") or cluster-robust SEs instead.

## fixest (R) vs pyfixest Differences

| Feature | R fixest | pyfixest | Notes |
|---------|----------|----------|-------|
| Sun-Abraham | `sunab()` function | `event_study(estimator="saturated")` | Different API, same estimator |
| etable maturity | Full-featured | Evolving (migrating to maketables) | R version more polished |
| feglm with FE | Supported | NOT supported | Major gap in pyfixest |
| Default SE (v0.40+) | iid | iid | Now aligned |
| Wild bootstrap | `fwildclusterboot` (R) | `wildboottest` (Python) | Separate packages |
| sunab aggregation | `aggregate()` | `fit.aggregate()` | Similar API |
| Formula syntax | Nearly identical | Nearly identical | `i()` and `|` notation shared |
| `etable()` type argument | `"latex"`, `"md"` | `"tex"`, `"md"`, `"gt"`, `"df"` | Slight naming difference |
| Multiple LHS | `c(Y1, Y2)` | `Y1 + Y2` | Syntax differs |

### Features in R fixest Not Yet in pyfixest

Check the pyfixest GitHub issues and changelog for current status:
- Some `etable()` customization options
- Some specialized FE features
- Certain post-estimation utilities

When a feature is missing in pyfixest, consider whether `statsmodels`, `linearmodels`, or manual implementation can fill the gap.

## Matching Stata Results

### Clustered Standard Errors

Stata and pyfixest use slightly different default small-sample corrections:

```python
# To match Stata's one-way clustering:
fit = pf.feols("Y ~ X | fe", data=df,
               vcov={"CRV1": "cluster"},
               ssc=pf.ssc(k_adj=True, k_fixef="none", G_adj=True))

# To match Stata's two-way clustering:
fit = pf.feols("Y ~ X | fe", data=df,
               vcov={"CRV1": "cluster1+cluster2"},
               ssc=pf.ssc(G_df="conventional"))
```

### HC3 Standard Errors

```python
# To match Stata's HC3 (robust, small):
fit_no_fe = pf.feols("Y ~ X", data=df)
fit_no_fe.vcov("HC3")
# Use ssc=pf.ssc(k_adj=False) if results don't match
```

### OLS Precision

With IID standard errors, pyfixest and R fixest match to ~10^-18 precision. Poisson matches to ~10^-8 to 10^-9. Differences beyond these thresholds suggest a specification mismatch, not a numerical issue.

## Polars DataFrame Input

pyfixest expects a **pandas DataFrame** as input. If your data pipeline uses Polars (as DAAF recommends), convert before passing to estimation functions:

```python
# Convert Polars → pandas before estimation
df = df_polars.to_pandas()
fit = pf.feols("Y ~ X1 | fe", data=df)
```

Passing a Polars DataFrame directly may raise a `TypeError` or produce unexpected behavior. Always convert explicitly. See `quickstart.md` for the full conversion pattern.

## Quick Diagnostic Table

| Symptom | Likely Cause | Fix |
|---------|-------------|-----|
| TypeError with Polars DataFrame | pyfixest expects pandas | `df = df_polars.to_pandas()` |
| Different SEs from old code | v0.40 default SE change | Specify `vcov` explicitly |
| `NotImplementedError` with feglm | FE not supported in feglm | Use feols (LPM) or statsmodels |
| Very slow first call | numba JIT compilation | Normal; or use `demeaner_backend="scipy"` |
| Memory error with CRV3 | Too many clusters × params | Use CRV1 or wild bootstrap |
| Poisson won't converge | Separation or sparse data | Increase maxiter, check for separation |
| Many singletons dropped | Fine-grained FE | Expected; check FE specification |
| `AttributeError` on lpdid result | lpdid returns DataFrame | Use DataFrame methods, not Feols methods |
| HC2/HC3 error with FE | Not implemented with FE | Use HC1 or clustered SEs |

## References and Further Reading

- pyfixest changelog: https://py-econometrics.github.io/pyfixest/changelog.html
- pyfixest GitHub issues: https://github.com/py-econometrics/pyfixest/issues
- Berge, L., Butts, K., and McDermott, G. (2026). "Fast and User-Friendly Econometrics Estimations: The R Package fixest." arXiv:2601.21749
- Cameron, A.C. and Miller, D.L. (2015). "A Practitioner's Guide to Cluster-Robust Inference." *Journal of Human Resources*, 50(2), 317-372

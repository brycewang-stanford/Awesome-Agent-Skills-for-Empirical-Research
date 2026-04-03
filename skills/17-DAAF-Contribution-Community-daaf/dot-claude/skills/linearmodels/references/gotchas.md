# Common Gotchas and Troubleshooting

A reference for known sharp edges, silent failures, and library-specific
behaviors in linearmodels. Each section describes a problem, why it happens,
and how to fix it. No methodology content -- syntax and library guidance only.

---

## Contents

1. [MultiIndex Requirement for Panel Models](#1-multiindex-requirement-for-panel-models)
2. [Maximum Two-Way Fixed Effects in PanelOLS](#2-maximum-two-way-fixed-effects-in-panelols)
3. [No Panel IV (FE + IV Combined)](#3-no-panel-iv-fe--iv-combined)
4. [No DiD Estimators](#4-no-did-estimators)
5. [No Automatic Singleton Removal](#5-no-automatic-singleton-removal)
6. [No Post-Estimation SE Switching](#6-no-post-estimation-se-switching)
7. [Constant Term Handling](#7-constant-term-handling)
8. [Formula Syntax Differences from pyfixest](#8-formula-syntax-differences-from-pyfixest)
9. [SUR Performance with Large Datasets](#9-sur-performance-with-large-datasets)
10. [Three-Way Package Boundary](#10-three-way-package-boundary)

---

## 1. MultiIndex Requirement for Panel Models

**This is the most common linearmodels error.** All panel model estimators
(PanelOLS, RandomEffects, BetweenOLS, FirstDifferenceOLS, PooledOLS,
FamaMacBeth) require a pandas DataFrame with a MultiIndex where level 0 is the
entity identifier and level 1 is the time identifier. Passing a flat DataFrame
raises an error immediately.

```python
import pandas as pd
from linearmodels.panel import PanelOLS

# WRONG -- flat DataFrame with entity and time as regular columns
df = pd.read_csv("panel_data.csv")
mod = PanelOLS.from_formula("y ~ x + EntityEffects", data=df)
# ValueError: The index on the data must be a MultiIndex with 2 levels
```

```python
# CORRECT -- set MultiIndex before estimation
df = df.set_index(["entity_id", "year"])
mod = PanelOLS.from_formula("y ~ x + EntityEffects", data=df)
res = mod.fit()
```

### From Polars

```python
df_pandas = df_polars.to_pandas()
df_pandas = df_pandas.set_index(["entity_id", "year"])
```

### Checking Your Index

```python
print(f"Index names: {df.index.names}")    # Should be ['entity_id', 'year']
print(f"Index levels: {df.index.nlevels}") # Should be 2
assert df.index.nlevels == 2, "MultiIndex required for panel models"
```

**Important:** IV models (IV2SLS, IVLIML, IVGMM, IVGMMCUE) do NOT require a
MultiIndex -- they work with ordinary DataFrames. System models (SUR, 3SLS,
SystemGMM) also do not require a MultiIndex.

---

## 2. Maximum Two-Way Fixed Effects in PanelOLS

PanelOLS supports at most two sets of absorbed effects: entity effects, time
effects, or one of each plus an `other_effects` term. Attempting three or more
dimensions raises an error.

```python
from linearmodels.panel import PanelOLS

# Two-way -- OK
mod = PanelOLS(y, x, entity_effects=True, time_effects=True)

# Three-way -- ERROR: too many absorbed effects
mod = PanelOLS(y, x, entity_effects=True, time_effects=True, other_effects=z)
```

### Workarounds

**AbsorbingLS** from `linearmodels.iv` supports unlimited absorbed dimensions
via the pyhdfe backend:

```python
from linearmodels.iv import AbsorbingLS

mod = AbsorbingLS(y, x, absorb=df[["entity", "year", "industry"]])
res = mod.fit()
```

**pyfixest** handles multi-way FE natively and is generally faster:

```python
import pyfixest as pf

fit = pf.feols("y ~ x | entity + year + industry", data=df)
```

---

## 3. No Panel IV (FE + IV Combined)

linearmodels provides excellent panel estimators AND excellent IV estimators,
but **there is no estimator that absorbs fixed effects while simultaneously
instrumenting endogenous variables**. This is listed as planned but not yet
implemented in the linearmodels roadmap.

```python
# There is no way to do this in linearmodels:
# PanelOLS with entity_effects=True AND an instrument for an endogenous regressor
```

### Workaround

Use pyfixest's three-part formula syntax:

```python
import pyfixest as pf

# FE + IV in one call
fit = pf.feols("y ~ exog | entity + year | endog ~ instrument", data=df)
```

---

## 4. No DiD Estimators

linearmodels does not provide any difference-in-differences estimators. There
is no TWFE convenience wrapper, no did2s, no event study, no local projections
DiD, and no Sun-Abraham estimator.

Use pyfixest for all DiD work:

```python
import pyfixest as pf

# TWFE
fit = pf.feols("y ~ treat | entity + year", data=df)

# did2s (Gardner 2022)
fit = pf.did2s(data=df, yname="y", first_stage="~ 0 | entity + year",
               second_stage="~ i(rel_year, ref=-1)", treatment="treat",
               cluster="entity")
```

---

## 5. No Automatic Singleton Removal

Unlike pyfixest (which drops singleton fixed-effect groups by default since
v0.40 via `fixef_rm="singleton"`), linearmodels historically did not detect or
remove singletons. As of recent versions, `PanelOLS` now has a `singletons`
parameter (default `True`) that controls whether singleton groups are kept or
dropped. Singleton groups -- entity-time combinations with exactly one
observation -- can inflate degrees of freedom and produce misleading inference.

### Check for Singletons Manually

```python
# Check for entities with only one time period
group_sizes = df.groupby(level=0).size()
singletons = group_sizes[group_sizes == 1]
print(f"Singleton entities: {len(singletons)}")

# Remove if present
if len(singletons) > 0:
    df = df[~df.index.get_level_values(0).isin(singletons.index)]
    print(f"Removed {len(singletons)} singleton entities")
```

---

## 6. No Post-Estimation SE Switching

Unlike pyfixest where `fit.vcov("hetero")` switches standard errors without
re-estimating, linearmodels requires re-fitting the model with a different
`cov_type` argument:

```python
from linearmodels.panel import PanelOLS

mod = PanelOLS.from_formula("y ~ x + EntityEffects", data=df)

# Must call .fit() separately for each SE type
res_robust = mod.fit(cov_type="robust")
res_clustered = mod.fit(cov_type="clustered", cluster_entity=True)
res_kernel = mod.fit(cov_type="kernel")
```

```python
# pyfixest -- switch SEs post-estimation (no re-fit)
import pyfixest as pf
fit = pf.feols("y ~ x | entity", data=df)
fit.vcov("hetero")
fit.vcov({"CRV1": "entity"})
```

The computational cost of re-fitting in linearmodels is typically small since
the estimation step itself is fast. The inconvenience is mainly syntactic.

---

## 7. Constant Term Handling

### Array API

Like statsmodels, the linearmodels array API does NOT add a constant
automatically. Omitting the constant silently fits a model through the origin
with no warning.

```python
import statsmodels.api as sm
from linearmodels.iv import IV2SLS

# WRONG -- no intercept (model through origin)
mod = IV2SLS(y, X, endog, instruments)

# CORRECT -- add constant explicitly
mod = IV2SLS(y, sm.add_constant(X), endog, instruments)
```

### Formula API

The formula API adds a constant automatically (consistent with statsmodels
formula behavior). To suppress the intercept: `"y ~ x - 1"`.

### Panel Models Exception

PanelOLS with `entity_effects=True` absorbs the intercept into the entity
dummies -- you do not need to add or worry about a constant. However,
RandomEffects DOES include an explicit intercept, so ensure the constant is
present (the `"1"` in `"y ~ 1 + x"` via the formula API, or
`sm.add_constant(X)` via the array API).

---

## 8. Formula Syntax Differences from pyfixest

linearmodels and pyfixest use different formula conventions. Mixing them up
produces confusing errors.

| Feature | linearmodels | pyfixest |
|---------|-------------|----------|
| Entity FE | `"y ~ x + EntityEffects"` | `"y ~ x \| entity"` |
| Time FE | `"y ~ x + TimeEffects"` | `"y ~ x \| time"` |
| Two-way FE | `"y ~ x + EntityEffects + TimeEffects"` | `"y ~ x \| entity + time"` |
| IV specification | `"y ~ 1 + exog + [endog ~ inst]"` | `"y ~ exog \| 0 \| endog ~ inst"` |
| Multiple estimation | Not supported | `sw()`, `csw()`, `csw0()` |
| Categorical | `C(var)` | `C(var)` or `i(var, ref=val)` |

### Common Mistakes

```python
# WRONG -- pyfixest pipe syntax in linearmodels
mod = PanelOLS.from_formula("y ~ x | entity", data=df)
# This does NOT absorb entity FE; it's parsed as a bitwise OR

# CORRECT -- use EntityEffects keyword
mod = PanelOLS.from_formula("y ~ x + EntityEffects", data=df)
```

```python
# WRONG -- linearmodels IV bracket syntax in pyfixest
fit = pf.feols("y ~ 1 + exog + [endog ~ inst]", data=df)
# ParseError

# CORRECT -- pyfixest three-part formula
fit = pf.feols("y ~ exog | 0 | endog ~ inst", data=df)
```

---

## 9. SUR Performance with Large Datasets

The SUR (Seemingly Unrelated Regression) estimator uses dense matrix operations
and does not scale well to large datasets. The cross-equation covariance matrix
grows with the number of equations, and the system-level GLS step operates on
the full stacked dataset.

### Practical Thresholds

| Observations per Equation | Performance |
|---------------------------|-------------|
| N < 10,000 | Works well |
| 10,000 < N < 50,000 | Slow but feasible; monitor memory |
| N > 50,000 | Consider alternatives |

### Alternative for Large Data

If cross-equation correlation is low, equation-by-equation OLS with clustered
standard errors provides similar efficiency gains with much better scaling:

```python
import pyfixest as pf

# Instead of SUR, estimate each equation separately
fit1 = pf.feols("y1 ~ x1 + x2", data=df, vcov={"CRV1": "cluster"})
fit2 = pf.feols("y2 ~ x1 + x3", data=df, vcov={"CRV1": "cluster"})
```

---

## 10. Three-Way Package Boundary

linearmodels, pyfixest, and statsmodels have complementary but overlapping
capabilities. Choosing the wrong package wastes time and produces suboptimal
results.

### When to Use linearmodels

- Random effects, between effects, first difference, Fama-MacBeth
- IV without fixed effects (especially LIML, GMM, CUE-GMM)
- System estimation: SUR, 3SLS, system GMM
- Asset pricing factor models (linear factor models, risk premia)
- Driscoll-Kraay standard errors with fine-grained kernel control

### When to Use pyfixest Instead

- Any regression with absorbed fixed effects (faster, more convenient)
- FE + IV combined (linearmodels cannot do this)
- Difference-in-differences / event study (linearmodels has none)
- Poisson / GLM with fixed effects (`fepois`)
- Wild bootstrap, CRV3, randomization inference
- Multiple estimation via `sw()` / `csw()`
- Publication tables (`etable`) and coefficient plots (`coefplot`)

### When to Use statsmodels Instead

- GLM without fixed effects (logit, probit, negative binomial, zero-inflated)
- Time series (ARIMA, VAR, state space, GARCH via arch)
- Diagnostic tests (heteroskedasticity, normality, VIF, influence measures)
- Discrete choice (multinomial logit, ordered probit)
- Mixed / multilevel models (MixedLM)
- Robust regression (M-estimators, quantile regression)
- Prediction intervals and marginal effects

---

## Quick Diagnostic Table

| Symptom | Likely Cause | Fix |
|---------|-------------|-----|
| `ValueError` about MultiIndex with 2 levels | Missing MultiIndex on panel data | `df.set_index(["entity", "time"])` |
| Too many absorbed effects error | PanelOLS supports max 2-way FE | Use `AbsorbingLS` or pyfixest |
| Need IV with absorbed FE | No Panel IV in linearmodels | Use pyfixest three-part formula |
| All coefficients wrong (model through origin) | Missing constant in array API | `sm.add_constant(X)` |
| `EntityEffects` not recognized or ignored | Using pyfixest pipe syntax in linearmodels | Use `EntityEffects` keyword in formula string |
| SUR estimation very slow or OOM | Dataset too large for dense system GLS | Consider equation-by-equation OLS |
| SEs differ from pyfixest for same model | Different degrees-of-freedom corrections | Check `debiased` parameter in `.fit()` |
| `TypeError` with Polars DataFrame | linearmodels expects pandas | `df = df_polars.to_pandas()` then `set_index()` |

---

## References and Further Reading

- Sheppard, K. linearmodels documentation: https://bashtage.github.io/linearmodels/
- Sheppard, K. linearmodels GitHub repository: https://github.com/bashtage/linearmodels
- Sheppard, K. linearmodels GitHub issues: https://github.com/bashtage/linearmodels/issues
- Cameron, A.C. and Trivedi, P.K. (2005). *Microeconometrics: Methods and Applications*. Cambridge University Press. (Panel data and IV theory)
- Wooldridge, J.M. (2010). *Econometric Analysis of Cross Section and Panel Data*. 2nd ed. MIT Press. (FE, RE, FD, Hausman test)

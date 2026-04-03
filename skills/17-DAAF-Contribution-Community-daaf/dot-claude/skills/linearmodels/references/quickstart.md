# linearmodels Quickstart

A technical reference for using linearmodels v7.0 in Python. Covers installation,
the MultiIndex requirement, formula vs array APIs, first panel and IV models, reading
output, and syntax comparison with pyfixest and statsmodels. No methodology content
-- syntax and library guidance only.

## Contents

- [Installation](#installation)
- [The MultiIndex Requirement (CRITICAL)](#the-multiindex-requirement-critical)
- [Formula API vs Array API](#formula-api-vs-array-api)
- [Your First Panel Model](#your-first-panel-model)
- [Reading the Summary Output](#reading-the-summary-output)
- [Key Results Attributes](#key-results-attributes)
- [Your First IV Model](#your-first-iv-model)
- [Standard Errors](#standard-errors)
- [Model Comparison Tables](#model-comparison-tables)
- [Quick Syntax Comparison: linearmodels vs pyfixest vs statsmodels](#quick-syntax-comparison-linearmodels-vs-pyfixest-vs-statsmodels)
- [References and Further Reading](#references-and-further-reading)

---

## Installation

```bash
pip install linearmodels
```

Key dependencies (installed automatically):

| Package | Role |
|---------|------|
| `numpy` | Array operations and linear algebra |
| `pandas` | DataFrame input and MultiIndex handling |
| `scipy` | Statistical distributions and sparse matrices |
| `statsmodels` | Foundation for estimation infrastructure |
| `formulaic` | R-style formula parsing (replaces patsy) |
| `pyhdfe` | High-dimensional fixed effects absorption |
| `mypy_extensions` | Type stub support |

Optional dependencies:

| Package | Role |
|---------|------|
| `xarray` | Alternative data structure input |
| `Cython` | Compiled performance extensions |
| `numba` | JIT acceleration for select operations |

Verify installation:

```python
import linearmodels
print(linearmodels.__version__)  # Should print 7.x
```

Requires Python 3.10+.

---

## The MultiIndex Requirement (CRITICAL)

This is the single most important thing to know about linearmodels. All panel models
(`PanelOLS`, `RandomEffects`, `BetweenOLS`, `FirstDifferenceOLS`, `PooledOLS`,
`FamaMacBeth`) require a pandas DataFrame with a **two-level MultiIndex** where:

- **Level 0** = entity (firm, person, state, school, etc.)
- **Level 1** = time (year, quarter, date, etc.)

### Converting from a Flat DataFrame

```python
import pandas as pd

# Flat data with entity and time as regular columns
df = pd.read_parquet("panel_data.parquet")
print(df.columns.tolist())
# ['firm_id', 'year', 'invest', 'value', 'capital']

# Set the MultiIndex — entity first, time second
df = df.set_index(["firm_id", "year"])

# Verify
print(f"Index names: {df.index.names}")    # ['firm_id', 'year']
print(f"Index levels: {df.index.nlevels}")  # 2
```

### Converting from Polars

```python
import polars as pl

df_polars = pl.read_parquet("panel_data.parquet")
df = df_polars.to_pandas().set_index(["firm_id", "year"])
```

### What Happens If You Forget

Passing a DataFrame without a MultiIndex raises an error:

```
ValueError: Panel models require a MultiIndex with 2 levels that corresponds
to entities and time periods
```

If you see this error, set the index before passing data to any panel model.

### Important: IV Models Do NOT Require MultiIndex

The `IV2SLS`, `IVLIML`, `IVGMM`, and `IVGMMCUE` classes work with regular
(non-panel) DataFrames. Only panel models require the MultiIndex.

---

## Formula API vs Array API

linearmodels exposes two parallel interfaces for every model class.

### Formula API

Uses the `.from_formula()` class method. Formulas are parsed by **formulaic**
(not patsy — formulaic is the modern replacement used by both linearmodels and
pyfixest).

```python
from linearmodels.panel import PanelOLS

mod = PanelOLS.from_formula("invest ~ value + capital + EntityEffects", data=df)
res = mod.fit()
```

### Array API

Passes dependent variable, exogenous regressors, and optional parameters directly
to the constructor.

```python
from linearmodels.panel import PanelOLS

mod = PanelOLS(df["invest"], df[["value", "capital"]], entity_effects=True)
res = mod.fit()
```

### Same Model, Both Ways

```python
import pandas as pd
from linearmodels.panel import PanelOLS

df = pd.read_parquet("grunfeld.parquet")
df = df.set_index(["firm_id", "year"])

# --- Formula API ---
res_f = PanelOLS.from_formula(
    "invest ~ value + capital + EntityEffects", data=df
).fit(cov_type="clustered", cluster_entity=True)

# --- Array API ---
res_a = PanelOLS(
    df["invest"], df[["value", "capital"]], entity_effects=True
).fit(cov_type="clustered", cluster_entity=True)

# Both produce identical coefficient estimates
print(res_f.params)
print(res_a.params)
```

### When to Prefer Each

| Situation | Preferred API | Reason |
|-----------|---------------|--------|
| Exploratory analysis | Formula | Concise, readable |
| Quick specification changes | Formula | Change one string instead of subsetting columns |
| Programmatic model building | Array | Loop over column subsets, build matrices in code |
| Dynamic variable selection | Array | No string manipulation needed |

### Formula Syntax Unique to linearmodels

linearmodels formulas differ from statsmodels and pyfixest in two key ways:

**1. Fixed effects as keywords in the formula (not after `|`)**

```python
# linearmodels — EntityEffects and TimeEffects are keywords IN the formula
"invest ~ value + capital + EntityEffects"
"invest ~ value + capital + EntityEffects + TimeEffects"

# pyfixest — fixed effects go AFTER the pipe
"invest ~ value + capital | firm_id"
"invest ~ value + capital | firm_id + year"
```

**2. IV uses bracket notation (not pipe notation)**

```python
# linearmodels — endogenous variable and instruments in brackets
"np.log(wage) ~ 1 + exper + exper_sq + [educ ~ motheduc + fatheduc]"

# pyfixest — endogenous and instruments after second pipe
"np.log(wage) ~ 1 + exper + exper_sq | 0 | educ ~ motheduc + fatheduc"
```

---

## Your First Panel Model

### PanelOLS with Entity Effects (Formula)

```python
import pandas as pd
from linearmodels.panel import PanelOLS

# Load and set MultiIndex
df = pd.read_parquet("grunfeld.parquet")
df = df.set_index(["firm_id", "year"])

# Estimate with entity fixed effects
mod = PanelOLS.from_formula(
    "invest ~ value + capital + EntityEffects", data=df
)
res = mod.fit(cov_type="clustered", cluster_entity=True)
print(res.summary)
```

### PanelOLS with Entity Effects (Array)

```python
mod = PanelOLS(
    dependent=df["invest"],
    exog=df[["value", "capital"]],
    entity_effects=True,
)
res = mod.fit(cov_type="clustered", cluster_entity=True)
print(res.summary)
```

### Two-Way Fixed Effects

```python
# Formula: add both keywords
mod = PanelOLS.from_formula(
    "invest ~ value + capital + EntityEffects + TimeEffects", data=df
)
res = mod.fit(cov_type="clustered", cluster_entity=True)

# Array: set both flags
mod = PanelOLS(
    df["invest"], df[["value", "capital"]],
    entity_effects=True, time_effects=True,
)
res = mod.fit(cov_type="clustered", cluster_entity=True)
```

---

## Reading the Summary Output

`res.summary` (a property, not a method — no parentheses) prints a multi-panel
text table.

### Panel 1: Model Information

```
                          PanelOLS Estimation Summary
================================================================================
Dep. Variable:              invest   R-squared:                        0.7668
Estimator:                PanelOLS   R-squared (Between):              0.8194
No. Observations:              200   R-squared (Within):               0.7668
Date:                ...            R-squared (Overall):              0.8132
Time:                ...            Log-likelihood                   -1070.2
Cov. Estimator:          Clustered
                                     F-statistic:                      324.86
Entities:                       10   P-value                           0.0000
Avg Obs:                     20.00   Distribution:                  F(2,188)
Min Obs:                     20.00
Max Obs:                     20.00   F-statistic (robust):             160.84
                                     P-value                           0.0000
Time periods:                   20   Distribution:                  F(2,188)
Avg Obs:                     10.00
Min Obs:                     10.00
Max Obs:                     10.00
```

Key fields:

| Field | Meaning |
|-------|---------|
| `R-squared` | Within R-squared (variation explained within entities) |
| `R-squared (Between)` | Cross-entity variation explained |
| `R-squared (Within)` | Same as R-squared for FE models |
| `R-squared (Overall)` | Total variation explained (pooled) |
| `F-statistic` | Joint test that all slope coefficients are zero (non-robust) |
| `F-statistic (robust)` | Same test using the robust covariance estimator |
| `Entities` / `Time periods` | Panel dimensions |
| `Cov. Estimator` | Covariance type used (`Clustered`, `Unadjusted`, `Robust`, etc.) |

### Panel 2: Coefficient Table

```
                Parameter Estimates
============================================
            Parameter  Std. Err.  T-stat  P-value  Lower CI  Upper CI
--------------------------------------------
value          0.1101    0.0155   7.1073   0.0000    0.0796    0.1406
capital        0.3100    0.0530   5.8488   0.0000    0.2055    0.4146
```

Entity effects are absorbed — they do not appear as coefficients. The F-test
for effects tests whether entity effects are jointly significant.

### Panel 3: Additional Statistics

```
F-test for Poolability:      49.177
P-value:                     0.0000
Distribution:                F(9,188)
```

The poolability F-test (also called the F-test for fixed effects) tests the null
hypothesis that all entity intercepts are equal. A small p-value supports using
fixed effects over pooled OLS.

---

## Key Results Attributes

All attributes are available on the results object returned by `.fit()`.

| Attribute | Type | Description |
|-----------|------|-------------|
| `res.params` | Series | Estimated coefficients |
| `res.std_errors` | Series | Standard errors of coefficients |
| `res.tstats` | Series | t-statistics for each coefficient |
| `res.pvalues` | Series | Two-sided p-values |
| `res.rsquared` | float | R-squared (within for FE models) |
| `res.rsquared_between` | float | Between R-squared |
| `res.rsquared_overall` | float | Overall R-squared |
| `res.rsquared_adj` | float | Adjusted R-squared |
| `res.f_statistic` | WaldTestStatistic | F-test for joint significance |
| `res.resids` | Series | Residuals |
| `res.fitted_values` | Series | Fitted values |
| `res.nobs` | int | Number of observations |
| `res.entity_info` | Series | Entity counts and observation distribution |
| `res.time_info` | Series | Time period counts |
| `res.conf_int()` | DataFrame | Confidence intervals (default 95%) |
| `res.summary` | Summary | Full summary table (property, no parentheses) |

```python
# Direct attribute access
print(res.params)
print(res.pvalues)
print(res.rsquared)
print(res.conf_int(level=0.99))  # 99% CI
```

---

## Your First IV Model

IV models (`IV2SLS`, `IVLIML`, `IVGMM`) do **not** require a MultiIndex — they
work with regular DataFrames on cross-sectional or any flat data.

### IV2SLS (Formula)

```python
from linearmodels.iv import IV2SLS

# Bracket notation: [endogenous ~ instruments]
mod = IV2SLS.from_formula(
    "np.log(wage) ~ 1 + exper + exper_sq + [educ ~ motheduc + fatheduc]",
    data=df,
)
res = mod.fit(cov_type="robust")
print(res.summary)
```

### IV2SLS (Array)

```python
from linearmodels.iv import IV2SLS
import numpy as np

mod = IV2SLS(
    dependent=np.log(df["wage"]),
    exog=df[["const", "exper", "exper_sq"]],  # exogenous regressors (include constant)
    endog=df[["educ"]],                        # endogenous regressor
    instruments=df[["motheduc", "fatheduc"]],  # excluded instruments
)
res = mod.fit(cov_type="robust")
```

### IV Formula Notes

- The `1` in the formula adds an intercept (constant term)
- Brackets `[endog ~ instruments]` contain the endogenous variable on the left
  and excluded instruments on the right
- Multiple endogenous variables: `[endog1 + endog2 ~ inst1 + inst2 + inst3]`
- Exogenous variables outside brackets are included in both stages automatically

---

## Standard Errors

Standard errors are specified at `.fit()` time via `cov_type` and related
keyword arguments.

### Panel Models

```python
from linearmodels.panel import PanelOLS

mod = PanelOLS.from_formula("invest ~ value + capital + EntityEffects", data=df)

# Unadjusted (homoskedastic) — default
res = mod.fit(cov_type="unadjusted")

# Heteroskedasticity-robust
res = mod.fit(cov_type="robust")

# Clustered by entity
res = mod.fit(cov_type="clustered", cluster_entity=True)

# Clustered by time
res = mod.fit(cov_type="clustered", cluster_time=True)

# Two-way clustered (entity and time)
res = mod.fit(cov_type="clustered", cluster_entity=True, cluster_time=True)

# Driscoll-Kraay (kernel-based, robust to cross-sectional dependence)
res = mod.fit(cov_type="kernel", kernel="bartlett", bandwidth=5)
```

### IV Models

```python
from linearmodels.iv import IV2SLS

mod = IV2SLS.from_formula(
    "np.log(wage) ~ 1 + exper + [educ ~ motheduc + fatheduc]", data=df
)

# Unadjusted — default
res = mod.fit(cov_type="unadjusted")

# Heteroskedasticity-robust
res = mod.fit(cov_type="robust")

# Kernel (HAC)
res = mod.fit(cov_type="kernel", kernel="bartlett", bandwidth=4)

# Clustered
res = mod.fit(cov_type="clustered", clusters=df["state"])
```

### Quick SE Reference

| SE Type | Panel Syntax | IV Syntax |
|---------|-------------|-----------|
| Homoskedastic | `cov_type="unadjusted"` | `cov_type="unadjusted"` |
| Robust (HC1) | `cov_type="robust"` | `cov_type="robust"` |
| Entity-clustered | `cov_type="clustered", cluster_entity=True` | `cov_type="clustered", clusters=var` |
| Time-clustered | `cov_type="clustered", cluster_time=True` | N/A |
| Two-way clustered | `cluster_entity=True, cluster_time=True` | N/A |
| Driscoll-Kraay | `cov_type="kernel", kernel="bartlett"` | `cov_type="kernel", kernel="bartlett"` |

---

## Model Comparison Tables

linearmodels provides a `compare()` function for side-by-side model comparison.

```python
from linearmodels.panel import PanelOLS, RandomEffects, BetweenOLS, PooledOLS, compare

df = df.set_index(["firm_id", "year"])

# Estimate multiple specifications
res_pooled = PooledOLS.from_formula("invest ~ 1 + value + capital", data=df).fit()
res_fe = PanelOLS.from_formula(
    "invest ~ value + capital + EntityEffects", data=df
).fit(cov_type="clustered", cluster_entity=True)
res_re = RandomEffects.from_formula(
    "invest ~ 1 + value + capital", data=df
).fit()
res_be = BetweenOLS.from_formula(
    "invest ~ 1 + value + capital", data=df
).fit()

# Compare in a single table
comp = compare({
    "Pooled": res_pooled,
    "FE": res_fe,
    "RE": res_re,
    "Between": res_be,
})
print(comp.summary)
```

The comparison table shows coefficients, standard errors, and fit statistics
across models in aligned columns — useful for assessing sensitivity to
estimation approach.

---

## Quick Syntax Comparison: linearmodels vs pyfixest vs statsmodels

| Task | linearmodels | pyfixest | statsmodels |
|------|-------------|----------|-------------|
| OLS (no FE) | `IV2SLS.from_formula("y ~ 1 + x", data)` | `pf.feols("y ~ x", data)` | `smf.ols("y ~ x", data).fit()` |
| Entity FE | `PanelOLS.from_formula("y ~ x + EntityEffects", data)` | `pf.feols("y ~ x \| entity", data)` | N/A (manual dummies) |
| Two-way FE | `PanelOLS.from_formula("y ~ x + EntityEffects + TimeEffects", data)` | `pf.feols("y ~ x \| entity + year", data)` | N/A |
| Random effects | `RandomEffects.from_formula("y ~ 1 + x", data)` | N/A | N/A |
| Between estimation | `BetweenOLS.from_formula("y ~ 1 + x", data)` | N/A | N/A |
| First difference | `FirstDifferenceOLS.from_formula("y ~ x", data)` | N/A | N/A |
| Fama-MacBeth | `FamaMacBeth.from_formula("y ~ 1 + x", data)` | N/A | N/A |
| IV / 2SLS | `IV2SLS.from_formula("y ~ 1 + x + [endog ~ inst]", data)` | `pf.feols("y ~ x \| 0 \| endog ~ inst", data)` | Limited |
| LIML | `IVLIML.from_formula("y ~ 1 + x + [endog ~ inst]", data)` | N/A | N/A |
| GMM-IV | `IVGMM.from_formula("y ~ 1 + x + [endog ~ inst]", data)` | N/A | N/A |
| SUR | `SUR.from_formula(system_dict)` | N/A | N/A |
| Robust SE | `.fit(cov_type="robust")` | `vcov="hetero"` | `.fit(cov_type="HC1")` |
| Clustered SE | `.fit(cov_type="clustered", cluster_entity=True)` | `vcov={"CRV1": "entity"}` | `.fit(cov_type="cluster", ...)` |
| Driscoll-Kraay SE | `.fit(cov_type="kernel", kernel="bartlett")` | N/A | N/A |
| Model table | `compare({"M1": r1, "M2": r2})` | `pf.etable([f1, f2])` | Manual |

### When to Use Which

**Use linearmodels when:**
- You need random effects, between estimation, or first difference estimators
- Running Fama-MacBeth cross-sectional regressions
- Estimating LIML, GMM-IV, or continuously updating GMM
- Building system models (SUR, 3SLS, system GMM)
- You need Driscoll-Kraay standard errors for panel data
- Asset pricing factor model tests

**Use pyfixest when:**
- High-dimensional fixed effects (3+ way FE, interacted FE)
- IV combined with fixed effects (linearmodels cannot do this)
- Difference-in-differences or event study designs
- Wild bootstrap or CRV3 clustered standard errors
- Publication-quality tables and coefficient plots

**Use statsmodels when:**
- GLMs (logit, probit, Poisson, negative binomial)
- Time series models (ARIMA, VAR, state space)
- Diagnostic tests (heteroskedasticity, normality, autocorrelation)
- Discrete choice models
- No panel structure or fixed effects needed

---

## References and Further Reading

- Sheppard, K. linearmodels documentation: https://bashtage.github.io/linearmodels/
- Sheppard, K. linearmodels GitHub: https://github.com/bashtage/linearmodels
- formulaic documentation: https://matthewwardrop.github.io/formulaic/
- pyhdfe documentation: https://github.com/jeffgortmaker/pyhdfe

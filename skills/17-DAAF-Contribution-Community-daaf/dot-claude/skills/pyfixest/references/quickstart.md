# pyfixest Quickstart

## Contents

- [Installation](#installation)
- [Your First Regression](#your-first-regression)
- [Switching Standard Errors After Estimation](#switching-standard-errors-after-estimation)
- [Formula Syntax Overview](#formula-syntax-overview)
- [Quick Comparison: pyfixest vs statsmodels vs R fixest](#quick-comparison-pyfixest-vs-statsmodels-vs-r-fixest)
- [Using pyfixest with Polars DataFrames](#using-pyfixest-with-polars-dataframes)

## Installation

### Basic Install

```bash
pip install pyfixest
# or
uv add pyfixest
```

### Optional Dependencies

```bash
pip install pyfixest[plots]        # lets-plot for visualization
pip install pyfixest[gt]           # great_tables for etable output
pip install pyfixest[jax]          # JAX backend for GPU demeaning
pip install wildboottest           # Wild cluster bootstrap
pip install marginaleffects        # Post-estimation interpretation
```

### Verify Installation

```python
import pyfixest as pf
print(pf.__version__)  # Should be 0.40.0+
```

## Your First Regression

### Basic OLS (No Fixed Effects)

```python
import pyfixest as pf
import pandas as pd

# Load example data
data = pf.get_data()

# Simple OLS
fit = pf.feols("Y ~ X1 + X2", data=data)
fit.summary()
```

### OLS with Fixed Effects

```python
# One-way FE: absorb entity-level intercepts
fit = pf.feols("Y ~ X1 | f1", data=data)
fit.summary()

# Two-way FE: entity + time fixed effects
fit = pf.feols("Y ~ X1 | f1 + f2", data=data)
fit.summary()
```

### Reading the Summary Output

The `.summary()` output displays:
- **Dep. var.**: The outcome variable
- **Observations**: Sample size (after dropping singletons if applicable)
- **S.E. type**: Standard error type used (e.g., iid, hetero, CRV1)
- **Coefficient table**: Estimate, Std. Error, t value, Pr(>|t|), confidence interval
- **R2 / R2 Within / R2 Adj.**: Model fit statistics
- **Fixed effects info**: Number of levels absorbed for each FE

### Switching Standard Errors After Estimation

A key workflow pattern: estimate once, try different SE assumptions without re-estimating.

```python
fit = pf.feols("Y ~ X1 | f1", data=data)

# IID (default in v0.40+)
fit.summary()

# Heteroskedasticity-robust
fit.vcov("hetero").summary()

# Clustered by f1
fit.vcov({"CRV1": "f1"}).summary()

# Two-way clustered
fit.vcov({"CRV1": "f1+f2"}).summary()
```

This works because SE computation is independent of point estimation under OLS — changing the variance estimator only affects standard errors, not coefficients.

## Formula Syntax Overview

pyfixest uses a three-part formula separated by `|`:

```
depvar ~ exogenous_vars | fixed_effects | endogenous ~ instruments
```

### Part 1: Dependent Variable and Exogenous Regressors

```python
# Basic regressors
"Y ~ X1 + X2"

# Interaction with main effects
"Y ~ X1 * X2"          # equivalent to X1 + X2 + X1:X2

# Interaction only (no main effects)
"Y ~ X1:X2"

# Categorical variable
"Y ~ C(state)"

# Transformations (via formulaic)
"Y ~ np.log(X1) + X2"
```

### Part 2: Fixed Effects (After First `|`)

```python
# One-way FE
"Y ~ X1 | entity"

# Two-way FE
"Y ~ X1 | entity + year"

# Three-way FE
"Y ~ X1 | entity + year + industry"

# Interacted FE (entity-by-year)
"Y ~ X1 | entity ^ year"
```

### Part 3: Instrumental Variables (After Second `|`)

```python
# IV: endogenous ~ instrument
"Y ~ X_exog | fe | X_endog ~ Z_instrument"

# IV with no FE (use 0 for empty FE)
"Y ~ X_exog | 0 | X_endog ~ Z1 + Z2"

# Multiple instruments
"Y ~ 1 | fe | X_endog ~ Z1 + Z2"
```

### The `i()` Operator for Interactions and Categoricals

```python
# Categorical with reference level
"Y ~ i(year, ref=2000) | entity"

# Numeric interaction with categorical
"Y ~ i(group, X1, ref='control')"

# Two categoricals interacted
"Y ~ i(race, gender, ref='white', ref2='male')"

# Binning levels
"Y ~ i(age, bin={'young': [18,19,20], 'old': [60,61,62]})"
```

`i()` is especially important for event study specifications — see `difference-in-differences.md`.

## Quick Comparison: pyfixest vs statsmodels vs R fixest

| Task | pyfixest | statsmodels | R fixest |
|------|----------|-------------|----------|
| OLS | `pf.feols("Y ~ X", data)` | `smf.ols("Y ~ X", data).fit()` | `feols(Y ~ X, data)` |
| OLS + FE | `pf.feols("Y ~ X \| fe", data)` | Manual dummies | `feols(Y ~ X \| fe, data)` |
| Clustered SE | `fit.vcov({"CRV1": "g"})` | `fit.get_robustcov_results(cov_type="cluster")` | `vcov = ~g` |
| Poisson + FE | `pf.fepois("Y ~ X \| fe", data)` | Not available with FE | `fepois(Y ~ X \| fe, data)` |
| IV + FE | `pf.feols("Y ~ 1 \| fe \| X ~ Z", data)` | `IV2SLS` (no FE) | `feols(Y ~ 1 \| fe \| X ~ Z, data)` |
| Regression table | `pf.etable([fit1, fit2])` | Manual construction | `etable(fit1, fit2)` |

pyfixest syntax is nearly identical to R fixest, making cross-language work straightforward.

## Using pyfixest with Polars DataFrames

DAAF pipelines use Polars for data processing (Stages 5-7), but pyfixest expects a **pandas DataFrame** as input. Convert before estimation:

```python
import polars as pl
import pyfixest as pf

# Load processed data (Polars DataFrame from earlier pipeline stages)
df_polars = pl.read_parquet("data/processed/analysis_data.parquet")

# Convert to pandas for pyfixest
df = df_polars.to_pandas()

# Now estimate
fit = pf.feols("Y ~ X1 + X2 | entity + year", data=df)
```

Post-estimation results (`.tidy()`, `.coef()`, etc.) return pandas objects. If you need to rejoin results with Polars data downstream, convert back with `pl.from_pandas()`.

pyfixest also accepts PyArrow-backed pandas DataFrames, but explicit `.to_pandas()` conversion is the most reliable approach.

## Next Steps

- Learn about fixed effects and standard error types → `fixed-effects.md`
- Set up instrumental variables → `instrumental-variables.md`
- Run difference-in-differences designs → `difference-in-differences.md`
- Create publication tables and plots → `tables-and-plots.md`

## References and Further Reading

- Berge, L., Butts, K., and McDermott, G. (2026). "Fast and User-Friendly Econometrics Estimations: The R Package fixest." arXiv:2601.21749. https://arxiv.org/abs/2601.21749
- pyfixest documentation: https://pyfixest.org
- pyfixest GitHub: https://github.com/py-econometrics/pyfixest
- R fixest documentation: https://lrberge.github.io/fixest/

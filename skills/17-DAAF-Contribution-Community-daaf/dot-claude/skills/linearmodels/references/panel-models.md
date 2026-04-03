# Panel Data Models

Reference for all panel estimators in `linearmodels.panel`. For methodology guidance on when to use FE vs RE, assumption checking, and model selection, see the data-scientist skill's `statistical-modeling.md` reference.

## Contents

- [Data Requirements](#data-requirements)
- [PanelOLS (Fixed Effects)](#panelols-fixed-effects)
- [RandomEffects](#randomeffects)
- [BetweenOLS](#betweenols)
- [FirstDifferenceOLS](#firstdifferenceols)
- [PooledOLS](#pooledols)
- [FamaMacBeth](#famamacbeth)
- [Weighted Estimation](#weighted-estimation)
- [Model Comparison with compare()](#model-comparison-with-compare)
- [Common Patterns](#common-patterns)
- [References and Further Reading](#references-and-further-reading)

## Data Requirements

All panel models require a pandas DataFrame with a two-level MultiIndex of `(entity, time)`. Balanced panels are not required -- all estimators handle unbalanced panels. Observations with NaN in the dependent or any independent variable are dropped automatically.

### Standard Setup Pattern

```python
import pandas as pd
from linearmodels.panel import PanelOLS

# Load data (Grunfeld investment dataset as example)
df = pd.read_parquet("data/raw/grunfeld.parquet")

# Set MultiIndex — entity first, time second
df = df.set_index(["firm_id", "year"])

# Verify structure before estimation
print(f"Index names: {df.index.names}")      # ['firm_id', 'year']
print(f"Index levels: {df.index.nlevels}")    # 2
print(f"Entities: {df.index.get_level_values(0).nunique()}")
print(f"Periods: {df.index.get_level_values(1).nunique()}")
print(f"Total obs: {len(df)}")

# Check balance
obs_per_entity = df.groupby(level=0).size()
print(f"Balanced: {obs_per_entity.nunique() == 1}")
print(f"Min periods per entity: {obs_per_entity.min()}")
print(f"Max periods per entity: {obs_per_entity.max()}")
```

## PanelOLS (Fixed Effects)

Within estimator that absorbs entity and/or time fixed effects by demeaning. This is the workhorse panel model for controlling unobserved heterogeneity.

### Effect Types

| Parameter | Formula Keyword | What It Absorbs |
|-----------|----------------|-----------------|
| `entity_effects=True` | `EntityEffects` | Time-invariant entity heterogeneity |
| `time_effects=True` | `TimeEffects` | Entity-invariant time shocks |
| Both simultaneously | Both keywords | Two-way fixed effects |
| `other_effects=df["group"]` | n/a (array API only) | Arbitrary grouping variable |

PanelOLS supports a maximum of 2 sets of effects. For 3+ way FE, use pyfixest.

### Formula API

```python
from linearmodels.panel import PanelOLS

# Entity fixed effects
mod = PanelOLS.from_formula("invest ~ value + capital + EntityEffects", data=df)
res = mod.fit()
print(res.summary)

# Time fixed effects only
mod = PanelOLS.from_formula("invest ~ value + capital + TimeEffects", data=df)

# Two-way fixed effects (entity + time)
mod = PanelOLS.from_formula(
    "invest ~ value + capital + EntityEffects + TimeEffects", data=df
)
```

### Array API

```python
mod = PanelOLS(
    dependent=df["invest"],
    exog=df[["value", "capital"]],
    entity_effects=True,
    time_effects=True,
)
res = mod.fit()
```

### Other Effects (Arbitrary Groupings)

```python
# Absorb a third grouping variable (array API only)
mod = PanelOLS(
    dependent=df["invest"],
    exog=df[["value", "capital"]],
    entity_effects=True,
    other_effects=df["industry_code"],
)
res = mod.fit()
```

### check_rank Parameter

```python
# Disable rank check when you know the model is identified
# Useful with large numbers of effects where rank checking is slow
mod = PanelOLS.from_formula(
    "invest ~ value + capital + EntityEffects", data=df, check_rank=False
)
```

### Interpreting PanelOLS Output

The results object provides three R-squared measures:

| R-squared | Measures | Interpretation |
|-----------|----------|----------------|
| Within | Variation within entities after demeaning | How well regressors explain within-entity changes |
| Between | Variation across entity means | How well regressors explain cross-entity differences |
| Overall | Total variation (pooled) | Combined explanatory power |

Key output elements:
- **F-test for poolability**: Tests the null that all entity effects are jointly zero. Rejection means entity effects matter and pooled OLS is inappropriate.
- **Estimated parameters** do NOT include entity/time dummies -- they are absorbed via demeaning.
- **Degrees of freedom** account for absorbed effects.

```python
res = mod.fit()

# Access fit statistics
print(f"Within R-sq: {res.rsquared_within:.4f}")
print(f"Between R-sq: {res.rsquared_between:.4f}")
print(f"Overall R-sq: {res.rsquared_overall:.4f}")

# F-test for poolability (entity effects jointly zero)
print(f"F-stat (poolable): {res.f_pooled.stat:.4f}")
print(f"F p-value: {res.f_pooled.pval:.4f}")
```

### Extracting Fixed Effects

```python
res = mod.fit()

# Estimated entity/time effects
effects = res.estimated_effects
print(effects.head(10))

# Merge effects back for inspection
# Effects are indexed by the same MultiIndex as the original data
print(f"Shape: {effects.shape}")
print(f"Mean effect (should be ~0 for entity FE): {effects.mean().values}")
```

## RandomEffects

GLS estimator with quasi-demeaning. Assumes entity effects are uncorrelated with regressors -- more efficient than FE when this assumption holds, inconsistent when it does not.

### Usage

```python
from linearmodels.panel import RandomEffects

# RE requires an intercept — include 1 in the formula
mod = RandomEffects.from_formula("invest ~ 1 + value + capital", data=df)
res = mod.fit()
print(res.summary)
```

### Array API

```python
from linearmodels.panel import RandomEffects
import numpy as np

# Must add constant column manually in array API
exog = df[["value", "capital"]].copy()
exog.insert(0, "const", 1.0)

mod = RandomEffects(dependent=df["invest"], exog=exog)
res = mod.fit()
```

### Variance Decomposition

```python
# RE decomposes total variance into entity and idiosyncratic components
print(f"Sigma^2_entity: {res.variance_decomposition.Effects:.4f}")
print(f"Sigma^2_idiosyncratic: {res.variance_decomposition.Residual:.4f}")

# Theta: quasi-demeaning parameter (0 = pooled OLS, 1 = full within)
# Closer to 1 means more within-entity variation, RE approaches FE
print(f"Theta: {res.theta.iloc[0]:.4f}")
```

### FE vs RE Comparison

linearmodels does NOT have a built-in Hausman test. Compare FE and RE results using the `compare()` function and inspect whether coefficients diverge substantively. For the methodology behind the FE vs RE decision, see the data-scientist skill's `statistical-modeling.md`.

```python
from linearmodels.panel import PanelOLS, RandomEffects, compare

fe_mod = PanelOLS.from_formula(
    "invest ~ value + capital + EntityEffects", data=df
)
re_mod = RandomEffects.from_formula("invest ~ 1 + value + capital", data=df)

fe_res = fe_mod.fit()
re_res = re_mod.fit()

# Side-by-side comparison table
comp = compare({"Fixed Effects": fe_res, "Random Effects": re_res})
print(comp.summary)

# Manual coefficient comparison for Hausman-style inspection
fe_params = fe_res.params
re_params = re_res.params[fe_params.index]  # Align on common regressors
diff = fe_params - re_params
print("Coefficient differences (FE - RE):")
print(diff)
print("Large differences suggest RE assumption is violated → use FE")
```

## BetweenOLS

Regresses entity time-averages on entity-averaged regressors. Uses only between-entity (cross-sectional) variation. Useful as a diagnostic or as part of variance decomposition analysis.

```python
from linearmodels.panel import BetweenOLS

# Between estimator requires an intercept
mod = BetweenOLS.from_formula("invest ~ 1 + value + capital", data=df)
res = mod.fit()
print(res.summary)

# Number of effective observations = number of entities
print(f"Entities used: {res.nobs}")
```

## FirstDifferenceOLS

Eliminates entity effects by first-differencing: delta_y_it = delta_x_it * beta + delta_epsilon_it. Alternative to within-estimation that can handle certain forms of serial correlation better. Loses one time period per entity.

```python
from linearmodels.panel import FirstDifferenceOLS

# No intercept or effects keywords — differencing removes both
mod = FirstDifferenceOLS.from_formula("invest ~ value + capital", data=df)
res = mod.fit()
print(res.summary)

# First-difference requires at least 2 time periods per entity
# Entities with only 1 period are dropped automatically
print(f"Observations used: {res.nobs}")
```

## PooledOLS

Standard OLS ignoring panel structure, but with panel-aware covariance estimation. Entity and time identifiers are used for clustering standard errors, not for absorbing effects. Useful as a baseline model.

```python
from linearmodels.panel import PooledOLS

# Include intercept explicitly
mod = PooledOLS.from_formula("invest ~ 1 + value + capital", data=df)

# Without clustered SEs — equivalent to plain OLS
res_naive = mod.fit()

# With entity-clustered SEs — accounts for within-entity correlation
res_clustered = mod.fit(cov_type="clustered", cluster_entity=True)
print(res_clustered.summary)
```

## FamaMacBeth

Two-step procedure: (1) run a cross-sectional regression for each time period, (2) average coefficients across periods. Standard approach in empirical asset pricing for testing factor models. See `./asset-pricing.md` for factor model application context.

```python
from linearmodels.panel import FamaMacBeth

# Typical asset pricing specification
mod = FamaMacBeth.from_formula("ret ~ 1 + beta + size + bm", data=df)

# Basic Fama-MacBeth SEs (assumes independence across periods)
res = mod.fit()
print(res.summary)

# HAC-adjusted SEs for time-series dependence in averaged coefficients
res_hac = mod.fit(cov_type="kernel", kernel="bartlett", bandwidth=5)
print(res_hac.summary)

# Access time-period-by-period coefficient estimates
# Not directly available in results — re-estimate manually if needed
```

## Weighted Estimation

All panel models accept a `weights` parameter for WLS-style estimation. Weights must have the same shape as the dependent variable (one weight per observation).

```python
# Weighted fixed effects
mod = PanelOLS.from_formula(
    "invest ~ value + capital + EntityEffects",
    data=df,
    weights=df["weight"],
)
res = mod.fit()

# Weighted random effects
mod = RandomEffects.from_formula(
    "invest ~ 1 + value + capital",
    data=df,
    weights=df["weight"],
)
res = mod.fit()
```

Common weight sources:
- **Population weights**: weight by group size for representative estimates
- **Precision weights**: inverse of known variance for heteroskedastic data
- **Frequency weights**: when data is pre-aggregated with counts

## Model Comparison with compare()

The `compare()` function produces a side-by-side table showing coefficients, standard errors, and fit statistics for all models. It is the linearmodels equivalent of pyfixest's `etable()`.

```python
from linearmodels.panel import (
    PanelOLS, RandomEffects, BetweenOLS,
    FirstDifferenceOLS, PooledOLS, compare,
)

# Estimate all models on the same specification
pooled_res = PooledOLS.from_formula(
    "invest ~ 1 + value + capital", data=df
).fit(cov_type="clustered", cluster_entity=True)

fe_res = PanelOLS.from_formula(
    "invest ~ value + capital + EntityEffects", data=df
).fit()

re_res = RandomEffects.from_formula(
    "invest ~ 1 + value + capital", data=df
).fit()

between_res = BetweenOLS.from_formula(
    "invest ~ 1 + value + capital", data=df
).fit()

fd_res = FirstDifferenceOLS.from_formula(
    "invest ~ value + capital", data=df
).fit()

# Compare all
comp = compare({
    "Pooled": pooled_res,
    "FE": fe_res,
    "RE": re_res,
    "Between": between_res,
    "FD": fd_res,
})
print(comp.summary)
```

## Common Patterns

### Typical Panel Analysis Workflow

1. Estimate PooledOLS as baseline
2. Estimate PanelOLS (FE) -- check if entity effects matter via F-test for poolability
3. Estimate RandomEffects -- compare coefficients with FE
4. If FE and RE coefficients diverge substantially, use FE (RE assumption likely violated)
5. Consider FirstDifferenceOLS as a robustness check
6. Report preferred specification with appropriate clustered SEs

### Adding Time Trends Instead of Time FE

```python
# Linear time trend as a regressor (not as absorbed time effects)
# Useful when you want to model the trend parametrically
df["trend"] = (
    df.index.get_level_values("year")
    - df.index.get_level_values("year").min()
)

mod = PanelOLS.from_formula(
    "invest ~ value + capital + trend + EntityEffects", data=df
)
res = mod.fit()
```

### Clustered Standard Errors with Panel Models

```python
# Entity-clustered (default clustering dimension for panel data)
res = mod.fit(cov_type="clustered", cluster_entity=True)

# Time-clustered
res = mod.fit(cov_type="clustered", cluster_time=True)

# Two-way clustering (entity and time)
res = mod.fit(cov_type="clustered", cluster_entity=True, cluster_time=True)
```

For full covariance estimation options including Driscoll-Kraay and HAC kernels, see `./covariance-inference.md`.

### Accessing Results Programmatically

```python
res = mod.fit()

# Coefficients and standard errors
print(res.params)           # pd.Series of point estimates
print(res.std_errors)       # pd.Series of standard errors
print(res.pvalues)          # pd.Series of p-values
print(res.conf_int())       # pd.DataFrame with 95% CI (default)
print(res.conf_int(0.90))   # 90% CI

# Residuals and fitted values
print(res.resids.head())    # Residuals
print(res.fitted_values.head())

# Number of observations and entities
print(f"N obs: {res.nobs}")
print(f"N entities: {res.entity_info['total']}")
print(f"N time periods: {res.time_info['total']}")
```

## References and Further Reading

- Sheppard, K. linearmodels Panel Models documentation. https://bashtage.github.io/linearmodels/panel/introduction.html
- Wooldridge, J.M. (2010). *Econometric Analysis of Cross Section and Panel Data*. 2nd ed. MIT Press.
- Baltagi, B.H. (2021). *Econometric Analysis of Panel Data*. 6th ed. Springer.
- Mundlak, Y. (1978). "On the Pooling of Time Series and Cross Section Data." *Econometrica*, 46(1), 69-85.

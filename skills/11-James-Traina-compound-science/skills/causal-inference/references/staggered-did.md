# Staggered DiD Estimators — Implementation Reference

## The Problem with TWFE

With staggered adoption, TWFE (two-way fixed effects) estimates a weighted average of treatment effects where some weights can be **negative**. This means the TWFE estimate can be negative even when all unit-level effects are positive.

**Root cause:** Already-treated units serve as controls for later-treated units, and the "effect" is differenced relative to these already-treated units.

## Callaway and Sant'Anna (2021)

Estimates group-time ATTs — the effect for group g (units first treated at time g) at time t.

```python
# Python: csdid package (or use R's did package)
# R implementation (more mature):
# library(did)
# result <- att_gt(
#     yname = "y",
#     tname = "year",
#     idname = "unit_id",
#     gname = "first_treat",  # 0 for never-treated
#     data = df,
#     control_group = "nevertreated",  # or "notyettreated"
#     est_method = "dr"  # doubly robust
# )
# agg_result <- aggte(result, type = "dynamic")  # aggregate to event-time
```

**Key choices:**
- **Control group**: "never-treated" (cleaner, but requires never-treated units) vs "not-yet-treated" (more comparison units, weaker assumption)
- **Estimation method**: "dr" (doubly robust — recommended), "ipw", "reg"
- **Aggregation**: "dynamic" (event study), "group" (by cohort), "calendar" (by time period), "simple" (overall)

## Sun and Abraham (2021)

Interaction-weighted estimator that corrects TWFE with heterogeneous effects:

```python
# R implementation:
# library(fixest)
# result <- feols(
#     y ~ sunab(first_treat, year) | unit + year,
#     data = df,
#     cluster = ~state
# )
# The sunab() function handles the interaction-weighting automatically
```

## de Chaisemartin and D'Haultfoeuille (2020)

```python
# R: did_multiplegt package
# Estimates treatment effect under minimal assumptions
# Particularly useful when treatment can turn on and off
```

## Which Method to Use

| Feature | Callaway-Sant'Anna | Sun-Abraham | de Chaisemartin-D'H |
|---------|-------------------|-------------|---------------------|
| Treatment reversals | No | No | Yes |
| Covariates | Time-varying OK | Baseline only | Limited |
| Aggregation flexibility | High (group, time, event) | Event study | Limited |
| Implementation maturity | R: excellent; Python: developing | R (fixest): excellent | R: good |
| Never-treated required | No (not-yet-treated option) | Recommended | No |

## BJS24 and Related Extensions

Borusyak, Jaravel, and Spiess (2024) offer an imputation-based estimator via the `did_imputation` package in R. Like C-SA and S-A, it avoids negative weighting and supports event-study aggregation. Particularly suited when there are many cohorts and the parallel trends assumption holds unconditionally.

## Bacon Decomposition

Before switching methods, decompose the TWFE estimate to understand what is driving it:

```r
# R: bacondecomp package
library(bacondecomp)
df_bacon <- bacon(y ~ treated, data = df, id_var = "unit", time_var = "year")
# Shows the weights each 2x2 comparison receives in the TWFE estimate
# Negative-weight comparisons (already-treated as controls) are the concern
```

The decomposition is diagnostic — if nearly all weight is on clean comparisons, TWFE may be fine. If substantial weight goes to contaminated comparisons, switch to C-SA or S-A.

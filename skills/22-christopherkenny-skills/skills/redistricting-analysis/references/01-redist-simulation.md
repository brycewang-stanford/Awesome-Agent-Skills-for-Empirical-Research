# redist — Map Objects, Simulation, and Diagnostics

## Overview

`redist` is the core simulation package. It creates `redist_map` objects that define the redistricting problem, runs SMC or MCMC algorithms to sample an ensemble of valid plans, and provides diagnostics to assess convergence. Start here for any simulation task.

## Creating a `redist_map`

```r
map <- redist_map(shp, pop_col = 'pop', ndists = 8, adj = NULL,
  pop_tol = 0.005, total_pop = NULL)
```

| Parameter | Description |
|-----------|-------------|
| `shp` | `sf` object with one row per precinct |
| `pop_col` | Column name for population (string) |
| `ndists` | Number of districts to draw |
| `adj` | Pre-built `adj` object; computed from `shp` if `NULL` |
| `pop_tol` | Population deviation tolerance (0.005 = ±0.5%) |

```r
# Typical setup
library(redistverse)
map <- alarm_50state_map('MD')          # pre-built map with adj, pop, elections
map <- set_pop_tol(map, 0.005)          # adjust tolerance after construction
get_pop_tol(map)                        # retrieve current tolerance
```

**Subsetting**: `map[map$county == "Baltimore City", ]` — `redist_map` subsets preserve the `adj`, `ndists`, and `pop_tol` metadata.

## Simulation Algorithms

### `redist_smc()` — Sequential Monte Carlo (recommended)

Builds plans district-by-district by drawing random spanning trees and cutting edges. Most efficient for large ensembles; produces approximately independent draws.

```r
plans <- redist_smc(
  map,
  nsims = 5000,    # number of plans to sample
  runs = 2,       # independent runs (for convergence checking)
  compactness = 1,      # spanning-tree compactness weight (0 = off, 1 = default)
  constraints = NULL,   # redist_constr object (see 02-redist-constraints.md)
  counties = map$county,  # encourages keeping counties whole (soft)
  pop_temper = 0,       # population temperament for relaxed balance (advanced)
  seq_alpha = 0.5,     # resampling threshold
  verbose = TRUE
)
```

### `redist_mergesplit()` — Merge-split MCMC

Merges two adjacent districts, then splits the merged region. Covers the same distribution as SMC but produces correlated draws; requires more samples and thinning.

```r
plans <- redist_mergesplit(
  map,
  nsims = 50000,
  warmup = 10000,   # burn-in iterations
  thin = 100,     # keep every Nth draw
  init_plan = NULL,  # starting plan (uses random if NULL)
  constraints = constr,
  compactness = 1,
  verbose = TRUE
)
```

### `redist_flip()` — Flip MCMC

Reassigns individual precincts along district boundaries. Slower mixing on large maps; useful for small problems or local exploration.

```r
plans <- redist_flip(
  map,
  nsims = 10000,
  constraints = constr,
  init_plan = NULL,
  verbose = TRUE
)
```

## `redist_plans` Object

The output of any simulation function. A tibble with `ndists × nsims` rows (plus rows for reference plans), one row per district per plan.

```r
nrow(plans)          # ndists * (nsims + n_reference_plans)
ncol(plans)          # district-level metrics added via mutate()

# Access the plan assignment matrix (precincts × plans)
mat <- get_plans_matrix(plans)   # integer matrix, 0-indexed districts

# Access which plan each row belongs to
plans$draw           # factor with plan IDs

# Subset to a single plan
subset_sampled(plans, draws = 1:10)   # first 10 sampled plans
subset_ref(plans)                      # reference plans only (enacted, etc.)
```

## Adding Reference Plans

Add an enacted or proposed plan for comparison. It appears as a named reference draw in the ensemble.

```r
# From an integer vector (precinct → district assignment, 1-indexed)
plans <- alarm_add_plan(plans, ref_plan = map$cd_2020, map = map, name = 'Enacted')

# From a BAF data frame (see 15-baf.md)
plans <- alarm_add_plan(plans, ref_plan = baf_df, map = map, name = 'Proposed')

# From an sf object with district polygons
plans <- alarm_add_plan(plans, ref_plan = districts_sf, map = map, name = 'Alt')
```

## Diagnostics and Validation

Run `summary()` immediately after simulation to check convergence before computing metrics.

```r
summary(plans)
```

Key output fields:

| Field | What to look for |
|-------|-----------------|
| `r_hat` | Gelman-Rubin statistic; target **< 1.05** per district split |
| `ess_pct` | Effective sample size as % of `nsims`; should stay substantial |
| `accept_pct` | MCMC acceptance rate; very low (<1%) signals over-constrained problem |
| `diversity` | Pairwise VI distance range; 80% range should span ~0.5–0.8 |

```r
# Validate with comprehensive diagnostics plot
validate_analysis(plans, map)

# Visual inspection of individual plans
redist.plot.plans(plans, draws = 1:4, shp = map)

# Distribution of a metric with enacted plan highlighted
hist(plans, ndv / (ndv + nrv), bins = 50)     # partisan vote share
plot(plans, plan_parity(pl()), style = 'box')  # population deviation
```

## Common Patterns

```r
# Standard two-run SMC workflow
plans <- redist_smc(map, nsims = 5000, runs = 2,
                    constraints = constr, counties = map$county)
summary(plans)

# Add enacted plan and score
plans <- alarm_add_plan(plans, map$cd_2020, map, 'Enacted')
plans <- plans |>
  mutate(
    egap = part_egap(pl(), ndv, nrv),
    splits = splits_admin(pl(), map, map$county),
    polsby = comp_polsby(pl(), map)
  )

# Compare enacted to simulated distribution
plans |>
  filter(draw != 'Enacted') |>
  ggplot(aes(egap)) +
  geom_histogram() +
  geom_vline(data = filter(plans, draw == 'Enacted'), aes(xintercept = egap))
```

## See Also

- Constraints: [02-redist-constraints.md](02-redist-constraints.md)
- Advanced algorithms (enumpart, shortburst): [03-redist-advanced.md](03-redist-advanced.md)
- Metrics: [04-redistmetrics-compactness.md](04-redistmetrics-compactness.md), [05-redistmetrics-partisan.md](05-redistmetrics-partisan.md)

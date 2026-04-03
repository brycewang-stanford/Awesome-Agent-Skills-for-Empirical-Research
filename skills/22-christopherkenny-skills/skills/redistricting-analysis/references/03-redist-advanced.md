# redist — Advanced Algorithms

## Overview

Beyond the standard SMC and merge-split workflows, `redist` provides exact enumeration for small problems, short-burst heuristic optimization for finding extreme plans, and cycle-walk MCMC. Use these when you need to find optimal plans, exhaustively characterize small maps, or explore the Pareto frontier across competing criteria.

## `redist_enumpart()` — Exact Enumeration

Uses zero-suppressed binary decision diagrams (ZDDs) to enumerate all valid plans. Practical only for maps with fewer than ~70 precincts. Returns either all valid plans or a uniform sample from them.

```r
plans <- redist_enumpart(
  map,
  ndists = map$ndists,
  pop_tol = 0.05,
  save_all = TRUE    # FALSE to uniform-sample instead of returning all
)
```

This is the only algorithm that can compute exact statistics (e.g., exact seat probabilities) because it covers the full space of valid plans.

## `redist_shortburst()` — Short-Burst Optimization

Finds extreme plans by running short MCMC bursts and keeping the best plan seen. Useful for:
- Finding the most/least gerrymandered plan (given a metric)
- Characterizing the Pareto frontier across two criteria
- Producing extreme examples for illustration

```r
plans_opt <- redist_shortburst(
  map,
  score_fn = function(plans, map) part_egap(plans, map$ndv, map$nrv),
  max_bursts = 200,
  burst_size = 10,       # MCMC steps per burst
  maximize = TRUE,     # TRUE to maximize, FALSE to minimize
  constraints = constr,
  verbose = TRUE
)
```

The `score_fn` receives the `redist_plans` object and `map`, and should return a numeric vector (one value per plan). Any `redistmetrics` function works.

### Pareto Frontier

To trace the tradeoff between two metrics (e.g., compactness vs. partisan fairness):

```r
# Use the built-in frontier approach with redist_shortburst
# Run multiple optimizations with varying weights between objectives
```

## `redist_cyclewalk()` — Cycle-Walk MCMC

A variant MCMC that adds random cycles into spanning trees before cutting, increasing diversity in the generated plans. Can be useful when merge-split mixes poorly.

```r
plans <- redist_cyclewalk(
  map,
  nsims = 10000,
  constraints = constr,
  init_plan = NULL,
  verbose = TRUE
)
```

## `init_particles` — Partial-State Simulations

For states where some districts are predetermined (e.g., island districts that must include specific precincts), supply an initial particle set to SMC that fixes the predetermined structure.

```r
# Example: Hawaii has two focal regions that must anchor the two districts
# Precompute which precincts must go in each region, then pass to SMC
plans <- redist_smc(
  map,
  nsims = 5000,
  init_particles = my_particle_list   # list of partial plan assignments
)
```

This is used in the ALARM 50-state simulations for states with geographic constraints (islands, disconnected regions).

## See Also

- Standard simulation: [01-redist-simulation.md](01-redist-simulation.md)
- Constraints for scoring functions: [02-redist-constraints.md](02-redist-constraints.md)
- Metrics usable as `score_fn`: [04-redistmetrics-compactness.md](04-redistmetrics-compactness.md), [05-redistmetrics-partisan.md](05-redistmetrics-partisan.md)

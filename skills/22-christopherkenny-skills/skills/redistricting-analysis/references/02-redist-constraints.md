# redist — Constraints

## Overview

Constraints shape the target distribution of simulated plans. Hard constraints (population balance, contiguity) are enforced by construction; soft constraints are penalties applied as sampling weights. Build a constraint object with `redist_constr()`, then pipe in `add_constr_*()` calls.

## Creating a Constraint Object

```r
constr <- redist_constr(map)
```

Pass `constr` to `redist_smc()`, `redist_mergesplit()`, or `redist_flip()` via the `constraints` argument.

## Hard Constraints

These are automatically enforced and do not need to be added to `redist_constr`:

| Constraint | How enforced |
|-----------|-------------|
| **Contiguity** | Guaranteed by tree-based construction in SMC/merge-split |
| **Population balance** | Controlled by `pop_tol` in `redist_map` (see `set_pop_tol()`) |

## Soft Constraints (Sampling Penalties)

All `add_constr_*()` functions take `strength` as their primary tuning parameter. Higher strength = stronger penalty = stronger pull toward the constraint target. Start with moderate values and verify outcomes in the simulated ensemble.

### County / Administrative Splits

```r
constr <- constr |>
  add_constr_splits(
    strength = 1.5,         # penalty per additional split (log scale)
    admin = map$county   # column defining administrative units
  )
```

Also available:
```r
add_constr_multisplits(strength, admin)   # penalizes splitting a unit into 3+ pieces
add_constr_total_splits(strength, admin)  # penalizes total number of district pieces
```

### Minority Representation (VRA Compliance)

Hinge constraints apply a penalty *below* the target, and are flat (no penalty) above it. Use to encourage majority-minority districts without capping representation.

```r
constr <- constr |>
  add_constr_grp_hinge(
    strength = 30,
    group_pop = map$pop_black,    # minority population column
    total_pop = map$pop,
    tgts_group = c(0.55)           # target: ≥55% Black VAP in one district
  )
```

Inverse hinge — penalizes *above* the target (useful to avoid packing):
```r
constr <- constr |>
  add_constr_grp_inv_hinge(
    strength = 15,
    group_pop = map$pop_black,
    total_pop = map$pop,
    tgts_group = c(0.65)           # penalize if any district exceeds 65%
  )
```

### Compactness (Polsby-Popper)

Adds a Polsby-Popper compactness penalty (in addition to the built-in spanning-tree compactness from the `compactness` parameter in `redist_smc`).

```r
constr <- constr |>
  add_constr_polsby(
    strength = 3,
    perim_df = prep_perims(map)   # precomputed perimeter data
  )
```

### Status Quo / Incumbent Proximity

Penalizes departure from a reference plan. Useful for studying how much maps can deviate from the status quo.

```r
constr <- constr |>
  add_constr_status_quo(
    strength = 0.05,
    plan = map$cd_2020    # reference plan (integer vector)
  )
```

Avoid pairing incumbents in the same district:
```r
constr <- constr |>
  add_constr_incumbency(
    strength = 100,
    incumbents = c(3, 7, 12)   # precinct indices of incumbents
  )
```

### Competitiveness

Encourages more competitive districts (those near 50–50 partisan split):

```r
constr <- constr |>
  add_constr_compet(
    strength = 5,
    rvote = map$nrv,
    dvote = map$ndv
  )
```

### Custom Constraint

Define any scoring function of a plan assignment vector:

```r
my_score <- function(plan, map) {
  # plan: integer vector of district assignments (1-indexed)
  # return: numeric scalar (higher = more desirable)
  -sum(plan != map$cd_2020)   # e.g., minimize precincts moved from status quo
}

constr <- constr |>
  add_constr_custom(
    strength = 1,
    fn = my_score,
    map = map
  )
```

## Full Constraint Example

```r
library(redistverse)
map <- alarm_50state_map('NC')

constr <- redist_constr(map) |>
  add_constr_splits(strength = 1.5, admin = map$county) |>
  add_constr_grp_hinge(strength = 30, group_pop = map$pop_black,
                       total_pop = map$pop, tgts_group = c(0.55))

plans <- redist_smc(map, nsims = 5000, runs = 2,
                    compactness = 1,
                    constraints = constr)
```

## Tuning Tips

- **Verify constraint outcomes in the ensemble**, not just trust the strength value. After simulation, compute the relevant metric (e.g., `splits_admin()`, `group_frac()`) and check the distribution looks as intended.
- **Very low acceptance rates** in MCMC (<1%) or severe ESS loss in SMC indicates over-constrained problem. Reduce `strength` values.
- **Strength interactions**: Multiple soft constraints can interact unexpectedly. Add them incrementally and check diagnostics after each addition.
- The `counties` argument in `redist_smc()` provides a built-in soft county-preservation mechanism and is often sufficient without `add_constr_splits`.

## See Also

- Simulation and diagnostics: [01-redist-simulation.md](01-redist-simulation.md)
- Group fraction metrics: [06-redistmetrics-other.md](06-redistmetrics-other.md)
- Polsby-Popper metric: [04-redistmetrics-compactness.md](04-redistmetrics-compactness.md)

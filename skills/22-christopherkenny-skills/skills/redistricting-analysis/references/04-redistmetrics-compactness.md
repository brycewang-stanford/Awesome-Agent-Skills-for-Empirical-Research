# redistmetrics — Compactness Metrics

## Overview

`redistmetrics` computes plan-level and district-level metrics for evaluating redistricting plans. All functions work with integer vectors, matrices, or `redist_plans` objects. In `mutate()` pipelines, use `pl()` as the pronoun for the plan assignment.

## The `pl()` Pronoun

Inside `mutate()` on a `redist_plans` object, `pl()` returns the current plan assignments. This is the standard way to compute metrics across an ensemble:

```r
plans <- plans |>
  mutate(
    polsby = comp_polsby(pl(), map),   # district-level (vector per plan)
    fk = comp_frac_kept(pl(), map) # plan-level scalar per plan
  )
```

## Precomputing Perimeters

Geometric compactness measures (Polsby-Popper, Schwartzberg) require perimeter calculations. Precompute once and pass the result to all geometric metrics:

```r
perim_df <- prep_perims(map)    # returns a data frame; expensive to compute

plans <- plans |>
  mutate(
    polsby = comp_polsby(pl(), map, perim_df = perim_df),
    schw = comp_schwartzberg(pl(), map, perim_df = perim_df)
  )
```

## Geometric Compactness

These measure the shape of district boundaries. Higher = more compact.

### Polsby-Popper

Most commonly used. Ratio of district area to the area of a circle with the same perimeter. Range: (0, 1].

```r
# District-level (one value per district per plan)
pp <- comp_polsby(plans, shp = map, perim_df = perim_df)

# Or in mutate:
plans <- plans |> mutate(polsby = comp_polsby(pl(), map, perim_df))
```

### Reock

Ratio of district area to the area of the smallest enclosing circle. Range: (0, 1].

```r
plans <- plans |> mutate(reock = comp_reock(pl(), map))
```

### Convex Hull

Ratio of district area to the area of its convex hull. Range: (0, 1].

```r
plans <- plans |> mutate(cvx = comp_convex_hull(pl(), map))
```

### Schwartzberg

Ratio of district perimeter to the perimeter of a circle with the same area. Range: ≥ 1 (lower = more compact).

```r
plans <- plans |> mutate(schw = comp_schwartzberg(pl(), map, perim_df))
```

## Graph-Based Compactness

These use the adjacency graph rather than geometry. Faster to compute and useful when geometric data is unavailable.

### Fraction of Edges Kept (`comp_frac_kept`)

Proportion of precinct-level adjacency edges that are internal to a district (not cut). Plan-level scalar. Higher = more compact.

```r
plans <- plans |> mutate(frac_kept = comp_frac_kept(pl(), map))
```

This is the compactness measure built into `redist_smc` via the `compactness` parameter.

### Log Spanning Trees (`comp_log_st`)

Log of the number of spanning trees within each district. Related to the probability of the district being sampled. Useful for weighting analyses.

```r
plans <- plans |> mutate(log_st = comp_log_st(pl(), map))
```

## Summary Statistics

Compactness metrics return district-level vectors. To get plan-level summaries for comparing against the enacted plan:

```r
plans <- plans |>
  mutate(
    polsby = comp_polsby(pl(), map, perim_df),
    polsby_min = min(polsby),    # worst district in each plan
    polsby_mean = mean(polsby)    # average across districts
  )
```

Or use `group_by(draw)` if working outside `mutate()`:

```r
plans |>
  group_by(draw) |>
  summarize(min_polsby = min(polsby), mean_polsby = mean(polsby))
```

## Comparison Table

| Function | Type | Input needed | Range | Higher = |
|----------|------|-------------|-------|---------|
| `comp_polsby()` | geometric | `perim_df` | (0, 1] | more compact |
| `comp_reock()` | geometric | geometry | (0, 1] | more compact |
| `comp_convex_hull()` | geometric | geometry | (0, 1] | more compact |
| `comp_schwartzberg()` | geometric | `perim_df` | ≥ 1 | less compact |
| `comp_frac_kept()` | graph | adjacency | (0, 1] | more compact |
| `comp_log_st()` | graph | adjacency | unbounded | more connected |

## See Also

- Add compactness as a soft constraint: [02-redist-constraints.md](02-redist-constraints.md) (`add_constr_polsby`)
- Partisan metrics: [05-redistmetrics-partisan.md](05-redistmetrics-partisan.md)
- Other metrics (splits, segregation): [06-redistmetrics-other.md](06-redistmetrics-other.md)

# redistmetrics — Splits, Population, Minority Representation, and Other Metrics

## Overview

This file covers the non-compactness, non-partisan metrics in `redistmetrics`: administrative splits, population parity, minority group representation, segregation, competitiveness, and incumbent pairings.

## Population Parity

Measures how evenly population is distributed across districts. Usually the first metric to check after simulation.

```r
plans <- plans |>
  mutate(parity = plan_parity(pl(), map))
# Returns max absolute deviation from equal population, as a fraction
# e.g., 0.004 means worst district is 0.4% from ideal
```

## Administrative Splits

### County Splits

```r
# Number of counties split into 2+ pieces
plans <- plans |>
  mutate(county_splits = splits_admin(pl(), map, admin = map$county))

# Number of counties split into 3+ pieces
plans <- plans |>
  mutate(county_multi = splits_multi(pl(), map, admin = map$county))

# Total number of county-district pieces (sum of pieces across all counties)
plans <- plans |>
  mutate(county_total = splits_total(pl(), map, admin = map$county))
```

The `admin` argument accepts any column that identifies administrative units (counties, municipalities, school districts, etc.).

```r
# Municipal splits
plans <- plans |>
  mutate(muni_splits = splits_admin(pl(), map, admin = map$municipality))
```

## Minority Group Representation

### Group Fraction

Fraction of a minority group's population in each district. Returns district-level values.

```r
plans <- plans |>
  mutate(
    bvap_frac = group_frac(pl(), map$pop_black, map$pop),       # Black share
    hvap_frac = group_frac(pl(), map$pop_hisp, map$pop),        # Hispanic share
    cvap_frac = group_frac(pl(), map$pop_black + map$pop_hisp,  # Combined BCVAP
                           map$pop)
  )
```

### Minority Opportunity Districts

Count districts exceeding a threshold:

```r
plans <- plans |>
  mutate(
    n_majority_black = sum(group_frac(pl(), map$pop_black, map$pop) > 0.50),
    n_above_40pct = sum(group_frac(pl(), map$pop_black, map$pop) > 0.40)
  )
```

### BVAP and HVAP Columns (ALARM datasets)

The ALARM pre-built maps include:
- `pop_black`, `pop_hisp`, `pop_asian`, `pop_aian`, `pop_nhpi`, `pop_white` — total population by race
- `pop_vap` — voting-age population
- `pop_bvap` — Black voting-age population (where available)

## Segregation

Dissimilarity index between two groups across districts. Ranges 0–1; higher = more segregated.

```r
plans <- plans |>
  mutate(
    seg_bw = seg_dissim(pl(), map,
                        group_pop = map$pop_black,
                        total_pop = map$pop)
  )
```

## Competitiveness

### Talisman Competitiveness

Measures the fraction of districts where the outcome is uncertain (close to 50–50). Higher = more competitive map.

```r
plans <- plans |>
  mutate(compet = compet_talisman(pl(), map$ndv, map$nrv))
```

## Incumbent Pairings

Counts how many pairs of incumbents are placed in the same district (forced to run against each other).

```r
# incumbents: integer vector of precinct indices (0-indexed) where incumbents live
incumbents <- c(42, 107, 318)   # example precinct indices

plans <- plans |>
  mutate(inc_pairings = inc_pairs(pl(), incumbents))
```

## Combining Metrics: Full Scoring Pipeline

```r
perim_df <- prep_perims(map)

plans <- plans |>
  mutate(
    # Population
    parity = plan_parity(pl(), map),
    # Splits
    county_splits = splits_admin(pl(), map, map$county),
    # Compactness
    polsby = comp_polsby(pl(), map, perim_df),
    polsby_min = min(polsby),
    # Partisan
    egap = part_egap(pl(), map$ndv, map$nrv),
    # Minority representation
    bvap_max = max(group_frac(pl(), map$pop_black, map$pop))
  )
```

## Reference Plan Comparison

After adding the enacted plan with `alarm_add_plan()`, compare each metric:

```r
# Where does the enacted plan fall in the simulated distribution?
plans |>
  group_by(draw == 'Enacted') |>
  summarize(
    mean_egap = mean(egap),
    mean_splits = mean(county_splits),
    mean_polsby = mean(polsby_min)
  )

# Rank of enacted plan (percentile)
sim_egaps <- plans |> filter(draw != 'Enacted') |> pull(egap)
enacted_egap <- plans |> filter(draw == 'Enacted') |> pull(egap) |> unique()
mean(sim_egaps < enacted_egap)   # fraction of simulated plans with lower egap
```

## See Also

- Compactness metrics: [04-redistmetrics-compactness.md](04-redistmetrics-compactness.md)
- Partisan metrics: [05-redistmetrics-partisan.md](05-redistmetrics-partisan.md)
- VRA constraints (hinge): [02-redist-constraints.md](02-redist-constraints.md)

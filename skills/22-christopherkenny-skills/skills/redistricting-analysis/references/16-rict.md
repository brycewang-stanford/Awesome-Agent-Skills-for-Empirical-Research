# rict — Redistricting Summary Tables

## Overview

`rict` generates formatted `gt` tables summarizing redistricting plans — population parity, demographics, election results, compactness, splits, and contiguity — designed for inclusion in reports and court filings. All functions accept a `redist_map` or `sf` object plus a plan assignment and return a `gt::gt_tbl` by default, or a plain tibble when `as_gt = FALSE`.

## Core Table Functions

All functions share the same basic signature:

```r
rict_*(map, plan, ..., as_gt = TRUE)
```

| Function | What it shows |
|----------|--------------|
| `rict_population()` | Population per district, deviation from ideal, % deviation |
| `rict_demographics()` | Total pop and VAP by race/ethnicity (White, Black, Hispanic, Asian, AIAN, NHPI, Other, Two+) |
| `rict_elections()` | Democratic vote shares across electoral contests by district |
| `rict_compactness()` | Polsby-Popper, Schwartzberg, Reock, Convex Hull scores per district |
| `rict_splits()` | Number of counties (or other admin units) split by the plan |
| `rict_contiguity()` | Number of disconnected geographic pieces per district |
| `rict_boundary()` | Precincts along the boundary between two specified districts |
| `rict_component()` | Population by administrative unit within each district |

### Examples

```r
library(rict)
library(redistverse)

map <- alarm_50state_map('MD')

# Population table for the enacted plan
rict_population(map, plan = map$cd_2020)

# Demographics table
rict_demographics(map, plan = map$cd_2020)

# Compactness (uses Polsby-Popper, Schwartzberg, Reock, Convex Hull by default)
rict_compactness(map, plan = map$cd_2020)

# County splits
rict_splits(map, plan = map$cd_2020, admin = map$county)

# As a tibble instead of gt table (for further manipulation)
pop_tbl <- rict_population(map, plan = map$cd_2020, as_gt = FALSE)
```

## The Main `rict()` Function

`rict()` produces a combined summary from a `redist_plans` object, covering population, demographics, and elections in one table:

```r
plans <- alarm_50state_plans('MD')
plans <- alarm_add_plan(plans, map$cd_2020, map, 'Enacted')

# Full summary table for the enacted plan
rict(plans, plan = 'Enacted')

# Summary for a specific simulated plan
rict(plans, plan = 1)
```

## Adding Maps to Tables

`gt_plot_sf()` embeds district geometry thumbnails directly in a gt table:

```r
rict_demographics(map, plan = map$cd_2020) |>
  gt_plot_sf(name = 'geometry', height = 80)
```

`gt_plot_compactness()` embeds compactness visualizations:

```r
rict_compactness(map, plan = map$cd_2020) |>
  gt_plot_compactness()
```

## Partisan Styling

Apply a red-blue partisan color scale to election columns:

```r
rict_elections(map, plan = map$cd_2020) |>
  data_color_party()
```

## Standalone Compactness Plots

For a district-level visual of compactness geometry (outside of a table):

```r
plot_compactness(
  shp = map,
  plan = map$cd_2020,
  measure = 'Polsby Popper'   # or 'Reock', 'Convex Hull', 'Schwartzberg'
)
# Returns a list of ggplot2 objects, one per district
```

## Extracting Data from a gt Table

```r
tab <- rict_demographics(map, plan = map$cd_2020)
df  <- gt_get_data(tab)   # retrieve the underlying tibble
```

## See Also

- Simulation and plans: [01-redist-simulation.md](01-redist-simulation.md)
- Pre-built data: [12-alarmdata.md](12-alarmdata.md)
- Compactness metrics: [04-redistmetrics-compactness.md](04-redistmetrics-compactness.md)

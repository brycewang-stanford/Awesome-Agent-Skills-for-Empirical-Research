# redistio — Interactive Redistricting Interface

## Overview

`redistio` provides a Shiny-based point-and-click interface for drawing and editing redistricting plans, and a separate interactive editor for adjacency graphs. It integrates with `redist_map` and `redist_plans` objects so that plans drawn in the UI can be immediately compared against a simulated ensemble.

## Drawing Plans: `draw()`

Launches an interactive map where users can click precincts to assign them to districts. Works with a bare `sf` object for simple drawing, or a `redist_map` for algorithmic assistance and live statistical feedback.

```r
library(redistio)
library(redistverse)

map <- alarm_50state_map('MD')
plans <- alarm_50state_plans('MD')

# Simple interactive drawing (sf only)
draw(shp = map)

# With simulated ensemble for live comparison
draw(
  shp = map,
  plans = plans,
  init_plan = map$cd_2020,    # starting plan shown in the UI
  pop_col = 'pop',
  pop_tol = 0.005,
  split_cols = 'county',
  elect_cols = c('ndv', 'nrv'),
  demog_cols = c('pop_black', 'pop_hisp')
)
```

### What the UI shows

- **Live population parity** — deviation from ideal as you draw
- **Compactness and splits** — updated after each precinct assignment
- **Partisan metrics** — efficiency gap, seat share, compared against the simulated ensemble
- **Plans browser** — browse pre-computed plans and adopt one as your starting point
- **Algorithmic help** — when `redist_map` is supplied, can run short-burst optimization from within the UI

### Exporting from the UI

The UI can write the drawn plan to a file (BAF or shapefile) via paths set in `redistio_options()`. It also returns the plan assignment vector when the session ends.

## Editing Adjacency: `adj_editor()`

A visual tool for correcting adjacency graphs before simulation. Displays the precinct map with the adjacency graph overlaid; click edges to add or remove them.

```r
# Open the adjacency editor for Maryland
adj_editor(
  shp = map,
  adj = map$adj[[1]],      # existing adjacency list
  init_plan = map$county         # color precincts by county for context
)
# Returns the corrected adjacency list when the session closes
```

Useful for:
- Removing cross-water edges (alternative to `seam_rip()` when the seam is irregular)
- Adding missing edges between non-touching but functionally adjacent precincts
- Visual verification after programmatic adjacency edits

## Adding Plan Statistics for Comparison

Before launching `draw()` with an ensemble, add summary statistics to the plans so the UI can display real-time comparisons:

```r
plans <- add_plan_stats(
  plans = plans,
  ref_plan = map$cd_2020,
  map = map,
  name = 'Enacted'
)

draw(shp = map, plans = plans, init_plan = map$cd_2020)
```

## Configuring the Interface

`redistio_options()` controls which panels are shown, the map style, color scales, and output paths:

```r
opts <- redistio_options(
  show_elections = TRUE,
  show_demographics = TRUE,
  show_algorithms = TRUE,   # enable short-burst optimization panel
  show_plans = TRUE,   # enable plans browser
  map_tiles = 'CartoDB.Positron',
  out_path = '~/redistricting/my_plan.csv'  # where to save drawn plan
)

draw(shp = map, plans = plans, opts = opts)
```

## Automatic Column Detection

`redistio` can guess which columns contain elections, demographics, and administrative units without manual specification:

```r
guess_elections(map)         # identifies ndv, nrv, and election-year columns
guesstimate_demographics(map) # identifies pop_black, pop_hisp, vap_* columns
guess_admins(map)            # identifies county, vtd, and similar columns
```

These are called automatically if `elect_cols`, `demog_cols`, and `split_cols` are not provided to `draw()`.

## Custom Hover Tooltips

Override the default precinct tooltip shown on hover:

```r
draw(
  shp = map,
  hover_fn = function(shp) {
    hover_precinct(shp,
      pop = starts_with('pop'),
      elections = starts_with('ndv') | starts_with('nrv'))
  }
)
```

## See Also

- Adjacency graph construction and repair (programmatic): [09-geomander-adjacency.md](09-geomander-adjacency.md)
- Simulation workflow and `redist_plans`: [01-redist-simulation.md](01-redist-simulation.md)
- Summary tables for drawn plans: [16-rict.md](16-rict.md)
- Pre-built Maryland data: [12-alarmdata.md](12-alarmdata.md)

# alarmdata — Pre-built Redistricting Datasets

## Overview

`alarmdata` provides access to the ALARM Project's pre-compiled redistricting datasets hosted on Harvard Dataverse. These include precinct-level shapefiles, 2020 Census demographics, VEST election returns, and pre-simulated ensembles of 5,000 plans for all 50 U.S. states. Using these saves hours of data wrangling for common redistricting analyses.

## Loading Pre-built Map Data

```r
library(redistverse)

# Download map for a state (returns redist_map object)
map <- alarm_50state_map('MD')   # Maryland — use 2-letter postal code
map <- alarm_50state_map('NC')
map <- alarm_50state_map('TX')
```

The returned `redist_map` includes:
- Precinct-level `sf` geometry
- Pre-built adjacency graph (`adj` column)
- Population and demographic variables
- Election return variables
- Enacted district assignment (e.g., `cd_2020` for congressional)

## Standard Column Names

| Column | Description |
|--------|-------------|
| `pop` | 2020 Census total population |
| `pop_white` | Non-Hispanic White population |
| `pop_black` | Black/African American population |
| `pop_hisp` | Hispanic/Latino population |
| `pop_asian` | Asian population |
| `pop_aian` | American Indian/Alaska Native |
| `pop_nhpi` | Native Hawaiian/Pacific Islander |
| `pop_other` | Other/multiracial |
| `pop_vap` | Voting-age population (18+) |
| `pop_bvap` | Black voting-age population |
| `ndv` | Composite Democratic votes (across recent elections) |
| `nrv` | Composite Republican votes |
| `cd_2020` | Enacted congressional district assignment |
| `state_sen_2020` | Enacted state senate assignment (where available) |
| `state_leg_2020` | Enacted state house assignment (where available) |
| `adj` | Pre-built adjacency list |
| `geometry` | Precinct polygon geometry (sf) |

Individual election columns follow patterns like `pre_20_dem_bid` (2020 presidential, Democratic, Biden).

## Loading Pre-simulated Plan Ensembles

Download the ALARM Project's pre-computed ensemble of 5,000 plans:

```r
plans <- alarm_50state_plans('MD')    # returns redist_plans with 5000 simulated plans

# Plans already include key metrics:
# draw, district, pop_dev, comp_edge, etc.
names(plans)
```

Download statistics only (no full plan matrix, smaller download):

```r
stats <- alarm_50state_stats('MD')
```

## Adding Reference Plans

Compare an enacted or proposed plan to the simulated ensemble:

```r
# From an integer vector (precinct → district, 1-indexed)
plans <- alarm_add_plan(plans, ref_plan = map$cd_2020, map = map, name = 'Enacted')

# From a BAF data frame (GEOID → district mapping)
plans <- alarm_add_plan(plans, ref_plan = baf_df, map = map, name = 'Proposed')

# From an sf object with district polygons
plans <- alarm_add_plan(plans, ref_plan = district_sf, map = map, name = 'Commission')
```

## Caching

By default, downloaded files go to a temporary directory and are not retained between sessions. Enable persistent caching:

```r
# Enable caching (survives R sessions)
options(alarm.use_cache = TRUE)

# Check cache size
alarm_cache_size()

# Clear the cache
alarm_cache_clear()
```

The cache location is managed by `rappdirs` (platform-appropriate user data directory).

## Typical Full Workflow

```r
library(redistverse)

# 1. Load data
map <- alarm_50state_map('MD')
plans <- alarm_50state_plans('MD')

# 2. Add enacted plan for comparison
plans <- alarm_add_plan(plans, map$cd_2020, map, 'Enacted')

# 3. Compute additional metrics
plans <- plans |>
  mutate(
    egap = part_egap(pl(), ndv, nrv),
    splits = splits_admin(pl(), map, map$county)
  )

# 4. Summarize
plans |>
  filter(draw != 'Enacted') |>
  summarize(
    mean_egap = mean(egap),
    pct_enacted = mean(egap < filter(plans, draw == 'Enacted')$egap[[1]])
  )
```

## State Coverage

All 50 U.S. states for both congressional (`ndists` = state's delegation) and, for most states, state legislative chambers. Use `alarm_50state_map()` with the postal code. The dataset uses 2020 Census geography.

## See Also

- Census data (when building your own map): [13-pl94171.md](13-pl94171.md)
- Block assignment file downloads: [15-baf.md](15-baf.md)
- Simulation workflow: [01-redist-simulation.md](01-redist-simulation.md)

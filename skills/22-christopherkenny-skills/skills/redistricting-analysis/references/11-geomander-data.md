# geomander — Data Downloads

## Overview

`geomander` includes functions for downloading pre-processed election and geographic datasets from several sources: VEST (Voting and Election Science Team), the ALARM Project, Dave's Redistricting App (DRA), and the Harvard Election Data Archive (HEDA). These are useful when you need election data for states not yet in `alarmdata` or when working with historical elections.

## VEST Election Data

VEST provides precinct-level election returns for many states and election cycles, harmonized to a consistent format.

```r
library(geomander)

# List available states
vest_states()    # returns a tibble of state/year combinations available

# Download VEST data for a state and year
vest_data <- get_vest(state = 'VA', year = 2018)
# Returns an sf object with precinct geometry + election columns
```

Column naming convention: `G{YY}{OFFICE}{PARTY}{CANDIDATE}` e.g., `G18USSRKAV` = 2018 US Senate, Republican, Kavanaugh.

```r
# Clean VEST column names to a standardized format
cleaned <- clean_vest(vest_data)
```

## ALARM Project Data

Download ALARM Project datasets (alternative to the `alarmdata` package functions):

```r
# List available states in the ALARM dataset
alarm_states()   # tibble of states and what's available

# Download an ALARM dataset
alarm_data <- get_alarm(state = 'MD')
# Returns a list with map and plans components
```

Note: For most work with ALARM data, `alarmdata::alarm_50state_map()` and `alarm_50state_plans()` are more convenient (see [12-alarmdata.md](12-alarmdata.md)).

## Dave's Redistricting App (DRA)

Import and export plans to/from Dave's Redistricting App format:

```r
# Download a plan from DRA (requires the plan's share link/ID)
dra_plan <- get_dra(url = 'https://davesredistricting.org/maps#...')

# Convert a DRA-exported CSV to an R assignment vector
# DRA exports block-level assignments as CSV
r_plan <- dra2r(
  dra = dra_export_df,   # data frame from DRA CSV export
  shp = precincts_sf,    # precinct shapefile to match against
  id = 'GEOID20'        # GEOID column in shapefile
)

# Convert an R plan vector back to DRA format
dra_df <- r2dra(
  plan = r_plan_vector,
  shp = precincts_sf,
  id = 'GEOID20'
)
```

## Harvard Election Data Archive (HEDA)

Older historical election returns at the county level:

```r
# List available states
heda_states()

# Download HEDA data
heda_data <- get_heda(state = 'VA')
```

## Historical Congressional District Shapefiles

```r
# Download historical US congressional district boundaries (Lewis et al.)
# Available for many Congresses going back to the 1st
hist_districts <- get_lewis(congress = 117)   # 117th Congress
hist_districts <- get_lewis(congress = 100)   # historical Congresses
```

## Racially Polarized Voting Data

```r
# Download RPV (Racially Polarized Voting) dataset for nearby precincts
rpv_data <- get_rpvnearme(state = 'VA', county = '013')
```

## Regionalization

Estimate geographic regions based on spatial features (useful for identifying natural communities or geographic clusters):

```r
regions <- regionalize(
  shp = precincts_sf,
  adj = adj,
  nregions = 5,
  wts = precincts_sf$pop
)
```

## Count Connections

Count how many times precincts share adjacency connections (useful for analyzing plan robustness):

```r
connection_counts <- count_connections(plans = plans, adj = adj)
```

## Typical Workflow: Adding VEST Data to a Custom Map

```r
library(redistverse)
library(geomander)

# 1. Load precinct shapefile (from local source or tinytiger)
precincts <- st_read('md_precincts_2020.shp')

# 2. Download VEST election data for Maryland 2020
vest_md <- get_vest(state = 'MD', year = 2020)

# 3. Match VEST precincts to your precincts
matches <- geo_match(from = vest_md, to = precincts, method = 'area')

# 4. Transfer election columns using estimation
for (col in grep('^G20', names(vest_md), value = TRUE)) {
  precincts[[col]] <- estimate_up(
    estimate_down(wts = vest_md$vap, value = vest_md[[col]],
                  group = seq_len(nrow(vest_md))),
    group = matches
  )
}

# 5. Build redist_map
map <- redist_map(precincts, pop_col = 'pop', ndists = 8, pop_tol = 0.005)
```

## See Also

- Adjacency tools: [09-geomander-adjacency.md](09-geomander-adjacency.md)
- Spatial estimation (geo_match, estimate_down): [10-geomander-spatial.md](10-geomander-spatial.md)
- Pre-built ALARM data (easier for common states): [12-alarmdata.md](12-alarmdata.md)

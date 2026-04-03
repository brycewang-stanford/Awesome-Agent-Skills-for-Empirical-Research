# geomander — Spatial Estimation and Block Aggregation

## Overview

This file covers `geomander`'s tools for matching geographic units across datasets, disaggregating and reaggregating data between geographic levels, and processing spatial data for redistricting analysis. The core workflow is: match blocks to precincts, estimate election data down to blocks, then re-aggregate to new geographic boundaries.

## Geographic Matching

`geo_match()` assigns each unit in one geographic layer to the most appropriate unit in another layer.

```r
geo_match(
  from = blocks_sf,       # smaller geography (source)
  to = precincts_sf,    # larger geography (target)
  method = 'centroid',      # see methods below
  by = NULL,            # optional: column to match within
  tiebreaker = TRUE,         # resolve ties
  epsg = 3857
)
# Returns: integer vector (length = nrow(from)), each entry is the row index in `to`
```

### Matching Methods

| Method | Description | Best for |
|--------|-------------|---------|
| `"centroid"` | Assigns to the `to` unit containing the centroid | Most cases |
| `"center"` | Uses approximate center (handles non-convex shapes better) | Irregular shapes |
| `"point"` | Uses surface point (guaranteed inside polygon) | Concave/donut polygons |
| `"circle"` | Uses center of largest inscribed circle | Compact shapes |
| `"area"` | Assigns to `to` unit with greatest overlap | Boundary-crossing units |

```r
# Match blocks to precincts by centroid
matches <- geo_match(from = blocks_sf, to = precincts_sf, method = 'centroid')

# Match within county (faster for large states)
matches <- geo_match(from = blocks_sf, to = precincts_sf,
  by = c('COUNTYFP', 'COUNTYFP'),  # column in from, column in to
  method = 'centroid')
```

## Block Aggregation

### `block2prec()` — Aggregate block-level data to precincts

```r
# Step 1: get matches
matches <- geo_match(from = block_table, to = precincts_sf, method = 'centroid')

# Step 2: aggregate (sums all numeric columns by match group)
prec_data <- block2prec(block_table = block_table, matches = matches)

# Combine with precinct shapefile
precincts <- bind_cols(precincts_sf, prec_data)
```

### `block2prec_by_county()` — Aggregate per county (faster for large states)

Performs `geo_match()` and `block2prec()` within each county separately, which is more reliable near county boundaries:

```r
prec_data <- block2prec_by_county(
  block_table = block_table,
  precinct = precincts_sf,
  precinct_county_fips = 'COUNTYFP'    # county FIPS column in precincts_sf
)
```

### `create_block_table()` — Download and create block-level demographic data

Downloads Census block data for a given state and county directly:

```r
block_table <- create_block_table(state = 'VA', county = '013')
# Returns sf object with block geometry + race/ethnicity + VAP columns
```

```r
# Statewide (omit county)
block_table <- create_block_table(state = 'MD')
```

### `create_tract_table()` — Same but at tract level

```r
tract_table <- create_tract_table(state = 'MD', county = NULL)
```

## Estimating Across Geographic Levels

When you have election data at one level (e.g., precincts) and need it at another (e.g., VTDs or districts), use the estimate functions.

### Workflow: Precinct → Block → VTD

```r
# 1. Match blocks to precincts and to VTDs
matches_to_prec <- geo_match(from = blocks_sf, to = precincts_sf, method = 'centroid')
matches_to_vtd <- geo_match(from = blocks_sf, to = vtds_sf, method = 'centroid')

# 2. Disaggregate precinct election results down to blocks (weighted by VAP)
dem_blocks <- estimate_down(
  wts = blocks_sf$vap,          # weights for distribution
  value = precincts_sf$G18USSDKAI, # values to disaggregate
  group = matches_to_prec         # which precinct each block belongs to
)

# 3. Re-aggregate blocks up to VTDs
dem_vtd <- estimate_up(
  value = dem_blocks,
  group = matches_to_vtd
)
```

### `geo_estimate_down()` / `geo_estimate_up()` — Simplified single-variable versions

```r
# Combines geo_match + estimate_down in one call
dem_blocks <- geo_estimate_down(
  from = precincts_sf,
  to = blocks_sf,
  wts = 'vap',                 # column in `to` to use as weights
  value = 'G18USSDKAI'          # column in `from` to disaggregate
)

# Reaggregate
dem_vtd <- geo_estimate_up(
  from = blocks_sf,
  to = vtds_sf,
  value = dem_blocks
)
```

## Filtering and Cleaning Spatial Data

```r
# Keep only units that intersect with a target area
filtered <- geo_filter(shp = precincts_sf, target = county_sf)

# Remove tiny slivers (units with very small area relative to neighbors)
trimmed <- geo_trim(shp = precincts_sf, target = county_sf,
                    min_pct = 0.01)   # remove units with <1% of area in target

# Sort precincts geographically (for consistent ordering)
sorted_shp <- geo_sort(shp = precincts_sf, pop_col = 'pop')
```

## Other Spatial Tools

### Splitting Precincts

When a precinct crosses an administrative boundary, split it:

```r
split_map <- split_precinct(
  shp = precincts_sf,
  admin = precincts_sf$county   # column defining the boundaries to split along
)
```

### BAF to VTD Conversion

Convert a block assignment file to VTD-level assignments via areal interpolation:

```r
vtd_plan <- baf_to_vtd(
  baf = baf_df,        # data frame with GEOID20 and district columns
  vtds = vtds_sf        # VTD shapefile
)
```

### Center of Shape

```r
# Approximate center (handles non-convex shapes)
centers <- st_centerish(shp = precincts_sf)

# Center of largest inscribed circle
circle_centers <- st_circle_center(shp = precincts_sf)
```

### Spatial Autocorrelation

```r
# Moran's I (tests for spatial clustering)
morans <- global_morans(x = map$ndv / (map$ndv + map$nrv), adj = adj)

# Local Moran's I (identifies clusters and outliers)
local <- local_morans(x = map$ndv / (map$ndv + map$nrv), adj = adj, shp = map)

# Geary's C
gearys <- global_gearys(x = map$pop_black / map$pop, adj = adj)

# Getis-Ord G*i (hot spot analysis)
hotspots <- gstar_i(x = map$pop_black / map$pop, adj = adj, shp = map)
```

## Full Block-to-Precinct Aggregation Workflow

```r
library(redistverse)
library(geomander)

# 1. Download block-level data
blocks <- create_block_table(state = 'VA')

# 2. Load precinct shapefile
precincts <- st_read('va_precincts_2020.shp')

# 3. Aggregate population to precincts
prec_pop <- block2prec_by_county(
  block_table = blocks,
  precinct = precincts,
  precinct_county_fips = 'COUNTYFP'
)

# 4. Build redist_map
map <- bind_cols(precincts, prec_pop) |>
  redist_map(pop_col = 'pop', ndists = 11, pop_tol = 0.005)
```

## See Also

- Adjacency and contiguity tools: [09-geomander-adjacency.md](09-geomander-adjacency.md)
- Downloading VEST/ALARM/DRA data: [11-geomander-data.md](11-geomander-data.md)
- Census block data: [13-pl94171.md](13-pl94171.md) and [14-census-utilities.md](14-census-utilities.md)

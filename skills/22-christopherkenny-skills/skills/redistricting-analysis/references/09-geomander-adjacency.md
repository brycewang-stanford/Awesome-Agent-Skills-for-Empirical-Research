# geomander — Adjacency and Contiguity

## Overview

`geomander` provides the primary tools for building, inspecting, and repairing precinct adjacency graphs in redistricting. This file covers adjacency construction, contiguity checking, edge editing, and the seam tools for removing edges along administrative boundaries. See also [10-geomander-spatial.md](10-geomander-spatial.md) for spatial estimation and [11-geomander-data.md](11-geomander-data.md) for data downloads.

## Building an Adjacency List

```r
library(geomander)

# Build from an sf shapefile (returns a zero-indexed list of neighbor vectors)
adj <- adjacency(shp = precincts_sf)

# Store in a redist_map
map <- redist_map(precincts_sf, pop_col = 'pop', ndists = 8, adj = adj)
```

Note: The `adj` package's `adj_from_shp()` provides a similar function with a validated S3 class. The `geomander::adjacency()` output is a plain list — compatible with `redist` which accepts either.

## Checking Contiguity

After building or modifying an adjacency graph, always verify connectivity within each group (e.g., each county or district):

```r
# Full contiguity report — returns tibble with group, group_number, component
check_contiguity(adj = adj, group = map$county)
# component == 1 for all rows = fully connected within each county
# component > 1 indicates disconnected islands

# Aliases:
cct(adj, group)   # frequency table of component counts (1 = all contiguous)
ccm(adj, group)   # max component number (1 = all contiguous)

# Check overall graph (no groups — are all precincts reachable?)
check_contiguity(adj = adj)  # group defaults to 1 (single group)

# Check polygon contiguity (geometry-based, no adj needed)
check_polygon_contiguity(shp = precincts_sf, group = precincts_sf$county)
```

**Interpretation**: If `ccm(adj, group) > 1`, some group has a disconnected component — precincts in that group that cannot reach each other. This usually needs fixing before simulation.

## Finding and Fixing Disconnected Components

```r
# Suggest which edges to add to connect isolated precincts
suggest_neighbors(adj = adj, shp = precincts_sf, idx = isolated_precinct_idx)

# Suggest how to connect disconnected components within groups
suggest_component_connection(adj = adj, shp = precincts_sf, group = map$county)
# Returns a data frame of suggested (from, to) edge pairs to add
```

## Editing Edges

```r
# Add an edge between precinct i and precinct j (zero-indexed)
adj <- add_edge(adj, v1 = 42L, v2 = 107L)

# Remove an edge
adj <- subtract_edge(adj, v1 = 42L, v2 = 107L)

# Vectorized (add/remove multiple edges at once)
adj <- subtract_edge(adj, v1 = c(3L, 8L), v2 = c(15L, 22L))
```

Note: `add_edge()` and `subtract_edge()` are geomander's versions; the `adj` package provides equivalent `adj_add_edges()` and `adj_subtract_edges()`.

## Comparing Adjacency Lists

Useful for checking what changed after manual edits:

```r
compare_adjacencies(adj1 = original_adj, adj2 = modified_adj)
# Returns a tibble of edges that differ between the two graphs
```

## Seam Tools — Removing Edges Along Administrative Boundaries

The seam functions handle edges that cross between specified administrative units. This is the primary approach for water-body adjacency correction.

### `seam_rip()` — Remove edges along a boundary

Removes all adjacency edges that cross between precincts on opposite sides of a specified seam.

```r
seam_rip(
  adj = adj,
  shp = map,           # sf tibble with the admin column
  admin = 'county',      # column defining the administrative units
  seam = c('Orange', 'Rockland'),  # units to disconnect from each other
  epsg = 3857           # projection for spatial operations
)
```

**Key distinction from `adj_subtract_edges()`**: `seam_rip()` works at the administrative unit level — you name which counties/units to separate, and it finds and removes all edges between them automatically. `adj_subtract_edges()` requires you to specify exact precinct pairs.

### `seam_adj()` — Inspect edges along a border

Returns only the edges that run along a specified boundary (useful for verification):

```r
border_edges <- seam_adj(adj = adj, shp = map, admin = 'county',
  seam = c('Orange', 'Rockland'))
# tibble of (from, to) pairs that cross the seam
```

### `seam_geom()` — Subset precincts along a border

Returns the subset of precincts that lie along a specified boundary:

```r
border_precincts <- seam_geom(shp = map, admin = 'county',
  seam = c('Orange', 'Rockland'))
```

### `seam_sew()` — Suggest connections across a border

When a border should be crossable (e.g., a bridge connection), suggest which edges to add:

```r
suggested_edges <- seam_sew(adj = adj, shp = map, admin = 'county',
  seam = c('Bronx', 'Queens'))
# Returns (from, to) pairs to add with add_edge()
```

## Visualization

```r
# Plot the shapefile with row numbers labeled (useful for identifying precinct indices)
geo_plot(shp = precincts_sf)

# Plot groups with connected components colored differently
# Disconnected components appear in different colors
geo_plot_group(shp = precincts_sf, adj = adj, group = precincts_sf$county)
```

## Common Workflow: Water-Body Adjacency Correction

```r
library(redistverse)
library(geomander)

# Load map
map <- alarm_50state_map('MD')

# Build adjacency (or use the pre-built one)
adj <- map$adj[[1]]

# Identify which counties are separated by the Chesapeake Bay
eastern_shore_counties <- c('Kent', "Queen Anne's", 'Talbot', 'Caroline',
  'Dorchester', 'Wicomico', 'Somerset', 'Worcester')
western_counties <- c('Anne Arundel', 'Baltimore', ...)  # counties on west side

# Check if cross-bay edges exist
border_edges <- seam_adj(adj, map, admin = 'county',
  seam = eastern_shore_counties)

# Remove cross-bay edges
adj_fixed <- seam_rip(adj, map, admin = 'county',
  seam = eastern_shore_counties)

# Verify fix
ccm(adj_fixed, map$county)   # should still be 1 within each county

# Store back in map
map$adj <- list(adj_fixed)
```

## See Also

- Spatial estimation and block aggregation: [10-geomander-spatial.md](10-geomander-spatial.md)
- Data downloads (VEST, ALARM, DRA): [11-geomander-data.md](11-geomander-data.md)
- `adj` package equivalents (validated S3 class): [08-adj.md](08-adj.md)

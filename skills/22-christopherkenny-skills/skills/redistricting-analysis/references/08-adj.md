# adj — Adjacency Graphs

## Overview

`adj` is an S3 vector class representing precinct adjacency graphs. Each element is a zero-indexed integer vector of neighbors. The adjacency graph is stored as the `adj` column of a `redist_map`, and is central to all tree-based simulation algorithms. Use `adj` functions when you need to construct, inspect, or modify the adjacency structure.

## Construction

### From a Shapefile

The most common approach: compute adjacency from shared boundaries in an `sf` object.

```r
library(adj)

# Build adjacency from shared polygon boundaries
adjacency <- adj_from_shp(shp)      # sf object with polygon geometry

# Equivalent using the map directly
adjacency <- adj_from_shp(map)
```

### From ALARM Pre-built Data

The `alarm_50state_map()` function returns a `redist_map` with the `adj` column pre-built:

```r
map <- alarm_50state_map('MD')
adj_graph <- map$adj     # already computed
```

### Manual Construction

```r
# Create from a list of neighbor index vectors (zero-indexed)
adj_graph <- adj(list(
  c(1L, 2L),    # precinct 0 is adjacent to precincts 1 and 2
  c(0L, 2L),    # precinct 1 is adjacent to 0 and 2
  c(0L, 1L)     # precinct 2 is adjacent to 0 and 1
))
```

## Inspecting the Graph

```r
length(adj_graph)              # number of precincts (nodes)
adj_graph[[i]]                 # neighbors of precinct i (0-indexed)
plot(adj_graph, map)           # visualize the graph overlaid on the map geometry
```

## Modifying Edges

### Remove Edges

Use to disconnect precincts separated by water bodies, mountain ranges, or other barriers that make adjacency legally or geographically incorrect.

```r
# Remove the edge between precincts 42 and 107
adj_graph <- adj_subtract_edges(adj_graph, v1 = 42L, v2 = 107L)

# Remove multiple edges at once (vectorized)
adj_graph <- adj_subtract_edges(adj_graph,
                                v1 = c(42L, 58L, 91L),
                                v2 = c(107L, 59L, 92L))
```

### Add Edges

Add connections for precincts linked by ferry, bridge, or tunnel:

```r
adj_graph <- adj_add_edges(adj_graph, v1 = 204L, v2 = 312L)
```

## Storing Modified Adjacency Back in the Map

```r
map <- map |> mutate(adj = list(adj_graph))
# Or directly:
attr(map, 'adj') <- adj_graph
```

## District-Level Adjacency

Build a district-level adjacency graph from a plan assignment vector. Useful for checking contiguity of merged regions or computing district-level graph properties.

```r
district_adj <- adj_quotient(adj_graph, plan = map$cd_2020)
# Returns an adj object with one node per district
```

## Graph Coloring

Assign colors to precincts/districts so no two adjacent units share a color. Uses the DSatur algorithm; typically requires 4–5 colors for U.S. states.

```r
# Color districts for map visualization
colors <- adj_color(adj_graph)        # returns integer vector of color assignments
colors <- adj_color(district_adj)     # color the district-level graph

# Use in ggplot
map$color <- adj_color(map$adj[[1]])
ggplot(map, aes(fill = factor(color), group = cd_2020)) + geom_district()
```

## Graph Laplacian

The Laplacian matrix encodes graph structure and is used internally by `redist` to weight spanning trees (controlling compactness). You rarely need this directly, but it's available for advanced analyses.

```r
L <- adj_laplacian(adj_graph)    # sparse matrix (Matrix package)
# Number of spanning trees = product of nonzero eigenvalues / n
```

## Common Workflow: Fixing Water Adjacency

```r
library(redistverse)

map <- alarm_50state_map('MD')

# Identify and remove spurious water-crossing edges
# (Chesapeake Bay separates Eastern and Western Shore)
# Use geomander::seam_rip() or manually identify edge pairs to remove
# (see 09-geomander-adjacency.md)

map <- map |>
  mutate(adj = list(
    adj_subtract_edges(map$adj[[1]],
                       v1 = water_edge_from,
                       v2 = water_edge_to)
  ))

# Verify the graph is still connected
# redist_map() will warn if adj yields disconnected units
```

## See Also

- Geographic edge removal utilities: [09-geomander-adjacency.md](09-geomander-adjacency.md)
- How adjacency is used in simulation: [01-redist-simulation.md](01-redist-simulation.md)
- District coloring in ggredist: [07-ggredist.md](07-ggredist.md)

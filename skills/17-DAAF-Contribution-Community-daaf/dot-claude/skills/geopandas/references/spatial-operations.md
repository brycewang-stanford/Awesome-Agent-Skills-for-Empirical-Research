# Spatial Operations

Vector spatial operations in geopandas — joins, overlays, dissolve, clip, buffer, distance, and areal interpolation. For methodology guidance (when/why to use each operation), see the `data-scientist` skill's `geospatial-operations.md`.

---

## Spatial Joins

Spatial joins connect records from two GeoDataFrames based on geographic relationships rather than shared key columns.

### Basic Spatial Join

```python
# Which county contains each school? (point-in-polygon)
result = gpd.sjoin(schools, counties, predicate="within")

# Which schools fall within each county? (polygon-contains-point)
result = gpd.sjoin(counties, schools, predicate="contains")

# Which features overlap? (most permissive)
result = gpd.sjoin(gdf1, gdf2, predicate="intersects")
```

### Spatial Join Parameters

```python
gpd.sjoin(
    left_df,                # Left GeoDataFrame
    right_df,               # Right GeoDataFrame
    how="inner",            # 'inner', 'left', 'right'
    predicate="intersects", # Spatial predicate
    lsuffix="left",         # Suffix for overlapping column names from left
    rsuffix="right"         # Suffix for overlapping column names from right
)
```

### Spatial Predicates

| Predicate | Meaning | Common Use |
|-----------|---------|------------|
| `intersects` | Geometries share any space (including touching) | Default — broadest match |
| `within` | Left is entirely inside right | Points within polygons |
| `contains` | Left entirely encloses right | Polygons containing points |
| `touches` | Shared boundary, no interior overlap | Adjacency detection |
| `crosses` | Partial interior overlap | Lines crossing polygons |
| `covers` | Like contains but includes boundary | Inclusive containment |
| `covered_by` | Like within but includes boundary | Inclusive membership |

### Nearest-Neighbor Join

```python
# Find nearest school to each census tract centroid
result = gpd.sjoin_nearest(
    tracts,                   # Left GeoDataFrame
    schools,                  # Right GeoDataFrame
    how="left",               # Keep all left features
    max_distance=10000,       # Max search distance (CRS units)
    distance_col="dist_m"     # Add column with actual distance
)
```

`sjoin_nearest` requires both GeoDataFrames in a projected CRS for meaningful distances.

### Post-Join Validation

Spatial joins can produce unexpected row counts due to many-to-many relationships. Always validate:

```python
print(f"Left rows: {len(schools)}")
print(f"Result rows: {len(result)}")
print(f"Duplicated left indices: {result.index.duplicated().sum()}")
print(f"Null join columns: {result['county_name'].isna().sum()}")

# If duplicates exist, decide how to handle:
# Option 1: Keep first match
result_dedup = result[~result.index.duplicated(keep="first")]

# Option 2: Aggregate
result_agg = result.groupby(result.index).agg({"county_name": "first", "value": "sum"})
```

---

## Attribute Joins (Non-Spatial)

Standard pandas merge for joining by shared columns:

```python
# Join census data to county geometries by FIPS code
counties_with_data = counties.merge(census_df, left_on="GEOID", right_on="fips", how="left")

# Note: merge returns a GeoDataFrame if the left input is a GeoDataFrame
```

---

## Overlay Operations

Overlays combine two polygon layers to produce new geometries. Unlike spatial joins (which transfer attributes), overlays create new geometries from intersections.

```python
gpd.overlay(
    df1,                   # First GeoDataFrame (polygons)
    df2,                   # Second GeoDataFrame (polygons)
    how="intersection",    # 'intersection', 'union', 'difference',
                           # 'symmetric_difference', 'identity'
    keep_geom_type=True,   # Filter out geometry type changes
    make_valid=True        # Auto-fix invalid geometries before overlay
)
```

### Overlay Types

| Operation | Output Contains | Example |
|-----------|----------------|---------|
| `intersection` | Only overlapping areas | "Area that is both wetland AND flood zone" |
| `union` | All areas from both layers | "All unique sub-areas from districts and tracts" |
| `difference` | Areas in df1 but NOT in df2 | "Park area NOT in the fire zone" |
| `symmetric_difference` | Areas in either but NOT both | "Areas in one zone but not the other" |
| `identity` | All of df1, split where df2 overlaps | "Districts, subdivided by tract boundaries" |

### Overlay Example

```python
# Find areas where flood zones and school districts overlap
flood_school = gpd.overlay(school_districts, flood_zones, how="intersection")

# Compute area of overlap
flood_school["overlap_area_km2"] = flood_school.to_crs(epsg=5070).area / 1e6
```

---

## Dissolve (Aggregate Geometries)

Dissolve merges geometries by a grouping column, combining multiple features into one. It is the spatial equivalent of `groupby().agg()`.

```python
# Merge counties into states (sum population, merge geometries)
states = counties.dissolve(by="state_fips", aggfunc="sum")

# Multiple aggregation functions
states = counties.dissolve(
    by="state_fips",
    aggfunc={
        "population": "sum",
        "area_sq_mi": "sum",
        "median_income": "mean"
    }
)

# Dissolve all features into one (no grouping)
us_boundary = counties.dissolve()
```

### Dissolve Parameters

```python
gdf.dissolve(
    by=None,              # Column(s) to group by (None = dissolve all)
    aggfunc="first",      # Aggregation: 'first', 'sum', 'mean', 'min', 'max', or dict
    as_index=True,        # Use group column as index
    sort=True,            # Sort by group column
    method="unary"        # 'unary' (default), 'coverage_union' (faster if no overlaps)
)
```

---

## Clipping

Clip features to a boundary — everything outside the mask is removed.

```python
# Clip schools to a state boundary
schools_in_state = gpd.clip(schools, state_boundary)

# Clip a polygon layer to a bounding box
from shapely.geometry import box
bbox = box(-78.0, 38.0, -76.0, 40.0)
clipped = gpd.clip(gdf, bbox)
```

### clip vs sjoin

- **`clip`**: Modifies geometries — polygons are cut at the mask boundary
- **`sjoin`**: Keeps original geometries — only filters which features to include

---

## Buffering

Create a zone around features at a specified distance.

```python
# Buffer points by 1 km (CRS must be in meters!)
gdf_proj = gdf.to_crs(epsg=5070)
gdf_buffered = gdf_proj.copy()
gdf_buffered["geometry"] = gdf_proj.buffer(1000)  # 1000 meters

# Variable-distance buffer (different distance per feature)
gdf_buffered["geometry"] = gdf_proj.buffer(gdf_proj["radius_m"])

# Buffer parameters
gdf_proj.buffer(
    distance=1000,       # Distance in CRS units
    resolution=16,       # Number of segments per quarter circle
    cap_style="round",   # 'round', 'flat', 'square'
    join_style="round",  # 'round', 'mitre', 'bevel'
    single_sided=False   # True for one-sided buffer (lines only)
)
```

Buffering in a geographic CRS (degrees) produces elliptical buffers that vary with latitude — always project first.

---

## Distance

```python
# Distance between aligned GeoSeries (element-wise)
distances = gdf1.distance(gdf2)  # Returns Series of distances in CRS units

# Distance from every feature to a single point
from shapely.geometry import Point
capitol = Point(-77.009, 38.890)
gdf["dist_to_capitol"] = gdf.to_crs(epsg=5070).distance(
    gpd.GeoSeries([capitol], crs="EPSG:4326").to_crs(epsg=5070).iloc[0]
)
```

Always compute distances in a projected CRS for results in meters.

---

## Centroid

```python
# Centroid of each geometry
gdf["centroid"] = gdf.to_crs(epsg=5070).centroid

# Representative point (guaranteed to be inside the polygon — centroid might not be)
gdf["rep_point"] = gdf.to_crs(epsg=5070).representative_point()
```

Use `representative_point()` for irregular or concave polygons where the centroid might fall outside the geometry.

---

## Area and Length

```python
# Area (project to equal-area CRS first)
gdf_proj = gdf.to_crs(epsg=5070)
gdf["area_m2"] = gdf_proj.area
gdf["area_km2"] = gdf_proj.area / 1e6

# Length (for LineString geometries)
gdf["length_m"] = gdf_proj.length
gdf["length_km"] = gdf_proj.length / 1e3
```

---

## Geometry Manipulation

### Simplify

Reduce geometry complexity (fewer vertices) for faster rendering or smaller file size:

```python
# Simplify with tolerance (in CRS units)
gdf["geometry"] = gdf.simplify(tolerance=100)  # 100 meters if projected

# Preserve topology (prevents holes between adjacent polygons)
gdf["geometry"] = gdf.simplify(tolerance=100, preserve_topology=True)
```

### Convex Hull

```python
gdf["convex_hull"] = gdf.convex_hull
```

### Explode (Multi to Single)

Split MultiPolygons/MultiLineStrings into individual geometries:

```python
gdf_single = gdf.explode(index_parts=False)
```

### Unary Union

Merge all geometries into one:

```python
merged = gdf.geometry.union_all()  # Returns a single Shapely geometry
```

### Bounds

```python
# Bounding box of each geometry
bounds = gdf.bounds  # DataFrame with minx, miny, maxx, maxy columns

# Overall bounding box
total_bounds = gdf.total_bounds  # Array: [minx, miny, maxx, maxy]
```

---

## Areal Interpolation (Boundary Mismatch)

When source and target boundaries don't align (e.g., redistributing census tract data to school districts), use the `tobler` package:

```python
from tobler.area_weighted import area_interpolate

# Redistribute population from tracts to school districts
result = area_interpolate(
    source_df=tracts,                # Source polygons with data
    target_df=school_districts,      # Target polygons to receive data
    extensive_variables=["population", "housing_units"],  # Totals: distributed by area fraction
    intensive_variables=["median_income", "poverty_rate"]  # Rates: area-weighted average
)
```

**Extensive vs intensive:**
- **Extensive** (population, count): scales with area. 1000 people in a tract, 60% area overlap → 600 assigned.
- **Intensive** (rate, density): independent of area. 15% poverty rate → area-weighted average.

Confusing them is the most common areal interpolation error.

### Dasymetric Refinement

Simple area-weighting assumes uniform distribution within source zones. Dasymetric methods use auxiliary data (land use rasters) for better accuracy:

```python
from tobler.dasymetric import masked_area_interpolate

result = masked_area_interpolate(
    source_df=tracts,
    target_df=districts,
    extensive_variables=["population"],
    raster="landuse.tif",             # Binary raster: 1 = inhabited, 0 = uninhabited
)
```

---

## References and Further Reading

Jordahl, K. et al. (2024). *geopandas: Merging data*. https://geopandas.org/en/stable/docs/user_guide/mergingdata.html

Jordahl, K. et al. (2024). *geopandas: Set operations with overlay*. https://geopandas.org/en/stable/docs/user_guide/set_operations.html

Rey, S.J., Arribas-Bel, D., and Wolf, L.J. (2023). *Geographic Data Science with Python*, Ch. 4: "Spatial weights." https://geographicdata.science/book/

Dorman, M., Graser, A., Nowosad, J., and Lovelace, R. (2025). *Geocomputation with Python*, Chs. 3-4: "Attribute data operations" and "Spatial data operations." https://py.geocompx.org/

tobler documentation. https://pysal.org/tobler/

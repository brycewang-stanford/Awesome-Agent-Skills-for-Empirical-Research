# Common Gotchas and Troubleshooting

Frequent issues when working with geopandas and the spatial Python stack — symptoms, causes, and fixes.

---

## CRS Mismatch Errors

### Symptom

```
ValueError: GeoDataFrame does not have a CRS set.
# or
CRSMismatchError: CRS mismatch between the CRS of left geometries and the CRS of right geometries.
```

### Cause

Spatial operations (join, overlay, distance) require all inputs in the same CRS. This error fires when CRS is missing or doesn't match.

### Fix

```python
# Check CRS of both inputs
print(gdf1.crs)  # e.g., EPSG:4326
print(gdf2.crs)  # e.g., EPSG:5070 or None

# If missing CRS, set it (don't reproject — set declares what system the data is already in)
gdf2 = gdf2.set_crs("EPSG:4326")

# If mismatched, reproject one to match the other
gdf2 = gdf2.to_crs(gdf1.crs)

# Now the spatial operation will work
result = gpd.sjoin(gdf1, gdf2)
```

### Prevention

Reproject all inputs to a common CRS at the start of the script:

```python
TARGET_CRS = "EPSG:5070"
gdf1 = gdf1.to_crs(TARGET_CRS)
gdf2 = gdf2.to_crs(TARGET_CRS)
```

---

## Invalid Geometries

### Symptom

- Overlay or spatial join returns empty or incomplete results
- `TopologyException: found non-noded intersection` error
- Unexpected geometry fragments after overlay

### Cause

Invalid geometries violate the Simple Features specification — self-intersections, unclosed rings, duplicate vertices, etc.

### Detection

```python
# Check which geometries are invalid
invalid_mask = ~gdf.geometry.is_valid
print(f"Invalid geometries: {invalid_mask.sum()} / {len(gdf)}")

# Inspect a sample
if invalid_mask.any():
    from shapely.validation import explain_validity
    for idx in gdf[invalid_mask].index[:5]:
        print(f"  Row {idx}: {explain_validity(gdf.loc[idx, 'geometry'])}")
```

### Fix

```python
# Option 1: make_valid() — preferred (Shapely 2.0+)
gdf["geometry"] = gdf.geometry.make_valid()

# Option 2: Buffer by zero — classic approach
gdf["geometry"] = gdf.geometry.buffer(0)

# Verify fix
assert gdf.geometry.is_valid.all(), "Some geometries still invalid after repair"
```

### When to Validate

- Before any overlay operation
- Before spatial joins with `contains` or `within` predicates
- After reading Shapefiles (the format is prone to validity issues)
- After any geometry transformation (simplification, projection, dissolve)

---

## Spatial Join Produces Wrong Row Count

### Symptom

After `gpd.sjoin()`, the result has more rows than the left input (unexpected duplicates) or fewer rows (unexpected drops).

### Cause: Many-to-Many Matches

A point on a polygon boundary may match multiple polygons (with `intersects`). Overlapping polygons cause a single feature to match several targets.

### Diagnosis

```python
print(f"Input rows: {len(left_gdf)}")
print(f"Result rows: {len(result)}")
print(f"Duplicated indices: {result.index.duplicated().sum()}")
print(f"Null join columns: {result['right_col'].isna().sum()}")
```

### Fix

```python
# Strategy 1: Use stricter predicate
result = gpd.sjoin(points, polygons, predicate="within")  # Instead of "intersects"

# Strategy 2: Drop duplicates (keep first match)
result = result[~result.index.duplicated(keep="first")]

# Strategy 3: Aggregate after join
result = result.groupby(result.index).agg({
    "county_name": "first",
    "population": "sum"
})
```

### Cause: Unmatched Features (Fewer Rows)

Default `how="inner"` drops features with no spatial match.

```python
# Use left join to keep all left features
result = gpd.sjoin(schools, counties, predicate="within", how="left")
# Unmatched schools will have NaN in county columns
```

---

## Memory Issues with Large Shapefiles

### Symptom

Out of memory when reading a large Shapefile, or very slow performance.

### Fixes

```python
# 1. Read only needed columns
gdf = gpd.read_file("huge.shp", columns=["GEOID", "NAME", "geometry"])

# 2. Read only a geographic subset
gdf = gpd.read_file("huge.shp", bbox=(-80, 35, -75, 40))

# 3. Use pyogrio with Arrow backend (lower memory)
gdf = gpd.read_file("huge.shp", engine="pyogrio", use_arrow=True)

# 4. Use GeoParquet instead (much faster reads, column selection)
# Convert once:
gdf_full = gpd.read_file("huge.shp")
gdf_full.to_parquet("huge.parquet")
# Then read efficiently:
gdf = gpd.read_parquet("huge.parquet", columns=["GEOID", "geometry"])

# 5. For visualization of millions of features, use lonboard instead of matplotlib
from lonboard import viz
m = viz(gdf)
```

---

## Shapely 1.x vs 2.x Differences

geopandas 1.x requires **Shapely 2.0+**, which introduced significant changes.

### Key Changes

| Feature | Shapely 1.x | Shapely 2.x |
|---------|-------------|-------------|
| Geometry creation | Objects are mutable | Objects are immutable |
| Operations | Method-based only | Vectorized ufuncs + methods |
| Performance | Slow (Python-level loops) | Fast (C-level vectorized) |
| Array operations | Required PyGEOS separately | Built-in (PyGEOS merged) |
| `numpy` interop | Limited | Full support |

### What Broke

```python
# Shapely 1.x (no longer works)
from shapely.ops import cascaded_union    # Removed
cascaded_union(geom_list)

# Shapely 2.x equivalent
from shapely import union_all
union_all(geom_list)
# Or in geopandas:
gdf.geometry.union_all()

# Shapely 1.x
geom.is_empty  # Was an attribute in 1.x, still works in 2.x

# The PyGEOS backend option is gone — Shapely 2.x IS the vectorized engine
# Delete any old environment variable:
# unset USE_PYGEOS  (no longer needed)
```

### If You See Deprecation Warnings

Some Shapely 1.x functions were removed; others still work but have modern equivalents:

```python
# Removed (will raise ImportError)
from shapely.ops import cascaded_union  # Use shapely.union_all() instead

# Deprecated — use the modern equivalents
from shapely.ops import unary_union     # Deprecated in shapely; use union_all()
from shapely import union_all           # Preferred vectorized equivalent
# In geopandas: gdf.geometry.union_all() (unary_union is deprecated in 1.1.3)

# Repair pattern
geom.buffer(0)                # Classic fix — still works
shapely.make_valid(geom)      # Preferred in 2.x (more predictable)
```

---

## Coordinate Order Confusion (lon/lat vs lat/lon)

### The Problem

- **Mathematics/GIS convention:** x = longitude, y = latitude → `(lon, lat)` = `(-77.036, 38.901)`
- **Everyday convention:** "latitude and longitude" → people say `(38.901, -77.036)`
- **Google Maps URLs:** `@38.901,-77.036` (lat, lon)
- **GeoJSON spec:** `[longitude, latitude]` (lon, lat)

### Symptoms of Getting It Wrong

- Points plot in the ocean or in the wrong hemisphere
- Spatial joins return zero matches
- Data appears reflected across the equator or prime meridian

### How geopandas Expects Coordinates

```python
# geopandas follows the GIS convention: x = longitude, y = latitude
gpd.points_from_xy(
    x=df["longitude"],    # x-axis = longitude (horizontal)
    y=df["latitude"]      # y-axis = latitude (vertical)
)

# Shapely Point: Point(x, y) = Point(longitude, latitude)
from shapely.geometry import Point
capitol = Point(-77.009, 38.890)  # (lon, lat)
```

### Quick Diagnostic

```python
# If total_bounds look wrong, coordinates may be swapped
print(gdf.total_bounds)
# Expected for US data: [-125, 24, -66, 50] (minx, miny, maxx, maxy)
# If you see [24, -125, 50, -66], lat/lon are swapped

# Fix: swap x and y
from shapely.ops import transform
gdf["geometry"] = gdf.geometry.map(lambda geom: transform(lambda x, y: (y, x), geom))
```

---

## dtype Warnings with Mixed Geometry Types

### Symptom

```
UserWarning: Geometry column does not contain geometry.
```

Or unexpected behavior when a GeoDataFrame contains mixed geometry types (e.g., both Point and MultiPoint, or Polygon and MultiPolygon).

### Fix

```python
# Check geometry types
print(gdf.geom_type.value_counts())

# Explode MultiGeometries to single parts
gdf = gdf.explode(index_parts=False)

# Or force to Multi type for consistency
from shapely.geometry import MultiPolygon

def to_multi(geom):
    if geom.geom_type == "Polygon":
        return MultiPolygon([geom])
    return geom

gdf["geometry"] = gdf.geometry.map(to_multi)
```

---

## GeoDataFrame Loses CRS After Pandas Operations

### Symptom

After a pandas operation (concat, merge, groupby), `gdf.crs` is None.

### Cause

Some pandas operations return a plain DataFrame, losing the GeoDataFrame type and CRS.

### Fix

```python
# After pd.concat — re-wrap as GeoDataFrame
import pandas as pd
result = pd.concat([gdf1, gdf2])
result = gpd.GeoDataFrame(result, crs=gdf1.crs)

# After merge where geometry might be lost
result = gdf.merge(df, on="key")
if not isinstance(result, gpd.GeoDataFrame):
    result = gpd.GeoDataFrame(result, geometry="geometry", crs=gdf.crs)

# After groupby — dissolve preserves geometry; manual groupby does not
# Use dissolve instead of groupby for spatial data:
result = gdf.dissolve(by="state", aggfunc="sum")  # Preserves geometry + CRS
```

---

## Plotting Issues

### Map Appears Stretched or Distorted

```python
# Add aspect ratio correction
ax.set_aspect("equal")

# Or use a projection that minimizes distortion for your study area
gdf.to_crs(epsg=5070).plot()
```

### Legend Overlaps Map

```python
gdf.plot(
    column="value",
    legend=True,
    legend_kwds={
        "loc": "lower right",
        "fontsize": 8,
        "shrink": 0.6,       # For continuous legends
        "pad": 0.02
    }
)
```

### Basemap Not Showing

```python
# Ensure data is in Web Mercator for basemap alignment
import contextily as ctx
ax = gdf.to_crs(epsg=3857).plot(alpha=0.5)
ctx.add_basemap(ax)

# Or pass CRS explicitly
ax = gdf.plot(alpha=0.5)
ctx.add_basemap(ax, crs=gdf.crs)
```

---

## geopolars: Not Production-Ready

geopolars (a potential geopandas-like interface backed by Polars) is experimental and not suitable for production use. Stick with geopandas for spatial operations and convert to/from Polars for non-spatial data manipulation:

```python
import polars as pl
import geopandas as gpd

# Polars → GeoDataFrame
df_polars = pl.read_parquet("data.parquet")
df_pandas = df_polars.to_pandas()
gdf = gpd.GeoDataFrame(df_pandas, geometry=gpd.points_from_xy(df_pandas.lon, df_pandas.lat), crs="EPSG:4326")

# GeoDataFrame → Polars (drop geometry, or convert to WKT/WKB)
df_polars = pl.from_pandas(gdf.drop(columns=["geometry"]))
```

---

## References and Further Reading

geopandas FAQ and migration guide. https://geopandas.org/en/stable/docs/user_guide.html

Shapely 2.0 migration guide. https://shapely.readthedocs.io/en/stable/migration.html

Tenkanen, H., Heikinheimo, V., and Whipp, D. (forthcoming). *Introduction to Python for Geographic Data Analysis*. https://pythongis.org/

Dorman, M., Graser, A., Nowosad, J., and Lovelace, R. (2025). *Geocomputation with Python*. https://py.geocompx.org/

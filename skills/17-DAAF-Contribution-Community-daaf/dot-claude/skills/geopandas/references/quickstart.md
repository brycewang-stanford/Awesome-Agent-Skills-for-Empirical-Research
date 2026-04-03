# GeoPandas Quickstart

## Installation

### Basic Install

```bash
pip install geopandas
# or
conda install -c conda-forge geopandas
```

geopandas 1.x automatically installs core dependencies: shapely (>=2.0), pyproj (>=3.3), pyogrio (>=0.7.2, default I/O engine), and pandas.

### Recommended Extras

```bash
# Visualization and basemaps
pip install matplotlib contextily mapclassify folium

# Raster integration
pip install rasterio rasterstats rioxarray

# Spatial statistics (PySAL ecosystem)
pip install libpysal esda spreg pointpats

# GPU-accelerated visualization for large datasets
pip install lonboard

# Interactive notebooks
pip install mapwidget ipywidgets
```

### Verify Installation

```python
import geopandas as gpd
print(gpd.__version__)       # Should be 1.x
gpd.show_versions()          # Full dependency report (prints directly)
```

---

## Core Concepts

### GeoDataFrame = DataFrame + Geometry

A GeoDataFrame is a pandas DataFrame with a special `geometry` column containing Shapely geometry objects. All standard pandas operations work — plus spatial operations.

```python
import geopandas as gpd
import pandas as pd
from shapely.geometry import Point

# A GeoDataFrame has:
# - Regular columns (name, population, etc.)
# - A geometry column (points, lines, or polygons)
# - A CRS (coordinate reference system)
```

### GeoSeries

The geometry column is a `GeoSeries` — a pandas Series of Shapely geometries. It provides vectorized spatial operations:

```python
gdf.geometry              # Access the GeoSeries
gdf.geometry.area         # Area of each geometry
gdf.geometry.centroid     # Centroid of each geometry
gdf.geometry.is_valid     # Validity check for each geometry
```

---

## Creating GeoDataFrames

### From a DataFrame with Coordinates

The most common case — a DataFrame with latitude/longitude columns:

```python
import geopandas as gpd
import pandas as pd

df = pd.DataFrame({
    "name": ["School A", "School B", "School C"],
    "lon": [-77.036, -77.009, -76.995],
    "lat": [38.901, 38.889, 38.910],
    "enrollment": [500, 800, 650]
})

gdf = gpd.GeoDataFrame(
    df,
    geometry=gpd.points_from_xy(df.lon, df.lat),
    crs="EPSG:4326"
)
```

`gpd.points_from_xy(x, y)` takes longitude as x and latitude as y. This is the standard mathematical convention (x=horizontal=longitude) but trips up many users who think "lat, lon". See `gotchas.md` for more on coordinate order.

### From Shapely Geometry Objects

```python
from shapely.geometry import Point, Polygon

gdf = gpd.GeoDataFrame(
    {"name": ["Park", "Lake"], "type": ["green", "water"]},
    geometry=[
        Polygon([(-77.05, 38.90), (-77.04, 38.90), (-77.04, 38.91), (-77.05, 38.91)]),
        Polygon([(-77.02, 38.88), (-77.01, 38.88), (-77.01, 38.89), (-77.02, 38.89)])
    ],
    crs="EPSG:4326"
)
```

### From a GeoJSON-like Dictionary

```python
gdf = gpd.GeoDataFrame.from_features([
    {
        "type": "Feature",
        "geometry": {"type": "Point", "coordinates": [-77.036, 38.901]},
        "properties": {"name": "Capitol", "visitors": 3000000}
    }
], crs="EPSG:4326")
```

### Empty GeoDataFrame with Schema

```python
from shapely.geometry import Point

gdf = gpd.GeoDataFrame(
    columns=["name", "value", "geometry"],
    geometry="geometry",
    crs="EPSG:4326"
)
```

---

## Reading Spatial Data

### Read Any Supported Vector Format

```python
# GeoPackage (recommended modern format)
gdf = gpd.read_file("counties.gpkg")

# Shapefile (legacy — see data-io.md for limitations)
gdf = gpd.read_file("counties.shp")

# GeoJSON
gdf = gpd.read_file("counties.geojson")

# FlatGeobuf
gdf = gpd.read_file("counties.fgb")
```

### Read with Filters (Efficient for Large Files)

```python
# Read only features within a bounding box (west, south, east, north)
gdf = gpd.read_file("large_file.gpkg", bbox=(-78.0, 38.0, -76.0, 40.0))

# Read only specific columns
gdf = gpd.read_file("large_file.gpkg", columns=["NAME", "POP", "geometry"])

# Read limited rows
gdf = gpd.read_file("large_file.gpkg", rows=100)

# Read specific layer from multi-layer file
gdf = gpd.read_file("multi_layer.gpkg", layer="counties")
```

### Read GeoParquet (Fastest for Analytical Workflows)

```python
gdf = gpd.read_parquet("counties.parquet")

# With bounding box filter
gdf = gpd.read_parquet("counties.parquet", bbox=(-78.0, 38.0, -76.0, 40.0))

# With column selection
gdf = gpd.read_parquet("counties.parquet", columns=["NAME", "POP", "geometry"])
```

For more formats and advanced I/O, see `data-io.md`.

---

## Writing Spatial Data

```python
# GeoPackage (preferred)
gdf.to_file("output.gpkg", driver="GPKG")

# GeoParquet (preferred for analytical pipelines)
gdf.to_parquet("output.parquet")

# Shapefile (legacy — avoid if possible)
gdf.to_file("output.shp")

# GeoJSON
gdf.to_file("output.geojson", driver="GeoJSON")
```

---

## Basic Inspection

```python
gdf.head()                # First rows
gdf.shape                 # (rows, columns)
gdf.columns               # Column names
gdf.dtypes                # Column types (geometry shows as 'geometry')
gdf.crs                   # Coordinate Reference System
gdf.total_bounds          # [minx, miny, maxx, maxy] bounding box
gdf.geom_type.unique()    # Geometry types present (Point, Polygon, etc.)
gdf.geometry.is_valid.all()  # Check all geometries are valid
```

---

## Basic Plotting

### Quick Plot

```python
# Default plot — just the geometries
gdf.plot()

# Choropleth — color by a column
gdf.plot(column="population", legend=True)

# With figure size
gdf.plot(column="population", legend=True, figsize=(12, 8))
```

### Layered Plot

```python
import matplotlib.pyplot as plt

fig, ax = plt.subplots(figsize=(12, 8))
counties.plot(ax=ax, color="lightgray", edgecolor="white")
schools.plot(ax=ax, color="red", markersize=5)
ax.set_title("Schools by County")
ax.set_axis_off()
plt.tight_layout()
plt.savefig("map.png", dpi=300, bbox_inches="tight")
```

### Interactive Map

```python
# Built-in folium integration (opens in notebook or saves to HTML)
gdf.explore(column="population", cmap="YlOrRd", legend=True)

# Save to HTML
m = gdf.explore(column="population")
m.save("map.html")
```

For advanced visualization (basemaps, classification schemes, lonboard), see `visualization.md`.

---

## Essential Spatial Operations Preview

```python
# Reproject
gdf_projected = gdf.to_crs(epsg=5070)

# Spatial join (which polygon contains each point?)
result = gpd.sjoin(points_gdf, polygons_gdf, predicate="within")

# Buffer (create 1km buffer around points — CRS must be in meters)
gdf_buffered = gdf_projected.copy()
gdf_buffered["geometry"] = gdf_projected.buffer(1000)

# Dissolve (merge counties into states)
states = counties.dissolve(by="state_fips", aggfunc="sum")

# Overlay (intersect two polygon layers)
overlap = gpd.overlay(layer1, layer2, how="intersection")
```

For complete spatial operation reference, see `spatial-operations.md`.

---

## Next Steps

- Learn about [CRS and projections](./crs-projections.md) — essential before any geometric computation
- Master [spatial operations](./spatial-operations.md) — joins, overlays, dissolve
- Explore [visualization options](./visualization.md) — static and interactive maps
- Understand [file formats](./data-io.md) — choosing the right format for your workflow

## References and Further Reading

Jordahl, K. et al. (2024). *geopandas: Python tools for geographic data*. https://geopandas.org/

Tenkanen, H., Heikinheimo, V., and Whipp, D. (2024). *Introduction to Python for Geographic Data Analysis*. CRC Press. https://pythongis.org/

Dorman, M., Graser, A., Nowosad, J., and Lovelace, R. (2025). *Geocomputation with Python*. CRC Press. https://py.geocompx.org/

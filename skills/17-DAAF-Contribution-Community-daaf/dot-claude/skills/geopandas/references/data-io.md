# Spatial Data I/O

Reading and writing spatial data in geopandas — file formats, engines, web data sources, and spatial databases.

---

## File Format Comparison

| Format | Extension | Strengths | Weaknesses | Recommendation |
|--------|-----------|-----------|------------|----------------|
| **GeoPackage** | `.gpkg` | Multi-layer, no file limits, SQL-based, open standard | Slightly larger than Shapefile | **Default for vector files** |
| **GeoParquet** | `.parquet` | Columnar, fast reads, compact, column selection | Newer format, less universal GIS support | **Default for analytical pipelines** |
| **Shapefile** | `.shp` + sidecar files | Universal GIS support | 2GB limit, 10-char column names, no nulls, multi-file | **Legacy only — avoid for new work** |
| **GeoJSON** | `.geojson` | Human-readable, web-native | Verbose, slow for large data, WGS84 only by spec | **Web exchange only** |
| **FlatGeobuf** | `.fgb` | Fast streaming, spatial index built-in | Less tooling support | **Large files needing spatial filtering** |
| **GeoFeather** | `.feather` | Very fast reads/writes via Arrow | Less adoption than GeoParquet | **Local caching** |

---

## The pyogrio Engine

Since geopandas 1.0, **pyogrio** is the default I/O engine (replacing fiona). It is 5-10x faster for most operations because it uses GDAL's vectorized column-oriented reading.

```python
# pyogrio is used automatically — no explicit engine needed
gdf = gpd.read_file("data.gpkg")

# Explicitly specify engine if needed
gdf = gpd.read_file("data.gpkg", engine="pyogrio")

# Use Arrow for even faster reads (returns Arrow-backed geometries)
gdf = gpd.read_file("data.gpkg", engine="pyogrio", use_arrow=True)

# Fall back to fiona if needed (must be installed separately)
gdf = gpd.read_file("data.gpkg", engine="fiona")
```

### pyogrio Direct Usage

For maximum control or when not using GeoDataFrames:

```python
import pyogrio

# List layers in a file
pyogrio.list_layers("multi_layer.gpkg")

# Read file info without loading data
info = pyogrio.read_info("data.gpkg")
print(info)  # CRS, geometry type, feature count, bounds, etc.

# Read to Arrow for interop with other tools
table = pyogrio.read_arrow("data.gpkg")
```

---

## Reading Vector Data

### Standard Read

```python
gdf = gpd.read_file("counties.gpkg")
```

### Filtered Reads (Essential for Large Files)

```python
# Bounding box filter — only features intersecting the box
gdf = gpd.read_file("us_counties.gpkg", bbox=(-80, 35, -75, 40))

# Geometry mask — only features intersecting a geometry
from shapely.geometry import box
mask = box(-80, 35, -75, 40)
gdf = gpd.read_file("us_counties.gpkg", mask=mask)

# Column filter — read only needed columns (reduces memory)
gdf = gpd.read_file("us_counties.gpkg", columns=["GEOID", "NAME", "POP", "geometry"])

# Row limit — read a sample
gdf = gpd.read_file("us_counties.gpkg", rows=100)

# Specific layer from multi-layer file
gdf = gpd.read_file("census.gpkg", layer="tracts")

# SQL-based filter (with pyogrio engine)
gdf = gpd.read_file("us_counties.gpkg", where="STATE_FIPS = '06'")
```

### Reading GeoParquet

GeoParquet is the best format for analytical workflows — columnar storage enables fast column selection, predicate pushdown, and compact storage.

```python
gdf = gpd.read_parquet("counties.parquet")

# Column selection (only reads selected columns from disk)
gdf = gpd.read_parquet("counties.parquet", columns=["GEOID", "NAME", "geometry"])

# Bounding box filter
gdf = gpd.read_parquet("counties.parquet", bbox=(-80, 35, -75, 40))

# From cloud storage (requires fsspec + storage backend)
gdf = gpd.read_parquet("s3://bucket/counties.parquet")
```

### Reading GeoFeather

```python
gdf = gpd.read_feather("counties.feather")
gdf = gpd.read_feather("counties.feather", columns=["GEOID", "geometry"])
```

---

## Writing Vector Data

### To Standard Formats

```python
# GeoPackage (recommended)
gdf.to_file("output.gpkg", driver="GPKG")

# GeoPackage with specific layer name
gdf.to_file("output.gpkg", driver="GPKG", layer="counties")

# Append to existing GeoPackage
gdf.to_file("output.gpkg", driver="GPKG", layer="new_layer", mode="a")

# Shapefile (legacy)
gdf.to_file("output.shp")

# GeoJSON
gdf.to_file("output.geojson", driver="GeoJSON")

# FlatGeobuf
gdf.to_file("output.fgb", driver="FlatGeobuf")
```

### To GeoParquet (Preferred for Pipelines)

```python
gdf.to_parquet("output.parquet")

# With compression
gdf.to_parquet("output.parquet", compression="snappy")  # default
gdf.to_parquet("output.parquet", compression="zstd")     # better compression
```

### To GeoFeather

```python
gdf.to_feather("output.feather")
```

### To Other Formats

```python
# GeoJSON string (for web APIs)
geojson_str = gdf.to_json()

# Well-Known Text (WKT)
gdf["wkt"] = gdf.geometry.to_wkt()

# Well-Known Binary (WKB)
gdf["wkb"] = gdf.geometry.to_wkb()
```

---

## Web Data Sources

### OpenStreetMap via osmnx

```python
import osmnx as ox

# Download street network
G = ox.graph_from_place("Washington, DC", network_type="drive")

# Download building footprints
buildings = ox.features_from_place("Washington, DC", tags={"building": True})

# Download specific POIs
schools = ox.features_from_place("Washington, DC", tags={"amenity": "school"})

# Download administrative boundary
dc = ox.geocode_to_gdf("Washington, DC")
```

### Census Boundaries via pygris

```python
import pygris

# Download county boundaries
counties = pygris.counties(year=2022)

# Download census tracts for a state
tracts = pygris.tracts(state="DC", year=2022)

# Download school districts
districts = pygris.school_districts(state="VA", year=2022)

# Download block groups
bgs = pygris.block_groups(state="MD", county="031", year=2022)
```

### Census Boundaries via Direct URL

```python
# TIGER/Line Shapefiles (direct download)
url = "https://www2.census.gov/geo/tiger/TIGER2022/COUNTY/tl_2022_us_county.zip"
counties = gpd.read_file(url)
```

### Natural Earth (Global Boundaries)

```python
# Via URL
url = "https://naciscdn.org/naturalearth/110m/cultural/ne_110m_admin_0_countries.zip"
world = gpd.read_file(url)
```

### WFS (Web Feature Service)

```python
# Example WFS endpoint
wfs_url = "https://example.com/wfs?service=WFS&version=2.0.0&request=GetFeature&typeName=layer_name&outputFormat=application/json"
gdf = gpd.read_file(wfs_url)
```

---

## Spatial Databases

### PostGIS

```python
from sqlalchemy import create_engine

engine = create_engine("postgresql://user:pass@host:5432/dbname")

# Read from PostGIS
gdf = gpd.read_postgis(
    "SELECT * FROM counties WHERE state_fips = '06'",
    con=engine,
    geom_col="geom"
)

# Write to PostGIS
gdf.to_postgis("counties_clean", engine, if_exists="replace")
```

### DuckDB Spatial

```python
import duckdb

con = duckdb.connect()
con.install_extension("spatial")
con.load_extension("spatial")

# Read spatial data via DuckDB
result = con.execute("""
    SELECT *, ST_AsWKB(geom) as geometry
    FROM read_parquet('counties.parquet')
    WHERE state_fips = '06'
""").fetchdf()

# Convert to GeoDataFrame
gdf = gpd.GeoDataFrame(
    result.drop(columns=["geometry"]),
    geometry=gpd.GeoSeries.from_wkb(result["geometry"]),
    crs="EPSG:4326"
)
```

---

## Format Selection Guide

```
What's the use case?
├─ Analytical pipeline (parquet ecosystem) → GeoParquet
├─ GIS interoperability (QGIS, ArcGIS) → GeoPackage
├─ Web display / API response → GeoJSON
├─ Streaming large files over network → FlatGeobuf
├─ Local temporary cache → GeoFeather
├─ Must support legacy GIS tools → Shapefile (reluctantly)
└─ Multi-layer container → GeoPackage
```

---

## References and Further Reading

Jordahl, K. et al. (2024). *geopandas I/O documentation*. https://geopandas.org/en/stable/docs/user_guide/io.html

pyogrio documentation. https://pyogrio.readthedocs.io/

GeoParquet specification. https://geoparquet.org/

Tenkanen, H., Heikinheimo, V., and Whipp, D. (2024). *Introduction to Python for Geographic Data Analysis*, Ch. 6: "Reading and writing spatial data." https://pythongis.org/

Boeing, G. (2017). "OSMnx: New methods for acquiring, constructing, analyzing, and visualizing complex street networks." *Computers, Environment and Urban Systems*, 65, 126-139.

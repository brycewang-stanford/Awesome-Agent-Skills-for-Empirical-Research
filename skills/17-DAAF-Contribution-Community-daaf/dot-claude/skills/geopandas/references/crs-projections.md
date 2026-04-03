# CRS and Projections

Coordinate Reference System handling in geopandas — checking, setting, transforming, and choosing projections. Getting the CRS right is a prerequisite for correct spatial operations; getting it wrong produces silently wrong results.

---

## CRS Fundamentals

### Geographic vs Projected CRS

| Property | Geographic CRS | Projected CRS |
|----------|---------------|---------------|
| Coordinates | Longitude/latitude (degrees) | Easting/northing (meters or feet) |
| Earth model | 3D ellipsoid | 2D flat plane |
| Standard example | WGS84 (EPSG:4326) | NAD83 Conus Albers (EPSG:5070) |
| Distance units | Decimal degrees (not constant!) | Meters (constant within valid region) |
| Area calculation | Wrong — 1 degree varies by latitude | Correct (within projection's valid region) |

**The critical rule:** Buffer, area, distance, and centroid operations on a geographic CRS (longitude/latitude) produce wrong or misleading results because one degree of longitude varies from ~111 km at the equator to ~0 km at the poles. Always reproject to an appropriate projected CRS before computing.

---

## Checking CRS

```python
# Check the current CRS
print(gdf.crs)
# Output: EPSG:4326 (or the full WKT2 string)

# Check EPSG code
print(gdf.crs.to_epsg())
# Output: 4326

# Check if geographic (lon/lat) or projected
print(gdf.crs.is_geographic)
# Output: True

print(gdf.crs.is_projected)
# Output: False

# Check the axis units
print(gdf.crs.axis_info)
# Shows units (degree vs metre)

# Detailed CRS information
print(gdf.crs.to_wkt(pretty=True))
```

---

## Setting CRS (Declaring, Not Transforming)

**Setting** a CRS tells geopandas what system the coordinates are already in. No coordinate values change. Use this when data arrives without CRS metadata (common with CSV files containing lat/lon columns).

```python
# Set CRS on creation
gdf = gpd.GeoDataFrame(df, geometry=gpd.points_from_xy(df.lon, df.lat), crs="EPSG:4326")

# Set CRS on existing GeoDataFrame (no CRS currently set)
gdf = gdf.set_crs("EPSG:4326")

# Override an incorrect CRS (use cautiously — you're saying "the existing CRS label is wrong")
gdf = gdf.set_crs("EPSG:4326", allow_override=True)
```

**When to use `set_crs`:** Only when the GeoDataFrame has no CRS (`gdf.crs is None`) or when you know the existing CRS label is incorrect. If the data already has a CRS and you want to change the projection, use `to_crs` instead.

---

## Reprojecting (Transforming Coordinates)

**Reprojecting** recomputes all coordinate values from one CRS to another. Use this when you need a different projection for analysis or visualization.

```python
# Reproject to NAD83 Conus Albers (equal-area, good for US maps)
gdf_albers = gdf.to_crs(epsg=5070)

# Reproject using CRS string
gdf_utm = gdf.to_crs("EPSG:32617")

# Reproject using PROJ string (less common)
gdf_custom = gdf.to_crs("+proj=aea +lat_1=29.5 +lat_2=45.5 +lat_0=37.5 +lon_0=-96")

# Reproject to match another GeoDataFrame's CRS
gdf_matched = gdf.to_crs(other_gdf.crs)
```

### Setting vs Transforming: The Difference

```python
# WRONG: Using set_crs to "reproject" — coordinates don't change, CRS label changes
# This makes the data plot in the wrong location
gdf_wrong = gdf.set_crs("EPSG:5070")  # DON'T DO THIS if gdf is in EPSG:4326

# RIGHT: Using to_crs to reproject — coordinates are recomputed
gdf_right = gdf.to_crs(epsg=5070)     # Coordinates change, CRS changes
```

---

## Choosing a Projection

### Decision Guide

```
What does your analysis need?
├─ Area calculations or thematic maps
│   └─ Equal-area projection
│       ├─ Continental US → EPSG:5070 (NAD83 Conus Albers)
│       ├─ Single state → State Plane (equal-area variant) or LAEA
│       ├─ Global → Mollweide or Equal Earth
│       └─ Custom study area → LAEA centered on study centroid
├─ Distance or local-scale analysis (<500 km)
│   └─ UTM zone for study area
│       Use pyproj to find the right zone:
│       from pyproj import CRS
│       CRS.from_authority("EPSG", pyproj.database.query_utm_crs_info(
│           datum_name="WGS 84", area_of_interest=pyproj.aoi.AreaOfInterest(
│               west_lon_degree=-77, south_lat_degree=38,
│               east_lon_degree=-76, north_lat_degree=39))[0].code)
├─ Web map display
│   └─ Web Mercator (EPSG:3857) — display only, never for analysis
├─ Data storage or exchange
│   └─ WGS84 (EPSG:4326)
└─ Unsure
    └─ Start with EPSG:5070 for US, UTM for local
```

### Common US Projections

| EPSG | Name | Best For | Units |
|------|------|----------|-------|
| 4326 | WGS84 | Storage, exchange (not analysis) | Degrees |
| 5070 | NAD83 Conus Albers | Continental US thematic maps, area calculations | Meters |
| 3857 | Web Mercator | Web tile display only | Meters (distorted) |
| 32617 | UTM Zone 17N | US East Coast local analysis | Meters |
| 32610 | UTM Zone 10N | US West Coast local analysis | Meters |
| 2163 | US National Atlas (deprecated; prefer 9311) | General US reference maps | Meters |

### State Plane Coordinate Systems

Each US state has one or more State Plane zones optimized for local accuracy. Find the right one:

```python
import pyproj

# List available State Plane CRS for a state
results = pyproj.database.query_crs_info(
    auth_name="EPSG",
    area_of_interest=pyproj.aoi.AreaOfInterest(
        west_lon_degree=-78.0, south_lat_degree=38.0,
        east_lon_degree=-75.0, north_lat_degree=40.0
    ),
    crs_types=["PROJECTED_CRS"]
)
# Filter results for "State Plane" in the name
```

### Custom LAEA (Lambert Azimuthal Equal-Area)

For study areas not well-served by standard projections, create a custom equal-area projection centered on your data:

```python
# Center the projection on your study area
centroid = gdf.to_crs(epsg=4326).dissolve().centroid.iloc[0]
custom_crs = f"+proj=laea +lat_0={centroid.y} +lon_0={centroid.x} +datum=WGS84 +units=m"
gdf_custom = gdf.to_crs(custom_crs)
```

---

## CRS Matching Before Spatial Operations

All spatial operations (join, overlay, distance, etc.) require both inputs to be in the same CRS. geopandas raises a `CRSMismatchError` if they differ.

```python
# Check if two GeoDataFrames share the same CRS
if gdf1.crs == gdf2.crs:
    result = gpd.sjoin(gdf1, gdf2)
else:
    # Reproject one to match the other
    gdf2_reprojected = gdf2.to_crs(gdf1.crs)
    result = gpd.sjoin(gdf1, gdf2_reprojected)
```

### Best Practice: Reproject Early

```python
# Standard workflow: reproject all inputs to a common CRS at the start
TARGET_CRS = "EPSG:5070"

counties = gpd.read_file("counties.gpkg").to_crs(TARGET_CRS)
schools = gpd.read_file("schools.gpkg").to_crs(TARGET_CRS)
tracts = gpd.read_file("tracts.gpkg").to_crs(TARGET_CRS)

# Now all spatial operations work without CRS concerns
```

---

## pyproj CRS Objects

geopandas uses pyproj for CRS handling. The `pyproj.CRS` object provides rich CRS information:

```python
from pyproj import CRS

# Create from EPSG
crs = CRS.from_epsg(5070)

# Create from PROJ string
crs = CRS.from_proj4("+proj=aea +lat_1=29.5 +lat_2=45.5 +lon_0=-96 +datum=NAD83")

# Create from WKT
crs = CRS.from_wkt(wkt_string)

# Inspect properties
print(crs.name)             # NAD83 / Conus Albers
print(crs.is_geographic)    # False
print(crs.is_projected)     # True
print(crs.axis_info)        # Axis names, directions, units
print(crs.area_of_use)      # Valid geographic extent
print(crs.to_epsg())        # 5070

# Get UTM zone for a point
from pyproj import database
utm_results = database.query_utm_crs_info(
    datum_name="WGS 84",
    area_of_interest=pyproj.aoi.AreaOfInterest(
        west_lon_degree=-77.1, south_lat_degree=38.8,
        east_lon_degree=-76.9, north_lat_degree=39.0
    )
)
print(f"EPSG:{utm_results[0].code}")  # e.g., EPSG:32618
```

---

## Common CRS Pitfalls

| Pitfall | Symptom | Fix |
|---------|---------|-----|
| Area computed in geographic CRS | Areas in square degrees (tiny numbers) | Reproject to equal-area CRS first |
| Buffer in degrees | Circular buffers become elliptical | Reproject to projected CRS first |
| Distance in degrees | Values like 0.01 instead of 1000 m | Reproject to projected CRS first |
| `set_crs` used instead of `to_crs` | Data plots in wrong hemisphere/location | Use `to_crs` to reproject |
| Web Mercator for analysis | Areas wildly wrong (Greenland = Africa) | Use equal-area projection |
| Missing CRS after pandas operation | `gdf.crs` is None | Re-set CRS: `gdf = gdf.set_crs("EPSG:4326")` |
| Mixed CRS in spatial join | `CRSMismatchError` | Reproject to common CRS |

---

## References and Further Reading

Dorman, M., Graser, A., Nowosad, J., and Lovelace, R. (2025). *Geocomputation with Python*, Chs. 1 and 6: "Geographic data" and "Reprojecting geographic data." https://py.geocompx.org/

Tenkanen, H., Heikinheimo, V., and Whipp, D. (2024). *Introduction to Python for Geographic Data Analysis*, Ch. 5: "Map projections." https://pythongis.org/

pyproj documentation. https://pyproj4.github.io/pyproj/

Battersby, S. (2017). "Map Projections." *The Geographic Information Science & Technology Body of Knowledge*. https://gistbok.ucgis.org/

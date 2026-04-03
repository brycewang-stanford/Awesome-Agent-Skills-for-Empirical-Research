# Raster Integration

Working with raster data alongside geopandas — reading GeoTIFFs with rasterio, multidimensional rasters with xarray/rioxarray, zonal statistics, and raster-vector conversion.

---

## Rasterio Basics

rasterio provides Python access to GDAL's raster I/O. It reads and writes GeoTIFF and other raster formats.

### Reading a GeoTIFF

```python
import rasterio
import numpy as np

with rasterio.open("elevation.tif") as src:
    # Metadata
    print(src.crs)          # CRS
    print(src.bounds)       # BoundingBox(left, bottom, right, top)
    print(src.res)          # (pixel_width, pixel_height)
    print(src.shape)        # (rows, cols)
    print(src.count)        # Number of bands
    print(src.dtypes)       # Data type per band
    print(src.nodata)       # NoData value
    print(src.transform)    # Affine transform (pixel→world coordinates)

    # Read band data as NumPy array
    band1 = src.read(1)     # Read band 1 (1-indexed)
    all_bands = src.read()  # Read all bands: shape (bands, rows, cols)
```

### Reading a Window (Subset)

```python
from rasterio.windows import from_bounds

with rasterio.open("large_raster.tif") as src:
    # Read only a geographic extent
    window = from_bounds(
        left=-78.0, bottom=38.0, right=-76.0, top=40.0,
        transform=src.transform
    )
    subset = src.read(1, window=window)
```

### Writing a GeoTIFF

```python
import rasterio
from rasterio.transform import from_bounds
import numpy as np

data = np.random.rand(100, 100).astype(np.float32)

with rasterio.open(
    "output.tif",
    mode="w",
    driver="GTiff",
    height=data.shape[0],
    width=data.shape[1],
    count=1,                    # Number of bands
    dtype=data.dtype,
    crs="EPSG:4326",
    transform=from_bounds(-78, 38, -76, 40, data.shape[1], data.shape[0]),
    nodata=-9999
) as dst:
    dst.write(data, 1)         # Write to band 1
```

### Masking Raster by Polygon

```python
import rasterio
from rasterio.mask import mask
import geopandas as gpd

gdf = gpd.read_file("study_area.gpkg")
geometries = gdf.geometry.values

with rasterio.open("raster.tif") as src:
    # Clip raster to polygon boundaries
    out_image, out_transform = mask(
        src,
        geometries,
        crop=True,        # Crop to geometry extent
        nodata=-9999,     # Fill outside with NoData
        all_touched=False # Only cells whose center is inside
    )
    out_meta = src.meta.copy()
    out_meta.update({
        "height": out_image.shape[1],
        "width": out_image.shape[2],
        "transform": out_transform
    })

# Write clipped raster
with rasterio.open("clipped.tif", "w", **out_meta) as dst:
    dst.write(out_image)
```

### Extracting Values at Points

```python
import rasterio
import geopandas as gpd

points = gpd.read_file("sample_points.gpkg")

with rasterio.open("temperature.tif") as src:
    # Ensure same CRS
    points_proj = points.to_crs(src.crs)

    # Sample raster at each point location
    coords = [(pt.x, pt.y) for pt in points_proj.geometry]
    values = [val[0] for val in src.sample(coords)]

    points["temperature"] = values
```

---

## xarray + rioxarray

For multidimensional rasters (multiple bands, time series, or named dimensions), xarray with the rioxarray extension provides a higher-level interface.

### Installation

```bash
pip install xarray rioxarray netcdf4
```

### Reading Rasters

```python
import xarray as xr
import rioxarray  # Extends xarray with .rio accessor

# Read a GeoTIFF
ds = xr.open_dataarray("temperature.tif", engine="rasterio")
# or
ds = rioxarray.open_rasterio("temperature.tif")

# Inspect
print(ds.dims)       # ('band', 'y', 'x')
print(ds.rio.crs)    # CRS
print(ds.rio.bounds())  # Bounding box
print(ds.rio.resolution())  # Pixel size
```

### CRS Operations

```python
# Reproject
ds_proj = ds.rio.reproject("EPSG:5070")

# Set CRS (if missing)
ds = ds.rio.write_crs("EPSG:4326")
```

### Clipping by Polygon

```python
import geopandas as gpd

gdf = gpd.read_file("study_area.gpkg")

# Clip raster to polygon
ds_clipped = ds.rio.clip(gdf.geometry, gdf.crs)

# Clip to bounding box
ds_bbox = ds.rio.clip_box(minx=-78, miny=38, maxx=-76, maxy=40)
```

### Writing

```python
ds.rio.to_raster("output.tif")
```

### NetCDF / Multi-Temporal Rasters

```python
# Read NetCDF with time dimension
ds = xr.open_dataset("climate_data.nc")

# Select a time slice
temp_jan = ds["temperature"].sel(time="2024-01")

# Spatial operations on each time step
ds_proj = ds.rio.reproject("EPSG:5070")
```

---

## Zonal Statistics

Zonal statistics summarize raster cell values within vector polygon boundaries — for example, computing mean elevation within each county.

### Using rasterstats

```python
from rasterstats import zonal_stats
import geopandas as gpd

counties = gpd.read_file("counties.gpkg")

# Basic zonal statistics
stats = zonal_stats(
    counties,                    # Vector polygons (GeoDataFrame or path)
    "temperature.tif",           # Raster (path or numpy array)
    stats=["mean", "min", "max", "std", "count", "median"]
)
# Returns: list of dicts, one per polygon
# [{'mean': 15.2, 'min': 8.1, 'max': 22.4, ...}, ...]

# Merge back to GeoDataFrame
import pandas as pd
stats_df = pd.DataFrame(stats)
counties_with_stats = pd.concat([counties, stats_df], axis=1)
```

### Zonal Statistics Parameters

```python
zonal_stats(
    vectors,                # Polygons (GeoDataFrame, path, or GeoJSON)
    raster,                 # Raster (path or ndarray + affine transform)
    stats=["mean", "sum"],  # Statistics to compute
    all_touched=False,      # Include cells that touch boundary (not just center-in)
    nodata=None,            # Override raster NoData value
    categorical=False,      # For categorical rasters: count per category
    category_map=None,      # Map raster values to labels
    band=1,                 # Which raster band
    geojson_out=False,      # Return GeoJSON features
    prefix=""               # Prefix for output column names
)
```

### Available Statistics

| Stat | Meaning |
|------|---------|
| `count` | Number of valid (non-NoData) cells |
| `nodata` | Number of NoData cells |
| `min`, `max` | Minimum, maximum |
| `mean`, `median` | Central tendency |
| `sum` | Total (for count-based variables) |
| `std` | Standard deviation |
| `majority`, `minority` | Most/least common value |
| `unique` | Number of unique values |
| `range` | max - min |
| `percentile_25`, etc. | Custom percentiles |

### Choosing the Right Statistic

| Variable Type | Correct Stat | Example |
|--------------|-------------|---------|
| Count/total (population) | `sum` | Total population in each county |
| Rate/density (temperature) | `mean` or `median` | Average temperature per county |
| Extremes (flood risk) | `min`, `max` | Highest elevation in each district |
| Categorical (land use) | `majority`, categorical=True | Dominant land use type |

### Categorical Zonal Statistics

```python
# Count pixels per land use class within each polygon
stats = zonal_stats(
    counties,
    "landuse.tif",
    categorical=True,
    category_map={1: "urban", 2: "forest", 3: "water", 4: "agriculture"}
)
# Returns: [{'urban': 450, 'forest': 1200, 'water': 50, 'agriculture': 800}, ...]
```

### Data Completeness Check

Always report how many cells contributed to each polygon's statistics:

```python
stats = zonal_stats(counties, "raster.tif", stats=["mean", "count", "nodata"])
stats_df = pd.DataFrame(stats)

# Flag polygons with too few cells (unreliable statistics)
stats_df["reliable"] = stats_df["count"] >= 10
print(f"Unreliable polygons: {(~stats_df['reliable']).sum()}")
```

---

## Raster-Vector Conversion

### Rasterize (Vector to Raster)

Convert vector features to a raster grid:

```python
from rasterio.features import rasterize
from rasterio.transform import from_bounds
import numpy as np

# Define output grid
transform = from_bounds(*gdf.total_bounds, width=1000, height=1000)

# Burn values from a column
shapes = [(geom, val) for geom, val in zip(gdf.geometry, gdf["population"])]
raster = rasterize(
    shapes,
    out_shape=(1000, 1000),
    transform=transform,
    fill=0,                  # Background value
    dtype=np.float32,
    all_touched=False
)
```

### Vectorize (Raster to Vector)

Convert raster cells to vector polygons:

```python
from rasterio.features import shapes
import geopandas as gpd
from shapely.geometry import shape

with rasterio.open("classified.tif") as src:
    image = src.read(1)
    mask = image != src.nodata

    results = [
        {"geometry": shape(geom), "value": val}
        for geom, val in shapes(image, mask=mask, transform=src.transform)
    ]

gdf = gpd.GeoDataFrame(results, crs=src.crs)
```

---

## CRS Matching Between Raster and Vector

Raster and vector data must be in the same CRS for zonal statistics, masking, and extraction. Always verify:

```python
import rasterio
import geopandas as gpd

gdf = gpd.read_file("polygons.gpkg")

with rasterio.open("raster.tif") as src:
    if gdf.crs != src.crs:
        gdf = gdf.to_crs(src.crs)
    # Now safe to use together
```

---

## References and Further Reading

Gillies, S. et al. (2024). *rasterio: Fast and direct raster I/O for Python*. https://rasterio.readthedocs.io/

Hoyer, S. and Hamman, J. (2017). "xarray: N-D labeled arrays and datasets in Python." *Journal of Open Research Software*, 5(1), 10.

Snow, A. et al. (2024). *rioxarray: xarray extension for rasterio*. https://corteva.github.io/rioxarray/

Perry, M. (2024). *rasterstats: Summary statistics of geospatial raster datasets based on vector geometries*. https://pythonhosted.org/rasterstats/

Dorman, M., Graser, A., Nowosad, J., and Lovelace, R. (2025). *Geocomputation with Python*, Chs. 5-6: "Raster-vector interactions" and "Reprojecting geographic data." https://py.geocompx.org/

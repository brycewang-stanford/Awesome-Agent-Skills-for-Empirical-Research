---
name: satellite-remote-sensing
description: "Satellite imagery analysis and remote sensing for earth science research"
metadata:
  openclaw:
    emoji: "🛰️"
    category: "domains"
    subcategory: "geoscience"
    keywords: ["remote-sensing", "satellite", "geospatial", "landsat", "sentinel", "gis", "earth-observation"]
    source: "wentor"
---

# Satellite Remote Sensing

A skill for processing and analyzing satellite imagery for earth science research. Covers data acquisition from major satellite platforms, preprocessing workflows, spectral index computation, land cover classification, and change detection using Python geospatial tools.

## Satellite Data Sources

### Major Earth Observation Missions

| Mission | Operator | Resolution | Revisit | Key Bands | Access |
|---------|----------|-----------|---------|-----------|--------|
| Landsat 8/9 | USGS/NASA | 30m (MS), 15m (pan) | 16 days | 11 bands, OLI+TIRS | Free (USGS EarthExplorer) |
| Sentinel-2 | ESA | 10m-60m | 5 days | 13 bands, MSI | Free (Copernicus Open Access Hub) |
| MODIS | NASA | 250m-1km | 1-2 days | 36 bands | Free (NASA LAADS DAAC) |
| Sentinel-1 | ESA | 5-20m | 6 days | C-band SAR | Free (Copernicus) |
| GOES-16/17 | NOAA | 0.5-2km | 5-15 min | 16 bands, ABI | Free (NOAA CLASS) |

### Programmatic Data Access

```python
import planetary_computer
import pystac_client
import rioxarray

# Search Sentinel-2 imagery via Microsoft Planetary Computer
catalog = pystac_client.Client.open(
    "https://planetarycomputer.microsoft.com/api/stac/v1",
    modifier=planetary_computer.sign_inplace,
)

# Search for cloud-free imagery over a region
search = catalog.search(
    collections=["sentinel-2-l2a"],
    bbox=[11.0, 46.0, 12.0, 47.0],  # Tyrol, Austria
    datetime="2025-06-01/2025-08-31",
    query={"eo:cloud_cover": {"lt": 10}},
)

items = search.item_collection()
print(f"Found {len(items)} scenes with <10% cloud cover")

# Load a specific band as xarray DataArray
item = items[0]
red = rioxarray.open_rasterio(item.assets["B04"].href)
nir = rioxarray.open_rasterio(item.assets["B08"].href)
```

## Preprocessing Pipeline

### Atmospheric Correction

Raw satellite data (Level-1) must be atmospherically corrected to obtain surface reflectance (Level-2):

- **Sentinel-2**: Use Sen2Cor processor (ESA) or download pre-processed L2A products
- **Landsat**: Collection 2 Level-2 products include surface reflectance
- **Custom correction**: Use 6S radiative transfer model via Py6S

```python
# Cloud masking for Sentinel-2 using the SCL band
import numpy as np

def mask_clouds_sentinel2(scl_band: np.ndarray) -> np.ndarray:
    """
    Create cloud mask from Sentinel-2 Scene Classification Layer.
    SCL values: 0=no_data, 1=saturated, 2=dark_area, 3=cloud_shadow,
    4=vegetation, 5=bare_soil, 6=water, 7=unclassified,
    8=cloud_medium, 9=cloud_high, 10=cirrus, 11=snow
    """
    cloud_classes = {0, 1, 3, 8, 9, 10}
    mask = np.isin(scl_band, list(cloud_classes))
    return mask  # True where clouds/invalid
```

### Geometric Correction and Mosaicking

```python
import rasterio
from rasterio.merge import merge
from rasterio.warp import calculate_default_transform, reproject, Resampling

def reproject_raster(src_path: str, dst_path: str, dst_crs: str = "EPSG:4326"):
    """Reproject a raster to a target coordinate reference system."""
    with rasterio.open(src_path) as src:
        transform, width, height = calculate_default_transform(
            src.crs, dst_crs, src.width, src.height, *src.bounds
        )
        kwargs = src.meta.copy()
        kwargs.update({
            "crs": dst_crs,
            "transform": transform,
            "width": width,
            "height": height,
        })
        with rasterio.open(dst_path, "w", **kwargs) as dst:
            for i in range(1, src.count + 1):
                reproject(
                    source=rasterio.band(src, i),
                    destination=rasterio.band(dst, i),
                    src_transform=src.transform,
                    src_crs=src.crs,
                    dst_transform=transform,
                    dst_crs=dst_crs,
                    resampling=Resampling.bilinear,
                )
```

## Spectral Indices

### Vegetation and Water Indices

```python
def compute_indices(red: np.ndarray, nir: np.ndarray,
                    green: np.ndarray, swir: np.ndarray) -> dict:
    """
    Compute common spectral indices from surface reflectance bands.
    All inputs should be float arrays with values in [0, 1].
    """
    eps = 1e-10  # avoid division by zero
    ndvi = (nir - red) / (nir + red + eps)
    ndwi = (green - nir) / (green + nir + eps)
    nbr = (nir - swir) / (nir + swir + eps)
    evi = 2.5 * (nir - red) / (nir + 6 * red - 7.5 * 0.0001 + 1 + eps)
    savi = 1.5 * (nir - red) / (nir + red + 0.5 + eps)

    return {
        "NDVI": ndvi,   # vegetation vigor [-1, 1]
        "NDWI": ndwi,   # water bodies [-1, 1]
        "NBR": nbr,     # burn severity [-1, 1]
        "EVI": evi,     # enhanced vegetation
        "SAVI": savi,   # soil-adjusted vegetation
    }
```

### Index Interpretation

| Index | Range | Low Values | High Values |
|-------|-------|-----------|-------------|
| NDVI | -1 to 1 | Water, bare soil, clouds | Dense green vegetation |
| NDWI | -1 to 1 | Dry land | Open water bodies |
| NBR | -1 to 1 | Recently burned areas | Healthy vegetation |
| EVI | -1 to 1 | Non-vegetated | Dense canopy (less saturated than NDVI) |

## Land Cover Classification

### Supervised Classification with Random Forest

```python
from sklearn.ensemble import RandomForestClassifier
from sklearn.model_selection import cross_val_score

# Stack bands into feature array: (n_pixels, n_bands)
# training_labels: land cover classes from ground truth polygons
bands = np.stack([blue, green, red, nir, swir1, swir2, ndvi, ndwi], axis=-1)
n_rows, n_cols, n_bands = bands.shape
X = bands.reshape(-1, n_bands)

# Train Random Forest classifier
rf = RandomForestClassifier(n_estimators=200, max_depth=20, n_jobs=-1)
scores = cross_val_score(rf, X_train, y_train, cv=5, scoring="f1_macro")
print(f"5-fold F1: {scores.mean():.3f} +/- {scores.std():.3f}")

rf.fit(X_train, y_train)
classification = rf.predict(X).reshape(n_rows, n_cols)
```

## Change Detection

Multi-temporal analysis for detecting land cover changes (deforestation, urbanization, flood extent):

1. **Image differencing**: Subtract spectral index values between dates
2. **Post-classification comparison**: Classify each date independently, compare maps
3. **Change vector analysis**: Compute magnitude and direction of spectral change
4. **Time series analysis**: BFAST, LandTrendr for continuous monitoring

## Tools and Libraries

- **Rasterio / GDAL**: Raster I/O and geospatial transformations
- **xarray + rioxarray**: Labeled multi-dimensional array analysis
- **Google Earth Engine (GEE)**: Cloud-based planetary-scale analysis
- **QGIS**: Open-source GIS for visualization and manual digitization
- **Orfeo ToolBox (OTB)**: Advanced remote sensing processing chain
- **SentinelHub**: Commercial API for on-the-fly Sentinel processing

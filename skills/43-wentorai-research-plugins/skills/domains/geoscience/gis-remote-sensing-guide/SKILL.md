---
name: gis-remote-sensing-guide
description: "GIS analysis and remote sensing workflows for geospatial research applications"
metadata:
  openclaw:
    emoji: "🌎"
    category: "domains"
    subcategory: "geoscience"
    keywords: ["GIS", "remote sensing", "geology", "atmospheric science", "climatology", "geospatial analysis"]
    source: "wentor"
---

# GIS and Remote Sensing Guide

A comprehensive skill for conducting geospatial analysis and remote sensing research. Covers data acquisition from satellite platforms, spatial analysis with open-source tools, and publication-quality map production.

## Satellite Data Sources

### Key Earth Observation Platforms

| Platform | Provider | Spatial Res. | Revisit | Free? | Use Case |
|----------|----------|-------------|---------|-------|----------|
| Landsat 8/9 | USGS/NASA | 30m (MS), 15m (pan) | 16 days | Yes | Land cover, NDVI time series |
| Sentinel-2 | ESA/Copernicus | 10m | 5 days | Yes | Agriculture, urban mapping |
| MODIS | NASA | 250m-1km | 1-2 days | Yes | Large-scale vegetation, fire |
| Sentinel-1 | ESA | 5-20m | 6 days | Yes | SAR, flood mapping, deformation |
| SRTM/ASTER | NASA | 30m | N/A | Yes | Digital elevation models |

### Data Download with Python

```python
import ee

# Initialize Google Earth Engine
ee.Initialize()

def get_sentinel2_composite(aoi: ee.Geometry, start: str, end: str,
                             cloud_max: int = 20) -> ee.Image:
    """
    Create a cloud-free Sentinel-2 composite.

    Args:
        aoi: Area of interest as ee.Geometry
        start: Start date (YYYY-MM-DD)
        end: End date (YYYY-MM-DD)
        cloud_max: Maximum cloud cover percentage
    """
    collection = (ee.ImageCollection('COPERNICUS/S2_SR_HARMONIZED')
                  .filterBounds(aoi)
                  .filterDate(start, end)
                  .filter(ee.Filter.lt('CLOUDY_PIXEL_PERCENTAGE', cloud_max)))

    # Cloud masking using SCL band
    def mask_clouds(image):
        scl = image.select('SCL')
        mask = scl.neq(3).And(scl.neq(8)).And(scl.neq(9)).And(scl.neq(10))
        return image.updateMask(mask)

    return collection.map(mask_clouds).median().clip(aoi)

# Define study area
study_area = ee.Geometry.Rectangle([116.0, 39.5, 117.0, 40.5])  # Beijing region
composite = get_sentinel2_composite(study_area, '2024-06-01', '2024-09-30')
```

## Spatial Analysis with GeoPandas

### Vector Data Processing

```python
import geopandas as gpd
from shapely.geometry import Point

def spatial_join_analysis(points_gdf: gpd.GeoDataFrame,
                          polygons_gdf: gpd.GeoDataFrame,
                          agg_col: str) -> gpd.GeoDataFrame:
    """
    Perform spatial join and aggregate point data within polygons.
    """
    joined = gpd.sjoin(points_gdf, polygons_gdf, how='inner', predicate='within')
    summary = joined.groupby('index_right').agg(
        count=(agg_col, 'count'),
        mean_value=(agg_col, 'mean'),
        std_value=(agg_col, 'std')
    ).reset_index()
    result = polygons_gdf.merge(summary, left_index=True, right_on='index_right')
    return result

# Example: aggregate soil samples within administrative boundaries
soil_samples = gpd.read_file('soil_data.geojson')
admin_bounds = gpd.read_file('admin_boundaries.shp')
result = spatial_join_analysis(soil_samples, admin_bounds, 'pH_value')
```

## Remote Sensing Indices

### Vegetation and Water Indices

```python
import rasterio
import numpy as np

def compute_indices(image_path: str) -> dict:
    """Compute common remote sensing spectral indices."""
    with rasterio.open(image_path) as src:
        red = src.read(3).astype(float)    # Band 4 in Sentinel-2
        nir = src.read(4).astype(float)    # Band 8
        green = src.read(2).astype(float)  # Band 3
        swir = src.read(5).astype(float)   # Band 11

    # Normalized Difference Vegetation Index
    ndvi = (nir - red) / (nir + red + 1e-10)

    # Normalized Difference Water Index
    ndwi = (green - nir) / (green + nir + 1e-10)

    # Normalized Burn Ratio
    nbr = (nir - swir) / (nir + swir + 1e-10)

    return {'NDVI': ndvi, 'NDWI': ndwi, 'NBR': nbr}
```

## Map Production

For publication-quality maps, always include: scale bar, north arrow, coordinate reference system label, legend, and data source attribution. Use `matplotlib` with `cartopy` for projected maps, or `folium` for interactive web maps. Export at 300 DPI minimum for journal submissions.

## Coordinate Reference Systems

Always verify and document the CRS. Use EPSG codes (e.g., EPSG:4326 for WGS84, EPSG:32650 for UTM Zone 50N). Reproject all layers to a common CRS before spatial operations to avoid misalignment errors.

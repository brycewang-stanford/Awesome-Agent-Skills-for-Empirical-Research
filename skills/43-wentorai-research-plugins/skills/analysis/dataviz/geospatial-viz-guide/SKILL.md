---
name: geospatial-viz-guide
description: "Create maps, choropleths, and spatial data visualizations for research"
metadata:
  openclaw:
    emoji: "🗺️"
    category: "analysis"
    subcategory: "dataviz"
    keywords: ["geospatial", "choropleth", "maps", "GIS", "spatial visualization", "geopandas"]
    source: "wentor-research-plugins"
---

# Geospatial Visualization Guide

A skill for creating maps, choropleths, and spatial data visualizations for research publications. Covers coordinate systems, choropleth maps, point maps, Python geospatial libraries, and cartographic best practices for academic papers.

## Geospatial Data Fundamentals

### Common Spatial Data Formats

```
Vector data (discrete features):
  - Shapefile (.shp): Legacy standard, multi-file
  - GeoJSON (.geojson): Web-friendly, single file
  - GeoPackage (.gpkg): Modern SQLite-based, recommended
  - KML (.kml): Google Earth format

Raster data (continuous surfaces):
  - GeoTIFF (.tif): Georeferenced image
  - NetCDF (.nc): Climate and atmospheric data
  - HDF5 (.h5): Satellite and remote sensing data

Key concepts:
  - CRS (Coordinate Reference System): How 3D Earth maps to 2D
  - EPSG:4326 (WGS84): Latitude/longitude (most GPS data)
  - EPSG:3857: Web Mercator (Google Maps, web tiles)
  - Always check and document your CRS
```

## Choropleth Maps

### Building a Choropleth with GeoPandas

```python
import geopandas as gpd
import matplotlib.pyplot as plt


def create_choropleth(shapefile_path: str, data_column: str,
                      title: str, cmap: str = "YlOrRd") -> None:
    """
    Create a choropleth map from a shapefile.

    Args:
        shapefile_path: Path to shapefile or GeoPackage
        data_column: Column name to visualize
        title: Map title
        cmap: Matplotlib colormap name
    """
    gdf = gpd.read_file(shapefile_path)

    fig, ax = plt.subplots(1, 1, figsize=(12, 8))

    gdf.plot(
        column=data_column,
        cmap=cmap,
        linewidth=0.5,
        edgecolor="0.5",
        legend=True,
        legend_kwds={
            "label": data_column,
            "orientation": "horizontal",
            "shrink": 0.6,
            "pad": 0.05
        },
        ax=ax
    )

    ax.set_title(title, fontsize=14, fontweight="bold")
    ax.axis("off")
    plt.tight_layout()
    plt.savefig("choropleth.pdf", bbox_inches="tight", dpi=300)
```

### Joining Data to Geometries

```python
import pandas as pd


def join_data_to_map(gdf: gpd.GeoDataFrame,
                     data: pd.DataFrame,
                     geo_key: str,
                     data_key: str) -> gpd.GeoDataFrame:
    """
    Join tabular data to geographic features.

    Args:
        gdf: GeoDataFrame with polygons (e.g., country boundaries)
        data: DataFrame with your research data
        geo_key: Column in gdf to join on (e.g., 'ISO_A3')
        data_key: Column in data to join on (e.g., 'country_code')
    """
    merged = gdf.merge(data, left_on=geo_key, right_on=data_key, how="left")

    missing = merged[merged[data.columns[1]].isna()]
    if len(missing) > 0:
        print(f"Warning: {len(missing)} regions have no data (will appear blank)")

    return merged
```

## Point Maps and Proportional Symbols

### Mapping Research Sites or Events

```python
def create_point_map(gdf_base: gpd.GeoDataFrame,
                     points: gpd.GeoDataFrame,
                     size_column: str = None,
                     color_column: str = None) -> None:
    """
    Create a point map with proportional symbols.

    Args:
        gdf_base: Base map (country or region polygons)
        points: GeoDataFrame with point geometries
        size_column: Column to scale point sizes
        color_column: Column to color points
    """
    fig, ax = plt.subplots(figsize=(12, 8))

    # Base map
    gdf_base.plot(ax=ax, color="lightgray", edgecolor="white", linewidth=0.5)

    # Points
    sizes = points[size_column] * 2 if size_column else 30
    colors = points[color_column] if color_column else "red"

    points.plot(
        ax=ax,
        markersize=sizes,
        color=colors,
        alpha=0.6,
        edgecolor="black",
        linewidth=0.3
    )

    ax.axis("off")
    plt.tight_layout()
    plt.savefig("point_map.pdf", bbox_inches="tight", dpi=300)
```

## Interactive Maps with Folium

```python
import folium


def create_interactive_map(center: tuple = (20, 0),
                            zoom: int = 2) -> folium.Map:
    """
    Create an interactive web map (useful for supplementary materials).

    Args:
        center: (latitude, longitude) center point
        zoom: Initial zoom level
    """
    m = folium.Map(location=center, zoom_start=zoom,
                   tiles="CartoDB positron")

    # Add markers, choropleth layers, or heatmaps as needed
    # folium.Marker([lat, lon], popup="Label").add_to(m)

    return m
```

## Cartographic Best Practices

### Publication Standards

```
1. Projection choice:
   - Global maps: Robinson or Equal Earth (not Mercator for thematic maps)
   - Country/region: Appropriate local projection
   - Mercator distorts area -- misleading for choropleths

2. Color schemes:
   - Sequential: Low-to-high values (YlOrRd, Blues, Viridis)
   - Diverging: Values around a midpoint (RdBu, BrBG)
   - Qualitative: Categorical data (Set2, Paired)
   - Use colorbrewer2.org for perceptually uniform palettes
   - Test for colorblind accessibility

3. Required map elements:
   - Title
   - Legend with units
   - Scale bar
   - North arrow (if orientation is non-standard)
   - Data source attribution
   - CRS/projection information

4. Ethical considerations:
   - Disputed borders: Use dashed lines or note in caption
   - Data gaps: Show "no data" regions explicitly (do not leave blank)
   - Privacy: Aggregate point data to protect individual locations
```

## Free Data Sources

| Source | Data | Format |
|--------|------|--------|
| Natural Earth | Country/region boundaries, physical features | Shapefile, GeoJSON |
| GADM | Administrative boundaries (all countries, all levels) | GeoPackage, Shapefile |
| OpenStreetMap | Roads, buildings, land use | PBF, Shapefile |
| WorldPop | Population density grids | GeoTIFF |
| NASA SEDAC | Socioeconomic and environmental data | GeoTIFF, Shapefile |
| USGS Earth Explorer | Satellite imagery, elevation | GeoTIFF |

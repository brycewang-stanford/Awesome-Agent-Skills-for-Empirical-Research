# Spatial Visualization

Making maps with geopandas and the Python visualization ecosystem — static choropleths, classification schemes, basemap tiles, interactive maps, and GPU-accelerated rendering for large datasets.

---

## Static Maps with `.plot()`

geopandas `.plot()` wraps matplotlib for quick static maps.

### Basic Choropleth

```python
import matplotlib.pyplot as plt

fig, ax = plt.subplots(figsize=(12, 8))
gdf.plot(
    column="poverty_rate",    # Column to color by
    ax=ax,
    legend=True,
    cmap="YlOrRd",            # Colormap
    edgecolor="white",
    linewidth=0.3,
    missing_kwds={"color": "lightgrey", "label": "No data"}
)
ax.set_title("Poverty Rate by County", fontsize=14)
ax.set_axis_off()
plt.tight_layout()
plt.savefig("choropleth.png", dpi=300, bbox_inches="tight")
```

### Layered Map

```python
fig, ax = plt.subplots(figsize=(12, 8))

# Base layer: counties
counties.plot(ax=ax, color="lightyellow", edgecolor="gray", linewidth=0.5)

# Overlay: schools colored by enrollment
schools.plot(
    ax=ax,
    column="enrollment",
    cmap="Blues",
    markersize=10,
    legend=True,
    legend_kwds={"label": "Enrollment", "shrink": 0.6}
)

# Overlay: district boundaries
districts.plot(ax=ax, facecolor="none", edgecolor="red", linewidth=1.5)

ax.set_title("Schools by Enrollment")
ax.set_axis_off()
plt.tight_layout()
```

### Categorical Map

```python
gdf.plot(
    column="school_type",     # Categorical column
    categorical=True,
    legend=True,
    cmap="Set2",
    legend_kwds={"loc": "lower right", "fontsize": 8, "title": "Type"}
)
```

### Common Colormaps

| Category | Colormaps | Use For |
|----------|-----------|---------|
| Sequential | `YlOrRd`, `Blues`, `Greens`, `Purples`, `viridis` | Single-direction data (counts, rates) |
| Diverging | `RdBu`, `RdYlGn`, `coolwarm`, `BrBG` | Data with meaningful center (change, deviation) |
| Categorical | `Set1`, `Set2`, `tab10`, `Paired` | Distinct categories |

### Plot Parameters Quick Reference

| Parameter | Effect |
|-----------|--------|
| `column` | Column to color by |
| `cmap` | Colormap name |
| `legend` | Show legend (True/False) |
| `categorical` | Treat as categorical (True/False) |
| `scheme` | Classification scheme (requires mapclassify) |
| `k` | Number of classes |
| `edgecolor` | Border color |
| `linewidth` | Border width |
| `markersize` | Point size |
| `alpha` | Transparency (0-1) |
| `figsize` | Figure size tuple |
| `missing_kwds` | Dict for styling missing values |
| `legend_kwds` | Dict for legend customization |

---

## Classification Schemes (mapclassify)

mapclassify provides statistical classification methods for choropleth maps. Without classification, continuous color ramps can obscure patterns.

### Installation

```bash
pip install mapclassify
```

### Using with `.plot()`

```python
gdf.plot(
    column="poverty_rate",
    scheme="FisherJenks",   # Classification method
    k=5,                     # Number of classes
    cmap="YlOrRd",
    legend=True,
    legend_kwds={"loc": "lower right", "fontsize": 8}
)
```

### Available Schemes

| Scheme | How It Works | Best For |
|--------|-------------|----------|
| `Quantiles` | Equal number of observations per class | Ensuring visual balance; skewed distributions |
| `EqualInterval` | Equal range per class | Uniformly distributed data |
| `FisherJenks` | Minimizes within-class variance | General purpose — default recommendation |
| `NaturalBreaks` | Jenks optimization (similar to FisherJenks) | General purpose |
| `StdMean` | Classes based on standard deviations from mean | Highlighting deviation from average |
| `Percentiles` | Custom percentile boundaries | Specific breakpoints needed |
| `BoxPlot` | Based on IQR (outlier detection) | Highlighting extremes |
| `HeadTailBreaks` | For heavy-tailed distributions | Power-law distributed data |
| `MaximumBreaks` | Maximizes between-class differences | Unknown distribution |
| `UserDefined` | Custom breakpoints | Domain-specific thresholds |

### Direct mapclassify Usage

```python
import mapclassify

# Compute classification
classifier = mapclassify.FisherJenks(gdf["poverty_rate"], k=5)
print(classifier.bins)        # Class breakpoints
print(classifier.counts)      # Observations per class
print(classifier.adcm)        # Absolute deviation around class medians

# Apply custom classification
gdf["class"] = mapclassify.UserDefined(
    gdf["poverty_rate"],
    bins=[5, 10, 15, 20, 30]
).yb  # .yb = class labels (0-indexed)
```

### Choosing a Classification Scheme

```
What's your data distribution?
├─ Roughly uniform → EqualInterval
├─ Skewed (most values low, few high) → Quantiles or FisherJenks
├─ Heavy-tailed / power-law → HeadTailBreaks
├─ Need to show deviation from average → StdMean
├─ Domain-specific thresholds exist → UserDefined
└─ Unsure → FisherJenks (safest default)
```

---

## Basemap Tiles (contextily)

contextily adds web map tiles (OpenStreetMap, CartoDB, etc.) as background layers.

### Installation

```bash
pip install contextily
```

### Adding Basemaps

```python
import contextily as ctx
import matplotlib.pyplot as plt

fig, ax = plt.subplots(figsize=(12, 8))
gdf.to_crs(epsg=3857).plot(ax=ax, alpha=0.5, edgecolor="red")

# Add basemap tiles
ctx.add_basemap(ax, source=ctx.providers.CartoDB.Positron)
ax.set_axis_off()
```

**CRS requirement:** Basemap tiles are in Web Mercator (EPSG:3857). Either reproject your data to 3857 before plotting, or pass the `crs` parameter:

```python
# Option 1: Reproject data to 3857
gdf_3857 = gdf.to_crs(epsg=3857)
gdf_3857.plot(ax=ax)
ctx.add_basemap(ax)

# Option 2: Keep data in its CRS, let contextily handle reprojection
gdf.plot(ax=ax)
ctx.add_basemap(ax, crs=gdf.crs, source=ctx.providers.CartoDB.Positron)
```

### Popular Tile Providers

| Provider | Style | Use For |
|----------|-------|---------|
| `ctx.providers.CartoDB.Positron` | Light, minimal | Choropleth overlays (default recommendation) |
| `ctx.providers.CartoDB.DarkMatter` | Dark background | Bright overlays, points |
| `ctx.providers.OpenStreetMap.Mapnik` | Full OSM detail | Street-level context |
| `ctx.providers.Stadia.StamenTerrain` | Terrain shading | Physical geography |
| `ctx.providers.Stadia.StamenTonerLite` | Grayscale, clean | Print-friendly maps |
| `ctx.providers.Esri.WorldImagery` | Satellite imagery | Land use verification |

### Controlling Zoom Level

```python
# Auto zoom (default)
ctx.add_basemap(ax, zoom="auto")

# Specific zoom level (higher = more detail, more tiles)
ctx.add_basemap(ax, zoom=10)

# Adjust auto zoom
ctx.add_basemap(ax, zoom="auto", zoom_adjust=1)  # One level more detail
```

---

## Interactive Maps (folium via `.explore()`)

geopandas `.explore()` creates folium-based interactive maps with pan, zoom, and hover tooltips.

### Basic Interactive Map

```python
# Quick interactive map
m = gdf.explore(
    column="poverty_rate",
    cmap="YlOrRd",
    legend=True,
    tooltip=["NAME", "poverty_rate", "population"],
    popup=True,
    tiles="CartoDB positron"
)

# Save to HTML
m.save("interactive_map.html")
```

### Layered Interactive Map

```python
# Start with one layer
m = counties.explore(
    column="poverty_rate",
    cmap="YlOrRd",
    name="Counties",
    legend=True,
    tooltip=["NAME", "poverty_rate"]
)

# Add more layers
schools.explore(
    m=m,                          # Pass existing map
    color="blue",
    marker_kwds={"radius": 3},
    name="Schools",
    tooltip=["school_name", "enrollment"]
)

# Add layer control
import folium
folium.LayerControl().add_to(m)

m.save("layered_map.html")
```

### Direct Folium Usage

```python
import folium

# Create map centered on data
center = [gdf.geometry.centroid.y.mean(), gdf.geometry.centroid.x.mean()]
m = folium.Map(location=center, zoom_start=10, tiles="CartoDB positron")

# Add choropleth
folium.Choropleth(
    geo_data=gdf.to_json(),
    data=gdf,
    columns=["GEOID", "poverty_rate"],
    key_on="feature.properties.GEOID",
    fill_color="YlOrRd",
    fill_opacity=0.7,
    line_opacity=0.2,
    legend_name="Poverty Rate (%)"
).add_to(m)

m.save("folium_map.html")
```

---

## GPU-Accelerated Rendering (lonboard)

lonboard uses deck.gl for GPU-accelerated rendering of very large datasets (millions of features) that would overwhelm matplotlib or folium.

### Installation

```bash
pip install lonboard
```

### Quick Visualization

```python
from lonboard import viz

# Automatic layer type detection based on geometry
m = viz(gdf)

# Save to HTML
m.to_html("large_map.html")
```

For column-based coloring, use the layer API (below) which gives explicit control over color mapping.

### Layer-Based API

```python
from lonboard import Map, ScatterplotLayer, PolygonLayer

# Points
layer = ScatterplotLayer.from_geopandas(
    schools_gdf,
    get_radius=500,           # Radius in meters
    radius_units="meters",
    get_fill_color=[255, 0, 0, 180],  # RGBA
    pickable=True
)

# Polygons
layer = PolygonLayer.from_geopandas(
    counties_gdf,
    get_fill_color=[200, 200, 200, 100],
    get_line_color=[50, 50, 50, 255],
    get_line_width=1,
    pickable=True
)

# Combine layers in a map
m = Map(layers=[polygon_layer, point_layer])
m.to_html("multi_layer.html")
```

---

## Publication Maps with Cartopy

cartopy provides matplotlib-based map projections with proper geographic axes — essential for publication-quality maps requiring explicit projection control, graticules, and natural features.

### Installation

```bash
pip install cartopy
```

### Basic Map with Projection

```python
import cartopy.crs as ccrs
import cartopy.feature as cfeature
import matplotlib.pyplot as plt

fig, ax = plt.subplots(
    figsize=(12, 8),
    subplot_kw={"projection": ccrs.AlbersEqualArea(
        central_longitude=-96, central_latitude=37.5,
        standard_parallels=(29.5, 45.5)
    )}
)

# Add natural features
ax.add_feature(cfeature.STATES, linewidth=0.5, edgecolor="gray")
ax.add_feature(cfeature.COASTLINE, linewidth=0.8)
ax.add_feature(cfeature.BORDERS, linewidth=0.5, linestyle="--")

# Plot geopandas data on the cartopy axes
# transform= tells cartopy what CRS the data is in
gdf.plot(ax=ax, column="poverty_rate", cmap="YlOrRd", legend=True,
         transform=ccrs.PlateCarree())  # PlateCarree = lon/lat (EPSG:4326)

ax.set_extent([-125, -66, 24, 50], crs=ccrs.PlateCarree())  # Continental US
ax.set_title("Poverty Rate by County", fontsize=14)
plt.tight_layout()
plt.savefig("cartopy_map.png", dpi=300, bbox_inches="tight")
```

### Common Cartopy Projections

| Projection | Class | Use For |
|-----------|-------|---------|
| Albers Equal-Area | `ccrs.AlbersEqualArea()` | US thematic maps (preserves area) |
| Lambert Conformal | `ccrs.LambertConformal()` | Continental-scale (shape + area) |
| Plate Carrée | `ccrs.PlateCarree()` | Simple lon/lat display |
| Mercator | `ccrs.Mercator()` | Web-style maps |
| Robinson | `ccrs.Robinson()` | Global thematic maps |
| Orthographic | `ccrs.Orthographic()` | Globe-like perspective views |

### Key cartopy + geopandas Integration

The `transform=` parameter is critical: it declares what CRS the input data is in, so cartopy can reproject it to the axes projection. If your GeoDataFrame is in EPSG:4326, use `transform=ccrs.PlateCarree()`. If already projected, match accordingly.

---

## Datashader for Massive Point Datasets

datashader rasterizes point or line data into pixel grids before rendering, enabling visualization of billions of points without browser or memory limitations.

### Installation

```bash
pip install datashader
```

### Basic Point Density

```python
import datashader as ds
import datashader.transfer_functions as tf
import pandas as pd

# Extract coordinates (datashader works on plain DataFrames, not GeoDataFrames)
df = pd.DataFrame({"x": gdf.geometry.x, "y": gdf.geometry.y})

canvas = ds.Canvas(plot_width=800, plot_height=600)
agg = canvas.points(df, "x", "y")
img = tf.shade(agg, cmap="viridis")
img = tf.set_background(img, "black")

# Save as PNG
from datashader.utils import export_image
export_image(img, "point_density", background="black")
```

### When to Use Each Tool

| Tool | Max Features | Interactivity | Output | Best For |
|------|-------------|---------------|--------|----------|
| `.plot()` (matplotlib) | ~50K | None (static) | PNG/SVG/PDF | Publication figures |
| cartopy + matplotlib | ~50K | None (static) | PNG/SVG/PDF | Publication maps with projections |
| `.explore()` (folium) | ~100K | Pan/zoom/hover | HTML | Exploration, reports |
| lonboard | Millions | Pan/zoom/click | HTML/Jupyter | Large datasets, dashboards |
| datashader | Billions | None (static) | PNG | Point density at massive scale |

---

## Multi-Panel Maps

### Matplotlib Subplots

```python
fig, axes = plt.subplots(1, 3, figsize=(18, 6))

for ax, (col, title) in zip(axes, [
    ("poverty_rate", "Poverty Rate"),
    ("median_income", "Median Income"),
    ("graduation_rate", "Graduation Rate")
]):
    gdf.plot(column=col, ax=ax, cmap="YlOrRd", legend=True, scheme="FisherJenks", k=5)
    ax.set_title(title)
    ax.set_axis_off()

plt.tight_layout()
plt.savefig("panel_maps.png", dpi=300, bbox_inches="tight")
```

---

## Exporting Maps

### Static Formats

```python
# PNG (default for web and reports)
plt.savefig("map.png", dpi=300, bbox_inches="tight")

# SVG (scalable, for publications)
plt.savefig("map.svg", bbox_inches="tight")

# PDF (for print)
plt.savefig("map.pdf", bbox_inches="tight")
```

### Interactive Formats

```python
# Folium to HTML
m = gdf.explore(column="value")
m.save("map.html")

# Lonboard to HTML
from lonboard import viz
m = viz(gdf)
m.to_html("map.html")
```

---

## References and Further Reading

Jordahl, K. et al. (2024). *geopandas: Making maps*. https://geopandas.org/en/stable/docs/user_guide/mapping.html

Rey, S.J., Arribas-Bel, D., and Wolf, L.J. (2023). *Geographic Data Science with Python*, Ch. 5: "Choropleth mapping." https://geographicdata.science/book/

Dorman, M., Graser, A., Nowosad, J., and Lovelace, R. (2025). *Geocomputation with Python*, Ch. 8: "Making maps with Python." https://py.geocompx.org/

contextily documentation. https://contextily.readthedocs.io/

folium documentation. https://python-visualization.github.io/folium/

lonboard documentation. https://developmentseed.org/lonboard/

mapclassify documentation. https://pysal.org/mapclassify/

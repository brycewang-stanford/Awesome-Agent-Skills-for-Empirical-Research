---
name: geopandas
description: >-
  Spatial data: GeoDataFrames, spatial joins, CRS/projections, choropleth/interactive maps, spatial autocorrelation, PySAL. Use for geographic data, spatial files (Shapefile, GeoPackage, GeoParquet), or spatial stats. For charts without GIS use plotly.
metadata:
  audience: research-coders
  domain: python-library
  library-version: "1.1.3"
  skill-last-updated: "2026-03-28"
---

# GeoPandas Skill

geopandas spatial data library for Python: manipulation, analysis, and visualization of geographic data. Covers GeoDataFrames, spatial joins, CRS/projections, vector operations, raster integration (rasterio, xarray), choropleth mapping, interactive maps (folium), basemap tiles (contextily), spatial autocorrelation, and the PySAL ecosystem. Use when working with geographic data, reading/writing spatial files (Shapefile, GeoPackage, GeoParquet), making maps, or running spatial statistics. For interactive web-based geographic charts without spatial analysis, use plotly.

Comprehensive skill for spatial data analysis with geopandas and the broader Python geospatial stack. Use the decision trees below to find the right guidance, then load detailed references as needed.

## Version Notes

This skill targets **geopandas 1.x** (tested with 1.1.3). Key changes from earlier versions:
- Shapely >= 2.0 required (PyGEOS backend removed, vectorized ops built-in)
- pyogrio is the default I/O engine (replacing fiona, 5-10x faster)
- `cascaded_union` removed — use `union_all()` instead
- `GeoSeries.unary_union` property renamed to `GeoSeries.union_all()` method

## What is GeoPandas?

GeoPandas extends pandas with spatial data types and operations:

- **GeoDataFrame**: A pandas DataFrame with a geometry column — tabular data meets spatial operations
- **Spatial operations**: Joins, overlays, dissolve, clip, buffer, and distance calculations on vector geometries
- **CRS handling**: Coordinate reference system management via pyproj for correct spatial computations
- **Visualization**: Static maps (matplotlib), interactive maps (folium via `.explore()`), and GPU-accelerated rendering (lonboard)
- **Ecosystem hub**: Integrates with PySAL (spatial statistics), rasterio (rasters), contextily (basemaps), and mapclassify (classification schemes)

## How to Use This Skill

### Reference File Structure

| File | Purpose | When to Read |
|------|---------|--------------|
| `quickstart.md` | Installation, GeoDataFrame creation, basic I/O and plotting | Starting with geopandas |
| `data-io.md` | File formats, pyogrio, web data, spatial databases | Loading/saving spatial data |
| `crs-projections.md` | CRS fundamentals, reprojecting, choosing projections | CRS errors or projection decisions |
| `spatial-operations.md` | Spatial joins, overlays, dissolve, clip, buffer, distance | Combining or transforming spatial data |
| `raster-integration.md` | rasterio, xarray/rioxarray, zonal statistics | Working with raster data |
| `visualization.md` | Static maps, interactive maps, basemaps, classification | Making maps and figures |
| `pysal-spatial-stats.md` | Spatial weights, autocorrelation, LISA, spatial regression | Spatial statistics and modeling |
| `gotchas.md` | CRS mismatches, invalid geometries, common errors | Debugging spatial issues |

### Reading Order

1. **New to geopandas?** Start with `quickstart.md` then `spatial-operations.md`
2. **Making maps?** Read `visualization.md` (relies on `crs-projections.md` for projection choices)
3. **Spatial statistics?** Read `pysal-spatial-stats.md` (for methodology context, also load `data-scientist` skill's `geospatial-analysis.md`)
4. **Having issues?** Check `gotchas.md` first

## Related Skills

- **data-scientist** (`geospatial-analysis.md`, `geospatial-operations.md`): Spatial methodology — when/why to use spatial methods, interpretation guidance, MAUP, ecological fallacy. Load alongside this skill for research workflows.
- **polars**: If spatial data is combined with large tabular datasets, use polars for non-spatial transformations before converting to GeoDataFrame.
- **plotnine / plotly**: For non-map visualizations of spatial analysis results (coefficient plots, distributions).

## Quick Decision Trees

### "I need to read or write spatial data"

```
Loading/saving spatial data?
├─ Read vector file (Shapefile, GeoPackage, GeoJSON) → ./references/data-io.md
├─ Read GeoParquet → ./references/data-io.md
├─ Read from PostGIS / DuckDB Spatial → ./references/data-io.md
├─ Download boundaries (Census, OSM) → ./references/data-io.md
├─ Create GeoDataFrame from lat/lon columns → ./references/quickstart.md
├─ Write to file → ./references/data-io.md
└─ Read raster data (GeoTIFF) → ./references/raster-integration.md
```

### "I need to combine or transform spatial data"

```
Spatial operations?
├─ Join by location (point-in-polygon, etc.) → ./references/spatial-operations.md
├─ Join by nearest feature → ./references/spatial-operations.md
├─ Overlay (intersection, union, difference) → ./references/spatial-operations.md
├─ Dissolve (merge polygons by attribute) → ./references/spatial-operations.md
├─ Clip to boundary → ./references/spatial-operations.md
├─ Buffer features → ./references/spatial-operations.md
├─ Compute distances → ./references/spatial-operations.md
├─ Compute centroids or areas → ./references/spatial-operations.md
└─ Areal interpolation (mismatched boundaries) → ./references/spatial-operations.md
```

### "I need to fix CRS or projection issues"

```
CRS/projection issues?
├─ Check current CRS → ./references/crs-projections.md
├─ Reproject to different CRS → ./references/crs-projections.md
├─ Choose a projection for analysis → ./references/crs-projections.md
├─ Data has no CRS (set it) → ./references/crs-projections.md
├─ CRS mismatch error → ./references/gotchas.md
└─ Area/distance calculations wrong → ./references/crs-projections.md
```

### "I need to make a map"

```
Making maps?
├─ Quick static choropleth → ./references/visualization.md
├─ Classification schemes (quantiles, Fisher-Jenks) → ./references/visualization.md
├─ Add basemap tiles → ./references/visualization.md
├─ Interactive map (pan/zoom/hover) → ./references/visualization.md
├─ Large dataset (millions of features) → ./references/visualization.md
├─ Multi-panel / faceted maps → ./references/visualization.md
├─ LISA cluster map → ./references/pysal-spatial-stats.md
└─ Export to PNG/SVG/HTML → ./references/visualization.md
```

### "I need spatial statistics"

```
Spatial statistics?
├─ Build spatial weights matrix → ./references/pysal-spatial-stats.md
├─ Test for spatial autocorrelation (Moran's I) → ./references/pysal-spatial-stats.md
├─ Find hot spots / cold spots (LISA) → ./references/pysal-spatial-stats.md
├─ Spatial regression (lag, error, Durbin) → ./references/pysal-spatial-stats.md
├─ Point pattern analysis → ./references/pysal-spatial-stats.md
└─ Methodology guidance (interpretation, MAUP) → data-scientist skill: geospatial-analysis.md
```

### "I need to work with rasters"

```
Raster operations?
├─ Read GeoTIFF → ./references/raster-integration.md
├─ Zonal statistics (summarize raster by polygons) → ./references/raster-integration.md
├─ Clip/mask raster by polygon → ./references/raster-integration.md
├─ Extract raster values at points → ./references/raster-integration.md
├─ Multidimensional raster (xarray) → ./references/raster-integration.md
└─ Rasterize vectors / vectorize rasters → ./references/raster-integration.md
```

### "Something isn't working"

```
Having issues?
├─ CRS mismatch errors → ./references/gotchas.md
├─ Invalid geometry errors → ./references/gotchas.md
├─ Spatial join produced wrong row count → ./references/gotchas.md
├─ Memory issues with large files → ./references/gotchas.md
├─ Shapely version confusion → ./references/gotchas.md
├─ Coordinate order (lon/lat vs lat/lon) → ./references/gotchas.md
└─ General troubleshooting → ./references/gotchas.md
```

## File-First Execution in Research Workflows

**Important:** In data research pipelines (see `CLAUDE.md`), spatial operations are executed through **script files**, not interactively. This ensures auditability and reproducibility.

**The pattern:**
1. Write spatial analysis code to `scripts/stage{N}_{type}/{step}_{task-name}.py`
2. Execute via Bash with automatic output capture wrapper script
3. Validation results get automatically embedded in scripts as comments
4. If failed, create versioned copy for fixes

Closely read `agent_reference/SCRIPT_EXECUTION_REFERENCE.md` for the mandatory file-first execution protocol covering complete code file writing, output capture, and file versioning rules.

**See:**
- `agent_reference/SCRIPT_EXECUTION_REFERENCE.md` — Script execution protocol and format with validation

The examples in reference files show geopandas syntax. In research workflows, wrap them in scripts following the file-first pattern.

---

## Quick Reference

### Essential Imports

```python
import geopandas as gpd
from shapely.geometry import Point, Polygon, LineString, MultiPolygon
```

### Core Operations

| Operation | Code |
|-----------|------|
| Read file | `gpd.read_file("data.gpkg")` |
| Read Parquet | `gpd.read_parquet("data.parquet")` |
| From lat/lon | `gpd.GeoDataFrame(df, geometry=gpd.points_from_xy(df.lon, df.lat), crs="EPSG:4326")` |
| Check CRS | `gdf.crs` |
| Reproject | `gdf.to_crs(epsg=5070)` |
| Spatial join | `gpd.sjoin(points, polygons, predicate="within")` |
| Nearest join | `gpd.sjoin_nearest(gdf1, gdf2, max_distance=1000)` |
| Overlay | `gpd.overlay(gdf1, gdf2, how="intersection")` |
| Dissolve | `gdf.dissolve(by="state")` |
| Buffer | `gdf.buffer(1000)` (in CRS units) |
| Centroid | `gdf.centroid` |
| Area | `gdf.area` (project first) |
| Distance | `gdf1.distance(gdf2)` |
| Clip | `gpd.clip(gdf, mask)` |
| Plot | `gdf.plot(column="value", legend=True)` |
| Interactive map | `gdf.explore(column="value")` |
| Write file | `gdf.to_file("out.gpkg")` |
| Write Parquet | `gdf.to_parquet("out.parquet")` |

### Common CRS Codes

| EPSG | Name | Use For |
|------|------|---------|
| 4326 | WGS84 | Storage, exchange, web (not analysis) |
| 5070 | NAD83 Conus Albers | US thematic maps (equal-area) |
| 3857 | Web Mercator | Web tiles display only |
| 32617 | UTM Zone 17N | US East Coast local analysis |

## Topic Index

| Topic | Reference File |
|-------|---------------|
| Installation | `./references/quickstart.md` |
| GeoDataFrame creation | `./references/quickstart.md` |
| Basic plotting | `./references/quickstart.md` |
| File formats (GeoPackage, Shapefile, GeoJSON) | `./references/data-io.md` |
| GeoParquet | `./references/data-io.md` |
| pyogrio engine | `./references/data-io.md` |
| Web data (OSM, Census, WFS) | `./references/data-io.md` |
| Spatial databases (PostGIS, DuckDB) | `./references/data-io.md` |
| CRS fundamentals | `./references/crs-projections.md` |
| Reprojection | `./references/crs-projections.md` |
| Choosing projections | `./references/crs-projections.md` |
| Common US projections | `./references/crs-projections.md` |
| Spatial joins | `./references/spatial-operations.md` |
| Nearest-neighbor joins | `./references/spatial-operations.md` |
| Overlay operations | `./references/spatial-operations.md` |
| Dissolve and aggregation | `./references/spatial-operations.md` |
| Buffering | `./references/spatial-operations.md` |
| Clipping | `./references/spatial-operations.md` |
| Areal interpolation | `./references/spatial-operations.md` |
| rasterio basics | `./references/raster-integration.md` |
| xarray / rioxarray | `./references/raster-integration.md` |
| Zonal statistics | `./references/raster-integration.md` |
| Raster-vector conversion | `./references/raster-integration.md` |
| Choropleth maps | `./references/visualization.md` |
| Classification schemes | `./references/visualization.md` |
| Basemap tiles (contextily) | `./references/visualization.md` |
| Interactive maps (folium) | `./references/visualization.md` |
| GPU rendering (lonboard) | `./references/visualization.md` |
| Exporting maps | `./references/visualization.md` |
| Spatial weights | `./references/pysal-spatial-stats.md` |
| Moran's I | `./references/pysal-spatial-stats.md` |
| LISA cluster maps | `./references/pysal-spatial-stats.md` |
| Spatial regression | `./references/pysal-spatial-stats.md` |
| Point pattern analysis | `./references/pysal-spatial-stats.md` |
| Cartopy publication maps | `./references/visualization.md` |
| Datashader massive point rendering | `./references/visualization.md` |
| Join count statistics | `./references/pysal-spatial-stats.md` |
| Ripley's functions (G, F, K) | `./references/pysal-spatial-stats.md` |
| CRS mismatch errors | `./references/gotchas.md` |
| Invalid geometries | `./references/gotchas.md` |
| Spatial join row count issues | `./references/gotchas.md` |
| Memory with large files | `./references/gotchas.md` |
| Shapely 2.x changes | `./references/gotchas.md` |
| Coordinate order confusion | `./references/gotchas.md` |

## Citation

When this library is used as a primary analytical tool, include in the report's
Software & Tools references:

> Jordahl, K. et al. geopandas: Python tools for geographic data [Computer software]. https://geopandas.org/

**Cite when:** geopandas is used for spatial operations, spatial joins, or map visualization central to the analysis.
**Do not cite when:** Only used to read a shapefile for a simple reference lookup.

If PySAL spatial analysis functions are also used (spatial weights, Moran's I, etc.),
additionally cite:

> Rey, S.J. et al. (2022). "The PySAL Ecosystem of Open-Source Python Packages for the Analysis of Spatial Data." Geographical Analysis, 54(3), 467-487.

For method-specific citations (e.g., spatial statistics techniques),
consult the reference files in this skill and `agent_reference/CITATION_REFERENCE.md`.

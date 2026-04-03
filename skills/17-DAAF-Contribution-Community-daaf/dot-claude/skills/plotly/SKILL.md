---
name: plotly
description: >-
  Plotly interactive visualization. Express and Graph Objects: scatter, line, bar, heatmap, 3D, geographic charts; subplots; styling; export. Use when interactivity (hover/zoom) is needed. For static figures use plotnine; for GIS use geopandas.
metadata:
  audience: research-coders
  domain: python-library
  library-version: "6.x"
  skill-last-updated: "2026-03-28"
---

# Plotly Skill

Plotly interactive visualization library for Python. Covers Plotly Express and Graph Objects for scatter, line, bar, histogram, box, heatmap, 3D, and geographic charts; subplots and faceting; styling; and HTML/image export. Use when creating interactive visualizations with hover/zoom/pan, building web-based charts, or producing geographic or 3D plots. Prefer over plotnine when interactivity is required; for spatial analysis, projections, or GIS-style mapping, use geopandas.

Quick reference for creating interactive data visualizations with Plotly, featuring both the high-level Plotly Express API and low-level Graph Objects.

## What is Plotly?

Plotly is an interactive visualization library for Python:
- **Interactive**: Hover, zoom, pan, and select built-in
- **Two APIs**: Plotly Express (simple) and Graph Objects (flexible)
- **Web-based**: Renders as HTML/JavaScript, works in notebooks and browsers
- **Wide chart support**: 40+ chart types including statistical, scientific, financial, and geographic

## How to Use This Skill

### Reference File Structure

| File | Purpose | When to Read |
|------|---------|--------------|
| `quickstart.md` | Installation, imports, px vs go | Starting out |
| `charts.md` | Scatter, line, bar, histogram, box | Creating visualizations |
| `subplots-facets.md` | Multi-panel layouts, faceting | Multiple charts together |
| `styling.md` | Templates, colors, layout | Customizing appearance |
| `export.md` | HTML, images, JSON | Saving and sharing |
| `gotchas.md` | Common errors, best practices | Debugging |

## Quick Decision Trees

### "I need to create a chart"

```
What kind of chart?
├─ Scatter plot → ./references/charts.md
├─ Line chart → ./references/charts.md
├─ Bar chart → ./references/charts.md
├─ Histogram → ./references/charts.md
├─ Box/Violin plot → ./references/charts.md
├─ Heatmap → ./references/charts.md
├─ 3D/Maps/Financial → ./references/charts.md (Other Chart Types)
└─ Not sure → ./references/quickstart.md
```

### "I need multiple charts"

```
Multiple panels?
├─ Same chart, split by category → ./references/subplots-facets.md (faceting)
├─ Different charts in grid → ./references/subplots-facets.md (make_subplots)
├─ Shared axes → ./references/subplots-facets.md
└─ Secondary y-axis → ./references/subplots-facets.md
```

### "I need to customize appearance"

```
What to customize?
├─ Overall theme → ./references/styling.md (templates)
├─ Colors → ./references/styling.md
├─ Titles/labels → ./references/styling.md
├─ Axes → ./references/styling.md
├─ Legend → ./references/styling.md
└─ Hover info → ./references/styling.md
```

### "I need to save/export"

```
Export format?
├─ Interactive HTML → ./references/export.md
├─ Static image (PNG/SVG/PDF) → ./references/export.md
├─ JSON for API → ./references/export.md
└─ Embed in webpage → ./references/export.md
```

### "Something isn't working"

```
Common issues?
├─ Figure not showing → ./references/gotchas.md
├─ Image export fails → ./references/gotchas.md
├─ Performance issues → ./references/gotchas.md
├─ px vs go confusion → ./references/gotchas.md
└─ Column/data errors → ./references/gotchas.md
```

## File-First Execution in Research Workflows

**Important:** In data research pipelines (see `CLAUDE.md`), all visualizations are generated through **script files** in `scripts/stage8_analysis/`, not interactively. This ensures auditability and reproducibility.

**The pattern:**
1. Write plot code FIRST to `scripts/stage8_analysis/{step}_{plot-name}.py`
2. Execute via Bash with automatic output capture wrapper script
3. Validation results get automatically embedded in scripts as comments
4. If failed, create versioned copy for fixes

Closely read `agent_reference/SCRIPT_EXECUTION_REFERENCE.md` for the mandatory file-first execution protocol covering complete code file writing, output capture, and file versioning rules.

**See:**
- `agent_reference/WORKFLOW_PHASE4_ANALYSIS.md` — Stage 8 (Analysis & Visualization)

The examples below show Plotly syntax. In research workflows, wrap them in scripts following the file-first pattern.

---

## Quick Reference

### Essential Imports

```python
import plotly.express as px          # High-level API
import plotly.graph_objects as go    # Low-level API
from plotly.subplots import make_subplots  # For subplots
import plotly.io as pio              # For export/config
```

### Plotly Express Pattern

```python
import plotly.express as px

fig = px.scatter(df, x="col_x", y="col_y", color="category")
fig.show()
```

### Graph Objects Pattern

```python
import plotly.graph_objects as go

fig = go.Figure()
fig.add_trace(go.Scatter(x=x_data, y=y_data, mode="markers"))
fig.update_layout(title="My Plot")
fig.show()
```

### Common px Functions

| Function | Chart Type |
|----------|------------|
| `px.scatter()` | Scatter plot |
| `px.line()` | Line chart |
| `px.bar()` | Bar chart |
| `px.histogram()` | Histogram |
| `px.box()` | Box plot |
| `px.violin()` | Violin plot |
| `px.imshow()` | Heatmap/Image |
| `px.pie()` | Pie chart |

### Common go Trace Types

| Trace | Use Case |
|-------|----------|
| `go.Scatter` | Points, lines, or both |
| `go.Bar` | Bar charts |
| `go.Histogram` | Histograms |
| `go.Box` | Box plots |
| `go.Heatmap` | Heatmaps |
| `go.Pie` | Pie charts |

### Saving Plots

```python
# Interactive HTML
fig.write_html("plot.html")

# Static image export (PNG/SVG/PDF) is NOT available in DAAF — kaleido is not
# installed due to its heavy Chromium dependency. Use plotnine for static figures.
# For interactive output, use HTML:
# fig.write_image("plot.png")  # Would require: pip install kaleido + Chromium
```

## Topic Index

| Topic | Reference File |
|-------|---------------|
| Installation | `./references/quickstart.md` |
| px vs go | `./references/quickstart.md` |
| Built-in datasets | `./references/quickstart.md` |
| Scatter plots | `./references/charts.md` |
| Line charts | `./references/charts.md` |
| Bar charts | `./references/charts.md` |
| Histograms | `./references/charts.md` |
| Box plots | `./references/charts.md` |
| Other chart types | `./references/charts.md` |
| Faceting | `./references/subplots-facets.md` |
| make_subplots | `./references/subplots-facets.md` |
| Templates/Themes | `./references/styling.md` |
| Colors | `./references/styling.md` |
| Layout customization | `./references/styling.md` |
| Hover customization | `./references/styling.md` |
| HTML export | `./references/export.md` |
| Image export | `./references/export.md` |
| JSON export | `./references/export.md` |
| Common errors | `./references/gotchas.md` |
| Performance | `./references/gotchas.md` |
| Best practices | `./references/gotchas.md` |

## Citation

When this library is used as a primary analytical tool, include in the report's
Software & Tools references:

> Plotly Technologies Inc. Plotly: Interactive graphing library [Computer software]. https://plotly.com/

**Cite when:** Plotly is the primary visualization library producing interactive figures included in the report or notebook.
**Do not cite when:** Only used for quick exploratory plots not included in deliverables.

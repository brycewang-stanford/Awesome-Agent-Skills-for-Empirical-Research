---
name: plotnine
description: >-
  plotnine static visualization (ggplot2 syntax for Python). Geoms, aesthetics, scales, coordinates, facets, themes. Use for static publication-quality figures with grammar-of-graphics syntax. For interactive charts use plotly; for maps use geopandas.
metadata:
  audience: research-coders
  domain: python-library
  library-version: "0.15.x"
  skill-last-updated: "2026-03-26"
---

# Plotnine Skill

plotnine static visualization library for Python, implementing the grammar of graphics (ggplot2 syntax). Covers geoms (point, line, bar, histogram, boxplot, smooth), aesthetics, scales, coordinates, facets, and themes. Use when creating static publication-quality figures with ggplot2-style syntax, producing charts for print or reports, or working with an R ggplot2 background. Prefer over plotly when static output is needed.

Quick reference for creating data visualizations with plotnine, a Python implementation of the grammar of graphics (ggplot2).

## What is Plotnine?

plotnine is a data visualization library based on the **grammar of graphics**:
- **Declarative**: Describe what you want, not how to draw it
- **Layered**: Build plots by adding components with `+`
- **ggplot2 compatible**: Nearly identical syntax to R's ggplot2
- **Publication-ready**: Themes and customization for polished output

## How to Use This Skill

### Reference File Structure

| File | Purpose | When to Read |
|------|---------|--------------|
| `quickstart.md` | Installation, imports, basic syntax | Starting out |
| `geoms.md` | Geometric objects (points, lines, bars) | Choosing chart types |
| `aesthetics.md` | Mapping data to visual properties | Customizing appearance |
| `scales-coords.md` | Scales, coordinates, positions | Axis/color control |
| `facets-themes.md` | Multi-panel plots and styling | Layout and themes |
| `gotchas.md` | Common errors and best practices | Debugging |

## Quick Decision Trees

### "I need to create a plot"

```
What kind of plot?
├─ Scatter plot (geom_point) → ./references/geoms.md
├─ Line plot (geom_line) → ./references/geoms.md
├─ Bar chart (geom_bar, geom_col) → ./references/geoms.md
├─ Histogram (geom_histogram) → ./references/geoms.md
├─ Box plot (geom_boxplot) → ./references/geoms.md
└─ Other geoms → ./references/geoms.md
```

### "I need to customize appearance"

```
What to customize?
├─ Colors, sizes, shapes → ./references/aesthetics.md
├─ Axis limits/labels → ./references/scales-coords.md
├─ Color palettes → ./references/scales-coords.md
├─ Overall theme → ./references/facets-themes.md
├─ Title/labels → ./references/facets-themes.md
└─ Multiple panels (faceting) → ./references/facets-themes.md
```

### "Something isn't working"

```
Common issues?
├─ Plot not showing → ./references/quickstart.md
├─ Column not found → ./references/gotchas.md
├─ Color not applying → ./references/aesthetics.md
├─ Unexpected grouping → ./references/gotchas.md
└─ Syntax errors → ./references/gotchas.md
```

## File-First Execution in Research Workflows

**Important:** In data research pipelines (see `CLAUDE.md`), all visualizations are generated through **script files** in `scripts/stage8_analysis/`, not interactively. This ensures auditability and reproducibility.

**The pattern:**
1. Write plot code to `scripts/stage8_analysis/{step}_{plot-name}.py`
2. Execute via Bash with automatic output capture wrapper script
3. Validation results get automatically embedded in scripts as comments
4. If failed, create versioned copy for fixes

Closely read `agent_reference/SCRIPT_EXECUTION_REFERENCE.md` for the mandatory file-first execution protocol covering complete code file writing, output capture, and file versioning rules.

**See:**
- `agent_reference/WORKFLOW_PHASE4_ANALYSIS.md` — Stage 8 (Analysis & Visualization)

The examples below show plotnine syntax. In research workflows, wrap them in scripts following the file-first pattern.

---

## Quick Reference

### Basic Plot Pattern

```python
from plotnine import ggplot, aes, geom_point

(
    ggplot(df, aes(x="col_x", y="col_y"))
    + geom_point()
)
```

### Essential Imports

```python
from plotnine import *           # All components
from plotnine.data import mtcars # Built-in datasets
```

### Common Geoms

| Geom | Use Case |
|------|----------|
| `geom_point()` | Scatter plots |
| `geom_line()` | Line plots |
| `geom_bar()` | Count bars |
| `geom_col()` | Value bars |
| `geom_histogram()` | Distributions |
| `geom_boxplot()` | Box plots |
| `geom_smooth()` | Trend lines |

### Common Aesthetics

| Aesthetic | Controls |
|-----------|----------|
| `x`, `y` | Position |
| `color` | Point/line color |
| `fill` | Area fill color |
| `size` | Point/line size |
| `shape` | Point shape |
| `alpha` | Transparency |

### Saving Plots

```python
p = ggplot(df, aes("x", "y")) + geom_point()
p.save("plot.png", width=10, height=8, dpi=300)
```

## Topic Index

| Topic | Reference File |
|-------|---------------|
| Installation | `./references/quickstart.md` |
| Basic syntax | `./references/quickstart.md` |
| Chart types | `./references/geoms.md` |
| Data mapping | `./references/aesthetics.md` |
| Color/shape values | `./references/aesthetics.md` |
| Axis scales | `./references/scales-coords.md` |
| Color scales | `./references/scales-coords.md` |
| Coordinates | `./references/scales-coords.md` |
| Faceting | `./references/facets-themes.md` |
| Themes | `./references/facets-themes.md` |
| Labels/titles | `./references/facets-themes.md` |
| Common errors | `./references/gotchas.md` |
| Best practices | `./references/gotchas.md` |

## Citation

When this library is used as a primary analytical tool, include in the report's
Software & Tools references:

> Kibirige, H. et al. plotnine: Grammar of graphics for Python [Computer software]. https://plotnine.org/

**Cite when:** plotnine is the primary visualization library producing figures included in the report.
**Do not cite when:** Only used for quick exploratory plots not included in deliverables.

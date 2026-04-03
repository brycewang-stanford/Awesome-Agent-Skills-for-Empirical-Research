---
name: chart-image-generator
description: "Generate publication-quality chart images from research data"
metadata:
  openclaw:
    emoji: "📉"
    category: "analysis"
    subcategory: "dataviz"
    keywords: ["chart generation", "data visualization", "matplotlib", "publication figures", "scientific plots", "graph export"]
    source: "wentor-research-plugins"
---

# Chart Image Generator

A skill for generating publication-quality chart images from research data using Python visualization libraries. Covers chart type selection, styling for academic journals, multi-panel layouts, color accessibility, and export at the correct resolution and format for submission.

## Overview

Creating figures for academic publications requires more than just plotting data. Journals have specific requirements for resolution (typically 300-600 DPI), file format (TIFF, EPS, PDF, or high-resolution PNG), font sizes (often 8-12pt in the final printed figure), line weights, and color accessibility. This skill automates the production of figures that meet these standards, reducing the time researchers spend on manual formatting and ensuring consistency across all figures in a manuscript.

The skill supports common chart types used in academic research: scatter plots, bar charts, line plots, box plots, violin plots, heatmaps, forest plots, Kaplan-Meier curves, and multi-panel composite figures. All examples use matplotlib and seaborn with a custom academic styling configuration.

## Academic Figure Styling

### Journal-Ready Style Configuration

```python
import matplotlib.pyplot as plt
import matplotlib as mpl

def set_academic_style():
    """
    Configure matplotlib for publication-quality figures.
    Matches common requirements for Nature, Science, PLOS, IEEE journals.
    """
    plt.rcParams.update({
        # Font settings
        'font.family': 'sans-serif',
        'font.sans-serif': ['Arial', 'Helvetica', 'DejaVu Sans'],
        'font.size': 8,
        'axes.titlesize': 9,
        'axes.labelsize': 8,
        'xtick.labelsize': 7,
        'ytick.labelsize': 7,
        'legend.fontsize': 7,

        # Line and marker settings
        'lines.linewidth': 1.0,
        'lines.markersize': 4,
        'axes.linewidth': 0.5,
        'xtick.major.width': 0.5,
        'ytick.major.width': 0.5,

        # Grid and background
        'axes.grid': False,
        'axes.facecolor': 'white',
        'figure.facecolor': 'white',

        # Legend
        'legend.frameon': False,
        'legend.borderpad': 0.3,

        # Save settings
        'savefig.dpi': 300,
        'savefig.bbox': 'tight',
        'savefig.pad_inches': 0.05,

        # Use Type 1 fonts for EPS/PDF (required by many journals)
        'pdf.fonttype': 42,
        'ps.fonttype': 42,
    })

# Common journal figure widths (in inches):
SINGLE_COLUMN = 3.5   # ~89mm (Nature, Science, PLOS)
DOUBLE_COLUMN = 7.0   # ~178mm
ONE_AND_HALF = 5.5    # ~140mm
```

### Accessible Color Palettes

```python
# Colorblind-safe palettes for academic figures
PALETTES = {
    'categorical_8': [
        '#332288', '#88CCEE', '#44AA99', '#117733',
        '#999933', '#DDCC77', '#CC6677', '#882255'
    ],  # Tol's qualitative palette

    'sequential': 'viridis',  # Perceptually uniform

    'diverging': 'RdBu_r',   # Red-Blue diverging

    'binary': ['#0072B2', '#D55E00'],  # Blue and vermilion
}
```

## Chart Type Selection Guide

| Data Pattern | Recommended Chart | When to Use |
|-------------|------------------|-------------|
| Distribution of one variable | Histogram, KDE, violin | Showing data spread |
| Comparing groups | Box plot, violin, bar + error bars | Group differences |
| Two continuous variables | Scatter plot | Correlation, regression |
| Trends over time | Line plot | Time series, longitudinal |
| Proportions | Stacked bar, pie (sparingly) | Composition |
| Correlation matrix | Heatmap | Many variable pairs |
| Effect sizes + CIs | Forest plot | Meta-analysis, multi-model |
| Survival data | Kaplan-Meier curve | Time-to-event |

## Generating Common Academic Charts

### Scatter Plot with Regression Line

```python
import numpy as np
import seaborn as sns

def scatter_with_regression(x, y, xlabel, ylabel, title, output_path,
                            groups=None, group_label=None):
    """
    Create a scatter plot with regression line and confidence interval.
    """
    set_academic_style()
    fig, ax = plt.subplots(figsize=(SINGLE_COLUMN, SINGLE_COLUMN * 0.8))

    if groups is not None:
        for group_val in sorted(set(groups)):
            mask = groups == group_val
            ax.scatter(x[mask], y[mask], s=15, alpha=0.7, label=group_val)
        ax.legend(title=group_label)
    else:
        ax.scatter(x, y, s=15, alpha=0.7, color=PALETTES['binary'][0])

    # Add regression line
    from scipy import stats
    slope, intercept, r, p, se = stats.linregress(x, y)
    x_line = np.linspace(x.min(), x.max(), 100)
    ax.plot(x_line, slope * x_line + intercept, color='#CC6677',
            linewidth=1.0, linestyle='--')

    # Annotate with statistics
    ax.text(0.05, 0.95, f'r = {r:.3f}\np = {p:.3f}',
            transform=ax.transAxes, verticalalignment='top', fontsize=7)

    ax.set_xlabel(xlabel)
    ax.set_ylabel(ylabel)
    ax.set_title(title)

    fig.savefig(output_path, dpi=300, bbox_inches='tight')
    plt.close(fig)
    return output_path
```

### Multi-Panel Composite Figure

```python
def create_multipanel_figure(panels: list, ncols: int = 2,
                              output_path: str = 'figure.pdf'):
    """
    Create a multi-panel figure with automatic panel labels (A, B, C, ...).

    Args:
        panels: List of dicts with 'plot_func', 'args', 'title'
        ncols: Number of columns
        output_path: Output file path
    """
    set_academic_style()
    nrows = int(np.ceil(len(panels) / ncols))
    fig, axes = plt.subplots(nrows, ncols,
                              figsize=(DOUBLE_COLUMN, 3.0 * nrows))
    axes = axes.flatten() if hasattr(axes, 'flatten') else [axes]

    for i, (ax, panel) in enumerate(zip(axes, panels)):
        panel['plot_func'](ax, **panel.get('args', {}))
        # Add panel label (A, B, C, ...)
        ax.text(-0.15, 1.08, chr(65 + i), transform=ax.transAxes,
                fontsize=11, fontweight='bold', va='top')
        if 'title' in panel:
            ax.set_title(panel['title'])

    # Hide unused panels
    for ax in axes[len(panels):]:
        ax.set_visible(False)

    fig.tight_layout()
    fig.savefig(output_path, dpi=300, bbox_inches='tight')
    plt.close(fig)
    return output_path
```

## Export Specifications by Journal

| Journal / Publisher | Format | DPI | Max Width | Color Mode |
|--------------------|--------|-----|-----------|------------|
| Nature | TIFF, EPS, PDF | 300 | 180mm | RGB |
| Science | EPS, PDF | 300 | 174mm | RGB |
| PLOS | TIFF, EPS | 300 | 174mm | RGB |
| IEEE | EPS, PDF, PNG | 300 | 3.5in (1-col) | RGB or CMYK |
| Elsevier | TIFF, EPS, PDF | 300-600 | 190mm | RGB or CMYK |
| Springer | TIFF, EPS, PDF | 300 | 174mm | RGB or CMYK |

### Export Function

```python
def export_figure(fig, basename: str, formats=('pdf', 'png', 'tiff'), dpi=300):
    """Export a figure in multiple formats for journal submission."""
    paths = []
    for fmt in formats:
        path = f"{basename}.{fmt}"
        fig.savefig(path, format=fmt, dpi=dpi, bbox_inches='tight',
                    facecolor='white', edgecolor='none')
        paths.append(path)
    return paths
```

## Best Practices

- Always use vector formats (PDF, EPS) for line art and plots; raster (TIFF, PNG) only when required.
- Set figure dimensions to the exact column width of your target journal.
- Use the same font and size across all figures in a manuscript for consistency.
- Test figures in grayscale to ensure they remain readable without color.
- Include all figure generation code in your supplementary materials for reproducibility.
- Label axes with units (e.g., "Temperature (K)") and avoid abbreviations unless defined.

## References

- Rougier, N. P., Droettboom, M., & Borne, P. E. (2014). Ten Simple Rules for Better Figures. *PLoS Computational Biology*, 10(9).
- Tufte, E. R. (2001). *The Visual Display of Quantitative Information* (2nd ed.). Graphics Press.
- Wong, B. (2011). Color Blindness. *Nature Methods*, 8(6), 441.

---
name: publication-figures-guide
description: "Create journal-quality scientific figures with proper styling and accessibility"
metadata:
  openclaw:
    emoji: "🎨"
    category: "analysis"
    subcategory: "dataviz"
    keywords: ["scientific figure creation", "publication quality figure", "figure standards", "colorblind-friendly palette", "data visualization"]
    source: "wentor"
---

# Publication Figures Guide

A skill for creating publication-quality scientific figures that meet journal standards for resolution, formatting, accessibility, and visual clarity. Covers matplotlib, seaborn, and ggplot2 workflows with journal-ready export settings.

## Journal Figure Requirements

### Common Standards

| Requirement | Typical Spec | Notes |
|------------|-------------|-------|
| Resolution | 300-600 DPI | 300 DPI minimum for print |
| File format | PDF, EPS, TIFF | Vector (PDF/EPS) preferred |
| Color mode | CMYK for print, RGB for online | Check journal spec |
| Max width | Single column: 3.3in / Double: 6.7in | Varies by journal |
| Font size | 6-8pt minimum | Must be legible at final print size |
| Line width | 0.5-1.5pt | Thin lines may not reproduce |
| File size | Varies (often <10MB per figure) | TIFF can be large |

### Matplotlib Configuration for Publication

```python
import matplotlib.pyplot as plt
import matplotlib as mpl
import numpy as np

def setup_publication_style(journal: str = 'nature'):
    """
    Configure matplotlib for publication-quality figures.
    """
    styles = {
        'nature': {
            'figure.figsize': (3.3, 2.5),    # single column
            'font.size': 7,
            'font.family': 'sans-serif',
            'font.sans-serif': ['Arial', 'Helvetica'],
            'axes.linewidth': 0.5,
            'axes.labelsize': 8,
            'xtick.labelsize': 7,
            'ytick.labelsize': 7,
            'legend.fontsize': 6,
            'lines.linewidth': 1.0,
            'lines.markersize': 4,
            'savefig.dpi': 300,
            'savefig.bbox': 'tight',
            'savefig.pad_inches': 0.05,
        },
        'ieee': {
            'figure.figsize': (3.5, 2.6),
            'font.size': 8,
            'font.family': 'serif',
            'font.serif': ['Times New Roman', 'Times'],
            'axes.linewidth': 0.5,
            'axes.labelsize': 9,
            'xtick.labelsize': 8,
            'ytick.labelsize': 8,
            'legend.fontsize': 7,
            'lines.linewidth': 1.0,
            'savefig.dpi': 300,
        },
        'acs': {
            'figure.figsize': (3.25, 2.5),
            'font.size': 7,
            'font.family': 'sans-serif',
            'font.sans-serif': ['Arial'],
            'axes.linewidth': 0.5,
            'savefig.dpi': 600,
        }
    }

    style = styles.get(journal, styles['nature'])
    mpl.rcParams.update(style)
    return style

setup_publication_style('nature')
```

## Colorblind-Friendly Palettes

### Recommended Color Schemes

```python
def get_accessible_palette(n_colors: int = 8, style: str = 'categorical') -> list:
    """
    Return colorblind-friendly palettes.
    """
    palettes = {
        'categorical': {
            # Wong (2011) Nature Methods palette
            3: ['#0072B2', '#D55E00', '#009E73'],
            4: ['#0072B2', '#D55E00', '#009E73', '#CC79A7'],
            5: ['#0072B2', '#D55E00', '#009E73', '#CC79A7', '#F0E442'],
            8: ['#0072B2', '#D55E00', '#009E73', '#CC79A7',
                '#F0E442', '#56B4E9', '#E69F00', '#000000']
        },
        'sequential': {
            # Viridis-based (perceptually uniform)
            'cmap': 'viridis'  # Also: 'cividis', 'inferno', 'magma'
        },
        'diverging': {
            'cmap': 'RdBu_r'  # Also: 'coolwarm', 'BrBG'
        }
    }

    if style == 'categorical':
        n = min(n_colors, 8)
        return palettes['categorical'].get(n, palettes['categorical'][8][:n])
    else:
        return palettes[style]

# Usage
colors = get_accessible_palette(4)
```

## Common Figure Types

### Bar Charts with Error Bars

```python
def publication_barplot(data: dict, ylabel: str, title: str = '',
                         output: str = 'figure.pdf'):
    """
    Create a publication-quality bar chart.

    Args:
        data: Dict mapping group names to (mean, std_error) tuples
    """
    setup_publication_style('nature')
    colors = get_accessible_palette(len(data))

    fig, ax = plt.subplots()
    x = np.arange(len(data))
    names = list(data.keys())
    means = [data[k][0] for k in names]
    errors = [data[k][1] for k in names]

    bars = ax.bar(x, means, yerr=errors, capsize=3, color=colors,
                  edgecolor='black', linewidth=0.5, width=0.6,
                  error_kw={'linewidth': 0.5})

    ax.set_xticks(x)
    ax.set_xticklabels(names, rotation=0)
    ax.set_ylabel(ylabel)
    if title:
        ax.set_title(title)

    # Remove top and right spines
    ax.spines['top'].set_visible(False)
    ax.spines['right'].set_visible(False)

    fig.savefig(output, dpi=300, bbox_inches='tight')
    plt.close()
    return output
```

### Scatter Plots with Regression Lines

```python
from scipy import stats

def publication_scatter(x, y, xlabel, ylabel, output='scatter.pdf',
                         groups=None, group_labels=None):
    """Publication-quality scatter plot with optional regression line."""
    setup_publication_style('nature')
    fig, ax = plt.subplots()

    if groups is None:
        ax.scatter(x, y, s=15, alpha=0.7, color='#0072B2', edgecolors='none')
        # Regression line
        slope, intercept, r, p, se = stats.linregress(x, y)
        x_fit = np.linspace(min(x), max(x), 100)
        ax.plot(x_fit, slope*x_fit + intercept, '--', color='#D55E00', linewidth=0.8)
        ax.text(0.05, 0.95, f'r = {r:.2f}, p = {p:.3f}',
                transform=ax.transAxes, fontsize=6, va='top')
    else:
        colors = get_accessible_palette(len(set(groups)))
        for i, label in enumerate(group_labels or sorted(set(groups))):
            mask = np.array(groups) == label
            ax.scatter(np.array(x)[mask], np.array(y)[mask],
                      s=15, alpha=0.7, color=colors[i], label=label)
        ax.legend(frameon=False)

    ax.set_xlabel(xlabel)
    ax.set_ylabel(ylabel)
    ax.spines['top'].set_visible(False)
    ax.spines['right'].set_visible(False)

    fig.savefig(output, dpi=300, bbox_inches='tight')
    plt.close()
```

## Multi-Panel Figures

```python
def multi_panel_figure(n_rows, n_cols, panel_data, output='multipanel.pdf'):
    """Create a multi-panel figure with automatic panel labels."""
    setup_publication_style('nature')
    fig, axes = plt.subplots(n_rows, n_cols,
                              figsize=(3.3*n_cols, 2.5*n_rows))
    if n_rows * n_cols == 1:
        axes = np.array([axes])
    axes = axes.flatten()

    labels = 'abcdefghijklmnopqrstuvwxyz'
    for i, ax in enumerate(axes[:len(panel_data)]):
        # Add panel label
        ax.text(-0.15, 1.05, labels[i], transform=ax.transAxes,
                fontsize=10, fontweight='bold', va='bottom')

    plt.tight_layout()
    fig.savefig(output, dpi=300, bbox_inches='tight')
    plt.close()
```

## Export Best Practices

1. **Vector formats first**: Use PDF or EPS for line art and charts; TIFF only for photographs
2. **Font embedding**: Ensure all fonts are embedded (use `plt.rcParams['pdf.fonttype'] = 42`)
3. **Check at print size**: View the figure at actual print size (3.3in wide) to verify readability
4. **CMYK conversion**: For print journals, convert RGB to CMYK using ImageMagick or Photoshop
5. **Consistent styling**: All figures in a paper should use the same fonts, colors, and styling

```python
# Ensure fonts are embedded in PDF output
mpl.rcParams['pdf.fonttype'] = 42  # TrueType fonts
mpl.rcParams['ps.fonttype'] = 42
```

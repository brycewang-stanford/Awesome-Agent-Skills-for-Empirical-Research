---
name: python-dataviz-guide
description: "Publication-quality data visualization with matplotlib, seaborn, and plotly"
metadata:
  openclaw:
    emoji: "📊"
    category: "analysis"
    subcategory: "dataviz"
    keywords: ["data visualization", "chart design", "Python dataviz", "scientific figure creation", "publication quality figure"]
    source: "N/A"
---

# Python Data Visualization Guide

## Overview

Data visualization is how researchers communicate quantitative findings. A well-designed figure can convey complex relationships instantly, while a poor one buries the signal in clutter. Python's visualization ecosystem -- anchored by matplotlib, seaborn, and plotly -- provides everything needed to produce publication-quality figures for journals, conferences, and presentations.

This guide covers the three major Python visualization libraries, their strengths and trade-offs, and concrete recipes for the chart types researchers use most frequently. Each example is designed to be copy-paste ready and customizable for your specific dataset and venue requirements.

The emphasis is on producing figures that meet journal standards: correct DPI, appropriate font sizes, accessible color palettes, and vector-format exports. We also cover interactive visualization with plotly for exploratory analysis and supplementary materials.

## Matplotlib: The Foundation

Matplotlib is the most flexible Python plotting library. Nearly every other visualization tool in the Python ecosystem builds on it.

### Setting Up Publication Defaults

```python
import matplotlib.pyplot as plt
import matplotlib as mpl

# Publication-quality defaults
plt.rcParams.update({
    'figure.figsize': (6, 4),
    'figure.dpi': 150,
    'savefig.dpi': 300,
    'savefig.bbox': 'tight',
    'font.size': 11,
    'font.family': 'serif',
    'font.serif': ['Times New Roman'],
    'axes.labelsize': 12,
    'axes.titlesize': 13,
    'xtick.labelsize': 10,
    'ytick.labelsize': 10,
    'legend.fontsize': 10,
    'lines.linewidth': 1.5,
    'lines.markersize': 6,
    'axes.grid': True,
    'grid.alpha': 0.3,
})
```

### Line Plot with Error Bands

```python
import numpy as np

epochs = np.arange(1, 51)
acc_mean = 1 - 0.5 * np.exp(-epochs / 10)
acc_std = 0.03 * np.exp(-epochs / 20)

fig, ax = plt.subplots()
ax.plot(epochs, acc_mean, label='Our Method', color='#2563EB')
ax.fill_between(epochs, acc_mean - acc_std, acc_mean + acc_std,
                alpha=0.2, color='#2563EB')
ax.set_xlabel('Epoch')
ax.set_ylabel('Accuracy')
ax.set_ylim(0.4, 1.0)
ax.legend(frameon=False)
fig.savefig('accuracy_curve.pdf')  # Vector format for papers
```

### Multi-Panel Figures

```python
fig, axes = plt.subplots(1, 3, figsize=(15, 4), sharey=True)

for ax, dataset, color in zip(axes, ['CIFAR-10', 'ImageNet', 'COCO'],
                                ['#2563EB', '#DC2626', '#16A34A']):
    x = np.random.randn(200)
    ax.hist(x, bins=30, color=color, alpha=0.7, edgecolor='white')
    ax.set_title(dataset)
    ax.set_xlabel('Score Distribution')

axes[0].set_ylabel('Count')
plt.tight_layout()
fig.savefig('multi_panel.pdf')
```

## Seaborn: Statistical Visualization

Seaborn excels at statistical graphics with minimal code. It handles data frames natively and produces polished output by default.

### Comparison Bar Chart with Significance

```python
import seaborn as sns
import pandas as pd

data = pd.DataFrame({
    'Method': ['Baseline', 'Baseline', 'Ours', 'Ours', 'Ours+FT', 'Ours+FT'],
    'Metric': ['BLEU', 'ROUGE'] * 3,
    'Score': [34.2, 45.1, 41.8, 52.3, 48.5, 58.7]
})

fig, ax = plt.subplots(figsize=(8, 5))
sns.barplot(data=data, x='Metric', y='Score', hue='Method',
            palette=['#94A3B8', '#3B82F6', '#EF4444'], ax=ax)
ax.set_ylabel('Score')
ax.legend(title='Method', frameon=False)
fig.savefig('comparison.pdf')
```

### Correlation Heatmap

```python
corr_matrix = pd.DataFrame(
    np.random.randn(8, 8),
    columns=[f'Feature {i}' for i in range(8)]
).corr()

fig, ax = plt.subplots(figsize=(8, 7))
sns.heatmap(corr_matrix, annot=True, fmt='.2f', cmap='RdBu_r',
            center=0, square=True, linewidths=0.5, ax=ax)
ax.set_title('Feature Correlation Matrix')
fig.savefig('heatmap.pdf')
```

### Violin Plot for Distribution Comparison

```python
df = pd.DataFrame({
    'Group': np.repeat(['Control', 'Treatment A', 'Treatment B'], 100),
    'Value': np.concatenate([
        np.random.normal(50, 10, 100),
        np.random.normal(55, 8, 100),
        np.random.normal(60, 12, 100)
    ])
})

fig, ax = plt.subplots(figsize=(8, 5))
sns.violinplot(data=df, x='Group', y='Value', palette='Set2',
               inner='box', ax=ax)
ax.set_ylabel('Measurement')
fig.savefig('violin.pdf')
```

## Plotly: Interactive Visualization

Plotly is ideal for exploratory analysis and HTML-based supplementary materials.

```python
import plotly.express as px

df = px.data.gapminder().query("year == 2007")
fig = px.scatter(df, x="gdpPercap", y="lifeExp",
                 size="pop", color="continent",
                 hover_name="country",
                 log_x=True, size_max=60,
                 title="GDP vs Life Expectancy (2007)")
fig.write_html("interactive_scatter.html")
fig.write_image("scatter.pdf")  # Requires kaleido
```

## Chart Type Selection Guide

| Data Relationship | Recommended Chart | Library |
|-------------------|-------------------|---------|
| Trend over time | Line plot | matplotlib |
| Distribution | Histogram, violin, box | seaborn |
| Comparison (categories) | Bar chart, grouped bar | seaborn |
| Correlation (2 vars) | Scatter plot | matplotlib/plotly |
| Correlation (matrix) | Heatmap | seaborn |
| Part-to-whole | Stacked bar (not pie) | matplotlib |
| High-dimensional | PCA/t-SNE scatter | plotly |
| Geospatial | Choropleth | plotly |

## Best Practices

- **Export as PDF or SVG for print, PNG at 300 DPI as fallback.** Never submit JPEG figures to journals.
- **Use colorblind-safe palettes.** `sns.color_palette("colorblind")` or use tools like ColorBrewer.
- **Label everything.** Axes, legends, and units should be readable without referring to the caption.
- **Avoid chartjunk.** Remove unnecessary gridlines, borders, and decorative elements.
- **Match the figure width to the journal column width.** Single-column is typically 3.3 inches; double-column is 6.9 inches.
- **Use consistent styling across all figures in a paper.** Define a style dictionary once and reuse it.
- **Include error bars or confidence intervals.** Raw point estimates without uncertainty are incomplete.

## References

- [matplotlib Documentation](https://matplotlib.org/stable/) -- Official reference
- [seaborn Documentation](https://seaborn.pydata.org/) -- Statistical visualization
- [plotly Documentation](https://plotly.com/python/) -- Interactive charts
- [Scientific Visualization: Python + Matplotlib](https://github.com/rougier/scientific-visualization-book) -- Nicolas Rougier
- [Ten Simple Rules for Better Figures](https://journals.plos.org/ploscompbiol/article?id=10.1371/journal.pcbi.1003833) -- Rougier et al.

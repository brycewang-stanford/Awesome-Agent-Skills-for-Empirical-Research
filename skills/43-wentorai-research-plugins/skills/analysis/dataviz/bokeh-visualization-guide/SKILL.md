---
name: bokeh-visualization-guide
description: "Guide to Bokeh for interactive browser-based research visualizations"
metadata:
  openclaw:
    emoji: "🎨"
    category: "analysis"
    subcategory: "dataviz"
    keywords: ["Bokeh", "interactive plots", "Python visualization", "web dashboards", "scientific charts", "data exploration"]
    source: "https://github.com/bokeh/bokeh"
---

# Bokeh Visualization Guide

## Overview

Bokeh is a Python library for creating interactive visualizations for modern web browsers, with over 20K stars on GitHub. Developed and maintained by NumFocus, Bokeh generates standalone HTML documents or serves live interactive applications. Its architecture renders graphics in the browser using BokehJS, meaning the resulting visualizations are portable and can be shared as static HTML files without requiring Python on the viewer's end.

For researchers, Bokeh offers a unique advantage: its server-backed interactive applications allow real-time data exploration during analysis. Unlike static plotting libraries, Bokeh lets researchers build tools where they can brush-select data points, link multiple views of the same dataset, and stream live data from instruments or simulations. This makes it invaluable for exploratory data analysis in laboratory and computational research settings.

Bokeh provides multiple levels of API access. The high-level `bokeh.plotting` interface is comparable in convenience to matplotlib, while the low-level `bokeh.models` interface gives fine-grained control over every visual element. The library also integrates with HoloViews and Panel for building complex dashboards with minimal code.

## Getting Started with Bokeh

### Installation and Basic Setup

```python
# Install bokeh
# pip install bokeh

from bokeh.plotting import figure, show, output_file, output_notebook
from bokeh.models import ColumnDataSource, HoverTool
import numpy as np
import pandas as pd

# For Jupyter notebooks
output_notebook()

# For standalone HTML files
output_file("research_figure.html")
```

### Basic Scatter Plot for Experimental Data

```python
from bokeh.plotting import figure, show
from bokeh.models import ColumnDataSource, HoverTool

# Prepare data
data = pd.DataFrame({
    'sample_id': [f'S{i:03d}' for i in range(100)],
    'measurement_a': np.random.normal(5, 1.5, 100),
    'measurement_b': np.random.normal(10, 2, 100),
    'group': np.random.choice(['Control', 'Treatment A', 'Treatment B'], 100),
    'pvalue': np.random.uniform(0.001, 0.1, 100)
})

source = ColumnDataSource(data)

# Color mapping by group
color_map = {'Control': '#6B7280', 'Treatment A': '#3B82F6', 'Treatment B': '#EF4444'}
data['color'] = data['group'].map(color_map)

p = figure(
    title='Measurement A vs B by Treatment Group',
    x_axis_label='Measurement A (units)',
    y_axis_label='Measurement B (units)',
    width=700, height=500,
    tools='pan,wheel_zoom,box_zoom,reset,save'
)

for group, color in color_map.items():
    subset = data[data['group'] == group]
    p.circle(
        x='measurement_a', y='measurement_b',
        source=ColumnDataSource(subset),
        color=color, size=8, alpha=0.7,
        legend_label=group
    )

# Add hover tooltip
hover = HoverTool(tooltips=[
    ('Sample', '@sample_id'),
    ('Group', '@group'),
    ('Measure A', '@measurement_a{0.3f}'),
    ('Measure B', '@measurement_b{0.3f}'),
    ('p-value', '@pvalue{0.4f}')
])
p.add_tools(hover)
p.legend.location = 'top_left'
p.legend.click_policy = 'hide'

show(p)
```

## Linked Plots for Multi-Dimensional Data Exploration

One of Bokeh's most powerful features for research is linked brushing, where selecting data in one plot highlights the same data points in all other linked plots.

```python
from bokeh.layouts import gridplot
from bokeh.models import ColumnDataSource

# Shared data source enables linked selections
source = ColumnDataSource(data=dict(
    x1=np.random.normal(0, 1, 500),
    x2=np.random.normal(0, 1, 500),
    x3=np.random.normal(0, 1, 500),
    cluster=np.random.choice(['A', 'B', 'C'], 500)
))

TOOLS = "pan,wheel_zoom,box_select,lasso_select,reset"

# Create linked scatter plots
p1 = figure(title="PC1 vs PC2", tools=TOOLS, width=400, height=400)
p1.circle('x1', 'x2', source=source, alpha=0.6, size=5, color='#3B82F6',
          selection_color='#EF4444', nonselection_alpha=0.1)

p2 = figure(title="PC1 vs PC3", tools=TOOLS, width=400, height=400,
            x_range=p1.x_range)  # Share x-axis range
p2.circle('x1', 'x3', source=source, alpha=0.6, size=5, color='#3B82F6',
          selection_color='#EF4444', nonselection_alpha=0.1)

p3 = figure(title="PC2 vs PC3", tools=TOOLS, width=400, height=400,
            y_range=p2.y_range)  # Share y-axis range
p3.circle('x2', 'x3', source=source, alpha=0.6, size=5, color='#3B82F6',
          selection_color='#EF4444', nonselection_alpha=0.1)

grid = gridplot([[p1, p2], [p3, None]])
show(grid)
```

## Statistical and Scientific Plot Types

### Box Plot with Whiskers

```python
from bokeh.plotting import figure, show
from bokeh.models import ColumnDataSource, Whisker
import pandas as pd

groups = ['Control', 'Low', 'Medium', 'High']
q1 = [2.1, 3.5, 5.2, 6.8]
q2 = [3.0, 4.5, 6.5, 8.0]
q3 = [3.8, 5.5, 7.8, 9.2]
lower = [1.2, 2.5, 3.8, 5.5]
upper = [4.5, 6.5, 9.0, 10.5]

source = ColumnDataSource(data=dict(
    groups=groups, q1=q1, q2=q2, q3=q3, lower=lower, upper=upper
))

p = figure(
    x_range=groups,
    title='Biomarker Levels by Dosage Group',
    y_axis_label='Concentration (ng/mL)',
    width=600, height=450
)

# Boxes
p.vbar(x='groups', top='q3', bottom='q2', width=0.5, source=source,
       fill_color='#3B82F6', line_color='black', fill_alpha=0.7)
p.vbar(x='groups', top='q2', bottom='q1', width=0.5, source=source,
       fill_color='#93C5FD', line_color='black', fill_alpha=0.7)

# Whiskers
p.add_layout(Whisker(source=source, base='groups', upper='upper', lower='lower',
                      level='annotation', line_width=2))

# Median line
p.segment(x0='groups', y0='q2', x1='groups', y1='q2', source=source,
          line_color='red', line_width=2)

show(p)
```

### Heatmap for Gene Expression

```python
from bokeh.plotting import figure, show
from bokeh.models import LinearColorMapper, ColorBar, BasicTicker
from bokeh.transform import transform

genes = [f'Gene_{i}' for i in range(20)]
samples = [f'Sample_{j}' for j in range(10)]
expression = np.random.randn(20, 10)

# Flatten for Bokeh
x_vals, y_vals, values = [], [], []
for i, gene in enumerate(genes):
    for j, sample in enumerate(samples):
        x_vals.append(sample)
        y_vals.append(gene)
        values.append(expression[i, j])

source = ColumnDataSource(dict(x=x_vals, y=y_vals, values=values))

mapper = LinearColorMapper(palette="RdBu11", low=-3, high=3)

p = figure(
    title="Gene Expression Heatmap",
    x_range=samples, y_range=list(reversed(genes)),
    width=700, height=600,
    toolbar_location='right'
)

p.rect(x='x', y='y', width=1, height=1, source=source,
       fill_color=transform('values', mapper), line_color=None)

color_bar = ColorBar(color_mapper=mapper, ticker=BasicTicker(desired_num_ticks=10),
                     label_standoff=8, width=12, location=(0, 0))
p.add_layout(color_bar, 'right')

p.xaxis.major_label_orientation = 0.8
show(p)
```

## Bokeh Server for Live Interactive Applications

Bokeh's server mode allows researchers to build interactive tools with Python callbacks.

```python
from bokeh.io import curdoc
from bokeh.layouts import column
from bokeh.models import Slider
from bokeh.plotting import figure

# Create a plot that updates based on slider input
p = figure(title="Signal with Adjustable Frequency", width=700, height=400)
x = np.linspace(0, 10, 500)
source = ColumnDataSource(data=dict(x=x, y=np.sin(x)))
p.line('x', 'y', source=source, line_width=2)

slider = Slider(start=0.1, end=10, value=1, step=0.1, title="Frequency")

def update(attr, old, new):
    source.data = dict(x=x, y=np.sin(new * x))

slider.on_change('value', update)
curdoc().add_root(column(slider, p))

# Run with: bokeh serve --show script.py
```

## Export and Embedding

```python
from bokeh.io import export_png, export_svgs

# Export as PNG (requires selenium and a browser driver)
export_png(p, filename="figure.png")

# Export as SVG
p.output_backend = "svg"
export_svgs(p, filename="figure.svg")

# Embed as standalone HTML
from bokeh.embed import file_html
from bokeh.resources import CDN
html = file_html(p, CDN, "Research Figure")
with open("figure.html", "w") as f:
    f.write(html)
```

## References

- Bokeh documentation: https://docs.bokeh.org
- Bokeh GitHub repository: https://github.com/bokeh/bokeh
- Bokeh gallery: https://docs.bokeh.org/en/latest/docs/gallery.html
- HoloViews (high-level Bokeh wrapper): https://holoviews.org

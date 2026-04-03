---
name: plotly-interactive-guide
description: "Guide to Plotly.py for interactive scientific visualizations in Python"
metadata:
  openclaw:
    emoji: "🔬"
    category: "analysis"
    subcategory: "dataviz"
    keywords: ["Plotly", "interactive visualization", "Dash", "Python charts", "scientific plots", "research figures"]
    source: "https://github.com/plotly/plotly.py"
---

# Plotly Interactive Visualization Guide

## Overview

Plotly.py is a high-level, interactive graphing library for Python with over 18K stars on GitHub. Built on top of plotly.js (which itself uses D3.js and WebGL), Plotly enables researchers to create publication-quality interactive figures directly from Python code. The library integrates seamlessly with pandas DataFrames, NumPy arrays, and the broader scientific Python ecosystem.

What sets Plotly apart for academic researchers is its Plotly Express module, which provides a concise, high-level API for creating complex visualizations in a single function call. Researchers can go from a pandas DataFrame to a fully interactive figure in one line of code, then customize it further as needed. Every Plotly figure is inherently interactive, supporting hover tooltips, zoom, pan, and selection out of the box.

Plotly also offers Dash, a framework for building analytical web applications entirely in Python. This allows researchers to create interactive dashboards for exploring experimental data, sharing results with collaborators, or building supplementary interactive materials for publications without needing front-end development skills.

## Plotly Express for Quick Research Figures

Plotly Express provides the fastest path from data to visualization. It works directly with pandas DataFrames and supports faceting, color mapping, animation, and trendlines.

### Scatter Plot with Regression

```python
import plotly.express as px
import pandas as pd
import numpy as np

# Simulated experimental data
np.random.seed(42)
df = pd.DataFrame({
    'concentration': np.random.uniform(0.1, 10, 200),
    'response': np.random.normal(0, 1, 200),
    'treatment': np.random.choice(['Drug A', 'Drug B', 'Control'], 200),
    'cell_line': np.random.choice(['HeLa', 'MCF7', 'A549'], 200)
})
df['response'] = df['concentration'] * 0.8 + df['response']

fig = px.scatter(
    df,
    x='concentration',
    y='response',
    color='treatment',
    facet_col='cell_line',
    trendline='ols',
    title='Dose-Response Across Cell Lines',
    labels={'concentration': 'Concentration (uM)', 'response': 'Normalized Response'},
    template='plotly_white'
)
fig.update_layout(font=dict(family='Arial', size=12))
fig.show()
```

### Box Plot with Individual Data Points

```python
fig = px.box(
    df,
    x='treatment',
    y='response',
    color='treatment',
    points='all',
    title='Treatment Response Distribution',
    template='plotly_white'
)
fig.update_traces(quartilemethod='linear')
fig.update_layout(showlegend=False)
fig.show()
```

### Violin Plot for Distribution Comparison

```python
fig = px.violin(
    df,
    x='treatment',
    y='response',
    color='treatment',
    box=True,
    points='outliers',
    title='Response Distribution by Treatment Group',
    template='plotly_white'
)
fig.show()
```

## Graph Objects for Fine-Grained Control

For more customized figures, Plotly's graph_objects module provides full control over every visual element.

### Error Bar Plot for Experimental Results

```python
import plotly.graph_objects as go

groups = ['Control', 'Low Dose', 'Medium Dose', 'High Dose']
means = [1.0, 1.8, 3.2, 4.5]
sems = [0.15, 0.22, 0.31, 0.28]

fig = go.Figure()

fig.add_trace(go.Bar(
    x=groups,
    y=means,
    error_y=dict(type='data', array=sems, visible=True),
    marker_color=['#6B7280', '#3B82F6', '#3B82F6', '#3B82F6'],
    text=[f'{m:.2f}' for m in means],
    textposition='outside'
))

fig.update_layout(
    title='Treatment Effect on Biomarker Levels',
    yaxis_title='Relative Expression',
    xaxis_title='Treatment Group',
    template='plotly_white',
    font=dict(family='Arial', size=13),
    bargap=0.3,
    yaxis=dict(range=[0, max(means) * 1.3])
)

# Add significance brackets
fig.add_annotation(
    x=0.5, y=max(means) * 1.15,
    text='*** p < 0.001',
    showarrow=False,
    font=dict(size=12)
)

fig.show()
```

### Heatmap for Correlation Analysis

```python
import plotly.figure_factory as ff

# Compute correlation matrix
corr_matrix = df[['concentration', 'response']].corr()
variables = corr_matrix.columns.tolist()

fig = ff.create_annotated_heatmap(
    z=corr_matrix.values,
    x=variables,
    y=variables,
    colorscale='RdBu_r',
    zmin=-1, zmax=1,
    showscale=True
)

fig.update_layout(
    title='Variable Correlation Matrix',
    template='plotly_white',
    width=600, height=500
)
fig.show()
```

## 3D and Specialized Scientific Plots

### 3D Surface Plot for Response Surfaces

```python
import plotly.graph_objects as go
import numpy as np

x = np.linspace(-3, 3, 50)
y = np.linspace(-3, 3, 50)
X, Y = np.meshgrid(x, y)
Z = np.sin(np.sqrt(X**2 + Y**2)) * np.exp(-0.1 * (X**2 + Y**2))

fig = go.Figure(data=[go.Surface(
    x=X, y=Y, z=Z,
    colorscale='Viridis',
    contours=dict(
        z=dict(show=True, usecolormap=True, project_z=True)
    )
)])

fig.update_layout(
    title='Response Surface Analysis',
    scene=dict(
        xaxis_title='Factor A',
        yaxis_title='Factor B',
        zaxis_title='Response'
    ),
    width=700, height=600
)
fig.show()
```

### Animated Time-Series for Temporal Data

```python
# Create animated scatter showing progression over experimental phases
fig = px.scatter(
    temporal_df,
    x='metric_a',
    y='metric_b',
    animation_frame='time_point',
    animation_group='sample_id',
    size='magnitude',
    color='cluster',
    hover_name='sample_id',
    title='Sample Trajectories Over Time',
    template='plotly_white',
    range_x=[0, 10],
    range_y=[0, 10]
)
fig.layout.updatemenus[0].buttons[0].args[1]['frame']['duration'] = 800
fig.show()
```

## Exporting for Publications

Plotly provides multiple export options for journal-ready figures.

```python
# Static export (requires kaleido)
fig.write_image('figure_1.pdf', width=800, height=500, scale=3)
fig.write_image('figure_1.svg', width=800, height=500)
fig.write_image('figure_1.png', width=800, height=500, scale=3)

# Interactive HTML for supplementary materials
fig.write_html('interactive_figure.html', include_plotlyjs='cdn')

# Save as JSON for reproducibility
fig.write_json('figure_data.json')
```

## Dash for Interactive Research Dashboards

```python
from dash import Dash, dcc, html, Input, Output
import plotly.express as px

app = Dash(__name__)

app.layout = html.Div([
    html.H1('Experiment Data Explorer'),
    dcc.Dropdown(
        id='variable-select',
        options=[{'label': v, 'value': v} for v in variables],
        value=variables[0]
    ),
    dcc.Graph(id='main-plot')
])

@app.callback(Output('main-plot', 'figure'), Input('variable-select', 'value'))
def update_plot(selected_var):
    return px.histogram(df, x=selected_var, nbins=30, template='plotly_white')

if __name__ == '__main__':
    app.run(debug=True, port=8050)
```

## References

- Plotly Python documentation: https://plotly.com/python/
- Plotly.py GitHub repository: https://github.com/plotly/plotly.py
- Dash documentation: https://dash.plotly.com
- Plotly Express reference: https://plotly.com/python/plotly-express/

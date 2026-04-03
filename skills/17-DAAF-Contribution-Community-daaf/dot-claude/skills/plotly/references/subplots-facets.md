# Subplots & Faceting

## Faceting with Plotly Express

Faceting splits data into multiple panels by category. This is the easiest way to create subplots.

### Basic Faceting

```python
import plotly.express as px

# Facet by column (horizontal split)
fig = px.scatter(df, x="x", y="y", facet_col="category")

# Facet by row (vertical split)
fig = px.scatter(df, x="x", y="y", facet_row="category")

# Both row and column
fig = px.scatter(df, x="x", y="y", facet_row="cat1", facet_col="cat2")
```

### Wrapping Columns

```python
# Wrap to multiple rows
fig = px.scatter(df, x="x", y="y", facet_col="category", facet_col_wrap=3)
```

### Facet Options

| Parameter | Purpose |
|-----------|---------|
| `facet_col` | Column for horizontal facets |
| `facet_row` | Column for vertical facets |
| `facet_col_wrap` | Max columns before wrapping |
| `facet_row_spacing` | Vertical spacing (0-1) |
| `facet_col_spacing` | Horizontal spacing (0-1) |

### Independent Axes

By default, facets share axes. To make them independent:

```python
fig = px.scatter(df, x="x", y="y", facet_col="category")
fig.update_yaxes(matches=None)  # Independent y-axes
fig.update_xaxes(matches=None)  # Independent x-axes
```

### Customizing Facet Labels

```python
fig.for_each_annotation(lambda a: a.update(text=a.text.split("=")[-1]))
```

---

## make_subplots

For more control, use `make_subplots` from `plotly.subplots`.

### Basic Grid

```python
from plotly.subplots import make_subplots
import plotly.graph_objects as go

# Create 2x2 grid
fig = make_subplots(rows=2, cols=2)

# Add traces to specific positions
fig.add_trace(go.Scatter(x=[1,2,3], y=[4,5,6]), row=1, col=1)
fig.add_trace(go.Bar(x=["A","B"], y=[1,2]), row=1, col=2)
fig.add_trace(go.Scatter(x=[1,2,3], y=[6,5,4]), row=2, col=1)
fig.add_trace(go.Histogram(x=[1,1,2,3,3,3]), row=2, col=2)

fig.show()
```

### With Titles

```python
fig = make_subplots(
    rows=2, cols=2,
    subplot_titles=("Plot 1", "Plot 2", "Plot 3", "Plot 4")
)
```

### Shared Axes

```python
# Share x-axes within columns
fig = make_subplots(rows=2, cols=1, shared_xaxes=True)

# Share y-axes within rows
fig = make_subplots(rows=1, cols=2, shared_yaxes=True)

# Share all axes
fig = make_subplots(rows=2, cols=2, shared_xaxes=True, shared_yaxes=True)
```

### Custom Spacing

```python
fig = make_subplots(
    rows=2, cols=2,
    horizontal_spacing=0.1,  # Space between columns (0-1)
    vertical_spacing=0.1     # Space between rows (0-1)
)
```

### Column/Row Sizing

```python
fig = make_subplots(
    rows=2, cols=2,
    column_widths=[0.7, 0.3],  # First column 70%, second 30%
    row_heights=[0.4, 0.6]     # First row 40%, second 60%
)
```

---

## Spanning Rows/Columns

### Colspan and Rowspan

```python
fig = make_subplots(
    rows=2, cols=2,
    specs=[
        [{"colspan": 2}, None],  # First row spans both columns
        [{}, {}]                  # Second row has 2 plots
    ]
)

fig.add_trace(go.Scatter(x=[1,2,3], y=[1,2,3]), row=1, col=1)  # Spans both cols
fig.add_trace(go.Bar(x=["A","B"], y=[1,2]), row=2, col=1)
fig.add_trace(go.Bar(x=["A","B"], y=[2,1]), row=2, col=2)
```

### Row Span

```python
fig = make_subplots(
    rows=2, cols=2,
    specs=[
        [{"rowspan": 2}, {}],  # Left plot spans both rows
        [None, {}]
    ]
)
```

---

## Mixed Chart Types

### Specifying Types

```python
fig = make_subplots(
    rows=1, cols=2,
    specs=[
        [{"type": "xy"}, {"type": "pie"}]
    ]
)

fig.add_trace(go.Scatter(x=[1,2,3], y=[4,5,6]), row=1, col=1)
fig.add_trace(go.Pie(labels=["A","B","C"], values=[1,2,3]), row=1, col=2)
```

### Common Types

| Type | Use For |
|------|---------|
| `"xy"` | Cartesian plots (scatter, bar, line) |
| `"pie"` | Pie charts |
| `"polar"` | Polar charts |
| `"scene"` | 3D plots |
| `"geo"` | Geographic maps |
| `"mapbox"` | Mapbox maps |
| `"domain"` | Sunburst, treemap, etc. |

### Example: Mixed 2D and 3D

```python
fig = make_subplots(
    rows=1, cols=2,
    specs=[[{"type": "xy"}, {"type": "scene"}]]
)

fig.add_trace(go.Scatter(x=[1,2,3], y=[1,2,3]), row=1, col=1)
fig.add_trace(go.Scatter3d(x=[1,2,3], y=[1,2,3], z=[1,2,3]), row=1, col=2)
```

---

## Secondary Y-Axis

### With make_subplots

```python
fig = make_subplots(specs=[[{"secondary_y": True}]])

fig.add_trace(go.Scatter(x=[1,2,3], y=[40,50,60], name="Left"), secondary_y=False)
fig.add_trace(go.Bar(x=[1,2,3], y=[4,5,6], name="Right"), secondary_y=True)

# Set axis titles
fig.update_yaxes(title_text="Left Axis", secondary_y=False)
fig.update_yaxes(title_text="Right Axis", secondary_y=True)
```

---

## Combining px Figures in Subplots

Extract traces from px figures and add to subplots:

```python
from plotly.subplots import make_subplots
import plotly.express as px

# Create px figures
fig1 = px.scatter(df1, x="x", y="y")
fig2 = px.bar(df2, x="category", y="value")

# Create subplot
fig = make_subplots(rows=1, cols=2)

# Add traces from px figures
for trace in fig1.data:
    fig.add_trace(trace, row=1, col=1)

for trace in fig2.data:
    fig.add_trace(trace, row=1, col=2)

fig.show()
```

---

## Updating Subplot Axes

### By Position

```python
fig.update_xaxes(title_text="X Label", row=1, col=1)
fig.update_yaxes(title_text="Y Label", row=1, col=1)
```

### All Axes

```python
fig.update_xaxes(showgrid=False)  # All x-axes
fig.update_yaxes(showgrid=False)  # All y-axes
```

---

## Common Patterns

### Dashboard Layout

```python
fig = make_subplots(
    rows=2, cols=2,
    specs=[
        [{"colspan": 2}, None],
        [{}, {}]
    ],
    subplot_titles=("Overview", "Detail 1", "Detail 2"),
    vertical_spacing=0.15
)

# Main chart spans top row
fig.add_trace(go.Scatter(x=x, y=y), row=1, col=1)

# Two detail charts below
fig.add_trace(go.Bar(x=cats, y=vals1), row=2, col=1)
fig.add_trace(go.Bar(x=cats, y=vals2), row=2, col=2)

fig.update_layout(height=600, title_text="Dashboard")
```

### Comparison Grid

```python
fig = make_subplots(
    rows=2, cols=2,
    shared_xaxes=True,
    shared_yaxes=True,
    subplot_titles=("Q1", "Q2", "Q3", "Q4")
)

# Add same chart type to each
for i, (row, col) in enumerate([(1,1), (1,2), (2,1), (2,2)]):
    fig.add_trace(
        go.Scatter(x=x, y=data[i], name=f"Q{i+1}"),
        row=row, col=col
    )
```

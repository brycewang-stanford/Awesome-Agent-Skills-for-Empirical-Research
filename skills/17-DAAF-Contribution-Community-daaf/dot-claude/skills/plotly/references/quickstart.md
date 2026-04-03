# Quickstart

## Installation

```bash
# Basic install
pip install plotly

# With image export support (not installed in DAAF — use plotnine for static figures)
# pip install plotly kaleido

# Using conda
conda install -c conda-forge plotly
```

## Core Imports

```python
import plotly.express as px              # High-level API (recommended start)
import plotly.graph_objects as go        # Low-level API (full control)
from plotly.subplots import make_subplots # Multi-panel figures
import plotly.io as pio                  # I/O and configuration
```

## Plotly Express vs Graph Objects

Plotly has two main APIs:

### Plotly Express (px)

**Best for**: Quick exploration, standard charts, clean code.

```python
import plotly.express as px

fig = px.scatter(df, x="sepal_width", y="sepal_length", color="species")
fig.show()
```

- One function call creates complete figure
- Automatic legends, axes, hover info
- Returns a `go.Figure` (can use all go methods)
- Supports 30+ chart types

### Graph Objects (go)

**Best for**: Custom layouts, fine-grained control, complex figures.

```python
import plotly.graph_objects as go

fig = go.Figure()
fig.add_trace(go.Scatter(
    x=[1, 2, 3],
    y=[4, 5, 6],
    mode="markers",
    name="Series A"
))
fig.update_layout(title="My Plot")
fig.show()
```

- Build figures trace by trace
- Full control over every property
- More verbose but more flexible

### When to Use Each

| Use Case | Recommendation |
|----------|----------------|
| Quick data exploration | px |
| Standard chart types | px |
| Complex customization | go |
| Multiple trace types | go |
| Subplots with mixed types | go + make_subplots |
| Starting point, then customize | px, then update_* methods |

## Figure Anatomy

Every Plotly figure has two main parts:

```python
fig = go.Figure(
    data=[...],    # List of traces (the actual data/charts)
    layout={...}   # Layout settings (title, axes, legend, etc.)
)
```

Access them:

```python
fig.data      # Tuple of traces
fig.layout    # Layout object
```

## Built-in Datasets

Plotly Express includes sample datasets:

```python
# Load built-in datasets
df = px.data.iris()        # Iris flower measurements
df = px.data.tips()        # Restaurant tips
df = px.data.gapminder()   # Country statistics over time
df = px.data.stocks()      # Stock prices
df = px.data.medals_long() # Olympic medals
df = px.data.wind()        # Wind patterns
df = px.data.carshare()    # Car sharing locations
df = px.data.election()    # Election results
```

Quick example:

```python
import plotly.express as px

df = px.data.iris()
fig = px.scatter(df, x="sepal_width", y="sepal_length", color="species")
fig.show()
```

## Displaying Figures

### In Jupyter Notebooks

Figures display automatically as the last expression:

```python
px.scatter(df, x="x", y="y")  # Auto-displays
```

Or explicitly:

```python
fig = px.scatter(df, x="x", y="y")
fig.show()
```

### In Python Scripts

Always call `.show()`:

```python
fig = px.scatter(df, x="x", y="y")
fig.show()  # Opens in browser
```

Or save to file:

```python
fig.write_html("plot.html")  # Interactive (primary export in DAAF)
# fig.write_image("plot.png")  # NOT available — kaleido not installed; use plotnine for static
```

### Renderer Configuration

```python
import plotly.io as pio

# See available renderers
print(pio.renderers)

# Set default renderer
pio.renderers.default = "browser"    # Open in browser
pio.renderers.default = "notebook"   # Jupyter notebook
pio.renderers.default = "svg"        # Static SVG
```

## Basic Patterns

### Creating a Figure with px

```python
# Most px functions follow this pattern
fig = px.chart_type(
    data_frame,          # DataFrame or dict
    x="column_name",     # X-axis column
    y="column_name",     # Y-axis column
    color="column_name", # Color by category (optional)
    title="My Title"     # Chart title (optional)
)
```

### Creating a Figure with go

```python
# Create empty figure
fig = go.Figure()

# Add traces
fig.add_trace(go.Scatter(x=x, y=y, name="Series 1"))
fig.add_trace(go.Bar(x=x, y=y2, name="Series 2"))

# Update layout
fig.update_layout(title="My Plot", xaxis_title="X", yaxis_title="Y")

# Show
fig.show()
```

### Updating Figures

Both px and go figures support update methods:

```python
# Update layout
fig.update_layout(title="New Title", height=500)

# Update all traces
fig.update_traces(marker_size=10)

# Update axes
fig.update_xaxes(title_text="X Axis")
fig.update_yaxes(title_text="Y Axis")
```

## Method Chaining

All update methods return the figure, enabling chaining:

```python
fig = (
    px.scatter(df, x="x", y="y", color="category")
    .update_layout(title="My Plot")
    .update_traces(marker_size=12)
    .update_xaxes(showgrid=False)
)
```

## Quick Comparison

| Task | Plotly Express | Graph Objects |
|------|----------------|---------------|
| Scatter plot | `px.scatter(df, x="a", y="b")` | `go.Figure(go.Scatter(x=x, y=y))` |
| Add color | `color="col"` parameter | `marker_color=` in trace |
| Add title | `title="My Title"` | `.update_layout(title="My Title")` |
| Multiple series | `color="series_col"` | Multiple `add_trace()` calls |

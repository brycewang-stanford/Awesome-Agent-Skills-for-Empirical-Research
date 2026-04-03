# Chart Types

## Scatter Plots

### Plotly Express

```python
import plotly.express as px

# Basic scatter
fig = px.scatter(df, x="col_x", y="col_y")

# With color, size, and hover
fig = px.scatter(
    df,
    x="sepal_width",
    y="sepal_length",
    color="species",           # Color by category
    size="petal_length",       # Size by value
    hover_data=["petal_width"] # Extra hover info
)
```

### Graph Objects

```python
import plotly.graph_objects as go

fig = go.Figure(go.Scatter(
    x=[1, 2, 3, 4],
    y=[10, 11, 12, 13],
    mode="markers",  # "markers", "lines", or "lines+markers"
    marker=dict(size=10, color="blue")
))
```

### Common Options

| Parameter (px) | Purpose |
|----------------|---------|
| `color` | Color points by column |
| `size` | Size points by column |
| `symbol` | Shape by column |
| `hover_data` | Additional hover columns |
| `hover_name` | Main hover label |
| `text` | Text labels on points |
| `trendline` | Add trendline ("ols", "lowess") |
| `marginal_x/y` | Marginal plots ("histogram", "box", "violin", "rug") |

---

## Line Charts

### Plotly Express

```python
# Basic line
fig = px.line(df, x="date", y="value")

# Multiple lines by color
fig = px.line(df, x="date", y="value", color="category")

# With markers
fig = px.line(df, x="date", y="value", markers=True)
```

### Graph Objects

```python
fig = go.Figure()

fig.add_trace(go.Scatter(
    x=dates,
    y=values,
    mode="lines",           # or "lines+markers"
    name="Series A",
    line=dict(color="blue", width=2, dash="dash")  # dash: "solid", "dot", "dash"
))
```

### Line Styles

```python
# Dashed line
fig.add_trace(go.Scatter(
    x=x, y=y,
    mode="lines",
    line=dict(dash="dash")  # "solid", "dot", "dash", "longdash", "dashdot"
))
```

---

## Bar Charts

### Plotly Express

```python
# Vertical bars
fig = px.bar(df, x="category", y="value")

# Horizontal bars
fig = px.bar(df, x="value", y="category", orientation="h")

# Grouped bars
fig = px.bar(df, x="category", y="value", color="group", barmode="group")

# Stacked bars
fig = px.bar(df, x="category", y="value", color="group", barmode="stack")
```

### Graph Objects

```python
fig = go.Figure()

fig.add_trace(go.Bar(x=categories, y=values, name="Series A"))
fig.add_trace(go.Bar(x=categories, y=values2, name="Series B"))

# Set bar mode
fig.update_layout(barmode="group")  # "group", "stack", "relative", "overlay"
```

### Bar Options

| Parameter | Purpose |
|-----------|---------|
| `barmode` | "group", "stack", "relative", "overlay" |
| `orientation` | "v" (vertical) or "h" (horizontal) |
| `text` | Labels on bars |
| `text_auto` | Auto-format bar labels (px) |

---

## Histograms

### Plotly Express

```python
# Basic histogram
fig = px.histogram(df, x="value")

# With bins
fig = px.histogram(df, x="value", nbins=30)

# Colored by category
fig = px.histogram(df, x="value", color="category")

# Stacked or overlaid
fig = px.histogram(df, x="value", color="category", barmode="overlay")
```

### Graph Objects

```python
fig = go.Figure(go.Histogram(
    x=data,
    nbinsx=30,
    name="Distribution"
))
```

### Histogram Options

| Parameter | Purpose |
|-----------|---------|
| `nbins` | Number of bins |
| `histnorm` | Normalization: "percent", "probability", "density", "probability density" |
| `cumulative` | Cumulative histogram |
| `barmode` | "stack", "overlay", "group" |
| `marginal` | Add marginal plot: "rug", "box", "violin" |

---

## Box Plots

### Plotly Express

```python
# Basic box plot
fig = px.box(df, y="value")

# Grouped by category
fig = px.box(df, x="category", y="value")

# With individual points
fig = px.box(df, x="category", y="value", points="all")  # "all", "outliers", "suspectedoutliers", False

# Notched (confidence interval)
fig = px.box(df, x="category", y="value", notched=True)
```

### Graph Objects

```python
fig = go.Figure(go.Box(
    y=data,
    name="Distribution",
    boxpoints="all",  # "all", "outliers", "suspectedoutliers", False
    jitter=0.3,
    pointpos=-1.8
))
```

---

## Violin Plots

### Plotly Express

```python
# Basic violin
fig = px.violin(df, y="value")

# Grouped
fig = px.violin(df, x="category", y="value")

# With box and points
fig = px.violin(df, x="category", y="value", box=True, points="all")
```

### Graph Objects

```python
fig = go.Figure(go.Violin(
    y=data,
    box_visible=True,
    meanline_visible=True
))
```

---

## Heatmaps

### Plotly Express

```python
# From 2D array
fig = px.imshow(z_data)

# With labels
fig = px.imshow(
    z_data,
    labels=dict(x="X Label", y="Y Label", color="Value"),
    x=x_labels,
    y=y_labels
)

# Color scale
fig = px.imshow(z_data, color_continuous_scale="Viridis")
```

### Graph Objects

```python
fig = go.Figure(go.Heatmap(
    z=z_data,
    x=x_labels,
    y=y_labels,
    colorscale="Viridis"
))
```

### Annotated Heatmap

```python
import plotly.figure_factory as ff

fig = ff.create_annotated_heatmap(
    z=z_data,
    x=x_labels,
    y=y_labels,
    colorscale="Blues"
)
```

---

## Pie Charts

### Plotly Express

```python
fig = px.pie(df, values="value", names="category")

# Donut chart
fig = px.pie(df, values="value", names="category", hole=0.4)
```

### Graph Objects

```python
fig = go.Figure(go.Pie(
    labels=categories,
    values=values,
    hole=0.4  # For donut
))
```

---

## Other Chart Types

### 3D Scatter

```python
fig = px.scatter_3d(df, x="x", y="y", z="z", color="category")
```

### 3D Surface

```python
fig = go.Figure(go.Surface(z=z_data, x=x, y=y))
```

### Geographic Maps

```python
# Choropleth (colored regions)
fig = px.choropleth(
    df,
    locations="country_code",
    color="value",
    locationmode="ISO-3"
)

# Scatter on map
fig = px.scatter_geo(df, lat="latitude", lon="longitude", size="value")
```

### Financial Charts

```python
# Candlestick
fig = go.Figure(go.Candlestick(
    x=dates,
    open=open_prices,
    high=high_prices,
    low=low_prices,
    close=close_prices
))

# OHLC
fig = go.Figure(go.Ohlc(
    x=dates,
    open=open_prices,
    high=high_prices,
    low=low_prices,
    close=close_prices
))
```

### Hierarchical Charts

```python
# Sunburst
fig = px.sunburst(df, path=["continent", "country", "city"], values="population")

# Treemap
fig = px.treemap(df, path=["continent", "country"], values="population")
```

### Polar Charts

```python
# Polar scatter
fig = px.scatter_polar(df, r="value", theta="angle", color="category")

# Polar bar (wind rose)
fig = px.bar_polar(df, r="frequency", theta="direction", color="strength")
```

---

## Chart Selection Guide

| Data Type | Chart |
|-----------|-------|
| Two continuous variables | `px.scatter()` |
| Time series | `px.line()` |
| Categories vs values | `px.bar()` |
| Distribution (one var) | `px.histogram()` |
| Distribution comparison | `px.box()` or `px.violin()` |
| Matrix/correlation | `px.imshow()` (heatmap) |
| Part of whole | `px.pie()` |
| 3D relationships | `px.scatter_3d()` |
| Geographic data | `px.choropleth()` or `px.scatter_geo()` |
| Hierarchical data | `px.sunburst()` or `px.treemap()` |

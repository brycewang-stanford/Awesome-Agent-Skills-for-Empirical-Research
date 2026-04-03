# Styling & Customization

## Templates (Themes)

### Built-in Templates

```python
import plotly.io as pio

# List available templates
print(pio.templates)
```

| Template | Description |
|----------|-------------|
| `plotly` | Default Plotly theme |
| `plotly_white` | White background, minimal |
| `plotly_dark` | Dark theme |
| `ggplot2` | R ggplot2 style |
| `seaborn` | Seaborn style |
| `simple_white` | Clean, minimal |
| `presentation` | Large fonts for slides |
| `none` | No default styling |

### Using Templates

```python
# In Plotly Express
fig = px.scatter(df, x="x", y="y", template="plotly_dark")

# In Graph Objects
fig.update_layout(template="plotly_white")

# Set default for all figures
import plotly.io as pio
pio.templates.default = "plotly_dark"
```

### Combining Templates

```python
fig.update_layout(template="plotly_dark+presentation")
```

---

## Layout Customization

### Title

```python
fig.update_layout(
    title=dict(
        text="My Chart Title",
        x=0.5,              # Center (0=left, 1=right)
        font=dict(size=24)
    )
)

# Simple version
fig.update_layout(title="My Chart Title")
```

### Size

```python
fig.update_layout(
    width=800,
    height=600,
    autosize=False
)
```

### Margins

```python
fig.update_layout(
    margin=dict(l=50, r=50, t=80, b=50)  # left, right, top, bottom
)

# Tight margins
fig.update_layout(margin=dict(l=0, r=0, t=30, b=0))
```

### Background

```python
fig.update_layout(
    paper_bgcolor="white",   # Area outside plot
    plot_bgcolor="lightgray" # Plot area
)
```

### Font

```python
fig.update_layout(
    font=dict(
        family="Arial, sans-serif",
        size=14,
        color="black"
    )
)
```

---

## Axis Customization

### Axis Titles

```python
fig.update_xaxes(title_text="X Axis Label")
fig.update_yaxes(title_text="Y Axis Label")

# Or via layout
fig.update_layout(
    xaxis_title="X Axis Label",
    yaxis_title="Y Axis Label"
)
```

### Axis Range

```python
fig.update_xaxes(range=[0, 100])
fig.update_yaxes(range=[-10, 10])

# Auto-range with padding
fig.update_yaxes(rangemode="tozero")  # Start at zero
```

### Tick Formatting

```python
fig.update_xaxes(
    tickformat=".2f",           # Number format
    tickprefix="$",             # Prefix
    ticksuffix="%",             # Suffix
    tickangle=45,               # Rotate labels
    dtick=10                    # Tick interval
)

# Date format
fig.update_xaxes(tickformat="%Y-%m-%d")
```

### Log Scale

```python
fig.update_yaxes(type="log")
```

### Reversed Axis

```python
fig.update_yaxes(autorange="reversed")
```

### Grid Lines

```python
fig.update_xaxes(
    showgrid=True,
    gridwidth=1,
    gridcolor="lightgray"
)

# Hide grid
fig.update_xaxes(showgrid=False)
fig.update_yaxes(showgrid=False)
```

### Axis Lines

```python
fig.update_xaxes(
    showline=True,
    linewidth=2,
    linecolor="black",
    mirror=True  # Show on opposite side too
)
```

---

## Legend

### Position

```python
fig.update_layout(
    legend=dict(
        x=1,           # 0=left, 1=right
        y=1,           # 0=bottom, 1=top
        xanchor="left",
        yanchor="top"
    )
)

# Horizontal legend at bottom
fig.update_layout(
    legend=dict(
        orientation="h",
        x=0.5,
        y=-0.1,
        xanchor="center"
    )
)
```

### Legend Title

```python
fig.update_layout(legend_title_text="Categories")
```

### Hide Legend

```python
fig.update_layout(showlegend=False)
```

### Legend Appearance

```python
fig.update_layout(
    legend=dict(
        bgcolor="white",
        bordercolor="black",
        borderwidth=1
    )
)
```

---

## Colors

### Discrete Colors (Categories)

```python
# Plotly Express - use built-in sequence
fig = px.scatter(df, x="x", y="y", color="category",
                 color_discrete_sequence=px.colors.qualitative.Set1)

# Custom color map
fig = px.scatter(df, x="x", y="y", color="category",
                 color_discrete_map={"A": "red", "B": "blue", "C": "green"})
```

### Built-in Color Sequences

```python
import plotly.express as px

px.colors.qualitative.Plotly    # Default
px.colors.qualitative.Set1
px.colors.qualitative.Set2
px.colors.qualitative.Pastel
px.colors.qualitative.Dark24
px.colors.qualitative.Alphabet
```

### Continuous Colors (Numeric)

```python
# Plotly Express
fig = px.scatter(df, x="x", y="y", color="value",
                 color_continuous_scale="Viridis")

# Built-in scales: "Viridis", "Plasma", "Inferno", "Magma",
# "Blues", "Reds", "Greens", "RdBu", "Spectral", etc.
```

### Reversed Color Scale

```python
fig = px.scatter(df, x="x", y="y", color="value",
                 color_continuous_scale="Viridis_r")  # _r for reversed
```

### Graph Objects Colors

```python
fig.add_trace(go.Scatter(
    x=x, y=y,
    marker=dict(
        color=values,              # Color by values
        colorscale="Viridis",
        showscale=True             # Show colorbar
    )
))

# Fixed color
fig.add_trace(go.Scatter(
    x=x, y=y,
    marker_color="red"
))
```

---

## Hover Customization

### Hover Template

```python
fig.update_traces(
    hovertemplate="X: %{x}<br>Y: %{y}<br>Name: %{text}<extra></extra>"
)

# Format numbers
hovertemplate="Value: %{y:.2f}<extra></extra>"

# <extra></extra> removes trace name box
```

### Hover Info

```python
# Control what appears on hover
fig.update_traces(hoverinfo="x+y")  # Only x and y

# Options: "x", "y", "z", "text", "name", "all", "none", "skip"
```

### Hover Data (px)

```python
fig = px.scatter(df, x="x", y="y",
                 hover_data=["col1", "col2"],  # Add columns
                 hover_name="name_col")        # Main label
```

### Hover Mode

```python
fig.update_layout(hovermode="x unified")  # All traces at same x

# Options: "x", "y", "closest", "x unified", "y unified", False
```

---

## Annotations

### Text Annotations

```python
fig.add_annotation(
    x=2,
    y=5,
    text="Important point",
    showarrow=True,
    arrowhead=2
)
```

### Multiple Annotations

```python
fig.update_layout(
    annotations=[
        dict(x=1, y=2, text="Point A", showarrow=True),
        dict(x=3, y=4, text="Point B", showarrow=True),
    ]
)
```

### Annotation Styling

```python
fig.add_annotation(
    x=2, y=5,
    text="Label",
    font=dict(size=14, color="red"),
    bgcolor="white",
    bordercolor="black",
    borderwidth=1
)
```

---

## Shapes

### Reference Lines

```python
# Horizontal line
fig.add_hline(y=50, line_dash="dash", line_color="red")

# Vertical line
fig.add_vline(x="2020-01-01", line_dash="dot")

# With annotation
fig.add_hline(y=50, annotation_text="Target")
```

### Rectangles

```python
fig.add_vrect(x0="2020-01", x1="2020-06", fillcolor="green", opacity=0.2)
fig.add_hrect(y0=0, y1=50, fillcolor="red", opacity=0.1)
```

### Custom Shapes

```python
fig.add_shape(
    type="rect",
    x0=1, x1=3,
    y0=1, y1=4,
    line=dict(color="blue"),
    fillcolor="lightblue",
    opacity=0.5
)
```

---

## Quick Styling Recipes

### Publication-Ready

```python
fig.update_layout(
    template="simple_white",
    font=dict(family="Arial", size=12),
    title=dict(font=dict(size=16)),
    margin=dict(l=60, r=20, t=40, b=40)
)
fig.update_xaxes(showline=True, linewidth=1, linecolor="black")
fig.update_yaxes(showline=True, linewidth=1, linecolor="black")
```

### Dark Theme

```python
fig.update_layout(
    template="plotly_dark",
    paper_bgcolor="#1e1e1e",
    plot_bgcolor="#1e1e1e"
)
```

### Minimal

```python
fig.update_layout(
    template="simple_white",
    showlegend=False
)
fig.update_xaxes(showgrid=False)
fig.update_yaxes(showgrid=False)
```

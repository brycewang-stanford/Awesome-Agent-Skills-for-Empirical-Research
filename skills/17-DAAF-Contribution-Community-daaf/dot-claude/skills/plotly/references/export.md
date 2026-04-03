# Export & Saving

## Interactive HTML

### Basic HTML Export

```python
# Save to file
fig.write_html("plot.html")

# Get HTML string
html_string = fig.to_html()
```

### Include Plotly.js Options

```python
# Full file with embedded Plotly.js (~3MB)
fig.write_html("plot.html", include_plotlyjs=True)

# Use CDN (smaller file, requires internet)
fig.write_html("plot.html", include_plotlyjs="cdn")

# Separate directory (reusable across files)
fig.write_html("plot.html", include_plotlyjs="directory")

# No Plotly.js (for embedding in page that already has it)
fig.write_html("plot.html", include_plotlyjs=False)
```

### Full HTML vs Div Only

```python
# Full HTML document
fig.write_html("plot.html", full_html=True)

# Just the div (for embedding)
fig.write_html("plot.html", full_html=False)

# Or get div string
div_string = fig.to_html(full_html=False)
```

### Config Options

```python
fig.write_html(
    "plot.html",
    config={
        "displayModeBar": False,      # Hide toolbar
        "scrollZoom": False,          # Disable scroll zoom
        "staticPlot": True,           # Disable all interaction
        "displaylogo": False,         # Hide Plotly logo
        "modeBarButtonsToRemove": ["zoom2d", "pan2d"]  # Remove specific buttons
    }
)
```

### Animation Options

```python
fig.write_html(
    "plot.html",
    auto_play=False  # Don't auto-play animations
)
```

---

## Static Images

> **DAAF note:** kaleido is NOT installed in the DAAF container. Static image
> export (`write_image`) is unavailable. Use **plotnine** for static PNG/SVG
> figures in reports. Reserve Plotly for interactive HTML output. The kaleido
> package requires a bundled Chromium browser (~300MB) plus 9 system shared
> libraries, which is excessive for this use case. The reference below is
> retained for completeness if kaleido is installed in a custom environment.

### Installation

```bash
pip install -U kaleido
```

### Basic Image Export

```python
# PNG
fig.write_image("plot.png")

# JPEG
fig.write_image("plot.jpg")

# SVG (vector)
fig.write_image("plot.svg")

# PDF (vector)
fig.write_image("plot.pdf")

# WebP
fig.write_image("plot.webp")
```

### Size and Resolution

```python
fig.write_image(
    "plot.png",
    width=1200,      # Pixels
    height=800,      # Pixels
    scale=2          # 2x resolution (for retina/print)
)
```

### Get Image Bytes

```python
# Get bytes (for APIs, in-memory use)
img_bytes = fig.to_image(format="png")

# With size
img_bytes = fig.to_image(format="png", width=800, height=600)
```

### Supported Formats

| Format | Extension | Type | Notes |
|--------|-----------|------|-------|
| PNG | `.png` | Raster | Best for web |
| JPEG | `.jpg` | Raster | Smaller, lossy |
| WebP | `.webp` | Raster | Modern, efficient |
| SVG | `.svg` | Vector | Scalable, editable |
| PDF | `.pdf` | Vector | Print quality |

---

## JSON Export

### Save to JSON

```python
# Write to file
fig.write_json("plot.json")

# Get JSON string
json_string = fig.to_json()
```

### Load from JSON

```python
import plotly.io as pio

# From file
fig = pio.read_json("plot.json")

# From string
fig = pio.from_json(json_string)
```

### Dictionary Representation

```python
# Get figure as dict
fig_dict = fig.to_dict()

# Access parts
fig_dict["data"]    # Traces
fig_dict["layout"]  # Layout

# Create figure from dict
fig = go.Figure(fig_dict)
```

---

## Embedding in Web Pages

### Basic Embed

```html
<!DOCTYPE html>
<html>
<head>
    <!-- Warning: plotly-latest.min.js is frozen at v1.58.5. For Plotly 6.x, use a versioned URL, e.g., plotly-2.35.2.min.js -->
    <script src="https://cdn.plot.ly/plotly-latest.min.js"></script>
</head>
<body>
    <!-- Get div from fig.to_html(full_html=False) -->
    <div id="plotly-div">
        <!-- Plot will render here -->
    </div>
</body>
</html>
```

### Using to_html for Embedding

```python
# Get just the div + script
div_html = fig.to_html(
    full_html=False,
    include_plotlyjs="cdn"  # Or False if page already has it
)

# Insert div_html into your page template
```

### Responsive Sizing

```python
fig.update_layout(
    autosize=True,
    width=None,   # Let container control width
    height=None
)

html = fig.to_html(
    full_html=False,
    include_plotlyjs="cdn",
    default_width="100%",
    default_height="500px"
)
```

---

## Batch Export

### Multiple Figures

```python
import plotly.io as pio

figures = [fig1, fig2, fig3]

for i, fig in enumerate(figures):
    fig.write_image(f"plot_{i}.png")
    fig.write_html(f"plot_{i}.html")
```

### Using pio Functions

```python
import plotly.io as pio

# These work on figure objects directly
pio.write_html(fig, "plot.html")
pio.write_image(fig, "plot.png")
pio.write_json(fig, "plot.json")

# Read functions
fig = pio.read_json("plot.json")
```

---

## Export Configuration

### Set Default Image Engine

```python
import plotly.io as pio

# Use kaleido (recommended)
# Note (Plotly 6.2+): pio.kaleido.scope.* is deprecated. Use pio.defaults.* instead,
# e.g., pio.defaults.default_format = 'png'
pio.kaleido.scope.default_format = "png"
pio.kaleido.scope.default_width = 800
pio.kaleido.scope.default_height = 600
pio.kaleido.scope.default_scale = 2
```

### Default Export Settings

```python
# Set defaults that apply to all exports
pio.kaleido.scope.default_format = "png"
pio.kaleido.scope.default_width = 1200
pio.kaleido.scope.default_height = 800
```

---

## Quick Reference

| Task | Method |
|------|--------|
| Interactive HTML file | `fig.write_html("plot.html")` |
| HTML string | `fig.to_html()` |
| PNG image | `fig.write_image("plot.png")` |
| High-res PNG | `fig.write_image("plot.png", scale=2)` |
| SVG (vector) | `fig.write_image("plot.svg")` |
| PDF | `fig.write_image("plot.pdf")` |
| JSON file | `fig.write_json("plot.json")` |
| JSON string | `fig.to_json()` |
| Image bytes | `fig.to_image(format="png")` |
| Load from JSON | `pio.read_json("plot.json")` |

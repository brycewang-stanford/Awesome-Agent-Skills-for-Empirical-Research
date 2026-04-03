# Quickstart

## Installation

```bash
pip install plotnine
# or
conda install -c conda-forge plotnine
```

## Basic Imports

```python
# Import everything (common approach)
from plotnine import *

# Or import specific components
from plotnine import ggplot, aes, geom_point, geom_line, theme_minimal
```

## Built-in Datasets

```python
from plotnine.data import mtcars, diamonds, mpg, economics, faithful
```

## Basic Plot Anatomy

Every plot follows this pattern:

```python
(
    ggplot(data, aes(x="column_x", y="column_y"))  # Data + aesthetics
    + geom_point()                                  # Geometry layer
)
```

### Key Components

| Component | Purpose |
|-----------|---------|
| `ggplot()` | Initialize plot with data |
| `aes()` | Map columns to visual properties |
| `geom_*()` | Define how to represent data |
| `+` | Add layers/components |

## Minimal Example

```python
from plotnine import ggplot, aes, geom_point
from plotnine.data import mtcars

(
    ggplot(mtcars, aes(x="wt", y="mpg"))
    + geom_point()
)
```

## Adding Layers

Layers are added with `+`:

```python
(
    ggplot(mtcars, aes("wt", "mpg"))
    + geom_point()
    + geom_smooth(method="lm")
)
```

## Multi-line Syntax

Use parentheses to span multiple lines:

```python
p = (
    ggplot(df, aes("x", "y"))
    + geom_point()
    + theme_minimal()
)
```

## Displaying Plots

### In Jupyter/IPython

The plot displays automatically as the last expression:

```python
ggplot(df, aes("x", "y")) + geom_point()
```

### In Scripts

Assign to variable and call `.draw()`:

```python
p = ggplot(df, aes("x", "y")) + geom_point()
p.draw()
```

## Saving Plots

```python
p = ggplot(df, aes("x", "y")) + geom_point()

# Basic save
p.save("plot.png")

# With options
p.save("plot.png", width=10, height=8, dpi=300)

# Different formats
p.save("plot.pdf")
p.save("plot.svg")
```

### Save Parameters

| Parameter | Description |
|-----------|-------------|
| `filename` | Output path |
| `width` | Width in inches |
| `height` | Height in inches |
| `dpi` | Resolution (default 100) |
| `format` | Override file extension |

## DataFrame Requirements

plotnine works with:
- **Pandas DataFrame** (primary)
- **Polars DataFrame** (supported)

Column names are passed as **strings**:

```python
# Correct
aes(x="column_name", y="other_column")

# Wrong
aes(x=column_name, y=other_column)
```

## Quick Examples

### Scatter with Color

```python
(
    ggplot(mtcars, aes("wt", "mpg", color="factor(cyl)"))
    + geom_point()
)
```

### Line Plot

```python
(
    ggplot(economics, aes("date", "unemploy"))
    + geom_line()
)
```

### Bar Chart

```python
(
    ggplot(mtcars, aes(x="factor(cyl)"))
    + geom_bar()
)
```

### Histogram

```python
(
    ggplot(diamonds, aes(x="price"))
    + geom_histogram(bins=30)
)
```

## Next Steps

- [Geoms](./geoms.md) - Chart types
- [Aesthetics](./aesthetics.md) - Visual mappings
- [Scales & Coords](./scales-coords.md) - Axis control
- [Facets & Themes](./facets-themes.md) - Layout and styling

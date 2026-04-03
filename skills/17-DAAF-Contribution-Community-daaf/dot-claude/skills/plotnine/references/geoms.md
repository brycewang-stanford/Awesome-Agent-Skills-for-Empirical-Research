# Geoms (Geometric Objects)

Geoms determine how data is visually represented. Each geom has required and optional aesthetics.

## Geoms by Use Case

### Points & Scatter

| Geom | Description | Required aes |
|------|-------------|--------------|
| `geom_point()` | Scatter plot | x, y |
| `geom_jitter()` | Jittered points | x, y |
| `geom_count()` | Count overlapping points | x, y |

```python
# Basic scatter
ggplot(df, aes("x", "y")) + geom_point()

# With jitter for overplotting
ggplot(df, aes("x", "y")) + geom_jitter(width=0.2)
```

### Lines & Paths

| Geom | Description | Required aes |
|------|-------------|--------------|
| `geom_line()` | Connect points (ordered by x) | x, y |
| `geom_path()` | Connect points (data order) | x, y |
| `geom_step()` | Step line | x, y |
| `geom_segment()` | Line segment | x, y, xend, yend |

```python
# Line plot
ggplot(df, aes("date", "value")) + geom_line()

# Grouped lines
ggplot(df, aes("date", "value", color="group")) + geom_line()
```

### Bars

| Geom | Description | Required aes |
|------|-------------|--------------|
| `geom_bar()` | Bar heights from counts | x |
| `geom_col()` | Bar heights from values | x, y |

```python
# Count occurrences
ggplot(df, aes(x="category")) + geom_bar()

# Use existing values
ggplot(df, aes(x="category", y="value")) + geom_col()

# Stacked bars
ggplot(df, aes("category", fill="group")) + geom_bar()

# Dodged (side-by-side)
ggplot(df, aes("category", fill="group")) + geom_bar(position="dodge")
```

### Distributions

| Geom | Description | Required aes |
|------|-------------|--------------|
| `geom_histogram()` | Histogram | x |
| `geom_density()` | Density curve | x |
| `geom_freqpoly()` | Frequency polygon | x |

```python
# Histogram
ggplot(df, aes(x="value")) + geom_histogram(bins=30)

# Density
ggplot(df, aes(x="value")) + geom_density()

# Overlaid densities
ggplot(df, aes(x="value", fill="group")) + geom_density(alpha=0.5)
```

### Box & Violin

| Geom | Description | Required aes |
|------|-------------|--------------|
| `geom_boxplot()` | Box-and-whisker | x, y |
| `geom_violin()` | Violin plot | x, y |

```python
# Boxplot by group
ggplot(df, aes("category", "value")) + geom_boxplot()

# Violin plot
ggplot(df, aes("category", "value")) + geom_violin()
```

### Area & Ribbon

| Geom | Description | Required aes |
|------|-------------|--------------|
| `geom_area()` | Area under line | x, y |
| `geom_ribbon()` | Ribbon with ymin/ymax | x, ymin, ymax |

```python
# Stacked area
ggplot(df, aes("date", "value", fill="group")) + geom_area()

# Confidence band
ggplot(df, aes("x", ymin="lower", ymax="upper")) + geom_ribbon(alpha=0.3)
```

### Smoothing & Trends

| Geom | Description | Required aes |
|------|-------------|--------------|
| `geom_smooth()` | Smoothed conditional mean | x, y |

```python
# Default: method="auto" (loess for n<1000, glm otherwise)
ggplot(df, aes("x", "y")) + geom_point() + geom_smooth()

# Linear regression
ggplot(df, aes("x", "y")) + geom_point() + geom_smooth(method="lm")

# Without confidence interval
ggplot(df, aes("x", "y")) + geom_smooth(se=False)
```

### Error Bars

| Geom | Description | Required aes |
|------|-------------|--------------|
| `geom_errorbar()` | Vertical error bars | x, ymin, ymax |
| `geom_errorbarh()` | Horizontal error bars | y, xmin, xmax |
| `geom_pointrange()` | Point with range | x, y, ymin, ymax |
| `geom_linerange()` | Vertical line | x, ymin, ymax |

```python
# Error bars
ggplot(df, aes("category", "mean", ymin="lower", ymax="upper")) + geom_errorbar()

# Point with range
ggplot(df, aes("category", "mean", ymin="lower", ymax="upper")) + geom_pointrange()
```

### Text & Labels

| Geom | Description | Required aes |
|------|-------------|--------------|
| `geom_text()` | Text labels | x, y, label |
| `geom_label()` | Text with background | x, y, label |

```python
# Add labels
ggplot(df, aes("x", "y", label="name")) + geom_point() + geom_text()

# Adjust position
ggplot(df, aes("x", "y", label="name")) + geom_text(nudge_y=0.5)
```

### Reference Lines

| Geom | Description | Parameters |
|------|-------------|------------|
| `geom_hline()` | Horizontal line | yintercept |
| `geom_vline()` | Vertical line | xintercept |
| `geom_abline()` | Line by slope/intercept | slope, intercept |

```python
# Add reference lines
(
    ggplot(df, aes("x", "y"))
    + geom_point()
    + geom_hline(yintercept=0, linetype="dashed")
    + geom_vline(xintercept=5, color="red")
)
```

### 2D Density

| Geom | Description | Required aes |
|------|-------------|--------------|
| `geom_bin_2d()` | 2D histogram | x, y |
| `geom_density_2d()` | 2D density contours | x, y |

```python
# 2D bins (heatmap)
ggplot(df, aes("x", "y")) + geom_bin_2d()

# Density contours
ggplot(df, aes("x", "y")) + geom_density_2d()
```

### Tiles & Raster

| Geom | Description | Required aes |
|------|-------------|--------------|
| `geom_tile()` | Rectangle by center | x, y |
| `geom_rect()` | Rectangle by corners | xmin, xmax, ymin, ymax |
| `geom_raster()` | Fast tiles (equal size) | x, y |

```python
# Heatmap
ggplot(df, aes("x", "y", fill="value")) + geom_tile()
```

## Common Geom Parameters

| Parameter | Description | Example |
|-----------|-------------|---------|
| `color` | Outline color | `color="blue"` |
| `fill` | Fill color | `fill="red"` |
| `alpha` | Transparency (0-1) | `alpha=0.5` |
| `size` | Size | `size=2` |
| `linetype` | Line style | `linetype="dashed"` |
| `position` | Position adjustment | `position="dodge"` |

## Position Adjustments

Use `position` parameter to handle overlapping:

| Position | Description |
|----------|-------------|
| `"identity"` | No adjustment (default) |
| `"dodge"` | Side by side |
| `"stack"` | Stack on top |
| `"fill"` | Stack and normalize to 100% |
| `"jitter"` | Random noise |

```python
# Dodged bars
geom_bar(position="dodge")

# Stacked area
geom_area(position="stack")

# Custom jitter
geom_point(position=position_jitter(width=0.2, height=0))
```

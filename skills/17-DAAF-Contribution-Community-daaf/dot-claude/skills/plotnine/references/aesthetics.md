# Aesthetics

Aesthetics map data columns to visual properties using `aes()`.

## The aes() Function

```python
aes(x="column_x", y="column_y", color="column_color")
```

### Placement

**In ggplot()** - applies to all layers:

```python
ggplot(df, aes("x", "y", color="group")) + geom_point() + geom_line()
```

**In geom_*()** - applies to that layer only:

```python
ggplot(df, aes("x", "y")) + geom_point(aes(color="group"))
```

## Variable vs. Literal Values

### Variable Mapping (inside aes)

Maps a column to the aesthetic:

```python
# Color varies by "species" column
aes(color="species")
```

### Literal Value (outside aes)

Sets a fixed value:

```python
# All points are blue
geom_point(color="blue")
```

### Common Mistake

```python
# WRONG: looks for column named "blue"
aes(color="blue")

# CORRECT: fixed color
geom_point(color="blue")

# CORRECT: map to column
aes(color="species")
```

## Core Aesthetics

| Aesthetic | Description | Applies to |
|-----------|-------------|------------|
| `x` | X position | All |
| `y` | Y position | All |
| `color` | Outline/point color | Points, lines |
| `fill` | Fill color | Bars, areas, polygons |
| `size` | Size | Points, lines |
| `shape` | Point shape | Points |
| `alpha` | Transparency | All |
| `linetype` | Line pattern | Lines |
| `group` | Grouping (no legend) | Lines, paths |

## Color vs. Fill

- **color**: Outline of shapes, color of points and lines
- **fill**: Interior of shapes

```python
# Points use color
geom_point(aes(color="group"))

# Bars use fill (and optionally color for outline)
geom_bar(aes(fill="group"))

# Both
geom_bar(aes(fill="group"), color="black")
```

## Grouping

Use `group` to connect or group data without creating a legend:

```python
# Multiple lines without color distinction
ggplot(df, aes("x", "y", group="id")) + geom_line()
```

## Computed Aesthetics

### after_stat()

Access computed statistics:

```python
# Density scaled to max 1
geom_density(aes(y=after_stat("scaled")))

# Histogram with density instead of count
geom_histogram(aes(y=after_stat("density")))
```

### after_scale()

Access scaled values:

```python
# Lighter fill color
geom_bar(aes(fill="group", alpha=after_scale("fill")))
```

## Aesthetic Specifications

### Colors

Named colors, hex codes, or RGB:

```python
color="red"
color="steelblue"
color="#FF5733"
```

### Shapes

**Note:** plotnine uses matplotlib marker codes, not ggplot2's 0-25 integer system. Common markers: `'o'` (circle), `'s'` (square), `'^'` (triangle up), `'D'` (diamond), `'v'` (triangle down), `'+'` (plus), `'x'` (cross). The ggplot2 integer codes below may work for some shapes but matplotlib string markers are preferred.

Integer codes (0-25) or names:

| Code | Name |
|------|------|
| 0 | square open |
| 1 | circle open |
| 2 | triangle open |
| 15 | square |
| 16 | circle |
| 17 | triangle |
| 19 | circle (default) |
| 21 | circle filled |

```python
geom_point(shape=17)  # triangles
geom_point(shape="triangle")
```

### Linetypes

Integer codes or names:

| Code | Name |
|------|------|
| 0 | blank |
| 1 | solid |
| 2 | dashed |
| 3 | dotted |
| 4 | dotdash |
| 5 | longdash |
| 6 | twodash |

```python
geom_line(linetype="dashed")
geom_line(linetype=2)
```

### Sizes

Numeric values (in mm for most geoms):

```python
geom_point(size=3)
geom_line(size=1.5)
```

### Alpha (Transparency)

Values from 0 (invisible) to 1 (opaque):

```python
geom_point(alpha=0.5)
```

## factor() for Discrete Mapping

Convert continuous to discrete:

```python
# Treat numeric as categorical
aes(color="factor(cyl)")
```

## reorder() for Ordering

Order categories by another variable:

```python
# Order bars by count
aes(x="reorder(category, -count)", y="count")
```

## Multiple Aesthetics Example

```python
(
    ggplot(df, aes(
        x="x",
        y="y",
        color="group",
        size="value",
        shape="type",
        alpha="confidence"
    ))
    + geom_point()
)
```

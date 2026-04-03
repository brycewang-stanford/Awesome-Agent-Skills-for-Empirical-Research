# Gotchas & Best Practices

## Common Errors

### Column Name Issues

**Error**: `KeyError` or "column not found"

**Cause**: Column names must be strings in `aes()`.

```python
# WRONG
aes(x=column_name, y=other)

# CORRECT
aes(x="column_name", y="other")
```

### Literal vs. Mapped Color

**Problem**: All points same color when expecting variation.

```python
# WRONG: looks for column named "blue"
aes(color="blue")

# CORRECT: fixed color (outside aes)
geom_point(color="blue")

# CORRECT: mapped to column
aes(color="species")
```

### Missing Required Aesthetic

**Error**: `PlotnineError: geom_*() requires the following missing aesthetics: ...`

**Fix**: Add required aesthetics to `aes()`.

```python
# geom_point needs x and y
ggplot(df, aes(x="col1", y="col2")) + geom_point()
```

### Plus at End of Line

**Error**: `SyntaxError`

**Cause**: Python doesn't allow `+` at line end without continuation.

```python
# WRONG
ggplot(df, aes("x", "y")) +
geom_point()

# CORRECT: use parentheses
(
    ggplot(df, aes("x", "y"))
    + geom_point()
)
```

### Data Type Mismatch

**Problem**: Unexpected plot behavior or errors.

```python
# If "year" is numeric but should be categorical
aes(x="factor(year)")

# Or convert in pandas first
df["year"] = df["year"].astype(str)
```

### Grouped Data Not Connecting

**Problem**: `geom_line()` draws separate segments.

**Fix**: Add `group` aesthetic.

```python
# Multiple lines by group
aes(x="x", y="y", group="id")

# Or use color (implicitly groups)
aes(x="x", y="y", color="id")
```

## ggplot2 Differences

### String Column Names

R uses bare names; Python uses strings:

```r
# R
aes(x = column, y = other)
```

```python
# Python
aes(x="column", y="other")
```

### Formula Syntax in Facets

```python
# plotnine uses string formula
facet_grid("row ~ col")

# Not R's bare formula
# facet_grid(row ~ col)  # WRONG
```

### factor() Syntax

```python
# In aes string
aes(color="factor(cyl)")
```

### Some Functions Missing

Not all ggplot2 functions exist. Check API reference for alternatives.

### plotnine vs ggplot2 Divergences

These gotchas catch R ggplot2 users who translate code directly to plotnine.

**`stat_summary` requires a callable, not a string:**

In R ggplot2, `stat_summary(fun="mean")` accepts a string function name. In
plotnine, the `fun_y`, `fun_ymin`, and `fun_ymax` parameters require a Python
callable — not a string.

```python
import numpy as np

# WRONG: R-style string name
stat_summary(fun_y="mean")  # Error

# CORRECT: Python callable
stat_summary(fun_y=np.mean)
stat_summary(fun_y=np.mean, fun_ymin=np.min, fun_ymax=np.max)
```

**`guide=False` is deprecated in scale functions:**

In R ggplot2, `guide=FALSE` or `guide="none"` inside a scale function removes
that scale's legend entry. In recent plotnine versions, `guide=False` inside
scale functions is deprecated. Use `theme(legend_position="none")` to remove all
legends, or `guides(color=None)` to remove a specific scale's legend.

```python
# WRONG: deprecated in recent plotnine
scale_color_brewer(guide=False)

# CORRECT: remove all legends
theme(legend_position="none")

# CORRECT: remove specific scale legend
guides(color=None)
```

**R color names are not valid:**

Named colors from R like `"gray40"`, `"grey80"`, `"steelblue1"` are not
recognized by plotnine/matplotlib. Use hex codes or matplotlib named colors.

```python
# WRONG: R-style color names
geom_point(color="gray40")    # Not recognized
geom_point(color="steelblue1")  # Not recognized

# CORRECT: hex codes
geom_point(color="#666666")

# CORRECT: matplotlib named colors
geom_point(color="steelblue")
geom_point(color="gray")
```

**`guide_colorbar()` parameters differ from R:**

The parameter names and behavior of `guide_colorbar()` differ between R ggplot2
and plotnine. Always check the plotnine docs for exact parameter names rather
than copying R code directly.

## Performance Tips

### Large Datasets

1. **Sample data** for exploration:
   ```python
   ggplot(df.sample(1000), aes(...))
   ```

2. **Use `geom_bin_2d()`** instead of `geom_point()` for millions of points.

3. **Reduce DPI** during development:
   ```python
   theme(dpi=72)
   ```

### Memory

Save plots explicitly and close:

```python
p = ggplot(...) + geom_point()
p.save("plot.png")
del p
```

## Best Practices

### Choosing Geoms

| Data | Geom |
|------|------|
| x: continuous, y: continuous | `geom_point()`, `geom_smooth()` |
| x: discrete, y: continuous | `geom_boxplot()`, `geom_violin()` |
| x: continuous (distribution) | `geom_histogram()`, `geom_density()` |
| x: discrete (counts) | `geom_bar()` |
| x: continuous, y: continuous (time) | `geom_line()` |

### Color vs. Fill

- **Points, lines**: use `color`
- **Bars, areas, polygons**: use `fill` (and `color` for outline)

```python
# Points
geom_point(aes(color="group"))

# Bars
geom_bar(aes(fill="group"))
```

### Layer Order

Later layers draw on top:

```python
(
    ggplot(df, aes("x", "y"))
    + geom_point(color="gray")     # Bottom
    + geom_smooth(color="red")     # Top
)
```

### Consistent Styling

Create reusable theme:

```python
my_theme = (
    theme_minimal()
    + theme(
        axis_text=element_text(size=12),
        plot_title=element_text(size=16, weight="bold")
    )
)

# Apply to plots
ggplot(...) + geom_point() + my_theme
```

### Readable Code

```python
# Good: clear structure
(
    ggplot(df, aes("x", "y", color="group"))
    + geom_point(size=2)
    + geom_smooth(method="lm")
    + scale_color_brewer(palette="Set1")
    + labs(title="My Plot", x="X Label", y="Y Label")
    + theme_minimal()
)
```

## Debugging

### Check Data

```python
print(df.head())
print(df.dtypes)
print(df["column"].unique())
```

### Simplify Plot

Start minimal, add layers one at a time:

```python
# Start here
ggplot(df, aes("x", "y")) + geom_point()

# Then add
+ geom_smooth()

# Then add
+ facet_wrap("group")
```

### Print Intermediate

```python
p = ggplot(df, aes("x", "y"))
print(p)  # Shows structure
p + geom_point()
```

## Quick Fixes

| Problem | Fix |
|---------|-----|
| Plot not showing | Add `.draw()` or ensure last expression |
| Legend unwanted | `+ theme(legend_position="none")` or `+ guides(color=None)` |
| Axis labels overlapping | `+ theme(axis_text_x=element_text(angle=45))` |
| Too many legend items | Filter data or use `scale_*_manual()` |
| Bars not stacking | Check `position="stack"` |
| Points hidden | Add `alpha=0.5` or `position_jitter()` |
| Wrong colors | Check `color` vs `fill` |
| Facets same scale | Use `scales="free"` |

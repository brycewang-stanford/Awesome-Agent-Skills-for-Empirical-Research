# Scales, Coordinates & Positions

## Scales Overview

Scales control how data values map to visual properties.

### Scale Naming Convention

```
scale_<aesthetic>_<type>()
```

Examples: `scale_x_continuous()`, `scale_color_brewer()`, `scale_fill_manual()`

## Position Scales

### Continuous

| Scale | Description |
|-------|-------------|
| `scale_x_continuous()` | Continuous x-axis |
| `scale_y_continuous()` | Continuous y-axis |
| `scale_x_log10()` | Log10 x-axis |
| `scale_y_log10()` | Log10 y-axis |
| `scale_x_sqrt()` | Square root x |
| `scale_x_reverse()` | Reverse direction |

```python
# Custom breaks and labels
scale_x_continuous(breaks=[0, 5, 10], labels=["Low", "Mid", "High"])

# Limit range
scale_x_continuous(limits=(0, 100))

# Format labels
scale_y_continuous(labels=lambda x: f"${x:,.0f}")
```

### Discrete

| Scale | Description |
|-------|-------------|
| `scale_x_discrete()` | Categorical x-axis |
| `scale_y_discrete()` | Categorical y-axis |

```python
# Reorder categories
scale_x_discrete(limits=["C", "B", "A"])
```

### DateTime

| Scale | Description |
|-------|-------------|
| `scale_x_datetime()` | Date/time x-axis |
| `scale_x_date()` | Date x-axis |

```python
scale_x_datetime(date_labels="%Y-%m")
```

## Color & Fill Scales

### Discrete Colors

| Scale | Description |
|-------|-------------|
| `scale_color_brewer()` | ColorBrewer palettes |
| `scale_fill_brewer()` | ColorBrewer fills |
| `scale_color_manual()` | Custom colors |
| `scale_fill_manual()` | Custom fills |
| `scale_color_hue()` | Default hue-based |

```python
# ColorBrewer palette
scale_color_brewer(palette="Set1")
scale_fill_brewer(palette="Blues")

# Manual colors
scale_color_manual(values=["red", "blue", "green"])
scale_fill_manual(values={"A": "#FF0000", "B": "#00FF00"})
```

### ColorBrewer Palettes

| Type | Palettes |
|------|----------|
| Sequential | Blues, Greens, Oranges, Reds, Purples, Greys |
| Diverging | RdBu, RdYlBu, BrBG, PiYG, PRGn, RdYlGn |
| Qualitative | Set1, Set2, Set3, Pastel1, Dark2, Paired |

### Continuous Colors

| Scale | Description |
|-------|-------------|
| `scale_color_gradient()` | Two-color gradient |
| `scale_color_gradient2()` | Diverging gradient |
| `scale_color_gradientn()` | Multi-color gradient |
| `scale_color_distiller()` | ColorBrewer continuous |
| `scale_color_cmap()` | Matplotlib colormap |

```python
# Two-color gradient
scale_color_gradient(low="white", high="red")

# Diverging with midpoint
scale_color_gradient2(low="blue", mid="white", high="red", midpoint=0)

# Matplotlib colormap
scale_color_cmap(cmap_name="viridis")
```

### Grey Scale

```python
scale_color_grey()
scale_fill_grey(start=0.2, end=0.8)
```

## Other Scales

### Size

```python
scale_size(range=(1, 10))
scale_size_area(max_size=10)  # Area proportional to value
```

### Shape

```python
scale_shape_manual(values=[16, 17, 18])
```

### Alpha

```python
scale_alpha(range=(0.2, 1))
```

### Linetype

```python
scale_linetype_manual(values=["solid", "dashed", "dotted"])
```

## Axis Limits

### Quick Methods

```python
xlim(0, 100)
ylim(-10, 10)
lims(x=(0, 100), y=(-10, 10))
```

### Via Scales

```python
scale_x_continuous(limits=(0, 100))
```

### Coordinate Limits (Zoom)

```python
# Zooms without removing data
coord_cartesian(xlim=(0, 100))
```

**Difference**: `limits` in scales removes data outside range; `coord_cartesian` just zooms.

## Coordinates

### coord_cartesian()

Default Cartesian coordinates:

```python
coord_cartesian(xlim=(0, 10), ylim=(0, 100))
```

### coord_fixed()

Fixed aspect ratio:

```python
coord_fixed(ratio=1)  # Square plot
```

### coord_flip()

Swap x and y axes:

```python
# Horizontal bar chart
ggplot(df, aes("category", "value")) + geom_col() + coord_flip()
```

### coord_trans()

Transform coordinates:

```python
coord_trans(x="log10", y="sqrt")
```

## Position Adjustments

Used to handle overlapping elements.

| Position | Use |
|----------|-----|
| `position_identity()` | No adjustment |
| `position_dodge()` | Side by side |
| `position_dodge2()` | Side by side (preserve width) |
| `position_stack()` | Stack vertically |
| `position_fill()` | Stack to 100% |
| `position_jitter()` | Random noise |
| `position_jitterdodge()` | Both |
| `position_nudge()` | Fixed offset |

```python
# Dodge with custom width
geom_bar(position=position_dodge(width=0.8))

# Jitter with control
geom_point(position=position_jitter(width=0.2, height=0))

# Nudge labels
geom_text(position=position_nudge(y=0.5))
```

## Guides (Legends)

### Modify Legend

```python
# Legend title
scale_color_brewer(name="Category", palette="Set1")

# Remove all legends
theme(legend_position="none")

# Remove legend for a specific scale
guides(color=None)

# Customize legend
guides(color=guide_legend(title="My Title", nrow=2))
```

> **Note:** `guide=False` inside scale functions (e.g., `scale_color_brewer(guide=False)`)
> is deprecated in recent plotnine versions. Use `theme(legend_position="none")` to remove
> all legends, or `guides(color=None)` for a specific scale.

### guide_legend()

```python
guide_legend(
    title="Title",
    nrow=2,
    ncol=1,
    reverse=True
)
```

### guide_colorbar()

For continuous color scales:

```python
guide_colorbar(
    title="Value",
    barwidth=10,
    barheight=100
)
```

> **Note:** The parameter names and behavior of `guide_colorbar()` differ between
> R ggplot2 and plotnine. Always check the plotnine docs for exact parameter names
> rather than copying R code directly.

## Common Patterns

### Percentage Y-Axis

```python
scale_y_continuous(labels=lambda x: f"{x:.0%}")
```

### Currency Format

```python
scale_y_continuous(labels=lambda x: f"${x:,.0f}")
```

### Scientific Notation

```python
scale_y_continuous(labels=lambda x: f"{x:.2e}")
```

### Date Formatting

```python
scale_x_datetime(date_labels="%b %Y")  # "Jan 2024"
```

### Reverse Axis

```python
scale_y_reverse()
```

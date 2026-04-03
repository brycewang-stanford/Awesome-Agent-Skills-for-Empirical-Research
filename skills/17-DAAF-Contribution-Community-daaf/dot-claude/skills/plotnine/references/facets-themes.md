# Facets & Themes

## Faceting

Create multiple panels (small multiples) from data subsets.

### facet_wrap()

Wrap panels into rows/columns:

```python
# Single variable
facet_wrap("variable")

# Control layout
facet_wrap("variable", ncol=3)
facet_wrap("variable", nrow=2)

# Free scales
facet_wrap("variable", scales="free")
facet_wrap("variable", scales="free_x")
facet_wrap("variable", scales="free_y")
```

### facet_grid()

Grid layout with row and column variables:

```python
# Rows by one variable, columns by another
facet_grid("row_var ~ col_var")

# Only rows
facet_grid("row_var ~ .")

# Only columns
facet_grid(". ~ col_var")

# Free scales
facet_grid("row ~ col", scales="free")
```

### Facet Labels

```python
# Show variable name and value
facet_wrap("var", labeller=label_both)

# Custom labels
facet_wrap("var", labeller=labeller(var={"A": "Group A", "B": "Group B"}))
```

### Labeller Options

| Function | Result |
|----------|--------|
| `label_value` | Value only (default) |
| `label_both` | Variable: Value |
| `label_context` | Smart context |

## Labels & Titles

### labs()

Set multiple labels:

```python
labs(
    title="Main Title",
    subtitle="Subtitle",
    caption="Data source: ...",
    x="X Axis Label",
    y="Y Axis Label",
    color="Legend Title",
    fill="Fill Legend"
)
```

### Individual Functions

```python
ggtitle("Title")
xlab("X Label")
ylab("Y Label")
```

## Themes

### Premade Themes

| Theme | Description |
|-------|-------------|
| `theme_gray()` | Default gray background |
| `theme_bw()` | Black and white |
| `theme_minimal()` | Minimal, no background |
| `theme_classic()` | Classic, axes only |
| `theme_light()` | Light gray lines |
| `theme_dark()` | Dark background |
| `theme_void()` | Nothing (maps, etc.) |
| `theme_538()` | FiveThirtyEight style |
| `theme_tufte()` | Tufte minimal ink |
| `theme_xkcd()` | XKCD comic style |

```python
ggplot(df, aes("x", "y")) + geom_point() + theme_minimal()
```

### Theme Base Parameters

```python
theme_minimal(base_size=14, base_family="Arial")
```

## Custom Themes

### theme()

Modify individual elements:

```python
theme(
    axis_text=element_text(size=12),
    axis_title=element_text(size=14, weight="bold"),
    legend_position="bottom",
    panel_grid_major=element_line(color="gray", size=0.5),
    panel_background=element_rect(fill="white")
)
```

### Element Functions

| Function | For |
|----------|-----|
| `element_text()` | Text styling |
| `element_line()` | Lines and borders |
| `element_rect()` | Rectangles (backgrounds) |
| `element_blank()` | Remove element |

### element_text()

```python
element_text(
    size=12,
    color="black",
    family="Arial",
    weight="bold",      # normal, bold
    style="italic",     # normal, italic
    angle=45,
    hjust=0.5,          # horizontal alignment
    vjust=0.5           # vertical alignment
)
```

### element_line()

```python
element_line(
    color="gray",
    size=0.5,
    linetype="dashed"
)
```

### element_rect()

```python
element_rect(
    fill="white",
    color="black",
    size=1
)
```

### element_blank()

Remove an element:

```python
theme(panel_grid_minor=element_blank())
```

## Common Theme Modifications

### Legend Position

```python
theme(legend_position="bottom")     # bottom, top, left, right
theme(legend_position="none")       # remove legend
theme(legend_position=(0.8, 0.2))   # coordinates (0-1)
```

### Remove Grid Lines

```python
theme(
    panel_grid_major=element_blank(),
    panel_grid_minor=element_blank()
)
```

### Rotate Axis Labels

```python
theme(axis_text_x=element_text(angle=45, hjust=1))
```

### Transparent Background

```python
theme(
    panel_background=element_rect(fill="transparent"),
    plot_background=element_rect(fill="transparent")
)
```

### Figure Size

```python
theme(figure_size=(10, 6))  # width, height in inches
```

### DPI

```python
theme(dpi=300)
```

## Themeable Elements

### Axis

| Element | Description |
|---------|-------------|
| `axis_title` | Both axis titles |
| `axis_title_x` | X axis title |
| `axis_title_y` | Y axis title |
| `axis_text` | Both tick labels |
| `axis_text_x` | X tick labels |
| `axis_text_y` | Y tick labels |
| `axis_ticks` | Tick marks |
| `axis_line` | Axis lines |

### Panel

| Element | Description |
|---------|-------------|
| `panel_background` | Panel background |
| `panel_border` | Panel border |
| `panel_grid_major` | Major grid lines |
| `panel_grid_minor` | Minor grid lines |
| `panel_spacing` | Space between panels |

### Legend

| Element | Description |
|---------|-------------|
| `legend_position` | Position |
| `legend_title` | Legend title |
| `legend_text` | Legend labels |
| `legend_background` | Background |
| `legend_key` | Key background |

### Plot

| Element | Description |
|---------|-------------|
| `plot_title` | Main title |
| `plot_subtitle` | Subtitle |
| `plot_caption` | Caption |
| `plot_background` | Overall background |
| `plot_margin` | Margins |

### Strip (Facet Labels)

| Element | Description |
|---------|-------------|
| `strip_text` | Facet label text |
| `strip_text_x` | Top strip text |
| `strip_text_y` | Right strip text |
| `strip_background` | Strip background |

## Combining Themes

```python
(
    ggplot(df, aes("x", "y"))
    + geom_point()
    + theme_minimal()
    + theme(
        axis_text=element_text(size=12),
        legend_position="bottom"
    )
)
```

## Set Default Theme

```python
from plotnine import theme_set, theme_minimal

theme_set(theme_minimal())
```

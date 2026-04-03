# Visualization: R to Python Translation

This reference covers translating R visualization code to Python within the DAAF
stack. The core mapping is **ggplot2 to plotnine** for static plots and **plotly R
to plotly Python** for interactive plots. plotnine implements the same grammar of
graphics as ggplot2 and provides the highest-fidelity R-to-Python translation of
any visualization library in the DAAF ecosystem. R users familiar with ggplot2
will find plotnine immediately recognizable -- the mental model, layer system,
and component names are identical. The differences are syntactic, not conceptual.

For R-only visualization tools (ggeffects, sjPlot, coefplot, ggridges, patchwork),
this reference documents the DAAF workaround or equivalent.

> **Versions referenced:**
> Python: plotnine 0.15.3, plotly 6.5.2
> R: ggplot2 4.0.2, plotly 4.12.0
> See SKILL.md § Library Versions for the complete version table.

## Section 1: ggplot2 to plotnine -- Core Grammar

The grammar of graphics in plotnine is a near-1:1 port of ggplot2. The building
blocks are the same: `ggplot()` initializes the plot, `aes()` maps data to visual
properties, `geom_*()` layers define geometry, `scale_*()` controls mappings,
`facet_*()` creates panels, and `theme_*()` controls styling. You compose them
with the `+` operator, exactly as in R.

### Key Syntax Differences

| Aspect | ggplot2 (R) | plotnine (Python) |
|--------|-------------|-------------------|
| Column references in `aes()` | Bare names: `aes(x = year, y = value)` | Strings: `aes(x="year", y="value")` |
| Formula in facets | Formula: `facet_wrap(~ var)` | String: `facet_wrap("var")` |
| Import pattern | `library(ggplot2)` | `from plotnine import *` or selective imports |
| Saving plots | `ggsave("file.png", p, width=10, height=8)` | `p.save("file.png", width=10, height=8, dpi=300)` |
| Display in scripts | `print(p)` | `p.draw()` or `print(p)` |
| Multi-line syntax | `+` at end of line works | Wrap in `()` with `+` at start of line |
| Dot in names | `element_text()`, `panel.grid.major` | `element_text()`, `panel_grid_major` (underscore) |
| factor() in aes | `aes(color = factor(cyl))` | `aes(color="factor(cyl)")` (inside string) |

### Complete Parallel Example

**R (ggplot2):**

```r
library(ggplot2)

p <- ggplot(mtcars, aes(x = wt, y = mpg, color = factor(cyl))) +
  geom_point(size = 3) +
  geom_smooth(method = "lm", se = FALSE) +
  scale_color_brewer(palette = "Set1") +
  labs(
    title = "Fuel Efficiency vs Weight",
    x = "Weight (1000 lbs)",
    y = "Miles per Gallon",
    color = "Cylinders"
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(size = 16, face = "bold"),
    legend.position = "bottom"
  )

ggsave("mpg_vs_wt.png", p, width = 10, height = 8)
```

**Python (plotnine):**

```python
from plotnine import *
from plotnine.data import mtcars

p = (
    ggplot(mtcars, aes(x="wt", y="mpg", color="factor(cyl)"))
    + geom_point(size=3)
    + geom_smooth(method="lm", se=False)
    + scale_color_brewer(palette="Set1")
    + labs(
        title="Fuel Efficiency vs Weight",
        x="Weight (1000 lbs)",
        y="Miles per Gallon",
        color="Cylinders",
    )
    + theme_minimal()
    + theme(
        plot_title=element_text(size=16, weight="bold"),
        legend_position="bottom",
    )
)

p.save("mpg_vs_wt.png", width=10, height=8, dpi=300)
```

Note three differences: (1) column names are strings in `aes()`, (2) `face="bold"`
becomes `weight="bold"`, (3) theme element names use underscores not dots.

## Section 2: Geom Mapping

plotnine (v0.15.x) provides 40+ geoms. The vast majority are named identically to
their ggplot2 counterparts and accept the same parameters. The table below covers
the most commonly used geoms and flags the few that differ.

### Complete Geom Translation Table

| ggplot2 | plotnine | Status | Notes |
|---------|----------|--------|-------|
| `geom_point()` | `geom_point()` | Identical | |
| `geom_line()` | `geom_line()` | Identical | |
| `geom_path()` | `geom_path()` | Identical | Uses `size` not `linewidth` |
| `geom_step()` | `geom_step()` | Identical | |
| `geom_bar()` | `geom_bar()` | Identical | |
| `geom_col()` | `geom_col()` | Identical | |
| `geom_histogram()` | `geom_histogram()` | Identical | |
| `geom_boxplot()` | `geom_boxplot()` | Identical | |
| `geom_violin()` | `geom_violin()` | Identical | |
| `geom_smooth()` | `geom_smooth()` | Identical | |
| `geom_tile()` | `geom_tile()` | Identical | |
| `geom_raster()` | `geom_raster()` | Identical | |
| `geom_rect()` | `geom_rect()` | Identical | |
| `geom_text()` | `geom_text()` | Minor diff | `hjust`/`vjust` accept strings only, not numeric |
| `geom_label()` | `geom_label()` | Minor diff | Same `hjust`/`vjust` limitation |
| `geom_hline()` | `geom_hline()` | Identical | |
| `geom_vline()` | `geom_vline()` | Identical | |
| `geom_abline()` | `geom_abline()` | Identical | |
| `geom_ribbon()` | `geom_ribbon()` | Identical | |
| `geom_area()` | `geom_area()` | Identical | |
| `geom_density()` | `geom_density()` | Identical | |
| `geom_density_2d()` | `geom_density_2d()` | Identical | |
| `geom_bin_2d()` | `geom_bin_2d()` | Identical | |
| `geom_errorbar()` | `geom_errorbar()` | Identical | |
| `geom_errorbarh()` | `geom_errorbarh()` | Identical | |
| `geom_pointrange()` | `geom_pointrange()` | Identical | |
| `geom_linerange()` | `geom_linerange()` | Identical | |
| `geom_crossbar()` | `geom_crossbar()` | Identical | |
| `geom_jitter()` | `geom_jitter()` | Identical | |
| `geom_count()` | `geom_count()` | Identical | |
| `geom_segment()` | `geom_segment()` | Identical | |
| `geom_polygon()` | `geom_polygon()` | Identical | |
| `geom_rug()` | `geom_rug()` | Identical | |
| `geom_freqpoly()` | `geom_freqpoly()` | Identical | |
| `geom_dotplot()` | `geom_dotplot()` | Identical | |
| `geom_spoke()` | `geom_spoke()` | Identical | |
| `geom_qq()` | `geom_qq()` | Identical | |
| `geom_qq_line()` | `geom_qq_line()` | Identical | |
| `geom_quantile()` | `geom_quantile()` | Identical | |
| `geom_sina()` | `geom_sina()` | Identical | From ggforce in R; built into plotnine |
| `geom_map()` | `geom_map()` | Available | Draws GeoDataFrame geometries; see Section 8 |
| `geom_sf()` | Not available | **Missing** | Use `geom_map()` with geopandas GeoDataFrame |
| `geom_sf_text()` | Not available | **Missing** | Use `geom_text()` with centroid coordinates |
| `geom_sf_label()` | Not available | **Missing** | Use `geom_label()` with centroid coordinates |

### Geoms Not in plotnine and Workarounds

- **`geom_sf()` / `coord_sf()`**: plotnine does not have native simple features
  support. Use `geom_map()` with a geopandas GeoDataFrame, or use geopandas'
  own `.plot()` method for spatial visualization. For production maps in DAAF,
  prefer geopandas directly (see the `geopandas` skill).
- **`geom_contour_filled()`**: Use `geom_density_2d()` with `fill` aesthetic or
  use matplotlib directly.
- **`geom_sf_text()` / `geom_sf_label()`**: Extract centroids from geometries
  into x/y columns, then use `geom_text()` or `geom_label()`.

## Section 3: Aesthetics, Scales, and Coordinates

### aes() Mapping

The `aes()` function is identical in concept. The only difference is that plotnine
requires string column names.

```r
# R
aes(x = year, y = enrollment, color = sector, size = total_revenue)
```

```python
# Python
aes(x="year", y="enrollment", color="sector", size="total_revenue")
```

Computed aesthetics use `after_stat()` in both languages:

```r
# R
geom_histogram(aes(y = after_stat(density)))
```

```python
# Python
geom_histogram(aes(y=after_stat("density")))
```

### Scales -- Direct Translation

Scale functions translate directly. The naming convention
`scale_<aesthetic>_<type>()` is identical in both libraries.

| ggplot2 | plotnine | Notes |
|---------|----------|-------|
| `scale_x_continuous()` | `scale_x_continuous()` | Identical |
| `scale_y_continuous()` | `scale_y_continuous()` | Identical |
| `scale_x_log10()` | `scale_x_log10()` | Identical |
| `scale_y_log10()` | `scale_y_log10()` | Identical |
| `scale_x_discrete()` | `scale_x_discrete()` | Identical |
| `scale_x_date()` | `scale_x_date()` | Identical |
| `scale_x_datetime()` | `scale_x_datetime()` | Identical |
| `scale_color_manual()` | `scale_color_manual()` | Identical |
| `scale_fill_manual()` | `scale_fill_manual()` | Identical |
| `scale_color_brewer()` | `scale_color_brewer()` | Identical |
| `scale_fill_brewer()` | `scale_fill_brewer()` | Identical |
| `scale_color_gradient()` | `scale_color_gradient()` | Identical |
| `scale_color_gradient2()` | `scale_color_gradient2()` | Identical |
| `scale_color_viridis_c()` | `scale_color_cmap(cmap_name="viridis")` | Different name |
| `scale_fill_viridis_c()` | `scale_fill_cmap(cmap_name="viridis")` | Different name |
| `scale_color_viridis_d()` | `scale_color_cmap_d(cmap_name="viridis")` | Different name |
| `scale_color_grey()` | `scale_color_grey()` | Identical |
| `scale_size()` | `scale_size()` | Identical |
| `scale_alpha()` | `scale_alpha()` | Identical |
| `scale_x_reverse()` | `scale_x_reverse()` | Identical |

**Key difference:** R's `scale_color_viridis_c()` / `scale_fill_viridis_c()` map
to plotnine's `scale_color_cmap()` / `scale_fill_cmap()`, which wraps any
matplotlib colormap. Pass the colormap name explicitly.

### Axis Formatting

```r
# R: format y-axis as currency
scale_y_continuous(labels = scales::dollar)
```

```python
# Python: use a lambda for custom formatting
scale_y_continuous(labels=lambda x: [f"${v:,.0f}" for v in x])
```

R's `scales` package helper functions (`dollar`, `percent`, `comma`) do not have
direct plotnine equivalents. Use lambda functions instead.

### Coordinates

| ggplot2 | plotnine | Notes |
|---------|----------|-------|
| `coord_cartesian()` | `coord_cartesian()` | Identical; zooms without dropping data |
| `coord_flip()` | `coord_flip()` | Identical |
| `coord_fixed()` | `coord_fixed()` | Identical |
| `coord_trans()` | `coord_trans()` | Identical |
| `coord_polar()` | `coord_polar()` | Available in plotnine |
| `coord_sf()` | Not available | Use geopandas for CRS-aware plotting |

### labs() -- Identical

```r
# R
labs(title = "My Plot", subtitle = "Details", x = "Year", y = "Value",
     caption = "Source: CCD", color = "Sector")
```

```python
# Python
labs(title="My Plot", subtitle="Details", x="Year", y="Value",
     caption="Source: CCD", color="Sector")
```

## Section 4: Faceting

Faceting syntax differs only in that plotnine uses strings where ggplot2 uses
formulas.

### facet_wrap()

```r
# R
facet_wrap(~ state, ncol = 3, scales = "free_y")
```

```python
# Python
facet_wrap("state", ncol=3, scales="free_y")
```

### facet_grid()

```r
# R
facet_grid(sector ~ year)
facet_grid(sector ~ .)
facet_grid(. ~ year)
```

```python
# Python
facet_grid("sector ~ year")
facet_grid("sector ~ .")
facet_grid(". ~ year")
```

### Facet Labels

```r
# R
facet_wrap(~ var, labeller = label_both)
facet_wrap(~ var, labeller = labeller(var = c("A" = "Group A", "B" = "Group B")))
```

```python
# Python
facet_wrap("var", labeller=label_both)
facet_wrap("var", labeller=labeller(var={"A": "Group A", "B": "Group B"}))
```

R uses a named vector (`c("A" = "Group A")`); Python uses a dict
(`{"A": "Group A"}`). The labeller function names are the same.

## Section 5: Themes

### Built-in Themes

All major ggplot2 themes are available in plotnine:

| ggplot2 | plotnine | Notes |
|---------|----------|-------|
| `theme_gray()` | `theme_gray()` | Default in both |
| `theme_bw()` | `theme_bw()` | Identical |
| `theme_minimal()` | `theme_minimal()` | Identical |
| `theme_classic()` | `theme_classic()` | Identical |
| `theme_light()` | `theme_light()` | Identical |
| `theme_dark()` | `theme_dark()` | Identical |
| `theme_void()` | `theme_void()` | Identical |
| `theme_linedraw()` | `theme_linedraw()` | Identical |
| `theme_tufte()` | `theme_tufte()` | Identical |
| `theme_538()` | `theme_538()` | Identical |
| `theme_xkcd()` | `theme_xkcd()` | Identical |

R extension themes from `ggthemes` (e.g., `theme_economist()`, `theme_wsj()`)
are not available in plotnine. Build equivalents with `theme()` customization.

### theme() Customization

The `theme()` system is functionally identical. The only convention difference is
that R uses dots in element names (`plot.title`, `panel.grid.major`) while
plotnine uses underscores (`plot_title`, `panel_grid_major`).

**R (ggplot2):**

```r
theme(
  plot.title = element_text(size = 16, face = "bold", hjust = 0.5),
  axis.text.x = element_text(angle = 45, hjust = 1),
  panel.grid.minor = element_blank(),
  legend.position = "bottom",
  strip.background = element_rect(fill = "lightblue"),
  plot.margin = margin(10, 10, 10, 10)
)
```

**Python (plotnine):**

```python
theme(
    plot_title=element_text(size=16, weight="bold", ha="center"),
    axis_text_x=element_text(angle=45, ha="right"),
    panel_grid_minor=element_blank(),
    legend_position="bottom",
    strip_background=element_rect(fill="lightblue"),
    plot_margin=10,
)
```

Note: R's `face = "bold"` maps to `weight = "bold"` in plotnine. R's `hjust`
maps to `ha` in some contexts (plotnine uses matplotlib's text alignment
parameters internally).

### Custom Reusable Theme

```r
# R
my_theme <- theme_minimal() +
  theme(
    plot.title = element_text(size = 14, face = "bold"),
    axis.text = element_text(size = 11),
    legend.position = "bottom"
  )

p + my_theme
```

```python
# Python
my_theme = (
    theme_minimal()
    + theme(
        plot_title=element_text(size=14, weight="bold"),
        axis_text=element_text(size=11),
        legend_position="bottom",
    )
)

p + my_theme
```

### Set Global Default Theme

```r
# R
theme_set(theme_minimal(base_size = 14))
```

```python
# Python
from plotnine import theme_set
theme_set(theme_minimal(base_size=14))
```

## Section 6: plotly R to plotly Python

Plotly exists natively in both R and Python, but the APIs differ significantly.
R uses a formula-based interface with `plot_ly()` and the pipe operator; Python
offers two APIs -- Plotly Express (`px`) for concise one-call charts, and Graph
Objects (`go`) for fine-grained control.

### Core API Mapping

| plotly R | plotly Python (px) | plotly Python (go) |
|----------|--------------------|--------------------|
| `plot_ly(df, x = ~year, y = ~value)` | `px.scatter(df, x="year", y="value")` | `go.Figure(go.Scatter(x=df["year"], y=df["value"]))` |
| `add_trace(...)` | N/A (one-call API) | `fig.add_trace(go.Scatter(...))` |
| `add_markers()` | `px.scatter()` | `go.Scatter(mode="markers")` |
| `add_lines()` | `px.line()` | `go.Scatter(mode="lines")` |
| `add_bars()` | `px.bar()` | `go.Bar(...)` |
| `layout(title = "...", xaxis = list(...))` | `fig.update_layout(title="...", xaxis=dict(...))` | Same |
| `subplot(p1, p2, nrows = 2)` | `make_subplots(rows=2, cols=1)` | Same |
| `%>% layout(...)` | `.update_layout(...)` (method chain) | Same |

### Key Syntax Differences

| Concept | R | Python |
|---------|---|--------|
| Variable reference | Tilde formula: `~column_name` | String: `"column_name"` |
| Configuration objects | `list(title = "X", showgrid = FALSE)` | `dict(title="X", showgrid=False)` |
| Boolean values | `TRUE` / `FALSE` | `True` / `False` |
| Pipe operator | `%>%` or `|>` | Method chaining (`.update_layout().update_traces()`) |
| Save interactive HTML | `htmlwidgets::saveWidget(p, "file.html")` | `fig.write_html("file.html")` |
| Save static image | `orca(p, "file.png")` or `kaleido` | `fig.write_image("file.png")` (requires kaleido) |

### Complete Parallel Example

**R (plotly):**

```r
library(plotly)

p <- plot_ly(economics, x = ~date, y = ~unemploy, type = "scatter",
             mode = "lines", name = "Unemployment") %>%
  add_trace(y = ~psavert, name = "Savings Rate", yaxis = "y2") %>%
  layout(
    title = "Economic Indicators Over Time",
    xaxis = list(title = "Date"),
    yaxis = list(title = "Unemployment (thousands)"),
    yaxis2 = list(
      title = "Savings Rate (%)",
      overlaying = "y",
      side = "right"
    ),
    legend = list(x = 0.1, y = 0.9)
  )

htmlwidgets::saveWidget(p, "economic_indicators.html")
```

**Python (plotly):**

```python
import plotly.graph_objects as go
from plotly.subplots import make_subplots

fig = make_subplots(specs=[[{"secondary_y": True}]])

fig.add_trace(
    go.Scatter(x=economics["date"], y=economics["unemploy"],
               mode="lines", name="Unemployment"),
    secondary_y=False,
)
fig.add_trace(
    go.Scatter(x=economics["date"], y=economics["psavert"],
               mode="lines", name="Savings Rate"),
    secondary_y=True,
)

fig.update_layout(
    title="Economic Indicators Over Time",
    xaxis=dict(title="Date"),
    legend=dict(x=0.1, y=0.9),
)
fig.update_yaxes(title_text="Unemployment (thousands)", secondary_y=False)
fig.update_yaxes(title_text="Savings Rate (%)", secondary_y=True)

fig.write_html("economic_indicators.html")
```

### ggplotly() Equivalent

R users often convert ggplot2 objects to interactive plotly via `ggplotly()`.
There is no direct equivalent in Python. The workaround is to rebuild the plot
using plotly Express or Graph Objects. For static publication figures, plotnine
is preferred in DAAF; for interactivity, use plotly Python directly.

## Section 7: Coefficient and Effect Plots

R's ecosystem has several specialized packages for regression visualization.
The DAAF Python stack covers the most important use cases through pyfixest.

### fixest Coefficient Plots

| R (fixest) | Python (pyfixest) | Notes |
|------------|-------------------|-------|
| `coefplot(fit)` | `pf.coefplot(fit)` | Direct equivalent |
| `coefplot(list(fit1, fit2))` | `pf.coefplot([fit1, fit2])` | Compare models |
| `iplot(fit)` | `fit.iplot()` | Event study / interaction plots |
| `iplot(fit, ci_level = 0.95)` | `fit.iplot(alpha=0.05)` | Confidence level |

pyfixest's `coefplot()` and `iplot()` are functionally equivalent to their fixest
R counterparts. They support `keep`, `drop`, `coord_flip`, and `figsize`
parameters. `iplot()` additionally supports joint confidence bands via
`joint="bonferroni"` or `joint="scheffe"`.

### ggfixest (R) Equivalence

R's `ggfixest` package provides `ggcoefplot()` and `ggiplot()` which return
ggplot2 objects for further customization. pyfixest plots use matplotlib as the
backend, so further customization uses matplotlib methods:

```python
import matplotlib.pyplot as plt

fit.iplot(title="Event Study: Treatment Effect")
plt.axhline(y=0, color="red", linestyle="--", alpha=0.5)
plt.savefig("event_study.png", dpi=300, bbox_inches="tight")
plt.close()
```

### ggeffects / marginaleffects

| R | Python | Notes |
|---|--------|-------|
| `ggeffects::ggeffect(model)` | Manual: compute with `marginaleffects` + plot with plotnine | No single-function equivalent |
| `marginaleffects::plot_predictions(model)` | `marginaleffects.plot_predictions(model)` | Direct equivalent (if using marginaleffects Python) |
| `marginaleffects::plot_slopes(model)` | `marginaleffects.plot_slopes(model)` | Direct equivalent |
| `marginaleffects::plot_comparisons(model)` | `marginaleffects.plot_comparisons(model)` | Direct equivalent |

The Python `marginaleffects` package (by Vincent Arel-Bundock) provides
`plot_predictions()`, `plot_slopes()`, and `plot_comparisons()` that mirror the R
versions. For `ggeffects`-style output, compute predictions with
`marginaleffects.predictions()` and plot the resulting DataFrame with plotnine.

### modelsummary / sjPlot

| R | Python | Notes |
|---|--------|-------|
| `modelsummary::modelplot(models)` | `pf.coefplot(models)` | Similar output |
| `sjPlot::tab_model(fit1, fit2)` | `pf.etable([fit1, fit2])` | Table, not plot |
| `sjPlot::plot_model(fit)` | `pf.coefplot(fit)` | Coefficient plot |

`pf.etable()` produces formatted regression tables (HTML, markdown, or LaTeX)
comparable to `sjPlot::tab_model()`. For forest-plot-style model comparison,
`pf.coefplot()` covers the same ground as `modelsummary::modelplot()`.

## Section 8: R-Only Viz Tools and DAAF Workarounds

Several popular R visualization packages have no direct plotnine equivalent. This
section documents workaround patterns for DAAF research workflows.

### ggcorrplot -- Correlation Heatmaps

**R:**
```r
library(ggcorrplot)
ggcorrplot(cor(df), type = "lower", lab = TRUE)
```

**Python workaround (plotnine):**
```python
import numpy as np
corr = df.corr()

# Reshape to long format for geom_tile
mask = np.triu(np.ones_like(corr, dtype=bool), k=1)
corr_long = (
    corr.where(~mask)
    .stack()
    .reset_index()
    .rename(columns={"level_0": "var1", "level_1": "var2", 0: "corr"})
)

p = (
    ggplot(corr_long, aes(x="var1", y="var2", fill="corr"))
    + geom_tile(color="white")
    + geom_text(aes(label="corr"), format_string="{:.2f}", size=8)
    + scale_fill_cmap(cmap_name="RdBu_r")
    + theme_minimal()
    + theme(axis_text_x=element_text(angle=45, ha="right"))
)
```

### GGally::ggpairs -- Scatter Matrix

**R:**
```r
library(GGally)
ggpairs(df, columns = c("x1", "x2", "x3"), aes(color = group))
```

**Python workaround:** No plotnine equivalent. Use seaborn's `pairplot()` or
pandas' `scatter_matrix()`:
```python
import seaborn as sns
sns.pairplot(df[["x1", "x2", "x3", "group"]], hue="group")
```

### ggridges -- Ridgeline Plots

**R:**
```r
library(ggridges)
ggplot(df, aes(x = value, y = category, fill = category)) +
  geom_density_ridges(alpha = 0.7)
```

**Python workaround:** plotnine does not include `geom_density_ridges()`. Use
`geom_violin()` with `coord_flip()` as an approximation, or use the `ridgeplot`
Python package, or build manually with offset `geom_density()` layers. For
publication work, seaborn's experimental `objects.Plot` or matplotlib with
`scipy.stats.gaussian_kde` provides the most control.

### patchwork -- Combining Plots

**R:**
```r
library(patchwork)
(p1 | p2 | p3) / p4
```

**Python (plotnine v0.15+):** plotnine now has native plot composition with the
same operator syntax as patchwork:
```python
# Side by side
p1 | p2 | p3

# Stacked
(p1 | p2 | p3) / p4
```

This is a direct translation -- the operators (`|` for side-by-side, `/` for
stacking) match patchwork exactly.

### gt / kableExtra -- Formatted Tables

**R:**
```r
library(gt)
gt(summary_df) %>%
  tab_header(title = "Summary Statistics") %>%
  fmt_number(columns = everything(), decimals = 2)
```

**Python alternatives:**
- `pf.etable()` for regression tables (HTML, markdown, LaTeX)
- `pf.dtable()` for descriptive statistics tables
- `great_tables` Python package for gt-equivalent formatted tables
- Markdown tables for simple summaries in DAAF reports

### ggrepel -- Non-overlapping Labels

**R:**
```r
library(ggrepel)
geom_text_repel(aes(label = name))
```

**Python workaround:** plotnine does not have `geom_text_repel()`. Use
`geom_text()` with `adjust_text` parameter (if available in current version),
or use `position_nudge()` for manual offset. For complex label placement,
the `adjustText` Python package can post-process matplotlib text objects.

### ggforce -- Extended Geoms

Several `ggforce` geoms (e.g., `geom_mark_ellipse()`, `geom_mark_hull()`) are
not available in plotnine. However, `geom_sina()` (from ggforce in R) is built
into plotnine natively. Other ggforce geoms require matplotlib workarounds.

## Quick Reference: Decision Matrix

| Need | R Tool | DAAF Python Tool |
|------|--------|------------------|
| Static grammar-of-graphics plot | ggplot2 | plotnine |
| Interactive chart | plotly R | plotly Python (px or go) |
| Coefficient plot | fixest::coefplot / ggfixest | pf.coefplot() |
| Event study plot | fixest::iplot / ggfixest | fit.iplot() |
| Marginal effects plot | ggeffects / marginaleffects | marginaleffects Python |
| Regression table | modelsummary / sjPlot / stargazer | pf.etable() |
| Correlation heatmap | ggcorrplot | plotnine geom_tile() + manual reshape |
| Scatter matrix | GGally::ggpairs | seaborn.pairplot() |
| Ridgeline plot | ggridges | Manual (no direct equivalent) |
| Combining plots | patchwork | plotnine native composition (`\|`, `/`) |
| Spatial / map | ggplot2 + geom_sf | geopandas .plot() or plotnine geom_map() |
| Formatted table | gt / kableExtra | great_tables / pf.etable() |
| Label repulsion | ggrepel | geom_text() + adjustText |

> **Sources:** Wickham, H., *ggplot2: Elegant Graphics for Data Analysis*, 3rd ed.
> (Springer, 2024); plotnine documentation, v0.15.3 (plotnine.org, accessed
> 2026-03-28); plotnine feature parity guide (plotnine.org/guide/feature-coverage.html,
> accessed 2026-03-28); Plotly R reference (plotly.com/r/, accessed 2026-03-28);
> Plotly Python reference (plotly.com/python/, accessed 2026-03-28); pyfixest
> documentation (py-econometrics.github.io/pyfixest/, accessed 2026-03-28);
> Arel-Bundock, V., marginaleffects Python package (marginaleffects.com, accessed
> 2026-03-28); Tidy Intelligence, "ggplot2 vs plotnine" (blog.tidy-intelligence.com,
> accessed 2026-03-28)

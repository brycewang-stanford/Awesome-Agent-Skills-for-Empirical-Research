# Visualization: Stata to Python Translation

Stata's graph system uses an imperative, command-based syntax: you tell Stata what
type of plot to make and supply options. Python's plotnine uses the grammar of
graphics: you describe a plot's structure by composing layers. The mental model
shift is from "run a graph command with options" to "build a plot by adding
components." This feels more verbose at first but produces more composable and
customizable visualizations.

plotnine requires pandas DataFrames as input. In DAAF, convert polars DataFrames
before plotting: `df_pd = df.to_pandas()`.

> **Versions referenced:**
> Python: plotnine 0.15.3, plotly 6.5.2, pyfixest 0.40.0, binsreg (latest)
> Stata: Stata 18 (graph system stable across recent versions)
> See SKILL.md Section: Library Versions for the complete version table.

---

## Section 1: Conceptual Bridge -- Command Syntax to Grammar of Graphics

### The Two Paradigms

**Stata's graph system** is command-based. You pick a plot type and configure it
with options:

```stata
graph twoway scatter y x, mcolor(blue) msize(small) title("My Plot")
```

The command name (`scatter`) declares the plot type. Everything else is options.
Multiple plot types are overlaid by listing them inside `twoway`:

```stata
graph twoway (scatter y x) (lfit y x), title("Scatter with Fit")
```

**plotnine's grammar of graphics** decomposes a plot into orthogonal components:

```python
from plotnine import *

p = (
    ggplot(df_pd, aes(x="x", y="y"))      # data + aesthetic mapping
    + geom_point(color="blue", size=1)     # geometry layer
    + geom_smooth(method="lm")             # another geometry layer
    + labs(title="Scatter with Fit")        # labels
    + theme_minimal()                       # theme
)
```

Each component (`ggplot`, `geom_*`, `scale_*`, `facet_*`, `theme_*`) is
independent and composable via `+`.

### Why plotnine Looks Verbose But Is More Powerful

Stata's approach is concise for simple plots but becomes unwieldy for complex
ones. plotnine's approach requires more lines for a basic scatter plot but scales
gracefully: adding a color dimension, faceting by a variable, or changing the
coordinate system each requires only one additional line, not a restructuring of
the entire command.

### Core Mapping Table

| Stata Concept | plotnine Concept | Example |
|---------------|-----------------|---------|
| `graph twoway scatter y x` | `ggplot(aes("x","y")) + geom_point()` | Basic scatter |
| `mcolor(blue)` | `color="blue"` inside `geom_point()` | Static color |
| `by(group)` | `aes(color="group")` or `facet_wrap("group")` | Group by variable |
| `, over(group)` | `aes(fill="group")` | Bar chart groups |
| `title("text")` | `labs(title="text")` | Title |
| `scheme(s2color)` | `theme_minimal()` / `theme_bw()` | Visual theme |
| `graph export "f.png"` | `p.save("f.png", dpi=300)` | Export |

---

## Section 2: Scatter Plots

### Basic Scatter

**Stata:**
```stata
graph twoway scatter mpg weight
```

**plotnine:**
```python
p = (
    ggplot(df_pd, aes(x="weight", y="mpg"))
    + geom_point()
)
```

### Scatter with Options

**Stata:**
```stata
graph twoway scatter mpg weight, ///
    mcolor(navy) msize(small) msymbol(circle) ///
    title("Fuel Efficiency vs Weight") ///
    xtitle("Weight (lbs)") ytitle("Miles per Gallon")
```

**plotnine:**
```python
p = (
    ggplot(df_pd, aes(x="weight", y="mpg"))
    + geom_point(color="navy", size=1, shape="o")
    + labs(
        title="Fuel Efficiency vs Weight",
        x="Weight (lbs)",
        y="Miles per Gallon",
    )
)
```

### Scatter by Group

**Stata:**
```stata
* Option 1: Color by group
graph twoway (scatter mpg weight if cyl==4, mcolor(blue)) ///
             (scatter mpg weight if cyl==6, mcolor(red)) ///
             (scatter mpg weight if cyl==8, mcolor(green)), ///
    legend(order(1 "4 cyl" 2 "6 cyl" 3 "8 cyl"))

* Option 2: Separate panels
graph twoway scatter mpg weight, by(cyl)
```

**plotnine:**
```python
# Option 1: Color by group (one line change)
p = (
    ggplot(df_pd, aes(x="weight", y="mpg", color="factor(cyl)"))
    + geom_point()
    + labs(color="Cylinders")
)

# Option 2: Separate panels
p = (
    ggplot(df_pd, aes(x="weight", y="mpg"))
    + geom_point()
    + facet_wrap("cyl")
)
```

Note: Stata requires separate scatter commands per group or the `by()` option.
plotnine maps groups to aesthetics (color, shape, size) with a single change to
`aes()`, and the legend is generated automatically.

### Scatter with Fitted Line

**Stata:**
```stata
graph twoway (scatter mpg weight) (lfit mpg weight), ///
    legend(order(1 "Data" 2 "Linear Fit"))
```

**plotnine:**
```python
p = (
    ggplot(df_pd, aes(x="weight", y="mpg"))
    + geom_point()
    + geom_smooth(method="lm", se=False)
)
```

To add a confidence band around the fit, change `se=False` to `se=True` (the
default). Stata's `lfitci` command is the equivalent:

```stata
graph twoway (scatter mpg weight) (lfitci mpg weight)
```

---

## Section 3: Line Plots

### Basic Line

**Stata:**
```stata
graph twoway line unemployment year
```

**plotnine:**
```python
p = (
    ggplot(df_pd, aes(x="year", y="unemployment"))
    + geom_line()
)
```

### Connected Scatter (Line + Points)

**Stata:**
```stata
graph twoway connected unemployment year
```

**plotnine:**
```python
p = (
    ggplot(df_pd, aes(x="year", y="unemployment"))
    + geom_line()
    + geom_point()
)
```

### Multiple Series

**Stata:**
```stata
graph twoway (line unemployment year) (line inflation year), ///
    legend(order(1 "Unemployment" 2 "Inflation"))
```

**plotnine (requires long format):**
```python
# Stata can plot multiple y-variables in wide format.
# plotnine requires long format with a group variable.
df_long = df_pd.melt(
    id_vars="year",
    value_vars=["unemployment", "inflation"],
    var_name="indicator",
    value_name="value",
)

p = (
    ggplot(df_long, aes(x="year", y="value", color="indicator"))
    + geom_line()
    + labs(color="Indicator")
)
```

This is a common friction point: Stata plots multiple y-variables from wide data
directly; plotnine requires reshaping to long format first, with a group variable
mapped to the color aesthetic.

---

## Section 4: Bar Charts

### Bar Chart of Means

**Stata:**
```stata
graph bar (mean) income, over(education)
```

**plotnine:**
```python
# Option 1: Pre-aggregate, then plot
bar_data = df_pd.groupby("education")["income"].mean().reset_index()
p = (
    ggplot(bar_data, aes(x="education", y="income"))
    + geom_col()
)

# Option 2: Use stat_summary within plotnine
import numpy as np
p = (
    ggplot(df_pd, aes(x="education", y="income"))
    + stat_summary(fun_y=np.mean, geom="bar")
)
```

Stata's `graph bar` computes summary statistics internally. plotnine's `geom_bar`
counts observations by default (`stat="count"`); for means, use `geom_col()` with
pre-aggregated data or `stat_summary()`.

### Stacked and Grouped Bars

**Stata:**
```stata
* Stacked
graph bar (count), over(sector) over(year) stack

* Grouped (side-by-side)
graph bar (count), over(sector) over(year)
```

**plotnine:**
```python
# Stacked (default when fill is mapped)
p = (
    ggplot(df_pd, aes(x="year", fill="sector"))
    + geom_bar(stat="count")
)

# Grouped (side-by-side)
p = (
    ggplot(df_pd, aes(x="year", fill="sector"))
    + geom_bar(stat="count", position="dodge")
)
```

### Horizontal Bars

**Stata:**
```stata
graph hbar (mean) income, over(education)
```

**plotnine:**
```python
p = (
    ggplot(bar_data, aes(x="education", y="income"))
    + geom_col()
    + coord_flip()
)
```

---

## Section 5: Histograms and Density Plots

### Basic Histogram

**Stata:**
```stata
histogram income, bin(30) freq
```

**plotnine:**
```python
p = (
    ggplot(df_pd, aes(x="income"))
    + geom_histogram(bins=30)
)
```

### Histogram with Kernel Density Overlay

**Stata:**
```stata
histogram income, kdensity
```

**plotnine:**
```python
p = (
    ggplot(df_pd, aes(x="income"))
    + geom_histogram(aes(y=after_stat("density")), bins=30, alpha=0.5)
    + geom_density(color="red")
)
```

Note: To overlay a density curve on a histogram, the histogram must use density
(not count) on the y-axis. plotnine uses `after_stat("density")` for this;
Stata handles it automatically with the `kdensity` option.

### Kernel Density Only

**Stata:**
```stata
kdensity income
kdensity income, bwidth(5000)
```

**plotnine:**
```python
p = (
    ggplot(df_pd, aes(x="income"))
    + geom_density()
)

# With explicit bandwidth
p = (
    ggplot(df_pd, aes(x="income"))
    + geom_density(bw=5000)
)
```

### Density by Group

**Stata:**
```stata
kdensity income if gender==1, addplot(kdensity income if gender==2)
* Or more commonly:
twoway (kdensity income if gender==1) (kdensity income if gender==2), ///
    legend(order(1 "Male" 2 "Female"))
```

**plotnine:**
```python
p = (
    ggplot(df_pd, aes(x="income", color="gender"))
    + geom_density()
)
```

Again, plotnine handles groups through the `aes()` mapping rather than requiring
separate commands.

---

## Section 6: Box Plots

**Stata:**
```stata
graph box income, over(education)
graph box income, over(education) over(gender)
```

**plotnine:**
```python
# Single grouping
p = (
    ggplot(df_pd, aes(x="education", y="income"))
    + geom_boxplot()
)

# Two groupings (color within x-axis)
p = (
    ggplot(df_pd, aes(x="education", y="income", fill="gender"))
    + geom_boxplot()
)
```

### Violin Plots (No Stata Built-in)

Stata has no built-in violin plot. plotnine does:

```python
p = (
    ggplot(df_pd, aes(x="education", y="income"))
    + geom_violin()
)
```

Community Stata packages like `vioplot` exist but are not standard.

---

## Section 7: Coefficient Plots

Coefficient plots are central to applied economics presentations. Stata's
community `coefplot` package and pyfixest's `pf.coefplot()` / `fit.iplot()` are
the primary tools.

### Basic Coefficient Plot

**Stata:**
```stata
regress wage education experience age, robust
coefplot, drop(_cons)
```

**Python (pyfixest):**
```python
import pyfixest as pf

fit = pf.feols("wage ~ education + experience + age", data=pdf, vcov="hetero")
pf.coefplot(fit, figsize=(8, 5))
```

### Multiple Model Comparison

**Stata:**
```stata
eststo m1: regress wage education, robust
eststo m2: regress wage education experience, robust
eststo m3: regress wage education experience age, robust
coefplot m1 m2 m3, drop(_cons)
```

**Python:**
```python
m1 = pf.feols("wage ~ education", data=pdf, vcov="hetero")
m2 = pf.feols("wage ~ education + experience", data=pdf, vcov="hetero")
m3 = pf.feols("wage ~ education + experience + age", data=pdf, vcov="hetero")

pf.coefplot([m1, m2, m3], figsize=(10, 6))
```

### Event Study / Interaction Plots

**Stata:**
```stata
reghdfe y i.rel_time, absorb(unit year) cluster(unit)
coefplot, vertical base
* Or with eventdd/event_plot community commands
```

**Python:**
```python
fit = pf.feols(
    "y ~ i(rel_time, ref=-1) | unit + year",
    data=pdf,
    vcov={"CRV1": "unit"},
)
fit.iplot(figsize=(10, 5))

# With joint confidence bands (Bonferroni + Scheffe)
fit.iplot(joint="both")
```

pyfixest's `iplot()` is a direct equivalent of Stata's event study plotting
workflow. It supports `keep`, `drop`, `coord_flip`, `figsize`, and joint
confidence band parameters.

### Customizing pyfixest Plots

pyfixest plots use matplotlib as the backend. For customization beyond the
built-in parameters:

```python
import matplotlib.pyplot as plt

fit.iplot(title="Event Study: Treatment Effect")
plt.axhline(y=0, color="red", linestyle="--", alpha=0.5)
plt.savefig("event_study.png", dpi=300, bbox_inches="tight")
plt.close()
```

---

## Section 8: Plot Customization

### Titles, Subtitles, Axis Labels, Notes

**Stata:**
```stata
graph twoway scatter y x, ///
    title("Main Title") subtitle("Subtitle") ///
    xtitle("X Axis Label") ytitle("Y Axis Label") ///
    note("Source: CCD 2020")
```

**plotnine:**
```python
p = (
    ggplot(df_pd, aes(x="x", y="y"))
    + geom_point()
    + labs(
        title="Main Title",
        subtitle="Subtitle",
        x="X Axis Label",
        y="Y Axis Label",
        caption="Source: CCD 2020",
    )
)
```

Stata's `note()` maps to plotnine's `caption` in `labs()`.

### Legends

**Stata:**
```stata
graph twoway (scatter y x if g==1) (scatter y x if g==2), ///
    legend(order(1 "Group A" 2 "Group B") position(6) rows(1))
```

**plotnine:**
```python
p = (
    ggplot(df_pd, aes(x="x", y="y", color="group"))
    + geom_point()
    + scale_color_manual(
        values={"A": "blue", "B": "red"},
        labels={"A": "Group A", "B": "Group B"},
    )
    + theme(legend_position="bottom")
)
```

### Themes (Stata Schemes)

Stata uses `scheme()` to set the overall visual style. plotnine uses `theme_*()`
functions.

| Stata Scheme | plotnine Theme | Notes |
|-------------|---------------|-------|
| `scheme(s2color)` | `theme_gray()` | Default in both |
| `scheme(s2mono)` | `theme_bw()` | Black and white |
| `scheme(s1color)` | `theme_minimal()` | Clean, minimal |
| `scheme(economist)` | No direct equivalent | Build with `theme()` |
| `scheme(sj)` | `theme_classic()` | Stata Journal style approximation |

```python
# Set a global theme for all plots in the script
from plotnine import theme_set
theme_set(theme_minimal(base_size=14))
```

### Graph Size

**Stata:**
```stata
graph twoway scatter y x, xsize(10) ysize(6)
```

**plotnine:**
```python
p = (
    ggplot(df_pd, aes(x="x", y="y"))
    + geom_point()
    + theme(figure_size=(10, 6))
)
```

### Axis Formatting

**Stata:**
```stata
graph twoway scatter y x, ylabel(, format(%9.0fc)) xlabel(2010(2)2020)
```

**plotnine:**
```python
from plotnine import scale_x_continuous, scale_y_continuous

p = (
    ggplot(df_pd, aes(x="x", y="y"))
    + geom_point()
    + scale_y_continuous(labels=lambda x: [f"{v:,.0f}" for v in x])
    + scale_x_continuous(breaks=range(2010, 2021, 2))
)
```

Stata's `format()` option uses Stata format codes (`%9.0fc`). plotnine uses
Python lambda functions for custom label formatting.

---

## Section 9: Multi-Panel Layouts (Faceting)

### Facet by One Variable

**Stata:**
```stata
graph twoway scatter y x, by(state)
graph twoway scatter y x, by(state, cols(3))
```

**plotnine:**
```python
p = (
    ggplot(df_pd, aes(x="x", y="y"))
    + geom_point()
    + facet_wrap("state")
)

# Control columns
p = (
    ggplot(df_pd, aes(x="x", y="y"))
    + geom_point()
    + facet_wrap("state", ncol=3)
)
```

### Facet by Two Variables

**Stata:**
```stata
graph twoway scatter y x, by(state year)
```

**plotnine:**
```python
# Grid layout: rows by one variable, columns by another
p = (
    ggplot(df_pd, aes(x="x", y="y"))
    + geom_point()
    + facet_grid("state ~ year")
)
```

### Free Scales

**Stata:**
```stata
* Stata's by() uses the same axes by default; ycommon/xcommon options control this
graph twoway scatter y x, by(state, yrescale)
```

**plotnine:**
```python
p = (
    ggplot(df_pd, aes(x="x", y="y"))
    + geom_point()
    + facet_wrap("state", scales="free_y")
)
```

Options: `"free"` (both axes free), `"free_x"`, `"free_y"`, `"fixed"` (default).

### Combining Separate Plots

**Stata:**
```stata
graph twoway scatter y1 x, name(g1)
graph twoway scatter y2 x, name(g2)
graph combine g1 g2, cols(2)
```

**plotnine (v0.15+):**
```python
p1 = ggplot(df_pd, aes(x="x", y="y1")) + geom_point()
p2 = ggplot(df_pd, aes(x="x", y="y2")) + geom_point()

# Side by side
p1 | p2

# Stacked
p1 / p2

# Complex layout
(p1 | p2) / p3
```

plotnine v0.15+ supports plot composition with the same `|` (side-by-side) and
`/` (stacking) operators as R's patchwork package. For earlier versions, use
matplotlib subplots directly.

---

## Section 10: Exporting

### Static Image Export

**Stata:**
```stata
graph export "figure.png", replace width(1200)
graph export "figure.pdf", replace
graph export "figure.eps", replace
```

**plotnine:**
```python
p.save("figure.png", dpi=300, width=10, height=8)
p.save("figure.pdf", width=10, height=8)
```

DAAF convention: save all figures to `output/figures/` with date-prefixed names
and 300 DPI minimum for publication quality.

### plotnine Export Tips

- `dpi=300` is the minimum for publication; use `dpi=600` for print
- `width` and `height` are in inches
- `bbox_inches="tight"` is not a plotnine parameter; for tight layout, adjust
  `plot_margin` in `theme()`
- Supported formats: PNG, PDF, SVG, EPS

---

## Section 11: Interactive Plots (plotly)

Stata has no built-in interactive visualization. Python's plotly library provides
hover tooltips, zooming, panning, and linked views that have no Stata equivalent.

### When to Use plotly vs plotnine in DAAF

| Use plotnine when... | Use plotly when... |
|---------------------|-------------------|
| Publication-quality static figures | Exploratory data analysis |
| Report/paper figures | Dashboard-style presentation |
| Reproducible output (PNG/PDF) | HTML output for sharing |
| Grammar-of-graphics composability | Hover tooltips, zoom, pan needed |

### Basic plotly Examples

```python
import plotly.express as px

# Scatter with hover
fig = px.scatter(
    df_pd, x="income", y="test_score",
    color="sector", hover_data=["school_name"],
    title="Test Scores vs Income",
)
fig.write_html("output/figures/scatter_interactive.html")

# Line chart
fig = px.line(
    df_pd, x="year", y="enrollment",
    color="state", title="Enrollment Over Time",
)

# Histogram
fig = px.histogram(df_pd, x="income", nbins=30)
```

### plotly Graph Objects for Fine Control

```python
import plotly.graph_objects as go

fig = go.Figure()
fig.add_trace(go.Scatter(
    x=df_pd["year"], y=df_pd["unemployment"],
    mode="lines+markers", name="Unemployment",
))
fig.update_layout(
    title="Economic Indicators",
    xaxis=dict(title="Year"),
    yaxis=dict(title="Rate (%)"),
)
fig.write_html("output/figures/economic.html")
```

---

## Section 12: Binscatter

Binscatter is a workhorse visualization in applied economics. The `binsreg`
package is maintained by the same team (Cattaneo, Crump, Farrell, Feng) across
Stata, R, and Python, with virtually identical APIs.

### Basic Binscatter

**Stata:**
```stata
binscatter y x
binscatter y x, nquantiles(20)
```

**Python:**
```python
import binsreg

# Basic binscatter
est = binsreg.binsreg(y=df_pd["y"], x=df_pd["x"], nbins=20)

# With covariates (residualized)
est = binsreg.binsreg(
    y=df_pd["y"], x=df_pd["x"],
    w=df_pd[["covar1", "covar2"]],
    nbins=20,
)
```

### Binscatter with Controls

**Stata:**
```stata
binscatter y x, controls(covar1 covar2) absorb(state_fe)
```

**Python:**
```python
est = binsreg.binsreg(
    y=df_pd["y"], x=df_pd["x"],
    w=df_pd[["covar1", "covar2"]],
)
```

Note: The older Stata `binscatter` command (not `binsreg`) supports `absorb()`.
The `binsreg` package in Python does not directly absorb fixed effects; residualize
manually using pyfixest before passing to binsreg if FE absorption is needed.

### Additional binsreg Functions

| Stata | Python | Purpose |
|-------|--------|---------|
| `binsreg y x` | `binsreg.binsreg(y, x)` | Binscatter with CI |
| `binslogit y x` | `binsreg.binslogit(y, x)` | Binscatter with logit |
| `binstest y x` | `binsreg.binstest(y, x)` | Hypothesis testing |
| `binspwc y x, by(group)` | `binsreg.binspwc(y, x, by=group)` | Pairwise comparison |
| `binsregselect y x` | `binsreg.binsregselect(y, x)` | Data-driven bin selection |

All functions share identical syntax across Stata, R, and Python because they are
maintained by the same methodological authors.

---

## Quick Reference: Stata Graph Command to plotnine

| Stata Command | plotnine Equivalent | Notes |
|--------------|-------------------|-------|
| `twoway scatter y x` | `ggplot(aes("x","y")) + geom_point()` | |
| `twoway line y x` | `ggplot(aes("x","y")) + geom_line()` | |
| `twoway connected y x` | `geom_line() + geom_point()` | |
| `twoway area y x` | `geom_area()` | |
| `twoway bar y x` | `geom_col()` (pre-aggregated data) | |
| `twoway (scatter y x) (lfit y x)` | `geom_point() + geom_smooth(method="lm")` | |
| `twoway (scatter y x) (lowess y x)` | `geom_point() + geom_smooth(method="loess")` | |
| `graph bar (mean) y, over(g)` | Pre-aggregate + `geom_col()` | |
| `graph bar (count), over(g)` | `geom_bar(stat="count")` | |
| `graph hbar` | `geom_col() + coord_flip()` | |
| `graph box y, over(g)` | `geom_boxplot()` | |
| `histogram y` | `geom_histogram()` | |
| `histogram y, kdensity` | `geom_histogram(aes(y=after_stat("density"))) + geom_density()` | |
| `kdensity y` | `geom_density()` | |
| `graph pie` | No plotnine equivalent | Use matplotlib directly |
| `coefplot` | `pf.coefplot()` | pyfixest |
| `marginsplot` | Manual from `marginaleffects` output | No single-function equivalent |
| `binscatter y x` | `binsreg.binsreg(y, x)` | Same authors, same API |
| `graph export "f.png"` | `p.save("f.png", dpi=300)` | |

---

## Common Gotchas for Stata Users

1. **plotnine requires pandas:** Always convert polars DataFrames before plotting.
   `df_pd = df.to_pandas()`. Forgetting this produces cryptic errors.

2. **String column names in `aes()`:** Unlike Stata where variables are bare
   names, plotnine requires quoted strings: `aes(x="income", y="score")`. This is
   different from R's ggplot2 which uses bare names.

3. **Wide-to-long for multiple series:** Stata plots multiple y-variables from
   wide data directly. plotnine requires reshaping to long format with a grouping
   variable mapped to color/linetype.

4. **No automatic summary statistics in geom_bar:** Stata's `graph bar (mean)`
   computes means internally. plotnine's `geom_bar()` defaults to counting. Use
   `geom_col()` with pre-aggregated data or `stat_summary()`.

5. **Plot display:** Stata automatically displays plots in a window. In DAAF's
   file-first model, plots must be explicitly saved with `p.save()`. Use
   `print(p)` in scripts to trigger rendering to the execution log.

6. **Factor ordering:** Stata respects the order of value labels. plotnine sorts
   categories alphabetically by default. To control order, convert to
   `pd.Categorical` with explicit category ordering before plotting.

7. **Theme element names use underscores:** R's ggplot2 uses dots
   (`plot.title`, `panel.grid.major`). plotnine uses underscores
   (`plot_title`, `panel_grid_major`). Stata users coming via R resources
   should watch for this.

> **Sources:** plotnine documentation, v0.15.3 (plotnine.org, accessed
> 2026-03-28); Stata Graphics Reference Manual (stata.com/manuals, accessed
> 2026-03-28); pyfixest documentation, coefplot and iplot functions
> (pyfixest.org, accessed 2026-03-28); Cattaneo, Crump, Farrell, & Feng,
> binsreg package documentation (nppackages.github.io/binsreg/, accessed
> 2026-03-28); Turrell, "Data Visualisation using the Grammar of Graphics with
> Plotnine" in *Coding for Economists* (aeturrell.github.io, accessed
> 2026-03-28); Plotly Python documentation (plotly.com/python/, accessed
> 2026-03-28)

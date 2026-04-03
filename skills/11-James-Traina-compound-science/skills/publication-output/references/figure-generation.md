# Figure Generation — Publication-Quality Research Plots

Reference for generating figures that meet journal submission standards. Covers plot types common in applied micro and structural work, framework selection, publication defaults, multi-panel assembly, LaTeX integration, and accessibility.

---

## Plot Types

### Event Study

Displays dynamic treatment effects relative to an event or policy adoption.

**Components:** x-axis of periods relative to treatment (leads -K to lags +L), y-axis of coefficient estimates, point markers at each period, vertical bars or shaded bands for confidence intervals, horizontal reference line at zero, vertical reference line at the normalized period (typically -1).

**Key decisions:**
- Normalize to the last pre-treatment period (coefficient set to zero as the omitted category).
- Show 95% CIs by default; optionally overlay 90% CIs in a lighter shade.
- For staggered treatment designs, plot the aggregated event-study coefficients from Callaway-Sant'Anna or Sun-Abraham, not raw TWFE.
- Annotate the joint pre-trend test p-value in the caption or directly on the plot.
- If confidence intervals widen dramatically at long horizons, consider truncating or noting effective sample sizes.

**Conventions:** Freyaldenhoven, Hansen, and Shapiro (2019) establish the modern event-study format. Pre-treatment coefficients close to zero support parallel trends; post-treatment coefficients trace out the dynamic path.

### RD Plot

Visualizes the discontinuity in an outcome at a threshold in the running variable.

**Components:** x-axis of the running variable centered at the cutoff, y-axis of the outcome, binned scatter points (local means on each side), local polynomial fit lines with separate curves left and right of the cutoff, shaded 95% CI bands, vertical dashed line at the threshold.

**Key decisions:**
- Bin width: IMSE-optimal following Calonico, Cattaneo, and Titiunik (2015), or evenly spaced quantile bins.
- Local polynomial order: local linear is the default; local quadratic for sensitivity.
- Report the bandwidth and number of effective observations on each side.
- Pair with a McCrary (2008) or Cattaneo-Jansson-Ma (2020) density plot as a companion panel to show no manipulation of the running variable.

**Conventions:** Cattaneo, Idrobo, and Titiunik (2020) provide the canonical RD plot format. Use `rdplot` (R/Stata) or `rdrobust` for automated optimal binning.

### Coefficient Plot

Compares point estimates and confidence intervals across variables or specifications.

**Components:** variable or specification labels on one axis, coefficient values on the other, markers for point estimates, horizontal or vertical lines for CIs (thick for 90%, thin for 95%), vertical or horizontal reference line at zero.

**Key decisions:**
- Horizontal layout (variables on y-axis, coefficients on x-axis) works best when there are many variables.
- Vertical layout suits comparison of a single coefficient across specifications.
- Order variables by magnitude or logical grouping, not alphabetically.
- Use distinct marker shapes when overlaying multiple specifications.

### Power Curve

Shows statistical power as a function of sample size or minimum detectable effect.

**Components:** x-axis of sample size or MDE, y-axis of power (0 to 1), curves for each significance level or effect size, horizontal reference lines at 0.80 (conventional threshold) and at the nominal alpha.

**Key decisions:**
- Use log scale on the x-axis when sample sizes span orders of magnitude.
- Show alpha = 0.05 as the primary curve, alpha = 0.01 as secondary.
- Annotate the sample size required for 80% power at the target effect.
- Vary line dash patterns to distinguish multiple effect sizes.

### Density and Distribution

Compares distributions across groups (treatment/control, pre/post).

**Components:** x-axis of variable values, y-axis of kernel density estimate, overlapping density curves colored or shaded by group, dashed vertical lines at group means, legend identifying each group.

**Key decisions:**
- Gaussian kernel is the default; Epanechnikov for bounded support.
- Bandwidth: Silverman's rule or Sheather-Jones plug-in.
- Add a rug plot along the x-axis for small samples (N < 200).
- For McCrary-style tests, use bin counts with a local polynomial fit at the cutoff rather than a smooth density.

### Binned Scatter

Reveals the conditional expectation function by plotting bin means.

**Components:** x-axis of binned values, y-axis of mean outcome within each bin, scatter points at bin centroids, linear or polynomial fit line, optional confidence band.

**Key decisions:**
- Default to 20 equal-sized bins (equal number of observations per bin).
- If controls are present, residualize both x and y before binning, following Cattaneo, Crump, Farrell, and Feng (2024).
- Report the binning method and number of bins in figure notes.

**Conventions:** Use `binsreg` (R/Stata) or the `binsreg` Python package for automated bin selection and inference.

### Survival / Kaplan-Meier

Displays time-to-event distributions and group comparisons.

**Components:** x-axis of time since origin, y-axis of survival probability (1 to 0), step-function curves by group, tick marks for censored observations, shaded 95% CI, log-rank test p-value annotation.

**Key decisions:**
- Include number-at-risk table below the x-axis for clinical or duration studies.
- Mark censored observations with small vertical ticks on the survival curve.
- Use distinct line styles per group so the plot reads in grayscale.

### Heat Map

Displays matrix-valued data such as correlation matrices or transition probabilities.

**Components:** rows and columns labeled by variable or state, cells colored by value, color bar indicating scale, cell annotations with numeric values when the matrix is small.

**Key decisions:**
- Sequential palette (single-hue gradient) for non-negative data.
- Diverging palette (blue-white-red) for data centered at zero (e.g., correlations).
- Annotate cell values when the matrix is 10x10 or smaller.
- Mask the upper triangle for symmetric matrices to reduce redundancy.

### Time Series

Plots one or more series over calendar or index time.

**Components:** x-axis of dates or time index, y-axis of variable value, line for each series, shaded regions for recessions or treatment windows, vertical lines for structural breaks or policy dates.

**Key decisions:**
- Use consistent date formatting (e.g., "2005 Q1" or "Jan 2005").
- Shade NBER recession bars in light gray when plotting US macroeconomic data.
- If series have different scales, use a secondary y-axis or normalize to an index (base period = 100).
- Mark structural breaks or policy changes with labeled vertical lines.

---

## Framework Selection

Choose the plotting library that matches the project language and existing codebase.

| Language | Primary | Notes |
|----------|---------|-------|
| **Python** | matplotlib + seaborn | matplotlib controls fine layout; seaborn provides statistical plot types. Use `matplotlib.pyplot` for all final formatting. |
| **R** | ggplot2 | Grammar-of-graphics syntax. Extend with `fixest::coefplot`, `rdrobust::rdplot`, `binsreg`, `survminer`. |
| **Julia** | Plots.jl (GR backend) | `Plots.jl` with GR is the most portable. `Makie.jl` for interactive or 3D work. |
| **Stata** | `twoway` / `graph` | Use `grstyle` or `plotplainblind` scheme for clean defaults. `coefplot`, `rdplot`, `binscatter` for specialized types. |

If the project already uses a plotting library, follow that library for consistency. If the user requests a specific framework, use it regardless of the project language.

---

## Publication Defaults

Apply these settings to every figure unless the target journal specifies otherwise.

| Setting | Value | Rationale |
|---------|-------|-----------|
| Font family | Computer Modern, Times New Roman, or serif | Matches LaTeX body text |
| Axis label size | 11-12 pt | Readable at single-column print width |
| Tick label size | 9-10 pt | Subordinate to axis labels |
| Title size | 12-14 pt, or omit entirely | Titles belong in captions for journal papers |
| Figure size | 6.5 in x 4.5 in (single column) | Standard journal column width |
| Figure size | 13 in x 4.5 in (full width, two panels) | Spans both columns |
| Resolution | 300 DPI minimum for raster; vector (PDF) preferred | Print quality |
| Background | White, no fill | Clean appearance |
| Grid lines | None, or very light gray (#EEEEEE) if data is dense | Reduce clutter |
| Axis lines | Bottom and left only (no top or right spines) | Tufte-style minimalism |
| Legend | Inside plot area or below the figure; no border box | Minimal chrome |
| Output formats | PDF (primary, vector), PNG (secondary, 300 DPI), EPS if required | Vector for papers, raster for presentations |

---

## Color Palette Specification

Design palettes that are distinguishable in grayscale print and accessible to readers with color vision deficiency.

| Use case | Palette | Detail |
|----------|---------|--------|
| **2 groups** | Black + gray (#888888) | Maximum contrast in B&W |
| **3-5 groups** | Grayscale ramp: black, #444444, #888888, #BBBBBB, white with black border | Evenly spaced in luminance |
| **Sequential** | Single-hue gradient (e.g., light blue to dark blue) | For ordered, non-negative data |
| **Diverging** | Blue (#2166AC) - white - red (#B2182B) | For deviations from a center value; colorblind-safe |
| **Qualitative (color)** | Okabe-Ito: #E69F00, #56B4E9, #009E73, #F0E442, #0072B2, #D55E00, #CC79A7, #000000 | Designed for deuteranopia and protanopia |

When color is used, always pair it with a redundant visual channel: different marker shapes, line dash patterns, or fill patterns. This ensures the figure communicates its message both in color display and grayscale print.

---

## Multi-Panel Assembly

### Layout Selection

| Layout | When to use |
|--------|-------------|
| **1x2 (side-by-side)** | Two related outcomes, or treatment vs. control |
| **2x1 (stacked)** | Event study above, pre-trend test or density below |
| **2x2 (grid)** | Four subgroup analyses or robustness variants |
| **2x3 or 3x2** | Six specifications, outcomes, or subsamples |

### Assembly Rules

- **Shared axes:** Use identical axis ranges across panels when comparing magnitudes. Suppress redundant y-axis labels on the right panels of a row.
- **Panel labels:** Label as "(a)", "(b)", "(c)" or "Panel A", "Panel B", "Panel C" in the upper-left corner of each subplot, in bold, matching the body font.
- **Shared legends:** Place a single shared legend below the figure or in the bottom-right panel if one panel has more whitespace. Do not duplicate legends across panels.
- **Font consistency:** All panels must use the same font family, axis label size, and tick label size. Verify this after assembly — subplot functions sometimes reset defaults.
- **Spacing:** Use `constrained_layout` (matplotlib), `theme(plot.margin=...)` (ggplot2), or `subplots_adjust` to prevent label overlap. Leave at least 0.3 inches between panels.

---

## LaTeX Figure Environment

Standard template for including figures in a LaTeX manuscript:

```latex
\begin{figure}[htbp]
\centering
\includegraphics[width=\textwidth]{figures/<filename>.pdf}
\caption{<Descriptive caption stating what the figure shows, the data source,
and sample period. Include the number of observations and key estimation
details.>}
\label{fig:<name>}
\begin{figurenotes}
Notes: <Confidence level (e.g., 95\%), bandwidth or bin width,
sample restrictions, variable definitions, clustering level.
Source: <dataset name and vintage>.>
\end{figurenotes}
\end{figure}
```

**Conventions:**
- Labels follow `fig:<descriptive-name>` (e.g., `fig:event-study-earnings`, `fig:rd-test-scores`).
- Captions are self-contained: a reader should understand the figure from the caption alone without referring to the main text.
- Figure notes go in a `figurenotes` environment (or a `\floatfoot{}` or small-font paragraph after the caption, depending on the document class). Notes contain methodological details, confidence levels, data sources, and sample restrictions.
- Use `\textwidth` for full-width figures and `0.48\textwidth` side-by-side with `\hfill` for two-panel layouts within a single float.
- Require `\usepackage{graphicx}` in the preamble. If using `figurenotes`, ensure the relevant package or custom command is defined.

---

## Accessibility

### Redundant Encoding

Every visual distinction made through color must also be made through a second channel:

| Color distinction | Redundant channel |
|-------------------|-------------------|
| Treatment vs. control lines | Solid vs. dashed line style |
| Multiple group lines | Different marker shapes (circle, triangle, square, diamond) |
| Shaded regions | Different fill patterns (solid, hatched, crosshatched) |
| Heat map values | Annotate cells with numeric labels |

### Contrast and Legibility

- Foreground elements (lines, markers, text) must have a contrast ratio of at least 4.5:1 against the background, per WCAG AA.
- Line widths: 1.5 pt minimum for data lines, 0.75 pt for reference/grid lines.
- Marker sizes: 4-6 pt for scatter, 6-8 pt for coefficient plots.
- Avoid encoding information solely through thin color differences (e.g., light blue vs. light green).

### Alt Text

For HTML or slide output, provide alt text that describes the figure's main finding, not just its structure. Example: "Event study showing a sharp increase in earnings of approximately 12% beginning in the first post-treatment period, with no evidence of pre-trends" rather than "Line plot with dots and error bars."

---

## Common Research Plot References

| Plot | Method | Key reference | Software |
|------|--------|---------------|----------|
| Event study | DiD, staggered treatment | Freyaldenhoven, Hansen, Shapiro (2019) | R: `fixest::coefplot`; Stata: `event_plot` |
| RD plot | Regression discontinuity | Cattaneo, Idrobo, Titiunik (2020) | R/Stata/Python: `rdplot` via `rdrobust` |
| Binned scatter | Nonparametric conditional means | Cattaneo, Crump, Farrell, Feng (2024) | R/Stata/Python: `binsreg` |
| Specification curve | Multiverse robustness | Simonsohn, Simmons, Nelson (2020) | R: `specr`; custom code |
| McCrary density | RD manipulation test | McCrary (2008); Cattaneo, Jansson, Ma (2020) | R/Stata: `rddensity` |
| Coefficient plot | Specification comparison | Jann (2014) | R: `coefplot`, `dwplot`; Stata: `coefplot` |
| Power curve | Study design | Cohen (1988) | R: `pwr`; Python: `statsmodels.stats.power` |
| Survival curve | Duration models | Kaplan and Meier (1958) | R: `survminer`; Python: `lifelines` |

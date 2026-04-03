# Tables and Plots

## Contents

- [etable: Publication-Quality Regression Tables](#etable-publication-quality-regression-tables)
- [coefplot: Coefficient Plots](#coefplot-coefficient-plots)
- [iplot: Interaction / Event Study Plots](#iplot-interaction--event-study-plots)
- [dtable: Descriptive Statistics Tables](#dtable-descriptive-statistics-tables)
- [panelview: Treatment Visualization](#panelview-treatment-visualization)

## etable: Publication-Quality Regression Tables

`etable()` produces formatted regression tables comparing multiple models side by side.

### Basic Usage

```python
import pyfixest as pf

data = pf.get_data()

fit1 = pf.feols("Y ~ X1", data=data)
fit2 = pf.feols("Y ~ X1 + X2", data=data)
fit3 = pf.feols("Y ~ X1 + X2 | f1", data=data)
fit4 = pf.feols("Y ~ X1 + X2 | f1 + f2", data=data)

# Compare all models
pf.etable([fit1, fit2, fit3, fit4])
```

### Output Formats

```python
# Interactive HTML table (default, requires great_tables)
pf.etable([fit1, fit2], type="gt")

# Markdown table
pf.etable([fit1, fit2], type="md")

# LaTeX (requires booktabs, threeparttable, makecell)
pf.etable([fit1, fit2], type="tex")

# DataFrame for further processing
df_table = pf.etable([fit1, fit2], type="df")

# Save to file
pf.etable([fit1, fit2], type="tex", file_name="regression_table.tex")
```

### Customization

```python
pf.etable(
    [fit1, fit2, fit3],
    # Variable selection
    keep=["X1", "X2"],           # Show only these variables (regex supported)
    drop=["Intercept"],          # Hide these variables
    exact_match=False,           # False = regex matching (default)

    # Formatting
    coef_fmt="b \n (se)",        # Format: b=coef, se=SE, p=p-val, ci=CI
    digits=3,                    # Decimal places
    signif_code=[0.001, 0.01, 0.05],  # Significance stars

    # Labels
    labels={"X1": "Education", "X2": "Experience"},
    felabels={"f1": "Entity FE", "f2": "Year FE"},
    cat_template="{value}",      # For i() categoricals: show value only

    # Structure
    caption="Main Regression Results",
    model_heads=["(1)", "(2)", "(3)"],
)
```

### Coefficient Format Templates

The `coef_fmt` parameter controls how coefficients are displayed:

| Template | Output |
|----------|--------|
| `"b \n (se)"` | Coefficient with SE below (default) |
| `"b (se)"` | Coefficient and SE on same line |
| `"b [ci]"` | Coefficient with confidence interval |
| `"b \n (se) \n [p]"` | Coefficient, SE, and p-value |

### Fixed Effects Rows

`etable()` automatically adds rows showing which fixed effects are included (checkmarks) in each model. Use `felabels` to provide readable names.

### Mixing Estimators in One Table

`feols()`, `did2s()`, and `event_study()` all return `Feols` objects, so they can be combined in a single `etable()` call:

```python
fit_twfe = pf.feols("Y ~ treatment | entity + year", data=df, vcov={"CRV1": "state"})
fit_did2s = pf.did2s(data=df, yname="Y", first_stage="~ 0 | entity + year",
                      second_stage="~ treated", treatment="treated", cluster="state")

# Compare TWFE vs did2s in one table
pf.etable([fit_twfe, fit_did2s])
```

`lpdid()` returns a **DataFrame** (not a `Feols` object) and cannot be included in `etable()`. Present lpdid results separately or extract coefficients manually.

### Working with Multiple Estimation

When using `sw()`, `csw()`, or multiple dependent variables, `feols()` returns a `FixestMulti` object. Pass it directly to `etable()` — do **not** wrap it in a list:

```python
# Multiple models from single estimation call
fits = pf.feols("Y ~ csw0(X1, X2, X3) | f1", data=data)
pf.etable(fits)              # Correct: pass FixestMulti directly
# pf.etable([fits])          # Wrong: wrapping in list causes TypeError
```

Individual `Feols` models from separate calls can still be combined as `pf.etable([model1, model2])`.

## coefplot: Coefficient Plots

`coefplot()` visualizes estimated coefficients with confidence intervals.

### Basic Usage

```python
# Single model
pf.coefplot(fit1)

# Compare coefficients across models
pf.coefplot([fit1, fit2, fit3])
```

### Customization

```python
pf.coefplot(
    [fit1, fit2],
    keep=["X1", "X2"],          # Variables to include
    drop=["Intercept"],         # Variables to exclude
    coord_flip=True,            # Horizontal layout (default)
    title="Treatment Effects",
    figsize=(8, 5),
)
```

### Use Cases

- Comparing the same coefficient across different specifications
- Visualizing the effect of adding controls (from `csw0()` specifications)
- Presenting results for non-technical audiences

## iplot: Interaction / Event Study Plots

`iplot()` is specifically designed for models with `i()` interaction terms, particularly event studies.

### Basic Event Study Plot

```python
fit = pf.feols("Y ~ i(rel_year, ref=-1) | entity + year", data=df,
               vcov={"CRV1": "entity"})

# Default event study plot
fit.iplot()
```

### Joint Confidence Bands

```python
# Pointwise CIs only
fit.iplot(joint=None)

# Both Bonferroni and Scheffe simultaneous bands
fit.iplot(joint="both")

# Only Bonferroni
fit.iplot(joint="bonferroni")

# Only Scheffe
fit.iplot(joint="scheffe")
```

Joint bands account for multiple testing across time periods. They answer: "Can we reject that ALL pre-treatment coefficients are zero simultaneously?"

### Customization

```python
fit.iplot(
    alpha=0.05,              # Significance level for CIs
    figsize=(12, 6),         # Figure dimensions
    yintercept=0,            # Horizontal reference line
    coord_flip=False,        # Vertical (standard) orientation
    title="Event Study: Treatment Effect Over Time",
)
```

### Comparing Estimators

```python
fit_twfe = pf.feols("Y ~ i(rel_year, ref=-1) | entity + year", data=df)
fit_did2s = pf.did2s(data=df, yname="Y",
                      first_stage="~ 0 | entity + year",
                      second_stage="~ i(rel_year, ref=-1)",
                      treatment="treated", cluster="entity")

# Side-by-side comparison
pf.iplot([fit_twfe, fit_did2s])
```

## dtable: Descriptive Statistics Tables

`dtable()` produces summary statistics tables. Note: this function is being migrated to the `maketables` package (`maketables.DTable()`).

### Basic Usage

```python
# Summary statistics for selected variables
pf.dtable(data, vars=["Y", "X1", "X2"])
```

### By Group

```python
# Summary by treatment group
pf.dtable(data, vars=["Y", "X1", "X2"], by="treated")
```

### Available Statistics

Default statistics include mean, standard deviation, min, max, and count. Custom statistics can be specified.

## panelview: Treatment Visualization

`panelview()` creates heatmap-style visualizations of treatment assignment patterns across units and time.

```python
pf.panelview(
    data=df,
    unit="entity",        # Unit identifier column
    time="year",          # Time period column
    treat="treated",      # Treatment indicator column
)
```

This is essential for DiD analysis — visualize the treatment pattern before running any estimator. It shows:
- Which units are treated and when
- Whether adoption is staggered
- The size of the never-treated comparison group
- Any treatment reversals or gaps

## Saving Plots

All pyfixest plots use matplotlib or lets-plot as backends. To save:

```python
import matplotlib.pyplot as plt

# Method 1: Use matplotlib's savefig after iplot/coefplot
fit.iplot()
plt.savefig("event_study.png", dpi=300, bbox_inches="tight")
plt.close()

# Method 2: For more control, access the figure object
fig = fit.iplot()
fig.savefig("event_study.png", dpi=300, bbox_inches="tight")
```

For research pipeline scripts, save all figures to `output/figures/` following the file naming conventions in `CLAUDE.md`.

## References and Further Reading

- Berge, L., Butts, K., and McDermott, G. (2026). "Fast and User-Friendly Econometrics Estimations: The R Package fixest." arXiv:2601.21749
- pyfixest documentation — Visualization: https://pyfixest.org
- great_tables Python package: https://posit-dev.github.io/great-tables/
- maketables package (successor to dtable): check pyfixest changelog for migration guidance

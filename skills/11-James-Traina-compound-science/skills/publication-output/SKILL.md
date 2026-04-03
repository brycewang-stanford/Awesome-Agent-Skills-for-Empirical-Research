---
name: publication-output
argument-hint: "<table or figure type>"
description: >-
  This skill covers publication-quality tables and figures for academic research papers. Use when formatting regression results, summary statistics, Monte Carlo output, or research visualizations for LaTeX inclusion. Triggers on "table", "figure", "tabulate", "stargazer", "publication-ready", "LaTeX table", "event study plot", "coefficient plot", "RD plot", "power curve", "specification curve", "binscatter", "format results", "booktabs".
---

# Publication Output

Generate publication-quality tables and figures for academic research papers. Routes to the appropriate output type based on content, applies standard academic formatting conventions, and produces files ready for LaTeX inclusion.

## When to Use

Skip when:
- The task is choosing an empirical method or running estimation (use `empirical-playbook` or `causal-inference` skill)
- The task is journal submission logistics or referee responses (use `submission-guide` skill)
- Results are exploratory and not yet ready for formatted output (finish estimation first)

Use when:
- After estimation: format regression results, diagnostics, or robustness checks into tables
- After simulation: format Monte Carlo results (bias, RMSE, coverage) into comparison tables
- For descriptive work: summary statistics, balance tables, transition matrices
- For visualization: event studies, RD plots, coefficient plots, power curves, densities, specification curves

## Output Type Router

| Content type | Output | Reference |
|---|---|---|
| Regression results (coefficients, SEs, R², N) | Stargazer-style coefficient table | `references/table-generation.md` |
| Summary statistics (means, SDs, quantiles) | Descriptive statistics panel | `references/table-generation.md` |
| Monte Carlo output (bias, RMSE, coverage) | Simulation results table | `references/table-generation.md` |
| Balance / covariate comparison | Balance table with normalized differences | `references/table-generation.md` |
| Transition probabilities | Matrix with row/column labels | `references/table-generation.md` |
| First-stage IV results | First-stage regression table | `references/table-generation.md` |
| Time-relative coefficients (leads/lags) | Event study plot | `references/figure-generation.md` |
| Running variable + cutoff | RD plot with local polynomial | `references/figure-generation.md` |
| Multiple estimates with CIs | Coefficient comparison plot | `references/figure-generation.md` |
| Sample sizes × effect sizes | Power curve | `references/figure-generation.md` |
| Group distributions | Density / kernel density plot | `references/figure-generation.md` |
| Two continuous variables | Binned scatter plot | `references/figure-generation.md` |
| Sorted estimates + indicator matrix | Specification curve | `references/figure-generation.md` |

## Format Defaults

### Tables

| Setting | Default |
|---|---|
| Format | LaTeX (booktabs: `\toprule`, `\midrule`, `\bottomrule`) |
| Stars | On coefficients, never on SEs (* p<0.10, ** p<0.05, *** p<0.01) |
| SEs | In parentheses, directly below coefficient |
| Decimal alignment | All numbers in a column align at decimal point |
| Fixed effects | Yes/No indicator rows, not coefficient rows |
| Negative numbers | Minus sign (economics convention), not parentheses |
| File location | `tables/<descriptive-name>.tex` |
| Label format | `tab:<name>` |

### Figures

| Setting | Default |
|---|---|
| Font | Serif (Computer Modern / Times), 11-12pt labels |
| Size | 6.5" × 4.5" (single column), 13" × 4.5" (two-panel) |
| DPI | Vector (PDF) primary, 300 DPI PNG secondary |
| Style | White background, no gridlines, bottom+left axes only |
| Color | Grayscale-friendly with distinct markers and line styles |
| Colorblind | Okabe-Ito or ColorBrewer Set2 when color is used |
| File location | `figures/<descriptive-name>.pdf` + `.png` |
| Label format | `fig:<name>` |

## Language-Specific Packages

| Language | Tables | Figures |
|---|---|---|
| Python | pandas, stargazer, pystout, tabulate | matplotlib + seaborn |
| R | stargazer, modelsummary, kableExtra, gt, tinytable, fixest::etable() | ggplot2, coefplot, binsreg |
| Julia | PrettyTables.jl, Latexify.jl | Plots.jl, Makie.jl |
| Stata | esttab, outreg2, estout | twoway, coefplot, binscatter |

**Package notes:**

- `pystout` (Python) — estout-style regression tables for statsmodels and linearmodels (OLS, IV2SLS, PanelOLS). Supports `mgroups` for column grouping, `modstat` for custom statistics rows.
- `tinytable` (R) — lightweight, native Typst support, used as modelsummary backend.
- `fixest::etable()` (R) — direct from estimation, handles multi-way FE notation automatically.

**Automated vs semi-automated tradeoff:** Automated tools (esttab, stargazer) are quick but hard to customize. Semi-automated tools (save intermediates, generate LaTeX separately) are harder to start but easier to customize. Costs are convex for automated, concave for semi-automated.

**Quarto+Typst:** Quarto with Typst backend offers sub-second compilation for iterative work. Use `keep-tex: true` for journal submission when you need the raw LaTeX output.

## Multi-Panel Assembly

Tables and figures often require multi-panel layouts:

| Pattern | Table panels | Figure layout |
|---|---|---|
| Multiple outcomes | Panel A/B/C by outcome | 1×2 or 1×3 side-by-side |
| Multiple samples | Panel by subsample | 2×1 stacked |
| Multiple methods | Panel by estimator (OLS/IV/GMM) | 2×2 grid |
| Robustness variants | Columns within one panel | 2×3 grid |
| Event study + pre-trends | — | 2×1 stacked (estimates + test) |

Ensure consistent axis scales, font sizes, and formatting across panels. Label panels as (a), (b), (c) or Panel A, Panel B, Panel C.

## Quick Examples

### Python: Regression Table

```python
import pandas as pd
from stargazer.stargazer import Stargazer
from linearmodels.iv import IV2SLS

# Format results with stargazer
stargazer = Stargazer([ols_result, iv_result])
stargazer.custom_columns(["OLS", "IV/2SLS"])
stargazer.show_model_numbers(False)
stargazer.significant_digits(3)
with open("tables/main-results.tex", "w") as f:
    f.write(stargazer.render_latex())
```

### Python: Event Study Plot

```python
import matplotlib.pyplot as plt
import matplotlib

matplotlib.rcParams.update({"font.family": "serif", "font.size": 11})
fig, ax = plt.subplots(figsize=(6.5, 4.5))
ax.errorbar(leads_lags, coefficients, yerr=1.96 * se, fmt="o-", color="black", capsize=3)
ax.axhline(y=0, color="gray", linestyle="--", linewidth=0.8)
ax.axvline(x=-0.5, color="red", linestyle=":", linewidth=0.8)
ax.set_xlabel("Periods relative to treatment")
ax.set_ylabel("Coefficient estimate")
ax.spines[["top", "right"]].set_visible(False)
fig.savefig("figures/event-study.pdf", bbox_inches="tight")
```

## Quality Checklist

Before finalizing any output:

- [ ] Decimal alignment consistent within each column
- [ ] Stars attached to coefficients only (never to SEs)
- [ ] SE format consistent throughout (parentheses or brackets, not mixed)
- [ ] Sample sizes sum correctly across panels
- [ ] Column/axis labels clear and unambiguous
- [ ] Significance note present if stars used
- [ ] LaTeX compiles without errors
- [ ] Figures readable in grayscale (B&W print)
- [ ] No default titles on figures (titles go in \caption)
- [ ] All information encoded in color also encoded in shape/line style

## Integration with Other Components

- `econometric-reviewer` agent preloads this skill to audit tables against code output
- `econometric-reviewer` may request formatted output during `/workflows:review`
- `/workflows:compound` captures table/figure templates into `docs/solutions/`
- Companion outputs: regression table → summary statistics table; event study → pre-trend test figure

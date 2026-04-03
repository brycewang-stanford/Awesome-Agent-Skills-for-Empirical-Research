# Table Generation Reference

Procedural reference for building publication-ready tables: type-specific structure, formatting defaults, multi-panel assembly, output formats, and reproduction code. Referenced from the `publication-output` skill.

---

## Table Types

### Regression Table (Stargazer-Style)

Structure:
- Header row with specification labels: (1), (2), (3), ...
- Dependent variable row (include if it varies across columns)
- Coefficient rows with significance stars on the estimate
- Standard error rows in parentheses directly below each coefficient
- Midrule separator
- Footer block: N, R-squared, Adjusted R-squared, F-statistic
- Fixed effects indicators as Yes/No rows (one per FE dimension)
- Controls indicator: Yes/No
- Clustering level stated in footer or table notes
- Significance note: \* p<0.10, \*\* p<0.05, \*\*\* p<0.01

Conventions:
- Stars attach to coefficients, never to standard errors
- Standard errors in parentheses: `(0.287)`
- Negative numbers use a minus sign, not accounting parentheses (economics convention)
- Omit individual control coefficients when many — use "Controls: Yes" row instead
- Fixed effects appear as indicator rows, not coefficient rows
- Align decimal points across all columns
- Build specifications additively: baseline (column 1) adds controls progressively through the final column

### Summary Statistics

Structure:
- Variable names in first column
- Statistic columns: Mean, SD, Min, P25, Median, P75, Max, N
- Panel structure for multiple groups (Panel A: Full Sample, Panel B: Treatment, Panel C: Control)

Conventions:
- Report mean and SD for continuous variables
- Report frequency and percentage for categorical variables
- Include per-variable N if missingness varies across variables
- Order variables logically: outcome, then treatment, then key controls, then demographics
- Include units in variable labels when non-obvious (e.g., "Income (USD)")

### Monte Carlo Results

Structure:
- Rows: estimator x sample size combinations
- Columns: Bias, RMSE, MAE, Coverage (95%), Coverage (90%), Size, Power
- Panel by estimator or by DGP variation
- Footer: R (number of replications), base seed

Conventions:
- Report bias with explicit sign (positive or negative)
- Bold coverage values outside [0.90, 0.98] for nominal 95% CI
- Bold size values outside [0.03, 0.07] for nominal 5% level
- Bold the lowest RMSE in each sample-size row (best estimator)
- Include analytical standard errors alongside simulation SE when available

### Balance Table

Structure:
- Variable names in first column
- Columns: Treatment Mean, Control Mean, Difference, SE(Diff), p-value
- Optional: Normalized difference column (Imbens & Rubin)
- Footer: N(treatment), N(control)

Conventions:
- Stars on the difference column only
- Flag normalized differences exceeding 0.25 (Imbens-Rubin threshold)
- Include joint F-test for overall balance at the bottom
- Order variables to match summary statistics table

### Transition Matrix

Structure:
- Row labels: origin states
- Column labels: destination states
- Cell values: transition probabilities or counts
- Marginal row and column totals

Conventions:
- Rows sum to 1.0 for probability matrices
- Bold diagonal entries (persistence)
- State labels should match model notation

### First-Stage Results

Structure:
- Same layout as regression table
- Instrument coefficients with standard errors
- Footer must include: F-statistic (Kleibergen-Paap if robust SEs), partial R-squared, Shea partial R-squared
- N matching the corresponding second-stage table

Conventions:
- Always present as a companion to the IV/2SLS table
- Report all excluded instruments even if some are weak
- Include endogenous variable as the dependent variable label

---

## Number Formatting Defaults

| Content | Decimal places | Format |
|---------|---------------|--------|
| Coefficients | 3 | Plain number |
| Standard errors | 3 | In parentheses |
| t-statistics | 2 | In brackets (if shown) |
| p-values | 3 | Plain or significance stars |
| R-squared | 3 | Plain number |
| N (sample size) | 0 | Comma-separated (e.g., 12,345) |
| Percentages | 1 | With % symbol |
| Dollar amounts | 0-2 | With $ and comma separators |

Override rules:
- If all coefficients are very small (< 0.001), increase decimal places or rescale the variable
- If coefficients span orders of magnitude, consider scientific notation or log transformation
- Currency formatting follows the paper's convention (US papers: $1,234; European papers: 1.234 EUR)

---

## Multi-Panel Assembly

### Panel Detection

Assemble multiple result sets as panels when:
- Comparing across samples, methods, or time periods
- Reporting extensive and intensive margin results together
- Separating outcomes that share the same set of specifications

### Panel Organization Patterns

| Pattern | Panel structure |
|---------|---------------|
| Multiple outcomes | Panel A: Outcome 1, Panel B: Outcome 2 |
| Multiple samples | Panel A: Full Sample, Panel B: Subsample 1, Panel C: Subsample 2 |
| Multiple methods | Panel A: OLS, Panel B: IV, Panel C: GMM |
| Multiple time periods | Panel A: Pre-period, Panel B: Post-period |
| Extensive + intensive margin | Panel A: Participation, Panel B: Conditional on Participation |

### Cross-Specification Alignment

- Variable names must be consistent across panels (same variable, same label)
- Column positions must align: specification (1) in Panel A matches specification (1) in Panel B
- Number formatting is uniform across all panels
- Column headers appear once at the top, not repeated per panel
- Panel labels use bold or small caps: **Panel A: ...** or `\textsc{Panel A: ...}`

### Companion Tables

- Regression table -> companion summary statistics table
- Balance table -> companion distribution comparison or histogram
- First-stage table -> companion reduced-form table
- Store companions as separate files; note the relationship in both captions

### Sizing Guidelines

- Maximum recommended columns: 8-10 for letter/A4 portrait
- Maximum rows before splitting: 40-50
- If table exceeds page width: use landscape orientation or reduce font size
- If table exceeds one page: split into separate tables or use `longtable`
- Prefer splitting over shrinking below `\scriptsize`

---

## Output Formats

### LaTeX (Default)

Configuration defaults:

| Setting | Default | Notes |
|---------|---------|-------|
| Table environment | `table` with `tabular` | Use `longtable` if > 40 rows |
| Column alignment | `l` for labels, `c` for numeric | Right-align if mixed-width numbers |
| Rules | `booktabs` (`\toprule`, `\midrule`, `\bottomrule`) | Never use `\hline` |
| Font size | `\small` or `\footnotesize` | Adjust to fit page width |
| Float placement | `[htbp]` | Standard float |
| Caption + label | `\caption{...}\label{tab:<name>}` | Label format: `tab:<name>` |

Standalone table file (includable via `\input{}`):

```latex
\begin{table}[htbp]
\centering
\caption{Main Regression Results}
\label{tab:main-results}
\small
\begin{tabular}{lcccc}
\toprule
 & (1) & (2) & (3) & (4) \\
\midrule
Treatment & 0.543*** & 0.498*** & 0.512*** & 0.487** \\
          & (0.102)  & (0.115)  & (0.118)  & (0.201) \\
\midrule
Controls      & No  & Yes & Yes & Yes \\
State FE      & No  & No  & Yes & Yes \\
Year FE       & No  & No  & Yes & Yes \\
\midrule
Observations  & 12,345 & 12,345 & 12,345 & 8,901 \\
R-squared     & 0.041  & 0.132  & 0.287  & 0.301 \\
\bottomrule
\multicolumn{5}{l}{\footnotesize Standard errors in parentheses.} \\
\multicolumn{5}{l}{\footnotesize * p$<$0.10, ** p$<$0.05, *** p$<$0.01} \\
\end{tabular}
\end{table}
```

Integration in a paper:

```latex
% Simple include (table file contains full environment):
\input{tables/main-results.tex}

% Or wrap externally (table file contains only tabular):
\begin{table}[htbp]
\centering
\caption{Main Results}\label{tab:main-results}
\input{tables/main-results-tabular.tex}
\end{table}
```

### Markdown

Use pipe-delimited tables. Align columns with `:---:` (center) or `---:` (right). Suitable for README files, GitHub display, and quick review.

### HTML

Styled `<table>` with CSS classes for striping, alignment, and borders. Suitable for web display and presentations.

### CSV

Plain comma-separated values. No formatting, no stars, no parentheses on SEs. Include a header row. Suitable for data exchange and spreadsheet import.

---

## Quality Checks

Run before finalizing any table:

| Check | Requirement |
|-------|------------|
| Decimal alignment | All numbers in a column align at the decimal point |
| Star placement | Stars on coefficients only, never on standard errors |
| SE format consistency | Parentheses (or brackets) used uniformly throughout |
| N consistency | Sample sizes sum correctly across panels; N matches data |
| Column labels | Clear, concise, no ambiguous abbreviations |
| Significance note | Present at table bottom whenever stars are used |
| Source note | Data source included if relevant |
| LaTeX compilation | No special-character errors (`%`, `&`, `_` escaped properly) |
| Cross-table consistency | Same variable has same label and formatting across all tables |
| Rounding consistency | Same statistic uses the same decimal places across tables |

---

## Reproduction Code Patterns

### Python

```python
# pandas + manual formatting
import pandas as pd

# Build results DataFrame from model objects
results = pd.DataFrame({
    '(1)': [f'{m1.params["treat"]:.3f}{"***" if m1.pvalues["treat"]<0.01 else ""}',
            f'({m1.bse["treat"]:.3f})'],
    '(2)': [f'{m2.params["treat"]:.3f}{"***" if m2.pvalues["treat"]<0.01 else ""}',
            f'({m2.bse["treat"]:.3f})'],
}, index=['Treatment', ''])
results.to_latex('tables/main-results.tex', escape=False)

# stargazer package
from stargazer.stargazer import Stargazer
sg = Stargazer([m1, m2, m3])
sg.custom_columns(['OLS', 'IV', 'GMM'], [1, 1, 1])
sg.significance_levels([0.10, 0.05, 0.01])
sg.show_model_numbers(True)
with open('tables/main-results.tex', 'w') as f:
    f.write(sg.render_latex())
```

### R

```r
# stargazer
library(stargazer)
stargazer(m1, m2, m3,
          type = "latex",
          out = "tables/main-results.tex",
          title = "Main Results",
          label = "tab:main-results",
          dep.var.labels = "Log Wages",
          covariate.labels = c("Treatment", "Experience", "Experience$^2$"),
          add.lines = list(c("Controls", "No", "Yes", "Yes"),
                           c("State FE", "No", "No", "Yes")),
          omit.stat = c("f", "ser"),
          notes.align = "l",
          star.cutoffs = c(0.10, 0.05, 0.01))

# modelsummary
library(modelsummary)
modelsummary(list("(1)" = m1, "(2)" = m2, "(3)" = m3),
             output = "tables/main-results.tex",
             stars = c('*' = 0.10, '**' = 0.05, '***' = 0.01),
             gof_map = c("nobs", "r.squared", "adj.r.squared"),
             coef_rename = c(treat = "Treatment"))

# kableExtra (for summary statistics and custom layouts)
library(kableExtra)
sumstats %>%
    kbl(format = "latex", booktabs = TRUE, digits = 3,
        caption = "Summary Statistics", label = "sumstats") %>%
    kable_styling(font_size = 9) %>%
    pack_rows("Panel A: Full Sample", 1, 10) %>%
    pack_rows("Panel B: Treatment", 11, 20) %>%
    save_kable("tables/sumstats.tex")
```

### Stata

```stata
* esttab (recommended — part of estout suite)
eststo clear
eststo: reg y treat x1 x2, robust
eststo: ivregress 2sls y x1 x2 (treat = z1 z2), robust
eststo: reg y treat x1 x2 i.state i.year, cluster(state)

esttab using "tables/main-results.tex", replace ///
    b(3) se(3) star(* 0.10 ** 0.05 *** 0.01) ///
    label booktabs alignment(D{.}{.}{-1}) ///
    title("Main Results") ///
    mtitles("OLS" "IV" "FE") ///
    scalars("N Observations" "r2 R-squared") ///
    addnotes("Standard errors in parentheses." ///
             "* p<0.10, ** p<0.05, *** p<0.01")

* outreg2 (alternative)
outreg2 using "tables/main-results.tex", replace ///
    tex(frag) label dec(3) ///
    addstat("F-stat", e(F)) ///
    title("Main Results")

* tabstat for summary statistics
tabstat y x1 x2 x3, stats(mean sd min p25 p50 p75 max n) ///
    columns(statistics) format(%9.3f)
```

### Julia

```julia
using PrettyTables, DataFrames

# Build results DataFrame
results = DataFrame(
    Variable = ["Treatment", "", "Controls", "N", "R²"],
    col1 = ["0.543***", "(0.102)", "No", "12,345", "0.041"],
    col2 = ["0.498***", "(0.115)", "Yes", "12,345", "0.132"]
)

# LaTeX output
open("tables/main-results.tex", "w") do io
    pretty_table(io, results;
        backend = Val(:latex),
        nosubheader = true,
        tf = tf_latex_booktabs,
        alignment = [:l, :c, :c],
        header = ["", "(1)", "(2)"])
end

# Latexify.jl for equation-embedded tables
using Latexify
latexify(results, env = :table, fmt = "%.3f")
```

---

## File Naming and Organization

| File type | Naming pattern | Example |
|-----------|---------------|---------|
| Main regression | `reg-<topic>.tex` | `reg-main-results.tex` |
| Summary statistics | `sumstats-<sample>.tex` | `sumstats-full-sample.tex` |
| Balance table | `balance-<comparison>.tex` | `balance-treat-control.tex` |
| First stage | `firststage-<instrument>.tex` | `firststage-proximity.tex` |
| Monte Carlo | `mc-<metric>.tex` | `mc-bias-coverage.tex` |
| Robustness | `rob-<variant>.tex` | `rob-alt-specs.tex` |
| Transition matrix | `trans-<states>.tex` | `trans-employment.tex` |

All table files go in `tables/` (create if absent). Label format in LaTeX: `\label{tab:<name>}` matching the file stem.

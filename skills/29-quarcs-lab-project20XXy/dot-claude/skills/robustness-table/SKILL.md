---
name: robustness-table
description: Generates robustness check code and formats results as a combined table. Use for sensitivity analysis.
argument-hint: <notebook> <baseline spec>
allowed-tools: Bash, Read, Write, Edit, Glob, Grep
---

# Generate Robustness Checks and Table

Given a baseline regression, generate code for standard robustness checks and format the results as a publication-ready table.

## Arguments

- `$ARGUMENTS` — notebook reference and baseline specification description (e.g., "notebook-02 baseline OLS with GDP on life expectancy")

## Steps

1. Read the specified notebook and locate the baseline regression:
   - Look for estimation commands (Python: `statsmodels`, `linearmodels`; R: `lm`, `fixest`, `felm`; Stata: `reg`, `reghdfe`, `ivregress`)
   - Identify the dependent variable, independent variables, fixed effects, and clustering

2. Ask the user which robustness checks to include:
   - Alternative control variable sets (drop/add controls)
   - Alternative fixed effects specifications
   - Different standard error clustering levels
   - Subsample analysis (e.g., by region, time period, income group)
   - Winsorized or trimmed dependent variable
   - Alternative dependent variable (e.g., log vs level)
   - Placebo tests (randomized treatment, pre-period outcome)
   - Alternative estimation methods (e.g., OLS vs Poisson, logit vs probit)

3. Generate code cells in the notebook for each robustness specification:
   - Each cell should be self-contained (loads data, runs regression, stores results)
   - Use consistent variable naming for results collection

4. Create a summary cell that collects all results into a single table:
   - Cell directive: `#| label: tbl-robustness` (or `*|` for Stata)
   - Cell directive: `#| tbl-cap: "Robustness checks"` (or `*|` for Stata)
   - Format: baseline in column (1), each robustness check in subsequent columns
   - Follow academic conventions: coefficient (SE), significance stars, N, R², FE indicators
   - **Stata caveat:** Do NOT use `tbl-` prefix for Stata text output — use a plain label (e.g., `stata-robustness`)

5. Optionally export the table to `tables/` as a standalone file (LaTeX or CSV)

6. Sync the Jupytext pair:
   ```bash
   uv run jupytext --sync notebooks/<name>.md
   ```

7. Show the embed shortcode for `index.qmd`:
   ```
   {{< embed notebooks/<name>.ipynb#tbl-robustness >}}
   ```

## Error handling

- If the baseline regression is not found, ask the user to point to the specific cell.
- If the notebook uses a language not recognized, ask for guidance on the estimation syntax.

---
name: regression-table
description: Formats estimation output as a publication-quality regression table with stars, SEs, and fit statistics. Use when creating a results table.
argument-hint: <notebook> [description]
allowed-tools: Bash, Read, Write, Edit, Glob, Grep
---

# Format Regression Table

Create a publication-quality regression table from estimation output in a notebook.

## Arguments

- `$ARGUMENTS` — a notebook reference and/or description of the table (e.g., "notebook-02 OLS results" or "main regression table with 3 specifications")

## Steps

1. Identify the source notebook and the estimation output:
   - If a notebook name is provided, read that notebook
   - If no notebook is specified, ask the user which notebook contains the regression results
   - Look for cells with estimation commands (Python: `statsmodels`, `linearmodels`; R: `lm`, `fixest`, `felm`; Stata: `reg`, `reghdfe`, `ivregress`)

2. Ask the user for table specifications:
   - Which models/columns to include
   - Dependent variable name(s)
   - Which coefficients to display (or "all")
   - Fixed effects to report as Yes/No rows
   - Clustering level for standard errors
   - Any custom notes for the table footer

3. Construct the table following academic conventions:
   - **Header row:** Dependent variable name spanning all columns, column numbers (1), (2), (3)...
   - **Coefficient rows:** Point estimate on top, standard error in parentheses below
   - **Significance stars:** `*` p<0.10, `**` p<0.05, `***` p<0.01
   - **Fixed effects rows:** Yes/No indicators
   - **Summary rows:** Observations (N), R-squared, Adjusted R-squared, or other fit statistics
   - **Footer:** Significance legend and notes about standard errors

4. Create or update a cell in the specified notebook with:
   - Cell directive: `#| label: tbl-<descriptive-name>` (or `*|` for Stata)
   - Cell directive: `#| tbl-cap: "<caption>"` (or `*|` for Stata)
   - The code to generate the formatted Markdown table
   - **Stata caveat:** Do NOT use `tbl-` prefix for Stata text output — use a plain label instead (e.g., `stata-regression`)

5. Sync the Jupytext pair:
   ```bash
   uv run jupytext --sync notebooks/<name>.md
   ```

6. Show the user the embed shortcode to paste into `index.qmd`:
   ```
   {{< embed notebooks/<name>.ipynb#tbl-<label> >}}
   ```

## Error handling

- If the notebook has no estimation output, report this and ask the user to run the regressions first.
- If the estimation output format is not recognized, ask the user to provide the raw coefficients and standard errors.

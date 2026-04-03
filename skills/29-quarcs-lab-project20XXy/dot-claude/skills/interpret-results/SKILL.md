---
name: interpret-results
description: Writes academic prose interpreting regression output. Use when describing estimation results in manuscript-ready language.
argument-hint: <cell ref or output>
allowed-tools: Bash, Read, Write, Edit, Glob, Grep
---

# Interpret Regression Results

Write academic prose interpreting estimation output, suitable for pasting into `index.qmd`.

## Arguments

- `$ARGUMENTS` — regression output (pasted directly), or a notebook cell reference (e.g., "notebook-02#tbl-main-regression")

## Steps

1. Parse the regression output:
   - If a notebook cell reference is provided, read that notebook and extract the output from the specified cell
   - If output is pasted directly, parse the coefficients, standard errors, significance levels, and fit statistics

2. Identify key elements:
   - Dependent variable
   - Key independent variable(s) of interest (vs. controls)
   - Significance levels and confidence intervals
   - R-squared, N, F-statistic
   - Fixed effects or clustering used

3. Draft 1–3 paragraphs of academic prose covering:
   - **Statistical significance:** Which coefficients are significant at which levels
   - **Direction and magnitude:** Sign and size of key coefficients, in interpretable units
   - **Economic significance:** What the coefficient means in practical terms (e.g., "a one standard deviation increase in X is associated with a Y% change in the outcome")
   - **Comparison across specifications:** If multiple columns, note how results change with additional controls or FE
   - **Robustness:** Note whether results are stable across specifications

4. Use appropriate academic hedging language:
   - "The results suggest..." / "We find evidence consistent with..."
   - "The coefficient is statistically significant at the 5% level"
   - "The point estimate implies that..."
   - Avoid causal language unless the identification strategy supports it

5. Format the output for `index.qmd`:
   - Use Quarto cross-references where appropriate (e.g., "as shown in @tbl-main-regression")
   - Include parenthetical references to table columns (e.g., "Column (3)")
   - Note: use plain prose for cross-references to embedded content to avoid Quarto crossref warnings

6. Present the draft to the user for review. Do not insert into `index.qmd` without approval.

## Error handling

- If the output format is not recognized, ask the user to clarify which values are coefficients, SEs, and significance indicators.

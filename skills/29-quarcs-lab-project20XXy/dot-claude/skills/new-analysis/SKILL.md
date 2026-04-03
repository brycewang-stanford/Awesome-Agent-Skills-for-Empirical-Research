---
name: new-analysis
description: Scaffolds a method-specific analysis notebook (DiD, IV, RDD, LASSO, Panel FE) with boilerplate. Use when starting a new econometric analysis.
argument-hint: <method> [title]
allowed-tools: Bash, Read, Write, Edit, Glob, Grep
---

# Scaffold Analysis Notebook

Create a new notebook pre-populated with method-specific boilerplate for a common econometric technique.

## Arguments

- `$ARGUMENTS` — the method name and optional title (e.g., "DiD Event Study", "IV Analysis of Colonial Origins", "RDD Minimum Wage", "LASSO Variable Selection", "Panel FE Growth Regressions")

## Steps

1. Parse the method from the arguments. Recognized methods:
   - **DiD** (difference-in-differences)
   - **IV** (instrumental variables)
   - **RDD** (regression discontinuity design)
   - **LASSO** (regularized regression / variable selection)
   - **Panel FE** (panel fixed effects)
   - If the method is not recognized, ask the user to clarify.

2. Follow the same notebook creation conventions as `/project:new-notebook`:
   - Check `notebooks/` for existing files to determine the next sequential number
   - Ask the user for the kernel: Python, R, or Stata
   - Create the `.ipynb` with the appropriate kernel and setup cell:
     - **Python:** `import sys; sys.path.insert(0, ".."); from config import set_seeds, DATA_DIR; set_seeds()`
     - **R:** `source("../config.R"); set_seeds()`
     - **Stata:** `clear all` followed by `set seed 42`

3. Add method-specific sections as markdown and code cells:

   **All methods include these sections:**
   - Data Loading (code cell)
   - Variable Construction (code cell)
   - Summary Statistics (code cell with `#| label: tbl-<method>-sumstats`)
   - Estimation (code cell with `#| label: tbl-<method>-main`)
   - Visualization (code cell with `#| label: fig-<method>-main`)
   - Robustness Checks (markdown header + empty code cell)

   **Method-specific boilerplate:**

   - **DiD:** parallel trends test, event study plot (`#| label: fig-event-study`), TWFE regression, staggered treatment note
   - **IV:** first-stage regression, reduced-form, 2SLS estimation, weak instrument diagnostics (F-statistic, Anderson-Rubin), overidentification test stub
   - **RDD:** running variable histogram, McCrary density test, bandwidth selection (Imbens-Kalyanaraman), local polynomial estimation, RD plot (`#| label: fig-rd-plot`)
   - **LASSO:** cross-validation for lambda, coefficient path plot (`#| label: fig-lasso-path`), selected variables, post-LASSO OLS
   - **Panel FE:** within estimator, entity and time FE, clustered standard errors, Hausman test (FE vs RE)

4. Create the Jupytext `.md` pair:
   ```bash
   uv run jupytext --set-formats ipynb,md:myst notebooks/<name>.ipynb
   ```

5. Register in `_quarto.yml` under `manuscript.notebooks`:
   ```yaml
   - notebook: notebooks/<name>.ipynb
     title: "N<number>: <title>"
   ```

6. Confirm the notebook renders: `quarto render notebooks/<name>.ipynb`

7. Report the file path and list the embed-ready cell labels created.

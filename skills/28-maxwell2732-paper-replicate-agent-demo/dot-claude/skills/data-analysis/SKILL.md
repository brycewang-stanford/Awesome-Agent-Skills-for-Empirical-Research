---
name: data-analysis
description: End-to-end R data analysis workflow from exploration through regression to publication-ready tables and figures
disable-model-invocation: true
argument-hint: "[dataset path or description of analysis goal]"
allowed-tools: ["Read", "Grep", "Glob", "Write", "Edit", "Bash", "Task"]
---

# Data Analysis Workflow

Run an end-to-end data analysis in R: load, explore, analyze, and produce publication-ready output.

**Input:** `$ARGUMENTS` — a dataset path (e.g., `data/county_panel.csv`) or a description of the analysis goal (e.g., "regress wages on education with state fixed effects using CPS data").

---

## Constraints

- **Follow R code conventions** in `.claude/rules/r-code-conventions.md`
- **Save all scripts** to `scripts/R/` with descriptive names
- **Save all outputs** (figures, tables, RDS) to `output/`
- **Use `saveRDS()`** for every computed object — Quarto slides may need them
- **Use project theme** for all figures (check for custom theme in `.claude/rules/`)
- **Run r-reviewer** on the generated script before presenting results

---

## Workflow Phases

### Phase 1: Setup and Data Loading

1. Read `.claude/rules/r-code-conventions.md` for project standards
2. Create R script with proper header (title, author, purpose, inputs, outputs)
3. Load required packages at top (`library()`, never `require()`)
4. Set seed once at top: `set.seed(42)`
5. Load and inspect the dataset

### Phase 2: Exploratory Data Analysis

Generate diagnostic outputs:
- **Summary statistics:** `summary()`, missingness rates, variable types
- **Distributions:** Histograms for key continuous variables
- **Relationships:** Scatter plots, correlation matrices
- **Time patterns:** If panel data, plot trends over time
- **Group comparisons:** If treatment/control, compare pre-treatment means

Save all diagnostic figures to `output/diagnostics/`.

### Phase 3: Main Analysis

Based on the research question:
- **Regression analysis:** Use `fixest` for panel data, `lm`/`glm` for cross-section
- **Standard errors:** Cluster at the appropriate level (document why)
- **Multiple specifications:** Start simple, progressively add controls
- **Effect sizes:** Report standardized effects alongside raw coefficients

### Phase 4: Publication-Ready Output

**Tables:**
- Use `modelsummary` for regression tables (preferred) or `stargazer`
- Include all standard elements: coefficients, SEs, significance stars, N, R-squared
- Export as `.tex` for LaTeX inclusion and `.html` for quick viewing

**Figures:**
- Use `ggplot2` with project theme
- Set `bg = "transparent"` for Beamer compatibility
- Include proper axis labels (sentence case, units)
- Export with explicit dimensions: `ggsave(width = X, height = Y)`
- Save as both `.pdf` and `.png`

### Phase 5: Save and Review

1. `saveRDS()` for all key objects (regression results, summary tables, processed data)
2. Create `output/` subdirectories as needed with `dir.create(..., recursive = TRUE)`
3. Run the r-reviewer agent on the generated script:

```
Delegate to the r-reviewer agent:
"Review the script at scripts/R/[script_name].R"
```

4. Address any Critical or High issues from the review.

---

## Script Structure

Follow this template:

```r
# ============================================================
# [Descriptive Title]
# Author: [from project context]
# Purpose: [What this script does]
# Inputs: [Data files]
# Outputs: [Figures, tables, RDS files]
# ============================================================

# 0. Setup ----
library(tidyverse)
library(fixest)
library(modelsummary)

set.seed(42)

dir.create("output/analysis", recursive = TRUE, showWarnings = FALSE)

# 1. Data Loading ----
# [Load and clean data]

# 2. Exploratory Analysis ----
# [Summary stats, diagnostic plots]

# 3. Main Analysis ----
# [Regressions, estimation]

# 4. Tables and Figures ----
# [Publication-ready output]

# 5. Export ----
# [saveRDS for all objects, ggsave for all figures]
```

---

## Important

- **Reproduce, don't guess.** If the user specifies a regression, run exactly that.
- **Show your work.** Print summary statistics before jumping to regression.
- **Check for issues.** Look for multicollinearity, outliers, perfect prediction.
- **Use relative paths.** All paths relative to repository root.
- **No hardcoded values.** Use variables for sample restrictions, date ranges, etc.

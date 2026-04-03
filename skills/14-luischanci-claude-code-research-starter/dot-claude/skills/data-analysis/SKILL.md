---
name: data-analysis
description: End-to-end R data analysis workflow from exploration through regression to publication-ready tables and figures.
disable-model-invocation: true
argument-hint: "[dataset path or description of analysis goal]"
allowed-tools: ["Read", "Grep", "Glob", "Write", "Edit", "Bash", "Task"]
---

## Data Analysis

Run an end-to-end data analysis in R through 5 phases.

### Phase 1: Setup and Data Loading
- Read R code conventions from `.claude/rules/r-code-conventions.md`
- Create script with proper header (title, author, purpose, inputs, outputs)
- Load packages with `library()` (never `require()`)
- Set `set.seed()` if stochastic elements are involved
- Load data using relative paths

### Phase 2: Exploratory Data Analysis
- Summary statistics (mean, sd, min, max, N)
- Missingness patterns
- Distributions of key variables
- Bivariate relationships
- Time patterns (if panel data)
- Group comparisons
- Save diagnostics to `output/diagnostics/`

### Phase 3: Main Analysis
- Use `fixest` for panel data with fixed effects (see `/econometrics-r` for detailed patterns)
- Use `lm`/`glm` for cross-section
- Cluster standard errors appropriately
- Run multiple specifications (simple to complex)
- Report both statistical and economic significance
- For causal inference (IV, DiD, RDD), see `/causal-inference-r` for diagnostics and modern estimators
- For spatial econometrics, see `/econometrics-r` for `spdep`/`spatialreg` patterns

### Phase 4: Publication-Ready Output
- **Tables:** `modelsummary` (preferred) or `stargazer`, export as `.tex` and `.html`
- **Figures:** `ggplot2` with project theme, explicit dimensions, white background, 300 DPI
- Export figures as `.pdf` and `.png`

### Phase 5: Save and Review
- `saveRDS()` for all computed objects
- Run r-reviewer agent on generated script
- Address Critical/High issues

### Script Structure Template
```r
# ==============================================================================
# Title: [Analysis Name]
# Author: [Name]
# Date: [YYYY-MM-DD]
# Purpose: [What this script does]
# Inputs: [Data files]
# Outputs: [Tables, figures, RDS files]
# ==============================================================================

# 0. Setup ----
library(tidyverse)
library(fixest)
library(modelsummary)

# 1. Data Loading ----

# 2. Exploratory Analysis ----

# 3. Main Analysis ----

# 4. Tables and Figures ----

# 5. Export ----
```

All scripts saved to `scripts/R/`, all outputs to `output/`.

---
name: r-reproducibility-guide
description: "Create reproducible research workflows with R and RMarkdown/Quarto"
metadata:
  openclaw:
    emoji: "🔁"
    category: "tools"
    subcategory: "code-exec"
    keywords: ["R programming", "RMarkdown", "reproducibility", "Quarto", "renv", "computational reproducibility"]
    source: "wentor-research-plugins"
---

# Reproducible Research with R

A skill for creating fully reproducible research workflows in R using RMarkdown, Quarto, package management with renv, and project organization best practices. Covers literate programming, environment management, automated reporting, and sharing reproducible analyses.

## Project Organization

### Recommended Directory Structure

```
my-research-project/
  README.md
  my-project.Rproj         # RStudio project file
  renv.lock                 # Package versions (managed by renv)
  renv/                     # renv library directory
  data/
    raw/                    # Untouched original data
    processed/              # Cleaned, analysis-ready data
  R/
    01-clean.R              # Data cleaning functions
    02-analyze.R            # Analysis functions
    03-visualize.R          # Plotting functions
    utils.R                 # Helper functions
  analysis/
    main-analysis.Rmd       # Primary analysis notebook
    supplementary.Rmd       # Supplementary analyses
  output/
    figures/                # Generated plots
    tables/                 # Generated tables
    manuscript.pdf          # Compiled document
  Makefile                  # Reproducible build commands
```

### Key Principles

```
1. Raw data is read-only (never modify original data files)
2. All processing steps are scripted (no manual spreadsheet edits)
3. Generated outputs can be deleted and recreated from source
4. Package versions are locked with renv
5. Random seeds are set for all stochastic operations
6. Paths are relative to project root (never absolute)
```

## RMarkdown and Quarto

### RMarkdown Document

````markdown
---
title: "Analysis of Treatment Effects"
author: "Jane Smith"
date: "`r Sys.Date()`"
output:
  pdf_document:
    toc: true
    number_sections: true
  html_document:
    toc: true
    code_folding: hide
bibliography: references.bib
---

```{r setup, include=FALSE}
knitr::opts_chunk$set(
  echo = TRUE,
  message = FALSE,
  warning = FALSE,
  fig.width = 7,
  fig.height = 5,
  dpi = 300
)

library(tidyverse)
library(broom)

set.seed(42)
```

# Introduction

This analysis examines the effect of treatment on outcomes
[@smith2024].

# Methods

```{r load-data}
df <- read_csv("data/processed/study_data.csv")
glimpse(df)
```

# Results

```{r model}
model <- lm(outcome ~ treatment + age + gender, data = df)
tidy(model, conf.int = TRUE)
```

```{r fig-main, fig.cap="Treatment effect on primary outcome."}
ggplot(df, aes(x = treatment, y = outcome, fill = treatment)) +
  geom_boxplot() +
  theme_minimal() +
  labs(x = "Group", y = "Outcome Score")
```
````

### Quarto (Next Generation)

```yaml
---
title: "Analysis Report"
format:
  html:
    code-fold: true
    toc: true
  pdf:
    documentclass: article
execute:
  echo: true
  warning: false
---
```

Quarto supports R, Python, Julia, and Observable JS in a single document, making it ideal for multilingual research workflows.

## Package Management with renv

### Setting Up renv

```r
# Initialize renv in your project
renv::init()

# Install packages as usual
install.packages("tidyverse")
install.packages("lme4")

# Snapshot current package versions
renv::snapshot()

# Restore environment from lockfile (on a new machine)
renv::restore()
```

### How renv Works

```python
def explain_renv() -> dict:
    """
    Explain the renv reproducibility workflow.
    """
    return {
        "init": "Creates project-local library and renv.lock",
        "snapshot": (
            "Records exact package versions (name, version, source) "
            "into renv.lock. Commit this file to Git."
        ),
        "restore": (
            "Installs exact package versions from renv.lock on any machine. "
            "Collaborators run renv::restore() to match your environment."
        ),
        "benefits": [
            "Each project has isolated package versions",
            "No conflicts between projects",
            "Exact reproducibility months or years later",
            "renv.lock is a text file that diffs cleanly in Git"
        ]
    }
```

## Automated Reporting

### Make-Based Pipeline

```makefile
# Makefile for reproducible analysis

all: output/manuscript.pdf

data/processed/clean_data.csv: data/raw/study_data.csv R/01-clean.R
	Rscript R/01-clean.R

output/figures/figure1.pdf: data/processed/clean_data.csv R/03-visualize.R
	Rscript R/03-visualize.R

output/manuscript.pdf: analysis/main-analysis.Rmd data/processed/clean_data.csv
	Rscript -e "rmarkdown::render('analysis/main-analysis.Rmd', output_dir='output')"

clean:
	rm -rf output/figures/* output/manuscript.pdf data/processed/*
```

### targets Package (R-native Pipeline)

```r
# _targets.R
library(targets)

tar_option_set(packages = c("tidyverse", "broom"))

list(
  tar_target(raw_data, read_csv("data/raw/study_data.csv")),
  tar_target(clean_data, clean_dataset(raw_data)),
  tar_target(model, fit_model(clean_data)),
  tar_target(report, {
    rmarkdown::render("analysis/main-analysis.Rmd")
    "output/manuscript.pdf"
  })
)
```

The targets package tracks dependencies between pipeline steps and only reruns steps whose inputs have changed, saving time on large analyses.

## Sharing Reproducible Analyses

### Options for Sharing

| Method | Effort | Reproducibility |
|--------|--------|----------------|
| GitHub repo + renv.lock | Low | Good (requires R installation) |
| Docker container | Medium | Excellent (full environment) |
| Binder (mybinder.org) | Low | Good (browser-based, no install) |
| Code Ocean capsule | Medium | Excellent (certified reproducibility) |

Always include a README with instructions for reproducing the analysis: required software, how to install dependencies (renv::restore), how to run the pipeline (make all), and expected runtime.

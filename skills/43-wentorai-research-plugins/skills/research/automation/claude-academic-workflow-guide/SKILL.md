---
name: claude-academic-workflow-guide
description: "Claude Code template for LaTeX, Beamer, and R research workflows"
metadata:
  openclaw:
    emoji: "📚"
    category: "research"
    subcategory: "automation"
    keywords: ["Claude Code", "academic workflow", "LaTeX", "Beamer", "R", "multi-agent review"]
    source: "https://github.com/pedrohcgs/claude-code-my-workflow"
---

# Claude Code Academic Workflow Guide

## Overview

A template and workflow guide for using Claude Code in academic research — managing LaTeX papers, Beamer presentations, R analysis scripts, and multi-agent peer review. Provides structured CLAUDE.md configurations, project templates, and automation patterns for common academic tasks. Designed for economists, social scientists, and quantitative researchers.

## Project Structure

```
research-project/
├── CLAUDE.md              # Claude Code instructions
├── paper/
│   ├── main.tex           # Main LaTeX document
│   ├── references.bib     # Bibliography
│   ├── sections/          # LaTeX sections
│   └── figures/           # Generated figures
├── slides/
│   ├── presentation.tex   # Beamer slides
│   └── figures/
├── code/
│   ├── analysis.R         # Main analysis
│   ├── data_clean.R       # Data preparation
│   └── figures.R          # Figure generation
├── data/
│   ├── raw/               # Original data
│   └── processed/         # Cleaned data
└── output/
    ├── tables/            # LaTeX tables
    └── figures/           # PDF/PNG figures
```

## CLAUDE.md Configuration

```markdown
# Project: [Your Paper Title]

## Instructions
- This is an academic research project in economics
- LaTeX compiler: pdflatex (paper) or xelatex (if CJK)
- R version: 4.3+ with tidyverse, fixest, ggplot2
- Citation style: natbib, authoryear
- Always compile paper after LaTeX changes
- Run R scripts from project root

## Paper Conventions
- Use \input{sections/intro} for section includes
- Tables: booktabs package, generated from R
- Figures: PDF format, width=\textwidth
- Cross-refs: \label{sec:}, \label{tab:}, \label{fig:}

## R Conventions
- Style: tidyverse style guide
- Data: read from data/processed/
- Output: tables/ (LaTeX), figures/ (PDF)
- Reproducibility: set.seed(42) for all random ops

## Build Commands
- Paper: `cd paper && pdflatex main && bibtex main && pdflatex main && pdflatex main`
- Slides: `cd slides && pdflatex presentation`
- Analysis: `cd code && Rscript analysis.R`
```

## LaTeX Paper Workflow

```bash
# Claude Code can manage the full LaTeX workflow:

# 1. Draft a section
# "Write the methodology section for our diff-in-diff analysis"

# 2. Generate tables from R output
# "Create a LaTeX table from the regression results in output/tables/"

# 3. Fix compilation errors
# "The paper won't compile — fix the LaTeX errors"

# 4. Update bibliography
# "Add the Callaway & Sant'Anna (2021) reference"

# 5. Format for submission
# "Format the paper for AER submission guidelines"
```

## Beamer Presentations

```latex
% Template for academic presentations
\documentclass[aspectratio=169]{beamer}
\usetheme{metropolis}

\title{Your Presentation Title}
\subtitle{Conference/Seminar Name}
\author{Author Name}
\institute{University}
\date{\today}

\begin{document}
\maketitle

\begin{frame}{Motivation}
\begin{itemize}
    \item Research question
    \item Why it matters
    \item What we do
\end{itemize}
\end{frame}

\begin{frame}{Data}
\input{figures/summary_stats_table}
\end{frame}

\begin{frame}{Results}
\centering
\includegraphics[width=0.8\textwidth]{figures/main_result.pdf}
\end{frame}
\end{document}
```

## R Analysis Integration

```r
# analysis.R — Main analysis script
library(tidyverse)
library(fixest)
library(modelsummary)

# Load cleaned data
df <- read_csv("data/processed/analysis_data.csv")

# Main regression
model1 <- feols(outcome ~ treatment | year + state, data = df)
model2 <- feols(outcome ~ treatment + controls | year + state,
                data = df, cluster = ~state)

# Export table for LaTeX
modelsummary(
  list("(1)" = model1, "(2)" = model2),
  output = "output/tables/main_results.tex",
  stars = c("*" = 0.1, "**" = 0.05, "***" = 0.01),
  gof_map = c("nobs", "r.squared", "FE: year", "FE: state"),
)

# Export figure
ggplot(df, aes(x = year, y = outcome, color = treated)) +
  geom_point(alpha = 0.3) +
  geom_smooth(method = "loess") +
  theme_minimal() +
  labs(x = "Year", y = "Outcome", color = "Treatment Group")
ggsave("output/figures/treatment_trends.pdf", width = 8, height = 5)
```

## Multi-Agent Review

```markdown
### Self-Review Workflow
Use Claude Code to simulate peer review:

1. "Review this paper as a critical referee for AER"
2. "Check all mathematical derivations in section 3"
3. "Verify that all tables match the R code output"
4. "Check for consistency between text claims and results"
5. "List potential referee objections and how to address them"
```

## Common Tasks

```markdown
### Things to ask Claude Code:
- "Compile the paper and fix any errors"
- "Add robustness check using propensity score matching"
- "Create a Beamer slide summarizing Table 2"
- "Generate event study plot from the regression results"
- "Convert this Word draft to LaTeX format"
- "Check all cross-references are correct"
- "Format references in AEA style"
```

## Use Cases

1. **Paper writing**: LaTeX drafting and compilation workflow
2. **Data analysis**: R script development and debugging
3. **Presentations**: Beamer slide creation from paper content
4. **Self-review**: Multi-agent review simulation
5. **Submission prep**: Format conversion for journal submission

## References

- [claude-code-my-workflow](https://github.com/pedrohcgs/claude-code-my-workflow)
- [Metropolis Beamer Theme](https://github.com/matze/mtheme)
- [modelsummary](https://modelsummary.com/)

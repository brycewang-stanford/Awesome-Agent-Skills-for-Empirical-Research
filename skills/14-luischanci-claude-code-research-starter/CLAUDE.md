# CLAUDE.MD -- [PROJECT TITLE]

**Project:** [Your project title]
**Authors:** [Author 1, Author 2, ...]
**Institution:** [Your institution]
**Branch:** main

---

## Core Principles

- **Plan first** -- enter plan mode before non-trivial tasks; save plans to `quality_reports/plans/`
- **Verify after** -- compile/run and confirm output at the end of every task
- **Quality gates** -- nothing ships below 80/100
- **[LEARN] tags** -- when corrected, save `[LEARN:category] wrong -> right` to MEMORY.md

---

## Folder Structure

```
project-root/
├── CLAUDE.MD                    # This file
├── .claude/                     # Rules, skills, agents, hooks
├── [code-folder]/               # Estimation code (Julia/R/Python)
│   ├── [main-script]            # Pipeline entry point
│   ├── [core-module]            # Core estimation algorithms
│   ├── [data-processing]        # Data cleaning/processing script
│   ├── Data/Raw/                # Input data files
│   ├── Data/Processed/          # Generated intermediate data
│   └── Outcomes/                # Output: estimates, tables, figures
├── [paper-folder]/              # LaTeX manuscript source
│   ├── [manuscript].tex         # Main manuscript
│   ├── [bibliography].bib       # Bibliography
│   ├── figures/                 # Paper figures
│   └── includes/                # LaTeX-ready parameter estimates
├── scripts/                     # Utility scripts
├── quality_reports/             # Plans, session logs, merge reports
├── explorations/                # Research sandbox (see rules)
├── templates/                   # Session log, quality report templates
└── master_supporting_docs/      # Supporting papers and materials
```

---

## Commands

```bash
# [CUSTOMIZE: Add your project's compilation/execution commands]

# Julia estimation pipeline
# julia [code-folder]/main.jl

# R data processing
# Rscript -e "setwd('[code-folder]'); source('[data-processing].R')"

# LaTeX paper compilation (3-pass, pdflatex)
# cd [paper-folder] && pdflatex -interaction=nonstopmode [manuscript].tex
# bibtex [manuscript]
# pdflatex -interaction=nonstopmode [manuscript].tex
# pdflatex -interaction=nonstopmode [manuscript].tex
```

---

## Model Specifications

| Model | Type | Estimates | Description |
|-------|------|-----------|-------------|
| [M1] | [type] | [parameters] | [Brief description] |
| [M2] | [type] | [parameters] | [Brief description] |

---

## Quality Thresholds

| Score | Gate | Meaning |
|-------|------|---------|
| 80 | Commit | Good enough to save |
| 90 | PR | Ready for review |
| 95 | Excellence | Aspirational |

---

## Skills Quick Reference

### Workflow Skills

| Command | What It Does |
|---------|-------------|
| `/compile-latex [file]` | 3-pass pdflatex + bibtex |
| `/proofread [file]` | Grammar/typo/consistency review |
| `/review-r [file]` | R code quality review |
| `/review-julia [file]` | Julia code quality review |
| `/review-paper [file]` | Manuscript review |
| `/validate-bib` | Cross-reference citations |
| `/devils-advocate` | Challenge design decisions |
| `/commit [msg]` | Stage, commit, PR, merge |
| `/lit-review [topic]` | Literature search + synthesis |
| `/research-ideation [topic]` | Research questions + strategies |
| `/interview-me [topic]` | Interactive research interview |
| `/data-analysis [dataset]` | End-to-end R analysis |

### Econometrics Reference Skills

| Command | What It Does |
|---------|-------------|
| `/econometrics-julia` | MLE, GMM, simulation, Optim.jl, parallel computing |
| `/econometrics-r` | data.table, fixest, spatial, causal forests, tables |
| `/causal-inference-r` | IV, DiD, RDD with diagnostics |
| `/stata` | Full Stata reference (30 ref docs + 20 package docs) |

---

## Key Output Files

| File Pattern | Location | Content |
|-------------|----------|---------|
| [CUSTOMIZE] | [path] | [description] |

---

## Current Project State

| Component | Status | Notes |
|-----------|--------|-------|
| [Component 1] | Not started | [Notes] |
| [Component 2] | Not started | [Notes] |

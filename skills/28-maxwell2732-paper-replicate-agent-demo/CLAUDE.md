# CLAUDE.MD -- UKB Empirical Replication Agent

**Project:** UKB Empirical Replication Agent
**Institution:** China Agricultural University
**Branch:** main

---

## Core Principles

- **Plan first** -- enter plan mode before non-trivial tasks; save plans to `quality_reports/plans/`
- **Verify after** -- run scripts and confirm outputs match targets at the end of every task
- **Replicate before extending** -- match published results exactly before any modifications
- **Quality gates** -- nothing ships below 80/100
- **[LEARN] tags** -- when corrected, save `[LEARN:category] wrong → right` to MEMORY.md

---

## Folder Structure

```
my-ukb-agent/
├── CLAUDE.md                    # This file
├── .claude/                     # Rules, skills, agents, hooks
├── papers/                      # Source PDFs and original replication packages
│   └── [PaperName]/
│       ├── original_paper.pdf
│       ├── supplementary.pdf
│       ├── *.do / *.R           # Original Stata/R code (if provided)
│       └── README.md
├── data/                        # Datasets (gitignored — sensitive UKB data)
├── replications/                # Our replication scripts and outputs
│   └── [PaperName]/
│       ├── R/replicate.R
│       ├── R/figures/
│       ├── R/results/
│       ├── python/replicate.py  # (if Python replication needed)
│       └── validation_report.md
├── reports/                     # Polished final replication reports
├── scripts/                     # Utility scripts (quality_score.py, helpers)
│   └── R/                       # Shared R utility functions
├── quality_reports/             # Plans, session logs, replication targets
│   ├── plans/
│   ├── specs/
│   ├── session_logs/
│   ├── merges/
│   └── [Paper]_replication_targets.md
├── explorations/                # Exploratory analysis sandbox
│   └── ARCHIVE/
├── master_supporting_docs/      # Methodology reference papers and slides
│   ├── supporting_papers/
│   └── supporting_slides/
└── templates/                   # Session log, quality report templates
```

---

## Commands

```bash
# Run R replication script
Rscript replications/[PaperName]/R/replicate.R

# Run Python replication script
python replications/[PaperName]/python/replicate.py

# Quality score
python scripts/quality_score.py replications/[PaperName]/R/replicate.R
```

---

## Quality Thresholds

| Score | Gate | Meaning |
|-------|------|---------|
| 80 | Commit | Good enough to save |
| 90 | PR | Ready for deployment |
| 95 | Excellence | Aspirational |

---

## Skills Quick Reference

| Command | What It Does |
|---------|-------------|
| `/replicate-paper [paper.pdf] [data]` | Full 6-phase replication pipeline |
| `/data-analysis [dataset]` | End-to-end R analysis |
| `/review-r [file]` | R code quality review |
| `/review-paper [file]` | Manuscript review |
| `/lit-review [topic]` | Literature search + synthesis |
| `/research-ideation [topic]` | Research questions + strategies |
| `/interview-me [topic]` | Interactive research interview |
| `/commit [msg]` | Stage, commit, PR, merge |
| `/proofread [file]` | Grammar/typo review of reports |
| `/devils-advocate [topic]` | Challenge design decisions |

---

## Active Replications

| Paper | Status | Targets | Pass | Fail | Notes |
|-------|--------|---------|------|------|-------|
| Gracner et al. (2024) | IN PROGRESS | — | — | — | Sugar tax, UKB |

---

## UKB Data Notes

- **Data location:** `data/` (gitignored — sensitive)
- **Application ID:** [YOUR UKB APPLICATION ID]
- **Withdrawal list:** Always apply latest withdrawal list before any analysis
- **Field IDs:** Verify all field IDs against UKB Data Showcase; note instance (baseline vs. repeat)
- **ICD codes:** Map ICD-9 (pre-2016 HES) and ICD-10 (post-2016) per paper's Supplementary Table

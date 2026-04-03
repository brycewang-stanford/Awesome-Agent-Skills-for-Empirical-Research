---
description: Social science research plugin — 5-step workflow, available skills, agents, quality thresholds, and hooks. Loaded in every session.
paths: ["**/*"]
---

# Social Science Research Plugin

## The 5-Step Research Workflow

| Step | What You're Doing | Skill(s) | Output Location |
|------|------------------|----------|-----------------|
| 0. Setup | Configure field, journals, datasets, R colors | `/research-setup` | `references/domain-profile.md`, `CLAUDE.md` |
| 1. Idea | Interview → ideation → unified spec | `/new-project` | `quality_reports/project_spec_*.md` |
| 2a. Lit Review | Parallel journal + repo + citation search | `/lit-review` → `/validate-bib` | `quality_reports/lit_review_*.md` |
| 2b. Data | Find + assess datasets for the RQ | `/data-finder` | `quality_reports/data_exploration_*.md` |
| 3. Analysis | Run R or Python analysis | `/data-analysis` → `/review-r` | `output/tables/`, `output/figures/` |
| 4. Write | Draft and review the paper | `/write-paper` → `/review-paper` | `manuscripts/[name]-draft.tex` |
| 5. Quality Gate | Verify analysis ↔ paper match | `/quality-gate` → `/proofread` | `quality_reports/quality_gate_*.md` |

---

## Core Principles

- **Plan first** — enter plan mode before non-trivial tasks; save plans to `quality_reports/plans/`
- **Verify after** — run code and confirm outputs at the end of every task
- **Quality gates** — nothing ships below 80/100

---

## Skills

| Skill | Step | What It Does |
|-------|------|-------------|
| `/research-setup` | 0 | Interactive wizard — configures field, journals, datasets, institutional colors, and `CLAUDE.md` |
| `/new-project [topic]` | 1 | Structured interview → 3-5 research questions with identification strategies → unified project spec |
| `/lit-review [topic]` | 2a | Parallel Librarian fleet: top journals + NBER/SSRN/IZA + citation chains |
| `/validate-bib` | 2a, 5 | Cross-reference all citations against the bibliography |
| `/data-finder [topic]` | 2b | Find and assess datasets: parallel Explorer agents + Explorer-Critic critique |
| `/data-analysis [dataset]` | 3 | End-to-end R or Python analysis: load → explore → analyze → output |
| `/review-r [file\|all]` | 3 | R code quality review — reproducibility, style, domain correctness |
| `/write-paper [title]` | 4 | Draft paper manuscript from analysis outputs |
| `/review-paper [file]` | 4 | Top-journal-style manuscript review — 6 dimensions |
| `/quality-gate [file]` | 5 | Verify every paper claim is traceable to an output file |
| `/proofread [file\|all]` | 5 | Grammar, typos, layout, and consistency review |
| `/deep-audit` | — | Repository-wide infrastructure consistency audit |

---

## Agents

| Agent | Role | Invoke When |
|-------|------|-------------|
| `librarian` | Searches one literature angle (journals, repos, citation chain) | Dispatched in parallel by `/lit-review` |
| `explorer` | Finds candidate datasets across source categories | Dispatched in parallel pairs by `/data-finder` |
| `explorer-critic` | Applies 5-point methodology critique to candidate datasets | Dispatched by `/data-finder` after explorers complete |
| `proofreader` | Grammar, typos, layout issues, citation format | After drafting paper sections |
| `domain-reviewer` | Substantive correctness — math, assumptions, derivations, citations | Dispatched by `/write-paper` and `/review-paper` for substance review |
| `r-reviewer` | R code quality, reproducibility, figure standards | After writing or modifying R scripts |
| `verifier` | Scripts run cleanly, outputs exist, bibliography consistent | Dispatched by `/quality-gate` for claim verification |

---

## Quality Gates

| Score | Gate | Meaning |
|-------|------|---------|
| 80 | Commit | Good enough to save |
| 90 | PR | Ready for deployment |
| 95 | Excellence | Aspirational |

**Key deductions:** script failure −100, claimed result absent from output −50, domain bug −30, missing citation −15, broken table/figure ref −5.

---

## Hooks (Active Automatically)

| Hook | Trigger | What It Does |
|------|---------|-------------|
| `setup-project-dirs.sh` | Every session start | Creates `quality_reports/` subdirs and copies templates into project (no-clobber) |
| `protect-files.sh` | Edit/Write | Blocks edits to protected files (e.g. `Bibliography_base.bib`) |
| `pre-compact.py` | Before context compaction | Saves active plan and recent decisions |
| `post-compact-restore.py` | Session resume after compaction | Restores saved context to avoid losing plan state |

---

## Recommended Project Structure

```
your-project/
├── CLAUDE.md                    # Project context (name, author, current state)
├── Bibliography_base.bib        # Centralized bibliography (protected)
├── data/                        # Raw data files
├── scripts/
│   ├── R/                       # R analysis scripts
│   └── python/                  # Python analysis scripts
├── notebooks/                   # Jupyter notebooks
├── output/
│   ├── tables/                  # Generated .tex and .html tables
│   └── figures/                 # Generated .pdf and .png figures
├── manuscripts/                 # Paper drafts (.tex, .qmd)
├── quality_reports/             # Plans, session logs, review reports
│   ├── plans/
│   ├── session_logs/
│   ├── specs/
│   └── merges/
└── references/
    ├── domain-profile.md        # Field, journals, datasets, key researchers
    └── papers/                  # Reference papers and PDFs
```

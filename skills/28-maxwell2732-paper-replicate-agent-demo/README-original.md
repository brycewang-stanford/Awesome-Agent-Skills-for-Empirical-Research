[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.18723722.svg)](https://doi.org/10.5281/zenodo.18723722)

# UKB Empirical Replication Agent

A structured Claude Code workflow for **empirically replicating published research** using UK Biobank (UKB) data, created by 朱晨 | 遗传社科研究. Special thanks to Pedro H. C. Sant'Anna for the claude-code-my-workflow repository, which inspired this workflow. You describe a paper; Claude plans the replication approach, writes R/Python scripts, validates outputs against published targets, documents discrepancies, and reports results — like a research contractor who handles the full pipeline.

---

## Quick Start

### 1. Clone & Set Up

```bash
git clone https://github.com/YOUR_USERNAME/paper-replicate-agent-demo.git
cd paper-replicate-agent-demo
```

### 2. Start Claude Code

```bash
claude
```

### 3. Describe Your Task

Paste a prompt like:

> I want to replicate [Paper Author (Year)]. The PDF is in `papers/[PaperName]/`. The relevant UKB data is in `data/`. Please enter plan mode, read the paper, identify all empirical targets, and plan the replication.

**What this does:** Claude reads the configuration files and paper, inventories the available data, identifies every table and figure to replicate, enters plan mode, drafts a step-by-step plan, waits for your approval, then implements — running scripts, verifying outputs against tolerance thresholds, and saving a validation report.

---

## How It Works

### Contractor Mode

You describe a task. For complex or ambiguous requests, Claude first creates a requirements specification with MUST/SHOULD/MAY priorities. You approve the spec, then Claude plans, implements, verifies, scores against quality gates, and presents a summary. Say "just do it" and it auto-commits when the work meets quality standards.

### Replication Pipeline (6 Phases)

| Phase | What Happens |
|-------|-------------|
| **0. Paper Intake** | Read paper; record all empirical targets in `quality_reports/[paper]_replication_targets.md` |
| **1. Inventory & Data Audit** | Verify data matches paper's described sample (N, events, key variables) |
| **2. Translate & Execute** | Write R/Python scripts; match original specification exactly |
| **3. Verify Match** | Check outputs against targets within tolerance thresholds |
| **4. Document Discrepancies** | Investigate every near-miss; document explanations |
| **5. Report** | Save `replications/[paper]/validation_report.md` and polished `reports/[paper]_replication_report.md` |

### Specialized Agents

| Agent | What It Does |
|-------|-------------|
| `domain-reviewer` | Senior epidemiology referee (NEJM/Lancet/IJE standard) — checks causal assumptions, methods, code-theory alignment |
| `r-reviewer` | R code quality, reproducibility, and UKB-specific correctness |
| `proofreader` | Grammar, typos, consistency in reports |
| `verifier` | End-to-end task completion verification |

### Quality Gates

Every script and report gets a score (0–100). Scores below threshold block the action:
- **80** — commit threshold
- **90** — PR threshold
- **95** — excellence (aspirational)

### Tolerance Thresholds

| Quantity | Tolerance |
|----------|-----------|
| Sample sizes (N, events) | Exact match |
| Point estimates (HR, OR, β) | ±0.01 |
| Standard errors | ±0.05 |
| P-values | Same significance bracket |
| Percentages | ±0.1pp |

---

## What's Included

<details>
<summary><strong>4 agents, 10 skills, 13 rules, 4 hooks</strong> (click to expand)</summary>

### Agents (`.claude/agents/`)

| Agent | What It Does |
|-------|-------------|
| `domain-reviewer` | Epidemiology substance review (causal assumptions, methods, UKB specifics) |
| `r-reviewer` | R code quality, reproducibility, and domain correctness |
| `proofreader` | Grammar, typos, overflow, consistency review |
| `verifier` | End-to-end task completion verification |

### Skills (`.claude/skills/`)

| Skill | What It Does |
|-------|-------------|
| `/replicate-paper` | Full 6-phase replication pipeline |
| `/data-analysis` | End-to-end R analysis with publication-ready output |
| `/review-r` | Launch R code reviewer |
| `/proofread` | Launch proofreader on a file |
| `/review-paper` | Manuscript review: structure, epidemiology, referee objections |
| `/lit-review` | Literature search, synthesis, and gap identification |
| `/research-ideation` | Generate research questions and empirical strategies |
| `/interview-me` | Interactive interview to formalize a research idea |
| `/devils-advocate` | Challenge design decisions before committing |
| `/commit` | Stage, commit, create PR, and merge to main |

### Rules (`.claude/rules/`)

**Always-on** (load every session):

| Rule | What It Enforces |
|------|-----------------|
| `plan-first-workflow` | Plan mode for non-trivial tasks + context preservation |
| `orchestrator-protocol` | Contractor mode: implement → verify → review → fix → score |
| `session-logging` | Three logging triggers: post-plan, incremental, end-of-session |

**Path-scoped** (load only when working on matching files):

| Rule | Triggers On | What It Enforces |
|------|------------|-----------------|
| `replication-protocol` | `replications/**`, `scripts/**` | 6-phase replication + Stata→R/Python pitfalls |
| `quality-gates` | `*.R`, `*.py`, `reports/**` | 80/90/95 scoring + tolerance thresholds |
| `r-code-conventions` | `*.R` | R coding standards, reproducibility, UKB pitfalls |
| `python-code-conventions` | `*.py` | Python scientific coding standards |
| `orchestrator-research` | `*.R`, `explorations/**` | Simplified orchestrator for research (no multi-round reviews) |
| `verification-protocol` | `replications/**`, `reports/**` | Replication task completion checklist |
| `pdf-processing` | `master_supporting_docs/` | Safe large PDF handling |
| `proofreading-protocol` | `*.md`, `quality_reports/**` | Propose-first, then apply with approval |
| `knowledge-base-template` | `*.R`, `*.py`, `replications/**` | UKB field registry, estimand registry, pitfalls |
| `exploration-folder-protocol` | `explorations/` | Structured sandbox for experimental work |
| `exploration-fast-track` | `explorations/` | Lightweight exploration workflow (60/100 threshold) |

### Templates (`templates/`)

| Template | What It Does |
|----------|-------------|
| `session-log.md` | Structured session logging format |
| `quality-report.md` | Merge-time quality report format |
| `exploration-readme.md` | Exploration project README template |
| `archive-readme.md` | Archive documentation template |
| `requirements-spec.md` | MUST/SHOULD/MAY requirements framework |
| `constitutional-governance.md` | Non-negotiable principles vs. preferences |
| `skill-template.md` | Skill creation template |

</details>

---

## Prerequisites

| Tool | Required For | Install |
|------|-------------|---------|
| [Claude Code](https://docs.anthropic.com/en/docs/claude-code/overview) | Everything | `npm install -g @anthropic-ai/claude-code` |
| R (≥ 4.2) | Replication scripts | [r-project.org](https://www.r-project.org/) |
| Python (≥ 3.10) | Python replication scripts | [python.org](https://www.python.org/) |
| [gh CLI](https://cli.github.com/) | PR workflow | `winget install GitHub.cli` (Windows) |

---

## Data Setup

Create a `data/` directory at the project root and place approved datasets there.

The `data/` folder is intentionally excluded from version control.

1. Place your UKB data extract in `data/` (gitignored — never commit)
2. Apply the latest participant withdrawal list before any analysis
3. Update your UKB Application ID in `CLAUDE.md`
4. Verify field IDs against the [UKB Data Showcase](https://biobank.ndph.ox.ac.uk/showcase/)

---

## Folder Structure

```
my-ukb-agent/
├── papers/           # PDFs + original replication packages
├── data/             # UKB data (gitignored)
├── replications/     # Our R/Python replication scripts + outputs
├── reports/          # Polished final reports
├── quality_reports/  # Plans, specs, session logs, replication targets
├── explorations/     # Sandbox for experimental analyses
├── master_supporting_docs/  # Reference papers and methods docs
└── scripts/          # Utility scripts and shared R functions
```

---

## License

MIT License. Use freely for research.

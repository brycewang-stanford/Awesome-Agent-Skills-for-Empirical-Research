# Social Science Research

> **Work in Progress.** This plugin is still under active development by a university student. For now, it is an experiment on the utility of Claude Code for social science research. If you have any feedback or suggestions, reach me on X at [@felpix_](https://x.com/felpix_).

A Claude Code plugin based on [Pedro Sant'Anna's Claude Code workflow](https://github.com/pedrohcgs/claude-code-my-workflow) designed for producing social science research.

## Quick Start

### 1. Install

Use Claude Code to install the plugin in your project directory.

```bash
/plugin marketplace add Felpix-Studios/social-science-research
```

```
/plugin install social-science-research@felpix-research
```

> **Why project scope?** The plugin creates `quality_reports/`, `templates/`, `references/`, and `manuscripts/` directories on every session start. Installing at user (global) scope would scaffold those folders in every project you open — including non-research repos. Project scope keeps everything contained to the repo you're working in.

### 2. Restart Claude Code

In your project directory, on first launch, the plugin will automatically:

- Create project directories: `quality_reports/`, `references/papers/`, `manuscripts/`, `output/`, `scripts/`
- Copy `references/domain-profile.md` into your project (your field's journals, datasets, and key researchers)
- Copy starter templates into `templates/` (session log, requirements spec, quality report formats)
- Create `CLAUDE.md` with project identity placeholders (name, author, institution)

### 3. Run `/research-setup`

Configure your field, institution, journals, datasets, key researchers, and institutional colors. This writes your domain profile and customizes R figure themes to match your institution's visual identity.

Enjoy using the plugin!

## Prerequisites

| Tool | Required For | Install |
|------|-------------|---------|
| Claude Code (with plugin support) | Everything | [claude.ai/download](https://claude.ai/download) |
| R (>= 4.0) | `/data-analysis` (R track), `/review-r` | [r-project.org](https://www.r-project.org/) |
| Python (>= 3.9) | `/data-analysis` (Python track), compact hooks | [python.org](https://www.python.org/) |
| LaTeX distribution | `/write-paper` with `.tex` output | [tug.org/texlive](https://tug.org/texlive/) |

## How It Works

| Step | What You Do | Skill(s) | Output |
|------|-------------|----------|--------|
| 0. Setup | Configure field, journals, datasets, R colors | `/research-setup` | `references/domain-profile.md`, `CLAUDE.md` |
| 1. Idea | Interview → ideation → unified project spec | `/new-project` | `quality_reports/project_spec_*.md` |
| 2a. Literature | Parallel journal + working paper + citation search | `/lit-review` then `/validate-bib` | `quality_reports/lit_review_*.md` |
| 2b. Data | Find and assess datasets for the research question | `/data-finder` | `quality_reports/data_exploration_*.md` |
| 3. Analysis | Run R or Python analysis, review code quality | `/data-analysis` then `/review-r` | `output/tables/`, `output/figures/`, `scripts/` |
| 4. Write | Draft and review the manuscript | `/write-paper` then `/review-paper` | `manuscripts/[name]-draft.tex` |
| 5. Verify | Check analysis-paper consistency, proofread | `/quality-gate` then `/proofread` | `quality_reports/quality_gate_*.md` |

## What's Included

<details>
<summary><strong>7 agents, 12 skills, 8 rules, 4 hooks</strong> (click to expand)</summary>

### Agents

| Agent | What It Does |
|-------|-------------|
| `librarian` | Search one literature angle and return BibTeX |
| `explorer` | Find datasets across one source category |
| `explorer-critic` | Stress-test dataset candidates on 5 dimensions |
| `proofreader` | Grammar, typos, layout, and consistency check |
| `domain-reviewer` | Top-journal referee review through 5 lenses |
| `r-reviewer` | R code quality and reproducibility review |
| `verifier` | Trace paper claims to output files |

### Skills

| Skill | What It Does |
|-------|-------------|
| `/research-setup` | Configure field, institution, journals, datasets, and colors |
| `/new-project` | Interactive interview to formalize a research idea |
| `/lit-review` | Literature search, synthesis, and gap identification |
| `/validate-bib` | Cross-reference citations against bibliography |
| `/data-finder` | Find and rank datasets for a research question |
| `/data-analysis` | End-to-end R or Python analysis with publication-ready output |
| `/review-r` | Launch R code reviewer on scripts |
| `/write-paper` | Draft manuscript from analysis outputs |
| `/review-paper` | Manuscript review: structure, econometrics, referee objections |
| `/quality-gate` | Verify every paper claim traces to an output file |
| `/proofread` | Launch proofreader on a file |
| `/deep-audit` | Repository-wide consistency audit |

### Rules

| Rule | What It Does |
|------|-------------|
| `workflow-overview.md` | Master orientation: workflow, skills, agents, thresholds |
| `plan-first-workflow.md` | Plan mode before non-trivial tasks; session logs |
| `orchestrator-protocol.md` | Autonomous execution loop (Code vs Prose track) |
| `r-code-conventions.md` | R coding standards and visual identity |
| `quality-gates.md` | 0-100 scoring rubric with deduction tables |
| `proofreading-protocol.md` | Three-phase review: propose, approve, apply |
| `analysis-verification.md` | Run scripts and verify outputs after writing code |
| `replication-protocol.md` | Replicate original results before extending |

### Hooks

| Hook | What It Does |
|------|-------------|
| `setup-project-dirs.sh` | Create project scaffold and copy templates on session start |
| `protect-files.sh` | Block edits to protected files |
| `pre-compact.py` | Save plan state and decisions before compaction |
| `post-compact-restore.py` | Restore context after compaction |

</details>

## License

MIT License. See [LICENSE](LICENSE).

# The Clo-Author: AI Research Architecture for Empirical Social Science

[![Version](https://img.shields.io/github/v/release/hugosantanna/clo-author?style=flat-square&color=b44dff&label=version)](CHANGELOG.md)

> **Work in progress.** This repo is evolving as I learn, and I share it in case others find it useful and would like to build upon it. Expect rough edges.

An open-source [Claude Code](https://docs.anthropic.com/en/docs/claude-code) architecture that turns your terminal into a research assistant for empirical social science — economics, finance, marketing, management, accounting, and public policy. From literature review to journal submission.

**Live guide:** [hugosantanna.github.io/clo-author](https://hugosantanna.github.io/clo-author/)
<br>**Built on:** [Pedro Sant'Anna's claude-code-my-workflow](https://github.com/pedrohcgs/claude-code-my-workflow)

---

## Quick Start

```bash
# 1. Fork and clone
gh repo fork hugosantanna/clo-author --clone
cd clo-author

# 2. Open Claude Code
claude
```

Then paste this prompt:

> I am starting a new empirical research project in **[YOUR FIELD]** on **[YOUR TOPIC]**.
> Read CLAUDE.md and help me set up the project structure.
> Start with a literature review on [YOUR TOPIC].

Claude reads the configuration, fills in your project details, and works autonomously — planning, implementing, reviewing, and verifying.

**Using VS Code?** Open the Claude Code panel instead. Everything works the same.

---

## What It Does

### Contractor Mode

You describe a task. Claude plans the approach, implements it, runs specialized review agents, fixes issues, re-verifies, and scores against quality gates — all autonomously. You approve the plan and see a summary when the work meets quality standards.

### Specialized Agents in Worker-Critic Pairs

Every creator has a paired critic. Critics can't edit files; creators can't score themselves.

| Phase | Worker (Creates) | Critic (Reviews) |
|-------|-----------------|-----------------|
| Discovery | Librarian | librarian-critic |
| Discovery | Explorer | explorer-critic |
| Strategy | Strategist | strategist-critic |
| Execution | Coder | coder-critic |
| Execution | Data-engineer | coder-critic |
| Paper | Writer | writer-critic |
| Peer Review | Editor → domain-referee + methods-referee | — |
| Presentation | Storyteller | storyteller-critic |
| Infrastructure | Orchestrator, Verifier | — |

### Realistic Peer Review Simulation

`/review --peer [journal]` simulates a full journal submission:

1. **Editor desk review** — reads your paper, verifies novelty claims via web search, decides: desk reject or send to referees
2. **Referee assignment** — editor selects two referees with intellectual dispositions (Structuralist, Credibility, Measurement, Policy, Theory, Skeptic) weighted by journal culture
3. **Independent blind reports** — each referee scores on 5 dimensions with pet peeves (1 critical, 1 constructive), and every major comment includes "what would change my mind"
4. **Editorial decision** — editor classifies each concern as FATAL / ADDRESSABLE / TASTE, sides with one referee when they disagree, produces MUST / SHOULD / MAY action items

Additional modes:
- `--stress [journal]` — adversarial referees for pre-submission battle testing
- `--peer --r2 [journal]` — R&R second round with referee memory (checks whether prior concerns were addressed)
- Max 3 rounds, then the editor's patience runs out — just like real life

**30 journal profiles** across economics, finance, accounting, marketing, and management (all top-tier, A* in the Australian Business Deans Council ranking), each with calibrated referee pools.

### 10 Slash Commands

| Category | Commands |
|----------|----------|
| **Research** | `/new-project`, `/discover`, `/strategize`, `/analyze`, `/write` |
| **Review** | `/review`, `/revise` |
| **Output** | `/talk`, `/submit` |
| **Tools** | `/tools` (commit, compile, validate-bib, journal, learn, deploy, context) |

### Quality Gates

Weighted aggregate scoring with per-component minimums:

| Score | Gate | Applies To |
|-------|------|------------|
| 80 | Commit | Weighted aggregate (blocking) |
| 90 | PR | Weighted aggregate (blocking) |
| 95 | Submission | Aggregate + all components >= 80 |
| -- | Advisory | Talks (reported, non-blocking) |

---

## Project Structure

```
your-project/
├── CLAUDE.md                    # Project configuration (fill in placeholders)
├── .claude/                     # Agents, skills, rules, references, hooks
├── Bibliography_base.bib        # Centralized bibliography
├── paper/                       # Main LaTeX manuscript (source of truth)
│   ├── main.tex
│   ├── sections/
│   ├── figures/
│   ├── tables/
│   ├── talks/                   # Beamer presentations
│   ├── quarto/                  # Quarto RevealJS presentations
│   ├── preambles/               # Shared LaTeX headers
│   ├── supplementary/           # Online appendix
│   └── replication/             # Replication package for deposit
├── data/                        # Raw and cleaned datasets
├── scripts/                     # Analysis code (R, Stata, Python, Julia)
├── quality_reports/             # Plans, session logs, reviews, scores
├── explorations/                # Research sandbox
└── master_supporting_docs/      # Reference papers and data docs
```

---

## Prerequisites

| Tool | Required For | Install |
|------|-------------|---------|
| [Claude Code](https://docs.anthropic.com/en/docs/claude-code) | Everything | `npm install -g @anthropic-ai/claude-code` |
| XeLaTeX | Paper compilation | [TeX Live](https://tug.org/texlive/) or [MacTeX](https://tug.org/mactex/) |
| R | Analysis & figures | [r-project.org](https://www.r-project.org/) |
| [gh CLI](https://cli.github.com/) | GitHub integration | `brew install gh` (macOS) |

Optional: Stata, Python, Julia (for multi-language analysis), [Quarto](https://quarto.org) (web slides).

---

## Adapting for Your Field

1. **Fill in `CLAUDE.md`** — replace `[BRACKETED PLACEHOLDERS]` with your project details
2. **Fill in the domain profile** (`.claude/references/domain-profile.md`) — your field's journals, data sources, identification strategies, conventions, and seminal references. Use `/discover interview` to populate it interactively.
3. **Add journal profiles** — 30 profiles are included. Add your own to `.claude/references/journal-profiles.md` using the template at the bottom of the file.
4. **Configure your language** — R is the default; Stata, Python, and Julia are also supported. Set your preference in CLAUDE.md.

---

## Origin

This project builds on [Pedro Sant'Anna's claude-code-my-workflow](https://github.com/pedrohcgs/claude-code-my-workflow), which was built for Econ 730 at Emory University. The Clo-Author reorients that infrastructure from lecture production to empirical research publication, and expands the scope from economics to all empirical social science.

Maintained by [Hugo Sant'Anna](https://hsantanna.org) at UAB.

---

## Upgrading from 2.x

Your files are safe. The upgrade only touches `.claude/` (infrastructure). Your paper, scripts, data, and bibliography are never modified.

1. **Download** the [latest release](https://github.com/hugosantanna/clo-author/releases) or clone clo-author 3.0 into a temp folder
2. **Delete** your old `.claude/` directory
3. **Copy** the new `.claude/` into your project
4. **Done** — your CLAUDE.md, paper, scripts, and data are untouched

No git merge, no upstream remote, no conflicts. Once on 3.0, future upgrades can use `/tools upgrade`.

---

## Context Efficiency

The 3.0 architecture loads 71% fewer tokens per session compared to 2.x. Reference files (journal profiles, domain profiles) load on demand — only when agents need them. Rules are path-scoped where possible. You get more done with less context consumed.

---

## License

MIT License. Fork it, customize it, make it yours.

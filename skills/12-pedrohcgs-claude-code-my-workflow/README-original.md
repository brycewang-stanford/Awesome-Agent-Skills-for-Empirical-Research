# My Claude Code Setup

> **Work in progress.** This is not meant to be a polished guide for everyone. It's mostly a summary of how I've been using Claude Code for academic work — slides, papers, data analysis, and more. I keep learning new things, and as I do, I keep updating these files. This is just a way for me to share what I've figured out with friends and colleagues.

**Live site:** [psantanna.com/claude-code-my-workflow](https://psantanna.com/claude-code-my-workflow/)
**Last Updated:** 2026-03-20

A ready-to-fork foundation for AI-assisted academic work. You describe what you want — lecture slides, a research paper, a data analysis, a replication package — and Claude plans the approach, runs specialized agents, fixes issues, verifies quality, and presents results. Like a contractor who handles the entire job. Extracted from a production PhD course and extended by a growing [community](#community--extensions).

---

## Quick Start (5 minutes)

### 1. Fork & Clone

```bash
# Fork this repo on GitHub (click "Fork" on the repo page), then:
git clone https://github.com/YOUR_USERNAME/claude-code-my-workflow.git my-project
cd my-project
```

Replace `YOUR_USERNAME` with your GitHub username.

### 2. Start Claude Code and Paste This Prompt

```bash
claude
```

**Using VS Code?** Open the Claude Code panel instead. Everything works the same — see the [full guide](https://psantanna.com/claude-code-my-workflow/workflow-guide.html#sec-setup) for details.

Then paste the [starter prompt](https://psantanna.com/claude-code-my-workflow/workflow-guide.html#sec-first-session) from the guide, filling in your project details:

> I am starting to work on **[PROJECT NAME]** in this repo. **[Describe your project in 2–3 sentences.]** I've set up the Claude Code academic workflow... Please read the configuration files and adapt them for my project. Enter plan mode and start.

The [full guide](https://psantanna.com/claude-code-my-workflow/workflow-guide.html#sec-first-session) has the complete starter prompt with all the details.

**What this does:** Claude reads all the configuration files, fills in your project name, institution, and preferences, then enters contractor mode — planning, implementing, reviewing, and verifying autonomously. You approve the plan and Claude handles the rest.

---

## How It Works

### Contractor Mode

You describe a task. For complex or ambiguous requests, Claude first creates a requirements specification with MUST/SHOULD/MAY priorities and clarity status (CLEAR/ASSUMED/BLOCKED). You approve the spec, then Claude plans the approach, implements it, runs specialized review agents, fixes issues, re-verifies, and scores against quality gates — all autonomously. You see a summary when the work meets quality standards. Say "just do it" and it auto-commits too.

### Specialized Agents

Instead of one general-purpose reviewer, 10 focused agents each check one dimension:

- **proofreader** — grammar/typos
- **slide-auditor** — visual layout
- **pedagogy-reviewer** — teaching quality
- **r-reviewer** — R code quality
- **domain-reviewer** — field-specific correctness (template — customize for your field)

Each is better at its narrow task than a generalist would be. The `/slide-excellence` skill runs them all in parallel. The same pattern extends to any academic artifact — manuscripts, data pipelines, proposals.

### Adversarial QA

Two agents work in opposition: the **critic** reads both Beamer and Quarto and produces harsh findings. The **fixer** implements exactly what the critic found. They loop until the critic says "APPROVED" (or 5 rounds max). This catches errors that single-pass review misses.

### Quality Gates

Every file gets a score (0–100). Scores below threshold block the action:
- **80** — commit threshold
- **90** — PR threshold
- **95** — excellence (aspirational)

### Context Survival

Plans, specifications, and session logs survive auto-compression and session boundaries. The PreCompact hook saves a context snapshot before Claude's auto-compression triggers, ensuring critical decisions are never lost. MEMORY.md accumulates learning across sessions, so patterns discovered in one session inform future work.

---

## The Guide

For a comprehensive walkthrough, read the **[full guide](https://psantanna.com/claude-code-my-workflow/workflow-guide.html)** (or see the [source](guide/workflow-guide.qmd)).

It covers:
1. **Why This Workflow Exists** — the problem and the vision
2. **Getting Started** — fork, paste one prompt, and Claude sets up the rest
3. **The System in Action** — specialized agents, adversarial QA, quality scoring
4. **The Building Blocks** — CLAUDE.md, rules, skills, agents, hooks, memory
5. **Workflow Patterns** — slides, research, reproducibility, presentation rhetoric, sequential adversarial audits, and more
6. **The Ecosystem** — extensions by clo-author, claudeblattman, MixtapeTools, autoresearch, ClaudeCodeTools, and a growing community
7. **Customizing for Your Domain** — creating your own reviewers and knowledge bases

### 2026 Features

The guide covers Claude Code's latest capabilities:

- **Effort levels** — `/effort` command for cost vs. thoroughness tradeoffs (low/medium/high/max)
- **Skill frontmatter** — `effort`, `context: fork`, `agent`, `hooks`, and dynamic content (`$ARGUMENTS`, `!command` syntax)
- **Permission modes** — Normal, Auto-accept, Plan, Bypass for different workflows
- **Hook handler types** — command, prompt, and HTTP handlers with 20+ hook events
- **Advanced agent configuration** — model, maxTurns, isolation, tool restrictions
- **Built-in skills** — `/batch` for parallel refactoring, `/simplify` for code review, `/remote-control` for browser bridge
- **Plugins** — `/discover-plugins` for third-party extensions

---

## Use Cases

| Academic Task | How This Workflow Helps |
|---------------|----------------------|
| Lecture slides (Beamer/Quarto) | Full creation, translation, multi-agent review, deployment |
| Research papers | Literature review, manuscript review, simulated peer review |
| Data analysis | End-to-end R pipelines, replication verification, publication-ready output |
| Replication packages | AEA-compliant packaging, reproducibility audit trails |
| Presentations | Rhetoric of decks principles, visual audit, cognitive load review |
| Research proposals | Structured drafting with adversarial critique |

---

## What's Included

<details>
<summary><strong>10 agents, 22 skills, 18 rules, 7 hooks</strong> (click to expand)</summary>

### Agents (`.claude/agents/`)

| Agent | What It Does |
|-------|-------------|
| `proofreader` | Grammar, typos, overflow, consistency review |
| `slide-auditor` | Visual layout audit (overflow, font consistency, spacing) |
| `pedagogy-reviewer` | 13-pattern pedagogical review (narrative arc, notation density, pacing) |
| `r-reviewer` | R code quality, reproducibility, and domain correctness |
| `tikz-reviewer` | Merciless TikZ diagram visual critique |
| `beamer-translator` | Beamer-to-Quarto translation specialist |
| `quarto-critic` | Adversarial QA comparing Quarto against Beamer benchmark |
| `quarto-fixer` | Implements fixes from the critic agent |
| `verifier` | End-to-end task completion verification |
| `domain-reviewer` | **Template** for your field-specific substance reviewer |

### Skills (`.claude/skills/`)

| Skill | What It Does |
|-------|-------------|
| `/compile-latex` | 3-pass XeLaTeX compilation with bibtex |
| `/deploy` | Render Quarto + sync to GitHub Pages |
| `/extract-tikz` | TikZ diagrams to PDF to SVG pipeline |
| `/proofread` | Launch proofreader on a file |
| `/visual-audit` | Launch slide-auditor on a file |
| `/pedagogy-review` | Launch pedagogy-reviewer on a file |
| `/review-r` | Launch R code reviewer |
| `/qa-quarto` | Adversarial critic-fixer loop (max 5 rounds) |
| `/slide-excellence` | Combined multi-agent review |
| `/translate-to-quarto` | Full 11-phase Beamer-to-Quarto translation |
| `/validate-bib` | Cross-reference citations against bibliography |
| `/devils-advocate` | Challenge design decisions before committing |
| `/create-lecture` | Full lecture creation workflow |
| `/commit` | Stage, commit, create PR, and merge to main |
| `/lit-review` | Literature search, synthesis, and gap identification |
| `/research-ideation` | Generate research questions and empirical strategies |
| `/interview-me` | Interactive interview to formalize a research idea |
| `/review-paper` | Manuscript review: structure, econometrics, referee objections |
| `/data-analysis` | End-to-end R analysis with publication-ready output |
| `/learn` | Extract non-obvious discoveries into persistent skills |
| `/context-status` | Show session health and context usage |
| `/deep-audit` | Repository-wide consistency audit |

### Research Workflow

| Feature | What It Does |
|---------|-------------|
| Exploration folder | Structured `explorations/` sandbox with graduate/archive lifecycle |
| Fast-track workflow | 60/100 quality threshold for rapid prototyping |
| Simplified orchestrator | implement → verify → score → done (no multi-round reviews) |
| Enhanced session logging | Structured tables for changes, decisions, verification |
| Merge-only reporting | Quality reports at merge time only |
| Math line-length exception | Long lines acceptable for documented formulas |
| Workflow quick reference | One-page cheat sheet at `.claude/WORKFLOW_QUICK_REF.md` |

### Rules (`.claude/rules/`)

Rules use path-scoped loading: **always-on** rules load every session (~100 lines total); **path-scoped** rules load only when Claude works on matching files. Claude follows ~150 instructions reliably, so less is more.

**Always-on** (no `paths:` frontmatter — load every session):

| Rule | What It Enforces |
|------|-----------------|
| `plan-first-workflow` | Plan mode for non-trivial tasks + context preservation |
| `orchestrator-protocol` | Contractor mode: implement → verify → review → fix → score |
| `session-logging` | Three logging triggers: post-plan, incremental, end-of-session |
| `meta-governance` | Template vs. working project distinctions |

**Path-scoped** (load only when working on matching files):

| Rule | Triggers On | What It Enforces |
|------|------------|-----------------|
| `verification-protocol` | `.tex`, `.qmd`, `docs/` | Task completion checklist |
| `single-source-of-truth` | `Figures/`, `.tex`, `.qmd` | No content duplication; Beamer is authoritative |
| `quality-gates` | `.tex`, `.qmd`, `*.R` | 80/90/95 scoring + tolerance thresholds |
| `r-code-conventions` | `*.R` | R coding standards + math line-length exception |
| `tikz-visual-quality` | `.tex` | TikZ diagram visual standards |
| `beamer-quarto-sync` | `.tex`, `.qmd` | Auto-sync Beamer edits to Quarto |
| `pdf-processing` | `master_supporting_docs/` | Safe large PDF handling |
| `proofreading-protocol` | `.tex`, `.qmd`, `quality_reports/` | Propose-first, then apply with approval |
| `no-pause-beamer` | `.tex` | No overlay commands in Beamer |
| `replication-protocol` | `*.R` | Replicate original results before extending |
| `knowledge-base-template` | `.tex`, `.qmd`, `*.R` | Notation/application registry template |
| `orchestrator-research` | `*.R`, `explorations/` | Simple orchestrator for research (no multi-round reviews) |
| `exploration-folder-protocol` | `explorations/` | Structured sandbox for experimental work |
| `exploration-fast-track` | `explorations/` | Lightweight exploration workflow (60/100 threshold) |

### Templates (`templates/`)

| Template | What It Does |
|----------|-------------|
| `session-log.md` | Structured session logging format |
| `quality-report.md` | Merge-time quality report format |
| `exploration-readme.md` | Exploration project README template |
| `archive-readme.md` | Archive documentation template |
| `requirements-spec.md` | MUST/SHOULD/MAY requirements framework with clarity status |
| `constitutional-governance.md` | Template for defining non-negotiable principles vs. preferences |
| `skill-template.md` | Academic skill creation template with domain-specific examples |

</details>

---

## Prerequisites

| Tool | Required For | Install |
|------|-------------|---------|
| [Claude Code](https://code.claude.com/docs/en/overview) | Everything | `npm install -g @anthropic-ai/claude-code` |
| XeLaTeX | LaTeX compilation | [TeX Live](https://tug.org/texlive/) or [MacTeX](https://tug.org/mactex/) |
| [Quarto](https://quarto.org) | Web slides | [quarto.org/docs/get-started](https://quarto.org/docs/get-started/) |
| R | Figures & analysis | [r-project.org](https://www.r-project.org/) |
| pdf2svg | TikZ to SVG | `brew install pdf2svg` (macOS) |
| [gh CLI](https://cli.github.com/) | PR workflow | `brew install gh` (macOS) |

Not all tools are needed — install only what your project uses. Claude Code is the only hard requirement.

---

## Adapting for Your Field

1. **Fill in the knowledge base** (`.claude/rules/knowledge-base-template.md`) with your notation, applications, and design principles
2. **Customize the domain reviewer** (`.claude/agents/domain-reviewer.md`) with review lenses specific to your field
3. **Update the color palette** in your Quarto theme SCSS file — change the color variables at the top
4. **Add field-specific R pitfalls** to `.claude/rules/r-code-conventions.md`
5. **Fill in the lecture mapping** in `.claude/rules/beamer-quarto-sync.md`
6. **Customize the workflow quick reference** (`.claude/WORKFLOW_QUICK_REF.md`) with your non-negotiables and preferences
7. **Set up the exploration folder** (`explorations/`) for experimental work

---

## Additional Resources

- [Claude Code Documentation](https://code.claude.com/docs/en/overview)
- [Writing a Good CLAUDE.md](https://code.claude.com/docs/en/memory) — official guidance on project memory

---

## Origin

This infrastructure was extracted from **Econ 730: Causal Panel Data** at Emory University, developed by Pedro Sant'Anna using Claude Code over 6+ sessions. The course produced 6 complete PhD lecture decks with 800+ slides, interactive Quarto versions with plotly charts, and full R replication packages — all managed through this multi-agent workflow. The patterns are domain-agnostic: the same agents, rules, and orchestrator work for any academic project.

---

## Community & Extensions

As of March 2026, **15+ research groups** across economics, energy, political science, and engineering have forked and adapted this workflow. The infrastructure (orchestrator, hooks, quality gates) transfers without modification.

**Extended workflows:**

- **[clo-author](https://github.com/hsantanna88/clo-author)** by Hugo Sant'Anna (UAB) — Paper-centric research workflows with 17 specialized agents (6 worker-critic pairs plus referees, data-engineer, verifier), simulated blind peer review, AEA replication compliance, and full research lifecycle management
- **[claudeblattman](https://github.com/chrisblattman/claudeblattman)** by Chris Blattman (U Chicago) — Comprehensive guide for non-technical academics: executive assistant workflows, proposal writing, agent debates, and self-improving configuration
- **[MixtapeTools](https://github.com/scunning1975/MixtapeTools)** by Scott Cunningham (Baylor) — The Rhetoric of Decks: philosophy and practice of beautiful, rhetorically effective academic presentations
- **[autoresearch](https://github.com/karpathy/autoresearch)** by Andrej Karpathy — Constraint-based autonomous research with `program.md` as constitutional document
- **[ClaudeCodeTools](https://github.com/aspi6246/ClaudeCodeTools)** — "The Editor" persona: seven-audit sequential paper review protocol

See the [guide's ecosystem section](https://psantanna.com/claude-code-my-workflow/workflow-guide.html#sec-ecosystem) for detailed descriptions, design principles, and more resources.

---

## License

MIT License. See [LICENSE](LICENSE).

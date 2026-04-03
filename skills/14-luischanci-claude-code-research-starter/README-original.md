# Claude Code Research Starter Kit

A reusable Claude Code workflow for academic research projects in economics, econometrics, macroeconomics, and related fields. Designed for researchers who use **Julia**, **R**, **Stata**, and **LaTeX** for estimation, data analysis, and manuscript preparation.

**Author:** Luis Chanci

---

## What This Is

A ready-to-use folder structure with Claude Code configuration files (skills, agents, rules, hooks, and templates) tailored for **quantitative economics research**. Clone this repo into your new project and customize the placeholders to get a production-grade Claude Code setup immediately.

### What You Get

- **Contractor workflow:** You direct, Claude orchestrates autonomously (plan, execute, verify, report)
- **16 custom skills:** 12 workflow skills + 4 econometrics reference skills (Julia, R, Stata, causal inference)
- **4 specialized agents:** domain reviewer (substantive correctness), proofreader (grammar/notation), R code reviewer (code quality), verifier (compilation/execution)
- **14 rules:** quality gates, code conventions (R + Julia), verification protocols, exploration workflows, session logging
- **4 hooks:** file protection, desktop notifications, session log reminders, pre-compaction context snapshots
- **3 templates:** session logs, quality reports, exploration READMEs
- **Quality gate system:** 80 (commit) / 90 (PR) / 95 (excellence) scoring rubrics

---

## Quick Start

### 1. Clone or Copy

```bash
# Option A: Fork on GitHub, then clone your fork
git clone https://github.com/YOUR_USERNAME/claude-code-research-starter.git my-new-project
cd my-new-project
rm -rf .git
git init

# Option B: Copy into existing project
cp -r claude-code-research-starter/.claude/ /path/to/your/project/
cp claude-code-research-starter/CLAUDE.md /path/to/your/project/
cp claude-code-research-starter/MEMORY.md /path/to/your/project/
cp -r claude-code-research-starter/templates/ /path/to/your/project/
cp -r claude-code-research-starter/quality_reports/ /path/to/your/project/
cp -r claude-code-research-starter/explorations/ /path/to/your/project/
cp claude-code-research-starter/.gitignore /path/to/your/project/
```

### 2. Launch Claude Code and Paste the Starter Prompt

Open a terminal in your project directory and run `claude`. Then paste the following, filling in your project details:

> I am starting to work on **[PROJECT NAME]** in this repo. **[Describe your project in 2–3 sentences — what you're building, what data you use, what methods or tools (Julia, R, Stata, LaTeX) are involved.]**
>
> I want our collaboration to be structured, precise, and rigorous. When creating visuals, everything must be polished and publication-ready.
>
> I've set up the Claude Code Research Starter Kit (from `luischanci/claude-code-research-starter`). The configuration files are already in this repo. Please read them, understand the workflow, and then **update all configuration files to fit my project** — fill in placeholders in `CLAUDE.md`, adjust rules if needed, and propose any customizations specific to my use case.
>
> After that, use the plan-first workflow for all non-trivial tasks. Once I approve a plan, switch to contractor mode — coordinate everything autonomously and only come back to me when there's ambiguity or a decision to make.
>
> Enter plan mode and start by adapting the workflow configuration for this project.

**What this does:** Claude reads all the configuration files (`CLAUDE.md`, rules, agents, skills), fills in your project name, institution, and preferences, then enters contractor mode — planning, implementing, reviewing, and verifying autonomously. You approve the plan and Claude handles the rest.

**Prefer to configure manually?** Skip to step 3 below for detailed instructions on each file to customize.

### 3. Customize CLAUDE.md (Manual Alternative)

Open `CLAUDE.md` and fill in the placeholders marked with `[PLACEHOLDER]`:

- **Project title, authors, institution**
- **Folder structure** (adapt to your project's layout)
- **Commands** (your specific compilation/execution commands)
- **Model specifications** (your econometric models)
- **Key output files** (your specific outputs)

### 4. Customize Domain-Specific Files

1. **`.claude/agents/domain-reviewer.md`** -- Replace the review lenses with your field's concerns (e.g., identification strategy for causal inference, instrument validity for IV, etc.)

2. **`.claude/rules/knowledge-base-template.md`** -- Fill in your notation registry, symbol reference, and model specifications.

3. **`.claude/rules/r-code-conventions.md`** and **`.claude/rules/julia-code-conventions.md`** -- Adjust the visual palette, common pitfalls, and domain-specific conventions for your project.

### 5. Verify Hooks Work

The hooks are configured for **Windows (PowerShell)**. If you're on macOS/Linux, replace `.ps1` files with `.sh` equivalents and update `.claude/settings.json` accordingly. See the `hooks/` section below.

### 6. Start Working

```bash
claude  # Launch Claude Code in your project directory
```

Claude will automatically read `CLAUDE.md` and load the relevant rules, skills, and agents.

---

## Folder Structure

```
your-project/
├── CLAUDE.md                         # Project config (Claude reads every session)
├── MEMORY.md                         # Persistent learnings across sessions
├── .gitignore                        # Pre-configured for LaTeX/R/Julia/Python
├── .claude/                          # Claude Code configuration
│   ├── settings.json                 # Permissions + hooks
│   ├── settings.local.json           # Local overrides (gitignored)
│   ├── WORKFLOW_QUICK_REF.md         # One-page cheat sheet
│   ├── agents/                       # Specialized review agents
│   │   ├── domain-reviewer.md        # Substantive correctness review
│   │   ├── proofreader.md            # Grammar/notation/consistency
│   │   ├── r-reviewer.md             # R code quality review
│   │   └── verifier.md               # End-to-end verification
│   ├── skills/                       # Executable workflows (/command)
│   │   ├── compile-latex/SKILL.md    # LaTeX compilation
│   │   ├── proofread/SKILL.md        # Manuscript proofreading
│   │   ├── review-r/SKILL.md         # R code review
│   │   ├── review-julia/SKILL.md     # Julia code review
│   │   ├── review-paper/SKILL.md     # Referee-style paper review
│   │   ├── validate-bib/SKILL.md     # Bibliography validation
│   │   ├── devils-advocate/SKILL.md  # Challenge assumptions
│   │   ├── commit/SKILL.md           # Git workflow
│   │   ├── lit-review/SKILL.md       # Literature search
│   │   ├── research-ideation/SKILL.md # Research questions
│   │   ├── interview-me/SKILL.md     # Research interview
│   │   ├── data-analysis/SKILL.md    # End-to-end R analysis
│   │   ├── econometrics-julia/SKILL.md  # Julia econometrics reference
│   │   ├── econometrics-r/SKILL.md      # R econometrics reference
│   │   ├── causal-inference-r/SKILL.md  # IV/DiD/RDD in R
│   │   └── stata/                       # Comprehensive Stata suite
│   │       ├── SKILL.md                 # Main skill + routing table
│   │       ├── references/ (30 files)   # Stata reference docs
│   │       └── packages/ (20 files)     # Community package docs
│   ├── rules/                        # Embedded governance rules
│   │   ├── plan-first-workflow.md
│   │   ├── orchestrator-protocol.md
│   │   ├── orchestrator-research.md
│   │   ├── session-logging.md
│   │   ├── verification-protocol.md
│   │   ├── quality-gates.md
│   │   ├── r-code-conventions.md
│   │   ├── julia-code-conventions.md
│   │   ├── proofreading-protocol.md
│   │   ├── replication-protocol.md
│   │   ├── exploration-fast-track.md
│   │   ├── exploration-folder-protocol.md
│   │   ├── pdf-processing.md
│   │   └── knowledge-base-template.md
│   └── hooks/                        # Automation hooks
│       ├── log-reminder.py
│       ├── notify.ps1 (or notify.sh)
│       ├── protect-files.ps1 (or .sh)
│       └── pre-compact.ps1 (or .sh)
├── templates/                        # Reference templates
│   ├── session-log.md
│   ├── quality-report.md
│   └── exploration-readme.md
├── quality_reports/                   # Plans, logs, merge reports
│   ├── plans/
│   ├── session_logs/
│   └── merges/
├── explorations/                      # Research sandbox (60/100 threshold)
│   └── ARCHIVE/
├── scripts/                           # Utility scripts
└── master_supporting_docs/            # Reference papers
    └── supporting_papers/
```

---

## Skills Reference

### Workflow Skills

| Command | What It Does |
|---------|-------------|
| `/compile-latex [file]` | 3-pass pdflatex + bibtex compilation |
| `/proofread [file]` | Grammar, typos, notation consistency review |
| `/review-r [file]` | R code quality and reproducibility review |
| `/review-julia [file]` | Julia code quality and performance review |
| `/review-paper [file]` | Comprehensive referee-style manuscript review |
| `/validate-bib` | Cross-reference all citations against .bib |
| `/devils-advocate [topic]` | Challenge design decisions and assumptions |
| `/commit [msg]` | Stage, commit, PR, merge workflow |
| `/lit-review [topic]` | Literature search + synthesis + gaps |
| `/research-ideation [topic]` | Generate research questions + strategies |
| `/interview-me [topic]` | Interactive research interview |
| `/data-analysis [dataset]` | End-to-end R analysis workflow |

### Econometrics Reference Skills

| Command | What It Does |
|---------|-------------|
| `/econometrics-julia` | Julia code patterns for MLE, GMM, simulation-based estimation, Optim.jl, parallel computing |
| `/econometrics-r` | R patterns for data.table, fixest, spatial econometrics, causal forests, publication tables |
| `/causal-inference-r` | IV, DiD, and RDD in R with proper diagnostics (first-stage F, parallel trends, bandwidth) |
| `/stata` | Comprehensive Stata reference: 30 reference docs + 20 package docs (reghdfe, estout, csdid, rdrobust, ivreg2, etc.) |

---

## Quality Gates

| Score | Gate | Meaning |
|-------|------|---------|
| 80 | Commit | Good enough to save |
| 90 | PR | Ready for review |
| 95 | Excellence | Aspirational |

---

## Workflow Model: Contractor Mode

```
Your instruction
    |
[PLAN] (if non-trivial) --> Show plan --> Your approval
    |
[EXECUTE] Implement, verify, done
    |
[REPORT] Summary + what's ready
    |
Repeat
```

**Claude asks you when:** design forks, code ambiguity, replication edge cases, scope questions.

**Claude just executes when:** obvious bug fixes, verification/tolerance checks, documentation/logs, plotting per standards.

---

## Cross-Platform Notes

### Windows (Default)
Hooks use PowerShell (`.ps1` files). Works out of the box.

### macOS / Linux
1. Rename hook files from `.ps1` to `.sh`
2. Make them executable: `chmod +x .claude/hooks/*.sh`
3. Update `.claude/settings.json` to call `.sh` instead of `.ps1`:
   ```json
   "command": "bash \"$CLAUDE_PROJECT_DIR/.claude/hooks/notify.sh\""
   ```
4. For macOS notifications, use `osascript` instead of Windows toast.

---

## Customization Checklist

When starting a new project with this starter kit:

- [ ] Fill in `CLAUDE.md` placeholders (project, authors, institution, folder structure)
- [ ] Customize `domain-reviewer.md` review lenses for your field
- [ ] Update `knowledge-base-template.md` notation registry
- [ ] Adjust `r-code-conventions.md` color palette and pitfalls
- [ ] Adjust `julia-code-conventions.md` if using Julia (or delete if not)
- [ ] Update `verification-protocol.md` with your compilation commands
- [ ] Set protected files in `protect-files.ps1`
- [ ] Run `claude` and verify hooks work

---

## License

MIT -- Use freely for your research projects.

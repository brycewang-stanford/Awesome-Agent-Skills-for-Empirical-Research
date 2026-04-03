---
name: new-project
description: Full research pipeline from idea to paper. Orchestrates all phases — discovery, strategy, analysis, writing, peer review, and submission. Use when starting a new research project from scratch.
argument-hint: "[research topic or 'interactive' for guided start]"
allowed-tools: Read,Grep,Glob,Write,Edit,Bash,Task,WebSearch,WebFetch
---

# New Project

Launch a full research pipeline from idea to paper, orchestrated through the dependency graph.

**Input:** `$ARGUMENTS` — a research topic or `interactive` for a guided start via `/discover interview`.

---

## Pipeline Overview

This skill orchestrates the full dependency graph. Each phase activates when its dependencies are met. The orchestrator manages agent dispatch, three-strikes escalation, and quality gates.

```
Phase 1: Discovery
  ├── /discover interview → Research Spec + Domain Profile
  ├── /discover lit → Literature Synthesis + BibTeX
  └── /discover data → Data Assessment

Phase 2: Strategy (depends on Phase 1)
  └── /strategize → Strategy Memo + Robustness Plan

Phase 3: Execution (depends on Phase 2)
  ├── /analyze → Scripts + Tables + Figures
  └── /write → Paper Sections

Phase 4: Peer Review (depends on Phase 3)
  ├── /review --all → Comprehensive Quality Score
  └── /review --peer → domain-referee + methods-referee Reports

Phase 5: Submission (depends on Phase 4, score >= 95)
  ├── /submit target → Journal Recommendations
  ├── /submit package → Replication Package
  └── /submit final → Final Verification
```

---

## Workflow

### Step 0: Enter Plan Mode

Before any work begins:
1. **Enter plan mode** — use `EnterPlanMode`
2. **Create the project folder structure** — `data/raw/`, `data/cleaned/`, `scripts/R/`, `paper/sections/`, `paper/figures/`, `paper/tables/`, etc.
3. **Draft a high-level plan** — what phases are needed, estimated scope
4. **Save to disk** — `quality_reports/plans/YYYY-MM-DD_new-project.md`
5. **Present to user** — wait for approval before proceeding
6. **Exit plan mode** — only after approval

### Step 1: Discovery Phase

1. **If `interactive` or no research spec exists:**
   Run `/discover interview` to produce:
   - Research specification (`quality_reports/research_spec_*.md`)
   - Domain profile (`.claude/references/domain-profile.md`) — if still template

2. **Run `/discover lit`** with the research topic:
   - Librarian collects literature
   - librarian-critic reviews coverage
   - Output: literature synthesis + BibTeX entries

3. **Run `/discover data`** to find datasets:
   - Explorer searches for data sources
   - explorer-critic assesses data quality

**Gate:** Research spec and literature review must exist before proceeding.

### Step 2: Strategy Phase

4. **Run `/strategize`** to design the empirical strategy:
   - Strategist proposes identification strategy
   - strategist-critic validates the design

**Gate:** Strategy memo must pass strategist-critic review (score >= 80).

### Step 3: Execution Phase

5. **Run `/analyze`** to implement the strategy:
   - Data-engineer cleans data and creates figures
   - Coder writes analysis scripts
   - coder-critic reviews code

6. **Run `/write`** to draft the paper:
   - Writer drafts sections
   - Humanizer pass strips AI patterns

**Gate:** Code must pass coder-critic review. Paper sections must exist.

### Step 4: Peer Review Phase

7. **Run `/review --all`** for comprehensive review:
   - strategist-critic + coder-critic + writer-critic + Verifier in parallel
   - Weighted aggregate score computed

8. **Run `/review --peer`** for simulated peer review:
   - domain-referee (subject expertise) + methods-referee (econometrics)
   - Independent, blind reports
   - Orchestrator synthesizes editorial decision

**Gate:** Aggregate score >= 80 (commit-ready). Score >= 90 for submission.

### Step 5: Submission Phase (optional, user-triggered)

9. **Run `/submit target`** for journal recommendations
10. **Run `/submit package`** for replication package
11. **Run `/submit final`** for final verification

---

## User Interaction Points

The pipeline pauses for user input at these points:
- After interview (approve research spec)
- After strategy memo (approve identification strategy)
- After data analysis (review results before paper drafting)
- After peer review (review feedback before revision)
- Before submission (approve journal choice)

Between pauses, the orchestrator runs autonomously per `workflow.md`.

---

## Principles

- **This is always orchestrated.** Unlike other skills, `/new-project` always runs through the full pipeline.
- **Dependency-driven.** Phases activate by dependency, not forced sequence.
- **Quality-gated.** Each phase transition requires passing quality checks.
- **User retains control.** Pipeline pauses at key decision points.
- **Resumable.** If interrupted, the pipeline resumes from the last completed phase.

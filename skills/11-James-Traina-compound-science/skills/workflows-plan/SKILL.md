---
name: workflows:plan
description: Transform research descriptions into well-structured implementation plans following project conventions
argument-hint: "<research task, estimation problem, or methodological improvement>"
allowed-tools: Read, Glob, Bash
---

# Create an Implementation Plan for a Research Task

**Pipeline mode:** This command operates fully autonomously. All decisions are made automatically.

## Introduction

Transform research descriptions, estimation problems, or methodological improvements into well-structured plan files that follow project conventions and best practices. This command auto-selects the appropriate detail level based on task complexity.

## Research Description

<feature_description> #$ARGUMENTS </feature_description>

**If the research description above is empty:** Infer the task from recent context — open plan files, recent brainstorms in `docs/brainstorms/`, or the current estimation code. If no context is available, state "No research task provided" and stop.

### 0. Idea Refinement

**Check for brainstorm output first:**

Before analysis, look for recent brainstorm documents in `docs/brainstorms/` that match this task:

```bash
ls -la docs/brainstorms/*.md 2>/dev/null | head -10
```

If docs/brainstorms/ does not exist, skip brainstorm lookup and proceed with task analysis.

**Relevance criteria:** A brainstorm is relevant if:
- The topic (from filename or YAML frontmatter) semantically matches the research description
- Created within the last 14 days
- If multiple candidates match, use the most recent one

**If a relevant brainstorm exists:**
1. Read the brainstorm document thoroughly — every section matters
2. Announce: "Found brainstorm from [date]: [topic]. Using as foundation for planning."
3. Extract and carry forward ALL of the following into the plan:
   - Key decisions and their rationale
   - Chosen approach and why alternatives were rejected
   - Constraints and requirements discovered during brainstorming
   - Open questions (flag these for resolution during implementation)
   - Success criteria and scope boundaries
   - Any specific methodological choices or estimator selections
4. **Skip the idea refinement analysis below** — the brainstorm already answered WHAT to do
5. Use brainstorm content as the **primary input** to research and planning phases
6. Throughout the plan, reference specific decisions with `(see brainstorm: docs/brainstorms/<filename>)` when carrying forward conclusions
7. Do not omit brainstorm content — if the brainstorm discussed it, the plan must address it

**If no brainstorm found (or not relevant), analyze the task:**

Decompose the research description to understand scope:

- **What is being asked?** New estimator, bug fix, robustness check, data work, pipeline change?
- **What is the identification strategy?** If estimation work, what identifies the parameters?
- **What dependencies exist?** Data availability, computational resources, prior estimation steps?
- **What is the risk level?** Simple change vs architectural shift vs novel methodology?

## Main Tasks

### 1. Local Research (Always Runs — Parallel)

Run these agents **in parallel** to gather local context:

- Task methods-explorer(research_description)
- Search `docs/solutions/` for documented solutions that might apply (convergence fixes, data issues, specification errors)

**What to look for:**
- **Methods research:** existing estimation patterns, methodology used in this project, relevant packages and implementations
- **Learnings:** documented solutions in `docs/solutions/` that might apply (see `workflows-compound/references/solution-schema.md` for search workflow)

These findings inform the next step.

### 1.5. Research Decision

Based on task analysis and local findings, decide on extended research.

**Novel methodology → always research.** New identification strategies, unfamiliar estimators, methods without established implementations. The cost of missing relevant literature is too high.

**Strong local context → skip extended research.** Project has established patterns for this type of work, prior brainstorm covers the approach, straightforward extension of existing code.

**Uncertainty or unfamiliar territory → research.** Unfamiliar econometric method, no existing examples in codebase, potential identification concerns.

**Announce the decision and proceed.** Brief explanation, then continue.

Examples:
- "Project has established DiD patterns for this. Proceeding without extended research."
- "This involves a new identification strategy. Researching current best practices and recent Monte Carlo evidence."

### 1.5b. Extended Research (Conditional)

**Only run if Step 1.5 indicates extended research is valuable.**

Run these agents in parallel:

- Task literature-scout(research_description)

### 1.6. Consolidate Research

After all research steps complete, consolidate findings:

- Document relevant file paths from codebase research (e.g., `src/estimation/blp_demand.py:42`)
- Include relevant methodological learnings from `docs/solutions/` (convergence fixes, specification patterns)
- Note software packages, estimator properties, and Monte Carlo evidence (if extended research was done)
- List related estimation code or prior implementations discovered
- Capture CLAUDE.md conventions and project-specific patterns

### 2. Plan Structure & Categorization

**Title & Categorization:**

- Draft clear, searchable title using conventional format (e.g., `feat: Add Callaway-Sant'Anna staggered DiD estimator`, `fix: BLP inner-loop convergence failure`)
- Determine type: feat (new estimator/method), fix (bug/convergence issue), refactor (code improvement)
- Convert title to filename: add today's date prefix, strip prefix colon, kebab-case, add `-plan` suffix
  - Example: `feat: Add Staggered DiD Estimator` → `2026-02-26-feat-add-staggered-did-estimator-plan.md`

### 3. Specification Flow Analysis

After planning the structure, validate the research specification by checking the chain from model → estimator → code. Verify that model assumptions imply estimator requirements, objective function and moments match the methodology, and diagnostic tests exist for each testable identification assumption. If gaps are found, incorporate them as plan items.

### 4. Auto-Select Implementation Detail Level

**Auto-detect based on task characteristics:**

| Signal | Level | Examples |
|--------|-------|---------|
| Bug fix, simple data cleaning, minor parameter change | **MINIMAL** | Fix standard error clustering, correct variable coding, update sample restriction |
| New estimator, additional robustness check, new data source | **MORE** | Add Callaway-Sant'Anna estimator, implement placebo tests, merge new dataset |
| New identification strategy, structural model change, pipeline overhaul | **A LOT** | Switch from reduced-form to structural estimation, redesign DGP, build replication package |

If signals are mixed, default to **MORE** — it covers most research tasks well.

---

#### MINIMAL (Quick Plan)

**Best for:** Simple bug fixes, parameter changes, minor data corrections

```markdown
---
title: [Plan Title]
type: [feat|fix|refactor]
status: active
date: YYYY-MM-DD
origin: docs/brainstorms/YYYY-MM-DD-<topic>-brainstorm.md  # if originated from brainstorm
---

# [Plan Title]

[Brief problem/task description]

## Acceptance Criteria

- [ ] Core requirement 1
- [ ] Core requirement 2

## Context

[Critical information: data source, estimation method, relevant code paths]

## Implementation

### [filename.py]

```python
# Key implementation sketch
```

## Sources

- **Origin brainstorm:** [path] — include if plan originated from a brainstorm
- Related code: [file_path:line_number]
```

---

#### MORE (Standard Plan)

**Best for:** Most research tasks — new estimators, robustness checks, data work

```markdown
---
title: [Plan Title]
type: [feat|fix|refactor]
status: active
date: YYYY-MM-DD
origin: docs/brainstorms/YYYY-MM-DD-<topic>-brainstorm.md  # if originated from brainstorm
---

# [Plan Title]

## Overview

[Comprehensive description of the research task]

## Problem Statement / Motivation

[Why this matters — what research question does this advance?]

## Proposed Approach

[High-level methodological approach]

## Technical Considerations

- Estimation method and its properties
- Computational requirements and convergence expectations
- Data structure and variable construction

## Research Impact Assessment

- **Identification Impact**: What assumptions does this change affect? Are exclusion restrictions, rank conditions, or support conditions modified?
- **Estimation Impact**: How does this affect computational cost, convergence properties, or asymptotic efficiency?
- **Robustness Impact**: Which robustness checks need updating? New placebo tests, alternative specifications, or sensitivity analyses?
- **Replication Impact**: What changes to the replication package? New dependencies, data files, or computational steps?

## Acceptance Criteria

- [ ] Estimation converges with sensible parameter values
- [ ] Standard errors computed correctly (appropriate clustering/robustness)
- [ ] Diagnostic tests pass (first-stage F, overidentification, specification tests)
- [ ] Results are robust to reasonable alternative specifications
- [ ] Code is documented and reproducible

## Dependencies & Risks

[What could block or complicate this — data availability, computational cost, identification concerns]

## Sources & References

- **Origin brainstorm:** [path] — include if plan originated from a brainstorm
- Methodological reference: [paper/package]
- Similar code in project: [file_path:line_number]
```

---

#### A LOT (Comprehensive Plan)

**Best for:** Major methodological changes, new identification strategies, structural model development

```markdown
---
title: [Plan Title]
type: [feat|fix|refactor]
status: active
date: YYYY-MM-DD
origin: docs/brainstorms/YYYY-MM-DD-<topic>-brainstorm.md  # if originated from brainstorm
---

# [Plan Title]

## Overview

[Executive summary of the research task and its significance]

## Problem Statement

[Detailed problem analysis — what gap in the literature or project does this fill?]

## Proposed Approach

[Comprehensive methodological approach with theoretical motivation]

## Technical Approach

### Identification Strategy

[Formal identification argument — target parameter, assumptions, identification result]

### Estimation Method

[Estimator choice, properties, computational approach]

### Implementation Phases

#### Phase 1: [Foundation]

- Tasks and deliverables
- Success criteria (convergence, diagnostics)
- Key files to create/modify

#### Phase 2: [Core Estimation]

- Tasks and deliverables
- Success criteria
- Key files to create/modify

#### Phase 3: [Robustness & Documentation]

- Robustness checks and sensitivity analyses
- Documentation and replication materials
- Success criteria

## Alternative Approaches Considered

[Other methods evaluated and why rejected — reference brainstorm if applicable]

## Research Impact Assessment

### Identification Impact

[Detailed analysis: What assumptions does this change affect? How testable are they? What happens if they fail?]

### Estimation Impact

[Detailed analysis: Computational cost, convergence properties, efficiency gains/losses, finite-sample behavior]

### Robustness Impact

[Detailed analysis: Which specification tests apply? Placebo tests, alternative instruments, subsample analysis, sensitivity to functional form]

### Replication Impact

[Detailed analysis: New dependencies, data requirements, computational environment changes, pipeline modifications]

## Acceptance Criteria

### Estimation Requirements

- [ ] Point estimates are economically sensible (sign, magnitude, significance)
- [ ] Standard errors use appropriate inference (clustering, bootstrap, analytical)
- [ ] Convergence achieved with tolerance < [threshold]
- [ ] Multiple starting values yield consistent results

### Diagnostic Requirements

- [ ] First-stage F-statistic > 10 (if IV)
- [ ] Overidentification test not rejected (if overidentified)
- [ ] Specification tests pass (Hausman, reset, etc.)
- [ ] No evidence of weak instruments

### Robustness Requirements

- [ ] Results robust to alternative specifications
- [ ] Placebo tests show null effects where expected
- [ ] Sensitivity analysis documents parameter sensitivity

### Quality Gates

- [ ] All tests pass
- [ ] Pipeline runs end-to-end from raw data
- [ ] Random seeds set and documented
- [ ] Results match across runs (reproducibility verified)

## Dependencies & Prerequisites

[Detailed dependency analysis — data, packages, prior estimation steps]

## Risk Analysis & Mitigation

[Comprehensive risk assessment — identification failures, convergence issues, data problems]

## Sources & References

### Origin

- **Brainstorm document:** [path] — Key decisions carried forward: [list 2-3 major decisions]

### Methodological References

- [Seminal paper for the method]
- [Recent Monte Carlo evidence]
- [Software documentation]

### Internal References

- Existing estimation code: [file_path:line_number]
- Prior results: [file_path]
- Data documentation: [file_path]
```

### 5. Write Plan File

**REQUIRED: Write the plan file to disk.**

```bash
mkdir -p docs/plans/
```

Use the Write tool to save the complete plan to `docs/plans/YYYY-MM-DD-<type>-<descriptive-name>-plan.md`. This step is mandatory.

### Artifact Storage

Write the plan to `docs/plans/<topic>-plan.md` with YAML frontmatter:
```yaml
---
status: active
date: YYYY-MM-DD
topic: <descriptive topic>
origin: docs/brainstorms/<matching-brainstorm>.md
---
```

Check `docs/brainstorms/` for a matching upstream document and link it via the `origin` field.
If `docs/plans/` contains a recent plan matching this topic, ask the user: "Found existing plan on this topic. Continue from it, or start fresh?"

Confirm: "Plan written to docs/plans/[filename]"

## Output Format

**Filename:** Use the date and kebab-case filename from Step 2.

```
docs/plans/YYYY-MM-DD-<type>-<descriptive-name>-plan.md
```

Examples:
- `docs/plans/2026-01-15-feat-callaway-santanna-staggered-did-plan.md`
- `docs/plans/2026-02-03-fix-blp-inner-loop-convergence-plan.md`
- `docs/plans/2026-03-10-refactor-estimation-pipeline-extraction-plan.md`

### 6. Parallel Research Enrichment (A LOT plans only)

For **A LOT** detail level plans, enrich the plan by spawning parallel specialist agents against the plan's key decisions:

- **literature-scout**: "Given this plan, identify 3-5 missing citations, recent methods advances (post-2022) that complement the approach, and the 1-2 most important prior applications of this identification strategy."
- **identification-critic**: "Given this plan, identify the weakest link in the identification argument, any unstated regularity conditions, and whether the estimator correctly targets the stated estimand."
- **methods-explorer**: "Given this plan, identify the best software implementation (package, version, known bugs), computational considerations, and one alternative estimator that may be more robust."

Launch all agents simultaneously. For each section the agents comment on, add a `### Research Insights` subsection:

```
### Research Insights
**Literature** (literature-scout): [2-3 sentences]
**Identification** (identification-critic): [2-3 sentences]
**Methods** (methods-explorer): [2-3 sentences]
```

Flag items requiring immediate attention with a warning marker. Update the saved plan file with the enriched content.

## Post-Generation Handoff

After writing the plan file, the handoff depends on how this skill was invoked.

### Pipeline Mode (invoked from `/lfg` or `/slfg`)

Skip the summary display. Immediately invoke `/workflows:work` with the plan file path as the argument. Do not pause or present options.

### Standalone Mode (invoked directly by the user)

Display the post-generation summary:

```
Plan ready at docs/plans/YYYY-MM-DD-<type>-<name>-plan.md

Detail level: [MINIMAL | MORE | A LOT]
Research impact: [Brief summary of identification/estimation/robustness/replication impacts]

Next steps:
- Run `/workflows:work` to begin implementation
- Run `/workflows:review` after implementation for methodological review
```

Then present the following options and wait for user input:

```
What would you like to do next?

1. Start implementation (Recommended) — Immediately run /workflows:work in this session
2. Review and edit the plan — Open the plan file for manual revision
3. End session — Stop here; the plan is saved for later
```

Act on the user's choice:
- **Option 1**: Invoke `/workflows:work` with the plan file path as the argument.
- **Option 2**: Open the plan file using the Read tool so the user can review it, then wait for further instructions.
- **Option 3**: Stop. No further action needed.

## Key Principles

- **Auto-detect everything** — detail level, research depth, methodology choices are inferred from context
- **Ground in real methods** — cite actual estimators, packages, and papers, not generic advice
- **Research impact over system impact** — identification, estimation, robustness, and replication are what matter
- **Parsimony in planning** — match plan complexity to task complexity; a simple bug fix needs a MINIMAL plan
- **The brainstorm is the origin document** — carry forward all decisions, don't re-derive what was already decided

## Routes To

- `/workflows:work` — implement the plan
- `/workflows:brainstorm` — explore alternatives before committing
- `econometric-reviewer` agent — for specification flow analysis (model → estimator → code)

NEVER CODE! Just research and write the plan.

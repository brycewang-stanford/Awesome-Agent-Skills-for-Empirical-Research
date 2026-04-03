---
name: workflows:compound
description: Document a recently solved research problem to compound methodological knowledge
argument-hint: "[optional: brief context about the fix or problem solved]"
allowed-tools: Read, Write, Edit, Glob
---

# /compound

**Pipeline mode:** This command operates fully autonomously. All decisions are made automatically.

Coordinate multiple subagents working in parallel to document a recently solved research problem. Creates structured documentation in `docs/solutions/` with YAML frontmatter for searchability and future reference.

## Purpose

Captures problem solutions while context is fresh. Uses parallel subagents for maximum efficiency — Phase 1 gathers information, Phase 2 assembles the final document.

**Why "compound"?** Each documented solution compounds your methodological knowledge. The first time you solve a convergence problem takes hours of research. Document it, and the next occurrence takes minutes. Knowledge compounds.

## Usage

```bash
/workflows:compound                          # Document the most recent fix
/workflows:compound convergence failure in BLP inner loop  # Provide context
/workflows:compound fixed cluster-robust SEs  # Brief description
```

## Execution Strategy: Two-Phase Orchestration

<critical_requirement>
**Only ONE file gets written — the final documentation.**

Phase 1 subagents return TEXT DATA to the orchestrator. They must NOT use Write, Edit, or create any files. Only the orchestrator (Phase 2) writes the final documentation file.
</critical_requirement>

### Phase 1: Parallel Research

<parallel_tasks>

Launch these subagents IN PARALLEL. Each returns text data to the orchestrator.

#### 1. **Context Analyzer**
   - Extracts conversation history for the problem-solving session
   - Identifies problem type, estimation method, symptoms, error messages
   - Auto-categorizes the problem (see Category Classification below)
   - Returns: YAML frontmatter skeleton with problem metadata

#### 2. **Solution Extractor**
   - Analyzes all investigation steps taken during the session
   - Identifies root cause (e.g., "ill-conditioned Hessian due to poor starting values")
   - Extracts working solution with code examples
   - Documents what didn't work and why (important for future reference)
   - Returns: Solution content block with code snippets

#### 3. **Related Docs Finder**
   - Searches `docs/solutions/` for related documentation
   - Identifies cross-references and links to similar problems
   - Checks if this problem is a variant of a previously documented issue
   - Returns: Links, relationships, and duplicate-avoidance notes

#### 4. **Prevention Strategist**
   - Develops prevention strategies specific to the problem type
   - Creates diagnostic checklist ("check these things first next time")
   - Suggests robustness checks or tests that would catch this early
   - Returns: Prevention/diagnostic content

#### 5. **Category Classifier**
   - Auto-detects the appropriate `docs/solutions/` category from problem description and session content
   - Validates category against the schema below
   - Generates filename slug from problem description
   - Returns: Final path and filename

</parallel_tasks>

### Category Classification

Problems are auto-classified into one or more categories using keyword matching on the problem description and session content:

| Category | Directory | Keywords / Signals |
|----------|-----------|-------------------|
| **Estimation Issues** | `estimation-issues/` | convergence, bias, efficiency, standard errors, MLE, GMM, likelihood, optimizer, starting values, boundary, gradient, Hessian |
| **Data Issues** | `data-issues/` | missing data, measurement error, sample selection, merge, duplicates, outliers, panel structure, encoding, cleaning |
| **Numerical Issues** | `numerical-issues/` | floating-point, overflow, underflow, condition number, tolerance, ill-conditioning, precision, NaN, Inf, singular matrix |
| **Methodology Issues** | `methodology-issues/` | identification, model specification, assumption violations, endogeneity, exclusion restriction, functional form, overidentification |
| **Derivation Issues** | `derivation-issues/` | proof, theorem, lemma, asymptotic, regularity conditions, existence, uniqueness, fixed point, convergence rate |
| **Replication Issues** | `replication-issues/` | reproducibility, package versions, seeds, environment, Docker, conda, renv, pipeline, Makefile, DVC |

**Multi-category problems:** A problem can belong to multiple categories (e.g., "BLP convergence failure" is both `estimation-issues/` and `numerical-issues/`). Use the primary category for the file location and cross-reference the secondary category in the frontmatter `tags` field.

**Ambiguous problems:** If keyword matching is inconclusive, default to `methodology-issues/` (the broadest category).

### Phase 2: Assembly & Write

<sequential_tasks>

**WAIT for all Phase 1 subagents to complete before proceeding.**

The orchestrating agent performs these steps:

1. **Collect** all text results from Phase 1 subagents
2. **Assemble** complete markdown file using the template below
3. **Validate** YAML frontmatter fields are complete
4. **Create** directory if needed: `mkdir -p docs/solutions/[category]/`
5. **Write** the SINGLE final file: `docs/solutions/[category]/[filename].md`

#### Documentation Template

```markdown
---
title: "[Problem title — concise, searchable]"
date: YYYY-MM-DD
category: [primary category]
tags: [estimation, convergence, BLP, ...]
estimation_method: [if applicable: MLE, GMM, IV, DiD, ...]
language: [Python, R, Julia, Stata]
severity: [critical, moderate, minor]
time_to_resolve: [approximate time spent]
---

# [Problem Title]

## Problem

**Symptom:** [What was observed — error messages, wrong results, failure to converge]

**Context:** [What estimation/analysis was being performed, what data, what method]

**Reproduction:** [Minimal steps to reproduce the problem]

## Investigation

### What Didn't Work
1. [Attempted fix and why it failed]
2. [Another attempt and outcome]

### Root Cause
[Technical explanation of why the problem occurred]

## Solution

[Step-by-step fix with code examples]

```python
# or R, Julia, Stata as appropriate
# Working code with comments explaining the fix
```

## Prevention

**Diagnostic Checklist** (check these first next time):
- [ ] [First thing to verify]
- [ ] [Second thing to verify]
- [ ] [Third thing to verify]

**Robustness Checks:**
- [Checks that would catch this early]

## Related

- [Links to related docs/solutions/ entries]
- [Links to methodology papers if relevant]
- [Links to package documentation]
```

</sequential_tasks>

### Phase 3: Specialized Agent Review (Optional)

**WAIT for Phase 2 to complete before proceeding.**

Based on the problem category, optionally invoke a specialized agent to review the documentation for accuracy and completeness:

<parallel_tasks>

| Problem Category | Agent | Review Focus |
|-----------------|-------|-------------|
| `estimation-issues/` | `econometric-reviewer` | Solution correctness, estimation theory |
| `numerical-issues/` | `numerical-auditor` | Numerical accuracy, stability claims |
| `methodology-issues/` | `methods-explorer` | Methodological completeness, alternatives |
| `derivation-issues/` | `mathematical-prover` | Proof correctness, regularity conditions |
| `data-issues/` | `data-detective` | Data handling best practices |
| `replication-issues/` | `reproducibility-auditor` | Reproducibility completeness |

Launch the matching agent(s) to verify the documented solution is correct and complete. If the agent finds issues, update the documentation file.

</parallel_tasks>

### Phase 4: Knowledge Capture

Use `references/solution-schema.md` to ensure the solution is properly indexed and cross-referenced:

- Verify the documentation follows the YAML frontmatter schema
- Cross-reference with existing docs/solutions/ entries
- Detect patterns (3+ similar issues) and promote critical patterns
- Update any index or search metadata

## What It Captures

- **Problem symptom**: Exact error messages, observable behavior, numerical output
- **Investigation steps tried**: What didn't work and why (often the most valuable part)
- **Root cause analysis**: Technical explanation grounded in estimation/statistical theory
- **Working solution**: Step-by-step fix with complete, runnable code examples
- **Prevention strategies**: Diagnostic checklists and robustness checks
- **Cross-references**: Links to related solutions, methodology papers, package docs

## What It Creates

**Organized documentation:**

- File: `docs/solutions/[category]/[filename].md`
- Categories auto-detected from problem description

**Category directories:**

- `estimation-issues/` — convergence failures, biased estimates, wrong standard errors
- `data-issues/` — missing data, merge errors, sample selection problems
- `numerical-issues/` — floating-point, ill-conditioning, overflow/underflow
- `methodology-issues/` — identification failures, specification errors, assumption violations
- `derivation-issues/` — proof errors, incorrect asymptotics, missing regularity conditions
- `replication-issues/` — reproducibility failures, environment issues, missing documentation

## Common Mistakes to Avoid

| Wrong | Correct |
|-------|---------|
| Subagents write files like `context-analysis.md` | Subagents return text data; orchestrator writes one final file |
| Research and assembly run in parallel | Research completes, THEN assembly runs |
| Multiple files created during workflow | Single file: `docs/solutions/[category]/[filename].md` |
| Generic description ("fixed the bug") | Specific description ("replaced numerical Hessian with analytic Hessian to fix ill-conditioning in BLP inner loop") |
| Solution without code | Always include runnable code showing the fix |
| Skipping "what didn't work" | Failed approaches are the most valuable for future reference |

## Success Output

```
Documentation complete

Subagent Results:
  Context Analyzer: Identified numerical_issue in BLP inner loop
  Solution Extractor: Analytic Hessian fix with code example
  Related Docs Finder: 1 related entry (estimation-issues/blp-starting-values.md)
  Prevention Strategist: 4-item diagnostic checklist
  Category Classifier: numerical-issues/

Specialized Review:
  numerical-auditor: Verified solution correctness, confirmed condition number improvement

Knowledge Capture:
  Solution schema: Indexed and cross-referenced

File created:
  docs/solutions/numerical-issues/blp-inner-loop-hessian-conditioning.md

This solution will be searchable for future reference when similar
numerical stability issues occur in BLP estimation.

Next steps:
1. Continue workflow — run /workflows:review for remaining changes
2. Link related documentation if other solutions should reference this
3. Run /workflows:work if additional implementation is needed
```

## The Compounding Philosophy

This creates a compounding knowledge system for research methodology:

1. First time you solve "ill-conditioned Hessian in BLP" → Research and debug (2 hours)
2. Document the solution → `docs/solutions/numerical-issues/blp-hessian.md` (5 min)
3. Next time similar issue occurs → Quick lookup via `docs/solutions/` search (2 min)
4. Knowledge compounds → Research team gets faster at diagnosing and fixing estimation problems

The feedback loop:

```
Specify Model → Estimate → Diagnose Issue → Research → Fix → Document → Validate
     ↑                                                                       ↓
     └───────────────────────────────────────────────────────────────────────┘
```

**Each unit of methodological problem-solving should make subsequent units easier — not harder.**

## Auto-Invoke

This command is most valuable immediately after solving a non-trivial problem. Trigger phrases:

- "that converges now"
- "fixed the estimation"
- "identification argument is complete"
- "pipeline runs end-to-end"
- "replication package works"

Or invoke directly: `/workflows:compound [brief context]`

### Phase 5: Handoff

**Pipeline mode** (when invoked from /lfg or /slfg):
- This is the final step in the chain. Report completion and stop.
- Output: "Workflow complete. Solution documented at [path]."

**Standalone mode** (when invoked directly by the user):
- After the documentation is written, present options:
  1. **Start next cycle** — Run `/workflows:brainstorm` to begin a new research cycle
  2. **Review the documentation** — Read back the docs/solutions/ file just created
  3. **End session** — Stop here; the solution is documented

This closes the loop: compound → brainstorm → plan → work → review → compound.

## Applicable Specialized Agents

Based on problem category, these agents enhance and verify documentation:

### Estimation & Methodology
- **econometric-reviewer**: Reviews estimation-issue solutions for theoretical correctness
- **methods-explorer**: Enriches with alternative approaches and literature references
- **identification-critic**: Verifies identification-related solutions are complete

### Numerical & Data
- **numerical-auditor**: Validates numerical stability claims and solutions
- **data-detective**: Reviews data-issue solutions for completeness

### Rigor & Reproducibility
- **mathematical-prover**: Checks derivation-issue solutions for proof correctness
- **reproducibility-auditor**: Validates replication-issue solutions

### Configuration
Customize which review agents run by editing `compound-science.local.md`.

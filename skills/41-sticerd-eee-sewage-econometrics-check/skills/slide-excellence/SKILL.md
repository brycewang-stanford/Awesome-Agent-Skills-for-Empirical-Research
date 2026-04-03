---
name: slide-excellence
description: Multi-agent review for research presentation slides in the sewage-house-prices project (visual, econometric fidelity, proofreading, substance). Use for comprehensive quality check before milestones.
argument-hint: "[TEX filename]"
allowed-tools: ["Read", "Grep", "Glob", "Write", "Task"]
context: fork
---

# Slide Excellence Review

Run a comprehensive multi-dimensional review of research presentation slides. Multiple agents analyze the file independently, then results are synthesized.

## Steps

### 1. Identify the File

Parse `$ARGUMENTS` for the filename. Resolve path in `docs/conferences/`.

### 2. Run Review Agents in Parallel

**Agent 1: Visual Audit** (slide-auditor)
- Overflow, font consistency, box fatigue, spacing, images
- Save: `docs/conferences/quality_reports/[FILE]_visual_audit.md`

**Agent 2: Econometric Fidelity Review** (econometrics-reviewer)
- Every quantitative claim on slides must be traceable to the paper (`docs/overleaf/_main.tex`)
- Check: coefficients, standard errors, sample sizes, p-values match paper tables/figures
- Check: identification strategy correctly described (hedonic pricing, repeat sales, long-difference, DiD, upstream/downstream)
- Check: treatment variables defined correctly (spill_count/spill_hrs, 12/24hr counting methodology)
- Check: confidence intervals and significance stars consistent with paper
- Check: no causal language without identification support
- Save: `docs/conferences/quality_reports/[FILE]_econometrics_report.md`

**Agent 3: Proofreading** (proofreader)
- Grammar, typos, consistency, academic quality, citations
- Save: `docs/conferences/quality_reports/[FILE]_report.md`

**Agent 4: TikZ Review** (only if file contains TikZ)
- Label overlaps, geometric accuracy, visual semantics
- Save: `docs/conferences/quality_reports/[FILE]_tikz_review.md`

**Agent 5: Substance Review** (domain correctness)
- Verify environmental economics claims are accurate
- Check EDM/water company institutional context is correct
- Verify spatial econometrics descriptions match methodology
- Check hedonic pricing theory correctly invoked
- Verify England housing market characterisation
- Save: `docs/conferences/quality_reports/[FILE]_substance_review.md`

### 3. Synthesize Combined Summary

```markdown
# Slide Excellence Review: [Filename]

## Overall Quality Score: [EXCELLENT / GOOD / NEEDS WORK / POOR]

| Dimension | Critical | Medium | Low |
|-----------|----------|--------|-----|
| Visual/Layout | | | |
| Econometric Fidelity | | | |
| Proofreading | | | |
| Substance | | | |

### Critical Issues (Immediate Action Required)
### Medium Issues (Next Revision)
### Recommended Next Steps
```

## Quality Score Rubric

| Score | Critical | Medium | Meaning |
|-------|----------|--------|---------|
| Excellent | 0-2 | 0-5 | Ready to present |
| Good | 3-5 | 6-15 | Minor refinements |
| Needs Work | 6-10 | 16-30 | Significant revision |
| Poor | 11+ | 31+ | Major restructuring |

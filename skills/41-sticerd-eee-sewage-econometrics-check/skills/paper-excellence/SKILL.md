---
name: paper-excellence
description: Comprehensive multi-dimensional review of the sewage-house-prices project. Runs econometrics audit, code review, manuscript proofread, and bibliography validation in parallel. Computes a weighted aggregate score. This skill should be used when asked for a "full review", "quality check", "paper excellence", or before submission milestones.
argument-hint: "['all' or specific component: econometrics|code|paper|bib]"
allowed-tools: ["Read", "Grep", "Glob", "Write", "Agent", "Bash"]
---

# Paper Excellence Review

Run a comprehensive quality assessment of the sewage-house-prices project across all dimensions.

**Input:** `$ARGUMENTS` — `all` for full review, or a specific component.

---

## Workflow

### Step 1: Identify Targets

- `docs/overleaf/*.tex` — Manuscript sections
- `scripts/R/09_analysis/` — Analysis scripts
- `output/tables/` — Generated tables
- `output/figures/` — Generated figures
- `docs/overleaf/refs.bib` — Bibliography

### Step 2: Launch Review Agents (Parallel)

Launch up to 4 agents simultaneously:

**Agent 1: Econometrics Audit**
Review all identification strategies (hedonic, repeat sales, long diff, DiD, upstream/downstream, dry spills).
Cross-reference manuscript claims against analysis scripts.
**Weight: 30%**

**Agent 2: Code Review**
Review all scripts in `scripts/R/09_analysis/` for code quality, reproducibility, and project convention compliance.
**Weight: 15%**

**Agent 3: Manuscript Proofread**
Review all `.tex` files for structure, claims-evidence alignment, identification fidelity, writing quality, grammar, and LaTeX compilation.
**Weight: 35%**

**Agent 4: Bibliography Validation**
Cross-reference all citations against `refs.bib`. Check for missing entries, unused references, and quality issues.
**Weight: 5%**

### Step 3: Compute Weighted Aggregate Score

```
Overall = 0.30 × Econometrics + 0.15 × Code + 0.35 × Paper + 0.05 × Bibliography + 0.15 × Polish
```

Where Polish is derived from the Proofreader's writing quality subscore.

If components are missing (e.g. no manuscript sections yet), renormalise weights over available components.

### Step 4: Present Results

```markdown
# Paper Excellence Report: Sewage in Our Waters
**Date:** YYYY-MM-DD
**Aggregate Score:** XX/100

## Score Breakdown
| Component | Weight | Score | Issues | Source |
|-----------|--------|-------|--------|--------|
| Econometrics | 30% | XX | N | /econometrics-check |
| Code | 15% | XX | N | /review-r |
| Paper | 35% | XX | N | /proofread |
| Bibliography | 5% | XX | N | /validate-bib |
| Polish | 15% | XX | N | Writing quality subscore |

## Priority Fixes (Top 5)
1. **[CRITICAL]** [Most important issue]
2. **[MAJOR]** [Second priority]
3. ...

## Quality Gate
- Score >= 90: "Ready for submission."
- Score >= 80: "Commit-ready. Address major issues before submission."
- Score < 80: "Blocked. Must fix critical/major issues."

## Full Reports
- Econometrics: output/log/econometrics_check_all.md
- Code: output/log/code_review_all.md
- Proofread: output/log/proofread_report_all.md
- Bibliography: output/log/bib_validation.md
```

Save to `output/log/paper_excellence_[date].md`.

---

## Principles

- **Parallel execution.** All agents run simultaneously for efficiency.
- **Weighted aggregation.** Not a simple average — econometrics and paper quality dominate.
- **Don't double-count.** Same issue found by multiple agents counts once in priority list.
- **One unified report.** User sees one priority list, not separate reports.
- **Proportional gating.** Working papers get developmental feedback. Near-final manuscripts get submission-level scrutiny.

---
paths:
  - "**/*.tex"
  - "**/*.jl"
  - "**/*.R"
  - "scripts/**"
---

# Quality Gates & Scoring Rubrics

## Thresholds

- **80/100 = Commit** -- good enough to save
- **90/100 = PR** -- ready for review
- **95/100 = Excellence** -- aspirational

## LaTeX Manuscript (.tex)

| Severity | Issue | Deduction |
|----------|-------|-----------|
| Critical | pdflatex compilation failure | -100 |
| Critical | Undefined citation | -15 |
| Critical | Typo in equation | -10 |
| Critical | Overfull hbox > 10pt | -10 |
| Major | Notation inconsistency | -5 |
| Major | Missing or incorrect table/figure reference | -5 |
| Minor | Long lines (>100 chars) | -1 (EXCEPT documented math formulas) |
| Minor | Inconsistent formatting | -1 |

## Julia Scripts (.jl)

| Severity | Issue | Deduction |
|----------|-------|-----------|
| Critical | Syntax errors / module won't load | -100 |
| Critical | Convergence failure not handled | -30 |
| Critical | Hardcoded absolute paths | -20 |
| Major | Missing `@everywhere` for parallel code | -10 |
| Major | Type instability in hot loops | -5 |
| Minor | Long lines in non-mathematical code | -1 |

## R Scripts (.R)

| Severity | Issue | Deduction |
|----------|-------|-----------|
| Critical | Syntax errors | -100 |
| Critical | Domain-specific bugs | -30 |
| Critical | Hardcoded absolute paths | -20 |
| Major | Missing figure generation | -5 |
| Major | Incorrect variable transformations | -10 |

## Enforcement

- **Score < 80:** Block commit. List blocking issues.
- **Score < 90:** Allow commit, warn. List recommendations.
- User can override with justification.

## Quality Reports

Generated **only at merge time**. Use `templates/quality-report.md` for format.
Save to `quality_reports/merges/YYYY-MM-DD_[branch-name].md`.

## Tolerance Thresholds (Customize Per Project)

| Quantity | Tolerance | Rationale |
|----------|-----------|-----------|
| Point estimates | < 1e-6 | Numerical precision of optimization |
| Standard errors | < 1e-4 | Bootstrap/simulation MC variability |
| Significance stars | Exact match | Discrete classification must agree |
| Sample sizes | Exact match | No reason for difference |

---
description: "0\u2013100 scoring rubric with deduction tables. Thresholds: 80 = commit, 90 = PR, 95 = excellence."
paths:
  - "**/*.tex"
  - "**/*.qmd"
  - "**/*.R"
  - "**/*.py"
  - "**/*.ipynb"
  - "manuscripts/**"
---

# Quality Gates & Scoring Rubrics

## Thresholds

- **80/100 = Commit** -- good enough to save
- **90/100 = PR** -- ready for deployment
- **95/100 = Excellence** -- aspirational

## Paper Manuscripts (.tex, .qmd, .md)

| Severity | Issue | Deduction |
|----------|-------|-----------|
| Critical | Claimed result absent from analysis outputs | -50 |
| Critical | Citation in paper not in bibliography | -15 |
| Critical | Undefined notation used | -10 |
| Major | Identification assumption unstated | -10 |
| Major | Broken table or figure reference | -5 |
| Major | Writing quality blocks comprehension | -5 |
| Minor | Style inconsistency | -1 per instance |

## Quarto Files (.qmd)

| Severity | Issue | Deduction |
|----------|-------|-----------|
| Critical | Render failure | -100 |
| Critical | Equation overflow | -20 |
| Critical | Broken citation | -15 |
| Critical | Typo in equation | -10 |
| Major | Text overflow | -5 |
| Major | Notation inconsistency | -3 |
| Minor | Font size reduction | -1 per slide |
| Minor | Long lines (>100 chars) | -1 (EXCEPT documented math formulas) |

## R Scripts (.R)

| Severity | Issue | Deduction |
|----------|-------|-----------|
| Critical | Syntax errors | -100 |
| Critical | Domain-specific bugs | -30 |
| Critical | Hardcoded absolute paths | -20 |
| Major | Missing set.seed() | -10 |
| Major | Missing figure generation | -5 |

## Python Scripts / Notebooks (.py, .ipynb)

| Severity | Issue | Deduction |
|----------|-------|-----------|
| Critical | Syntax errors | -100 |
| Critical | Domain-specific bugs | -30 |
| Critical | Hardcoded absolute paths | -20 |
| Major | Missing random seed | -10 |
| Major | Missing figure export | -5 |

## LaTeX Files (.tex)

| Severity | Issue | Deduction |
|----------|-------|-----------|
| Critical | Compilation failure | -100 |
| Critical | Undefined citation | -15 |
| Critical | Overfull hbox > 10pt | -10 |

## Enforcement

- **Score < 80:** Block commit. List blocking issues.
- **Score < 90:** Allow commit, warn. List recommendations.
- User can override with justification.

## Quality Reports

Generated **only at merge time**. Use `templates/quality-report.md` for format.
Save to `quality_reports/merges/YYYY-MM-DD_[branch-name].md`.

## Tolerance Thresholds (Research)

<!-- Customize for your domain -->

| Quantity | Tolerance | Rationale |
|----------|-----------|-----------|
| Point estimates | [e.g., 1e-6] | [Numerical precision] |
| Standard errors | [e.g., 1e-4] | [MC variability] |
| Coverage rates | [e.g., +/- 0.01] | [MC with B reps] |

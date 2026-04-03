---
paths:
  - "replications/**/*.py"
  - "replications/**/*.R"
  - "scripts/**/*.py"
  - "scripts/**/*.R"
  - "reports/**/*.md"
---

# Quality Gates & Scoring Rubrics

## Thresholds

- **80/100 = Commit** -- good enough to save
- **90/100 = PR** -- ready for deployment
- **95/100 = Excellence** -- aspirational

## Python Scripts (.py)

| Severity | Issue | Deduction |
|----------|-------|-----------|
| Critical | Syntax errors | -100 |
| Critical | Hardcoded absolute paths | -20 |
| Critical | Missing random seed for stochastic code | -15 |
| Critical | Results not saved (script produces no output files) | -15 |
| Major | Missing `requirements.txt` reference or `# requires:` comment | -10 |
| Major | `inplace=True` in pandas (silent failures) | -5 |
| Major | Missing dtype specification on `pd.read_csv()` | -5 |
| Major | Figure not saved at 300 DPI | -5 |
| Minor | Non-pathlib path construction (string concatenation) | -3 |
| Minor | Missing inline comment on Stata→Python translation decision | -2 |

## R Scripts (.R)

| Severity | Issue | Deduction |
|----------|-------|-----------|
| Critical | Syntax errors | -100 |
| Critical | Hardcoded absolute paths (not `here::here()`) | -20 |
| Critical | Missing `set.seed()` for stochastic code | -10 |
| Major | Missing figure generation where expected | -5 |
| Major | Results not saved as `.rds` | -5 |

## Replication Reports (.md)

| Severity | Issue | Deduction |
|----------|-------|-----------|
| Critical | Comparison table missing | -20 |
| Critical | Discrepancies present but not investigated | -15 |
| Major | Sample size not reported vs. paper | -10 |
| Major | Overall verdict (REPLICATED/PARTIAL/FAILED) missing | -10 |
| Minor | Environment section missing (R/Python version, package versions) | -5 |

## Enforcement

- **Score < 80:** Block commit. List blocking issues.
- **Score < 90:** Allow commit, warn. List recommendations.
- User can override with justification.

## Quality Reports

Generated **only at merge time**. Use `templates/quality-report.md` for format.
Save to `quality_reports/merges/YYYY-MM-DD_[branch-name].md`.

## Tolerance Thresholds (Replication)

| Quantity | Tolerance | Rationale |
|----------|-----------|-----------|
| Integers (N, events, counts) | Exact match | No reason for any difference |
| Point estimates (OR, HR, β, mean) | ±0.01 | Rounding in paper display |
| Standard errors | ±0.05 | Bootstrap/clustering variation |
| P-values | Same significance bracket (< 0.05, < 0.01, < 0.001) | Exact p may differ slightly |
| Percentages | ±0.1pp | Display rounding |

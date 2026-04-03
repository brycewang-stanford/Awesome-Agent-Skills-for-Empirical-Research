# Audit Report Template

Output structure for `quick-audit` and `gate` modes.

---

## Template

```markdown
# Paper Audit Report

**File**: `{file_path}` | **Language**: {language} | **Mode**: {mode}
**Generated**: {timestamp} | **Venue**: {venue or "general"}

---

## Executive Summary

Found **{total_issues} issues** ({critical_count} Critical, {major_count} Major, {minor_count} Minor).
Overall score: **{overall_score}/6.0** ({score_label}).

{verdict_line — only for gate mode: "**Verdict: PASS** / **Verdict: FAIL**"}

---

## Scores

| Dimension | Score | Issues (C/M/m) | Label |
|-----------|-------|-----------------|-------|
| Quality (30%) | {quality}/6.0 | {c}/{m}/{mi} | {label} |
| Clarity (30%) | {clarity}/6.0 | {c}/{m}/{mi} | {label} |
| Significance (20%) | {significance}/6.0 | {c}/{m}/{mi} | {label} |
| Originality (20%) | {originality}/6.0 | {c}/{m}/{mi} | {label} |
| **Overall** | **{overall}/6.0** | | **{label}** |

---

## Issues

### Critical (P0) — Must Fix

| # | Module | Line | Issue | Suggestion |
|---|--------|------|-------|------------|
| 1 | {MODULE} | {line} | {message} | {suggestion} |

### Major (P1) — Should Fix

| # | Module | Line | Issue | Suggestion |
|---|--------|------|-------|------------|
| 1 | {MODULE} | {line} | {message} | {suggestion} |

### Minor (P2) — Nice to Fix

| # | Module | Line | Issue | Suggestion |
|---|--------|------|-------|------------|
| 1 | {MODULE} | {line} | {message} | {suggestion} |

{If no issues in a severity level, show: "No {severity} issues found."}

---

## Pre-Submission Checklist

- [x] {passed item description}
- [ ] {failed item description} — {failure details}

{If venue specified, venue-specific items appear with [VENUE] prefix.}

---

## ScholarEval Assessment (if --scholar-eval)

| Dimension | Score | Weight | Source | Evidence |
|-----------|-------|--------|--------|----------|
| Soundness | {score}/10 | 20% | Script | — |
| Clarity | {score}/10 | 15% | Script | — |
| Presentation | {score}/10 | 10% | Script | — |
| Novelty | {score}/10 | 15% | LLM | {evidence or "N/A (awaiting LLM)"} |
| Significance | {score}/10 | 15% | LLM | {evidence or "N/A (awaiting LLM)"} |
| Reproducibility | {score}/10 | 10% | Mixed | {evidence} |
| Ethics | {score}/10 | 5% | LLM | {evidence or "N/A (awaiting LLM)"} |
| **Overall** | **{score}/10** | | | **{readiness_label}** |
```

---

## Format Guidelines

### Gate Mode Specifics

- Verdict is PASS only if: zero Critical issues AND all checklist items pass
- Blocking Issues section only appears on FAIL
- Non-blocking issues shown as informational only

### Severity Markers

| Severity | Priority | Score Deduction | Report Section |
|----------|----------|----------------|----------------|
| Critical | P0 | -1.5 | Must Fix |
| Major | P1 | -0.75 | Should Fix |
| Minor | P2 | -0.25 | Nice to Fix |

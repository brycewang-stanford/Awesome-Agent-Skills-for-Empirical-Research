# Audit Guide

How to use the paper-audit skill and interpret its results.

## Quick Start

```bash
# Basic quick audit
python scripts/audit.py paper.tex --mode quick-audit

# Deep review
python scripts/audit.py paper.tex --mode deep-review

# Quality gate (pass/fail)
python scripts/audit.py paper.pdf --mode gate --pdf-mode enhanced

# Chinese thesis
python scripts/audit.py thesis.tex --lang zh --venue thesis-zh
```

## Mode Selection Guide

| Scenario | Recommended Mode | Why |
|----------|-----------------|-----|
| "Is my paper ready to submit?" | `quick-audit` | Fast readiness analysis |
| "What would reviewers say?" | `deep-review` | Reviewer-style issue bundle and roadmap |
| "Can my student submit this?" | `gate` | Fast pass/fail check |
| "Quick sanity check before deadline" | `gate` | Fastest, checks essentials only |
| "I want detailed feedback" | `deep-review` | Most comprehensive output |

## Understanding the Report

### Quick-Audit Report

The quick-audit report contains:

1. **Executive Summary**: Overall score and issue count at a glance
2. **Scores Table**: Per-dimension scores with issue counts (Critical/Major/Minor)
3. **Issues List**: All findings sorted by severity
4. **Pre-Submission Checklist**: Pass/fail for each checklist item

**How to read scores**:
- **5.0+**: Excellent — minor polish only
- **4.0-5.0**: Good — address Major issues
- **3.0-4.0**: Needs work — significant revisions required
- **< 3.0**: Major concerns — consider restructuring

### Deep Review Report

The deep review report adds:
- **Overall Assessment**: short calibrated reviewer summary
- **Major / Moderate / Minor Issues**: quote-anchored structured findings
- **Revision Roadmap**: prioritized fix list
- **Recommendation**: score summary, if requested

### Gate Report

Binary verdict:
- **PASS**: All mandatory checks passed, no critical issues
- **FAIL**: Blocking issues found — must fix before submission

## PDF Input Considerations

PDF mode has inherent limitations:

| Feature | LaTeX/Typst | PDF Basic | PDF Enhanced |
|---------|-------------|-----------|-------------|
| Section detection | Exact | Heuristic | Good |
| Math verification | Full | Unavailable | Unavailable |
| Format checking | Full | Skipped | Skipped |
| Figure references | Full | Skipped | Skipped |
| Grammar analysis | Full | Good | Good |
| Logic analysis | Full | Good | Good |
| Bibliography | Full | Skipped | Skipped |

**Recommendation**: Use source files (.tex/.typ) whenever possible for maximum accuracy. Use PDF mode for quick reviews when source is unavailable.

## Addressing Issues

### Priority Order
1. **Critical (P0)**: Must fix — these will likely cause rejection
2. **Major (P1)**: Should fix — these weaken the paper significantly
3. **Minor (P2)**: Nice to fix — these improve polish

### Common Critical Issues
- Missing figure/table references
- Compilation errors
- Placeholder text (TODO/FIXME)
- Author names in blind submission

### Common Major Issues
- Long, convoluted sentences
- Logic gaps in methodology
- Missing baselines or ablations
- AI-trace patterns in writing

### Common Minor Issues
- Minor grammar issues
- Inconsistent notation
- Style guide violations

## Re-auditing After Fixes

After addressing issues, re-run the audit to verify improvements:

```bash
# Before fixes
python scripts/audit.py paper.tex -o report_before.md

# After fixes
python scripts/audit.py paper.tex -o report_after.md
```

Compare scores to track improvement.

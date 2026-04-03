# Revision Roadmap Template

Prioritized action plan generated from audit findings and review assessments.

---

## Template

```markdown
# Revision Roadmap

**Paper**: `{file_path}` | **Date**: {timestamp}
**Based on**: {mode} audit {+ multi-perspective review if applicable}
**Overall Score**: {overall}/6.0 ({score_label})

---

## Priority 1 — Must Address (Blocking)

Issues that must be resolved before submission. Correspond to Critical severity findings.

| # | Task | Source | Section | Est. Effort |
|---|------|--------|---------|-------------|
| R1 | {Specific revision task} | {Module or Reviewer} | {Section X.X} | {hours/days} |
| R2 | {Specific revision task} | {Module or Reviewer} | {Section X.X} | {hours/days} |

### R1: {Task title}
- **Problem**: {What is wrong}
- **Source**: {Which check or reviewer identified this}
- **Requirement**: {What needs to change}
- **Acceptance criteria**: {How to verify it is fixed}

### R2: {Task title}
- **Problem**: {description}
- **Source**: {source}
- **Requirement**: {what to do}
- **Acceptance criteria**: {verification}

---

## Priority 2 — Strongly Recommended

Issues that significantly improve paper quality. Correspond to Major severity findings.

| # | Task | Source | Section | Est. Effort |
|---|------|--------|---------|-------------|
| S1 | {Specific revision task} | {Module or Reviewer} | {Section X.X} | {hours/days} |
| S2 | {Specific revision task} | {Module or Reviewer} | {Section X.X} | {hours/days} |

---

## Priority 3 — Optional Improvements

Style, formatting, and minor issues. Correspond to Minor severity findings.

- [ ] {Minor task — from GRAMMAR, SENTENCES, FORMAT, etc.}
- [ ] {Minor task}
- [ ] {Minor task}

---

## Revision Checklist

### Priority 1 (Must Fix)
- [ ] R1: {task}
- [ ] R2: {task}

### Priority 2 (Should Fix)
- [ ] S1: {task}
- [ ] S2: {task}

### Priority 3 (Nice to Fix)
- [ ] {task}
- [ ] {task}

---

## Estimated Total Effort

| Priority | Items | Est. Time |
|----------|-------|-----------|
| Priority 1 | {count} | ~{X} hours |
| Priority 2 | {count} | ~{Y} hours |
| Priority 3 | {count} | ~{Z} hours |
| **Total** | **{total}** | **~{sum} hours** |

---

## Revision Deadline Guidance

- **Minor Revision scope** (P1 only): 1-2 weeks
- **Major Revision scope** (P1 + P2): 4-6 weeks
- **Full Revision scope** (P1 + P2 + P3): 6-8 weeks

---

## Re-Audit Instructions

After completing revisions, run:
```bash
python audit.py {file_path} --mode re-audit --previous-report {this_report_path}
```

This will verify each item against the revised paper and report:
- FULLY_ADDRESSED / PARTIALLY_ADDRESSED / NOT_ADDRESSED per item
- Any new issues introduced during revision
- Updated scores for comparison
```

---

## Design Principles

1. **Actionability**: Every item is a concrete task, not a vague comment
2. **Traceability**: Every item links back to the source check or reviewer
3. **Prioritization**: P1 > P2 > P3, reflecting impact on paper quality
4. **Time estimation**: Helps authors plan their revision schedule
5. **Verifiability**: Each P1 item has acceptance criteria
6. **Compatibility**: Format works as input for re-audit mode verification

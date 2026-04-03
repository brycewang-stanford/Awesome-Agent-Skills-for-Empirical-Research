---
name: submit
description: Final submission verification gate for the sewage-house-prices paper. Runs full paper excellence review, replication audit, enforces score gates, and generates cover letter draft and submission checklist. This skill should be used when asked to "submit", "prepare for submission", or "submission checklist".
argument-hint: "[journal name (optional)]"
allowed-tools: ["Read", "Grep", "Glob", "Write", "Bash", "Agent"]
---

# Submit

Final submission gate combining full verification, score enforcement, and submission checklist.

**Input:** `$ARGUMENTS` — target journal name (optional).

---

## Workflow

### Step 1: Pre-Flight Checks

1. Verify manuscript exists at `docs/overleaf/_main.tex`
2. Check for existing quality reports in `output/log/`
3. Verify analysis outputs exist in `output/tables/` and `output/figures/`
4. Check `Replication/` directory exists (if not, flag for `/data-deposit`)

### Step 2: Run Full Verification

If `/paper-excellence` hasn't been run recently (check report dates in `output/log/`):
- Run the full paper excellence review (econometrics, code, paper, bibliography)

### Step 3: Run Replication Audit

If `Replication/` exists:
- Run `/audit-replication Replication/`

### Step 4: Score Gate

Check against thresholds:

| Requirement | Threshold | Status |
|-------------|-----------|--------|
| Aggregate score | >= 90 | PASS/FAIL |
| Econometrics component | >= 80 | PASS/FAIL |
| Code component | >= 80 | PASS/FAIL |
| Paper component | >= 80 | PASS/FAIL |
| Replication (if exists) | >= 8/10 checks | PASS/FAIL |

**If any requirement FAILS:** List specific blocking issues and stop. Do not generate submission materials.

### Step 5: Generate Submission Package

If all gates pass:

1. **Cover letter draft** (save to `output/log/cover_letter_[journal]_[date].tex`):
   - Addressed to current editor
   - 1 paragraph: what the paper does (sewage spill capitalisation using EDM data)
   - 1 paragraph: why this journal (fit with environmental/housing economics)
   - 1 paragraph: originality confirmation
   - Suggested referees (3-5, from `/target-journal` if available)

2. **Final checklist** (save to `output/log/submission_checklist_[date].md`):
   ```markdown
   # Submission Checklist: [Journal]

   ## Manuscript
   - [ ] Title page with affiliations and contact info
   - [ ] Abstract within word limit
   - [ ] JEL codes (2-3): Q53, R31, Q58
   - [ ] Keywords: sewage spills, house prices, hedonic pricing, environmental disamenity, EDM
   - [ ] Journal formatting guidelines followed

   ## Data and Code
   - [ ] Replication package assembled
   - [ ] Data availability statement in manuscript
   - [ ] Restricted data flagged (Land Registry, Zoopla)

   ## Quality Gates
   - [ ] Aggregate score: XX/100 (>= 90 required)
   - [ ] All components >= 80
   - [ ] No unresolved CRITICAL issues

   ## Submission
   - [ ] Upload manuscript PDF
   - [ ] Upload replication package (if required)
   - [ ] Upload cover letter
   - [ ] Submit via [portal]
   ```

### Step 6: Present Results

```markdown
# Submission Report
**Date:** YYYY-MM-DD
**Target Journal:** [name]
**Aggregate Score:** XX/100

## Gate Status: [PASS / FAIL]

| Component | Score | Threshold | Status |
|-----------|-------|-----------|--------|
| Aggregate | XX | >= 90 | ... |
| Econometrics | XX | >= 80 | ... |
| Code | XX | >= 80 | ... |
| Paper | XX | >= 80 | ... |
| Replication | X/10 | >= 8/10 | ... |

## Generated Materials
- Cover letter: output/log/cover_letter_*.tex
- Checklist: output/log/submission_checklist_*.md

## Remaining Steps (manual)
1. Review and customise cover letter
2. Upload to [submission portal]
3. Enter suggested referees
4. Submit
```

---

## Principles

- **This is the final gate.** Score >= 90 with all components >= 80.
- **If it fails, stop.** List blocking issues. Don't generate submission materials for a failing paper.
- **Cover letter is a draft.** The user must review and customise before sending.
- **Manual submission.** This skill prepares materials but does NOT submit to journals.
- **Be realistic.** If the paper isn't ready, say so clearly.

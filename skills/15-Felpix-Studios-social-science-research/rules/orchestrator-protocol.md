---
description: After plan approval, run autonomously. Code track fixes and retries; prose track proposes changes and waits for approval.
paths: ["**/*"]
---

# Orchestrator Protocol

**After a plan is approved, the orchestrator takes over and runs autonomously until done.**

---

## Choose the Right Track

The track is determined by what you're working on:

| Track | Applies When Working In | Approach |
|-------|------------------------|----------|
| **Code Track** | `scripts/`, `notebooks/`, `output/`, `.R`, `.py`, `.ipynb` | Autonomous — implement, verify, fix, commit |
| **Prose Track** | `manuscripts/`, `.tex` drafts, `.qmd` manuscripts | Propose-first — never edit without user approval |

---

## Code Track (Analysis Scripts)

Simple 3-step loop. No multi-agent reviews. Fix and move on.

```
IMPLEMENT → VERIFY → SCORE
     ↑______________|  (if score < 80, fix and re-verify; max 2 retries)
```

**Step 1 — IMPLEMENT:** Execute the plan steps.

**Step 2 — VERIFY:** Run the script. Check exit code. Verify output files exist and have size > 0. See `rules/analysis-verification.md` for the full checklist.

**Step 3 — SCORE:** Apply the quality-gates rubric for the file type. Score >= 80 → present to user. Score < 80 → fix the blocking issues and re-verify (max 2 retries). After 2 retries, present with remaining issues listed.

---

## Prose Track (Paper & Manuscript Writing)

Full review loop with propose-first. The agent NEVER applies edits without approval.

```
IMPLEMENT → VERIFY → REVIEW → FIX (proposed) → USER APPROVES → APPLY → RE-VERIFY → SCORE
                        ↑___________________________|  (max 5 rounds)
```

**Step 1 — IMPLEMENT:** Draft or revise the manuscript section.

**Step 2 — VERIFY:** Check that the file is valid (no broken LaTeX syntax, renders without error if applicable).

**Step 3 — REVIEW:** Run the appropriate review agent(s):
- `proofreader` — grammar, typos, layout issues, consistency
- `domain-reviewer` — argument structure, identification claims, citation fidelity

**Step 4 — PROPOSE FIXES:** Present all proposed changes to the user. Do NOT apply any edit yet.

**Step 5 — WAIT FOR APPROVAL:** Only after the user approves (all or selectively) does the agent apply edits.

**Step 6 — RE-VERIFY & SCORE:** Confirm approved edits applied cleanly. Score >= 90 for PR readiness. Present summary.

**Max rounds:** 5 review-fix cycles. After max rounds, present with remaining issues listed.

---

## Shared Rules

### Quality Thresholds
- **80/100** = commit (code track gate)
- **90/100** = PR-ready (prose track target)
- **95/100** = excellence (aspirational)

### "Just Do It" Mode
When the user says "just do it" or "handle it":
- Skip the final approval pause before committing
- Auto-commit if score >= 80 (code track) or user has pre-approved the prose approach
- Still run the full verify → review → fix loop
- Still present a summary when done

### Never
- Never loop indefinitely
- Never apply prose edits without explicit user approval
- Never skip verification after making fixes

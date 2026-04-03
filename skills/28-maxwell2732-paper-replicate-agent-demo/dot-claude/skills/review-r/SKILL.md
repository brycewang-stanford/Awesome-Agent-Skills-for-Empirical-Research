---
name: review-r
description: Run the R code review protocol on R scripts. Checks code quality, reproducibility, domain correctness, and professional standards. Produces a report without editing files.
disable-model-invocation: true
argument-hint: "[filename or 'all' or 'LectureN']"
allowed-tools: ["Read", "Grep", "Glob", "Write", "Task"]
---

# Review R Scripts

Run the comprehensive R code review protocol.

## Steps

1. **Identify scripts to review:**
   - If `$ARGUMENTS` is a specific `.R` filename: review that file only
   - If `$ARGUMENTS` is `LectureN`: review all R scripts matching that lecture
   - If `$ARGUMENTS` is `all`: review all R scripts in `scripts/R/` and `Figures/*/`

2. **For each script, launch the `r-reviewer` agent** with instructions to:
   - Follow the full protocol in the agent instructions
   - Read `.claude/rules/r-code-conventions.md` for current standards
   - Save report to `quality_reports/[script_name]_r_review.md`

3. **After all reviews complete**, present a summary:
   - Total issues found per script
   - Breakdown by severity (Critical / High / Medium / Low)
   - Top 3 most critical issues

4. **IMPORTANT: Do NOT edit any R source files.**
   Only produce reports. Fixes are applied after user review.

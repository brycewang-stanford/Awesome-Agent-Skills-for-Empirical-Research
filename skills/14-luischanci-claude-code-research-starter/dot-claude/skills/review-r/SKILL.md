---
name: review-r
description: Run the R code review protocol on R scripts. Checks code quality, reproducibility, domain correctness, and professional standards. Produces a report without editing files.
disable-model-invocation: true
argument-hint: "[filename or 'all']"
allowed-tools: ["Read", "Grep", "Glob", "Write", "Task"]
---

## Review R Code

Run a comprehensive R code review on the specified script(s). **Do NOT edit any R source files** -- produce a report only.

### Steps

1. **Identify target**: Use `$ARGUMENTS` to find the R file(s). If `all`, scan all `.R` files in `scripts/` and project subdirectories.

2. **Launch r-reviewer agent** following the full protocol from `.claude/agents/r-reviewer.md`.

3. **Read standards** from `.claude/rules/r-code-conventions.md`.

4. **Check 10 categories**: Structure & Header, Console Output Hygiene, Reproducibility, Function Design, Domain Correctness, Figure Quality, RDS Data Pattern, Comment Quality, Error Handling, Professional Polish.

5. **Save report** to `quality_reports/[script_name]_r_review.md`.

6. **Present summary**: Total issues per script, severity breakdown (Critical/High/Medium/Low), top 3 critical issues.

### Important
- **NEVER edit source files.** Report only.
- Prioritize correctness over style.

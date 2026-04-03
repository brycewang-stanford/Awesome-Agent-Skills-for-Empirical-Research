# Workflow Quick Reference

**Model:** Contractor (you direct, Claude orchestrates)

---

## The Loop

```
Your instruction
    ↓
[PLAN] (if multi-file or unclear) → Show plan → Your approval
    ↓
[EXECUTE] Implement, verify, done
    ↓
[REPORT] Summary + what's ready
    ↓
Repeat
```

---

## I Ask You When

- **Design forks:** "Option A (fast) vs. Option B (robust). Which?"
- **Code ambiguity:** "Spec unclear on X. Assume Y?"
- **Replication edge case:** "Just missed tolerance. Investigate?"
- **Scope question:** "Also refactor Y while here, or focus on X?"

---

## I Just Execute When

- Code fix is obvious (bug, pattern application)
- Verification (tolerance checks, tests, compilation)
- Documentation (logs, commits)
- Plotting (per established standards)
- Deployment (after you approve, I ship automatically)

---

## Quality Gates (No Exceptions)

| Score | Action |
|-------|--------|
| >= 80 | Ready to commit |
| < 80  | Fix blocking issues |

---

## Non-Negotiables

- **Path convention:** `pathlib.Path` for Python; `here::here()` for R; always relative paths
- **Seed convention:** `random.seed(YYYYMMDD)` + `numpy.random.seed(YYYYMMDD)` at top of every stochastic Python script; `set.seed(YYYYMMDD)` at top of every stochastic R script
- **Figure standards:** 300 DPI, white or transparent background, journal-quality axes, colorblind-safe palette
- **Color palette:** `viridis` / `colorblind` R palette; Okabe-Ito palette for Python (`matplotlib`)
- **Tolerance thresholds:** integers exact; point estimates ±0.01; SEs ±0.05; p-values same significance bracket; percentages ±0.1pp

---

## Preferences

**Visual:** 300 DPI, Okabe-Ito palette, `bbox_inches='tight'` for Python figures
**Reporting:** Structured Markdown report with comparison tables (paper value vs. ours vs. diff)
**Session logs:** Always (post-plan, incremental, end-of-session)
**Replication:** Flag all near-misses (within 2× tolerance); investigate before proceeding to extensions

---

## Exploration Mode

For experimental work, use the **Fast-Track** workflow:
- Work in `explorations/` folder
- 60/100 quality threshold (vs. 80/100 for production)
- No plan needed — just a research value check (2 min)
- See `.claude/rules/exploration-fast-track.md`

---

## Next Step

You provide task → I plan (if needed) → Your approval → Execute → Done.

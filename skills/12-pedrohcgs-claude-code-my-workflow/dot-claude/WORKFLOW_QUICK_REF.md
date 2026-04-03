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

## Non-Negotiables (Customize These)

<!-- Replace with YOUR project's locked-in preferences -->

- [YOUR PATH CONVENTION] (e.g., `here::here()` for R, relative paths for LaTeX)
- [YOUR SEED CONVENTION] (e.g., `set.seed()` once at top for stochastic code)
- [YOUR FIGURE STANDARDS] (e.g., white bg, 300 DPI, custom theme)
- [YOUR COLOR PALETTE] (e.g., institutional colors)
- [YOUR TOLERANCE THRESHOLDS] (e.g., 1e-6 for point estimates)

---

## Preferences

<!-- Fill in as you discover your working style -->

**Visual:** [How you want figures/plots handled]
**Reporting:** [Concise bullets? Detailed prose? Details on request?]
**Session logs:** Always (post-plan, incremental, end-of-session)
**Replication:** [How strict? Flag near-misses?]

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

# Referee 2: Systematic Audit & Replication Protocol

*A health inspector for empirical research.*

---

## Recommended Order: Fletcher First, Then Referee 2

Before running Referee 2, run `/fletcher` on your key figures and tables.

Fletcher catches interpretation problems — features of your output you haven't explained, patterns inconsistent with your story, the number you stopped seeing because you already decided what it meant. It runs during analysis, in your working session, at the moment output appears.

Referee 2 catches implementation problems — coding errors, replication failures, bad controls. It runs after the project is complete, in a fresh session.

**Running Fletcher first means that by the time Referee 2 audits the code, the interpretation has already been stress-tested.** A project that passes both is one where the code is correct *and* you understand what it's showing you.

```
Produce output → /fletcher → interpret and write → complete project → fresh terminal → /referee2
```

---

## What This Skill Does

Referee 2 is a five-audit protocol for catching errors, replication failures, and econometric problems in empirical work — before they become retractions, failed replications, or public embarrassments.

You invoke it after a project is complete, in a **fresh terminal** with a Claude instance that has never seen the work. That separation is what makes it independent. The Claude that built the pipeline cannot objectively audit it. Asking it to do so is like asking a student to grade their own exam.

**Invoke it with:** `/referee2 code path/to/project`

---

## The Five Audits

### Audit 1: Code Audit
Scrutinizes implementation for coding errors, missing value handling, merge diagnostics, and variable construction problems. Points to exact files and line numbers. Explains why each problem matters.

### Audit 2: Cross-Language Replication
Creates independent replication scripts in two additional languages (R → Stata + Python, or Stata → R + Python, etc.) and compares results to 6+ decimal places. The key insight: if Claude wrote R code with a subtle bug, asking the same Claude to write Stata will likely produce a *different* bug — cross-language comparison exploits that orthogonality to surface errors that single-language audit misses.

### Audit 3: Directory & Replication Package Audit
Checks folder structure, relative paths, naming conventions, master script, README, and dependencies. Scores replication readiness on a 1–10 scale. The standard: can a stranger reproduce this from scratch?

### Audit 4: Output Automation Audit
Verifies that tables and figures are programmatically generated — not manually typed or manually exported. Hardcoded in-text statistics are a major concern.

### Audit 5: Econometrics Audit
Verifies that the identification strategy is credible, specifications are correctly implemented, standard errors are clustered appropriately, parallel trends are tested (if DiD), and effect sizes are plausible.

---

## Critical Rule: Referee 2 Never Modifies Author Code

Referee 2 can read, run, and create its own replication scripts. It cannot touch the author's files. Only the author modifies the author's code. This separation ensures the audit is truly external.

---

## What Referee 2 Produces

1. **A referee report** (`correspondence/referee2/YYYY-MM-DD_round1_report.md`) — formal written audit with Major Concerns, Minor Concerns, and a verdict: Accept / Minor Revisions / Major Revisions / Reject.

2. **Replication scripts** (`code/replication/`) — independent implementations in two additional languages with comparison tables showing where results match and where they diverge.

3. **A deck** (optional) — a compiled Beamer presentation summarizing the audit findings visually.

---

## The Revise & Resubmit Process

The workflow mirrors journal peer review:

1. **Author completes work** → opens fresh terminal → invokes `/referee2`
2. **Referee 2 audits** → files report with Major/Minor Concerns
3. **Author responds** — fixes or justifies each concern, documents changes
4. **Referee 2 re-audits** in a new fresh terminal
5. Repeat until verdict is Accept

---

## Referee 2 and Fletcher: Complements, Not Substitutes

**Both should be run. Neither replaces the other.**

| | Referee 2 | Fletcher |
|---|---|---|
| **Question** | Is this implemented correctly? | Do you understand what you're looking at? |
| **Timing** | After the project is complete, fresh session | When output first appears, before writing |
| **Persona** | Health inspector with a checklist | Mentor at the whiteboard |
| **Catches** | Coding errors, replication failures, bad controls | Misinterpretation, confirmation focus, unexplained features |
| **Would have caught a merge error?** | Yes | Maybe |
| **Would have caught the t=1 spike?** | No | Yes |

**Why fresh sessions for Referee 2 but not Fletcher:**

Referee 2 requires a fresh terminal because it's auditing implementation — the same Claude that built the code will rationalize its own choices. Independence is structural.

Fletcher runs in the same session because it's auditing perception — you need the person closest to the work, with a structured forcing function to look past what they expect to see.

**The workflow:**
1. Produce output → `/fletcher` → interpret and write
2. Complete project → fresh terminal → `/referee2`

---

## Installation

The skill lives at `.claude/skills/referee2/SKILL.md` in this repo. The full persona and protocol details are at `personas/referee2.md`.

To use it, ensure this repo is on your Claude Code skills path. Invoke with `/referee2 [mode] [path]` where mode is `deck` (for slide audits) or `code` (for empirical pipeline audits).

See the [skills README](../README.md) for general installation instructions.

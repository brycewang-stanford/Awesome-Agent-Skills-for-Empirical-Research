---
description: Enter plan mode before non-trivial tasks. Get user approval, then execute. Save plans to quality_reports/plans/.
paths: ["**/*"]
---

# Plan-First Workflow

**For any non-trivial task, enter plan mode before writing code.**

## The Protocol

1. **Enter Plan Mode** — use `EnterPlanMode`
2. **Read the most recent session log** in `quality_reports/session_logs/` for relevant context
3. **Requirements Specification (for complex/ambiguous tasks)** — see below
4. **Draft the plan** — what changes, which files, in what order
5. **Save to disk** — write to `quality_reports/plans/YYYY-MM-DD_short-description.md`
6. **Present to user** — wait for approval
7. **Exit plan mode** — only after approval
8. **Save initial session log** — create `quality_reports/session_logs/YYYY-MM-DD_short-description.md` using `templates/session-log.md` as the format. Fill in:
   - **Objective:** the goal from the approved plan
   - **Changes Made:** leave empty (will be filled during implementation)
   - **Design Decisions:** record any decisions made during planning, one per line prefixed with `Decision:` (e.g., `Decision: Using DiD instead of IV because parallel trends hold`)
9. **Implement via orchestrator** — see `orchestrator-protocol.md`

## Step 3: Requirements Specification (For Complex/Ambiguous Tasks)

**When to use:**
- Task is high-level or vague ("improve the paper", "analyze the data")
- Multiple valid interpretations exist
- Significant effort required (>1 hour or >3 files)

**When to skip:**
- Task is clear and specific ("fix typo in line 42")
- Simple single-file edit
- User has already provided detailed requirements

**Protocol:**
1. Use AskUserQuestion to clarify ambiguities (max 3-5 questions)
2. Create `quality_reports/specs/YYYY-MM-DD_description.md` using `templates/requirements-spec.md`
3. Mark each requirement:
   - **MUST** (non-negotiable)
   - **SHOULD** (preferred)
   - **MAY** (optional)
4. Declare clarity status for each major aspect:
   - **CLEAR:** Fully specified
   - **ASSUMED:** Reasonable assumption (user can override)
   - **BLOCKED:** Cannot proceed until answered
5. Get user approval on spec
6. THEN proceed to Step 4 (draft the plan) with spec as input

**Template:** `templates/requirements-spec.md`

**Why this helps:** Catches ambiguity BEFORE planning. Reduces mid-plan pivots by 30-50%.

## Plans on Disk

Plans survive context compression. Save every plan to:

```
quality_reports/plans/YYYY-MM-DD_short-description.md
```

Format: Status (DRAFT/APPROVED/COMPLETED), approach, files to modify, verification steps.

## Context Management

### General Principles
- Prefer auto-compression over `/clear`
- Save important context to disk before it's lost
- `/clear` only when context is genuinely polluted

### Context Survival Strategy

**Before Auto-Compression:**
When approaching context limits, ensure:
1. Session log is current — update the session log in `quality_reports/session_logs/` with new decisions as work progresses. Prefix each decision line with `Decision:` so compact hooks can extract them
2. Active plan is saved to disk
3. Open questions are documented in session log

The pre-compact hook will remind you of this checklist.

**After Compression:**
First message should be: "Resuming after compression. Last task: [read most recent plan + git log]. Status: [next step]."

## Session Recovery

After compression or new session:
1. Read `CLAUDE.md` + most recent plan in `quality_reports/plans/`
2. Check `git log --oneline -10` and `git diff`
3. State what you understand the current task to be

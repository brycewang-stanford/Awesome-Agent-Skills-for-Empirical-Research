# Plan-First Workflow

**For any non-trivial task, enter plan mode before writing code.**

## The Protocol

1. **Enter Plan Mode** -- use `EnterPlanMode`
2. **Check MEMORY.md** -- read any `[LEARN]` entries relevant to this task
3. **Draft the plan** -- what changes, which files, in what order
4. **Save to disk** -- write to `quality_reports/plans/YYYY-MM-DD_short-description.md`
5. **Present to user** -- wait for approval
6. **Exit plan mode** -- only after approval
7. **Save initial session log** -- capture goal and key context while fresh
8. **Implement via orchestrator** -- see `orchestrator-protocol.md`

## Plans on Disk

Plans survive context compression. Save every plan to:

```
quality_reports/plans/YYYY-MM-DD_short-description.md
```

Format: Status (DRAFT/APPROVED/COMPLETED), approach, files to modify, verification steps.

## Context Management

- Prefer auto-compression over `/clear`
- Save important context to disk before it's lost
- `/clear` only when context is genuinely polluted

## Session Recovery

After compression or new session:
1. Read `CLAUDE.md` + most recent plan in `quality_reports/plans/`
2. Check `git log --oneline -10` and `git diff`
3. State what you understand the current task to be

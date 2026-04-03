---
name: handoff
description: Writes a session handoff report to handoffs/ with project state, work done, decisions, and next steps. Use at session end or after significant work.
allowed-tools: Bash, Read, Write, Glob, Grep
---

# Write Handoff Report

Write a session handoff report to preserve context across sessions.

## Steps

1. Check the most recent file in `handoffs/` to understand prior state
2. Create a new file in `handoffs/` named with today's date and time: `YYYYMMDD_HHMM.md`
3. Include these sections:
   - **Project State** — one paragraph summarizing current status
   - **Work Completed** — bullet list of what was done this session with key results
   - **Decisions Made** — any choices and their rationale
   - **Open Issues** — blockers or unresolved items
   - **Next Steps** — concrete actions for the next session
4. Verify the file was saved and summarize next steps to the user

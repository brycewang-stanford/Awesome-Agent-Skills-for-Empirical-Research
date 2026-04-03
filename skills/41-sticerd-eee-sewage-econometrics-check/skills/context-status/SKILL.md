---
name: context-status
description: |
  Show current session status and context health for the sewage project.
  Use to check context usage, active work state, and what will survive compaction.
allowed-tools: ["Bash", "Read", "Glob"]
---

# Context Status

Show current session status including context usage estimate and project state.

## Workflow

### Step 1: Check Session State

```bash
# Recent git activity
git log --oneline -5

# Working tree status
git status --short

# Recent output files
ls -lt output/log/ 2>/dev/null | head -5
```

### Step 2: Check Project Progress

```bash
# Count analysis scripts
find scripts/R/09_analysis/ -name "*.R" | wc -l

# Count output tables and figures
ls output/tables/*.tex 2>/dev/null | wc -l
ls output/figures/ 2>/dev/null | wc -l

# Check manuscript sections
ls docs/overleaf/*.tex 2>/dev/null
```

### Step 3: Report Status

Format output:

```
Session Status
---
Recent commits: [last 3]
Uncommitted changes: [count]
Recent reports: [last 3 in output/log/]

Project Progress
---
Pipeline scripts: N
Analysis scripts: N
Output tables: N
Output figures: N
Manuscript sections: N .tex files

Memory Files
---
[List files in .claude/projects/.../memory/]
```

## Notes

- Context usage is estimated from conversation length
- All important state is saved to disk (memory files, output/log/)
- Use `/commit` to save work before context compaction

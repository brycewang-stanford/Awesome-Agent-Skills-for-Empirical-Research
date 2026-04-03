---
name: deep-audit
description: |
  Deep consistency audit of the entire repository infrastructure.
  Launches 4 parallel specialist agents to find factual errors, code bugs,
  count mismatches, and cross-document inconsistencies. Then fixes all issues
  and loops until clean.
  Use when: after making broad changes, before releases, or when user says
  "audit", "find inconsistencies", "check everything".
author: Claude Code Academic Workflow
version: 1.0.0
allowed-tools: ["Read", "Write", "Edit", "Bash", "Glob", "Grep", "Task"]
---

# /deep-audit — Repository Infrastructure Audit

Run a comprehensive consistency audit across the entire repository, fix all issues found, and loop until clean.

## When to Use

- After broad changes (new skills, rules, hooks, guide edits)
- Before releases or major commits
- When the user asks to "find inconsistencies", "audit", or "check everything"

## Workflow

### PHASE 1: Launch 4 Parallel Audit Agents

Launch these 4 agents simultaneously using `Task` with `subagent_type=general-purpose`:

#### Agent 1: Guide Content Accuracy
Focus: `guide/workflow-guide.qmd`
- All numeric claims match reality (skill count, agent count, rule count, hook count)
- All file paths mentioned actually exist on disk
- All skill/agent/rule names match actual directory names
- Code examples are syntactically correct
- Cross-references and anchors resolve
- No stale counts from previous versions

#### Agent 2: Hook Code Quality
Focus: `.claude/hooks/*.py` and `.claude/hooks/*.sh`
- No remaining `/tmp/` usage (should use `~/.claude/sessions/`)
- Hash length consistency (`[:8]` across all hooks)
- Proper error handling (fail-open pattern: top-level `try/except` with `sys.exit(0)`)
- JSON input/output correctness (stdin for input, stdout/stderr for output)
- Exit code correctness (0 for non-blocking, non-zero only when intentionally blocking)
- `from __future__ import annotations` for Python 3.8+ compatibility
- Correct field names from hook input schema (`source` not `type` for SessionStart)
- PreCompact hooks print to stderr (stdout is ignored)

#### Agent 3: Skills and Rules Consistency
Focus: `.claude/skills/*/SKILL.md` and `.claude/rules/*.md`
- Valid YAML frontmatter in all files
- No stale `disable-model-invocation: true`
- `allowed-tools` values are sensible
- Rule `paths:` reference existing directories
- No contradictions between rules
- CLAUDE.md skills table matches actual skill directories 1:1
- All templates referenced in rules/guide exist in `templates/`

#### Agent 4: Cross-Document Consistency
Focus: `README.md`, `docs/index.html`, `docs/workflow-guide.html`
- All feature counts agree across all 3 documents
- All links point to valid targets
- License section matches LICENSE file
- Directory tree matches actual structure
- No stale counts from previous versions

### PHASE 2: Triage Findings

Categorize each finding:
- **Genuine bug**: Fix immediately
- **False alarm**: Discard (document WHY it's false for future rounds)

Common false alarms to watch for:
- Quarto callout `## Title` inside `:::` divs — this is standard syntax, NOT a heading bug
- `allowed-tools` linter warning — known linter bug (Claude Code issue #25380), field IS valid
- Counts in old session logs — these are historical records, not user-facing docs

### PHASE 3: Fix All Issues

Apply fixes in parallel where possible. For each fix:
1. Read the file first (required by Edit tool)
2. Apply the fix
3. Verify the fix (grep for stale values, check syntax)

### PHASE 4: Re-render if Guide Changed

If `guide/workflow-guide.qmd` was modified:
```bash
quarto render guide/workflow-guide.qmd
cp guide/workflow-guide.html docs/workflow-guide.html
```

### PHASE 5: Loop or Declare Clean

After fixing, launch a fresh set of 4 agents to verify.
- If new issues found → fix and loop again
- If zero genuine issues → declare clean and report summary

**Max loops: 5** (to prevent infinite cycling)

## Key Lessons from Past Audits

These are real bugs found across 7 rounds — check for these specifically:

| Bug Pattern | Where to Check | What Went Wrong |
|-------------|---------------|-----------------|
| Stale counts ("19 skills" → "21") | Guide, README, landing page | Added skills but didn't update all mentions |
| Hook exit codes | All Python hooks | Exit 2 in PreCompact silently discards stdout |
| Hook field names | post-compact-restore.py | SessionStart uses `source`, not `type` |
| State in /tmp/ | All Python hooks | Should use `~/.claude/sessions/<hash>/` |
| Hash length mismatch | All Python hooks | Some used `[:12]`, others `[:8]` |
| Missing fail-open | Python hooks `__main__` | Unhandled exception → exit 1 → confusing behavior |
| Python 3.10+ syntax | Type hints like `dict | None` | Need `from __future__ import annotations` |
| Missing directories | quality_reports/specs/ | Referenced in rules but never created |
| Always-on rule listing | Guide + README | meta-governance omitted from listings |
| macOS-only commands | Skills, rules | `open` without `xdg-open` fallback |
| Protected file blocking | settings.json edits | protect-files.sh blocks Edit/Write |

## Output Format

After each round, report:

```
## Round N Audit Results

### Issues Found: X genuine, Y false alarms

| # | Severity | File | Issue | Status |
|---|----------|------|-------|--------|
| 1 | Critical | file.py:42 | Description | Fixed |
| 2 | Medium | file.qmd:100 | Description | Fixed |

### Verification
- [ ] No stale counts (grep confirms)
- [ ] All hooks have fail-open + future annotations
- [ ] Guide renders successfully
- [ ] docs/ updated

### Result: [CLEAN | N issues remaining]
```

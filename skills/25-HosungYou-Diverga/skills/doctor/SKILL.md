---
name: doctor
description: |
  System diagnostics and health checks for Diverga plugin.
  OpenClaw-style Check-Report-Fix pattern with 5-layer diagnostics.
  Triggers: /diverga:doctor, diverga doctor, system check, diagnose, 진단
version: "12.0.1"
---

# Diverga Doctor

**Version**: 11.1.0
**Trigger**: `/diverga:doctor`

## Description

System diagnostics for the Diverga plugin. Checks plugin health, skill sync, hook enforcement, configuration validity, API keys, and project state. Reports issues with actionable fix commands.

Follows OpenClaw Check-Report-Fix pattern: every detected issue includes a fix recommendation.

## Instructions

When user invokes `/diverga:doctor`, execute all 7 diagnostic layers sequentially and display results.

### Layer 1: Plugin Health

**Check plugin registration:**
- Read `~/.claude/plugins/installed_plugins.json`
- Verify `diverga@diverga` entry exists
- Extract version and install date

**Check config JSON validity:**
- Read `~/.claude/plugins/diverga/config/diverga-config.json`
- Verify it parses as valid JSON
- Check required fields exist: `version`, `human_checkpoints`, `language`

**Report format:**
```
PLUGIN HEALTH
  Registration:    [PASS - diverga@diverga v11.1.0 | FAIL - not found in installed_plugins.json]
  Config file:     [PASS - valid JSON | FAIL - missing or invalid]
  Config fields:   [PASS - all required fields present | WARN - missing: field1, field2]
```

**Fix if FAIL:**
- Registration missing: "Run: /plugin install diverga"
- Config missing: "Run: /diverga:setup to regenerate configuration"
- Config invalid JSON: "Config file is corrupted. Run: /diverga:setup to regenerate"

### Layer 2: Skill Sync

**Check skill counts match between plugin and local cache:**
- Use Glob to count directories in `~/.claude/plugins/diverga/skills/*/SKILL.md`
- Use Glob to count directories in `~/.claude/skills/diverga-*/SKILL.md` (exclude `diverga-diverga` prefix duplication — count unique skill names)
- Compare counts

**Check for missing skills in local cache:**
- For each skill in plugin directory, check if corresponding `diverga-{name}` exists in local skills
- List any missing skills

**Report format:**
```
SKILL SYNC
  Plugin skills:   [count] skills in plugin directory
  Local skills:    [count] skills in local cache
  Sync status:     [PASS - all synced | WARN - X skills missing locally]
  Missing:         [list of missing skill names, if any]
```

**Fix if WARN:**
- "Missing local skills. To resync, reinstall the plugin or manually copy:"
- For each missing skill: "  cp -r ~/.claude/plugins/diverga/skills/{name} ~/.claude/skills/diverga-{name}"

### Layer 3: Plugin Cache Sync

**Check that the plugin cache matches the installed version:**
- Read `~/.claude/plugins/diverga/plugin.json` → extract `version`
- Glob `~/.claude/plugins/cache/diverga/diverga/*/plugin.json` → list cached versions
- Compare: cached version should match installed version
- Check if cached version has `hooks/hooks.json`

**Report format:**
```
PLUGIN CACHE
  Installed version: [11.1.0 | FAIL - plugin.json missing]
  Cached version:    [11.1.0 | WARN - stale cache: 8.0.1 | FAIL - no cache found]
  Cache has hooks:   [PASS - hooks.json present | FAIL - hooks missing from cache]
  Cache has agents:  [PASS - agents/ present | WARN - agents/ missing]
```

**Fix if WARN/FAIL:**
- Stale cache: "Plugin cache is outdated. Run in terminal:"
  ```
  REPO="/Volumes/External SSD/Projects/Diverga/Diverga-core"
  CACHE="$HOME/.claude/plugins/cache/diverga/diverga/11.1.0"
  rm -rf "$HOME/.claude/plugins/cache/diverga/diverga/8.0.1"
  mkdir -p "$CACHE"
  cp -R "$REPO"/{skills,agents,config,hooks,mcp,CLAUDE.md,AGENTS.md,README.md} "$CACHE/"
  cp "$REPO/.claude-plugin/plugin.json" "$CACHE/"
  ```
- No hooks in cache: "Copy hooks manually: cp -R ~/.claude/plugins/diverga/hooks/ $CACHE/hooks/"
- Restart Claude Code after cache update for changes to take effect

### Layer 4: Hook Enforcement

**Check hook configuration:**
- Read `~/.claude/plugins/diverga/hooks/hooks.json` → verify it exists and has `PreToolUse` entries
- Check matchers include "Agent" and "Skill" (not "Task" — known bug in pre-11.1.0)
- Read `~/.claude/settings.json` → check if hooks are also configured at global level
- Test hook execution: Run `echo '{"tool_name":"Skill","tool_input":{"skill":"diverga:c1"}}' | node ~/.claude/plugins/diverga/hooks/prereq-enforcer.mjs` → verify it returns valid JSON with `continue` field

**Report format:**
```
HOOK ENFORCEMENT
  Plugin hooks.json: [PASS - exists with Agent+Skill matchers | FAIL - missing or wrong matchers]
  Global hooks:      [PASS - configured in settings.json | WARN - not in settings.json (relies on plugin)]
  Hook executable:   [PASS - returns valid JSON | FAIL - execution error]
  Matcher check:     [PASS - uses "Agent" | FAIL - uses stale "Task" matcher]
```

**Fix if issues found:**
- Wrong matcher: 'Change "Task" to "Agent" in hooks.json — Claude Code uses "Agent" as tool name'
- Not in settings.json: "Add hooks to ~/.claude/settings.json for reliable enforcement across sessions"
- Execution error: "Check that better-sqlite3 is installed: cd ~/.claude/plugins/diverga/mcp && npm install"

### Layer 5: Config Validity

**Deep validation of diverga-config.json:**
- Read `~/.claude/plugins/diverga/config/diverga-config.json`
- Check `version` field matches "11.1.0"
- Check `human_checkpoints` object exists and has `enabled` (boolean) and `required` (array)
- Check `language` is one of: "en", "ko", "auto"
- Check `model_routing` has `high`, `medium`, `low` keys if present

**Report format:**
```
CONFIG VALIDITY
  Version field:   [PASS - 11.1.0 | WARN - version mismatch: found X.Y.Z]
  Checkpoints:     [PASS - configured | FAIL - missing or malformed]
  Language:        [PASS - "en" | WARN - unexpected value: "XX"]
  Model routing:   [PASS - configured | SKIP - not set (using defaults)]
```

**Fix if issues found:**
- Version mismatch: "Config version X.Y.Z doesn't match plugin 11.1.0. Run: /diverga:setup to update"
- Checkpoints malformed: "Run: /diverga:setup to reconfigure checkpoints"

### Layer 6: API Keys

**Check 8 environment variables using Bash tool (`echo $VAR_NAME`):**

| Variable | Purpose | Required? |
|----------|---------|-----------|
| `GROQ_API_KEY` | LLM screening (recommended) | Recommended |
| `ANTHROPIC_API_KEY` | Claude API | Recommended |
| `OPENAI_API_KEY` | OpenAI screening | Optional |
| `GEMINI_API_KEY` | Gemini visualization | Optional |
| `SEMANTIC_SCHOLAR_API_KEY` | Paper retrieval | Optional |
| `OPENALEX_EMAIL` | OpenAlex polite pool | Optional |
| `SCOPUS_API_KEY` | Scopus access | Optional |
| `WOS_API_KEY` | Web of Science | Optional |

For each variable, use Bash: `echo "${VAR_NAME:+configured}"` — if output is "configured", it's set; if empty, it's not set.

**Report format:**
```
API STATUS
  Groq:              [configured | NOT SET -> export GROQ_API_KEY=your_key]
  Anthropic:         [configured | NOT SET -> export ANTHROPIC_API_KEY=your_key]
  OpenAI:            [configured | not set (optional)]
  Gemini:            [configured | not set (optional)]
  Semantic Scholar:  [configured | not set (optional)]
  OpenAlex:          [configured | not set (optional)]
  Scopus:            [configured | not set (optional)]
  Web of Science:    [configured | not set (optional)]
```

**Fix if NOT SET (recommended keys):**
- Show `export VAR_NAME=your_key_here` for each missing recommended key
- For optional keys, just note "(optional)" — no urgent fix needed

### Layer 7: Project State

**Check for active research project:**
- Use Glob to check if `.research/project-state.yaml` exists in current working directory
- If exists: Read it and validate YAML structure (has `project_name`, `current_stage`)
- Also check if `.research/` directory exists with expected subdirectories

**Report format:**
```
PROJECT STATE
  Active project:  [project name | No active project]
  State file:      [PASS - valid | WARN - invalid YAML | SKIP - no project]
  Research dir:    [PASS - structure intact | WARN - missing subdirs | SKIP - no project]
```

**Fix if issues:**
- Invalid YAML: "Project state file is corrupted. Run: /diverga:setup in your project directory"
- Missing subdirs: "Run: /diverga:setup to reinitialize project structure"
- No project: "Start a new project with: /diverga:setup or describe your research topic"

### Final Summary

After all 7 layers, display overall status:

```
══════════════════════════════════════════════
DIVERGA SYSTEM DIAGNOSTICS v11.1.0
══════════════════════════════════════════════

[Layer 1-7 results as shown above]

------------------------------------------
OVERALL: [HEALTHY | X WARNING(S) | X ERROR(S)]

[If issues found, numbered list:]
  1. [Issue description] -> [Fix command]
  2. [Issue description] -> [Fix command]
  ...

[If healthy:]
  All systems operational. Diverga is ready to use.
  Run /diverga:help to see all 24 agents and commands.
══════════════════════════════════════════════
```

## Implementation Notes

- Execute all Bash commands for API key checks in PARALLEL (single message, multiple Bash calls)
- Use Read tool for JSON/YAML file checks
- Use Glob tool for skill counting
- This skill is READ-ONLY — it does not modify any files
- If any individual check encounters an error (file not readable, etc.), show "UNABLE TO CHECK" rather than crashing
- Total execution target: under 10 seconds

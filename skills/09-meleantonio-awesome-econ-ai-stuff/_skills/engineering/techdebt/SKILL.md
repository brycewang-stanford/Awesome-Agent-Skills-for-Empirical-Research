---
name: techdebt
description: Find and fix technical debt including duplicated code, dead code, outdated patterns, and code smells. Run at the end of sessions to clean up.
workflow_stage: engineering
compatibility:
  - claude-code
  - cursor
  - codex
  - gemini-cli
author: Awesome Econ AI Community
version: 1.0.0
disable-model-invocation: true
tags:
  - refactoring
  - code-quality
  - maintenance
---

# Technical Debt Finder

Identify and fix technical debt in the codebase.

## What to Look For

### Code Duplication
- Functions with similar logic that could be consolidated
- Copy-pasted code blocks
- Repeated patterns that should be abstracted

### Dead Code
- Unused imports
- Unused functions or classes
- Commented-out code blocks
- Unreachable code paths

### Outdated Patterns
- Deprecated API usage
- Old-style string formatting (% or .format) vs f-strings
- Type hints using `typing.List` instead of `list`
- Missing type hints on public functions

### Code Smells
- Functions longer than 50 lines
- Too many parameters (more than 5)
- Deep nesting (more than 3 levels)
- Magic numbers without constants
- Overly complex conditionals

### Missing Best Practices
- Missing docstrings on public functions
- Missing error handling
- Hardcoded values that should be config
- Missing tests for critical paths

## Workflow

1. **Scan the Codebase**
   - Look for patterns matching the issues above
   - Prioritize by impact and ease of fix

2. **Report Findings**
   - List issues by category
   - Include file paths and line numbers
   - Estimate severity (high/medium/low)

3. **Fix Issues**
   - Start with high-severity, easy fixes
   - Create atomic commits for each fix
   - Run tests after each change

4. **Verify**
   - Run linter: `ruff check .`
   - Run tests: `pytest`
   - Ensure no new issues introduced

## Arguments

Optionally specify a directory or file to focus on.

Usage:
- `/techdebt` - Scan entire project
- `/techdebt src/` - Scan specific directory
- `/techdebt src/utils.py` - Scan specific file

## Output

Provide a summary of:
- Issues found (by category)
- Issues fixed
- Remaining items for future sessions

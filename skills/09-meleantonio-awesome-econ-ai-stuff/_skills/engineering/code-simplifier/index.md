---
name: code-simplifier
description: Simplify and clean up code after changes are complete. Reduces complexity, improves readability, and ensures consistency.
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
  - python
  - readability
---

# Code Simplifier

Clean up and simplify code after making changes.

## When to Use

Run this skill after completing a feature or fix to ensure the code is clean, readable, and maintainable.

## Simplification Goals

### Reduce Complexity
- Break long functions into smaller, focused ones
- Reduce nesting depth (max 3 levels)
- Simplify complex conditionals
- Extract magic numbers to named constants

### Improve Readability
- Use descriptive variable and function names
- Add clarifying comments for non-obvious logic
- Ensure consistent formatting
- Remove unnecessary comments

### Apply Pythonic Patterns
- Use list/dict/set comprehensions where appropriate
- Use `with` statements for resource management
- Use `enumerate()` instead of manual indexing
- Use `zip()` for parallel iteration
- Use f-strings for formatting
- Use `pathlib` for file paths

### Clean Up
- Remove unused imports
- Remove unused variables
- Remove commented-out code
- Remove redundant code paths
- Consolidate duplicate logic

## Workflow

1. **Identify Changed Files**
   - Focus on files modified in the current session
   - Or specify files/directories as arguments

2. **Analyze Each File**
   - Check for simplification opportunities
   - Prioritize high-impact improvements

3. **Apply Simplifications**
   - Make incremental changes
   - Preserve original behavior
   - Run tests after each change

4. **Format and Lint**
   - Run `ruff format .`
   - Run `ruff check --fix .`

5. **Verify**
   - Run tests: `pytest`
   - Ensure behavior unchanged

## Arguments

Optionally specify files or directories to simplify.

Usage:
- `/code-simplifier` - Simplify recently changed files
- `/code-simplifier src/module.py` - Simplify specific file
- `/code-simplifier src/` - Simplify entire directory

## Example Transformations

Before:
```python
result = []
for i in range(len(items)):
    if items[i].is_valid == True:
        result.append(items[i].value)
```

After:
```python
result = [item.value for item in items if item.is_valid]
```

Before:
```python
if x != None:
    if y != None:
        if z != None:
            process(x, y, z)
```

After:
```python
if all(v is not None for v in (x, y, z)):
    process(x, y, z)
```

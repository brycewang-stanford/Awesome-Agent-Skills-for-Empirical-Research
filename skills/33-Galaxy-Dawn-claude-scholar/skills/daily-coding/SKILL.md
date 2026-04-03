---
name: daily-coding
description: Use for everyday coding tasks that involve writing or modifying source code.
version: 1.0.0
tags: [Coding, Daily, Checklist]
---

# Daily Coding Checklist

A minimal coding quality assurance checklist ensuring every code modification follows best practices.

## When to Use

Use this skill for:
- Implementing new features
- Adding code or modifying existing code
- User requests like "write a...", "implement...", "add...", or "modify..."
- Any coding task that involves Edit or Write tools

## When Not to Use

Do not use this skill for:
- Pure reading or understanding tasks with no modification intent
- Work already covered by specialized skills such as `bug-detective`, `architecture-design`, or `tdd-guide`
- Configuration-only changes
- Documentation-only writing

## Core Checklist

### Before Starting

- [ ] **Read before modify** - Must read target file with Read tool before making changes
- [ ] **Understand context** - Confirm understanding of existing code logic and design intent

### During Coding

- [ ] **Minimal changes** - Only change what's necessary, no over-engineering, no unrelated features
- [ ] **Type safety** - Add type hints for Python, avoid `any` in TypeScript
- [ ] **Security check** - Avoid command injection, XSS, SQL injection vulnerabilities

### After Completion

- [ ] **Verify execution** - Ensure code runs correctly with no syntax errors
- [ ] **Clean up** - Remove print/console.log debug statements and temporary files
- [ ] **Brief summary** - Inform user what was changed and the scope of impact

## Quick Reference

### Common Mistakes to Avoid

```python
# ❌ Don't
def process(data=[]):  # Mutable default argument
    pass

# ✅ Should
def process(data: list | None = None):
    data = data or []
```

```python
# ❌ Don't
except:  # Bare except
    pass

# ✅ Should
except ValueError as e:
    logger.error(f"Processing failed: {e}")
    raise
```

### Security Check Points

- User input must be validated/escaped
- Use pathlib for file paths, avoid path traversal
- Never hardcode sensitive info (API keys, passwords)

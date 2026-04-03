# Gotchas & Best Practices

Common mistakes, validation errors, and a pre-submission checklist for skill authors.

## Validation Errors

### "SKILL.md not found"

**Cause:** File doesn't exist or wrong location.

**Fix:**
```bash
# Check file exists
ls .claude/skills/my-skill/SKILL.md

# Check spelling (must be uppercase)
# SKILL.md ✓
# skill.md ✗
# Skill.md ✗
```

### "No YAML frontmatter found"

**Cause:** File doesn't start with `---`.

**Fix:** Ensure frontmatter starts on line 1:
```yaml
---
name: my-skill
description: ...
---
```

Not:
```markdown
# My Skill
---
name: my-skill
```

### "Invalid frontmatter format"

**Cause:** Frontmatter not properly delimited.

**Fix:** Check for matching `---` markers:
```yaml
---
name: my-skill
description: My description.
---

# Content starts here
```

### "Invalid YAML in frontmatter"

**Cause:** YAML syntax error.

**Common issues:**

| Problem | Invalid | Valid |
|---------|---------|-------|
| Unquoted special chars | `description: Use <this>` | `description: "Use this"` |
| Missing colon | `name my-skill` | `name: my-skill` |
| Bad indentation | Mixed tabs/spaces | Consistent spaces |
| Unescaped quotes | `description: Say "hello"` | `description: 'Say "hello"'` |

### "Missing 'name' in frontmatter"

**Cause:** Required `name` field absent.

**Fix:**
```yaml
---
name: my-skill
description: ...
---
```

### "Missing 'description' in frontmatter"

**Cause:** Required `description` field absent.

**Fix:**
```yaml
---
name: my-skill
description: What this does. When to use it.
---
```

### "Name must be hyphen-case"

**Cause:** Invalid characters in name.

| Invalid | Issue | Valid |
|---------|-------|-------|
| `My-Skill` | Uppercase | `my-skill` |
| `my_skill` | Underscore | `my-skill` |
| `my skill` | Space | `my-skill` |
| `-my-skill` | Leading hyphen | `my-skill` |
| `my-skill-` | Trailing hyphen | `my-skill` |
| `my--skill` | Consecutive hyphens | `my-skill` |

### "Name is too long"

**Cause:** Name exceeds 64 characters.

**Fix:** Shorten the name. Use abbreviations if needed.

### "Description cannot contain angle brackets"

**Cause:** `<` or `>` in description.

**Fix:**
```yaml
# Invalid
description: Use <command> to do X.

# Valid
description: Use the command to do X.
```

### "Description is too long"

**Cause:** Description exceeds 1024 characters.

**Fix:** Shorten description. Move details to SKILL.md body.

### "Unexpected key(s) in frontmatter"

**Cause:** Unknown fields in frontmatter.

**Allowed fields only:**
- `name`
- `description`
- `metadata`

**Invalid fields (examples):**
- `author`
- `version`
- `tags`
- `short-description`

### "Directory name doesn't match skill name"

**Cause:** Folder name differs from `name` field.

**Fix:**
```
# Must match
.claude/skills/my-skill/SKILL.md
               ^^^^^^^^
---
name: my-skill
      ^^^^^^^^
---
```

## Common Anti-Patterns

### "When to Use" in Body

**Problem:** Triggering info in body, loaded too late.

```markdown
---
name: my-skill
description: A helpful skill.
---

## When to Use This Skill  <!-- WRONG: This is never seen during triggering -->

Use this when you need to...
```

**Fix:** Put triggering info in `description`:

```yaml
description: A helpful skill. Use when you need to process PDFs or manipulate documents.
```

### Undertriggering

**Problem:** Skill doesn't load when it should. Users have to manually enable it.

**Symptoms:**
- Skill never loads automatically
- Users manually invoking it by name
- Support questions about when to use it

**Diagnosis:** Ask Claude: "When would you use the [skill name] skill?" Claude will quote the description back. Adjust based on what's missing.

**Fix:** Make the description more "pushy" — include contexts where the skill should activate even without explicit naming:

```yaml
# Before (undertriggers)
description: Build dashboards to display data.

# After (better triggering)
description: Build dashboards to display data. Use whenever the user mentions dashboards, data visualization, metrics display, or wants to present any kind of data visually, even if they don't explicitly ask for a "dashboard."
```

### Overtriggering

**Problem:** Skill loads for unrelated queries. Users disabling it.

**Symptoms:**
- Skill loads for clearly unrelated tasks
- Users confused about why it activated
- Interference with other skills

**Fix:** Add negative triggers and narrow scope:

```yaml
# Before (overtriggers)
description: Processes documents.

# After (narrowed scope)
description: Processes PDF legal documents for contract review. Do NOT use for general document editing, spreadsheets, or non-PDF formats.
```

### Overly Verbose Descriptions

**Problem:** Long descriptions waste metadata budget.

```yaml
# Bad: 200+ words
description: This skill is a comprehensive solution for managing and processing various types of document files including but not limited to PDF, Word, and Excel formats. It provides functionality for...
```

**Fix:** Be concise, focus on triggers:

```yaml
# Good: ~30 words
description: Process document files (PDF, Word, Excel). Use when converting formats, extracting text, or manipulating document content.
```

### Duplicated Content

**Problem:** Same info in SKILL.md and references.

**Fix:** Information lives in ONE place. Reference it from other locations.

### Nested References

**Problem:** Multi-level reference directories.

```
# Bad
references/
├── api/
│   ├── endpoints.md
│   └── auth.md
└── guides/
    └── quickstart.md

# Good
references/
├── api-endpoints.md
├── api-auth.md
└── quickstart.md
```

### Giant SKILL.md

**Problem:** 800+ line SKILL.md file.

**Fix:** Split into references. Keep SKILL.md as navigation hub (<500 lines). Note: the opposite problem — *anemic reference files* — is equally harmful. Reference files should be comprehensive since they load on-demand. Aim for total reference content >= 3x SKILL.md lines for data source skills.

### Missing Decision Trees

**Problem:** No navigation for complex skills.

**Fix:** Add decision trees pointing to relevant sections/files.

### No Topic Index

**Problem:** Hard to find specific topics.

**Fix:** Add Topic Index table at end of SKILL.md.

### Untested Scripts

**Problem:** Scripts that don't work.

**Fix:** Test all scripts manually before including:

```bash
python ./scripts/my_script.py --help
python ./scripts/my_script.py test-input.txt
```

### Too Many Options

**Problem:** Presenting multiple equivalent approaches instead of a clear default.

**Fix:** Provide one recommended approach with an escape hatch:

```markdown
# Bad: Confusing choices
You can use pypdf, pdfplumber, PyMuPDF, or pdf2image...

# Good: Default with escape hatch
Use pdfplumber for text extraction. For scanned PDFs requiring OCR,
use pdf2image with pytesseract instead.
```

### Windows-Style Paths

**Problem:** Using backslashes in file paths, which fail on Unix systems.

**Fix:** Always use forward slashes — they work cross-platform:

```markdown
# Bad
scripts\helper.py
reference\guide.md

# Good
scripts/helper.py
reference/guide.md
```

### Unnecessary Files

**Problem:** README.md, CHANGELOG.md, etc.

Skills are for AI execution, not human documentation.

**Don't include:**
- README.md
- INSTALLATION_GUIDE.md
- CHANGELOG.md
- CONTRIBUTING.md
- LICENSE

## Pre-Submission Checklist

### Frontmatter

- [ ] `name` is lowercase hyphen-case
- [ ] `name` matches directory name
- [ ] `name` is 1-64 characters
- [ ] `description` includes what skill does
- [ ] `description` includes when to use it (triggers)
- [ ] `description` is 1-1024 characters
- [ ] `description` has no angle brackets
- [ ] No unknown frontmatter fields

### Structure

- [ ] SKILL.md is under 500 lines
- [ ] Has "What is X?" or equivalent intro
- [ ] Has decision trees for navigation (if complex)
- [ ] Has Quick Reference section
- [ ] Has Topic Index (if has references)
- [ ] Reference files are one level deep
- [ ] Long references (>100 lines) have TOC
- [ ] All file paths use forward slashes (no backslashes)

### Content

- [ ] Uses imperative/infinitive form
- [ ] Prefers examples over prose
- [ ] No duplicated information
- [ ] No "When to Use" section in body
- [ ] Code blocks have language specified
- [ ] Tables used for quick lookups
- [ ] Consistent terminology throughout (one term per concept)
- [ ] No time-sensitive information (or in collapsible "old patterns" sections)
- [ ] Explains "why" behind instructions, not just "what"

### Resources (if applicable)

- [ ] Scripts tested and working
- [ ] Scripts have clear parameters
- [ ] References are focused (one topic each)
- [ ] Assets are necessary and minimal
- [ ] Resources documented in SKILL.md
- [ ] Scripts handle errors explicitly (don't punt to Claude)
- [ ] Script constants are documented (no magic numbers)
- [ ] Execute vs. read intent is clear for each script

### Files

- [ ] No README.md
- [ ] No CHANGELOG.md
- [ ] No auxiliary documentation
- [ ] Only necessary files included

### Testing

- [ ] 2-3 realistic test prompts created
- [ ] Triggering tested (should-trigger and should-not-trigger queries)
- [ ] Tested with real usage scenarios
- [ ] Iterated based on observed behavior

## Self-Review Questions

Before finalizing, ask:

1. **Triggering:** Will the description match user queries that should trigger this skill?

2. **Completeness:** Does the skill contain everything needed to accomplish its purpose?

3. **Conciseness (SKILL.md):** Does every line in SKILL.md justify its token cost? (Reference files have different economics — thoroughness is preferred; see `progressive-disclosure.md`.)

4. **Navigation:** Can users quickly find what they need?

5. **Examples:** Are there enough examples to guide usage?

6. **Testing:** Have all scripts been tested?

7. **Duplication:** Is any information repeated?

8. **Scope:** Is the skill focused on one domain/purpose?

## Quick Fixes

| Problem | Quick Fix |
|---------|-----------|
| Skill not triggering | Improve `description` with specific triggers |
| Too long | Split into references |
| Hard to navigate | Add decision trees |
| Missing info | Add to appropriate reference file |
| Script failing | Test script, check paths |
| Validation error | Check frontmatter format |

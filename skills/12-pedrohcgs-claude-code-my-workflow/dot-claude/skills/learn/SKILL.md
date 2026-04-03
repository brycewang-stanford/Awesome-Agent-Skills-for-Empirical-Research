---
name: learn
description: |
  Extract reusable knowledge from the current session into a persistent skill.
  Use when you discover something non-obvious, create a workaround, or develop
  a multi-step workflow that future sessions would benefit from.
author: Claude Code Academic Workflow
version: 1.0.0
argument-hint: "[skill-name (kebab-case)]"
allowed-tools: ["Read", "Write", "Bash", "Glob", "Grep"]
---

# /learn — Skill Extraction Workflow

Extract non-obvious discoveries into reusable skills that persist across sessions.

## When to Use This Skill

Invoke `/learn` when you encounter:

- **Non-obvious debugging** — Investigation that took significant effort, not in docs
- **Misleading errors** — Error message was wrong, found the real cause
- **Workarounds** — Found a limitation with a creative solution
- **Tool integration** — Undocumented API usage or configuration
- **Trial-and-error** — Multiple attempts before success
- **Repeatable workflows** — Multi-step task you'd do again
- **User-facing automation** — Reports, checks, or processes users will request

## Workflow Phases

### PHASE 1: Evaluate (Self-Assessment)

Before creating a skill, answer these questions:

1. "What did I just learn that wasn't obvious before starting?"
2. "Would future-me benefit from this being documented?"
3. "Was the solution non-obvious from documentation alone?"
4. "Is this a multi-step workflow I'd repeat?"

**Continue only if YES to at least one question.**

### PHASE 2: Check Existing Skills

Search for related skills to avoid duplication:

```bash
# Check project skills
ls .claude/skills/ 2>/dev/null

# Search for keywords
grep -r -i "KEYWORD" .claude/skills/ 2>/dev/null
```

**Outcomes:**
- Nothing related → Create new skill (continue to Phase 3)
- Same trigger & fix → Update existing skill (bump version)
- Partial overlap → Update with new variant

### PHASE 3: Create Skill

Create the skill file at `.claude/skills/[skill-name]/SKILL.md`:

```yaml
---
name: descriptive-kebab-case-name
description: |
  [CRITICAL: Include specific triggers in the description]
  - What the skill does
  - Specific trigger conditions (exact error messages, symptoms)
  - When to use it (contexts, scenarios)
author: Claude Code Academic Workflow
version: 1.0.0
argument-hint: "[expected arguments]"  # Optional
---

# Skill Name

## Problem
[Clear problem description — what situation triggers this skill]

## Context / Trigger Conditions
[When to use — exact error messages, symptoms, scenarios]
[Be specific enough that you'd recognize it again]

## Solution
[Step-by-step solution]
[Include commands, code snippets, or workflows]

## Verification
[How to verify it worked]
[Expected output or state]

## Example
[Concrete example of the skill in action]

## References
[Documentation links, related files, or prior discussions]
```

### PHASE 4: Quality Gates

Before finalizing, verify:

- [ ] Description has specific trigger conditions (not vague)
- [ ] Solution was verified to work (tested)
- [ ] Content is specific enough to be actionable
- [ ] Content is general enough to be reusable
- [ ] No sensitive information (credentials, personal data)
- [ ] Skill name is descriptive and uses kebab-case

## Output

After creating the skill, report:

```
✓ Skill created: .claude/skills/[name]/SKILL.md
  Trigger: [when to use]
  Problem: [what it solves]
```

## Example: Creating a Skill

User discovers that a specific R package silently drops observations:

```markdown
---
name: fixest-missing-covariate-handling
description: |
  Handle silent observation dropping in fixest when covariates have missing values.
  Use when: estimates seem wrong, sample size unexpectedly small, or comparing
  results between packages.
author: Claude Code Academic Workflow
version: 1.0.0
---

# fixest Missing Covariate Handling

## Problem
The fixest package silently drops observations when covariates have NA values,
which can produce unexpected results when comparing to other packages.

## Context / Trigger Conditions
- Sample size in fixest is smaller than expected
- Results differ from Stata or other R packages
- Model has covariates with potential missing values

## Solution
1. Check for NA patterns before regression:
   ```r
   summary(complete.cases(data[, covariates]))
   ```
2. Explicitly handle NA values or use `na.action` parameter
3. Document the expected sample size in comments

## Verification
Compare `nobs(model)` with `nrow(data)` — difference indicates dropped obs.

## References
- fixest documentation on missing values
- [LEARN:r-code] entry in MEMORY.md
```

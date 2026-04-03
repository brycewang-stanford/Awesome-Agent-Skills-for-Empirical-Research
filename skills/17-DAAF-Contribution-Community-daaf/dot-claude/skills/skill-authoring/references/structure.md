# SKILL.md Body Structure

The Markdown body follows the frontmatter and contains instructions for the agent. This document covers organization patterns, formatting conventions, and section templates.

## Body Constraints

| Constraint | Guideline |
|------------|-----------|
| Line count | <500 lines (recommended) |
| Word count | <5000 words |
| Writing style | Imperative/infinitive form |
| Content focus | Examples over explanations |

## Four Body Patterns

Choose based on your skill's primary purpose. Patterns can be mixed.

### Pattern 1: Workflow-Based

For skills with sequential processes or decision flows.

**Best for:** CI/CD pipelines, deployment processes, multi-step procedures

**Structure:**

```markdown
# Skill Name

Brief intro.

## Overview

What this workflow accomplishes.

## Decision Tree

```
Starting point?
├─ Condition A → Step 1
├─ Condition B → Step 2
└─ Condition C → Step 3
```

## Step 1: First Action

Instructions for step 1.

## Step 2: Second Action

Instructions for step 2.

## Step 3: Third Action

Instructions for step 3.
```

### Pattern 2: Task-Based

For skills that are collections of related tools or operations.

**Best for:** File processors, API clients, utility collections

**Structure:**

```markdown
# Skill Name

Brief intro.

## Quick Start

Minimal example to get started.

## Task 1: Do Something

How to accomplish task 1.

## Task 2: Do Another Thing

How to accomplish task 2.

## Task 3: Advanced Operation

How to accomplish task 3.

## Quick Reference

| Task | Command/Method |
|------|----------------|
| Task 1 | `command1` |
| Task 2 | `command2` |
```

### Pattern 3: Reference-Based

For skills that encode standards, specifications, or guidelines.

**Best for:** Style guides, API specs, coding standards

**Structure:**

```markdown
# Skill Name

Brief intro.

## Overview

What this reference covers.

## Guidelines

### Guideline 1

Explanation and examples.

### Guideline 2

Explanation and examples.

## Specifications

| Item | Specification |
|------|---------------|
| Spec 1 | Details |
| Spec 2 | Details |

## Examples

### Good Example

```code
good code here
```

### Bad Example

```code
bad code here
```
```

### Pattern 4: Capabilities-Based

For skills that expose integrated system features.

**Best for:** Platform integrations, feature-rich tools, SDK wrappers

**Structure:**

```markdown
# Skill Name

Brief intro.

## Core Capabilities

- Capability 1
- Capability 2
- Capability 3

## Feature 1

### Usage

How to use feature 1.

### Examples

```code
example code
```

## Feature 2

### Usage

How to use feature 2.

### Examples

```code
example code
```
```

## Standard Sections

These sections appear in most well-structured skills.

### "What is X?" Section

Brief introduction with bullet points.

```markdown
## What is X?

X is a tool for doing Y:

- **Feature 1**: Brief description
- **Feature 2**: Brief description
- **Feature 3**: Brief description
```

### Reference File Structure Table

Links topics to reference files for progressive disclosure.

```markdown
## Reference File Structure

| File | Purpose | When to Read |
|------|---------|--------------|
| `quickstart.md` | Getting started | New to this tool |
| `advanced.md` | Deep features | Need more control |
| `gotchas.md` | Common issues | Debugging |
```

### Decision Trees

Navigate users to the right information.

```markdown
## Decision Tree

```
What do you need?
├─ Getting started → ./references/quickstart.md
├─ Advanced feature → ./references/advanced.md
│   ├─ Sub-feature A → Section in advanced.md
│   └─ Sub-feature B → Section in advanced.md
└─ Troubleshooting → ./references/gotchas.md
```
```

**Decision tree conventions:**

- Use ASCII box-drawing: `├─`, `└─`, `│`
- Keep to 2-3 levels of nesting
- Point to files or sections
- Use `→` for pointing

### Quick Reference Section

Essential commands/APIs in table format.

```markdown
## Quick Reference

| Command | Purpose |
|---------|---------|
| `cmd1` | Does X |
| `cmd2` | Does Y |
| `cmd3` | Does Z |
```

### Topic Index

Final section mapping all topics to locations.

```markdown
## Topic Index

| Topic | Reference File |
|-------|---------------|
| Installation | `./references/quickstart.md` |
| Configuration | `./references/config.md` |
| API Reference | `./references/api.md` |
| Troubleshooting | `./references/gotchas.md` |
```

## Formatting Conventions

### Tables

Use tables for:
- Quick lookups (commands, APIs)
- Comparisons
- Reference data

```markdown
| Column 1 | Column 2 | Column 3 |
|----------|----------|----------|
| Data | Data | Data |
```

### Code Blocks

Always specify language for syntax highlighting:

````markdown
```python
def example():
    pass
```

```bash
echo "hello"
```

```yaml
key: value
```
````

### Bullet Points

Use for:
- Feature lists
- Guidelines
- Non-sequential items

```markdown
- Item 1
- Item 2
- Item 3
```

### Numbered Lists

Use for:
- Sequential steps
- Prioritized items
- Ordered procedures

```markdown
1. First step
2. Second step
3. Third step
```

## Content Patterns

These patterns address common needs in skill content. Mix and match as appropriate.

### Workflow Checklists

For complex multi-step tasks, provide a copyable checklist that tracks progress:

````markdown
## Data Processing Workflow

Copy this checklist and track your progress:

```
Task Progress:
- [ ] Step 1: Fetch raw data
- [ ] Step 2: Validate schema
- [ ] Step 3: Clean and transform
- [ ] Step 4: Run analysis
- [ ] Step 5: Verify output
```
````

Checklists help both the agent and the user track progress through multi-step operations.

### Feedback Loops

For quality-critical operations, build in validate-fix-repeat cycles:

```markdown
## Document Editing Process

1. Make edits to the target file
2. **Validate immediately**: `python scripts/validate.py output/`
3. If validation fails:
   - Review the error message
   - Fix the issues
   - Run validation again
4. **Only proceed when validation passes**
5. Finalize output
```

The validation loop catches errors early rather than discovering them at the end.

### Template Pattern

Provide output templates with appropriate strictness:

**Strict** (for formats where consistency is critical):

````markdown
## Report Structure

ALWAYS use this exact template:

```markdown
# [Title]

## Executive Summary
[One-paragraph overview]

## Key Findings
- Finding with supporting data

## Recommendations
1. Specific actionable recommendation
```
````

**Flexible** (when adaptation is useful):

````markdown
## Report Structure

Sensible default format — adjust sections based on what you discover:

```markdown
# [Title]

## Executive Summary
[Overview]

## Key Findings
[Adapt based on analysis]

## Recommendations
[Tailor to context]
```
````

### Examples Pattern (Input/Output Pairs)

Show concrete input/output examples rather than describing behavior in prose:

````markdown
## Commit Message Format

**Example 1:**
Input: Added user authentication with JWT tokens
Output:
```
feat(auth): implement JWT-based authentication
```

**Example 2:**
Input: Fixed bug where dates displayed incorrectly
Output:
```
fix(reports): correct date formatting in timezone conversion
```
````

Examples help the agent understand desired style and detail more clearly than descriptions alone.

### Verifiable Intermediate Outputs

For complex operations, have the agent create an intermediate plan file that gets validated before execution:

```markdown
## Batch Update Workflow

1. Analyze the input: `python scripts/analyze.py input.csv`
2. Create a changes plan: save proposed changes to `changes.json`
3. **Validate the plan**: `python scripts/validate_plan.py changes.json`
4. If validation passes, execute: `python scripts/apply_changes.py changes.json`
5. Verify output: `python scripts/verify.py output/`
```

This catches errors before they're applied, keeping operations reversible at the plan stage.

### Consistent Terminology

Choose one term for each concept and use it throughout the skill:

| Do | Don't |
|----|-------|
| Always "API endpoint" | Mix "endpoint", "URL", "route", "path" |
| Always "field" | Mix "field", "box", "element", "control" |
| Always "extract" | Mix "extract", "pull", "get", "retrieve" |

Consistency reduces ambiguity and helps the agent follow instructions reliably.

### Time-Sensitive Information

Avoid information that will become outdated. If historical context is needed, use collapsible sections:

```markdown
## Current Method

Use the v2 API endpoint: `api.example.com/v2/data`

<details>
<summary>Legacy v1 API (deprecated)</summary>

The v1 API used: `api.example.com/v1/data`

This endpoint is no longer supported.
</details>
```

## Writing Style

### Use Imperative Form

```markdown
# Good
Run the command.
Create a new file.
Configure the settings.

# Bad
The command should be run.
A new file is created.
You should configure the settings.
```

### Prefer Examples Over Prose

```markdown
# Good
```python
df.filter(pl.col("x") > 10)
```

# Less Good
To filter a DataFrame, use the filter method with a column expression
that specifies the condition you want to match against the data.
```

### Be Concise (in SKILL.md)

Every line in SKILL.md should justify its token cost. Reference files have different economics — see `progressive-disclosure.md` for guidance on thorough reference file authoring.

```markdown
# Good
Use `pl.col("x").cast(pl.Int64)` to cast column types in Polars.

# Bad
When you want to change the data type of a column named x to a
64-bit integer in Polars, you can use the cast method on the
column expression with the Int64 type to perform the conversion.
```

### Explain the Why

Explain reasoning behind instructions rather than using rigid directives. Today's LLMs respond better to understanding *why* something matters than to heavy-handed mandates.

```markdown
# Less effective
ALWAYS validate data before proceeding. NEVER skip this step.

# More effective
Validate data before proceeding — unvalidated data can silently
corrupt downstream transformations, making errors much harder
to diagnose after the fact.
```

If you find yourself writing ALWAYS or NEVER in all caps, that's a signal to reframe: explain the reasoning so the model understands the importance.

### Degrees of Freedom

Match the level of specificity to the task's fragility:

| Freedom Level | When to Use | Example |
|---------------|-------------|---------|
| **High** (text guidance) | Multiple valid approaches; context-dependent | Code review process |
| **Medium** (pseudocode/templates) | Preferred pattern exists; some variation OK | Report generation with parameters |
| **Low** (exact scripts) | Fragile operations; consistency critical | Database migrations, destructive ops |

Think of it as a path: a narrow bridge with cliffs needs exact instructions (low freedom), while an open field just needs general direction (high freedom).

## Length Guidelines

| Section | Recommended Length |
|---------|-------------------|
| Intro | 1-2 sentences |
| "What is X?" | 3-5 bullet points |
| Decision tree | 5-15 lines per tree |
| Quick reference | 5-20 rows |
| Topic index | Match number of topics |

## When to Split Content

If SKILL.md exceeds 300-400 lines, consider splitting:

1. Move detailed reference content to `references/` files
2. Keep SKILL.md as a navigation hub
3. Use decision trees to point to reference files

See `progressive-disclosure.md` for splitting patterns.

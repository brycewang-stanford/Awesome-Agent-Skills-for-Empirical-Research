# Quickstart

## Skill Location

Claude Code discovers skills from these paths (searched in order):

| Location | Scope | Path |
|----------|-------|------|
| Project config | Project | `.claude/skills/<name>/SKILL.md` |
| Global config | User | `~/.claude/skills/<name>/SKILL.md` |

For project-local paths, Claude Code walks up from the current directory to the git worktree root.

## Create Your First Skill

### Step 1: Create Directory

```bash
mkdir -p .claude/skills/my-skill
```

The directory name must match the skill's `name` field in frontmatter.

### Step 2: Create SKILL.md

Create `.claude/skills/my-skill/SKILL.md`:

```yaml
---
name: my-skill
description: Brief explanation of what this skill does. Use when [specific trigger conditions].
metadata:
  audience: developers
  domain: example
---

# My Skill

One-sentence introduction to the skill.

## What This Skill Does

- Bullet point 1
- Bullet point 2
- Bullet point 3

## Quick Reference

| Command | Purpose |
|---------|---------|
| `example` | Does something |

## How to Use

Instructions for the agent to follow.
```

### Step 3: Verify Loading

The skill should appear in the `skill` tool's available skills list. The agent can load it by calling:

```
skill({ name: "my-skill" })
```

## Minimal Viable Skill

The absolute minimum SKILL.md:

```yaml
---
name: hello-world
description: Example skill that greets users. Use when asked to demonstrate a basic skill.
---

# Hello World

When triggered, respond with a friendly greeting.
```

Only `name` and `description` are required. Optional fields (`metadata`) can be added later.

## Naming Your Skill

### Valid Names

- `my-skill`
- `pdf-processor`
- `gh-fix-ci`
- `data2chart`

### Invalid Names

| Invalid | Reason |
|---------|--------|
| `My-Skill` | Uppercase not allowed |
| `-my-skill` | Cannot start with hyphen |
| `my-skill-` | Cannot end with hyphen |
| `my--skill` | No consecutive hyphens |
| `my_skill` | Underscores not allowed |
| `my skill` | Spaces not allowed |

### Naming Conventions

- Use lowercase hyphen-case
- Prefer short, verb-led names: `rotate-pdf`, `fix-imports`
- Namespace by tool when helpful: `gh-address-comments`, `linear-create-issue`
- Maximum 64 characters

## Adding Resources (Optional)

If your skill needs bundled files:

```bash
# For executable scripts
mkdir -p .claude/skills/my-skill/scripts

# For documentation
mkdir -p .claude/skills/my-skill/references

# For templates/assets
mkdir -p .claude/skills/my-skill/assets
```

See `references-resources.md` for details on each directory type.

## Development Workflow

### 1. Start Simple

Begin with just SKILL.md. Add resources only when needed.

### 2. Test Early

Use the skill on real tasks to identify gaps.

### 3. Iterate

Refine based on actual usage:
- Did the agent understand the instructions?
- Was information missing?
- Was there unnecessary content?

### 4. Keep Concise

Every line should justify its token cost. Remove fluff.

## Example: Complete Simple Skill

```yaml
---
name: commit-message
description: Generate conventional commit messages. Use when committing code changes or asked to write commit messages.
metadata:
  audience: developers
  domain: git
---

# Commit Message Generator

Generate commit messages following the Conventional Commits specification.

## Format

```
<type>(<scope>): <description>

[optional body]

[optional footer]
```

## Types

| Type | When to Use |
|------|-------------|
| `feat` | New feature |
| `fix` | Bug fix |
| `docs` | Documentation only |
| `style` | Formatting, no code change |
| `refactor` | Code change, no feature/fix |
| `test` | Adding tests |
| `chore` | Maintenance tasks |

## Guidelines

- Keep subject line under 72 characters
- Use imperative mood: "add feature" not "added feature"
- Don't end subject with period
- Separate subject from body with blank line
```

## Next Steps

- Read `frontmatter.md` for field specifications
- Read `structure.md` for body organization patterns
- Read `gotchas.md` before publishing

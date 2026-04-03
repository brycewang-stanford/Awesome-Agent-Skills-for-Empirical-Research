# Progressive Disclosure

Progressive disclosure is the architectural pattern that optimizes context window usage by loading skill information in stages. Instead of loading everything at once, content is loaded only when needed.

## Three-Level Loading System

| Level | Content | When Loaded | Token Cost | Purpose |
|-------|---------|-------------|------------|---------|
| **1** | `name` + `description` | Agent startup | ~100 words/skill | Discovery & matching |
| **2** | SKILL.md body | Skill triggers | <5k words | Detailed instructions |
| **3** | Bundled resources | During execution | Variable | Implementation details |

### Level 1: Metadata

Loaded for **all installed skills** at agent startup.

```yaml
---
name: my-skill
description: What it does. When to use it.
---
```

- Always in context (~100 words per skill)
- Used for skill matching/triggering
- Must contain triggering information in `description`

### Level 2: Body

Loaded **only when the skill triggers**.

```markdown
# My Skill

Full instructions here...
```

- Loaded on-demand
- Target: <500 lines, <5000 words
- Contains detailed guidance

### Level 3: Resources

Loaded **as needed during execution**.

```
my-skill/
├── scripts/     → Executed (often 0 tokens)
├── references/  → Read into context
└── assets/      → Used in output (0 tokens)
```

- `scripts/`: May execute without reading
- `references/`: Read when agent needs information — **no size limit**; these should be comprehensive since their token cost is only incurred on demand
- `assets/`: Used directly, not read into context

## Why Progressive Disclosure Matters

The context window is a **shared resource**:

- System prompt
- Conversation history
- All skills' metadata
- User request
- Agent's working memory

Loading all skill content at once would quickly exhaust the budget.

**Example:** 20 skills × 300 lines = 6000 lines of skill content. Progressive disclosure reduces this to ~2000 words of metadata until skills are actually needed.

## Token Budget Guidelines

| Component | Budget | Notes |
|-----------|--------|-------|
| All skill metadata | ~100 words × N skills | Always loaded |
| Active skill body | <5000 words | One skill at a time typically |
| Loaded references | Variable | Load only what's needed |
| Scripts | 0 tokens | Executed, not read |
| Assets | 0 tokens | Used, not read |

## When to Split Content

Split SKILL.md into reference files when:

1. **Approaching 300-400 lines** in SKILL.md
2. **Domain-specific sections** that aren't always needed
3. **Framework/variant alternatives** (only one used at a time)
4. **Detailed API docs** that support but don't drive the workflow

**Keep in SKILL.md:**
- Core workflow/process
- Decision trees for navigation
- Quick reference tables
- Topic index pointing to references

## Content Splitting Patterns

### Pattern 1: High-Level Guide with References

SKILL.md as navigation hub, details in references.

```
my-skill/
├── SKILL.md                 # Overview + decision trees + quick ref
└── references/
    ├── quickstart.md        # Getting started details
    ├── advanced.md          # Deep dive content
    └── troubleshooting.md   # Error resolution
```

**SKILL.md contains:**
```markdown
## Reference Files

| File | When to Read |
|------|--------------|
| `quickstart.md` | New to this |
| `advanced.md` | Need more control |
| `troubleshooting.md` | Having issues |

## Decision Tree

```
What do you need?
├─ Getting started → ./references/quickstart.md
├─ Advanced features → ./references/advanced.md
└─ Fix an issue → ./references/troubleshooting.md
```
```

### Pattern 2: Domain-Specific Organization

Split by domain when user queries target specific areas.

```
analytics-skill/
├── SKILL.md                 # Overview + navigation
└── references/
    ├── finance.md           # Revenue, billing metrics
    ├── sales.md             # Opportunities, pipeline
    ├── product.md           # API usage, features
    └── marketing.md         # Campaigns, attribution
```

**Benefit:** When user asks about sales metrics, only `sales.md` is loaded.

### Pattern 3: Framework/Variant Organization

Split by mutually exclusive alternatives.

```
deploy-skill/
├── SKILL.md                 # Workflow + provider selection
└── references/
    ├── aws.md               # AWS deployment patterns
    ├── gcp.md               # GCP deployment patterns
    └── azure.md             # Azure deployment patterns
```

**Benefit:** Only the relevant provider's reference is loaded.

### Pattern 4: Conditional Details

Split rarely-needed detailed information.

```
api-skill/
├── SKILL.md                 # Common operations
└── references/
    ├── endpoints.md         # Full API reference
    ├── schemas.md           # Data schemas
    └── errors.md            # Error codes
```

**SKILL.md might say:**
```markdown
For complete endpoint reference, see `./references/endpoints.md`.
```

## Structural Guidelines

### Keep References Flat

```
# Good: One level deep
references/
├── topic1.md
├── topic2.md
└── topic3.md

# Bad: Nested references
references/
├── category1/
│   ├── subtopic1.md
│   └── subtopic2.md
└── category2/
    └── subtopic3.md
```

### Include Navigation in Long References

For reference files >100 lines, add a table of contents:

```markdown
# API Reference

## Contents

- [Authentication](#authentication)
- [Endpoints](#endpoints)
- [Error Handling](#error-handling)

## Authentication

...
```

### Avoid Duplication

Information should live in **one place**:

```markdown
# Bad: Same info in two places
# SKILL.md
## Installation
pip install foo

# references/quickstart.md
## Installation
pip install foo

# Good: Reference points to details
# SKILL.md
For installation, see `./references/quickstart.md`.

# references/quickstart.md
## Installation
pip install foo
```

### Reference with Context

When pointing to references, explain what's there:

```markdown
# Good
For database schema details, see `./references/schema.md`.

# Less helpful
See `./references/schema.md`.
```

## Design Principle: Right-Size Each Level

### SKILL.md (Level 2): Concise is Key

Challenge each piece of SKILL.md content:

- "Does the agent really need this explanation?"
- "Does this paragraph justify its token cost?"
- "Could this be an example instead of prose?"

**Default assumption:** The agent is already smart. Only add context it doesn't already have.

### Reference Files (Level 3): Thorough is Key

Reference files have fundamentally different token economics — they are loaded only when an agent specifically needs that information. Apply a different lens:

- "Would a researcher need this detail to use the data correctly?"
- "Would omitting this cause an analyst to make a wrong assumption?"
- "Is this knowledge that would be lost if not encoded here?"

**Default assumption for reference files:** Encode everything discovered during profiling. Information not written down is information lost. The cost of including too much in a reference file is near-zero (it only loads when needed); the cost of omitting important detail is a future analyst making avoidable mistakes.

## Summary

| Level | Content | Load Time | Optimization |
|-------|---------|-----------|--------------|
| 1 | Metadata | Startup | Keep description focused |
| 2 | Body | On trigger | Stay under 500 lines |
| 3 | Resources | On demand | Split by domain/variant |

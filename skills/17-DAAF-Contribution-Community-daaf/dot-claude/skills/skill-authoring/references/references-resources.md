# Bundled Resources

Skills can include optional resource directories alongside SKILL.md. Each directory type serves a different purpose and has different loading characteristics.

## Directory Overview

```
my-skill/
├── SKILL.md              # Required
├── scripts/              # Executable code
├── references/           # Documentation to read
└── assets/               # Files for output
```

| Directory | Purpose | Loaded to Context? | Token Cost |
|-----------|---------|-------------------|------------|
| `scripts/` | Executable code | Usually no (executed) | ~0 |
| `references/` | Documentation | Yes (when needed) | Variable |
| `assets/` | Templates, images | No (used in output) | 0 |

## scripts/ Directory

Executable code that the agent can run during skill execution.

### When to Use

- Same code gets rewritten repeatedly
- Deterministic operations needed
- Complex/fragile procedures
- Operations that benefit from consistency

### Characteristics

- **Executed without reading**: Agent runs the script, doesn't load content
- **Zero token cost**: During execution (unless debugging)
- **Can be read**: Agent may read scripts for patching or understanding
- **Tested independently**: Should work when run manually

### Examples

```
scripts/
├── rotate_pdf.py         # PDF manipulation
├── fetch_data.py         # API calls
├── validate_config.py    # Config validation
└── generate_report.sh    # Report generation
```

### Script Patterns

**Python script with CLI:**

```python
#!/usr/bin/env python3
"""Rotate PDF pages."""

# --- Parse arguments ---
import argparse
parser = argparse.ArgumentParser()
parser.add_argument("input", help="Input PDF path")
parser.add_argument("--degrees", type=int, default=90)
args = parser.parse_args()

# --- Execute ---
print(f"Rotated {args.input} by {args.degrees} degrees")
```

**Bash script:**

```bash
#!/bin/bash
# Fetch and process data
set -e

INPUT_URL="$1"
OUTPUT_FILE="$2"

curl -s "$INPUT_URL" | jq '.data' > "$OUTPUT_FILE"
echo "Data saved to $OUTPUT_FILE"
```

### Script Quality Guidelines

#### Solve, Don't Punt

Scripts should handle error conditions explicitly rather than failing and leaving it to the agent to figure out:

```python
# Good: Handle errors explicitly
def process_file(path):
    """Process a file, creating it if it doesn't exist."""
    try:
        with open(path) as f:
            return f.read()
    except FileNotFoundError:
        print(f"File {path} not found, creating default")
        with open(path, "w") as f:
            f.write("")
        return ""
    except PermissionError:
        print(f"Cannot access {path}, using default")
        return ""

# Bad: Punt to the agent
def process_file(path):
    return open(path).read()  # just fails
```

#### Self-Documenting Constants

Avoid "voodoo constants" — unexplained magic numbers. Document why each value was chosen:

```python
# Good: Self-documenting
# HTTP requests typically complete within 30 seconds
# Longer timeout accounts for slow connections
REQUEST_TIMEOUT = 30

# Three retries balances reliability vs speed
# Most intermittent failures resolve by the second retry
MAX_RETRIES = 3

# Bad: Magic numbers
TIMEOUT = 47  # Why 47?
RETRIES = 5   # Why 5?
```

#### Verbose Validation Messages

Make validation scripts produce specific, actionable error messages:

```python
# Good: Specific and actionable
if field not in available_fields:
    print(f"Field '{field}' not found. Available: {', '.join(available_fields)}")

# Bad: Vague
if field not in available_fields:
    print("Invalid field")
```

### Referencing Scripts in SKILL.md

```markdown
## Rotating PDFs

Use the bundled script:

```bash
python ./scripts/rotate_pdf.py input.pdf --degrees 90
```

The script accepts:
- `input`: Path to PDF file
- `--degrees`: Rotation angle (default: 90)
```

### Execute vs. Read Intent

Make clear whether the agent should run a script or read it for understanding:

```markdown
# Execute (most common — more reliable and token-efficient)
Run `scripts/analyze_form.py` to extract form fields.

# Read as reference (for understanding complex logic)
See `scripts/analyze_form.py` for the field extraction algorithm.
```

For most utility scripts, execution is preferred because it's more reliable, saves tokens (no code generation needed), and ensures consistency across uses.

### When Agent Reads Scripts

- Debugging script failures
- Adapting to environment differences
- Understanding parameters
- Modifying behavior

## references/ Directory

Documentation files that get loaded into context when the agent needs them.

### When to Use

- Detailed information too long for SKILL.md
- Domain-specific documentation
- API references, schemas
- Information needed only for specific tasks

### Characteristics

- **Loaded on demand**: Agent reads when it determines need
- **Variable token cost**: Full file content
- **Markdown format**: Typically `.md` files
- **One level deep**: Don't nest subdirectories

### Examples

```
references/
├── api-endpoints.md      # API documentation
├── schema.md             # Data schemas
├── style-guide.md        # Coding standards
├── finance.md            # Domain: finance
├── sales.md              # Domain: sales
└── troubleshooting.md    # Common issues
```

### Reference File Structure

Good reference files have:

1. **Clear title** matching the filename
2. **Table of contents** (if >100 lines)
3. **Focused scope** (one domain/topic)
4. **Examples** throughout

```markdown
# API Endpoints Reference

## Contents

- [Authentication](#authentication)
- [Users API](#users-api)
- [Data API](#data-api)

## Authentication

All endpoints require Bearer token:

```bash
curl -H "Authorization: Bearer $TOKEN" ...
```

## Users API

### GET /users

Returns list of users.

```json
{
  "users": [{"id": 1, "name": "Alice"}]
}
```
```

### Referencing in SKILL.md

```markdown
## API Operations

For endpoint details, see `./references/api-endpoints.md`.

Common operations:
- List users: `GET /users`
- Create user: `POST /users`
```

### Guidelines for References

| Do | Don't |
|----|-------|
| One topic per file | Mix unrelated topics |
| Include examples | Wall of prose |
| Add TOC for long files | Skip navigation |
| Keep flat structure | Nest directories |

## assets/ Directory

Files used directly in output without being read into context.

### When to Use

- Templates to copy/modify
- Boilerplate code
- Images, icons, fonts
- Sample files
- Project scaffolds

### Characteristics

- **Not loaded to context**: Used directly in output
- **Zero token cost**: Agent doesn't read content
- **Any file type**: Not limited to Markdown
- **Copied or referenced**: Used as-is or as starting point

### Examples

```
assets/
├── logo.png              # Brand asset
├── template.html         # HTML template
├── config.example.json   # Config template
├── slides.pptx           # Presentation template
└── react-starter/        # Project scaffold
    ├── package.json
    ├── src/
    └── public/
```

### Asset Patterns

**Template file:**

```
assets/config.example.json
```

```json
{
  "database": {
    "host": "localhost",
    "port": 5432,
    "name": "myapp"
  },
  "api": {
    "key": "YOUR_API_KEY_HERE"
  }
}
```

**Project scaffold:**

```
assets/express-starter/
├── package.json
├── src/
│   ├── index.js
│   └── routes/
└── README.md
```

### Referencing in SKILL.md

```markdown
## Creating New Project

Copy the starter template:

```bash
cp -r ./assets/express-starter ./my-new-project
```

Then customize `package.json` and `src/index.js`.
```

## Choosing the Right Resource Type

| Scenario | Use |
|----------|-----|
| Reusable code that runs | `scripts/` |
| Documentation for agent to read | `references/` |
| Files agent creates/copies for user | `assets/` |
| Code examples to show in output | `assets/` |
| API schemas agent needs to understand | `references/` |
| Validation logic | `scripts/` |

### Decision Flow

```
Is it executable code?
├─ Yes → scripts/
└─ No
   ├─ Does agent need to read/understand it?
   │  ├─ Yes → references/
   │  └─ No → assets/
   └─ Is it a template/starting point?
      └─ Yes → assets/
```

## Resource Best Practices

### Testing Scripts

Always test scripts before including:

```bash
# Test manually
python ./scripts/process.py test-input.txt

# Verify exit codes
echo $?
```

### Setting Executable Permissions

All `.sh` files in `scripts/` must have executable permissions set both on the filesystem and in Git's index. After creating a shell script, run:

```bash
chmod +x ./scripts/generate_report.sh
git update-index --chmod=+x ./scripts/generate_report.sh
```

Verify with `git ls-files -s` — mode should be `100755`, not `100644`. See `CLAUDE.md` > Project Conventions > Shell Script Permissions for the full convention.

### Documenting Resources

In SKILL.md, explain:
- What each resource does
- When to use it
- How to invoke/reference it

### Keeping Resources Right-Sized

**For `scripts/` and `assets/`:** Keep minimal. Only include resources that get used repeatedly, provide significant value, and can't be easily regenerated. Don't include one-off scripts or large files that could be fetched.

**For `references/`:** Thoroughness is preferred over minimalism. Reference files load on-demand (Level 3), so their token cost is incurred only when needed. For data source skills, reference files should be comprehensive — collectively targeting 3x+ the SKILL.md line count. See `progressive-disclosure.md` for the "Thorough is Key" principle and `DATA_SOURCE_SKILL_TEMPLATE.md` for density guidelines.

Don't include in any resource type:
- Files that duplicate content already in SKILL.md
- Files with no clear consumer (who will read this and when?)

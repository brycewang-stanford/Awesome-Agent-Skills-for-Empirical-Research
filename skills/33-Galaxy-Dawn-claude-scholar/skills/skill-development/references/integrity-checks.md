# Skill Integrity Checks

## Minimal local checks

```bash
# referenced files exist
rg -n "references/|examples/|scripts/|assets/" SKILL.md

# skill inventory
find . -maxdepth 2 -type f | sort

# obvious editor/cache noise
find . -type d -name "__pycache__" -o -name ".DS_Store"
```

## Common failure modes
- `SKILL.md` mentions references that were never created.
- A migrated skill still refers to old agent or plugin names.
- The directory contains logs or session artifacts.
- The frontmatter name and the directory slug drift apart.
- The skill promises a script-based path but ships no runnable script.

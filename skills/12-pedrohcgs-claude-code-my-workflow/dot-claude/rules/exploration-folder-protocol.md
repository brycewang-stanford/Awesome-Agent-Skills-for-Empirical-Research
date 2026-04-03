---
paths:
  - "explorations/**"
---

# Exploration Folder Protocol

**All experimental work goes into `explorations/` first.** Never directly into production folders.

## Folder Structure

```
explorations/
├── ACTIVE_PROJECTS.md
├── [project]/
│   ├── README.md          # Goal, status, findings
│   ├── R/                 # Code (use _v1, _v2 for iterations)
│   ├── scripts/           # Test scripts
│   ├── output/            # Results
│   └── SESSION_LOG.md     # Progress notes
└── ARCHIVE/
    ├── completed_[project]/
    └── abandoned_[project]/
```

## Lifecycle

1. **Create** -- `mkdir -p explorations/[name]/{R,scripts,output}` + README from `templates/exploration-readme.md`
2. **Develop** -- work entirely within the exploration folder
3. **Decide:**

   - **Graduate to production** -- copy to `R/`, `scripts/`; requires quality >= 80, tests pass, code clear. Move to `ARCHIVE/completed_[project]/`
   - **Keep exploring** -- document next steps in README
   - **Abandon** -- move to `ARCHIVE/abandoned_[project]/` with explanation (use `templates/archive-readme.md`)

## Graduate Checklist

- [ ] Quality score >= 80
- [ ] All tests pass
- [ ] Results replicate within tolerance
- [ ] Code is clear without deep context
- [ ] README explains approach and findings

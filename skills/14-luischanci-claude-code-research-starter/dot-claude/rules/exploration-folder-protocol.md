---
paths:
  - "explorations/**"
---

# Exploration Folder Protocol

**All experimental work goes into `explorations/` first.** Never directly into production folders.

## Folder Structure

```
explorations/
├── [project]/
│   ├── README.md          # Goal, status, findings
│   ├── R/                 # Code
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

   - **Graduate to production** -- copy to production folders; requires quality >= 80, results replicate. Move to `ARCHIVE/completed_[project]/`
   - **Keep exploring** -- document next steps in README
   - **Abandon** -- move to `ARCHIVE/abandoned_[project]/` with explanation

## Graduate Checklist

- [ ] Quality score >= 80
- [ ] Results replicate within tolerance
- [ ] Code is clear without deep context
- [ ] README explains approach and findings

---
name: validate-bib
description: Validate bibliography entries against citations in manuscript and Quarto book files. Find missing entries, unused references, potential typos, and quality issues. This skill should be used when asked to "check the bibliography", "validate citations", or "validate-bib".
allowed-tools: ["Read", "Grep", "Glob"]
---

# Validate Bibliography

Cross-reference all citations in manuscript and book files against bibliography entries.

---

## Workflow

### Step 1: Read the bibliography

Read `docs/overleaf/refs.bib` and extract all citation keys.

### Step 2: Scan all files for citation keys

- **`.tex` files** in `docs/overleaf/`: look for `\textcite{`, `\parencite{`, `\cite{`, `\citet{`, `\citep{`, `\citeauthor{`, `\citeyear{}`
- **`.qmd` files** in `book/`: look for `@key`, `[@key]`, `[@key1; @key2]`
- Extract all unique citation keys used

### Step 3: Cross-reference

- **Missing entries (CRITICAL):** Citations used in files but NOT in `refs.bib`
- **Unused entries (informational):** Entries in `refs.bib` not cited anywhere
- **Potential typos:** Similar-but-not-matching keys (Levenshtein distance)

### Step 4: Check entry quality

For each bib entry:
- Required fields present (author, title, year, journal/booktitle)
- Author field properly formatted (Last, First and Last, First)
- Year is reasonable (1900-2026)
- No malformed characters or encoding issues
- Entry type appropriate (@article, @incollection, @techreport, etc.)

### Step 5: Report findings

```markdown
## Bibliography Validation Report
**Date:** YYYY-MM-DD
**Bibliography:** docs/overleaf/refs.bib
**Total entries:** N
**Files scanned:** N .tex + N .qmd

### Missing Entries (CRITICAL)
| Citation Key | Used In | Line |
|-------------|---------|------|
| ... | ... | ... |

### Unused Entries
| Citation Key | Entry Type |
|-------------|------------|
| ... | ... |

### Potential Typos
| Used Key | Similar Bib Key | File |
|----------|----------------|------|
| ... | ... | ... |

### Quality Issues
| Citation Key | Issue |
|-------------|-------|
| ... | Missing journal field |
```

---

## Files to scan

```
docs/overleaf/*.tex
book/*.qmd
```

## Bibliography location

```
docs/overleaf/refs.bib
```

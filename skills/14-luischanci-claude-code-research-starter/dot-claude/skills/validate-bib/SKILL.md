---
name: validate-bib
description: Validate bibliography entries against citations in all manuscript files. Find missing entries and unused references.
disable-model-invocation: true
allowed-tools: ["Read", "Grep", "Glob"]
---

## Validate Bibliography

Cross-reference all citations in manuscript files against bibliography entries.

### Steps

1. **Read the bibliography file(s)**: Find `.bib` files in the project.

2. **Scan manuscript files** for citation commands:
   - LaTeX: `\cite{}`, `\citet{}`, `\citep{}`, `\citeauthor{}`, `\citeyear{}`
   - Extract all citation keys

3. **Cross-reference**:
   - **Missing entries (CRITICAL):** Citation keys in `.tex` files without matching `.bib` entries
   - **Unused entries (INFO):** `.bib` entries not cited anywhere
   - **Potential typos:** Citation keys that look similar to existing entries (edit distance <= 2)

4. **Check entry quality**:
   - Required fields present (author, title, year, journal/booktitle)
   - Author formatting consistent
   - Year values reasonable
   - No encoding issues in special characters

5. **Report** findings with severity levels.

### Notes
- Missing entries are CRITICAL because they cause compilation warnings.
- Unused entries are informational -- the user may want to keep them for future use.

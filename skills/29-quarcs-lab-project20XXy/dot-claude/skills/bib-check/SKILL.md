---
name: bib-check
description: Cross-checks citation keys in index.qmd against references.bib, reporting missing, orphaned, and duplicate entries. Use when verifying citations.
allowed-tools: Bash, Read, Glob, Grep
---

# Audit Citations and References

Cross-check all citation keys in the manuscript against `references.bib` and report mismatches.

## Steps

1. Read `index.qmd` and extract every citation key:
   - Narrative citations: `@key`
   - Parenthetical citations: `[@key]`, `[@key1; @key2]`
   - Ignore email addresses and `@sec-`, `@fig-`, `@tbl-` cross-references

2. Read `references.bib` and extract every entry key (the identifier after `@article{`, `@book{`, etc.)

3. Check for duplicate keys within `references.bib` (same key defined more than once)

4. Report three categories:

   **Errors — cited in manuscript but missing from `.bib`:**
   - List each missing key with the line number in `index.qmd` where it appears
   - For each, suggest running `/project:cite <key>` to add the entry

   **Orphaned — in `.bib` but never cited in manuscript:**
   - List each unused key (informational, not necessarily a problem)

   **Duplicates — same key appears multiple times in `.bib`:**
   - List each duplicate with line numbers in `references.bib`

5. Print a summary: total cited keys, total `.bib` entries, errors, orphaned, duplicates

## Error handling

- If `references.bib` does not exist, report the error and stop.
- If `index.qmd` contains no citations, report "No citations found" and stop.

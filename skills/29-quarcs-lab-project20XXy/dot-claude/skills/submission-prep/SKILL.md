---
name: submission-prep
description: Runs pre-submission checks (word count, anonymization, citations, placeholders, cross-refs) and generates a checklist. Use before journal submission.
allowed-tools: Bash, Read, Write, Edit, Glob, Grep
---

# Prepare for Submission

Run pre-submission checks and generate a submission checklist for a journal submission.

## Steps

1. **Render the manuscript** if `_manuscript/` does not exist or is stale:
   ```bash
   bash scripts/render.sh
   ```

2. **Word count** — Count words in the prose body of `index.qmd`:
   - Exclude YAML front matter, code blocks, embed shortcodes, and the References section
   - Report: total word count, and breakdown by section
   - Flag if over common limits (8,000 or 10,000 words)

3. **Anonymization check** — Scan `index.qmd` for content that may violate double-blind review:
   - Author names (from the YAML `author` field) appearing in the body text
   - First-person self-citations (e.g., "our previous work", "we showed in Author (Year)")
   - Acknowledgments section content that identifies the authors
   - Repository URLs that reveal author identity
   - Report each finding with line numbers

4. **Citation audit** — Cross-check citations and references:
   - Extract all `@key` and `[@key]` citations from `index.qmd`
   - Extract all keys from `references.bib`
   - Report:
     - Citations used in text but missing from `.bib` (errors)
     - Entries in `.bib` not cited in the manuscript (unused — informational only)

5. **Figures and tables inventory** — List all embedded outputs:
   - Extract all `{{< embed >}}` shortcodes from `index.qmd`
   - For each, check that the referenced notebook and cell label exist
   - Report a table: label, notebook, caption (from cell directive), type (figure/table)

6. **Placeholder check** — Scan for orphan `[FILL:]` placeholders in `index.qmd`:
   ```bash
   grep -n "\[FILL:" index.qmd
   ```
   Report each with line number and context.

7. **Cross-reference check** — Scan for `@sec-`, `@fig-`, `@tbl-` references in `index.qmd` and verify each target exists (section IDs in the document, figure/table labels in notebooks).

8. **Generate submission checklist:**

   ```markdown
   ## Submission Checklist

   - [ ] Word count within journal limit: <count> words
   - [ ] No anonymization issues (or list issues to fix)
   - [ ] All citations resolve to references.bib entries
   - [ ] No orphan [FILL:] placeholders in manuscript
   - [ ] All embedded figures/tables have valid notebook sources
   - [ ] All cross-references resolve
   - [ ] Abstract present and complete
   - [ ] Keywords listed
   - [ ] Acknowledgments section reviewed
   - [ ] Data availability statement included
   - [ ] PDF renders without errors
   - [ ] Figures are high resolution
   - [ ] Supplementary materials prepared (if applicable)
   ```

9. Report the full checklist with pass/fail status for each automated check, and leave manual items unchecked for the user.

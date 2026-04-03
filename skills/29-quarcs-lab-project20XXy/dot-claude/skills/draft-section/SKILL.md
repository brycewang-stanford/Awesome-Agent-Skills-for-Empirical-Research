---
name: draft-section
description: Drafts academic prose for a manuscript section from bullet points or an outline. Use when writing or expanding a section.
argument-hint: "<section>: <notes>"
allowed-tools: Bash, Read, Write, Edit, Glob, Grep
---

# Draft Manuscript Section

Draft academic prose for a manuscript section from bullet points or an outline.

## Arguments

- `$ARGUMENTS` — section name and content notes (e.g., "Introduction: regional GDP disparities, panel data from 2000-2020, spatial econometrics, contributes to convergence literature")

## Steps

1. Parse the section name and content bullets/notes from the arguments.

2. Read `index.qmd` to understand:
   - The manuscript's existing tone and writing style
   - What sections already exist and their content
   - Citation conventions used (narrative `@key` vs parenthetical `[@key]`)
   - What figures and tables are embedded (to reference them)

3. Read `references.bib` to know which citations are available for use.

4. Draft 2–5 paragraphs of academic prose:
   - Write in the register of empirical economics journals (AER, QJE, ReStud style)
   - Use formal but accessible language
   - Structure paragraphs logically: general → specific, or claim → evidence → implication
   - Include Quarto cross-references where appropriate (`@sec-`, `@fig-`, `@tbl-`)
   - Insert citations from `references.bib` where they strengthen the argument
   - Where a citation would be helpful but none exists in `.bib`, insert a placeholder: `[CITE: description of needed reference]`

5. If the section matches an existing section in `index.qmd` (e.g., "Introduction" matches `## Introduction {#sec-introduction}`):
   - Show how the draft would replace the current `[FILL:]` placeholders or extend existing content
   - Preserve any `{{< embed >}}` shortcodes already in that section

6. Present the draft to the user for review. On approval, insert or replace the content in `index.qmd`.

## Error handling

- If no section name is provided, ask the user which section to draft.
- If the arguments are too vague, ask for more specific content points.

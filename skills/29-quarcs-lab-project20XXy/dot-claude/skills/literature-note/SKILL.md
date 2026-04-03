---
name: literature-note
description: Creates a structured annotation note in references/ with sections for research question, data, findings, and relevance. Use when documenting a paper.
argument-hint: <key, DOI, or description>
allowed-tools: Bash, Read, Write, Edit, Glob, Grep, WebSearch, WebFetch
---

# Create Literature Note

Create a structured annotation note for a paper in `references/`.

## Arguments

- `$ARGUMENTS` — a citation key from `references.bib`, a DOI, or a paper description (e.g., "acemoglu2001colonial" or "Acemoglu 2001 colonial origins")

## Steps

1. Parse the argument:
   - If it matches an existing key in `references.bib`, use that entry's metadata
   - If it is a DOI or description, search for the paper and optionally add it to `references.bib` first (offer to run the `/project:cite` workflow)

2. If a URL or DOI is provided, attempt to fetch and read the paper to extract key information.

3. Create a Markdown file in `references/` named `<citation-key>.md` with this structure:

   ```markdown
   # <Author (Year)> — <Short Title>

   **Citation key:** `<key>`
   **Full reference:** <formatted reference>

   ## Research Question

   [What question does this paper address?]

   ## Identification Strategy

   [How do the authors establish causality? What is the main source of variation?]

   ## Data and Sample

   [What data do they use? What is the sample period, unit of observation, and sample size?]

   ## Key Findings

   - [Finding 1]
   - [Finding 2]
   - [Finding 3]

   ## Methodology Notes

   [Econometric methods, estimators, robustness checks worth noting]

   ## Relevance to This Project

   [How does this paper relate to the current research? What can we build on or contrast with?]
   ```

4. If information about the paper was retrieved (from the web or a PDF), pre-fill the sections with extracted content. Otherwise, leave the bracket placeholders for the user to fill in.

5. Report the file path and remind the user to fill in any remaining placeholder sections.

## Error handling

- If the citation key is not found in `references.bib` and cannot be resolved, ask the user for more details.
- If `references/<key>.md` already exists, show the existing note and ask if the user wants to update it.

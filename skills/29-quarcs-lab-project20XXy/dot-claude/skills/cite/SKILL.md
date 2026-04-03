---
name: cite
description: Finds a paper by title, author, or DOI, adds BibTeX to references.bib, and shows citation syntax. Use when adding a reference.
argument-hint: <paper or DOI>
allowed-tools: Bash, Read, Write, Edit, Glob, Grep, WebSearch, WebFetch
---

# Add Citation

Find a paper, create a BibTeX entry, add it to `references.bib`, and provide the citation syntax.

## Arguments

- `$ARGUMENTS` — a paper description, title, author name, or DOI (e.g., "Acemoglu 2001 colonial origins" or "10.1257/aer.91.5.1369")

## Steps

1. Parse the argument to determine if it is a DOI or a descriptive search query.

2. Search for the paper:
   - If a DOI is provided, fetch the metadata directly (use web search or CrossRef)
   - If a description is provided, search the web to identify the paper and its DOI/metadata

3. Construct a valid BibTeX entry with these fields (at minimum):
   - `@article{key,` (or `@book`, `@incollection`, etc. as appropriate)
   - `author`, `title`, `journal` (or `booktitle`), `year`, `volume`, `number`, `pages`, `doi`
   - Use a citation key in the format: `lastname_yearword` (e.g., `acemoglu2001colonial`)

4. Read `references.bib` and check for duplicate keys:
   - If the exact key already exists, inform the user and show the existing entry
   - If a similar key exists (same author and year), warn the user

5. Append the new entry to `references.bib` (add a blank line before the new entry)

6. Show the user the citation syntax for use in `index.qmd`:
   - Narrative: `@key` → "Author (Year)"
   - Parenthetical: `[@key]` → "(Author, Year)"
   - Multiple: `[@key1; @key2]`

7. Ask if the user wants to create an annotation note in `references/` (see `/project:literature-note`)

## Error handling

- If the paper cannot be found, report the search results and ask the user to provide more details or a DOI.
- If `references.bib` does not exist, create it with the new entry.

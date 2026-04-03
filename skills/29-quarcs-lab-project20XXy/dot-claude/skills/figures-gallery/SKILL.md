---
name: figures-gallery
description: Generates an HTML gallery of all project figures with captions and source notebooks. Use when reviewing figures.
allowed-tools: Bash, Read, Write, Glob, Grep
---

# Generate Figures Gallery

Create an HTML gallery page displaying all project figures with their captions and source notebooks.

## Steps

1. Scan `images/` for all image files:
   - Supported formats: `.png`, `.jpg`, `.jpeg`, `.svg`, `.pdf`
   - Record each file's name, path, and modification date

2. Scan all registered notebooks (from `_quarto.yml`) for cells with `fig-` labels:
   - Extract the cell label (e.g., `fig-sample`, `fig-event-study`)
   - Extract the caption from `#| fig-cap:` or `*| fig-cap:` directives
   - Record the source notebook path

3. Generate an HTML gallery page with:
   - A title and generation timestamp
   - For each figure from `images/`:
     - Image thumbnail (or placeholder for PDFs)
     - Filename as caption
     - File size and dimensions (if determinable)
   - For each figure from notebooks:
     - The cell label
     - The caption (from cell directive)
     - The source notebook name
     - The embed shortcode: `{{< embed notebooks/<name>.ipynb#<label> >}}`
   - Simple CSS styling for a grid layout

4. Save the gallery to `_manuscript/figures-gallery.html` (the `_manuscript/` directory is gitignored, so this output won't be committed).

5. Report:
   - File path to the gallery
   - Count of figures from `images/`
   - Count of figure cells from notebooks
   - Command to open: `open _manuscript/figures-gallery.html`

## Error handling

- If `images/` does not exist or is empty, note it and continue with notebook figures.
- If no notebooks have `fig-` labeled cells, note it and continue with `images/` files.
- If both sources are empty, report "No figures found in the project."

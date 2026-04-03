---
name: deploy
description: Render Quarto slides and sync to docs/ for GitHub Pages deployment. Use when deploying lecture slides after making changes.
disable-model-invocation: true
argument-hint: "[LectureN or 'all']"
allowed-tools: ["Read", "Bash"]
---

# Deploy Slides to GitHub Pages

Render Quarto slides and sync all files to `docs/` for GitHub Pages deployment.

## Steps

1. **Run the sync script:**
   - If `$ARGUMENTS` is provided (e.g., "Lecture4"): `./scripts/sync_to_docs.sh $ARGUMENTS`
   - If no argument: `./scripts/sync_to_docs.sh` (syncs all lectures)

2. **Verify deployment:**
   - Check that HTML files exist in `docs/slides/`
   - Check that `_files/` directories were copied (RevealJS assets)
   - Check that `docs/Figures/` was synced from `Figures/`

3. **Verify interactive charts** (if applicable):
   - Grep rendered HTML for interactive widget count
   - Confirm count matches expected

4. **Verify TikZ SVGs** (if applicable):
   - Check that all referenced SVG files exist in `docs/Figures/LectureN/`

5. **Open in browser** for visual verification:
   - `open docs/slides/LectureX_Name.html`
   - Confirm slides render, images display, navigation works

6. **Report results** to the user

## What the sync script does:
- Renders all `.qmd` files in `Quarto/` (skips `*_backup*` files)
- Copies HTML and `_files/` directories to `docs/slides/`
- Copies Beamer PDFs from `Slides/` to `docs/slides/`
- Syncs `Figures/` to `docs/Figures/` using rsync

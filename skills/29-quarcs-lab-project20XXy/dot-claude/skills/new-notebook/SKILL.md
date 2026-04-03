---
name: new-notebook
description: Creates a Jupyter notebook with Jupytext pairing and registers it in _quarto.yml. Use when adding a new notebook.
argument-hint: <name> <title>
allowed-tools: Bash, Read, Write, Edit, Glob, Grep
---

# Create New Notebook

Create a new Jupyter notebook with Jupytext pairing and register it in the manuscript.

## Arguments

- `$ARGUMENTS` — the notebook name and title (e.g., "notebook-02 Regression Analysis")

## Steps

1. Parse the name and title from the arguments. Follow the naming convention: `notebook-NN.ipynb` (sequential numbering)
2. Check `notebooks/` for existing notebooks to determine the next number
3. Create the `.ipynb` file in `notebooks/` with:
   - The correct kernel (ask user: Python, R, or Stata)
   - A first code cell with the setup appropriate for the chosen kernel:
     - **Python:** `import sys; sys.path.insert(0, ".."); from config import set_seeds, DATA_DIR; set_seeds()`
     - **R:** `source("../config.R"); set_seeds()`
     - **Stata:** `clear all` followed by `set seed 42`
   - A markdown cell with the notebook title
4. Create the Jupytext `.md` pair by running: `uv run jupytext --set-formats ipynb,md:myst notebooks/<name>.ipynb`
5. Register the notebook in `_quarto.yml` under `manuscript.notebooks`:
   ```yaml
   - notebook: notebooks/<name>.ipynb
     title: "N<number>: <title>"
   ```
6. Confirm the notebook renders: `quarto render notebooks/<name>.ipynb`

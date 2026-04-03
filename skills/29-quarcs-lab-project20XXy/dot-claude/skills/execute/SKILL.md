---
name: execute
description: Executes all registered notebooks, strips noisy cell metadata, and syncs Jupytext pairs. Use when asked to re-run notebooks or refresh outputs.
disable-model-invocation: true
allowed-tools: Bash, Read, Write, Edit, Glob, Grep
---

# Execute All Notebooks

Execute all registered notebooks, strip noisy metadata, and sync Jupytext pairs.

## Steps

1. Read `_quarto.yml` and extract all notebook paths from `manuscript.notebooks`
2. For each notebook, execute it:
   ```bash
   uv run jupyter execute --inplace notebooks/<name>.ipynb
   ```
   Record execution time and success/failure for each notebook.
3. After all notebooks execute, strip noisy cell metadata from every `.ipynb` file.
   Open each `.ipynb` as JSON and remove these keys from every cell's `metadata` object:
   - `execution` (timestamps added by `jupyter execute`)
   - `_sphinx_cell_id` (MyST/Sphinx artifact)
   - `vscode` (VS Code editor state)
   Save the cleaned JSON back to the file (preserve formatting with 1-space indent).
4. Sync all Jupytext `.md` pairs:
   ```bash
   uv run jupytext --sync notebooks/<name>.md
   ```
5. Report a summary table:
   - Notebook name
   - Status (success / failure)
   - Execution time
   - Any errors or warnings

## Error handling

- If a notebook fails to execute, continue with the remaining notebooks. Report the error at the end.
- If `_quarto.yml` has no notebooks registered, report "No notebooks found in _quarto.yml" and stop.

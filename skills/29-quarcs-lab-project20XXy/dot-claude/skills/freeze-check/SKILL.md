---
name: freeze-check
description: Checks whether registered notebooks have current, stale, or missing outputs. Use before rendering or to verify freshness.
allowed-tools: Bash, Read, Glob, Grep
---

# Check Notebook Execution Freshness

Verify that all registered notebooks have been executed and their outputs are current.

## Steps

1. Read `_quarto.yml` and extract all notebook paths from `manuscript.notebooks`.

2. For each registered notebook, check:
   - **Has outputs:** Open the `.ipynb` JSON and check if any code cells have non-empty `outputs` arrays
   - **Last modified:** File modification timestamp of the `.ipynb`
   - **Outputs age:** Check `execution` metadata timestamps in cell metadata (if present) to determine when outputs were last generated
   - **Freeze cache:** Check if `_freeze/notebooks/<name>/` directory exists and contains cached output

3. Determine freshness status for each notebook:
   - **Current:** has outputs and the `.ipynb` has not been modified since outputs were generated
   - **Stale:** has outputs but the `.ipynb` source cells have been modified more recently than the outputs
   - **Unexecuted:** no outputs in any code cell
   - **Freeze only:** no cell outputs but a `_freeze/` cache exists (Quarto will use the cache)

4. Report a summary table:

   ```
   Notebook              Has Outputs   Last Modified        Status
   ─────────────────────────────────────────────────────────────────
   notebook-01.ipynb     Yes           2026-02-28 14:30     Current
   notebook-02.ipynb     Yes           2026-03-01 09:15     Stale
   notebook-03.ipynb     No            2026-02-25 11:00     Unexecuted
   ```

5. If any notebooks are stale or unexecuted, flag them and offer to run `/project:execute` to re-execute all notebooks.

6. If all notebooks are current, report "All notebooks are up to date."

## Error handling

- If `_quarto.yml` has no notebooks registered, report "No notebooks found in _quarto.yml" and stop.
- If a registered notebook file does not exist on disk, flag it as missing.

---
name: data-audit
description: Scans notebooks for data file references and verifies each file exists on disk. Use when checking for broken data paths.
allowed-tools: Bash, Read, Glob, Grep
---

# Audit Data References

Scan all notebooks for data file references and verify they exist on disk.

## Steps

1. Scan all `.ipynb` files in `notebooks/` for data loading patterns:
   - **Python:** `pd.read_csv(...)`, `pd.read_stata(...)`, `pd.read_excel(...)`, `pd.read_parquet(...)`, `open(...)`, `np.loadtxt(...)`
   - **R:** `read.csv(...)`, `read_csv(...)`, `read.dta(...)`, `haven::read_dta(...)`, `readxl::read_excel(...)`, `load(...)`
   - **Stata:** `use "..."`, `import delimited "..."`, `import excel "..."`, `insheet using "..."`
   - Also check the `.md` Jupytext pairs for the same patterns

2. Extract every referenced file path and normalize it:
   - Resolve relative paths from the notebook's directory (`notebooks/`)
   - Resolve paths using `DATA_DIR`, `RAW_DATA_DIR` from `config.py` / `config.R`

3. Check that each referenced file exists in `data/rawData/` or `data/`

4. Scan `data/rawData/` and `data/` for all data files present on disk

5. Report three categories:

   **Resolved — referenced and found:**
   - File path, which notebook references it, line/cell number

   **Broken — referenced but not found:**
   - File path as written in code, which notebook, suggested fix (closest matching file, or note that it may need to be downloaded)

   **Undocumented — on disk but never referenced by any notebook:**
   - File path in `data/rawData/` or `data/` that no notebook loads

6. Print a summary: total references, resolved, broken, undocumented files

## Error handling

- If no notebooks exist, report "No notebooks found" and stop.
- If `data/rawData/` does not exist, warn but continue checking `data/`.

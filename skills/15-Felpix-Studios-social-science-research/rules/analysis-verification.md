---
description: After writing analysis code, run the script and verify outputs exist, are non-empty, and pass plausibility checks.
paths:
  - "scripts/**/*.R"
  - "scripts/**/*.py"
  - "notebooks/**/*.ipynb"
  - "output/**"
---

# Analysis Verification Protocol

**Run at the end of every analysis task before scoring.**

---

## For R Scripts (.R)

```bash
Rscript path/to/script.R 2>&1 | tail -30
```

- [ ] Exit code is 0 (success)
- [ ] Expected output files exist in `output/` with size > 0
- [ ] Spot-check one estimate for reasonable magnitude (not NA, Inf, or 0 everywhere)
- [ ] No warnings about missing packages or unresolved references

## For Python Scripts (.py)

```bash
python path/to/script.py 2>&1 | tail -30
```

- [ ] Exit code is 0
- [ ] Expected output files exist with size > 0
- [ ] No unhandled exception tracebacks in output

## For Jupyter Notebooks (.ipynb)

```bash
jupyter nbconvert --to notebook --execute path/to/notebook.ipynb \
  --output path/to/notebook_executed.ipynb 2>&1 | tail -30
```

- [ ] Exit code is 0
- [ ] No cell execution errors (`"ename"` key absent from cell outputs)
- [ ] Output notebook created

## For Bibliography Consistency

Grep the manuscript for all citation keys, verify each is in the bibliography:

```bash
grep -oP '\\\\cite\{[^}]+\}|@\K\w+' manuscripts/*.tex manuscripts/*.qmd 2>/dev/null | sort -u
```

- [ ] Every cited key has a matching entry in `Bibliography_base.bib` (or the project's `.bib` file)
- [ ] Flag any missing keys as CRITICAL

## Output Completeness Check

- [ ] List files in `output/tables/` and `output/figures/`
- [ ] If a paper draft exists, verify each output file is referenced in the manuscript
- [ ] Flag unreferenced outputs (may indicate omitted results)

## Verification Checklist Summary

```
[ ] Script(s) run without errors
[ ] All expected output files created (size > 0)
[ ] Spot-check: estimates are plausible
[ ] Bibliography: no missing citation keys
[ ] No unreferenced output files (or omission is intentional)
```

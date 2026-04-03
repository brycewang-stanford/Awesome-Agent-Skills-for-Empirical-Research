---
paths:
  - "**/*.tex"
  - "**/*.jl"
  - "**/*.R"
  - "scripts/**"
---

# Task Completion Verification Protocol

**At the end of EVERY task, Claude MUST verify the output works correctly.** This is non-negotiable.

## For LaTeX Manuscripts (.tex):
1. Compile with pdflatex (3-pass + bibtex):
   ```bash
   cd [paper-folder] && pdflatex -interaction=nonstopmode [manuscript].tex
   bibtex [manuscript]
   pdflatex -interaction=nonstopmode [manuscript].tex
   pdflatex -interaction=nonstopmode [manuscript].tex
   ```
2. Check for overfull hbox warnings
3. Check for undefined citations or missing references
4. Verify PDF was generated with non-zero size

## For Julia Scripts (.jl):
1. Verify module loads without errors:
   ```bash
   julia -e "include(\"[module].jl\"); using .[Module]"
   ```
2. For full pipeline: run the main script (caution: may be long-running)
3. Check that output directory contains expected files
4. Verify output files contain numeric values (not NaN or errors)

## For R Scripts (.R):
1. Run `Rscript [script].R`
2. Verify output files created
3. Spot-check: reasonable dimensions, expected file sizes

## For Bibliography (.bib):
- Check that all `\cite` references in the manuscript have entries in the .bib file
- Verify no duplicate keys

## Common Pitfalls:
- **Path separators**: Windows uses `\` but Julia/R often need `/` -- use `joinpath()` in Julia, `file.path()` in R
- **RCall interop**: Julia's RCall may fail if R libraries aren't installed system-wide
- **Bootstrap timing**: Stochastic procedures can be slow -- don't run unnecessarily

## Verification Checklist:
```
[ ] Output file created successfully
[ ] No compilation/execution errors
[ ] Figures/tables display correctly
[ ] Parameter estimates within expected ranges
[ ] Reported results to user
```

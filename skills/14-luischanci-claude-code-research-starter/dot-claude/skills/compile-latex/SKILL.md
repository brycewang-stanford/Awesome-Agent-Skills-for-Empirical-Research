---
name: compile-latex
description: Compile a LaTeX manuscript with pdflatex (3 passes + bibtex). Use when compiling the research paper.
disable-model-invocation: true
argument-hint: "[filename without .tex extension]"
allowed-tools: ["Read", "Bash", "Glob"]
---

## Compile LaTeX Manuscript

Compile a LaTeX manuscript using the standard 3-pass sequence for full citation resolution.

### Steps

1. **Identify the file**: Use `$ARGUMENTS` as the base name (without `.tex`). If no argument, look for the main `.tex` file in the paper folder.

2. **Compile** (from the paper folder):
   ```bash
   pdflatex -interaction=nonstopmode $ARGUMENTS.tex
   bibtex $ARGUMENTS
   pdflatex -interaction=nonstopmode $ARGUMENTS.tex
   pdflatex -interaction=nonstopmode $ARGUMENTS.tex
   ```

3. **Check results**:
   - Grep for `Overfull \\hbox` warnings -- count them
   - Grep for `undefined citations` or `missing references`
   - Verify PDF was generated with non-zero size: `ls -la $ARGUMENTS.pdf`
   - Report page count if `pdfinfo` is available

4. **Report**:
   - Compilation: PASS / FAIL
   - Warnings: N overfull hbox, N undefined citations
   - PDF: exists, N pages, X KB

### Notes
- Uses `pdflatex` by default. Change to `xelatex` or `lualatex` if your project requires it.
- The `.bib` file should be in the same directory or referenced with a relative path.
- Parameter estimates loaded via `\input{}` must exist at their referenced paths.

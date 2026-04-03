---
name: render
description: Runs the clean render pipeline (HTML, PDF, Word) via scripts/render.sh. Use when asked to render, build, or compile the manuscript.
disable-model-invocation: true
allowed-tools: Bash, Read, Glob, Grep
---

# Render Manuscript

Run the clean render pipeline and report results.

## Steps

1. Run `bash scripts/render.sh` to clear caches and render all formats (HTML, PDF, Word)
2. If the render fails, read the full error output and diagnose the issue
3. After a successful render, report the output file sizes:
   - `ls -lh _manuscript/index.html _manuscript/index.pdf _manuscript/index.docx`
4. Summarize any warnings from the Quarto output

---
name: check-env
description: Verifies required tools (Quarto, uv, Python, R, Stata, TeX) and Jupyter kernels are installed. Use when setting up or troubleshooting.
allowed-tools: Bash, Read, Glob, Grep
---

# Check Environment

Verify that all required tools and dependencies are installed and correctly configured.

## Steps

1. Check each required tool and report its version (or "not found"):

   | Tool | Command | Minimum |
   | ---- | ------- | ------- |
   | Quarto | `quarto --version` | >= 1.4 |
   | uv | `uv --version` | any |
   | Python | `python3 --version` | >= 3.12 |
   | R | `R --version` | optional |
   | Stata | `which stata` | optional |
   | TeX Live | `pdflatex --version` | optional (for PDF) |
   | GitHub CLI | `gh --version` | optional |

2. Check Jupyter kernels by running `uv run jupyter kernelspec list` and verify:
   - `python3` — required
   - `ir` — optional (needed for R notebooks)
   - `nbstata` — optional (needed for Stata notebooks)

3. Check the Python virtual environment:
   - Verify `.venv/` exists
   - Run `uv run python -c "import numpy; import pandas; import matplotlib; import jupytext; print('Core packages OK')"` to confirm importability

4. Check nbstata configuration (if nbstata kernel is present):
   - Verify `~/.config/nbstata/nbstata.conf` exists
   - Read it and check that `stata_dir` points to an existing directory

5. Report a structured results table:

   ```
   Tool/Check              Status    Version/Details
   ─────────────────────────────────────────────────
   Quarto                  PASS      1.6.x
   uv                      PASS      0.x.x
   Python                  PASS      3.12.x
   R                       PASS      4.x.x
   Stata                   SKIP      not found (optional)
   TeX Live                PASS      2024
   GitHub CLI              PASS      2.x.x
   Kernel: python3         PASS      installed
   Kernel: ir              PASS      installed
   Kernel: nbstata         SKIP      not installed
   .venv/                  PASS      exists
   Core Python packages    PASS      importable
   nbstata.conf            SKIP      kernel not installed
   ```

   Use PASS / FAIL / SKIP (SKIP for optional tools that are absent).

6. If any required check fails, provide the installation command or link to fix it.

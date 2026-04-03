---
name: env-snapshot
description: Captures tool versions, packages, and kernel info as a reproducibility record in notes/. Use when documenting the environment.
allowed-tools: Bash, Read, Write, Glob, Grep
---

# Document Environment Snapshot

Capture the full environment state and save it as a reproducibility record.

## Steps

1. Gather system and tool versions:
   ```bash
   uname -a                    # OS info
   quarto --version            # Quarto
   uv --version                # uv
   python3 --version           # Python
   ```

2. Capture Python package versions:
   ```bash
   uv pip list                 # all installed packages with versions
   ```

3. Capture Jupyter kernel list:
   ```bash
   uv run jupyter kernelspec list
   ```

4. If R is available, capture R session info:
   ```bash
   R -e "sessionInfo()"
   ```

5. If Stata is available, note the version:
   ```bash
   which stata                 # or check nbstata.conf for edition info
   ```
   Read `~/.config/nbstata/nbstata.conf` for `stata_dir` and `edition`.

6. If TeX Live is available:
   ```bash
   pdflatex --version | head -1
   ```

7. Generate a timestamped Markdown file with all collected information:

   ```markdown
   # Environment Snapshot — YYYY-MM-DD

   ## System
   - OS: ...
   - Platform: ...

   ## Tools
   | Tool | Version |
   | ---- | ------- |
   | Quarto | x.x.x |
   | uv | x.x.x |
   | Python | 3.12.x |
   | R | x.x.x (or N/A) |
   | Stata | SE x.x (or N/A) |
   | TeX Live | xxxx (or N/A) |

   ## Jupyter Kernels
   - python3: /path/to/kernel
   - ir: /path/to/kernel (or N/A)
   - nbstata: /path/to/kernel (or N/A)

   ## Python Packages
   | Package | Version |
   | ------- | ------- |
   | numpy | x.x.x |
   | pandas | x.x.x |
   | ... | ... |

   ## R Session Info
   (full sessionInfo() output, or "R not available")

   ## Stata Packages
   (ado dir output, or "Stata not available")
   ```

8. Save to `notes/environment-YYYYMMDD.md` (using today's date).

9. Report the file path.

---
name: latex-ecosystem-guide
description: "Comprehensive guide to LaTeX editors, packages, and typesetting workflows"
metadata:
  openclaw:
    emoji: "📐"
    category: "writing"
    subcategory: "latex"
    keywords: ["LaTeX typesetting", "LaTeX template", "LaTeX package management", "online LaTeX editor"]
    source: "https://github.com/egeerardyn/awesome-LaTeX"
---

# LaTeX Ecosystem Guide

## Overview

LaTeX remains the gold standard for typesetting academic documents in mathematics, computer science, physics, and engineering. Its precise control over document layout, equation rendering, and bibliography management makes it indispensable for journal and conference submissions.

This guide consolidates the best resources from the awesome-LaTeX repository (1,600+ stars) into an actionable reference covering editors, essential packages, document classes, bibliography management, and workflow optimization. Whether you are a LaTeX beginner setting up your first paper or an experienced user looking to streamline your pipeline, this skill provides the tools and techniques you need.

The LaTeX ecosystem is vast -- over 6,000 packages on CTAN alone. Rather than cataloging everything, this guide focuses on the packages and tools that researchers use most frequently and the workflows that save the most time.

## Editors and IDEs

### Editor Comparison

| Editor | Platform | Real-time Preview | Collaboration | Free |
|--------|----------|-------------------|---------------|------|
| Overleaf | Web | Yes | Real-time | Yes (limited) |
| TeXstudio | Desktop | Compile-based | No | Yes |
| VS Code + LaTeX Workshop | Desktop | Yes (SyncTeX) | Live Share | Yes |
| Texifier | macOS/iOS | Live | No | Paid |
| Vim + VimTeX | Terminal | Zathura/Skim | No | Yes |

### Recommended Setup: VS Code + LaTeX Workshop

```json
// .vscode/settings.json
{
  "latex-workshop.latex.autoBuild.run": "onSave",
  "latex-workshop.latex.recipe.default": "latexmk (xelatex)",
  "latex-workshop.latex.recipes": [
    {
      "name": "latexmk (xelatex)",
      "tools": ["latexmk-xelatex"]
    }
  ],
  "latex-workshop.latex.tools": [
    {
      "name": "latexmk-xelatex",
      "command": "latexmk",
      "args": [
        "-xelatex",
        "-synctex=1",
        "-interaction=nonstopmode",
        "-file-line-error",
        "%DOC%"
      ]
    }
  ],
  "latex-workshop.view.pdf.viewer": "tab"
}
```

## Essential Packages

### Document Structure

```latex
\usepackage[margin=1in]{geometry}    % Page margins
\usepackage{setspace}                 % Line spacing
\usepackage{fancyhdr}                 % Headers and footers
\usepackage{titlesec}                 % Section heading styles
\usepackage[hidelinks]{hyperref}      % Clickable cross-references
\usepackage{cleveref}                 % Smart cross-references (\cref)
```

### Mathematics

```latex
\usepackage{amsmath}      % Core math environments
\usepackage{amssymb}      % Extended symbols
\usepackage{amsthm}       % Theorem environments
\usepackage{mathtools}    % Extensions to amsmath
\usepackage{bm}           % Bold math symbols
```

### Figures and Tables

```latex
\usepackage{graphicx}     % Include images
\usepackage{subcaption}   % Subfigures
\usepackage{booktabs}     % Professional tables (\toprule, \midrule, \bottomrule)
\usepackage{multirow}     % Multi-row cells
\usepackage{siunitx}      % SI units and number formatting
```

### Code Listings

```latex
\usepackage{listings}     % Basic code listings
\usepackage{minted}       % Syntax-highlighted code (requires Pygments)
\usepackage{algorithm2e}  % Algorithm pseudocode
```

## Document Classes for Research

| Class | Use Case | Key Feature |
|-------|----------|-------------|
| `article` | Short papers, preprints | Standard LaTeX |
| `revtex4-2` | APS journals (Phys Rev) | Built-in journal styles |
| `IEEEtran` | IEEE conferences/journals | Two-column, IEEE format |
| `acmart` | ACM conferences/journals | Multiple formats (sigconf, sigplan) |
| `elsarticle` | Elsevier journals | Preprint and journal modes |
| `svjour3` | Springer journals | Springer Nature format |
| `aaai` | AAAI conference | AAAI formatting |

### Example: ACM Conference Paper

```latex
\documentclass[sigconf,review]{acmart}

\begin{document}
\title{Your Paper Title}
\author{First Author}
\affiliation{%
  \institution{University Name}
  \city{City}
  \country{Country}
}
\email{author@university.edu}

\begin{abstract}
Your abstract here.
\end{abstract}

\maketitle
\section{Introduction}
...
\end{document}
```

## Bibliography Management

### BibLaTeX + Biber (Recommended)

```latex
\usepackage[
  backend=biber,
  style=numeric-comp,
  sorting=none,
  maxbibnames=99
]{biblatex}
\addbibresource{refs.bib}

% In document body:
As shown in prior work~\cite{vaswani2017attention}...

% At the end:
\printbibliography
```

### Quick Reference: BibTeX Entry Types

```bibtex
@article{key,
  author  = {Last, First and Last2, First2},
  title   = {Paper Title},
  journal = {Journal Name},
  year    = {2024},
  volume  = {42},
  pages   = {1--15},
  doi     = {10.xxxx/xxxxx}
}

@inproceedings{key2,
  author    = {Last, First},
  title     = {Conference Paper Title},
  booktitle = {Proceedings of Conference},
  year      = {2024},
  pages     = {100--110}
}
```

## Workflow Automation

### Makefile for LaTeX Projects

```makefile
MAIN = paper
TEX = $(MAIN).tex
PDF = $(MAIN).pdf

.PHONY: all clean watch

all: $(PDF)

$(PDF): $(TEX) refs.bib
	latexmk -xelatex -interaction=nonstopmode $(TEX)

clean:
	latexmk -C

watch:
	latexmk -xelatex -pvc -interaction=nonstopmode $(TEX)
```

### Git Integration for LaTeX

```bash
# .gitignore for LaTeX projects
*.aux
*.bbl
*.blg
*.log
*.out
*.synctex.gz
*.fdb_latexmk
*.fls
*.toc
*.nav
*.snm
```

## Best Practices

- **Use `latexmk` instead of manual compilation chains.** It handles multi-pass compilation automatically.
- **Prefer `booktabs` for tables.** Never use vertical lines (`|`) in academic tables.
- **Use `\cref{}` from cleveref.** It automatically prepends "Figure," "Table," or "Equation."
- **Keep one sentence per line in source files.** This makes Git diffs readable and merges cleaner.
- **Pin your TeX distribution version.** Use Docker or Nix to ensure reproducible builds across machines.
- **Store figures as PDF or SVG for vector graphics, PNG for raster.** Never upscale low-resolution images.

## References

- [awesome-LaTeX](https://github.com/egeerardyn/awesome-LaTeX) -- Curated list of LaTeX resources (1,600+ stars)
- [CTAN](https://ctan.org/) -- Comprehensive TeX Archive Network
- [LaTeX Wikibook](https://en.wikibooks.org/wiki/LaTeX) -- Community-maintained reference
- [Overleaf Documentation](https://www.overleaf.com/learn) -- Tutorials and templates
- [LaTeX Workshop for VS Code](https://github.com/James-Yu/LaTeX-Workshop) -- VS Code extension

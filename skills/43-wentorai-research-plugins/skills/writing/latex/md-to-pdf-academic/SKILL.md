---
name: md-to-pdf-academic
description: "Convert Markdown to publication-quality PDF with LaTeX math rendering"
metadata:
  openclaw:
    emoji: "📄"
    category: "writing"
    subcategory: "latex"
    keywords: ["markdown", "PDF", "pandoc", "LaTeX rendering", "document conversion", "academic formatting"]
    source: "https://github.com/Wandmalfarbe/pandoc-latex-template"
---

# Markdown to PDF (Academic)

## Overview

Many researchers prefer writing in Markdown for its simplicity and readability, but academic publishing demands the typographic quality of LaTeX-rendered PDFs. The Markdown to PDF Academic skill bridges this gap by providing a complete workflow for converting Markdown documents—including mathematical equations, citations, cross-references, figures, and tables—into publication-quality PDFs using Pandoc and LaTeX as the rendering backend.

This approach gives you the best of both worlds: you write in clean, portable Markdown that is easy to version-control and collaborate on, while producing output that is indistinguishable from a paper written directly in LaTeX. The workflow supports all standard academic elements including numbered equations, BibTeX citations, figure floats, and custom LaTeX templates for specific journal or conference formats.

This skill is particularly useful for researchers who find LaTeX syntax cumbersome for drafting but need LaTeX-quality output, for teams where some members are not comfortable with LaTeX, and for documents that need to be published in multiple formats (PDF, HTML, DOCX) from a single source.

## Setup and Prerequisites

### Required Software

Install the following tools:

```bash
# macOS
brew install pandoc
brew install --cask mactex  # Full LaTeX distribution
# or for a minimal install:
brew install basictex
sudo tlmgr install collection-fontsrecommended latexmk

# Ubuntu/Debian
sudo apt-get install pandoc texlive-full

# Verify installation
pandoc --version
pdflatex --version
```

### Recommended Pandoc Extensions

Install useful Pandoc filters for academic writing:

```bash
# Citation processing
pip install pandoc-citeproc  # or use --citeproc flag (built-in since Pandoc 2.11)

# Cross-referencing (figures, tables, equations, sections)
pip install pandoc-crossref

# Include code from external files
pip install pandoc-include
```

### Academic LaTeX Template

Download or create a LaTeX template for your target venue. The Eisvogel template is an excellent general-purpose starting point:

```bash
# Download Eisvogel template
mkdir -p ~/.pandoc/templates
wget https://github.com/Wandmalfarbe/pandoc-latex-template/releases/latest/download/Eisvogel.tar.gz
tar -xzf Eisvogel.tar.gz -C ~/.pandoc/templates/
```

## Writing Academic Markdown

### Document Header (YAML Front Matter)

Start your Markdown document with YAML metadata:

```yaml
---
title: "Your Paper Title"
author:
  - name: "Author One"
    affiliation: "University of Example"
    email: "author@example.edu"
  - name: "Author Two"
    affiliation: "Institute of Research"
date: "March 2026"
abstract: |
  This is the abstract of the paper. It can span
  multiple lines using the YAML block scalar syntax.
keywords: ["keyword one", "keyword two", "keyword three"]
bibliography: references.bib
csl: ieee.csl
numbersections: true
header-includes:
  - \usepackage{amsmath}
  - \usepackage{booktabs}
---
```

### Mathematical Equations

Use standard LaTeX math syntax within Markdown. Pandoc processes these natively:

```markdown
Inline math: The loss function $\mathcal{L}(\theta)$ is minimized.

Display math (numbered):
$$
\mathcal{L}(\theta) = -\sum_{i=1}^{N} \log p(y_i | x_i; \theta) {#eq:loss}
$$

Multi-line equations:
$$
\begin{aligned}
\nabla_\theta \mathcal{L} &= \frac{1}{N} \sum_{i=1}^{N} \nabla_\theta \log p(y_i | x_i; \theta) \\
\theta_{t+1} &= \theta_t - \eta \nabla_\theta \mathcal{L}
\end{aligned}
$$

Reference: As shown in @eq:loss (requires pandoc-crossref).
```

### Citations

Reference entries in your BibTeX file using `@citekey` syntax:

```markdown
Recent work has shown promising results [@smith2024; @jones2025].

@smith2024 demonstrated that transformers scale efficiently.

For a comprehensive review, see [-@wang2023].
```

### Figures and Tables

```markdown
![Architecture of our proposed model. The encoder processes
input sequences while the decoder generates output tokens
autoregressively.](figures/architecture.pdf){#fig:arch width=80%}

As shown in Figure @fig:arch, the architecture consists of...

| Method | Accuracy | F1 Score | Params (M) |
|--------|----------|----------|------------|
| Baseline | 82.3 | 79.1 | 110 |
| **Ours** | **87.6** | **84.9** | 95 |

: Comparison of methods on the benchmark dataset. {#tbl:results}

Results in Table @tbl:results show that...
```

## Building the PDF

### Basic Conversion Command

```bash
pandoc paper.md \
  -o paper.pdf \
  --pdf-engine=pdflatex \
  --citeproc \
  --filter pandoc-crossref \
  --number-sections \
  --bibliography=references.bib \
  --csl=ieee.csl \
  --template=eisvogel
```

### Makefile for Reproducible Builds

Create a `Makefile` for consistent builds:

```makefile
PAPER = paper
PANDOC_FLAGS = --pdf-engine=pdflatex \
               --citeproc \
               --filter pandoc-crossref \
               --number-sections \
               --bibliography=references.bib

pdf: $(PAPER).md
	pandoc $(PAPER).md -o $(PAPER).pdf $(PANDOC_FLAGS) --template=eisvogel

docx: $(PAPER).md
	pandoc $(PAPER).md -o $(PAPER).docx $(PANDOC_FLAGS)

html: $(PAPER).md
	pandoc $(PAPER).md -o $(PAPER).html $(PANDOC_FLAGS) --standalone --mathjax

clean:
	rm -f $(PAPER).pdf $(PAPER).docx $(PAPER).html

.PHONY: pdf docx html clean
```

### Custom LaTeX Templates

For specific journal formats, create a custom Pandoc template. Start from the default and modify:

```bash
# Export default template
pandoc -D latex > my-template.tex

# Edit my-template.tex to match your journal's requirements
# Then use it:
pandoc paper.md -o paper.pdf --template=my-template.tex
```

Key template variables you can set from YAML front matter:
- `documentclass`: article, report, book, or a journal's custom class
- `fontsize`: 10pt, 11pt, 12pt
- `geometry`: margins (e.g., `margin=1in`)
- `linestretch`: line spacing (1.0 = single, 1.5 = one-and-a-half, 2.0 = double)

## Troubleshooting Common Issues

- **Missing LaTeX packages**: Install with `tlmgr install <package-name>`
- **Unicode characters in text**: Use `--pdf-engine=xelatex` or `lualatex` instead of `pdflatex`
- **Figure not found**: Use relative paths from the Markdown file's directory; ensure the file extension matches
- **Citation not resolving**: Verify the cite key matches exactly (case-sensitive) between your Markdown and `.bib` file
- **Equation numbering**: Requires `pandoc-crossref`; use `{#eq:label}` syntax after display equations
- **Table overflow**: Add `\usepackage{adjustbox}` in `header-includes` and use `\adjustbox{max width=\textwidth}` in the template

## References

- Pandoc User's Guide: https://pandoc.org/MANUAL.html
- Eisvogel LaTeX Template: https://github.com/Wandmalfarbe/pandoc-latex-template
- pandoc-crossref: https://github.com/lierdakil/pandoc-crossref
- Pandoc citations: https://pandoc.org/MANUAL.html#citations

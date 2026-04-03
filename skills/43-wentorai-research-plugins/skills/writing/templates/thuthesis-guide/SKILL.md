---
name: thuthesis-guide
description: "Write Tsinghua University theses using the ThuThesis LaTeX template"
metadata:
  openclaw:
    emoji: "🎓"
    category: "writing"
    subcategory: "templates"
    keywords: ["latex", "thesis", "tsinghua", "template", "academic-writing", "typesetting"]
    source: "https://github.com/tuna/thuthesis"
---

# ThuThesis Guide

## Overview

ThuThesis is the official LaTeX thesis template for Tsinghua University, one of China's most prestigious research institutions. Maintained by TUNA (Tsinghua University Network Administrators), the template provides comprehensive formatting for bachelor's, master's, and doctoral theses, as well as postdoctoral reports, ensuring full compliance with Tsinghua University's stringent formatting requirements.

Writing a thesis involves balancing content creation with precise typographic standards. ThuThesis eliminates the formatting burden by encoding all institutional requirements into LaTeX class files: page margins, font selections, heading hierarchy, bibliography formatting, front matter structure, and appendix layout are all handled automatically. Researchers can focus entirely on writing while the template ensures every page, caption, and citation meets the graduation office requirements.

With over 5,000 GitHub stars, ThuThesis has become the de facto standard for thesis typesetting at Tsinghua. Its codebase also serves as a reference implementation for other university thesis templates in China, influencing templates at dozens of institutions.

## Installation and Setup

**TeX Live Installation** (recommended):

ThuThesis requires a complete TeX distribution. Install TeX Live (full scheme recommended to avoid missing packages):

```bash
# On macOS via Homebrew
brew install --cask mactex

# On Ubuntu/Debian
sudo apt-get install texlive-full

# On Windows, download TeX Live from tug.org/texlive
```

**Download ThuThesis**:

```bash
git clone https://github.com/tuna/thuthesis.git
cd thuthesis
```

Alternatively, download the latest release from the GitHub releases page or install via CTAN:

```bash
tlmgr install thuthesis
```

**Compile the template**:

```bash
# Using latexmk (recommended)
latexmk -xelatex main.tex

# Or manually
xelatex main.tex
bibtex main
xelatex main.tex
xelatex main.tex
```

XeLaTeX is required rather than pdfLaTeX because the template uses system fonts for Chinese typesetting. Ensure you have the required fonts installed (SimSun, SimHei, KaiTi, FangSong for Windows; or their equivalents on macOS and Linux).

## Core Features

**Degree Type Configuration**: A single configuration option switches between thesis formats:

```latex
\documentclass[
  degree=doctor,       % bachelor, master, doctor, or postdoc
  degree-type=academic % academic or professional
]{thuthesis}
```

Each degree type automatically adjusts title page layout, committee signature pages, abstract formatting, and chapter numbering conventions.

**Bilingual Support**: Tsinghua requires both Chinese and English abstracts, title pages, and keywords. ThuThesis provides dedicated environments for each:

```latex
\begin{abstract}
  This thesis investigates the application of deep learning methods
  to protein structure prediction, focusing on attention mechanisms
  that capture long-range amino acid interactions.
\end{abstract}

\begin{abstract*}
  % Chinese abstract here
\end{abstract*}
```

**Bibliography Management**: The template integrates with BibTeX and supports the GB/T 7714 citation standard required by Chinese academic institutions:

```latex
\usepackage[backend=bibtex, style=gb7714-2015]{biblatex}
\addbibresource{references.bib}

% In text
\cite{einstein1905}
\parencite{dirac1928}
```

**Mathematical Typesetting**: Full support for equations, theorems, and proofs with consistent numbering tied to chapter structure:

```latex
\begin{theorem}\label{thm:convergence}
  Under assumptions A1--A3, the proposed estimator converges
  at rate $O(n^{-1/2})$ uniformly over the parameter space.
\end{theorem}

\begin{proof}
  By the triangle inequality and Lemma~\ref{lem:concentration}...
\end{proof}
```

**Figure and Table Formatting**: Captions, numbering, and cross-referencing follow institutional standards automatically. The template supports subfigures and multi-page tables.

## Thesis Structure and Organization

ThuThesis provides a standard project structure:

```
thuthesis/
  main.tex              # Master document
  thuthesis.cls         # Class file (do not modify)
  thuthesis-setup.tex   # Personal info and thesis metadata
  data/
    abstract.tex        # Abstracts (CN + EN)
    chap01.tex          # Chapter 1
    chap02.tex          # Chapter 2
    ...
    appendix01.tex      # Appendices
    acknowledgements.tex
    resume.tex          # Publication list
  figures/              # All figures
  ref/
    refs.bib            # Bibliography database
```

Edit `thuthesis-setup.tex` to fill in your personal information:

```latex
\thusetup{
  title  = {Deep Learning for Protein Structure Prediction},
  title* = {Your Chinese title here},
  author = {Zhang San},
  supervisor = {Prof. Li Si},
  degree-name = {Doctor of Engineering},
  department = {Department of Computer Science},
  date = {2026-06-01},
}
```

## Research Workflow Integration

**Version Control**: The plain-text LaTeX source works seamlessly with Git. Track changes across drafts, collaborate with advisors via pull requests, and maintain a complete revision history:

```bash
git init
git add main.tex data/ figures/ ref/
git commit -m "Initial thesis structure"
```

**Continuous Compilation**: Use latexmk in watch mode during writing for immediate feedback:

```bash
latexmk -xelatex -pvc main.tex
```

**Overleaf Compatibility**: Upload the ThuThesis files to Overleaf for cloud-based editing. Set the compiler to XeLaTeX in project settings. Note that some system fonts may not be available on Overleaf; the template includes fallback font configurations.

**Advisor Collaboration**: Generate PDF versions for advisor review while maintaining the LaTeX source as the canonical version. Use PDF annotation tools for feedback and incorporate changes back into the source files.

## References

- ThuThesis repository: https://github.com/tuna/thuthesis
- CTAN package page: https://ctan.org/pkg/thuthesis
- Tsinghua University thesis formatting guidelines (available through the graduate school)
- TUNA association: https://tuna.moe/

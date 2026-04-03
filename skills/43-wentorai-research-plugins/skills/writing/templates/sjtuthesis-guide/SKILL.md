---
name: sjtuthesis-guide
description: "Write SJTU theses using the SJTUThesis LaTeX template with full compliance"
metadata:
  openclaw:
    emoji: "🎓"
    category: "writing"
    subcategory: "templates"
    keywords: ["latex", "thesis", "sjtu", "template", "academic-writing", "shanghai-jiaotong"]
    source: "https://github.com/sjtug/SJTUThesis"
---

# SJTUThesis Guide

## Overview

SJTUThesis is the community-maintained LaTeX thesis template for Shanghai Jiao Tong University (SJTU), one of China's top research universities. Developed and maintained by SJTUG (SJTU Linux User Group), the template encodes all formatting requirements specified by SJTU's graduate school, enabling students to produce professionally typeset theses without manually adjusting margins, fonts, heading styles, or citation formats.

The template has evolved over many years through contributions from hundreds of SJTU students and alumni, resulting in a mature and battle-tested codebase that handles the many edge cases in Chinese academic typesetting. It supports bachelor's, master's, and doctoral degrees, accommodating differences in title page layout, committee requirements, and structural organization between degree levels.

With approximately 4,000 GitHub stars, SJTUThesis represents one of the most widely used university-specific LaTeX templates in the Chinese academic ecosystem. Its design principles and code patterns have influenced thesis templates at many other Chinese universities.

## Installation and Setup

**Prerequisites**: Install a full TeX distribution with XeLaTeX support:

```bash
# macOS
brew install --cask mactex

# Ubuntu/Debian
sudo apt-get install texlive-full

# Windows: install TeX Live or MiKTeX from official sites
```

**Download and Initialize**:

```bash
git clone https://github.com/sjtug/SJTUThesis.git
cd SJTUThesis
```

Or download the latest release archive from the GitHub releases page.

**First Compilation**:

```bash
# Recommended: use latexmk
latexmk -xelatex main.tex

# Alternative: manual compilation
xelatex main.tex
biber main
xelatex main.tex
xelatex main.tex
```

The template requires XeLaTeX for proper Chinese font handling. Ensure the required CJK fonts are available on your system. On Windows, the standard SimSun, SimHei, and KaiTi fonts are used by default. On macOS and Linux, the template can be configured to use alternative fonts.

**Font Configuration**: If system fonts differ from the defaults, modify the font setup:

```latex
% In the preamble or configuration file
\documentclass[
  type=master,
  fontset=mac   % Options: windows, mac, ubuntu, fandol
]{sjtuthesis}
```

## Core Features

**Degree Type Selection**: Configure the thesis type through document class options:

```latex
\documentclass[
  type=doctor,      % bachelor, master, doctor
  language=chinese, % chinese or english
  review=false      % Set true for blind review version
]{sjtuthesis}
```

The `review=true` option automatically strips author names, advisor information, and acknowledgements to produce an anonymous version for external review.

**Thesis Information Setup**: Define all metadata in a structured configuration block:

```latex
\sjtusetup{
  info = {
    title = {Research on Graph Neural Networks for Molecular Property Prediction},
    title* = {Chinese title here},
    author = {Wang Wu},
    supervisor = {Prof. Zhao Liu},
    department = {School of Chemistry and Chemical Engineering},
    major = {Chemical Engineering},
    date = {2026-06-15},
    keywords = {graph neural networks, molecular properties, deep learning},
    keywords* = {Chinese keywords here},
  },
}
```

**Bibliography with GB/T 7714**: The template integrates the Chinese national bibliography standard:

```latex
% Bibliography is configured automatically
% Simply maintain your refs.bib file and cite normally
\cite{wang2024molecular}
\parencite{zhang2023graphnn}
```

BibLaTeX with Biber backend is used by default, supporting the full range of entry types and fields required for Chinese academic citations including patent numbers, technical standards, and government documents.

**Mathematical Environments**: Theorem-like environments are pre-configured with Chinese labels:

```latex
\begin{theorem}[Convergence Guarantee]\label{thm:main}
  Let $f: \mathbb{R}^d \to \mathbb{R}$ be $L$-smooth and $\mu$-strongly convex.
  Then the proposed algorithm converges at rate $O(1/k^2)$.
\end{theorem}

\begin{proof}
  We proceed by establishing a Lyapunov function...
\end{proof}

\begin{definition}\label{def:stability}
  A solution $x^*$ is said to be locally stable if...
\end{definition}
```

## Project Structure

The template organizes thesis components into a clean directory hierarchy:

```
SJTUThesis/
  main.tex                  # Master document
  sjtuthesis.cls            # Class file
  contents/
    abstract.tex            # Chinese and English abstracts
    intro.tex               # Introduction chapter
    literature.tex          # Literature review
    methodology.tex         # Methods
    results.tex             # Results and discussion
    conclusion.tex          # Conclusions
    acknowledgements.tex    # Acknowledgements
    appendix.tex            # Appendices
    publications.tex        # Author publications list
  figures/                  # All figures
  bibliography/
    refs.bib                # BibTeX database
```

Each chapter is maintained as a separate file and included via the master document. This modular structure supports independent compilation of chapters during drafting and simplifies version control.

## Research Workflow Integration

**Git-Based Collaboration**: Track thesis progress with version control, create branches for experimental sections, and use meaningful commit messages to document your writing journey:

```bash
git init
git add main.tex contents/ figures/ bibliography/
git commit -m "Chapter 3: complete methodology section"
```

**Continuous Preview**: Use latexmk watch mode for real-time PDF updates during writing sessions:

```bash
latexmk -xelatex -pvc main.tex
```

**Integration with Reference Managers**: Export BibTeX entries from Zotero, Mendeley, or other managers directly into the `refs.bib` file. Use Better BibTeX for Zotero for automatic citation key generation and export synchronization.

**Overleaf Deployment**: Upload the complete template to Overleaf for browser-based editing. Set compiler to XeLaTeX. For Overleaf, use `fontset=fandol` since Fandol fonts are available on the Overleaf platform.

**Blind Review Preparation**: When submitting your thesis for external review, simply toggle the review flag and recompile:

```bash
# Edit main.tex: set review=true
latexmk -xelatex main.tex
# Output PDF has all identifying information removed
```

## Common Issues and Solutions

**Missing fonts**: Use the `fandol` fontset option if system CJK fonts are unavailable. Fandol provides open-source Chinese fonts included with TeX Live.

**Bibliography errors**: Ensure you run Biber (not BibTeX) as the bibliography processor. Check that all cited keys exist in your `.bib` file.

**Long table formatting**: For tables spanning multiple pages, use the `longtable` environment which is pre-configured in the template to match SJTU formatting requirements.

## References

- SJTUThesis repository: https://github.com/sjtug/SJTUThesis
- SJTU graduate school formatting guidelines
- SJTUG user group: https://sjtug.org/
- LaTeX workshop materials from SJTUG

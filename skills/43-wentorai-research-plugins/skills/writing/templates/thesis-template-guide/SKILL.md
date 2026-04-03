---
name: thesis-template-guide
description: "Set up LaTeX templates for PhD and Master's thesis documents"
metadata:
  openclaw:
    emoji: "🎓"
    category: "writing"
    subcategory: "templates"
    keywords: ["thesis template", "dissertation", "LaTeX thesis", "PhD writing", "graduate thesis", "document class"]
    source: "wentor-research-plugins"
---

# Thesis Template Guide

A skill for setting up and customizing LaTeX templates for PhD and Master's theses. Covers document class selection, front matter configuration, chapter organization, and strategies for managing a large multi-file LaTeX project over months or years of writing.

## Document Class Selection

### Common Thesis Classes

| Class | Description | Use Case |
|-------|------------|---------|
| `book` | Standard LaTeX class with chapters | Most flexible, requires manual formatting |
| `memoir` | Extended book class with many built-in features | Excellent default for custom templates |
| `report` | Simpler than book, supports chapters | Quick setup for shorter theses |
| University-specific | Custom class provided by your institution | Required by many universities |

### Basic Thesis Structure

```latex
\documentclass[12pt, a4paper, twoside, openright]{book}
\usepackage[utf8]{inputenc}
\usepackage[T1]{fontenc}
\usepackage[english]{babel}
\usepackage{geometry}
\geometry{margin=2.5cm, bindingoffset=1cm}

% Essential packages
\usepackage{graphicx}
\usepackage{amsmath, amssymb}
\usepackage{hyperref}
\usepackage[backend=biber, style=authoryear]{biblatex}
\addbibresource{references.bib}

\begin{document}

\frontmatter
\include{chapters/titlepage}
\include{chapters/abstract}
\include{chapters/acknowledgements}
\tableofcontents
\listoffigures
\listoftables

\mainmatter
\include{chapters/introduction}
\include{chapters/literature_review}
\include{chapters/methodology}
\include{chapters/results}
\include{chapters/discussion}
\include{chapters/conclusion}

\appendix
\include{chapters/appendix_a}

\backmatter
\printbibliography[heading=bibintoc]

\end{document}
```

## Project File Organization

### Recommended Directory Structure

```
thesis/
  main.tex              -- Master document (compile this)
  references.bib        -- Bibliography database
  preamble.tex          -- All package imports and settings
  chapters/
    titlepage.tex
    abstract.tex
    acknowledgements.tex
    introduction.tex
    literature_review.tex
    methodology.tex
    results.tex
    discussion.tex
    conclusion.tex
    appendix_a.tex
  figures/
    ch1/                -- Figures organized by chapter
    ch2/
    ch3/
  tables/
  styles/
    university.sty      -- University-specific formatting
```

### Using a Preamble File

```latex
% preamble.tex -- imported with \input{preamble} in main.tex
\usepackage{setspace}
\doublespacing                    % Most universities require double-spacing

\usepackage{fancyhdr}
\pagestyle{fancy}
\fancyhead[LE,RO]{\thepage}
\fancyhead[RE]{\leftmark}
\fancyhead[LO]{\rightmark}
\fancyfoot{}

\usepackage[font=small, labelfont=bf]{caption}
\usepackage{booktabs}             % Professional tables
\usepackage{microtype}            % Better typography

% Custom commands
\newcommand{\TODO}[1]{\textcolor{red}{\textbf{TODO: #1}}}
\newcommand{\ie}{i.e.,\xspace}
\newcommand{\eg}{e.g.,\xspace}
```

## Managing a Long Document

### Compilation Strategies

```python
def thesis_compilation_tips() -> dict:
    """
    Tips for efficiently compiling a multi-chapter thesis.
    """
    return {
        "selective_compilation": {
            "method": "\\includeonly{chapters/results}",
            "benefit": "Compile only the chapter you are working on",
            "note": "Page numbers and references stay correct"
        },
        "draft_mode": {
            "method": "\\documentclass[draft]{book}",
            "benefit": "Skips images, shows overfull boxes",
            "note": "Much faster compilation during writing"
        },
        "latexmk": {
            "command": "latexmk -pdf -pvc main.tex",
            "benefit": "Auto-recompile on file save",
            "note": "-pvc flag opens viewer with live updates"
        },
        "subfile_package": {
            "method": "\\usepackage{subfiles}",
            "benefit": "Each chapter compiles as standalone document",
            "note": "Useful for co-authoring individual chapters"
        }
    }
```

### Version Control Best Practices

```
1. Use Git for your thesis from day one
2. Commit after each writing session with descriptive messages
3. Add to .gitignore:
   *.aux *.bbl *.bcf *.blg *.fdb_latexmk *.fls
   *.log *.out *.synctex.gz *.toc *.lof *.lot *.run.xml
4. Keep generated PDFs out of version control (regenerate from source)
5. Use branches for major revisions or advisor feedback rounds
6. Tag milestones: v1-first-draft, v2-committee-review, v3-final
```

## Front Matter Essentials

### Title Page Template

```latex
% chapters/titlepage.tex
\begin{titlepage}
\centering
\vspace*{2cm}
{\LARGE\bfseries Your Thesis Title: A Study of Something Important\par}
\vspace{1.5cm}
{\Large Your Full Name\par}
\vspace{1cm}
{\large A thesis submitted in partial fulfillment of the requirements
for the degree of\par}
\vspace{0.5cm}
{\large\bfseries Doctor of Philosophy\par}
\vspace{0.5cm}
{\large Department of Your Department\par}
{\large Your University\par}
\vspace{1cm}
{\large Month Year\par}
\vfill
{\large Advisor: Prof.\ Advisor Name\par}
\end{titlepage}
```

## Common Formatting Requirements

Most universities specify margins, font size, spacing, page numbering (roman for front matter, arabic for body), and binding offset. Always obtain your institution's official formatting guidelines before starting. Many universities provide their own LaTeX class file or Word template -- use it as the base and customize minimally to avoid format rejection at submission time.

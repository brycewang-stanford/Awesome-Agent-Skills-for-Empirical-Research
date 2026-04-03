# Preamble to YAML Front Matter

Convert everything before `\begin{document}` into Quarto YAML front matter.

---

## Document Class → Format Settings

| LaTeX | Quarto YAML |
|-------|-------------|
| `\documentclass{article}` | `format:\n  pdf:\n    documentclass: article` |
| `\documentclass[12pt]{article}` | `format:\n  pdf:\n    fontsize: 12pt` |
| `\documentclass[a4paper]{article}` | `format:\n  pdf:\n    papersize: a4` |
| `\documentclass[twocolumn]{article}` | `format:\n  pdf:\n    classoption: twocolumn` |
| `\documentclass{beamer}` | `format: revealjs` (flag for review — significant restructuring needed) |
| `\documentclass{report}` | `format:\n  pdf:\n    documentclass: report` |
| `\documentclass{book}` | `format:\n  pdf:\n    documentclass: book` |

Multiple class options: `\documentclass[12pt,a4paper,twocolumn]{article}` — map each option separately.

---

## Geometry Package → PDF Margins

| LaTeX | Quarto YAML |
|-------|-------------|
| `\usepackage[margin=1in]{geometry}` | `format:\n  pdf:\n    geometry: margin=1in` |
| `\usepackage[top=1in,bottom=1in,left=1.25in,right=1.25in]{geometry}` | `format:\n  pdf:\n    geometry:\n      - top=1in\n      - bottom=1in\n      - left=1.25in\n      - right=1.25in` |
| `\usepackage[letterpaper,margin=1in]{geometry}` | `format:\n  pdf:\n    papersize: letter\n    geometry: margin=1in` |
| `\usepackage[a4paper,margin=2.5cm]{geometry}` | `format:\n  pdf:\n    papersize: a4\n    geometry: margin=2.5cm` |

---

## Title, Author, Date

Move from preamble commands to top-level YAML fields:

| LaTeX | Quarto YAML |
|-------|-------------|
| `\title{My Paper}` | `title: "My Paper"` |
| `\title{My Paper\thanks{Funded by...}}` | `title: "My Paper"` (move `\thanks` content to `acknowledgements:` or a footnote) |
| `\author{Jane Doe}` | `author: "Jane Doe"` |
| `\author{Jane Doe \and John Smith}` | `author:\n  - Jane Doe\n  - John Smith` |
| `\author{Jane Doe\thanks{MIT}\and John Smith\thanks{Harvard}}` | (see structured author block below) |
| `\date{2025}` | `date: 2025` |
| `\date{\today}` | `date: today` |
| `\date{}` (suppress date) | *(omit `date:` field)* |

### Structured Author Block

When authors have affiliations or emails, use the expanded YAML form:

```yaml
author:
  - name: Jane Doe
    affiliations:
      - name: MIT
        department: Economics
    email: jdoe@mit.edu
  - name: John Smith
    affiliations: Harvard University
```

---

## Bibliography

| LaTeX | Quarto YAML |
|-------|-------------|
| `\bibliography{refs}` (body command) | `bibliography: refs.bib` in YAML; remove from body |
| `\bibliography{refs1,refs2}` | `bibliography:\n  - refs1.bib\n  - refs2.bib` |
| `\addbibresource{refs.bib}` (biblatex) | `bibliography: refs.bib` |
| `\addbibresource{refs.bib}\addbibresource{extra.bib}` | `bibliography:\n  - refs.bib\n  - extra.bib` |
| `\bibliographystyle{plain}` | *(remove — use `csl:` for custom styles if needed)* |
| `\usepackage[style=apa]{biblatex}` | `csl: apa.csl` (download CSL file separately) |
| `\usepackage[style=chicago-author-date]{biblatex}` | `csl: chicago-author-date.csl` |
| `\usepackage{natbib}` | *(remove — natbib commands converted in body)* |

---

## Spacing and Typography

| LaTeX | Quarto YAML |
|-------|-------------|
| `\usepackage{setspace}` + `\doublespacing` | `format:\n  pdf:\n    linestretch: 2` |
| `\usepackage{setspace}` + `\onehalfspacing` | `format:\n  pdf:\n    linestretch: 1.5` |
| `\setlength{\parindent}{0pt}` | `format:\n  pdf:\n    indent: false` |
| `\setlength{\parskip}{1em}` | *(no direct equivalent; use LaTeX raw block if needed)* |
| `\usepackage{times}` / `\usepackage{mathptmx}` | `format:\n  pdf:\n    mainfont: "Times New Roman"` |
| `\usepackage{lmodern}` | *(remove — Quarto default)* |
| `\usepackage{microtype}` | *(remove — PDF-only, add back manually if needed)* |

---

## Common Packages: What to Do

| Package | Action |
|---------|--------|
| `amsmath`, `amssymb`, `amsfonts` | Remove — Quarto loads these automatically for PDF |
| `graphicx` | Remove — handled by Pandoc |
| `hyperref` | Remove — Quarto adds hyperlinks automatically |
| `xcolor` | Remove (flag any `\textcolor{}{}` uses for manual review) |
| `booktabs` | Remove — pipe tables don't need it |
| `longtable` | Remove — use knitr/kableExtra for long tables if needed |
| `float` | Remove |
| `caption` | Remove (flag if custom caption formatting is used) |
| `subcaption` | Remove — use Quarto subfigure layout divs instead |
| `appendix` | Remove — use `{.appendix}` attribute on headings |
| `inputenc`, `fontenc`, `babel` | Remove — handled by Quarto/Pandoc |
| `todonotes` | Remove — use Quarto comments or `<!-- -->` instead |
| `lineno` | Flag — add back via `include-in-header` if required for submission |
| `soul`, `ulem` | Remove — use `[text]{.underline}` / `~~text~~` instead |
| `csquotes` | Remove — convert `\enquote{}` to standard quotes in body |
| `cleveref` | Remove — convert `\cref{}` to `@label` in body |
| `authblk` | Remove — use structured YAML author block |
| `abstract` | Remove — use YAML `abstract:` field |

---

## Custom Commands (Flag for Review)

`\newcommand` and `\renewcommand` definitions cannot be automatically inlined.
Flag each one in your report with:
- The command name
- Its expansion
- A count of uses in the document

Example flag: `` \newcommand{\E}{\mathbb{E}} `` — used 14 times; replace each `\E` with
`\mathbb{E}` in the document body.

---

## Full YAML Template

Use this as the assembled YAML block:

```yaml
---
title: "Title Here"
author:
  - name: "First Author"
    affiliations: "University Name"
  - name: "Second Author"
    affiliations: "Other University"
date: today
abstract: |
  Abstract text here.
bibliography: refs.bib
format:
  html:
    toc: true
  pdf:
    documentclass: article
    papersize: letter
    fontsize: 12pt
    geometry: margin=1in
---
```

Omit any fields that were not present in the original document.
Do not add `format: html` or `format: pdf` sections unless the original document had
relevant configuration (geometry, fontsize, etc.) that needs to be preserved.

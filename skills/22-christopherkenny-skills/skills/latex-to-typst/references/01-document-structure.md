# Document Structure

## Overview

A LaTeX article has: `\documentclass`, preamble (`\usepackage`, `\newcommand`, etc.), and `\begin{document}...\end{document}`. Typst has none of these: everything is a `.typ` file where `set`/`show` rules replace the preamble and content starts immediately.

## Preamble → Set Rules

| LaTeX | Typst |
|-------|-------|
| `\documentclass[12pt,a4paper]{article}` | `#set page(paper: "a4")` + `#set text(size: 12pt)` |
| `\usepackage[margin=1in]{geometry}` | `#set page(margin: 1in)` |
| `\usepackage{fontspec}` + `\setmainfont{...}` | `#set text(font: "...")` |
| `\usepackage{amsmath}` | *(built in — no import needed)* |
| `\usepackage{graphicx}` | *(built in)* |
| `\usepackage{hyperref}` | *(built in — links work automatically)* |
| `\usepackage{xcolor}` | `#import "@preview/..."`  or use `rgb(...)` directly |
| `\usepackage{booktabs}` | *(replicate with `table.hline` stroke settings)* |
| `\usepackage[style=apa]{biblatex}` | `#bibliography("refs.bib", style: "apa")` |

## Document Body

### Title, Author, Date

```tex
% LaTeX
\title{My Paper}
\author{Jane Doe \and John Smith}
\date{March 2025}
\maketitle
```

```typst
// Typst — inline in document
#align(center)[
  #text(size: 17pt, weight: "bold")[My Paper]

  Jane Doe, John Smith

  March 2025
]
```

Or use a custom title function for repeatability:

```typst
#let make-title(title, authors, date) = align(center)[
  #block(text(size: 17pt, weight: "bold")[#title])
  #v(0.5em)
  #authors.join(", ")
  #v(0.3em)
  #date
  #v(1em)
]

#make-title(
  "My Paper",
  ("Jane Doe", "John Smith"),
  "March 2025",
)
```

### Abstract

```tex
% LaTeX
\begin{abstract}
This paper studies...
\end{abstract}
```

```typst
// Typst
#align(center)[*Abstract*]
#par(justify: true)[
  This paper studies...
]
#v(1em)
```

Or with a box:

```typst
#block(
  width: 85%,
  inset: (x: 1em, y: 0.8em),
  stroke: none,
)[
  *Abstract.* This paper studies...
]
```

### Full Article Template

```typst
// Preamble (set rules)
#set page(
  paper: "us-letter",
  margin: (x: 1in, y: 1in),
  numbering: "1",
  number-align: center + bottom,
)
#set text(
  font: "Linux Libertine",
  size: 11pt,
)
#set par(
  justify: true,
  leading: 0.65em,
  first-line-indent: 1.2em,
)
#set heading(numbering: "1.1")

// Show rules (formatting transformations)
#show heading.where(level: 1): it => block(above: 1.5em, below: 0.8em)[
  #text(size: 12pt, weight: "bold")[#it.body]
]

// Title block
#align(center)[
  #text(17pt, weight: "bold")[Title of the Paper] \
  #v(0.4em)
  #text(12pt)[Author Name] \
  #text(10pt, fill: luma(40%))[Institution · email\@example.com] \
  #v(0.3em)
  #text(10pt)[March 2025]
]

#v(0.8em)

// Abstract
#align(center)[#text(weight: "bold")[Abstract]]
#par(first-line-indent: 0pt)[
  This paper examines...
]

#v(1em)

// Body
= Introduction
<intro>

Text begins here...
```

## Custom Commands → Functions

```tex
% LaTeX
\newcommand{\norm}[1]{\left\lVert #1 \right\rVert}
\newcommand{\R}{\mathbb{R}}
```

```typst
// Typst
#let norm(x) = $lr(‖ #x ‖)$
#let RR = $RR$   // or just use RR directly in math mode
```

## Package Equivalents

| LaTeX package | Typst equivalent |
|---------------|-----------------|
| `geometry` | `#set page(...)` |
| `fontspec` / `inputenc` | `#set text(font: "...")` |
| `amsmath` | Built-in math mode |
| `amssymb` | Built-in symbols (`sym` namespace) |
| `graphicx` | Built-in `image()` |
| `hyperref` | Built-in links and cross-refs |
| `cleveref` | `@label` with `#set heading(supplement: "Section")` |
| `natbib` / `biblatex` | `#bibliography(...)` with `@key` |
| `booktabs` | `table.hline(stroke: ...)` |
| `multirow` | `table.cell(rowspan: n, ...)` |
| `xcolor` | `rgb(...)`, `luma(...)` built in |
| `tikz` / `pgfplots` | CeTZ: `#import "@preview/cetz:0.3.1"` |
| `listings` / `minted` | Built-in raw blocks with syntax highlighting |
| `microtype` | `#set text(kerning: true)` (partial) |
| `setspace` | `#set par(leading: ...)` |
| `caption` | `figure.caption` styling |
| `subcaption` | `grid` inside `figure` |
| `algorithm2e` / `algorithmicx` | `@preview/algo` (community package) |
| `todonotes` | `#highlight(...)` or custom show rule |

---
name: latex-to-typst
description: 'Translates LaTeX documents (.tex) to Typst (.typ), focusing on article-class documents. Use when asked to convert, port, migrate, or translate LaTeX to Typst. Covers document structure, text formatting, page layout, math equations and symbols, figures, tables, TikZ-to-CeTZ diagrams, bibliography, cross-references, footnotes, and code blocks. Includes comprehensive symbol mapping tables.'
---

# LaTeX to Typst Translation Guide

A comprehensive reference for converting LaTeX article-class documents to Typst.

## When to Use This Skill

- User asks to convert, port, or translate a `.tex` file to `.typ`
- User wants to know the Typst equivalent of a LaTeX command
- User is migrating an academic paper or report from LaTeX to Typst
- User needs help with specific LaTeX environments in Typst

## Quick Navigation: Use What Reference

| Task | Reference File |
|------|---------------|
| Overall document structure, preamble → set rules | [01-document-structure.md](references/01-document-structure.md) |
| Bold, italic, fonts, font sizes, colors | [02-text-formatting.md](references/02-text-formatting.md) |
| Margins, page size, columns, headers/footers | [03-page-layout.md](references/03-page-layout.md) |
| `\section`, `\subsection`, numbering | [04-headings-sections.md](references/04-headings-sections.md) |
| `itemize`, `enumerate`, `description` | [05-lists.md](references/05-lists.md) |
| Math mode, equations, aligned, matrices, operators | [06-math.md](references/06-math.md) |
| Symbol table: arrows, Greek, operators, sets, logic | [07-math-symbols.md](references/07-math-symbols.md) |
| `\includegraphics`, `figure` environment, subfigures | [08-figures.md](references/08-figures.md) |
| `tabular`, `booktabs`, `tabularx`, multirow/multicolumn | [09-tables.md](references/09-tables.md) |
| BibTeX, biblatex, natbib → `bibliography`, `cite` | [10-bibliography.md](references/10-bibliography.md) |
| `\label`, `\ref`, `\eqref`, `\autoref` | [11-cross-references.md](references/11-cross-references.md) |
| TikZ → CeTZ diagrams | [12-diagrams-cetz.md](references/12-diagrams-cetz.md) |
| `verbatim`, `lstlisting`, `minted`; footnotes, links | [13-misc.md](references/13-misc.md) |

## Key Conceptual Differences

### Preamble → `set` and `show` Rules

LaTeX uses a `\documentclass{article}` preamble with `\usepackage` calls. Typst replaces this with **`set` rules** (for properties) and **`show` rules** (for transformations), placed at the top of the document.

```tex
% LaTeX
\documentclass[12pt,a4paper]{article}
\usepackage[margin=1in]{geometry}
\usepackage{fontenc}
\setmainfont{Times New Roman}
```

```typst
// Typst equivalent
#set page(paper: "a4", margin: 1in)
#set text(font: "Times New Roman", size: 12pt)
```

### No `\begin`/`\end` Environments

Most LaTeX environments have direct Typst function equivalents. For example:

| LaTeX | Typst |
|-------|-------|
| `\begin{equation}...\end{equation}` | `$ ... $` (block, with space) |
| `\begin{figure}...\end{figure}` | `#figure(...)` |
| `\begin{tabular}...\end{tabular}` | `#table(...)` |
| `\begin{itemize}...\end{itemize}` | `- item` (markup) |

### Content vs. Code Mode

In Typst, `#` switches from markup mode into code mode. Inside `#{ }` blocks or function arguments, you write code. Markup is the default.

### Units

| LaTeX | Typst | Notes |
|-------|-------|-------|
| `pt` | `pt` | Same |
| `em` | `em` | Same |
| `cm` | `cm` | Same |
| `mm` | `mm` | Same |
| `in` | `in` | Same |
| `\textwidth` | `100%` (relative to container) | — |
| `0.5\textwidth` | `50%` | — |

## Minimal Article Template

```tex
% LaTeX article
\documentclass[12pt]{article}
\usepackage[margin=1in]{geometry}
\usepackage{amsmath}
\title{My Paper}
\author{Jane Doe}
\date{\today}
\begin{document}
\maketitle
\begin{abstract}
This paper...
\end{abstract}
\section{Introduction}
Hello world.
\end{document}
```

```typst
// Typst equivalent
#set page(margin: 1in)
#set text(size: 12pt)

#align(center)[
  = My Paper
  Jane Doe \
  #datetime.today().display()
]

#set par(justify: true)

*Abstract.* This paper...

= Introduction

Hello world.
```

For a more polished article template with abstract box, see [01-document-structure.md](references/01-document-structure.md).

## Workflow for Full Document Conversion

1. **Convert preamble** → `#set page()`, `#set text()`, `#set par()` (see [03-page-layout.md](references/03-page-layout.md), [02-text-formatting.md](references/02-text-formatting.md))
2. **Convert sectioning** → `=`, `==`, `===` (see [04-headings-sections.md](references/04-headings-sections.md))
3. **Convert math** → inline `$...$`, block `$ ... $` (see [06-math.md](references/06-math.md), [07-math-symbols.md](references/07-math-symbols.md))
4. **Convert figures** → `#figure(image(...), caption: [...])` (see [08-figures.md](references/08-figures.md))
5. **Convert tables** → `#table(...)` or `#figure(table(...), ...)` (see [09-tables.md](references/09-tables.md))
6. **Convert bibliography** → `#bibliography("refs.bib")` + `@key` citations (see [10-bibliography.md](references/10-bibliography.md))
7. **Convert TikZ** → `#canvas({...})` with CeTZ (see [12-diagrams-cetz.md](references/12-diagrams-cetz.md))
8. **Fix cross-references** → `<label>` + `@label` (see [11-cross-references.md](references/11-cross-references.md))

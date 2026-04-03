---
name: latex-to-quarto
description: 'Converts LaTeX article-class .tex documents to Quarto .qmd format for multi-format publishing (HTML, PDF, Word). Use when asked to convert, port, migrate, or translate a .tex LaTeX file to Quarto; when porting an academic paper or manuscript from LaTeX to Quarto; when a .tex document needs to render to HTML, Word, or Typst PDF. Covers preamble → YAML front matter, section headings, text formatting, math, citations (natbib/biblatex), cross-references, figures, tables, lists, footnotes, hyperlinks, and special characters.'
metadata:
  author: Christopher T. Kenny
  version: 1.0
---

# LaTeX to Quarto Conversion

Convert a full LaTeX `.tex` article to a Quarto `.qmd` document that renders correctly
to HTML, PDF (Typst or LaTeX), and Word.
This skill handles the entire conversion pipeline: preamble extraction, document structure,
and all inline/block transformations.

**This skill writes the output file** (overwriting the input or writing to a second path).
Before writing, tell the user what file will be changed and remind them that `git diff` or
file history can recover the original.

---

## Input Arguments

| Position | Required | Description |
|----------|----------|-------------|
| 1 | **Yes** | Path to the input `.tex` file (e.g., `paper/paper.tex`) |
| 2 | No | Output `.qmd` path. Defaults to same directory, `.qmd` extension. |

**Example invocations:**
```
/latex-to-quarto paper/paper.tex
/latex-to-quarto paper/paper.tex paper/paper.qmd
```

---

## Quick Navigation: Use Which Reference

| Task | Reference File |
|------|----------------|
| `\documentclass`, `\usepackage`, `\title`, `\author` → YAML | [01-preamble-yaml.md](references/01-preamble-yaml.md) |
| `\begin{document}`, `\maketitle`, `\begin{abstract}`, `\appendix` | [02-document-structure.md](references/02-document-structure.md) |
| `\textbf`, `\emph`, `\texttt`, `\footnote`, `\href` | [03-text-formatting.md](references/03-text-formatting.md) |
| `equation`, `align`, `gather`, inline math delimiters | [04-math.md](references/04-math.md) |
| `\cite`, `\citep`, `\citet`, natbib/biblatex commands | [05-citations.md](references/05-citations.md) |
| `\label`, `\ref`, `\autoref`, `\eqref`, prefix mapping | [06-cross-references.md](references/06-cross-references.md) |
| `\includegraphics`, `figure` environment, subfigures | [07-figures.md](references/07-figures.md) |
| `tabular`, `table`, `booktabs`, `\multicolumn` | [08-tables.md](references/08-tables.md) |
| `\section`, `\subsection`, `itemize`, `enumerate` | [09-sections-lists.md](references/09-sections-lists.md) |
| Special characters, `\newpage`, `verbatim`, `\input` | [10-misc.md](references/10-misc.md) |

---

## Step-by-Step Workflow

### 1. Parse Arguments

Identify the input `.tex` path (arg 1) and output path (arg 2).
If arg 2 is omitted, replace the `.tex` extension with `.qmd` in the same directory.

### 2. Read the File

Use the `Read` tool to load the full `.tex` file.
Hold the entire content in memory — you will produce one complete `.qmd` file at the end.

### 3. Extract and Convert the Preamble

Everything before `\begin{document}` is the **preamble**. Extract:

- `\documentclass` options → YAML `format:` settings
- `\title{}`, `\author{}`, `\date{}` → YAML `title:`, `author:`, `date:`
- `\bibliography{file}` / `\addbibresource{file}` → YAML `bibliography:`
- Package hints (`geometry`, `setspace`, `natbib`, `biblatex`) → YAML format options

See [01-preamble-yaml.md](references/01-preamble-yaml.md) for the full mapping table.

### 4. Strip Document Wrapper

Remove `\begin{document}` and `\end{document}`.
Remove `\maketitle` (title is rendered from YAML automatically).
Convert `\begin{abstract}...\end{abstract}` to YAML `abstract:`.
See [02-document-structure.md](references/02-document-structure.md).

### 5. Apply All Body Transformations

Work through the full document body and apply every applicable rule. Key principles:

- **Preserve math regions**: Never alter content inside `$...$` or `$$...$$` except to
  move `\label{}` outside display math and convert delimiters (`\(...\)` → `$...$`).
- **Handle nesting**: `\textbf{\emph{text}}` → `***text***`. Process inner commands first.
- **Be complete**: Scan the entire file. Fix every instance of each pattern, not just the first.
- **Apply all categories**: Work through every reference file. A single paragraph may
  require rules from multiple categories.

Apply reference files in this order (structural → inline):

1. [09-sections-lists.md](references/09-sections-lists.md) — headings and lists
2. [05-citations.md](references/05-citations.md) — citations
3. [06-cross-references.md](references/06-cross-references.md) — labels and references
4. [07-figures.md](references/07-figures.md) — figures
5. [08-tables.md](references/08-tables.md) — tables
6. [04-math.md](references/04-math.md) — math environments and delimiters
7. [03-text-formatting.md](references/03-text-formatting.md) — inline formatting
8. [10-misc.md](references/10-misc.md) — special characters and remaining patterns

### 6. Assemble the QMD File

Combine:
1. YAML front matter (between `---` delimiters)
2. Converted document body (blank line after closing `---`)

### 7. Write the Output File

Use the `Write` tool to write the complete `.qmd` file in one pass.
Do not use `Edit` for individual substitutions — a single full write ensures nothing is missed.

### 8. Report to the User

Tell the user:
- **Output path** written
- **Summary of conversions** by category (citation count, figure count, table count, etc.)
- **Items requiring manual review** with approximate line numbers
- **Reminder** to run `quarto render` to verify the output

---

## Key Conceptual Differences: LaTeX vs. Quarto

### Preamble → YAML Front Matter

LaTeX uses a `\documentclass` preamble; Quarto uses YAML front matter between `---`.

```latex
% LaTeX preamble
\documentclass[12pt,a4paper]{article}
\usepackage[margin=1in]{geometry}
\title{My Paper}
\author{Jane Doe}
\date{\today}
\bibliography{refs}
```

```yaml
# Quarto YAML front matter
---
title: "My Paper"
author: "Jane Doe"
date: today
bibliography: refs.bib
format:
  html: default
  pdf:
    documentclass: article
    papersize: a4
    fontsize: 12pt
    geometry: margin=1in
---
```

### Math Content Is Preserved as LaTeX

Unlike conversion to Typst, Quarto uses **LaTeX math directly**.
Inline `\(...\)` → `$...$`; display `\[...\]` → `$$...$$`.
Math *content* (operators, symbols, matrices) stays unchanged.

### Citations Use Pandoc Bracket Syntax

`\citep{key}` → `[@key]`; `\citet{key}` → `@key`.
The `.bib` file is referenced in YAML and left unchanged.

### Cross-References Use `@label` Not `\ref{}`

`\ref{fig:map}` → `@fig-map`. Labels move from standalone `\label{}` commands
into element attribute blocks `{#fig-map}`.

---

## Minimal Conversion Example

**Input (`paper.tex`):**
```latex
\documentclass[12pt]{article}
\usepackage{natbib}
\title{My Study}
\author{Jane Doe}
\date{2025}
\begin{document}
\maketitle
\begin{abstract}
We examine the effect of X on Y.
\end{abstract}
\section{Introduction}
Prior work \citep{smith2020} shows that $x > 0$.
See Figure~\ref{fig:map} for an overview.
\begin{figure}[h]
  \centering
  \includegraphics[width=0.8\textwidth]{figs/map.pdf}
  \caption{Study region.}
  \label{fig:map}
\end{figure}
\bibliography{refs}
\end{document}
```

**Output (`paper.qmd`):**
```markdown
---
title: "My Study"
author: "Jane Doe"
date: 2025
bibliography: refs.bib
---

## Abstract

We examine the effect of X on Y.

# Introduction

Prior work [@smith2020] shows that $x > 0$.
See @fig-map for an overview.

![Study region.](figs/map.pdf){#fig-map width=80% fig-align="center"}
```

---

## Patterns Requiring Manual Review

Flag these in your report with a suggested fix but no automatic conversion:

| Pattern | Suggested Quarto Equivalent |
|---------|------------------------------|
| `\begin{theorem}`, `\begin{proof}`, `\begin{lemma}` | `::: {.callout-note}` div, or install a theorem extension |
| `\newcommand{}{}` / `\renewcommand{}{}` | Inline the macro expansion throughout; flag remaining uses |
| `\input{file}` / `\include{file}` | Inline contents or use `{{< include file.qmd >}}` shortcode |
| `\vspace{}` / `\hspace{}` | Remove or replace with CSS; no direct Quarto equivalent |
| `\multicolumn{}{}{}` in tables | Requires manual table restructuring |
| TikZ / PGF diagrams | Remove or replace with Mermaid/Observable JS |
| Beamer `\begin{frame}` | Switch to `format: revealjs` with `##` slide headings |
| `\bibliographystyle{}` | Remove; use `csl:` in YAML if a specific citation style is needed |
| Multiple `\label` in one `align` block | Each labeled row may need its own equation block |

---

## What to Preserve Unchanged

- LaTeX math *content* inside `$...$` and `$$...$$`
- File paths in `\includegraphics` and `\bibliography` (adjust extension if needed)
- Existing `@ref` and `[@citation]` patterns already in correct Quarto form
- Content inside `\begin{verbatim}...\end{verbatim}` (convert to fenced block, keep content)

# Working Paper Format Standard

All LaTeX papers generated or reviewed by this system must conform to the standard economics working paper format. This rule applies to the writer, writer-critic, and verifier agents.

## Document Class and Layout

- `\documentclass[12pt]{article}`
- Margins: 1 inch all sides
- Body text: `\doublespacing`
- References: `\singlespacing` or `\small`
- Page numbers centered in footer via `fancyhdr`

## Reference Preamble

The following preamble is the project standard. New papers should use this structure. The writer-critic checks against it.

```latex
\documentclass[12pt]{article}
% ====== Page Layout and Basic Formatting ======
\usepackage[left=1.0in,right=1.0in,top=1.0in,bottom=1.0in]{geometry}
\usepackage{setspace}
\doublespacing
\usepackage{fancyhdr}
\pagestyle{fancy}
\fancyhf{}
\fancyfoot[C]{\thepage}
\renewcommand{\headrulewidth}{0pt}

% ====== Typography and Fonts ======
\usepackage{lmodern}
\usepackage{microtype}
\usepackage[normalem]{ulem}
\usepackage[T1]{fontenc}

% ====== Section Styling ======
\usepackage{titlesec}
\usepackage[title]{appendix}
\usepackage{titling}
\pretitle{\begin{center}\large\bfseries}
\posttitle{\end{center}}
\preauthor{\begin{center}\normalsize}
\postauthor{\end{center}}
\predate{\begin{center}\normalsize}
\postdate{\end{center}}

% ====== Math Packages ======
\usepackage{amssymb, amsmath, amsfonts, mathtools}
\usepackage{dsfont}
\usepackage{amsthm}
\newtheorem{theorem}{Theorem}
\newtheorem{proposition}{Proposition}
\newtheorem{corollary}{Corollary}
\newtheorem{lemma}{Lemma}
\newtheorem{definition}{Definition}
\newtheorem{hyp}{Hypothesis}
\DeclareMathOperator*{\argmax}{arg\,max}
\DeclareMathOperator*{\argmin}{arg\,min}
\newcommand{\norm}[1]{\left\lVert #1 \right\rVert}
\newcommand{\1}[1]{\mathds{1}\left[#1\right]}

% ====== Table Packages ======
\usepackage{array, booktabs, makecell, cellspace}
\usepackage{siunitx}
\usepackage[flushleft]{threeparttable}
\usepackage{rotating, tabularx}

% ====== Figure and Caption Packages ======
\usepackage{graphicx, subcaption}
\usepackage{pdflscape, tikz}
\usepackage{caption}
\captionsetup{font=small, labelfont=bf, justification=justified}
\captionsetup[figure]{labelfont=bf}
\usepackage{float}

% ====== List Formatting ======
\usepackage{enumitem}

% ====== Bibliography and Citation (biblatex + biber) ======
\usepackage{xurl}
\usepackage{xcolor}
\definecolor{citationcolor}{RGB}{0, 127, 255}

\usepackage[backend=biber,
            style=authoryear,
            maxcitenames=3,
            mincitenames=1,
            maxbibnames=99,
            giveninits=true,
            uniquename=false,
            uniquelist=true,
            dashed=false,
            urldate=long,
            url=true,
            natbib=true]{biblatex}
\addbibresource{references.bib}

% Citation color settings
\renewcommand*{\nameyeardelim}{\addcomma\space}
\DeclareCiteCommand{\cite}
  {\usebibmacro{prenote}}
  {\usebibmacro{citeindex}%
   \printtext[bibhyperref]{\color{citationcolor}\usebibmacro{cite}}}
  {\multicitedelim}
  {\usebibmacro{postnote}}
\DeclareCiteCommand{\parencite}[\mkbibparens]
  {\usebibmacro{prenote}}
  {\usebibmacro{citeindex}%
   \printtext[bibhyperref]{\color{citationcolor}\usebibmacro{cite}}}
  {\multicitedelim}
  {\usebibmacro{postnote}}

% ====== Custom Column Types ======
\newcolumntype{L}[1]{>{\raggedright\let\newline\\arraybackslash\hspace{0pt}}m{#1}}
\newcolumntype{C}[1]{>{\centering\let\newline\\arraybackslash\hspace{0pt}}m{#1}}
\newcolumntype{R}[1]{>{\raggedleft\let\newline\\arraybackslash\hspace{0pt}}m{#1}}

% ====== Footnote Settings ======
\interfootnotelinepenalty=10000
\setlength{\footnotesep}{0.5cm}

% ====== URL Bleeding Fixes ======
\setcounter{biburllcpenalty}{7000}
\setcounter{biburlucpenalty}{8000}
\setcounter{biburlnumpenalty}{9000}

% ====== Hyperref (loaded last) ======
\usepackage[hidelinks, breaklinks, colorlinks=true,
            linkcolor=citationcolor, citecolor=citationcolor,
            urlcolor=citationcolor]{hyperref}
```

## Key Design Decisions

| Choice | Standard | Rationale |
|--------|----------|-----------|
| `biblatex` + `biber` | Required | Replaces `natbib` + `bibtex`. More flexible, better Unicode, `natbib=true` preserves `\citet`/`\citep` |
| `lmodern` | Required | Clean Latin Modern font; compatible with all LaTeX engines |
| `microtype` | Required | Improved character spacing and margin kerning |
| `fancyhdr` | Required | Clean centered page numbers, no header rule |
| Citation color `(0,127,255)` | Default | Azure — visible but professional. Consistent across citations, links, URLs |
| `\doublespacing` | Required | Standard for working paper submissions |
| `captionsetup` | Required | Small font, bold labels — matches journal style |
| `hidelinks` in `hyperref` | Required | No colored boxes around links; colors applied via `colorlinks` |
| `hyperref` loaded last | Required | Avoids conflicts with other packages |

## Title Page Format

```latex
\title{Paper Title\thanks{Acknowledgments footnote.}}

\author{
Author One\thanks{Affiliation and email.} \quad
Author Two\thanks{Affiliation.} \quad
Author Three\thanks{Affiliation.}
}

\date{\today}
```

Rules:
- Do NOT wrap title in `\textbf{}` — `\maketitle` already bolds it via `\pretitle`
- Do NOT use `\and` for authors — use `\quad` spacing on a single line
- Do NOT repeat university name under each author — affiliations go in `\thanks{}` footnotes only
- Suppress page number on title page: `\thispagestyle{empty}`
- Reset page counter after title page: `\newpage \setcounter{page}{1}`

## Abstract and Metadata

```latex
\begin{abstract}
\noindent \singlespacing
Abstract text here.
\end{abstract}

\vspace{1em}
\noindent \textbf{JEL Codes:} X00, Y00

\vspace{0.5em}
\noindent \textbf{Keywords:} keyword one, keyword two
```

- Abstract must have `\noindent` and `\singlespacing`
- Abstract should be 150 words or fewer
- JEL codes and keywords follow the abstract, outside `\begin{abstract}`
- The entire title page must fit on one page

## Section Structure

Standard economics paper order:
1. Introduction
2. Background / Institutional Setting (if needed)
3. Literature Review (or combined with Introduction)
4. Data
5. Empirical Strategy / Methodology
6. Results
7. Discussion (if separate from Results)
8. Robustness (if separate section)
9. Conclusion

Each section uses `\section{}` with `\label{sec:name}`. Subsections use `\subsection{}`.

## Tables and Figures

- Tables and figures placed inline (modern standard)
- Use `\begin{threeparttable}` for tables with notes
- `\captionsetup` handles caption styling globally — no manual `\small` on captions
- Use `booktabs` rules (`\toprule`, `\midrule`, `\bottomrule`) — never `\hline`
- Generated `.tex` files contain bare `tabular` only — no `\begin{table}`, `\caption`, or notes

## Bibliography

```latex
\clearpage
\small \printbibliography
```

- `\printbibliography` replaces `\bibliography{}`/`\bibliographystyle{}`
- Compile with `biber` (not `bibtex`): `xelatex → biber → xelatex → xelatex`
- Single-spaced or `\small` references
- New page before references

## Compilation

```bash
xelatex new_main.tex
biber new_main
xelatex new_main.tex
xelatex new_main.tex
```

Note: `biber` replaces `bibtex` when using `biblatex`.

## What the Writer-Critic Checks

The writer-critic deducts points for:
- Wrong document class or font size (-5)
- Missing `\doublespacing` in body (-5)
- Using `natbib` instead of `biblatex` (-3)
- Missing `microtype` (-2)
- Missing `fancyhdr` page number setup (-2)
- `\textbf{}` wrapping `\title{}` (-3)
- `\and` between authors instead of `\quad` (-3)
- Repeated affiliation text outside `\thanks{}` (-3)
- Missing JEL codes or keywords (-5)
- `\hline` instead of `booktabs` rules (-3)
- Missing table notes on any table (-5)
- Missing figure notes on any figure (-5)
- `hyperref` not loaded last (-2)
- Missing caption styling (`captionsetup`) (-2)
- Using `bibtex` instead of `biber` (-3)

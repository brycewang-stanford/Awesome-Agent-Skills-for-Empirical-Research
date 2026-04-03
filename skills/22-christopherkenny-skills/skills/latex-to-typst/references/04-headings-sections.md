# Headings and Sections

## Basic Heading Syntax

Typst uses `=` signs for headings — no `\begin`/`\end` needed.

| LaTeX | Typst (markup) | Typst (function) |
|-------|---------------|-----------------|
| `\section{Title}` | `= Title` | `#heading(level: 1)[Title]` |
| `\subsection{Title}` | `== Title` | `#heading(level: 2)[Title]` |
| `\subsubsection{Title}` | `=== Title` | `#heading(level: 3)[Title]` |
| `\paragraph{Title}` | `==== Title` | `#heading(level: 4)[Title]` |
| `\subparagraph{Title}` | `===== Title` | `#heading(level: 5)[Title]` |
| `\section*{Title}` (unnumbered) | `= Title` (with `numbering: none`) | `#heading(numbering: none)[Title]` |
| `\chapter{Title}` *(book class)* | `= Title` with offset | See below |

## Heading Labels for Cross-References

```tex
% LaTeX
\section{Introduction}
\label{sec:intro}
...
See Section~\ref{sec:intro}.
```

```typst
// Typst — label immediately after heading
= Introduction <intro>

...
See @intro.
```

## Numbering

```tex
% LaTeX — default numbering varies by class
% article: 1, 1.1, 1.1.1
% To customize: titlesec package
```

```typst
// Typst — configure globally
#set heading(numbering: "1.1")          // 1, 1.1, 1.1.1
#set heading(numbering: "1.1.a")        // 1, 1.1, 1.1.a
#set heading(numbering: "I.A.1")        // Roman → Letter → Arabic
#set heading(numbering: none)           // no numbering (like \section*)
```

### Numbering Patterns

| Pattern string | Example output |
|---------------|----------------|
| `"1."` | 1., 2., 3. |
| `"1.1"` | 1.1, 1.2, 2.1 |
| `"1.1.1."` | 1.1.1., 1.1.2. |
| `"I.A.1."` | I.A.1., I.A.2. |
| `"(1)"` | (1), (2) |
| `"a)"` | a), b) |

### Selectively Suppress Numbering

```typst
// Unnumbered section heading
#heading(numbering: none)[Acknowledgements]

// Or globally unnumber levels > 2
#set heading(numbering: (..nums) =>
  if nums.pos().len() <= 2 { numbering("1.1", ..nums) }
)
```

## Styling Headings

```tex
% LaTeX (titlesec)
\usepackage{titlesec}
\titleformat{\section}{\large\bfseries}{}{0em}{}
\titlespacing*{\section}{0pt}{12pt}{6pt}
```

```typst
// Typst — show rules
#show heading.where(level: 1): it => block(
  above: 1.5em,
  below: 0.8em,
)[
  #text(size: 14pt, weight: "bold")[#it.body]
]

#show heading.where(level: 2): it => block(
  above: 1.2em,
  below: 0.6em,
)[
  #text(size: 12pt, weight: "bold")[#it.body]
]

#show heading.where(level: 3): it => block(
  above: 1em,
  below: 0.5em,
)[
  #text(size: 11pt, weight: "bold", style: "italic")[#it.body]
]
```

### Adding Numbering to the Show Rule

```typst
#set heading(numbering: "1.1")

#show heading: it => {
  let number = if it.numbering != none {
    counter(heading).display(it.numbering)
    h(0.5em)
  }
  block(above: 1.5em, below: 0.8em)[
    #number
    #it.body
  ]
}
```

## Table of Contents

```tex
% LaTeX
\tableofcontents
\listoffigures
\listoftables
```

```typst
// Typst
#outline()                            // table of contents
#outline(title: "List of Figures", target: figure.where(kind: image))
#outline(title: "List of Tables",  target: figure.where(kind: table))

// Customize TOC depth
#outline(depth: 2)                    // only sections and subsections

// Style the TOC
#show outline.entry.where(level: 1): it => {
  v(12pt, weak: true)
  strong(it)
}
```

## Section Counters

```tex
% LaTeX
\setcounter{section}{3}              % start from section 4
\addtocounter{subsection}{1}
```

```typst
// Typst
#counter(heading).update(3)           // set section counter to 3
```

## Offset for Chapter-Level Documents

When translating `\book` or `\report` classes where `\chapter` is the top level:

```typst
// Make = be chapter-level (one indent higher)
#set heading(offset: 1)    // all = headings treated as level 2 from counter perspective
// Then use == for sections, === for subsections, etc.
```

Or equivalently, treat `=` as chapters naturally in Typst — it's the same mechanism.

## Appendix

```tex
% LaTeX
\appendix
\section{Appendix Title}
```

```typst
// Typst — change numbering at the appendix point
#counter(heading).update(0)
#set heading(numbering: "A.1")

= First Appendix
== Sub-section
```

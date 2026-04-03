# Text Formatting

## Core Text Commands

| LaTeX | Typst (markup) | Typst (function) |
|-------|---------------|-----------------|
| `\textbf{text}` | `*text*` | `#text(weight: "bold")[text]` |
| `\textit{text}` | `_text_` | `#text(style: "italic")[text]` |
| `\emph{text}` | `_text_` | `#emph[text]` |
| `\texttt{text}` | `` `text` `` | `#raw("text")` |
| `\underline{text}` | `#underline[text]` | `#underline(text)` |
| `\textrm{text}` | *(already roman)* | `#text(font: "...")[text]` |
| `\textsf{text}` | `#text(font: "Liberation Sans")[text]` | — |
| `\textsc{text}` | `#smallcaps[text]` | `#text(variant: "small-caps")[text]` |
| `\textbf{\textit{text}}` | `*_text_*` | `#text(weight: "bold", style: "italic")[text]` |
| `\text{text}` *(in math)* | `"text"` *(inside `$...$`)* | — |
| `\mbox{text}` | `#box[text]` | `#box(text)` |
| `\sout{text}` *(ulem)* | `#strike[text]` | `#strike(text)` |
| `\textsuperscript{x}` | `#super[x]` | `#super(x)` |
| `\textsubscript{x}` | `#sub[x]` | `#sub(x)` |

## Font Sizes

| LaTeX command | Approximate size | Typst |
|---------------|-----------------|-------|
| `\tiny` | 5pt | `#text(size: 5pt)[...]` |
| `\scriptsize` | 7pt | `#text(size: 7pt)[...]` |
| `\footnotesize` | 8pt | `#text(size: 8pt)[...]` |
| `\small` | 9pt | `#text(size: 9pt)[...]` |
| `\normalsize` | 10–12pt (base) | *(default)* |
| `\large` | ~12pt | `#text(size: 1.2em)[...]` |
| `\Large` | ~14pt | `#text(size: 1.4em)[...]` |
| `\LARGE` | ~17pt | `#text(size: 1.7em)[...]` |
| `\huge` | ~20pt | `#text(size: 2em)[...]` |
| `\Huge` | ~25pt | `#text(size: 2.5em)[...]` |

Relative sizes using `em` are preferable because they scale with `#set text(size: ...)`.

## Font Families

```tex
% LaTeX (fontspec)
\setmainfont{Times New Roman}
\setsansfont{Helvetica Neue}
\setmonofont{Inconsolata}
```

```typst
// Typst
#set text(font: "Times New Roman")    // main font

// Locally override
#text(font: "Helvetica Neue")[Sans text]
#text(font: "Inconsolata")[Mono text]
```

### Common Font Mappings

| LaTeX | Typst font name |
|-------|----------------|
| Computer Modern (default LaTeX) | `"New Computer Modern"` (install separately) |
| Latin Modern | `"Latin Modern Roman"` |
| Times New Roman | `"Times New Roman"` |
| Libertine | `"Linux Libertine"` *(Typst default)* |
| Palatino | `"Palatino Linotype"` |
| Helvetica | `"Helvetica"` or `"Arial"` |
| Courier | `"Courier New"` |

## Font Weight and Style

```typst
// Numeric weight (100–900)
#text(weight: 100)[Thin]
#text(weight: 400)[Regular]
#text(weight: 700)[Bold]
#text(weight: 900)[Black]

// Named weight
#text(weight: "light")[Light]
#text(weight: "medium")[Medium]
#text(weight: "semibold")[Semibold]
#text(weight: "extrabold")[Extrabold]

// Style
#text(style: "italic")[Italic]
#text(style: "oblique")[Oblique]
```

## Colors

```tex
% LaTeX (xcolor)
\textcolor{red}{red text}
\textcolor[RGB]{0,128,255}{custom}
\colorbox{yellow}{highlighted}
```

```typst
// Typst — built-in color support
#text(fill: red)[red text]
#text(fill: rgb(0, 128, 255))[custom]
#highlight(fill: yellow)[highlighted]

// Named colors
#text(fill: blue)[blue]
#text(fill: green)[green]
#text(fill: gray)[gray]

// Using luma (grayscale)
#text(fill: luma(50%))[50% gray]

// Hex colors
#text(fill: rgb("#ff5733"))[hex color]
```

### Built-in Named Colors

`black`, `white`, `gray`, `silver`, `navy`, `blue`, `teal`, `aqua`, `eastern`, `purple`, `fuchsia`, `maroon`, `red`, `orange`, `yellow`, `olive`, `green`, `lime`

## Spacing and Paragraph Formatting

```tex
% LaTeX spacing
\hspace{1cm}
\vspace{2em}
\noindent
\par
\\          % line break
~           % non-breaking space
\quad
\qquad
```

```typst
// Typst spacing
#h(1cm)                    // horizontal space
#v(2em)                    // vertical space
#par(first-line-indent: 0pt)[...]   // no indent on specific paragraph
                           // blank line = paragraph break
\                          // explicit line break (in markup)
#h(1fr)                    // fill remaining horizontal space
~                          // non-breaking space (same as LaTeX)
#h(1em)                    // \quad equivalent
#h(2em)                    // \qquad equivalent
```

### Global Paragraph Settings

```typst
#set par(
  justify: true,            // \setlength{\parindent}...  + justify
  leading: 0.65em,          // line spacing within paragraph
  spacing: 1.2em,           // space between paragraphs
  first-line-indent: 1.5em, // \parindent
)
```

### Line Spacing (setspace package)

```tex
% LaTeX
\usepackage{setspace}
\doublespacing
\onehalfspacing
```

```typst
// Typst — leading controls line spacing
#set par(leading: 1.3em)   // approx 1.5 spacing
#set par(leading: 2.6em)   // approx double spacing
```

## Text Alignment

| LaTeX | Typst |
|-------|-------|
| `\begin{center}...\end{center}` | `#align(center)[...]` |
| `\begin{flushleft}...\end{flushleft}` | `#align(left)[...]` |
| `\begin{flushright}...\end{flushright}` | `#align(right)[...]` |
| `\centering` *(in float)* | `#align(center)[...]` |

## Special Characters

| LaTeX | Typst | Character |
|-------|-------|-----------|
| `\%` | `\%` | % |
| `\$` | `\$` | $ |
| `\&` | `\&` | & |
| `\#` | `\#` | # |
| `\_` | `\_` | _ |
| `\{` | `\{` | { |
| `\}` | `\}` | } |
| `\textasciitilde` | `\~` | ~ |
| `\textasciicircum` | `\^` | ^ |
| `\textbackslash` | `\\` | \ |
| `---` | `---` | — (em dash) |
| `--` | `--` | – (en dash) |
| `` `` `` + `''` | `"..."` *(auto smart quotes)* | " " |
| `` ` `` + `'` | `'...'` *(auto)* | ' ' |
| `\ldots` | `...` *(auto)* | … |

## Boxes and Frames

```tex
% LaTeX
\fbox{framed text}
\framebox[3cm]{centered in frame}
\colorbox{lightgray}{gray box}
\begin{framed}...\end{framed}  % framed package
```

```typst
// Typst
#box(stroke: black, inset: 4pt)[framed text]
#box(width: 3cm, stroke: black, inset: 4pt, baseline: 0pt)[centered]
#box(fill: luma(230), inset: 4pt)[gray box]

// Block-level framed box
#block(
  stroke: 0.5pt + black,
  inset: 1em,
  radius: 2pt,
  width: 100%,
)[
  Block content here.
]
```

# Page Layout

## Page Size and Orientation

```tex
% LaTeX (geometry)
\usepackage[a4paper]{geometry}
\usepackage[letterpaper,landscape]{geometry}
```

```typst
// Typst
#set page(paper: "a4")
#set page(paper: "us-letter", flipped: true)   // landscape
```

### Supported Paper Sizes

| Paper | LaTeX name | Typst name |
|-------|-----------|-----------|
| A4 | `a4paper` | `"a4"` |
| US Letter | `letterpaper` | `"us-letter"` |
| A3 | `a3paper` | `"a3"` |
| A5 | `a5paper` | `"a5"` |
| B5 | `b5paper` | `"iso-b5"` |
| Legal | `legalpaper` | `"us-legal"` |
| Executive | `executivepaper` | `"us-executive"` |
| Custom | `\setlength{\paperwidth}{...}` | `width: ..., height: ...` |

```typst
// Custom page size
#set page(width: 15cm, height: 20cm)
```

## Margins

```tex
% LaTeX (geometry)
\usepackage[margin=1in]{geometry}
\usepackage[top=2cm, bottom=2cm, left=3cm, right=2cm]{geometry}
\usepackage[inner=3cm, outer=2cm, top=2.5cm, bottom=2.5cm]{geometry}
```

```typst
// Typst
#set page(margin: 1in)                              // all sides
#set page(margin: (top: 2cm, bottom: 2cm, left: 3cm, right: 2cm))
#set page(margin: (inside: 3cm, outside: 2cm, top: 2.5cm, bottom: 2.5cm))
#set page(margin: (x: 2cm, y: 3cm))                // horizontal/vertical
#set page(margin: (rest: 2cm, top: 3cm))            // rest = all others
```

## Columns

```tex
% LaTeX (multicol)
\usepackage{multicol}
\begin{multicols}{2}
  Two columns of text...
\end{multicols}

% Document-wide two columns
\documentclass[twocolumn]{article}
```

```typst
// Document-wide
#set page(columns: 2)

// Local two-column block
#columns(2, gutter: 12pt)[
  Left column content.
  #colbreak()
  Right column content.
]

// Three columns
#columns(3)[
  Content spread across three columns.
]
```

## Headers and Footers

```tex
% LaTeX (fancyhdr)
\usepackage{fancyhdr}
\pagestyle{fancy}
\fancyhead[L]{Left header}
\fancyhead[C]{Center header}
\fancyhead[R]{Right header}
\fancyfoot[C]{\thepage}
\renewcommand{\headrulewidth}{0.4pt}
```

```typst
// Typst
#set page(
  header: context [
    #set text(size: 9pt)
    Left header
    #h(1fr)
    Center header
    #h(1fr)
    Right header
  ],
  footer: context [
    #h(1fr)
    #counter(page).display("1")
    #h(1fr)
  ],
)

// Header with rule
#set page(
  header: [
    #text(size: 9pt)[My Paper — Author Name]
    #v(-0.5em)
    #line(length: 100%, stroke: 0.4pt)
  ],
)
```

### Accessing Page Number in Header/Footer

```typst
// context is required for dynamic content
#set page(
  footer: context [
    #h(1fr)
    #counter(page).display("1 / 1", both: true)
    #h(1fr)
  ],
)
```

### Different First-Page Header

```typst
#set page(
  header: context {
    if counter(page).get().first() == 1 {
      none   // no header on first page
    } else [
      Running title #h(1fr) #counter(page).display()
    ]
  },
)
```

## Page Numbering

```tex
% LaTeX
\pagenumbering{arabic}       % 1, 2, 3
\pagenumbering{roman}        % i, ii, iii
\pagenumbering{Roman}        % I, II, III
\pagenumbering{alph}         % a, b, c
\setcounter{page}{1}
```

```typst
// Typst
#set page(numbering: "1")          // arabic
#set page(numbering: "i")          // roman (i, ii, iii)
#set page(numbering: "I")          // Roman (I, II, III)
#set page(numbering: "a")          // alphabetic
#set page(numbering: "1 / 1")      // "3 / 10" style
#set page(numbering: none)         // no numbering

// Position
#set page(number-align: center + bottom)   // default
#set page(number-align: right + bottom)
#set page(number-align: center + top)

// Reset counter
#counter(page).update(1)
```

## Page Breaks

```tex
% LaTeX
\newpage
\clearpage
\pagebreak
```

```typst
// Typst
#pagebreak()
#pagebreak(weak: true)    // only if needed (won't create blank page at section start)
```

## Vertical Spacing

```tex
% LaTeX
\vspace{1cm}
\vspace*{1cm}   % forces even at page break
\vfill          % stretch to fill
```

```typst
// Typst
#v(1cm)
#v(1fr)     // fills remaining vertical space
```

## Text Width and Block Sizing

```tex
% LaTeX
\begin{minipage}{0.5\textwidth}
  Content
\end{minipage}
```

```typst
// Typst
#box(width: 50%)[Content]            // inline
#block(width: 50%)[Content]          // block-level

// Side-by-side blocks (like minipage)
#grid(
  columns: (1fr, 1fr),
  gutter: 1em,
  [Left content],
  [Right content],
)
```

## Line Length and Justification

```tex
% LaTeX
\setlength{\parindent}{1.5em}
\setlength{\parskip}{0.5em}
\raggedright
\raggedleft
```

```typst
// Typst
#set par(first-line-indent: 1.5em)
#set par(spacing: 0.5em)
#set par(justify: false)   // raggedright equivalent
#align(right)[...]         // raggedleft equivalent
```

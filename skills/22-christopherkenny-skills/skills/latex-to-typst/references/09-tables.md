# Tables

## Basic Table

```tex
% LaTeX
\begin{tabular}{lcr}
  Left & Center & Right \\
  a    & b      & c     \\
\end{tabular}
```

```typst
// Typst
#table(
  columns: (auto, auto, auto),
  align: (left, center, right),
  [Left], [Center], [Right],
  [a],    [b],      [c],
)
```

## Column Widths

```tex
% LaTeX tabular column specs
{lcr}               % auto, centered, auto
{|l|c|r|}           % with vertical rules
{p{3cm}ll}          % fixed width, left, left
{m{3cm}}            % middle-aligned fixed
{X}                 % tabularx: stretch to fill
```

```typst
// Typst column sizes
columns: 3                          // equal auto columns
columns: (auto, auto, auto)         // all auto
columns: (left, center, right)      // specify alignment differently
columns: (3cm, 1fr, 2fr)            // fixed + fractional fill
columns: (auto, 1fr)                // auto + stretch

// Full table width (like tabularx)
#table(
  columns: (auto, 1fr, auto),       // middle column fills remaining width
  ...
)
```

## Table in Figure (with Caption)

```tex
% LaTeX
\begin{table}[htbp]
  \centering
  \caption{My table caption}     % caption ABOVE tabular = standard for tables
  \label{tab:mytable}
  \begin{tabular}{lll}
    A & B & C \\
    1 & 2 & 3 \\
  \end{tabular}
\end{table}
```

```typst
// Typst
#figure(
  table(
    columns: 3,
    [A], [B], [C],
    [1], [2], [3],
  ),
  caption: [My table caption.],
) <tab:mytable>
```

In LaTeX, table captions conventionally appear **above** the tabular. In Typst captions
default to below. Set caption above either per-figure or (better) with a document-level
`show` rule:

```typst
// Document-wide: all table figures get caption on top
#show figure.where(kind: table): set figure.caption(position: top)

// Per-figure override if needed
#figure(
  table(...),
  caption: figure.caption(position: top)[My table caption.],
)
```

## Lines and Rules (booktabs)

```tex
% LaTeX (booktabs)
\begin{tabular}{lll}
  \toprule
  Head1 & Head2 & Head3 \\
  \midrule
  a     & b     & c     \\
  d     & e     & f     \\
  \bottomrule
\end{tabular}
```

```typst
// Typst — use table.hline
#table(
  columns: 3,
  stroke: none,                          // remove all default strokes
  table.hline(stroke: 1.5pt),            // toprule
  [Head1], [Head2], [Head3],
  table.hline(stroke: 0.5pt),            // midrule
  [a], [b], [c],
  [d], [e], [f],
  table.hline(stroke: 1.5pt),            // bottomrule
)
```

### Partial Horizontal Lines

```tex
% LaTeX (booktabs)
\cmidrule{2-3}          % line spanning columns 2-3
\cmidrule(lr){1-2}      % with left/right trim
```

```typst
// Typst
table.hline(start: 1, end: 3, stroke: 0.5pt)   // spans columns 2-3 (0-indexed)
```

### Vertical Lines

```tex
% LaTeX
{|l|c|r|}    % vertical lines between all columns
{l||c|r}     % double line
```

```typst
// Typst — add vertical lines explicitly
#table(
  columns: 3,
  table.vline(x: 0),   // left of first column
  table.vline(x: 1),   // between col 1 and 2
  table.vline(x: 2),   // between col 2 and 3
  table.vline(x: 3),   // right of last column
  [A], [B], [C],
  [1], [2], [3],
)

// Or use stroke on table for full grid
#table(
  columns: 3,
  stroke: 0.5pt + black,   // all cell borders
  [A], [B], [C],
  [1], [2], [3],
)
```

## Merged Cells

### Column Span (multicolumn)

```tex
% LaTeX
\multicolumn{2}{c}{Merged heading}
```

```typst
// Typst
#table(
  columns: 3,
  table.cell(colspan: 2, align: center)[Merged heading], [C],
  [1], [2], [3],
)
```

### Row Span (multirow)

```tex
% LaTeX (multirow)
\multirow{2}{*}{Tall cell}
```

```typst
// Typst
#table(
  columns: 3,
  rows: (auto, auto),
  table.cell(rowspan: 2)[Tall cell], [B1], [C1],
  // first cell of second row is consumed by rowspan
  [B2], [C2],
)
```

## Cell Styling

### Fill (Background Color)

```tex
% LaTeX (colortbl)
\rowcolor{lightgray}
\cellcolor{yellow}
```

```typst
// Per-cell fill
#table(
  columns: 3,
  fill: (col, row) =>
    if row == 0 { luma(200) }         // header row gray
    else if calc.odd(row) { luma(240) } // alternating rows
    else { none },
  [H1], [H2], [H3],
  [a],  [b],  [c],
  [d],  [e],  [f],
)

// Or use table.cell directly
table.cell(fill: yellow)[highlighted]
```

### Cell-Level Alignment

```typst
#table(
  columns: 3,
  align: (col, row) =>
    if col == 0 { left }
    else { center },
  [Name], [Score], [Grade],
  [Alice], [95], [A],
)
```

### Cell Padding

```typst
#table(
  columns: 3,
  inset: 8pt,                          // all cells
  // or per-direction:
  inset: (x: 12pt, y: 6pt),
  [A], [B], [C],
)
```

## Bold Header Cells

In LaTeX, header cells are often written as `\textbf{Col}`. In Typst, `table.header()`
does **not** auto-bold — wrap each cell in `*...*`:

```tex
% LaTeX
\textbf{Year} & \textbf{Dem. Seats} & \textbf{Change} \\
\midrule
```

```typst
// Typst
table.hline(stroke: 1.5pt),
table.header(
  [*Year*], [*Dem. Seats*], [*Change*],
),
table.hline(stroke: 0.5pt),
```

To bold all header cells globally:

```typst
#show table.header: it => strong(it)
```

## Header Rows (Repeated Across Pages)

```tex
% LaTeX (longtable)
\begin{longtable}{lll}
  \toprule Head1 & Head2 & Head3 \\ \midrule
  \endfirsthead
  Head1 & Head2 & Head3 \\ \midrule
  \endhead
  \bottomrule
  \endfoot
  ...rows...
\end{longtable}
```

```typst
// Typst — tables automatically break across pages
// Mark header rows with table.header:
#table(
  columns: 3,
  table.header(
    [Head1], [Head2], [Head3],
  ),
  ..rows..
)
```

## Numeric Alignment

```tex
% LaTeX (dcolumn)
{D{.}{.}{2}}   % align on decimal point
```

```typst
// Typst — no built-in decimal alignment
// Workaround: use two columns or right-align
#table(
  columns: (auto, auto),
  align: (left, right),
  [Item], [Price],
  [Apple], [\$1.25],
  [Banana], [\$0.75],
)
```

## Complete booktabs-Style Example

```typst
#figure(
  table(
    columns: (auto, 1fr, auto, auto),
    stroke: none,
    inset: (x: 8pt, y: 6pt),
    align: (left, left, center, right),
    table.hline(stroke: 1.5pt),
    [*Model*], [*Description*], [*Accuracy*], [*Time (s)*],
    table.hline(stroke: 0.5pt),
    [Baseline], [Simple linear regression], [72.3%], [0.02],
    [MLP],      [3-layer neural network],   [85.1%], [1.45],
    [Transformer], [Attention-based model], [91.7%], [8.23],
    table.hline(stroke: 1.5pt),
  ),
  caption: [Model comparison on test set.],
) <tab:models>
```

## List of Tables

```tex
% LaTeX
\listoftables
```

```typst
// Typst
#outline(
  title: [List of Tables],
  target: figure.where(kind: table),
)
```

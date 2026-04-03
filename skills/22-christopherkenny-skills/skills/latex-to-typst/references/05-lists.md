# Lists

## Bullet Lists (itemize)

```tex
% LaTeX
\begin{itemize}
  \item First item
  \item Second item
  \begin{itemize}
    \item Nested item
  \end{itemize}
  \item Third item
\end{itemize}
```

```typst
// Typst markup (preferred)
- First item
- Second item
  - Nested item
- Third item

// Typst function call
#list[First item][Second item][Third item]
```

### Custom Bullets

```tex
% LaTeX (enumitem)
\begin{itemize}[label=\textbullet]
  \item ...
\end{itemize}
\begin{itemize}[label=--]
  \item ...
\end{itemize}
```

```typst
// Typst
#set list(marker: [--])
- Item one
- Item two

// Different markers per nesting level
#set list(marker: ([•], [‣], [–]))
- Level 1
  - Level 2
    - Level 3

// Custom function-based marker
#set list(marker: (depth) =>
  if depth == 0 { [•] }
  else if depth == 1 { [◦] }
  else { [▪] }
)
```

## Numbered Lists (enumerate)

```tex
% LaTeX
\begin{enumerate}
  \item First
  \item Second
  \item Third
\end{enumerate}
```

```typst
// Typst markup (preferred)
+ First
+ Second
+ Third

// Function call
#enum[First][Second][Third]
```

### Custom Numbering Styles

```tex
% LaTeX (enumitem)
\begin{enumerate}[label=\alph*)]    % a), b), c)
\begin{enumerate}[label=\Roman*.]   % I., II., III.
\begin{enumerate}[label=(\arabic*)] % (1), (2), (3)
```

```typst
// Typst
#set enum(numbering: "a)")         // a), b), c)
+ Alpha
+ Beta

#set enum(numbering: "I.")         // I., II., III.
+ First
+ Second

#set enum(numbering: "(1)")        // (1), (2), (3)
+ Item
+ Item
```

### Start From Specific Number

```tex
% LaTeX (enumitem)
\begin{enumerate}[start=5]
  \item Fifth
\end{enumerate}

% Or with setcounter
\begin{enumerate}
  \setcounter{enumi}{4}
  \item Fifth
\end{enumerate}
```

```typst
// Typst
#enum(start: 5)[Fifth][Sixth]

// Or in markup, use the explicit number
5. Fifth
6. Sixth
```

### Resumed Lists

```tex
% LaTeX (enumitem)
\begin{enumerate}
  \item First
  \item Second
\end{enumerate}
Text in between.
\begin{enumerate}[resume]
  \item Third (continues from 2)
\end{enumerate}
```

```typst
// Typst — use enum.item with explicit numbers
+ First
+ Second

Text in between.

#enum(start: 3)[Third (continues from 2)]
```

## Description Lists (description)

```tex
% LaTeX
\begin{description}
  \item[Term 1] Definition of term 1.
  \item[Term 2] Definition of term 2.
\end{description}
```

```typst
// Typst — no built-in description list; use terms
/ Term 1: Definition of term 1.
/ Term 2: Definition of term 2.

// Or style manually
#list(
  marker: none,
  indent: 0pt,
)[
  #[*Term 1*: Definition of term 1.]
  #[*Term 2*: Definition of term 2.]
]
```

## List Spacing

```tex
% LaTeX (enumitem)
\begin{itemize}[noitemsep]    % tight
\begin{itemize}[topsep=0pt]   % no extra space before/after
\begin{itemize}[itemsep=1em]  % custom spacing
```

```typst
// Typst
#set list(tight: true)     // compact (uses leading between items)
#set list(tight: false)    // open (uses paragraph spacing between items)
#set list(spacing: 1em)    // explicit spacing between items

// Local override
#list(tight: false)[Item 1][Item 2]
```

## Nested Lists

```tex
% LaTeX
\begin{enumerate}
  \item Level 1
  \begin{enumerate}
    \item Level 2
    \begin{enumerate}
      \item Level 3
    \end{enumerate}
  \end{enumerate}
\end{enumerate}
```

```typst
// Typst
+ Level 1
  + Level 2
    + Level 3

// Full path numbering (shows 1.a.i style)
#set enum(numbering: "1.a.i.", full: true)
+ Outer
  + Middle
    + Inner
```

## Checklist / Task Lists

```tex
% LaTeX — manual
\begin{itemize}
  \item[$\checkmark$] Done
  \item[$\square$] Todo
\end{itemize}
```

```typst
// Typst
#list(
  marker: [☑],
)[Done]
#list(
  marker: [☐],
)[Todo]

// Or mixed
- #sym.checkmark Done item
- #sym.square.stroked Pending item
```

## List Indentation

```tex
% LaTeX (enumitem)
\setlist[itemize]{leftmargin=2cm}
```

```typst
// Typst
#set list(indent: 2cm)
#set enum(indent: 2cm)
```

## Inline Lists

```tex
% LaTeX (paralist or inline enumitem)
\begin{inlineenum}
  \item one \item two \item three
\end{inlineenum}
```

```typst
// Typst — no built-in, construct manually
#[(1) one, (2) two, (3) three]
```

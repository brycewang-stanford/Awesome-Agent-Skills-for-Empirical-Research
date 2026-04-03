# Miscellaneous: Code Blocks, Footnotes, Links, and More

## Code Blocks (verbatim / listings / minted)

### Inline Code

```tex
% LaTeX
\verb|some code|
\texttt{code}
```

```typst
// Typst
`some code`
#raw("some code")
```

### Block Code

```tex
% LaTeX (verbatim)
\begin{verbatim}
for i in range(10):
    print(i)
\end{verbatim}

% LaTeX (listings)
\begin{lstlisting}[language=Python]
for i in range(10):
    print(i)
\end{lstlisting}

% LaTeX (minted)
\begin{minted}{python}
for i in range(10):
    print(i)
\end{minted}
```

````typst
// Typst
```python
for i in range(10):
    print(i)
```
````

### Code Block Styling

```typst
// Custom font for all code
#show raw: set text(font: "Cascadia Code", size: 9pt)

// Scale block code differently from inline
#show raw.where(block: true): set text(size: 0.9em)

// Add background to code blocks
#show raw.where(block: true): block.with(
  fill: luma(240),
  inset: 1em,
  radius: 4pt,
  width: 100%,
)
```

### Code in Figures

```typst
#figure(
  raw(lang: "python", block: true,
    "def hello():\n    print('Hello, world!')"
  ),
  caption: [A simple Python function.],
  kind: raw,
)
```

### Supported Languages

Typst uses Sublime Text syntax definitions. Common identifiers: `python`, `rust`, `javascript`, `typescript`, `c`, `cpp`, `java`, `bash`, `sh`, `html`, `css`, `json`, `yaml`, `toml`, `sql`, `r`, `julia`, `matlab`, `latex`, `typ` (Typst), `typc` (Typst code mode), `typm` (Typst math mode).

## Footnotes

```tex
% LaTeX
This is text.\footnote{This is a footnote.}
This uses symbol marks.\footnote[*]{Starred footnote.}
```

```typst
// Typst
This is text.#footnote[This is a footnote.]

// Custom numbering style
#set footnote(numbering: "*")
This uses symbols.#footnote[Symbol footnote.]

// Reset to numbers
#set footnote(numbering: "1")
```

### Footnote at End of Sentence

```typst
// Note: footnote mark appears before period in Typst
This is text#footnote[Note.].
// renders as: "This is text¹."
```

### Reusing Footnotes

```typst
// Define once, reference multiple times
This text#footnote[Shared note.] <fn-shared> references a note.
Later text also references the same note.#footnote(<fn-shared>)
```

### Footnote Styling

```typst
// Change separator
#show footnote.entry: set par(leading: 0.5em)

// Custom separator line
#show footnote.entry: it => {
  v(3pt)
  line(length: 40%, stroke: 0.4pt)
  v(2pt)
  it
}
```

## Hyperlinks

```tex
% LaTeX (hyperref)
\href{https://example.com}{click here}
\url{https://example.com}
\email{user@example.com}   % (custom command)
```

```typst
// Typst
#link("https://example.com")[click here]
#link("https://example.com")           // URL is display text
https://example.com                    // auto-linked in text
#link("mailto:user@example.com")[email]
```

### Styling Links

```typst
// Blue underlined links (like hyperref default)
#show link: it => underline(text(fill: blue, it))

// Remove all link styling (print-friendly)
#show link: it => it.body
```

## Endnotes

LaTeX's `endnotes` package has no direct Typst equivalent. Simulate with a list at the end:

```typst
#let endnote-list = state("endnotes", ())

#let endnote(body) = {
  endnote-list.update(lst => lst + (body,))
  context super[#endnote-list.get().len()]
}

// At end of document:
#context {
  let notes = endnote-list.final()
  if notes.len() > 0 {
    heading(level: 1, numbering: none)[Notes]
    for (i, note) in notes.enumerate() {
      [#(i+1). #note #linebreak()]
    }
  }
}
```

## Margin Notes

```tex
% LaTeX
\marginpar{Margin note.}
\marginpar[\raggedleft Note]{\raggedright Note}  % two-sided
```

```typst
// Typst
#place(
  right + top,
  dx: 1em,
  float: false,
)[
  #text(size: 8pt, fill: gray)[Margin note.]
]

// Or using marginalia pattern
#let marginnote(body) = place(
  right,
  dx: 1em,
)[#text(size: 8pt)[#body]]
```

## Colors

```tex
% LaTeX (xcolor)
\textcolor{red}{red text}
\textcolor[HTML]{FF5733}{custom}
\colorbox{yellow}{box}
\fcolorbox{red}{yellow}{framed box}
```

```typst
// Typst
#text(fill: red)[red text]
#text(fill: rgb("#FF5733"))[custom]
#highlight(fill: yellow)[box]
#box(fill: yellow, stroke: red, inset: 4pt)[framed box]
```

## Horizontal Rules

```tex
% LaTeX
\hrule
\rule{\textwidth}{0.4pt}
\noindent\rule[0.5ex]{\linewidth}{1pt}
```

```typst
// Typst
#line(length: 100%)
#line(length: 100%, stroke: 0.4pt)
#line(length: 100%, stroke: 1pt)
```

## Paragraph Indentation Control

```tex
% LaTeX
\noindent First paragraph.
\indent Indented.
```

```typst
// Typst
#par(first-line-indent: 0pt)[No indent.]

// Or set globally
#set par(first-line-indent: 0pt)
```

## Theorem-Like Environments

See [06-math.md](06-math.md) for theorem implementations. For the `thmtools` / `amsthm` pattern:

```tex
% LaTeX
\newtheorem{lemma}[theorem]{Lemma}
\newtheorem*{remark}{Remark}
\begin{theorem}[Fermat's Last]
  ...
\end{theorem}
\begin{proof}
  ...
\end{proof}
```

```typst
// Typst
#let env-counter = counter("thm")

#let make-env(name, numbered: true, body, title: none) = {
  if numbered { env-counter.step() }
  block(
    stroke: (left: 2pt + black),
    inset: (left: 1em, rest: 0.5em),
    width: 100%,
  )[
    *#name#if numbered [
      #context [ #env-counter.display()]
    ]#if title [ (#title)]*. #body
  ]
}

#let theorem(body, title: none) = make-env("Theorem", body, title: title)
#let lemma(body, title: none)   = make-env("Lemma",   body, title: title)
#let remark(body)               = make-env("Remark",  numbered: false, body)
#let proof(body) = block[_Proof._ #body #h(1fr) $square$]

#theorem(title: "Fermat's Last")[
  No integer solution to $a^n + b^n = c^n$ for $n > 2$.
]
#proof[By contradiction...]
```

## Todo Notes

```tex
% LaTeX (todonotes)
\todo{Fix this!}
\missingfigure{Add chart here}
```

```typst
// Typst
#let todo(body) = box(
  fill: yellow.lighten(60%),
  stroke: yellow.darken(30%),
  inset: (x: 4pt, y: 2pt),
  radius: 2pt,
)[
  #text(size: 8pt, fill: yellow.darken(50%))[TODO: #body]
]

Some text #todo[Fix this!] and more text.
```

## Acronyms

```tex
% LaTeX (acro or acronym package)
\newacronym{NLP}{NLP}{Natural Language Processing}
\ac{NLP}    % first use: Natural Language Processing (NLP)
\ac{NLP}    % subsequent: NLP
```

```typst
// Typst — use state to track first use
#let acro-state = state("acronyms", (:))

#let acro(short, long) = context {
  let used = acro-state.get()
  if short not in used {
    acro-state.update(d => d + (short: true))
    [#long (#short)]
  } else {
    short
  }
}

// Usage
#acro("NLP", "Natural Language Processing") is useful.
Later, #acro("NLP", "Natural Language Processing") is referred to briefly.
```

## Smart Quotes

```tex
% LaTeX
``English quotes''
`single quotes'
```

```typst
// Typst — automatic smart quotes (default on)
"English quotes"
'single quotes'

// Disable smart quotes
#set text(smartquotes: false)
"Dumb quotes"
```

## Dates

```tex
% LaTeX
\today   % current date in full format
```

```typst
// Typst
#datetime.today().display()         // locale-dependent
#datetime.today().display("[year]-[month]-[day]")   // ISO format
#datetime.today().display("[month repr:long] [day], [year]")  // "March 15, 2025"
```

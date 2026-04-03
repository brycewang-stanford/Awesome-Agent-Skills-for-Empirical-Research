# Cross-References

## Labels and References

In LaTeX, you use `\label{key}` to mark a location and `\ref{key}` to reference it. In Typst, labels are written as `<key>` directly after the element and referenced with `@key`.

### Basic Pattern

```tex
% LaTeX
\section{Introduction}
\label{sec:intro}

\begin{equation}
  E = mc^2
  \label{eq:einstein}
\end{equation}

\begin{figure}
  \includegraphics{photo.jpg}
  \caption{Caption}
  \label{fig:photo}
\end{figure}

% References
See Section~\ref{sec:intro}.
See Equation~\eqref{eq:einstein}.
See Figure~\ref{fig:photo}.
```

```typst
// Typst
= Introduction <sec:intro>

$ E = m c^2 $ <eq:einstein>

#figure(
  image("photo.jpg"),
  caption: [Caption],
) <fig:photo>

// References
See @sec:intro.
See @eq:einstein.
See @fig:photo.
```

## Label Placement Rules

In Typst, labels bind to the element immediately before them:

| Element | Label syntax |
|---------|-------------|
| Heading | `= Title <label>` |
| Equation | `$ ... $ <label>` |
| Figure | `#figure(...) <label>` |
| Table (via figure) | `#figure(table(...), ...) <label>` |
| Paragraph / text | `Text here. <label>` |
| Any block | `#block[...] <label>` |

## Reference Output

`@key` automatically generates the appropriate label text (e.g., "Section 1", "Figure 2", "Equation (1)") based on the element type and its numbering.

```typst
// @label outputs: "Section 1", "eq. (1)", "fig. 1", etc. depending on style
See @intro for details.
As shown in @fig:results.
From @eq:main, we derive...
```

### Supplement Text

Typst adds the element name automatically. You can configure it:

```typst
// Change supplement for headings
#set heading(supplement: "Sec.")
// Now @sec:intro outputs "Sec. 1"

// Change supplement for figures
#set figure(supplement: "Fig.")
// Now @fig:photo outputs "Fig. 1"

// Change supplement for equations
#set math.equation(supplement: "Eq.")
// Now @eq:einstein outputs "Eq. (1)"
```

## Page References

```tex
% LaTeX
\pageref{key}    % page number only
```

```typst
// Typst
#context [see p.~#locate(<key>).page]

// Or use @key with context
At page #context counter(page).at(<key>).first()
```

## Custom Reference Format

```tex
% LaTeX (cleveref)
\cref{sec:intro}     % "section 1"
\Cref{sec:intro}     % "Section 1"
\cref{fig:a,fig:b}   % "figures 1 and 2"
```

```typst
// Typst — @key automatically uses the element's supplement
@sec:intro      // "Section 1" (with appropriate supplement set)

// For range references (no built-in multi-ref):
@fig:a and @fig:b
```

## Forward and Backward References

Typst handles both forward and backward references — you can reference a figure before it appears in the document.

```typst
As shown in @fig:result (on the following page)...

// ... later in the document ...

#figure(image("result.png"), caption: [Result.]) <fig:result>
```

## Numbered Equations with \eqref

```tex
% LaTeX
See~\eqref{eq:main}.    % outputs "(1)"
```

```typst
// Typst — @label outputs the equation number with parentheses
// if numbering: "(1)" is set
#set math.equation(numbering: "(1)")

$ x^2 = y $ <eq:main>

See @eq:main.   // outputs "Eq. (1)" or just "(1)" depending on supplement
```

To suppress the supplement and show only the number:

```typst
#show ref.where(element: math.equation): it => {
  it.element.counter.display(it.element.numbering)
}
// Now @eq:main outputs "(1)"
```

## Hyperlinks vs. Cross-references

```tex
% LaTeX (hyperref)
\href{https://example.com}{link text}   % URL hyperlink
\hyperlink{label}{text}                 % internal hyperlink
\label{label}
```

```typst
// Typst
#link("https://example.com")[link text]    // URL hyperlink
#link(<label>)[text]                       // internal hyperlink via label
```

## Counters

```tex
% LaTeX
\theequation      % current equation number
\thefigure        % current figure number
\thesection       % current section number
```

```typst
// Typst — access counters with context
#context counter(math.equation).display()
#context counter(figure.where(kind: image)).display()
#context counter(heading).display()
```

## Cross-referencing Theorems

```typst
#let thm-counter = counter("theorem")

#let theorem(label: none, body) = {
  thm-counter.step()
  let num = context thm-counter.display()
  block(
    stroke: 0.5pt,
    inset: 1em,
    width: 100%,
  )[
    *Theorem #num.* #body
  ]
}

// Usage
#theorem(label: <thm:main>)[
  For all $n$...
]

// Reference
By @thm:main...
```

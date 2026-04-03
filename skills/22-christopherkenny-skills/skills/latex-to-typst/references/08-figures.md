# Figures and Images

## Basic Image Inclusion

```tex
% LaTeX
\usepackage{graphicx}
\includegraphics{image.png}
\includegraphics[width=0.5\textwidth]{image.png}
\includegraphics[width=5cm, height=3cm]{image.png}
\includegraphics[scale=0.75]{image.png}
```

```typst
// Typst — no import needed
#image("image.png")
#image("image.png", width: 50%)
#image("image.png", width: 5cm, height: 3cm)
#image("image.png", width: 75%)

// Fit options (when both width and height given)
#image("image.png", width: 5cm, height: 3cm, fit: "contain")   // letterbox
#image("image.png", width: 5cm, height: 3cm, fit: "cover")     // crop (default)
#image("image.png", width: 5cm, height: 3cm, fit: "stretch")   // distort
```

## Figure Environment

```tex
% LaTeX
\begin{figure}[htbp]
  \centering
  \includegraphics[width=0.8\textwidth]{photo.jpg}
  \caption{A descriptive caption.}
  \label{fig:photo}
\end{figure}
```

```typst
// Typst
#figure(
  image("photo.jpg", width: 80%),
  caption: [A descriptive caption.],
) <fig:photo>
```

### Figure Placement

```tex
% LaTeX placement specifiers
\begin{figure}[h]   % here
\begin{figure}[t]   % top
\begin{figure}[b]   % bottom
\begin{figure}[p]   % separate page
\begin{figure}[H]   % force here (float package)
```

```typst
// Typst
#figure(
  image("photo.jpg"),
  caption: [...],
  placement: auto,    // Typst decides (default: none = in-flow)
)

#figure(
  image("photo.jpg"),
  caption: [...],
  placement: top,     // float to top
)

#figure(
  image("photo.jpg"),
  caption: [...],
  placement: bottom,  // float to bottom
)

// In-flow (no floating) — default when placement: none
#figure(
  image("photo.jpg"),
  caption: [...],
)
```

### Caption Positioning

```tex
% LaTeX (caption package)
\captionsetup{position=above}
```

```typst
// Typst
#figure(
  image("photo.jpg"),
  caption: figure.caption(
    position: top,     // caption above image
    [My caption text]
  ),
)

// Set globally
#show figure.caption: set block(above: 0.5em)
#set figure.caption(position: top)   // not directly supported; use show rule
```

## Numbering and Captions

```tex
% LaTeX — default "Figure 1: ..."
\captionsetup{labelfont=bf}
\captionsetup{labelformat=simple}
```

```typst
// Typst
#set figure(numbering: "1")     // default: Figure 1

// Bold label
#show figure.caption: it => [
  *#it.supplement #it.counter.display(it.numbering)*#it.separator#it.body
]

// Custom separator
#show figure.caption: it => [
  #it.supplement #it.counter.display(it.numbering) -- #it.body
]
```

## Subfigures

```tex
% LaTeX (subcaption)
\begin{figure}
  \begin{subfigure}{0.45\textwidth}
    \includegraphics[width=\linewidth]{a.png}
    \caption{First subfigure}
    \label{fig:a}
  \end{subfigure}
  \hfill
  \begin{subfigure}{0.45\textwidth}
    \includegraphics[width=\linewidth]{b.png}
    \caption{Second subfigure}
    \label{fig:b}
  \end{subfigure}
  \caption{Overall caption}
  \label{fig:both}
\end{figure}
```

```typst
// Typst — use grid inside figure
#figure(
  grid(
    columns: 2,
    gutter: 1em,
    [
      #image("a.png", width: 100%)
      (a) First subfigure
    ],
    [
      #image("b.png", width: 100%)
      (b) Second subfigure
    ],
  ),
  caption: [Overall caption.],
) <fig:both>

// With subfigure labels via figure
#figure(
  grid(
    columns: 2,
    gutter: 1em,
    figure(image("a.png"), caption: [First], numbering: "(a)") <fig:a>,
    figure(image("b.png"), caption: [Second], numbering: "(a)") <fig:b>,
  ),
  caption: [Overall caption.],
) <fig:both>
```

## Wrapping Text Around Figures

```tex
% LaTeX (wrapfig)
\begin{wrapfigure}{r}{0.4\textwidth}
  \centering
  \includegraphics[width=0.35\textwidth]{image.png}
  \caption{Caption}
\end{wrapfigure}
```

```typst
// Typst — use place
#place(
  right,
  float: false,
  dx: -1em,
)[
  #figure(
    image("image.png", width: 5cm),
    caption: [Caption],
  )
]

// Or use box with float
#figure(
  image("image.png", width: 40%),
  caption: [Caption],
  placement: right,
)
```

## Rotating Figures

```tex
% LaTeX (rotating)
\begin{sidewaysfigure}
  \includegraphics{wide-figure.pdf}
  \caption{Rotated}
\end{sidewaysfigure}
```

```typst
// Typst
#figure(
  rotate(-90deg, reflow: true)[
    #image("wide-figure.pdf", width: 20cm)
  ],
  caption: [Rotated figure],
)
```

## Supported Image Formats

| Format | LaTeX (pdflatex) | LaTeX (lualatex/xelatex) | Typst |
|--------|-----------------|--------------------------|-------|
| PNG | ✓ | ✓ | ✓ |
| JPEG | ✓ | ✓ | ✓ |
| PDF | ✓ | ✓ | ✓ (specify page) |
| SVG | ✗ | ✓ (via package) | ✓ |
| GIF | ✗ | ✗ | ✓ (first frame) |
| EPS | ✓ | ✗ | ✗ |
| WebP | ✗ | ✗ | ✓ |

```typst
// PDF with specific page
#image("multi-page.pdf", page: 3)
```

## List of Figures

```tex
% LaTeX
\listoffigures
```

```typst
// Typst
#outline(
  title: [List of Figures],
  target: figure.where(kind: image),
)
```

## Accessibility

```typst
// Add alt text for accessibility
#figure(
  image("chart.png", alt: "Bar chart showing annual sales from 2020 to 2024"),
  caption: [Annual sales data.],
)
```

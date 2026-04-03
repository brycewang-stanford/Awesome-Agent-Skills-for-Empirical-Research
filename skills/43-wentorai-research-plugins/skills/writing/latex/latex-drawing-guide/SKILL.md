---
name: latex-drawing-guide
description: "TikZ and PGFPlots techniques for publication-quality scientific figures"
metadata:
  openclaw:
    emoji: "🎨"
    category: "writing"
    subcategory: "latex"
    keywords: ["LaTeX typesetting", "LaTeX figure insertion", "LaTeX custom style", "scientific figure creation"]
    source: "https://github.com/xinychen/awesome-latex-drawing"
---

# LaTeX Drawing Guide

## Overview

Publication-quality figures are a critical component of scientific papers. While external tools like matplotlib or Inkscape can produce good results, drawing figures directly in LaTeX using TikZ and PGFPlots offers unique advantages: figures share the same fonts and styling as the document, scale perfectly at any resolution, and remain fully version-controllable as plain text.

This guide draws from the awesome-latex-drawing repository (2,000+ stars), which provides 30+ complete examples of LaTeX-drawn figures covering Bayesian networks, neural network architectures, function plots, tensor diagrams, and machine learning frameworks. The techniques here apply broadly to any discipline that needs diagrams, flowcharts, or data plots embedded in LaTeX documents.

Learning TikZ has a steep initial curve, but the investment pays off substantially for researchers who publish frequently. Once you build a library of reusable components, creating new figures becomes fast and consistent.

## TikZ Fundamentals

### Basic Setup

```latex
\usepackage{tikz}
\usetikzlibrary{arrows.meta, positioning, calc, shapes.geometric, fit}
```

### Coordinate System and Basic Shapes

```latex
\begin{tikzpicture}
  % Rectangle
  \draw[fill=blue!20, rounded corners] (0,0) rectangle (3,2);

  % Circle
  \draw[fill=red!20] (5,1) circle (1cm);

  % Arrow
  \draw[-{Stealth[length=3mm]}, thick] (3.2,1) -- (3.8,1);

  % Text node
  \node at (1.5,1) {Input};
  \node at (5,1) {Output};
\end{tikzpicture}
```

### Node-Based Diagrams

Nodes are the building blocks of most scientific diagrams:

```latex
\begin{tikzpicture}[
  block/.style={
    rectangle, draw, fill=blue!10,
    minimum width=2.5cm, minimum height=1cm,
    rounded corners, font=\small
  },
  arrow/.style={-{Stealth[length=2.5mm]}, thick}
]
  \node[block] (input) {Data Input};
  \node[block, right=2cm of input] (process) {Processing};
  \node[block, right=2cm of process] (output) {Results};

  \draw[arrow] (input) -- (process);
  \draw[arrow] (process) -- (output);
\end{tikzpicture}
```

## Neural Network Diagrams

### Fully Connected Layer

```latex
\begin{tikzpicture}[
  neuron/.style={circle, draw, fill=orange!30, minimum size=8mm},
  conn/.style={->, gray!70}
]
  % Input layer
  \foreach \i in {1,...,3}
    \node[neuron] (I\i) at (0, -\i*1.2) {$x_{\i}$};

  % Hidden layer
  \foreach \j in {1,...,4}
    \node[neuron, fill=blue!20] (H\j) at (3, -\j*1.2+0.6) {$h_{\j}$};

  % Output layer
  \foreach \k in {1,...,2}
    \node[neuron, fill=green!20] (O\k) at (6, -\k*1.2-0.6) {$y_{\k}$};

  % Connections
  \foreach \i in {1,...,3}
    \foreach \j in {1,...,4}
      \draw[conn] (I\i) -- (H\j);
  \foreach \j in {1,...,4}
    \foreach \k in {1,...,2}
      \draw[conn] (H\j) -- (O\k);

  % Labels
  \node[above=0.3cm of I1] {\small Input};
  \node[above=0.3cm of H1] {\small Hidden};
  \node[above=0.3cm of O1] {\small Output};
\end{tikzpicture}
```

### Transformer Block

```latex
\begin{tikzpicture}[
  block/.style={rectangle, draw, rounded corners, minimum width=3cm,
    minimum height=0.8cm, fill=#1, font=\small},
  block/.default=gray!10,
  arr/.style={-{Stealth}, thick}
]
  \node[block=yellow!20] (attn) at (0,0) {Multi-Head Attention};
  \node[block=blue!10] (norm1) at (0,1.3) {Add \& LayerNorm};
  \node[block=green!20] (ffn) at (0,2.6) {Feed-Forward Network};
  \node[block=blue!10] (norm2) at (0,3.9) {Add \& LayerNorm};

  \draw[arr] (attn) -- (norm1);
  \draw[arr] (norm1) -- (ffn);
  \draw[arr] (ffn) -- (norm2);

  % Residual connections
  \draw[arr, dashed, gray] (attn.west) -- ++(-0.8,0) |- (norm1.west);
  \draw[arr, dashed, gray] (ffn.west) -- ++(-0.8,0) |- (norm2.west);
\end{tikzpicture}
```

## PGFPlots for Data Visualization

### Setup

```latex
\usepackage{pgfplots}
\pgfplotsset{compat=1.18}
```

### Line Plot with Error Bars

```latex
\begin{tikzpicture}
\begin{axis}[
  width=0.8\textwidth,
  height=6cm,
  xlabel={Epoch},
  ylabel={Accuracy (\%)},
  legend pos=south east,
  grid=major,
  grid style={gray!30},
  tick label style={font=\small}
]
\addplot+[mark=o, thick, error bars/.cd, y dir=both, y explicit]
  coordinates {
    (1,72) +- (0,1.5)
    (5,85) +- (0,1.2)
    (10,91) +- (0,0.8)
    (20,94) +- (0,0.5)
    (50,96) +- (0,0.3)
  };
\addlegendentry{Our Method}

\addplot+[mark=square, thick, dashed]
  coordinates {(1,68) (5,79) (10,85) (20,89) (50,91)};
\addlegendentry{Baseline}
\end{axis}
\end{tikzpicture}
```

### Bar Chart Comparing Methods

```latex
\begin{tikzpicture}
\begin{axis}[
  ybar,
  width=10cm, height=6cm,
  symbolic x coords={BLEU, ROUGE-L, METEOR},
  xtick=data,
  ylabel={Score},
  ymin=0, ymax=100,
  bar width=12pt,
  legend style={at={(0.5,1.05)}, anchor=south, legend columns=3},
  nodes near coords,
  nodes near coords style={font=\tiny}
]
\addplot coordinates {(BLEU,45.2) (ROUGE-L,62.1) (METEOR,38.7)};
\addplot coordinates {(BLEU,52.8) (ROUGE-L,68.4) (METEOR,44.3)};
\addplot coordinates {(BLEU,58.1) (ROUGE-L,71.9) (METEOR,49.6)};
\legend{Baseline, +Pretraining, +Fine-tuning}
\end{axis}
\end{tikzpicture}
```

## Bayesian Network and Graphical Models

```latex
\begin{tikzpicture}[
  latent/.style={circle, draw, minimum size=1cm, fill=gray!20},
  observed/.style={circle, draw, minimum size=1cm, fill=white, thick},
  plate/.style={rectangle, draw, dashed, rounded corners, inner sep=10pt},
  arr/.style={-{Stealth}, thick}
]
  \node[latent] (theta) at (0,2) {$\theta$};
  \node[latent] (z) at (2,2) {$z_n$};
  \node[observed] (x) at (2,0) {$x_n$};
  \node[latent] (alpha) at (-1.5,2) {$\alpha$};

  \draw[arr] (alpha) -- (theta);
  \draw[arr] (theta) -- (z);
  \draw[arr] (z) -- (x);

  \node[plate, fit=(z)(x), label=below right:$N$] {};
\end{tikzpicture}
```

## Best Practices

- **Define styles globally.** Use `\tikzset{}` in the preamble so all figures share consistent colors and shapes.
- **Use relative positioning.** `right=2cm of nodeA` is more maintainable than absolute coordinates.
- **Externalize figures.** For large documents, use `\usetikzlibrary{external}` to cache compiled figures and speed up builds.
- **Match document fonts.** TikZ inherits the document font automatically -- this is a key advantage over external tools.
- **Export standalone figures.** Use the `standalone` document class to compile figures individually for reuse in presentations.
- **Keep source readable.** One node or drawing command per line, with comments explaining the visual structure.

## References

- [awesome-latex-drawing](https://github.com/xinychen/awesome-latex-drawing) -- 30+ LaTeX drawing examples (2,000+ stars)
- [TikZ and PGF Manual](https://tikz.dev/) -- Official documentation
- [PGFPlots Manual](https://pgfplots.net/) -- Data visualization in LaTeX
- [TikZ Examples](https://texample.net/tikz/examples/) -- Community gallery
- [LaTeX Drawing Tutorial](https://www.overleaf.com/learn/latex/TikZ_package) -- Overleaf tutorial

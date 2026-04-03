---
name: tikz-diagrams-guide
description: "Create publication-quality scientific diagrams with TikZ in LaTeX"
metadata:
  openclaw:
    emoji: "📐"
    category: "writing"
    subcategory: "latex"
    keywords: ["TikZ", "LaTeX diagrams", "scientific figures", "flowcharts", "PGFplots", "vector graphics"]
    source: "wentor-research-plugins"
---

# TikZ Diagrams Guide

A skill for creating publication-quality scientific diagrams directly in LaTeX using the TikZ package. Covers basic drawing commands, flowcharts, neural network architectures, data flow diagrams, and integration with PGFplots for camera-ready figures.

## Getting Started with TikZ

### Basic Setup

```latex
\documentclass{article}
\usepackage{tikz}
\usetikzlibrary{arrows.meta, positioning, shapes.geometric, calc, fit}

\begin{document}
\begin{tikzpicture}
  % Your drawing commands here
\end{tikzpicture}
\end{document}
```

### Fundamental Drawing Commands

```latex
% Lines and shapes
\draw (0,0) -- (3,0) -- (3,2) -- cycle;          % Triangle
\draw[thick, ->] (0,0) -- (4,0);                  % Arrow
\draw[dashed, blue] (0,0) circle (1.5);            % Dashed circle
\filldraw[fill=gray!20, draw=black] (2,1) ellipse (1 and 0.5);

% Nodes (text labels with optional shapes)
\node[draw, rectangle, minimum width=2cm] (A) at (0,0) {Input};
\node[draw, circle] (B) at (3,0) {Process};
\draw[->] (A) -- (B);

% Relative positioning (requires positioning library)
\node[draw, rectangle] (C) [right=2cm of B] {Output};
\draw[->] (B) -- (C);
```

## Common Scientific Diagrams

### Flowcharts

```latex
\begin{tikzpicture}[
    block/.style={rectangle, draw, fill=blue!10, text width=5em,
                  text centered, rounded corners, minimum height=3em},
    decision/.style={diamond, draw, fill=green!10, text width=4em,
                     text centered, inner sep=0pt, aspect=2},
    line/.style={draw, -Stealth}
]
  \node[block] (data) {Collect Data};
  \node[block, below=1cm of data] (clean) {Clean \& Preprocess};
  \node[decision, below=1cm of clean] (valid) {Valid?};
  \node[block, below=1cm of valid] (analyze) {Analyze};
  \node[block, right=2cm of valid] (fix) {Fix Issues};

  \path[line] (data) -- (clean);
  \path[line] (clean) -- (valid);
  \path[line] (valid) -- node[right] {Yes} (analyze);
  \path[line] (valid) -- node[above] {No} (fix);
  \path[line] (fix) |- (clean);
\end{tikzpicture}
```

### Neural Network Architecture

```latex
\begin{tikzpicture}[
    neuron/.style={circle, draw, minimum size=0.8cm, fill=orange!20},
    layer/.style={rectangle, draw, dashed, inner sep=0.3cm}
]
  % Input layer
  \foreach \i in {1,2,3,4} {
    \node[neuron] (I\i) at (0, -\i*1.2) {};
  }

  % Hidden layer
  \foreach \j in {1,2,3} {
    \node[neuron, fill=blue!20] (H\j) at (3, -\j*1.2 - 0.6) {};
  }

  % Output layer
  \foreach \k in {1,2} {
    \node[neuron, fill=green!20] (O\k) at (6, -\k*1.2 - 1.2) {};
  }

  % Connections
  \foreach \i in {1,2,3,4} {
    \foreach \j in {1,2,3} {
      \draw[->] (I\i) -- (H\j);
    }
  }
  \foreach \j in {1,2,3} {
    \foreach \k in {1,2} {
      \draw[->] (H\j) -- (O\k);
    }
  }

  % Labels
  \node[above=0.5cm of I1] {Input};
  \node[above=0.5cm of H1] {Hidden};
  \node[above=0.5cm of O1] {Output};
\end{tikzpicture}
```

## Integration with PGFplots

### Combining Diagrams and Plots

```latex
\usepackage{pgfplots}
\pgfplotsset{compat=1.18}

\begin{tikzpicture}
\begin{axis}[
    xlabel={Epoch},
    ylabel={Loss},
    legend pos=north east,
    grid=major,
    width=8cm, height=6cm
]
  \addplot[blue, thick, mark=none] table {
    1  0.95
    5  0.72
    10 0.45
    20 0.22
    30 0.15
    50 0.08
  };
  \addlegendentry{Training}

  \addplot[red, thick, dashed, mark=none] table {
    1  0.98
    5  0.75
    10 0.52
    20 0.35
    30 0.30
    50 0.28
  };
  \addlegendentry{Validation}
\end{axis}
\end{tikzpicture}
```

## Tips for Publication-Quality Figures

### Style Guidelines

```
1. Font consistency:
   - Use the same font family as your document body
   - Minimum 8pt for axis labels and annotations
   - Match font size to caption text

2. Color considerations:
   - Use colorblind-friendly palettes (avoid red-green only)
   - Ensure figures are readable in grayscale
   - Use patterns or line styles as secondary differentiators

3. Size and resolution:
   - TikZ produces vector output (PDF) -- always sharp
   - Set figure width to match column width (single or double)
   - Use consistent sizing across all figures in the paper

4. Labeling:
   - Label all axes with units
   - Use (a), (b), (c) for sub-figures
   - Place legends inside the plot area when possible
```

### Exporting Standalone TikZ Figures

```latex
% standalone.tex -- compile separately, include as PDF
\documentclass[tikz, border=2mm]{standalone}
\usetikzlibrary{arrows.meta, positioning}
\begin{document}
\begin{tikzpicture}
  % ... your diagram ...
\end{tikzpicture}
\end{document}

% In your main document:
% \includegraphics{standalone.pdf}
```

## Useful TikZ Libraries

| Library | Purpose |
|---------|---------|
| `positioning` | Relative node placement (right=of, below=of) |
| `arrows.meta` | Modern arrow tip styles |
| `shapes.geometric` | Diamond, trapezium, ellipse nodes |
| `calc` | Coordinate calculations |
| `fit` | Fit a node around a set of other nodes |
| `decorations.pathreplacing` | Braces, snakes, zigzag lines |
| `backgrounds` | Draw behind other elements |
| `matrix` | Grid-based node layouts |

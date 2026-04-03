# Diagrams: TikZ to CeTZ

## Overview

CeTZ ("CeTZ, ein Typst Zeichenpaket") is the primary drawing package for Typst, analogous to TikZ in LaTeX. Import it from the Typst package registry.

```typst
// Import CeTZ
#import "@preview/cetz:0.3.1": canvas, draw, vector, matrix
```

```tex
% LaTeX TikZ
\usepackage{tikz}
\begin{tikzpicture}
  ...
\end{tikzpicture}
```

```typst
// Typst CeTZ
#canvas({
  import draw: *
  ...
})
```

## Key Differences

| Aspect | TikZ | CeTZ |
|--------|------|------|
| Y-axis direction | Down-positive (screen) | Up-positive (math) |
| Canvas sizing | Manual bounding box | Automatic |
| Coordinate system | `(x, y)` or named | `(x, y)` |
| Anchors | TikZ-style | Borrowed from TikZ |
| Styles | Key-value options | Named parameters |

## Basic Drawing Primitives

### Lines

```tex
% TikZ
\draw (0,0) -- (2,1);
\draw[thick, blue] (0,0) -- (2,1);
\draw[->, red] (0,0) -- (3,0);
```

```typst
// CeTZ
import draw: *

line((0,0), (2,1))
line((0,0), (2,1), stroke: (thickness: 2pt, paint: blue))
line((0,0), (3,0), mark: (end: "stealth"), stroke: red)
```

### Circles and Ellipses

```tex
% TikZ
\draw (0,0) circle (1cm);
\draw (0,0) ellipse (2cm and 1cm);
\fill[blue] (1,1) circle (0.5cm);
```

```typst
// CeTZ
circle((0,0), radius: 1)
circle((0,0), radius: (2, 1))   // ellipse
circle((1,1), radius: 0.5, fill: blue)
```

### Rectangles

```tex
% TikZ
\draw (0,0) rectangle (2,1);
\fill[gray] (0,0) rectangle (2,1);
\draw[fill=yellow] (0,0) rectangle (3,2);
```

```typst
// CeTZ
rect((0,0), (2,1))
rect((0,0), (2,1), fill: gray)
rect((0,0), (3,2), fill: yellow)
```

### Arcs

```tex
% TikZ
\draw (1,0) arc (0:90:1cm);
\draw (0,0) arc (0:270:1 and 0.5);
```

```typst
// CeTZ
arc((1,0), start: 0deg, stop: 90deg, radius: 1)
arc((0,0), start: 0deg, stop: 270deg, radius: (1, 0.5))
```

### Bezier Curves

```tex
% TikZ
\draw (0,0) .. controls (1,2) and (2,2) .. (3,0);
```

```typst
// CeTZ
bezier((0,0), (3,0), (1,2), (2,2))
```

## Text and Labels

```tex
% TikZ
\node at (1,1) {Label};
\node[above] at (0,2) {Top label};
\node[draw, rectangle] at (2,2) {Boxed};
```

```typst
// CeTZ
content((1,1), [Label])
content((0,2), [Top label], anchor: "south")
content((2,2), box(stroke: black, inset: 4pt)[Boxed])
```

### Anchors

CeTZ uses cardinal directions and named anchors:

```typst
// Anchors: "north", "south", "east", "west", "north-east", etc.
content((0,2), [Label], anchor: "south")    // label above point
content((2,0), [Label], anchor: "west")     // label to the right
```

## Named Nodes and Connecting Them

```tex
% TikZ
\node (A) at (0,0) {A};
\node (B) at (3,0) {B};
\draw[->] (A) -- (B);
\draw[->] (A.east) -- (B.west);
```

```typst
// CeTZ
import draw: *

// Name elements with set-style
circle((0,0), radius: 0.3, name: "A")
content("A", [A])
circle((3,0), radius: 0.3, name: "B")
content("B", [B])
line("A.east", "B.west", mark: (end: "stealth"))
```

## Paths and Fills

```tex
% TikZ
\draw[fill=lightgray] (0,0) -- (2,0) -- (1,2) -- cycle;
\filldraw[fill=blue!20, draw=blue] (0,0) -- (3,0) -- (3,3) -- cycle;
```

```typst
// CeTZ
import draw: *

line((0,0), (2,0), (1,2), close: true, fill: luma(220))
line((0,0), (3,0), (3,3), close: true,
  fill: blue.lighten(80%), stroke: blue)
```

## Transformations

```tex
% TikZ
\begin{scope}[shift={(2,0)}]
  \draw (0,0) circle (1);
\end{scope}
\begin{scope}[rotate=45]
  \draw (0,0) -- (2,0);
\end{scope}
\begin{scope}[scale=2]
  \draw (0,0) rectangle (1,1);
\end{scope}
```

```typst
// CeTZ
import draw: *

scope({
  translate((2,0))
  circle((0,0), radius: 1)
})

scope({
  rotate(45deg)
  line((0,0), (2,0))
})

scope({
  scale(2)
  rect((0,0), (1,1))
})
```

## Arrows and Marks

```tex
% TikZ
\draw[->] (0,0) -- (2,0);
\draw[<-] (0,0) -- (2,0);
\draw[<->] (0,0) -- (2,0);
\draw[-stealth] (0,0) -- (2,0);
\draw[-latex] (0,0) -- (2,0);
```

```typst
// CeTZ
import draw: *

line((0,0), (2,0), mark: (end: ">"))
line((0,0), (2,0), mark: (start: ">"))
line((0,0), (2,0), mark: (start: ">", end: ">"))
line((0,0), (2,0), mark: (end: "stealth"))
line((0,0), (2,0), mark: (end: "latex"))
```

## Colors and Styles

```tex
% TikZ
\draw[color=red, line width=2pt] ...;
\draw[dashed] ...;
\draw[dotted] ...;
\draw[thick] ...;
```

```typst
// CeTZ
import draw: *

set-style(stroke: red)
line(...)

line(..., stroke: (paint: red, thickness: 2pt))
line(..., stroke: (dash: "dashed"))
line(..., stroke: (dash: "dotted"))
line(..., stroke: 2pt)
```

## Common TikZ Patterns

### Commutative Diagram

```tex
% TikZ
\begin{tikzcd}
  A \arrow[r, "f"] \arrow[d, "g"'] & B \arrow[d, "h"] \\
  C \arrow[r, "k"'] & D
\end{tikzcd}
```

```typst
// CeTZ (manual approach — or use @preview/fletcher package)
#import "@preview/fletcher:0.5.1" as fletcher: diagram, node, edge

#diagram(
  node((0,0), $A$),
  node((1,0), $B$),
  node((0,1), $C$),
  node((1,1), $D$),
  edge((0,0), (1,0), $f$, "->"),
  edge((0,0), (0,1), $g$, "->"),
  edge((1,0), (1,1), $h$, "->"),
  edge((0,1), (1,1), $k$, "->"),
)
```

### State Machine / Automaton

```typst
// Using fletcher for automaton diagrams
#import "@preview/fletcher:0.5.1" as fletcher: diagram, node, edge

#diagram(
  node((0,0), $q_0$, shape: circle, stroke: 1pt),
  node((2,0), $q_1$, shape: circle, stroke: 1pt),
  node((4,0), $q_2$, shape: circle, stroke: 2pt, extrude: (-2,0)), // accepting
  edge((-0.5,0), (0,0), "->"),
  edge((0,0), (2,0), $a$, "->", bend: 30deg),
  edge((2,0), (0,0), $b$, "->", bend: 30deg),
  edge((2,0), (4,0), $a$, "->"),
  edge((4,0), (4,0), $a\,b$, "->", loop: right),
)
```

### Simple Graph

```typst
#canvas({
  import draw: *

  // Nodes
  let nodes = (
    "A": (0, 2),
    "B": (2, 0),
    "C": (-2, 0),
  )

  for (name, pos) in nodes {
    circle(pos, radius: 0.3, fill: white, stroke: black, name: name)
    content(pos, [#name])
  }

  // Edges
  line("A.south-east", "B.north-west")
  line("A.south-west", "C.north-east")
  line("B.west", "C.east")
})
```

## Alternative Packages

| TikZ library | Typst alternative |
|-------------|------------------|
| `tikzcd` (commutative diagrams) | `@preview/fletcher` |
| `pgfplots` (data plots) | `@preview/cetz-plot` or `@preview/lilac` |
| `tikz-automata` | `@preview/fletcher` |
| `tikz-trees` | `@preview/pintoree` or manual CeTZ |
| `circuitikz` | `@preview/circuiteer` |
| `pgf-umlsd` (sequence diagrams) | `@preview/chronos` |
| `forest` (tree structures) | `@preview/pintoree` |

## CeTZ in a Figure

```typst
#figure(
  canvas({
    import draw: *
    circle((0,0), radius: 1)
    line((0,0), (1,0), mark: (end: ">"))
    content((0.5, 0.2), [$r$])
  }),
  caption: [A circle with radius $r$.],
) <fig:circle>
```

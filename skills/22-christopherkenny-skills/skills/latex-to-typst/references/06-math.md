# Math Mode and Equations

## Inline vs. Display Math

| LaTeX | Typst |
|-------|-------|
| `$x^2$` or `\(x^2\)` | `$x^2$` |
| `$$x^2$$` or `\[x^2\]` | `$ x^2 $` (spaces around = block) |
| `\begin{equation}...\end{equation}` | `$ ... $` with `#set math.equation(numbering: "(1)")` |
| `\begin{equation*}...\end{equation*}` | `$ ... $` without numbering set |

> **Key difference**: In Typst, `$...$` with whitespace after `$` and before the closing `$` renders as a block equation. Without whitespace it's inline.

```typst
Inline: $x^2 + y^2 = r^2$

Block:
$ x^2 + y^2 = r^2 $
```

## Numbered Equations

```tex
% LaTeX
\begin{equation}
  E = mc^2
  \label{eq:einstein}
\end{equation}
See Equation~\eqref{eq:einstein}.
```

```typst
// Typst
#set math.equation(numbering: "(1)")

$ E = m c^2 $ <eq:einstein>

See @eq:einstein.
```

### Custom Equation Numbering

```typst
// Section-prefixed: (1.1), (1.2), (2.1), ...
#set math.equation(numbering: it => {
  let h = counter(heading).get()
  "("+str(h.first())+"."+str(it)+")"
})
```

## Subscripts and Superscripts

| LaTeX | Typst |
|-------|-------|
| `x_1` | `x_1` |
| `x^2` | `x^2` |
| `x_{ij}` | `x_(i j)` |
| `x^{n+1}` | `x^(n+1)` |
| `x_1^2` | `x_1^2` |
| `{}^{14}C` | `attach(C, tl: 14)` |
| `\sideset{_a^b}{_c^d}{\sum}` | `attach(sum, tl: b, bl: a, tr: d, br: c)` |

## Fractions

| LaTeX | Typst |
|-------|-------|
| `\frac{a}{b}` | `a/b` or `frac(a, b)` |
| `\dfrac{a}{b}` | `display(a/b)` |
| `\tfrac{a}{b}` | `inline(a/b)` |
| `\cfrac{a}{b}` | *(no exact equiv; use `frac` in display)* |
| `\sfrac{a}{b}` *(xfrac)* | `frac(a, b, style: "skewed")` |
| `\nicefrac{a}{b}` *(units)* | `frac(a, b, style: "skewed")` |

```typst
// Shorthand fraction
$ 1/2 $

// Grouping for complex numerator/denominator
$ (x+1)/(2y) $

// Explicit frac
$ frac(a + b, c + d) $

// Continued fraction
$ a + frac(1, b + frac(1, c + frac(1, d))) $
```

## Roots

| LaTeX | Typst |
|-------|-------|
| `\sqrt{x}` | `sqrt(x)` |
| `\sqrt[3]{x}` | `root(3, x)` |
| `\sqrt[n]{x}` | `root(n, x)` |

## Aligned Equations

```tex
% LaTeX
\begin{align}
  a &= b + c \\
  d &= e + f
\end{align}

\begin{align*}
  x &= 1 \\
  y &= 2
\end{align*}
```

```typst
// Typst — use & for alignment, \ for line break
$ a &= b + c \
  d &= e + f $

// Without equation numbers (default)
$ x &= 1 \
  y &= 2 $
```

### Multiple Alignment Points

```tex
% LaTeX
\begin{alignat}{2}
  x &= y  &&\quad \text{(substituting)} \\
  z &= w  &&\quad \text{(rearranging)}
\end{alignat}
```

```typst
// Typst — multiple & pairs work naturally
$ x &= y  & quad "(substituting)" \
  z &= w  & quad "(rearranging)" $
```

## Cases

```tex
% LaTeX
f(x) = \begin{cases}
  1 & \text{if } x > 0 \\
  0 & \text{otherwise}
\end{cases}
```

```typst
// Typst
$ f(x) = cases(
  1 & "if" x > 0,
  0 & "otherwise",
) $

// With bracket delimiter
$ cases(delim: "[", a, b) $
```

## Matrices

```tex
% LaTeX
\begin{pmatrix} a & b \\ c & d \end{pmatrix}
\begin{bmatrix} a & b \\ c & d \end{bmatrix}
\begin{vmatrix} a & b \\ c & d \end{vmatrix}
\begin{Vmatrix} a & b \\ c & d \end{Vmatrix}
\begin{Bmatrix} a & b \\ c & d \end{Bmatrix}
```

```typst
// Typst — delimiter controls matrix type
$ mat(a, b; c, d) $                         // pmatrix ( )
$ mat(delim: "[", a, b; c, d) $             // bmatrix [ ]
$ mat(delim: "|", a, b; c, d) $             // vmatrix | |
$ mat(delim: "‖", a, b; c, d) $            // Vmatrix ‖ ‖
$ mat(delim: "{", a, b; c, d) $             // Bmatrix { }
$ mat(delim: #none, a, b; c, d) $           // no delimiters

// Augmented matrix
$ mat(augment: 2, 1, 0, 1; 0, 1, 0) $      // vertical line after column 2
```

### Column Vectors

```tex
% LaTeX
\begin{pmatrix} x \\ y \\ z \end{pmatrix}
```

```typst
$ vec(x, y, z) $              // column vector (  )
$ vec(delim: "[", x, y, z) $  // with square brackets
```

## Operators

### Built-in Operators

These work without any declaration: `arccos`, `arcsin`, `arctan`, `arg`, `cos`, `cosh`, `cot`, `coth`, `csc`, `deg`, `det`, `dim`, `exp`, `gcd`, `hom`, `inf`, `ker`, `lcm`, `lg`, `lim`, `liminf`, `limsup`, `ln`, `log`, `max`, `min`, `mod`, `Pr`, `sec`, `sin`, `sinh`, `sup`, `tan`, `tanh`, `tr`

```typst
$ lim_(n -> oo) 1/n = 0 $
$ det(A) $
$ max_(x in RR) f(x) $
```

### Custom Operators

```tex
% LaTeX
\DeclareMathOperator{\rank}{rank}
\DeclareMathOperator*{\argmax}{arg\,max}
```

```typst
// Typst
#let rank = math.op("rank")
#let argmax = math.op("arg max", limits: true)

$ rank(A) $
$ argmax_(x in X) f(x) $
```

## Limits, Sums, Integrals

```tex
% LaTeX
\sum_{i=1}^{n} x_i
\int_0^\infty f(x)\,dx
\lim_{n \to \infty} a_n
\prod_{i=1}^{n} x_i
```

```typst
// Typst — subscripts/superscripts work the same
$ sum_(i=1)^n x_i $
$ integral_0^infinity f(x) dif x $
$ lim_(n -> oo) a_n $
$ product_(i=1)^n x_i $

// Display mode forces limits above/below (default in block)
// Inline mode uses scripts
// Override:
$ scripts(sum)_1^n $   // force script style
$ limits(sum)_1^n $    // force limits style
```

## Accents

| LaTeX | Typst |
|-------|-------|
| `\hat{x}` | `hat(x)` |
| `\tilde{x}` | `tilde(x)` |
| `\bar{x}` | `macron(x)` |
| `\vec{v}` | `arrow(v)` |
| `\dot{x}` | `dot(x)` |
| `\ddot{x}` | `dot.double(x)` |
| `\dddot{x}` | `dot.triple(x)` |
| `\grave{x}` | `grave(x)` |
| `\acute{x}` | `acute(x)` |
| `\breve{x}` | `breve(x)` |
| `\check{x}` | `caron(x)` |
| `\mathring{x}` | `circle(x)` |
| `\overrightarrow{AB}` | `arrow(A B)` |
| `\overleftarrow{AB}` | `arrow.l(A B)` |
| `\widehat{ABC}` | `hat(A B C)` |
| `\widetilde{ABC}` | `tilde(A B C)` |

## Over/Under Decorations

| LaTeX | Typst |
|-------|-------|
| `\overline{abc}` | `overline(a b c)` |
| `\underline{abc}` | `underline(a b c)` |
| `\overbrace{abc}^{n}` | `overbrace(a b c, n)` |
| `\underbrace{abc}_{n}` | `underbrace(a b c, n)` |
| `\overbracket{abc}` *(mathtools)* | `overbracket(a b c)` |
| `\underbracket{abc}` *(mathtools)* | `underbracket(a b c)` |
| `\overparen{abc}` | `overparen(a b c)` |
| `\underparen{abc}` | `underparen(a b c)` |
| `\xrightarrow{abc}` | `xarrow(sym: arrow.r, abc)` |

## Delimiters (Auto-sizing)

| LaTeX | Typst |
|-------|-------|
| `\left( ... \right)` | `lr((...))` |
| `\left[ ... \right]` | `lr([...])` |
| `\left\{ ... \right\}` | `lr({...})` |
| `\left\lvert ... \right\rvert` | `abs(...)` or `lr(|...|)` |
| `\left\lVert ... \right\rVert` | `norm(...)` or `lr(‖...‖)` |
| `\left\lfloor ... \right\rfloor` | `floor(...)` |
| `\left\lceil ... \right\rceil` | `ceil(...)` |
| `\left\langle ... \right\rangle` | `lr(angle.l ... angle.r)` |
| `\big( ... \big)` | `lr((...), size: 150%)` |

## Math Styles

| LaTeX | Typst |
|-------|-------|
| `\mathbb{R}` | `RR` (in math) |
| `\mathcal{L}` | `cal(L)` |
| `\mathfrak{g}` | `frak(g)` |
| `\mathbf{x}` | `bold(x)` |
| `\mathrm{d}` | `upright(d)` |
| `\mathit{x}` | `italic(x)` (default in math) |
| `\displaystyle` | `display(...)` |
| `\textstyle` | `inline(...)` |
| `\scriptstyle` | `script(...)` |
| `\scriptscriptstyle` | `sscript(...)` |

## Cancellation

| LaTeX | Typst |
|-------|-------|
| `\cancel{x}` *(cancel pkg)* | `cancel(x)` |
| `\bcancel{x}` | `cancel(x, inverted: true)` |
| `\xcancel{x}` | `cancel(x, cross: true)` |
| `\cancelto{v}{x}` | *(no direct equiv)* |

## Spacing in Math

| LaTeX | Typst | Width |
|-------|-------|-------|
| `\,` | `thin` or `#h(1pt/6*1em)` | 3/18 em |
| `\:` or `\>` | `med` | 4/18 em |
| `\;` | `thick` | 5/18 em |
| `\quad` | `quad` | 1 em |
| `\qquad` | `wide` | 2 em |
| `\!` | `#h(-1pt/6*1em)` | -3/18 em |
| `\hspace{1cm}` | `#h(1cm)` | custom |

```typst
// In math, use thin/med/thick/quad/wide directly:
$ a thin b $
$ a quad b $
```

## Text in Math

```tex
% LaTeX
$x = 1 \quad \text{for all } x \in \mathbb{R}$
```

```typst
// Typst — just use quotes for text in math
$ x = 1 quad "for all" x in RR $
```

## Theorems and Proofs

```tex
% LaTeX
\usepackage{amsthm}
\newtheorem{theorem}{Theorem}
\begin{theorem}
  Statement.
\end{theorem}
\begin{proof}
  Proof. \qed
\end{proof}
```

```typst
// Typst — define your own environment
#let thm-counter = counter("theorem")

#let theorem(body) = block(
  stroke: 0.5pt + black,
  inset: 1em,
  width: 100%,
)[
  #thm-counter.step()
  *Theorem #context thm-counter.display().*
  #body
]

#let proof(body) = block[
  _Proof._ #body #h(1fr) $square$
]

#theorem[
  For all $n in NN$, ...
]

#proof[
  By induction on $n$...
]
```

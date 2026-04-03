---
name: math-typesetting-guide
description: "LaTeX math typesetting, equation formatting, and cross-referencing"
metadata:
  openclaw:
    emoji: "∑"
    category: "writing"
    subcategory: "latex"
    keywords: ["LaTeX math typesetting", "equation formatting", "mathematical notation", "cross-reference"]
    source: "wentor-research-plugins"
---

# Math Typesetting Guide

Comprehensive reference for typesetting mathematical notation, equations, and theorems in LaTeX with correct formatting, numbering, and cross-referencing.

## Essential Packages

```latex
\usepackage{amsmath}    % Core math environments (align, gather, etc.)
\usepackage{amssymb}    % Additional math symbols
\usepackage{amsthm}     % Theorem environments
\usepackage{mathtools}  % Extensions to amsmath (dcases, coloneqq, etc.)
\usepackage{bm}         % Bold math symbols (\bm{x})
\usepackage{bbm}        % Blackboard bold for indicators (\mathbbm{1})
\usepackage{nicefrac}   % Inline fractions (\nicefrac{1}{2})
\usepackage{siunitx}    % SI units (\SI{9.8}{m/s^2})
```

## Inline vs. Display Math

### Inline Math

Use `$...$` or `\(...\)` for math within text:

```latex
The loss function $\mathcal{L}(\theta) = -\sum_{i=1}^{N} \log p(y_i | x_i; \theta)$
minimizes the negative log-likelihood.
```

### Display Math (Unnumbered)

Use `\[...\]` for centered, unnumbered equations:

```latex
\[
  \nabla_\theta \mathcal{L}(\theta) = -\frac{1}{N} \sum_{i=1}^{N}
  \nabla_\theta \log p(y_i | x_i; \theta)
\]
```

### Display Math (Numbered)

Use the `equation` environment for numbered equations:

```latex
\begin{equation}
  E = mc^2
  \label{eq:einstein}
\end{equation}
```

Reference with `\eqref{eq:einstein}` to produce "(1)" with parentheses automatically.

## Multi-Line Equations

### align Environment

Use `align` for multi-line equations with alignment points (`&`):

```latex
\begin{align}
  \mathcal{L}(\theta) &= \mathbb{E}_{(x,y) \sim \mathcal{D}} \left[ \ell(f_\theta(x), y) \right] \label{eq:loss} \\
  &= \frac{1}{N} \sum_{i=1}^{N} \ell(f_\theta(x_i), y_i) \label{eq:empirical-loss} \\
  &\approx \frac{1}{B} \sum_{j=1}^{B} \ell(f_\theta(x_j), y_j) \label{eq:minibatch-loss}
\end{align}
```

Use `align*` for unnumbered multi-line equations. Use `\nonumber` to suppress numbering on specific lines.

### split Environment

Use `split` inside `equation` for a single equation number spanning multiple lines:

```latex
\begin{equation}
\begin{split}
  \text{ELBO}(\theta, \phi; x) &= \mathbb{E}_{q_\phi(z|x)} \left[ \log p_\theta(x|z) \right] \\
  &\quad - D_\text{KL}\left( q_\phi(z|x) \| p(z) \right)
\end{split}
\label{eq:elbo}
\end{equation}
```

### cases Environment

For piecewise functions:

```latex
\begin{equation}
  \text{ReLU}(x) =
  \begin{cases}
    x & \text{if } x > 0 \\
    0 & \text{otherwise}
  \end{cases}
  \label{eq:relu}
\end{equation}
```

## Common Mathematical Notation

### Symbols Reference Table

| Notation | LaTeX | Category |
|----------|-------|----------|
| Real numbers | `\mathbb{R}` | Sets |
| Integers | `\mathbb{Z}` | Sets |
| Natural numbers | `\mathbb{N}` | Sets |
| Expectation | `\mathbb{E}` | Probability |
| Probability | `\mathbb{P}` or `\Pr` | Probability |
| Normal distribution | `\mathcal{N}(\mu, \sigma^2)` | Distributions |
| Partial derivative | `\frac{\partial f}{\partial x}` | Calculus |
| Gradient | `\nabla f` | Calculus |
| Matrix transpose | `\mathbf{A}^\top` | Linear algebra |
| Matrix inverse | `\mathbf{A}^{-1}` | Linear algebra |
| Frobenius norm | `\|\mathbf{A}\|_F` | Linear algebra |
| L2 norm | `\|\mathbf{x}\|_2` | Linear algebra |
| Inner product | `\langle \mathbf{x}, \mathbf{y} \rangle` | Linear algebra |
| Indicator function | `\mathbbm{1}_{[condition]}` | Functions |
| Summation | `\sum_{i=1}^{N}` | Operations |
| Product | `\prod_{i=1}^{N}` | Operations |
| Argmin/argmax | `\operatorname*{argmin}_\theta` | Optimization |
| KL divergence | `D_\text{KL}(p \| q)` | Information theory |

### Custom Operators

Define custom operators for clean notation:

```latex
% In preamble
\DeclareMathOperator*{\argmin}{arg\,min}
\DeclareMathOperator*{\argmax}{arg\,max}
\DeclareMathOperator{\Tr}{Tr}        % Matrix trace
\DeclareMathOperator{\diag}{diag}    % Diagonal matrix
\DeclareMathOperator{\softmax}{softmax}
\DeclareMathOperator{\sigmoid}{\sigma}
\newcommand{\R}{\mathbb{R}}         % Shorthand for real numbers
\newcommand{\E}{\mathbb{E}}         % Shorthand for expectation
\newcommand{\norm}[1]{\left\| #1 \right\|}  % Norm shorthand
\newcommand{\abs}[1]{\left| #1 \right|}     % Absolute value
\newcommand{\inner}[2]{\langle #1, #2 \rangle}  % Inner product
```

## Matrices and Arrays

```latex
% Matrix with parentheses
\begin{equation}
  \mathbf{W} = \begin{pmatrix}
    w_{11} & w_{12} & \cdots & w_{1n} \\
    w_{21} & w_{22} & \cdots & w_{2n} \\
    \vdots & \vdots & \ddots & \vdots \\
    w_{m1} & w_{m2} & \cdots & w_{mn}
  \end{pmatrix}
\end{equation}

% Matrix with square brackets
\begin{equation}
  \mathbf{A} = \begin{bmatrix} 1 & 0 \\ 0 & 1 \end{bmatrix}
\end{equation}
```

## Theorems and Proofs

```latex
% In preamble: define theorem environments
\newtheorem{theorem}{Theorem}[section]
\newtheorem{lemma}[theorem]{Lemma}
\newtheorem{proposition}[theorem]{Proposition}
\newtheorem{corollary}[theorem]{Corollary}
\theoremstyle{definition}
\newtheorem{definition}[theorem]{Definition}
\theoremstyle{remark}
\newtheorem{remark}[theorem]{Remark}

% In document:
\begin{theorem}[Universal Approximation]
\label{thm:universal-approx}
For any continuous function $f: [0,1]^n \to \mathbb{R}$ and any
$\epsilon > 0$, there exists a feedforward neural network $g$ with
one hidden layer such that $\sup_{x \in [0,1]^n} |f(x) - g(x)| < \epsilon$.
\end{theorem}

\begin{proof}
The proof proceeds by construction. Consider a network with
$\sigmoid$ activation functions...

% End proof with QED symbol (automatic with amsthm)
\end{proof}
```

## Cross-Referencing Best Practices

```latex
% Use cleveref for automatic reference formatting
\usepackage[capitalise,noabbrev]{cleveref}

% Then reference with:
\cref{eq:loss}       % -> "Equation 1"
\cref{thm:universal-approx}  % -> "Theorem 1"
\Cref{eq:loss}       % -> "Equation 1" (capital, for start of sentence)
\crefrange{eq:loss}{eq:minibatch-loss}  % -> "Equations 1 to 3"

% Label naming conventions:
% eq:name   for equations
% thm:name  for theorems
% lem:name  for lemmas
% def:name  for definitions
% fig:name  for figures
% tab:name  for tables
% sec:name  for sections
```

## Formatting Tips

- Use `\left(` and `\right)` for auto-sizing delimiters, or explicit sizes: `\big(`, `\Big(`, `\bigg(`, `\Bigg(`
- Use `\text{...}` for words within math mode: `$p(\text{data} | \theta)$`
- Use `\quad` or `\qquad` for spacing in equations
- Use `\phantom{x}` for invisible spacing to align elements
- Avoid `$$...$$` (plain TeX); use `\[...\]` or environments instead
- Number only equations that are referenced in the text

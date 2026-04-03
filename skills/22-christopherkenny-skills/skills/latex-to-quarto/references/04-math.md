# Math

Quarto uses LaTeX math syntax directly. Math **content** (operators, symbols, matrices)
is preserved unchanged — only the **delimiters** and **environment wrappers** need conversion.

---

## Inline Math

| LaTeX | Quarto |
|-------|--------|
| `\(x + y\)` | `$x + y$` |
| `$ x + y $` (already `$...$`) | Keep as-is |

---

## Display Math — No Label

| LaTeX | Quarto |
|-------|--------|
| `\[x + y = z\]` | `$$x + y = z$$` |
| `\begin{equation*}...\end{equation*}` | `$$...$$` |
| `\begin{align*}...\end{align*}` | `$$\begin{aligned}...\end{aligned}$$` |
| `\begin{gather*}...\end{gather*}` | `$$\begin{gathered}...\end{gathered}$$` |
| `\begin{multline*}...\end{multline*}` | `$$\begin{multline}...\end{multline}$$` |
| `\begin{flalign*}...\end{flalign*}` | `$$\begin{aligned}...\end{aligned}$$` |

---

## Display Math — With Label

The `\label{}` command must be **removed from inside the math** and placed as a Quarto
attribute **after** the closing `$$` on the same line:

```latex
\begin{equation}
  E = mc^2
  \label{eq:einstein}
\end{equation}
```

Becomes:

```markdown
$$
E = mc^2
$$ {#eq-einstein}
```

### Labeled Environment Conversions

| LaTeX | Quarto |
|-------|--------|
| `\begin{equation}...\label{eq:x}...\end{equation}` | `$$...$$ {#eq-x}` |
| `\begin{align}...\label{eq:x}...\end{align}` | `$$\begin{aligned}...\end{aligned}$$ {#eq-x}` |
| `\begin{gather}...\label{eq:x}...\end{gather}` | `$$\begin{gathered}...\end{gathered}$$ {#eq-x}` |
| `\begin{multline}...\label{eq:x}...\end{multline}` | `$$\begin{multline}...\end{multline}$$ {#eq-x}` |

**Label prefix conversion**: `eq:x` → `eq-x` (colon replaced by hyphen).
See [06-cross-references.md](06-cross-references.md) for the full prefix mapping.

---

## Multiple Labels in One Align Block (Flag for Review)

In LaTeX, each row of an `align` environment can have its own `\label`:

```latex
\begin{align}
  y &= \alpha + \beta x \label{eq:ols} \\
  y &= \alpha + \beta x + \gamma z \label{eq:iv}
\end{align}
```

Quarto supports only one label per display math block.
Flag for manual review with this suggested split:

```markdown
$$
y = \alpha + \beta x
$$ {#eq-ols}

$$
y = \alpha + \beta x + \gamma z
$$ {#eq-iv}
```

---

## Environments to Keep Inside `$$`

These are standard LaTeX math environments that Quarto/MathJax/KaTeX renders inside `$$`:

| Environment | Notes |
|-------------|-------|
| `cases` | Keep `\begin{cases}...\end{cases}` inside `$$` |
| `matrix`, `pmatrix`, `bmatrix`, `vmatrix`, `Vmatrix` | Keep as-is |
| `array` | Keep as-is |
| `split` | Keep `\begin{split}...\end{split}` inside `$$` |
| `subarray` | Keep as-is |

Example — cases environment (no change needed to content):
```latex
\begin{equation}
  f(x) = \begin{cases} 1 & x > 0 \\ 0 & x \leq 0 \end{cases}
  \label{eq:step}
\end{equation}
```
→
```markdown
$$
f(x) = \begin{cases} 1 & x > 0 \\ 0 & x \leq 0 \end{cases}
$$ {#eq-step}
```

---

## Math Spacing Commands

Remove display-math vertical spacing arguments — they are not valid in Quarto:

| LaTeX | Quarto |
|-------|--------|
| `\\[6pt]` (in align/equation) | `\\` (remove spacing argument; note visual spacing is lost) |
| `\\[1em]` | `\\` |
| `\\[2mm]` | `\\` |

Keep these — they are valid LaTeX math spacing and render in MathJax/KaTeX:

| Command | Keep? |
|---------|-------|
| `\quad`, `\qquad` | Yes |
| `\,`, `\:`, `\;`, `\!` | Yes |
| `\text{...}` | Yes |
| `\hspace{1em}` inside math | Flag — may not render in all engines |

---

## What NOT to Change Inside Math

Never modify inside `$...$` or `$$...$$` (except the specific rules above):

- Greek letters: `\alpha`, `\beta`, `\gamma`, `\Delta`, ...
- Operators: `\frac`, `\sqrt`, `\sum`, `\int`, `\prod`, `\lim`, ...
- Math fonts: `\mathbf`, `\mathcal`, `\mathrm`, `\mathbb`, `\mathit`, ...
- Symbols: `\leq`, `\geq`, `\in`, `\subset`, `\cup`, `\cap`, `\to`, `\Rightarrow`, ...
- Subscripts and superscripts: `_`, `^`
- Accents: `\hat`, `\bar`, `\tilde`, `\dot`, `\vec`, ...
- Decorators: `\overline`, `\underbrace`, `\overbrace`, ...

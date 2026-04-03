# Miscellaneous: Special Characters, Spacing, Code, and Includes

---

## Special Characters

| LaTeX | Quarto | Notes |
|-------|--------|-------|
| `\&` | `&` | Outside math |
| `\%` | `%` | Outside math |
| `\$` | `$` | Outside math (literal dollar sign) |
| `\#` | `#` | Outside math |
| `\_` | `_` | Outside math |
| `\{` | `{` | Outside math |
| `\}` | `}` | Outside math |
| `\textbackslash` | `\` | Literal backslash |
| `\ldots` or `\dots` | `...` | Ellipsis |
| `\textellipsis` | `...` | |
| `---` (em dash) | `---` | Keep as-is (Pandoc converts to em dash) |
| `--` (en dash) | `--` | Keep as-is |
| `\textemdash` | `---` | |
| `\textendash` | `--` | |
| `\copyright` | `©` | Unicode directly |
| `\textregistered` | `®` | |
| `\texttrademark` | `™` | |
| `\S` | `§` | Section symbol |
| `\P` | `¶` | Paragraph symbol |
| `\dag` | `†` | Dagger |
| `\ddag` | `‡` | Double dagger |

---

## Spacing and Page Breaks

| LaTeX | Quarto | Notes |
|-------|--------|-------|
| `\newpage` | `{{< pagebreak >}}` | Quarto shortcode |
| `\clearpage` | `{{< pagebreak >}}` | |
| `\cleardoublepage` | `{{< pagebreak >}}` | |
| `\vspace{1em}` | *(remove)* | No direct equivalent; flag if critical |
| `\vspace*{1em}` | *(remove)* | |
| `\hspace{1em}` | ` ` or `&nbsp;` | Context-dependent; usually remove |
| `\smallskip` | *(remove)* | |
| `\medskip` | *(remove)* | |
| `\bigskip` | *(remove)* | |
| `\noindent` | *(remove)* | |
| `\par` | Blank line | |
| `\linebreak` | Two trailing spaces | Forces line break in paragraph |
| `\\` in prose | Blank line or two trailing spaces | |
| `~` (tie) | ` ` (space) | Non-breaking space; convert to regular space after cross-ref processing |

---

## Verbatim and Code Listings

### `verbatim` Environment

```latex
\begin{verbatim}
x <- 1:10
mean(x)
\end{verbatim}
```

→

````markdown
```
x <- 1:10
mean(x)
```
````

### `lstlisting` Environment

```latex
\begin{lstlisting}[language=R, caption={Mean calculation}, label={lst:mean}]
x <- 1:10
mean(x)
\end{lstlisting}
```

→

````markdown
```{r}
#| label: lst-mean
#| lst-cap: "Mean calculation"
x <- 1:10
mean(x)
```
````

For non-executed code (display only):

````markdown
```r
x <- 1:10
mean(x)
```
````

### `lstlisting` Language Mapping

| LaTeX `language=` | Fenced block language |
|-------------------|----------------------|
| `R` | `r` |
| `Python` | `python` |
| `Matlab` | `matlab` |
| `bash` or `sh` | `bash` |
| `C` | `c` |
| `C++` | `cpp` |
| `Java` | `java` |
| `SQL` | `sql` |
| *(none or unknown)* | *(no language tag)* |

### `minted` Environment

Convert the same way as `lstlisting`: extract the language identifier and code body.

### Inline Verbatim

| LaTeX | Quarto |
|-------|--------|
| `\verb|code|` | `` `code` `` |
| `\verb!code!` | `` `code` `` |
| `\texttt{code}` | `` `code` `` |

---

## `\input` and `\include` (Flag for Review)

Flag each occurrence with the filename and line number.

| LaTeX | Suggested Action |
|-------|-----------------|
| `\input{sections/intro}` | Inline the file contents here, OR replace with `{{< include sections/intro.qmd >}}` |
| `\include{sections/intro}` | Same as `\input` |
| `\input{tables/results}` | If the file is a pure tabular block, inline and convert the table |

When inlining: read the included `.tex` file and apply all the same conversion rules to
its content before inserting it at the `\input` location.

---

## Macro Definitions (Flag for Review)

Flag each `\newcommand` / `\renewcommand` / `\DeclareMathOperator`:

```latex
\newcommand{\E}{\mathbb{E}}
\newcommand{\Var}{\operatorname{Var}}
\DeclareMathOperator*{\argmax}{arg\,max}
```

For each:
1. Note the command name and its expansion
2. Count the occurrences in the document body
3. Inline the expansion at each occurrence

Example:
- `\E[X]` → `\mathbb{E}[X]`
- `\Var(X)` → `\operatorname{Var}(X)`
- `\argmax_x f(x)` → `\operatorname*{arg\,max}_x f(x)`

Report each substitution count so the user can verify completeness.

---

## Comments

LaTeX `%` comments are removed entirely during conversion — they are not part of the
document content and have no Quarto equivalent.

Exception: if a comment appears to be a structural TODO or important annotation
(e.g., `% TODO: update this figure`), flag it in your report so the user can decide
whether to convert it to a Quarto comment `<!-- TODO: update this figure -->`.

---

## Raw LaTeX Blocks (Last Resort)

For patterns that truly have no Quarto equivalent and cannot be restructured,
you may wrap them in a raw LaTeX block for PDF-only rendering:

```markdown
```{=latex}
\begin{somepackageenv}
  ...
\end{somepackageenv}
```
```

Flag these prominently: raw LaTeX blocks will not render in HTML or Word output.
Use this only when flagging for manual review is insufficient and the user needs
something in place.

---

## TikZ / PGF Diagrams (Flag for Review)

TikZ diagrams have no automatic Quarto equivalent. Flag each one:

> **Manual review needed**: TikZ diagram at line N. Options:
> - Replace with a Mermaid diagram (flowcharts, sequence diagrams): ` ```{mermaid} `
> - Replace with an Observable JS visualization for interactive HTML
> - Keep as a raw LaTeX block (`{=latex}`) for PDF-only output
> - Export the TikZ diagram to PDF/PNG and include as a static figure

Do not attempt automatic conversion.

# Tables

Convert LaTeX `tabular`/`table` environments to Quarto pipe table syntax.

---

## Pipe Table Syntax Reference

```markdown
| Col A | Col B | Col C |
|:------|:-----:|------:|
| left  | center | right |
| val   | 2     | 3.14  |

: Table caption here. {#tbl-results}
```

- Column alignment from tabular spec: `l` → `:---`, `c` → `:---:`, `r` → `---:`
- Caption goes **below** the table after `: ` with `{#tbl-label}` at the end
- Blank line required between table body and caption line

---

## Full `table` Environment Conversion

```latex
\begin{table}[h]
  \centering
  \caption{OLS and IV estimates.}
  \label{tab:results}
  \begin{tabular}{lrr}
    \hline
    Method & Estimate & SE \\
    \hline
    OLS & 1.23 & 0.45 \\
    IV  & 1.89 & 0.67 \\
    \hline
  \end{tabular}
\end{table}
```

Becomes:

```markdown
| Method | Estimate |   SE |
|:-------|--------:|-----:|
| OLS    |    1.23 | 0.45 |
| IV     |    1.89 | 0.67 |

: OLS and IV estimates. {#tbl-results}
```

---

## Booktabs Commands

| LaTeX | Action |
|-------|--------|
| `\toprule` | Replace with header separator (handled by pipe table header row) |
| `\midrule` | Remove (pipe table has implicit row separation) |
| `\bottomrule` | Remove |
| `\hline` | Remove (top/bottom), or represent mid-table breaks manually |
| `\cmidrule{2-4}` | Remove — no direct equivalent in pipe tables; flag |
| `\addlinespace` | Remove |

For booktabs tables, the header separator in the pipe table replaces `\toprule`/`\midrule`.
The closing `\bottomrule` is implicit in the pipe table.

---

## `tabular` Column Spec Conversion

| LaTeX spec | Quarto alignment |
|------------|-----------------|
| `l` | `:---` |
| `c` | `:---:` |
| `r` | `---:` |
| `p{3cm}` | `:---` (left-align; note fixed width is lost) |
| `m{3cm}` | `:---:` (center; fixed width lost) |
| `b{3cm}` | `:---` (left-align; fixed width lost) |
| `\|` (vertical rule) | Remove — pipe tables use implicit borders |
| `@{}` (no padding) | Remove |

Example: `{lrrr}` → four columns with alignments `:---`, `---:`, `---:`, `---:`

---

## `table*` (Span Two Columns)

```latex
\begin{table*}
  ...
\end{table*}
```

Convert the table contents normally. Add a note in your report that `table*`
(two-column spanning) is not directly supported in Quarto pipe tables for PDF output;
the user may need `{.column-page}` or a raw LaTeX block.

---

## `\multicolumn` (Flag for Review)

`\multicolumn{2}{c}{Header}` has no pipe table equivalent.
Flag these tables in your report with:

> **Manual review needed**: Table at line N contains `\multicolumn`. Pipe tables do not
> support cell spanning. Convert to a `knitr::kable()` / `gt` code chunk for full control,
> or restructure the table manually.

---

## `\multirow` (Flag for Review)

Similarly, `\multirow{2}{*}{text}` has no pipe table equivalent.
Flag for manual review with the same recommendation.

---

## `longtable` Environment

`longtable` produces multi-page tables in PDF. In Quarto:
- For static content, convert to a regular pipe table (it will paginate automatically in PDF)
- For computed content, use a code chunk with `knitr::kable()` + `longtable = TRUE`

Flag in report: if the table is very long, consider a code chunk.

---

## `tabularx` / `tabulary`

Convert column types:
- `X` (flexible width) → `:---` (left)
- `L`, `C`, `R` (tabulary) → `:---`, `:---:`, `---:`

The flexible-width behavior is lost in pipe tables; note this in your report.

---

## Inline Table Formatting

Inside table cells, apply the same inline formatting rules as prose:

| LaTeX | Quarto |
|-------|--------|
| `\textbf{val}` | `**val**` |
| `\textit{val}` | `*val*` |
| `\texttt{val}` | `` `val` `` |
| `$x^2$` | `$x^2$` |

---

## No-Caption Tables

A table with no `\caption` or `\label`:

```latex
\begin{tabular}{ll}
  A & B \\
  C & D \\
\end{tabular}
```

Becomes a plain pipe table with no caption line:

```markdown
| A | B |
|---|---|
| C | D |
```

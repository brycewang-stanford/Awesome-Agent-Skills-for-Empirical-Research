# Cross-References

Convert `\label{}` and `\ref{}` commands to Quarto's `{#label}` / `@label` syntax.

---

## Label Prefix Mapping

The LaTeX label prefix (before `:`) maps to a Quarto prefix (with `-`):

| LaTeX prefix | Quarto prefix | Example LaTeX label | Example Quarto label |
|--------------|---------------|---------------------|----------------------|
| `fig:` | `fig-` | `\label{fig:map}` | `{#fig-map}` |
| `tab:` or `table:` | `tbl-` | `\label{tab:results}` | `{#tbl-results}` |
| `sec:` or `section:` | `sec-` | `\label{sec:intro}` | `{#sec-intro}` |
| `eq:` or `eqn:` | `eq-` | `\label{eq:ols}` | `{#eq-ols}` |
| `lst:` | `lst-` | `\label{lst:code}` | `{#lst-code}` |
| `thm:` | `thm-` | `\label{thm:main}` | `{#thm-main}` |
| `lem:` | `lem-` | `\label{lem:aux}` | `{#lem-aux}` |
| `prop:` | `prop-` | `\label{prop:1}` | `{#prop-1}` |
| `app:` | `sec-` | `\label{app:data}` | `{#sec-data}` (appendix section) |

**Name cleanup**: Replace underscores with hyphens in the name part.
`fig:my_figure` → `{#fig-my-figure}`

---

## Reference Commands → `@label`

| LaTeX | Quarto | Notes |
|-------|--------|-------|
| `\ref{fig:map}` | `@fig-map` | |
| `\ref{tab:results}` | `@tbl-results` | |
| `\ref{sec:intro}` | `@sec-intro` | |
| `\ref{eq:ols}` | `@eq-ols` | |
| `\autoref{fig:map}` | `@fig-map` | Quarto auto-generates "Figure N" |
| `\autoref{tab:results}` | `@tbl-results` | |
| `\autoref{sec:intro}` | `@sec-intro` | |
| `\eqref{eq:ols}` | `@eq-ols` | |
| `\cref{fig:map}` (cleveref) | `@fig-map` | |
| `\Cref{fig:map}` (cleveref) | `@fig-map` | Quarto capitalizes automatically |
| `\vref{fig:map}` (varioref) | `@fig-map` | Drop page-relative qualifier |
| `\pageref{fig:map}` | Flag for review | No direct Quarto equivalent |

---

## Drop Redundant Type Words

Quarto auto-generates "Figure N", "Table N", "Section N", etc.
Remove the explicit type word before the reference:

| LaTeX | Quarto |
|-------|--------|
| `Figure~\ref{fig:map}` | `@fig-map` |
| `Table~\ref{tab:results}` | `@tbl-results` |
| `Section~\ref{sec:intro}` | `@sec-intro` |
| `Equation~(\ref{eq:ols})` | `@eq-ols` |
| `Eq.~(\ref{eq:ols})` | `@eq-ols` |
| `Appendix~\ref{app:data}` | `@sec-data` |
| `Figure \ref{fig:map} and \ref{fig:plot}` | `@fig-map and @fig-plot` |

---

## Moving `\label` to Quarto Elements

`\label{}` must be moved from a standalone command into the attribute block of the
associated element:

### Figures

```latex
\begin{figure}[h]
  \includegraphics{figs/map.pdf}
  \caption{Study region.}
  \label{fig:map}
\end{figure}
```
→
```markdown
![Study region.](figs/map.pdf){#fig-map}
```

### Tables

```latex
\begin{table}
  \caption{Results.}
  \label{tab:results}
  ...
\end{table}
```
→
```markdown
: Results. {#tbl-results}

| ... |
```
(caption line comes **before** the pipe table body)

### Section Headings

```latex
\section{Introduction}
\label{sec:intro}
```
→
```markdown
# Introduction {#sec-intro}
```

If the `\label` is on a separate line immediately after the heading, merge it into
the heading's attribute block.

### Display Math

```latex
\begin{equation}
  y = \alpha + \beta x
  \label{eq:ols}
\end{equation}
```
→
```markdown
$$
y = \alpha + \beta x
$$ {#eq-ols}
```

---

## Unlabeled References (Bare `\ref`)

If a `\label{}` in the document has no matching `\ref{}`, keep it silently (Quarto
ignores unreferenced labels). If a `\ref{}` has no matching `\label{}`, flag it in
your report with the unresolved key so the user can investigate.

# Figures

---

## `\includegraphics` (Standalone, No `figure` Environment)

| LaTeX | Quarto |
|-------|--------|
| `\includegraphics{figs/plot.pdf}` | `![](figs/plot.pdf)` |
| `\includegraphics[width=0.8\textwidth]{figs/plot.pdf}` | `![](figs/plot.pdf){width=80%}` |
| `\includegraphics[width=5cm]{figs/plot.pdf}` | `![](figs/plot.pdf){width=5cm}` |
| `\includegraphics[height=3in]{figs/plot.pdf}` | `![](figs/plot.pdf){height=3in}` |
| `\includegraphics[scale=0.5]{figs/plot.pdf}` | `![](figs/plot.pdf){width=50%}` |
| `\includegraphics[width=\textwidth]{figs/plot.pdf}` | `![](figs/plot.pdf){width=100%}` |
| `\includegraphics[width=0.5\textwidth]{figs/plot.pdf}` | `![](figs/plot.pdf){width=50%}` |

---

## Full `figure` Environment

```latex
\begin{figure}[h]
  \centering
  \includegraphics[width=0.8\textwidth]{figs/map.pdf}
  \caption{A map of the study region.}
  \label{fig:map}
\end{figure}
```

Becomes:

```markdown
![A map of the study region.](figs/map.pdf){#fig-map width=80% fig-align="center"}
```

### Placement Rules

- `\centering` → `fig-align="center"` attribute
- `\caption{...}` → becomes the alt text / caption between `![` and `](`
- `\label{fig:x}` → becomes `{#fig-x}` in the attribute block
- Positional options (`[h]`, `[t]`, `[b]`, `[H]`, `[!t]`) → remove (no meaning in Quarto)
- `\begin{figure*}` (two-column spanning) → add `fig-env="figure*"` to attribute block

---

## `figure*` (Span Two Columns)

```latex
\begin{figure*}
  \centering
  \includegraphics[width=\textwidth]{figs/wide.pdf}
  \caption{Wide figure spanning both columns.}
  \label{fig:wide}
\end{figure*}
```

Becomes:

```markdown
![Wide figure spanning both columns.](figs/wide.pdf){#fig-wide width=100% fig-align="center" fig-env="figure*"}
```

---

## Subfigures (`subfig` / `subcaption`)

Convert to a Quarto div with `layout-ncol` (or `layout-nrow`):

```latex
\begin{figure}
  \centering
  \begin{subfigure}[b]{0.45\textwidth}
    \includegraphics[width=\textwidth]{figs/a.pdf}
    \caption{First panel.}
    \label{fig:a}
  \end{subfigure}
  \hfill
  \begin{subfigure}[b]{0.45\textwidth}
    \includegraphics[width=\textwidth]{figs/b.pdf}
    \caption{Second panel.}
    \label{fig:b}
  \end{subfigure}
  \caption{Both panels together.}
  \label{fig:both}
\end{figure}
```

Becomes:

```markdown
::: {#fig-both layout-ncol=2}

![First panel.](figs/a.pdf){#fig-a}

![Second panel.](figs/b.pdf){#fig-b}

Both panels together.
:::
```

Key rules for subfigures:
- Outer `\label` → `{#fig-label}` on the div opening
- `layout-ncol=N` where N is the number of columns
- Each `\subfigure` → a separate `![]()` image with its own `{#fig-sub-label}`
- The overall caption goes as plain text **inside** the div, after the last image
- Remove `\hfill`, `\hspace`, `\quad` between subfigures

---

## `wrapfigure` (Wrapped Text)

```latex
\begin{wrapfigure}{r}{0.4\textwidth}
  \includegraphics[width=0.38\textwidth]{figs/side.pdf}
  \caption{Side figure.}
  \label{fig:side}
\end{wrapfigure}
```

Becomes (flag for review — text wrapping is HTML-only):

```markdown
![Side figure.](figs/side.pdf){#fig-side width=38% fig-align="right"}
```

Note in report: text wrapping around figures is not supported in Word output.
Use a standard figure or a column layout instead for multi-format compatibility.

---

## Figures with No Caption or Label

```latex
\begin{figure}[h]
  \centering
  \includegraphics[width=0.6\textwidth]{figs/diagram.png}
\end{figure}
```

Becomes:

```markdown
![](figs/diagram.png){width=60% fig-align="center"}
```

An empty alt text (`![]`) is valid Quarto — the figure will appear without a caption
and without a figure number.

---

## File Extension Notes

- `.pdf` figures render in PDF output and are fine to keep
- `.eps` figures may not render in HTML; flag and suggest converting to `.pdf` or `.png`
- `.png`, `.jpg`, `.svg` render in all formats

---
name: quarto-clean
description: 'Cleans a Quarto (.qmd) file by replacing LaTeX holdovers with proper Quarto/Pandoc syntax so the document renders correctly to HTML, PDF (Typst/LaTeX), and Word. Fixes citations (\citep → [@key]), cross-references (\ref → @label), figures (\includegraphics → markdown), tables, text formatting (\textbf → **bold**), inline math (\( \) → $ $), hyperlinks (\href → [text](url)), footnotes (\footnote → ^[]), list environments, section headings, and R Markdown chunk options (dot-style → #| YAML). Use when asked to clean, fix, modernize, or port a Quarto or R Markdown document; when LaTeX commands appear in a .qmd file; when a document fails to render to Word or Typst; or when citations/cross-references do not appear in non-LaTeX output.'
metadata:
  author: Christopher T. Kenny
  version: 1.1
---

# Quarto Clean

You clean a Quarto (`.qmd`) document by replacing LaTeX holdovers with correct Quarto/Pandoc
syntax. Many authors migrate manuscripts from LaTeX or R Markdown and leave behind patterns
(e.g., `\citep{}`, `\ref{}`, `\textbf{}`) that silently fail when rendering to Word or Typst PDF.
This skill finds and fixes them all in a single pass.

**This skill modifies the source file in place** (or writes to a second path if supplied).
Before writing, tell the user what file will be changed and remind them that `git diff` or
file history can recover the original.

---

## Input Arguments

| Position | Required | Description |
|----------|----------|-------------|
| 1 | **Yes** | Path to the `.qmd` file to clean (e.g., `paper/paper.qmd`). Cleaned in place by default. |
| 2 | No | Output path. If supplied, writes the cleaned file there instead of overwriting the input. |

**Example invocations:**
```
/quarto-clean paper/paper.qmd
/quarto-clean paper/paper.qmd drafts/paper-clean.qmd
```

---

## Step-by-Step Workflow

### 1. Parse Arguments

Identify the input `.qmd` path (arg 1) and output path (arg 2, or same as arg 1 if omitted).

### 2. Read the File

Use the `Read` tool to load the entire file. Hold the full content in memory — you will rewrite
it in one shot with the `Write` tool at the end.

### 3. Apply All Transformations

Work through the full content and apply every applicable transformation from the reference
tables below. Key principles:

- **Preserve protected regions**: Never modify content inside fenced code blocks (` ``` ` or
  `~~~`), inline code (`` ` `` ), display math (`$$...$$`), inline math (`$...$`), or YAML
  front matter (`---` to `---`). Treat these regions as opaque.
- **Handle nesting correctly**: Because you understand the full document structure, handle nested
  commands naturally. `\textbf{something \cite{key}}` → `**something [@key]**`.
  `\footnote{See \cite{key} for details}` → `^[See [@key] for details]`.
- **Apply all categories**: Work through every category in the reference below. A single command
  (`\textbf{\emph{text}}`) may require multiple rules (`***text***`).
- **Be complete**: Scan the entire file. Do not stop after the first occurrence of a pattern —
  fix every instance.

### 4. Write the Cleaned File

Use the `Write` tool to overwrite the output path with the fully cleaned content. Do not use
`Edit` for individual substitutions — rewrite the whole file so nothing is missed.

### 5. Report to the User

Tell the user:
- **Output path** written
- **Summary of fixes** by category (how many of each type were converted)
- **Items requiring manual review** — any patterns you could not safely convert automatically
  (list with approximate line numbers so the user can find them)
- **Reminder** to run `quarto render` to verify

---

## Transformation Reference

Apply every applicable rule. Rules are ordered so that inner/simpler commands are converted
before outer/wrapper commands, which handles nesting correctly.

### Citations

Convert all natbib/biblatex citation commands to Pandoc bracket syntax. These must work in
all output formats (HTML, Word, Typst PDF).

| LaTeX | Quarto | Notes |
|-------|--------|-------|
| `\cite{key}` | `[@key]` | |
| `\citep{key}` | `[@key]` | |
| `\citep{a,b}` | `[@a; @b]` | Split comma-separated keys |
| `\citep[p.~5]{key}` | `[@key, p. 5]` | Locator (suffix only) |
| `\citep[see][p.~5]{key}` | `[see @key, p. 5]` | Prefix + locator |
| `\citet{key}` | `@key` | Narrative / in-text citation |
| `\citet{a,b}` | `@a and @b` | Multiple narrative keys |
| `\citealt{key}` | `@key` | No parentheses |
| `\citeauthor{key}` | `@key` | Loses "author-only" semantics; flag in report |
| `\citeyear{key}` | `[-@key]` | Year only; suppresses author |
| `\nocite{key}` | Move to YAML `nocite: '@key'` | Remove from body; add to front matter |
| `\nocite{*}` | Move to YAML `nocite: '@*'` | |

### Cross-References

Convert `\label` and `\ref` commands. The label prefix maps directly:

| LaTeX prefix | Quarto prefix | Example LaTeX | Example Quarto |
|--------------|--------------|---------------|----------------|
| `fig:` | `fig-` | `\label{fig:map}` → `{#fig-map}` | `\ref{fig:map}` → `@fig-map` |
| `tab:` or `table:` | `tbl-` | `\label{tab:results}` | `@tbl-results` |
| `sec:` or `section:` | `sec-` | `\label{sec:intro}` | `@sec-intro` |
| `eq:` or `eqn:` | `eq-` | `\label{eq:ols}` | `@eq-ols` |
| `lst:` | `lst-` | | |
| `thm:`, `lem:`, `prop:`, etc. | same with `-` | | |

Rules:
- `\ref{type:name}` → `@type-name` (replace `:` with `-`, map prefix per table)
- `\autoref{type:name}` → `@type-name`
- `\eqref{eq:name}` → `@eq-name`
- **Drop redundant type words**: `Figure \ref{fig:x}` → `@fig-x` (Quarto auto-generates
  "Figure N"). Same for "Table", "Section", "Equation", "Appendix".
- `\label{type:name}` must be moved to the appropriate Quarto element as `{#type-name}`:
  - On a figure: `![Caption](file){#fig-name}`
  - On a table caption: `: Caption {#tbl-name}`
  - On a heading: `## Title {#sec-name}`
  - On display math: `$$...$$ {#eq-name}` (on the line after `$$`)
- Replace underscores with hyphens in the name part: `fig:my_fig` → `{#fig-my-fig}`

### R Markdown Chunk Options

Convert old-style inline chunk options to `#|` YAML comments. The fence header becomes bare
(language only), and each option becomes a `#|` line inside the chunk.

**Before:**
```
```{r my-label, echo=FALSE, fig.cap="My figure", fig.width=6, out.width="80%"}
```

**After:**
```
```{r}
#| label: my-label
#| echo: false
#| fig-cap: "My figure"
#| fig-width: 6
#| out-width: "80%"
```

Option name mapping (dots → dashes, booleans → lowercase):

| Old | New |
|-----|-----|
| `fig.cap` | `fig-cap` |
| `fig.width` | `fig-width` |
| `fig.height` | `fig-height` |
| `fig.align` | `fig-align` |
| `fig.alt` | `fig-alt` |
| `fig.subcap` | `fig-subcap` |
| `fig.pos` | `fig-pos` |
| `fig.env` | `fig-env` |
| `out.width` | `out-width` |
| `out.height` | `out-height` |
| `echo=FALSE` | `echo: false` |
| `eval=FALSE` | `eval: false` |
| `warning=FALSE` | `warning: false` |
| `message=FALSE` | `message: false` |
| `include=FALSE` | `include: false` |
| `cache=TRUE` | `cache: true` |
| `results='hide'` | `output: false` |
| `results='asis'` | `output: asis` |
| `tidy=TRUE` | *(remove — deprecated)* |

The first unnamed token in the old header is the label: `{r my-label, echo=FALSE}` → `#| label: my-label`.

### Figures

| LaTeX | Quarto |
|-------|--------|
| `\includegraphics{file}` | `![](file)` |
| `\includegraphics[width=0.8\textwidth]{file}` | `![](file){width=80%}` |
| `\includegraphics[width=5cm]{file}` | `![](file){width=5cm}` |
| `\centering` inside figure env | `fig-align="center"` attribute on the figure |

**Full figure environment:**
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

- `\begin{figure*}` → add `fig-env="figure*"` to the attribute block
- For computational figures in code chunks, use `#| fig-cap:` and `#| label: fig-...`

### Tables

**Markdown / pipe tables:**
```markdown
| Col A | Col B |
|:------|------:|
| val   | 1.23  |

: My table caption. {#tbl-results}
```

- Column alignment from tabular spec: `l` → `:---`, `r` → `---:`, `c` → `:---:`
- Caption goes *below* the table, after `: `, with `{#tbl-label}` at the end
- For computational tables (knitr/kable output), add chunk options instead:
  ```
  #| label: tbl-results
  #| tbl-cap: "My table caption."
  ```

**LaTeX table environment → Quarto pipe table:**
```latex
\begin{table}
  \caption{My table caption.}
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

: My table caption. {#tbl-results}
```

### Text Formatting

Handle nesting: `\textbf{\emph{text}}` → `***text***`.

| LaTeX | Quarto |
|-------|--------|
| `\textbf{text}` | `**text**` |
| `\textit{text}` | `*text*` |
| `\emph{text}` | `*text*` |
| `\texttt{text}` | `` `text` `` |
| `\underline{text}` | `[text]{.underline}` |
| `\textsc{text}` | `[text]{.smallcaps}` |
| `\textsuperscript{x}` | `^x^` |
| `\textsubscript{x}` | `~x~` |
| `\sout{text}` | `~~text~~` |
| `\footnote{text}` | `^[text]` |

### Math

| LaTeX | Quarto |
|-------|--------|
| `\(x + y\)` | `$x + y$` |
| `\[x + y\]` | `$$x + y$$` |
| `\begin{equation}` / `\end{equation}` | `$$` / `$$` with `{#eq-name}` after closing `$$` |
| `\begin{align}` / `\end{align}` | `$$\begin{aligned}` / `\end{aligned}$$` |
| `\label{eq:name}` inside math | Remove from math body; add `{#eq-name}` after closing `$$` |

### Hyperlinks

| LaTeX | Quarto |
|-------|--------|
| `\url{https://...}` | `<https://...>` |
| `\href{url}{text}` | `[text](url)` |

### Special Characters and Spacing

| LaTeX | Quarto | Notes |
|-------|--------|-------|
| `\&` | `&` | Outside math |
| `\%` | `%` | Outside math |
| `\ldots` or `\dots` | `...` | |
| `\footnote{text}` | `^[text]` | (also in Text Formatting above) |
| `\noindent` | *(remove)* | |
| `\par` | blank line | |
| `\newline` or `\\` | blank line or two trailing spaces | Paragraph break in prose |
| `\newpage` or `\clearpage` | `{{< pagebreak >}}` | |
| `~` (tie space) | ` ` or `&nbsp;` | Context-dependent |

### Section Headings

| LaTeX | Quarto |
|-------|--------|
| `\section{Title}` | `# Title` |
| `\subsection{Title}` | `## Title` |
| `\subsubsection{Title}` | `### Title` |
| `\paragraph{Title}` | `#### Title` |
| `\section*{Title}` | `# Title {.unnumbered}` |
| `\section{Title}\label{sec:x}` | `# Title {#sec-x}` |

If a `\label{sec:x}` appears on the line following a heading, merge it into the heading's
attribute block: `## Methods {#sec-methods}`.

### List Environments

| LaTeX | Quarto |
|-------|--------|
| `\begin{itemize}` / `\item` | Unordered list with `-` |
| `\begin{enumerate}` / `\item` | Ordered list with `1.` |
| `\begin{description}` / `\item[Term]` | `: Term\n:   definition` |

Nested lists: indent continuation lines by two spaces per level.

### Abstract and Front Matter

Move these from the document body to YAML:

```latex
\begin{abstract}
  We study the effect of X on Y...
\end{abstract}
```
→ YAML field:
```yaml
abstract: |
  We study the effect of X on Y...
```

Similarly for `\title{}`, `\author{}`, `\date{}` appearing in the body — move to YAML
`title:`, `author:`, `date:` fields.

---

## Patterns That Need Judgment

Flag these in your report if you encounter them, with a suggested fix but no automatic
conversion (the content depends too much on context):

- **Custom LaTeX environments** (`\begin{theorem}`, `\begin{proof}`, `\begin{lemma}`,
  `\begin{frame}`, etc.) → suggest converting to `::: {.callout-note}` or a theorem div
- **`\vspace{}` / `\hspace{}`** → no direct Quarto equivalent; suggest removing or using CSS
- **`\multicolumn{}{}{}` in tables** → requires restructuring the table manually
- **`\citeauthor{key}`** → converted to `@key` but the "author only" rendering is lost;
  suggest rephrasing (e.g., "Smith [-@smith2020]")
- **`cite-method: natbib` or `cite-method: biblatex` in YAML** → should likely be removed
  for non-LaTeX output formats; flag for user decision
- **`\\[6pt]` or `\\[1em]`** (spacing in math display) → the spacing argument is not valid
  in Quarto; convert to `\\` and note the spacing is lost

---

## What to Preserve Unchanged

- All content inside ` ```...``` ` fenced code blocks (including chunk body code)
- All content inside `` `...` `` inline code
- All content inside `$...$` inline math and `$$...$$` display math (except `\label{}` which
  must be moved outside, and `\( \)` / `\[ \]` delimiters which must be converted)
- YAML front matter between `---` delimiters
- Quarto shortcodes `{{< ... >}}`
- Existing `@ref` cross-references and `[@citation]` citations that are already correct
- Pandoc div/span syntax `:::` and `[]{}` that is already valid Quarto

# Section Headings and Lists

---

## Section Headings

| LaTeX | Quarto |
|-------|--------|
| `\section{Title}` | `# Title` |
| `\subsection{Title}` | `## Title` |
| `\subsubsection{Title}` | `### Title` |
| `\paragraph{Title}` | `#### Title` |
| `\subparagraph{Title}` | `##### Title` |
| `\section*{Title}` | `# Title {.unnumbered}` |
| `\subsection*{Title}` | `## Title {.unnumbered}` |
| `\subsubsection*{Title}` | `### Title {.unnumbered}` |
| `\section{Title}\label{sec:x}` | `# Title {#sec-x}` |
| `\section*{Title}\label{sec:x}` | `# Title {.unnumbered #sec-x}` |

### Merging Labels into Headings

If a `\label{sec:x}` appears on the line immediately after a heading, merge it into the
heading's attribute block:

```latex
\section{Introduction}
\label{sec:intro}
```
→
```markdown
# Introduction {#sec-intro}
```

If both `*` (unnumbered) and a label are present:

```latex
\section*{Appendix A}
\label{app:a}
```
→
```markdown
# Appendix A {.unnumbered #sec-a}
```

---

## Itemize (Unordered Lists)

```latex
\begin{itemize}
  \item First item
  \item Second item with \textbf{bold}
  \item Third item
\end{itemize}
```

→

```markdown
- First item
- Second item with **bold**
- Third item
```

---

## Enumerate (Ordered Lists)

```latex
\begin{enumerate}
  \item First step
  \item Second step
  \item Third step
\end{enumerate}
```

→

```markdown
1. First step
2. Second step
3. Third step
```

---

## Description Lists

```latex
\begin{description}
  \item[OLS] Ordinary least squares estimator
  \item[IV] Instrumental variables estimator
\end{description}
```

→

```markdown
OLS
:   Ordinary least squares estimator

IV
:   Instrumental variables estimator
```

---

## Nested Lists

Indent continuation lines by four spaces per level:

```latex
\begin{itemize}
  \item Top level
  \begin{itemize}
    \item Nested item
    \item Another nested
  \end{itemize}
  \item Back to top
\end{itemize}
```

→

```markdown
- Top level
    - Nested item
    - Another nested
- Back to top
```

Mixed nesting (ordered inside unordered):

```latex
\begin{itemize}
  \item Category A
  \begin{enumerate}
    \item First in A
    \item Second in A
  \end{enumerate}
\end{itemize}
```

→

```markdown
- Category A
    1. First in A
    2. Second in A
```

---

## Items with Multiple Paragraphs

```latex
\begin{itemize}
  \item First paragraph of item.

  Second paragraph of same item.
  \item Next item.
\end{itemize}
```

→

```markdown
- First paragraph of item.

  Second paragraph of same item.

- Next item.
```

(Continuation paragraphs within an item are indented by two spaces.)

---

## Custom Enumerate Labels (`enumitem`)

If `enumitem` is used with custom labels (e.g., `[label=(\alph*)]`), convert to
standard numbered lists and note the loss of custom labeling:

```latex
\begin{enumerate}[label=(\alph*)]
  \item First
  \item Second
\end{enumerate}
```

→ (flag in report: custom labels lost)

```markdown
a. First
b. Second
```

Or use standard `1.` if alphabetic labeling isn't critical.

---

## `\item[custom]` in Itemize

An `\item[*]` or `\item[-]` in an `itemize` environment uses a custom bullet:

```latex
\begin{itemize}
  \item[--] Dashed item
  \item[$\bullet$] Bulleted item
\end{itemize}
```

→ Convert to standard `-` items and flag the custom bullets in your report.

---

## Block Quotes (`quote` / `quotation`)

| LaTeX | Quarto |
|-------|--------|
| `\begin{quote}...\end{quote}` | `> text` (block quote) |
| `\begin{quotation}...\end{quotation}` | `> text` (block quote) |

```latex
\begin{quote}
The quick brown fox.
\end{quote}
```

→

```markdown
> The quick brown fox.
```

# Text Formatting

---

## Basic Inline Formatting

Handle nesting: process inner commands before outer wrappers.
`\textbf{\emph{text}}` → `***text***`

| LaTeX | Quarto |
|-------|--------|
| `\textbf{text}` | `**text**` |
| `\textit{text}` | `*text*` |
| `\emph{text}` | `*text*` |
| `\texttt{text}` | `` `text` `` |
| `\textrm{text}` | `text` (remove wrapper — markdown default is roman) |
| `\textsl{text}` | `*text*` (slanted ≈ italic) |
| `\underline{text}` | `[text]{.underline}` |
| `\textsc{text}` | `[text]{.smallcaps}` |
| `\textsuperscript{x}` | `^x^` |
| `\textsubscript{x}` | `~x~` |
| `\sout{text}` (ulem) | `~~text~~` |
| `\textbf{\emph{text}}` | `***text***` |
| `\emph{\textbf{text}}` | `***text***` |

### Old LaTeX2e Font Commands

| LaTeX | Quarto |
|-------|--------|
| `{\bf text}` | `**text**` |
| `{\it text}` | `*text*` |
| `{\tt text}` | `` `text` `` |
| `{\em text}` | `*text*` |
| `{\sc text}` | `[text]{.smallcaps}` |
| `{\rm text}` | `text` (remove) |

---

## Footnotes

| LaTeX | Quarto |
|-------|--------|
| `\footnote{text}` | `^[text]` |
| `\footnote{See \cite{key} for details.}` | `^[See [@key] for details.]` |
| `\footnote{Values are \textbf{not} adjusted.}` | `^[Values are **not** adjusted.]` |
| `\footnotemark` + `\footnotetext{text}` | Flag for manual review — convert if the pairing is unambiguous |

Footnotes may contain inline formatting and citations; apply those rules inside the `^[...]`.

---

## Hyperlinks and URLs

| LaTeX | Quarto |
|-------|--------|
| `\url{https://example.com}` | `<https://example.com>` |
| `\href{https://example.com}{link text}` | `[link text](https://example.com)` |
| `\href{mailto:foo@bar.com}{email}` | `[email](mailto:foo@bar.com)` |
| `\href{#sec-intro}{see Section}` | `[see Section](#sec-intro)` (internal link) |

---

## Font Size Commands (Remove)

Font size commands adjust visual presentation but carry no semantic meaning in prose.
Remove the size wrapper and keep the text content.

| LaTeX | Action |
|-------|--------|
| `{\tiny text}` | `text` |
| `{\scriptsize text}` | `text` |
| `{\footnotesize text}` | `text` |
| `{\small text}` | `text` |
| `{\normalsize text}` | `text` |
| `{\large text}` | `text` |
| `{\Large text}` | `text` |
| `{\LARGE text}` | `text` |
| `{\huge text}` | `text` (flag if used for a section title effect) |
| `{\Huge text}` | `text` |

---

## Color (Flag for Review)

`\textcolor{red}{text}` → `[text]{style="color:red"}` (HTML only).
Flag in report: this will not render color in PDF without additional configuration.

Common colors: `red`, `blue`, `green`, `gray`, `orange`.

---

## Quoted Text

| LaTeX | Quarto |
|-------|--------|
| `` `word' `` (single LaTeX quotes) | `'word'` |
| ` ``word'' ` (double LaTeX quotes) | `"word"` |
| `\enquote{text}` (csquotes) | `"text"` |
| `\textquoteleft` / `\textquoteright` | `'` / `'` |
| `\textquotedblleft` / `\textquotedblright` | `"` / `"` |

---

## Spacing and Line Breaks in Prose

| LaTeX | Quarto |
|-------|--------|
| `~` (non-breaking space, e.g., `Figure~\ref{}`) | ` ` or `&nbsp;` depending on context; typically just a regular space after cross-ref conversion |
| `\,` (thin space in prose) | Remove (not meaningful in markdown) |
| `\ ` (forced space after command) | ` ` (regular space) |
| `\\` or `\newline` (line break in prose) | Two trailing spaces or a blank line (paragraph break) |
| `\noindent` | Remove |
| `\par` | Blank line |

---

## Emphasis Nesting Note

When `\emph{}` appears inside already-italic text, LaTeX toggles back to upright.
In Quarto markdown, `*...*` within `*...*` does not toggle — it creates broken markup.
Flag these cases for manual review.

Example: `\emph{This is \emph{important} here}` → `*This is* important *here*`
(the inner word reverts to upright in LaTeX; replicate manually).

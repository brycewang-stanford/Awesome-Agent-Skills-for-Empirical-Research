# Document Structure

---

## Wrapper Commands (Remove)

Remove these structural LaTeX commands — they have no Quarto equivalent in the body:

| LaTeX | Action |
|-------|--------|
| `\begin{document}` | Remove |
| `\end{document}` | Remove |
| `\maketitle` | Remove (title rendered from YAML automatically) |
| `\tableofcontents` | Remove from body; add `toc: true` under the relevant format in YAML |
| `\listoffigures` | Remove (no direct equivalent; flag if needed) |
| `\listoftables` | Remove (no direct equivalent; flag if needed) |

---

## Abstract

Move `\begin{abstract}...\end{abstract}` to YAML (see [01-preamble-yaml.md](01-preamble-yaml.md)):

```latex
\begin{abstract}
  We study the effect of X on Y using panel data from 1990–2020.
  Our results show a significant positive relationship.
\end{abstract}
```

→ Remove from body; add to YAML front matter:

```yaml
abstract: |
  We study the effect of X on Y using panel data from 1990–2020.
  Our results show a significant positive relationship.
```

If there is a `\section*{Abstract}` heading followed by body text (no environment), move
the text to YAML the same way and remove the heading.

---

## Keywords

| LaTeX | Quarto YAML |
|-------|-------------|
| `\keywords{key1, key2, key3}` | `keywords: [key1, key2, key3]` |
| `\begin{keywords}...\end{keywords}` | `keywords: [...]` (move to YAML) |

---

## Appendices

| LaTeX | Quarto |
|-------|--------|
| `\appendix` (standalone command) | Remove the command; mark the first appendix section (see below) |
| `\section{Data}` (after `\appendix`) | `# Data {.appendix}` |
| `\section*{Data}` (after `\appendix`) | `# Data {.appendix .unnumbered}` |

The `{.appendix}` attribute on the first post-appendix heading triggers Quarto's appendix
numbering (A, B, C...). All subsequent headings at the same level in the appendix region
are automatically included.

```latex
% LaTeX
\appendix
\section{Additional Tables}
\section{Proofs}
```

```markdown
<!-- Quarto -->
# Additional Tables {.appendix}

# Proofs
```

---

## Acknowledgements

| LaTeX | Quarto |
|-------|--------|
| `\section*{Acknowledgements}` + body text | Keep as `# Acknowledgements {.unnumbered}` in body |
| `\thanks{...}` inside `\author{}` | Move content to `acknowledgements:` YAML field or a body footnote `^[...]` |
| `\thanks{...}` inside `\title{}` | Move to a footnote on the title or `acknowledgements:` YAML field |

---

## Theorem-Like Environments (Flag for Review)

These require manual review — there is no single automatic conversion:

| LaTeX | Suggested Quarto |
|-------|------------------|
| `\begin{theorem}...\end{theorem}` | `::: {.callout-note}\n**Theorem.** ...\n:::` |
| `\begin{proof}...\end{proof}` | `::: {.callout-tip}\n**Proof.** ... $\square$\n:::` |
| `\begin{lemma}...\end{lemma}` | `::: {.callout-note}\n**Lemma.** ...\n:::` |
| `\begin{corollary}...\end{corollary}` | `::: {.callout-note}\n**Corollary.** ...\n:::` |
| `\begin{remark}...\end{remark}` | `::: {.callout-tip}\n**Remark.** ...\n:::` |
| `\begin{definition}...\end{definition}` | `::: {.callout-note}\n**Definition.** ...\n:::` |
| `\begin{example}...\end{example}` | `::: {.callout-note}\n**Example.** ...\n:::` |
| `\begin{assumption}...\end{assumption}` | `::: {.callout-caution}\n**Assumption.** ...\n:::` |
| `\begin{proposition}...\end{proposition}` | `::: {.callout-note}\n**Proposition.** ...\n:::` |

For numbered theorems (e.g., "Theorem 2"), consider the
[`theorems` Quarto extension](https://github.com/quarto-ext/theorem-callouts) or
leave as a callout div with a manually added number.

### Callout Syntax Reference

```markdown
::: {.callout-note}
**Theorem 1.** For all $x > 0$, we have $f(x) > 0$.
:::

::: {.callout-tip}
**Proof.** By definition of $f$... $\square$
:::
```

Available callout types: `note`, `warning`, `important`, `tip`, `caution`.

---

## Multi-Part and Include Files (Flag for Review)

| LaTeX | Suggested Quarto |
|-------|------------------|
| `\input{sections/intro}` | Inline the file contents directly, OR use `{{< include sections/intro.qmd >}}` |
| `\include{sections/intro}` | Same as `\input` — inline or use `{{< include >}}` |

When inlining, convert the included file using the same rules as the main document.
When using `{{< include >}}`, note that the included file must be `.qmd`, not `.tex`.

Flag each `\input`/`\include` occurrence with the filename so the user can decide.

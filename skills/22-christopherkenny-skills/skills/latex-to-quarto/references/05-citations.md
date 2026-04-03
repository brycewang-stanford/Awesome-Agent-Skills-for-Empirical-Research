# Citations

Convert all natbib and biblatex citation commands to Pandoc bracket syntax.
Pandoc citations work in all Quarto output formats (HTML, Word, Typst PDF, LaTeX PDF).

The `.bib` file is referenced in YAML and left **unchanged**.

---

## natbib Commands

| LaTeX | Quarto | Notes |
|-------|--------|-------|
| `\cite{key}` | `[@key]` | |
| `\citep{key}` | `[@key]` | Parenthetical |
| `\citep{a,b}` | `[@a; @b]` | Split comma-separated keys |
| `\citep[p.~5]{key}` | `[@key, p. 5]` | Suffix/locator only |
| `\citep[see][p.~5]{key}` | `[see @key, p. 5]` | Prefix + locator |
| `\citep[see][]{key}` | `[see @key]` | Prefix only |
| `\citet{key}` | `@key` | Narrative (in-text) citation |
| `\citet{a,b}` | `@a and @b` | Multiple narrative — join with "and" |
| `\citealt{key}` | `@key` | No parentheses (like `\citet` without parens) |
| `\citealt[p.~3]{key}` | `@key [p. 3]` | No parentheses with locator |
| `\citealp{key}` | `@key` | Like `\citep` without parentheses |
| `\citeauthor{key}` | `@key` | Author name only — loses "author-only" semantics; flag in report |
| `\citeyear{key}` | `[-@key]` | Year only; `-` suppresses author |
| `\citeyearpar{key}` | `[-@key]` | Year in parentheses |
| `\nocite{key}` | Move to YAML `nocite: '@key'` | Remove from body |
| `\nocite{*}` | Move to YAML `nocite: '@*'` | All bibliography entries |

### Multiple Keys in One Command

| LaTeX | Quarto |
|-------|--------|
| `\citep{a,b,c}` | `[@a; @b; @c]` |
| `\citet{a,b}` | `@a and @b` |
| `\cite{a,b,c}` | `[@a; @b; @c]` |

### Locators: Tilde and Spacing

Remove LaTeX non-breaking spaces and spacing commands in locators:

| LaTeX locator | Quarto locator |
|---------------|---------------|
| `p.~5` | `p. 5` |
| `pp.~5--8` | `pp. 5–8` |
| `chap.~2` | `chap. 2` |
| `fig.~3` | `fig. 3` |

---

## biblatex Commands

| LaTeX | Quarto | Notes |
|-------|--------|-------|
| `\cite{key}` | `[@key]` | |
| `\parencite{key}` | `[@key]` | Parenthetical |
| `\parencite[p.~5]{key}` | `[@key, p. 5]` | With locator |
| `\parencite[see][p.~5]{key}` | `[see @key, p. 5]` | Prefix + locator |
| `\textcite{key}` | `@key` | Narrative (in-text) |
| `\textcite{a,b}` | `@a and @b` | Multiple narrative |
| `\autocite{key}` | `[@key]` | Context-dependent; default to parenthetical |
| `\footcite{key}` | `^[[@key]]` | Footnote citation |
| `\citeauthor{key}` | `@key` | Flag: loses author-only semantics |
| `\citeyear{key}` | `[-@key]` | Year only |
| `\citetitle{key}` | Flag for review | No direct equivalent |
| `\citeurl{key}` | Flag for review | No direct equivalent |

---

## YAML Changes for Bibliography

Remove `\bibliography{}` from the document body (it goes to YAML).
Remove `\bibliographystyle{}` entirely.
Remove `\printbibliography` from the document body (Quarto renders it automatically).

Add to YAML front matter:

```yaml
bibliography: refs.bib
```

Quarto will render the bibliography at the end of the document automatically.
To control placement, add `# References` as a heading where you want it.
To use a specific citation style, add:

```yaml
csl: apa.csl
```

CSL files are available at https://www.zotero.org/styles

---

## cite-method Warning

If the original document's YAML has `cite-method: natbib` or `cite-method: biblatex`,
flag it in your report:

> **Manual review needed**: `cite-method: natbib` in YAML forces LaTeX-only citation
> rendering. Remove this line so Pandoc handles citations in all output formats.

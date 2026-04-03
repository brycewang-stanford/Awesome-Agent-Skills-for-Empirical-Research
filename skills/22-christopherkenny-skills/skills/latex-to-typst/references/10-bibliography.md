# Bibliography and Citations

## Setup

```tex
% LaTeX (biblatex)
\usepackage[style=authoryear, backend=biber]{biblatex}
\addbibresource{refs.bib}
...
\printbibliography

% LaTeX (natbib)
\usepackage{natbib}
\bibliographystyle{plainnat}
\bibliography{refs.bib}
```

```typst
// Typst — one line at the end of document
#bibliography("refs.bib")

// With custom style
#bibliography("refs.bib", style: "apa")
#bibliography("refs.bib", style: "ieee")
#bibliography("refs.bib", style: "chicago-author-date")
#bibliography("refs.bib", style: "mla")

// Multiple bib files
#bibliography(("refs.bib", "extra.bib"))

// Custom title
#bibliography("refs.bib", title: "References")
#bibliography("refs.bib", title: none)   // suppress heading
```

## Citation Commands

### Basic Citations

| LaTeX | Typst | Output style |
|-------|-------|-------------|
| `\cite{key}` | `@key` | [1] or (Smith 2020) |
| `\citep{key}` *(natbib)* | `@key` | (Smith, 2020) |
| `\citet{key}` *(natbib)* | `@key` | Smith (2020) |
| `\citeauthor{key}` | `#cite(<key>, form: "prose")` | Smith |
| `\citeyear{key}` | *(not directly supported)* | 2020 |
| `\cite[p.~10]{key}` | `@key[p.~10]` | [1, p. 10] |
| `\cite[see][p.~5]{key}` | `#cite(<key>, supplement: [see p.~5])` | — |
| `\nocite{*}` | `#bibliography(..., full: true)` | include all entries |

### In-text Citation Examples

```tex
% LaTeX
As shown in \cite{smith2020}...
\citep{jones2019} argues that...
See also \cite[Chapter~3]{brown2021}.
Multiple citations: \cite{a,b,c}.
```

```typst
// Typst
As shown in @smith2020...
@jones2019 argues that...
See also @brown2021[Chapter 3].
Multiple citations: @a @b @c.
```

### Citation Form

```typst
// Default (bracket/superscript depending on style)
@smith2020

// Prose form (author-year in text)
#cite(<smith2020>, form: "prose")

// Full form
#cite(<smith2020>, form: "full")

// Suppress author (show year only)
#cite(<smith2020>, form: "year")

// Custom supplement
#cite(<smith2020>, supplement: [p.~42])
```

## Citation Styles

Typst uses Citation Style Language (CSL). Built-in styles include:

| Style | Typst name |
|-------|-----------|
| APA | `"apa"` |
| Chicago (author-date) | `"chicago-author-date"` |
| Chicago (notes) | `"chicago-notes"` |
| IEEE | `"ieee"` |
| MLA | `"mla"` |
| Harvard | `"harvard-cite-them-right"` |
| Nature | `"nature"` |
| Vancouver | `"vancouver"` |
| ACS | `"american-chemical-society"` |

> For a custom CSL file: `#bibliography("refs.bib", style: "my-style.csl")`

## BibTeX Format

Typst accepts standard `.bib` files (BibLaTeX format). Example:

```bibtex
@article{smith2020,
  author  = {Smith, John and Doe, Jane},
  title   = {A Study of Things},
  journal = {Journal of Studies},
  year    = {2020},
  volume  = {42},
  number  = {3},
  pages   = {100--120},
  doi     = {10.1000/xyz123},
}

@book{jones2019,
  author    = {Jones, Alice},
  title     = {Book of Knowledge},
  year      = {2019},
  publisher = {Academic Press},
  address   = {New York},
}

@inproceedings{brown2021,
  author    = {Brown, Bob},
  title     = {Conference Paper},
  booktitle = {Proceedings of the Conference},
  year      = {2021},
  pages     = {55--60},
}
```

Typst also natively supports Hayagriva `.yaml` format:

```yaml
smith2020:
  type: article
  author: ["Smith, John", "Doe, Jane"]
  title: A Study of Things
  journal: Journal of Studies
  date: 2020
  volume: 42
  issue: 3
  page-range: 100-120
  doi: 10.1000/xyz123
```

## Bibliography Formatting

```typst
// Show bibliography in smaller text
#show bibliography: set text(size: 9pt)

// Custom bibliography title style
#show bibliography: it => [
  #v(1em)
  #align(center)[#text(weight: "bold", size: 12pt)[References]]
  #v(0.5em)
  #it.body
]
```

## Natbib-Style Citations

For author-year style matching `\citet` and `\citep`:

```typst
// Set APA or Chicago author-date
#set bibliography(style: "apa")

// Then @key produces (Smith, 2020) in parentheses
// @key for prose-like citation
```

## Cross-referencing Footnote Citations

```tex
% LaTeX (footnote citations)
Text.\footnote{\cite{key}}
```

```typst
// Typst
Text.#footnote[@key]
```

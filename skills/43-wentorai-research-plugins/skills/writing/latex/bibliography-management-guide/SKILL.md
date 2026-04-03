---
name: bibliography-management-guide
description: "Manage references with BibLaTeX, natbib, and LaTeX bibliography styles"
metadata:
  openclaw:
    emoji: "📑"
    category: "writing"
    subcategory: "latex"
    keywords: ["BibLaTeX", "natbib", "bibliography", "BibTeX", "citation styles", "reference management"]
    source: "wentor-research-plugins"
---

# Bibliography Management Guide

A skill for managing references in LaTeX using BibLaTeX, natbib, and traditional BibTeX. Covers bibliography database setup, citation commands, style selection, and troubleshooting common bibliography compilation issues.

## Choosing a Bibliography System

### BibLaTeX vs. natbib vs. Traditional BibTeX

| Feature | BibLaTeX + Biber | natbib + BibTeX | Traditional BibTeX |
|---------|-----------------|----------------|-------------------|
| Backend | Biber | BibTeX | BibTeX |
| Unicode support | Full | Limited | Limited |
| Citation styles | Highly customizable | Style-dependent | .bst files |
| Multi-bibliography | Built-in | Requires hacks | Difficult |
| Date handling | Advanced (circa, ranges) | Basic | Basic |
| Recommended for | New projects | Legacy journals | Minimal setups |

## BibLaTeX Setup

### Basic Configuration

```latex
\documentclass{article}
\usepackage[
    backend=biber,
    style=authoryear,       % or numeric, apa, ieee, chem-acs, etc.
    sorting=nyt,            % name, year, title
    maxcitenames=2,         % "Author et al." after 2 names
    giveninits=true         % First name initials
]{biblatex}

\addbibresource{references.bib}

\begin{document}
Some claim \parencite{smith2024}.
\textcite{jones2023} disagrees.

\printbibliography
\end{document}
```

### Common BibLaTeX Citation Commands

```latex
\parencite{key}       % (Author, 2024)
\textcite{key}        % Author (2024)
\autocite{key}        % Context-dependent (adapts to style)
\cite{key}            % Basic cite (style-dependent)
\footcite{key}        % Citation in footnote
\cites{k1}{k2}       % Multiple sources: (Author1; Author2)
\parencite[p.~42]{key}  % With page number: (Author, 2024, p. 42)
\parencite[see][]{key}   % With prefix: (see Author, 2024)
\nocite{key}          % Add to bibliography without citing in text
\nocite{*}            % Include ALL entries from .bib file
```

### Popular BibLaTeX Styles

```
authoryear   -- Smith (2024), standard humanities/social science
numeric      -- [1], standard science/engineering
apa          -- APA 7th edition (requires biblatex-apa package)
ieee         -- IEEE numbered style
chem-acs     -- American Chemical Society
phys         -- Physical Review style
chicago      -- Chicago Manual of Style
mla          -- Modern Language Association
```

## The .bib Database

### Entry Types and Fields

```bibtex
@article{smith2024attention,
  author    = {Smith, Jane A. and Doe, John B.},
  title     = {Attention Mechanisms in Transformer Models},
  journal   = {Journal of Machine Learning Research},
  year      = {2024},
  volume    = {25},
  number    = {3},
  pages     = {1--45},
  doi       = {10.1234/jmlr.2024.001}
}

@inproceedings{jones2023deep,
  author    = {Jones, Robert and Lee, Min},
  title     = {Deep Reinforcement Learning for Robotics},
  booktitle = {Proceedings of the International Conference on Robotics},
  year      = {2023},
  pages     = {112--120},
  publisher = {IEEE}
}

@book{garcia2022methods,
  author    = {Garcia, Maria},
  title     = {Research Methods in Social Science},
  publisher = {Academic Press},
  year      = {2022},
  edition   = {4th},
  address   = {New York}
}

@phdthesis{chen2023optimization,
  author  = {Chen, Wei},
  title   = {Optimization Algorithms for Large-Scale Systems},
  school  = {Massachusetts Institute of Technology},
  year    = {2023}
}
```

## natbib Setup

### Configuration for Journals That Require natbib

```latex
\documentclass{article}
\usepackage[round, sort&compress]{natbib}
\bibliographystyle{plainnat}  % or abbrvnat, unsrtnat, agsm, etc.

\begin{document}
Results were significant \citep{smith2024}.
\citet{jones2023} proposed a new framework.

\bibliography{references}
\end{document}
```

### natbib Commands

```latex
\citet{key}    % Author (2024)       -- textual
\citep{key}    % (Author, 2024)      -- parenthetical
\citet*{key}   % All authors in text
\citep*{key}   % All authors in parens
\citealt{key}  % Author 2024         -- no parentheses
\citealp{key}  % Author, 2024        -- no parentheses
\citep[p.~5]{key}  % (Author, 2024, p. 5)
```

## Compilation Workflow

### Build Commands

```bash
# BibLaTeX with Biber:
pdflatex manuscript.tex
biber manuscript
pdflatex manuscript.tex
pdflatex manuscript.tex

# natbib/BibTeX:
pdflatex manuscript.tex
bibtex manuscript
pdflatex manuscript.tex
pdflatex manuscript.tex

# With latexmk (handles all passes automatically):
latexmk -pdf manuscript.tex
```

## Troubleshooting Common Issues

### Frequent Errors and Fixes

```
Problem: "Citation undefined" warning
  Cause: Biber/BibTeX has not been run, or key is misspelled
  Fix: Run the full compilation chain; check .bib for matching key

Problem: Bibliography not appearing
  Cause: Missing \printbibliography or \bibliography command
  Fix: Add the appropriate command at the end of the document

Problem: "I found no \citation commands"
  Cause: .aux file is stale or no \cite commands in the document
  Fix: Delete .aux, .bbl, .bcf files and recompile from scratch

Problem: Unicode characters causing errors with BibTeX
  Cause: BibTeX does not support Unicode natively
  Fix: Switch to BibLaTeX + Biber, or use LaTeX escapes (\"o, \'{e})

Problem: Wrong citation style
  Cause: Conflicting style options or wrong .bst file
  Fix: Verify style= option matches your target journal requirements
```

## Best Practices

- Keep one master .bib file per project (or use your reference manager's export)
- Use consistent citation keys (authorYEARfirstword is a common convention)
- Always include DOIs -- many styles now render them as hyperlinks
- Validate your .bib file with `biber --validate-datamodel manuscript` before submission
- Export from Zotero or Mendeley rather than hand-typing entries to reduce errors

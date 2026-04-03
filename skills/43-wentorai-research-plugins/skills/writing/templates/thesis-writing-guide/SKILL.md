---
name: thesis-writing-guide
description: "Templates, formatting rules, and strategies for thesis and dissertation writing"
metadata:
  openclaw:
    emoji: "📑"
    category: "writing"
    subcategory: "templates"
    keywords: ["thesis template", "dissertation formatting", "journal formatting requirements", "page limit"]
    source: "https://github.com/awesome-thesis/awesome-thesis"
---

# Thesis Writing Guide

## Overview

Writing a thesis or dissertation is the culminating challenge of graduate education. Unlike journal papers, a thesis demands sustained coherence across hundreds of pages, covering background, methodology, multiple studies, and synthesis. The formatting requirements are often institution-specific and unforgiving -- a misplaced margin or incorrect heading style can delay your defense.

This guide draws from the awesome-thesis repository (626+ stars), which curates practical tips and tricks for computer science theses, and extends the advice to cover all disciplines. It covers thesis structure, LaTeX and Word templates, formatting checklists, writing strategies for long documents, and common pitfalls that delay graduation.

Whether you are writing a master's thesis (50-100 pages) or a PhD dissertation (150-300 pages), the planning and execution patterns here will help you finish on time and produce a document you are proud of.

## Thesis Structure

### Standard Structure (Monograph Style)

| Chapter | Content | Typical Pages |
|---------|---------|---------------|
| 1. Introduction | Problem, motivation, contributions, outline | 10-20 |
| 2. Background | Core concepts, definitions, prerequisites | 15-25 |
| 3. Related Work | Comprehensive literature review | 15-30 |
| 4. Methodology | Your approach, design, algorithms | 20-40 |
| 5. Experiments | Setup, results, analysis | 20-40 |
| 6. Discussion | Interpretation, limitations, broader impact | 10-20 |
| 7. Conclusion | Summary, contributions, future work | 5-10 |

### Paper-Based (Compilation) Style

Many institutions now accept theses composed of published papers:

```
Chapter 1: Introduction and Overview (new content, 15-20 pages)
Chapter 2: Paper A (published, reformatted)
Chapter 3: Paper B (published, reformatted)
Chapter 4: Paper C (under review, reformatted)
Chapter 5: Synthesis and Conclusion (new content, 10-15 pages)
Appendix: Supplementary materials for each paper
```

The key challenge with compilation theses is the "red thread" -- the narrative that connects your papers into a coherent whole. The introduction and conclusion chapters carry this responsibility.

## LaTeX Templates

### University Template Setup

Most universities provide official LaTeX templates. Here is a generic setup:

```latex
\documentclass[12pt, a4paper, twoside]{report}

% Essential packages
\usepackage[margin=1in, bindingoffset=0.5in]{geometry}
\usepackage{setspace}
\doublespacing
\usepackage[hidelinks]{hyperref}
\usepackage{cleveref}
\usepackage[backend=biber, style=numeric]{biblatex}
\addbibresource{thesis.bib}

% Front matter
\begin{document}
\frontmatter
\include{chapters/titlepage}
\include{chapters/abstract}
\include{chapters/acknowledgments}
\tableofcontents
\listoffigures
\listoftables

% Main content
\mainmatter
\include{chapters/introduction}
\include{chapters/background}
\include{chapters/related_work}
\include{chapters/methodology}
\include{chapters/experiments}
\include{chapters/discussion}
\include{chapters/conclusion}

% Back matter
\backmatter
\printbibliography
\appendix
\include{chapters/appendix_a}
\end{document}
```

### Popular Thesis Templates

| Template | Institution/Style | Link |
|----------|-------------------|------|
| `thuthesis` | Tsinghua University | github.com/tuna/thuthesis |
| `SJTUThesis` | Shanghai Jiao Tong | github.com/sjtug/SJTUThesis |
| `Dissertate` | Harvard (multi-school) | github.com/suchow/Dissertate |
| `novathesis` | Universidade Nova de Lisboa | github.com/joaomlourenco/novathesis |
| `cleanthesis` | Generic clean style | github.com/derric/cleanthesis |

### Project Organization

```
thesis/
  main.tex                # Master file
  thesis.bib              # Bibliography
  chapters/
    titlepage.tex
    abstract.tex
    introduction.tex
    ...
  figures/
    ch1/
    ch2/
    ...
  tables/
  code/                   # Code listings
  Makefile                # Build automation
  .gitignore
```

## Writing Strategies for Long Documents

### The Modular Writing Approach

1. **Write chapters independently.** Each chapter should be understandable on its own before integration.
2. **Start with the easiest chapter.** Often this is the Methods or a chapter based on a published paper.
3. **Write the Introduction last.** You need to know all your contributions before you can introduce them.
4. **Set daily word count targets.** 500 words/day produces a 100-page thesis in roughly 4 months of writing.

### Timeline Planning

For a 6-month writing period:

| Month | Task | Deliverable |
|-------|------|------------|
| 1 | Outline all chapters; write Methods | Methods draft |
| 2 | Write Experiments chapter | Experiments draft |
| 3 | Write Background and Related Work | Literature review draft |
| 4 | Write Discussion and Conclusion | Full rough draft |
| 5 | Write Introduction; revise all chapters | Complete first draft |
| 6 | Advisor review; final revisions; formatting | Submission-ready thesis |

### Managing Advisor Feedback

- Send one chapter at a time for review, not the entire thesis.
- Include a cover note explaining what feedback you need (structure? content? prose?).
- Allow 2 weeks per chapter for advisor review.
- Track revisions using `latexdiff` or track changes in Word.

```bash
# Generate a visual diff between thesis versions
latexdiff old_version.tex new_version.tex > diff.tex
pdflatex diff.tex
```

## Formatting Checklist

Before submission, verify every item:

### Document-Level

- [ ] Title page matches university template exactly.
- [ ] Page numbers: roman for front matter, arabic for main text.
- [ ] Margins meet requirements (typically 1-1.5 inch, larger on binding side).
- [ ] Line spacing is correct (usually double-spaced; some allow 1.5).
- [ ] Font and size comply (usually 12pt Times New Roman or Computer Modern).

### Figures and Tables

- [ ] All figures are referenced in the text.
- [ ] Figure captions are below figures; table captions are above tables.
- [ ] Resolution is at least 300 DPI for raster images.
- [ ] All figures are readable in grayscale (accessibility).

### References

- [ ] All cited works appear in the bibliography.
- [ ] All bibliography entries are cited in the text.
- [ ] Citation style matches university requirements.
- [ ] DOIs are included where available.

### Front and Back Matter

- [ ] Abstract is within the word limit.
- [ ] Acknowledgments are complete (funding, advisor, committee, family).
- [ ] Table of contents, list of figures, list of tables are up to date.
- [ ] Appendices are properly numbered and referenced.

## Common Pitfalls

1. **Starting too late.** Begin writing during your research, not after.
2. **Perfectionism on first drafts.** "Done is better than perfect" for draft 1.
3. **Inconsistent notation.** Define a notation table and stick to it across all chapters.
4. **Ignoring the formatting guide.** Read your university's thesis manual before writing, not the week before submission.
5. **Not backing up.** Use Git + cloud storage. Losing a thesis to hardware failure is devastating and preventable.

## Best Practices

- **Use version control.** Git with a private GitHub/GitLab repository provides backup and history.
- **Compile frequently.** Catch LaTeX errors early rather than debugging 200 pages of broken code.
- **Create a glossary.** Define all domain-specific terms in one place for consistency.
- **Write the abstract in three versions:** 50-word (elevator pitch), 150-word (standard), and 300-word (extended).
- **Schedule your defense date early.** Having a deadline makes the writing timeline concrete.
- **Read other theses from your lab.** They set expectations for scope, depth, and style.

## References

- [awesome-thesis](https://github.com/awesome-thesis/awesome-thesis) -- Practical thesis tips (626+ stars)
- [How to Write a Thesis](https://www.ldeo.columbia.edu/~martins/sen_res/how_to_thesis.html) -- Columbia University guide
- [Dissertate Template](https://github.com/suchow/Dissertate) -- Harvard multi-school LaTeX template
- [latexdiff](https://ctan.org/pkg/latexdiff) -- Visual diff tool for LaTeX documents
- [Overleaf Thesis Templates](https://www.overleaf.com/latex/templates/tagged/thesis) -- Gallery of institutional templates

---
name: scientific-writing-guide
description: "Curated tools and techniques for scientific writing beyond LaTeX"
metadata:
  openclaw:
    emoji: "🖊"
    category: "writing"
    subcategory: "composition"
    keywords: ["academic writing style", "scientific writing", "formal English", "paper title writing", "abstract writing"]
    source: "https://github.com/writing-resources/awesome-scientific-writing"
---

# Scientific Writing Guide

## Overview

Scientific writing is a specialized skill that demands clarity, precision, and adherence to disciplinary conventions. Whether you are drafting a journal article, conference paper, or grant proposal, the quality of your prose directly influences how reviewers and readers perceive your research.

This guide distills best practices from the awesome-scientific-writing community (920+ stars) and supplements them with actionable techniques for structuring papers, writing compelling titles and abstracts, choosing the right authoring tools, and polishing manuscripts to publication quality. The focus is on practical, tool-agnostic advice that works across STEM and social-science disciplines.

Modern scientific writing extends well beyond LaTeX. Markdown-based workflows (Pandoc, Quarto, Jupyter Book), collaborative platforms (Overleaf, HackMD), and reference managers (Zotero, Paperpile) have reshaped how researchers draft and publish. This skill helps you navigate these options and adopt a workflow that fits your team.

## Structuring a Research Paper

A well-structured paper guides the reader from problem to contribution with minimal friction. The standard IMRaD (Introduction, Methods, Results, and Discussion) skeleton remains the default for empirical work, but variations exist for theoretical, review, and systems papers.

### The IMRaD Skeleton

| Section | Purpose | Typical Length |
|---------|---------|---------------|
| Title | Concise summary of contribution | 8-15 words |
| Abstract | Self-contained overview | 150-300 words |
| Introduction | Context, gap, contribution | 1-2 pages |
| Related Work | Position within the field | 1-2 pages |
| Methods | Reproducible description | 2-4 pages |
| Results | Empirical findings | 2-3 pages |
| Discussion | Interpretation and limitations | 1-2 pages |
| Conclusion | Takeaways and future work | 0.5-1 page |

### Step-by-Step Drafting Process

1. **Outline first.** Write one sentence per section summarizing its core message.
2. **Draft figures and tables early.** These anchor your results and drive the narrative.
3. **Write Methods before Results.** Describing what you did is easier than interpreting outcomes.
4. **Draft the Introduction last.** By then you know exactly what contribution to advertise.
5. **Iterate on the Abstract.** It is the single most-read part of any paper.

## Writing Titles and Abstracts

### Titles

A strong title is specific, informative, and free of jargon abbreviations. Compare:

- Weak: "A Study of Neural Networks for NLP"
- Strong: "Attention Is All You Need: Replacing Recurrence with Self-Attention for Sequence Transduction"

Rules of thumb:

- Include the method and the domain.
- Avoid questions unless the answer is surprising.
- Keep it under 15 words for most venues.

### Abstracts

Use the four-sentence abstract formula:

1. **Context** -- What is the broad problem area?
2. **Gap** -- What specific problem remains unsolved?
3. **Approach** -- What did you do?
4. **Result** -- What did you find, and why does it matter?

Example template:

```
[Domain] faces the challenge of [problem]. Existing approaches [limitation].
We propose [method], which [key innovation]. Experiments on [benchmarks]
show that [method] achieves [metric improvements], demonstrating [significance].
```

## Authoring Tools and Workflows

### Markdown + Pandoc Pipeline

For researchers who prefer plain text and version control:

```bash
# Convert Markdown to PDF via LaTeX
pandoc paper.md \
  --citeproc \
  --bibliography refs.bib \
  --csl ieee.csl \
  --pdf-engine=xelatex \
  -o paper.pdf

# Convert to DOCX for collaborators
pandoc paper.md \
  --citeproc \
  --bibliography refs.bib \
  -o paper.docx
```

### Quarto for Reproducible Documents

Quarto extends R Markdown to Python, Julia, and Observable JS:

```yaml
# _quarto.yml
project:
  type: manuscript

manuscript:
  article: paper.qmd

format:
  html: default
  pdf:
    template: elsevier.tex
```

### Tool Comparison

| Tool | Best For | Collaboration | Version Control |
|------|----------|---------------|-----------------|
| Overleaf | LaTeX teams | Real-time | Git integration |
| Quarto | Code + prose | Git | Native |
| Google Docs | Non-technical coauthors | Real-time | Suggest mode |
| Typst | Fast typesetting | Git | Native |

## Common Pitfalls and How to Avoid Them

1. **Passive voice overuse.** "The experiment was conducted" vs. "We conducted the experiment." Active voice is shorter and clearer.
2. **Hedging inflation.** One "may" per paragraph is enough. Stacking "might potentially possibly" weakens your claims.
3. **Undefined acronyms.** Always expand on first use: "Large Language Model (LLM)."
4. **Figure-text mismatch.** Every figure must be referenced in the text, and the text must add interpretation beyond what the figure shows.
5. **Citation dumps.** "[1-15]" without commentary is unhelpful. Group citations by contribution type: "Prior work on X [1,2] addressed Y, while [3,4] focused on Z."

## Best Practices

- **Write every day.** Even 30 minutes of daily writing accumulates faster than weekend marathons.
- **Use a reference manager.** Zotero or Paperpile with browser extensions save hours of manual BibTeX entry.
- **Get feedback early.** Share outlines and rough drafts before polishing prose.
- **Read your paper aloud.** Awkward phrasing becomes obvious when spoken.
- **Check venue requirements before submission.** Page limits, formatting templates, and supplementary material policies vary widely.
- **Use grammar tools as a second pass.** Grammarly, LanguageTool, or Writefull catch errors humans miss, but do not replace human review.

## References

- [awesome-scientific-writing](https://github.com/writing-resources/awesome-scientific-writing) -- Curated list of tools and resources (920+ stars)
- [How to Write a Great Research Paper](https://www.microsoft.com/en-us/research/academic-program/write-great-research-paper/) -- Simon Peyton Jones, Microsoft Research
- [The Science of Scientific Writing](https://www.americanscientist.org/blog/the-long-view/the-science-of-scientific-writing) -- Gopen and Swan, American Scientist
- [Improving Your Scientific Writing](https://lijunsun.github.io/files/ScientificWritingV39.pdf) -- Lijun Sun, McGill University
- [Three Sins of Authors in CS and Math](http://www.cs.cmu.edu/~jrs/sins.html) -- Jonathan Shewchuk, UC Berkeley

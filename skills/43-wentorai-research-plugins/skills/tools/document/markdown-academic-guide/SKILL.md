---
name: markdown-academic-guide
description: "Write academic papers in Markdown with Pandoc for multi-format output"
metadata:
  openclaw:
    emoji: "📄"
    category: "tools"
    subcategory: "document"
    keywords: ["Markdown", "Pandoc", "academic writing", "document conversion", "scholarly Markdown", "plain text"]
    source: "wentor-research-plugins"
---

# Academic Writing in Markdown with Pandoc

A skill for writing academic papers in plain-text Markdown and converting them to PDF, Word, LaTeX, and HTML using Pandoc. Covers YAML metadata, citation management, cross-references, templates, and workflows for collaborative academic writing.

## Why Markdown for Academic Writing?

### Advantages

```
1. Plain text: Version-controllable with Git (diff-friendly)
2. Portable: Works on any OS, any editor
3. Pandoc: Convert to PDF, DOCX, LaTeX, HTML, EPUB
4. Focus: Content-first writing without formatting distractions
5. Citations: Pandoc-citeproc handles bibliography automatically
6. Collaboration: Easy to review diffs in pull requests
```

### When to Use Markdown vs. LaTeX

```
Use Markdown when:
  - You need multi-format output (PDF + Word + HTML)
  - Collaborators prefer Word but you prefer plain text
  - The paper has standard formatting needs
  - You want a simpler syntax than LaTeX

Use LaTeX directly when:
  - The journal provides a mandatory LaTeX template
  - You need advanced typesetting (complex math layouts, custom floats)
  - You are writing a thesis with institutional LaTeX requirements
```

## Document Structure

### YAML Front Matter

```yaml
---
title: "Your Paper Title: A Markdown-Based Approach"
author:
  - name: Jane Smith
    affiliation: Department of Computer Science, University X
    email: jane@university.edu
    orcid: 0000-0002-1234-5678
  - name: John Doe
    affiliation: School of Engineering, University Y
date: 2026-03-09
abstract: |
  This paper demonstrates how academic manuscripts can be written
  in plain Markdown and converted to publication-quality documents
  using Pandoc. We show that this approach reduces formatting overhead
  while maintaining full citation and cross-reference capabilities.
keywords: [academic writing, Markdown, Pandoc, reproducible research]
bibliography: references.bib
csl: apa-7th-edition.csl
link-citations: true
numbersections: true
---
```

### Body Text with Citations

```markdown
# Introduction

Academic writing often involves tedious formatting tasks that
distract from content creation [@smith2024; @jones2023, pp. 45-50].
Recent tools enable plain-text workflows that separate content
from presentation [see @garcia2022, chap. 3].

## Background

As @lee2021 demonstrated, Markdown-based workflows reduce
formatting errors by 40% compared to WYSIWYG editors.

### Subsection Example

Inline math: $E = mc^2$

Display math:
$$
\hat{\beta} = (X^T X)^{-1} X^T y
$$
```

### Citation Syntax

```
[@key]           -> (Author, 2024)
@key             -> Author (2024)
[@key, p. 42]    -> (Author, 2024, p. 42)
[@key1; @key2]   -> (Author1, 2024; Author2, 2023)
[-@key]          -> (2024) -- suppress author name
[see @key]       -> (see Author, 2024)
```

## Pandoc Conversion

### Basic Commands

```bash
# Markdown to PDF (via LaTeX)
pandoc paper.md -o paper.pdf \
  --citeproc \
  --number-sections \
  --pdf-engine=xelatex

# Markdown to Word (DOCX)
pandoc paper.md -o paper.docx \
  --citeproc \
  --reference-doc=template.docx

# Markdown to LaTeX
pandoc paper.md -o paper.tex \
  --citeproc \
  --standalone

# Markdown to HTML
pandoc paper.md -o paper.html \
  --citeproc \
  --standalone \
  --mathjax
```

### Custom LaTeX Template

```bash
# Extract default template for customization
pandoc -D latex > custom-template.tex

# Use custom template
pandoc paper.md -o paper.pdf \
  --template=custom-template.tex \
  --citeproc \
  --pdf-engine=xelatex
```

## Cross-References and Figures

### Using pandoc-crossref

```markdown
See @fig:architecture for the system overview.

![System Architecture](figures/architecture.pdf){#fig:architecture width=80%}

Results are shown in @tbl:results.

| Method | Accuracy | F1 Score |
|--------|----------|----------|
| Ours   | 0.95     | 0.93     |
| Baseline| 0.88    | 0.85     |

: Comparison of methods. {#tbl:results}

As proven in @eq:main, the relationship holds.

$$y = \alpha + \beta x + \epsilon$$ {#eq:main}
```

```bash
# Compile with cross-references
pandoc paper.md -o paper.pdf \
  --filter pandoc-crossref \
  --citeproc \
  --pdf-engine=xelatex
```

## Collaborative Workflow

### Git-Based Collaboration

```python
def markdown_collaboration_workflow() -> dict:
    """
    Recommended workflow for multi-author Markdown papers.
    """
    return {
        "setup": [
            "Create a Git repository for the paper",
            "Add .gitignore for PDF output and LaTeX aux files",
            "Store references.bib in the repo",
            "Include a Makefile for reproducible builds"
        ],
        "writing": [
            "Each author works on a branch",
            "Use pull requests for section drafts",
            "Review diffs in GitHub/GitLab (plain text diffs are readable)",
            "Resolve merge conflicts in plain text (much easier than .docx)"
        ],
        "makefile_example": (
            "all: paper.pdf paper.docx\n"
            "paper.pdf: paper.md references.bib\n"
            "\tpandoc paper.md -o paper.pdf --citeproc --pdf-engine=xelatex\n"
            "paper.docx: paper.md references.bib\n"
            "\tpandoc paper.md -o paper.docx --citeproc --reference-doc=template.docx\n"
            "clean:\n"
            "\trm -f paper.pdf paper.docx"
        )
    }
```

## Tips and Limitations

Pandoc handles most academic writing needs, but has limitations with complex table layouts, advanced figure placement, and journal-specific LaTeX class features. For final submission, you may need to fine-tune the generated LaTeX or DOCX output. Keep your Markdown source as the canonical version and treat generated files as disposable build artifacts.

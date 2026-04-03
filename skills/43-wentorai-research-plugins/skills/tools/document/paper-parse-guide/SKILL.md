---
name: paper-parse-guide
description: "Deep dual-mode reading of academic papers from PDF or URL sources"
metadata:
  openclaw:
    emoji: "🔬"
    category: "tools"
    subcategory: "document"
    keywords: ["paper reading", "PDF parsing", "academic paper", "deep reading", "annotation", "GROBID"]
    source: "wentor-research-plugins"
---

# Paper Parse Guide

Perform structured, dual-mode deep reading of academic papers from PDF files or URLs. Mode A provides a rapid overview suitable for screening during literature reviews. Mode B delivers exhaustive section-by-section analysis for papers central to your research.

## Overview

Reading academic papers efficiently is a core research skill, yet the density and conventions of scholarly writing make it time-consuming. A typical researcher reads dozens of papers per week during a literature review phase, requiring different levels of depth for different papers. Some need only a quick scan to determine relevance; others demand line-by-line scrutiny of methods and results.

This skill implements a dual-mode reading system. Mode A (Survey Mode) extracts key metadata, the main argument, methods summary, and key findings in under two minutes of processing time. Mode B (Deep Analysis Mode) performs exhaustive section-by-section analysis including methodology critique, statistical evaluation, figure interpretation, and connection to broader literature.

Both modes begin by parsing the paper's structure from its PDF or HTML source, extracting clean text with section boundaries, figures, tables, equations, and references. The parsing pipeline handles the common challenges of academic PDFs: two-column layouts, footnotes, headers/footers, embedded equations, and supplementary materials.

## Paper Acquisition and Parsing

### Input Sources

| Source | Method | Notes |
|--------|--------|-------|
| Local PDF | Direct file path | Best quality, no network needed |
| DOI | Resolve via CrossRef/Unpaywall | Auto-fetches open access version |
| arXiv ID | `https://arxiv.org/pdf/{id}` | Always available |
| URL | Direct download | May require institutional access |
| OpenAlex ID | OpenAlex API + OA link | Includes metadata |

### PDF Parsing Pipeline

```python
from pathlib import Path
import fitz  # PyMuPDF

def parse_paper(pdf_path: str) -> dict:
    doc = fitz.open(pdf_path)
    sections = []
    current_section = {"title": "Header", "content": []}

    for page in doc:
        blocks = page.get_text("dict")["blocks"]
        for block in blocks:
            if block["type"] == 0:  # Text block
                for line in block["lines"]:
                    text = " ".join(span["text"] for span in line["spans"])
                    font_size = max(span["size"] for span in line["spans"])
                    is_bold = any("Bold" in span["font"] for span in line["spans"])

                    # Detect section headings
                    if font_size > 11 and is_bold:
                        if current_section["content"]:
                            sections.append(current_section)
                        current_section = {"title": text.strip(), "content": []}
                    else:
                        current_section["content"].append(text)

    sections.append(current_section)
    return {
        "title": extract_title(doc),
        "authors": extract_authors(doc),
        "sections": sections,
        "references": extract_references(doc),
        "page_count": len(doc)
    }
```

### GROBID Integration

For higher-quality structural parsing, use GROBID (GeneRation Of BIbliographic Data):

```bash
# Start GROBID server
docker run --rm -p 8070:8070 lfoppiano/grobid:0.8.0

# Parse a paper
curl -X POST "http://localhost:8070/api/processFulltextDocument" \
  -F "input=@paper.pdf" \
  -F "consolidateHeader=1" \
  -F "consolidateCitations=1" \
  -H "Accept: application/xml" \
  -o parsed_paper.xml
```

GROBID returns TEI XML with structured sections, author affiliations, parsed references, and figure/table captions. It handles two-column layouts, footnotes, and complex formatting better than simple text extraction.

## Mode A: Survey Reading

Designed for rapid screening. Produces a structured summary in 5 components:

### 1. Identity Card

```
Title:      [Extracted title]
Authors:    [First author et al., year]
Venue:      [Journal/Conference name]
DOI:        [DOI if available]
Pages:      [Page count]
Type:       [Empirical / Theoretical / Review / Methods]
```

### 2. Core Argument (1-2 sentences)

Extract from abstract + introduction: What is the main claim?

### 3. Methods Snapshot

- Study design (experimental, observational, computational, theoretical)
- Sample/dataset description
- Key techniques or models used

### 4. Key Findings (3-5 bullets)

Extract from results section and abstract.

### 5. Relevance Assessment

- Relevance to current research question: High / Medium / Low
- Methodological quality signal: sample size, controls, statistical rigor
- Recommended action: Deep read / Cite only / Skip

## Mode B: Deep Analysis

Exhaustive section-by-section reading with critical evaluation.

### Introduction Analysis

- What gap in the literature does this paper address?
- What is the stated research question or hypothesis?
- How does the framing position the contribution?

### Literature Review Evaluation

- Which theoretical frameworks are invoked?
- Are there notable omissions in cited literature?
- How does the paper position itself relative to competing approaches?

### Methodology Critique

- Is the methodology appropriate for the research question?
- Sample size and power analysis: reported? adequate?
- Threats to internal and external validity
- Reproducibility: are methods described in sufficient detail?
- Statistical tests: appropriate? assumptions met?

### Results Assessment

- Do the results support the claims?
- Effect sizes: reported? meaningful?
- Confidence intervals vs. p-values
- Figures and tables: do they accurately represent the data?
- Any signs of p-hacking or selective reporting?

### Discussion Evaluation

- Are limitations adequately acknowledged?
- Are alternative explanations considered?
- Do the conclusions follow logically from the results?
- Are implications overstated?

### Reference Network

- Extract all cited works with metadata
- Identify seminal references (cited by many papers in this field)
- Flag self-citations
- Map citation clusters by topic

## Output Formats

### Structured Note (Markdown)

```markdown
## [Paper Title] ([Year])

**Authors**: [Authors]
**Venue**: [Venue]
**DOI**: [DOI]

### Summary
[2-3 sentence summary]

### Key Contributions
1. [Contribution 1]
2. [Contribution 2]

### Methodology
[Methods description]

### Strengths
- [Strength 1]
- [Strength 2]

### Weaknesses
- [Weakness 1]
- [Weakness 2]

### Relevance to My Research
[How this paper connects to your work]

### Key Quotes
> "[Notable quote]" (p. X)

### References to Follow
- [Ref 1]: [Why relevant]
- [Ref 2]: [Why relevant]
```

### BibTeX Entry

Automatically extract or generate a BibTeX entry for the parsed paper, including all available fields (author, title, journal, year, volume, pages, doi).

## Batch Processing

For systematic reviews, process multiple papers in sequence:

```python
papers = ["paper1.pdf", "paper2.pdf", "paper3.pdf"]
summaries = []

for pdf in papers:
    parsed = parse_paper(pdf)
    summary = mode_a_survey(parsed)
    summaries.append(summary)

# Generate comparison matrix
comparison = create_comparison_table(summaries,
    columns=["methods", "sample_size", "key_finding", "relevance"])
```

## References

- GROBID: https://github.com/kermitt2/grobid
- PyMuPDF: https://pymupdf.readthedocs.io
- OpenAlex API: https://api.openalex.org
- Unpaywall API: https://unpaywall.org/products/api
- S. Keshav, "How to Read a Paper" (2007): http://ccr.sigcomm.org/online/files/p83-keshavA.pdf

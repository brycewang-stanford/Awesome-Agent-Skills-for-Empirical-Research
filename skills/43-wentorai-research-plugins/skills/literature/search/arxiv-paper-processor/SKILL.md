---
name: arxiv-paper-processor
description: "Process and analyze arXiv papers systematically for research workflows"
metadata:
  openclaw:
    emoji: "⚙️"
    category: "literature"
    subcategory: "search"
    keywords: ["arxiv", "paper processing", "PDF parsing", "metadata extraction", "preprint analysis", "research pipeline"]
    source: "https://github.com/tatsu-lab/gpt_paper_assistant"
---

# arXiv Paper Processor

## Overview

The arXiv Paper Processor skill provides a complete pipeline for downloading, parsing, and analyzing arXiv papers programmatically. While the arXiv API provides metadata, researchers often need to work with the full text—extracting sections, equations, figures, and references for deeper analysis.

This skill covers the entire processing chain: retrieving papers by ID or search query, downloading PDF and LaTeX source files, extracting structured content, and producing analysis-ready outputs. It is particularly valuable for researchers conducting large-scale literature analysis, building training datasets from academic text, or automating evidence extraction for systematic reviews.

The pipeline handles common challenges in academic PDF processing including multi-column layouts, mathematical notation, table extraction, and reference parsing. It integrates with tools like GROBID for PDF parsing and can work directly with arXiv LaTeX sources for higher-fidelity extraction.

## Paper Retrieval and Download

### Fetching by arXiv ID

The most reliable method is to fetch papers by their arXiv identifier:

```python
import urllib.request
import feedparser

# Fetch metadata via Atom feed
arxiv_id = "2301.07041"
url = f"http://export.arxiv.org/api/query?id_list={arxiv_id}"
response = urllib.request.urlopen(url)
feed = feedparser.parse(response.read())

entry = feed.entries[0]
title = entry.title
abstract = entry.summary
authors = [a.name for a in entry.authors]
pdf_url = entry.links[1].href  # PDF link
```

### Downloading Source Files

arXiv stores LaTeX source files for most papers. These provide much richer structure than PDFs:

```bash
# Download LaTeX source (typically a .tar.gz)
wget https://arxiv.org/e-print/2301.07041 -O paper_source.tar.gz
tar -xzf paper_source.tar.gz -C paper_source/
```

Source files contain the original `.tex` files, figures, bibliography files, and any custom style files. Parsing LaTeX directly gives you access to section structure, equations in their original notation, citation keys, and figure captions without the ambiguity of PDF extraction.

### Batch Download Guidelines

When downloading multiple papers, respect arXiv's usage policies:

- Limit requests to 1 per 3 seconds for API calls
- Use the arXiv bulk data access (S3 or GCS) for large-scale processing (1000+ papers)
- Cache all downloaded files locally and check before re-downloading
- Include a descriptive User-Agent header in your HTTP requests

## Content Extraction Pipeline

### PDF Extraction with GROBID

For papers where only PDF is available, use GROBID (GeneRation Of BIbliographic Data) for structured extraction:

```bash
# Run GROBID as a local service
docker run --rm -p 8070:8070 grobid/grobid:0.8.0

# Process a PDF
curl -X POST "http://localhost:8070/api/processFulltextDocument" \
  -F "input=@paper.pdf" \
  -F "consolidateHeader=1" \
  -F "consolidateCitations=1" \
  > paper_tei.xml
```

GROBID outputs TEI-XML with structured sections including:
- Header metadata (title, authors, affiliations, abstract)
- Body text with section hierarchy
- Equations (as MathML or raw text)
- Figure and table references
- Parsed bibliography entries with DOIs where available

### LaTeX Source Parsing

When LaTeX source is available, parse it directly for higher fidelity:

1. Identify the main `.tex` file (look for `\documentclass` or `\begin{document}`)
2. Resolve `\input{}` and `\include{}` directives to build the complete document
3. Extract sections using `\section{}`, `\subsection{}` markers
4. Extract equations from `equation`, `align`, `gather` environments
5. Parse `\cite{}` commands and cross-reference with the `.bib` file
6. Extract figure captions from `\caption{}` commands

### Structured Output Schema

Produce a standardized JSON output for each processed paper:

```json
{
  "arxiv_id": "2301.07041",
  "title": "Paper Title",
  "authors": ["Author One", "Author Two"],
  "abstract": "...",
  "sections": [
    {"heading": "Introduction", "level": 1, "text": "..."},
    {"heading": "Related Work", "level": 1, "text": "..."}
  ],
  "equations": ["E = mc^2", "..."],
  "figures": [{"id": "fig1", "caption": "..."}],
  "references": [{"key": "smith2020", "title": "...", "doi": "..."}],
  "processed_date": "2026-03-10"
}
```

## Analysis and Integration

Once papers are processed into structured format, several downstream analyses become possible:

- **Section-level search**: Search across the methods sections of hundreds of papers to find specific techniques.
- **Equation extraction**: Build a database of mathematical formulations used in your subfield.
- **Citation graph construction**: Map which papers cite which, using extracted reference lists.
- **Terminology tracking**: Monitor how specific terms evolve in usage frequency over time.
- **Dataset identification**: Extract mentions of datasets and benchmarks from experimental sections.

Integrate processed outputs with your reference manager by generating BibTeX entries enriched with extracted metadata, or feed structured JSON into a local search index for full-text retrieval across your paper collection.

## References

- arXiv API: https://info.arxiv.org/help/api/index.html
- GROBID: https://github.com/kermitt2/grobid
- GPT Paper Assistant: https://github.com/tatsu-lab/gpt_paper_assistant
- arXiv bulk data access: https://info.arxiv.org/help/bulk_data/index.html

---
name: arxiv-cli-tools
description: "Command-line tools for searching and batch-downloading arXiv papers"
metadata:
  openclaw:
    emoji: "🔍"
    category: "literature"
    subcategory: "search"
    keywords: ["arxiv", "command line", "paper download", "preprint search", "batch download", "literature retrieval"]
    source: "https://pypi.org/project/arxiv-cli-tools/"
---

# arXiv CLI Tools

## Overview

`arxiv-cli-tools` is a Python command-line interface for searching and downloading papers from arXiv.org. It wraps the `arxiv` Python client library into convenient CLI commands, enabling researchers to search by keyword, author, or category, view abstracts, and batch-download PDFs directly from the terminal. No API key is required.

## Installation

```bash
# Recommended: isolated install with pipx
pipx install arxiv-cli-tools

# Alternative: pip
pip install arxiv-cli-tools

# Verify installation
arxiv-cli --help
```

## Searching Papers

### Basic Search

```bash
# Search by keyword (default: 10 results)
arxiv-cli search "transformer attention mechanism"

# Limit results
arxiv-cli search "quantum computing" -n 5

# Show abstracts in results
arxiv-cli search "prompt engineering" -n 5 --summary
```

### Filtered Search

```bash
# Filter by author
arxiv-cli search "attention mechanism" --authors "Vaswani"

# Filter by arXiv category
arxiv-cli search "neural networks" --categories "cs.LG,cs.AI"

# Combine filters
arxiv-cli search "protein folding" --categories "q-bio" -n 20 --summary
```

### Common arXiv Categories

| Prefix | Field | Popular Subcategories |
|--------|-------|----------------------|
| `cs` | Computer Science | cs.AI, cs.CL, cs.CV, cs.LG, cs.SE |
| `math` | Mathematics | math.ST, math.OC, math.PR |
| `physics` | Physics | physics.comp-ph, hep-th, cond-mat |
| `stat` | Statistics | stat.ML, stat.ME, stat.TH |
| `q-bio` | Quantitative Biology | q-bio.BM, q-bio.GN |
| `q-fin` | Quantitative Finance | q-fin.ST, q-fin.PM |
| `econ` | Economics | econ.EM, econ.GN |
| `eess` | Electrical Engineering | eess.SP, eess.AS |

## Downloading Papers

### Single Paper

```bash
# Download by arXiv ID
arxiv-cli download --id 1706.03762 --dest ~/papers

# Download PDF format explicitly
arxiv-cli download --id 2301.13688 --dest ~/papers --pdf
```

### Batch Download

```bash
# Download multiple papers
arxiv-cli download --id 1706.03762 --id 2301.13688 --id 2303.08774 \
  --dest ~/papers/transformers

# Skip already downloaded files
arxiv-cli download --id 1706.03762 --id 2301.13688 \
  --dest ~/papers --skip-existing
```

### Download from Search Results

A common workflow is to search first, then download selected papers:

```bash
# 1. Search and note IDs
arxiv-cli search "diffusion models survey" -n 10 --summary

# 2. Download the relevant ones
arxiv-cli download --id 2209.00796 --id 2206.00364 --dest ~/papers/diffusion
```

## Python API Alternative

For programmatic use, the underlying `arxiv` library provides a Python API:

```python
import arxiv

# Search
search = arxiv.Search(
    query="large language models",
    max_results=10,
    sort_by=arxiv.SortCriterion.SubmittedDate
)

for result in arxiv.Client().results(search):
    print(f"{result.entry_id}: {result.title}")
    print(f"  Authors: {', '.join(a.name for a in result.authors)}")
    print(f"  Published: {result.published.date()}")
    print(f"  PDF: {result.pdf_url}")
    print()

# Download
result.download_pdf(dirpath="./papers", filename="paper.pdf")
```

## Workflow Integration

### Daily Paper Check Script

```bash
#!/bin/bash
# Check for new papers in your research area
DATE=$(date +%Y-%m-%d)
LOG="$HOME/papers/daily_${DATE}.txt"

echo "=== arXiv Papers for $DATE ===" > "$LOG"
arxiv-cli search "retrieval augmented generation" \
  --categories "cs.CL,cs.AI" -n 20 --summary >> "$LOG"

echo "Paper digest saved to $LOG"
```

### Export to BibTeX

After finding relevant papers, retrieve BibTeX entries via the arXiv API:

```bash
# Get BibTeX for a specific paper
curl -s "https://arxiv.org/bibtex/1706.03762"
```

## Rate Limits and Etiquette

- arXiv API allows **1 request per 3 seconds** for programmatic access
- For bulk downloads, add delays between requests
- The CLI tool respects rate limits by default
- See [arXiv API Terms of Use](https://info.arxiv.org/help/api/tou.html)

## References

- [arxiv-cli-tools on PyPI](https://pypi.org/project/arxiv-cli-tools/)
- [arxiv Python Client](https://github.com/lukasschwab/arxiv.py)
- [arXiv API Documentation](https://info.arxiv.org/help/api/)
- [arXiv Category Taxonomy](https://arxiv.org/category_taxonomy)

---
name: findpapers-guide
description: "Search multiple academic databases simultaneously with Findpapers"
metadata:
  openclaw:
    emoji: "🔍"
    category: "literature"
    subcategory: "search"
    keywords: ["Findpapers", "multi-database search", "systematic review", "arXiv", "PubMed", "Scopus", "IEEE"]
    source: "https://github.com/jonatasgrosman/findpapers"
---

# Findpapers Guide

## Overview

Findpapers is a Python tool for searching multiple academic databases simultaneously — arXiv, bioRxiv, IEEE, medRxiv, PubMed, and Scopus — using a single query. It automates the tedious process of running the same search across multiple platforms, deduplicates results, and exports to structured formats for systematic reviews.

## Installation

```bash
pip install findpapers
```

## Basic Usage

### Search Multiple Databases

```python
import findpapers
import datetime

# Define search
query = '([deep learning] AND [medical imaging]) AND NOT [survey]'
since = datetime.date(2022, 1, 1)
until = datetime.date(2026, 12, 31)

# Run search across all databases
findpapers.search(
    outputpath="search_results.json",
    query=query,
    since=since,
    until=until,
    databases=["arxiv", "pubmed", "ieee", "scopus"],
    limit_per_database=200,
)
```

### Query Syntax

```python
# Boolean operators: AND, OR, NOT
# Brackets for grouping
# Terms in square brackets

# Example: find NLP papers about healthcare
query = '[natural language processing] AND ([healthcare] OR [clinical])'

# Example: exclude surveys
query = '[transformer] AND [attention] AND NOT [survey]'

# Example: specific domain
query = '[reinforcement learning] AND [robotics] AND [simulation]'
```

### Refine and Filter Results

```python
# Load previous search
search = findpapers.load("search_results.json")

# Interactive refinement (in Jupyter/terminal)
findpapers.refine(
    inputpath="search_results.json",
    categories=["relevant", "maybe", "irrelevant"],
)

# Programmatic filtering
for paper in search.papers:
    if paper.citations and paper.citations > 50:
        paper.selected = True
```

### Export Results

```python
# Export to BibTeX
findpapers.generate_bibtex(
    inputpath="search_results.json",
    outputpath="references.bib",
    only_selected=True,
)

# Export to CSV
findpapers.generate_csv(
    inputpath="search_results.json",
    outputpath="papers.csv",
)
```

## Database Configuration

### API Keys (Optional)

```python
# Scopus requires an Elsevier API key
# IEEE requires an IEEE Xplore API key
# arXiv and PubMed are free

import os
os.environ["SCOPUS_API_TOKEN"] = "your-scopus-key"
os.environ["IEEE_API_TOKEN"] = "your-ieee-key"
```

### Database Support

| Database | API Key | Content |
|----------|---------|---------|
| arXiv | Not needed | Preprints (CS, physics, math) |
| PubMed | Not needed | Biomedical literature |
| bioRxiv | Not needed | Biology preprints |
| medRxiv | Not needed | Medical preprints |
| IEEE | Optional | Engineering and CS |
| Scopus | Required | Multi-discipline |

## Systematic Review Workflow

```python
import findpapers
import datetime

# Step 1: Define protocol
query = '[machine learning] AND [drug discovery]'
since = datetime.date(2020, 1, 1)

# Step 2: Search
findpapers.search(
    outputpath="slr_search.json",
    query=query,
    since=since,
    limit_per_database=500,
)

# Step 3: Remove duplicates (automatic)
search = findpapers.load("slr_search.json")
print(f"Found {len(search.papers)} unique papers")

# Step 4: Screen titles/abstracts
findpapers.refine("slr_search.json",
                   categories=["include", "exclude", "uncertain"])

# Step 5: Export included papers
findpapers.generate_bibtex("slr_search.json", "included.bib",
                            only_selected=True)
```

## CLI Usage

```bash
# Search from command line
findpapers search "search.json" \
  --query "[climate change] AND [adaptation]" \
  --since 2022-01-01 \
  --databases arxiv pubmed

# Refine results interactively
findpapers refine "search.json"

# Export to BibTeX
findpapers bibtex "search.json" "refs.bib" --only-selected
```

## References

- [Findpapers GitHub](https://github.com/jonatasgrosman/findpapers)
- [Findpapers PyPI](https://pypi.org/project/findpapers/)
- Grosman, J. & Ciferri, R. (2020). "Findpapers: A tool for systematic literature searching."

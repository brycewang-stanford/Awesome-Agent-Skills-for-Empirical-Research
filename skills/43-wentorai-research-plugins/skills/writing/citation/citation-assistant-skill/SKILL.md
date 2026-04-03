---
name: citation-assistant-skill
description: "Claude Code skill for citation workflow via OpenAlex and CrossRef"
metadata:
  openclaw:
    emoji: "📎"
    category: "writing"
    subcategory: "citation"
    keywords: ["citation assistant", "OpenAlex", "Claude Code skill", "reference lookup", "academic citation"]
    source: "https://github.com/ZhangNy301/citation-assistant"
---

# Citation Assistant Skill Guide

## Overview

Citation Assistant is a Claude Code skill that integrates OpenAlex and CrossRef APIs into the coding workflow for instant paper lookup, citation formatting, and reference management. Search for papers by title or keyword, get formatted BibTeX entries, find related works, and insert citations — all without leaving the terminal. Designed for researchers writing papers in LaTeX or Markdown.

## Installation

```bash
# Add as Claude Code skill
# Copy SKILL.md to your Claude Code skills directory
# Or install via OpenClaw:
openclaw skills install citation-assistant
```

## Core Features

### Paper Search

```python
import requests

OA_API = "https://api.openalex.org"

def search_papers(query, limit=5):
    """Search OpenAlex for papers."""
    resp = requests.get(
        f"{OA_API}/works",
        params={
            "search": query,
            "per_page": limit,
        },
        headers={"User-Agent": "ResearchPlugins/1.0 (https://wentor.ai)"},
    )
    return resp.json().get("results", [])

papers = search_papers("attention mechanism transformer")
for p in papers:
    authors = [a["author"]["display_name"] for a in p.get("authorships", [])[:3]]
    print(f"[{p.get('publication_year')}] {p.get('title')}")
    print(f"  {', '.join(authors)} — Citations: {p.get('cited_by_count')}")
    print(f"  DOI: {p.get('doi', 'N/A')}")
```

### BibTeX Generation

```python
def get_bibtex(doi):
    """Get BibTeX for a paper via CrossRef DOI resolution."""
    resp = requests.get(
        f"https://api.crossref.org/works/{doi}",
        headers={"User-Agent": "ResearchPlugins/1.0 (https://wentor.ai; mailto:dev@wentor.ai)"},
    )
    msg = resp.json().get("message", {})

    # Generate citation key
    authors = msg.get("author", [])
    first_author = authors[0].get("family", "unknown").lower() if authors else "unknown"
    year = str(msg.get("published", {}).get("date-parts", [[""]])[0][0])
    key = f"{first_author}{year}"

    # Build BibTeX
    authors_str = " and ".join(f"{a.get('given', '')} {a.get('family', '')}".strip() for a in authors)
    doi_str = msg.get("DOI", "")

    title = msg.get("title", [""])[0] if isinstance(msg.get("title"), list) else msg.get("title", "")
    journal = msg.get("container-title", [""])[0] if msg.get("container-title") else ""

    bibtex = f"""@article{{{key},
  title = {{{title}}},
  author = {{{authors_str}}},
  year = {{{year}}},
  journal = {{{journal}}},
  doi = {{{doi_str}}},
}}"""
    return bibtex

# Example
bibtex = get_bibtex("10.18653/v1/N19-1423")
print(bibtex)
```

### Citation Context

```python
def get_citing_works(openalex_id, limit=10):
    """Get papers that cite this work via OpenAlex."""
    resp = requests.get(
        f"{OA_API}/works",
        params={
            "filter": f"cites:{openalex_id}",
            "per_page": limit,
            "sort": "cited_by_count:desc",
        },
        headers={"User-Agent": "ResearchPlugins/1.0 (https://wentor.ai)"},
    )
    results = resp.json().get("results", [])

    for paper in results:
        authors = [a["author"]["display_name"] for a in paper.get("authorships", [])[:3]]
        print(f"\n{paper.get('title')} ({paper.get('publication_year', '?')})")
        print(f"  Authors: {', '.join(authors)}")
        print(f"  Citations: {paper.get('cited_by_count', 0)}")

get_citing_works("W2741809807")
```

### Related Paper Discovery

```python
def find_related(openalex_id, limit=10):
    """Find papers related to a given paper via OpenAlex."""
    # Get the paper's concepts, then search for similar works
    resp = requests.get(
        f"{OA_API}/works/{openalex_id}",
        headers={"User-Agent": "ResearchPlugins/1.0 (https://wentor.ai)"},
    )
    paper = resp.json()
    concepts = [c["display_name"] for c in paper.get("concepts", [])[:3]]

    related_resp = requests.get(
        f"{OA_API}/works",
        params={
            "search": " ".join(concepts),
            "per_page": limit,
            "sort": "cited_by_count:desc",
        },
        headers={"User-Agent": "ResearchPlugins/1.0 (https://wentor.ai)"},
    )
    return related_resp.json().get("results", [])

related = find_related("W2741809807")
for p in related:
    print(f"[{p.get('publication_year')}] {p.get('title')} ({p.get('cited_by_count')} cites)")
```

## Workflow Integration

```markdown
### LaTeX Workflow
1. Search: "Find papers on transformer efficiency"
2. Select relevant papers from results
3. Generate BibTeX entries → append to references.bib
4. Insert \cite{key} in your .tex file

### Markdown Workflow
1. Search for papers while writing
2. Get formatted citation (APA, MLA, etc.)
3. Insert inline: (Author, Year) or [1]
4. Generate reference list at document end
```

## Batch Operations

```python
def build_bibliography(queries, output_file="refs.bib"):
    """Build BibTeX file from multiple search queries."""
    all_bibtex = []
    seen_ids = set()

    for query in queries:
        papers = search_papers(query, limit=3)
        for paper in papers:
            doi = paper.get("doi")
            if doi and doi not in seen_ids:
                seen_ids.add(doi)
                bibtex = get_bibtex(doi.replace("https://doi.org/", ""))

                all_bibtex.append(bibtex)

    with open(output_file, "w") as f:
        f.write("\n\n".join(all_bibtex))
    print(f"Wrote {len(all_bibtex)} entries to {output_file}")

build_bibliography([
    "attention mechanism",
    "transformer architecture",
    "BERT pre-training",
])
```

## Use Cases

1. **Paper writing**: Look up and format citations inline
2. **Literature review**: Discover related papers from seed papers
3. **Reference management**: Build BibTeX files from searches
4. **Citation analysis**: Explore how papers cite each other
5. **Quick lookup**: Find DOI, venue, citation count for any paper

## References

- [Citation Assistant GitHub](https://github.com/ZhangNy301/citation-assistant)
- [OpenAlex API](https://api.openalex.org/)
- [CrossRef API](https://api.crossref.org/)

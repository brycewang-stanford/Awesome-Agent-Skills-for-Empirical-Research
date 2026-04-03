---
name: plos-open-access-api
description: "Search PLOS open access journals with full-text Solr-powered API"
metadata:
  openclaw:
    emoji: "🔬"
    category: "literature"
    subcategory: "search"
    keywords: ["PLOS", "open access", "biomedical", "Solr search", "full text", "peer reviewed"]
    source: "https://api.plos.org/"
---

# PLOS Search API

## Overview

PLOS (Public Library of Science) publishes 7 peer-reviewed open access journals covering biology, medicine, genetics, and more. The Search API provides Solr-powered full-text search across all PLOS content — 350K+ articles, all freely available under CC-BY licenses. No authentication required. Particularly valuable for biomedical and life sciences systematic reviews.

## API Endpoint

### Base URL

```
https://api.plos.org/search
```

### Search Examples

```bash
# Basic keyword search
curl "https://api.plos.org/search?q=CRISPR+gene+editing&rows=20&wt=json"

# Search in specific fields
curl "https://api.plos.org/search?q=title:\"machine learning\"+AND+abstract:biomarker&wt=json"

# Filter by journal
curl "https://api.plos.org/search?q=microbiome&fq=journal:\"PLOS ONE\"&wt=json"

# Filter by date range
curl "https://api.plos.org/search?q=COVID-19+vaccine&\
fq=publication_date:[2024-01-01T00:00:00Z TO 2026-12-31T23:59:59Z]&wt=json"

# Filter by article type
curl "https://api.plos.org/search?q=climate+change&fq=article_type:\"Research Article\"&wt=json"

# Return specific fields only
curl "https://api.plos.org/search?q=deep+learning&fl=id,title,author,publication_date,score&wt=json"
```

### Search Fields

| Field | Description | Example |
|-------|-------------|---------|
| `title` | Article title | `title:"attention mechanism"` |
| `abstract` | Abstract text | `abstract:neural+network` |
| `body` | Full text body | `body:transformer` |
| `author` | Author name | `author:"Vaswani"` |
| `subject` | Subject area | `subject:"Neuroscience"` |
| `journal` | Journal name | `journal:"PLOS Medicine"` |

### Query Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `q` | Solr query (supports AND/OR/NOT) | Required |
| `fq` | Filter query (narrows without affecting score) | None |
| `fl` | Fields to return (comma-separated) | All |
| `rows` | Results per page (max 999) | 10 |
| `start` | Pagination offset | 0 |
| `sort` | Sort order | `score desc` |
| `wt` | Format: `json` or `xml` | `xml` |
| `hl` | Enable highlighting | `false` |

### Available Return Fields

| Field | Type | Description |
|-------|------|-------------|
| `id` | string | DOI |
| `title` | string | Article title |
| `author` | array | Author names |
| `abstract` | string | Abstract text |
| `body` | string | Full text (large) |
| `publication_date` | date | Publication date |
| `journal` | string | Journal name |
| `article_type` | string | Article type |
| `subject` | array | Subject categories |
| `score` | float | Relevance score |

### PLOS Journals

| Journal | Scope |
|---------|-------|
| PLOS ONE | Multidisciplinary |
| PLOS Biology | Life sciences |
| PLOS Medicine | Clinical medicine |
| PLOS Genetics | Genetics and genomics |
| PLOS Computational Biology | Computational biology |
| PLOS Pathogens | Infectious disease |
| PLOS Neglected Tropical Diseases | Tropical medicine |

## Python Usage

```python
import requests

BASE_URL = "https://api.plos.org/search"


def search_plos(query: str, rows: int = 20,
                journal: str = None,
                from_date: str = None,
                fields: str = None) -> list:
    """Search PLOS open access articles."""
    params = {
        "q": query,
        "wt": "json",
        "rows": rows,
        "fl": fields or "id,title,author,abstract,publication_date,journal,score",
    }

    fq_parts = []
    if journal:
        fq_parts.append(f'journal:"{journal}"')
    if from_date:
        fq_parts.append(
            f"publication_date:[{from_date}T00:00:00Z TO NOW]"
        )
    if fq_parts:
        params["fq"] = " AND ".join(fq_parts)

    resp = requests.get(BASE_URL, params=params)
    resp.raise_for_status()
    data = resp.json()

    results = []
    for doc in data.get("response", {}).get("docs", []):
        results.append({
            "doi": doc.get("id"),
            "title": doc.get("title"),
            "authors": doc.get("author", []),
            "date": doc.get("publication_date", "")[:10],
            "journal": doc.get("journal"),
            "abstract": (doc.get("abstract", [""])[0])[:300]
                        if isinstance(doc.get("abstract"), list)
                        else (doc.get("abstract", ""))[:300],
        })
    return results


def get_full_text(doi: str) -> str:
    """Retrieve full text body of a PLOS article."""
    params = {
        "q": f'id:"{doi}"',
        "fl": "body",
        "wt": "json",
    }
    resp = requests.get(BASE_URL, params=params)
    resp.raise_for_status()
    docs = resp.json().get("response", {}).get("docs", [])
    return docs[0].get("body", "") if docs else ""


# Example: search PLOS Computational Biology
papers = search_plos(
    "protein structure prediction",
    journal="PLOS Computational Biology",
    from_date="2024-01-01",
)
for p in papers:
    print(f"[{p['date']}] {p['title']}")
    print(f"  DOI: {p['doi']}")

# Example: full-text search across all PLOS
papers = search_plos("body:reinforcement+learning AND title:robot")
for p in papers:
    print(f"{p['title']} — {p['journal']}")
```

## Advanced Solr Queries

```bash
# Phrase proximity search (words within 5 of each other)
q=abstract:"machine learning"~5

# Boosted field search
q=title:"CRISPR"^2 OR abstract:"CRISPR"

# Wildcard search
q=title:neuro*

# Range query on dates
fq=publication_date:[2024-01-01T00:00:00Z TO 2024-12-31T23:59:59Z]
```

## Rate Limits

No formal rate limit, but PLOS requests courtesy delays of 1 request per second for bulk operations. No authentication needed.

## References

- [PLOS API Documentation](https://api.plos.org/)
- [PLOS Search Tips](https://journals.plos.org/plosone/s/search)
- [Solr Query Syntax](https://solr.apache.org/guide/solr/latest/query-guide/standard-query-parser.html)

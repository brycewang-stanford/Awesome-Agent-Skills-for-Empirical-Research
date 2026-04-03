---
name: citeseerx-api
description: "Search computer science literature via the CiteSeerX digital library"
metadata:
  openclaw:
    emoji: "📄"
    category: "literature"
    subcategory: "search"
    keywords: ["CiteSeerX", "computer science", "citation index", "academic search", "CS literature", "autonomous citation"]
    source: "https://citeseerx.ist.psu.edu/"
---

# CiteSeerX API

## Overview

CiteSeerX is a scientific literature digital library focusing on computer and information science, with 10M+ documents and 100M+ citations. It provides autonomous citation indexing — extracting and linking citations without manual curation. The API supports document search, citation lookup, and metadata retrieval. Free, no authentication required.

## API Endpoints

### Base URL

```
https://citeseerx.ist.psu.edu/api
```

### Document Search

```bash
# Keyword search
curl "https://citeseerx.ist.psu.edu/api/search?q=graph+neural+networks&start=0&rows=20"

# Search by title
curl "https://citeseerx.ist.psu.edu/api/search?q=title:attention+is+all+you+need"

# Search by author
curl "https://citeseerx.ist.psu.edu/api/search?q=author:hinton&rows=25"

# Filter by year
curl "https://citeseerx.ist.psu.edu/api/search?q=federated+learning&year=2024"

# Sort by citation count
curl "https://citeseerx.ist.psu.edu/api/search?q=reinforcement+learning&sort=citationCount+desc"
```

### Get Document by ID

```bash
# Get document metadata
curl "https://citeseerx.ist.psu.edu/api/document?doi=10.1.1.123.456"

# Get citations for a document
curl "https://citeseerx.ist.psu.edu/api/citations?doi=10.1.1.123.456"

# Get citing documents
curl "https://citeseerx.ist.psu.edu/api/citedby?doi=10.1.1.123.456"
```

### Query Parameters

| Parameter | Description | Example |
|-----------|-------------|---------|
| `q` | Search query | `q=deep+learning` |
| `start` | Pagination offset | `start=20` |
| `rows` | Results per page | `rows=50` |
| `sort` | Sort field | `citationCount desc` |
| `year` | Filter by year | `year=2024` |
| `doi` | CiteSeerX document ID | `doi=10.1.1.123.456` |

## Response Structure

```json
{
  "response": {
    "numFound": 5200,
    "docs": [
      {
        "id": "10.1.1.123.456",
        "title": "Graph Neural Networks: A Review",
        "authors": ["Zhou, Jie", "Cui, Ganqu"],
        "year": 2020,
        "abstract": "Graph neural networks have been widely applied...",
        "venue": "AI Open",
        "citationCount": 3500,
        "url": "https://citeseerx.ist.psu.edu/doc/10.1.1.123.456"
      }
    ]
  }
}
```

## Python Usage

```python
import requests

BASE_URL = "https://citeseerx.ist.psu.edu/api"


def search_citeseerx(query: str, rows: int = 20,
                     sort_by_citations: bool = False) -> list:
    """Search CiteSeerX computer science literature."""
    params = {
        "q": query,
        "rows": rows,
        "start": 0,
    }
    if sort_by_citations:
        params["sort"] = "citationCount desc"

    resp = requests.get(f"{BASE_URL}/search", params=params, timeout=30)
    resp.raise_for_status()
    data = resp.json()

    results = []
    for doc in data.get("response", {}).get("docs", []):
        results.append({
            "id": doc.get("id"),
            "title": doc.get("title"),
            "authors": doc.get("authors", []),
            "year": doc.get("year"),
            "venue": doc.get("venue"),
            "citations": doc.get("citationCount", 0),
            "abstract": doc.get("abstract", "")[:300],
            "url": doc.get("url"),
        })
    return results


def get_citations(doc_id: str) -> list:
    """Get papers cited by a document."""
    resp = requests.get(
        f"{BASE_URL}/citations",
        params={"doi": doc_id},
        timeout=30,
    )
    resp.raise_for_status()
    return resp.json().get("citations", [])


def get_cited_by(doc_id: str) -> list:
    """Get papers that cite a document."""
    resp = requests.get(
        f"{BASE_URL}/citedby",
        params={"doi": doc_id},
        timeout=30,
    )
    resp.raise_for_status()
    return resp.json().get("citedby", [])


# Example: find most-cited CS papers on a topic
papers = search_citeseerx("knowledge distillation",
                          rows=10, sort_by_citations=True)
for p in papers:
    print(f"[{p['year']}] {p['title']} (cited: {p['citations']})")

# Example: citation chain analysis
if papers:
    refs = get_citations(papers[0]["id"])
    print(f"\nReferences of top paper ({len(refs)} citations):")
    for r in refs[:5]:
        print(f"  -> {r.get('title', 'Unknown')}")
```

## Unique Features

- **Autonomous citation indexing**: Automatically extracts and links citations from PDF
- **CS focus**: Deep coverage of computer science subdisciplines
- **Citation graph**: Full bidirectional citation linking
- **Free PDF access**: Links to crawled open-access PDFs

## Limitations

- Primarily CS/information science (limited other fields)
- Some metadata may be noisy (auto-extracted from PDF)
- Coverage strongest for older papers (2000-2020)

## References

- [CiteSeerX](https://citeseerx.ist.psu.edu/)
- [CiteSeerX Documentation](https://citeseerx.ist.psu.edu/about)
- Giles, C.L., Bollacker, K.D., Lawrence, S. (1998). "CiteSeer: An Automatic Citation Indexing System." *ACM DL*.

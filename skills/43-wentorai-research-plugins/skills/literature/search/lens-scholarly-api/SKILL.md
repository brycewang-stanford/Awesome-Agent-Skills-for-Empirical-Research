---
name: lens-scholarly-api
description: "Search 300M+ scholarly and patent records via the Lens.org API"
metadata:
  openclaw:
    emoji: "🔎"
    category: "literature"
    subcategory: "search"
    keywords: ["Lens.org", "patent search", "scholarly search", "citation linking", "innovation", "prior art"]
    source: "https://www.lens.org/"
---

# Lens.org Scholarly and Patent API

## Overview

Lens.org provides unified access to 300M+ scholarly articles and 150M+ patent records with cross-linkage between them. Uniquely, Lens connects academic research to patent citations, enabling innovation tracking and prior art discovery. The API offers full-text search, citation analysis, and patent-paper linkage. Free for non-commercial use with registration (up to 1,000 requests/day).

## Authentication

```bash
# Register at https://www.lens.org/lens/user/subscriptions
# API token provided in your account settings
# Include in header: Authorization: Bearer YOUR_TOKEN
```

## API Endpoints

### Scholarly Search

```bash
# POST-based search
curl -X POST "https://api.lens.org/scholarly/search" \
  -H "Authorization: Bearer $LENS_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "query": {
      "match": {"field_of_study": "machine learning"}
    },
    "size": 20,
    "from": 0,
    "sort": [{"year_published": "desc"}]
  }'

# Boolean query
curl -X POST "https://api.lens.org/scholarly/search" \
  -H "Authorization: Bearer $LENS_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "query": {
      "bool": {
        "must": [
          {"match": {"title": "transformer"}},
          {"range": {"year_published": {"gte": 2023}}}
        ],
        "should": [
          {"match": {"abstract": "attention mechanism"}}
        ]
      }
    },
    "size": 25
  }'
```

### Patent Search

```bash
curl -X POST "https://api.lens.org/patent/search" \
  -H "Authorization: Bearer $LENS_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "query": {
      "bool": {
        "must": [
          {"match": {"title": "neural network"}},
          {"term": {"jurisdiction": "US"}}
        ]
      }
    },
    "size": 20
  }'
```

### Scholarly Fields

| Field | Description | Type |
|-------|-------------|------|
| `title` | Article title | text |
| `abstract` | Abstract text | text |
| `author.display_name` | Author name | text |
| `year_published` | Publication year | integer |
| `source.title` | Journal/venue name | text |
| `field_of_study` | Research field | text |
| `doi` | DOI identifier | keyword |
| `pmid` | PubMed ID | keyword |
| `citing_patent_count` | Patents citing this work | integer |
| `scholarly_citations_count` | Citation count | integer |
| `open_access.is_oa` | Open access status | boolean |

## Python Usage

```python
import os
import requests

TOKEN = os.environ["LENS_API_TOKEN"]
BASE_URL = "https://api.lens.org"
HEADERS = {
    "Authorization": f"Bearer {TOKEN}",
    "Content-Type": "application/json",
}


def search_scholarly(query: str, size: int = 20,
                     min_year: int = None,
                     fields: list = None) -> list:
    """Search Lens scholarly records."""
    must_clauses = [{"match": {"title": query}}]
    if min_year:
        must_clauses.append(
            {"range": {"year_published": {"gte": min_year}}}
        )

    body = {
        "query": {"bool": {"must": must_clauses}},
        "size": size,
        "sort": [{"scholarly_citations_count": "desc"}],
    }
    if fields:
        body["include"] = fields

    resp = requests.post(
        f"{BASE_URL}/scholarly/search",
        headers=HEADERS,
        json=body,
    )
    resp.raise_for_status()
    data = resp.json()

    results = []
    for doc in data.get("data", []):
        results.append({
            "title": doc.get("title"),
            "authors": [a.get("display_name", "")
                        for a in doc.get("authors", [])[:5]],
            "year": doc.get("year_published"),
            "source": doc.get("source", {}).get("title"),
            "doi": doc.get("doi"),
            "citations": doc.get("scholarly_citations_count", 0),
            "patent_citations": doc.get("citing_patent_count", 0),
            "open_access": doc.get("open_access", {}).get("is_oa"),
        })
    return results


def find_patent_cited_papers(topic: str, min_patents: int = 5) -> list:
    """Find papers cited by patents (innovation indicators)."""
    body = {
        "query": {
            "bool": {
                "must": [
                    {"match": {"title": topic}},
                    {"range": {"citing_patent_count": {"gte": min_patents}}},
                ]
            }
        },
        "size": 50,
        "sort": [{"citing_patent_count": "desc"}],
    }

    resp = requests.post(
        f"{BASE_URL}/scholarly/search",
        headers=HEADERS,
        json=body,
    )
    resp.raise_for_status()
    return resp.json().get("data", [])


# Example: find high-impact ML papers cited by patents
papers = search_scholarly("deep learning", size=10, min_year=2020)
for p in papers:
    print(f"[{p['year']}] {p['title']}")
    print(f"  Citations: {p['citations']} scholarly, "
          f"{p['patent_citations']} patent")

# Example: find industry-impactful research
patent_cited = find_patent_cited_papers("battery technology")
for doc in patent_cited[:5]:
    print(f"{doc['title']} — {doc.get('citing_patent_count')} patents")
```

## Unique Features

- **Patent-paper linkage**: Discover which research is cited in patents
- **Unified search**: Scholarly + patent in one platform
- **Innovation metrics**: Track technology transfer from academia to industry
- **Prior art search**: Find relevant literature for patent applications

## Rate Limits

| Tier | Daily requests | Results per query |
|------|---------------|-------------------|
| Free (non-commercial) | 1,000 | 1,000 |
| Institutional | 10,000+ | 10,000 |

## References

- [Lens.org](https://www.lens.org/)
- [Lens API Documentation](https://docs.api.lens.org/)
- [Lens Scholarly Search](https://www.lens.org/lens/search/scholar/list)

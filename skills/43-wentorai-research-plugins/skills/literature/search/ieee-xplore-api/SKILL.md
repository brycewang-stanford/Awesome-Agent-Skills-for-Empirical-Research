---
name: ieee-xplore-api
description: "Search IEEE's 6M+ engineering and CS publications via the Xplore API"
metadata:
  openclaw:
    emoji: "🔌"
    category: "literature"
    subcategory: "search"
    keywords: ["ieee", "engineering literature", "computer science", "technical standards", "conference papers", "xplore"]
    source: "https://developer.ieee.org/"
---

# IEEE Xplore API

## Overview

IEEE Xplore provides access to over 6 million technical documents — journal articles, conference proceedings, technical standards, and books — covering electrical engineering, computer science, and related fields. The API enables metadata search, full-text access (with subscription), and DOI-based batch lookup. Requires an API key (free registration) and institutional subscription for full features.

## API Endpoints

### Base URL

```
https://ieeexploreapi.ieee.org/api/v1/search/articles
```

### Metadata Search

```bash
# Basic keyword search
curl "https://ieeexploreapi.ieee.org/api/v1/search/articles?\
apikey=YOUR_API_KEY&\
querytext=transformer+attention+mechanism&\
max_records=25"

# Search with filters
curl "https://ieeexploreapi.ieee.org/api/v1/search/articles?\
apikey=YOUR_API_KEY&\
querytext=federated+learning&\
start_year=2022&\
end_year=2026&\
content_type=Conferences&\
max_records=50"
```

### Query Parameters

| Parameter | Description | Example |
|-----------|-------------|---------|
| `apikey` | API key (required) | `apikey=YOUR_KEY` |
| `querytext` | Free-text search | `querytext=neural+network` |
| `article_title` | Title search | `article_title=BERT` |
| `author` | Author name | `author=Vaswani` |
| `abstract` | Abstract search | `abstract=reinforcement+learning` |
| `index_terms` | IEEE keyword terms | `index_terms=machine+learning` |
| `d-au` | Exact author | `d-au=Yann+LeCun` |
| `start_year` | From year | `start_year=2020` |
| `end_year` | To year | `end_year=2026` |
| `content_type` | Document type | `Journals`, `Conferences`, `Standards`, `Books` |
| `publication_title` | Venue name | `publication_title=CVPR` |
| `max_records` | Results (max 200) | `max_records=50` |
| `start_record` | Pagination offset | `start_record=51` |
| `sort_field` | Sort by | `article_date`, `article_title` |
| `sort_order` | Sort direction | `asc` or `desc` |

### Boolean Search

```bash
# Boolean operators: AND, OR, NOT
querytext=(machine AND learning) NOT survey

# Phrase search
querytext="graph neural network"

# Field-specific boolean
article_title="attention" AND author="Vaswani"
```

### DOI Batch Lookup

```bash
# Look up up to 25 DOIs at once
curl "https://ieeexploreapi.ieee.org/api/v1/search/articles?\
apikey=YOUR_API_KEY&\
doi=10.1109/CVPR.2024.12345&\
doi=10.1109/TPAMI.2023.67890"
```

## Response Structure

```json
{
  "total_records": 1250,
  "articles": [
    {
      "title": "Article Title",
      "authors": {
        "authors": [
          {"full_name": "Author Name", "affiliation": "University"}
        ]
      },
      "abstract": "The abstract text...",
      "publication_title": "IEEE CVPR 2024",
      "content_type": "Conferences",
      "doi": "10.1109/CVPR.2024.12345",
      "publication_date": "2024-06-01",
      "start_page": "100",
      "end_page": "110",
      "citing_paper_count": 15,
      "pdf_url": "https://ieeexplore.ieee.org/stamp/stamp.jsp?tp=&arnumber=12345",
      "html_url": "https://ieeexplore.ieee.org/document/12345"
    }
  ]
}
```

## Python Usage

```python
import os
import requests

API_KEY = os.environ["IEEE_API_KEY"]
BASE_URL = "https://ieeexploreapi.ieee.org/api/v1/search/articles"

def search_ieee(query: str, max_results: int = 25,
                content_type: str = None, start_year: int = None) -> list:
    """Search IEEE Xplore for technical publications."""
    params = {
        "apikey": API_KEY,
        "querytext": query,
        "max_records": max_results,
        "sort_field": "article_date",
        "sort_order": "desc"
    }
    if content_type:
        params["content_type"] = content_type
    if start_year:
        params["start_year"] = start_year

    resp = requests.get(BASE_URL, params=params)
    resp.raise_for_status()
    data = resp.json()

    results = []
    for article in data.get("articles", []):
        authors = [a["full_name"] for a in article.get("authors", {}).get("authors", [])]
        results.append({
            "title": article.get("title"),
            "authors": authors,
            "venue": article.get("publication_title"),
            "year": article.get("publication_date", "")[:4],
            "doi": article.get("doi"),
            "citations": article.get("citing_paper_count", 0),
            "url": article.get("html_url")
        })
    return results

# Example
papers = search_ieee("edge computing IoT", content_type="Journals", start_year=2023)
for p in papers:
    print(f"[{p['year']}] {p['title']} — {p['venue']} (cited: {p['citations']})")
```

## Access Tiers

| Tier | Access Level | Requirements |
|------|-------------|-------------|
| **Free** | Metadata + abstracts | API key registration |
| **Open Access** | Full text of OA articles | API key |
| **Institutional** | Full text of all articles | API key + subscription |

## References

- [IEEE Xplore API Portal](https://developer.ieee.org/)
- [API Documentation](https://developer.ieee.org/docs)
- [IEEE Xplore Digital Library](https://ieeexplore.ieee.org/)

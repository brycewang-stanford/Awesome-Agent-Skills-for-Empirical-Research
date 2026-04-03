---
name: base-academic-search
description: "Search 400M+ open access documents via the BASE search engine API"
metadata:
  openclaw:
    emoji: "🔍"
    category: "literature"
    subcategory: "search"
    keywords: ["BASE", "academic search", "open access", "Bielefeld", "OAI-PMH", "repository aggregator"]
    source: "https://www.base-search.net/"
---

# BASE (Bielefeld Academic Search Engine) API

## Overview

BASE is one of the world's largest search engines for academic open access web resources. Operated by Bielefeld University Library, it indexes 400M+ documents from 11,000+ content providers including institutional repositories, preprint servers, and digital libraries. Unlike Google Scholar, BASE provides structured metadata, license information, and full-text links. The API is free with registration.

## API Endpoints

### Base URL

```
https://api.base-search.net/cgi-bin/BaseHttpSearchInterface.fcgi
```

### Search

```bash
# Basic keyword search (JSON response)
curl "https://api.base-search.net/cgi-bin/BaseHttpSearchInterface.fcgi?\
func=PerformSearch&query=climate+change+adaptation&format=json&hits=20"

# Search with field filters
curl "https://api.base-search.net/cgi-bin/BaseHttpSearchInterface.fcgi?\
func=PerformSearch&query=dctitle:transformer+AND+dcsubject:NLP&format=json"

# Filter by document type and year
curl "https://api.base-search.net/cgi-bin/BaseHttpSearchInterface.fcgi?\
func=PerformSearch&query=deep+learning&dctypenorm=121&dcyear:2024&format=json"

# Open access only
curl "https://api.base-search.net/cgi-bin/BaseHttpSearchInterface.fcgi?\
func=PerformSearch&query=CRISPR&dcrights:open&format=json"
```

### Search Fields

| Field | Description | Example |
|-------|-------------|---------|
| `dctitle` | Title | `dctitle:attention+mechanism` |
| `dccreator` | Author | `dccreator:vaswani` |
| `dcsubject` | Subject/keywords | `dcsubject:machine+learning` |
| `dcdescription` | Abstract | `dcdescription:neural+network` |
| `dcyear` | Publication year | `dcyear:2024` |
| `dctype` | Document type text | `dctype:article` |
| `dctypenorm` | Normalized type code | `121` (journal article) |
| `dcrights` | Access rights | `dcrights:open` |
| `dclang` | Language | `dclang:eng` |
| `dclink` | Source URL | `dclink:arxiv.org` |
| `dcoa` | Open access status | `dcoa:1` (OA), `dcoa:2` (restricted) |
| `dcprovider` | Content provider | `dcprovider:arxiv.org` |

### Document Type Codes

| Code | Type |
|------|------|
| `121` | Journal article |
| `122` | Book / monograph |
| `14` | Conference paper |
| `15` | Thesis / dissertation |
| `17` | Report |
| `18` | Preprint |

### Query Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `func` | Must be `PerformSearch` | Required |
| `query` | Search query with optional field prefixes | Required |
| `format` | Response format: `json` or `xml` | `xml` |
| `hits` | Results per page (max 125) | 10 |
| `offset` | Pagination offset | 0 |
| `sortby` | Sort: `dcyear desc`, `score desc` | relevance |

## Response Structure

```json
{
  "response": {
    "numFound": 45200,
    "start": 0,
    "docs": [
      {
        "dctitle": "Attention Is All You Need",
        "dccreator": ["Ashish Vaswani", "Noam Shazeer"],
        "dcyear": "2017",
        "dcsubject": ["machine learning", "attention mechanism"],
        "dcdescription": "The dominant sequence transduction models...",
        "dcidentifier": "https://arxiv.org/abs/1706.03762",
        "dcsource": "arXiv.org",
        "dcprovider": "arxiv.org",
        "dcdocid": "abc123xyz",
        "dcoa": 1,
        "dctypenorm": ["18"],
        "dclang": ["eng"]
      }
    ]
  }
}
```

## Python Usage

```python
import requests

BASE_URL = "https://api.base-search.net/cgi-bin/BaseHttpSearchInterface.fcgi"


def search_base(query: str, hits: int = 20,
                doc_type: int = None, oa_only: bool = False) -> list:
    """Search BASE for academic open access documents."""
    q = query
    if doc_type:
        q += f" AND dctypenorm:{doc_type}"
    if oa_only:
        q += " AND dcoa:1"

    params = {
        "func": "PerformSearch",
        "query": q,
        "format": "json",
        "hits": hits,
        "sortby": "dcyear desc",
    }

    resp = requests.get(BASE_URL, params=params)
    resp.raise_for_status()
    data = resp.json()

    results = []
    for doc in data.get("response", {}).get("docs", []):
        results.append({
            "title": doc.get("dctitle"),
            "authors": doc.get("dccreator", []),
            "year": doc.get("dcyear"),
            "source": doc.get("dcsource"),
            "url": doc.get("dcidentifier"),
            "abstract": (doc.get("dcdescription") or "")[:300],
            "open_access": doc.get("dcoa") == 1,
            "type": doc.get("dctypenorm", []),
        })
    return results


def search_dissertations(topic: str, lang: str = "eng") -> list:
    """Find dissertations and theses on a topic."""
    query = f"{topic} AND dctypenorm:15 AND dclang:{lang}"
    return search_base(query, hits=50)


def search_by_provider(query: str, provider: str) -> list:
    """Search within a specific content provider."""
    full_query = f"{query} AND dcprovider:{provider}"
    return search_base(full_query)


# Example: find recent open access ML papers
papers = search_base("transformer self-attention", hits=10, oa_only=True)
for p in papers:
    oa = "OA" if p["open_access"] else "restricted"
    print(f"[{p['year']}] {p['title']} ({oa}) — {p['source']}")

# Example: find dissertations on climate modeling
theses = search_dissertations("climate modeling ocean")
for t in theses:
    print(f"[{t['year']}] {t['title']} — {', '.join(t['authors'][:2])}")
```

## BASE vs Other Search Engines

| Feature | BASE | Google Scholar | OpenAlex |
|---------|------|---------------|----------|
| Records | 400M+ | Unknown | 250M+ |
| Open access focus | Yes | No | Yes |
| Structured API | Yes | No official API | Yes |
| License metadata | Yes | No | Partial |
| Dissertation coverage | Excellent | Good | Limited |
| Repository-level filtering | Yes | No | No |

## References

- [BASE Search Engine](https://www.base-search.net/)
- [BASE API Documentation](https://www.base-search.net/about/en/about_develop.php)
- [BASE Content Providers](https://www.base-search.net/about/en/about_sources.php)

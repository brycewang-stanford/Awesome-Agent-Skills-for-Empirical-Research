---
name: mendeley-api
description: "Manage references and search Mendeley's catalog via REST API"
metadata:
  openclaw:
    emoji: "📚"
    category: "writing"
    subcategory: "citation"
    keywords: ["mendeley", "reference manager", "bibliography", "catalog search", "research library", "citations"]
    source: "wentor-research-plugins"
---

# Mendeley REST API

## Overview

Mendeley provides a reference management platform with a REST API for programmatic access to personal libraries, group collections, and the Mendeley Catalog — a crowdsourced database of 200M+ academic documents. The API supports OAuth 2.0 authentication, CRUD operations on documents/folders/annotations, and catalog search with rich metadata. Free tier available with registration.

## Authentication

Mendeley uses OAuth 2.0 with client credentials or authorization code flow.

```bash
# 1. Register app at https://dev.elsevier.com/
# 2. Get access token via client credentials (for catalog search)
curl -X POST "https://api.mendeley.com/oauth/token" \
  -d "grant_type=client_credentials" \
  -d "scope=all" \
  -d "client_id=$MENDELEY_CLIENT_ID" \
  -d "client_secret=$MENDELEY_CLIENT_SECRET"

# Response: { "access_token": "...", "expires_in": 3600, "token_type": "bearer" }
```

## API Endpoints

### Base URL

```
https://api.mendeley.com
```

### Catalog Search

Search across Mendeley's 200M+ document database:

```bash
# Search by title/keywords
curl -H "Authorization: Bearer $TOKEN" \
  "https://api.mendeley.com/catalog?query=deep+learning+NLP&limit=20"

# Search by DOI
curl -H "Authorization: Bearer $TOKEN" \
  "https://api.mendeley.com/catalog?doi=10.1038/nature14539"

# Search by title
curl -H "Authorization: Bearer $TOKEN" \
  "https://api.mendeley.com/catalog?title=attention+is+all+you+need"
```

### User Library

```bash
# List documents in personal library
curl -H "Authorization: Bearer $TOKEN" \
  "https://api.mendeley.com/documents?limit=50&sort=created&order=desc"

# Get document details
curl -H "Authorization: Bearer $TOKEN" \
  "https://api.mendeley.com/documents/{doc_id}"

# Add document to library
curl -X POST -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/vnd.mendeley-document.1+json" \
  -d '{"title":"My Paper","type":"journal","year":2025,"authors":[{"first_name":"A","last_name":"B"}]}' \
  "https://api.mendeley.com/documents"
```

### Folders and Groups

```bash
# List folders
curl -H "Authorization: Bearer $TOKEN" \
  "https://api.mendeley.com/folders"

# List group documents
curl -H "Authorization: Bearer $TOKEN" \
  "https://api.mendeley.com/documents?group_id={group_id}"
```

### Annotations

```bash
# Get annotations for a document
curl -H "Authorization: Bearer $TOKEN" \
  "https://api.mendeley.com/annotations?document_id={doc_id}"
```

## Query Parameters

| Parameter | Description | Example |
|-----------|-------------|---------|
| `query` | Free-text search | `query=transformer+model` |
| `doi` | DOI lookup | `doi=10.1234/example` |
| `title` | Title search | `title=BERT` |
| `author` | Author filter | `author=LeCun` |
| `min_year` | From year | `min_year=2020` |
| `max_year` | To year | `max_year=2026` |
| `limit` | Results per page (max 500) | `limit=50` |
| `sort` | Sort field | `created`, `title`, `year` |
| `order` | Sort direction | `asc` or `desc` |
| `view` | Response detail | `bib` (bibliographic), `stats` (reader counts) |

## Catalog Response

```json
{
  "id": "abc123-...",
  "title": "Attention Is All You Need",
  "type": "conference_proceedings",
  "year": 2017,
  "authors": [
    {"first_name": "Ashish", "last_name": "Vaswani"}
  ],
  "source": "NeurIPS",
  "identifiers": {
    "doi": "10.5555/3295222.3295349",
    "arxiv": "1706.03762"
  },
  "keywords": ["attention mechanism", "transformer"],
  "abstract": "The dominant sequence transduction models...",
  "reader_count": 15432,
  "link": "https://www.mendeley.com/catalogue/..."
}
```

## Python Usage

```python
import os
import requests

CLIENT_ID = os.environ["MENDELEY_CLIENT_ID"]
CLIENT_SECRET = os.environ["MENDELEY_CLIENT_SECRET"]
TOKEN_URL = "https://api.mendeley.com/oauth/token"
BASE_URL = "https://api.mendeley.com"


def get_token() -> str:
    """Obtain access token via client credentials."""
    resp = requests.post(TOKEN_URL, data={
        "grant_type": "client_credentials",
        "scope": "all",
        "client_id": CLIENT_ID,
        "client_secret": CLIENT_SECRET,
    })
    resp.raise_for_status()
    return resp.json()["access_token"]


def search_catalog(query: str, limit: int = 20,
                   min_year: int = None) -> list:
    """Search the Mendeley catalog."""
    token = get_token()
    params = {"query": query, "limit": limit, "view": "bib"}
    if min_year:
        params["min_year"] = min_year

    resp = requests.get(
        f"{BASE_URL}/catalog",
        headers={"Authorization": f"Bearer {token}"},
        params=params,
    )
    resp.raise_for_status()

    results = []
    for doc in resp.json():
        results.append({
            "title": doc.get("title"),
            "authors": [f"{a['first_name']} {a['last_name']}"
                        for a in doc.get("authors", [])],
            "year": doc.get("year"),
            "source": doc.get("source"),
            "doi": doc.get("identifiers", {}).get("doi"),
            "readers": doc.get("reader_count", 0),
        })
    return results


def lookup_by_doi(doi: str) -> dict:
    """Look up a single document by DOI."""
    token = get_token()
    resp = requests.get(
        f"{BASE_URL}/catalog",
        headers={"Authorization": f"Bearer {token}"},
        params={"doi": doi, "view": "bib"},
    )
    resp.raise_for_status()
    items = resp.json()
    return items[0] if items else {}


# Example
papers = search_catalog("federated learning privacy", min_year=2023)
for p in papers:
    print(f"[{p['year']}] {p['title']} — readers: {p['readers']}")
```

## Reader Statistics

Mendeley tracks how many users have saved each paper, providing a real-time measure of scholarly interest (unlike citation counts which lag by months).

```python
def get_popular_papers(topic: str, limit: int = 10) -> list:
    """Find most-read papers on a topic via reader counts."""
    results = search_catalog(topic, limit=limit)
    return sorted(results, key=lambda x: x["readers"], reverse=True)
```

## Rate Limits

| Tier | Requests/hour | Catalog access |
|------|--------------|----------------|
| Free | 150 | Read-only catalog + personal library |
| Institutional | Higher | Full API access |

## References

- [Mendeley API Documentation](wentor-research-plugins)
- [Mendeley Developer Portal](https://dev.elsevier.com/)
- [Mendeley API Reference](https://api.mendeley.com/apidocs/)

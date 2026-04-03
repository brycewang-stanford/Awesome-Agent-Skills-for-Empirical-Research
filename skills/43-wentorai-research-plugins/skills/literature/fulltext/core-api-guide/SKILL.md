---
name: core-api-guide
description: "Search and retrieve open access research papers via CORE aggregator"
metadata:
  openclaw:
    emoji: "🔬"
    category: "literature"
    subcategory: "fulltext"
    keywords: ["open-access", "fulltext", "research-papers", "aggregator", "CORE"]
    source: "https://core.ac.uk/documentation/api"
---

# CORE API Guide

## Overview

CORE (COnnecting REpositories) is the world's largest aggregator of open access research papers, providing access to over 130 million articles harvested from thousands of data providers worldwide. The CORE API enables programmatic search, retrieval, and analysis of scholarly full-text content across repositories, journals, and preprint servers.

The API is particularly valuable for researchers conducting systematic reviews, bibliometric analyses, and literature mining tasks. Unlike many scholarly APIs that only provide metadata, CORE specializes in delivering full-text content, making it essential for text mining and natural language processing workflows in academic research.

CORE's v3 API provides a RESTful interface with JSON responses, supporting complex search queries with Boolean operators, field-specific filtering, and batch operations. It is free for non-commercial academic use, though an API key is required to access the service.

## Authentication

CORE requires a free API key for all requests. Register at https://core.ac.uk/services/api to obtain one.

Always store your API key in an environment variable and reference it in requests:

```bash
export CORE_API_KEY=$CORE_API_KEY
```

Pass the key via the `Authorization` header:

```bash
curl -H "Authorization: Bearer $CORE_API_KEY" \
  "https://api.core.ac.uk/v3/search/works?q=machine+learning"
```

## Core Endpoints

### Search Works

Search across the entire CORE corpus with full-text and metadata queries.

```
GET https://api.core.ac.uk/v3/search/works?q={query}&limit={n}&offset={n}
```

**Parameters:**
- `q` (required): Search query string, supports Boolean operators (AND, OR, NOT)
- `limit`: Number of results (default 10, max 100)
- `offset`: Pagination offset
- `entity_type`: Filter by type (e.g., `journal-article`, `preprint`)

**Example: Search for climate change papers with full text:**

```bash
curl -s -H "Authorization: Bearer $CORE_API_KEY" \
  "https://api.core.ac.uk/v3/search/works?q=climate+change+adaptation&limit=5" \
  | python3 -m json.tool
```

**Python example:**

```python
import requests
import os

headers = {"Authorization": f"Bearer {os.environ['CORE_API_KEY']}"}
params = {
    "q": "deep learning AND medical imaging",
    "limit": 20,
    "offset": 0
}
resp = requests.get("https://api.core.ac.uk/v3/search/works", headers=headers, params=params)
data = resp.json()

for result in data.get("results", []):
    print(f"Title: {result.get('title')}")
    print(f"DOI: {result.get('doi')}")
    print(f"Year: {result.get('yearPublished')}")
    print(f"Full text length: {len(result.get('fullText', ''))}")
    print("---")
```

### Get Work by ID

Retrieve a specific paper by its CORE ID or DOI.

```
GET https://api.core.ac.uk/v3/works/{core_id}
```

```bash
curl -s -H "Authorization: Bearer $CORE_API_KEY" \
  "https://api.core.ac.uk/v3/works/doi:10.1234/example.doi" \
  | python3 -m json.tool
```

### Batch Retrieval

Retrieve multiple works in a single request using POST with a list of IDs.

```bash
curl -s -X POST -H "Authorization: Bearer $CORE_API_KEY" \
  -H "Content-Type: application/json" \
  -d '[12345, 67890, 11111]' \
  "https://api.core.ac.uk/v3/works"
```

### Search Data Providers

List or search CORE's data providers (repositories, journals).

```
GET https://api.core.ac.uk/v3/data-providers?q={query}
```

## Common Research Patterns

**Systematic Literature Review:** Use Boolean queries to replicate a search strategy across the full-text corpus. Combine with date filters to identify papers within a specific time window, then export results for screening in tools like Rayyan or Covidence.

**Full-Text Mining:** Retrieve full-text content programmatically for NLP pipelines. Extract named entities, key phrases, or citation contexts at scale across thousands of papers.

**Repository Coverage Analysis:** Query data providers to understand which institutional repositories contribute to a specific field, useful for bibliometric and open-access policy research.

**Trend Detection:** Run time-series queries for specific terms and track publication volume over years to identify emerging research fronts.

## Rate Limits and Best Practices

- **Free tier:** 150 requests per 15-minute window (10 req/min effective)
- **Batch endpoints:** Use batch retrieval for multiple IDs to minimize request count
- **Pagination:** Always use `offset` and `limit` for large result sets; do not fetch all results in one call
- **Caching:** Cache responses locally for repeat queries, especially for static metadata
- **Respect robots.txt:** When downloading full texts, add delays between requests
- **Error handling:** The API returns standard HTTP status codes; implement exponential backoff for 429 (rate limit) responses

## References

- CORE API v3 Documentation: https://core.ac.uk/documentation/api
- CORE Dashboard and Key Registration: https://core.ac.uk/services/api
- CORE Data Dumps (for bulk access): https://core.ac.uk/documentation/dataset
- CORE GitHub: https://github.com/oacore

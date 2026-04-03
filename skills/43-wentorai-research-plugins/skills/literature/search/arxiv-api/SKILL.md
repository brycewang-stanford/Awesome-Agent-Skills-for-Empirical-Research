---
name: arxiv-api
description: "Search and retrieve preprints from the arXiv open-access repository"
metadata:
  openclaw:
    emoji: "🔍"
    category: "literature"
    subcategory: "search"
    keywords: ["academic database search", "literature search", "scholarly database", "semantic search", "preprint server"]
    source: "https://info.arxiv.org/help/api/"
---

# arXiv API Guide

## Overview

The arXiv API provides programmatic access to the arXiv preprint repository, one of the most important open-access archives in the sciences. Founded in 1991, arXiv hosts over 2.4 million scholarly articles across physics, mathematics, computer science, quantitative biology, quantitative finance, statistics, electrical engineering and systems science, and economics.

Researchers use the arXiv API to build literature review tools, monitor new submissions in their fields, and integrate preprint search into automated research workflows. The API returns results in Atom XML format with rich metadata including titles, authors, abstracts, categories, DOIs, and journal references.

The API is free to use with no authentication required. It supports complex boolean queries across multiple fields and allows sorting by relevance, submission date, or last-updated date.

## Authentication

No authentication required. The arXiv API is fully open. However, users must respect the rate limit of 3 requests per second. Excessive usage may result in temporary IP-based blocking. Including a descriptive User-Agent header is considered good practice.

## Using the `search_arxiv` Tool

**IMPORTANT:** When calling the `search_arxiv` tool, use parameter name `query` (NOT
`search_query`). The raw API uses `search_query`, but the tool wrapper accepts `query`.

```
search_arxiv({ query: "ti:transformer AND cat:cs.CL", sort_by: "submittedDate" })
```

## Core Endpoints (Raw API Reference)

### Query: Search for Articles

- **URL**: `GET http://export.arxiv.org/api/query`
- **Parameters** (raw API — the `search_arxiv` tool wraps these automatically):
  | Param | Type | Required | Description |
  |-------|------|----------|-------------|
  | search_query | string | Yes | Query string using arXiv field prefixes (ti, au, abs, cat, id) |
  | id_list | string | No | Comma-separated arXiv IDs for direct lookup |
  | start | integer | No | Starting index for pagination (default: 0) |
  | max_results | integer | No | Number of results to return (default: 10, max: 30000) |
  | sortBy | string | No | Sort field: relevance, lastUpdatedDate, submittedDate |
  | sortOrder | string | No | ascending or descending |
- **Example**:
  ```bash
  curl "http://export.arxiv.org/api/query?search_query=au:hinton+AND+ti:deep+learning&start=0&max_results=5&sortBy=submittedDate&sortOrder=descending"
  ```
- **Response**: Atom XML feed with `<entry>` elements containing `<title>`, `<summary>`, `<author>`, `<arxiv:primary_category>`, `<published>`, `<updated>`, and `<link>` fields.

### ID Lookup: Retrieve Specific Papers

- **URL**: `GET http://export.arxiv.org/api/query`
- **Parameters**:
  | Param | Type | Required | Description |
  |-------|------|----------|-------------|
  | id_list | string | Yes | Comma-separated arXiv IDs (e.g., 2301.00001,2301.00002) |
  | max_results | integer | No | Number of results to return |
- **Example**:
  ```bash
  curl "http://export.arxiv.org/api/query?id_list=2301.07041&max_results=1"
  ```
- **Response**: Atom XML feed with full metadata for the requested paper(s).

## Rate Limits

The arXiv API enforces a rate limit of 3 requests per second. There is no daily request cap, but automated bulk downloading should be done using the arXiv bulk data access options instead of the API. If you exceed the rate limit, you will receive HTTP 503 responses. Implement exponential backoff and a minimum 3-second delay between requests to avoid being temporarily blocked.

## Common Patterns

### Monitor New Submissions in a Category

Track daily submissions in a specific arXiv category by querying with a date range and category filter:

```bash
curl "http://export.arxiv.org/api/query?search_query=cat:cs.AI+AND+submittedDate:[202603010000+TO+202603092359]&sortBy=submittedDate&sortOrder=descending&max_results=50"
```

### Build a Reading List from Keywords

Search across titles and abstracts for specific research topics:

```bash
curl "http://export.arxiv.org/api/query?search_query=(ti:transformer+OR+abs:transformer)+AND+cat:cs.CL&max_results=20&sortBy=relevance"
```

### Batch Metadata Retrieval

Retrieve metadata for multiple known papers in a single request:

```bash
curl "http://export.arxiv.org/api/query?id_list=2301.07041,2302.13971,2303.08774&max_results=3"
```

## References

- Official documentation: https://info.arxiv.org/help/api/
- arXiv API user manual: https://info.arxiv.org/help/api/user-manual.html
- arXiv bulk data access: https://info.arxiv.org/help/bulk_data.html

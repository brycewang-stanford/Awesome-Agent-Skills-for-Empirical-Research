---
name: semantic-scholar-api
description: "Search papers and analyze citation graphs via OpenAlex and CrossRef APIs"
metadata:
  openclaw:
    emoji: "🔍"
    category: "literature"
    subcategory: "search"
    keywords: ["academic database search", "semantic search", "AI-powered literature search", "citation analysis", "citation network"]
    source: "https://api.openalex.org/"
---

# OpenAlex & CrossRef API Guide

## Overview

OpenAlex is a free, open catalog of the global research system, indexing over 250 million academic works across all fields of science. It provides structured access to papers, authors, institutions, concepts, and citation networks. OpenAlex is the successor to Microsoft Academic Graph and is maintained by OurResearch (the team behind Unpaywall).

CrossRef is the official DOI registration agency for scholarly content, providing metadata for over 150 million DOIs across all publishers and disciplines. Together, OpenAlex and CrossRef provide comprehensive coverage for academic search, citation analysis, and bibliometric research.

Both APIs are free to use without authentication. OpenAlex requests a polite `User-Agent` header; CrossRef requests a `User-Agent` with contact email for access to the polite pool (faster rate limits).

## Authentication

No authentication is required for either API.

OpenAlex: Include a `User-Agent` header for polite access:
```
User-Agent: ResearchPlugins/1.0 (https://wentor.ai)
```

CrossRef: Include a `User-Agent` header with contact email for polite pool:
```
User-Agent: ResearchPlugins/1.0 (https://wentor.ai; mailto:dev@wentor.ai)
```

## Core Endpoints

### OpenAlex: Search Works

- **URL**: `GET https://api.openalex.org/works`
- **Parameters**:
  | Param | Type | Required | Description |
  |-------|------|----------|-------------|
  | search | string | No | Full-text search query |
  | filter | string | No | Filter expression (e.g., `from_publication_date:2024-01-01`) |
  | sort | string | No | Sort field (e.g., `cited_by_count:desc`, `publication_date:desc`) |
  | per_page | integer | No | Results per page (default: 25, max: 200) |
  | page | integer | No | Page number (default: 1) |
- **Example**:
  ```bash
  curl "https://api.openalex.org/works?search=attention+is+all+you+need&per_page=5"
  ```
- **Response**: JSON with `meta` (count, page info) and `results` array containing work objects.

### OpenAlex: Get Work Details

- **URL**: `GET https://api.openalex.org/works/{id}`
- **Parameters**:
  | Param | Type | Required | Description |
  |-------|------|----------|-------------|
  | id | string | Yes | OpenAlex ID (e.g., `W2741809807`), DOI URL, or other identifier |
- **Example**:
  ```bash
  curl "https://api.openalex.org/works/W2741809807"
  ```
- **Response**: JSON with full work metadata including `id`, `title`, `abstract_inverted_index`, `publication_year`, `cited_by_count`, `authorships`, `concepts`, `referenced_works`.

### OpenAlex: Search Authors

- **URL**: `GET https://api.openalex.org/authors`
- **Parameters**:
  | Param | Type | Required | Description |
  |-------|------|----------|-------------|
  | search | string | No | Author name search |
  | filter | string | No | Filter expression |
  | per_page | integer | No | Results per page (max: 200) |
- **Example**:
  ```bash
  curl "https://api.openalex.org/authors?search=Yoshua+Bengio&per_page=5"
  ```
- **Response**: JSON with author profiles including `works_count`, `cited_by_count`, `summary_stats.h_index`, affiliations.

### CrossRef: Resolve DOI

- **URL**: `GET https://api.crossref.org/works/{doi}`
- **Parameters**:
  | Param | Type | Required | Description |
  |-------|------|----------|-------------|
  | doi | string | Yes | DOI to resolve (e.g., `10.1038/nature12373`) |
- **Example**:
  ```bash
  curl "https://api.crossref.org/works/10.18653/v1/N19-1423"
  ```
- **Response**: JSON with full bibliographic metadata including title, authors, journal, dates, references count, and citation count.

## Rate Limits

OpenAlex: No strict rate limit, but use polite `User-Agent` header. Recommended: max 10 requests per second. The API returns HTTP 429 when limits are exceeded.

CrossRef: Without polite pool: ~50 requests per second. With polite pool (contact email in User-Agent): higher limits. The API returns HTTP 429 when limits are exceeded.

## Common Patterns

### Build a Citation Network

Retrieve a paper and find all works that cite it:

```bash
# Get paper details
curl "https://api.openalex.org/works/W2741809807"

# Get works citing this paper, sorted by citation count
curl "https://api.openalex.org/works?filter=cites:W2741809807&sort=cited_by_count:desc&per_page=20"
```

### Find Influential Papers on a Topic

Search for highly cited works on a topic:

```bash
curl "https://api.openalex.org/works?search=graph+neural+networks&sort=cited_by_count:desc&per_page=20"
```

### Batch Paper Lookup via CrossRef

Search CrossRef for papers matching a query, sorted by citation count:

```bash
curl "https://api.crossref.org/works?query=graph+neural+networks&sort=is-referenced-by-count&order=desc&rows=20"
```

## References

- OpenAlex documentation: https://docs.openalex.org/
- CrossRef API documentation: https://api.crossref.org/swagger-ui/index.html
- OpenAlex source: https://github.com/ourresearch/openalex-guts

---
name: crossref-api
description: "Resolve DOIs and retrieve publication metadata from CrossRef registry"
metadata:
  openclaw:
    emoji: "🔍"
    category: "literature"
    subcategory: "metadata"
    keywords: ["DOI resolution", "digital object identifier", "CrossRef", "citation statistics", "citation tracking"]
    source: "https://api.crossref.org"
---

# CrossRef API Guide

## Overview

CrossRef is the official DOI registration agency for scholarly publishing, maintaining metadata for over 150 million content items including journal articles, books, conference proceedings, preprints, and datasets. The CrossRef REST API provides free, open access to this metadata, making it the authoritative source for resolving Digital Object Identifiers (DOIs) and retrieving standardized publication records.

Publishers deposit metadata with CrossRef when they register DOIs for their content. This makes the CrossRef API a reliable source for bibliographic information, citation counts, licensing data, funder acknowledgments, and links to full-text resources. The API is used extensively in reference management, citation analysis, and research information systems.

The API is free and requires no authentication. Users who include a `mailto` parameter in their requests are placed in the "polite pool" which provides faster and more reliable service.

## Authentication

No authentication required. For best performance, include your email to access the polite pool:

```
https://api.crossref.org/works?mailto=your@email.com
```

Users in the polite pool receive prioritized responses and are not subject to the same rate limiting as anonymous users. CrossRef Plus subscribers get additional benefits including guaranteed uptime and higher throughput.

## Core Endpoints

### Works: Query Publication Metadata

- **URL**: `GET https://api.crossref.org/works`
- **Parameters**:
  | Param | Type | Required | Description |
  |-------|------|----------|-------------|
  | query | string | No | Free-text query across all metadata fields |
  | query.title | string | No | Search specifically in titles |
  | query.author | string | No | Search specifically by author name |
  | filter | string | No | Structured filters (e.g., from-pub-date:2024, type:journal-article) |
  | sort | string | No | Sort field: relevance, published, is-referenced-by-count |
  | order | string | No | asc or desc |
  | rows | integer | No | Results per page (default: 20, max: 1000) |
  | offset | integer | No | Pagination offset |
  | mailto | string | No | Email for polite pool |
- **Example**:
  ```bash
  curl "https://api.crossref.org/works?query.title=attention+is+all+you+need&rows=5&mailto=user@example.com"
  ```
- **Response**: JSON with `message.items` array containing `DOI`, `title`, `author`, `published`, `is-referenced-by-count`, `reference`, `license`, and `link` fields.

### Works by DOI: Direct DOI Resolution

- **URL**: `GET https://api.crossref.org/works/{doi}`
- **Parameters**:
  | Param | Type | Required | Description |
  |-------|------|----------|-------------|
  | doi | string | Yes | The DOI to resolve (URL path parameter) |
  | mailto | string | No | Email for polite pool |
- **Example**:
  ```bash
  curl "https://api.crossref.org/works/10.1038/s41586-021-03819-2?mailto=user@example.com"
  ```
- **Response**: JSON with complete metadata record for the DOI, including all registered bibliographic information.

### Members: Publisher Information

- **URL**: `GET https://api.crossref.org/members`
- **Parameters**:
  | Param | Type | Required | Description |
  |-------|------|----------|-------------|
  | query | string | No | Publisher name search |
  | rows | integer | No | Results per page |
- **Example**:
  ```bash
  curl "https://api.crossref.org/members?query=springer&rows=5&mailto=user@example.com"
  ```
- **Response**: JSON with publisher metadata including member ID, name, prefix list, and coverage statistics.

### Journals: Journal Metadata

- **URL**: `GET https://api.crossref.org/journals`
- **Parameters**:
  | Param | Type | Required | Description |
  |-------|------|----------|-------------|
  | query | string | No | Journal title search |
  | rows | integer | No | Results per page |
- **Example**:
  ```bash
  curl "https://api.crossref.org/journals?query=nature+machine+intelligence&rows=5&mailto=user@example.com"
  ```
- **Response**: JSON with journal information including ISSN, title, publisher, subject, and coverage counts.

## Rate Limits

Anonymous users: no hard limit but throttled under load. Polite pool users (with `mailto`): prioritized access with no published rate cap. CrossRef Plus subscribers: guaranteed uptime with SLA. The API returns HTTP 429 when overloaded. Use exponential backoff and always include `mailto` for production applications. For bulk metadata retrieval, CrossRef provides database snapshots and the Public Data File.

## Common Patterns

### Validate and Enrich a Reference List

Resolve a list of DOIs to get standardized metadata:

```bash
# Single DOI resolution with full metadata
curl "https://api.crossref.org/works/10.1145/3292500.3330672?mailto=user@example.com"
```

### Find Recent Highly-Cited Papers in a Field

Filter by publication date and sort by citation count:

```bash
curl "https://api.crossref.org/works?filter=from-pub-date:2023,type:journal-article&query=machine+learning&sort=is-referenced-by-count&order=desc&rows=20&mailto=user@example.com"
```

### Track Citation Growth

Monitor citation counts for a specific DOI over time:

```bash
curl "https://api.crossref.org/works/10.1038/s41586-021-03819-2?mailto=user@example.com" | jq '.message["is-referenced-by-count"]'
```

## References

- Official documentation: https://api.crossref.org
- API documentation: https://api.crossref.org/swagger-ui/index.html
- CrossRef metadata best practices: https://www.crossref.org/documentation/

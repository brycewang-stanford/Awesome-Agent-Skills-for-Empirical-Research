---
name: openalex-api
description: "Query the OpenAlex catalog of scholarly works, authors, and institutions"
metadata:
  openclaw:
    emoji: "🔍"
    category: "literature"
    subcategory: "search"
    keywords: ["academic database search", "literature search", "citation statistics", "academic metrics", "bibliometrics"]
    source: "https://docs.openalex.org/"
---

# OpenAlex API Guide

## Overview

OpenAlex is a free, open catalog of the global research system. It indexes over 250 million scholarly works, 90 million authors, 100,000 institutions, and 65,000 concepts. Created by the nonprofit OurResearch as a replacement for Microsoft Academic Graph, OpenAlex provides comprehensive bibliometric data for academic research analysis.

The API serves as a powerful tool for researchers conducting systematic literature reviews, bibliometric analyses, and research landscape mapping. It covers works across all academic disciplines, linking papers to their authors, institutions, concepts, and citation networks. Each entity in OpenAlex has a persistent identifier (OpenAlex ID) and is enriched with metadata from CrossRef, ORCID, ROR, and other authoritative sources.

OpenAlex is entirely free to use. No API key is required, though providing a contact email in the `mailto` parameter grants access to the polite pool with faster response times and higher rate limits.

## Authentication

No authentication required. For better rate limits and access to the polite pool, include your email in requests:

```
https://api.openalex.org/works?mailto=your@email.com
```

The polite pool provides significantly faster responses and is recommended for all production usage.

## Core Endpoints

### Works: Search Scholarly Publications

- **URL**: `GET https://api.openalex.org/works`
- **Parameters**:
  | Param | Type | Required | Description |
  |-------|------|----------|-------------|
  | search | string | No | Full-text search across titles and abstracts |
  | filter | string | No | Structured filters (e.g., publication_year:2024, cited_by_count:>100) |
  | sort | string | No | Sort field: cited_by_count, publication_date, relevance_score |
  | page | integer | No | Page number for pagination (default: 1) |
  | per_page | integer | No | Results per page (default: 25, max: 200) |
  | mailto | string | No | Email for polite pool access |
- **Example**:
  ```bash
  curl "https://api.openalex.org/works?search=large+language+models&filter=publication_year:2024&sort=cited_by_count:desc&per_page=10&mailto=user@example.com"
  ```
- **Response**: JSON with `results` array containing `id`, `title`, `doi`, `publication_date`, `cited_by_count`, `authorships`, `concepts`, `open_access` status, and `abstract_inverted_index`.

### Authors: Search Researcher Profiles

- **URL**: `GET https://api.openalex.org/authors`
- **Parameters**:
  | Param | Type | Required | Description |
  |-------|------|----------|-------------|
  | search | string | No | Name-based author search |
  | filter | string | No | Filters (e.g., works_count:>50, last_known_institution.id) |
  | sort | string | No | Sort field: works_count, cited_by_count, h_index |
  | per_page | integer | No | Results per page (default: 25, max: 200) |
- **Example**:
  ```bash
  curl "https://api.openalex.org/authors?search=Geoffrey+Hinton&mailto=user@example.com"
  ```
- **Response**: JSON with `results` array containing `id`, `display_name`, `orcid`, `works_count`, `cited_by_count`, `h_index`, `last_known_institution`, and `x_concepts`.

### Institutions: Search Academic Organizations

- **URL**: `GET https://api.openalex.org/institutions`
- **Parameters**:
  | Param | Type | Required | Description |
  |-------|------|----------|-------------|
  | search | string | No | Institution name search |
  | filter | string | No | Filters (e.g., country_code:US, type:education) |
  | sort | string | No | Sort field: works_count, cited_by_count |
  | per_page | integer | No | Results per page |
- **Example**:
  ```bash
  curl "https://api.openalex.org/institutions?search=MIT&mailto=user@example.com"
  ```
- **Response**: JSON with institution details including `id`, `display_name`, `ror`, `country_code`, `type`, `works_count`, and `cited_by_count`.

### Concepts: Browse Research Topics

- **URL**: `GET https://api.openalex.org/concepts`
- **Parameters**:
  | Param | Type | Required | Description |
  |-------|------|----------|-------------|
  | search | string | No | Concept name search |
  | filter | string | No | Filters (e.g., level:0 for top-level concepts) |
  | per_page | integer | No | Results per page |
- **Example**:
  ```bash
  curl "https://api.openalex.org/concepts?filter=level:0&per_page=50&mailto=user@example.com"
  ```
- **Response**: JSON with concept hierarchy, `works_count`, and related concepts.

## Rate Limits

Without the `mailto` parameter: 10 requests per second, 100,000 requests per day. With the `mailto` parameter (polite pool): significantly higher throughput. The API uses HTTP 429 responses when limits are exceeded. Implement exponential backoff for production usage.

## Common Patterns

### Citation Analysis for a Paper

Retrieve all works that cite a specific paper by its DOI:

```bash
curl "https://api.openalex.org/works?filter=cites:W2741809807&sort=cited_by_count:desc&per_page=25&mailto=user@example.com"
```

### Institutional Research Output

Analyze publication trends for a specific institution:

```bash
curl "https://api.openalex.org/works?filter=institutions.id:I136199984,publication_year:2024&group_by=open_access.is_oa&mailto=user@example.com"
```

### Topic Landscape Mapping

Explore how a concept connects to others in the research landscape:

```bash
curl "https://api.openalex.org/concepts/C41008148?mailto=user@example.com"
```

## References

- Official documentation: https://docs.openalex.org/
- OpenAlex data model: https://docs.openalex.org/about-the-data
- API filters reference: https://docs.openalex.org/how-to-use-the-api/get-lists-of-entities/filter-entity-lists

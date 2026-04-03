---
name: doaj-api
description: "Search open access journals and articles in the DOAJ directory"
metadata:
  openclaw:
    emoji: "🔍"
    category: "literature"
    subcategory: "fulltext"
    keywords: ["full-text retrieval", "open access", "open access rights", "scholarly database"]
    source: "https://doaj.org/api/docs"
---

# DOAJ API Guide

## Overview

The Directory of Open Access Journals (DOAJ) is a community-curated online directory that indexes and provides access to high quality, open access, peer-reviewed journals. Founded in 2003, DOAJ currently indexes over 20,000 journals and 9 million articles from 130 countries, covering all areas of science, technology, medicine, social sciences, arts, and humanities.

DOAJ serves as a quality filter for open access publishing. Journals must meet strict criteria to be included, including editorial review, transparent policies, and adherence to open access principles. This makes DOAJ particularly valuable for researchers who need to verify whether a journal is a legitimate open access outlet, librarians curating discovery systems, and developers building tools that surface OA content.

The DOAJ API provides free, unauthenticated access to search and retrieve journal and article metadata. All data is available under a CC BY-SA license. The API returns JSON and supports Elasticsearch-style queries for advanced filtering.

## Authentication

No authentication required. The DOAJ API is fully open and free to use. No API key, registration, or email is needed. There are no published rate limits, but users should be respectful and avoid sending excessive concurrent requests. For bulk data access, DOAJ provides data dumps at https://doaj.org/docs/public-data-dump/.

## Core Endpoints

### Article Search: Find Open Access Articles

- **URL**: `GET https://doaj.org/api/search/articles/{search_query}`
- **Parameters**:
  | Param | Type | Required | Description |
  |-------|------|----------|-------------|
  | search_query | string | Yes | Search query (URL path parameter, supports field-specific search) |
  | page | integer | No | Page number (default: 1) |
  | pageSize | integer | No | Results per page (default: 10, max: 100) |
  | sort | string | No | Sort field (e.g., created_date:desc) |
- **Example**:
  ```bash
  curl "https://doaj.org/api/search/articles/climate+change?page=1&pageSize=10"
  ```
- **Response**: JSON with `total` count and `results` array. Each result contains `bibjson` with `title`, `abstract`, `author`, `journal.title`, `identifier` (DOI, ISSN), `link` (full-text URL), `year`, `month`, `keywords`, and `subject`.

### Journal Search: Find Open Access Journals

- **URL**: `GET https://doaj.org/api/search/journals/{search_query}`
- **Parameters**:
  | Param | Type | Required | Description |
  |-------|------|----------|-------------|
  | search_query | string | Yes | Journal search query |
  | page | integer | No | Page number (default: 1) |
  | pageSize | integer | No | Results per page (default: 10, max: 100) |
- **Example**:
  ```bash
  curl "https://doaj.org/api/search/journals/bioinformatics?page=1&pageSize=5"
  ```
- **Response**: JSON with journal records containing `bibjson` with `title`, `alternative_title`, `identifier` (ISSN, EISSN), `publisher`, `institution`, `subject`, `license`, `apc` (article processing charge info), `language`, and `editorial.review_process`.

### Article by DOI: Direct Lookup

- **URL**: `GET https://doaj.org/api/search/articles/doi:{doi}`
- **Parameters**:
  | Param | Type | Required | Description |
  |-------|------|----------|-------------|
  | doi | string | Yes | The DOI to look up |
- **Example**:
  ```bash
  curl "https://doaj.org/api/search/articles/doi:10.1371/journal.pone.0213676"
  ```
- **Response**: JSON with matching article records from DOAJ-indexed journals.

### Journal by ISSN: Direct Lookup

- **URL**: `GET https://doaj.org/api/search/journals/issn:{issn}`
- **Parameters**:
  | Param | Type | Required | Description |
  |-------|------|----------|-------------|
  | issn | string | Yes | The ISSN to look up |
- **Example**:
  ```bash
  curl "https://doaj.org/api/search/journals/issn:1932-6203"
  ```
- **Response**: JSON with journal record including full metadata and policies.

## Rate Limits

No published rate limits. DOAJ does not enforce strict API quotas. However, the service is maintained by a small nonprofit team. Best practices include limiting requests to a reasonable rate (2-5 per second), caching results, and using the public data dump for large-scale analyses. Abusive usage may result in IP blocking without notice.

## Common Patterns

### Verify Journal Quality

Check if a journal is indexed in DOAJ (a proxy for quality and legitimacy):

```bash
curl -s "https://doaj.org/api/search/journals/issn:2045-2322" | jq '{total: .total, title: .results[0].bibjson.title, publisher: .results[0].bibjson.publisher.name, license: .results[0].bibjson.license[0].type}'
```

### Find OA Articles in a Subject Area

Search for articles within a specific discipline with full-text links:

```bash
curl -s "https://doaj.org/api/search/articles/bibjson.subject.term:neuroscience?pageSize=20" | jq '.results[] | {title: .bibjson.title, journal: .bibjson.journal.title, url: .bibjson.link[0].url, year: .bibjson.year}'
```

### Check APC (Article Processing Charge) Information

Determine if a journal charges fees for publishing:

```bash
curl -s "https://doaj.org/api/search/journals/issn:2041-1723" | jq '.results[0].bibjson | {title: .title, has_apc: .apc.has_apc, apc_amount: .apc.max[0].price, currency: .apc.max[0].currency}'
```

## References

- Official documentation: https://doaj.org/api/docs
- DOAJ public data dump: https://doaj.org/docs/public-data-dump/
- DOAJ journal application criteria: https://doaj.org/apply/guide/

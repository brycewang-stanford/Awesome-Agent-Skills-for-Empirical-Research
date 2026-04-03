---
name: nasa-ads-api
description: "Search astrophysics and physics literature via NASA ADS bibliographic database"
metadata:
  openclaw:
    emoji: "🔍"
    category: "domains"
    subcategory: "physics"
    keywords: ["astrophysics", "observational astronomy", "cosmology", "high energy physics"]
    source: "https://ui.adsabs.harvard.edu/help/api/"
    requires:
      env: ["ADS_API_TOKEN"]
---

# NASA ADS API Guide

## Overview

The NASA Astrophysics Data System (ADS) is a digital library operated by the Smithsonian Astrophysical Observatory under a NASA grant. It is the primary bibliographic database for astronomy and astrophysics, also covering significant portions of physics, geophysics, and related disciplines. ADS indexes over 16 million records and provides access to full-text articles, citations, and usage metrics.

ADS is indispensable for astronomers and physicists. Nearly every paper in astrophysics is indexed in ADS, and the system provides powerful search capabilities including full-text search, citation and reference tracking, author disambiguation, and object-level queries (search by astronomical object name). The database integrates with SIMBAD, NED, and other astronomical databases to link publications to the celestial objects they study.

The ADS API requires a free API token and supports 3,000 requests per day. It returns JSON and supports a rich query language with field-specific searches, boolean operators, and positional queries.

## Authentication

Authentication is required via a free API token. Register at https://ui.adsabs.harvard.edu/user/settings/token to generate your token. Include it in every request as a header:

```
Authorization: Bearer YOUR_ADS_API_TOKEN
```

Tokens do not expire but can be regenerated from the settings page. Each token is associated with a user account and is subject to per-account rate limits.

## Core Endpoints

### Query: Search the ADS Database

- **URL**: `GET https://api.adsabs.harvard.edu/v1/search/query`
- **Parameters**:
  | Param | Type | Required | Description |
  |-------|------|----------|-------------|
  | q | string | Yes | Search query (ADS query syntax with field qualifiers) |
  | fl | string | No | Fields to return (comma-separated: title, author, year, bibcode, doi, citation_count, abstract, etc.) |
  | rows | integer | No | Results per page (default: 10, max: 2000) |
  | start | integer | No | Pagination offset (default: 0) |
  | sort | string | No | Sort field and order (e.g., citation_count desc, date desc) |
  | fq | string | No | Filter queries for faceting (e.g., database:astronomy) |
- **Example**:
  ```bash
  curl -H "Authorization: Bearer YOUR_TOKEN" \
       "https://api.adsabs.harvard.edu/v1/search/query?q=gravitational+waves&fl=title,author,year,bibcode,citation_count,doi&rows=10&sort=citation_count+desc"
  ```
- **Response**: JSON with `response.numFound` (total hits) and `response.docs` array. Each doc contains the requested fields. The `bibcode` is the unique ADS identifier (19-character string encoding journal, year, volume, and page).

### Author Search: Find Researcher Publications

- **URL**: `GET https://api.adsabs.harvard.edu/v1/search/query`
- **Parameters**:
  | Param | Type | Required | Description |
  |-------|------|----------|-------------|
  | q | string | Yes | Author query using author: or first_author: fields |
  | fl | string | No | Fields to return |
  | rows | integer | No | Results per page |
  | sort | string | No | Sort order |
- **Example**:
  ```bash
  curl -H "Authorization: Bearer YOUR_TOKEN" \
       "https://api.adsabs.harvard.edu/v1/search/query?q=author:%22Hawking,+S%22&fl=title,year,bibcode,citation_count&rows=20&sort=citation_count+desc"
  ```
- **Response**: JSON with matching publications by the specified author.

### Object Search: Find Papers About Astronomical Objects

- **URL**: `GET https://api.adsabs.harvard.edu/v1/search/query`
- **Parameters**:
  | Param | Type | Required | Description |
  |-------|------|----------|-------------|
  | q | string | Yes | Object query using object: field (e.g., object:"M31") |
  | fl | string | No | Fields to return |
  | rows | integer | No | Results per page |
- **Example**:
  ```bash
  curl -H "Authorization: Bearer YOUR_TOKEN" \
       "https://api.adsabs.harvard.edu/v1/search/query?q=object:%22Sgr+A*%22&fl=title,author,year,bibcode,citation_count&rows=10&sort=date+desc"
  ```
- **Response**: JSON with publications related to the specified astronomical object.

### Metrics: Paper and Author Metrics

- **URL**: `POST https://api.adsabs.harvard.edu/v1/metrics`
- **Parameters**:
  | Param | Type | Required | Description |
  |-------|------|----------|-------------|
  | bibcodes | array | Yes | Array of ADS bibcodes (JSON body) |
  | types | array | No | Metric types: basic, citations, indicators, histograms |
- **Example**:
  ```bash
  curl -X POST -H "Authorization: Bearer YOUR_TOKEN" \
       -H "Content-Type: application/json" \
       "https://api.adsabs.harvard.edu/v1/metrics" \
       -d '{"bibcodes": ["2016PhRvL.116f1102A"], "types": ["basic", "citations", "indicators"]}'
  ```
- **Response**: JSON with citation metrics, h-index, g-index, read counts, and citation histograms for the specified papers.

## Rate Limits

The API allows 3,000 requests per day (resets at midnight UTC) and 15 requests per second burst limit. If limits are exceeded, the API returns HTTP 429 with `X-RateLimit-Reset` header. For large bibliometric analyses, use the ADS bulk export or the myADS notification system. Monitor usage via `X-RateLimit-Remaining` response headers.

## Common Patterns

### Literature Review in Astrophysics

Search for recent highly-cited papers on a topic:

```bash
curl -H "Authorization: Bearer YOUR_TOKEN" \
     "https://api.adsabs.harvard.edu/v1/search/query?q=dark+energy+AND+year:2023-2026&fl=title,author,year,bibcode,citation_count,doi,abstract&rows=20&sort=citation_count+desc"
```

### Build an Author's Publication Profile

Retrieve complete publication list with metrics:

```bash
# Get publications
curl -H "Authorization: Bearer YOUR_TOKEN" \
     "https://api.adsabs.harvard.edu/v1/search/query?q=author:%22Perlmutter,+S%22&fl=title,year,bibcode,citation_count&rows=200&sort=date+desc"

# Get aggregate metrics
curl -X POST -H "Authorization: Bearer YOUR_TOKEN" \
     -H "Content-Type: application/json" \
     "https://api.adsabs.harvard.edu/v1/metrics" \
     -d '{"bibcodes": ["1999ApJ...517..565P", "2012ApJ...746...85S"], "types": ["basic", "indicators"]}'
```

### Cross-Match with Astronomical Databases

Find papers about a specific object and link to SIMBAD/NED:

```bash
curl -H "Authorization: Bearer YOUR_TOKEN" \
     "https://api.adsabs.harvard.edu/v1/search/query?q=object:%22Crab+Nebula%22+AND+year:2024-2026&fl=title,author,year,bibcode,doi&rows=10&sort=date+desc"
```

## References

- Official documentation: https://ui.adsabs.harvard.edu/help/api/
- ADS query syntax: https://ui.adsabs.harvard.edu/help/search/
- ADS search fields: https://ui.adsabs.harvard.edu/help/search/search-syntax

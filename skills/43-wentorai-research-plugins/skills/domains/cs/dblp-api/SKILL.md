---
name: dblp-api
description: "Search computer science publications, authors, and venues via DBLP"
metadata:
  openclaw:
    emoji: "🔍"
    category: "domains"
    subcategory: "cs"
    keywords: ["algorithms", "data structures", "software engineering", "database", "academic database search"]
    source: "https://dblp.org/faq/1474707.html"
---

# DBLP API Guide

## Overview

DBLP (Digital Bibliography and Library Project) is the most comprehensive open bibliographic database for computer science. Maintained by Schloss Dagstuhl - Leibniz Center for Informatics, DBLP indexes over 6.5 million publications from thousands of journals, conference proceedings, and informal publication venues in computer science and related fields.

DBLP is widely regarded as the authoritative source for computer science bibliographic data. It is used by researchers for tracking publication records, by hiring committees for evaluating academic productivity, and by bibliometric tools for analyzing the computer science research landscape. Each author in DBLP has a unique profile page with a complete, disambiguated publication list.

The API is entirely free and open, requiring no authentication. There are no published rate limits, though users are expected to be respectful and avoid excessive load on the servers. All data is available under the ODC-BY license.

## Authentication

No authentication required. The DBLP API is fully open and free to use. No API key, registration, or email is needed. Users should include a descriptive User-Agent header and avoid sending excessive concurrent requests.

## Core Endpoints

### Publication Search: Find Computer Science Papers

- **URL**: `GET https://dblp.org/search/publ/api`
- **Parameters**:
  | Param | Type | Required | Description |
  |-------|------|----------|-------------|
  | q | string | Yes | Search query (supports author:, venue:, year: prefixes) |
  | format | string | No | Response format: json, xml (default: xml) |
  | h | integer | No | Number of results (default: 30, max: 1000) |
  | f | integer | No | Starting offset for pagination (default: 0) |
  | c | integer | No | Maximum completions in auto-suggest mode |
- **Example**:
  ```bash
  curl "https://dblp.org/search/publ/api?q=graph+neural+networks&format=json&h=10&f=0"
  ```
- **Response**: JSON with `result.hits` containing `@total` count and `hit` array. Each hit has `info` with `title`, `authors.author`, `venue`, `year`, `type`, `doi`, `url`, and `ee` (electronic edition link).

### Author Search: Find Researchers

- **URL**: `GET https://dblp.org/search/author/api`
- **Parameters**:
  | Param | Type | Required | Description |
  |-------|------|----------|-------------|
  | q | string | Yes | Author name query |
  | format | string | No | Response format: json, xml |
  | h | integer | No | Number of results (default: 30) |
  | f | integer | No | Starting offset |
- **Example**:
  ```bash
  curl "https://dblp.org/search/author/api?q=Yann+LeCun&format=json&h=5"
  ```
- **Response**: JSON with matched author profiles including `author` name, `url` (DBLP profile URL), and optional `notes` with affiliation information.

### Venue Search: Find Journals and Conferences

- **URL**: `GET https://dblp.org/search/venue/api`
- **Parameters**:
  | Param | Type | Required | Description |
  |-------|------|----------|-------------|
  | q | string | Yes | Venue name query |
  | format | string | No | Response format: json, xml |
  | h | integer | No | Number of results |
  | f | integer | No | Starting offset |
- **Example**:
  ```bash
  curl "https://dblp.org/search/venue/api?q=NeurIPS&format=json&h=5"
  ```
- **Response**: JSON with matched venue names, acronyms, and DBLP venue URLs.

### Author Profile: Full Publication List

- **URL**: `GET https://dblp.org/pid/{pid}.json`
- **Parameters**:
  | Param | Type | Required | Description |
  |-------|------|----------|-------------|
  | pid | string | Yes | DBLP person ID (e.g., h/GeoffreyEHinton) from author search results |
- **Example**:
  ```bash
  curl "https://dblp.org/pid/h/GeoffreyEHinton.json"
  ```
- **Response**: JSON with full author profile including name variants, affiliation, and complete publication list with metadata.

## Rate Limits

No published rate limits. DBLP does not enforce strict API quotas. However, the service is provided by a non-profit institution with limited resources. Best practices include limiting requests to a reasonable rate (1-2 per second), using caching for repeated queries, and downloading the DBLP XML dump for large-scale analyses instead of querying the API repeatedly.

## Common Patterns

### Track an Author's Publication Record

Get a complete, chronological list of publications for a researcher:

```bash
# Step 1: Find the author's DBLP PID
curl "https://dblp.org/search/author/api?q=Jure+Leskovec&format=json&h=1"

# Step 2: Fetch their full profile
curl "https://dblp.org/pid/l/JureLeskovec.json"
```

### Find Top Papers at a Conference

Search for publications at a specific venue in a given year:

```bash
curl "https://dblp.org/search/publ/api?q=venue:ICML+year:2024&format=json&h=50"
```

### Cross-Reference with DOI

Use DBLP records to find DOIs and link to other metadata sources:

```bash
curl "https://dblp.org/search/publ/api?q=attention+is+all+you+need&format=json&h=1" | jq '.result.hits.hit[0].info.doi'
```

## References

- Official documentation: https://dblp.org/faq/1474707.html
- DBLP XML dump: https://dblp.org/xml/
- DBLP statistics: https://dblp.org/statistics/

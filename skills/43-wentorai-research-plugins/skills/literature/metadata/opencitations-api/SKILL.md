---
name: opencitations-api
description: "Query open citation data and reference networks via OpenCitations"
metadata:
  openclaw:
    emoji: "🔍"
    category: "literature"
    subcategory: "metadata"
    keywords: ["citation statistics", "citation tracking", "citation analysis", "bibliometrics", "citation network"]
    source: "https://opencitations.net/index/api/v1"
---

# OpenCitations API Guide

## Overview

OpenCitations is an independent infrastructure organization dedicated to open scholarship and the publication of open bibliographic and citation data. Its main product, the OpenCitations Index of Crossref open DOI-to-DOI citations (COCI), contains over 1.6 billion citation relationships harvested from CrossRef metadata. This makes it the largest fully open citation dataset in the world.

The OpenCitations API allows researchers to programmatically access citation and reference data for any DOI in the index. This is valuable for citation network analysis, bibliometric research, impact assessment, and building literature discovery tools. Unlike proprietary citation databases (Web of Science, Scopus), OpenCitations data is fully open under a CC0 public domain dedication.

The API is free, requires no authentication, and has no published rate limits. It returns data in JSON or CSV format, making it easy to integrate into data analysis pipelines.

## Authentication

No authentication required. The OpenCitations API is fully open and free. No API key, registration, or email is needed. There are no published rate limits, but users should implement reasonable request pacing for large-scale queries. For bulk data access, download the complete COCI dataset from https://opencitations.net/download.

## Core Endpoints

### Citations: Find Papers That Cite a DOI

- **URL**: `GET https://api.opencitations.net/index/v1/citations/{doi}`
- **Parameters**:
  | Param | Type | Required | Description |
  |-------|------|----------|-------------|
  | doi | string | Yes | The DOI of the cited paper (URL path parameter) |
  | format | string | No | Response format header: application/json or text/csv |
- **Example**:
  ```bash
  curl "https://api.opencitations.net/index/v1/citations/10.1038/nature12373"
  ```
- **Response**: JSON array of citation objects, each containing:
  - `oci`: OpenCitations Identifier for the citation link
  - `citing`: DOI of the citing paper
  - `cited`: DOI of the cited paper (the input DOI)
  - `creation`: date the citation was first recorded
  - `timespan`: time between publication of citing and cited papers
  - `journal_sc`: whether citing and cited are in the same journal (self-citation indicator)
  - `author_sc`: whether any author appears in both papers (author self-citation indicator)

### References: Find Papers Cited by a DOI

- **URL**: `GET https://api.opencitations.net/index/v1/references/{doi}`
- **Parameters**:
  | Param | Type | Required | Description |
  |-------|------|----------|-------------|
  | doi | string | Yes | The DOI of the paper whose references to retrieve |
- **Example**:
  ```bash
  curl "https://api.opencitations.net/index/v1/references/10.1038/nature12373"
  ```
- **Response**: JSON array of reference objects with the same structure as citations, where `citing` is the input DOI and `cited` are the referenced papers.

### Metadata: Retrieve Paper Metadata

- **URL**: `GET https://api.opencitations.net/index/v1/metadata/{doi}`
- **Parameters**:
  | Param | Type | Required | Description |
  |-------|------|----------|-------------|
  | doi | string | Yes | The DOI to look up (supports multiple DOIs separated by __) |
- **Example**:
  ```bash
  curl "https://api.opencitations.net/index/v1/metadata/10.1038/nature12373"
  ```
- **Response**: JSON array with metadata including `title`, `author`, `year`, `source_title` (journal), `volume`, `issue`, `page`, `doi`, `citation_count`, and `reference`.

### Citation Count: Quick Count Lookup

- **URL**: `GET https://api.opencitations.net/index/v1/citation-count/{doi}`
- **Parameters**:
  | Param | Type | Required | Description |
  |-------|------|----------|-------------|
  | doi | string | Yes | The DOI to check |
- **Example**:
  ```bash
  curl "https://api.opencitations.net/index/v1/citation-count/10.1038/nature12373"
  ```
- **Response**: JSON with `count` field indicating the number of citations in the index.

## Rate Limits

No published rate limits. OpenCitations does not enforce strict API quotas. The service runs on academic infrastructure, so users should be respectful. Best practices include pacing requests to 1-5 per second for sustained queries, caching results, and using the bulk dataset download for large-scale network analyses. The API may return HTTP 503 under heavy load.

## Common Patterns

### Build a Citation Network

Map the citation relationships around a seminal paper:

```bash
# Get all papers citing the target paper
curl -s "https://api.opencitations.net/index/v1/citations/10.1145/3292500.3330672" | jq '.[].citing'

# Get all papers referenced by the target paper
curl -s "https://api.opencitations.net/index/v1/references/10.1145/3292500.3330672" | jq '.[].cited'
```

### Detect Self-Citations

Filter out self-citations when computing impact metrics:

```bash
curl -s "https://api.opencitations.net/index/v1/citations/10.1038/nature12373" | jq '[.[] | select(.author_sc == "no")] | length'
```

### Compare Citation Counts Across Papers

Retrieve citation counts for multiple papers in a batch:

```bash
# Multiple DOIs separated by double underscore
curl -s "https://api.opencitations.net/index/v1/metadata/10.1038/nature12373__10.1126/science.aaa8685__10.1016/j.cell.2015.05.002" | jq '.[] | {doi: .doi, title: .title, citations: .citation_count}'
```

## References

- Official documentation: https://opencitations.net/index/api/v1
- OpenCitations data model: https://opencitations.net/model
- COCI dataset download: https://opencitations.net/download

---
name: pubmed-api
description: "Search biomedical literature and retrieve records via PubMed E-utilities"
metadata:
  openclaw:
    emoji: "🔍"
    category: "literature"
    subcategory: "search"
    keywords: ["academic database search", "literature search", "scholarly database", "field-specific search"]
    source: "https://www.ncbi.nlm.nih.gov/books/NBK25501/"
---

# PubMed E-utilities API Guide

## Overview

PubMed is the premier biomedical literature database maintained by the National Center for Biotechnology Information (NCBI) at the US National Library of Medicine. It indexes over 36 million citations and abstracts from MEDLINE, life science journals, and online books. The Entrez Programming Utilities (E-utilities) provide programmatic access to the entire PubMed database and other NCBI databases.

E-utilities consist of a suite of server-side programs that accept URL-based requests and return structured data. These tools are essential for biomedical researchers, systematic reviewers, and developers building health informatics applications. The API supports complex search queries using MeSH (Medical Subject Headings) terms, boolean operators, and field-specific searches.

The API is free and does not require authentication for basic usage. Registering for an NCBI API key raises the rate limit from 3 to 10 requests per second, which is recommended for any automated workflow.

## Authentication

No authentication required for basic usage (3 requests/second). For higher rate limits (10 requests/second), register for a free API key at https://www.ncbi.nlm.nih.gov/account/ and include it in requests:

```
&api_key=YOUR_API_KEY
```

Including `tool` and `email` parameters in requests helps NCBI contact you if there are issues with your application.

## Core Endpoints

### ESearch: Search and Retrieve PMIDs

- **URL**: `GET https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi`
- **Parameters**:
  | Param | Type | Required | Description |
  |-------|------|----------|-------------|
  | db | string | Yes | Database name (e.g., pubmed, pmc) |
  | term | string | Yes | Search query (supports boolean operators and field tags) |
  | retmax | integer | No | Maximum number of IDs returned (default: 20, max: 10000) |
  | retstart | integer | No | Index of first ID to retrieve (for pagination) |
  | retmode | string | No | Response format: xml (default) or json |
  | sort | string | No | Sort order: relevance, pub_date, author, journal |
  | datetype | string | No | Date type for range filter: pdat, mdat, edat |
  | mindate | string | No | Start date (YYYY/MM/DD) |
  | maxdate | string | No | End date (YYYY/MM/DD) |
  | usehistory | string | No | Set to "y" to store results on server for subsequent retrieval |
- **Example**:
  ```bash
  curl "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi?db=pubmed&term=CRISPR+AND+cancer[Title]&retmax=10&retmode=json&sort=pub_date"
  ```
- **Response**: JSON/XML with `esearchresult` containing `count` (total hits), `idlist` (array of PMIDs), and optionally `webenv` and `querykey` for history server.

### EFetch: Retrieve Full Records

- **URL**: `GET https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi`
- **Parameters**:
  | Param | Type | Required | Description |
  |-------|------|----------|-------------|
  | db | string | Yes | Database name |
  | id | string | Yes | Comma-separated list of PMIDs (or use WebEnv/query_key) |
  | rettype | string | No | Return type: abstract, medline, full, xml |
  | retmode | string | No | Format: xml, text |
  | WebEnv | string | No | Web environment from ESearch with usehistory=y |
  | query_key | string | No | Query key from ESearch |
- **Example**:
  ```bash
  curl "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=pubmed&id=33116299,34735795&rettype=abstract&retmode=xml"
  ```
- **Response**: XML with complete PubMed records including `MedlineCitation` with `Article` (title, abstract, authors, journal), `MeSHHeadingList`, and `PubmedData` (DOI, publication status).

### ESummary: Retrieve Document Summaries

- **URL**: `GET https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi`
- **Parameters**:
  | Param | Type | Required | Description |
  |-------|------|----------|-------------|
  | db | string | Yes | Database name |
  | id | string | Yes | Comma-separated PMIDs |
  | retmode | string | No | Response format: xml or json |
  | version | string | No | Set to "2.0" for enhanced XML format |
- **Example**:
  ```bash
  curl "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?db=pubmed&id=33116299&retmode=json&version=2.0"
  ```
- **Response**: JSON with document summary including `uid`, `title`, `authors`, `source` (journal), `pubdate`, `doi`, and `pmcid`.

## Rate Limits

Without API key: 3 requests per second. With API key: 10 requests per second. Exceeding limits results in temporary IP blocking. For large-scale data mining, use the NCBI FTP site for bulk downloads. Always include a delay of at least 334ms (or 100ms with API key) between requests. Weekend and evening hours (US Eastern time) are less congested.

## Common Patterns

### Systematic Literature Search

Perform a structured search using MeSH terms and field qualifiers:

```bash
# Search for clinical trials on diabetes treatment from the last 2 years
curl "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi?db=pubmed&term=diabetes[MeSH]+AND+treatment[Title]+AND+clinical+trial[Publication+Type]&mindate=2024/01/01&maxdate=2026/03/09&datetype=pdat&retmax=100&retmode=json"
```

### Pipeline: Search then Fetch

Use the history server to efficiently search and then retrieve records:

```bash
# Step 1: Search and store results
curl "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi?db=pubmed&term=machine+learning+AND+radiology&retmax=0&usehistory=y&retmode=json"

# Step 2: Fetch records using WebEnv and query_key from step 1
curl "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=pubmed&WebEnv=WEBENV_VALUE&query_key=1&retmax=50&rettype=abstract&retmode=xml"
```

### Retrieve Structured Metadata for Citation Management

Get JSON summaries for a batch of known PMIDs:

```bash
curl "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?db=pubmed&id=33116299,34735795,35363452&retmode=json&version=2.0"
```

## References

- Official documentation: https://www.ncbi.nlm.nih.gov/books/NBK25501/
- E-utilities quick start: https://www.ncbi.nlm.nih.gov/books/NBK25500/
- PubMed search help: https://pubmed.ncbi.nlm.nih.gov/help/

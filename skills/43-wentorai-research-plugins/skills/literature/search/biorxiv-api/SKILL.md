---
name: biorxiv-api
description: "Preprint server API for biology and medicine papers"
metadata:
  openclaw:
    emoji: "🔍"
    category: "literature"
    subcategory: "search"
    keywords: ["preprint server", "literature search", "academic database search", "full-text retrieval"]
    source: "https://api.biorxiv.org/"
---

# bioRxiv API Guide

## Overview

bioRxiv (pronounced "bio-archive") is a free online archive and distribution service for unpublished preprints in the life sciences. Operated by Cold Spring Harbor Laboratory, it provides researchers with immediate access to the latest findings before formal peer review. The bioRxiv API enables programmatic access to preprint metadata, content details, and publication linkage data across biology and medical sciences.

The API serves researchers who need to track emerging research trends, monitor preprint activity in specific subfields, or build automated literature surveillance pipelines. It is particularly valuable for systematic reviewers who want to capture the latest evidence before journal publication, and for bibliometric analysts studying the preprint-to-publication pipeline.

bioRxiv hosts preprints across more than 25 subject areas including neuroscience, genomics, bioinformatics, cell biology, and many more. The API returns structured metadata including titles, authors, abstracts, DOIs, publication dates, and links to corresponding published journal articles when available.

## Authentication

No authentication required. The bioRxiv API is fully open and does not require any API key, token, or registration. All endpoints are publicly accessible without rate limiting restrictions.

## Core Endpoints

### details: Retrieve Preprint Metadata

Fetch detailed metadata for preprints posted within a specified date range or for a specific server (bioRxiv or medRxiv).

- **URL**: `GET https://api.biorxiv.org/details/{server}/{interval}/{cursor}`
- **Parameters**:

| Parameter  | Type   | Required | Description                                      |
|------------|--------|----------|--------------------------------------------------|
| server     | string | Yes      | Server name: `biorxiv` or `medrxiv`              |
| interval   | string | Yes      | Date range in `YYYY-MM-DD/YYYY-MM-DD` format     |
| cursor     | int    | No       | Pagination cursor (default 0, increments of 100) |

- **Example**:

```bash
curl "https://api.biorxiv.org/details/biorxiv/2024-01-01/2024-01-31/0"
```

- **Response**: Returns a collection object containing `doi`, `title`, `authors`, `author_corresponding`, `date`, `category`, `abstract`, `published` (journal DOI if available), and `jatsxml` link.

### pubs: Published Article Linkage

Look up which preprints have been published in peer-reviewed journals, providing the mapping between preprint DOIs and journal article DOIs.

- **URL**: `GET https://api.biorxiv.org/pubs/{server}/{interval}/{cursor}`
- **Parameters**:

| Parameter  | Type   | Required | Description                                      |
|------------|--------|----------|--------------------------------------------------|
| server     | string | Yes      | Server name: `biorxiv` or `medrxiv`              |
| interval   | string | Yes      | Date range in `YYYY-MM-DD/YYYY-MM-DD` format     |
| cursor     | int    | No       | Pagination cursor (default 0, increments of 100) |

- **Example**:

```bash
curl "https://api.biorxiv.org/pubs/biorxiv/2024-01-01/2024-06-30/0"
```

- **Response**: Returns `preprint_doi`, `published_doi`, `preprint_title`, `published_journal`, `published_date`, and `preprint_date`.

## Rate Limits

No formal rate limits are documented for the bioRxiv API. However, responsible use is expected. Results are paginated at 100 records per request, and the cursor parameter should be incremented to retrieve additional pages. Avoid excessive concurrent requests to ensure availability for all users.

## Common Patterns

### Monitor New Preprints in a Subject Area

Retrieve the latest preprints and filter by category to track new submissions in your field:

```bash
# Fetch recent neuroscience preprints
curl "https://api.biorxiv.org/details/biorxiv/2024-06-01/2024-06-07/0" \
  | jq '.collection[] | select(.category == "neuroscience")'
```

### Track Preprint-to-Publication Conversion

Monitor which preprints in your area have been formally published:

```bash
# Check publication status for recent preprints
curl "https://api.biorxiv.org/pubs/biorxiv/2024-01-01/2024-06-30/0" \
  | jq '.collection[] | select(.published_doi != "")'
```

### Build a Preprint Alert System

Paginate through all results for a given date range to build a comprehensive alert feed:

```python
import requests

base = "https://api.biorxiv.org/details/biorxiv/2024-06-01/2024-06-07"
cursor = 0
all_preprints = []

while True:
    resp = requests.get(f"{base}/{cursor}").json()
    records = resp.get("collection", [])
    if not records:
        break
    all_preprints.extend(records)
    cursor += 100

print(f"Total preprints retrieved: {len(all_preprints)}")
```

## References

- Official documentation: https://api.biorxiv.org/
- bioRxiv homepage: https://www.biorxiv.org/
- medRxiv API (same structure): https://api.biorxiv.org/ (use `medrxiv` as server parameter)

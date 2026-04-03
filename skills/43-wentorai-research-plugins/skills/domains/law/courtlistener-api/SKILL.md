---
name: courtlistener-api
description: "Legal case law database with PACER data and judge profiles"
metadata:
  openclaw:
    emoji: "🔍"
    category: "domains"
    subcategory: "law"
    keywords: ["law", "case law", "legal theory", "compliance analysis", "jurisprudence"]
    source: "https://www.courtlistener.com/api/rest-info/"
---

# CourtListener API Guide

## Overview

CourtListener is a free legal research platform operated by Free Law Project, a non-profit organization dedicated to making legal data freely accessible. The platform hosts one of the largest open collections of U.S. case law, containing millions of court opinions, docket entries, oral arguments, and judge profiles sourced from PACER (Public Access to Court Electronic Records), state court websites, and historical digitization efforts.

The CourtListener REST API provides programmatic access to this extensive legal database, enabling searches across court opinions, dockets, judge biographical data, and court information. The API covers federal courts (Supreme Court, Circuit Courts, District Courts, Bankruptcy Courts) and many state courts, with records spanning from the founding of the republic to the present day.

Legal scholars, law students, practicing attorneys, journalists, policy researchers, and civic technologists use the CourtListener API to conduct legal research, perform empirical legal studies, build litigation analytics tools, track judicial behavior, monitor active litigation, and analyze trends in case law. It serves as a critical resource for computational legal studies and access-to-justice initiatives.

## Authentication

No authentication is required for basic API access. The CourtListener API is publicly accessible for read operations. However, creating an account and using an API token provides higher rate limits and access to additional features. Authentication is recommended for production applications.

To obtain an API token:
1. Create a free account at https://www.courtlistener.com/
2. Navigate to your profile settings
3. Generate an API token
4. Include it in the `Authorization` header

```bash
# Unauthenticated request
curl "https://www.courtlistener.com/api/rest/v4/opinions/?q=first+amendment"

# Authenticated request (higher rate limits)
curl -H "Authorization: Token YOUR_TOKEN" \
  "https://www.courtlistener.com/api/rest/v4/opinions/?q=first+amendment"
```

## Core Endpoints

### opinions: Search Court Opinions

Search and retrieve the full text of court opinions (judicial decisions) across all indexed courts.

- **URL**: `GET https://www.courtlistener.com/api/rest/v4/opinions/`
- **Parameters**:

| Parameter      | Type   | Required | Description                                          |
|----------------|--------|----------|------------------------------------------------------|
| q              | string | No       | Full-text search query                               |
| court          | string | No       | Court identifier (e.g., `scotus`, `ca9`)             |
| date_filed_min | string | No       | Minimum filing date (YYYY-MM-DD)                     |
| date_filed_max | string | No       | Maximum filing date (YYYY-MM-DD)                     |
| type           | string | No       | Opinion type: `010combined`, `020lead`, etc.         |
| ordering       | string | No       | Sort order: `date_filed`, `-date_filed`              |
| page           | int    | No       | Page number for pagination                           |

- **Example**:

```bash
curl "https://www.courtlistener.com/api/rest/v4/opinions/?q=privacy+fourth+amendment&court=scotus&ordering=-date_filed"
```

- **Response**: Returns paginated results with `count`, `next`, `previous`, and `results` array. Each opinion includes `id`, `absolute_url`, `cluster` (case metadata), `author` (judge), `type`, `date_filed`, `plain_text` or `html` (opinion text), `download_url`, and `citations`.

### dockets: Access Case Dockets

Search and retrieve docket information including case metadata, parties, attorneys, and docket entries from PACER and other sources.

- **URL**: `GET https://www.courtlistener.com/api/rest/v4/dockets/`
- **Parameters**:

| Parameter       | Type   | Required | Description                                       |
|-----------------|--------|----------|---------------------------------------------------|
| q               | string | No       | Full-text search query                            |
| court           | string | No       | Court identifier                                  |
| date_filed_min  | string | No       | Minimum filing date                               |
| date_filed_max  | string | No       | Maximum filing date                               |
| case_name       | string | No       | Filter by case name                               |
| docket_number   | string | No       | Filter by docket number                           |
| ordering        | string | No       | Sort order field                                  |

- **Example**:

```bash
curl "https://www.courtlistener.com/api/rest/v4/dockets/?q=antitrust&court=scotus&ordering=-date_filed"
```

- **Response**: Returns `count`, `results` array with `id`, `case_name`, `docket_number`, `court`, `date_filed`, `date_terminated`, `nature_of_suit`, `assigned_to` (judge), `referred_to`, and `docket_entries`.

### courts: Court Information

Retrieve information about courts in the CourtListener database, including jurisdiction, location, and identifiers.

- **URL**: `GET https://www.courtlistener.com/api/rest/v4/courts/`
- **Parameters**:

| Parameter    | Type   | Required | Description                                     |
|--------------|--------|----------|-------------------------------------------------|
| jurisdiction | string | No       | Filter by jurisdiction type: `F` (federal), `S` (state) |

- **Example**:

```bash
curl "https://www.courtlistener.com/api/rest/v4/courts/?jurisdiction=F"
```

- **Response**: Returns court objects with `id`, `full_name`, `short_name`, `jurisdiction`, `position`, `start_date`, `end_date`, and `url`.

### people: Judge Profiles

Access biographical and professional information about judges, including their appointment history, education, and political affiliations.

- **URL**: `GET https://www.courtlistener.com/api/rest/v4/people/`
- **Parameters**:

| Parameter    | Type   | Required | Description                              |
|--------------|--------|----------|------------------------------------------|
| q            | string | No       | Name search query                        |
| court        | string | No       | Filter by court served                   |
| appointer    | int    | No       | Filter by appointing authority           |

- **Example**:

```bash
curl "https://www.courtlistener.com/api/rest/v4/people/?q=ginsburg"
```

- **Response**: Returns judge profiles with `id`, `name_first`, `name_last`, `date_of_birth`, `gender`, `positions` (court appointments with dates), `education`, `political_affiliations`, and `aba_ratings`.

### search: Unified Search

Perform a unified full-text search across all CourtListener content types.

- **URL**: `GET https://www.courtlistener.com/api/rest/v4/search/`
- **Parameters**:

| Parameter | Type   | Required | Description                                   |
|-----------|--------|----------|-----------------------------------------------|
| q         | string | Yes      | Search query                                  |
| type      | string | No       | Content type: `o` (opinions), `r` (RECAP), `oa` (oral arguments) |

- **Example**:

```bash
curl "https://www.courtlistener.com/api/rest/v4/search/?q=net+neutrality&type=o"
```

- **Response**: Returns unified search results with relevance scoring across content types.

## Rate Limits

The CourtListener API allows up to 5,000 requests per hour for unauthenticated users. Authenticated users with API tokens receive higher limits. The API returns standard HTTP 429 responses when limits are exceeded. For bulk data access, CourtListener provides downloadable bulk data files at https://www.courtlistener.com/api/bulk-info/ which are more appropriate for large-scale research projects. The bulk data includes complete opinion texts, docket metadata, and judge biographical data.

## Common Patterns

### Track Recent Supreme Court Opinions

Monitor new opinions from the Supreme Court of the United States:

```python
import requests

params = {
    "court": "scotus",
    "ordering": "-date_filed",
    "page_size": 10
}
resp = requests.get("https://www.courtlistener.com/api/rest/v4/opinions/", params=params)
data = resp.json()

for opinion in data["results"]:
    cluster = opinion.get("cluster", {})
    print(f"{opinion['date_filed']}: {cluster.get('case_name', 'Unknown')}")
```

### Empirical Analysis of Judicial Citations

Study citation patterns across courts and time periods:

```python
import requests

params = {
    "q": "stare decisis",
    "court": "scotus",
    "date_filed_min": "2020-01-01",
    "ordering": "-date_filed"
}
resp = requests.get("https://www.courtlistener.com/api/rest/v4/search/", params={**params, "type": "o"})
results = resp.json()

print(f"Found {results['count']} opinions mentioning 'stare decisis' since 2020")
```

### Judge Appointment Analysis

Research judicial appointments and their characteristics:

```bash
curl "https://www.courtlistener.com/api/rest/v4/people/?court=scotus&ordering=-date_nominated"
```

## References

- Official API documentation: https://www.courtlistener.com/api/rest-info/
- CourtListener homepage: https://www.courtlistener.com/
- Bulk data downloads: https://www.courtlistener.com/api/bulk-info/
- Free Law Project: https://free.law/
- RECAP Archive: https://www.courtlistener.com/recap/

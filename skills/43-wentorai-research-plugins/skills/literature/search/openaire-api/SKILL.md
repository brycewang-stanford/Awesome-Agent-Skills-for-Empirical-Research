---
name: openaire-api
description: "Search EU-funded research outputs via the OpenAIRE Graph API"
metadata:
  openclaw:
    emoji: "🇪🇺"
    category: "literature"
    subcategory: "search"
    keywords: ["openaire", "european research", "open science", "EU funding", "research outputs", "open access"]
    source: "https://develop.openaire.eu/"
---

# OpenAIRE Graph API

## Overview

OpenAIRE is the European Open Science infrastructure providing programmatic access to millions of research outputs — publications, datasets, software, and other research products — linked to EU-funded projects, organizations, and researchers. The Graph API is free, requires no authentication, and returns JSON or XML. Uniquely valuable for discovering EU/Horizon-funded research and tracing connections between research outputs, projects, and institutions.

## API Endpoints

### Base URL

```
https://api.openaire.eu
```

### Search Publications

```bash
# Search by keywords
curl "https://api.openaire.eu/search/publications?keywords=climate+change+adaptation&format=json&size=10"

# Filter by open access
curl "https://api.openaire.eu/search/publications?keywords=machine+learning&openaccessonly=true&format=json"

# Filter by date
curl "https://api.openaire.eu/search/publications?keywords=CRISPR&fromDateAccepted=2023-01-01&toDateAccepted=2026-12-31&format=json"

# Filter by EU project
curl "https://api.openaire.eu/search/publications?projectID=corda__h2020::123456&format=json"

# Search by DOI
curl "https://api.openaire.eu/search/publications?doi=10.1038/s41586-023-05881-4&format=json"
```

### Search Datasets

```bash
# Find research datasets
curl "https://api.openaire.eu/search/datasets?keywords=genomics+sequencing&format=json&size=20"

# Open access datasets only
curl "https://api.openaire.eu/search/datasets?keywords=ocean+temperature&openaccessonly=true&format=json"
```

### Search Projects

```bash
# Search EU-funded projects
curl "https://api.openaire.eu/search/projects?keywords=artificial+intelligence&funder=EC&format=json"

# Horizon 2020 projects
curl "https://api.openaire.eu/search/projects?keywords=renewable+energy&fundingStream=H2020&format=json"

# Horizon Europe projects
curl "https://api.openaire.eu/search/projects?keywords=quantum+computing&fundingStream=HE&format=json"
```

### Query Parameters

| Parameter | Description | Example |
|-----------|-------------|---------|
| `keywords` | Free-text search | `keywords=deep+learning` |
| `doi` | Search by DOI | `doi=10.1234/example` |
| `openaccessonly` | Open access filter | `openaccessonly=true` |
| `fromDateAccepted` | Start date | `fromDateAccepted=2023-01-01` |
| `toDateAccepted` | End date | `toDateAccepted=2026-12-31` |
| `funder` | Funding agency | `funder=EC` (European Commission) |
| `fundingStream` | Funding program | `fundingStream=H2020` |
| `format` | Response format | `format=json` or `format=xml` |
| `size` | Results per page | `size=50` (max 100) |
| `page` | Page number | `page=2` |
| `sortBy` | Sort order | `sortBy=resultdateofacceptance,descending` |

## Python Usage

```python
import requests

BASE_URL = "https://api.openaire.eu"

def search_publications(keywords: str, open_access: bool = False,
                         from_date: str = None, size: int = 20) -> list:
    """Search OpenAIRE publications."""
    params = {
        "keywords": keywords,
        "format": "json",
        "size": size
    }
    if open_access:
        params["openaccessonly"] = "true"
    if from_date:
        params["fromDateAccepted"] = from_date

    resp = requests.get(f"{BASE_URL}/search/publications", params=params)
    resp.raise_for_status()
    data = resp.json()

    results = []
    for item in data.get("response", {}).get("results", {}).get("result", []):
        metadata = item.get("metadata", {}).get("oaf:entity", {}).get("oaf:result", {})
        title = metadata.get("title", {})
        if isinstance(title, dict):
            title = title.get("$", "")
        results.append({
            "title": title,
            "doi": metadata.get("pid", [{}])[0].get("$", "") if metadata.get("pid") else None,
            "date": metadata.get("dateofacceptance", {}).get("$", ""),
            "description": metadata.get("description", {}).get("$", "")[:300] if metadata.get("description") else None
        })
    return results

# Example: find recent open access papers on climate
pubs = search_publications("climate resilience urban", open_access=True, from_date="2024-01-01")
for p in pubs:
    print(f"[{p['date']}] {p['title']}")
```

## Unique Capabilities

- **Project-output linking**: Trace which publications came from which EU grant
- **Cross-entity relationships**: Publications ↔ Datasets ↔ Software ↔ Projects ↔ Organizations
- **Deduplication**: OpenAIRE deduplicates records from multiple sources (Crossref, PubMed, arXiv, institutional repos)
- **Open access monitoring**: Track OA compliance for funded research
- **175M+ research products** from 120,000+ data sources

## References

- [OpenAIRE API Documentation](https://develop.openaire.eu/)
- [OpenAIRE Graph](https://graph.openaire.eu/)
- [OpenAIRE EXPLORE Portal](https://explore.openaire.eu/)

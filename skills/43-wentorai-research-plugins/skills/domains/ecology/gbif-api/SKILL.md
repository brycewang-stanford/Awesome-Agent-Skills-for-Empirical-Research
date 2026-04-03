---
name: gbif-api
description: "Global biodiversity data API for species occurrences and datasets"
metadata:
  openclaw:
    emoji: "🔍"
    category: "domains"
    subcategory: "ecology"
    keywords: ["ecology", "biodiversity", "taxonomy", "environmental science"]
    source: "https://www.gbif.org/developer/summary"
---

# GBIF API Guide

## Overview

The Global Biodiversity Information Facility (GBIF) is an international network and data infrastructure funded by governments worldwide, aimed at providing open access to biodiversity data. GBIF aggregates hundreds of millions of species occurrence records from natural history collections, citizen science platforms, monitoring networks, and published literature across the globe.

The GBIF API provides programmatic access to this vast repository of biodiversity data. Researchers can search for species occurrences by taxonomy, geography, time period, and dataset. The API also supports taxonomic name matching, dataset discovery, and species profile lookups. It serves as a foundational resource for ecological research, conservation planning, biogeography, and environmental impact assessments.

Ecologists, conservation biologists, biogeographers, and environmental scientists rely on the GBIF API to retrieve georeferenced occurrence data for species distribution modeling, climate change impact analysis, invasive species tracking, and biodiversity hotspot identification. The data is freely available under open data licenses.

## Authentication

No authentication required for read access. The GBIF API is publicly accessible without any API key or token. All search and retrieval endpoints are open. User authentication is only required for data publishing operations (creating datasets and uploading occurrences), which requires a GBIF account.

## Core Endpoints

### occurrence/search: Search Species Occurrences

Search for georeferenced biodiversity observation and specimen records across all GBIF-indexed datasets.

- **URL**: `GET https://api.gbif.org/v1/occurrence/search`
- **Parameters**:

| Parameter       | Type   | Required | Description                                          |
|-----------------|--------|----------|------------------------------------------------------|
| q               | string | No       | Full-text search query                               |
| taxonKey        | int    | No       | GBIF backbone taxonomy key                           |
| scientificName  | string | No       | Scientific name to filter by                         |
| country         | string | No       | ISO 3166-1 alpha-2 country code                      |
| hasCoordinate   | bool   | No       | Filter for georeferenced records only                |
| year            | string | No       | Year or range (e.g., `2020,2024`)                    |
| limit           | int    | No       | Number of results (default 20, max 300)              |
| offset          | int    | No       | Pagination offset                                    |

- **Example**:

```bash
curl "https://api.gbif.org/v1/occurrence/search?scientificName=Panthera+tigris&hasCoordinate=true&limit=10"
```

- **Response**: Returns `count` (total matches), `results` array with `key`, `scientificName`, `decimalLatitude`, `decimalLongitude`, `country`, `basisOfRecord`, `eventDate`, `datasetKey`, `publishingOrgKey`, and `media` links.

### species/match: Taxonomic Name Matching

Match a species name against the GBIF backbone taxonomy to resolve canonical names and get taxonomy keys.

- **URL**: `GET https://api.gbif.org/v1/species/match`
- **Parameters**:

| Parameter | Type   | Required | Description                              |
|-----------|--------|----------|------------------------------------------|
| name      | string | Yes      | Scientific name to match                 |
| kingdom   | string | No       | Kingdom filter for disambiguation        |
| strict    | bool   | No       | If true, only return exact matches       |

- **Example**:

```bash
curl "https://api.gbif.org/v1/species/match?name=Homo+sapiens"
```

- **Response**: Returns `usageKey`, `scientificName`, `canonicalName`, `rank`, `status`, `kingdom`, `phylum`, `class`, `order`, `family`, `genus`, `species`, `confidence` score, and `matchType`.

### dataset: Discover Datasets

Search for and retrieve metadata about GBIF-indexed datasets from publishers worldwide.

- **URL**: `GET https://api.gbif.org/v1/dataset`
- **Parameters**:

| Parameter       | Type   | Required | Description                                     |
|-----------------|--------|----------|-------------------------------------------------|
| q               | string | No       | Full-text search query                          |
| type            | string | No       | Dataset type: `OCCURRENCE`, `CHECKLIST`, etc.   |
| publishingOrg   | string | No       | Publishing organization UUID                    |
| limit           | int    | No       | Number of results (default 20, max 1000)        |
| offset          | int    | No       | Pagination offset                               |

- **Example**:

```bash
curl "https://api.gbif.org/v1/dataset?q=bird+monitoring&type=OCCURRENCE&limit=5"
```

- **Response**: Returns `count`, `results` array with `key`, `title`, `description`, `type`, `publishingOrganizationKey`, `license`, `recordCount`, and `endpoints`.

## Rate Limits

No formal rate limits are enforced on the GBIF API. However, GBIF recommends responsible use patterns. Large data downloads (millions of records) should use the asynchronous download API at `https://api.gbif.org/v1/occurrence/download/request` rather than paginating through the search endpoint. The search endpoint is limited to 100,000 records maximum per query via pagination.

## Common Patterns

### Species Distribution Mapping

Retrieve georeferenced occurrence data for species distribution modeling:

```python
import requests

params = {
    "taxonKey": 2480498,  # Panthera tigris
    "hasCoordinate": True,
    "limit": 300
}
resp = requests.get("https://api.gbif.org/v1/occurrence/search", params=params)
data = resp.json()

coordinates = [(r["decimalLongitude"], r["decimalLatitude"])
               for r in data["results"]
               if "decimalLongitude" in r and "decimalLatitude" in r]

print(f"Retrieved {len(coordinates)} georeferenced occurrences of {data['results'][0]['scientificName']}")
```

### Taxonomic Name Resolution Pipeline

Resolve a list of species names against the GBIF backbone taxonomy:

```python
import requests

names = ["Homo sapiens", "Canis lupus", "Quercus robur", "Drosophila melanogaster"]

for name in names:
    resp = requests.get("https://api.gbif.org/v1/species/match", params={"name": name})
    match = resp.json()
    print(f"{name} -> {match['canonicalName']} (key: {match['usageKey']}, confidence: {match['confidence']})")
```

### Bulk Occurrence Download

For large-scale analyses requiring millions of records, use the asynchronous download API:

```bash
curl -X POST "https://api.gbif.org/v1/occurrence/download/request" \
  -H "Content-Type: application/json" \
  -u username:password \
  -d '{"creator":"username","predicate":{"type":"equals","key":"TAXON_KEY","value":"2480498"}}'
```

## References

- Official API documentation: https://www.gbif.org/developer/summary
- GBIF occurrence search API: https://www.gbif.org/developer/occurrence
- GBIF species API: https://www.gbif.org/developer/species
- GBIF data use guide: https://www.gbif.org/data-use

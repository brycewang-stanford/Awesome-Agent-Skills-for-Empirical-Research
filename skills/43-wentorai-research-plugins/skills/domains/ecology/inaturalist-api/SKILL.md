---
name: inaturalist-api
description: "Citizen science platform API for biodiversity observations"
metadata:
  openclaw:
    emoji: "🔍"
    category: "domains"
    subcategory: "ecology"
    keywords: ["ecology", "biodiversity", "taxonomy", "evolutionary biology"]
    source: "https://www.inaturalist.org/pages/api+reference"
---

# iNaturalist API Guide

## Overview

iNaturalist is a citizen science platform and social network for naturalists, jointly operated by the California Academy of Sciences and the National Geographic Society. The platform enables users to record and share observations of organisms in nature, which are then identified by the community and validated by computer vision models. With over 150 million observations of more than 400,000 species, iNaturalist is one of the largest biodiversity data sources in the world.

The iNaturalist API provides programmatic access to this massive observational dataset. Researchers can query observations by taxonomy, geography, time period, observer, and data quality grade. The API also provides access to taxonomic information, place boundaries, and project data. Research-grade observations (those with community-verified identifications) are automatically shared with GBIF for integration into the global biodiversity data infrastructure.

Ecologists, conservation biologists, evolutionary biologists, and citizen science coordinators use the iNaturalist API to analyze species distributions, track phenological patterns, study urban biodiversity, monitor invasive species, and validate species distribution models. The platform's broad geographic and taxonomic coverage makes it particularly valuable for large-scale ecological analyses.

## Authentication

No authentication is required for read-only access to public data. The iNaturalist API v1 allows anonymous queries for observations, taxa, and places. Authentication via OAuth 2.0 is only needed for write operations such as creating observations, adding identifications, or managing projects.

For authenticated requests, register an application at https://www.inaturalist.org/oauth/applications and use the OAuth 2.0 flow to obtain an access token.

## Core Endpoints

### observations: Search Biodiversity Observations

Query the iNaturalist observation database with filters for taxonomy, geography, time, and data quality.

- **URL**: `GET https://api.inaturalist.org/v1/observations`
- **Parameters**:

| Parameter      | Type   | Required | Description                                             |
|----------------|--------|----------|---------------------------------------------------------|
| taxon_id       | int    | No       | iNaturalist taxon ID to filter by                       |
| place_id       | int    | No       | Place ID to filter by geographic area                   |
| lat            | float  | No       | Latitude for geographic search                          |
| lng            | float  | No       | Longitude for geographic search                         |
| radius         | int    | No       | Search radius in km (used with lat/lng)                 |
| d1             | string | No       | Start date (YYYY-MM-DD)                                 |
| d2             | string | No       | End date (YYYY-MM-DD)                                   |
| quality_grade  | string | No       | `research`, `needs_id`, or `casual`                     |
| per_page       | int    | No       | Results per page (default 30, max 200)                  |
| page           | int    | No       | Page number                                             |
| order_by       | string | No       | Sort field: `created_at`, `observed_on`, `votes`        |

- **Example**:

```bash
curl "https://api.inaturalist.org/v1/observations?taxon_id=3&quality_grade=research&place_id=1&per_page=10"
```

- **Response**: Returns `total_results`, `results` array with `id`, `species_guess`, `taxon` (name, rank, ancestry), `location` (lat,lng), `observed_on`, `quality_grade`, `photos`, `user`, `identifications_count`, and `geojson`.

### taxa: Taxonomic Information

Look up taxonomic information, search for species, and retrieve taxonomic hierarchies.

- **URL**: `GET https://api.inaturalist.org/v1/taxa`
- **Parameters**:

| Parameter | Type   | Required | Description                                  |
|-----------|--------|----------|----------------------------------------------|
| q         | string | No       | Name search query                            |
| taxon_id  | int    | No       | Specific taxon ID                            |
| rank      | string | No       | Filter by rank: `species`, `genus`, etc.     |
| is_active | bool   | No       | Filter for active/inactive taxa              |
| per_page  | int    | No       | Results per page (default 30, max 200)       |

- **Example**:

```bash
curl "https://api.inaturalist.org/v1/taxa?q=monarch+butterfly&rank=species"
```

- **Response**: Returns `results` array with `id`, `name`, `preferred_common_name`, `rank`, `observations_count`, `ancestors`, `default_photo`, `wikipedia_url`, and `conservation_status`.

### places: Geographic Place Boundaries

Retrieve geographic place definitions used for filtering observations.

- **URL**: `GET https://api.inaturalist.org/v1/places`
- **Parameters**:

| Parameter | Type   | Required | Description                           |
|-----------|--------|----------|---------------------------------------|
| q         | string | No       | Place name search query               |
| per_page  | int    | No       | Results per page                      |

- **Example**:

```bash
curl "https://api.inaturalist.org/v1/places/autocomplete?q=Yellowstone"
```

- **Response**: Returns `results` with `id`, `name`, `display_name`, `bounding_box_geojson`, `location`, and `admin_level`.

## Rate Limits

The iNaturalist API enforces a rate limit of 100 requests per minute. Exceeding this limit returns HTTP 429 responses. For large-scale data exports, iNaturalist recommends using their export tools at https://www.inaturalist.org/observations/export or downloading the GBIF-shared dataset. The API also supports `If-Modified-Since` headers for efficient polling of updated records.

## Common Patterns

### Species Distribution Analysis

Retrieve research-grade observations of a species for distribution modeling:

```python
import requests

params = {
    "taxon_id": 48484,  # Danaus plexippus (Monarch Butterfly)
    "quality_grade": "research",
    "per_page": 200,
    "order_by": "observed_on"
}

resp = requests.get("https://api.inaturalist.org/v1/observations", params=params)
data = resp.json()

for obs in data["results"]:
    if obs.get("location"):
        lat, lng = obs["location"].split(",")
        print(f"{obs['observed_on']}: ({lat}, {lng}) - {obs['taxon']['name']}")
```

### Phenology Tracking

Monitor seasonal patterns by analyzing observation dates across years:

```python
import requests
from collections import Counter

params = {
    "taxon_id": 48484,
    "quality_grade": "research",
    "per_page": 200,
    "place_id": 1  # United States
}

resp = requests.get("https://api.inaturalist.org/v1/observations", params=params)
months = Counter()

for obs in resp.json()["results"]:
    if obs.get("observed_on"):
        month = obs["observed_on"][5:7]
        months[month] += 1

for month in sorted(months):
    print(f"Month {month}: {months[month]} observations")
```

### Invasive Species Monitoring

Track observations of invasive species in a specific region:

```bash
# Search for Spotted Lanternfly observations in Pennsylvania
curl "https://api.inaturalist.org/v1/observations?taxon_id=325295&place_id=46&quality_grade=research&per_page=50"
```

## References

- Official API reference: https://www.inaturalist.org/pages/api+reference
- API v1 documentation: https://api.inaturalist.org/v1/docs/
- iNaturalist homepage: https://www.inaturalist.org/
- Data export tools: https://www.inaturalist.org/observations/export

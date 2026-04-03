---
name: osf-api-guide
description: "Access Open Science Framework for preregistrations, preprints, and data"
metadata:
  openclaw:
    emoji: "🔓"
    category: "research"
    subcategory: "methodology"
    keywords: ["osf", "open-science", "preregistration", "preprints", "reproducibility", "collaboration"]
    source: "https://developer.osf.io/"
---

# OSF (Open Science Framework) API Guide

## Overview

The Open Science Framework (OSF) is a free, open-source platform developed by the Center for Open Science (COS) that supports the entire research lifecycle. It provides tools for project management, preregistration of studies, data storage, preprint hosting, and research collaboration. OSF is widely used across social sciences, psychology, and increasingly in other disciplines as a hub for transparent and reproducible research.

The OSF API v2 is a JSON:API-compliant RESTful interface that provides programmatic access to the full range of OSF features. Researchers can search for preregistrations, browse preprints hosted on OSF Preprints and its community servers (such as PsyArXiv, SocArXiv, and BioHackrXiv), access project files and metadata, and manage their own research projects.

Public data on OSF is accessible without authentication. Creating or modifying resources requires a personal access token. The API is free for all users.

## Authentication

Public read access requires no authentication. For creating or modifying resources, generate a personal access token at https://osf.io/settings/tokens.

```bash
# Public access (no auth needed)
curl "https://api.osf.io/v2/nodes/?filter[title]=reproducibility"

# Authenticated access for write operations
export OSF_TOKEN=$OSF_TOKEN
curl -H "Authorization: Bearer $OSF_TOKEN" \
  "https://api.osf.io/v2/users/me/"
```

## Core Endpoints

### Search Nodes (Projects)

Find public OSF projects by title, tags, or other attributes.

```
GET https://api.osf.io/v2/nodes/?filter[title]={query}
```

**Parameters:**
- `filter[title]`: Filter by project title (contains match)
- `filter[tags]`: Filter by tags
- `filter[category]`: Filter by category (project, data, analysis, etc.)
- `page[size]`: Results per page (default 10, max 100)
- `page`: Page number

**Example: Search for replication studies:**

```bash
curl -s "https://api.osf.io/v2/nodes/?filter[title]=replication&page[size]=5" \
  | python3 -m json.tool
```

### Search Preprints

Browse preprints across OSF and its community preprint servers.

```
GET https://api.osf.io/v2/preprints/?filter[provider]={provider}
```

```bash
curl -s "https://api.osf.io/v2/preprints/?filter[provider]=psyarxiv&page[size]=5" \
  | python3 -m json.tool
```

### Get Preregistrations

Search for preregistered studies, a cornerstone of open science methodology.

```
GET https://api.osf.io/v2/registrations/?filter[title]={query}
```

```bash
curl -s "https://api.osf.io/v2/registrations/?filter[title]=cognitive+bias&page[size]=5" \
  | python3 -m json.tool
```

### Python Example: Analyze Preregistration Trends

```python
import requests
import time

BASE_URL = "https://api.osf.io/v2"

def search_registrations(query, max_pages=5):
    """Search OSF registrations (preregistered studies)."""
    all_results = []
    url = f"{BASE_URL}/registrations/"
    params = {
        "filter[title]": query,
        "page[size]": 25,
        "page": 1
    }

    for page_num in range(1, max_pages + 1):
        params["page"] = page_num
        resp = requests.get(url, params=params)
        data = resp.json()
        results = data.get("data", [])
        if not results:
            break
        all_results.extend(results)
        time.sleep(0.5)

    return all_results

registrations = search_registrations("randomized controlled trial")
print(f"Found {len(registrations)} preregistrations")

for reg in registrations[:5]:
    attrs = reg.get("attributes", {})
    print(f"  Title: {attrs.get('title')}")
    print(f"  Created: {attrs.get('date_created', '')[:10]}")
    print(f"  Category: {attrs.get('category')}")
    print(f"  Public: {attrs.get('public')}")
    print("---")
```

### Get Project Files

List files attached to an OSF project node.

```bash
curl -s "https://api.osf.io/v2/nodes/{node_id}/files/osfstorage/" \
  | python3 -m json.tool
```

## Common Research Patterns

**Preregistration Review:** Search for preregistered studies in your field to understand how others formulate hypotheses, specify sample sizes, and plan analyses before data collection. This is essential for meta-science and methodological research.

**Preprint Discovery:** Use the preprints endpoint to find the latest unrefereed manuscripts across multiple community servers, getting access to cutting-edge findings before formal publication.

**Open Data Access:** Retrieve datasets attached to OSF projects for replication attempts, secondary analyses, or meta-analyses. OSF projects often include raw data, analysis scripts, and materials.

**Collaboration Mapping:** Explore contributors and linked projects to understand research collaboration networks in specific domains.

**Reproducibility Audits:** Programmatically check whether published studies have associated preregistrations, open data, or open materials on OSF.

## Rate Limits and Best Practices

- **Rate limit:** 100 requests per minute for unauthenticated, higher limits for authenticated requests
- **Pagination:** Use `page` and `page[size]` parameters; default page size is 10
- **JSON:API format:** Responses follow JSON:API specification; data is under the `data` key, relationships are linked
- **Sparse fieldsets:** Use `fields[nodes]=title,date_created` to request only needed fields
- **Embedding:** Use `embed=contributors` to include related resources in a single request
- **Respect the service:** Add delays between rapid sequential requests; use the `links.next` URL for pagination

## References

- OSF API v2 Documentation: https://developer.osf.io/
- OSF Platform: https://osf.io/
- OSF Preprints: https://osf.io/preprints/
- OSF Registrations (Preregistration): https://osf.io/registries/
- Center for Open Science: https://www.cos.io/

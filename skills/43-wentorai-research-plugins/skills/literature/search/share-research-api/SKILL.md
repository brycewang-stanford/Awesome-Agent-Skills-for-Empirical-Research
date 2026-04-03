---
name: share-research-api
description: "Discover open access research outputs via the SHARE notification API"
metadata:
  openclaw:
    emoji: "📢"
    category: "literature"
    subcategory: "search"
    keywords: ["SHARE", "open access", "research notification", "COS", "repository aggregator", "preprints"]
    source: "https://share.osf.io/"
---

# SHARE Research API

## Overview

SHARE (SHared Access Research Ecosystem) aggregates metadata from 200+ research repositories, preprint servers, and publishers into a unified search API. Operated by the Center for Open Science, it tracks research outputs as they move through the scholarly communication cycle — from preprint to publication. Free, no authentication for search.

## API Endpoints

### Base URL

```
https://share.osf.io/api/v2
```

### Search

```bash
# Text search across all sources
curl "https://share.osf.io/api/v2/search/creativeworks/?q=climate+change&page[size]=20"

# Filter by type
curl "https://share.osf.io/api/v2/search/creativeworks/?q=neural+networks&filter[type]=preprint"

# Filter by source
curl "https://share.osf.io/api/v2/search/creativeworks/?q=genomics&filter[sources]=PubMed+Central"

# Filter by date
curl "https://share.osf.io/api/v2/search/creativeworks/?q=COVID-19&filter[date][gte]=2024-01-01"

# Filter by tag/subject
curl "https://share.osf.io/api/v2/search/creativeworks/?q=machine+learning&filter[tags]=deep+learning"
```

### Query Parameters

| Parameter | Description | Example |
|-----------|-------------|---------|
| `q` | Search query | `q=CRISPR` |
| `filter[type]` | Output type | `preprint`, `article`, `dataset`, `thesis` |
| `filter[sources]` | Source repository | `PubMed Central`, `arXiv`, `Zenodo` |
| `filter[date][gte]` | From date | `2024-01-01` |
| `filter[date][lte]` | Until date | `2026-12-31` |
| `filter[tags]` | Tag filter | `open+data` |
| `page[size]` | Results per page | `page[size]=50` |
| `sort` | Sort order | `-date_updated` |

### Available Sources (200+)

| Source | Type |
|--------|------|
| arXiv | Preprints |
| PubMed Central | Biomedical articles |
| Zenodo | Multi-discipline repository |
| Figshare | Data/figures |
| SSRN | Social science preprints |
| DataCite | Research data |
| Institutional repositories | Various |

## Python Usage

```python
import requests

BASE_URL = "https://share.osf.io/api/v2"


def search_share(query: str, output_type: str = None,
                 source: str = None,
                 from_date: str = None,
                 page_size: int = 20) -> list:
    """Search SHARE for research outputs."""
    params = {"q": query, "page[size]": page_size}
    if output_type:
        params["filter[type]"] = output_type
    if source:
        params["filter[sources]"] = source
    if from_date:
        params["filter[date][gte]"] = from_date

    resp = requests.get(
        f"{BASE_URL}/search/creativeworks/",
        params=params,
    )
    resp.raise_for_status()
    data = resp.json()

    results = []
    for item in data.get("data", []):
        attrs = item.get("attributes", {})
        results.append({
            "title": attrs.get("title"),
            "description": (attrs.get("description") or "")[:300],
            "type": attrs.get("type"),
            "date": attrs.get("date_updated", "")[:10],
            "sources": attrs.get("sources", []),
            "tags": attrs.get("tags", []),
            "identifiers": attrs.get("identifiers", []),
        })
    return results


# Example: find recent preprints on a topic
preprints = search_share(
    "transformer architecture",
    output_type="preprint",
    from_date="2024-01-01",
)
for p in preprints[:5]:
    print(f"[{p['date']}] {p['title']}")
    print(f"  Type: {p['type']} | Sources: {', '.join(p['sources'][:3])}")
```

## References

- [SHARE](https://share.osf.io/)
- [SHARE API Documentation](https://share.osf.io/api/v2/)
- [Center for Open Science](https://cos.io/)

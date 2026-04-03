---
name: scielo-api
description: "Access Latin American and developing world research via SciELO API"
metadata:
  openclaw:
    emoji: "🌎"
    category: "literature"
    subcategory: "search"
    keywords: ["SciELO", "Latin America", "open access journals", "developing countries", "Brazilian research", "Spanish research"]
    source: "https://wiki.scielo.org/"
---

# SciELO API

## Overview

SciELO (Scientific Electronic Library Online) is the primary open access platform for scholarly journals in Latin America, the Caribbean, Spain, Portugal, and South Africa. It indexes 1,800+ peer-reviewed journals and 900K+ articles, many not indexed elsewhere. All content is open access. The API provides article search, journal metadata, and bibliometric indicators. Free, no authentication required.

## API Endpoints

### ArticleMeta API

Search and retrieve articles:

```bash
# Search articles by keyword
curl "https://articlemeta.scielo.org/api/v1/article/?collection=scl&q=machine+learning"

# Get article by PID (SciELO identifier)
curl "https://articlemeta.scielo.org/api/v1/article/?code=S0100-204X2024000100001"

# Filter by collection (country)
curl "https://articlemeta.scielo.org/api/v1/article/?collection=esp&q=climate+change"

# Filter by journal ISSN
curl "https://articlemeta.scielo.org/api/v1/article/?issn=0100-204X&from_date=2024-01-01"
```

### Collection Codes

| Code | Country/Region |
|------|---------------|
| `scl` | Brazil |
| `esp` | Spain |
| `mex` | Mexico |
| `col` | Colombia |
| `chl` | Chile |
| `arg` | Argentina |
| `cub` | Cuba |
| `ven` | Venezuela |
| `prt` | Portugal |
| `zaf` | South Africa |

### Journal Metadata

```bash
# List journals in a collection
curl "https://articlemeta.scielo.org/api/v1/journal/?collection=scl"

# Get journal by ISSN
curl "https://articlemeta.scielo.org/api/v1/journal/?issn=0100-204X"

# Journal indicators
curl "https://analytics.scielo.org/api/v1/journal/?issn=0100-204X"
```

### SciELO Search API

Full-text search with facets:

```bash
# Full-text search
curl "https://search.scielo.org/?q=biodiversity+conservation&format=json&count=20"

# Filter by subject area
curl "https://search.scielo.org/?q=neural+networks&filter[subject_area]=Computer+Science&format=json"

# Filter by year range
curl "https://search.scielo.org/?q=CRISPR&filter[year_cluster]=2023-2026&format=json"

# Filter by language
curl "https://search.scielo.org/?q=epidemiology&filter[la]=en&format=json"
```

### Query Parameters

| Parameter | Description | Example |
|-----------|-------------|---------|
| `q` | Free-text query | `q=tropical+ecology` |
| `collection` | Country code | `collection=scl` |
| `issn` | Journal ISSN | `issn=0100-204X` |
| `from_date` | Articles from date | `from_date=2024-01-01` |
| `until_date` | Articles until date | `until_date=2026-12-31` |
| `format` | Response format | `json`, `xml` |
| `count` | Results per page | `count=50` |
| `offset` | Pagination offset | `offset=20` |

## Python Usage

```python
import requests

ARTICLE_API = "https://articlemeta.scielo.org/api/v1"
SEARCH_API = "https://search.scielo.org"


def search_scielo(query: str, collection: str = None,
                  count: int = 20) -> list:
    """Search SciELO articles."""
    params = {"q": query, "format": "json", "count": count}
    if collection:
        params["collection"] = collection

    resp = requests.get(f"{SEARCH_API}/", params=params)
    resp.raise_for_status()
    data = resp.json()

    results = []
    for doc in data.get("docs", data.get("results", [])):
        results.append({
            "title": doc.get("title", {}).get("en", doc.get("title", "")),
            "authors": doc.get("authors", []),
            "journal": doc.get("journal_title", ""),
            "year": doc.get("publication_year", ""),
            "doi": doc.get("doi", ""),
            "pid": doc.get("pid", ""),
            "language": doc.get("la", []),
            "url": f"https://scielo.org/article/{doc.get('pid', '')}",
        })
    return results


def get_article(pid: str) -> dict:
    """Get full article metadata by SciELO PID."""
    resp = requests.get(
        f"{ARTICLE_API}/article/",
        params={"code": pid, "format": "json"},
    )
    resp.raise_for_status()
    return resp.json()


def list_journals(collection: str = "scl") -> list:
    """List journals in a SciELO collection."""
    resp = requests.get(
        f"{ARTICLE_API}/journal/",
        params={"collection": collection, "format": "json"},
    )
    resp.raise_for_status()
    return resp.json()


# Example: find Brazilian ecology research
papers = search_scielo("Amazon deforestation biodiversity", collection="scl")
for p in papers:
    print(f"[{p['year']}] {p['title']} — {p['journal']}")

# Example: find Spanish medical research
papers = search_scielo("diabetes treatment", collection="esp")
for p in papers:
    print(f"{p['title']} (DOI: {p['doi']})")
```

## Subject Areas Covered

- Agricultural Sciences, Biological Sciences, Health Sciences
- Engineering, Exact Sciences, Earth Sciences
- Human Sciences, Social Sciences, Linguistics/Arts

## Unique Value

- **Regional focus**: Primary index for Latin American and Iberian research
- **Language diversity**: Portuguese, Spanish, English content
- **100% open access**: All indexed content freely available
- **Underrepresented research**: Many journals not in Scopus/WoS

## References

- [SciELO](https://scielo.org/)
- [SciELO Analytics](https://analytics.scielo.org/)
- [ArticleMeta API](https://articlemeta.scielo.org/)
- [SciELO Developer Wiki](https://wiki.scielo.org/)

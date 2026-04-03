---
name: ror-organization-api
description: "Identify and link research organizations via the ROR registry API"
metadata:
  openclaw:
    emoji: "🏢"
    category: "literature"
    subcategory: "metadata"
    keywords: ["ROR", "research organizations", "institution registry", "affiliation", "organization identifiers", "ISNI"]
    source: "https://ror.org/"
---

# ROR (Research Organization Registry) API

## Overview

ROR is the community-led registry of open persistent identifiers for research organizations worldwide — 110,000+ entries covering universities, research institutes, government agencies, hospitals, and companies. The API enables affiliation disambiguation, institutional search, and metadata retrieval. Essential for bibliometrics, funder compliance, and research analytics. Free, no authentication required.

## API Endpoints

### Base URL

```
https://api.ror.org/v2
```

### Search Organizations

```bash
# Text search
curl "https://api.ror.org/v2/organizations?query=MIT"

# Affiliation matching (fuzzy match for messy affiliation strings)
curl "https://api.ror.org/v2/organizations?affiliation=Dept+of+CS,+Massachusetts+Inst+of+Technology"

# Filter by country
curl "https://api.ror.org/v2/organizations?query=university&filter=locations.geonames_details.country_code:US"

# Filter by organization type
curl "https://api.ror.org/v2/organizations?query=research&filter=types:facility"
```

### Get Organization by ROR ID

```bash
# Retrieve full record
curl "https://api.ror.org/v2/organizations/https://ror.org/042nb2s44"

# Also works with just the ID portion
curl "https://api.ror.org/v2/organizations/042nb2s44"
```

### Query Parameters

| Parameter | Description | Example |
|-----------|-------------|---------|
| `query` | Text search | `query=Harvard` |
| `affiliation` | Fuzzy affiliation match | `affiliation=MIT Cambridge MA` |
| `filter` | Faceted filtering | `filter=types:education` |
| `page` | Page number (1-based) | `page=2` |

### Organization Types

| Type | Description |
|------|-------------|
| `education` | Universities, colleges |
| `facility` | Research facilities, labs |
| `healthcare` | Hospitals, medical centers |
| `company` | Companies with research activities |
| `government` | Government agencies |
| `nonprofit` | Non-profit research organizations |
| `funder` | Funding agencies |
| `archive` | Archives, libraries |

## Response Structure

```json
{
  "number_of_results": 3,
  "items": [
    {
      "id": "https://ror.org/042nb2s44",
      "names": [
        {"value": "Massachusetts Institute of Technology", "types": ["ror_display"]},
        {"value": "MIT", "types": ["acronym"]}
      ],
      "types": ["education"],
      "locations": [
        {
          "geonames_details": {
            "country_code": "US",
            "country_name": "United States",
            "name": "Cambridge"
          }
        }
      ],
      "external_ids": [
        {"type": "isni", "all": ["0000 0001 2341 2786"]},
        {"type": "grid", "all": ["grid.116068.8"]},
        {"type": "wikidata", "all": ["Q49108"]}
      ],
      "links": [{"type": "website", "value": "https://www.mit.edu/"}],
      "relationships": [
        {"id": "https://ror.org/01a8ajp77", "label": "Lincoln Laboratory", "type": "child"}
      ],
      "status": "active",
      "established": 1861
    }
  ]
}
```

## Python Usage

```python
import requests

BASE_URL = "https://api.ror.org/v2/organizations"


def search_organizations(query: str,
                         country: str = None,
                         org_type: str = None) -> list:
    """Search ROR for research organizations."""
    params = {"query": query}
    filters = []
    if country:
        filters.append(
            f"locations.geonames_details.country_code:{country}")
    if org_type:
        filters.append(f"types:{org_type}")
    if filters:
        params["filter"] = ",".join(filters)

    resp = requests.get(BASE_URL, params=params)
    resp.raise_for_status()
    data = resp.json()

    results = []
    for org in data.get("items", []):
        display_name = next(
            (n["value"] for n in org.get("names", [])
             if "ror_display" in n.get("types", [])),
            org.get("names", [{}])[0].get("value", ""),
        )
        acronyms = [n["value"] for n in org.get("names", [])
                     if "acronym" in n.get("types", [])]
        loc = org.get("locations", [{}])[0].get("geonames_details", {})

        results.append({
            "ror_id": org.get("id"),
            "name": display_name,
            "acronyms": acronyms,
            "types": org.get("types", []),
            "country": loc.get("country_name"),
            "city": loc.get("name"),
            "established": org.get("established"),
        })
    return results


def match_affiliation(affiliation_string: str) -> dict:
    """Disambiguate a messy affiliation string to a ROR record."""
    resp = requests.get(
        BASE_URL,
        params={"affiliation": affiliation_string},
    )
    resp.raise_for_status()
    items = resp.json().get("items", [])
    if items and items[0].get("chosen"):
        return items[0].get("organization", {})
    return items[0] if items else {}


def get_organization(ror_id: str) -> dict:
    """Get full ROR record for an organization."""
    resp = requests.get(f"{BASE_URL}/{ror_id}")
    resp.raise_for_status()
    return resp.json()


# Example: find German research institutes
orgs = search_organizations("Max Planck", country="DE",
                            org_type="facility")
for o in orgs:
    print(f"{o['name']} ({', '.join(o['acronyms'])}) "
          f"— {o['city']}, {o['country']} (est. {o['established']})")

# Example: disambiguate messy affiliations
result = match_affiliation(
    "Dept. of Computer Sci., Stanford Univ., CA, USA")
print(f"Matched: {result.get('id')} — "
      f"{result.get('names', [{}])[0].get('value')}")
```

## Use Cases

1. **Affiliation disambiguation**: Clean messy author affiliation strings
2. **Bibliometric analysis**: Aggregate publications by institution
3. **Funder compliance**: Link outputs to institutional identifiers
4. **Research profiling**: Map institutional research portfolios
5. **Collaboration networks**: Trace inter-institutional partnerships

## References

- [ROR](https://ror.org/)
- [ROR API Documentation](https://ror.readme.io/)
- [ROR Data Dump](https://doi.org/10.5281/zenodo.6347574)

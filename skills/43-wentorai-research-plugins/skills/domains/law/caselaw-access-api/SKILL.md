---
name: caselaw-access-api
description: "Query 360+ years of US case law via the Harvard Caselaw Access Project"
metadata:
  openclaw:
    emoji: "⚖️"
    category: "domains"
    subcategory: "law"
    keywords: ["case law", "legal database", "court opinions", "Harvard law", "judicial data", "legal research"]
    source: "https://case.law/"
---

# Caselaw Access Project API

## Overview

The Caselaw Access Project (CAP) by Harvard Law School provides free access to 6.9 million US court opinions spanning 360+ years. The REST API enables searching, filtering, and downloading full-text case opinions from all federal and state courts. No authentication required for metadata; API key (free registration) required for full text of post-1923 cases.

## API Endpoints

### Base URL

```
https://api.case.law/v1/
```

### Cases

```bash
# Search cases by keyword
curl "https://api.case.law/v1/cases/?search=free+speech&decision_date_min=2020-01-01"

# Get a specific case by ID
curl "https://api.case.law/v1/cases/12345678/"

# Filter by jurisdiction and court
curl "https://api.case.law/v1/cases/?jurisdiction=us&court=us-sup-ct&search=miranda+rights"

# Filter by date range
curl "https://api.case.law/v1/cases/?decision_date_min=2015-01-01&decision_date_max=2025-12-31"

# Get full text (requires API key for post-1923)
curl -H "Authorization: Token YOUR_API_KEY" \
  "https://api.case.law/v1/cases/12345678/?full_case=true"
```

### Query Parameters

| Parameter | Description | Example |
|-----------|-------------|---------|
| `search` | Full-text search | `search=due+process` |
| `jurisdiction` | Filter by jurisdiction slug | `jurisdiction=cal` (California) |
| `court` | Filter by court slug | `court=us-sup-ct` |
| `decision_date_min` | Earliest date | `decision_date_min=2020-01-01` |
| `decision_date_max` | Latest date | `decision_date_max=2025-12-31` |
| `cite` | Search by citation | `cite=410+U.S.+113` |
| `name_abbreviation` | Case name | `name_abbreviation=Roe+v.+Wade` |
| `ordering` | Sort results | `ordering=-decision_date` |
| `page_size` | Results per page (max 100) | `page_size=50` |
| `full_case` | Include full text | `full_case=true` |

### Courts and Jurisdictions

```bash
# List all courts
curl "https://api.case.law/v1/courts/"

# List all jurisdictions
curl "https://api.case.law/v1/jurisdictions/"

# List all reporters (case report series)
curl "https://api.case.law/v1/reporters/"
```

## Python Usage

```python
import requests

BASE_URL = "https://api.case.law/v1"

def search_cases(query: str, jurisdiction: str = None,
                 court: str = None, max_results: int = 20) -> list:
    """Search US case law."""
    params = {"search": query, "page_size": min(max_results, 100)}
    if jurisdiction:
        params["jurisdiction"] = jurisdiction
    if court:
        params["court"] = court

    resp = requests.get(f"{BASE_URL}/cases/", params=params)
    resp.raise_for_status()
    data = resp.json()

    cases = []
    for case in data.get("results", []):
        cases.append({
            "id": case["id"],
            "name": case["name_abbreviation"],
            "citation": case["citations"][0]["cite"] if case.get("citations") else None,
            "court": case["court"]["name"],
            "date": case["decision_date"],
            "url": case["frontend_url"]
        })
    return cases

# Search Supreme Court cases
results = search_cases("fourth amendment", court="us-sup-ct")
for case in results:
    print(f"{case['citation']}: {case['name']} ({case['date']})")
```

## Bulk Data Access

For large-scale research, download bulk datasets instead of querying the API:

```bash
# Bulk data available at:
# https://case.law/bulk/download/
# Formats: JSON (full case data) or text-only
# Organized by jurisdiction and reporter
```

## Key Jurisdictions

| Slug | Jurisdiction | Cases |
|------|-------------|-------|
| `us` | Federal (all) | ~1.5M |
| `us-sup-ct` | US Supreme Court | ~65K |
| `cal` | California | ~500K |
| `ny` | New York | ~600K |
| `tex` | Texas | ~300K |
| `ill` | Illinois | ~250K |

## Authentication

```
1. Register at https://case.law/user/register/
2. Get API token from your account page
3. Include in requests: Authorization: Token YOUR_TOKEN
```

Free accounts get full text for pre-1923 cases. Post-1923 full text requires an API token (still free).

## References

- [CAP API Documentation](https://case.law/api/)
- [CAP Bulk Data](https://case.law/bulk/download/)
- [Harvard Library Innovation Lab](https://lil.law.harvard.edu/)

---
name: nih-reporter-api-guide
description: "Search NIH-funded grants and research projects via RePORTER API"
metadata:
  openclaw:
    emoji: "🧬"
    category: "research"
    subcategory: "funding"
    keywords: ["nih", "grants", "biomedical", "funding", "reporter", "health-research"]
    source: "https://api.reporter.nih.gov/"
---

# NIH RePORTER API Guide

## Overview

NIH RePORTER (Research Portfolio Online Reporting Tools) provides a comprehensive API for searching and analyzing grants funded by the National Institutes of Health and other agencies within the U.S. Department of Health and Human Services. The database includes project details, funding amounts, publications, patents, and clinical studies linked to funded research.

RePORTER is the authoritative source for NIH grant data and covers billions of dollars in annual biomedical research funding. The API enables programmatic access to search for funded projects, retrieve associated publications, and analyze funding trends across NIH institutes, study sections, and disease categories.

The v2 API is a modern RESTful service that accepts JSON POST bodies for search requests and returns structured JSON responses. It is completely free and requires no authentication.

## Authentication

No authentication is required. The NIH RePORTER API is a free public service.

```bash
# No API key needed
curl -X POST "https://api.reporter.nih.gov/v2/projects/search" \
  -H "Content-Type: application/json" \
  -d '{"criteria":{"advanced_text_search":{"search_field":"terms","search_text":"CRISPR"}},"limit":5}'
```

## Core Endpoints

### Search Projects

The primary endpoint for finding NIH-funded grants and projects.

```
POST https://api.reporter.nih.gov/v2/projects/search
```

**Request body (JSON):**
- `criteria.advanced_text_search`: Text query with `search_field` and `search_text`
- `criteria.fiscal_years`: Array of fiscal years (e.g., [2023, 2024, 2025])
- `criteria.pi_names`: Array of PI name objects with `first_name`, `last_name`
- `criteria.org_names`: Array of institution names
- `criteria.agencies`: Array of agency codes (e.g., ["NIH"])
- `criteria.activity_codes`: Grant mechanism codes (e.g., ["R01", "R21"])
- `limit`: Results per page (max 500)
- `offset`: Pagination offset

**Example: Search for CRISPR gene editing R01 grants:**

```bash
curl -s -X POST "https://api.reporter.nih.gov/v2/projects/search" \
  -H "Content-Type: application/json" \
  -d '{
    "criteria": {
      "advanced_text_search": {
        "search_field": "projecttitle,terms",
        "search_text": "CRISPR gene editing"
      },
      "activity_codes": ["R01"],
      "fiscal_years": [2024, 2025]
    },
    "limit": 10,
    "offset": 0
  }' | python3 -m json.tool
```

### Search Publications

Find publications linked to NIH-funded projects.

```
POST https://api.reporter.nih.gov/v2/publications/search
```

```bash
curl -s -X POST "https://api.reporter.nih.gov/v2/publications/search" \
  -H "Content-Type: application/json" \
  -d '{
    "criteria": {
      "core_project_nums": ["R01GM123456"]
    },
    "limit": 25,
    "offset": 0
  }' | python3 -m json.tool
```

### Python Example: Analyze NIH Funding by Institute

```python
import requests

API_URL = "https://api.reporter.nih.gov/v2/projects/search"

def search_nih_projects(query, fiscal_years=None, activity_codes=None, limit=50):
    """Search NIH RePORTER for funded projects."""
    payload = {
        "criteria": {
            "advanced_text_search": {
                "search_field": "projecttitle,terms",
                "search_text": query
            }
        },
        "limit": limit,
        "offset": 0
    }
    if fiscal_years:
        payload["criteria"]["fiscal_years"] = fiscal_years
    if activity_codes:
        payload["criteria"]["activity_codes"] = activity_codes

    resp = requests.post(API_URL, json=payload)
    resp.raise_for_status()
    data = resp.json()
    return data.get("results", []), data.get("meta", {}).get("total", 0)

results, total = search_nih_projects(
    "Alzheimer disease biomarkers",
    fiscal_years=[2024, 2025],
    activity_codes=["R01", "R21", "U01"]
)
print(f"Total matching projects: {total}")

institute_totals = {}
for project in results:
    ic = project.get("agency_ic_fundings", [])
    for funding in ic:
        name = funding.get("abbreviation", "Unknown")
        amount = funding.get("total_cost", 0) or 0
        institute_totals[name] = institute_totals.get(name, 0) + amount

for inst, total_amt in sorted(institute_totals.items(), key=lambda x: -x[1]):
    print(f"  {inst}: ${total_amt:,.0f}")
```

## Common Research Patterns

**Grant Prospecting:** Search for recently funded projects in your area to understand current NIH priorities, typical award sizes by mechanism (R01, R21, K99, etc.), and successful project framing.

**Publication-Grant Linkage:** Use the publications endpoint to find papers produced from specific grants, enabling analysis of research output and impact per dollar invested.

**PI Network Analysis:** Search by PI name to map a researcher's full NIH funding history, co-investigators, and institutional affiliations over time.

**Funding Trend Tracking:** Query across multiple fiscal years with consistent keywords to track how NIH investment evolves in emerging areas such as AI in healthcare, mRNA therapeutics, or long COVID.

## Rate Limits and Best Practices

- **No authentication required** but the API has reasonable use expectations
- **Max results per request:** 500 (use `offset` for pagination)
- **Recommended delay:** 0.5 seconds between paginated requests
- **POST-only:** All search endpoints use POST with JSON bodies, not GET parameters
- **Field selection:** Use `include_fields` in the request body to limit response fields for faster responses
- **Fiscal year filtering:** Always include `fiscal_years` to narrow results and improve performance
- **Error handling:** Check HTTP status codes; the API returns 400 for malformed requests with descriptive error messages

## References

- NIH RePORTER API v2 Documentation: https://api.reporter.nih.gov/
- NIH RePORTER Web Interface: https://reporter.nih.gov/
- NIH Activity Codes (Grant Mechanisms): https://grants.nih.gov/grants/funding/ac_search_results.htm
- NIH Institutes and Centers: https://www.nih.gov/institutes-nih/list-nih-institutes-centers-offices

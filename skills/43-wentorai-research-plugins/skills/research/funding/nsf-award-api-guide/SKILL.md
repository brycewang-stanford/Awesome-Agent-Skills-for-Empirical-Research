---
name: nsf-award-api-guide
description: "Search NSF awards and grants with free public API, no auth required"
metadata:
  openclaw:
    emoji: "🏛️"
    category: "research"
    subcategory: "funding"
    keywords: ["nsf", "grants", "funding", "awards", "national-science-foundation"]
    source: "https://www.research.gov/common/webapi/awardapisearch-v1.htm"
---

# NSF Award Search API Guide

## Overview

The National Science Foundation (NSF) Award Search API provides free, unauthenticated access to a comprehensive database of NSF-funded awards spanning decades of federally funded research in the United States. This API is invaluable for researchers seeking to understand funding trends, identify potential collaborators, or find precedent awards in their field.

The API covers all NSF directorates including Computer and Information Science and Engineering (CISE), Biological Sciences (BIO), Engineering (ENG), Geosciences (GEO), Mathematical and Physical Sciences (MPS), Social, Behavioral and Economic Sciences (SBE), and Education and Human Resources (EHR). Each award record includes principal investigator information, award amounts, abstracts, and institutional details.

No API key or authentication is needed. The service returns JSON or XML and supports a wide range of query parameters for precise filtering.

## Authentication

No authentication is required. The NSF Award Search API is completely open and free to use.

```bash
# No API key needed -- just make the request
curl "https://api.nsf.gov/services/v1/awards.json?keyword=quantum+computing"
```

## Core Endpoints

### Search Awards

```
GET https://api.nsf.gov/services/v1/awards.json?{params}
```

**Key Parameters:**
- `keyword`: Full-text search across award title and abstract
- `piFirstName`, `piLastName`: Filter by principal investigator name
- `awardeeCity`, `awardeeStateCode`: Filter by institution location
- `startDateStart`, `startDateEnd`: Date range (format: MM/DD/YYYY)
- `fundProgramName`: NSF program name
- `awardeeName`: Institution name
- `offset`: Pagination offset (default 1)
- `printFields`: Comma-separated list of fields to return

**Example: Search for machine learning awards at MIT:**

```bash
curl -s "https://api.nsf.gov/services/v1/awards.json?\
keyword=machine+learning&\
awardeeName=Massachusetts+Institute+of+Technology&\
printFields=id,title,piFirstName,piLastName,startDate,awardeeName,fundsObligatedAmt,abstractText&\
offset=1" | python3 -m json.tool
```

### Get Award by ID

Retrieve details for a specific award by its NSF award number.

```bash
curl -s "https://api.nsf.gov/services/v1/awards/2345678.json?\
printFields=id,title,piFirstName,piLastName,startDate,expDate,awardeeName,fundsObligatedAmt,abstractText" \
  | python3 -m json.tool
```

### Python Example: Funding Trend Analysis

```python
import requests
import time

base_url = "https://api.nsf.gov/services/v1/awards.json"

def search_nsf_awards(keyword, year_start, year_end, max_results=100):
    """Search NSF awards and return structured results."""
    results = []
    offset = 1

    while len(results) < max_results:
        params = {
            "keyword": keyword,
            "startDateStart": f"01/01/{year_start}",
            "startDateEnd": f"12/31/{year_end}",
            "printFields": "id,title,piFirstName,piLastName,startDate,awardeeName,fundsObligatedAmt",
            "offset": offset
        }
        resp = requests.get(base_url, params=params)
        data = resp.json()
        awards = data.get("response", {}).get("award", [])
        if not awards:
            break
        results.extend(awards)
        offset += 25
        time.sleep(0.5)

    return results[:max_results]

awards = search_nsf_awards("large language models", 2022, 2025)
total_funding = sum(int(a.get("fundsObligatedAmt", 0)) for a in awards)
print(f"Found {len(awards)} awards, total funding: ${total_funding:,}")

for a in awards[:5]:
    print(f"  [{a['id']}] {a['title']} — ${int(a.get('fundsObligatedAmt', 0)):,}")
```

## Common Research Patterns

**Grant Prospecting:** Search for awards in your field to understand typical funding amounts, common program solicitations, and successful framing of research projects. Analyze abstracts of funded proposals for vocabulary and scope.

**Collaborator Discovery:** Search by keyword and explore the PI network to identify active researchers and institutions. Cross-reference with publication databases to find potential collaborators.

**Funding Landscape Analysis:** Track funding volumes over time for specific keywords or programs to identify emerging priorities and declining areas. Useful for strategic planning and grant writing.

**Institutional Benchmarking:** Compare award counts and funding totals across institutions for a given field or directorate.

## Rate Limits and Best Practices

- **No formal rate limit** is published, but be respectful; add 0.5-1 second delays between paginated requests
- **Default page size:** 25 awards per request (use `offset` to paginate)
- **printFields:** Always specify `printFields` to reduce response size and improve performance
- **Date formats:** Use MM/DD/YYYY format strictly
- **Pagination:** The API uses 1-based offset; increment by 25 for each page
- **Large datasets:** For bulk analysis, consider using the NSF data download at https://www.nsf.gov/awardsearch/download.jsp

## References

- NSF Award Search API Documentation: https://www.research.gov/common/webapi/awardapisearch-v1.htm
- NSF Award Search Web Interface: https://www.nsf.gov/awardsearch/
- NSF Data Downloads: https://www.nsf.gov/awardsearch/download.jsp

---
name: worldcat-search-api
description: "Search the world's largest library catalog via OCLC WorldCat API"
metadata:
  openclaw:
    emoji: "🏛️"
    category: "literature"
    subcategory: "search"
    keywords: ["worldcat", "library catalog", "OCLC", "book search", "holdings", "interlibrary loan"]
    source: "https://developer.api.oclc.org/"
---

# WorldCat Search API

## Overview

WorldCat is the world's largest network of library content, aggregating catalogs from 10,000+ libraries across 170+ countries. The Search API provides access to 500M+ bibliographic records — books, journals, dissertations, media, and more — with holdings information showing which libraries own each item. Essential for interlibrary loan discovery, collection analysis, and comprehensive bibliographic searches. Requires a WSKey (free for non-commercial use).

## Authentication

```bash
# Register at https://platform.worldcat.org/
# Obtain a WSKey (API key) for your application

# OAuth 2.0 client credentials flow
curl -X POST "https://oauth.oclc.org/token" \
  -u "$WSKEY_CLIENT_ID:$WSKEY_SECRET" \
  -d "grant_type=client_credentials&scope=wcapi"
```

## API Endpoints

### Base URL

```
https://www.worldcat.org/api/search/
```

### Search Bibliographic Records

```bash
# Keyword search
curl -H "Authorization: Bearer $TOKEN" \
  "https://www.worldcat.org/api/search?q=machine+learning&limit=25"

# Search by title
curl -H "Authorization: Bearer $TOKEN" \
  "https://www.worldcat.org/api/search?q=ti:attention+is+all+you+need"

# Search by author
curl -H "Authorization: Bearer $TOKEN" \
  "https://www.worldcat.org/api/search?q=au:hinton+geoffrey"

# Search by ISBN
curl -H "Authorization: Bearer $TOKEN" \
  "https://www.worldcat.org/api/search?q=bn:9780262035613"

# Combined filters
curl -H "Authorization: Bearer $TOKEN" \
  "https://www.worldcat.org/api/search?q=su:artificial+intelligence+AND+yr:2020-2026&itemType=book"
```

### Search Indexes

| Index | Prefix | Example |
|-------|--------|---------|
| Keyword | (none) | `q=neural+networks` |
| Title | `ti:` | `q=ti:deep+learning` |
| Author | `au:` | `q=au:goodfellow` |
| Subject | `su:` | `q=su:machine+learning` |
| ISBN | `bn:` | `q=bn:9780262035613` |
| ISSN | `n:` | `q=n:0028-0836` |
| OCLC Number | `no:` | `q=no:1234567` |
| Publisher | `pb:` | `q=pb:MIT+Press` |
| Year | `yr:` | `q=yr:2024` or `yr:2020-2026` |
| Language | `la:` | `q=la:eng` |

### Query Parameters

| Parameter | Description | Example |
|-----------|-------------|---------|
| `q` | Search query with indexes | `q=ti:BERT+AND+au:devlin` |
| `limit` | Results per page (max 50) | `limit=25` |
| `offset` | Pagination offset | `offset=50` |
| `itemType` | Format filter | `book`, `journal`, `thesis`, `audiobook` |
| `itemSubType` | Subtype filter | `digital`, `printbook` |
| `heldByInstitutionID` | Holdings filter | Institution registry ID |
| `orderBy` | Sort order | `bestMatch`, `mostWidelyHeld`, `datePublished` |

### Get Record by OCLC Number

```bash
curl -H "Authorization: Bearer $TOKEN" \
  "https://www.worldcat.org/api/search/brief-bibs/{oclc_number}"
```

### Holdings / Library Locations

```bash
# Find libraries holding a specific item
curl -H "Authorization: Bearer $TOKEN" \
  "https://www.worldcat.org/api/search/brief-bibs/{oclc_number}/holdings?lat=42.36&lon=-71.06&distance=50"
```

## Response Structure

```json
{
  "numberOfRecords": 1250,
  "briefRecords": [
    {
      "oclcNumber": "1234567890",
      "title": "Deep Learning",
      "creator": "Ian Goodfellow; Yoshua Bengio; Aaron Courville",
      "date": "2016",
      "publisher": "MIT Press",
      "language": "eng",
      "generalFormat": "Book",
      "specificFormat": "PrintBook",
      "isbns": ["9780262035613"],
      "catalogingInfo": {
        "catalogingAgency": "DLC"
      },
      "totalHoldingCount": 3542
    }
  ]
}
```

## Python Usage

```python
import os
import requests

CLIENT_ID = os.environ["OCLC_WSKEY_ID"]
CLIENT_SECRET = os.environ["OCLC_WSKEY_SECRET"]
BASE_URL = "https://www.worldcat.org/api/search"


def get_token() -> str:
    """Obtain OAuth token from OCLC."""
    resp = requests.post(
        "https://oauth.oclc.org/token",
        auth=(CLIENT_ID, CLIENT_SECRET),
        data={"grant_type": "client_credentials", "scope": "wcapi"},
    )
    resp.raise_for_status()
    return resp.json()["access_token"]


def search_worldcat(query: str, limit: int = 25,
                    item_type: str = None) -> list:
    """Search WorldCat bibliographic records."""
    token = get_token()
    params = {"q": query, "limit": limit}
    if item_type:
        params["itemType"] = item_type

    resp = requests.get(
        BASE_URL,
        headers={"Authorization": f"Bearer {token}"},
        params=params,
    )
    resp.raise_for_status()
    data = resp.json()

    results = []
    for rec in data.get("briefRecords", []):
        results.append({
            "oclc": rec.get("oclcNumber"),
            "title": rec.get("title"),
            "creator": rec.get("creator"),
            "date": rec.get("date"),
            "publisher": rec.get("publisher"),
            "format": rec.get("generalFormat"),
            "holdings": rec.get("totalHoldingCount", 0),
            "isbns": rec.get("isbns", []),
        })
    return results


def find_nearby_holdings(oclc_number: str,
                         lat: float, lon: float,
                         distance_km: int = 50) -> list:
    """Find libraries near a location that hold a specific item."""
    token = get_token()
    resp = requests.get(
        f"{BASE_URL}/brief-bibs/{oclc_number}/holdings",
        headers={"Authorization": f"Bearer {token}"},
        params={"lat": lat, "lon": lon, "distance": distance_km},
    )
    resp.raise_for_status()
    return resp.json().get("briefRecords", [])


# Example: find widely-held ML textbooks
books = search_worldcat("su:machine learning AND yr:2020-2026",
                        item_type="book", limit=10)
for b in books:
    print(f"[{b['date']}] {b['title']} — {b['publisher']} "
          f"(held by {b['holdings']} libraries)")
```

## Use Cases

1. **Interlibrary loan**: Find nearest library holding a needed item
2. **Collection gap analysis**: Compare institutional holdings against a bibliography
3. **Dissertation discovery**: Search theses across global repositories
4. **Edition tracking**: Find all editions/translations of a work
5. **Bibliographic verification**: Confirm ISBNs, publication dates, and publishers

## Access Tiers

| Tier | Access | Rate Limit |
|------|--------|------------|
| WSKey (free) | Search + brief records | Moderate |
| Enterprise | Full MARC records + analytics | Higher |

## References

- [WorldCat Search API Documentation](https://developer.api.oclc.org/)
- [OCLC Developer Network](https://platform.worldcat.org/)
- [WorldCat.org](https://www.worldcat.org/)

---
name: eric-education-api
description: "Search 2M+ education research records via the ERIC database API"
metadata:
  openclaw:
    emoji: "🎓"
    category: "literature"
    subcategory: "search"
    keywords: ["ERIC", "education research", "IES", "pedagogy", "teaching", "educational technology"]
    source: "https://eric.ed.gov/"
---

# ERIC (Education Resources Information Center) API

## Overview

ERIC is the world's largest digital library of education research, sponsored by the U.S. Institute of Education Sciences (IES). It indexes 2M+ records including journal articles, reports, conference papers, and dissertations covering all aspects of education. The API provides free, unauthenticated access to metadata and links to full text where available.

## API Endpoints

### Base URL

```
https://api.ies.ed.gov/eric/
```

### Search

```bash
# Basic keyword search
curl "https://api.ies.ed.gov/eric/?search=online+learning&format=json&rows=20"

# Search in specific fields
curl "https://api.ies.ed.gov/eric/?search=title:\"blended learning\"&format=json"

# Filter by publication date
curl "https://api.ies.ed.gov/eric/?search=STEM+education&start=0&rows=25&\
publicationdatestart=2023-01-01&publicationdateend=2026-12-31&format=json"

# Filter by publication type
curl "https://api.ies.ed.gov/eric/?search=formative+assessment&\
publicationtype=Journal+Articles&format=json"

# Filter by descriptor (ERIC thesaurus term)
curl "https://api.ies.ed.gov/eric/?search=descriptor:\"Higher Education\"&format=json"

# Peer-reviewed only
curl "https://api.ies.ed.gov/eric/?search=metacognition&peerreviewed=true&format=json"
```

### Query Parameters

| Parameter | Description | Example |
|-----------|-------------|---------|
| `search` | Free-text or field search | `search=adaptive+learning` |
| `format` | Response format | `json` or `xml` |
| `rows` | Results per page (max 200) | `rows=50` |
| `start` | Pagination offset | `start=50` |
| `publicationtype` | Document type | `Journal Articles`, `Reports`, `Dissertations/Theses` |
| `publicationdatestart` | From date | `2024-01-01` |
| `publicationdateend` | To date | `2026-12-31` |
| `peerreviewed` | Peer-reviewed filter | `true` or `false` |
| `descriptor` | ERIC thesaurus term | `descriptor:"Distance Education"` |
| `educationlevel` | Education level | `Higher Education`, `Elementary Education` |
| `subject` | Subject area | `subject:"Mathematics Education"` |

### Search Fields

| Field | Description |
|-------|-------------|
| `title` | Article title |
| `author` | Author name |
| `descriptor` | ERIC controlled vocabulary term |
| `source` | Journal/source name |
| `abstract` | Abstract text |
| `id` | ERIC document ID (e.g., EJ1234567) |

### Publication Types

| Type | Description |
|------|-------------|
| `Journal Articles` | Peer-reviewed journal articles |
| `Reports - Research` | Research reports |
| `Reports - Descriptive` | Descriptive reports |
| `Reports - Evaluative` | Program evaluations |
| `Dissertations/Theses` | Graduate research |
| `Speeches/Meeting Papers` | Conference presentations |
| `Books` | Books and book chapters |

## Response Structure

```json
{
  "response": {
    "numFound": 8450,
    "start": 0,
    "docs": [
      {
        "id": "EJ1389012",
        "title": "Effects of AI Tutoring on Student Learning Outcomes",
        "author": ["Smith, John", "Chen, Wei"],
        "source": "Journal of Educational Technology",
        "publicationdateyear": 2024,
        "description": "This study examines the impact of AI-powered tutoring...",
        "descriptor": ["Artificial Intelligence", "Tutoring", "Academic Achievement"],
        "educationlevel": ["Higher Education"],
        "peerreviewed": "T",
        "url": "https://eric.ed.gov/?id=EJ1389012",
        "publicationtype": "Journal Articles",
        "issn": "1234-5678"
      }
    ]
  }
}
```

## Python Usage

```python
import requests

BASE_URL = "https://api.ies.ed.gov/eric/"


def search_eric(query: str, rows: int = 25,
                peer_reviewed: bool = True,
                pub_type: str = None,
                from_year: int = None) -> list:
    """Search the ERIC education research database."""
    params = {
        "search": query,
        "format": "json",
        "rows": rows,
    }
    if peer_reviewed:
        params["peerreviewed"] = "true"
    if pub_type:
        params["publicationtype"] = pub_type
    if from_year:
        params["publicationdatestart"] = f"{from_year}-01-01"

    resp = requests.get(BASE_URL, params=params)
    resp.raise_for_status()
    data = resp.json()

    results = []
    for doc in data.get("response", {}).get("docs", []):
        results.append({
            "id": doc.get("id"),
            "title": doc.get("title"),
            "authors": doc.get("author", []),
            "source": doc.get("source"),
            "year": doc.get("publicationdateyear"),
            "abstract": doc.get("description", "")[:300],
            "descriptors": doc.get("descriptor", []),
            "level": doc.get("educationlevel", []),
            "url": doc.get("url"),
        })
    return results


def search_by_descriptor(descriptor: str, rows: int = 50) -> list:
    """Search using ERIC thesaurus controlled vocabulary."""
    return search_eric(f'descriptor:"{descriptor}"', rows=rows)


# Example: find recent AI in education research
papers = search_eric("artificial intelligence classroom",
                     from_year=2023, rows=10)
for p in papers:
    print(f"[{p['year']}] {p['title']}")
    print(f"  Descriptors: {', '.join(p['descriptors'][:5])}")

# Example: search by ERIC descriptor
papers = search_by_descriptor("Gamification")
for p in papers:
    print(f"{p['id']}: {p['title']} — {p['source']}")
```

## ERIC Thesaurus

ERIC uses a controlled vocabulary of 12,000+ descriptors for consistent indexing. Key descriptors include:

| Descriptor | Coverage |
|------------|----------|
| `Distance Education` | Online/remote learning |
| `Educational Technology` | EdTech tools and methods |
| `Higher Education` | University-level education |
| `STEM Education` | Science, technology, engineering, math |
| `Teacher Education` | Teacher training and development |
| `Assessment` | Testing and evaluation |
| `Curriculum Development` | Curriculum design |
| `Special Education` | Inclusive education |

## References

- [ERIC Website](https://eric.ed.gov/)
- [ERIC API Guide](https://eric.ed.gov/pdf/ERIC_API.pdf)
- [ERIC Thesaurus](https://eric.ed.gov/thesaurus)

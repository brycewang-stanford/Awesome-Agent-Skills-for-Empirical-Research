---
name: hal-archive-api
description: "Access French and European research via the HAL open archive API"
metadata:
  openclaw:
    emoji: "🇫🇷"
    category: "literature"
    subcategory: "fulltext"
    keywords: ["HAL", "French research", "open archive", "CNRS", "European research", "institutional repository"]
    source: "https://api.archives-ouvertes.fr/"
---

# HAL Open Archive API

## Overview

HAL (Hyper Articles en Ligne) is France's national open archive for scholarly deposits. Managed by CNRS, it hosts 4M+ full-text documents from French research institutions and international collaborators. The API provides Solr-based search with full metadata, PDF links, and OAI-PMH harvesting. Free, no authentication required.

## API Endpoints

### Search API

```bash
# Keyword search
curl "https://api.archives-ouvertes.fr/search/?q=machine+learning&rows=20&wt=json"

# Search specific fields
curl "https://api.archives-ouvertes.fr/search/?q=title_s:\"deep learning\"&wt=json"

# Filter by document type
curl "https://api.archives-ouvertes.fr/search/?q=neural+networks&\
fq=docType_s:ART&rows=20&wt=json"

# Filter by year and language
curl "https://api.archives-ouvertes.fr/search/?q=climate+change&\
fq=producedDateY_i:[2023 TO 2026]&fq=language_s:en&wt=json"

# Filter by institution
curl "https://api.archives-ouvertes.fr/search/?q=robotics&\
fq=structId_i:441569&wt=json"

# Return specific fields
curl "https://api.archives-ouvertes.fr/search/?q=CRISPR&\
fl=halId_s,title_s,authFullName_s,producedDateY_i,uri_s,files_s&wt=json"
```

### Search Fields

| Field | Description | Example |
|-------|-------------|---------|
| `title_s` | Title | `title_s:"attention mechanism"` |
| `authFullName_s` | Author name | `authFullName_s:"Yann LeCun"` |
| `abstract_s` | Abstract | `abstract_s:transformer` |
| `keyword_s` | Keywords | `keyword_s:"natural language"` |
| `producedDateY_i` | Year | `producedDateY_i:2024` |
| `docType_s` | Document type | `docType_s:ART` |
| `language_s` | Language | `language_s:en` |
| `domain_s` | Domain/subject | `domain_s:info.info-ai` |
| `journalTitle_s` | Journal name | `journalTitle_s:"Nature"` |
| `structId_i` | Institution ID | Lab/university ID |

### Document Types

| Code | Type |
|------|------|
| `ART` | Journal article |
| `COMM` | Conference paper |
| `THESE` | PhD thesis |
| `HDR` | Habilitation thesis |
| `REPORT` | Report |
| `COUV` | Book chapter |
| `OUV` | Book |
| `POSTER` | Poster |
| `UNDEFINED` | Preprint/other |

### Query Parameters

| Parameter | Description |
|-----------|-------------|
| `q` | Solr query |
| `fq` | Filter query |
| `fl` | Fields to return |
| `rows` | Results per page (max 10000) |
| `start` | Pagination offset |
| `sort` | Sort order (e.g., `producedDateY_i desc`) |
| `wt` | Format: `json`, `xml`, `csv` |

## Response Structure

```json
{
  "response": {
    "numFound": 12500,
    "start": 0,
    "docs": [
      {
        "halId_s": "hal-01234567",
        "title_s": ["Deep Learning for Climate Modeling"],
        "authFullName_s": ["Marie Dupont", "Jean Martin"],
        "producedDateY_i": 2024,
        "docType_s": "ART",
        "journalTitle_s": "Environmental Modelling",
        "uri_s": "https://hal.science/hal-01234567",
        "files_s": ["https://hal.science/hal-01234567/document"],
        "domain_s": ["sde.es", "info.info-ai"],
        "abstract_s": ["We propose a novel deep learning approach..."],
        "language_s": ["en"]
      }
    ]
  }
}
```

## Python Usage

```python
import requests

BASE_URL = "https://api.archives-ouvertes.fr/search/"


def search_hal(query: str, rows: int = 20,
               doc_type: str = None, from_year: int = None,
               language: str = None) -> list:
    """Search HAL open archive."""
    params = {
        "q": query,
        "wt": "json",
        "rows": rows,
        "fl": "halId_s,title_s,authFullName_s,producedDateY_i,"
              "uri_s,files_s,docType_s,journalTitle_s,abstract_s",
        "sort": "producedDateY_i desc",
    }

    fq = []
    if doc_type:
        fq.append(f"docType_s:{doc_type}")
    if from_year:
        fq.append(f"producedDateY_i:[{from_year} TO 2030]")
    if language:
        fq.append(f"language_s:{language}")
    if fq:
        params["fq"] = fq

    resp = requests.get(BASE_URL, params=params)
    resp.raise_for_status()
    data = resp.json()

    results = []
    for doc in data.get("response", {}).get("docs", []):
        title = doc.get("title_s", [""])[0] if isinstance(
            doc.get("title_s"), list) else doc.get("title_s", "")
        results.append({
            "hal_id": doc.get("halId_s"),
            "title": title,
            "authors": doc.get("authFullName_s", []),
            "year": doc.get("producedDateY_i"),
            "type": doc.get("docType_s"),
            "journal": doc.get("journalTitle_s"),
            "url": doc.get("uri_s"),
            "pdf": doc.get("files_s", [None])[0],
        })
    return results


def search_theses(topic: str, from_year: int = 2020) -> list:
    """Find French PhD theses on a topic."""
    return search_hal(topic, rows=50, doc_type="THESE",
                      from_year=from_year)


def get_institution_publications(struct_id: int,
                                 from_year: int = 2023) -> list:
    """Get publications from a specific institution."""
    params = {
        "q": "*:*",
        "fq": [f"structId_i:{struct_id}",
               f"producedDateY_i:[{from_year} TO 2030]"],
        "wt": "json",
        "rows": 100,
        "fl": "halId_s,title_s,authFullName_s,producedDateY_i,docType_s",
        "sort": "producedDateY_i desc",
    }
    resp = requests.get(BASE_URL, params=params)
    resp.raise_for_status()
    return resp.json().get("response", {}).get("docs", [])


# Example: find recent French AI research
papers = search_hal("intelligence artificielle", from_year=2024)
for p in papers:
    pdf = " [PDF]" if p["pdf"] else ""
    print(f"[{p['year']}] {p['title']}{pdf}")

# Example: find PhD theses on NLP
theses = search_theses("natural language processing")
for t in theses:
    print(f"{t['title']} — {', '.join(t['authors'][:2])}")
```

## HAL Domains

| Code | Domain |
|------|--------|
| `info` | Computer Science |
| `math` | Mathematics |
| `phys` | Physics |
| `sde` | Environmental Sciences |
| `sdv` | Life Sciences |
| `shs` | Social Sciences & Humanities |
| `chim` | Chemistry |
| `spi` | Engineering Sciences |

## References

- [HAL Open Archive](https://hal.science/)
- [HAL API Documentation](https://api.archives-ouvertes.fr/docs)
- [HAL Search Guide](https://doc.archives-ouvertes.fr/en/)

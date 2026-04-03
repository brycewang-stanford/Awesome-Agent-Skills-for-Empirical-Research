---
name: viaf-authority-api
description: "Disambiguate author identities via the VIAF authority file API"
metadata:
  openclaw:
    emoji: "👤"
    category: "literature"
    subcategory: "metadata"
    keywords: ["VIAF", "authority control", "author disambiguation", "name authority", "OCLC", "library catalog"]
    source: "https://viaf.org/"
---

# VIAF (Virtual International Authority File) API

## Overview

VIAF clusters authority records from 50+ national libraries worldwide, linking different forms of an author's name into a single canonical identity. It covers 50M+ personal, corporate, and geographic name entries. Essential for author disambiguation in bibliometric research — resolving "J. Smith", "John Smith", and "Smith, J.A." to the same person. Free, no authentication.

## API Endpoints

### Base URL

```
https://viaf.org
```

### Search

```bash
# Search by name (AutoSuggest)
curl "https://viaf.org/viaf/AutoSuggest?query=einstein+albert"

# Search via SRU (structured query)
curl "https://viaf.org/viaf/search?query=local.personalNames+all+\"hinton+geoffrey\"&\
sortKeys=holdingscount&httpAccept=application/json"

# Search corporate names
curl "https://viaf.org/viaf/search?query=local.corporateNames+all+\"MIT\"&\
httpAccept=application/json"
```

### Get Record by VIAF ID

```bash
# JSON format
curl "https://viaf.org/viaf/75121530/viaf.json"

# Linked data formats
curl -H "Accept: application/json" "https://viaf.org/viaf/75121530"

# Cluster data (all linked identities)
curl "https://viaf.org/viaf/75121530/justlinks.json"
```

### Cross-Reference by External ID

```bash
# Look up by Library of Congress ID
curl "https://viaf.org/viaf/lccn/n79021164/viaf.json"

# Look up by ISNI
curl "https://viaf.org/viaf/isni/0000000121174331/viaf.json"

# Look up by ORCID
curl "https://viaf.org/viaf/sourceID/ORCID|0000-0002-1825-0097/viaf.json"

# Look up by Wikidata QID
curl "https://viaf.org/viaf/sourceID/WKP|Q937/viaf.json"
```

### Source Codes

| Code | Library/Source |
|------|---------------|
| `LC` | Library of Congress |
| `DNB` | German National Library |
| `BNF` | Bibliothèque nationale de France |
| `NLA` | National Library of Australia |
| `NDL` | National Diet Library (Japan) |
| `NKC` | National Library of Czech Republic |
| `WKP` | Wikidata |
| `ISNI` | ISNI |

## Response Structure

```json
{
  "viafID": "75121530",
  "nameType": "Personal",
  "mainHeadings": {
    "data": [
      {
        "text": "Einstein, Albert, 1879-1955",
        "sources": {"s": ["LC", "DNB", "BNF"]}
      }
    ]
  },
  "x400s": {
    "x400": [
      {"datafield": {"subfield": [{"text": "Albert Einstein"}]}}
    ]
  },
  "birthDate": "1879",
  "deathDate": "1955",
  "sources": {
    "source": [
      {"nsid": "n79022889", "sid": "LC|n79022889"},
      {"nsid": "118529579", "sid": "DNB|118529579"}
    ]
  }
}
```

## Python Usage

```python
import requests

BASE_URL = "https://viaf.org/viaf"


def search_person(name: str, limit: int = 10) -> list:
    """Search VIAF for personal name authorities."""
    resp = requests.get(
        f"{BASE_URL}/AutoSuggest",
        params={"query": name},
    )
    resp.raise_for_status()
    data = resp.json()

    results = []
    for item in data.get("result", [])[:limit]:
        results.append({
            "viaf_id": item.get("viafid"),
            "name": item.get("displayForm"),
            "name_type": item.get("nametype"),
            "source_count": len(item.get("sources", "").split("|")),
        })
    return results


def get_authority(viaf_id: str) -> dict:
    """Get full VIAF authority record."""
    resp = requests.get(f"{BASE_URL}/{viaf_id}/viaf.json")
    resp.raise_for_status()
    data = resp.json()

    name_forms = []
    for heading in data.get("mainHeadings", {}).get("data", []):
        if isinstance(heading, dict):
            name_forms.append({
                "text": heading.get("text"),
                "sources": heading.get("sources", {}).get("s", []),
            })

    external_ids = {}
    for src in data.get("sources", {}).get("source", []):
        sid = src.get("sid", "")
        if "|" in sid:
            prefix, local_id = sid.split("|", 1)
            external_ids[prefix] = local_id

    return {
        "viaf_id": data.get("viafID"),
        "name_forms": name_forms,
        "birth": data.get("birthDate"),
        "death": data.get("deathDate"),
        "external_ids": external_ids,
    }


def resolve_by_orcid(orcid: str) -> dict:
    """Resolve ORCID to VIAF authority record."""
    resp = requests.get(
        f"{BASE_URL}/sourceID/ORCID|{orcid}/viaf.json"
    )
    resp.raise_for_status()
    return resp.json()


# Example: disambiguate an author name
candidates = search_person("Geoffrey Hinton")
for c in candidates:
    print(f"VIAF {c['viaf_id']}: {c['name']} "
          f"({c['source_count']} libraries)")

# Example: get all name forms for an author
if candidates:
    record = get_authority(candidates[0]["viaf_id"])
    print(f"\nName forms for {record['viaf_id']}:")
    for form in record["name_forms"]:
        sources = ", ".join(form["sources"][:3])
        print(f"  {form['text']} [{sources}]")
    print(f"External IDs: {record['external_ids']}")
```

## Use Cases

1. **Author disambiguation**: Resolve name variants to canonical identities
2. **Cross-library linking**: Connect records across national catalogs
3. **Bibliometric deduplication**: Merge author records from different databases
4. **Identity verification**: Confirm author identity via multiple authority sources
5. **Linked data enrichment**: Bridge ORCID, Wikidata, and library authorities

## References

- [VIAF](https://viaf.org/)
- [VIAF API Documentation](https://www.oclc.org/developer/api/oclc-apis/viaf.en.html)
- [VIAF Guidelines](https://www.oclc.org/research/activities/viaf.html)

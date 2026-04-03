---
name: uk-legislation-api
description: "Access UK laws and statutory instruments via the Legislation.gov.uk API"
metadata:
  openclaw:
    emoji: "⚖️"
    category: "domains"
    subcategory: "law"
    keywords: ["UK law", "legislation", "statutory instruments", "legal research", "Parliament", "regulatory analysis"]
    source: "https://www.legislation.gov.uk"
---

# UK Legislation API (legislation.gov.uk)

## Overview

The Legislation.gov.uk API, maintained by The National Archives, provides open access to the full text of UK legislation from 1267 to the present day. The database covers over 100,000 items including Acts of Parliament, Statutory Instruments, Scottish and Welsh legislation, and Northern Ireland statutes. All data is available as structured XML with Dublin Core metadata, Atom feeds, and HTML. The API supports point-in-time versions showing how legislation read at any given date, plus amendment tracking.

## Authentication

No authentication or API key is required. The API is fully open. Respect rate limits by adding reasonable delays between bulk requests.

## URL Structure

All legislation follows the pattern:

```
https://www.legislation.gov.uk/{type}/{year}/{number}
```

### Legislation Types

| Type Code | Description | Example |
|-----------|-------------|---------|
| `ukpga` | UK Public General Act | `/ukpga/2010/15` (Equality Act 2010) |
| `uksi` | UK Statutory Instrument | `/uksi/2020/1374` |
| `asp` | Act of Scottish Parliament | `/asp/2020/13` |
| `asc` | Act of Senedd Cymru (Wales) | `/asc/2021/4` |
| `nia` | Northern Ireland Act | `/nia/2022/2` |
| `ukla` | UK Local Act | `/ukla/2008/1` |
| `ukdsi` | UK Draft Statutory Instrument | `/ukdsi/2023/123` |
| `eur` | Retained EU Legislation | `/eur/2016/679` (GDPR) |

## Core Endpoints

### Full Legislation Text (XML)

```bash
# Fetch the Equality Act 2010 — returns structured XML with Dublin Core metadata
curl "https://www.legislation.gov.uk/ukpga/2010/15/data.xml"
# Response: <Legislation DocumentURI="http://www.legislation.gov.uk/ukpga/2010/15"
#   NumberOfProvisions="564">
#   <dc:title>Equality Act 2010</dc:title>
#   <dc:description>An Act to make provision to require Ministers...</dc:description>

# Fetch Data Protection Act 2018
curl "https://www.legislation.gov.uk/ukpga/2018/12/data.xml"
# Response: <dc:title>Data Protection Act 2018</dc:title>
#   NumberOfProvisions="1181"

# Fetch a Statutory Instrument
curl "https://www.legislation.gov.uk/uksi/2020/1374/data.xml"
# Response: <dc:title>The Health Protection (Coronavirus, Restric...</dc:title>
```

### Specific Sections

```bash
# Fetch a single section
curl "https://www.legislation.gov.uk/ukpga/2010/15/section/1/data.xml"

# Fetch table of contents
curl "https://www.legislation.gov.uk/ukpga/2010/15/contents/data.xml"

# Fetch a specific Part
curl "https://www.legislation.gov.uk/ukpga/2010/15/part/1/data.xml"

# Fetch a Schedule
curl "https://www.legislation.gov.uk/ukpga/2010/15/schedule/1/data.xml"
```

### Search and Discovery

```bash
# Search by title — returns HTTP 300 with multiple matches
curl "https://www.legislation.gov.uk/id?title=equality+act"

# Browse by type, title keyword, and year
curl "https://www.legislation.gov.uk/ukpga?title=data+protection&year=2018"

# List recent Acts via Atom feed
curl "https://www.legislation.gov.uk/new/ukpga/data.feed"
# Response: <openSearch:totalResults> with <entry> elements per Act
```

### Amendment Tracking

```bash
# Changes affecting a specific Act (Atom feed, paginated)
curl "https://www.legislation.gov.uk/changes/affected/ukpga/2010/15/data.feed"
# Response: <title>Changes to Legislation</title>
#   <leg:totalPages>25</leg:totalPages>
#   Each <entry> describes one amendment with source and target provisions

# Changes made BY a specific Act
curl "https://www.legislation.gov.uk/changes/affecting/ukpga/2010/15/data.feed"
```

### Point-in-Time Versions

```bash
# Legislation as it stood on a specific date
curl "https://www.legislation.gov.uk/ukpga/2010/15/2015-01-01/data.xml"

# Enacted (original) version
curl "https://www.legislation.gov.uk/ukpga/2010/15/enacted/data.xml"
```

## Data Formats

| Suffix | Format | Content-Type |
|--------|--------|-------------|
| `/data.xml` | Legislation XML (CLML) | `application/xml` |
| `/data.feed` | Atom feed | `application/atom+xml` |
| `/data.csv` | CSV export | `text/csv` |
| (none) | HTML rendering | `text/html` |

The primary XML format uses the Crown Legislation Markup Language (CLML) schema with namespaces for `legislation`, `ukm:Metadata`, and Dublin Core (`dc:`, `dct:`) elements. Each document includes `NumberOfProvisions`, `RestrictExtent` (geographic applicability like `E+W+S+N.I.`), and `RestrictStartDate`.

## Academic Use Cases

- **Legislative history**: Track how a statute has evolved using point-in-time versions and amendment feeds
- **Policy analysis**: Compare regulatory regimes across UK jurisdictions (England, Scotland, Wales, NI)
- **Corpus linguistics**: Build legislative text corpora from XML for NLP analysis of legal language
- **Regulatory impact studies**: Use the changes feed to measure legislative amendment frequency
- **Comparative law**: Contrast UK statutory instruments with primary legislation structure
- **Brexit research**: Analyse retained EU legislation (type `eur`) and its UK modifications

## Python Usage

```python
import requests
from xml.etree import ElementTree as ET

BASE = "https://www.legislation.gov.uk"
NS = {"leg": "http://www.legislation.gov.uk/namespaces/legislation",
      "ukm": "http://www.legislation.gov.uk/namespaces/metadata",
      "dc": "http://purl.org/dc/elements/1.1/",
      "atom": "http://www.w3.org/2005/Atom"}

def get_legislation(leg_type: str, year: int, number: int) -> dict:
    """Fetch UK legislation metadata and full XML."""
    url = f"{BASE}/{leg_type}/{year}/{number}/data.xml"
    resp = requests.get(url)
    resp.raise_for_status()
    root = ET.fromstring(resp.content)
    meta = root.find(".//ukm:Metadata", NS)
    return {
        "title": meta.findtext("dc:title", namespaces=NS),
        "description": meta.findtext("dc:description", namespaces=NS),
        "provisions": root.attrib.get("NumberOfProvisions"),
        "extent": root.attrib.get("RestrictExtent"),
        "uri": root.attrib.get("DocumentURI"),
        "xml": resp.content
    }

# Example: fetch the Equality Act 2010
act = get_legislation("ukpga", 2010, 15)
print(f"{act['title']} — {act['provisions']} provisions, extent: {act['extent']}")
# Output: Equality Act 2010 — 564 provisions, extent: E+W+S+N.I.
```

## References

- [Legislation.gov.uk API Documentation](https://www.legislation.gov.uk/developer)
- [CLML Schema Documentation](https://legislation.github.io/clml-schema/)
- [Legislation.gov.uk URI Scheme](https://www.legislation.gov.uk/developer/uris)
- [The National Archives](https://www.nationalarchives.gov.uk/)
- [Atom Feed Specification](https://www.legislation.gov.uk/developer/formats/atom)

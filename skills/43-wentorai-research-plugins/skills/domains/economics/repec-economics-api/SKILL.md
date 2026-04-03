---
name: repec-economics-api
description: "Access 4M+ economics working papers and articles via RePEc API"
metadata:
  openclaw:
    emoji: "📊"
    category: "domains"
    subcategory: "economics"
    keywords: ["RePEc", "economics papers", "working papers", "IDEAS", "EconPapers", "economic research"]
    source: "https://ideas.repec.org/"
---

# RePEc (Research Papers in Economics) API

## Overview

RePEc is the largest decentralized bibliographic database for economics, indexing 4.4M+ items (working papers, journal articles, books, software) from 2,600+ publishers. It powers IDEAS and EconPapers — the two most-used economics paper search engines. The API provides metadata access and citation data. Free, no authentication required for basic access.

## Access Methods

### IDEAS Search API

```bash
# Search economics papers
curl "https://ideas.repec.org/cgi-bin/htsearch?q=monetary+policy+inflation&cmd=Search&fmt=json"

# Search specific types
# Working papers
curl "https://ideas.repec.org/cgi-bin/htsearch?q=fiscal+stimulus&ul=%%2Fp%%2F&fmt=json"

# Journal articles
curl "https://ideas.repec.org/cgi-bin/htsearch?q=trade+liberalization&ul=%%2Fa%%2F&fmt=json"
```

### RePEc Simple API

```bash
# Get metadata for a handle
curl "https://api.repec.org/handle?handle=RePEc:nbr:nberwo:28104"

# Author profile by short-id
curl "https://api.repec.org/author?short-id=ppi1"

# List items in a series
curl "https://api.repec.org/series?series=RePEc:nbr:nberwo"
```

### CitEc Citation Data

```bash
# Get citations for a paper
curl "https://citec.repec.org/api/plain/RePEc:nbr:nberwo:28104"

# Response: list of citing paper handles
```

### LogEc Usage Statistics

```bash
# Get download/view statistics
curl "https://logec.repec.org/scripts/paperstat.pf?h=RePEc:nbr:nberwo:28104"
```

## RePEc Handle Structure

```
RePEc:{archive}:{series}:{id}

Examples:
RePEc:nbr:nberwo:28104   → NBER Working Paper 28104
RePEc:aea:aecrev:v:114:y:2024:i:1:p:1-25  → AER article
RePEc:ecm:emetrp:v:92:y:2024:i:3:p:821-845 → Econometrica article
RePEc:red:sed024:1234    → SED 2024 meeting paper
```

### Major Archives

| Prefix | Publisher |
|--------|-----------|
| `nbr` | National Bureau of Economic Research (NBER) |
| `aea` | American Economic Association |
| `ecm` | Econometric Society |
| `wbk` | World Bank |
| `imf` | International Monetary Fund |
| `fed` | Federal Reserve System |
| `cpr` | Centre for Economic Policy Research (CEPR) |

## Python Usage

```python
import requests

IDEAS_URL = "https://ideas.repec.org/cgi-bin/htsearch"
CITEC_URL = "https://citec.repec.org/api/plain"


def search_economics(query: str, max_results: int = 20,
                     paper_type: str = None) -> list:
    """Search economics papers on IDEAS/RePEc."""
    params = {
        "q": query,
        "cmd": "Search",
        "fmt": "json",
        "ps": max_results,
    }
    if paper_type == "working_papers":
        params["ul"] = "%2Fp%2F"
    elif paper_type == "articles":
        params["ul"] = "%2Fa%2F"

    resp = requests.get(IDEAS_URL, params=params, timeout=30)
    resp.raise_for_status()
    data = resp.json()

    results = []
    for item in data.get("matches", []):
        results.append({
            "title": item.get("title", ""),
            "url": item.get("url", ""),
            "handle": item.get("handle", ""),
            "authors": item.get("authors", ""),
            "date": item.get("date", ""),
            "abstract": item.get("abstract", "")[:300],
        })
    return results


def get_citations(handle: str) -> list:
    """Get papers citing a given RePEc handle."""
    resp = requests.get(f"{CITEC_URL}/{handle}", timeout=30)
    resp.raise_for_status()
    citations = []
    for line in resp.text.strip().split("\n"):
        line = line.strip()
        if line and line.startswith("RePEc:"):
            citations.append(line)
    return citations


def search_working_papers(topic: str) -> list:
    """Search specifically for working papers."""
    return search_economics(topic, paper_type="working_papers")


# Example: find monetary policy research
papers = search_economics("central bank digital currency", max_results=10)
for p in papers:
    print(f"[{p['date']}] {p['title']}")
    print(f"  {p['authors']}")

# Example: citation analysis
if papers and papers[0].get("handle"):
    cites = get_citations(papers[0]["handle"])
    print(f"\nCited by {len(cites)} papers")
    for c in cites[:5]:
        print(f"  {c}")
```

## Key Data Products

| Product | URL | Description |
|---------|-----|-------------|
| IDEAS | ideas.repec.org | Full-text search engine |
| EconPapers | econpapers.repec.org | Alternative search interface |
| CitEc | citec.repec.org | Citation analysis |
| LogEc | logec.repec.org | Usage statistics |
| AuthorService | authors.repec.org | Author profiles and rankings |
| CollEc | collec.repec.org | Institutional research output |

## Rankings

RePEc publishes monthly rankings of economists, institutions, and journals based on citations, downloads, and h-index:

```bash
# Top economists
curl "https://ideas.repec.org/top/top.person.all.html"

# Top institutions
curl "https://ideas.repec.org/top/top.inst.all.html"
```

## References

- [IDEAS/RePEc](https://ideas.repec.org/)
- [EconPapers](https://econpapers.repec.org/)
- [RePEc Author Service](https://authors.repec.org/)
- [CitEc](https://citec.repec.org/)
- Zimmermann, C. (2013). "Academic Rankings with RePEc." *Econometrics* 1(3): 249-264.

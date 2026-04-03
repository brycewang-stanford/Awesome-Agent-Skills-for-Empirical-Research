---
name: nber-working-papers-api
description: "Access NBER working papers and economic research datasets"
metadata:
  openclaw:
    emoji: "📈"
    category: "domains"
    subcategory: "economics"
    keywords: ["NBER", "working papers", "economics research", "macroeconomics", "economic policy", "recession dating"]
    source: "https://www.nber.org/"
---

# NBER Working Papers and Data API

## Overview

The National Bureau of Economic Research (NBER) is the leading U.S. economics research organization, publishing 1,200+ working papers annually by top economists. NBER papers are among the most cited in economics. The website provides structured access to working papers, researcher profiles, and macroeconomic datasets. Free metadata access; some full text requires subscription.

## Working Papers Access

### RSS/Atom Feeds

```bash
# Latest working papers feed
curl "https://www.nber.org/papers.rss"

# Papers by program
curl "https://www.nber.org/programs/ef/papers.rss"  # Economic Fluctuations
curl "https://www.nber.org/programs/ls/papers.rss"  # Labor Studies
curl "https://www.nber.org/programs/io/papers.rss"  # Industrial Organization
```

### Working Paper Search

```bash
# Search via NBER website (HTML scraping needed)
curl "https://www.nber.org/api/v1/working_page_listing/contentType/working_paper/?page=1&perPage=20&q=inflation+expectations"

# Get specific paper metadata
curl "https://www.nber.org/api/v1/working_page_listing/contentType/working_paper/?page=1&perPage=1&q=w28104"
```

### NBER Data Portal

```bash
# Macroeconomic history data
# Available at: https://data.nber.org/

# Business cycle dates
curl "https://data.nber.org/data/cycles/business_cycle_dates.json"

# CPS labor data extracts
# https://data.nber.org/cps/
```

## NBER Programs

| Code | Program | Focus |
|------|---------|-------|
| `ef` | Economic Fluctuations and Growth | Macro, business cycles |
| `ls` | Labor Studies | Employment, wages |
| `io` | Industrial Organization | Markets, competition |
| `pe` | Public Economics | Taxation, spending |
| `he` | Health Economics | Healthcare markets |
| `de` | Development Economics | Developing countries |
| `if` | International Finance | Exchange rates, capital flows |
| `it` | International Trade | Trade policy |
| `me` | Monetary Economics | Central banking |
| `cf` | Corporate Finance | Firm finance |
| `ap` | Asset Pricing | Financial markets |
| `ed` | Education | Education economics |
| `ag` | Aging | Demographics |
| `ch` | Children | Child welfare |
| `le` | Law and Economics | Legal institutions |
| `env` | Environment and Energy | Environmental policy |
| `pol` | Political Economy | Political institutions |

## Python Usage

```python
import requests
from xml.etree import ElementTree


def get_latest_papers(program: str = None,
                      count: int = 20) -> list:
    """Get latest NBER working papers via RSS."""
    if program:
        url = f"https://www.nber.org/programs/{program}/papers.rss"
    else:
        url = "https://www.nber.org/papers.rss"

    resp = requests.get(url, timeout=30)
    resp.raise_for_status()

    root = ElementTree.fromstring(resp.content)
    papers = []
    for item in root.findall(".//item")[:count]:
        papers.append({
            "title": item.findtext("title", ""),
            "link": item.findtext("link", ""),
            "description": item.findtext("description", "")[:300],
            "pub_date": item.findtext("pubDate", ""),
        })
    return papers


def search_papers(query: str, page: int = 1,
                  per_page: int = 20) -> list:
    """Search NBER working papers."""
    resp = requests.get(
        "https://www.nber.org/api/v1/working_page_listing/"
        "contentType/working_paper/",
        params={"q": query, "page": page, "perPage": per_page},
        timeout=30,
    )
    resp.raise_for_status()
    data = resp.json()

    results = []
    for item in data.get("results", []):
        results.append({
            "title": item.get("title"),
            "authors": item.get("authors", ""),
            "number": item.get("wp_number", ""),
            "date": item.get("date", ""),
            "url": f"https://www.nber.org/papers/{item.get('wp_number', '')}",
            "abstract": item.get("description", "")[:300],
            "program": item.get("programs", []),
        })
    return results


def get_business_cycle_dates() -> list:
    """Get NBER official business cycle dates."""
    resp = requests.get(
        "https://data.nber.org/data/cycles/business_cycle_dates.json",
        timeout=30,
    )
    resp.raise_for_status()
    return resp.json()


# Example: latest macro working papers
papers = get_latest_papers(program="ef", count=5)
for p in papers:
    print(f"{p['title']}")
    print(f"  {p['link']}")

# Example: search for AI economics papers
results = search_papers("artificial intelligence labor market")
for r in results:
    print(f"[{r['number']}] {r['title']}")
    print(f"  Authors: {r['authors']}")

# Example: recession dates
cycles = get_business_cycle_dates()
for c in cycles[-3:]:
    print(f"Peak: {c.get('peak')} → Trough: {c.get('trough')}")
```

## Key Datasets

| Dataset | Description |
|---------|-------------|
| Business Cycle Dates | Official US recession start/end dates |
| CPS Extracts | Current Population Survey labor data |
| Macrohistory Database | 150 years of macro indicators |
| Patent Data | Patent citation and classification |
| Trade Data | Bilateral trade statistics |

## References

- [NBER](https://www.nber.org/)
- [NBER Working Papers](https://www.nber.org/papers)
- [NBER Data](https://data.nber.org/)
- [NBER Programs](https://www.nber.org/programs-projects/programs)

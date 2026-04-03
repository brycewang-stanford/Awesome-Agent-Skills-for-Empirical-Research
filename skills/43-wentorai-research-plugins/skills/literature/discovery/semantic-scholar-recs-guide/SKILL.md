---
name: semantic-scholar-recs-guide
description: "Paper discovery via recommendation APIs (OpenAlex, CrossRef citation networks)"
metadata:
  openclaw:
    emoji: "🤖"
    category: "literature"
    subcategory: "discovery"
    keywords: ["related papers", "literature recommendation", "paper discovery", "citation network"]
    source: "wentor-research-plugins"
---

# Paper Discovery via OpenAlex & CrossRef

Leverage the OpenAlex and CrossRef APIs to discover related papers, traverse citation networks, and build comprehensive reading lists programmatically.

## Overview

OpenAlex indexes over 250 million academic works and provides a free, no-key-required API that supports:

- Work search by title, keyword, or DOI
- Citation and reference graph traversal
- Author profiles and publication histories
- Concept-based discovery across disciplines
- Institutional and venue filtering

Base URL: `https://api.openalex.org`
CrossRef URL: `https://api.crossref.org`

## Finding Related Papers

Use OpenAlex's concept graph and citation data to discover related work from seed papers.

### Concept-Based Discovery

```python
import requests

HEADERS = {"User-Agent": "ResearchPlugins/1.0 (https://wentor.ai)"}
WORK_ID = "W2741809807"  # OpenAlex work ID

# Get the seed paper's concepts
response = requests.get(
    f"https://api.openalex.org/works/{WORK_ID}",
    headers=HEADERS
)
paper = response.json()
concepts = [c["id"] for c in paper.get("concepts", [])[:3]]

# Find works sharing the same concepts, sorted by citations
for concept_id in concepts:
    related = requests.get(
        "https://api.openalex.org/works",
        params={"filter": f"concepts.id:{concept_id}", "sort": "cited_by_count:desc", "per_page": 10},
        headers=HEADERS
    )
    for w in related.json().get("results", []):
        print(f"[{w.get('publication_year')}] {w.get('title')} (citations: {w.get('cited_by_count')})")
```

### CrossRef Subject-Based Discovery

```python
import requests

def search_crossref(query, limit=10, sort="is-referenced-by-count"):
    """Search CrossRef for papers sorted by citation count."""
    resp = requests.get(
        "https://api.crossref.org/works",
        params={"query": query, "rows": limit, "sort": sort, "order": "desc"},
        headers={"User-Agent": "ResearchPlugins/1.0 (https://wentor.ai; mailto:dev@wentor.ai)"}
    )
    return resp.json().get("message", {}).get("items", [])

results = search_crossref("transformer attention mechanism")
for w in results:
    title = w.get("title", [""])[0] if w.get("title") else ""
    print(f"  {title} — Cited by: {w.get('is-referenced-by-count', 0)}")
```

## Citation Network Traversal

Walk the citation graph to discover foundational and derivative works.

### Forward Citations (Who Cited This Paper?)

```python
work_id = "W2741809807"

response = requests.get(
    "https://api.openalex.org/works",
    params={
        "filter": f"cites:{work_id}",
        "sort": "cited_by_count:desc",
        "per_page": 20
    },
    headers=HEADERS
)

for w in response.json().get("results", []):
    print(f"  [{w.get('publication_year')}] {w.get('title')} ({w.get('cited_by_count')} cites)")
```

### Backward References (What Did This Paper Cite?)

```python
response = requests.get(
    f"https://api.openalex.org/works/{work_id}",
    headers=HEADERS
)
paper = response.json()
ref_ids = paper.get("referenced_works", [])

# Fetch details for referenced works
for ref_id in ref_ids[:20]:
    ref = requests.get(f"https://api.openalex.org/works/{ref_id.split('/')[-1]}", headers=HEADERS).json()
    print(f"  [{ref.get('publication_year')}] {ref.get('title')} ({ref.get('cited_by_count')} cites)")
```

## Building a Reading List Pipeline

Combine search, concept discovery, and citation traversal into a discovery pipeline:

| Step | Method | Purpose |
|------|--------|---------|
| 1. Seed selection | Manual or keyword search | Identify 3-5 highly relevant papers |
| 2. Expand via concepts | OpenAlex concept graph | Find thematically related work |
| 3. Forward citation | OpenAlex cites filter | Find recent derivative works |
| 4. Backward citation | referenced_works field | Find foundational papers |
| 5. Deduplicate | OpenAlex work ID matching | Remove duplicates across steps |
| 6. Rank & filter | Sort by year, citations, relevance | Prioritize reading order |

```python
def build_reading_list(seed_ids, max_papers=50):
    """Build a ranked reading list from seed papers."""
    seen = set()
    candidates = []

    for seed_id in seed_ids:
        # Get concepts from seed paper
        paper = requests.get(f"https://api.openalex.org/works/{seed_id}", headers=HEADERS).json()
        concept_ids = [c["id"] for c in paper.get("concepts", [])[:2]]

        # Find related works via concepts
        for cid in concept_ids:
            related = requests.get(
                "https://api.openalex.org/works",
                params={"filter": f"concepts.id:{cid}", "sort": "cited_by_count:desc", "per_page": 20},
                headers=HEADERS
            ).json().get("results", [])
            for w in related:
                wid = w.get("id", "").split("/")[-1]
                if wid not in seen:
                    seen.add(wid)
                    candidates.append(w)

        # Get citing works
        citing = requests.get(
            "https://api.openalex.org/works",
            params={"filter": f"cites:{seed_id}", "sort": "cited_by_count:desc", "per_page": 20},
            headers=HEADERS
        ).json().get("results", [])
        for w in citing:
            wid = w.get("id", "").split("/")[-1]
            if wid not in seen:
                seen.add(wid)
                candidates.append(w)

    # Rank by citation count and recency
    candidates.sort(key=lambda p: (p.get("publication_year", 0), p.get("cited_by_count", 0)), reverse=True)
    return candidates[:max_papers]
```

## Best Practices

- OpenAlex is free with no API key required; use a polite `User-Agent` header
- CrossRef requires a polite pool user agent with contact info for higher rate limits
- Always include only the fields you need via `select` parameter to reduce payload size
- Use `page` and `per_page` for pagination on large result sets
- Cache responses locally to avoid redundant requests
- Use DOI as the universal identifier for cross-system compatibility

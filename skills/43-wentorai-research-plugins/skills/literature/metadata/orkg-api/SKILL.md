---
name: orkg-api
description: "Query the Open Research Knowledge Graph for structured research data"
metadata:
  openclaw:
    emoji: "🕸️"
    category: "literature"
    subcategory: "metadata"
    keywords: ["knowledge graph", "research data", "structured research", "ORKG", "research contributions", "scholarly graph"]
    source: "https://orkg.org/"
---

# Open Research Knowledge Graph (ORKG) API

## Overview

The Open Research Knowledge Graph (ORKG) transforms unstructured scholarly articles into structured, machine-readable research contributions. Unlike traditional databases that store metadata (title, authors, DOI), ORKG captures the semantic content — research problems, methods, results, and their relationships. The REST API enables querying, creating, and comparing research contributions programmatically. Free, no authentication required for read operations.

## API Endpoints

### Base URL

```
https://orkg.org/api/
```

### Search Papers

```bash
# Search papers in ORKG
curl "https://orkg.org/api/papers?q=climate+change+adaptation&size=20"

# Get paper details by ID
curl "https://orkg.org/api/papers/R12345"
```

### Search Resources

```bash
# Search any resource (papers, predicates, comparisons)
curl "https://orkg.org/api/resources?q=machine+learning&size=20"

# Filter by class
curl "https://orkg.org/api/resources?q=BERT&exact=false&classes=Paper"
```

### Comparisons

ORKG's unique feature — structured side-by-side comparison of papers:

```bash
# List comparisons
curl "https://orkg.org/api/comparisons?size=10"

# Get a specific comparison
curl "https://orkg.org/api/comparisons/R54321"

# Search comparisons
curl "https://orkg.org/api/comparisons?q=sentiment+analysis"
```

### Research Contributions

```bash
# Get contributions of a paper
curl "https://orkg.org/api/papers/R12345/contributions"

# A contribution describes what a paper contributes:
# - Research problem addressed
# - Method used
# - Results achieved
# - Materials/datasets used
```

## Python Usage

```python
import requests

BASE_URL = "https://orkg.org/api"

def search_orkg_papers(query: str, size: int = 20) -> list:
    """Search papers in the Open Research Knowledge Graph."""
    resp = requests.get(f"{BASE_URL}/papers", params={"q": query, "size": size})
    resp.raise_for_status()
    data = resp.json()

    papers = []
    for item in data.get("content", []):
        papers.append({
            "id": item.get("id"),
            "title": item.get("title"),
            "created": item.get("created_at"),
            "contributions": item.get("contributions", [])
        })
    return papers

def get_paper_contributions(paper_id: str) -> dict:
    """Get structured research contributions for a paper."""
    resp = requests.get(f"{BASE_URL}/papers/{paper_id}/contributions")
    resp.raise_for_status()
    return resp.json()

def search_comparisons(topic: str) -> list:
    """Find structured paper comparisons on a topic."""
    resp = requests.get(f"{BASE_URL}/comparisons", params={"q": topic, "size": 10})
    resp.raise_for_status()
    return resp.json().get("content", [])

# Example usage
papers = search_orkg_papers("transfer learning NLP")
for p in papers:
    print(f"[{p['id']}] {p['title']}")

comparisons = search_comparisons("named entity recognition")
for c in comparisons:
    print(f"Comparison: {c.get('title')} ({len(c.get('contributions', []))} papers)")
```

## Key Concepts

| Concept | Description | Example |
|---------|-------------|---------|
| **Paper** | A scholarly article with metadata | "Attention Is All You Need" |
| **Contribution** | What a paper contributes to knowledge | "Proposes self-attention mechanism" |
| **Research Problem** | The problem a contribution addresses | "Machine translation quality" |
| **Predicate** | A relationship type | "has_method", "has_result", "uses_dataset" |
| **Comparison** | Side-by-side structured comparison | "Transformer variants comparison" |
| **Resource** | Any entity in the knowledge graph | A method, dataset, metric, or concept |

## ORKG vs Traditional Databases

| Feature | Traditional (S2, Crossref) | ORKG |
|---------|---------------------------|------|
| Content | Metadata (title, DOI, citations) | Semantic content (methods, results) |
| Structure | Flat records | Knowledge graph with relationships |
| Comparison | Manual (read each paper) | Automated structured comparisons |
| Machine-readable | Bibliographic metadata only | Research contributions structured |
| Coverage | Broad (200M+ papers) | Deep but narrower (~50K papers) |

## Use Cases

1. **Literature surveys**: Find existing comparisons to quickly understand a field
2. **Method selection**: Compare methods across papers on structured criteria
3. **Gap analysis**: Identify research problems without solutions
4. **Reproducibility**: Access structured descriptions of experimental setups

## References

- [ORKG Website](https://orkg.org/)
- [ORKG API Documentation](https://orkg.org/api/)
- [ORKG Help Center](https://orkg.org/help-center)
- Jaradeh, M.Y., et al. (2019). "Open Research Knowledge Graph: Next Generation Infrastructure for Semantic Scholarly Knowledge." *K-CAP 2019*.

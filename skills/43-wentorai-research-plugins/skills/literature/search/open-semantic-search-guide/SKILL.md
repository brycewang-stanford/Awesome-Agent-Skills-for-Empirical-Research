---
name: open-semantic-search-guide
description: "Self-hosted semantic search and text mining platform"
metadata:
  openclaw:
    emoji: "🔎"
    category: "literature"
    subcategory: "search"
    keywords: ["semantic search", "text mining", "self-hosted", "Solr", "NLP", "entity extraction"]
    source: "https://github.com/opensemanticsearch/open-semantic-search"
---

# Open Semantic Search Guide

## Overview

Open Semantic Search is a self-hosted search and text mining platform that combines full-text search (Apache Solr) with semantic analysis — entity extraction, named entity recognition, text classification, and knowledge graph building. Process and search across documents (PDF, DOCX, emails) with faceted navigation and visual analytics. Ideal for researchers needing private, on-premise document search over large paper collections.

## Installation

```bash
# Docker deployment (recommended)
git clone https://github.com/opensemanticsearch/open-semantic-search.git
cd open-semantic-search
docker-compose up -d

# Access web UI at http://localhost:8080
# Admin panel at http://localhost:8080/admin
```

## Architecture

```
Documents (PDF, DOCX, HTML, email)
         ↓
   Connector/Crawler (file system, web, IMAP)
         ↓
   ETL Pipeline
   ├── Text extraction (Apache Tika)
   ├── OCR (Tesseract, for scanned docs)
   ├── NER (spaCy, Stanford NER)
   ├── Entity linking (knowledge base)
   └── Classification (custom models)
         ↓
   Apache Solr (full-text index + facets)
         ↓
   Web UI (search, browse, visualize)
```

## Indexing Documents

```bash
# Index a directory of papers
curl -X POST "http://localhost:8080/api/index" \
  -H "Content-Type: application/json" \
  -d '{"path": "/data/papers/", "recursive": true}'

# Index single file
curl -X POST "http://localhost:8080/api/index" \
  -H "Content-Type: application/json" \
  -d '{"path": "/data/papers/attention.pdf"}'

# Schedule recurring index
# Add to crontab or use built-in scheduler
```

## Search Features

```markdown
### Full-Text Search
- Boolean queries: "attention mechanism" AND transformer
- Phrase search: "self-attention"
- Wildcard: transform*
- Proximity: "attention transformer"~5 (within 5 words)
- Field-specific: title:"attention" author:"Vaswani"

### Faceted Navigation
- Filter by: author, date, organization, topic, language
- Nested facets for hierarchical browsing
- Date range slider
- Entity type filters (person, organization, location)

### Semantic Features
- Named entity highlighting in results
- Related entity suggestions
- Concept co-occurrence visualization
- Auto-generated tag clouds
```

## Python Client

```python
import requests

SEARCH_URL = "http://localhost:8080/api/search"

def search_papers(query, filters=None, max_results=20):
    """Search indexed documents."""
    params = {
        "q": query,
        "rows": max_results,
        "fl": "title,author,content_type,date,score",
        "hl": "true",        # Highlight matches
        "hl.fl": "content",  # Highlight in content field
        "facet": "true",
        "facet.field": ["author", "organization", "topic"],
    }
    if filters:
        params["fq"] = filters

    resp = requests.get(SEARCH_URL, params=params)
    data = resp.json()

    results = data["response"]["docs"]
    facets = data.get("facet_counts", {}).get("facet_fields", {})

    return results, facets

# Search
results, facets = search_papers(
    "attention mechanism transformer",
    filters='date:[2023-01-01T00:00:00Z TO *]',
)

for doc in results:
    print(f"[{doc.get('date', 'N/A')}] {doc.get('title', 'Untitled')}")
    print(f"  Score: {doc['score']:.2f}")
```

## Entity Extraction Configuration

```json
{
  "ner": {
    "engines": ["spacy", "stanford"],
    "models": {
      "spacy": "en_core_web_lg",
      "stanford": "english.all.3class.caseless"
    },
    "entity_types": [
      "PERSON", "ORG", "GPE", "DATE",
      "WORK_OF_ART", "EVENT"
    ],
    "custom_entities": {
      "METHODOLOGY": ["transformer", "CNN", "RNN", "GAN"],
      "DATASET": ["ImageNet", "CIFAR", "MNIST", "COCO"]
    }
  },
  "classification": {
    "enabled": true,
    "model": "custom_topic_classifier",
    "categories": ["NLP", "CV", "RL", "Theory"]
  }
}
```

## Knowledge Graph

```python
# Query the auto-built knowledge graph
def get_entity_network(entity, depth=2):
    """Get co-occurring entities for a given entity."""
    resp = requests.get(
        f"{SEARCH_URL}/graph",
        params={"entity": entity, "depth": depth},
    )
    graph = resp.json()

    for node in graph["nodes"]:
        print(f"Entity: {node['label']} ({node['type']})")
    for edge in graph["edges"]:
        print(f"  {edge['source']} ↔ {edge['target']} "
              f"(co-occur: {edge['weight']})")

get_entity_network("Transformer")
```

## Use Cases

1. **Paper search**: Full-text search over local paper collections
2. **Literature mining**: Extract entities and relationships from papers
3. **Institutional repository**: Campus-wide document search
4. **Due diligence**: Search across legal/business document archives
5. **Investigative research**: Cross-reference entities across documents

## References

- [Open Semantic Search GitHub](https://github.com/opensemanticsearch/open-semantic-search)
- [Apache Solr](https://solr.apache.org/)
- [Apache Tika](https://tika.apache.org/)

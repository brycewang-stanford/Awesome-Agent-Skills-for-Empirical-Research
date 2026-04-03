---
name: semantic-paper-radar
description: "Semantic literature discovery and synthesis using embeddings"
metadata:
  openclaw:
    emoji: "📡"
    category: "literature"
    subcategory: "discovery"
    keywords: ["semantic search", "embeddings", "literature synthesis", "paper discovery", "vector search", "knowledge mapping"]
    source: "wentor-research-plugins"
---

# Semantic Paper Radar

## Overview

Traditional literature search relies on keyword matching—you find papers that contain the exact terms you search for. Semantic paper discovery goes further by understanding the meaning of research content and finding papers that are conceptually related, even when they use different terminology. This is especially powerful for interdisciplinary research, where the same idea may be expressed in completely different vocabularies across fields.

The Semantic Paper Radar skill provides methods for using embedding-based semantic search, vector databases, and AI-powered synthesis to build a comprehensive, continuously updated view of the literature relevant to your research. It enables you to discover papers you would never find through keyword search alone and to synthesize findings across large bodies of work.

This skill covers setting up a personal semantic search index over your paper collection, querying public semantic search APIs, and using LLM-powered analysis to extract themes and connections from clusters of related papers.

## Semantic Search Fundamentals

### How Embedding-Based Search Works

Semantic search represents both your query and each paper as dense numerical vectors (embeddings) in a high-dimensional space. Papers whose embeddings are close to your query's embedding are semantically similar, regardless of the specific words used.

Key components:
- **Embedding model**: Converts text to vectors. Models like SPECTER2, SciBERT, or general-purpose models like `text-embedding-3-small` work well for academic text.
- **Vector database**: Stores and indexes embeddings for fast similarity search. Options include ChromaDB (local), Qdrant, Pinecone, or Weaviate.
- **Similarity metric**: Cosine similarity is standard for comparing text embeddings.

### Using OpenAlex's Search API

OpenAlex indexes 250M+ works and supports search queries across all disciplines:

```bash
# Search works via the OpenAlex API
curl "https://api.openalex.org/works?search=attention+mechanisms+for+graph+neural+networks&per_page=20"
```

The search endpoint uses relevance-ranked matching. Combine with concept filters and citation data for more targeted discovery. For true semantic matching, build a local embedding index (see below).

### Building a Personal Semantic Index

For deeper control, build a local semantic search index over your own paper collection:

```python
import chromadb
from sentence_transformers import SentenceTransformer

# Initialize
model = SentenceTransformer("allenai/specter2")
client = chromadb.PersistentClient(path="./paper_index")
collection = client.get_or_create_collection(
    name="my_papers",
    metadata={"hnsw:space": "cosine"}
)

# Index a paper
abstract = "We propose a novel attention mechanism for graph neural networks..."
embedding = model.encode(abstract).tolist()
collection.add(
    documents=[abstract],
    embeddings=[embedding],
    metadatas=[{"title": "Graph Attention v2", "year": 2025, "arxiv_id": "2501.xxxxx"}],
    ids=["paper_001"]
)

# Query
results = collection.query(
    query_embeddings=[model.encode("message passing in GNNs").tolist()],
    n_results=10
)
```

This local index lets you search across all papers you have collected using natural language queries. As you add more papers, the index becomes a personalized discovery tool tuned to your specific research interests.

## Discovery Workflows

### Concept Expansion Radar

Use semantic search to expand your awareness beyond your current reading:

1. **Seed**: Take the abstract of your current paper (or a paragraph describing your research question).
2. **Search**: Run it as a semantic query against a large corpus (OpenAlex, CrossRef, or your local index).
3. **Filter**: Remove papers you have already read. Sort by a combination of semantic similarity and recency.
4. **Cluster**: Group the top 50 results into thematic clusters using k-means or HDBSCAN on their embeddings.
5. **Explore clusters**: Each cluster represents a related subtopic. Read the most-cited paper in each cluster to understand the connection to your work.

### Cross-Disciplinary Bridge Detection

Semantic search excels at finding papers from other fields that address similar problems:

1. Describe your research problem in plain, non-technical language.
2. Run this as a semantic query without restricting to your field's journals or categories.
3. Review results from unexpected fields—these are potential interdisciplinary connections.
4. For each bridge paper, check its reference list for more domain-specific work in that field.

### Novelty Radar

Set up periodic semantic searches to detect new papers in your area:

1. Define 3-5 "concept vectors" by encoding descriptions of your core research interests.
2. Weekly, search against newly published papers (last 7 days) from arXiv or OpenAlex.
3. Rank new papers by maximum similarity to any of your concept vectors.
4. Papers above your similarity threshold enter your reading queue automatically.

## Semantic Synthesis

Once you have discovered a cluster of related papers, use AI-assisted synthesis to extract insights across the collection:

### Theme Extraction

Feed the abstracts of a cluster of papers to an LLM and ask for:
- Common themes and findings across the papers
- Points of disagreement or contradiction
- Methodological trends (what approaches are gaining vs. losing popularity)
- Open questions that none of the papers fully address

### Evidence Mapping

Create a structured evidence map from your semantic cluster:

| Theme | Supporting Papers | Contradicting Papers | Strength of Evidence |
|-------|-------------------|----------------------|---------------------|
| Theme A | [1], [3], [7] | [5] | Strong |
| Theme B | [2], [4] | None | Moderate |
| Theme C | [6] | [1], [8] | Contested |

This provides a bird's-eye view of where consensus exists and where debates remain open.

### Gap Identification

Compare your research question against the semantic landscape of existing work. Regions of embedding space where your query falls but few papers exist represent potential research gaps—areas where your contribution would be most novel.

## References

- OpenAlex API: https://api.openalex.org
- SPECTER2 model: https://huggingface.co/allenai/specter2
- ChromaDB: https://www.trychroma.com
- ResearchGPT: https://github.com/mukulpatnaik/researchgpt
- OpenAlex: https://openalex.org

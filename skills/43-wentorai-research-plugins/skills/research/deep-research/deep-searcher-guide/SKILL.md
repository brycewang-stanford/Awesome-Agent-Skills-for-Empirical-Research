---
name: deep-searcher-guide
description: "Open deep research alternative for private data with vector search"
metadata:
  openclaw:
    emoji: "🔍"
    category: "research"
    subcategory: "deep-research"
    keywords: ["deep-search", "private-data", "milvus", "vector-search", "rag", "document-retrieval"]
    source: "https://github.com/zilliztech/deep-searcher"
---

# Deep Searcher Guide

## Overview

Deep Searcher is an open-source deep research tool developed by Zilliz with over 8,000 GitHub stars, designed to be an open alternative to proprietary deep research systems like OpenAI's Deep Research and Gemini Deep Research. What distinguishes Deep Searcher is its focus on private data -- it enables researchers to conduct deep, iterative research over their own document collections, databases, and institutional knowledge bases rather than being limited to public web content.

The system combines vector search via Milvus (or other vector databases) with agentic RAG (Retrieval-Augmented Generation) to decompose complex research questions, retrieve relevant passages from your document collection, reason over the retrieved content, and iteratively refine its search until it can produce a comprehensive answer. This makes it particularly valuable for researchers who work with proprietary datasets, unpublished manuscripts, internal reports, or specialized domain corpora that are not available through web search.

Deep Searcher supports multiple LLM providers and embedding models, and can be deployed entirely on-premises for organizations with strict data privacy requirements. It is built on top of Milvus, the high-performance open-source vector database also created by Zilliz, ensuring scalable and efficient similarity search across large document collections.

## Installation and Setup

```bash
# Install Deep Searcher
pip install deepsearcher

# Or clone for development
git clone https://github.com/zilliztech/deep-searcher.git
cd deep-searcher
pip install -e .
```

### Dependencies Setup

Deep Searcher requires a vector database and LLM access:

```bash
# Option 1: Milvus Lite (embedded, no separate server needed)
pip install pymilvus[model]

# Option 2: Full Milvus via Docker
docker run -d --name milvus \
  -p 19530:19530 \
  -p 9091:9091 \
  milvusio/milvus:latest standalone

# Configure LLM access
export OPENAI_API_KEY=$OPENAI_API_KEY
# Or for local LLMs
export OLLAMA_BASE_URL=http://localhost:11434
```

### Configuration

Create a configuration file for your research setup:

```python
from deepsearcher import DeepSearcher
from deepsearcher.config import Config

config = Config(
    # Vector database settings
    vector_db="milvus_lite",  # or "milvus", "zilliz_cloud"
    collection_name="research_papers",

    # LLM settings
    llm_provider="openai",
    llm_model="gpt-4o",

    # Embedding settings
    embedding_model="text-embedding-3-small",

    # Research settings
    max_iterations=10,
    chunk_size=1000,
    chunk_overlap=200,
)

searcher = DeepSearcher(config)
```

## Document Ingestion

### Loading Research Documents

Ingest your research documents into the vector database for searchable access:

```python
# Load individual files
searcher.load_document("path/to/paper.pdf")
searcher.load_document("path/to/notes.md")

# Load entire directories
searcher.load_directory(
    "path/to/papers/",
    file_types=["pdf", "md", "txt", "docx"],
    recursive=True,
)

# Load with metadata for filtering
searcher.load_document(
    "path/to/paper.pdf",
    metadata={
        "author": "Smith et al.",
        "year": 2024,
        "topic": "transformer efficiency",
        "venue": "NeurIPS",
    }
)
```

### Supported Document Types

Deep Searcher supports a wide range of document formats commonly used in academic research:

- **PDF**: Research papers, textbooks, reports (with OCR support for scanned documents)
- **Markdown**: Research notes, documentation, wikis
- **Plain text**: Data files, logs, transcripts
- **DOCX/DOC**: Word documents, manuscripts
- **HTML**: Web pages, saved articles
- **LaTeX**: TeX source files with equation extraction
- **Jupyter Notebooks**: Code and analysis notebooks

## Deep Research Workflow

### Basic Research Query

```python
# Ask a research question over your document collection
result = searcher.research(
    query="What methods have been proposed for reducing the "
          "computational complexity of self-attention in transformers?",
)

print(result.answer)
print(f"Sources: {len(result.sources)}")
for source in result.sources:
    print(f"  - {source.document}: {source.chunk_preview[:100]}...")
```

### Iterative Research Process

Deep Searcher follows an iterative research pipeline:

1. **Query decomposition**: The research question is broken into sub-queries
2. **Initial retrieval**: Vector search retrieves relevant passages for each sub-query
3. **Analysis**: The LLM analyzes retrieved content and identifies information gaps
4. **Refined search**: New queries are generated to fill gaps, with the search refined based on what has been found
5. **Synthesis**: All gathered information is synthesized into a comprehensive answer with citations

```python
# Watch the iterative research process
result = searcher.research(
    query="Compare the approaches to efficient attention in the papers "
          "I have collected, focusing on trade-offs between speed and quality",
    verbose=True,  # Print each research iteration
    max_iterations=8,
)

# Access the research trace
for step in result.trace:
    print(f"Iteration {step.iteration}:")
    print(f"  Sub-query: {step.query}")
    print(f"  Documents found: {step.num_results}")
    print(f"  Gap identified: {step.gap}")
```

### Filtered Research

Narrow your research to specific subsets of your collection:

```python
# Research only within papers from a specific venue
result = searcher.research(
    query="Novel loss functions for contrastive learning",
    filters={"venue": "ICML", "year": {"$gte": 2023}},
)

# Research across specific document groups
result = searcher.research(
    query="How do the baseline methods compare across my experiment logs?",
    filters={"topic": "baseline-comparison"},
)
```

## Integration with Research Tools

### Combining Private and Public Data

Deep Searcher can be combined with web search for comprehensive research that covers both your private collection and public sources:

```python
from deepsearcher.sources import WebSearchSource

# Add web search as an additional source
config.add_source(WebSearchSource(
    provider="tavily",
    api_key_env="TAVILY_API_KEY",
))

# Research now spans both private documents and the web
result = searcher.research(
    query="Recent advances in protein folding prediction",
    sources=["private", "web"],
)
```

### Export and Sharing

Export research results in formats suitable for academic use:

```python
# Export as markdown report
result.export_markdown("research_report.md")

# Export citations in BibTeX format
result.export_citations("references.bib")

# Export the full research trace for reproducibility
result.export_trace("research_trace.json")
```

### API Server

Run Deep Searcher as a service for team-wide access:

```bash
# Start the API server
deepsearcher serve --host 0.0.0.0 --port 8000

# Query via REST API
curl -X POST http://localhost:8000/research \
  -H "Content-Type: application/json" \
  -d '{"query": "What are the key findings in our latest experiments?"}'
```

## Performance and Scalability

Deep Searcher leverages Milvus for high-performance vector search, which means it can handle document collections ranging from hundreds to millions of documents efficiently. Key performance considerations include:

- **Indexing**: Milvus uses HNSW or IVF indexes for fast approximate nearest neighbor search
- **Chunking strategy**: Adjustable chunk size and overlap to balance retrieval precision and recall
- **Embedding caching**: Previously computed embeddings are cached to avoid redundant computation
- **Batch processing**: Documents can be ingested in parallel for faster indexing

## References

- Repository: https://github.com/zilliztech/deep-searcher
- Milvus vector database: https://milvus.io/
- Zilliz Cloud (managed Milvus): https://zilliz.com/
- Milvus documentation: https://milvus.io/docs/

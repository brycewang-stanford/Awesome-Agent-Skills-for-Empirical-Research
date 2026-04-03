---
name: docsgpt-guide
description: "Deploy DocsGPT for private document analysis and research knowledge bases"
metadata:
  openclaw:
    emoji: "📚"
    category: "tools"
    subcategory: "document"
    keywords: ["document-analysis", "knowledge-base", "rag", "private-ai", "enterprise-search", "question-answering"]
    source: "https://github.com/arc53/DocsGPT"
---

# DocsGPT Guide

## Overview

DocsGPT is an open-source platform for building private AI-powered document analysis and question-answering systems. It uses Retrieval Augmented Generation (RAG) to enable natural language queries against your own document collections, making it particularly valuable for researchers who need to quickly extract information from large corpora of papers, technical reports, and institutional documentation.

Unlike general-purpose chatbots, DocsGPT operates on your specific documents, providing grounded answers with source citations. This is critical in academic settings where hallucinated information can derail research. The platform supports a wide range of document formats including PDF, DOCX, Markdown, HTML, and plain text, covering the formats most commonly encountered in research workflows.

With over 18,000 GitHub stars and an active development community, DocsGPT offers both self-hosted deployment for data-sensitive research environments and a cloud-hosted option for quick evaluation. The self-hosted approach ensures that proprietary research data, unpublished manuscripts, and confidential institutional documents never leave your infrastructure.

## Installation and Setup

Deploy DocsGPT using Docker Compose for the simplest setup:

```bash
git clone https://github.com/arc53/DocsGPT.git
cd DocsGPT

# Copy and configure environment settings
cp .env_sample .env
```

Edit the `.env` file to configure your LLM backend:

```bash
# Set your LLM provider credentials
LLM_NAME=openai
API_KEY=$OPENAI_API_KEY

# Or use a local model via Ollama
LLM_NAME=ollama
OLLAMA_API_BASE=http://localhost:11434
MODEL_NAME=llama3
```

Launch the application:

```bash
docker compose up -d
```

The web interface becomes available at `http://localhost:5173`. For production deployments behind a reverse proxy, configure the appropriate `VITE_API_HOST` environment variable.

For development or lightweight usage without Docker:

```bash
pip install -r requirements.txt
cd application
python app.py
```

## Core Features

**Document Ingestion and Indexing**: Upload documents through the web interface or API. DocsGPT processes them into vector embeddings for efficient semantic search:

```bash
# Upload documents via the API
curl -X POST http://localhost:7091/api/upload \
  -F "file=@research_paper.pdf" \
  -F "name=my-research-collection"
```

Supported formats include PDF, DOCX, TXT, MD, HTML, EPUB, and RST files. Large documents are automatically chunked with configurable overlap to maintain context across segment boundaries.

**Conversational Querying**: Ask natural language questions about your documents and receive answers grounded in the source material:

```bash
# Query your document collection via API
curl -X POST http://localhost:7091/api/answer \
  -H "Content-Type: application/json" \
  -d '{
    "question": "What statistical methods were used for sample size estimation?",
    "active_docs": "my-research-collection"
  }'
```

Each response includes source references pointing to the specific document sections used to generate the answer, enabling verification.

**Multiple Knowledge Bases**: Create separate document collections for different research projects, courses, or literature review topics. Switch between collections seamlessly during querying.

**API Integration**: The REST API enables programmatic access for building custom research tools, automated analysis pipelines, or integration with existing laboratory information management systems.

## Research Workflow Integration

DocsGPT serves several important functions in academic research:

**Literature Synthesis**: Upload all papers related to a research question and use conversational queries to identify consensus findings, methodological variations, and contradictions across the literature. This accelerates the synthesis phase of literature reviews.

**Thesis and Dissertation Support**: Index your entire reference collection and use DocsGPT to quickly locate specific claims, find supporting evidence for arguments, and verify that your citations accurately represent source material.

**Lab Notebook Analysis**: Upload experimental protocols, lab notebooks, and equipment manuals to create a searchable knowledge base. New lab members can quickly find procedures and troubleshooting information without interrupting senior researchers.

**Grant Proposal Preparation**: Build a collection from relevant prior work, agency guidelines, and successful proposal examples. Query this collection to identify framing strategies, required elements, and alignment between your proposed work and funder priorities.

**Course Material Management**: Instructors can index textbooks, lecture notes, and supplementary readings. Students can then query the collection for study assistance, with all answers grounded in approved course materials.

## Configuration and Customization

Tune retrieval and generation parameters for your use case:

```bash
# Environment variables for fine-tuning
CHUNKS_PER_QUERY=5          # Number of document chunks retrieved per query
CHUNK_SIZE=512              # Size of text chunks during ingestion
CHUNK_OVERLAP=64            # Overlap between adjacent chunks
MAX_TOKENS=2048             # Maximum response length
TEMPERATURE=0.1             # Lower values for more factual responses
```

For academic use, keep temperature low (0.1-0.3) to prioritize factual accuracy over creative responses. Increase `CHUNKS_PER_QUERY` when questions require synthesizing information from multiple sections of a document.

Custom embeddings models can be configured for domain-specific terminology. If your research involves highly specialized vocabulary (medical terminology, chemical nomenclature), consider using domain-adapted embedding models for improved retrieval accuracy.

## References

- DocsGPT repository: https://github.com/arc53/DocsGPT
- DocsGPT documentation: https://docs.docsgpt.cloud/
- REST API reference available in the repository wiki

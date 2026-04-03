---
name: i3
description: |
  RAG Builder with Parallel Document Processing
  Vector database construction with local embeddings (zero cost)
  Handles PDF download, text extraction, chunking, and vector database creation
  Absorbed B5 (Parallel Document Processor) capabilities
  Use when: building RAG, creating vector database, downloading PDFs, embedding documents, batch processing
  Triggers: build RAG, create vector database, download PDFs, embed documents, batch PDF processing
version: "12.0.1"
---

## ⛔ Prerequisites (v8.2 — MCP Enforcement)

`diverga_check_prerequisites("i3")` → must return `approved: true`
If not approved → AskUserQuestion for each missing checkpoint (see `.claude/references/checkpoint-templates.md`)

### Checkpoints During Execution
- 🟠 SCH_RAG_READINESS → `diverga_mark_checkpoint("SCH_RAG_READINESS", decision, rationale)`

### Fallback (MCP unavailable)
Read `.research/decision-log.yaml` directly to verify prerequisites. Conversation history is last resort.

---

# I3-RAGBuilder

**Agent ID**: I3
**Category**: I - Systematic Review Automation
**Tier**: LOW (Haiku)
**Icon**: 🗄️⚡

## Overview

Builds a RAG (Retrieval-Augmented Generation) system from PRISMA-selected papers. Uses completely free local embeddings and ChromaDB, making the RAG building stage $0 cost. Handles PDF download, text extraction, chunking, and vector database creation.

## Zero-Cost Stack

| Component | Tool | Cost |
|-----------|------|------|
| **PDF Download** | requests | $0 |
| **Text Extraction** | PyMuPDF | $0 |
| **Embeddings** | all-MiniLM-L6-v2 | $0 (local) |
| **Vector DB** | ChromaDB | $0 (local) |
| **Chunking** | LangChain | $0 |

**Total RAG Building Cost**: **$0**

## Input Schema

```yaml
Required:
  - project_path: "string"

Optional:
  - chunk_size_tokens: "int (default: 500)"
  - chunk_overlap_tokens: "int (default: 100)"
  - embedding_model: "string (default: all-MiniLM-L6-v2)"
  - delay_between_downloads: "float (default: 2.0)"
  - download_timeout: "int (default: 30)"
```

## Output Schema

```yaml
main_output:
  stage: "rag_build"
  pdf_download:
    total_papers: "int"
    downloaded: "int"
    failed: "int"
    success_rate: "string"
    total_size_mb: "int"
  rag_build:
    total_chunks: "int"
    avg_chunks_per_paper: "float"
    chunk_size_tokens: "int"
    chunk_overlap_tokens: "int"
    embedding_model: "string"
    embedding_dimensions: "int"
    vector_db: "string"
  output_paths:
    pdfs: "string"
    chroma_db: "string"
    rag_config: "string"
```

## Human Checkpoint Protocol

### 🟠 SCH_RAG_READINESS (RECOMMENDED)

Before completing RAG build, I3 SHOULD:

1. **REPORT** build status:
   ```
   RAG Build Complete

   PDF Download:
   - Total papers: 287
   - PDFs downloaded: 245 (85.4%)
   - PDFs unavailable: 42

   Vector Database:
   - Total chunks: 4,850
   - Avg chunks/paper: 19.8
   - Embedding model: all-MiniLM-L6-v2
   - Database: ChromaDB

   Storage:
   - PDF size: 1.2 GB
   - Vector DB size: 450 MB

   Ready for research queries?
   ```

2. **ASK** if user wants to proceed
3. **CONFIRM** RAG is ready for queries

## Execution Commands

```bash
# Project path (set to your working directory)
cd "$(pwd)"

# Stage 4: PDF Download
python scripts/04_download_pdfs.py \
  --project {project_path} \
  --delay 2.0 \
  --timeout 30

# Stage 5: RAG Build
python scripts/05_build_rag.py \
  --project {project_path} \
  --chunk-size 1000 \
  --chunk-overlap 200 \
  --embedding-model sentence-transformers/all-MiniLM-L6-v2
```

## Chunking Strategy (v1.2.6: Token-Based)

**Problem**: Documentation says "1000 tokens" but code used "1000 characters"

**Fix**: Token-based chunking with tiktoken

```python
import tiktoken
tokenizer = tiktoken.get_encoding("cl100k_base")

# Settings
chunk_size_tokens = 500    # Actual tokens
chunk_overlap_tokens = 100  # Actual tokens

# Character fallback (if tiktoken unavailable)
chunk_size_chars = 1000
chunk_overlap_chars = 200
```

## Embedding Model Options

| Model | Dimensions | Speed | Quality |
|-------|------------|-------|---------|
| **all-MiniLM-L6-v2** (Default) | 384 | Fast | Good |
| all-mpnet-base-v2 | 768 | Medium | Better |
| bge-small-en-v1.5 | 384 | Fast | Good |
| e5-small-v2 | 384 | Fast | Good |

All models run locally at zero cost.

## PDF Download Strategy

### Open Access Sources
| Source | URL Pattern | Success Rate |
|--------|-------------|--------------|
| Semantic Scholar | `openAccessPdf.url` | ~40% |
| OpenAlex | `open_access.oa_url` | ~50% |
| arXiv | `arxiv.org/pdf/{id}.pdf` | 100% |

### Retry Logic
```python
max_retries = 3
base_delay = 2.0

for attempt in range(max_retries):
    try:
        download_pdf(url)
        break
    except Timeout:
        delay = base_delay * (2 ** attempt)
        time.sleep(delay)
```

### Validation
- Minimum file size: 1KB
- Content-Type: application/pdf
- PDF header check: %PDF-

## Vector Database Structure

```
data/04_rag/
├── chroma_db/
│   ├── chroma.sqlite3      # Metadata store
│   ├── {collection_id}/    # Vector embeddings
│   └── index/              # HNSW index
└── rag_config.json         # Configuration
```

## Query Testing

After build, I3 tests retrieval with research question:

```python
# Test query
results = vectorstore.similarity_search(
    research_question,
    k=5
)

# Report results
for doc in results:
    print(f"- {doc.metadata['title']} ({doc.metadata['year']})")
    print(f"  Preview: {doc.page_content[:150]}...")
```

## Auto-Trigger Keywords

| Keywords (EN) | Keywords (KR) | Action |
|---------------|---------------|--------|
| build RAG, create vector database | RAG 구축, 벡터 DB | Activate I3 |
| download PDFs | PDF 다운로드 | Activate I3 |
| embed documents | 문서 임베딩 | Activate I3 |

## Absorbed Capabilities (v11.0)

### From B5 — Parallel Document Processor

- **Distributed Workload Splitting**: Partition PDF collection into balanced worker batches by file size, configurable worker count (default: CPU cores - 1, max: 8), dynamic rebalancing
- **High-Throughput PDF Reading**: Parallel text extraction using multiprocessing Pool, per-worker memory limits (default: 2GB), automatic fallback (PyMuPDF -> pdfplumber -> OCR), streaming mode for PDFs > 50MB
- **Batch Extraction Pipeline**: Pool-based parallel processing with configurable chunk size and overlap
- **Performance Targets**: <50 PDFs sequential (<5 min), 50-200 PDFs 4 workers (<10 min), 200-500 PDFs 6 workers (<20 min), 500+ PDFs 8 workers (<45 min)
- **Error Handling in Parallel Mode**: Failed PDFs logged without halting other workers, retry queue for transient failures, checkpoint files for resuming interrupted processing

## Error Handling

| Error | Action |
|-------|--------|
| PDF corrupt | Skip, log to failed list |
| OCR needed | Fall back to pytesseract |
| Memory limit | Process in batches |
| Embedding timeout | Retry with smaller batch |

## Dependencies

```yaml
requires: ["I2-screening-assistant"]
sequential_next: []
parallel_compatible: []
```

## Related Agents

- **I0-review-pipeline-orchestrator**: Pipeline coordination
- **I2-screening-assistant**: PRISMA screening

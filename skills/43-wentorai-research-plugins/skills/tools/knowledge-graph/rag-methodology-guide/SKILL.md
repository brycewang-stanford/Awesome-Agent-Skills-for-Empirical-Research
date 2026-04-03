---
name: rag-methodology-guide
description: "RAG architecture for academic knowledge retrieval and synthesis"
metadata:
  openclaw:
    emoji: "🧠"
    category: "tools"
    subcategory: "knowledge-graph"
    keywords: ["RAG", "retrieval augmented generation", "academic knowledge graph", "knowledge modeling"]
    source: "wentor-research-plugins"
---

# RAG Methodology Guide

Design and implement Retrieval-Augmented Generation (RAG) systems for academic research, including document chunking, embedding strategies, retrieval pipelines, and evaluation.

## What Is RAG?

Retrieval-Augmented Generation (RAG) augments a language model's generation with relevant information retrieved from an external knowledge base. For academic research, this enables:

- Question answering over a personal paper library
- Literature synthesis across hundreds of papers
- Fact-checking claims against source documents
- Generating citations with provenance

### RAG Pipeline Architecture

```
Query: "What are the main challenges of protein folding?"
    |
    v
[1. Query Processing]
    |-- Embed query using embedding model
    |-- Optional: Query expansion / HyDE
    |
    v
[2. Retrieval]
    |-- Search vector database for top-k relevant chunks
    |-- Optional: Reranking with cross-encoder
    |
    v
[3. Context Assembly]
    |-- Combine retrieved chunks into a prompt
    |-- Add metadata (source, page, citation)
    |
    v
[4. Generation]
    |-- LLM generates answer grounded in retrieved context
    |-- Include inline citations
    |
    v
Answer with citations
```

## Step 1: Document Ingestion and Chunking

### Chunking Strategies

| Strategy | Description | Best For |
|----------|-------------|----------|
| **Fixed-size** | Split every N characters/tokens | Simple, fast, baseline |
| **Sentence-based** | Split on sentence boundaries | Natural reading units |
| **Paragraph-based** | Split on paragraph breaks | Coherent semantic units |
| **Section-based** | Split on document headings | Academic papers |
| **Recursive** | Hierarchically split (heading > paragraph > sentence) | General purpose |
| **Semantic** | Split on topic shifts using embeddings | Best quality, slower |

### Implementation

```python
from langchain.text_splitter import RecursiveCharacterTextSplitter

def chunk_academic_paper(text, chunk_size=1000, chunk_overlap=200):
    """Chunk an academic paper using recursive splitting."""
    splitter = RecursiveCharacterTextSplitter(
        chunk_size=chunk_size,
        chunk_overlap=chunk_overlap,
        separators=[
            "\n## ",     # H2 headings (section breaks)
            "\n### ",    # H3 headings (subsection breaks)
            "\n\n",      # Paragraph breaks
            "\n",        # Line breaks
            ". ",        # Sentence breaks
            " ",         # Word breaks
        ],
        length_function=len
    )
    chunks = splitter.split_text(text)
    return chunks

# Add metadata to each chunk
def create_documents(paper_text, metadata):
    """Create chunks with source metadata for citation tracking."""
    chunks = chunk_academic_paper(paper_text)
    documents = []
    for i, chunk in enumerate(chunks):
        documents.append({
            "text": chunk,
            "metadata": {
                **metadata,
                "chunk_index": i,
                "chunk_total": len(chunks)
            }
        })
    return documents

# Example usage
docs = create_documents(
    paper_text=extracted_text,
    metadata={
        "title": "Attention Is All You Need",
        "authors": "Vaswani et al.",
        "year": 2017,
        "doi": "10.48550/arXiv.1706.03762",
        "source_file": "vaswani2017attention.pdf"
    }
)
```

## Step 2: Embedding and Indexing

### Embedding Model Selection

| Model | Dimensions | Quality | Speed | Cost |
|-------|-----------|---------|-------|------|
| OpenAI text-embedding-3-small | 1536 | Good | Fast | $0.02/1M tokens |
| OpenAI text-embedding-3-large | 3072 | Excellent | Fast | $0.13/1M tokens |
| Cohere embed-v3 | 1024 | Excellent | Fast | $0.10/1M tokens |
| sentence-transformers/all-MiniLM-L6-v2 | 384 | Good | Very fast | Free (local) |
| BAAI/bge-large-en-v1.5 | 1024 | Excellent | Medium | Free (local) |
| nomic-embed-text | 768 | Good | Fast | Free (local) |

### Vector Database Options

| Database | Type | Scalability | Features |
|----------|------|------------|----------|
| ChromaDB | Embedded | Small-medium | Simple, good for prototyping |
| FAISS | Library | Large | Facebook research, GPU support |
| Pinecone | Cloud | Large | Managed, serverless |
| Weaviate | Self-hosted/Cloud | Large | Hybrid search, filters |
| Qdrant | Self-hosted/Cloud | Large | Rich filtering, payload storage |
| pgvector | PostgreSQL extension | Medium | SQL integration |

### Building the Index

```python
import chromadb
from sentence_transformers import SentenceTransformer

# Initialize embedding model (local, free)
embed_model = SentenceTransformer("BAAI/bge-large-en-v1.5")

# Initialize ChromaDB
client = chromadb.PersistentClient(path="./chroma_db")
collection = client.get_or_create_collection(
    name="research_papers",
    metadata={"hnsw:space": "cosine"}
)

# Index documents
def index_documents(documents):
    """Add documents to the vector database."""
    texts = [doc["text"] for doc in documents]
    embeddings = embed_model.encode(texts, show_progress_bar=True).tolist()
    ids = [f"doc_{i}" for i in range(len(documents))]
    metadatas = [doc["metadata"] for doc in documents]

    collection.add(
        documents=texts,
        embeddings=embeddings,
        metadatas=metadatas,
        ids=ids
    )
    print(f"Indexed {len(documents)} chunks")

index_documents(docs)
```

## Step 3: Retrieval

### Basic Retrieval

```python
def retrieve(query, top_k=5):
    """Retrieve the most relevant chunks for a query."""
    query_embedding = embed_model.encode([query]).tolist()

    results = collection.query(
        query_embeddings=query_embedding,
        n_results=top_k,
        include=["documents", "metadatas", "distances"]
    )

    retrieved = []
    for doc, meta, dist in zip(
        results["documents"][0],
        results["metadatas"][0],
        results["distances"][0]
    ):
        retrieved.append({
            "text": doc,
            "metadata": meta,
            "similarity": 1 - dist  # Convert distance to similarity
        })

    return retrieved

# Example
results = retrieve("What are the main components of the Transformer architecture?")
for r in results:
    print(f"[{r['similarity']:.3f}] {r['metadata'].get('title', 'N/A')}")
    print(f"  {r['text'][:150]}...")
```

### Advanced Retrieval: Hybrid Search

```python
def hybrid_retrieve(query, top_k=5, alpha=0.7):
    """Combine dense (semantic) and sparse (keyword) retrieval."""

    # Dense retrieval (vector similarity)
    dense_results = retrieve(query, top_k=top_k * 2)

    # Sparse retrieval (BM25 keyword matching)
    from rank_bm25 import BM25Okapi

    # Assume all_documents is a list of all chunk texts
    tokenized_corpus = [doc.split() for doc in all_documents]
    bm25 = BM25Okapi(tokenized_corpus)
    bm25_scores = bm25.get_scores(query.split())
    sparse_top_k = bm25_scores.argsort()[-top_k * 2:][::-1]

    # Reciprocal Rank Fusion (RRF)
    rrf_scores = {}
    k = 60  # RRF constant

    for rank, result in enumerate(dense_results):
        doc_id = result["metadata"].get("chunk_index", rank)
        rrf_scores[doc_id] = rrf_scores.get(doc_id, 0) + alpha / (k + rank + 1)

    for rank, idx in enumerate(sparse_top_k):
        rrf_scores[idx] = rrf_scores.get(idx, 0) + (1 - alpha) / (k + rank + 1)

    # Sort by RRF score and return top-k
    sorted_results = sorted(rrf_scores.items(), key=lambda x: x[1], reverse=True)
    return sorted_results[:top_k]
```

## Step 4: Generation with Citations

```python
def generate_answer(query, retrieved_contexts):
    """Generate an answer with inline citations using an LLM."""

    # Build context string with citation markers
    context_parts = []
    for i, ctx in enumerate(retrieved_contexts, 1):
        source = f"{ctx['metadata'].get('authors', 'Unknown')}, {ctx['metadata'].get('year', 'N/A')}"
        context_parts.append(f"[{i}] ({source}): {ctx['text']}")

    context_string = "\n\n".join(context_parts)

    prompt = f"""Based on the following research paper excerpts, answer the question.
Use inline citations like [1], [2] to reference specific sources.
Only use information from the provided excerpts.
If the excerpts do not contain enough information, say so.

EXCERPTS:
{context_string}

QUESTION: {query}

ANSWER (with inline citations):"""

    # Send to LLM (example with OpenAI)
    # response = openai.chat.completions.create(
    #     model="gpt-4",
    #     messages=[{"role": "user", "content": prompt}],
    #     temperature=0.1
    # )
    # return response.choices[0].message.content

    return prompt  # Return prompt for inspection
```

## Evaluation Metrics

| Metric | Measures | Tool |
|--------|----------|------|
| **Retrieval precision** | Are retrieved chunks relevant? | Manual annotation |
| **Retrieval recall** | Are all relevant chunks retrieved? | Known-relevant set |
| **NDCG** | Ranking quality of retrieved results | BEIR benchmark |
| **Answer correctness** | Is the generated answer factually correct? | Human evaluation |
| **Faithfulness** | Does the answer only use information from retrieved context? | RAGAS framework |
| **Answer relevance** | Does the answer address the question? | RAGAS framework |
| **Context relevance** | Are the retrieved contexts relevant to the question? | RAGAS framework |

```python
# Using RAGAS for automated RAG evaluation
from ragas import evaluate
from ragas.metrics import faithfulness, answer_relevancy, context_precision

# Prepare evaluation dataset
eval_data = {
    "question": ["What is the Transformer architecture?"],
    "answer": ["The Transformer uses self-attention mechanisms..."],
    "contexts": [["The Transformer model architecture eschews recurrence..."]],
    "ground_truth": ["The Transformer is a neural network architecture..."]
}

result = evaluate(
    dataset=eval_data,
    metrics=[faithfulness, answer_relevancy, context_precision]
)
print(result)
```

## Best Practices for Academic RAG

1. **Chunk by section**: Academic papers have natural section boundaries. Use them.
2. **Preserve metadata**: Always store title, authors, year, DOI, and page number with each chunk for proper citation.
3. **Use domain-specific embeddings**: Models fine-tuned on scientific text (e.g., SPECTER2) outperform general models for academic content.
4. **Rerank after retrieval**: A cross-encoder reranker significantly improves precision over embedding-only retrieval.
5. **Handle tables and figures**: Extract tables as text or structured data; do not ignore them during chunking.
6. **Evaluate systematically**: Use RAGAS or a custom evaluation set to measure retrieval and generation quality before deploying.

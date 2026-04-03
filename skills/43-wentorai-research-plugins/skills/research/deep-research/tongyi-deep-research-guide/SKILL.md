---
name: tongyi-deep-research-guide
description: "Open-source deep research agent by Alibaba for scholarly research"
metadata:
  openclaw:
    emoji: "🔎"
    category: "research"
    subcategory: "deep-research"
    keywords: ["deep-research", "alibaba", "tongyi", "agentic-rag", "scholarly-search", "open-source"]
    source: "https://github.com/Alibaba-NLP/DeepResearch"
---

# Tongyi Deep Research Guide

## Overview

Tongyi DeepResearch is an open-source deep research agent developed by Alibaba's NLP team, with over 18,000 stars on GitHub. It implements an agentic research pipeline that iteratively searches, reads, reasons, and synthesizes information to produce comprehensive research reports. The system is designed to handle complex, multi-faceted research questions that require gathering evidence from multiple sources and reasoning across diverse information.

Unlike simpler RAG (Retrieval-Augmented Generation) systems that perform a single search-and-answer cycle, DeepResearch uses an iterative approach where the agent dynamically decides what to search next based on what it has already found. This makes it particularly effective for research questions that require building up understanding incrementally, following citation chains, or exploring multiple angles of a topic.

The project is notable for being one of the leading open-source alternatives to proprietary deep research tools. It supports multiple LLM backends, various search APIs, and can be customized for domain-specific research needs. For academic researchers, it offers a transparent and modifiable research pipeline where every step can be inspected, reproduced, and adapted.

## Installation and Setup

```bash
# Clone the repository
git clone https://github.com/Alibaba-NLP/DeepResearch.git
cd DeepResearch

# Install dependencies
pip install -r requirements.txt

# Or install with conda
conda create -n deepresearch python=3.10
conda activate deepresearch
pip install -r requirements.txt
```

Configure your environment for the LLM and search backends:

```bash
# LLM configuration (supports multiple providers)
export LLM_API_KEY=$LLM_API_KEY
export LLM_BASE_URL=$LLM_BASE_URL
export LLM_MODEL=qwen-max

# Search API configuration
export SEARCH_API_KEY=$SEARCH_API_KEY
export SEARCH_ENGINE=bing  # or google, serper, tavily
```

For a fully local deployment with Ollama:

```bash
# Use local models
export LLM_BASE_URL=http://localhost:11434/v1
export LLM_MODEL=qwen2.5:72b
export LLM_API_KEY=ollama
```

## Core Research Pipeline

### The Iterative Research Loop

DeepResearch follows a think-search-read-reflect loop that mimics how a human researcher works:

1. **Think**: Analyze the research question and identify what information is needed
2. **Search**: Formulate search queries and retrieve relevant documents
3. **Read**: Extract and comprehend key information from retrieved documents
4. **Reflect**: Evaluate whether enough information has been gathered or if further research is needed
5. **Synthesize**: Compile findings into a structured, cited report

```python
from deep_research import DeepResearch

# Initialize the research agent
agent = DeepResearch(
    llm_model="qwen-max",
    search_engine="bing",
    max_iterations=10,
    max_sources=30,
)

# Run a research query
result = agent.research(
    query="What are the latest advances in multimodal large language models "
          "and their applications in scientific research?",
    output_format="markdown",
)

print(result.report)
print(f"Sources consulted: {len(result.sources)}")
print(f"Research iterations: {result.iterations}")
```

### Research Configuration

Fine-tune the research behavior for different types of queries:

```python
config = {
    "max_iterations": 15,          # Maximum research cycles
    "max_sources_per_query": 10,   # Sources per search query
    "min_relevance_score": 0.7,    # Minimum source relevance threshold
    "enable_citation_tracking": True,  # Follow citation chains
    "language": "en",              # Output language
    "report_length": "detailed",   # brief, standard, or detailed
}

agent = DeepResearch(config=config)
```

### Supported Search Backends

DeepResearch integrates with multiple search providers to cast a wide net:

- **Bing Search API**: General web search with academic content
- **Google Custom Search**: Configurable search with domain restrictions
- **Tavily**: AI-optimized search API designed for research agents
- **Serper**: Fast Google search results API
- **SearXNG**: Self-hosted meta-search engine for privacy-focused deployments
- **OpenAlex API**: Direct academic paper search (free, no API key required)

```python
# Configure multiple search backends for comprehensive coverage
agent = DeepResearch(
    search_engines=["bing", "openalex"],
    search_strategy="parallel",  # Search all engines simultaneously
)
```

## Advanced Features

### Citation Chain Following

DeepResearch can follow citation chains to discover related work:

```python
result = agent.research(
    query="Foundational papers on attention mechanisms in neural networks",
    enable_citation_tracking=True,
    citation_depth=2,  # Follow citations up to 2 levels deep
)
```

### Domain-Specific Research Profiles

Create research profiles optimized for specific academic domains:

```python
# Biomedical research profile
bio_config = {
    "preferred_sources": ["pubmed", "biorxiv", "nature", "science"],
    "search_engines": ["openalex", "bing"],
    "terminology_mode": "technical",
    "citation_format": "apa",
}

agent = DeepResearch(config=bio_config)
result = agent.research(
    "Recent developments in mRNA vaccine delivery mechanisms"
)
```

### Streaming Progress

Monitor the research process in real-time:

```python
async def stream_research():
    agent = DeepResearch(llm_model="qwen-max")

    async for event in agent.research_stream(
        query="Quantum computing applications in drug discovery"
    ):
        if event.type == "thinking":
            print(f"Thinking: {event.content}")
        elif event.type == "searching":
            print(f"Searching: {event.query}")
        elif event.type == "reading":
            print(f"Reading: {event.url}")
        elif event.type == "report":
            print(f"Final report:\n{event.content}")
```

## Research Workflow Integration

### Combining with Academic Tools

DeepResearch output can be integrated with standard academic tools:

- Export reports as BibTeX-compatible references for LaTeX papers
- Feed results into Zotero or Mendeley for reference management
- Use the structured output as input for systematic review tools
- Combine with local document collections for comprehensive literature coverage

### Reproducibility

Every research session can be fully reproduced:

```python
# Save the complete research trace
result = agent.research(query="...", save_trace=True)
result.save_trace("research_trace.json")

# Replay a research session
replayed = DeepResearch.replay("research_trace.json")
```

The trace includes all search queries, retrieved documents, LLM prompts and responses, and reasoning steps, enabling full transparency and reproducibility of the research process.

## References

- Repository: https://github.com/Alibaba-NLP/DeepResearch
- Qwen model family: https://github.com/QwenLM/Qwen
- Alibaba NLP group: https://github.com/Alibaba-NLP
- OpenAlex API: https://api.openalex.org/

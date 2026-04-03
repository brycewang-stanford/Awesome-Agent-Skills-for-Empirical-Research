---
name: local-deep-research-guide
description: "Deep research agent searching 10+ sources with local or cloud LLMs"
metadata:
  openclaw:
    emoji: "🏠"
    category: "research"
    subcategory: "deep-research"
    keywords: ["local-llm", "deep-research", "multi-source", "ollama", "privacy", "academic-search"]
    source: "https://github.com/LearningCircuit/local-deep-research"
---

# Local Deep Research Guide

## Overview

Local Deep Research is an open-source deep research tool with over 4,000 GitHub stars that conducts comprehensive multi-source research using either local LLMs (via Ollama, LM Studio, or vLLM) or cloud-based models. It searches across 10+ academic and web sources simultaneously, synthesizes the findings, and produces well-cited research reports. The project is designed for researchers who need thorough, multi-perspective research coverage while maintaining the option to keep everything running locally for privacy.

What makes Local Deep Research stand out is its breadth of search integration. Rather than relying on a single search API, it queries multiple sources in parallel -- including Google Scholar, OpenAlex, arXiv, PubMed, Wikipedia, web search engines, and more -- then cross-references and synthesizes the results. This multi-source approach produces more comprehensive and balanced research outputs compared to single-source tools.

The tool is particularly well-suited for academic researchers who need to conduct preliminary literature reviews, verify claims across multiple databases, or explore interdisciplinary topics where relevant work may be scattered across different platforms and publication venues.

## Installation and Setup

```bash
# Install from PyPI
pip install local-deep-research

# Or clone for development
git clone https://github.com/LearningCircuit/local-deep-research.git
cd local-deep-research
pip install -e .
```

### LLM Backend Configuration

Local Deep Research supports multiple LLM backends. Choose the one that fits your privacy and performance requirements:

```bash
# Option 1: Local LLM via Ollama (fully private)
# First, install Ollama: https://ollama.com/
ollama pull llama3.1:70b
export LDR_LLM_PROVIDER=ollama
export LDR_LLM_MODEL=llama3.1:70b

# Option 2: Local LLM via LM Studio
export LDR_LLM_PROVIDER=lmstudio
export LDR_LLM_BASE_URL=http://localhost:1234/v1

# Option 3: Cloud LLM (OpenAI)
export LDR_LLM_PROVIDER=openai
export OPENAI_API_KEY=$OPENAI_API_KEY
export LDR_LLM_MODEL=gpt-4o

# Option 4: Cloud LLM (Anthropic)
export LDR_LLM_PROVIDER=anthropic
export ANTHROPIC_API_KEY=$ANTHROPIC_API_KEY
export LDR_LLM_MODEL=claude-sonnet-4-20250514
```

### Search Source Configuration

Configure which search sources to use:

```bash
# Web search (at least one required)
export SERPER_API_KEY=$SERPER_API_KEY
# Or
export TAVILY_API_KEY=$TAVILY_API_KEY
# Or
export SEARX_URL=http://localhost:8888  # Self-hosted SearXNG

# Academic sources (optional, enhances academic research)
export SEMANTIC_SCHOLAR_API_KEY=$SEMANTIC_SCHOLAR_API_KEY
# PubMed and arXiv require no API keys
```

## Core Research Capabilities

### Running a Research Query

Start a research session from the command line or Python API:

```bash
# Command-line interface
local-deep-research "What are the most effective methods for \
  few-shot learning in NLP as of 2024?"
```

```python
# Python API
from local_deep_research import DeepResearcher

researcher = DeepResearcher(
    llm_provider="ollama",
    llm_model="llama3.1:70b",
    search_sources=["google_scholar", "openalex",
                    "arxiv", "web"],
    max_iterations=10,
)

result = researcher.research(
    "What are the most effective methods for few-shot learning "
    "in NLP as of 2024?"
)

print(result.report)
```

### Multi-Source Search Engine

Local Deep Research queries multiple sources in parallel for each research sub-question:

| Source | Type | API Key Required | Best For |
|--------|------|-----------------|----------|
| Google Scholar | Academic | No (via scraping) | Broad academic search |
| OpenAlex | Academic | No | Cross-disciplinary, citation data |
| arXiv | Academic | No | Preprints, ML/physics/math |
| PubMed | Academic | No | Biomedical literature |
| Wikipedia | Encyclopedia | No | Background and definitions |
| Web Search | General | Yes (Serper/Tavily) | Recent developments |
| SearXNG | Meta-search | Self-hosted | Privacy-focused web search |
| CrossRef | Academic | No | DOI resolution, metadata |
| CORE | Academic | Optional | Open access papers |
| Unpaywall | Academic | No | Open access PDF links |

```python
# Customize source priorities for your research domain
researcher = DeepResearcher(
    search_sources={
        "primary": ["openalex", "arxiv"],
        "secondary": ["google_scholar", "web"],
        "reference": ["wikipedia", "crossref"],
    },
    source_weights={
        "openalex": 1.5,  # Prioritize academic sources
        "arxiv": 1.5,
        "web": 0.8,
    },
)
```

### Research Report Generation

The research pipeline produces structured reports with proper citations:

```python
result = researcher.research(
    "Compare reinforcement learning from human feedback (RLHF) "
    "with direct preference optimization (DPO) for LLM alignment"
)

# The report includes:
# - Executive summary
# - Detailed findings organized by sub-topic
# - Inline citations with source URLs
# - Source bibliography
# - Confidence assessment for each claim

# Save the report
result.save_markdown("rlhf_vs_dpo_report.md")
result.save_html("rlhf_vs_dpo_report.html")
```

## Web Interface

Local Deep Research includes a built-in web interface for interactive research sessions:

```bash
# Start the web UI
local-deep-research --ui

# Or specify host and port
local-deep-research --ui --host 0.0.0.0 --port 5000
```

The web interface provides:

- **Interactive research sessions**: Submit queries and watch the research process in real-time
- **Source inspection**: Click through to original sources for each finding
- **Research history**: Browse and re-examine previous research sessions
- **Report export**: Download reports in markdown, HTML, or PDF format
- **Configuration panel**: Adjust LLM and search settings without editing config files

## Advanced Research Workflows

### Iterative Research with Follow-Up Questions

Build on previous research with follow-up queries:

```python
# Initial research
result1 = researcher.research(
    "Overview of graph neural networks for molecular property prediction"
)

# Follow-up that builds on context from the first query
result2 = researcher.follow_up(
    "Which of these approaches handle 3D molecular geometry?",
    context=result1,
)
```

### Batch Research

Run multiple research queries in batch for systematic investigations:

```python
queries = [
    "Attention mechanisms in protein structure prediction",
    "Graph neural networks for drug-target interaction",
    "Transfer learning approaches in computational chemistry",
    "Benchmarks for molecular property prediction models",
]

results = researcher.batch_research(
    queries,
    parallel=True,
    max_workers=4,
)

# Generate a comparative summary across all queries
summary = researcher.synthesize(results)
```

### Fully Private Research Pipeline

For maximum privacy, run everything locally with no external API calls:

```bash
# Use Ollama for LLM
ollama pull llama3.1:70b

# Use SearXNG for search (self-hosted)
docker run -d --name searxng -p 8888:8080 searxng/searxng

# Configure Local Deep Research
export LDR_LLM_PROVIDER=ollama
export LDR_LLM_MODEL=llama3.1:70b
export SEARX_URL=http://localhost:8888
export LDR_SEARCH_SOURCES=searxng,arxiv,pubmed,wikipedia

# All queries now stay on your local machine
local-deep-research "Your sensitive research query here"
```

## References

- Repository: https://github.com/LearningCircuit/local-deep-research
- Ollama: https://ollama.com/
- SearXNG: https://github.com/searxng/searxng
- OpenAlex API: https://api.openalex.org/
- arXiv API: https://info.arxiv.org/help/api/

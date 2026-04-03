---
name: gpt-researcher-guide
description: "Autonomous agent for comprehensive deep research on any topic"
metadata:
  openclaw:
    emoji: "🔬"
    category: "research"
    subcategory: "deep-research"
    keywords: ["deep-research", "autonomous-agent", "web-search", "report-generation", "literature-review"]
    source: "https://github.com/assafelovic/gpt-researcher"
---

# GPT Researcher Guide

## Overview

GPT Researcher is an autonomous research agent with over 26,000 GitHub stars that conducts comprehensive online research on any given topic. Developed by Assaf Elovic, it generates detailed, factual, and unbiased research reports by planning research questions, searching multiple sources, scraping and filtering relevant content, and synthesizing findings into well-structured reports with citations.

The agent addresses a fundamental challenge in AI-assisted research: generating accurate, comprehensive reports rather than relying on a single LLM's potentially outdated or hallucinated knowledge. GPT Researcher uses a multi-agent architecture where a planner agent decomposes the research query into sub-questions, multiple retriever agents gather information from diverse sources, and a writer agent synthesizes everything into a coherent report.

For academic researchers, GPT Researcher is valuable for conducting preliminary literature surveys, exploring unfamiliar research domains, gathering background information for grant proposals, and generating initial drafts of review sections. The agent can be configured to search specific domains, use academic search engines, and output reports in various formats including markdown and PDF.

## Installation and Setup

```bash
# Install from PyPI
pip install gpt-researcher

# Or clone for development
git clone https://github.com/assafelovic/gpt-researcher.git
cd gpt-researcher
pip install -e .
```

Configure your environment with API keys using environment variables:

```bash
# Required: LLM provider (choose one)
export OPENAI_API_KEY=$OPENAI_API_KEY
# Or use other providers
export ANTHROPIC_API_KEY=$ANTHROPIC_API_KEY

# Required: Search provider (choose one)
export TAVILY_API_KEY=$TAVILY_API_KEY
# Or alternatives
export SERPER_API_KEY=$SERPER_API_KEY
export SEARX_URL=$SEARX_URL
```

For a fully local setup without external API dependencies, you can configure local LLMs and search engines:

```bash
# Use local LLM via Ollama
export OPENAI_BASE_URL=http://localhost:11434/v1
export LLM_PROVIDER=ollama
export FAST_LLM=llama3
export SMART_LLM=llama3

# Use local search via SearXNG
export SEARX_URL=http://localhost:8888
export SEARCH_PROVIDER=searx
```

## Core Research Workflow

### Basic Research Report

Generate a research report with a single function call:

```python
from gpt_researcher import GPTResearcher
import asyncio

async def run_research():
    query = "Recent advances in protein structure prediction using deep learning"
    researcher = GPTResearcher(query=query, report_type="research_report")

    # Conduct research (searches, scrapes, analyzes sources)
    research_result = await researcher.conduct_research()

    # Generate the final report
    report = await researcher.write_report()

    # Access sources used
    sources = researcher.get_source_urls()
    print(f"Report based on {len(sources)} sources")
    print(report)

asyncio.run(run_research())
```

### Report Types

GPT Researcher supports multiple report types tailored to different needs:

- **research_report**: Comprehensive report with findings and analysis (default)
- **detailed_report**: Extended multi-page report with deeper analysis
- **resource_report**: Curated list of sources with summaries and relevance scores
- **outline_report**: Structured outline for further manual research
- **subtopic_report**: Focused report on a specific subtopic within a broader area

```python
# Generate a detailed multi-page report
researcher = GPTResearcher(
    query="Transformer architectures for scientific document understanding",
    report_type="detailed_report",
    max_subtopics=5,
)
```

### Multi-Agent Architecture

The research process follows a sophisticated multi-agent pipeline:

1. **Planner Agent**: Decomposes the research query into 4-6 focused sub-questions
2. **Retriever Agents**: Each sub-question is researched independently by a dedicated agent that searches, scrapes, and filters content
3. **Ranker Agent**: Evaluates and ranks gathered sources by relevance and quality
4. **Writer Agent**: Synthesizes all findings into a coherent, well-structured report with inline citations

```python
# Customize the research configuration
researcher = GPTResearcher(
    query="Impact of climate change on marine biodiversity",
    report_type="research_report",
    source_urls=None,  # Or provide specific URLs to research
    config_path=None,  # Or path to custom config
    max_search_results_per_query=5,
    verbose=True,
)
```

## Advanced Configuration

### Custom Source Restrictions

Restrict research to specific domains or provide seed URLs:

```python
# Research only from specific academic sources
researcher = GPTResearcher(
    query="CRISPR gene editing safety profiles",
    source_urls=[
        "https://pubmed.ncbi.nlm.nih.gov/",
        "https://www.nature.com/",
        "https://www.science.org/",
    ],
)
```

### LLM Configuration

Configure different LLMs for different stages of the research pipeline:

```python
# Use a fast model for planning and a powerful model for writing
# Set via environment variables
# FAST_LLM: Used for sub-question generation and filtering
# SMART_LLM: Used for report synthesis and writing
```

### Integration with FastAPI

GPT Researcher includes a web interface and API server:

```bash
# Start the web UI and API server
cd gpt-researcher
pip install -r requirements.txt
python -m uvicorn main:app --host 0.0.0.0 --port 8000
```

The API exposes WebSocket endpoints for streaming research progress and REST endpoints for report management, making it easy to integrate into existing research platforms.

## Academic Research Applications

GPT Researcher can be adapted for several academic use cases:

- **Preliminary literature surveys**: Quickly scan the landscape of a new research area before conducting a formal systematic review
- **Grant proposal background**: Gather recent developments and state-of-the-art results to strengthen research proposals
- **Conference talk preparation**: Generate comprehensive overviews of related work for presentations
- **Cross-disciplinary exploration**: Investigate adjacent fields to identify potential collaboration opportunities or interdisciplinary approaches
- **Fact-checking and verification**: Cross-reference claims across multiple sources to validate research findings

The reports include full citations with URLs, making it straightforward to verify sources and follow up with deeper reading of primary literature.

## References

- Repository: https://github.com/assafelovic/gpt-researcher
- Documentation: https://docs.gptr.dev/
- Tavily Search API: https://tavily.com/
- Research paper: https://arxiv.org/abs/2305.04091

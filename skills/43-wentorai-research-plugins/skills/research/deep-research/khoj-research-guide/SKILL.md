---
name: khoj-research-guide
description: "AI second brain for deep research and personal knowledge management"
metadata:
  openclaw:
    emoji: "🧠"
    category: "research"
    subcategory: "deep-research"
    keywords: ["second-brain", "knowledge-management", "document-analysis", "rag", "self-hosted", "research-assistant"]
    source: "https://github.com/khoj-ai/khoj"
---

# Khoj Research Guide

## Overview

Khoj is an open-source AI personal research assistant with over 33,000 GitHub stars that acts as a second brain for researchers, students, and knowledge workers. It can search and chat with your personal notes, documents, and the web to help you find information, synthesize knowledge, and conduct deep research. Khoj combines personal knowledge management with AI-powered research capabilities, making it a unique tool for academic researchers who need to work with large collections of papers, notes, and data.

Unlike general-purpose AI assistants, Khoj is designed to work with your own data. It indexes your documents -- including PDFs, markdown files, org-mode notes, plaintext, and images -- and provides an AI interface that can reason over this personal knowledge base alongside web search results. This means you can ask questions that require combining information from your personal research notes with the latest findings from the web.

Khoj supports both cloud-hosted and fully self-hosted deployments. The self-hosted option is particularly attractive for researchers working with sensitive data, unpublished manuscripts, or proprietary datasets that cannot be sent to third-party services. It supports multiple LLM backends including OpenAI, Anthropic, and local models via Ollama.

## Installation and Setup

### Self-Hosted Deployment (Recommended for Researchers)

```bash
# Using Docker (recommended)
docker run -d \
  --name khoj \
  -p 42110:42110 \
  -v ~/.khoj:/root/.khoj \
  ghcr.io/khoj-ai/khoj:latest

# Or using pip
pip install khoj

# Start the server
khoj --host 0.0.0.0 --port 42110
```

### Configuration

After starting Khoj, configure it through the web interface at `http://localhost:42110/config`:

1. **Content sources**: Point Khoj to your document directories
2. **LLM configuration**: Set up your preferred language model backend
3. **Search settings**: Configure web search and document search parameters

```bash
# Set environment variables for LLM access
export OPENAI_API_KEY=$OPENAI_API_KEY
# Or for local models
export OLLAMA_HOST=http://localhost:11434
```

### Client Integrations

Khoj provides clients for multiple platforms to integrate into your existing workflow:

- **Web interface**: Full-featured browser UI at `http://localhost:42110`
- **Obsidian plugin**: Search and chat from within Obsidian
- **Emacs package**: Native integration for Emacs/org-mode users
- **Desktop app**: Cross-platform Electron app
- **WhatsApp/Telegram**: Chat with Khoj via messaging apps

```bash
# Install the Obsidian plugin
# In Obsidian: Settings > Community Plugins > Search "Khoj"
# Configure server URL: http://localhost:42110
```

## Core Research Features

### Document Indexing and Search

Khoj indexes your research documents and makes them searchable using semantic search:

```python
# Supported document types
# - PDF files (research papers, textbooks)
# - Markdown files (notes, drafts)
# - Org-mode files (structured notes)
# - Plaintext files (data, logs)
# - Images (diagrams, figures)
# - GitHub repositories (code, documentation)
# - Notion pages (collaborative notes)

# Configure content sources via the web UI or API
import requests

# Add a document directory
requests.post("http://localhost:42110/api/config/data/source", json={
    "type": "folder",
    "path": "/path/to/research/papers",
    "file_types": ["pdf", "md"],
    "recursive": True,
})
```

### Deep Research Mode

Khoj includes a dedicated research mode that goes beyond simple question-answering. It iteratively searches, reads, and synthesizes information from both your personal knowledge base and the web:

```python
# Trigger deep research via the API
response = requests.post("http://localhost:42110/api/chat", json={
    "q": "Synthesize the key findings from my notes on transformer "
         "efficiency and relate them to recent papers on sparse attention",
    "research_mode": True,
    "max_iterations": 8,
})

# The response includes:
# - Synthesized answer drawing from personal notes and web sources
# - Citations to specific documents and web pages
# - Follow-up questions for further exploration
```

### Conversational Research

Chat with Khoj about your research, and it will draw on your indexed documents:

```
User: What are the main arguments in the papers I've saved about
      few-shot learning?

Khoj: Based on your indexed papers, I found 7 documents related to
      few-shot learning. The main arguments include:
      1. [From paper_x.pdf] Meta-learning approaches...
      2. [From notes/ml-review.md] Prototypical networks...
      ...
```

### Automated Research Agents

Khoj supports automated agents that can perform scheduled research tasks:

```python
# Create a research agent that monitors new papers
requests.post("http://localhost:42110/api/agents", json={
    "name": "paper-monitor",
    "schedule": "daily",
    "task": "Search for new papers on 'graph neural networks for "
            "molecular property prediction' published in the last "
            "24 hours and summarize the key findings",
    "notify": True,
})
```

## Advanced Research Workflows

### Literature Review Pipeline

Use Khoj to build a structured literature review:

1. **Collect**: Index your downloaded papers and notes in Khoj
2. **Explore**: Ask broad questions to understand the landscape
3. **Synthesize**: Request comparative analyses across papers
4. **Identify gaps**: Ask Khoj to find areas where your collection lacks coverage
5. **Expand**: Use web search to find additional papers on identified gaps

### Knowledge Graph Building

Khoj maintains connections between your documents, allowing you to discover relationships:

```
User: What connections exist between my notes on attention mechanisms
      and my notes on computational efficiency?

Khoj: I found several connections:
      - 3 papers discuss efficient attention variants
      - Your notes from 2024-03 mention linear attention
      - The survey paper you saved covers both topics in Section 4
```

### Multi-Modal Research

Khoj can index and reason about images alongside text, which is useful for researchers working with figures, diagrams, and visual data:

- Index experiment result plots and ask questions about trends
- Upload architecture diagrams and ask for explanations
- Search for specific visual patterns across your document collection

## Privacy and Data Sovereignty

For researchers handling sensitive or unpublished data, Khoj offers strong privacy guarantees in self-hosted mode:

- All data stays on your local machine or institutional server
- No telemetry or data sharing with third parties
- Compatible with fully local LLMs via Ollama (no external API calls)
- Encrypted storage for indexed documents
- Fine-grained access controls for multi-user deployments

## References

- Repository: https://github.com/khoj-ai/khoj
- Documentation: https://docs.khoj.dev/
- Obsidian plugin: https://github.com/khoj-ai/khoj/tree/master/src/interface/obsidian
- Self-hosting guide: https://docs.khoj.dev/get-started/setup/

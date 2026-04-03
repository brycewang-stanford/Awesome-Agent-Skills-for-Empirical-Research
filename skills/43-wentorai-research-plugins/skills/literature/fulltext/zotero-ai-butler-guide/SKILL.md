---
name: zotero-ai-butler-guide
description: "AI-powered paper summarization plugin for Zotero"
metadata:
  openclaw:
    emoji: "🤵"
    category: "literature"
    subcategory: "fulltext"
    keywords: ["Zotero", "AI summary", "paper summarization", "LLM", "abstract generation", "reading assistant"]
    source: "https://github.com/steven-jianhao-li/zotero-AI-Butler"
---

# Zotero AI Butler Guide

## Overview

Zotero AI Butler is a Zotero plugin that uses LLMs to summarize, analyze, and annotate academic papers directly within Zotero. It can generate structured summaries, extract key findings, compare papers, and answer questions about documents — all without leaving the reference manager. Supports multiple LLM backends (OpenAI, Claude, local models).

## Installation

```bash
# Download .xpi from GitHub releases
# Zotero 7: Tools → Add-ons → Install Add-on From File
```

## Configuration

```markdown
### LLM Backend Setup (Preferences → AI Butler)

**Option 1: OpenAI**
- Provider: OpenAI
- Model: gpt-4o
- Set environment variable for credentials

**Option 2: Anthropic**
- Provider: Anthropic
- Model: claude-sonnet-4-20250514

**Option 3: Local (Ollama)**
- Provider: Ollama
- Endpoint: http://localhost:11434
- Model: llama3.1

**Option 4: Custom API**
- Provider: Custom
- Endpoint: your-api-url
- Compatible with OpenAI API format
```

## Features

### Paper Summarization

```markdown
### Usage
1. Select paper in Zotero
2. Right-click → AI Butler → Summarize
3. Summary added as Zotero note

### Summary Templates
- **Quick Summary** (1 paragraph): Core contribution + method + result
- **Structured Summary**: Background / Method / Results / Limitations
- **Executive Brief**: Who should read this and why
- **Technical Deep-Dive**: Detailed methodology and math
```

### Key Finding Extraction

```markdown
### Extract structured information:
- **Research question**: What problem does this paper address?
- **Methodology**: What approach do the authors use?
- **Key results**: What are the main findings?
- **Contributions**: What is novel about this work?
- **Limitations**: What are the acknowledged limitations?
- **Future work**: What directions do the authors suggest?
```

### Paper Comparison

```markdown
### Compare multiple papers:
1. Select 2+ papers in Zotero
2. Right-click → AI Butler → Compare Papers
3. Generates comparison table:
   - Shared and unique contributions
   - Methodological differences
   - Performance comparison (if applicable)
   - Complementary insights
```

### Q&A Mode

```markdown
### Ask questions about papers:
1. Open paper in Zotero reader
2. AI Butler sidebar → Ask a question
3. Answers grounded in paper content with page references

Example questions:
- "What loss function do they use?"
- "How does this compare to prior work?"
- "What are the hyperparameters?"
- "Explain equation 3 in simpler terms"
```

## Batch Processing

```markdown
### Summarize multiple papers:
1. Select papers (or entire collection)
2. Right-click → AI Butler → Batch Summarize
3. Progress bar shows completion
4. Each paper gets a summary note attached

### Reading List Generation:
1. Select collection
2. AI Butler → Generate Reading Order
3. Suggests optimal reading sequence based on:
   - Citation relationships
   - Conceptual dependencies
   - Publication chronology
```

## Custom Prompts

```markdown
### Create custom analysis prompts:
# In AI Butler preferences → Custom Prompts

Prompt: "Systematic Review Extraction"
Template: |
  Extract the following from this paper:
  1. Study design (RCT, cohort, etc.)
  2. Sample size
  3. Primary outcome
  4. Effect size with CI
  5. Risk of bias indicators
  Format as structured JSON.
```

## Integration with Zotero Workflow

```markdown
### Combined Plugin Workflow
1. **Zotero Connector** → Import paper
2. **Zotero Sci-Hub** → Fetch PDF
3. **AI Butler** → Generate summary note
4. **Zotero Actions Tags** → Auto-tag based on summary
5. **Notero** → Sync to Notion with summary
6. **Better BibTeX** → Export citations for writing
```

## Use Cases

1. **Rapid screening**: Quick summaries for literature triage
2. **Paper comprehension**: Ask clarifying questions
3. **Comparison studies**: Side-by-side paper analysis
4. **Data extraction**: Structured information for systematic reviews
5. **Reading preparation**: Generate briefings before journal club

## References

- [Zotero AI Butler GitHub](https://github.com/steven-jianhao-li/zotero-AI-Butler)
- [Zotero Plugin Development](https://www.zotero.org/support/dev/client_coding/plugin_development)

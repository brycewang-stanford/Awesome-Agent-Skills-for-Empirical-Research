---
name: npcpy-research-guide
description: "All-in-one Python library for NLP, agents, and knowledge graphs"
metadata:
  openclaw:
    emoji: "🎭"
    category: "domains"
    subcategory: "ai-ml"
    keywords: ["npcpy", "NLP", "agents", "knowledge graph", "all-in-one", "Python library"]
    source: "https://github.com/NPC-Worldwide/npcpy"
---

# npcpy Research Guide

## Overview

npcpy is an all-in-one Python library that combines NLP, agent orchestration, and knowledge graph capabilities in a single package. It provides tools for text processing, entity extraction, agent creation, graph-based reasoning, and research automation. Designed as a Swiss Army knife for AI researchers who need quick access to diverse NLP and agent capabilities without juggling many dependencies.

## Installation

```bash
pip install npcpy
```

## Core Modules

### NLP Processing

```python
from npcpy import NLP

nlp = NLP()

# Text processing pipeline
doc = nlp.process(
    "Transformers have revolutionized NLP since Vaswani et al. "
    "introduced the attention mechanism in 2017."
)

# Named entities
for entity in doc.entities:
    print(f"[{entity.type}] {entity.text}")
# [METHOD] Transformers
# [PERSON] Vaswani
# [CONCEPT] attention mechanism
# [DATE] 2017

# Key phrases
print(doc.key_phrases)
# ["attention mechanism", "Transformers", "NLP"]

# Sentiment / stance
print(doc.sentiment)  # positive
```

### Agent Creation

```python
from npcpy import Agent, Tool

# Create a research agent
agent = Agent(
    name="research_assistant",
    llm_provider="anthropic",
    tools=[
        Tool("web_search", description="Search the web"),
        Tool("paper_search", description="Search academic papers"),
        Tool("calculator", description="Math calculations"),
    ],
)

# Run a task
result = agent.run(
    "Find the top 5 most cited papers on few-shot learning "
    "from 2023 and summarize their approaches."
)
print(result.output)
```

### Knowledge Graphs

```python
from npcpy import KnowledgeGraph

kg = KnowledgeGraph()

# Extract knowledge from text
kg.extract_from_text(
    "BERT uses masked language modeling for pre-training. "
    "GPT uses autoregressive language modeling. "
    "Both are based on the Transformer architecture."
)

# Query the graph
results = kg.query("What models use Transformer architecture?")
# ["BERT", "GPT"]

# Visualize
kg.visualize("knowledge_graph.html")

# Export
kg.export("kg.json")
```

## Research Workflows

```python
from npcpy import ResearchWorkflow

workflow = ResearchWorkflow(llm_provider="anthropic")

# Literature search + synthesis
report = workflow.literature_review(
    topic="prompt engineering techniques",
    num_papers=20,
    synthesis_style="academic",
)
report.save("review.md")

# Paper analysis
analysis = workflow.analyze_paper("paper.pdf")
print(analysis.summary)
print(analysis.methodology)
print(analysis.key_findings)
```

## Use Cases

1. **Quick NLP**: Text processing without heavy setup
2. **Agent prototyping**: Rapid agent creation and testing
3. **Knowledge extraction**: Build KGs from research text
4. **Research automation**: Literature search and synthesis
5. **Teaching**: Demonstrate NLP/agent concepts

## References

- [npcpy GitHub](https://github.com/NPC-Worldwide/npcpy)

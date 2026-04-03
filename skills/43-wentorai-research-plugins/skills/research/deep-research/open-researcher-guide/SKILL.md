---
name: open-researcher-guide
description: "Open pipeline for generating deep research trajectories with LLMs"
metadata:
  openclaw:
    emoji: "🔬"
    category: "research"
    subcategory: "deep-research"
    keywords: ["OpenResearcher", "deep research", "research trajectory", "open pipeline", "literature synthesis", "LLM research"]
    source: "https://github.com/GAIR-NLP/OpenResearcher"
---

# OpenResearcher Guide

## Overview

OpenResearcher is a fully open pipeline for long-horizon deep research trajectory synthesis. It breaks complex research questions into sub-questions, iteratively searches and reads literature, builds internal knowledge representations, and synthesizes comprehensive answers. Unlike single-shot approaches, it models the researcher's thought process — reading, questioning, connecting, and refining understanding over multiple rounds.

## Pipeline Stages

### 1. Question Decomposition

```python
from open_researcher import OpenResearcher

researcher = OpenResearcher(llm_provider="anthropic")

# Complex research question
result = researcher.research(
    "How do retrieval-augmented generation systems handle "
    "knowledge conflicts between parametric and retrieved knowledge, "
    "and what are the current mitigation strategies?"
)

# Automatically decomposes into sub-questions:
# SQ1: What types of knowledge conflicts occur in RAG?
# SQ2: How are conflicts detected?
# SQ3: What resolution strategies exist?
# SQ4: How effective are these strategies?
```

### 2. Iterative Search and Reading

```python
# Each sub-question triggers:
# - Academic search (OpenAlex, arXiv)
# - Paper reading (abstract + key sections)
# - Evidence extraction
# - Follow-up question generation

# Configuration
researcher = OpenResearcher(
    search_backends=["openalex", "arxiv"],
    max_iterations=5,           # Research rounds per sub-question
    papers_per_iteration=10,    # Papers to read per round
    follow_up_questions=True,   # Generate follow-up questions
)
```

### 3. Knowledge Graph Building

```python
# Internally builds a knowledge representation:
# - Claims linked to source papers
# - Relationships between concepts
# - Contradictions flagged

# Access the knowledge graph
kg = result.knowledge_graph
print(f"Concepts: {len(kg.nodes)}")
print(f"Relations: {len(kg.edges)}")
print(f"Contradictions: {len(kg.contradictions)}")
```

### 4. Synthesis and Report

```python
# Multi-section synthesis
report = result.report

# Sections:
# 1. Introduction and scope
# 2. Sub-question answers with evidence
# 3. Cross-cutting themes
# 4. Open questions and future directions
# 5. Full bibliography

report.save("research_report.md")
report.export_bibliography("refs.bib")
```

## Configuration

```python
researcher = OpenResearcher(
    llm_provider="anthropic",
    model="claude-sonnet-4-20250514",
    search_config={
        "backends": ["openalex", "arxiv"],
        "max_results_per_query": 20,
    },
    reading_config={
        "sections": ["abstract", "introduction", "methods", "conclusion"],
        "max_tokens_per_paper": 3000,
    },
    synthesis_config={
        "style": "academic",           # academic, technical, accessible
        "include_contradictions": True,
        "cite_inline": True,
    },
)
```

## Trajectory Inspection

```python
# Inspect the research trajectory
trajectory = result.trajectory

for step in trajectory:
    print(f"Round {step.round}: {step.action}")
    print(f"  Query: {step.query}")
    print(f"  Papers read: {step.papers_read}")
    print(f"  Key findings: {step.findings[:100]}...")
    print(f"  Follow-ups: {step.follow_up_questions}")
```

## Use Cases

1. **Literature surveys**: Comprehensive multi-round research
2. **Research proposals**: Evidence gathering for grant applications
3. **State-of-the-art reports**: Current landscape analysis
4. **Tutorial generation**: Deep topic explanations with citations

## References

- [OpenResearcher GitHub](https://github.com/GAIR-NLP/OpenResearcher)
- [GAIR-NLP Lab](https://github.com/GAIR-NLP)

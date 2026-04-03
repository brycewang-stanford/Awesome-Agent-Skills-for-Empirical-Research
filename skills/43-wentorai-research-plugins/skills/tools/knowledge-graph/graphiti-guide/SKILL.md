---
name: graphiti-guide
description: "Build real-time knowledge graphs for AI agents using Graphiti by Zep"
metadata:
  openclaw:
    emoji: "🕸"
    category: "tools"
    subcategory: "knowledge-graph"
    keywords: ["knowledge-graph", "ai-agents", "temporal-graphs", "neo4j", "memory", "entity-extraction"]
    source: "https://github.com/getzep/graphiti"
---

# Graphiti Guide

## Overview

Graphiti is an open-source framework for building and querying dynamic, temporally-aware knowledge graphs designed specifically for AI agent applications. Developed by Zep, Graphiti enables agents to maintain persistent, structured memory that evolves over time, capturing entities, relationships, and facts extracted from conversational and documentary sources.

Traditional knowledge graphs are static structures that require manual curation and batch updates. Graphiti takes a fundamentally different approach: it incrementally builds and updates the graph in real-time as new information arrives, resolving contradictions, merging duplicate entities, and maintaining temporal metadata that tracks when facts were established and whether they remain current.

For academic researchers, Graphiti offers a powerful framework for constructing domain-specific knowledge graphs from research literature, experimental observations, and collaborative discussions. With over 23,000 GitHub stars, the project has gained significant traction in both the AI engineering and research communities as a practical bridge between unstructured text and structured, queryable knowledge.

## Installation and Setup

Install Graphiti via pip:

```bash
pip install graphiti-core
```

Graphiti requires a Neo4j database for graph storage. Set up Neo4j using Docker:

```bash
docker run -d \
  --name neo4j-graphiti \
  -p 7474:7474 -p 7687:7687 \
  -e NEO4J_AUTH=neo4j/your-password \
  -e NEO4J_PLUGINS='["apoc"]' \
  neo4j:5
```

Configure environment variables for your LLM provider and Neo4j connection:

```bash
export NEO4J_URI=bolt://localhost:7687
export NEO4J_USER=neo4j
export NEO4J_PASSWORD=$NEO4J_PASSWORD
export OPENAI_API_KEY=$OPENAI_API_KEY
```

Initialize Graphiti in your Python project:

```python
from graphiti_core import Graphiti

graphiti = Graphiti(
    neo4j_uri="bolt://localhost:7687",
    neo4j_user="neo4j",
    neo4j_password=$NEO4J_PASSWORD,
)

# Build indices for efficient querying
await graphiti.build_indices()
```

## Core Features

**Incremental Graph Construction**: Add episodes of information that are automatically parsed into entities and relationships:

```python
from graphiti_core.nodes import EpisodeType
from datetime import datetime

# Add a research observation
await graphiti.add_episode(
    name="experiment_log_2026_03_10",
    episode_body="""
    The CRISPR-Cas9 experiment targeting gene BRCA1 in HeLa cells
    showed 87% knockout efficiency. The guide RNA sequence gRNA-42
    was designed using the Benchling platform. Dr. Chen supervised
    the experiment, which used the protocol established in our
    2025 Nature Methods paper.
    """,
    source=EpisodeType.text,
    source_description="Lab notebook entry",
    reference_time=datetime(2026, 3, 10),
)
```

Graphiti automatically extracts entities (BRCA1, HeLa cells, Dr. Chen, gRNA-42, Benchling), establishes relationships (gRNA-42 targets BRCA1, Dr. Chen supervised the experiment), and records temporal metadata.

**Temporal Awareness**: Knowledge graphs built with Graphiti track when facts were established and can reason about changes over time:

```python
# Add an update that modifies a previous fact
await graphiti.add_episode(
    name="experiment_update",
    episode_body="""
    After reanalysis, the CRISPR knockout efficiency for BRCA1
    in HeLa cells was revised to 82% due to off-target effects
    detected in the secondary sequencing run.
    """,
    source=EpisodeType.text,
    source_description="Updated analysis",
    reference_time=datetime(2026, 3, 12),
)
```

The graph updates the efficiency value while maintaining the historical record, enabling queries about both current and historical states of knowledge.

**Semantic Search**: Query the knowledge graph using natural language:

```python
# Search for relevant entities and facts
results = await graphiti.search(
    query="What is the knockout efficiency for BRCA1?",
    num_results=5,
)

for result in results:
    print(f"Fact: {result.fact}")
    print(f"Source: {result.source_description}")
    print(f"Valid from: {result.valid_at}")
    print(f"Confidence: {result.score}")
    print("---")
```

**Entity Resolution**: Graphiti handles duplicate and variant entity references automatically. References to "CRISPR-Cas9", "CRISPR", and "Cas9 system" are resolved to the appropriate entities based on context, reducing manual curation overhead.

## Research Workflow Integration

**Literature Knowledge Base**: Build a continuously growing knowledge graph from your reading notes and paper summaries:

```python
# Process a batch of paper summaries
papers = [
    {
        "title": "Attention Is All You Need",
        "summary": "Vaswani et al. introduced the Transformer architecture...",
        "date": datetime(2017, 6, 12),
    },
    {
        "title": "BERT: Pre-training of Deep Bidirectional Transformers",
        "summary": "Devlin et al. proposed BERT, a masked language model...",
        "date": datetime(2018, 10, 11),
    },
]

for paper in papers:
    await graphiti.add_episode(
        name=paper["title"],
        episode_body=paper["summary"],
        source=EpisodeType.text,
        source_description=f"Paper summary: {paper['title']}",
        reference_time=paper["date"],
    )
```

Then query across your entire reading history to find connections, trace the evolution of ideas, and identify foundational works.

**Experimental Knowledge Management**: Track the relationships between experiments, reagents, instruments, protocols, and personnel. This creates an institutional memory that survives personnel turnover and helps new lab members quickly understand the research context.

**Systematic Review Support**: As you read and annotate papers for a systematic review, feed summaries into Graphiti to build a structured representation of findings, methodologies, and populations studied. Query the resulting graph to identify patterns and gaps.

**Agent Memory for Research Assistants**: Integrate Graphiti as the memory backend for AI research assistants. The agent can accumulate knowledge from each interaction and provide increasingly informed responses:

```python
# Research agent with persistent memory
async def research_agent_step(user_query, conversation_context):
    # Retrieve relevant knowledge
    memories = await graphiti.search(
        query=user_query,
        num_results=10,
    )

    # Include memories in the agent context
    context = format_memories(memories) + conversation_context

    # Generate response using LLM
    response = await generate_response(user_query, context)

    # Store new knowledge from the interaction
    await graphiti.add_episode(
        name=f"conversation_{datetime.now().isoformat()}",
        episode_body=f"User asked: {user_query}\nResponse: {response}",
        source=EpisodeType.message,
        source_description="Research assistant conversation",
        reference_time=datetime.now(),
    )

    return response
```

## Graph Exploration and Maintenance

Access the Neo4j browser at `http://localhost:7474` to visually explore your knowledge graph. Use Cypher queries for advanced exploration:

```cypher
// Find all entities related to a specific gene
MATCH (e:Entity)-[r]-(connected)
WHERE e.name CONTAINS 'BRCA1'
RETURN e, r, connected
LIMIT 50

// Find the most connected entities (research hubs)
MATCH (e:Entity)-[r]-()
RETURN e.name, COUNT(r) AS connections
ORDER BY connections DESC
LIMIT 20
```

Periodically review and clean the graph to maintain quality. Remove incorrectly extracted entities and merge duplicates that automated resolution missed.

## References

- Graphiti repository: https://github.com/getzep/graphiti
- Zep documentation: https://docs.getzep.com/
- Neo4j graph database: https://neo4j.com/
- Temporal knowledge graph concepts in the project documentation

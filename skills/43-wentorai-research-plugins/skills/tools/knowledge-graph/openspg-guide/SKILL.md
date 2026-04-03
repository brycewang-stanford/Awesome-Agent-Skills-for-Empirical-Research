---
name: openspg-guide
description: "Ant Group knowledge graph engine with SPG and KAG framework"
metadata:
  openclaw:
    emoji: "🕸️"
    category: "tools"
    subcategory: "knowledge-graph"
    keywords: ["OpenSPG", "knowledge graph", "SPG", "KAG", "Ant Group", "semantic reasoning"]
    source: "https://github.com/OpenSPG/openspg"
---

# OpenSPG Knowledge Graph Guide

## Overview

OpenSPG is Ant Group's open-source knowledge graph engine based on the Semantic-enhanced Programmable Graph (SPG) framework. It combines property graphs with semantic reasoning, enabling knowledge extraction, representation, reasoning, and question answering. The KAG (Knowledge Augmented Generation) module integrates with LLMs for RAG over knowledge graphs. Suited for building domain-specific knowledge bases for research.

## Installation

```bash
# Docker deployment
git clone https://github.com/OpenSPG/openspg.git
cd openspg
docker-compose up -d

# Python SDK
pip install openspg

# Access KG Studio at http://localhost:8887
```

## Core Concepts

```
SPG Framework
├── Schema Layer (define types and relations)
│   ├── Entity types (Person, Paper, Concept)
│   ├── Properties (typed, constrained)
│   └── Relations (directed, typed edges)
├── Knowledge Layer (populate with data)
│   ├── Entity extraction (NER + linking)
│   ├── Relation extraction
│   └── Property filling
├── Reasoning Layer (infer new knowledge)
│   ├── Rule-based reasoning
│   ├── Statistical reasoning
│   └── LLM-augmented reasoning
└── Application Layer (query and use)
    ├── Graph queries (SPARQL-like)
    ├── Question answering
    └── Knowledge-augmented generation
```

## Schema Definition

```python
from openspg import Schema, EntityType, RelationType

# Define a research knowledge graph schema
schema = Schema("research_kg")

# Entity types
paper = EntityType("Paper", properties={
    "title": "Text",
    "abstract": "Text",
    "year": "Integer",
    "venue": "Text",
    "doi": "Text",
    "citation_count": "Integer",
})

author = EntityType("Author", properties={
    "name": "Text",
    "affiliation": "Text",
    "h_index": "Integer",
})

concept = EntityType("Concept", properties={
    "name": "Text",
    "definition": "Text",
    "domain": "Text",
})

# Relations
schema.add_relation(RelationType(
    "authored_by", source=paper, target=author
))
schema.add_relation(RelationType(
    "cites", source=paper, target=paper
))
schema.add_relation(RelationType(
    "discusses", source=paper, target=concept
))
schema.add_relation(RelationType(
    "related_to", source=concept, target=concept
))

schema.deploy()
```

## Knowledge Population

```python
from openspg import KnowledgeBuilder

builder = KnowledgeBuilder(schema="research_kg")

# Add entities
builder.add_entity("Paper", {
    "title": "Attention Is All You Need",
    "year": 2017,
    "venue": "NeurIPS",
    "doi": "10.48550/arXiv.1706.03762",
})

# Automatic extraction from text
builder.extract_from_text(
    "Vaswani et al. proposed the Transformer architecture "
    "which uses self-attention mechanisms to replace "
    "recurrence. The model achieved state-of-the-art on "
    "WMT 2014 English-to-German translation.",
    entity_types=["Paper", "Author", "Concept"],
    relation_types=["authored_by", "discusses"],
)

# Batch import from structured data
builder.import_csv(
    "papers.csv",
    entity_type="Paper",
    column_mapping={"title": "title", "year": "year"},
)

builder.commit()
```

## KAG: Knowledge-Augmented Generation

```python
from openspg.kag import KAGPipeline

kag = KAGPipeline(
    knowledge_graph="research_kg",
    llm_provider="anthropic",
)

# Question answering over knowledge graph
answer = kag.ask(
    "What are the key papers on attention mechanisms "
    "and how are they related?"
)

print(answer.text)
for source in answer.sources:
    print(f"  [{source.type}] {source.name}: {source.evidence}")

# The KAG pipeline:
# 1. Parses question to identify relevant entities/relations
# 2. Queries knowledge graph for subgraph
# 3. Augments LLM context with structured knowledge
# 4. Generates grounded answer with provenance
```

## Graph Queries

```python
from openspg import GraphQuery

gq = GraphQuery("research_kg")

# Find papers by concept
papers = gq.query("""
    MATCH (p:Paper)-[:discusses]->(c:Concept)
    WHERE c.name = 'self-attention'
    RETURN p.title, p.year, p.citation_count
    ORDER BY p.citation_count DESC
    LIMIT 10
""")

# Find co-author network
coauthors = gq.query("""
    MATCH (a1:Author)<-[:authored_by]-(p:Paper)
          -[:authored_by]->(a2:Author)
    WHERE a1.name = 'Ashish Vaswani'
    RETURN DISTINCT a2.name, COUNT(p) as papers
    ORDER BY papers DESC
""")

# Citation chain
chain = gq.query("""
    MATCH path = (p1:Paper)-[:cites*1..3]->(p2:Paper)
    WHERE p1.title CONTAINS 'GPT-4'
    RETURN path
    LIMIT 20
""")
```

## Use Cases

1. **Research KG**: Build knowledge graphs from paper collections
2. **Literature QA**: Grounded question answering over research
3. **Concept mapping**: Visualize research concept relationships
4. **Citation analysis**: Graph-based citation network analysis
5. **Domain ontology**: Build and maintain domain-specific schemas

## References

- [OpenSPG GitHub](https://github.com/OpenSPG/openspg)
- [KAG Framework](https://github.com/OpenSPG/KAG)
- [SPG White Paper](https://arxiv.org/abs/2302.09560)

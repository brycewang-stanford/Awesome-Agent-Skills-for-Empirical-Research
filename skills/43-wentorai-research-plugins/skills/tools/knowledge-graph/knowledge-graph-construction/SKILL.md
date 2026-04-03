---
name: knowledge-graph-construction
description: "Build research knowledge graphs for literature synthesis and RAG systems"
metadata:
  openclaw:
    emoji: "🗺"
    category: "tools"
    subcategory: "knowledge-graph"
    keywords: ["knowledge graph", "knowledge modeling", "ontology", "RAG", "retrieval augmented generation"]
    source: "N/A"
---

# Knowledge Graph Construction Guide

## Overview

Knowledge graphs (KGs) organize information as networks of entities and relationships, making them powerful tools for research synthesis, literature exploration, and AI-augmented retrieval. In academic contexts, knowledge graphs can represent relationships between papers, authors, methods, datasets, findings, and concepts -- enabling queries like "Which methods have been applied to dataset X?" or "What are the common limitations reported across studies of Y?"

This guide covers building knowledge graphs for research applications: defining schemas (ontologies), extracting entities and relations from text, storing and querying graph data, and integrating knowledge graphs with Retrieval Augmented Generation (RAG) systems for AI-powered research assistants.

Whether you are building a personal research knowledge base, constructing a domain-specific literature graph, or developing a RAG system for an academic chatbot, these patterns provide a solid foundation.

## Knowledge Graph Fundamentals

### Core Components

| Component | Definition | Research Example |
|-----------|-----------|-----------------|
| Entity (Node) | A distinct concept or object | Paper, Author, Method, Dataset |
| Relation (Edge) | A typed connection between entities | "cites", "uses_method", "evaluates_on" |
| Property | An attribute of an entity or relation | Paper.year, Author.affiliation |
| Ontology/Schema | Formal definition of entity and relation types | Research ontology defining valid types |

### Designing a Research Ontology

```yaml
# research_ontology.yaml
entities:
  Paper:
    properties: [title, year, doi, abstract, venue]
  Author:
    properties: [name, affiliation, orcid]
  Method:
    properties: [name, description, category]
  Dataset:
    properties: [name, domain, size, url]
  Finding:
    properties: [description, metric, value, significance]
  Concept:
    properties: [name, definition, domain]

relations:
  CITES:
    from: Paper
    to: Paper
  AUTHORED_BY:
    from: Paper
    to: Author
  USES_METHOD:
    from: Paper
    to: Method
  EVALUATES_ON:
    from: Paper
    to: Dataset
  REPORTS_FINDING:
    from: Paper
    to: Finding
  RELATED_TO:
    from: Concept
    to: Concept
  INTRODUCES:
    from: Paper
    to: Method
```

## Entity and Relation Extraction

### LLM-Based Extraction

Using a large language model to extract structured knowledge from paper abstracts:

```python
import json
from openai import OpenAI

client = OpenAI()

EXTRACTION_PROMPT = """Extract entities and relationships from this research paper abstract.

Return JSON with:
- entities: list of {type, name, properties}
- relations: list of {source, relation, target}

Entity types: Paper, Method, Dataset, Finding, Concept
Relation types: USES_METHOD, EVALUATES_ON, REPORTS_FINDING, RELATED_TO, INTRODUCES

Abstract: {abstract}

Respond ONLY with valid JSON."""

def extract_from_abstract(abstract, paper_title):
    response = client.chat.completions.create(
        model="gpt-4o",
        messages=[
            {"role": "system", "content": "You are a research knowledge extraction system."},
            {"role": "user", "content": EXTRACTION_PROMPT.format(abstract=abstract)}
        ],
        response_format={"type": "json_object"},
        temperature=0
    )

    result = json.loads(response.choices[0].message.content)

    # Add the paper itself as an entity
    result['entities'].insert(0, {
        'type': 'Paper',
        'name': paper_title,
        'properties': {'abstract': abstract[:200]}
    })

    return result
```

### SpaCy + Custom NER for Domain-Specific Extraction

```python
import spacy
from spacy.tokens import Span

nlp = spacy.load("en_core_web_trf")

# Register custom entity types
@spacy.Language.component("research_entities")
def research_entity_component(doc):
    # Pattern-based recognition for methods
    method_patterns = [
        "random forest", "gradient boosting", "neural network",
        "transformer", "attention mechanism", "BERT", "GPT",
        "convolutional", "recurrent", "GAN"
    ]

    new_ents = list(doc.ents)
    for token in doc:
        for pattern in method_patterns:
            if pattern.lower() in doc[token.i:token.i+3].text.lower():
                span = doc.char_span(token.idx, token.idx + len(pattern),
                                     label="METHOD")
                if span and span not in new_ents:
                    new_ents.append(span)
    doc.ents = spacy.util.filter_spans(new_ents)
    return doc

nlp.add_pipe("research_entities", after="ner")
```

## Graph Storage and Querying

### Neo4j (Production)

```python
from neo4j import GraphDatabase

class ResearchGraph:
    def __init__(self, uri, user, password):
        self.driver = GraphDatabase.driver(uri, auth=(user, password))

    def add_paper(self, paper):
        with self.driver.session() as session:
            session.run("""
                MERGE (p:Paper {doi: $doi})
                SET p.title = $title, p.year = $year, p.abstract = $abstract
            """, **paper)

    def add_citation(self, citing_doi, cited_doi):
        with self.driver.session() as session:
            session.run("""
                MATCH (a:Paper {doi: $citing})
                MATCH (b:Paper {doi: $cited})
                MERGE (a)-[:CITES]->(b)
            """, citing=citing_doi, cited=cited_doi)

    def add_method_usage(self, paper_doi, method_name):
        with self.driver.session() as session:
            session.run("""
                MATCH (p:Paper {doi: $doi})
                MERGE (m:Method {name: $method})
                MERGE (p)-[:USES_METHOD]->(m)
            """, doi=paper_doi, method=method_name)

    def find_papers_using_method(self, method_name):
        with self.driver.session() as session:
            result = session.run("""
                MATCH (p:Paper)-[:USES_METHOD]->(m:Method {name: $method})
                RETURN p.title AS title, p.year AS year, p.doi AS doi
                ORDER BY p.year DESC
            """, method=method_name)
            return [dict(record) for record in result]

    def find_common_methods(self, doi1, doi2):
        with self.driver.session() as session:
            result = session.run("""
                MATCH (p1:Paper {doi: $doi1})-[:USES_METHOD]->(m:Method)
                      <-[:USES_METHOD]-(p2:Paper {doi: $doi2})
                RETURN m.name AS method
            """, doi1=doi1, doi2=doi2)
            return [record['method'] for record in result]
```

### NetworkX (Lightweight / Prototyping)

```python
import networkx as nx
import json

def build_research_graph(extracted_data_list):
    """Build a NetworkX graph from extracted paper data."""
    G = nx.MultiDiGraph()

    for data in extracted_data_list:
        for entity in data['entities']:
            G.add_node(
                entity['name'],
                type=entity['type'],
                **entity.get('properties', {})
            )

        for rel in data['relations']:
            G.add_edge(
                rel['source'],
                rel['target'],
                relation=rel['relation']
            )

    return G

# Query the graph
def get_method_landscape(G):
    """Find which methods are most used across papers."""
    methods = [n for n, d in G.nodes(data=True) if d.get('type') == 'Method']
    method_usage = {}
    for method in methods:
        papers = [n for n in G.predecessors(method)
                  if G.nodes[n].get('type') == 'Paper']
        method_usage[method] = len(papers)
    return sorted(method_usage.items(), key=lambda x: x[1], reverse=True)
```

## Knowledge Graph + RAG Integration

Combining knowledge graphs with retrieval augmented generation creates powerful research assistants:

```python
def kg_rag_query(question, graph, embedding_model, llm):
    """Answer a research question using KG-enhanced RAG."""

    # Step 1: Extract entities from the question
    question_entities = extract_entities(question)

    # Step 2: Retrieve relevant subgraph
    subgraph_nodes = set()
    for entity in question_entities:
        if entity in graph:
            # Get 2-hop neighborhood
            neighbors = nx.ego_graph(graph, entity, radius=2)
            subgraph_nodes.update(neighbors.nodes())

    # Step 3: Format context from subgraph
    context_parts = []
    for node in subgraph_nodes:
        node_data = graph.nodes[node]
        edges = list(graph.edges(node, data=True))
        context_parts.append(
            f"{node} ({node_data.get('type', 'Unknown')}): "
            f"{', '.join(f'{e[2].get(\"relation\", \"related_to\")} {e[1]}' for e in edges[:5])}"
        )
    context = '\n'.join(context_parts[:20])

    # Step 4: Generate answer with LLM
    prompt = f"""Based on the following knowledge graph context, answer the question.

Context:
{context}

Question: {question}

Provide a detailed answer citing specific papers, methods, and findings from the context."""

    return llm.generate(prompt)
```

## Best Practices

- **Start with a clear schema.** Define your entity types and relations before extracting data. A schema change later requires re-processing.
- **Use persistent identifiers.** DOIs for papers, ORCIDs for authors, and canonical names for methods prevent duplicate nodes.
- **Validate extracted triples.** LLM extraction is imperfect. Sample and manually verify 5-10% of extractions.
- **Enrich with external data.** Link your KG to OpenAlex, CrossRef, or Wikidata for additional metadata.
- **Version your graph.** Export snapshots regularly and track changes over time.
- **Design queries before building.** Know what questions you want to answer before deciding on the schema.

## References

- [Neo4j Documentation](https://neo4j.com/docs/) -- Graph database
- [NetworkX Documentation](https://networkx.org/) -- Python graph library
- [OpenAlex API](https://docs.openalex.org/) -- Open bibliographic data
- [LlamaIndex Knowledge Graph Guide](https://docs.llamaindex.ai/) -- KG-RAG integration
- [Graphiti](https://github.com/getzep/graphiti) -- Temporal knowledge graph library

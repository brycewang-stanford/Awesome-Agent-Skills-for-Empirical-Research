---
name: ontology-design-guide
description: "Design ontologies and knowledge graphs for research data modeling"
metadata:
  openclaw:
    emoji: "🔗"
    category: "tools"
    subcategory: "knowledge-graph"
    keywords: ["ontology", "knowledge graph", "RDF", "OWL", "semantic web", "data modeling", "linked data"]
    source: "wentor-research-plugins"
---

# Ontology Design Guide

A skill for designing ontologies and knowledge graphs to model research domain knowledge. Covers ontology engineering methodologies, OWL and RDF basics, reusing existing ontologies, and practical tools for building, validating, and querying knowledge graphs.

## What Is an Ontology?

### Definitions and Purpose

```
An ontology is a formal, explicit specification of a shared
conceptualization. In practical terms, it defines:

  - Classes: Categories of things (e.g., Gene, Disease, Drug)
  - Properties: Relationships between things (e.g., causes, treats)
  - Individuals: Specific instances (e.g., TP53, Breast Cancer)
  - Axioms: Rules and constraints (e.g., every Drug has exactly
    one molecular formula)

Purpose in research:
  - Standardize terminology across research groups
  - Enable data integration from heterogeneous sources
  - Support automated reasoning and inference
  - Facilitate knowledge discovery through graph queries
  - Provide machine-readable domain models
```

### Ontology vs. Taxonomy vs. Knowledge Graph

```
Taxonomy:       Hierarchical classification (is-a relationships only)
                Example: Animal > Mammal > Primate > Human

Ontology:       Formal model with classes, properties, and axioms
                Supports reasoning (e.g., if X treats Y and Y is-a Disease,
                then X is a DrugCandidate)

Knowledge Graph: An ontology populated with instance data
                 Millions of triples: (subject, predicate, object)
                 Examples: Wikidata, DBpedia, Google Knowledge Graph
```

## Ontology Engineering Process

### Methodology Overview

```python
def ontology_design_process(domain: str) -> dict:
    """
    Steps for designing a domain ontology.

    Args:
        domain: The research domain to model
    """
    return {
        "step_1_scope": {
            "description": "Define scope and competency questions",
            "questions": [
                "What domain does the ontology cover?",
                "What questions should the ontology be able to answer?",
                "Who will use it and for what purpose?"
            ],
            "example": (
                "Domain: Drug-disease interactions. "
                "Competency question: 'What drugs target proteins "
                "associated with Alzheimer disease?'"
            )
        },
        "step_2_reuse": {
            "description": "Search for existing ontologies to reuse",
            "resources": [
                "BioPortal (bioportal.bioontology.org) -- biomedical ontologies",
                "Linked Open Vocabularies (lov.linkeddata.es) -- general",
                "OBO Foundry (obofoundry.org) -- life sciences",
                "Schema.org -- web-scale vocabulary"
            ]
        },
        "step_3_enumerate": {
            "description": "List key terms, concepts, and relationships",
            "method": "Brainstorm with domain experts; review literature"
        },
        "step_4_model": {
            "description": "Define class hierarchy and properties",
            "tools": ["Protege", "WebVOWL", "TopBraid Composer"]
        },
        "step_5_formalize": {
            "description": "Encode in OWL/RDF with axioms and constraints"
        },
        "step_6_validate": {
            "description": "Test against competency questions and real data",
            "methods": ["SPARQL queries", "Reasoner (HermiT, Pellet)", "Unit tests"]
        },
        "step_7_publish": {
            "description": "Publish with persistent URI and documentation",
            "best_practice": "Use w3id.org or purl.org for persistent identifiers"
        }
    }
```

## RDF and OWL Basics

### RDF Triple Model

```
RDF (Resource Description Framework) represents knowledge as triples:

  (Subject, Predicate, Object)

Examples:
  (:Aspirin, :treats, :Headache)
  (:TP53, rdf:type, :Gene)
  (:TP53, :associatedWith, :BreastCancer)
  (:Aspirin, :hasChemicalFormula, "C9H8O4")

Serialization formats:
  - Turtle (.ttl): Human-readable, most common for authoring
  - JSON-LD (.jsonld): Web-friendly, API-compatible
  - RDF/XML (.rdf): Verbose, legacy format
  - N-Triples (.nt): Simple, good for large datasets
```

### Turtle Syntax Example

```turtle
@prefix : <http://example.org/research#> .
@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> .
@prefix owl: <http://www.w3.org/2002/07/owl#> .

# Classes
:Gene a owl:Class ;
    rdfs:label "Gene" ;
    rdfs:comment "A unit of heredity in a living organism." .

:Disease a owl:Class ;
    rdfs:label "Disease" .

:Drug a owl:Class ;
    rdfs:label "Drug" .

# Properties
:associatedWith a owl:ObjectProperty ;
    rdfs:domain :Gene ;
    rdfs:range :Disease .

:treats a owl:ObjectProperty ;
    rdfs:domain :Drug ;
    rdfs:range :Disease .

# Individuals
:TP53 a :Gene ;
    rdfs:label "TP53" ;
    :associatedWith :BreastCancer .

:BreastCancer a :Disease ;
    rdfs:label "Breast Cancer" .
```

## Querying with SPARQL

### Basic SPARQL Queries

```sparql
# Find all genes associated with Breast Cancer
SELECT ?gene ?geneLabel
WHERE {
  ?gene a :Gene .
  ?gene :associatedWith :BreastCancer .
  ?gene rdfs:label ?geneLabel .
}

# Find drugs that treat diseases associated with gene TP53
SELECT ?drug ?disease
WHERE {
  :TP53 :associatedWith ?disease .
  ?drug :treats ?disease .
}

# Count diseases per gene
SELECT ?gene (COUNT(?disease) AS ?diseaseCount)
WHERE {
  ?gene a :Gene .
  ?gene :associatedWith ?disease .
}
GROUP BY ?gene
ORDER BY DESC(?diseaseCount)
```

## Tools and Software

### Ontology Development

| Tool | Type | Best For |
|------|------|---------|
| Protege | Desktop IDE | Full ontology development and reasoning |
| WebVOWL | Web viewer | Visualizing ontology structure |
| RDFLib (Python) | Library | Programmatic RDF manipulation |
| Apache Jena | Framework | SPARQL endpoint and reasoning |
| Neo4j | Graph database | Property graph modeling (not RDF) |
| Blazegraph/GraphDB | Triplestore | Storing and querying RDF data |

## Design Principles

Follow the FAIR principles (Findable, Accessible, Interoperable, Reusable) when publishing ontologies. Reuse existing terms from established ontologies before creating new ones. Document every class and property with labels, definitions, and examples. Use a reasoner to check logical consistency. Version your ontology and maintain a changelog. Publish both human-readable documentation (HTML) and machine-readable files (OWL/TTL) at a persistent URI.

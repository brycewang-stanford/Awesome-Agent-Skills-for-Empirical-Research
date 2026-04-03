---
name: concept-map-generator
description: "Generate structured concept maps from academic texts automatically"
metadata:
  openclaw:
    emoji: "🧠"
    category: "tools"
    subcategory: "knowledge-graph"
    keywords: ["concept map", "knowledge representation", "text mining", "ontology", "semantic extraction", "mind map"]
    source: "wentor-research-plugins"
---

# Concept Map Generator

A skill for automatically generating structured concept maps from academic texts, lecture notes, and research papers. Covers concept extraction using NLP techniques, relationship identification, hierarchical organization, and export to visual formats. Concept maps differ from mind maps in that they explicitly label relationships between concepts, making them more suitable for representing scientific knowledge.

## Concept Map Fundamentals

### Structure of a Concept Map

A concept map consists of three elements: concepts (nodes), linking phrases (labeled edges), and propositions (concept-link-concept triples that form meaningful statements).

```
Concept Map Elements:

Concept: A perceived regularity or pattern designated by a label.
  Examples: "DNA replication", "enzyme", "natural selection"
  Representation: boxes or ovals containing short noun phrases

Linking Phrase: Words that connect two concepts to form a proposition.
  Examples: "is catalyzed by", "requires", "leads to", "is a type of"
  Representation: labeled arrows between concept nodes

Proposition: A meaningful statement formed by two concepts and a link.
  Example: [DNA replication] --requires--> [DNA polymerase]
  This reads: "DNA replication requires DNA polymerase"

Cross-links: Connections between concepts in different domains or
  branches of the map, showing integrative understanding.
```

### Concept Maps vs Mind Maps

```
Feature            Concept Map           Mind Map
--------------     ------------------    ------------------
Structure          Network (graph)       Tree (hierarchical)
Relationships      Labeled explicitly    Implied by proximity
Root node          May have multiple     Single central topic
Cross-links        Encouraged            Rare
Best for           Deep understanding    Brainstorming
Scientific use     Knowledge modeling    Idea generation
Reading direction  Follow arrow labels   Center outward
```

## Automated Concept Extraction

### NLP Pipeline for Extraction

```python
import spacy

def extract_concepts(text, nlp_model="en_core_web_sm"):
    """
    Extract candidate concepts from academic text using NLP.

    Strategy:
    1. Extract noun phrases as concept candidates
    2. Filter by frequency and specificity
    3. Merge overlapping spans
    4. Rank by TF-IDF relevance
    """
    nlp = spacy.load(nlp_model)
    doc = nlp(text)

    # Extract noun phrases
    candidates = []
    for chunk in doc.noun_chunks:
        # Remove determiners and leading adjectives for cleaner concepts
        clean = chunk.text.strip()
        if len(clean.split()) <= 4:  # Keep manageable length
            candidates.append(clean.lower())

    # Count frequencies
    from collections import Counter
    freq = Counter(candidates)

    # Filter: keep concepts mentioned at least twice
    concepts = [c for c, count in freq.most_common() if count >= 2]

    return concepts
```

### Relationship Extraction

```python
def extract_relationships(text, concepts, nlp_model="en_core_web_sm"):
    """
    Extract relationships between concepts using dependency parsing.

    Identifies verb phrases connecting known concepts in the same sentence.
    """
    nlp = spacy.load(nlp_model)
    doc = nlp(text)
    concept_set = set(concepts)

    triples = []
    for sent in doc.sents:
        sent_text = sent.text.lower()
        # Find which concepts appear in this sentence
        found = [c for c in concept_set if c in sent_text]

        if len(found) >= 2:
            # Extract the verb connecting them
            verbs = [token.lemma_ for token in sent
                     if token.pos_ == "VERB"]
            if verbs:
                for i in range(len(found)):
                    for j in range(i + 1, len(found)):
                        triples.append({
                            "source": found[i],
                            "target": found[j],
                            "relation": verbs[0],
                            "sentence": sent.text
                        })

    return triples
```

## Hierarchical Organization

### Building Concept Hierarchies

Academic concept maps benefit from hierarchical organization, placing the most general, inclusive concepts at the top and progressively more specific concepts below.

```
Hierarchy Construction Algorithm:

1. Identify superordinate concepts:
   - Concepts that appear in titles, abstracts, section headings
   - Concepts with the most outgoing relationships
   - Concepts that subsume other concepts (hypernyms)

2. Identify subordinate concepts:
   - Concepts that are instances or types of superordinates
   - Concepts with high specificity (long noun phrases)
   - Concepts that appear only in methods/results sections

3. Assign levels:
   Level 0: Domain (e.g., "machine learning")
   Level 1: Subdomains (e.g., "supervised learning", "unsupervised learning")
   Level 2: Methods (e.g., "random forests", "k-means clustering")
   Level 3: Details (e.g., "Gini impurity", "elbow method")

4. Add cross-links between branches:
   e.g., "random forests" --uses--> "bootstrap sampling"
         (links supervised learning to statistical methods)
```

### Strategies for Academic Papers

```
Input: Research paper
Output: Concept map organized by paper structure

Section-Based Extraction:
  Introduction -> Key concepts, research questions, theoretical framework
  Methods -> Methodological concepts, tools, techniques, variables
  Results -> Findings, measurements, statistical outcomes
  Discussion -> Interpretations, implications, limitations

Connection Types in Academic Maps:
  "is defined as" - definitional relationships
  "is measured by" - operationalization
  "causes / leads to" - causal relationships
  "is correlated with" - associative relationships
  "is a type of" - taxonomic relationships
  "is part of" - mereological relationships
  "contradicts" - conflicting findings
  "extends" - building on prior work
```

## Export and Visualization

### Output Formats

```python
def export_to_graphml(concepts, relationships, output_path):
    """
    Export concept map to GraphML format for Gephi, yEd, or Cytoscape.
    """
    import networkx as nx

    G = nx.DiGraph()

    for concept in concepts:
        G.add_node(concept, label=concept)

    for rel in relationships:
        G.add_edge(
            rel["source"],
            rel["target"],
            label=rel["relation"]
        )

    nx.write_graphml(G, output_path)
    return output_path


def export_to_cmap(concepts, relationships, output_path):
    """
    Export to CXL format for CmapTools (IHMC).
    CmapTools is the standard concept mapping software in education.
    """
    # CXL is an XML format specific to CmapTools
    header = '<?xml version="1.0" encoding="UTF-8"?>\n'
    header += '<cmap xmlns="http://cmap.ihmc.us/xml/cmap/">\n'

    body = '  <map>\n'
    for i, concept in enumerate(concepts):
        body += f'    <concept id="c{i}" label="{concept}"/>\n'

    for j, rel in enumerate(relationships):
        src_id = concepts.index(rel["source"])
        tgt_id = concepts.index(rel["target"])
        body += (
            f'    <connection id="conn{j}" '
            f'from-id="c{src_id}" to-id="c{tgt_id}" '
            f'label="{rel["relation"]}"/>\n'
        )

    body += '  </map>\n'
    footer = '</cmap>\n'

    with open(output_path, "w") as f:
        f.write(header + body + footer)

    return output_path
```

### Recommended Tools

```
CmapTools (IHMC):
  - Free desktop application specifically designed for concept maps
  - Collaborative editing, cloud hosting
  - Export: CXL, image, PDF, web page
  - Best for: Educational concept maps, collaborative projects

yEd Graph Editor:
  - Free desktop application with auto-layout algorithms
  - Import: GraphML, Excel, CSV
  - Hierarchical, organic, circular layouts
  - Best for: Large concept maps needing automatic layout

Mermaid.js (text-based):
  - Embed concept maps in Markdown documents
  - Version-controllable (plain text)
  - Best for: Documentation, README files, lab notebooks
```

## Quality Criteria for Academic Concept Maps

```
Evaluation Rubric:

Comprehensiveness: Does the map capture the key concepts?
  - All major concepts from the source text should appear
  - No important relationships should be missing

Accuracy: Are the propositions correct?
  - Each concept-link-concept triple should be factually accurate
  - Linking phrases should precisely describe the relationship

Hierarchy: Is the map well-organized?
  - Most general concepts at top, specific at bottom
  - Logical grouping of related concepts

Cross-links: Does the map show integrative understanding?
  - Links between different branches demonstrate deep understanding
  - Cross-links are the most valuable part of a concept map
```

Concept maps serve as both learning tools and knowledge artifacts. In research, they help teams align on shared understanding of complex domains, identify knowledge gaps, and communicate theoretical frameworks to collaborators and reviewers.

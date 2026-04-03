---
name: citation-network-builder
description: "Build and analyze citation networks from academic reference data"
metadata:
  openclaw:
    emoji: "🕸️"
    category: "tools"
    subcategory: "knowledge-graph"
    keywords: ["citation network", "bibliometrics", "graph analysis", "co-citation", "bibliographic coupling", "network visualization"]
    source: "wentor-research-plugins"
---

# Citation Network Builder

A skill for constructing, analyzing, and visualizing citation networks from academic reference data. Covers data collection from bibliographic databases, network construction using direct citation, co-citation, and bibliographic coupling methods, community detection for identifying research clusters, and practical visualization with tools like Gephi, VOSviewer, and Python NetworkX.

## Data Collection and Preparation

### Source Databases

Citation network analysis requires structured bibliographic data with reference lists. The choice of database determines coverage and available metadata.

```
Database Comparison for Citation Analysis:

Web of Science (Clarivate):
  - Format: ISI/WoS plain text, BibTeX, CSV
  - Coverage: ~21,000 journals, back to 1900
  - Strengths: Cited reference data is most complete
  - Limits: 1,000 records per export, subscription required
  - Best for: High-quality citation network analysis

Scopus (Elsevier):
  - Format: CSV, BibTeX, RIS
  - Coverage: ~27,000 journals, back to 1970s for most
  - Strengths: Broader coverage than WoS, author IDs
  - Limits: 2,000 records per export, subscription required
  - Best for: Broader disciplinary coverage

OpenAlex (free):
  - Format: JSON via REST API
  - Coverage: ~250M works, all disciplines
  - Strengths: Free, open, comprehensive, API access
  - Limits: Reference linking less complete than WoS
  - Best for: Large-scale analysis, reproducible research

CrossRef (free):
  - Format: JSON via REST API
  - Coverage: ~150M DOIs across all publishers
  - Strengths: Free, authoritative DOI metadata, reference linking
  - Limits: No abstract text, citation counts may lag
  - Best for: Cross-publisher networks, DOI resolution
```

### Data Cleaning for Network Construction

```python
import pandas as pd

def clean_bibliographic_data(records):
    """
    Clean and deduplicate bibliographic records for network construction.

    Steps:
    1. Standardize DOIs (lowercase, strip prefixes)
    2. Deduplicate by DOI, then by title similarity
    3. Parse reference lists into structured format
    4. Filter records missing key fields
    """
    # Standardize DOIs
    records["doi"] = (
        records["doi"]
        .str.lower()
        .str.replace("https://doi.org/", "", regex=False)
        .str.replace("http://dx.doi.org/", "", regex=False)
        .str.strip()
    )

    # Remove duplicates by DOI
    records = records.drop_duplicates(subset="doi", keep="first")

    # Filter records without references (cannot build citation links)
    records = records[records["references"].notna()]
    records = records[records["references"].str.len() > 0]

    return records
```

## Network Construction Methods

### Direct Citation Network

The simplest approach: paper A cites paper B creates a directed edge from A to B.

```python
import networkx as nx

def build_direct_citation_network(records):
    """
    Build a directed citation network.
    Nodes = papers, Edges = citation relationships.

    Args:
        records: DataFrame with 'doi' and 'references' columns
                 where 'references' is a list of cited DOIs
    Returns:
        NetworkX DiGraph
    """
    G = nx.DiGraph()

    for _, row in records.iterrows():
        citing_doi = row["doi"]
        G.add_node(citing_doi, title=row.get("title", ""),
                   year=row.get("year", None))

        for ref_doi in row["references"]:
            G.add_edge(citing_doi, ref_doi)

    return G
```

### Co-Citation Network

Two papers are co-cited when a third paper cites both. Co-citation strength is the number of papers that cite both. This method identifies intellectual relationships between cited works.

```python
from itertools import combinations
from collections import Counter

def build_cocitation_network(records, min_cocitations=2):
    """
    Build an undirected co-citation network.
    Nodes = cited papers, Edges = co-citation frequency.
    """
    pair_counts = Counter()

    for _, row in records.iterrows():
        refs = sorted(set(row["references"]))
        for a, b in combinations(refs, 2):
            pair_counts[(a, b)] += 1

    G = nx.Graph()
    for (a, b), count in pair_counts.items():
        if count >= min_cocitations:
            G.add_edge(a, b, weight=count)

    return G
```

### Bibliographic Coupling Network

Two papers are bibliographically coupled when they share one or more references. This method groups papers with similar theoretical or methodological foundations.

```python
def build_bibliographic_coupling_network(records, min_shared=3):
    """
    Build an undirected bibliographic coupling network.
    Nodes = citing papers, Edges = number of shared references.
    """
    ref_sets = {}
    for _, row in records.iterrows():
        ref_sets[row["doi"]] = set(row["references"])

    G = nx.Graph()
    dois = list(ref_sets.keys())
    for i in range(len(dois)):
        for j in range(i + 1, len(dois)):
            shared = len(ref_sets[dois[i]] & ref_sets[dois[j]])
            if shared >= min_shared:
                G.add_edge(dois[i], dois[j], weight=shared)

    return G
```

## Network Analysis

### Key Metrics

```
Node-level metrics:
  - In-degree (direct citation): number of times a paper is cited
    -> identifies influential papers
  - Betweenness centrality: how often a node lies on shortest paths
    -> identifies bridging papers connecting subfields
  - PageRank: iterative importance score based on who cites the paper
    -> identifies papers cited by other influential papers

Network-level metrics:
  - Density: proportion of possible edges that exist
  - Clustering coefficient: tendency of nodes to form triangles
  - Average path length: mean shortest path between node pairs
  - Number of connected components: isolated clusters
```

### Community Detection

Community detection algorithms identify clusters of densely connected papers, corresponding to research subfields or intellectual traditions.

```python
import community as community_louvain

def detect_communities(G):
    """
    Detect communities using the Louvain algorithm.
    Returns a dictionary mapping node -> community_id.
    """
    partition = community_louvain.best_partition(G, weight="weight")

    # Summarize communities
    communities = {}
    for node, comm_id in partition.items():
        communities.setdefault(comm_id, []).append(node)

    for comm_id, members in sorted(communities.items()):
        print(f"Community {comm_id}: {len(members)} papers")

    return partition
```

## Visualization

### Tool Recommendations

```
Gephi (desktop application):
  - Best for: Interactive exploration of medium networks (1k-50k nodes)
  - Layout algorithms: ForceAtlas2, Fruchterman-Reingold
  - Export: SVG, PDF, PNG
  - Workflow: Import GEXF/GraphML -> layout -> partition by community
              -> adjust sizes by centrality -> export

VOSviewer (desktop application):
  - Best for: Bibliometric networks specifically
  - Direct import from WoS/Scopus export files
  - Built-in clustering and overlay visualizations
  - Limitation: less customizable than Gephi

Python (matplotlib, pyvis):
  - Best for: Reproducible, scriptable visualizations
  - Use pyvis for interactive HTML network graphs
  - Use matplotlib for static publication-quality figures
```

Citation network analysis provides a quantitative lens on the structure of scientific knowledge, revealing invisible colleges, emerging research fronts, and foundational works that shape entire disciplines.

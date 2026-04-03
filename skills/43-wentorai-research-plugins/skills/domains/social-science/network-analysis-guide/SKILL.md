---
name: network-analysis-guide
description: "Social network analysis methods, metrics, and visualization tools"
metadata:
  openclaw:
    emoji: "🌐"
    category: "domains"
    subcategory: "social-science"
    keywords: ["social network analysis", "graph theory", "centrality", "community detection", "network visualization", "SNA"]
    source: "wentor-research-plugins"
---

# Network Analysis Guide

A skill for conducting social network analysis (SNA) in research contexts. Covers network data collection and representation, key structural metrics (centrality, density, clustering), community detection algorithms, ego network analysis, longitudinal network models, and visualization best practices using Python NetworkX, igraph, and Gephi.

## Network Data Fundamentals

### Representing Network Data

Networks consist of nodes (actors) and edges (relationships). The first decision in any SNA project is how to represent the data.

```
Network data formats:

Edge List (simplest):
  source, target, weight
  Alice, Bob, 3
  Alice, Carol, 1
  Bob, David, 5

Adjacency Matrix (for small networks):
        Alice  Bob  Carol  David
  Alice   0     3    1      0
  Bob     3     0    0      5
  Carol   1     0    0      0
  David   0     5    0      0

Network types:
  Undirected: friendship, co-authorship, physical contact
  Directed: email, citation, following on social media
  Weighted: frequency of interaction, strength of tie
  Bipartite: two types of nodes (e.g., people and events)
  Multiplex: multiple types of edges between same nodes
  Temporal: edges have timestamps or time windows
```

### Data Collection Methods

```
Common SNA data collection approaches:

Survey-based (name generators):
  "List up to 5 people you go to for work advice."
  Advantages: captures subjective relationship perception
  Limitations: recall bias, boundary specification problem
  Best for: organizational networks, personal networks

Archival data:
  Email logs, collaboration records, co-authorship
  Advantages: objective, complete within data boundaries
  Limitations: may not reflect relationship quality
  Best for: large-scale communication networks

Observation:
  Systematic recording of interactions
  Advantages: captures actual behavior
  Limitations: time-intensive, observer effects
  Best for: small groups, classroom networks

Digital trace data:
  Social media follows, retweets, mentions
  Advantages: large-scale, timestamped
  Limitations: platform-specific behavior, not generalizable
  Best for: online community studies

Important considerations:
  - Boundary specification: who is included in the network?
  - Complete vs sampled networks require different methods
  - IRB/ethics approval needed for human subjects research
  - Node anonymization required for publication
```

## Core Network Metrics

### Node-Level Centrality

```python
import networkx as nx

def compute_centrality_measures(G):
    """
    Compute the four classic centrality measures for all nodes.

    Each captures a different dimension of node importance:
    - Degree: connectivity (popular nodes)
    - Betweenness: brokerage (bridge nodes)
    - Closeness: reachability (efficient nodes)
    - Eigenvector: prestige (connected to important nodes)
    """
    centralities = {}

    # Degree centrality: proportion of nodes connected to
    centralities["degree"] = nx.degree_centrality(G)

    # Betweenness: proportion of shortest paths through node
    centralities["betweenness"] = nx.betweenness_centrality(
        G, weight="weight", normalized=True
    )

    # Closeness: inverse of average shortest path to all others
    centralities["closeness"] = nx.closeness_centrality(G)

    # Eigenvector: connected to other high-centrality nodes
    try:
        centralities["eigenvector"] = nx.eigenvector_centrality(
            G, max_iter=1000, weight="weight"
        )
    except nx.PowerIterationFailedConvergence:
        centralities["eigenvector"] = {}

    return centralities
```

### Network-Level Metrics

```python
def compute_network_metrics(G):
    """
    Compute network-level structural properties.
    """
    metrics = {}

    n = G.number_of_nodes()
    m = G.number_of_edges()
    metrics["nodes"] = n
    metrics["edges"] = m

    # Density: actual edges / possible edges
    metrics["density"] = nx.density(G)

    # Average clustering coefficient: transitivity tendency
    metrics["avg_clustering"] = nx.average_clustering(G)

    # Global clustering (transitivity)
    metrics["transitivity"] = nx.transitivity(G)

    # Connected components
    if G.is_directed():
        metrics["weakly_connected_components"] = (
            nx.number_weakly_connected_components(G)
        )
    else:
        metrics["connected_components"] = (
            nx.number_connected_components(G)
        )
        if nx.is_connected(G):
            metrics["diameter"] = nx.diameter(G)
            metrics["avg_shortest_path"] = (
                nx.average_shortest_path_length(G)
            )

    # Degree distribution statistics
    degrees = [d for n, d in G.degree()]
    metrics["avg_degree"] = sum(degrees) / len(degrees)
    metrics["max_degree"] = max(degrees)

    return metrics


def interpret_metrics(metrics):
    """
    Provide interpretive context for network metrics.
    """
    interpretations = []

    if metrics["density"] > 0.5:
        interpretations.append(
            "High density: most actors are connected. "
            "Information spreads quickly but network is "
            "resource-intensive to maintain."
        )
    elif metrics["density"] < 0.1:
        interpretations.append(
            "Low density: sparse connections. Network "
            "may have structural holes and brokerage "
            "opportunities."
        )

    if metrics["avg_clustering"] > 0.5:
        interpretations.append(
            "High clustering: strong tendency to form "
            "closed triads. Indicates group cohesion "
            "and potential echo chambers."
        )

    return interpretations
```

## Community Detection

### Algorithms for Finding Groups

```python
import community as community_louvain

def detect_communities_multiple(G):
    """
    Apply multiple community detection algorithms and compare.
    Different algorithms may reveal different structural patterns.
    """
    results = {}

    # Louvain method (modularity optimization)
    results["louvain"] = community_louvain.best_partition(
        G, weight="weight"
    )
    results["louvain_modularity"] = (
        community_louvain.modularity(results["louvain"], G)
    )

    # Label Propagation (fast, non-deterministic)
    lp_communities = nx.community.label_propagation_communities(G)
    lp_partition = {}
    for i, comm in enumerate(lp_communities):
        for node in comm:
            lp_partition[node] = i
    results["label_propagation"] = lp_partition

    # Girvan-Newman (edge betweenness, slow but interpretable)
    # Only practical for small networks (< 1000 nodes)
    if G.number_of_nodes() < 500:
        gn_communities = nx.community.girvan_newman(G)
        top_level = next(gn_communities)
        gn_partition = {}
        for i, comm in enumerate(top_level):
            for node in comm:
                gn_partition[node] = i
        results["girvan_newman"] = gn_partition

    return results
```

## Ego Network Analysis

### Analyzing Individual Networks

```
Ego network concepts:

Ego: the focal actor
Alters: ego's direct contacts
Ties: connections between alters (not through ego)

Key ego network measures:
  - Size: number of alters
  - Density: proportion of possible alter-alter ties that exist
  - Constraint: Burt's measure of structural holes
    - Low constraint = access to diverse information
    - High constraint = redundant contacts
  - Effective size: size minus redundancy of contacts
  - Ego betweenness: brokerage within the ego network

Research applications:
  - Social support and health outcomes
  - Innovation diffusion and adoption
  - Career success and social capital
  - Information access and decision-making
```

## Visualization Best Practices

### Layout and Design

```
Network visualization guidelines:

Layout algorithms:
  - Force-directed (Fruchterman-Reingold, ForceAtlas2):
    Best for: showing clusters, general structure
    Use when: exploring data, presenting to general audience

  - Circular: Best for: showing connectivity patterns
    Use when: comparing density across groups

  - Hierarchical (Sugiyama): Best for: directed acyclic graphs
    Use when: showing flow or hierarchy

Visual encoding:
  - Node size: proportional to centrality or attribute value
  - Node color: community membership or categorical attribute
  - Edge width: relationship strength or frequency
  - Edge color: relationship type (in multiplex networks)

Publication standards:
  - Use colorblind-friendly palettes
  - Include a legend for all visual encodings
  - Report the layout algorithm used
  - State N (nodes) and M (edges) in the caption
  - For large networks, consider filtering to top-k nodes
  - Provide the network data in supplementary materials

Tools:
  - Gephi: interactive exploration, ForceAtlas2 layout
  - Python pyvis: interactive HTML visualizations
  - R igraph: publication-quality static figures
  - Cytoscape: biological networks, rich plugin ecosystem
```

Social network analysis provides a structural perspective on social phenomena that complements traditional individual-level analyses. By examining patterns of relationships rather than attributes of individuals, SNA reveals how position in a social structure shapes behavior, information access, influence, and outcomes.

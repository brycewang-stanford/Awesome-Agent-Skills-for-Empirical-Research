---
name: network-visualization-guide
description: "Visualize networks, graphs, citation maps, and relational data"
metadata:
  openclaw:
    emoji: "🕸️"
    category: "analysis"
    subcategory: "dataviz"
    keywords: ["network visualization", "graph visualization", "citation network", "NetworkX", "social network", "node-link diagram"]
    source: "wentor-research-plugins"
---

# Network Visualization Guide

A skill for visualizing networks, graphs, and relational data in research. Covers NetworkX for analysis, layout algorithms, publication-quality styling, and tools for citation networks, social networks, and knowledge graphs.

## Network Basics

### When to Use Network Visualization

```
Network visualization is appropriate when your data involves relationships:
  - Citation networks (papers citing other papers)
  - Co-authorship networks (researchers who collaborate)
  - Social networks (individuals connected by interactions)
  - Biological networks (protein interactions, gene regulation)
  - Knowledge graphs (concepts linked by relationships)
  - Trade/flow networks (countries, organizations, resources)
```

### Key Concepts

```
Nodes (vertices): The entities in your network
Edges (links):    The relationships between entities
Directed:         Edges have direction (A -> B)
Undirected:       Edges are bidirectional (A -- B)
Weighted:         Edges have a strength or value
```

## Building Networks with NetworkX

### Creating and Analyzing a Network

```python
import networkx as nx


def build_citation_network(citations: list[tuple]) -> dict:
    """
    Build and analyze a citation network.

    Args:
        citations: List of (citing_paper, cited_paper) tuples
    """
    G = nx.DiGraph()
    G.add_edges_from(citations)

    metrics = {
        "n_nodes": G.number_of_nodes(),
        "n_edges": G.number_of_edges(),
        "density": nx.density(G),
        "most_cited": sorted(
            G.in_degree(), key=lambda x: x[1], reverse=True
        )[:10],
        "most_citing": sorted(
            G.out_degree(), key=lambda x: x[1], reverse=True
        )[:10],
        "connected_components": nx.number_weakly_connected_components(G)
    }

    # PageRank (importance measure)
    pagerank = nx.pagerank(G)
    metrics["top_pagerank"] = sorted(
        pagerank.items(), key=lambda x: x[1], reverse=True
    )[:10]

    return metrics
```

### Visualizing with Matplotlib

```python
import matplotlib.pyplot as plt


def plot_network(G: nx.Graph, layout: str = "spring",
                 node_size_attr: str = None,
                 title: str = "Network") -> None:
    """
    Create a publication-quality network visualization.

    Args:
        G: NetworkX graph object
        layout: Layout algorithm (spring, kamada_kawai, circular, spectral)
        node_size_attr: Node attribute to scale node sizes by
        title: Plot title
    """
    layouts = {
        "spring": nx.spring_layout(G, k=1.5, seed=42),
        "kamada_kawai": nx.kamada_kawai_layout(G),
        "circular": nx.circular_layout(G),
        "spectral": nx.spectral_layout(G)
    }
    pos = layouts.get(layout, nx.spring_layout(G, seed=42))

    # Node sizes based on degree if no attribute specified
    if node_size_attr and nx.get_node_attributes(G, node_size_attr):
        sizes = [G.nodes[n].get(node_size_attr, 10) * 50 for n in G.nodes]
    else:
        degrees = dict(G.degree())
        sizes = [degrees[n] * 50 + 20 for n in G.nodes]

    fig, ax = plt.subplots(figsize=(12, 10))

    nx.draw_networkx_edges(G, pos, alpha=0.2, edge_color="gray", ax=ax)
    nx.draw_networkx_nodes(G, pos, node_size=sizes,
                           node_color="steelblue", alpha=0.7, ax=ax)

    # Label only high-degree nodes
    threshold = sorted(dict(G.degree()).values(), reverse=True)[:10][-1]
    labels = {n: n for n, d in G.degree() if d >= threshold}
    nx.draw_networkx_labels(G, pos, labels, font_size=8, ax=ax)

    ax.set_title(title, fontsize=14)
    ax.axis("off")
    plt.tight_layout()
    plt.savefig("network.pdf", bbox_inches="tight", dpi=300)
```

## Layout Algorithm Selection

### Choosing the Right Layout

| Layout | Best For | Properties |
|--------|---------|------------|
| Spring (Fruchterman-Reingold) | General purpose | Clusters emerge naturally |
| Kamada-Kawai | Small-medium networks | Minimizes edge crossings |
| Circular | Comparing connectivity | All nodes equidistant from center |
| Spectral | Community structure | Based on graph Laplacian eigenvectors |
| Hierarchical (Sugiyama) | DAGs, trees | Top-down layered layout |
| Force Atlas 2 | Large networks | Gravity-based, good for Gephi |

## Specialized Tools

### Beyond Python

```
Gephi:
  - Interactive exploration of large networks
  - Force Atlas 2 layout, community detection
  - Export publication-quality SVG/PDF
  - Best for exploratory analysis

VOSviewer:
  - Bibliometric networks (co-citation, co-authorship)
  - Reads Web of Science and Scopus exports directly
  - Density and overlay visualizations
  - Standard tool in bibliometrics research

Cytoscape:
  - Biological network visualization
  - Extensive plugin ecosystem for bioinformatics
  - Pathway analysis and enrichment

D3.js:
  - Interactive web-based network diagrams
  - Full customization via JavaScript
  - Best for interactive publications
```

## Publication Tips

### Making Networks Readable

```
1. Reduce visual clutter:
   - Filter: Show only edges above a weight threshold
   - Aggregate: Collapse clusters into supernodes
   - Prune: Remove isolates and low-degree nodes

2. Use visual encoding meaningfully:
   - Node size = importance (degree, PageRank, citation count)
   - Node color = community/category
   - Edge width = relationship strength
   - Edge color = relationship type

3. Always include:
   - A legend explaining visual encodings
   - Network statistics (N nodes, M edges, density)
   - Description of the layout algorithm used
   - Scale context (what does a node/edge represent?)
```

For networks with more than 500 nodes, static visualization becomes difficult to read. Consider interactive visualizations for supplementary materials, or show a filtered/aggregated view in the main paper with the full network available online.

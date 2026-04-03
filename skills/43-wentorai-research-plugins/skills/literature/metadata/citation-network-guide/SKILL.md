---
name: citation-network-guide
description: "Analyze citation networks, impact metrics, and bibliometric patterns"
metadata:
  openclaw:
    emoji: "🕸"
    category: "literature"
    subcategory: "metadata"
    keywords: ["citation statistics", "citation tracking", "citation analysis", "citation network", "altmetrics"]
    source: "N/A"
---

# Citation Network Analysis Guide

## Overview

Citation networks encode the intellectual structure of scientific fields. By analyzing who cites whom, how ideas propagate, and where research clusters form, researchers can identify foundational papers, emerging trends, influential authors, and gaps in the literature that represent opportunities for new contributions.

This guide covers the theory and practice of citation network analysis: building networks from bibliographic data, computing standard metrics (h-index, impact factor, PageRank, betweenness centrality), visualizing network structure, and interpreting results. It also covers altmetrics -- alternative impact measures that capture attention beyond traditional citations.

Whether you are conducting a systematic literature review, mapping a new research area, evaluating potential collaborators, or assessing the impact of your own work, citation network analysis provides quantitative tools to complement qualitative judgment.

## Core Concepts

### Types of Citation Networks

| Network Type | Nodes | Edges | Question Answered |
|-------------|-------|-------|-------------------|
| Direct citation | Papers | Paper A cites Paper B | Which papers directly build on each other? |
| Co-citation | Papers | A and B are both cited by C | Which papers are perceived as related? |
| Bibliographic coupling | Papers | A and B both cite C | Which papers share intellectual foundations? |
| Author co-citation | Authors | Two authors are frequently co-cited | Which researchers are seen as working in the same area? |
| Author collaboration | Authors | Two authors co-authored a paper | Who works together? |

### Key Metrics

| Metric | Level | Definition | Interpretation |
|--------|-------|-----------|----------------|
| Citation count | Paper | Number of times cited | Raw impact |
| h-index | Author | h papers with >= h citations | Sustained productivity |
| Impact Factor | Journal | Mean citations to recent articles | Journal prestige |
| PageRank | Paper/Author | Iterative importance based on network position | Influence (weighted by citing paper importance) |
| Betweenness centrality | Paper | Frequency on shortest paths between other nodes | Bridging role between subfields |
| Burst detection | Paper/Term | Sudden increase in citations/usage | Emerging topic |

## Building Citation Networks

### Data Sources

| Source | Coverage | API | Cost |
|--------|----------|-----|------|
| OpenAlex | 250M+ works, all disciplines | REST API, free | Free (no key required) |
| OpenAlex | 250M+ works, all disciplines | REST API, free | Free |
| Crossref | 140M+ DOIs | REST API | Free |
| Web of Science | Curated, multi-disciplinary | Institutional | Licensed |
| Scopus | 90M+ records | REST API | Licensed |

### Fetching Data with OpenAlex

```python
import requests
import networkx as nx

def get_citations(doi, max_results=100):
    """Fetch papers that cite a given DOI using OpenAlex."""
    work_url = f"https://api.openalex.org/works/doi:{doi}"
    resp = requests.get(work_url)
    work = resp.json()
    openalex_id = work['id']

    # Get citing works
    citing_url = (
        f"https://api.openalex.org/works"
        f"?filter=cites:{openalex_id}"
        f"&per_page={max_results}"
        f"&sort=cited_by_count:desc"
    )
    citing_resp = requests.get(citing_url)
    citing_works = citing_resp.json()['results']

    return [{
        'id': w['id'],
        'title': w['title'],
        'year': w['publication_year'],
        'cited_by_count': w['cited_by_count'],
        'authors': [a['author']['display_name']
                    for a in w.get('authorships', [])]
    } for w in citing_works]
```

### Building the Network with NetworkX

```python
import networkx as nx

def build_citation_network(seed_doi, depth=2):
    """Build a citation network to specified depth from a seed paper."""
    G = nx.DiGraph()
    visited = set()
    queue = [(seed_doi, 0)]

    while queue:
        doi, level = queue.pop(0)
        if doi in visited or level > depth:
            continue
        visited.add(doi)

        citations = get_citations(doi, max_results=20)
        for paper in citations:
            G.add_node(paper['id'],
                       title=paper['title'],
                       year=paper['year'],
                       citations=paper['cited_by_count'])
            G.add_edge(paper['id'], doi)  # citing -> cited

            if level + 1 <= depth:
                queue.append((paper['id'], level + 1))

    return G

# Build and analyze
G = build_citation_network("10.1234/example", depth=2)
print(f"Nodes: {G.number_of_nodes()}, Edges: {G.number_of_edges()}")
```

## Network Analysis

### Computing Centrality Metrics

```python
# PageRank (most important papers in the network)
pagerank = nx.pagerank(G, alpha=0.85)
top_papers = sorted(pagerank.items(), key=lambda x: x[1], reverse=True)[:10]

for paper_id, score in top_papers:
    title = G.nodes[paper_id].get('title', 'Unknown')
    print(f"  PR={score:.4f}: {title[:80]}")

# Betweenness centrality (bridge papers)
betweenness = nx.betweenness_centrality(G)
bridges = sorted(betweenness.items(), key=lambda x: x[1], reverse=True)[:10]

# Community detection (research clusters)
from networkx.algorithms.community import greedy_modularity_communities
communities = list(greedy_modularity_communities(G.to_undirected()))
print(f"Detected {len(communities)} research clusters")
```

### Co-Citation Analysis

```python
def build_cocitation_network(papers_with_refs):
    """Build co-citation network from papers with their reference lists."""
    from itertools import combinations
    G = nx.Graph()

    for paper in papers_with_refs:
        refs = paper['references']
        for a, b in combinations(refs, 2):
            if G.has_edge(a, b):
                G[a][b]['weight'] += 1
            else:
                G.add_edge(a, b, weight=1)

    return G
```

## Visualization

### Using pyvis for Interactive Visualization

```python
from pyvis.network import Network

def visualize_citation_network(G, output='citation_network.html'):
    net = Network(height='800px', width='100%', directed=True)

    for node in G.nodes():
        title = G.nodes[node].get('title', str(node))[:60]
        size = min(5 + G.nodes[node].get('citations', 0) * 0.1, 40)
        net.add_node(str(node), label=title, size=size,
                     title=G.nodes[node].get('title', ''))

    for u, v in G.edges():
        net.add_edge(str(u), str(v))

    net.set_options("""
    var options = {
      "physics": {"barnesHut": {"gravitationalConstant": -3000}},
      "nodes": {"font": {"size": 10}}
    }
    """)
    net.save_graph(output)
    print(f"Saved to {output}")
```

### Using VOSviewer

VOSviewer is a dedicated bibliometric visualization tool:

1. Export records from Web of Science or Scopus in CSV format.
2. Open VOSviewer and select "Create a map based on bibliographic data."
3. Choose analysis type: co-citation, bibliographic coupling, or co-authorship.
4. Adjust parameters (minimum citations, cluster resolution).
5. Export high-resolution images for publications.

## Altmetrics

Traditional citations take years to accumulate. Altmetrics capture immediate attention:

| Metric | Source | Speed | What It Measures |
|--------|--------|-------|-----------------|
| Altmetric Attention Score | altmetric.com | Hours | Media, social, policy mentions |
| PlumX metrics | Elsevier | Days | Usage, captures, mentions, social |
| Downloads | Publisher | Immediate | Reader interest |
| Twitter/X mentions | Social media | Immediate | Public discourse |
| Wikipedia citations | Wikipedia | Weeks | Encyclopedic significance |
| Policy document citations | Overton | Months | Policy relevance |

## Best Practices

- **Combine multiple data sources.** No single database has complete coverage. Merge OpenAlex and CrossRef for best results.
- **Normalize by field and age.** A 2024 paper in biology and a 2024 paper in mathematics have very different citation rate baselines.
- **Use relative indicators.** Field-Weighted Citation Impact (FWCI) accounts for disciplinary differences.
- **Do not equate citations with quality.** Retracted papers sometimes have high citation counts. Controversial papers accumulate criticism citations.
- **Report network metrics alongside standard citations.** PageRank and betweenness reveal influence that raw counts miss.
- **Update analyses periodically.** Citation networks change as new papers are published.

## References

- [OpenAlex API](https://docs.openalex.org/) -- Free, open bibliographic data
- [CrossRef API](https://api.crossref.org/) -- DOI resolution and metadata
- [VOSviewer](https://www.vosviewer.com/) -- Bibliometric visualization tool
- [bibliometrix R package](https://www.bibliometrix.org/) -- Comprehensive bibliometric analysis
- [Altmetric](https://www.altmetric.com/) -- Alternative impact metrics
- [NetworkX Documentation](https://networkx.org/) -- Python graph analysis library

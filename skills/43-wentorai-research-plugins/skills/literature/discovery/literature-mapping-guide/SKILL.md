---
name: literature-mapping-guide
description: "Visual literature mapping and connected papers exploration"
metadata:
  openclaw:
    emoji: "🗺️"
    category: "literature"
    subcategory: "discovery"
    keywords: ["literature map", "reference graph", "citation network", "related papers"]
    source: "wentor-research-plugins"
---

# Literature Mapping Guide

Build visual maps of scholarly literature to understand research landscapes, identify clusters of related work, and discover hidden connections between papers.

## What Is Literature Mapping?

Literature mapping transforms flat lists of papers into interactive visual networks where nodes represent papers and edges represent citation or similarity relationships. This approach helps researchers:

- See the overall structure of a research field at a glance
- Identify seminal papers (highly connected nodes)
- Discover clusters and subfields
- Find bridging papers that connect disparate areas
- Spot gaps where no papers exist

## Tools for Visual Literature Mapping

### Connected Papers

Connected Papers (connectedpapers.com) builds a similarity graph around a seed paper using co-citation and bibliographic coupling analysis.

| Feature | Details |
|---------|---------|
| Input | Paper title, DOI, or URL |
| Graph type | Similarity (not direct citation) |
| Node size | Citation count |
| Node color | Publication year (darker = older) |
| Max nodes | ~40 per graph |
| Cost | Free: 5 graphs/month; Premium: unlimited |

How to use:
1. Enter a seed paper URL or title
2. The tool builds a graph of the most similar papers (regardless of direct citation links)
3. Click any node to see its abstract and bibliographic details
4. Use "Prior works" to find foundational papers and "Derivative works" for recent developments
5. Export the graph or paper list as BibTeX

### Litmaps

Litmaps (litmaps.com) creates dynamic, multi-seed citation maps that update as new papers are published.

Workflow:
1. Add one or more seed papers via DOI, title, or OpenAlex ID
2. The tool builds a citation graph showing how the papers are connected
3. Add "discover" nodes to expand the map with algorithmically suggested papers
4. Create "collections" to organize maps by topic
5. Set up alerts for new papers that connect to your existing map

### VOSviewer

VOSviewer (vosviewer.com) is a free desktop tool for constructing and visualizing bibliometric networks at scale.

```
# VOSviewer supports several network types:
# - Co-authorship networks
# - Co-citation networks
# - Bibliographic coupling networks
# - Co-occurrence of keywords
# - Citation networks

# Input formats:
# - Web of Science export files
# - Scopus CSV exports
# - Dimensions export files
# - RIS files from reference managers
# - CrossRef API queries (built-in)
```

Steps for VOSviewer analysis:
1. Export search results from Web of Science or Scopus (include cited references)
2. Open VOSviewer and select "Create a map based on bibliographic data"
3. Choose analysis type (e.g., co-citation of cited references)
4. Set thresholds (e.g., minimum 5 citations for a reference to appear)
5. VOSviewer automatically clusters nodes and applies colors
6. Explore clusters to understand subfield structure

### CiteSpace

CiteSpace (citespace.podia.com) specializes in detecting research fronts and intellectual turning points.

Key features:
- Burst detection: identifies keywords or references with sudden spikes in frequency
- Timeline visualization: shows how clusters evolve over time
- Betweenness centrality: highlights bridging papers between clusters
- Requires Java; works with Web of Science data exports

## Building a Custom Literature Map with Python

```python
import networkx as nx
import requests
from collections import defaultdict

def build_citation_graph(seed_ids, depth=1, max_per_level=20):
    """Build a directed citation graph from seed papers."""
    G = nx.DiGraph()
    visited = set()
    queue = [(sid, 0) for sid in seed_ids]

    while queue:
        paper_id, level = queue.pop(0)
        if paper_id in visited or level > depth:
            continue
        visited.add(paper_id)

        # Get paper metadata
        meta_resp = requests.get(
            f"https://api.semanticscholar.org/graph/v1/paper/{paper_id}",
            params={"fields": "title,year,citationCount"}
        )
        if meta_resp.status_code != 200:
            continue
        meta = meta_resp.json()
        G.add_node(paper_id, title=meta.get("title", ""),
                   year=meta.get("year"), citations=meta.get("citationCount", 0))

        # Get references (backward)
        refs_resp = requests.get(
            f"https://api.semanticscholar.org/graph/v1/paper/{paper_id}/references",
            params={"fields": "title,year,citationCount", "limit": max_per_level}
        )
        if refs_resp.status_code == 200:
            for ref in refs_resp.json().get("data", []):
                cited = ref["citedPaper"]
                if cited.get("paperId"):
                    G.add_node(cited["paperId"], title=cited.get("title", ""),
                               year=cited.get("year"), citations=cited.get("citationCount", 0))
                    G.add_edge(paper_id, cited["paperId"], relation="cites")
                    if level < depth:
                        queue.append((cited["paperId"], level + 1))

    return G

# Build graph from 2 seed papers
seeds = ["DOI:10.1038/s41586-021-03819-2", "ARXIV:2005.14165"]
graph = build_citation_graph(seeds, depth=1, max_per_level=15)
print(f"Graph: {graph.number_of_nodes()} nodes, {graph.number_of_edges()} edges")

# Find most central papers
centrality = nx.betweenness_centrality(graph)
top_central = sorted(centrality.items(), key=lambda x: x[1], reverse=True)[:10]
for node_id, score in top_central:
    title = graph.nodes[node_id].get("title", "Unknown")
    print(f"  Centrality={score:.3f}: {title}")
```

## Interpreting Literature Maps

| Visual Feature | Interpretation |
|---------------|---------------|
| Large cluster | Established subfield with many related papers |
| Small isolated cluster | Emerging or niche research area |
| Bridge node between clusters | Interdisciplinary or foundational paper |
| Dense interconnections | Mature area with extensive cross-referencing |
| Sparse area between clusters | Potential research gap or opportunity |
| Temporal gradient (old to new) | Evolution of ideas over time |

## Best Practices

1. **Start with multiple seeds**: Using 3-5 seed papers from different angles gives better coverage than a single seed.
2. **Combine tools**: Use Connected Papers for quick exploration, VOSviewer for large-scale analysis, and custom scripts for specific analyses.
3. **Iterate**: Literature mapping is not a one-shot process. Refine your seeds and parameters based on initial results.
4. **Export and annotate**: Save your maps and annotate clusters with descriptive labels for use in literature review sections.
5. **Check boundaries**: If your map only shows papers from one group or country, broaden your seeds to capture different perspectives.

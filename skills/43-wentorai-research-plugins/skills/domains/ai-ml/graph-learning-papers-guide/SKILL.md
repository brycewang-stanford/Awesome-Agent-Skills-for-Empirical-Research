---
name: graph-learning-papers-guide
description: "Conference papers on graph neural networks and graph learning"
metadata:
  openclaw:
    emoji: "📊"
    category: "domains"
    subcategory: "ai-ml"
    keywords: ["graph neural network", "GNN", "graph learning", "graph transformer", "message passing", "node classification"]
    source: "https://github.com/doujiang-zheng/Awesome-Graph-Learning-Papers-List"
---

# Graph Learning Papers Guide

## Overview

A curated list of graph learning papers from top AI/ML conferences (NeurIPS, ICML, ICLR, KDD, WWW, AAAI). Covers graph neural networks, graph transformers, spectral methods, message passing, and applications in molecular science, social networks, and recommendation systems. Organized by venue, year, and topic for systematic tracking.

## Topic Taxonomy

```
Graph Learning
├── Graph Neural Networks
│   ├── Message Passing (GCN, GAT, GraphSAGE, GIN)
│   ├── Spectral (ChebNet, CayleyNet)
│   ├── Graph Transformers (Graphormer, GPS)
│   └── Equivariant GNNs (EGNN, SE(3)-Transformers)
├── Graph Generation
│   ├── VAE-based (GraphVAE)
│   ├── Autoregressive (GraphRNN)
│   ├── Diffusion (GDSS, DiGress)
│   └── Flow-based (GraphFlow)
├── Self-supervised Learning
│   ├── Contrastive (GraphCL, GCA)
│   ├── Generative (GraphMAE)
│   └── Predictive (GPT-GNN)
├── Scalability
│   ├── Sampling (GraphSAINT, ClusterGCN)
│   ├── Knowledge distillation
│   └── Graph condensation
├── Temporal Graphs
│   ├── Dynamic GNNs
│   ├── Temporal interaction
│   └── Evolving graphs
└── Applications
    ├── Molecular property prediction
    ├── Drug discovery
    ├── Social network analysis
    ├── Recommendation systems
    └── Traffic forecasting
```

## Key Models

| Model | Year | Innovation |
|-------|------|-----------|
| **GCN** | 2017 | Spectral convolution simplified |
| **GraphSAGE** | 2017 | Inductive with sampling |
| **GAT** | 2018 | Attention over neighbors |
| **GIN** | 2019 | WL-test as powerful as possible |
| **Graphormer** | 2021 | Transformer on graphs |
| **GPS** | 2022 | General, powerful, scalable recipe |
| **GraphMAE** | 2022 | Masked autoencoding on graphs |

## Paper Search

```python
import arxiv

def find_gnn_papers(topic="graph neural network", max_results=20):
    """Find recent GNN papers."""
    search = arxiv.Search(
        query=f"abs:{topic}",
        max_results=max_results,
        sort_by=arxiv.SortCriterion.SubmittedDate,
    )

    for r in search.results():
        print(f"[{r.published.strftime('%Y-%m-%d')}] {r.title}")

find_gnn_papers("graph transformer")
find_gnn_papers("molecular graph generation")
```

## Benchmark Datasets

```python
datasets = {
    "Node Classification": {
        "Cora": "Citation network, 7 classes",
        "PubMed": "Medical citation, 3 classes",
        "ogbn-arxiv": "arXiv papers, 40 classes",
        "ogbn-papers100M": "100M papers (large-scale)",
    },
    "Graph Classification": {
        "ZINC": "Molecular graphs, regression",
        "ogbg-molpcba": "128 molecular tasks",
        "PROTEINS": "Protein function prediction",
    },
    "Link Prediction": {
        "ogbl-collab": "Author collaborations",
        "ogbl-citation2": "Citation prediction",
    },
}

for task, ds in datasets.items():
    print(f"\n{task}:")
    for name, desc in ds.items():
        print(f"  {name}: {desc}")
```

## Use Cases

1. **Literature survey**: Track GNN research across top venues
2. **Method comparison**: Compare GNN architectures and results
3. **Research planning**: Identify trends and open problems
4. **Course preparation**: Curate reading lists for GNN courses
5. **Benchmark tracking**: Monitor SOTA on OGB leaderboards

## References

- [Awesome-Graph-Learning-Papers-List](https://github.com/doujiang-zheng/Awesome-Graph-Learning-Papers-List)
- [Open Graph Benchmark](https://ogb.stanford.edu/)
- [PyG (PyTorch Geometric)](https://pyg.org/)
- [DGL (Deep Graph Library)](https://www.dgl.ai/)

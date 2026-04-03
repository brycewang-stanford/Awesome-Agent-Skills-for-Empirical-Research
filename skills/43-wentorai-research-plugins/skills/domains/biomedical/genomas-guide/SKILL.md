---
name: genomas-guide
description: "Automate gene expression analysis with the GenoMAS multi-agent system"
metadata:
  openclaw:
    emoji: "🧬"
    category: "domains"
    subcategory: "biomedical"
    keywords: ["GenoMAS", "gene expression", "multi-agent", "bioinformatics", "RNA-seq", "genomics automation"]
    source: "wentor-research-plugins"
---

# GenoMAS Guide

## Overview

GenoMAS (Genomics Multi-Agent System) is a minimalist multi-agent framework for automating scientific analysis workflows, particularly gene expression analysis. It orchestrates specialized agents for data retrieval, preprocessing, differential expression analysis, pathway enrichment, and visualization — turning a natural language research question into a complete bioinformatics pipeline.

## Installation

```bash
pip install genomas
# Or from source
git clone https://github.com/futianfan/GenoMAS.git
cd GenoMAS && pip install -e .
```

## Core Workflow

### Natural Language to Pipeline

```python
from genomas import GenoMAS

geno = GenoMAS(llm_provider="anthropic")

# Describe analysis in natural language
result = geno.analyze(
    "Compare gene expression between tumor and normal tissue "
    "in the TCGA breast cancer dataset. Identify differentially "
    "expressed genes and run pathway enrichment analysis."
)

# GenoMAS automatically:
# 1. Retrieves TCGA-BRCA data via GDC API
# 2. Normalizes and filters expression data
# 3. Runs DESeq2-style differential expression
# 4. Performs GO and KEGG pathway enrichment
# 5. Generates volcano plots and heatmaps
```

### Agent Roles

| Agent | Responsibility |
|-------|---------------|
| **Data Agent** | Retrieves datasets from GEO, TCGA, ArrayExpress |
| **Preprocessing Agent** | Quality control, normalization, filtering |
| **Analysis Agent** | Differential expression, clustering, PCA |
| **Enrichment Agent** | GO, KEGG, MSigDB pathway analysis |
| **Visualization Agent** | Plots, heatmaps, volcano plots |
| **Report Agent** | Generates methods section and results summary |

### Step-by-Step Usage

```python
from genomas import DataAgent, AnalysisAgent, EnrichmentAgent

# Step 1: Retrieve data
data_agent = DataAgent()
dataset = data_agent.fetch("GSE12345", platform="RNA-seq")

# Step 2: Differential expression
analysis = AnalysisAgent()
de_results = analysis.differential_expression(
    dataset,
    group_col="condition",
    case="tumor",
    control="normal",
    method="deseq2",
)

# Step 3: Filter significant genes
sig_genes = de_results[
    (de_results["padj"] < 0.05) &
    (abs(de_results["log2FoldChange"]) > 1)
]
print(f"Found {len(sig_genes)} differentially expressed genes")

# Step 4: Pathway enrichment
enrichment = EnrichmentAgent()
pathways = enrichment.run(
    gene_list=sig_genes["gene_symbol"].tolist(),
    databases=["GO_BP", "KEGG", "Reactome"],
)

# Step 5: Visualize
from genomas.viz import volcano_plot, pathway_barplot
volcano_plot(de_results, output="volcano.png")
pathway_barplot(pathways, top_n=20, output="pathways.png")
```

## Supported Analyses

| Analysis | Method |
|----------|--------|
| Differential expression | DESeq2, edgeR, limma-voom |
| Clustering | Hierarchical, k-means, UMAP |
| PCA | Principal component analysis |
| GO enrichment | Gene Ontology term enrichment |
| KEGG pathway | KEGG pathway mapping |
| GSEA | Gene Set Enrichment Analysis |
| Survival analysis | Kaplan-Meier, Cox regression |

## Data Sources

| Source | Data type |
|--------|-----------|
| GEO (NCBI) | Microarray, RNA-seq |
| TCGA | Cancer genomics |
| GTEx | Normal tissue expression |
| ArrayExpress | European expression data |

## References

- [GenoMAS GitHub](https://github.com/futianfan/GenoMAS)
- Love, M.I. et al. (2014). "Moderated estimation of fold change and dispersion for RNA-seq data with DESeq2." *Genome Biology* 15(12).

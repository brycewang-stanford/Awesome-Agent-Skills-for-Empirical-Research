---
name: genotex-benchmark-guide
description: "Benchmark for LLM agents on gene expression data analysis"
metadata:
  openclaw:
    emoji: "🧫"
    category: "domains"
    subcategory: "biomedical"
    keywords: ["GenoTEX", "gene expression", "benchmark", "LLM agent", "bioinformatics", "GEO"]
    source: "https://github.com/Liu-Hy/GenoTEX"
---

# GenoTEX Benchmark Guide

## Overview

GenoTEX is a benchmark for evaluating LLM-based agents on gene expression data analysis tasks. It provides curated datasets from GEO (Gene Expression Omnibus) with ground-truth analysis pipelines, testing agents on data preprocessing, differential expression, enrichment analysis, and biological interpretation. Published at MLCB 2025 as an oral presentation.

## Benchmark Structure

```
GenoTEX Benchmark
├── Data Collection
│   └── Curated GEO datasets with ground truth
├── Task Categories
│   ├── Data preprocessing (QC, normalization)
│   ├── Differential expression analysis
│   ├── Gene set enrichment analysis
│   ├── Clustering and classification
│   └── Biological interpretation
├── Evaluation
│   ├── Code correctness (executes without error)
│   ├── Statistical validity (appropriate tests)
│   ├── Result accuracy (vs ground truth)
│   └── Interpretation quality (biological insight)
└── Baselines
    ├── GPT-4 agent
    ├── Claude agent
    └── Domain-specific fine-tuned models
```

## Usage

```python
from genotex import GenoTEXBenchmark

bench = GenoTEXBenchmark()

# List available tasks
tasks = bench.list_tasks()
for task in tasks[:5]:
    print(f"Task: {task.id}")
    print(f"  Dataset: {task.geo_accession}")
    print(f"  Category: {task.category}")
    print(f"  Difficulty: {task.difficulty}")

# Get a specific task
task = bench.get_task("GSE12345_DEG")
print(f"Description: {task.description}")
print(f"Input files: {task.input_files}")
print(f"Expected output: {task.expected_output_type}")
```

## Running Evaluations

```python
# Evaluate an agent on GenoTEX
from genotex import evaluate_agent

results = evaluate_agent(
    agent_fn=my_agent_function,
    tasks="all",            # or specific task IDs
    timeout_per_task=300,   # seconds
)

print(f"Tasks completed: {results.completed}/{results.total}")
print(f"Code correctness: {results.code_correct_rate:.1%}")
print(f"Statistical validity: {results.stats_valid_rate:.1%}")
print(f"Result accuracy: {results.accuracy:.3f}")
```

## Task Examples

```python
# Example: Differential Expression Analysis
task = {
    "id": "GSE12345_DEG",
    "description": "Identify differentially expressed genes "
                   "between treatment and control groups in "
                   "this RNA-seq dataset.",
    "input": "GSE12345_counts.csv",  # Raw count matrix
    "metadata": "GSE12345_metadata.csv",  # Sample info
    "expected": {
        "method": "DESeq2 or limma-voom",
        "output": "DEG table with log2FC, p-value, adj.p",
        "ground_truth": "GSE12345_deg_truth.csv",
    },
}

# Example: Gene Set Enrichment
task = {
    "id": "GSE12345_GSEA",
    "description": "Perform gene set enrichment analysis on "
                   "the DEGs and identify enriched pathways.",
    "input": "GSE12345_deg_results.csv",
    "expected": {
        "method": "fgsea, clusterProfiler, or enrichR",
        "output": "Enriched pathways with NES and FDR",
    },
}
```

## Use Cases

1. **Agent evaluation**: Test bioinformatics agents on real tasks
2. **Method comparison**: Compare LLM agents on genomics
3. **Benchmark development**: Extend with new GEO datasets
4. **Teaching**: Standard tasks for bioinformatics education
5. **Tool development**: Test new analysis pipelines

## References

- [GenoTEX GitHub](https://github.com/Liu-Hy/GenoTEX)
- [GEO Database](https://www.ncbi.nlm.nih.gov/geo/)
- [MLCB 2025](https://mlcb.github.io/)

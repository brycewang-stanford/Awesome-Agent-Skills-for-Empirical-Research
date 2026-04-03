---
name: kedro-pipeline-guide
description: "Build reproducible data science pipelines with Kedro for research projects"
metadata:
  openclaw:
    emoji: "🔧"
    category: "research"
    subcategory: "automation"
    keywords: ["pipeline", "reproducibility", "data-science", "workflow", "automation", "mlops"]
    source: "https://github.com/kedro-org/kedro"
---

# Kedro Pipeline Guide

## Overview

Kedro is an open-source Python framework for creating reproducible, maintainable, and modular data science pipelines. Developed originally at McKinsey's QuantumBlack labs, Kedro provides an opinionated project structure and a set of conventions that transform ad-hoc analysis scripts into production-quality code that can be tested, versioned, and shared across research teams.

In academic research, reproducibility is both a scientific imperative and a practical challenge. Jupyter notebooks and standalone scripts often become tangled webs of dependencies that are difficult to re-run months later when responding to reviewer comments or extending prior work. Kedro addresses this by separating data processing logic from data access, enforcing explicit pipeline definitions, and providing built-in data versioning and experiment tracking.

With over 11,000 GitHub stars, Kedro has gained adoption across industry and academia. Its design philosophy aligns naturally with the needs of computational research: clear data lineage, parameterized experiments, and the ability to scale from a laptop to a cluster without rewriting code.

## Installation and Setup

Install Kedro via pip:

```bash
pip install kedro
```

Create a new project using the Kedro starter:

```bash
kedro new --name my-research-project --tools lint,test,docs
cd my-research-project
```

This generates a standardized project structure:

```
my-research-project/
  conf/
    base/
      catalog.yml        # Data source definitions
      parameters.yml     # Experiment parameters
    local/               # Local overrides (gitignored)
  src/
    my_research_project/
      pipelines/
        data_processing/
          nodes.py       # Pure Python functions
          pipeline.py    # Pipeline definition
        modeling/
          nodes.py
          pipeline.py
      pipeline_registry.py
  data/                  # Local data directory
  notebooks/             # Jupyter notebooks
  tests/                 # Unit tests
```

Install project dependencies:

```bash
pip install -e ".[dev]"
```

## Core Concepts

**Nodes**: The fundamental units of computation in Kedro. Each node is a pure Python function with explicitly declared inputs and outputs:

```python
# src/my_research_project/pipelines/data_processing/nodes.py

import pandas as pd
from sklearn.preprocessing import StandardScaler

def clean_raw_data(raw_data: pd.DataFrame) -> pd.DataFrame:
    """Remove missing values and outliers from raw experimental data."""
    cleaned = raw_data.dropna(subset=["measurement", "condition"])
    q1 = cleaned["measurement"].quantile(0.01)
    q99 = cleaned["measurement"].quantile(0.99)
    return cleaned[cleaned["measurement"].between(q1, q99)]

def normalize_features(
    cleaned_data: pd.DataFrame, parameters: dict
) -> pd.DataFrame:
    """Standardize feature columns specified in parameters."""
    feature_cols = parameters["feature_columns"]
    scaler = StandardScaler()
    result = cleaned_data.copy()
    result[feature_cols] = scaler.fit_transform(cleaned_data[feature_cols])
    return result
```

**Pipelines**: Chains of nodes connected through named datasets:

```python
# src/my_research_project/pipelines/data_processing/pipeline.py

from kedro.pipeline import Pipeline, node, pipeline
from .nodes import clean_raw_data, normalize_features

def create_pipeline(**kwargs) -> Pipeline:
    return pipeline([
        node(
            func=clean_raw_data,
            inputs="raw_experiment_data",
            outputs="cleaned_data",
            name="clean_data_node",
        ),
        node(
            func=normalize_features,
            inputs=["cleaned_data", "params:preprocessing"],
            outputs="normalized_data",
            name="normalize_node",
        ),
    ])
```

**Data Catalog**: A declarative registry that maps logical dataset names to physical storage:

```yaml
# conf/base/catalog.yml
raw_experiment_data:
  type: pandas.CSVDataset
  filepath: data/01_raw/experiment_results.csv

cleaned_data:
  type: pandas.ParquetDataset
  filepath: data/02_intermediate/cleaned.parquet

normalized_data:
  type: pandas.ParquetDataset
  filepath: data/03_primary/normalized.parquet
  versioned: true
```

The `versioned: true` flag automatically creates timestamped versions of outputs, enabling exact reproduction of prior runs.

**Parameters**: Experiment configuration separated from code:

```yaml
# conf/base/parameters.yml
preprocessing:
  feature_columns:
    - temperature
    - pressure
    - concentration
  outlier_method: iqr

modeling:
  algorithm: random_forest
  n_estimators: 500
  max_depth: 10
  test_size: 0.2
  random_seed: 42
```

## Running and Visualizing Pipelines

Execute the full pipeline:

```bash
kedro run
```

Run a specific pipeline or node:

```bash
kedro run --pipeline data_processing
kedro run --nodes clean_data_node
```

Visualize the pipeline dependency graph:

```bash
pip install kedro-viz
kedro viz run
```

This launches an interactive web visualization showing the complete data flow, making it easy to understand and communicate your analytical pipeline to collaborators and reviewers.

## Research Workflow Integration

**Experiment Reproducibility**: Every Kedro run uses explicit parameters and versioned data. Store parameter files in Git alongside code to create a complete record of every experiment configuration.

**Reviewer Response**: When peer reviewers request additional analyses or modified parameters, change `parameters.yml` and re-run. The pipeline automatically reprocesses only affected downstream nodes.

**Team Collaboration**: Multiple researchers can work on different pipeline modules simultaneously. The explicit input/output contracts between nodes prevent integration conflicts.

**Scaling Computation**: Kedro pipelines can be deployed to distributed computing platforms without code changes using runners:

```bash
# Run with parallel execution
kedro run --runner=ParallelRunner

# Deploy to Airflow, Prefect, or other orchestrators
pip install kedro-airflow
kedro airflow create
```

**Integration with Jupyter**: Use Kedro notebooks for exploration while maintaining the pipeline for production runs:

```bash
kedro jupyter notebook
```

The Kedro Jupyter integration automatically loads the project catalog and parameters, bridging the gap between interactive exploration and pipeline execution.

## References

- Kedro repository: https://github.com/kedro-org/kedro
- Kedro documentation: https://docs.kedro.org/
- Kedro-Viz for pipeline visualization: https://github.com/kedro-org/kedro-viz
- QuantumBlack blog on reproducible data science

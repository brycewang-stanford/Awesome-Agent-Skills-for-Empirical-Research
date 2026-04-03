---
name: aim-experiment-guide
description: "Track and compare research experiments with Aim experiment tracker"
metadata:
  openclaw:
    emoji: "🎯"
    category: "research"
    subcategory: "automation"
    keywords: ["experiment-tracking", "visualization", "mlops", "reproducibility", "metrics", "hyperparameters"]
    source: "https://github.com/aimhubio/aim"
---

# Aim Experiment Tracker Guide

## Overview

Aim is an open-source experiment tracking platform designed for researchers and ML engineers who need to log, compare, and analyze large numbers of experiments. Unlike cloud-based tracking services that require sending data to external servers, Aim runs entirely on your own infrastructure, making it suitable for research environments with data privacy requirements or institutional restrictions on external services.

The core problem Aim solves is experiment management at scale. A typical research project involves hundreds or thousands of training runs with different hyperparameters, data splits, model architectures, and random seeds. Without systematic tracking, researchers lose track of which configurations produced which results, leading to wasted computation and unreproducible findings. Aim provides a high-performance storage backend and a rich web UI for logging, querying, and visualizing experiment metadata and metrics.

With over 6,000 GitHub stars, Aim has established itself as a compelling self-hosted alternative to tools like Weights and Biases and MLflow. Its Python-native API integrates with minimal friction into existing training loops, and the query language enables sophisticated filtering across thousands of runs.

## Installation and Setup

Install Aim via pip:

```bash
pip install aim
```

Initialize an Aim repository in your project directory:

```bash
cd /path/to/research-project
aim init
```

This creates a `.aim` directory that stores all experiment data locally. Launch the web UI:

```bash
aim up
```

The dashboard becomes available at `http://localhost:43800`, providing interactive visualizations of all tracked experiments.

For remote server deployment:

```bash
aim up --host 0.0.0.0 --port 43800
```

## Core Features

**Experiment Logging**: Integrate Aim tracking into your training scripts with minimal code changes:

```python
from aim import Run

# Initialize a tracked run
run = Run(experiment="protein_folding_v2")

# Log hyperparameters
run["hparams"] = {
    "learning_rate": 0.001,
    "batch_size": 64,
    "model": "transformer",
    "num_layers": 6,
    "hidden_dim": 256,
    "dropout": 0.1,
    "optimizer": "adamw",
    "weight_decay": 0.01,
    "seed": 42,
}

# Log dataset information
run["dataset"] = {
    "name": "protein_benchmark_v3",
    "train_size": 50000,
    "val_size": 5000,
    "test_size": 5000,
}

# Track metrics during training
for epoch in range(num_epochs):
    train_loss = train_one_epoch(model, train_loader)
    val_loss, val_accuracy = evaluate(model, val_loader)

    run.track(train_loss, name="loss", context={"subset": "train"})
    run.track(val_loss, name="loss", context={"subset": "val"})
    run.track(val_accuracy, name="accuracy", context={"subset": "val"})
```

**Framework Integrations**: Aim provides built-in callbacks for popular training frameworks:

```python
# PyTorch Lightning integration
from aim.pytorch_lightning import AimLogger

aim_logger = AimLogger(experiment="lightning_exp")
trainer = pl.Trainer(logger=aim_logger, max_epochs=100)

# Hugging Face Transformers integration
from aim.hugging_face import AimCallback

aim_callback = AimCallback(experiment="hf_training")
trainer = Trainer(
    model=model,
    args=training_args,
    callbacks=[aim_callback],
)

# Keras integration
from aim.keras import AimCallback as KerasAimCallback

model.fit(
    x_train, y_train,
    callbacks=[KerasAimCallback(experiment="keras_exp")],
    epochs=50,
)
```

**Powerful Query Language**: Filter and retrieve experiments programmatically:

```python
from aim import Repo

repo = Repo("/path/to/research-project")

# Query runs matching specific criteria
query = """
run.experiment == "protein_folding_v2"
and run.hparams.learning_rate < 0.01
and run.hparams.model == "transformer"
"""

for run in repo.query_runs(query).iter_runs():
    print(f"Run: {run.hash}")
    print(f"  LR: {run['hparams']['learning_rate']}")
    print(f"  Final val loss: {run['loss']}")
```

**Rich Visualizations**: The web UI provides interactive charts for comparing experiments:

- Line charts for metric trajectories across epochs
- Parallel coordinates plots for hyperparameter exploration
- Scatter plots correlating hyperparameters with final metrics
- Distribution plots for metric analysis across run groups
- Image and audio tracking for multimedia experiments

## Research Workflow Integration

**Hyperparameter Search Analysis**: After running grid search or random search experiments, use Aim to identify the best configurations:

```python
from aim import Repo

repo = Repo(".")

# Find the best run by validation accuracy
best_run = None
best_acc = 0.0

for run_metrics in repo.query_metrics(
    "metric.name == 'accuracy' and metric.context.subset == 'val'"
).iter_runs():
    for metric in run_metrics:
        final_val = list(metric.values.values())[-1]
        if final_val > best_acc:
            best_acc = final_val
            best_run = metric.run.hash

print(f"Best run: {best_run} with accuracy {best_acc:.4f}")
```

**Reproducibility Documentation**: Every tracked run captures the full hyperparameter configuration, making it straightforward to include exact experimental details in paper methods sections and supplementary materials.

**Ablation Studies**: Tag runs with ablation group identifiers and use the comparison UI to visualize the impact of each component:

```python
run = Run(experiment="ablation_study")
run["hparams"] = config
run["ablation"] = {
    "group": "attention_mechanism",
    "variant": "multi_head",
    "description": "Standard multi-head attention vs. linear attention",
}
```

**Lab Notebook Integration**: Export experiment summaries for inclusion in electronic lab notebooks. The query API enables automated report generation:

```python
import pandas as pd
from aim import Repo

repo = Repo(".")
records = []

for run_metrics in repo.query_metrics(
    "metric.name == 'accuracy'"
).iter_runs():
    run = run_metrics.run
    for metric in run_metrics:
        values = list(metric.values.values())
        records.append({
            "run_hash": run.hash[:8],
            "model": run["hparams"].get("model"),
            "lr": run["hparams"].get("learning_rate"),
            "final_accuracy": values[-1] if values else None,
        })

df = pd.DataFrame(records)
df.to_csv("experiment_summary.csv", index=False)
```

## Storage and Performance

Aim uses a custom high-performance storage engine optimized for time-series metrics data. The storage scales to millions of tracked values across thousands of runs without significant degradation in query performance.

Data is stored locally in the `.aim` directory. Back up this directory to preserve your experiment history. For team settings, the Aim server can be deployed as a shared service accessible to multiple researchers.

```bash
# Check storage usage
du -sh .aim/

# Export data for archival
aim storage --repo . upgrade 3.0
```

## References

- Aim repository: https://github.com/aimhubio/aim
- Aim documentation: https://aimstack.readthedocs.io/
- Aim UI demo and screenshots in the repository wiki
- Comparison with MLflow and Weights and Biases in the documentation

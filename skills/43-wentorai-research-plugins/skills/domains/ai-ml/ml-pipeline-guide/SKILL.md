---
name: ml-pipeline-guide
description: "Build and deploy reproducible production ML pipelines for research"
metadata:
  openclaw:
    emoji: "🔧"
    category: "domains"
    subcategory: "ai-ml"
    keywords: ["MLOps", "pipeline", "deployment", "reproducibility", "feature engineering", "CI/CD"]
    source: "https://github.com/mlflow/mlflow"
---

# ML Pipeline Guide

## Overview

Machine learning research increasingly demands reproducible, end-to-end pipelines that go beyond a single training script. A research ML pipeline encompasses data ingestion, feature engineering, model training, evaluation, experiment tracking, and artifact management. Without a structured pipeline, research results become difficult to reproduce, ablation studies become error-prone, and collaborators cannot build on prior work.

This guide covers the practical tools and patterns for building ML pipelines in an academic research context. The focus is on reproducibility, experiment tracking, and the transition from notebook prototyping to structured experiments. The patterns use MLflow, DVC, and standard Python tooling -- chosen because they are open source, widely adopted in published research, and require minimal infrastructure.

Unlike industry MLOps guides that emphasize deployment at scale, this guide prioritizes the research workflow: running many experiments, tracking what changed between runs, and producing results that reviewers can verify.

## Pipeline Architecture

A research ML pipeline typically has five stages:

```
Data Ingestion → Feature Engineering → Training → Evaluation → Artifact Storage
     │                  │                 │            │              │
     ├── raw data       ├── transforms    ├── model    ├── metrics    ├── models
     ├── splits         ├── features      ├── logs     ├── plots      ├── configs
     └── metadata       └── cache         └── ckpts    └── tables     └── reports
```

### Directory Structure for Reproducible Research

```
project/
├── configs/
│   ├── base.yaml           # Default hyperparameters
│   ├── experiment_001.yaml  # Experiment-specific overrides
│   └── sweep.yaml          # Hyperparameter search space
├── data/
│   ├── raw/                # Immutable original data
│   ├── processed/          # Cleaned and transformed
│   └── splits/             # Train/val/test splits (versioned)
├── src/
│   ├── data/               # Data loading and preprocessing
│   ├── features/           # Feature engineering
│   ├── models/             # Model definitions
│   ├── training/           # Training loops
│   └── evaluation/         # Metrics and visualization
├── experiments/            # MLflow/W&B experiment logs
├── notebooks/              # Exploratory analysis only
├── tests/                  # Unit tests for pipeline components
├── Makefile                # Reproducible commands
├── requirements.txt        # Pinned dependencies
└── dvc.yaml                # Data version control pipeline
```

## Experiment Tracking with MLflow

```python
import mlflow
import mlflow.pytorch
from pathlib import Path

def run_experiment(config: dict):
    """Run a single experiment with full tracking."""
    mlflow.set_experiment(config["experiment_name"])

    with mlflow.start_run(run_name=config.get("run_name")):
        # Log configuration
        mlflow.log_params({
            "model": config["model_name"],
            "learning_rate": config["lr"],
            "batch_size": config["batch_size"],
            "epochs": config["epochs"],
            "optimizer": config["optimizer"],
            "seed": config["seed"],
        })

        # Log environment
        mlflow.log_param("python_version", sys.version)
        mlflow.log_param("torch_version", torch.__version__)
        mlflow.log_param("cuda_version", torch.version.cuda)

        # Training
        model = build_model(config)
        for epoch in range(config["epochs"]):
            train_loss = train_one_epoch(model, train_loader, optimizer)
            val_loss, val_metrics = evaluate(model, val_loader)

            mlflow.log_metrics({
                "train_loss": train_loss,
                "val_loss": val_loss,
                **{f"val_{k}": v for k, v in val_metrics.items()},
            }, step=epoch)

        # Log final model
        mlflow.pytorch.log_model(model, "model")

        # Log artifacts (plots, configs)
        mlflow.log_artifact(config_path)
        save_evaluation_plots(model, test_loader, "plots/")
        mlflow.log_artifacts("plots/")

        return val_metrics
```

## Data Versioning with DVC

```yaml
# dvc.yaml -- Pipeline definition
stages:
  prepare_data:
    cmd: python src/data/prepare.py --config configs/base.yaml
    deps:
      - src/data/prepare.py
      - data/raw/
    outs:
      - data/processed/
    params:
      - configs/base.yaml:
          - data.split_ratio
          - data.random_seed

  extract_features:
    cmd: python src/features/extract.py --config configs/base.yaml
    deps:
      - src/features/extract.py
      - data/processed/
    outs:
      - data/features/
    params:
      - configs/base.yaml:
          - features

  train:
    cmd: python src/training/train.py --config configs/base.yaml
    deps:
      - src/training/train.py
      - src/models/
      - data/features/
    outs:
      - models/
    metrics:
      - metrics.json:
          cache: false
    plots:
      - plots/training_curve.csv:
          x: epoch
          y: loss
```

```bash
# Reproduce the full pipeline
dvc repro

# Compare experiments
dvc metrics diff

# Push data to remote storage
dvc push
```

## Configuration Management with Hydra

```python
import hydra
from omegaconf import DictConfig, OmegaConf

@hydra.main(config_path="configs", config_name="base", version_base=None)
def main(cfg: DictConfig):
    print(OmegaConf.to_yaml(cfg))

    model = build_model(
        name=cfg.model.name,
        hidden_dim=cfg.model.hidden_dim,
        num_layers=cfg.model.num_layers,
    )

    train(
        model=model,
        lr=cfg.training.lr,
        epochs=cfg.training.epochs,
        batch_size=cfg.training.batch_size,
    )

# Override from command line:
# python train.py training.lr=1e-4 model.hidden_dim=512
# python train.py --multirun training.lr=1e-3,1e-4,1e-5
```

```yaml
# configs/base.yaml
model:
  name: resnet50
  hidden_dim: 256
  num_layers: 4

training:
  lr: 1e-3
  epochs: 100
  batch_size: 32
  optimizer: adamw
  weight_decay: 0.01

data:
  dataset: cifar10
  split_ratio: [0.8, 0.1, 0.1]
  random_seed: 42
  augmentation: true
```

## Feature Engineering Patterns

```python
from sklearn.pipeline import Pipeline
from sklearn.preprocessing import StandardScaler, OneHotEncoder
from sklearn.compose import ColumnTransformer
from sklearn.impute import SimpleImputer
import joblib

def build_feature_pipeline(numeric_cols: list, categorical_cols: list) -> Pipeline:
    """Build a reproducible feature engineering pipeline."""
    numeric_transformer = Pipeline([
        ("imputer", SimpleImputer(strategy="median")),
        ("scaler", StandardScaler()),
    ])

    categorical_transformer = Pipeline([
        ("imputer", SimpleImputer(strategy="most_frequent")),
        ("encoder", OneHotEncoder(handle_unknown="ignore", sparse_output=False)),
    ])

    preprocessor = ColumnTransformer([
        ("num", numeric_transformer, numeric_cols),
        ("cat", categorical_transformer, categorical_cols),
    ])

    return preprocessor

# Save and load for reproducibility
preprocessor.fit(X_train)
joblib.dump(preprocessor, "artifacts/preprocessor.pkl")
# Later: preprocessor = joblib.load("artifacts/preprocessor.pkl")
```

## Makefile for Reproducibility

```makefile
.PHONY: setup data train evaluate all clean

setup:
	pip install -r requirements.txt
	dvc pull

data:
	python src/data/prepare.py --config configs/base.yaml

train:
	python src/training/train.py --config configs/base.yaml

evaluate:
	python src/evaluation/evaluate.py --config configs/base.yaml

all: setup data train evaluate

sweep:
	python src/training/train.py --multirun \
		training.lr=1e-3,1e-4,1e-5 \
		model.hidden_dim=128,256,512

clean:
	rm -rf outputs/ multirun/ __pycache__/
```

## Best Practices

- **Never modify raw data.** All transformations should be scripted and reproducible.
- **Pin every dependency version** including CUDA, cuDNN, and OS-level libraries.
- **Separate configuration from code.** Use YAML/JSON configs, not hardcoded values.
- **Track experiments from day one.** Retrofitting experiment tracking is painful.
- **Write tests for data preprocessing.** Shape mismatches and silent data corruption are common.
- **Use `Makefile` or `dvc repro`** so any collaborator can reproduce results with one command.
- **Version your data alongside your code** using DVC, Git-LFS, or cloud storage with manifests.

## References

- [MLflow documentation](https://mlflow.org/docs/latest/) -- Experiment tracking and model registry
- [DVC documentation](https://dvc.org/doc) -- Data version control for ML
- [Hydra documentation](https://hydra.cc/) -- Configuration management framework
- [Cookiecutter Data Science](https://drivendata.github.io/cookiecutter-data-science/) -- Project structure template
- [Made With ML](https://madewithml.com/) -- MLOps best practices for researchers

---
name: ml-experiment-tracker
description: "Plan reproducible ML experiment runs with parameters and metrics tracking"
metadata:
  openclaw:
    emoji: "🧪"
    category: "analysis"
    subcategory: "statistics"
    keywords: ["experiment tracking", "machine learning", "reproducibility", "hyperparameters", "MLflow", "model evaluation"]
    source: "wentor-research-plugins"
---

# ML Experiment Tracker

A skill for planning, executing, and tracking machine learning experiments with full reproducibility. Covers experiment design, hyperparameter management, metric logging, model versioning, and comparison across runs to support rigorous ML research.

## Overview

Machine learning research involves running dozens or hundreds of experiments with varying architectures, hyperparameters, data splits, and preprocessing pipelines. Without systematic tracking, it becomes impossible to reproduce results, compare configurations, or identify which changes actually improved performance. This skill provides a structured methodology for experiment management that aligns with academic standards for reproducible ML research.

The approach is framework-agnostic but demonstrates integration with MLflow, Weights & Biases, and plain file-based logging. It emphasizes the practices needed for publications: complete hyperparameter documentation, statistical significance testing across runs, and artifact management for model checkpoints and evaluation outputs.

## Experiment Design Framework

### Defining an Experiment Plan

Before writing any training code, document the experiment plan:

```yaml
# experiment_plan.yaml
experiment:
  name: "transformer-sentiment-analysis-v3"
  hypothesis: "Adding relative positional encoding improves F1 on long reviews (>512 tokens)"
  dataset:
    name: "imdb-extended"
    version: "2025.1"
    splits: {train: 0.8, val: 0.1, test: 0.1}
    stratify_by: "label"
    random_seed: 42

  baselines:
    - name: "bert-base-uncased"
      checkpoint: "bert-base-uncased"
    - name: "roberta-base"
      checkpoint: "roberta-base"

  variables:
    independent:
      - positional_encoding: ["absolute", "relative", "rotary"]
    controlled:
      - learning_rate: 2e-5
      - batch_size: 32
      - max_epochs: 10
      - early_stopping_patience: 3
      - optimizer: "AdamW"
      - weight_decay: 0.01

  metrics:
    primary: "f1_macro"
    secondary: ["accuracy", "precision_macro", "recall_macro", "loss"]
    report_at: ["best_val", "final"]

  compute:
    gpus: 1
    estimated_time_per_run: "45min"
    total_runs: 9  # 3 encodings x 3 seeds

  seeds: [42, 123, 456]
```

### Factorial Design for Hyperparameter Studies

```python
from itertools import product

def generate_experiment_grid(config: dict) -> list:
    """
    Generate all experiment configurations from a factorial design.
    """
    param_names = list(config.keys())
    param_values = list(config.values())

    runs = []
    for combo in product(*param_values):
        run_config = dict(zip(param_names, combo))
        run_config['run_id'] = '_'.join(f"{k}={v}" for k, v in run_config.items())
        runs.append(run_config)

    return runs

# Example: 3 learning rates x 2 batch sizes x 3 seeds = 18 runs
grid = generate_experiment_grid({
    'learning_rate': [1e-5, 2e-5, 5e-5],
    'batch_size': [16, 32],
    'seed': [42, 123, 456]
})
```

## Experiment Logging with MLflow

### Setup and Run Tracking

```python
import mlflow
import json
from datetime import datetime

def start_tracked_experiment(experiment_name: str, run_config: dict):
    """
    Initialize an MLflow experiment run with full configuration logging.
    """
    mlflow.set_experiment(experiment_name)

    with mlflow.start_run(run_name=run_config.get('run_id', None)) as run:
        # Log all hyperparameters
        mlflow.log_params(run_config)

        # Log environment info for reproducibility
        mlflow.log_param("python_version", "3.11.5")
        mlflow.log_param("torch_version", "2.1.0")
        mlflow.log_param("timestamp", datetime.now().isoformat())

        # Log the full config as an artifact
        with open("/tmp/run_config.json", "w") as f:
            json.dump(run_config, f, indent=2)
        mlflow.log_artifact("/tmp/run_config.json")

        return run.info.run_id

def log_epoch_metrics(epoch: int, metrics: dict):
    """Log metrics for a training epoch."""
    for name, value in metrics.items():
        mlflow.log_metric(name, value, step=epoch)

def log_final_results(metrics: dict, model_path: str = None):
    """Log final evaluation metrics and optionally the model artifact."""
    for name, value in metrics.items():
        mlflow.log_metric(f"final_{name}", value)
    if model_path:
        mlflow.log_artifact(model_path)
```

## Results Comparison and Statistical Testing

### Comparing Runs Across Seeds

```python
from scipy import stats
import numpy as np

def compare_experiment_results(results: dict) -> dict:
    """
    Compare experiment configurations using statistical tests.

    Args:
        results: Dict mapping config_name -> list of metric values across seeds
        e.g., {'relative_pe': [0.87, 0.86, 0.88], 'absolute_pe': [0.84, 0.83, 0.85]}
    """
    config_names = list(results.keys())
    comparisons = {}

    for i in range(len(config_names)):
        for j in range(i + 1, len(config_names)):
            name_a, name_b = config_names[i], config_names[j]
            values_a, values_b = results[name_a], results[name_b]

            # Paired t-test (same seeds)
            t_stat, p_value = stats.ttest_rel(values_a, values_b)

            # Effect size (Cohen's d)
            diff = np.array(values_a) - np.array(values_b)
            cohens_d = np.mean(diff) / np.std(diff, ddof=1)

            comparisons[f"{name_a}_vs_{name_b}"] = {
                'mean_a': np.mean(values_a),
                'mean_b': np.mean(values_b),
                'mean_diff': np.mean(diff),
                't_statistic': round(t_stat, 4),
                'p_value': round(p_value, 4),
                'significant': p_value < 0.05,
                'cohens_d': round(cohens_d, 3)
            }

    return comparisons
```

### Results Summary Table

| Configuration | F1 (mean +/- std) | Accuracy | p-value vs. baseline |
|--------------|-------------------|----------|---------------------|
| Baseline (absolute PE) | 0.840 +/- 0.010 | 0.852 | -- |
| Relative PE | 0.870 +/- 0.008 | 0.881 | 0.003 |
| Rotary PE | 0.865 +/- 0.012 | 0.876 | 0.011 |

## Reproducibility Checklist

Before submitting ML results for publication, verify:

- [ ] Random seeds are fixed and reported for all stochastic operations
- [ ] Dataset version and exact split indices are saved
- [ ] All hyperparameters are logged (not just the "important" ones)
- [ ] Software versions (framework, CUDA, key libraries) are documented
- [ ] Results are averaged over at least 3 random seeds with standard deviations
- [ ] Statistical significance tests are performed for key comparisons
- [ ] Model checkpoints or training scripts are archived
- [ ] Data preprocessing pipeline is fully specified and deterministic

## References

- Bouthillier, X., et al. (2021). Accounting for Variance in Machine Learning Benchmarks. *MLSys 2021*.
- Zaharia, M., et al. (2018). Accelerating the Machine Learning Lifecycle with MLflow. *IEEE Data Eng. Bull.*
- Dodge, J., et al. (2019). Show Your Work: Improved Reporting of Experimental Results. *EMNLP 2019*.

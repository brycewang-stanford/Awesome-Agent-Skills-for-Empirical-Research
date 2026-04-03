---
name: rd-agent-guide
description: "Microsoft AI-driven R&D agent for automated data and model development"
metadata:
  openclaw:
    emoji: "🤖"
    category: "research"
    subcategory: "automation"
    keywords: ["r-and-d", "microsoft", "automation", "model-development", "data-science", "experiment-automation"]
    source: "https://github.com/microsoft/RD-Agent"
---

# RD-Agent Guide

## Overview

RD-Agent is an open-source AI-powered research and development automation framework developed by Microsoft Research, with over 12,000 stars on GitHub. It automates key steps in the R&D lifecycle -- including hypothesis generation, experiment design, code implementation, and result analysis -- enabling researchers and data scientists to accelerate their development cycles significantly.

The framework implements a closed-loop R&D automation pipeline where an AI agent iteratively proposes hypotheses, implements experiments, evaluates results, and refines its approach based on feedback. This mirrors the scientific method but operates at machine speed, allowing researchers to explore a much larger space of ideas and configurations than would be feasible manually.

RD-Agent is particularly valuable for researchers working in quantitative finance, data science, and machine learning, where the development process involves iterating on feature engineering, model architectures, and hyperparameter configurations. The framework has demonstrated the ability to autonomously develop competitive machine learning models and trading strategies, achieving results comparable to experienced human practitioners.

## Installation and Setup

```bash
# Clone the repository
git clone https://github.com/microsoft/RD-Agent.git
cd RD-Agent

# Install dependencies
pip install -e .

# Or install from PyPI
pip install rdagent
```

### Environment Configuration

```bash
# LLM configuration (required)
export OPENAI_API_KEY=$OPENAI_API_KEY
export CHAT_MODEL=gpt-4o

# Or use Azure OpenAI
export AZURE_OPENAI_API_KEY=$AZURE_OPENAI_API_KEY
export AZURE_OPENAI_ENDPOINT=$AZURE_OPENAI_ENDPOINT
export AZURE_OPENAI_DEPLOYMENT=$AZURE_OPENAI_DEPLOYMENT

# Docker is required for sandboxed code execution
# Ensure Docker is installed and running
docker --version
```

RD-Agent uses Docker containers to execute generated code safely, ensuring that automatically generated experiments cannot affect the host system. This sandboxed execution is critical for an autonomous agent that writes and runs arbitrary code.

## Core Concepts

### The R&D Loop

RD-Agent implements a continuous improvement loop with four phases:

1. **Proposal**: The agent analyzes the current state and proposes new hypotheses or improvements
2. **Implementation**: Hypotheses are translated into executable code (feature engineering, model changes, etc.)
3. **Evaluation**: The implemented changes are executed in a sandbox and results are measured against defined metrics
4. **Feedback**: Results are analyzed and used to inform the next round of proposals

```python
from rdagent.core.runner import RDRunner
from rdagent.scenarios.data_science import DataScienceScenario

# Define the research scenario
scenario = DataScienceScenario(
    task="tabular_classification",
    dataset_path="path/to/dataset.csv",
    target_column="label",
    metric="auc",
)

# Create and run the R&D agent
runner = RDRunner(
    scenario=scenario,
    max_iterations=50,
    llm_model="gpt-4o",
)

# Start the autonomous R&D loop
results = runner.run()

# Review the best solution found
print(f"Best metric: {results.best_score}")
print(f"Iterations: {results.total_iterations}")
print(f"Solutions explored: {results.num_solutions}")
```

### Scenario Types

RD-Agent supports multiple R&D scenarios out of the box:

#### Data Science / Kaggle Competitions

Automatically engineer features, select models, and tune hyperparameters for tabular data tasks:

```python
from rdagent.scenarios.data_science import DataScienceScenario

scenario = DataScienceScenario(
    task="tabular_regression",
    dataset_path="data/housing.csv",
    target_column="price",
    metric="rmse",
    time_budget_hours=4,
)
```

#### Quantitative Finance

Develop and backtest trading factors and strategies:

```python
from rdagent.scenarios.qlib import QlibScenario

scenario = QlibScenario(
    market="csi300",
    task="alpha_factor_mining",
    backtest_start="2020-01-01",
    backtest_end="2024-12-31",
    metric="information_coefficient",
)
```

#### Model Development

Iterate on model architectures and training procedures:

```python
from rdagent.scenarios.model_dev import ModelDevScenario

scenario = ModelDevScenario(
    task="image_classification",
    base_model="resnet50",
    dataset="cifar100",
    optimization_target="accuracy",
)
```

## Advanced Features

### Experiment Tracking and Analysis

RD-Agent maintains detailed logs of all experiments, enabling post-hoc analysis of the R&D process:

```python
# Access experiment history
for experiment in results.history:
    print(f"Iteration {experiment.iteration}:")
    print(f"  Hypothesis: {experiment.hypothesis}")
    print(f"  Changes: {experiment.code_changes}")
    print(f"  Metric: {experiment.score}")
    print(f"  Analysis: {experiment.feedback}")
```

### Custom Evaluation Functions

Define custom evaluation metrics for domain-specific research:

```python
from rdagent.core.evaluation import EvaluationFunction

class CustomMetric(EvaluationFunction):
    def evaluate(self, predictions, ground_truth, **kwargs):
        # Your custom metric computation
        score = compute_domain_specific_metric(predictions, ground_truth)
        return {
            "primary_metric": score,
            "secondary_metrics": {
                "precision": compute_precision(predictions, ground_truth),
                "recall": compute_recall(predictions, ground_truth),
            }
        }

scenario = DataScienceScenario(
    evaluation_function=CustomMetric(),
    # ... other config
)
```

### Human-in-the-Loop Mode

Guide the agent with human feedback at key decision points:

```python
runner = RDRunner(
    scenario=scenario,
    human_in_the_loop=True,
    review_frequency=5,  # Review every 5 iterations
)

# The agent will pause for human review at specified intervals
# You can approve, reject, or modify proposed experiments
```

## Research Applications

### Ablation Studies at Scale

Use RD-Agent to systematically explore which components contribute most to model performance:

```python
# Define ablation study
ablation_config = {
    "base_model": "your_full_model",
    "components_to_ablate": [
        "attention_mechanism",
        "residual_connections",
        "layer_normalization",
        "data_augmentation",
    ],
    "metric": "accuracy",
    "num_seeds": 5,  # Run each configuration with 5 seeds
}
```

### Automated Feature Engineering

Let the agent discover and implement novel features for your dataset:

```python
scenario = DataScienceScenario(
    task="feature_engineering",
    dataset_path="data/research_data.csv",
    existing_features=["feature_a", "feature_b", "feature_c"],
    target="outcome",
    max_new_features=20,
)
```

### Reproducibility

Every experiment run by RD-Agent is fully reproducible. The framework saves the complete experiment specification including code, data transformations, random seeds, and environment details, enabling other researchers to reproduce and build upon the results.

## References

- Repository: https://github.com/microsoft/RD-Agent
- Microsoft Research blog post: https://www.microsoft.com/en-us/research/project/rd-agent/
- Qlib quantitative platform: https://github.com/microsoft/qlib
- Documentation: https://microsoft.github.io/RD-Agent/

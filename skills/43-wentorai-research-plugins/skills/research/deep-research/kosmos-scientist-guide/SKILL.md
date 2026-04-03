---
name: kosmos-scientist-guide
description: "Claude Code-driven autonomous AI Scientist for discovery"
metadata:
  openclaw:
    emoji: "🔭"
    category: "research"
    subcategory: "deep-research"
    keywords: ["AI Scientist", "autonomous discovery", "Claude Code", "research automation", "scientific method", "experiment"]
    source: "https://github.com/jimmc414/Kosmos"
---

# Kosmos AI Scientist Guide

## Overview

Kosmos is a Claude Code-driven AI Scientist framework that automates the scientific discovery process — from hypothesis generation through literature review, experiment design, code implementation, result analysis, and paper writing. It uses Claude Code as the execution engine with structured prompts that guide it through the full scientific method. Designed for ML/AI researchers automating experiment pipelines.

## Scientific Pipeline

```
Research Question
      ↓
  Literature Review (search + synthesize)
      ↓
  Hypothesis Generation (testable predictions)
      ↓
  Experiment Design (variables, controls, metrics)
      ↓
  Implementation (code, data pipeline)
      ↓
  Execution (run experiments)
      ↓
  Analysis (statistics, visualization)
      ↓
  Interpretation (findings, limitations)
      ↓
  Paper Draft (LaTeX manuscript)
```

## Project Configuration

```markdown
# CLAUDE.md for Kosmos AI Scientist

## Research Protocol
You are an AI Scientist conducting rigorous research.
Follow the scientific method strictly:

1. **Literature Review**: Search for related work before
   proposing anything new. Use OpenAlex API.
2. **Hypothesis**: State falsifiable hypotheses clearly.
3. **Experiment Design**: Define independent/dependent
   variables, controls, evaluation metrics.
4. **Implementation**: Write clean, reproducible code.
   Set random seeds. Log all hyperparameters.
5. **Analysis**: Run statistical tests. Report confidence
   intervals, not just point estimates.
6. **Honesty**: Report negative results. Acknowledge
   limitations. Never fabricate data.

## Tools Available
- Python 3.11+ with PyTorch, NumPy, SciPy
- LaTeX (pdflatex + bibtex)
- OpenAlex API for literature
- W&B for experiment tracking (optional)
```

## Workflow Stages

### Stage 1: Literature Review

```python
# Kosmos automates literature search
# The AI Scientist searches, reads, and synthesizes

# Guided prompt pattern:
"""
Search for papers on: [TOPIC]

1. Find 20+ relevant papers from last 3 years
2. Read abstracts and identify key methods
3. Create a summary table:
   | Paper | Method | Dataset | Key Result |
4. Identify gaps in current research
5. Propose novel directions based on gaps
"""
```

### Stage 2: Experiment Design

```python
# Structured experiment specification
experiment_spec = {
    "hypothesis": "Sparse attention patterns learned via "
                  "Gumbel-Softmax outperform fixed patterns "
                  "on long-sequence tasks",
    "independent_vars": ["attention_pattern_type"],
    "dependent_vars": ["accuracy", "throughput", "memory"],
    "controls": {
        "model_size": "same parameter count",
        "training_data": "same dataset and splits",
        "hyperparams": "same learning rate schedule",
    },
    "datasets": ["Long Range Arena", "PG-19"],
    "baselines": ["full_attention", "local_window",
                   "linformer", "performer"],
    "metrics": {
        "primary": "accuracy",
        "secondary": ["wall_clock_time", "peak_memory"],
    },
    "statistical_tests": ["paired_t_test", "bootstrap_ci"],
    "seed_runs": 5,
}
```

### Stage 3: Implementation and Execution

```python
# The AI Scientist writes and runs experiment code

# Pattern: iterative implementation with testing
"""
Implement the experiment:
1. Write model code with unit tests
2. Write training loop with logging
3. Run small-scale validation (1 epoch, subset)
4. Verify metrics are computed correctly
5. Run full experiments (all seeds, all baselines)
6. Save results to results/ directory
"""

# Results structure
# results/
# ├── config.json         # Full hyperparameters
# ├── metrics.csv         # All run metrics
# ├── figures/            # Generated plots
# └── checkpoints/        # Model checkpoints
```

### Stage 4: Analysis and Paper

```python
# Automated analysis and writing
"""
Analyze results and write paper:
1. Compute mean ± std across seeds
2. Run statistical significance tests
3. Generate publication-quality figures
4. Write LaTeX paper with:
   - Introduction (motivation + contributions)
   - Related Work (from literature review)
   - Method (formal description)
   - Experiments (setup + results + analysis)
   - Conclusion (summary + limitations + future)
5. Verify all citations are real (OpenAlex/CrossRef)
"""
```

## Safety and Ethics

```markdown
### Guardrails
- Never fabricate or manipulate experimental data
- Report all results including negative ones
- Acknowledge limitations explicitly
- Verify all citations against real databases
- Include compute cost and environmental impact
- Flag when results are inconclusive
- Human review required before submission
```

## Use Cases

1. **ML experiments**: Automated hypothesis → experiment → paper
2. **Ablation studies**: Systematic component analysis
3. **Baseline comparison**: Reproduce and compare methods
4. **Research acceleration**: Draft experiments faster
5. **Teaching**: Demonstrate scientific method with AI

## References

- [Kosmos GitHub](https://github.com/jimmc414/Kosmos)
- [The AI Scientist](https://arxiv.org/abs/2408.06292)
- [Claude Code](https://docs.anthropic.com/en/docs/claude-code)

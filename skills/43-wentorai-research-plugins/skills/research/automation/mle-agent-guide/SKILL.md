---
name: mle-agent-guide
description: "Intelligent companion for ML engineering with arXiv integration"
version: 1.0.0
author: wentor-community
source: https://github.com/MLSys-Tools/MLE-agent
metadata:
  openclaw:
    category: "research"
    subcategory: "automation"
    emoji: "🔬"
    keywords:
      - machine-learning
      - ml-engineering
      - arxiv-integration
      - experiment-tracking
      - model-development
      - ai-engineering
---

# MLE Agent Guide

A skill for using an intelligent ML engineering companion that integrates arXiv paper discovery with experiment implementation, tracking, and iteration. Based on MLE-agent (2K stars), this skill helps researchers bridge the gap between reading about new ML techniques and implementing them in their own projects.

## Overview

Machine learning research moves at an extraordinary pace, with hundreds of new papers appearing on arXiv daily. Researchers struggle not just to keep up with the literature but to translate promising ideas into working implementations. MLE-agent addresses this by combining paper discovery, technique extraction, implementation assistance, and experiment management into a unified workflow.

This skill is designed for ML researchers and engineers who want to quickly prototype ideas from papers, systematically compare approaches, and maintain organized experiment records throughout the research process.

## arXiv Integration

The skill provides sophisticated arXiv paper discovery and analysis:

**Paper Discovery**
- Monitor arXiv categories relevant to the researcher's interests (cs.LG, cs.CL, cs.CV, stat.ML, etc.)
- Filter new papers by keyword relevance, author familiarity, and citation velocity
- Rank papers by potential applicability to current research projects
- Generate daily or weekly digests of the most relevant new papers
- Track papers from specific authors or research groups

**Paper Analysis**
- Extract the core technical contribution from each paper
- Identify the proposed method's key components and hyperparameters
- Compare the method against baselines reported in the paper
- Note the datasets and evaluation metrics used
- Assess reproducibility based on available code, data, and method description detail

**Technique Extraction**
- Distill the algorithmic steps from the paper's method section
- Identify required input data formats and preprocessing steps
- Map the technique's computational requirements (GPU memory, training time)
- Note dependencies on specific frameworks or libraries
- Extract training recipes including learning rate schedules, batch sizes, and augmentation strategies

## Experiment Workflow

The core experiment management workflow:

**Project Setup**
- Initialize a structured project directory with standard ML conventions
- Set up experiment configuration files (YAML or JSON)
- Configure logging and metric tracking infrastructure
- Establish a baseline model and dataset pipeline
- Create a reproducibility checklist (random seeds, library versions, hardware specs)

**Implementation Assistance**
- Translate extracted techniques from papers into implementation plans
- Generate code scaffolds for new model architectures
- Suggest appropriate loss functions and optimization strategies
- Help debug common ML issues (gradient problems, data loading bottlenecks, memory issues)
- Provide code review focused on ML best practices

**Experiment Execution**
- Configure hyperparameter search spaces based on paper recommendations
- Set up systematic ablation studies to understand component contributions
- Track metrics across training runs with consistent logging
- Generate comparison tables and learning curve plots
- Flag anomalous training behavior (loss spikes, metric plateaus, divergence)

**Result Analysis**
- Compare results across experiment runs with statistical tests
- Identify which hyperparameters have the strongest effect on performance
- Generate publication-ready result tables with confidence intervals
- Produce ablation study summaries highlighting each component's contribution
- Assess whether results match or deviate from paper-reported numbers

## ML Engineering Best Practices

The skill enforces ML engineering standards throughout the workflow:

**Reproducibility**
- Log all random seeds and ensure deterministic operations where possible
- Record exact library versions in requirements files
- Version control all configuration files alongside code
- Store model checkpoints with their corresponding configurations
- Document any manual steps in the pipeline

**Code Quality**
- Separate data loading, model definition, training, and evaluation into distinct modules
- Use configuration files rather than hardcoded hyperparameters
- Implement proper validation splits independent of test sets
- Add assertions for tensor shapes and value ranges at module boundaries
- Write unit tests for custom layers and data transformations

**Resource Management**
- Estimate computational costs before launching large experiments
- Use gradient accumulation to train with limited GPU memory
- Implement early stopping to avoid wasting compute on unpromising runs
- Profile code to identify and optimize bottlenecks
- Clean up intermediate artifacts and checkpoints to manage storage

## Common ML Research Patterns

The skill recognizes and supports common research patterns:

**Baseline Comparison** - Implement and evaluate standard baselines before proposing improvements
**Ablation Study** - Systematically remove or vary components to understand contributions
**Scaling Analysis** - Test how performance changes with model size, data size, or compute
**Transfer Learning** - Adapt pretrained models to new tasks with appropriate fine-tuning strategies
**Ensemble Methods** - Combine multiple models for improved and more robust performance

## Integration with Research-Claw

This skill connects with the Research-Claw ecosystem:

- Use literature search skills to find relevant papers for the current project
- Feed experiment results to writing skills for paper drafting
- Connect with analysis skills for statistical evaluation of results
- Store successful experiment configurations as reusable templates
- Share experiment logs and results with collaborators via the platform

## Best Practices

- Always establish baselines before implementing novel techniques
- Read the paper's appendix and supplementary materials for implementation details often missing from the main text
- Start with the paper's reported hyperparameters, then tune for your specific setup
- Keep a research log documenting what was tried, what worked, and what failed
- Verify your reimplementation on the paper's original dataset before applying to new data
- Track compute costs alongside performance metrics to evaluate efficiency trade-offs

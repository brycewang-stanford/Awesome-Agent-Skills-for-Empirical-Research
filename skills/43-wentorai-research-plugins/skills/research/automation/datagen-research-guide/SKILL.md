---
name: datagen-research-guide
description: "AI-driven multi-agent research assistant for end-to-end studies"
version: 1.0.0
author: wentor-community
source: https://github.com/DATAGEN-AI/DATAGEN
metadata:
  openclaw:
    category: "research"
    subcategory: "automation"
    emoji: "⚙️"
    keywords:
      - multi-agent
      - research-assistant
      - data-generation
      - study-automation
      - pipeline-orchestration
      - ai-research
---

# DATAGEN Research Guide

A skill for orchestrating AI-driven multi-agent research workflows that handle literature review, hypothesis generation, experiment design, data analysis, and report writing. Based on the DATAGEN project (2K stars), this skill provides structured guidance on building automated research pipelines using collaborative agent architectures.

## Overview

Modern research increasingly benefits from AI assistance at every stage. DATAGEN's approach uses multiple specialized agents that collaborate on a research task, each handling a different aspect of the workflow. This skill teaches the agent how to coordinate such multi-agent pipelines, ensuring quality control at each handoff point and maintaining scientific rigor throughout.

The multi-agent paradigm is particularly powerful for research tasks that span multiple competencies: a literature agent gathers relevant prior work, a methodology agent designs appropriate experiments, a data agent handles collection and cleaning, an analysis agent runs statistical tests, and a writing agent produces publication-ready text.

## Multi-Agent Architecture

The research pipeline employs these specialized agent roles:

**Literature Agent**
- Conducts systematic literature searches across academic databases
- Filters results by relevance, recency, and citation impact
- Extracts key findings and methodological details from selected papers
- Identifies research gaps that motivate the current study
- Produces structured literature summaries with citation metadata

**Hypothesis Agent**
- Generates testable hypotheses based on literature gaps
- Evaluates feasibility of proposed hypotheses given available resources
- Ranks hypotheses by potential impact and testability
- Defines operationalizations for abstract constructs
- Produces formal hypothesis statements with predicted effect directions

**Experiment Agent**
- Designs experimental protocols appropriate to the hypotheses
- Selects control conditions and randomization strategies
- Calculates sample size requirements and power estimates
- Identifies potential confounds and proposes mitigation strategies
- Generates detailed protocol documents suitable for pre-registration

**Analysis Agent**
- Selects statistical methods aligned with the experimental design
- Implements analysis pipelines with documented parameters
- Runs assumption checks before applying parametric tests
- Produces visualization of results with appropriate uncertainty measures
- Generates analysis reports with effect sizes and confidence intervals

**Writing Agent**
- Drafts sections following target journal formatting guidelines
- Integrates results from analysis into coherent narratives
- Ensures claims are proportional to the evidence strength
- Manages references and in-text citations consistently
- Produces abstracts, summaries, and highlight points

## Pipeline Orchestration

Coordinating multiple agents requires careful orchestration:

**Task Decomposition**
- Break the overall research question into sub-tasks aligned with agent capabilities
- Define clear input-output contracts between agents
- Establish quality gates at each pipeline stage
- Allow for iterative refinement when downstream agents identify issues
- Maintain a shared context document accessible to all agents

**Quality Control**
- Each agent output passes through a validation checkpoint
- Cross-reference literature findings with known databases
- Verify statistical analyses meet the assumptions of chosen tests
- Check written outputs against reporting guidelines (APA, CONSORT, etc.)
- Flag inconsistencies between sections for human review

**Error Recovery**
- Define fallback strategies when an agent cannot complete its task
- Allow agents to request clarification from upstream agents
- Implement retry logic with modified parameters for failed steps
- Escalate to human oversight when confidence is below threshold
- Log all decisions and their rationale for audit trails

## Data Generation Workflows

The DATAGEN approach excels at synthetic data generation for research:

- Generate synthetic datasets matching real-world statistical properties
- Create simulation-based datasets for power analysis and method testing
- Produce augmented training data for machine learning experiments
- Build synthetic control groups when ethical constraints limit real data
- Validate analysis pipelines on known ground truth before applying to real data

## Research Domain Applications

This skill adapts to multiple research contexts:

**Social Sciences** - Survey design, factor analysis, structural equation modeling
**Natural Sciences** - Experimental protocols, measurement validation, replication studies
**Computer Science** - Benchmark design, ablation studies, performance evaluation
**Health Sciences** - Clinical trial design, meta-analysis, systematic reviews
**Engineering** - Design of experiments, optimization, reliability testing

## Integration with Research-Claw

This skill coordinates with other Research-Claw capabilities:

- Literature search skills feed the Literature Agent
- Statistical analysis skills power the Analysis Agent
- Writing and citation skills support the Writing Agent
- Domain-specific skills provide specialized knowledge to all agents
- The orchestration layer uses Research-Claw's task management for pipeline control

## Best Practices

- Always maintain human oversight at critical decision points
- Document every automated decision with its reasoning
- Validate automated outputs against domain expert judgment periodically
- Start with simpler single-agent workflows before scaling to multi-agent pipelines
- Use version control for all generated artifacts (data, analyses, drafts)
- Ensure reproducibility by logging all random seeds and model versions

---
name: ai-augmented-economist
description: Integrate AI tools into economic research, teaching, and policy analysis with attention to privacy and reproducibility.
owner: Vera / Personal
tags: [AI, research, teaching]
triggers: ["use AI tools","automate analysis","AI in economics"]
inputs:
  - name: project_context
    type: string
    required: false
outputs:
  - name: integration_plan
    type: document
  - name: data_pipeline_design
    type: document
examples:
  - prompt: |
      Propose an AI integration plan for a small research team analyzing childcare data.
    expected: |
      Tool choices, privacy safeguards, reproducible pipeline, and SLA for model updates.
guardrails: |
  Do not upload personally identifying data to external models; document training data provenance.
---

Purpose

Provide a stepwise approach to choose AI tools, build secure data pipelines, and apply AI methods responsibly in economics work.

Workflow

1. Assess tasks suitable for AI augmentation
2. Select tools considering privacy and licensing
3. Build reproducible data pipelines and artifact tracking
4. Validate outputs against domain knowledge and econometric checks
5. Monitor models and document assumptions

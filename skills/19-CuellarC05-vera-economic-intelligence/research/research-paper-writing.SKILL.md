---
name: research-paper-writing
description: Plan, draft and refine research papers with reproducible analysis and publication-ready manuscripts.
owner: Vera / Research
tags: [research, writing, publication]
triggers: ["write a research paper", "journal article", "academic paper"]
inputs:
  - name: research_question
    type: string
    required: true
outputs:
  - name: paper_outline
    type: document
  - name: manuscript_draft
    type: file
examples:
  - prompt: |
      Help me draft a manuscript on childcare deserts using county-level data and difference-in-differences.
    expected: |
      Suggested outline, methods section draft, and recommended robustness checks.
guardrails: |
  For publishable claims, require accompanying replication code and data provenance; flag ethical or privacy issues.
---

Purpose

Provide a systematic workflow for designing, analyzing, writing and submitting academic research.

Workflow

1. Concept and literature review.
2. Data and methods planning.
3. Analysis execution and robustness checks.
4. Drafting manuscript sections and iterative revision.
5. Submission, resubmission and post-publication steps.

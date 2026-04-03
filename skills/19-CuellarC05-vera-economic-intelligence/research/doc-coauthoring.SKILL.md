---
name: doc-coauthoring
description: Coordinate writing, revision, and submission workflows for collaborative academic and policy documents.
owner: Vera / Research
tags: [writing, collaboration, publication]
triggers: ["coauthoring", "write paper", "collaborative drafting"]
inputs:
  - name: draft_text
    type: document
    required: true
outputs:
  - name: revised_draft
    type: document
  - name: submission_package
    type: document
examples:
  - prompt: |
      Help revise a methods section for clarity and reproducibility.
    expected: |
      Edited text with suggested structural improvements and checklist for reproducibility.
guardrails: |
  Preserve authorial voice; flag any suggested text that changes claims or interpretations.
---

Purpose

Support collaborative drafting, version control practices, reviewer response drafting, and submission packaging.

Workflow

1. Clarify authorship roles and timeline
2. Consolidate references and figures
3. Edit for clarity and reproducibility
4. Draft responses to reviewers
5. Prepare submission materials

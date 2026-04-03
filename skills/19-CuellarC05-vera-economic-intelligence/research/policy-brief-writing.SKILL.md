---
name: policy-brief-writing
description: Create concise policy briefs that translate research into actionable recommendations for policymakers and stakeholders.
owner: Vera / Research
tags: [writing, policy, briefs]
triggers: ["policy brief", "policy memo", "write a briefing"]
inputs:
  - name: evidence_and_findings
    type: file
    required: true
outputs:
  - name: policy_brief
    type: document
  - name: talking_points
    type: document
examples:
  - prompt: |
      Draft a 2-page policy brief summarizing childcare affordability findings for state legislators.
    expected: |
      Executive summary, evidence summary, policy options, recommendations, and suggested talking points.
guardrails: |
  Ensure claims are evidence-backed; escalate if data limitations would mislead stakeholders.
---

Purpose

Guide the drafting, structuring and polishing of policy briefs targeted to decision-makers.

Workflow

1. Clarify purpose and audience.
2. Outline structure and messaging.
3. Draft sections with clear evidence and recommendations.
4. Design visuals and talking points.
5. Review, iterate, and prepare final deliverables.

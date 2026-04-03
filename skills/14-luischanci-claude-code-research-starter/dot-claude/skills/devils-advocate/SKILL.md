---
name: devils-advocate
description: Challenge research design decisions, assumptions, and methodology choices with specific critical questions. Helps strengthen the paper before submission.
disable-model-invocation: true
argument-hint: "[topic, design choice, or methodology to challenge]"
allowed-tools: ["Read", "Grep", "Glob"]
---

## Devil's Advocate

Critically examine a research design, methodology, or assumption with 5-7 specific challenges.

### Steps

1. **Understand the target**: Read `$ARGUMENTS` and any relevant project files (CLAUDE.md, manuscript, estimation code).

2. **Generate 5-7 challenges** from these categories:
   - **Identification:** Could the causal claim be undermined by [specific threat]?
   - **Specification:** What if the functional form is wrong? Alternative specifications?
   - **Data:** Are there sample selection issues? Measurement error concerns?
   - **Methodology:** Could a different estimator give different results? Why this method?
   - **Assumptions:** Which assumptions are most vulnerable? What if they're violated?
   - **Robustness:** What robustness checks are missing?
   - **External validity:** Does this generalize beyond the sample?

3. **For each challenge**, provide:
   - The question
   - Why it matters
   - Suggested resolution or robustness check
   - Severity (Critical / Major / Minor)

4. **Summary verdict**: Strengths, critical changes needed, and suggested improvements.

### Notes
- Be constructive, not destructive.
- Think like a skeptical referee at a top journal.
- Focus on the most impactful challenges first.

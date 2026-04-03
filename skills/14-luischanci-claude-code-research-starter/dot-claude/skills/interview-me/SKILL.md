---
name: interview-me
description: Interactive interview to formalize a research idea into a structured specification with hypotheses and empirical strategy.
disable-model-invocation: true
argument-hint: "[brief topic or 'start fresh']"
allowed-tools: ["Read", "Write"]
---

## Research Interview

Conduct a structured interview through 6 phases to formalize a research idea.

### Interview Phases

1. **The Big Picture** -- What phenomenon or puzzle are you investigating? Why does it matter?
2. **Theoretical Motivation** -- What's your intuition for the mechanism? What does theory predict?
3. **Data and Setting** -- What data do you have? What specific context or time period?
4. **Identification** -- Any natural experiments or policy changes? What are the threats to causality?
5. **Expected Results** -- What do you predict? What are the implications for policy or theory?
6. **Contribution** -- How does this differ from existing work? What's the value-added?

### Protocol

- Ask questions **one at a time** (no multi-question dumps)
- Probe deeper based on answers -- follow up on weak spots
- Be curious, not prescriptive
- Know when to stop (after 5-8 meaningful exchanges)

### Output

After the interview, produce a **Research Specification Document**:

```markdown
# Research Specification: [Topic]

## Research Question
[Clear, specific, answerable]

## Motivation
[Why this matters -- policy relevance, theoretical gap, empirical puzzle]

## Hypothesis
[Testable prediction with expected sign/magnitude]

## Empirical Strategy
- **Method:** [DiD, IV, RDD, etc.]
- **Treatment/Variation:** [What provides identification]
- **Control group:** [Comparison group]
- **Identifying assumption:** [What must hold]
- **Robustness checks:** [Planned sensitivity analyses]

## Data
[Sources, sample, key variables, time period]

## Expected Results
[What you expect to find and why]

## Contribution
[How this advances the literature]

## Open Questions
[What remains uncertain]
```

Save to `quality_reports/research_spec_[sanitized_topic].md`.

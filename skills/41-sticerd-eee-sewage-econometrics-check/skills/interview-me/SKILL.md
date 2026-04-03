---
name: interview-me
description: Structured conversational interview to formalise a research idea or extension into a concrete specification with hypotheses and empirical strategy. This skill should be used when asked to "interview me", "help me think through an idea", "formalise this idea", or "start fresh" on a new research direction.
argument-hint: "[brief topic or 'start fresh']"
allowed-tools: ["Read", "Write"]
---

# Research Interview

Conduct a structured interview to help formalise a research idea into a concrete specification.

**Input:** `$ARGUMENTS` — a brief topic description or "start fresh" for an open-ended exploration.

---

## How This Works

This is a **conversational** skill. Ask questions one at a time, probe deeper based on answers, and build toward a structured research specification.

Ask questions directly in text responses, one or two at a time. Wait for the user to respond before continuing.

---

## Interview Structure

### Phase 1: The Big Picture (1-2 questions)
- "What phenomenon or puzzle are you trying to understand?"
- "Why does this matter? Who should care about the answer?"

### Phase 2: Theoretical Motivation (1-2 questions)
- "What's your intuition for why X happens / what drives Y?"
- "What would standard theory predict? Do you expect something different?"

### Phase 3: Data and Setting (1-2 questions)
- "What data do you have access to, or what data would you ideally want?"
- "Is there a specific context, time period, or institutional setting you're focused on?"

For this project, also probe:
- Can this be answered with the existing EDM + Land Registry + Zoopla data?
- Does this require new data (e.g. water company financials, bathing water quality, health data)?

### Phase 4: Identification (1-2 questions)
- "Is there a natural experiment, policy change, or source of variation you can exploit?"
- "What's the biggest threat to a causal interpretation?"

### Phase 5: Expected Results (1-2 questions)
- "What would you expect to find? What would surprise you?"
- "What would the results imply for policy or theory?"

### Phase 6: Contribution (1 question)
- "How does this differ from what's already been done? What's the gap you're filling?"

---

## After the Interview

Once enough information is gathered (typically 5-8 exchanges), produce:

### Research Specification Document

```markdown
# Research Specification: [Title]
**Date:** YYYY-MM-DD

## Research Question
[Clear, specific question in one sentence]

## Motivation
[2-3 paragraphs: why this matters, theoretical context, policy relevance]

## Hypothesis
[Testable prediction with expected direction]

## Empirical Strategy
- **Method:** [e.g., Difference-in-Differences]
- **Treatment:** [What varies]
- **Control:** [Comparison group]
- **Key identifying assumption:** [What must hold]
- **Robustness checks:** [Pre-trends, placebo tests, etc.]

## Data
- **Primary dataset:** [Name, source, coverage]
- **Key variables:** [Treatment, outcome, controls]
- **Sample:** [Unit of observation, time period, N]
- **Available in project:** [Yes/No — what exists vs what's needed]

## Expected Results
[What the researcher expects to find and why]

## Contribution
[How this advances the literature — 2-3 sentences]

## Open Questions
[Issues raised during the interview that need further thought]

## Feasibility Assessment
- Data availability: [Ready / Partially available / Needs collection]
- Infrastructure reuse: [What from the existing pipeline can be reused]
- Estimated effort: [Low / Medium / High]
```

Save to `output/log/research_spec_[topic].md`.

---

## Interview Style

- **Be curious, not prescriptive.** Draw out the researcher's thinking, don't impose ideas.
- **Probe weak spots gently.** "What would a sceptic say about...?" rather than "This won't work."
- **Build on answers.** Each question should follow from the previous response.
- **Know when to stop.** If the researcher has a clear vision after 4-5 exchanges, move to the specification.
- **Project-aware.** Connect ideas to the existing sewage project infrastructure where relevant.

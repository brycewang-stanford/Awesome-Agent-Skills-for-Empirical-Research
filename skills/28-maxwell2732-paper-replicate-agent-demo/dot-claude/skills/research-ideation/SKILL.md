---
name: research-ideation
description: Generate structured research questions, testable hypotheses, and empirical strategies from a topic or dataset
disable-model-invocation: true
argument-hint: "[topic, phenomenon, or dataset description]"
allowed-tools: ["Read", "Grep", "Glob", "Write"]
---

# Research Ideation

Generate structured research questions, testable hypotheses, and empirical strategies from a topic, phenomenon, or dataset.

**Input:** `$ARGUMENTS` — a topic (e.g., "minimum wage effects on employment"), a phenomenon (e.g., "why do firms cluster geographically?"), or a dataset description (e.g., "panel of US counties with pollution and health outcomes, 2000-2020").

---

## Steps

1. **Understand the input.** Read `$ARGUMENTS` and any referenced files. Check `master_supporting_docs/` for related papers. Check `.claude/rules/` for domain conventions.

2. **Generate 3-5 research questions** ordered from descriptive to causal:
   - **Descriptive:** What are the patterns? (e.g., "How has X evolved over time?")
   - **Correlational:** What factors are associated? (e.g., "Is X correlated with Y after controlling for Z?")
   - **Causal:** What is the effect? (e.g., "What is the causal effect of X on Y?")
   - **Mechanism:** Why does the effect exist? (e.g., "Through what channel does X affect Y?")
   - **Policy:** What are the implications? (e.g., "Would policy X improve outcome Y?")

3. **For each research question, develop:**
   - **Hypothesis:** A testable prediction with expected sign/magnitude
   - **Identification strategy:** How to establish causality (DiD, IV, RDD, synthetic control, etc.)
   - **Data requirements:** What data would be needed? Is it available?
   - **Key assumptions:** What must hold for the strategy to be valid?
   - **Potential pitfalls:** Common threats to identification
   - **Related literature:** 2-3 papers using similar approaches

4. **Rank the questions** by feasibility and contribution.

5. **Save the output** to `quality_reports/research_ideation_[sanitized_topic].md`

---

## Output Format

```markdown
# Research Ideation: [Topic]

**Date:** [YYYY-MM-DD]
**Input:** [Original input]

## Overview

[1-2 paragraphs situating the topic and why it matters]

## Research Questions

### RQ1: [Question] (Feasibility: High/Medium/Low)

**Type:** Descriptive / Correlational / Causal / Mechanism / Policy

**Hypothesis:** [Testable prediction]

**Identification Strategy:**
- **Method:** [e.g., Difference-in-Differences]
- **Treatment:** [What varies and when]
- **Control group:** [Comparison units]
- **Key assumption:** [e.g., Parallel trends]

**Data Requirements:**
- [Dataset 1 — what it provides]
- [Dataset 2 — what it provides]

**Potential Pitfalls:**
1. [Threat 1 and possible mitigation]
2. [Threat 2 and possible mitigation]

**Related Work:** [Author (Year)], [Author (Year)]

---

[Repeat for RQ2-RQ5]

## Ranking

| RQ | Feasibility | Contribution | Priority |
|----|-------------|-------------|----------|
| 1  | High        | Medium      | ...      |
| 2  | Medium      | High        | ...      |

## Suggested Next Steps

1. [Most promising direction and immediate action]
2. [Data to obtain]
3. [Literature to review deeper]
```

---

## Principles

- **Be creative but grounded.** Push beyond obvious questions, but every suggestion must be empirically feasible.
- **Think like a referee.** For each causal question, immediately identify the identification challenge.
- **Consider data availability.** A brilliant question with no available data is not actionable.
- **Suggest specific datasets** where possible (FRED, Census, PSID, administrative data, etc.).

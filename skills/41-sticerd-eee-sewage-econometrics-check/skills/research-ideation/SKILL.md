---
name: research-ideation
description: Generate structured research questions, hypotheses, and empirical strategies from a topic or dataset within the sewage/environmental economics space. This skill should be used when asked to "brainstorm research questions", "what else can we do with this data", "research ideas", or "ideation".
argument-hint: "[topic, phenomenon, dataset, or 'extensions']"
allowed-tools: ["Read", "Grep", "Glob", "Write"]
---

# Research Ideation

Generate structured research questions, testable hypotheses, and empirical strategies from a topic, phenomenon, or dataset.

**Input:** `$ARGUMENTS` — a topic, phenomenon, dataset description, or `extensions` to brainstorm extensions of the current paper.

---

## Project-Specific Context

### Available Data
- **EDM data (2021-2024+):** Event-level sewage spill records for all overflow sites in England
- **Land Registry:** Universe of property transactions (prices, dates, postcodes)
- **Zoopla:** Rental listings with prices and characteristics
- **Met Office:** Daily rainfall at LSOA level
- **River networks:** PostGIS topology of English waterways
- **Annual returns:** Water company infrastructure data (sewer capacity, population served)
- **Geographic boundaries:** LSOAs, MSOAs, constituencies, water company areas

### Existing Identification Strategies
Hedonic, repeat sales, long difference, DiD with media coverage, upstream/downstream, dry spills, hydraulic capacity IV

### Related Literature Areas
Environmental disamenity capitalisation, water quality and property values, UK water industry regulation, infrastructure and house prices, information and price discovery

---

## Workflow

### Step 1: Understand the Input

Read `$ARGUMENTS` and any referenced files.
- If `extensions`: read current manuscript sections and analysis scripts to understand what's been done
- If a topic: ground it in the available data and methods

### Step 2: Generate 3-5 Research Questions

Order from descriptive to causal:

- **Descriptive:** What are the patterns? (e.g. "How do spill frequencies vary across water companies?")
- **Correlational:** What factors are associated? (e.g. "Is sewer age correlated with spill frequency after controlling for rainfall?")
- **Causal:** What is the effect? (e.g. "What is the causal effect of media coverage of sewage spills on house prices?")
- **Mechanism:** Why does the effect exist? (e.g. "Do dry spills affect prices through stigma or physical damage?")
- **Policy:** What are the implications? (e.g. "Would mandated real-time spill disclosure affect property markets?")

### Step 3: Develop Each Question

For each:
- **Hypothesis:** Testable prediction with expected sign/magnitude
- **Identification strategy:** How to establish causality
- **Data requirements:** What data is needed — is it available in the project?
- **Key assumptions:** What must hold
- **Potential pitfalls:** Threats to identification
- **Related literature:** 2-3 papers using similar approaches

### Step 4: Rank by Feasibility and Contribution

| RQ | Feasibility | Contribution | Priority |
|----|-------------|-------------|----------|
| 1 | High/Med/Low | High/Med/Low | ... |

### Step 5: Save Output

```markdown
# Research Ideation: [Topic]
**Date:** YYYY-MM-DD

## Overview
[1-2 paragraphs situating the topic]

## Research Questions

### RQ1: [Question] (Feasibility: High/Medium/Low)
**Type:** Descriptive / Correlational / Causal / Mechanism / Policy
**Hypothesis:** [Prediction]
**Identification:** [Method + key assumption]
**Data:** [What's needed and what's available]
**Pitfalls:** [Top 2 threats]
**Related work:** [2-3 papers]

## Ranking
[Table]

## Suggested Next Steps
1. [Most promising direction]
2. [Data to obtain or analysis to run]
3. [Literature to review]
```

Save to `output/log/research_ideation_[topic].md`.

---

## Principles

- **Be creative but grounded.** Every suggestion must be empirically feasible with available or obtainable data.
- **Think like a referee.** For each causal question, immediately identify the identification challenge.
- **Leverage existing infrastructure.** The project already has spatial matching, spill aggregation, and river network tools — build on them.
- **Consider data availability.** Flag when data is already available vs needs to be obtained.
- **Extensions are valuable.** For `extensions`, focus on questions that use the same data infrastructure but ask different questions.

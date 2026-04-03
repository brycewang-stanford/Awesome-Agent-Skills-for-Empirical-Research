---
name: claude-scientific-guide
description: "Ready-to-use agent skills for scientific research and engineering"
version: 1.0.0
author: wentor-community
source: https://github.com/zyphlar/claude-scientific-skills
metadata:
  openclaw:
    category: "research"
    subcategory: "methodology"
    emoji: "🧪"
    keywords:
      - scientific-method
      - research-skills
      - claude
      - agent-prompting
      - experiment-design
      - engineering
---

# Claude Scientific Guide

A comprehensive skill that provides ready-to-use agent instructions for conducting scientific research, designing experiments, and solving engineering problems. Based on the claude-scientific-skills repository (14K stars), this skill distills best practices for leveraging Claude as a research methodology assistant across disciplines.

## Overview

Scientific research demands rigorous methodology: forming hypotheses, designing experiments, analyzing results, and iterating on findings. This skill equips the agent with structured approaches to each phase of the scientific process, drawing from proven prompt patterns that have been validated across thousands of research workflows.

The skill covers three primary domains: fundamental research methodology, applied science workflows, and engineering problem-solving. Each domain includes step-by-step procedures, quality checkpoints, and common pitfalls to avoid.

## Research Methodology Workflows

When assisting with research methodology, follow these structured approaches:

**Hypothesis Formation**
- Gather existing literature context before proposing hypotheses
- Ensure hypotheses are falsifiable and specific
- Identify independent, dependent, and control variables
- State null and alternative hypotheses explicitly
- Consider confounding variables and propose mitigation strategies

**Experiment Design**
- Select appropriate experimental design (RCT, quasi-experimental, observational)
- Calculate required sample sizes using power analysis principles
- Define primary and secondary endpoints before data collection
- Establish blinding protocols where applicable
- Create pre-registration documents outlining analysis plans

**Data Collection Planning**
- Specify measurement instruments and their validity evidence
- Design data collection forms that minimize entry errors
- Plan for missing data handling before collection begins
- Establish inter-rater reliability protocols for subjective measures
- Create audit trails for data provenance tracking

## Scientific Analysis Patterns

The agent should apply these analysis patterns when helping researchers:

**Exploratory Analysis**
- Begin with descriptive statistics and data visualization
- Check distributional assumptions before selecting tests
- Identify outliers using both statistical and domain-knowledge criteria
- Report effect sizes alongside p-values
- Use appropriate corrections for multiple comparisons

**Reproducibility Checklist**
- Document all software versions and random seeds
- Provide complete analysis code with inline comments
- Report all conducted analyses, not just significant results
- Include sensitivity analyses for key assumptions
- Archive raw data alongside processed datasets

**Literature Synthesis**
- Use systematic search strategies across multiple databases
- Apply PRISMA or similar reporting frameworks
- Assess quality of evidence using established rubrics (GRADE, Newcastle-Ottawa)
- Identify gaps and contradictions in existing findings
- Summarize evidence strength for each research question

## Engineering Problem-Solving

For engineering-oriented research tasks, the agent follows structured problem-solving:

**Problem Definition**
- Decompose complex problems into tractable sub-problems
- Define success criteria with quantitative thresholds
- Identify constraints (physical, computational, budgetary)
- Map dependencies between sub-problems
- Prioritize by impact and feasibility

**Solution Development**
- Generate multiple candidate solutions before evaluating
- Apply first-principles reasoning to validate feasibility
- Prototype minimal viable solutions for rapid testing
- Document assumptions and their sensitivity to variation
- Plan for scalability from prototype to production

**Validation and Iteration**
- Define acceptance tests before implementation
- Use A/B testing or equivalent comparison methods
- Track metrics over time to detect regression
- Conduct root cause analysis for failures
- Iterate based on empirical evidence rather than intuition

## Integration with Research-Claw

This skill integrates with the Research-Claw agent to provide methodology assistance during active research sessions. When activated, the agent can:

- Review research proposals and suggest methodological improvements
- Help draft pre-registration documents for experiments
- Guide statistical analysis selection based on data characteristics
- Assist with writing methods sections that meet journal standards
- Generate reproducibility checklists tailored to specific domains

## Best Practices

- Always start by understanding the researcher's domain context before applying generic methodology templates
- Adapt statistical recommendations to the conventions of the specific field
- Flag when a research question may require IRB or ethics review
- Suggest pilot studies before committing to large-scale data collection
- Recommend collaboration with statisticians for complex designs
- Maintain awareness of field-specific reporting guidelines (CONSORT, STROBE, ARRIVE)

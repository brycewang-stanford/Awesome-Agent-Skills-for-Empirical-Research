---
name: research-ideation
description: Generate structured research questions, testable hypotheses, and empirical strategies from a topic or dataset.
disable-model-invocation: true
argument-hint: "[topic, phenomenon, or dataset description]"
allowed-tools: ["Read", "Grep", "Glob", "Write"]
---

## Research Ideation

Generate 3-5 research questions ordered from descriptive to causal.

### Steps

1. **Understand context**: Read CLAUDE.md and any relevant project files.

2. **Generate 3-5 research questions** ordered by type:
   - **Descriptive:** What are the stylized facts?
   - **Correlational:** What patterns exist in the data?
   - **Causal:** What is the effect of X on Y?
   - **Mechanism:** Through what channel does X affect Y?
   - **Policy:** What are the policy implications?

3. **For each question**, develop:
   - Testable hypothesis with expected sign/magnitude
   - Identification strategy (DiD, IV, RDD, synthetic control, matching, etc.)
   - Data requirements with availability assessment
   - Key assumptions and their plausibility
   - Potential pitfalls and how to address them
   - 2-3 related papers

4. **Rank questions** by feasibility and contribution in a summary table.

5. **Save output** to `quality_reports/research_ideation_[sanitized_topic].md`.

### Principles
- Be creative but grounded in what's feasible
- Think like a referee: what would make this convincing?
- Consider data availability realistically
- Suggest specific datasets (FRED, Census, PSID, BLS, central bank data, etc.)

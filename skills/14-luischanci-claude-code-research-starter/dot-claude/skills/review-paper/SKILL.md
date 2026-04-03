---
name: review-paper
description: Comprehensive manuscript review covering argument structure, identification strategy, econometric specification, citation completeness, and potential referee objections.
disable-model-invocation: true
argument-hint: "[paper filename in master_supporting_docs/ or path to .tex/.pdf]"
allowed-tools: ["Read", "Grep", "Glob", "Write", "Task"]
---

## Review Paper

Produce a thorough referee-style review of an academic manuscript.

### Steps

1. **Identify the paper**: Use `$ARGUMENTS`. Check `master_supporting_docs/supporting_papers/` or the paper folder.

2. **Evaluate across 6 dimensions** (rate each 1-5):
   - **Argument Structure:** Research question clarity, logical flow, evidence support, limitations acknowledged
   - **Identification Strategy:** Causal claim credibility, identifying assumptions stated, threats discussed, robustness checks proposed
   - **Econometric Specification:** Standard errors appropriate, functional form justified, sample selection discussed, multiple testing addressed, economic meaningfulness vs statistical significance
   - **Literature Positioning:** Key citations present, accurate characterization, clear differentiation, missing citations identified
   - **Writing Quality:** Clarity, tone, notation consistency, abstract quality, self-contained tables/figures
   - **Presentation:** Table/figure design, notation consistency across sections, typos, paper length

3. **Generate 3-5 likely referee objections** with suggested responses.

4. **Overall recommendation:** Strong Accept / Accept / Revise & Resubmit / Reject.

5. **Save report** to `quality_reports/paper_review_[sanitized_name].md`.

### Notes
- Be constructive. Identify strengths alongside weaknesses.
- Distinguish CRITICAL (math wrong) from MAJOR (missing discussion) from MINOR (could be clearer).

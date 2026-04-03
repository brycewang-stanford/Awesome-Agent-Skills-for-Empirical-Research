---
name: workflows:ideate
description: "Divergent research ideation — generate many candidate directions, then adversarially filter to the strongest"
argument-hint: "<research question, puzzle, or data opportunity>"
allowed-tools: Read, Glob, Bash
---

# Research Ideation

Divergent exploration before convergent brainstorming. Generate many candidates, then filter ruthlessly.

## Phase 0: Scope the Ideation

Read $ARGUMENTS. If the user provides a specific research question, ideate around it. If they provide a broad topic, explore broadly.

## Phase 1: Generate Candidates (Divergent)

Generate 15-20 candidate research directions. Use these research-adapted ideation frames:

1. **Identification weakness** — What existing results have weak identification? What new variation could fix it?
2. **Computational bottleneck** — What problems are infeasible with current methods but tractable with new estimators or hardware?
3. **Data limitation workaround** — What would become possible with data that is now available but underexploited?
4. **Alternative estimator class** — What if the standard approach (e.g., linear IV) were replaced with a different class (e.g., ML, structural, Bayesian)?
5. **Relaxed assumption** — What results depend on assumptions that could be relaxed? What happens when you relax them?
6. **Literature gap** — What do practitioners need that academics haven't provided? What do adjacent fields know that this field doesn't?

Dispatch `methods-explorer` and `literature-scout` agents in parallel to ground the ideation in real methods and recent papers.

**Iron rule:** Generate the full candidate list before critiquing any idea. Push past the first few obvious directions.

## Phase 2: Adversarial Filter (Convergent)

**Entry condition:** Phase 1 produced at least 15 candidate directions (the iron rule).
**Exit condition:** 5-7 survivors identified, all rejected candidates have one-line rejection reasons.

For each candidate, evaluate:
- **Feasibility** (0-100): Can this be done with available data, methods, and time?
- **Contribution** (0-100): Would a top journal care about this result?
- **Identification** (0-100): Is there a credible identification strategy?

Dispatch `identification-critic` to attack the top 10 candidates. Only candidates surviving adversarial scrutiny advance.

**Target:** 5-7 survivors with explicit rejection reasons for all others.

## Phase 3: Output

Write the ideation document to `docs/ideation/` with YAML frontmatter:
```yaml
---
status: complete
date: YYYY-MM-DD
topic: <descriptive topic>
candidates_generated: <N>
survivors: <N>
---
```

Content:
- Surviving candidates ranked by (Contribution x Identification x Feasibility)
- For each survivor: 2-3 sentence description, confidence score, key risk
- Rejected candidates with one-line rejection reason
- Recommended next step: `/workflows:brainstorm` on the top 1-2 candidates

## Handoff

End with: "Ideation complete. Run `/workflows:brainstorm [top candidate]` to develop requirements for the strongest direction."

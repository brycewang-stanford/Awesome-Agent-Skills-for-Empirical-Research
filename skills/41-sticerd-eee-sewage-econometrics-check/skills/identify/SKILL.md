---
name: identify
description: Design or review identification strategy for the sewage-house-prices project. Produces strategy memos with estimand, assumptions, pseudo-code, robustness plan, falsification tests, and referee objection anticipation. This skill should be used when asked to "design the strategy", "identify the effect", "write a strategy memo", or "think through identification".
argument-hint: "[research question, approach name, or 'review existing']"
allowed-tools: ["Read", "Grep", "Glob", "Write", "Agent"]
---

# Identification Strategy

Design or review an identification strategy for the sewage-house-prices project.

**Input:** `$ARGUMENTS` — a research question, approach name (e.g. "hedonic", "dry spills"), or "review existing" to audit all current strategies.

---

## Project-Specific Context

### Existing Strategies

1. **Hedonic** — Cross-sectional: `log(price) ~ spill_metrics + controls | lsoa + year_quarter`. Assumption: spill exposure is conditionally exogenous given LSOA FE.
2. **Repeat sales** — Within-property: `Δlog(price) ~ Δspill_metrics | house_id`. Eliminates time-invariant unobservables.
3. **Long difference** — Grid-level: changes in average prices within 250m grids. Eliminates level differences.
4. **News/media DiD** — Treatment = post-media-coverage × exposure. Tests whether information matters for capitalisation.
5. **Upstream/downstream** — River network topology via PostGIS. Downstream sites receive upstream pollution. Tests directionality.
6. **Dry spills** — Spills without rainfall. If dry spills affect prices, suggests awareness/stigma channel over physical damage.
7. **Hydraulic capacity instrument** — Planned IV using sewer capacity as instrument for spill frequency.

### Key Data Features
- EDM data: 2021-2024+, high-frequency (event-level)
- Land Registry: universe of transactions
- Zoopla: rental listings
- Met Office: daily rainfall at LSOA level
- River networks: PostGIS topology
- Treatment radii: 250m, 500m, 1000m, 2000m, 5000m, 10000m

---

## Workflow

### Step 1: Context Gathering

1. Read existing manuscript sections in `docs/overleaf/` for how strategies are currently described
2. Read relevant analysis scripts in `scripts/R/09_analysis/`
3. Read `scripts/R/utils/spill_aggregation_utils.R` for treatment construction
4. Check `docs/overleaf/refs.bib` for methodological references

### Step 2: Strategy Development

For a new or revised strategy, produce:

1. **Strategy memo** — Design choice, estimand (ATT/ATE/LATE), key assumptions, comparison group
2. **Estimating equation** — LaTeX-formatted with clear variable definitions
3. **Pseudo-code** — Implementation sketch (what the R code will do)
4. **Robustness plan** — Ordered list with rationale:
   - Radius sensitivity (250m → 10km)
   - Time period variation (prior period vs full period)
   - Alternative treatment measures (count vs hours vs binary)
   - Subsample analysis (sales vs rentals, urban vs rural)
5. **Falsification tests** — What SHOULD NOT show effects and why
6. **Referee objection anticipation** — Top 5 objections with pre-emptive responses

### Step 3: Strategy Review

If reviewing an existing strategy:

#### Phase 1: Claim Identification
- What is the claimed design?
- What is the estimand?
- What is the treatment / comparison?

#### Phase 2: Core Design Validity
- Are identifying assumptions stated and defensible?
- Are the biggest threats acknowledged?
- Does the specification match the stated design?

#### Phase 3: Robustness Assessment
- Does the robustness plan address the right concerns?
- Are falsification tests well-chosen?
- Is there radius sensitivity analysis?

### Step 4: Present Results

```markdown
# Identification Strategy: [Approach]
**Date:** YYYY-MM-DD
**Design:** [Hedonic / Repeat Sales / Long Diff / DiD / IV / etc.]
**Estimand:** [ATT / ATE / LATE]

## Strategy Summary
[2-3 sentence description]

## Estimating Equation
$$\log(p_{it}) = \alpha + \beta \cdot \text{SpillMetric}_{it} + \gamma X_{it} + \mu_i + \delta_t + \varepsilon_{it}$$

## Key Assumptions
1. [Assumption 1] — [defense]
2. [Assumption 2] — [defense]

## Assessment: [SOUND / CONCERNS / CRITICAL ISSUES]

## Robustness Plan (ordered)
1. [Most important check]
2. [Second check]
...

## Falsification Tests
1. [Test 1] — [expected null and why]

## Anticipated Referee Objections
1. [Objection] — [Response]

## Next Steps
- [ ] Implement main specification
- [ ] Run falsification tests
- [ ] Generate pre-trend evidence
```

Save to `output/log/strategy_memo_[approach].md`.

---

## Principles

- **Catch problems before coding.** A flawed strategy caught now saves weeks of wasted analysis.
- **Multiple strategies are strength.** This paper uses 6+ approaches — consistency across them is the key argument.
- **Cross-reference approaches.** Each strategy should address threats the others cannot.
- **The user decides.** Present trade-offs, don't make choices unilaterally.
- **Strategy memo is the contract.** Once approved, analysis scripts implement it faithfully.

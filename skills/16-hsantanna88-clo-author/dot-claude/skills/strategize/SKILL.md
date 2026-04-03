---
name: strategize
description: Design identification strategy or pre-analysis plan. Dispatches Strategist (proposer) and strategist-critic (validator). Replaces /identify and /pre-analysis-plan.
argument-hint: "[mode: strategy | pap | pap interactive] [research question or spec path]"
allowed-tools: Read,Grep,Glob,Write,Task
---

# Strategize

Design an identification strategy or pre-analysis plan by dispatching the **Strategist** (proposer) and **strategist-critic** (validator).

**Input:** `$ARGUMENTS` — mode keyword followed by research question or path to research spec.

---

## Modes

### `/strategize [question]` or `/strategize strategy [question]` — Identification Strategy
Design the causal identification strategy.

**Agents:** Strategist → strategist-critic
**Output:** Strategy memo + robustness plan + falsification tests

Workflow:
1. Read research spec, literature review, and data assessment if they exist
2. Read .claude/references/domain-profile.md for common identification strategies in the field
3. Dispatch Strategist to produce:
   - Strategy memo: design choice, estimand, assumptions, comparison group
   - Pseudo-code: implementation sketch
   - Robustness plan: ordered list of checks with rationale
   - Falsification tests: what SHOULD NOT show effects
   - Referee objection anticipation: top 5 objections with responses
4. Dispatch strategist-critic to review through 4 phases:
   - Phase 1: Claim identification (design, estimand, treatment, control)
   - Phase 2: Core design validity (assumption checks, sanity checks)
   - Phase 3: Inference soundness (clustering, multiple testing)
   - Phase 4: Polish and completeness (robustness, citations)
5. If CRITICAL issues found, iterate (max 3 rounds per three-strikes)
6. Save memo to `quality_reports/strategy_memo_[topic].md`
7. Save review to `quality_reports/strategy_memo_[topic]_review.md`

### `/strategize pap [spec]` — Pre-Analysis Plan
Draft a pre-analysis plan following AEA/OSF/EGAP standards.

**Input:** `$ARGUMENTS` — path to research spec file, a topic, or `interactive` for guided interview.

- If `$ARGUMENTS` includes a file path: read it (research spec from `/discover interview`)
- If `$ARGUMENTS` includes `interactive`: conduct the guided PAP interview (see below)
- Otherwise: treat as topic and draft with ASSUMED placeholders marked clearly

**Agents:** Strategist (in PAP mode), optionally strategist-critic
**Output:** Pre-analysis plan document

#### Interactive PAP Interview (6-Question Guided Flow)

When invoked as `/strategize pap interactive`, ask these questions one at a time before drafting:

1. **What is the research question?**
2. **What is the study design?** (RCT / natural experiment / quasi-experimental / observational)
3. **What are the primary outcome variables?** (names, measurement, data source)
4. **What is the identification strategy?** (randomization mechanism / treatment assignment / source of variation)
5. **What subgroup analyses are pre-specified?** (with justification for each)
6. **What multiple testing concerns exist?** (number of primary outcomes, family-wise error rate plan)

After all 6 answers are collected, proceed to PAP drafting.

#### PAP Sections

Dispatch Strategist in PAP mode to produce all standard sections:

1. **Study overview** — research question, design, treatment, control
2. **Outcomes** — primary, secondary, mechanism variables with measurement details
3. **Estimating equations** — with full notation protocol
4. **Subgroup analyses** — pre-specified, with justification for each
5. **Multiple testing correction** — Bonferroni / Benjamini-Hochberg / Romano-Wolf (specify which and why)
6. **Power calculations** — MDE, baseline statistics, sample size, assumptions stated explicitly with sensitivity
7. **Sample and exclusion rules** — inclusion criteria, attrition handling, outlier treatment
8. **Data and analysis** — sources, software, randomization/assignment mechanism
9. **Timeline** — data collection, analysis, registration dates
10. **Deviations log** — empty template for tracking post-registration changes

#### Platform-Specific PAP Templates

Ask the user which registry platform they plan to use (if unclear from context):

**AEA RCT Registry:**
- Most structured format. All fields required.
- Must be registered before intervention begins.
- Strict section ordering: hypotheses → outcomes → analysis → power.
- Requires IRB information and funding sources.

**OSF (Open Science Framework):**
- More flexible format. Good for observational studies and natural experiments.
- Allows iterative updates with version history.
- Less rigid section structure — can adapt to study design.
- Supports pre-registration of observational/archival studies.

**EGAP (Evidence in Governance and Politics):**
- Development economics and political science focused.
- Additional governance and ethics questions required.
- Emphasizes pre-specification of heterogeneous treatment effects.
- Requires description of implementing partners and field conditions.

#### Observational Study PAP Adaptation

For observational, quasi-experimental, or natural experiment designs, adapt the PAP template:

- **Identification strategy replaces randomization** — describe the source of exogenous variation
- **Comparison group replaces control group** — define who is compared to whom and why
- **Identification assumption discussion** — explicitly state and defend each assumption
- **Placebo and falsification tests** — pre-specify what SHOULD NOT show effects
- **Robustness to specification choices** — pre-commit to bandwidth, functional form, sample restrictions
- **Treatment of endogeneity concerns** — document known threats and planned diagnostics

#### ASSUMED Placeholder Safety

**CRITICAL: Flag every ASSUMED item clearly. The researcher must review and approve before registration.**

When drafting a PAP from a topic (without a full research spec or interactive interview), many details will be assumed. For each assumed item:

- Mark it with `[ASSUMED]` in bold
- Explain what was assumed and why
- Provide the most reasonable default but flag it for review

A registered PAP with unchecked assumptions is worse than no PAP. The final section of every PAP must include:

```markdown
## Pre-Registration Checklist

**Review every [ASSUMED] item before registering this plan.**

- [ ] [ASSUMED] Item 1 — [what was assumed]
- [ ] [ASSUMED] Item 2 — [what was assumed]

**Do not register until all items are reviewed and confirmed or corrected.**
```

#### Optional strategist-critic Review

After PAP creation, optionally dispatch the strategist-critic to review:
- Are identification assumptions clearly stated and defensible?
- Is the estimator choice appropriate for the design?
- Are power calculation assumptions reasonable? Show sensitivity.
- Are pre-specified subgroups justified (not fishing)?
- Are multiple testing corrections appropriate?
- Are any [ASSUMED] items potentially problematic if left uncorrected?

Save review to `quality_reports/pre_analysis_plan_[topic]_review.md`

Save PAP to `quality_reports/pre_analysis_plan_[topic].md`

---

## Principles

- **Strategist proposes, strategist-critic critiques.** Adversarial pairing catches design flaws early.
- **Strategy memo is the contract.** Once approved, the Coder implements it faithfully.
- **Catch problems before coding.** A flawed strategy caught now saves weeks of wasted analysis.
- **Multiple strategies are OK.** Present trade-offs and let the user choose.
- **The user decides.** If Strategist and strategist-critic disagree after 3 rounds, the user resolves it.
- **Pre-specification is the point.** Everything in a PAP is decided before seeing outcomes.
- **Be honest about what's exploratory.** Label subgroups and secondary outcomes clearly.
- **Power calculations require assumptions.** State every assumption. Show sensitivity.
- **A PAP is a commitment device.** Make sure the researcher understands what they're committing to.

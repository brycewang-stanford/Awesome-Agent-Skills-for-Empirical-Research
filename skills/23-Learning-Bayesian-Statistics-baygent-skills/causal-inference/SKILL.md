---
name: causal-inference
description: >
  Production-grade Bayesian causal inference with PyMC, CausalPy, and DoWhy. Enforces DAG-first
  thinking, mandatory user checkpoints for assumptions, design-specific refutation, and defensible
  reporting with causal language guardrails. Trigger on: causal inference, causal effect estimation,
  treatment effects, counterfactuals, difference-in-differences (DiD), synthetic control, regression
  discontinuity (RDD), interrupted time series (ITS), instrumental variables (IV), propensity scores,
  DAGs, causal graphs, confounders, backdoor criterion, do-calculus, interventional distributions,
  pm.do(), pm.observe(), CausalPy, DoWhy, mediation analysis, refutation, sensitivity analysis,
  parallel trends, placebo tests, or any question of the form "does X cause Y" or "what is the
  effect of X on Y."
license: MIT
metadata:
  author: "[Alexandre Andorra](https://alexandorra.github.io/)"
  version: "1.0"
---

# Causal Inference

## Dependencies

This skill requires the **bayesian-workflow** skill for all PyMC modeling steps (priors, sampling,
diagnostics, calibration, reporting).

Detect it:

```bash
ls ~/.claude/skills/bayesian-workflow/SKILL.md 2>/dev/null || ls .claude/skills/bayesian-workflow/SKILL.md 2>/dev/null
```

If not found, install it:

```bash
git clone https://github.com/Learning-Bayesian-Statistics/baygent-skills.git /tmp/baygent-skills
cp -r /tmp/baygent-skills/bayesian-workflow ~/.claude/skills/
```

For all PyMC modeling steps (priors, sampling, diagnostics, calibration, reporting), follow the
bayesian-workflow skill.

## Workflow overview

Every causal analysis follows this sequence. Steps 1-4 are the thinking phase (no code). Steps 5-8
are the doing phase. Think before you do.

1. **Formulate the causal question** — Propose precise estimand (ATE, ATT, LATE, etc.). ⚠️ ASK USER TO CONFIRM.
2. **Draw the DAG** — Propose causal graph with nodes, edges, and explicit non-edges. ⚠️ ASK USER TO CONFIRM. See [references/dags-and-identification.md](references/dags-and-identification.md)
3. **Identify** — Determine identification strategy (backdoor, front-door, IV, RDD, DiD). ⚠️ ASK USER TO CONFIRM untestable assumptions. See [references/dags-and-identification.md](references/dags-and-identification.md)
4. **Choose design** — Match problem to method using table below. ⚠️ ASK USER TO CONFIRM. See [references/quasi-experiments.md](references/quasi-experiments.md) or [references/structural-models.md](references/structural-models.md)
5. **Estimate** — Build and fit the model. Delegate all PyMC mechanics to bayesian-workflow skill.
6. **Refute** — MANDATORY. Run design-specific robustness checks. See [references/refutation.md](references/refutation.md)
7. **Interpret** — Effect size + decision-relevant HDIs + probability of direction.
8. **Report** — Generate causal analysis report. See [references/reporting.md](references/reporting.md)

## Design selection guide

| Design | Use when | Key assumption | Tool |
|---|---|---|---|
| DiD | Treatment at known time, control group available | Parallel trends | CausalPy |
| Staggered DiD | Treatment rolls out at different times | Parallel trends per cohort | CausalPy |
| Synthetic Control | Single treated unit, donor pool available | Weighted donors approximate counterfactual | CausalPy |
| ITS | Time series, intervention at known time, no control | No confounding event at treatment time | CausalPy |
| RDD | Treatment by threshold on running variable | No manipulation at threshold | CausalPy |
| IV | Endogenous treatment, valid instrument | Exclusion restriction, relevance | CausalPy |
| IPSW | Observational data, treatment modeled | No unmeasured confounders, positivity | CausalPy |
| Structural (do/observe) | Full causal theory, model mechanisms | Correct DAG specification | PyMC |
| Counterfactual | "What would Y have been if X differed?" | Correct structural model | PyMC |

## Critical rules

- **No estimation without a confirmed DAG.** A causal graph is not optional decoration — it makes
  assumptions explicit and determines the adjustment set. If the user resists, explain why the DAG
  is non-negotiable before proceeding.
- **No causal claims without refutation.** Every design has failure modes. Run at minimum one
  design-specific robustness check (placebo test, sensitivity analysis, falsification test) before
  reporting results. See [references/refutation.md](references/refutation.md).
- **State assumptions before results.** Lead with what must be true for the estimate to be causal.
  Bury the estimate after the assumptions, not before. This is not optional politeness — it prevents
  misuse of results.
- **Adapt HDIs to the decision context.** The bayesian-workflow skill's 94% HDI is a sensible
  default; adapt it with explicit explanation when the decision stakes warrant it (e.g., 89% for
  exploratory, 97% for high-stakes policy). Report multiple intervals when the decision threshold
  matters.
- **Downgrade causal language when warranted.** If identification assumptions are unverifiable or
  refutation raises flags, soften claims: "consistent with a causal effect" not "causes", "estimated
  effect" not "true effect". Flag uncertainty loudly in the report.
- **Ask the user when domain knowledge is needed.** You cannot know whether an instrument is valid,
  whether parallel trends holds, or whether a confounder exists without domain expertise. Ask
  before assuming.
- **Delegate PyMC mechanics to bayesian-workflow.** This skill handles causal structure and design.
  The bayesian-workflow skill handles priors, sampling, diagnostics, calibration, and reporting
  format. Don't duplicate those rules here.

## Common gotchas

These are battle-tested lessons that save hours of debugging:

- **CausalPy formula syntax uses `C()` for categoricals.** Passing a string column directly without
  `C()` will silently produce wrong dummy coding. Always wrap categorical treatment and group
  variables: `"y ~ C(treatment) + C(group)"`.
- **DoWhy requires explicit `U` nodes for unobserved confounders.** Omitting them from the graph
  will make DoWhy treat your model as fully identified when it isn't. Add latent nodes explicitly
  and mark them as unobserved.
- **CausalPy's PyMC models don't auto-store log-likelihood.** Same issue as bayesian-workflow:
  nutpie silently drops it. Call `pm.compute_log_likelihood(idata, model=model)` after sampling if
  you need it for model comparison.
- **Parallel trends is untestable in the post-treatment period.** Pre-treatment trend tests are
  necessary but not sufficient — passing them doesn't prove the assumption holds after treatment.
  State this explicitly in every DiD report.
- **Synthetic control requires the treated unit to lie within the convex hull of donors.** If the
  treated unit is an outlier (highest GDP, largest city), no weighted combination of donors can
  approximate its counterfactual. Check this before running — if violated, the design is invalid.
- **DiD group variable must be dummy-coded (0/1).** CausalPy rejects string labels like "treatment"/"control". Use integers: 1 = treatment, 0 = control. Data also requires a `unit` column.
- **SyntheticControl expects wide-format data.** Index = time, columns = unit names, values = outcome. If your data is long format, pivot first: `df.pivot(index="date", columns="unit", values="outcome")`.

## When things go wrong

| Symptom | Likely cause | Fix |
|---|---|---|
| Refutation fails | Assumption violated | Diagnose which assumption, try alternative design or sensitivity bounds |
| DiD effect at placebo time | Parallel trends violated | Try synthetic control or add group-specific time trends |
| RDD: bunching at threshold | Manipulation of running variable | Design is invalid for this threshold — report and stop |
| SC: poor pre-treatment fit | Donors don't span treated unit | Add donors, expand donor pool, or reconsider design |
| DoWhy says "not identifiable" | Insufficient adjustment set | Revise DAG, add measured variables, or change design |
| CausalPy formula error | Wrong formula syntax | Use `C()` for categoricals, check variable names match dataframe columns |

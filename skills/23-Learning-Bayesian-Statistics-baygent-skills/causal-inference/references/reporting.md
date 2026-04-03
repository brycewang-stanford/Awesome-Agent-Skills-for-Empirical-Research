# Reporting Causal Analyses

## Contents

1. [Causal analysis report template](#causal-analysis-report-template)
2. [Causal language guardrails](#causal-language-guardrails)
3. [Decision-relevant HDIs](#decision-relevant-hdis)
4. [Audience adaptation](#audience-adaptation)
5. [Common reporting mistakes](#common-reporting-mistakes)

---

## Causal analysis report template

Every causal analysis produces a report with this mandatory structure. Adapt sections as needed, but do not drop sections 1, 7, or 8 — they are non-negotiable.

### 1. Causal question

One sentence: "What is the effect of [treatment] on [outcome] in [population]?"

Write this before touching data. If you cannot write this sentence, you do not yet have a causal question — you have a dataset.

### 2. DAG and assumptions

Include the causal graph (generated with `model.plot()` or drawn explicitly) and an assumption transparency table:

| Assumption | Testable? | How fragile? | What if violated? |
|-----------|-----------|-------------|-------------------|
| No unobserved confounders | No | Often fragile | Effect estimate biased in unknown direction |
| Parallel trends (DiD) | Partially (pre-treatment only) | Moderate | Effect estimate biased |
| No anticipation (DiD) | No | Robust if policy unexpected | Effect diluted pre-treatment |
| SUTVA / no spillovers | No | Fragile if units interact | Estimate includes spillovers |
| Exclusion restriction (IV) | No | Very fragile | IV estimate inconsistent |

Every assumption in the table must be discussed — not just listed. For each fragile assumption, state what evidence, if any, supports it.

### 3. Identification strategy

"We use [method] to identify the causal effect. This is valid because [justification]."

Be explicit: which identification result applies (backdoor, frontdoor, IV, RDD continuity, DiD parallel trends)? Which variables are adjusted for and why? Reference `dags-and-identification.md` for identification criteria and `quasi-experiments.md` for design-based methods.

If the effect is not point-identified, say so. Partial identification — bounding the effect rather than pinning it down — is a legitimate and honest result.

### 4. Estimation

State the model specification: likelihood, priors, and any structural constraints. Summarize diagnostics (R-hat, ESS, divergences). Defer to `bayesian-workflow/references/diagnostics.md` for diagnostic standards and thresholds. Do not re-explain those standards here; link to them.

For structural causal models, report the DoWhy estimand and estimation method:

```python
estimate = model.estimate_effect(
    identified_estimand,
    method_name="backdoor.linear_regression",
)
```

### 5. Results with uncertainty

Report effect size with full posterior distribution and multiple HDIs. Never report only a point estimate.

Example:

> "We estimate the policy increased test scores by 4.2 points (50% HDI: [3.1, 5.3]; 95% HDI: [-0.3, 8.9]). The most likely effect is 3–5 points, but we cannot rule out a null effect at 95% credibility. There is an 87% posterior probability the effect is positive."

Include:
- A posterior density plot or forest plot of the causal effect
- The probability of direction: `P(effect > 0)` or `P(effect < threshold)`
- Effect size in domain-relevant units, not just standardized coefficients

### 6. Refutation results

Run all applicable refutation tests and report every result — including failures. Do not cherry-pick passing tests.

| Test | Result | Interpretation |
|------|--------|---------------|
| Placebo treatment (random treatment) | PASS | Random assignment gives near-zero effect |
| Placebo treatment time | PASS | No effect at a time when none should exist |
| Parallel trends (pre-treatment) | PASS | Pre-treatment trends are parallel |
| Random common cause | PASS | Adding a random confounder does not change estimate meaningfully |
| Data subset refutation | PASS | Effect is stable across random subsets |
| Sensitivity to unobserved confounding | E-value = 2.3 | A confounder with RR > 2.3 on both treatment and outcome would explain away the effect |

For DoWhy refutations:

```python
refute = model.refute_estimate(
    identified_estimand,
    estimate,
    method_name="placebo_treatment_refuter",
)
print(refute)
```

If a refutation test fails, downgrade the causal language accordingly — see [Causal language guardrails](#causal-language-guardrails).

### 7. Limitations and threats to validity

This section is mandatory and must be prominent — not buried in an appendix. Decision-makers must see it.

Rank threats by severity. For each:
- State the assumption that might be violated
- Explain the direction of bias if it is violated
- Quantify if possible (E-value, sensitivity analysis, bounding)
- State what additional data or design would resolve the threat

Example:

> "The main threat to this conclusion is unobserved confounding. An unobserved variable would need to be associated with both treatment assignment and outcomes with a relative risk greater than 2.3 to explain away the estimated effect (E-value = 2.3). Given the rich covariate set and the DiD design, we consider this unlikely but cannot rule it out without experimental data."

### 8. Plain-language conclusion

Close every report with one paragraph in plain language, regardless of audience:

> "We estimate [treatment] causes [outcome] to change by [effect] ([HDI]), assuming [key assumptions hold]. There is a [P]% probability the effect is positive. The main threat to this conclusion is [biggest weakness]. If that assumption is violated, the true effect could be [direction and magnitude of bias]."

---

## Causal language guardrails

The strength of your language must match the strength of your identification. Using causal language without identification is not just imprecise — it is misleading.

| Analysis state | Language | Example |
|---------------|----------|---------|
| ID + estimation + all refutations pass | Causal | "X causes Y to increase by Z" |
| ID + estimation pass, some refutations marginal | Suggestive | "Evidence suggests X causes Y to increase by Z, though [caveat]" |
| Critical refutation fails | Associational | "X is associated with a Z-unit increase in Y, but causal interpretation is limited because [reason]" |
| No identification strategy | Descriptive | "We observe X and Y are correlated. We cannot assign a causal interpretation without a credible identification strategy." |

Default to the more conservative language when in doubt. Overclaiming in a causal analysis is a more serious error than underclaiming — it can drive bad decisions.

Never use the word "effect" when the analysis state is Descriptive. "Association," "correlation," and "relationship" are correct.

---

## Decision-relevant HDIs

Do not default to a fixed HDI width. Choose widths that map to intuitive probabilities for the decision context.

| HDI width | Natural frequency | When to use |
|-----------|------------------|-------------|
| 50% | "roughly 1 in 2 chance" | Most likely range; good for communicating typical effect |
| 75% | "roughly 3 in 4 chance" | Good default for moderate-stakes decisions |
| 89% | "roughly 9 in 10 chance" | Moderate-to-high stakes |
| 95% | "roughly 19 in 20 chance" | High stakes; safety-critical decisions |

Report multiple widths when useful, especially when the conclusion changes across them:

> "The effect is 4.2 points (50% HDI: [3.1, 5.3]; 95% HDI: [-0.3, 8.9]). The most likely effect is 3–5 points, but we cannot rule out a null at 95% credibility."

Always state why you chose the reported HDI width. "We report the 75% HDI because this decision requires us to act if the effect is positive with 3-in-4 confidence" is better than silently presenting a number.

For causal analyses specifically, also report the probability of direction:

```python
# Probability effect is positive
p_positive = (idata.posterior["causal_effect"] > 0).mean().item()
print(f"P(effect > 0) = {p_positive:.2f}")
```

This is more interpretable than any fixed HDI when the question is directional ("does the policy help or hurt?").

---

## Audience adaptation

### Technical audience (researchers, analysts)

- Full DAG with node and edge justifications
- Formal identification result (backdoor/frontdoor/IV/RDD/DiD) with citation if applicable
- Posterior plots and full diagnostic summary
- Complete refutation table with test statistics
- Sensitivity analysis (E-values, partial R² bounds, or Rosenbaum bounds)
- Code or link to code repository in appendix

### Decision-makers (executives, policymakers)

- Causal question in plain language — one sentence
- Effect size translated to natural frequencies: "For every 100 people exposed, we estimate 8 more would [outcome]"
- Key threats in 1–2 sentences, stated simply: "The main reason this estimate could be wrong is [X]. If so, the true effect is likely [smaller/larger]."
- Actionable recommendation with explicit uncertainty: "Given the uncertainty, we recommend [action] if the cost of a false positive is less than [threshold]."
- Technical details (DAG, model specification, diagnostics, refutation table) in a clearly labeled appendix

**Both audiences get the limitations section.** Never hide limitations from decision-makers on the grounds that they are "too technical." Translate, do not omit.

### Presenting to mixed audiences

Open with the plain-language conclusion and effect size. Then walk through the DAG visually — most people understand arrows even without training. Reserve equations and diagnostic plots for Q&A or written appendices.

---

## Common reporting mistakes

1. **Using causal language without identification.** If there is no identification strategy, the word "effect" is wrong. Use "association."

2. **Reporting only the point estimate.** The posterior is the result. Always show the full distribution or at minimum multiple HDIs.

3. **Hiding refutation failures.** A failed refutation is information. Report it, downgrade your language, and explain what the failure means for the conclusion.

4. **Burying limitations.** Threats to validity belong in the body of the report, ranked by severity — not in an appendix labeled "caveats."

5. **Conflating LATE with ATE.** IV estimates give the Local Average Treatment Effect for compliers only. DiD estimates are often ATT (Average Treatment Effect on the Treated). Be explicit about whose effect you are estimating and whether it answers the question.

6. **Ignoring spillovers.** If SUTVA is violated — units affect each other — the estimated effect conflates direct and spillover effects. State whether spillovers are plausible and, if so, what direction they push the estimate.

7. **Omitting the E-value or sensitivity analysis.** For observational studies, always quantify how much unobserved confounding would be needed to overturn the conclusion. This anchors the limitations discussion in something concrete rather than vague hedging.

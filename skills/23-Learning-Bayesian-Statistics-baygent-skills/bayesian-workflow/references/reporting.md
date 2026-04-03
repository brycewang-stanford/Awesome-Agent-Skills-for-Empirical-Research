# Reporting Bayesian Analyses

## Contents
- Reporting principles
- Analysis report template
- Presentation template
- Visualization standards
- Common reporting mistakes

## Reporting principles

Bayesian results are inherently richer than frequentist results -- use that richness.

1. **Report full posteriors**, not just point estimates. Use HDI (Highest Density Interval) as default, 94% unless context demands otherwise (94% avoids the false precision of 95% and conveys its arbitrary nature).
2. **Visualize uncertainty**. Every parameter estimate should have a visual representation of its posterior.
3. **Show the model**. Include a model specification section -- readers should know exactly what was assumed. Use `pm.model_to_graphviz` to visualize the model.
4. **Report diagnostics**. Convergence and model criticism results build trust.
5. **Use probability language**, not p-value language. "There is a 94% probability that θ lies in [a, b]" — not "the interval [a, b] is significant."

## Analysis report template

Use this structure for written reports. Adapt sections as needed.

```markdown
# [Analysis Title]

## Executive summary
[2-3 sentence summary of key findings with credible intervals]

## Data description
- Source: [where the data came from]
- Sample size: N = [n]
- Key variables: [list with descriptions]
- Notable features: [missingness, outliers, grouping structure]

## Model specification

### Generative story
[Plain-language description of the assumed data-generating process]

### Mathematical notation
[Model equations using standard notation]

### Prior choices
| Parameter | Prior | Justification |
|-----------|-------|---------------|
| β | Normal(0, 2.5) | Weakly informative on standardized predictors |
| σ | Gamma(2, 2) | Allows wide range of residual variation |

### Model graph
[Figure: model graph, probably done with `pm.model_to_graphviz`]

### Prior predictive check
[Figure: prior predictive distribution vs. plausible data range]
[Brief assessment: "Priors generate data in the range [a, b], consistent with domain knowledge."]

## Results

### Convergence diagnostics
- R-hat: all ≤ 1.01 ✓
- ESS (bulk): minimum [X] ✓
- ESS (tail): minimum [X] ✓
- Divergences: [N] [✓ or ✗]
[Figure: trace/rank plots for key parameters]

### Parameter estimates
| Parameter | Mean | SD | 94% HDI |
|-----------|------|----|---------|
| β₁ | 0.45 | 0.12 | [0.22, 0.68] |
| σ | 1.23 | 0.08 | [1.08, 1.38] |

[Figure: forest plot of key parameters]

### Model criticism
- **Posterior predictive check**: [Figure + assessment]
- **LOO-CV**: ELPD = [X] (SE = [Y]), p_loo = [Z]
- **Calibration**: [Figure + assessment]
- **Pareto k**: all < 0.5 ✓ (or list problematic observations)

### Model comparison (if applicable)
| Model | ELPD | SE | ΔELPD | Weight |
|-------|------|----|-------|--------|
[comparison table]

### Prior sensitivity
| Parameter | Prior CJS | Likelihood CJS | Diagnostic |
|-----------|-----------|----------------|------------|
| β₁ | 0.02 | 0.01 | Low sensitivity ✓ |
| σ | 0.08 | 0.03 | Strong prior / weak likelihood — justified by [domain rationale] |

[Brief interpretation: which parameters are sensitive, whether this affects conclusions,
and justification for any retained informative priors.]

## Interpretation
[What do the results mean substantively? Discuss effect sizes, practical significance,
and how uncertainty affects conclusions. Be explicit about what the model does NOT tell us.]

## Limitations
[Model assumptions that may not hold. Sensitivity to prior choices. Data limitations.]

## Appendix
[Full ArviZ summary table. Additional diagnostic plots. Code repository link.]
```

## Presentation template

For slide-based presentations, use this structure:

```
Slide 1: Title + one-sentence finding
Slide 2: The question -- what are we trying to learn?
Slide 3: Data overview (1 figure, minimal text)
Slide 4: Model diagram or generative story (visual, not equations)
Slide 5: Prior predictive check ("Our assumptions produce plausible data")
Slide 6: Key results -- posterior distributions (forest plot or ridgeplot)
Slide 7: Posterior predictive check ("The data could have been credibly produced by the model")
Slide 8: Practical implications -- translate posteriors into decisions
Slide 9: Limitations and next steps
```

**Presentation rules**:
- One idea per slide
- Visualize posteriors, do not just show tables
- Use ridgeplots or forest plots for multiple parameters
- Show uncertainty in predictions (fan charts, spaghetti plots)
- For non-technical audiences: translate credible intervals into natural language ("There is a 5-in-6 chance that the effect is between X and Y")

## Visualization standards

### Parameter posteriors

```python
# Forest plot (multiple parameters)
az.plot_forest(idata, var_names=["beta"], combined=True)

# Ridge plot (distributions)
az.plot_forest(idata, kind='ridgeplot', var_names=["beta"], combined=True)

# Pair plot (correlations between parameters)
az.plot_pair(idata, var_names=["beta", "sigma"])
```

### Predictions with uncertainty

The following are very simple examples (most of the time you will use ArviZ's built-in functions, as well as
work directly with the `InferenceData` object through xarray).
Nevertheless, the following will give you an idea of the *concepts* we're interested in:

```python
# Fan chart for time series predictions
percentiles = [5, 25, 50, 75, 95]
for lo, hi in [(5, 95), (25, 75)]:
    plt.fill_between(
        x,
        np.percentile(preds, lo, axis=0),
        np.percentile(preds, hi, axis=0),
        alpha=0.3,
    )
plt.plot(
    x,
    np.percentile(preds, 50, axis=0),
    color="blue",
    label="Median",
)
plt.scatter(
    x_obs,
    y_obs,
    color="black",
    s=10,
    label="Observed",
)

# Spaghetti plot (individual posterior draws)
for i in range(50):
    plt.plot(x, preds[i], alpha=0.05, color="blue")
```

### Calibration plot

Use the new ArviZ's (1.0+) `plot_ppc_pit` [function](https://python.arviz.org/projects/plots/en/latest/api/generated/arviz_plots.plot_ppc_pit.html). Refer to [this guide](https://arviz-devs.github.io/EABM/Chapters/Prior_posterior_predictive_checks.html#coverage) for guidance about coverage interpretation, but also across the whole Bayesian workflow in general -- it's a treasure trove!

## Adapting for your audience

The report template above is for a technical audience. When the user mentions a non-technical audience (a boss, a medical board, stakeholders, executives), or says they're new to Bayesian stats, adapt the report:

**For non-technical audiences:**
- Generate a **standalone markdown report file** — not just code with inline comments. The report should be readable on its own, without looking at any code.
- Replace jargon with plain language: "There is roughly a 19-in-20 chance the effect is between X and Y" instead of "94% HDI: [X, Y]"
- Include a **glossary** defining terms like posterior, credible interval, prior, MCMC in everyday language
- Lead with the practical conclusion ("The drug lowers blood pressure by about 10 mmHg"), then support it with the statistical evidence
- Move technical details (convergence diagnostics, model equations) to an appendix
- Use the section "How the Analysis Works (Plain Language)" to explain the generative story as a narrative, not equations

**For Bayesian beginners:**
- Explain *why* each step matters, not just what it does: "We check our assumptions first (prior predictive check) to make sure our model doesn't predict impossible values like negative blood pressure"
- Contrast with frequentist approaches where helpful: "Unlike a p-value, a credible interval directly tells you where the parameter probably lies"
- Define acronyms on first use: "HDI (Highest Density Interval — the narrowest range containing 94% of the plausible values)"

## Common reporting mistakes

1. **Reporting only posterior means**: Always include credible intervals. The uncertainty IS the result.
2. **Using frequentist language**: Avoid "significant", "p < 0.05", "fail to reject". Use "probability", "credible interval", "posterior probability of direction."
3. **Hiding diagnostics**: If convergence was imperfect, say so. If you had to fix divergences, describe how.
4. **Ignoring practical significance**: A posterior that excludes zero is not automatically important. Discuss effect sizes in context.
5. **Not showing prior sensitivity**: Run `psense_summary(idata)` and report the results — especially for policy-relevant or controversial conclusions. Show the CJS values table, flag any parameters with CJS > 0.05, and briefly explain whether the sensitivity affects your conclusions. If you have an intentionally informative prior that flags as sensitive, justify it explicitly rather than hiding the diagnostic. Readers should know which conclusions depend on prior choices and which are robust.
6. **Skipping the generative story**: The model specification should make clear what process is assumed to have generated the data.

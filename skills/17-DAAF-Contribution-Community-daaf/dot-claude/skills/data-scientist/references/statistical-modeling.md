# Statistical Modeling Methodology

Guidance for model selection, assumption checking, robust inference, and interpretation. This reference covers the *why* and *when* of statistical modeling decisions. For implementation syntax, load the `pyfixest` or `statsmodels` skills.

**When to read this file:** Stage 8.1 analysis tasks involving regression, modeling, hypothesis testing, or robustness checks.

**Relationship to other references:**
- For causal vs. correlational language guidance, see `./research-questions.md`
- For chart selection when presenting model results, see `./visualization-design.md`
- For causal identification strategies (DiD, IV, RDD), see `./causal-inference.md`
- For regression as a purely descriptive tool, weighted analysis, or missing data characterization, see `./descriptive-analysis.md`
- For survey-weighted regression with complex survey designs (NHANES, ACS PUMS, CPS, ECLS-K, etc.), see `./survey-analysis.md` for methodology and load the `svy` skill for implementation. Standard regression (OLS, logit, Poisson) is inappropriate for complex survey data — it produces incorrect standard errors.

## Contents

- [Acknowledgments](#acknowledgments)
- [Model Selection Framework](#model-selection-framework)
- [Regression as Approximation](#regression-as-approximation-the-angrist-pischke-framing)
- [Assumption Checking Protocol](#assumption-checking-protocol)
- [Robust Inference](#robust-inference)
- [Interpretation Guide](#interpretation-guide)
- [Robustness Checks](#robustness-checks)
- [References and Further Reading](#references-and-further-reading)

## Acknowledgments

These materials draw extensively from several open-access resources that the
authors have generously made available to the research community:

- Joshua Angrist and Jorn-Steffen Pischke's *Mostly Harmless Econometrics* and *Mastering 'Metrics*, which established the modern applied econometrics pedagogy
- Scott Cunningham's *Causal Inference: The Mixtape* (https://mixtape.scunning.com/), particularly Chapter 2 on regression and the CEF
- Nick Huntington-Klein's *The Effect* (https://theeffectbook.net/) for research design thinking
- Grant McDermott's pedagogical materials on standard error adjustment (https://grantmcdermott.com/) and the LOST wiki (https://lost-stats.github.io/)
- Joshua Angrist's Mastering Econometrics course on MRU (https://mru.org/mastering-econometrics-joshua-angrist)

## Model Selection Framework

### Decision Tree by Outcome Type

Start with the nature of your dependent variable. The outcome type constrains which models are valid:

| Outcome Type | Primary Model | Alternatives | Key Consideration |
|---|---|---|---|
| Continuous | OLS | WLS, GLS, quantile regression | Check residual distribution and heteroskedasticity |
| Binary (0/1) | Logit | Probit, Linear Probability Model (LPM) | LPM gives interpretable AME (Angrist & Pischke 2009); see caveats below |
| Count (0, 1, 2, ...) | Poisson | Negative Binomial, Zero-Inflated | Poisson QMLE is consistent for mean parameters even under variance misspecification, given correct mean spec (Wooldridge 2010) |
| Categorical (unordered) | Multinomial Logit | Mixed Logit | Requires Independence of Irrelevant Alternatives (IIA) assumption |
| Categorical (ordered) | Ordered Logit/Probit | --- | Requires proportional odds assumption |
| Repeated observations (panel) | FE / RE panel models | Correlated Random Effects | Choice depends on research question, not just the Hausman test |

### The "Start Simple" Principle

Following Angrist and Pischke's (2009) guidance, begin with the simplest model that addresses your question and add complexity only when diagnostics demand it:

1. **Start with OLS.** Even for binary outcomes, the Linear Probability Model provides interpretable average marginal effects and consistent estimates under mild conditions. Angrist and Pischke argue that the LPM is underappreciated: its coefficients are directly interpretable as probability changes, and with robust standard errors, inference is reliable for the interior of the distribution.

2. **Check diagnostics.** Do residual patterns suggest the model is inadequate? Is the predicted range problematic (negative probabilities, probabilities above 1)?

3. **Add complexity only if diagnostics demand it.** Switch to logit/probit only if marginal effects at the extremes matter for your question. Use Poisson only if the count structure is integral to interpretation. Add fixed effects only if unobserved group-level heterogeneity threatens identification.

4. **Theory motivates specification, not data mining.** Model selection should be driven by what you know (or credibly assume) about the data generating process. Running many specifications and selecting the one with the "best" results is specification searching --- a threat to valid inference. Leamer (1983) called this "specification searches" and it remains one of the most common methodological pitfalls.

**A note on the "start simple" philosophy:** This framing reflects the influential Angrist-Pischke tradition in applied microeconomics. Other traditions (e.g., Gelman and Hill 2006) emphasize matching the model to the data-generating process from the start. The "start simple" approach works well when the primary goal is transparent causal or descriptive inference with interpretable coefficients; it is less appropriate when the data structure clearly demands a specific model class (e.g., multilevel data).

**LPM caveats:** The LPM can produce predicted probabilities outside [0,1] and has mechanical heteroskedasticity (the error variance is p(1-p) for binary outcomes, so robust SEs are mandatory). The LPM and logit AME are typically very close for binary treatments with average marginal effects in the interior of the probability distribution. However, for continuous treatments, effects near the boundaries (p near 0 or 1), or when the probability model itself is of interest, logit/probit is preferred.

### Fixed Effects vs. Random Effects

The choice between fixed effects (FE) and random effects (RE) is about what variation you want to use for estimation, not simply about a Hausman test p-value:

- **FE** absorbs all time-invariant unobserved heterogeneity by using only within-unit variation over time. Use when unobserved unit characteristics are likely correlated with the treatment variable. FE is more conservative but eliminates a major source of omitted variable bias.
- **RE** assumes unobserved heterogeneity is uncorrelated with regressors. More efficient than FE (uses both within- and between-unit variation) but biased if the assumption fails.
- **Correlated Random Effects (CRE)** --- the Mundlak (1978) approach --- includes group means of time-varying regressors as additional controls in the RE model. This nests FE within RE, allows a formal test of the RE assumption, and preserves the ability to estimate effects of time-invariant characteristics (which FE cannot do).
- **Practical advice:** In most applied research on observational data, FE is the safer default for questions about within-unit change. Use RE only when you have a strong theoretical reason to believe the RE assumption holds, or when estimating effects of time-invariant characteristics is central to your question.

## Regression as Approximation (The Angrist-Pischke Framing)

### The Conditional Expectation Function (CEF)

Following Angrist and Pischke (2009, Ch. 3) and Cunningham (2021, Ch. 2), regression should be understood as a tool for approximating the conditional expectation function (CEF), not as a literal model of reality.

The **CEF**, E(Y|X), gives the average value of Y for each value of X. It is the optimal predictor of Y given X in the mean-squared-error sense --- it minimizes MSE across all possible functions, not just linear ones. Three theorems establish why OLS is useful even when the CEF is nonlinear:

1. **Linear CEF Theorem:** If the true CEF is linear, population OLS recovers it exactly.
2. **Best Linear Predictor (BLP) Theorem:** OLS minimizes E[(Y - X'b)^2] over all linear functions --- it is the best linear approximation to **Y** itself.
3. **Regression CEF Theorem:** OLS minimizes E[(E(Y|X) - X'b)^2] over all linear functions --- it is the best linear approximation to **E(Y|X)**. This is the stronger and more important result: it establishes that OLS inherits the desirable properties of the CEF (the optimal predictor), not just that it is the best linear predictor of the raw outcome.

**Practical implication:** You do not need to believe the world is linear to use OLS. You need to believe that a linear approximation is adequate for your question in the region of interest. When it is not, add flexibility (polynomials, splines, interactions) or use nonparametric methods.

**CEF decomposition:** Any random variable decomposes as Y = E(Y|X) + epsilon, where epsilon has zero conditional mean and is uncorrelated with any function of X. This orthogonality property is what enables clean interpretation of regression coefficients as approximations to the CEF.

### What "Controlling For" Actually Means

The **Frisch-Waugh-Lovell (FWL) theorem** reveals what multivariate regression does mechanically. Also called the "regression anatomy" theorem by Angrist and Pischke: the coefficient on X1 in a regression of Y on X1, X2, ..., Xk equals the coefficient from a simple regression of Y on the *residuals* obtained by regressing X1 on all other covariates.

In plain language: "controlling for" X2 means isolating the variation in X1 that is orthogonal to (uncorrelated with) X2, then using only that residual variation to estimate X1's association with Y. You are comparing units that look the same on X2 but differ on X1.

This mechanical understanding has important implications:
- If X2 absorbs most of the variation in X1, the "controlled" coefficient is estimated from very little remaining variation --- explaining why adding many controls can dramatically increase standard errors
- If X2 is irrelevant (uncorrelated with X1), controlling for it does not change the coefficient on X1 but may reduce residual variance and improve precision
- FWL also explains what fixed effects do: they partial out group means, leaving only within-group variation for estimation

### The "Bad Controls" Problem

Never control for **post-treatment variables** --- variables that are themselves affected by the treatment. Following Angrist and Pischke (2009), a classic example:

> Estimating the gender wage gap while controlling for occupation. If gender affects occupational choice (which it does), occupation is a post-treatment variable. Controlling for it removes the part of the gender effect that operates *through* occupational sorting --- precisely the channel you may want to measure.

The test: Could the treatment plausibly affect the control variable? If yes, including it may absorb part of the treatment effect you are trying to estimate, biasing your results toward zero (or in unpredictable directions). When in doubt, present results both with and without the questionable control and discuss the implications of each.

Other common "bad control" situations:
- Controlling for college completion when estimating the effect of a K-12 intervention
- Controlling for firm size when estimating the effect of a policy on firm outcomes (if the policy affects firm size)
- Controlling for health behaviors when estimating the effect of income on health

### Saturated Models and the CEF

When X is discrete (or treated as discrete through binning) and a model includes a full set of group dummies (is "saturated"), the regression *is* the CEF --- no approximation is needed. The fitted values are simply the group means. This insight:

- Justifies fixed effects models: they provide exact conditional means within each group
- Explains why interacting treatment with group indicators allows heterogeneous effects without functional form concerns
- Underlies the logic of fully saturated specifications as a benchmark for more parsimonious models

## Assumption Checking Protocol

### OLS Assumptions and Diagnostics

| Assumption | Diagnostic | What to Do If Violated |
|---|---|---|
| Linearity | Residual vs. fitted plot, RESET test (Ramsey 1969) | Add polynomial terms, use splines, or transform variables |
| Independence | Durbin-Watson (time series), Moran's I (spatial) | Cluster SEs at the appropriate level, or use time-series/spatial models |
| Homoscedasticity | Breusch-Pagan test, White test, residual vs. fitted plot | Use heteroskedasticity-robust SEs (HC1/HC2/HC3) |
| Normality of residuals | Q-Q plot, Shapiro-Wilk, Jarque-Bera | Usually fine with large N (CLT); use bootstrap for small samples |
| No perfect multicollinearity | VIF (> 10 is a concern), condition number | Drop redundant variables, combine into index, or accept wider SEs |
| No influential outliers | Cook's distance (> 4/N), leverage (> 2k/N), DFBETAS | Winsorize, use robust regression (M-estimators), report with and without |

**Reading the residual vs. fitted plot** --- your single most informative diagnostic:
- **Fan shape** (widening spread) indicates heteroskedasticity. Use robust SEs.
- **Curve** (systematic pattern in residuals) indicates nonlinearity. Add polynomial terms or transform variables.
- **Clusters** (distinct groups of residuals) suggest an omitted grouping variable. Consider adding group fixed effects or clustering SEs.
- **Isolated extreme points** suggest influential observations. Check Cook's distance and report sensitivity.

### GLM Assumptions

For models beyond OLS, additional checks apply:

- **Link function appropriateness:** Does the chosen link (logit, log, identity) match how you believe the covariates relate to the outcome? For binary outcomes, logit and probit give nearly identical average marginal effects; the choice rarely matters in practice.
- **Dispersion in count models:** Poisson assumes the conditional mean equals the conditional variance. When the variance exceeds the mean (overdispersion), standard errors will be too small. Solutions: Negative Binomial (models overdispersion explicitly), quasi-Poisson (adjusts SEs), or --- following Wooldridge's (2010) recommendation --- use Poisson with robust standard errors, which remains consistent even when the variance function is misspecified.
- **Separation in logistic regression:** When a predictor perfectly predicts the outcome (complete separation) or nearly so (quasi-complete separation), maximum likelihood estimates diverge to infinity. Use Firth's (1993) penalized likelihood or investigate whether the offending predictor should be removed from the model.

### When Violations Matter vs. When They Don't

Not all assumption violations are equally consequential. Following Angrist and Pischke's (2009) pragmatic approach:

**Heteroskedasticity:** Almost always present in real data. The coefficient estimates remain consistent and unbiased --- only the classical standard errors are wrong. Use robust standard errors (HC1 or better) and move on. This is such standard practice that many applied researchers consider robust SEs the default rather than the exception.

**Non-normality of residuals:** With N > 50 or so, the Central Limit Theorem ensures that the sampling distribution of the coefficient estimator is approximately normal regardless of the error distribution. Normality of residuals only matters for exact small-sample tests (t-tests and F-tests with small N). For large samples, it is effectively irrelevant.

**Multicollinearity:** Individual coefficient estimates become imprecise (wider standard errors), but joint prediction is unaffected. Whether this matters depends entirely on your question: if you need to distinguish individual effects of correlated variables, multicollinearity is a genuine problem. If you only need the overall prediction or the effect of one variable conditional on the others, wider SEs may be an acceptable price.

**Nonlinearity:** Matters when the CEF is strongly nonlinear in the region of interest for your question. A linear approximation may be adequate for average effects even when the true relationship curves. But if you care about effects at the tails of the distribution or about threshold effects, you need to model the nonlinearity explicitly.

### Model Diagnostics Workflow

Run diagnostics in this order after estimation. This sequence is designed so that each step builds on the previous one:

1. **Residual vs. fitted plot** --- check linearity and heteroskedasticity simultaneously. This is your single most informative diagnostic and should always come first.
2. **VIF / condition number** --- check multicollinearity. If VIF > 10 for a variable, consider whether its individual effect is essential to your question. VIF between 5 and 10 is a gray zone: investigate but do not automatically drop variables.
3. **Influence diagnostics** --- Cook's distance, leverage, DFBETAS. If removing a small number of influential points changes the conclusion, the result is fragile and this should be documented, not silently resolved by dropping observations.
4. **Normality check** --- only if N < 50. For larger samples, skip this; the CLT handles it.
5. **Independence check** --- only if the data has panel, time-series, or spatial structure. Use Durbin-Watson (time series) or Moran's I (spatial).

If any diagnostic reveals a problem, address it (robust SEs, functional form adjustment, etc.) before interpreting coefficients.

### Missing Data in Regression

Missing data handling is a modeling decision that should be documented explicitly:

**When listwise deletion is acceptable:** When missingness is plausibly MCAR (Missing Completely at Random) or unrelated to the outcome conditional on included covariates, AND the sample size reduction is tolerable (less than 5-10% of observations dropped). Always report the number of observations dropped due to missingness and compare the analytic sample to the full sample on key covariates.

**When multiple imputation should be considered:** When more than 5-10% of observations are dropped, missingness is plausibly MAR (Missing at Random), and variables are available that predict the missing values. Multiple imputation under MNAR (Missing Not at Random) is also biased but may be less so than listwise deletion.

**Practical decision rule:** (1) Report the full-sample N and the analytic-sample N after listwise deletion. (2) Compare means of key variables between the full and analytic samples. (3) If they differ systematically, consider whether the missingness pattern threatens your conclusions and document this assessment. (4) For detailed coverage of MCAR/MAR/MNAR frameworks, see `./descriptive-analysis.md`.

### Sample Size Considerations

Minimum sample size heuristics vary by model type. These are rules of thumb, not hard thresholds:

| Model | Minimum N Heuristic | Consequence if Violated |
|---|---|---|
| OLS with k regressors | N >= 10k-20k per regressor | Unstable coefficient estimates, unreliable SEs |
| Logistic regression | >= 10 events per variable (EPV) | Biased coefficients, inflated SEs; use Firth's penalized likelihood if EPV < 10 |
| Interaction effects | Multiplicatively increases required N | Three-way interactions with small N are statistically meaningless regardless of p-value |
| Clustered SEs | See few-clusters table in Robust Inference | Anti-conservative inference; use CRV3 or bootstrap |

**When N is marginal:** Use HC3 instead of HC1 (more reliable for small samples), avoid complex specifications with many parameters, and emphasize confidence intervals over p-values. Acknowledge limited statistical power for detecting small effects --- a non-significant result may reflect insufficient power rather than a true null.

### Multiple Testing

When running multiple regression models, determine whether a multiple testing correction is needed:

- **Pre-specified primary analysis with a single primary outcome:** No correction needed. This is the standard case for a focused research question.
- **Multiple outcomes or subgroup analyses:** Each test is an additional comparison. Use Benjamini-Hochberg (FDR) correction for exploratory analyses with many outcomes. Bonferroni is valid but overly conservative.
- **Robustness checks of the same hypothesis:** These are sensitivity analyses, NOT multiple tests. The coefficient of interest should be qualitatively consistent across specifications, but each specification does not need to be individually significant.
- **Transparency rule:** If you are running many models, designate one as the primary (pre-specified) analysis and the rest as exploratory or robustness checks. Be explicit about this distinction in documentation and reporting.

## Robust Inference

### Standard Error Types and When to Use Each

This table is the primary quick-reference for SE selection. When uncertain, default to HC1 for cross-sectional data or CRV1 for clustered data.

| SE Type | When to Use | pyfixest | statsmodels |
|---|---|---|---|
| IID (classical) | Only if certain errors are homoscedastic and independent | `vcov="iid"` | Default |
| HC1 (White with df correction) | Default for cross-sectional data | `vcov="hetero"` | `cov_type='HC1'` |
| HC2 | Moderate small samples (N = 30-50); less biased than HC1 | `vcov="HC2"` | `cov_type='HC2'` |
| HC3 | Very small samples (N < 30); jackknife-like correction | `vcov="HC3"` | `cov_type='HC3'` |
| CRV1 (cluster-robust) | Observations correlated within groups | `vcov={"CRV1": "group"}` | Via linearmodels |
| CRV3 | Few clusters (< 50) | `vcov={"CRV3": "group"}` | N/A (use bootstrap) |
| HAC (Newey-West) | Time series with serial correlation | `vcov="HAC"` | `cov_type='HAC'` |
| Wild cluster bootstrap | Very few clusters (< 20) | `.wildboottest()` | Via wildboottest |

**SE selection decision tree:**

```
What is your data structure?
├─ Cross-sectional (one observation per unit)
│   ├─ Errors likely homoscedastic? → IID (rare in practice)
│   └─ Errors likely heteroscedastic? → HC1 (default choice)
│       └─ Small sample (N < 50)? → HC2 or HC3
├─ Clustered (observations grouped, e.g., students in schools)
│   ├─ Many clusters (>= 50)? → CRV1
│   ├─ Few clusters (20-49)? → CRV3
│   └─ Very few clusters (< 20)? → Wild cluster bootstrap
│       └─ Fewer than 5 clusters? → Randomization inference or aggregate to cluster level
└─ Time series (ordered observations with potential serial correlation)
    └─ HAC (Newey-West)
```

### On-the-Fly SE Adjustment

Following McDermott's pedagogical insight: coefficient estimates and standard errors answer separate questions. The coefficients capture the association (or causal effect, if identified). The standard errors quantify the precision of those estimates under a specific assumption about error structure. You can and should estimate the model once, then examine results under different SE assumptions.

This separation of estimation from inference means:
- Estimate the model once, then swap variance-covariance matrices to compare SEs under different assumptions (iid, robust, clustered)
- The coefficients never change --- only the standard errors, confidence intervals, and p-values change
- In pyfixest, this is operationalized via `.vcov()` calls on a fitted model object
- This approach is computationally efficient (one estimation instead of many), conceptually clarifying (separates "what is the estimate?" from "how precise is it?"), and reduces the risk of accidentally re-estimating with different settings

**Why this matters for robustness tables:** A common and informative robustness exercise is to show the same model with different SE specifications side by side. This reveals whether statistical significance is driven by a particular inference assumption, which is important information for the reader.

### Clustered Standard Errors: Choosing the Cluster Level

Following Abadie, Athey, Imbens, and Wooldridge (2023), the decision about whether and how to cluster depends on the research design:

**Core principle:** The need to cluster arises from two distinct channels: (1) a **design reason** --- treatment is assigned at the group level, so within-group errors are mechanically correlated; and (2) a **sampling reason** --- units are sampled in clusters, inducing within-cluster correlation. Abadie et al.'s key (and sometimes counterintuitive) result is that if treatment is assigned at the individual level and units are sampled randomly (not in clusters), clustering may not be necessary even if there is within-group correlation in the outcome.

Practical guidelines:
- If treatment is assigned at the state level, cluster at the state level (design reason)
- If treatment varies at the individual level but individuals are observed repeatedly, cluster at the individual level (serial correlation)
- If observations share a common group-level shock (e.g., students in the same school), cluster at the group level (sampling reason)

**When in doubt, cluster at a higher level.** Clustering at too fine a level understates uncertainty (anti-conservative). Clustering at too coarse a level overstates uncertainty (conservative) but keeps inference valid. Conservative errors are preferable to anti-conservative errors.

**The few-clusters problem:** Standard cluster-robust SEs (CRV1) perform poorly with fewer than approximately 50 clusters. The finite-sample correction is inadequate, and actual test rejection rates can far exceed nominal levels (e.g., a 5% test rejecting 15% of the time). Solutions by cluster count:

| Number of Clusters | Recommended Approach |
|---|---|
| >= 50 | CRV1 (standard cluster-robust) |
| 20--49 | CRV3 (bias-reduced linearization) |
| < 20 | Wild cluster bootstrap (Cameron, Gelbach, and Miller 2008) |
| < 5 | Randomization inference or aggregate data to cluster level |

**Multi-way clustering:** When observations are correlated along multiple dimensions simultaneously (e.g., students clustered within both schools and cohort years), use multi-way clustering following Cameron, Gelbach, and Miller (2011). This computes variance estimates from each clustering dimension and combines them to capture both sources of dependence.

## Interpretation Guide

### Coefficient Interpretation by Model Type

Misinterpreting coefficients is among the most common errors in applied research. Use this table as a quick reference:

| Model Specification | Coefficient beta Interpretation |
|---|---|
| Linear: Y ~ X | A 1-unit increase in X is associated with a beta-unit change in Y |
| Log-linear: log(Y) ~ X | A 1-unit increase in X is associated with approximately (beta x 100)% change in Y |
| Log-log: log(Y) ~ log(X) | A 1% increase in X is associated with a beta% change in Y (elasticity) |
| Linear-log: Y ~ log(X) | A 1% increase in X is associated with a beta/100 unit change in Y |
| Logit: P(Y=1) ~ X | A 1-unit increase in X changes the log-odds by beta; use marginal effects for probability interpretation |
| Poisson: E(count) ~ X | A 1-unit increase in X multiplies expected count by exp(beta); approximately (beta x 100)% for small beta |

**The log approximation caveat:** The "beta times 100 percent" interpretation for log-linear models is an approximation that works well for |beta| < 0.1. For larger coefficients, the exact percentage change is (exp(beta) - 1) x 100. For example, beta = 0.5 does not mean a 50% increase --- it means a 65% increase (exp(0.5) - 1 = 0.649). Always use the exact formula when beta is not small. This caveat is especially important for **dummy variables in log-linear models** (e.g., a treatment indicator in a log-wage regression): the coefficient on a dummy is typically large enough that the approximation fails, and the exact formula (exp(beta) - 1) should always be used (Kennedy 1981).

**Interaction terms:** The coefficient on an interaction X1 x X2 represents how the marginal effect of X1 changes as X2 changes (and vice versa). In nonlinear models (logit, Poisson), the interaction effect on the outcome scale (probability, count) is NOT simply the interaction coefficient. Ai and Norton (2003) demonstrate that the sign of the true interaction effect can even differ from the sign of the interaction coefficient in logit models. Always compute marginal interaction effects for nonlinear models.

### Marginal Effects

For nonlinear models, raw coefficients are not directly interpretable as marginal effects on the outcome. Two standard approaches exist:

- **Average Marginal Effects (AME):** Compute the marginal effect for each observation, then average across the sample. Answers: "What is the average effect of a 1-unit change in X across all individuals in the data?"
- **Marginal Effects at the Mean (MEM):** Compute the marginal effect evaluated at the sample means of all covariates. Answers: "What is the effect for a hypothetical individual at the sample averages?"

**AME is generally preferred** for three reasons:
1. The "average individual" defined by sample means may not exist or be meaningful --- averaging over a binary variable like gender produces a nonsensical value (Angrist and Pischke 2009)
2. AME respects the actual distribution of covariates in the sample rather than evaluating at a potentially unrepresentative point
3. AME is closer to the quantity of interest for policy evaluation: the average effect across the population, not the effect for a fictitious "average" person

The `marginaleffects` package provides a unified interface for computing AME and MEM across model types. Load the `pyfixest` skill for implementation details on integrating marginal effects computation with model estimation.

### Effect Sizes vs. Statistical Significance

**Statistical significance alone is uninformative.** A "significant" coefficient tells you the estimate is unlikely under the null hypothesis --- it says nothing about whether the effect is practically meaningful. Conversely, a "non-significant" result may reflect insufficient statistical power rather than a true null effect.

**Always report effect sizes in substantively meaningful units:**
- "A one-standard-deviation increase in school funding is associated with a 0.08 SD increase in test scores" communicates both direction and scale
- "The effect is statistically significant (p < 0.05)" communicates neither

**Standardized effect sizes** (Cohen 1988) provide a scale-free measure of magnitude when natural units are not available or not intuitive. Cohen himself cautioned against using these benchmarks mechanically --- they are rough conventions, and substantive context should always guide interpretation. In many applied settings (education policy, public health), effect sizes of 0.1-0.2 SD are considered practically significant at scale:

| Cohen's d | Conventional Benchmark | Practical Note |
|---|---|---|
| ~0.2 | Small | Typically requires large N to detect; may still be policy-relevant at scale |
| ~0.5 | Medium | Visible in everyday experience |
| ~0.8 | Large | Obvious without statistics |

**Confidence intervals as the primary inference tool:** Report confidence intervals rather than (or in addition to) p-values. A 95% confidence interval communicates both the magnitude and the precision of the estimate in a single display. A wide interval signals genuine uncertainty about magnitude; a narrow interval signals a precise estimate. This is far more informative than a binary significant/not-significant declaration.

**Practical significance screening:** Before running any model, ask: "What is the smallest effect size that would be meaningful for the decision this analysis informs?" If a 0.01 SD change in the outcome would be irrelevant regardless of p-value, frame the analysis in terms of whether the estimated effect exceeds a substantively meaningful threshold, not whether it crosses an arbitrary significance level.

## Robustness Checks

Robustness checks test whether conclusions are sensitive to specific analytical choices. A result that appears under only one specification is fragile; a result that persists across reasonable alternatives is credible. Following Angrist and Pischke (2009), robustness is not about running hundreds of specifications --- it is about varying the choices a skeptical reader would question.

### Specification Sensitivity

Vary the model specification systematically and present results side by side:

1. **Add and remove control variables.** Start with a "short" regression (minimal controls), then progressively add controls. If the coefficient of interest changes dramatically, investigate why. Large changes when adding controls may indicate you are removing omitted variable bias (desirable) or introducing bad controls (problematic). The direction and pattern of movement is informative.

2. **Change functional form.** Replace linear terms with logs, polynomials, or splines. If conclusions depend critically on functional form, they are fragile and this fragility should be prominently acknowledged.

3. **Alternative variable definitions.** Use different cutoffs (e.g., poverty at 100% FPL vs. 150% FPL), alternative operationalizations of the same construct, or different time windows. Sensitivity to variable definitions reveals how much your conclusion depends on measurement choices.

### Subsample Stability

Test whether the result holds across meaningful subgroups:

- Demographic groups (race, gender, age cohorts)
- Geographic regions (urban vs. rural, by state or region)
- Time periods (early vs. late in the sample)
- Data quality tiers (e.g., excluding observations with imputed values)

If the effect is concentrated in one subgroup, this is substantively important information. It may reflect genuine heterogeneity (a real finding worth reporting) rather than fragility. But if you only find the result in one cherry-picked subgroup, treat it with appropriate skepticism.

### Alternative Estimators

When feasible, compare results across estimation strategies:

- OLS vs. robust regression (M-estimators) to assess sensitivity to outliers
- OLS vs. quantile regression to examine whether effects differ across the outcome distribution
- Parametric vs. nonparametric approaches for key relationships
- Fixed effects vs. correlated random effects (Mundlak 1978) to test the RE assumption

Convergence across estimators strengthens credibility. Divergence is informative and should be discussed, not hidden.

### Omitted Variable Bias Assessment

Two complementary frameworks address the critical question: "How much unobserved confounding would be needed to overturn my result?"

**Oster (2019) --- Coefficient Stability:**

This method extends Altonji, Elder, and Taber (2005) by examining how both the coefficient of interest *and* R-squared change when observed controls are added:

- If adding controls produces a large R-squared increase but minimal coefficient movement, unobservables are unlikely to overturn the result. The observables already capture the important confounding.
- If R-squared barely moves while the coefficient shifts substantially, the result is fragile --- a small amount of additional confounding could eliminate the effect.
- Uses the "proportional selection" assumption: selection on unobservables is proportional to selection on observables (delta = 1 means equal selection).
- Requires specifying R_max (the maximum achievable R-squared if all relevant variables were observed). Oster recommends R_max = min(1.0, 1.3 x R-squared from the fully controlled regression). Note: the 1.3 multiplier is empirically calibrated from randomized controlled trials, not theoretically derived. It is a reasonable starting point, but sensitivity to this choice should be explored.
- The bias-adjusted treatment effect beta* bounds what the coefficient would be if all relevant unobservables were included. If the identified set [beta_controlled, beta*] excludes zero, the result survives the test.

**Cinelli and Hazlett (2020) --- Partial R-squared Sensitivity Analysis:**

This framework expresses omitted variable bias in terms of two partial R-squared values --- the confounder's explanatory power for the treatment and for the outcome:

- **Robustness Value (RV):** A single scalar summarizing how strong confounding must be to overturn the result. Example interpretation: "Unobserved confounders would need to explain more than 14% of the residual variance of both treatment and outcome to bring the estimate to zero."
- **Sensitivity contour plots** visualize which combinations of confounder-treatment and confounder-outcome partial R-squared values would change the conclusion.
- **Benchmarking** calibrates sensitivity parameters against observed covariates: "How strong would the confounder need to be relative to [observed variable X]?" This grounds the analysis empirically rather than relying on arbitrary assumptions.
- Implemented in the `sensemakr` R package and `pysensemakr` Python package.

**Using both methods is strongest.** Oster's approach is standard in economics journals. Cinelli and Hazlett's framework provides more interpretable visualization and the robustness value summary statistic. They are complementary because they parameterize the sensitivity analysis differently --- Oster through total R-squared movement, Cinelli and Hazlett through partial R-squared decomposition.

### Bounding Exercises

When identification assumptions are uncertain, Manski-style partial identification provides bounds on the treatment effect rather than point estimates. Rather than assuming a specific value for an unidentifiable parameter, this approach asks: "Given what we can observe, what is the range of possible effects consistent with the data?"

Partial identification is particularly valuable when:
- Identification assumptions are contestable and you want to show your conclusion holds under weaker assumptions
- There is non-ignorable selection or attrition
- You want to demonstrate that the sign of the effect is robust even if the magnitude is uncertain

The bounds are typically wide --- that is the point. They honestly represent what the data can tell you without strong assumptions. Narrower bounds require stronger (and more contestable) assumptions.

### Presenting Robustness Results

Present robustness checks in a **specification table** showing the coefficient of interest across multiple specifications side by side. Each column represents a different specification; rows show the coefficient, standard error, and key specification details. This format is standard in economics and social science journals.

Recommended columns:
1. Baseline (minimal controls)
2. Preferred specification (with theoretical motivation)
3. Extended controls (everything plausibly relevant)
4. Alternative functional form
5. Alternative sample definition

The coefficient should be qualitatively stable across reasonable specifications. If it changes sign or becomes practically negligible in any defensible specification, the result requires careful qualification and the instability should be prominently discussed.

### When Robustness Checks Fail

When a robustness check produces results that differ from the primary specification, follow this protocol:

1. **Coefficient changes sign in a defensible specification:** The primary result is not robust. State this explicitly --- do not bury it. Report both the primary and contradicting specifications with equal prominence.
2. **Coefficient loses significance but maintains sign and approximate magnitude:** This may reflect power loss from the alternative specification (e.g., smaller sample, less variation). Investigate *why* significance was lost --- if it is purely a precision issue, the result may still be credible. Document the investigation.
3. **Coefficient changes dramatically when adding/removing a specific control:** Apply the bad controls test from the Regression as Approximation section. Is the control a post-treatment variable? If so, the specification without the control may be more appropriate.
4. **Never hide a failed robustness check.** Selectively reporting only specifications that "work" is a form of specification searching. All pre-specified robustness checks must be reported regardless of outcome.

## References and Further Reading

### Textbooks

Angrist, J.D. and Pischke, J.-S. (2009). *Mostly Harmless Econometrics: An Empiricist's Companion*. Princeton University Press. https://www.mostlyharmlesseconometrics.com/

Angrist, J.D. and Pischke, J.-S. (2015). *Mastering 'Metrics: The Path from Cause to Effect*. Princeton University Press. https://www.masteringmetrics.com/

Cunningham, S. (2021). *Causal Inference: The Mixtape*. Yale University Press. https://mixtape.scunning.com/

Huntington-Klein, N. (2022). *The Effect: An Introduction to Research Design and Causality*. Chapman & Hall/CRC. https://theeffectbook.net/

Wooldridge, J.M. (2010). *Econometric Analysis of Cross Section and Panel Data*. 2nd ed. MIT Press.

### Key Papers

Abadie, A., Athey, S., Imbens, G.W., and Wooldridge, J.M. (2023). "When Should You Adjust Standard Errors for Clustering?" *Quarterly Journal of Economics*, 138(1), 1-35.

Ai, C. and Norton, E.C. (2003). "Interaction Terms in Logit and Probit Models." *Economics Letters*, 80(1), 123-129.

Altonji, J.G., Elder, T.E., and Taber, C.R. (2005). "Selection on Observed and Unobserved Variables: Assessing the Effectiveness of Catholic Schools." *Journal of Political Economy*, 113(1), 151-184.

Cameron, A.C., Gelbach, J.B., and Miller, D.L. (2008). "Bootstrap-Based Improvements for Inference with Clustered Errors." *Review of Economics and Statistics*, 90(3), 414-427.

Cameron, A.C., Gelbach, J.B., and Miller, D.L. (2011). "Robust Inference with Multiway Clustering." *Journal of Business & Economic Statistics*, 29(2), 238-249.

Cameron, A.C. and Miller, D.L. (2015). "A Practitioner's Guide to Cluster-Robust Inference." *Journal of Human Resources*, 50(2), 317-372.

Cinelli, C. and Hazlett, C. (2020). "Making Sense of Sensitivity: Extending Omitted Variable Bias." *Journal of the Royal Statistical Society: Series B*, 82(1), 39-67.

Cohen, J. (1988). *Statistical Power Analysis for the Behavioral Sciences*. 2nd ed. Lawrence Erlbaum Associates.

Firth, D. (1993). "Bias Reduction of Maximum Likelihood Estimates." *Biometrika*, 80(1), 27-38.

Kennedy, P.E. (1981). "Estimation with Correctly Interpreted Dummy Variables in Semilogarithmic Equations." *American Economic Review*, 71(4), 801.

Leamer, E.E. (1983). "Let's Take the Con Out of Econometrics." *American Economic Review*, 73(1), 31-43.

MacKinnon, J.G., Nielsen, M.O., and Webb, M.D. (2023). "Cluster-Robust Inference: A Guide to Empirical Practice." *Journal of Econometrics*, 232(2), 272-299.

Manski, C.F. (2003). *Partial Identification of Probability Distributions*. Springer.

Mundlak, Y. (1978). "On the Pooling of Time Series and Cross Section Data." *Econometrica*, 46(1), 69-85.

Oster, E. (2019). "Unobservable Selection and Coefficient Stability: Theory and Evidence." *Journal of Business & Economic Statistics*, 37(2), 187-204.

Ramsey, J.B. (1969). "Tests for Specification Errors in Classical Linear Least-Squares Regression Analysis." *Journal of the Royal Statistical Society: Series B*, 31(2), 350-371.

### Software Documentation

Fischer, A. and Schar, S. pyfixest: Fast High-Dimensional Fixed Effects Estimation in Python. https://pyfixest.org

Seabold, S. and Perktold, J. (2010). "Statsmodels: Econometric and Statistical Modeling with Python." *Proc. 9th Python in Science Conf.*

### Teaching Resources

Angrist, J.D. "Mastering Econometrics." Marginal Revolution University. https://mru.org/mastering-econometrics-joshua-angrist

McDermott, G.R. "A Better Way to Adjust Your Standard Errors." https://grantmcdermott.com/posts/better-way-adjust-ses/

McDermott, G.R. "Data Science for Economists and Other Animals." https://grantmcdermott.com/ds4e/

LOST (Library of Statistical Techniques). https://lost-stats.github.io/

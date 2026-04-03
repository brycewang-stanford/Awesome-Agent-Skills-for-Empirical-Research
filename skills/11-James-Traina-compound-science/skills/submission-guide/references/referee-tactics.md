# Referee Response Tactics by Method

## Common Referee Concerns: Instrumental Variables

| Concern | Typical Phrasing | Response Strategy |
|---------|-----------------|-------------------|
| Exclusion restriction | "The instrument may affect Y through channels other than X." | Provide institutional argument. Run reduced-form with controls for suspected channels. Show falsification tests (effect on placebo outcomes unaffected by X). |
| Weak instruments | "The first-stage F is only [N], raising weak instrument concerns." | Report Olea-Pflueger effective F. Show LIML results. Report Anderson-Rubin confidence sets. If F is truly low, consider alternate instruments. |
| LATE vs ATE | "The IV estimates a local effect for compliers, limiting external validity." | Characterize compliers (compare means of covariates for compliers vs always-takers). Discuss whether the complier subpopulation is policy-relevant. Bound ATE using complier share. |
| Endogenous instrument | "The instrument is correlated with [unobservable]." | This is the most dangerous critique. If the referee is right, the paper's identification fails. Provide maximum institutional detail. Run Conley et al. (2012) plausibly exogenous IV bounds. |
| Monotonicity | "There may be defiers in this setting." | Argue from institutional details why defiance is implausible. Test for heterogeneity in first stage across subgroups — monotonicity implies same-signed first stage everywhere. |

---

## Common Referee Concerns: Difference-in-Differences

| Concern | Typical Phrasing | Response Strategy |
|---------|-----------------|-------------------|
| Pre-trends | "Figure X shows concerning pre-trends." | Run formal pre-trend tests. Report Rambachan-Roth sensitivity analysis. If pre-trends exist, explore detrending or synthetic DiD. Show that results are robust to controlling for group-specific linear trends. |
| Parallel trends | "What justifies the parallel trends assumption?" | Plot raw outcomes for treated vs control. Report pre-treatment covariate balance. Discuss institutional reasons why trends should be similar. Run placebo treatment timing tests. |
| Staggered timing | "TWFE is biased with heterogeneous treatment effects and staggered adoption." | Switch to Callaway-Sant'Anna or Sun-Abraham. Report Bacon decomposition of TWFE estimate. Show results are similar (or explain differences). |
| Spillovers | "Treatment may spill over to control units." | Define control group more carefully (geographic distance, economic isolation). Test for treatment effects in "nearby control" units. Discuss direction of bias from spillovers. |
| Compositional changes | "The sample composition changes around the treatment date." | Show balanced panel results. Verify no differential attrition. Run on a fixed sample with no entry/exit. |
| Anticipation | "Agents may have anticipated the policy change." | Test for effects in pre-treatment periods. If anticipation is plausible, shift the treatment date earlier and re-estimate. Discuss institutional details about policy announcement vs implementation. |

---

## Common Referee Concerns: Structural Estimation

| Concern | Typical Phrasing | Response Strategy |
|---------|-----------------|-------------------|
| Functional form | "Results may be driven by functional form assumptions." | Report sensitivity to alternative functional forms (logit vs probit, parametric vs semiparametric). Show that key qualitative results survive flexible specifications. |
| Identification | "It is unclear what variation identifies the parameters." | Add a formal identification argument (preferably in the model section). Show which moments or data patterns pin down each parameter. Report identification-at-infinity or point-identification conditions. |
| Computational issues | "How do you know the solution is a global optimum?" | Report results from multiple starting values. Show the objective function surface. Report convergence diagnostics. For MPEC, report constraint violations. |
| Counterfactual validity | "The counterfactual is far from the data." | Report how far counterfactual parameters are from estimated values. Conduct sensitivity analysis around the counterfactual. Validate the model on out-of-sample data. |
| External validity | "The model is estimated on [specific context] and may not generalize." | Acknowledge the limitation. If possible, validate on a holdout sample or different context. Discuss which model features are context-specific vs general. |

---

## Common Referee Concerns: Regression Discontinuity

| Concern | Typical Phrasing | Response Strategy |
|---------|-----------------|-------------------|
| Manipulation | "Agents may manipulate the running variable to sort around the cutoff." | Report McCrary/Cattaneo-Jansson-Ma density test. Show histogram of running variable. If institutional rules prevent manipulation, explain them. Show covariate balance at the cutoff. |
| Bandwidth sensitivity | "Results are sensitive to bandwidth choice." | Report results at 0.5x, 0.75x, 1x, 1.25x, 1.5x, 2x the optimal bandwidth. Show a coefficient plot across bandwidths. Report both MSE-optimal and CER-optimal bandwidths. |
| Local effect | "The effect is identified only at the cutoff and may not generalize." | Acknowledge this is inherent to RDD. If the cutoff is policy-relevant (e.g., eligibility threshold), emphasize this. Explore heterogeneity away from the cutoff cautiously (using extrapolation methods from Angrist-Rokkanen 2015). |
| Polynomial order | "Why use a linear specification? A quadratic might be more appropriate." | Local linear (p=1) is the standard recommendation (Gelman-Imbens 2019 argue against higher-order polynomials). Report robustness to local quadratic. Use rdrobust which selects optimal polynomial. |
| Discrete running variable | "The running variable takes few distinct values." | Use Cattaneo-Idrobo-Titiunik methods for discrete running variables. Report results with and without clustering on the running variable. Standard rdrobust may not be appropriate. |

---

## Common Referee Concerns: Matching / Selection on Observables

| Concern | Typical Phrasing | Response Strategy |
|---------|-----------------|-------------------|
| Unobservables | "The selection-on-observables assumption is strong. Unobserved confounders may bias results." | Report Oster (2019) bounds or Altonji-Elder-Taber (2005) sensitivity analysis. Show that results survive controlling for increasingly rich sets of observables. Report Rosenbaum bounds. |
| Common support | "There is limited overlap between treated and control propensity score distributions." | Show propensity score density plots by treatment status. Report the fraction of observations trimmed. Show results are robust to alternative trimming thresholds. |
| Model dependence | "Results may depend on the propensity score model specification." | Report results from multiple specifications (logit, probit, random forest). Use doubly robust estimator (AIPW). Show covariate balance under each specification. |
| Balance | "Standardized mean differences remain large after matching." | Report Love plot of SMDs before and after matching. Target SMD < 0.1 on all covariates. If balance is poor, consider a different matching method or add covariates. |

---

## Anti-Patterns: Response Letter

| Anti-Pattern | Why It Fails | Better Approach |
|--------------|-------------|-----------------|
| Defensive or combative tone | Alienates referees and editors. Signals unwillingness to engage. | Thank the referee, acknowledge the concern, then explain your position with evidence. |
| Ignoring minor comments | Signals carelessness. Editors notice when comments are skipped. | Address every single comment, even if briefly ("Thank you, we have corrected this typo on p.7"). |
| Responding with only "Done" | Referee cannot verify the change without re-reading the entire paper. | Quote the specific change: "We have added the following sentence to Section 3 (p.12): '[quote]'." |
| Bulk-dismissing concerns | "We believe our original approach is correct" repeated for multiple points. | Each concern deserves an individual, substantive response. |
| Adding results not requested | Stuffing the paper with unrequested analyses dilutes the revision. | Focus on what was asked. Add unrequested improvements only if they directly strengthen the paper. |
| Not updating the literature review | Referees often suggest papers to cite. Ignoring these suggestions is noticed. | Add every reasonable citation suggestion. Explain how the paper relates to yours. |
| Submitting without the diff | Editor must manually compare versions, slowing the process. | Always include a latexdiff or tracked-changes version alongside the clean manuscript. |
| Waiting too long to resubmit | After 12+ months, referees may have forgotten the paper. Some journals revoke the R&R. | Aim to resubmit within 3-6 months. If you need more time, inform the editor. |

---

## Anti-Patterns: Manuscript

| Anti-Pattern | Why It Fails | Better Approach |
|--------------|-------------|-----------------|
| Burying the contribution | Reader must wade through 10 pages before understanding what the paper does. | State the question, method, and main result in the first two paragraphs of the introduction. |
| Results without context | Coefficients without economic interpretation ("the coefficient is 0.043"). | Interpret magnitudes: "A one-standard-deviation increase in X increases Y by 4.3%, roughly equivalent to [meaningful comparison]." |
| Too many tables | 20+ tables signal data mining. Editors want focused results. | 4-6 main tables. Move the rest to an appendix. |
| Inconsistent notation | Using both beta and b for the same coefficient in different sections. | Define notation once and use it consistently throughout. |
| Claiming causality without identification | "Our results show that X causes Y" after running an OLS regression with no causal strategy. | Be precise: "conditional on controls, X is associated with Y" unless you have a valid identification strategy. |
| No robustness section | Single specification, no sensitivity analysis. Referees will question every choice. | Dedicate a section to alternative specifications, sample definitions, and estimation methods. |

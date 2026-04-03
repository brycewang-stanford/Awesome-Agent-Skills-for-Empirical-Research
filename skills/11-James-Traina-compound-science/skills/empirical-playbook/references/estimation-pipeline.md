# Applied Micro Toolkit: Estimation Pipeline

Gated estimation pipeline from data validation through robustness. Load this when running or planning an empirical estimation, or when the `/estimate` command is invoked. Each phase has an explicit quality gate that must be cleared before proceeding.

This pipeline applies to any estimator: OLS, IV/2SLS, GMM, MLE, BLP, NFXP, MPEC, nonlinear LS, and custom structural models. The gates adapt to estimator complexity — linear models will pass quickly, nonlinear structural models will exercise every gate.

---

## Phase 1: Data Validation

**Purpose:** Confirm that the data are clean and suitable for estimation before any compute is spent on optimization or inference.

### Steps

1. **Locate data files** referenced in the model specification or estimation code. If no data file is found or specified, stop and ask the researcher to provide one.

2. **Profile key variables** against the following checklist:

   | Check | Threshold | Action if violated |
   |-------|-----------|-------------------|
   | Existence | All variables referenced in specification must exist in the dataset | Report missing variables |
   | Missing values | Flag variables with >5% missing | Report rates; document how missingness is handled (drop, impute, bound) |
   | Outliers | Values beyond 5 IQR from the median | Report but do not auto-trim; trimming is a research decision |
   | Panel structure | If panel: verify balanced/unbalanced, check for gaps in time dimension | Report gaps and unbalancedness |
   | Instrument relevance | If IV: run a quick first-stage regression | Report F-statistic (detailed check in Phase 2) |
   | Variable types | Numeric variables are numeric; categorical variables are properly coded | Flag type mismatches |
   | Sample size | Report N, number of clusters (if clustered), number of time periods (if panel) | Flag if N is very small relative to parameter count |

3. **Construct working dataset.** Apply sample restrictions from the specification (drop missing, restrict to subpopulation, trim if specified by the researcher). Document every restriction and the number of observations dropped at each step. The final analytic sample must be fully reproducible from these documented steps.

### GATE: Data Validation

Evaluate all profiling results. If any of the following critical issues are present, **stop and report the issue — do not proceed to Phase 2:**

- A key dependent or treatment variable does not exist in the dataset
- A key variable has zero variation (constant column)
- The dependent variable is entirely missing
- Sample size after restrictions is insufficient for the model (fewer observations than parameters)

If issues are present but non-critical (moderate missingness, outliers, minor type warnings), document the warnings and proceed.

---

## Phase 2: Identification Check

**Purpose:** Verify that the model is identified before investing in estimation. An estimator applied to an unidentified model produces meaningless numbers, regardless of convergence.

### Steps

1. **State the identification strategy** explicitly:
   - **Target parameter:** What causal or structural parameter is being estimated?
   - **Identifying variation:** What source of variation in the data identifies this parameter?
   - **Key assumptions:** What untestable assumptions are required (exclusion restrictions, parallel trends, continuity, functional form)?

2. **Dispatch the `identification-critic` agent** with the identification strategy. The agent evaluates:
   - Whether exclusion restrictions are plausible
   - Whether rank conditions hold (are instruments relevant and sufficient?)
   - Whether functional form is doing the identification work (a red flag for credibility)
   - Whether identification is point or set (partial identification changes the downstream pipeline)

3. **Run identification diagnostics** — compute every applicable test:

   | Test | When to run | Failure signal |
   |------|-------------|---------------|
   | First-stage F-statistic | IV / 2SLS / GMM | F < 10 is weak; F < 4 is very weak (Stock-Yogo critical values for bias) |
   | Kleibergen-Paap rank test | IV with multiple instruments | Rejection failure indicates under-identification |
   | Anderson-Rubin test | IV with weak-instrument concern | Provides inference robust to weak instruments |
   | Hausman test | Comparing IV to OLS | Large discrepancy suggests endogeneity; small discrepancy questions need for IV |
   | Sargan/Hansen J-test | Overidentified IV/GMM | Rejection suggests at least one instrument is invalid |

4. **Decision tree:**

   ```
   Identification diagnostics complete
   ├── All tests pass, identification-critic has no critical concerns
   │   └── PROCEED to Phase 3
   ├── Results are questionable (borderline F, minor concerns from critic)
   │   └── Document concerns prominently in the estimation record
   │       └── PROCEED to Phase 3 (the researcher may have domain reasons)
   └── Identification clearly fails
       ├── First-stage F < 4
       ├── Rank condition violated (Kleibergen-Paap rejects)
       └── identification-critic flags fundamental logical failure in exclusion restriction
           └── STOP. Report failure. Suggest fixes:
               - Stronger instruments
               - Alternative identification strategy
               - Partial identification / bounds approach
               - Dispatch to `identification-critic` agent for formal identification argument
   ```

### GATE: Identification

**Do not proceed to Phase 3 until identification status is resolved.** A "questionable" result is acceptable if documented; a clear failure is not. If the first-stage F-statistic is below 4 or the rank condition is violated, the pipeline stops here. Proceeding with a known-unidentified model wastes compute and produces unreliable estimates.

---

## Phase 3: Estimation with Convergence Monitoring

**Purpose:** Run the estimator with active monitoring. The goal is verified convergence to a global optimum, not just "the optimizer returned a number."

### Steps

1. **Detect the estimation method** from the specification or code:

   | Method | Convergence risk | Key concern |
   |--------|-----------------|-------------|
   | OLS / WLS | Very low | Check multicollinearity (condition number) |
   | 2SLS / IV | Low | Numerical issues with many instruments; check first-stage |
   | MLE | Moderate–High | Local optima; flat likelihood near boundary; separation |
   | GMM | Moderate | Weighting matrix iteration; many-moment instability |
   | BLP | High | Contraction mapping convergence; starting values critical |
   | NFXP | High | Inner loop must fully converge before each outer step |
   | MPEC | Moderate–High | Constraint satisfaction; optimizer tolerance settings |
   | Nonlinear LS | Moderate | Starting values; gradient accuracy; variable scaling |

2. **Starting values strategy** (for all nonlinear estimators — skip for OLS/IV):
   - Generate at least **3 random starting value vectors** drawn from a reasonable domain for each parameter (use domain knowledge to set bounds: e.g., elasticities in [-5, 0], discount factors in [0.8, 1.0])
   - Generate **1 informed starting value** from a simpler model (OLS estimates, prior literature, simulated method of moments)
   - Run all 4+ starting value sets through the optimizer
   - Compare convergence points: if they agree to 3+ significant digits, accept; if they disagree, there are multiple local optima — flag immediately

3. **Convergence monitoring** — track these metrics during estimation:

   | Metric | Normal behavior | Red flag |
   |--------|----------------|----------|
   | Iteration count | Well below limit | Approaching or hitting iteration limit (default: 1000) |
   | Gradient norm | Monotonically decreasing to near zero | Cycling, stuck above tolerance, or oscillating |
   | Objective function | Monotonically improving (decreasing for min, increasing for max) | Flat regions, sudden jumps, or non-monotone |
   | Step size | Moderate, gradually decreasing | Extremely small (line search failing) or extremely large (divergence) |
   | Parameter values | Stable, within reasonable domain | Hitting boundary constraints or growing without bound |
   | Inner loop (nested estimation) | Converges at every outer iteration | Inner solver fails or returns early before convergence |

4. **Non-convergence handling protocol:**

   ```
   Optimizer fails to converge
   ├── Try alternative algorithm
   │   ├── BFGS failed → try Newton-Raphson (if analytical Hessian available)
   │   ├── Newton failed → try BFGS or L-BFGS-B
   │   └── Both gradient methods failed → try Nelder-Mead (derivative-free)
   ├── If all algorithms fail on the full model
   │   ├── Rescale variables (normalize to similar magnitudes)
   │   ├── Check for near-collinearity in the design matrix
   │   ├── Estimate a simplified model (fewer parameters) to get starting values
   │   └── Re-parameterize (e.g., estimate log-sigma instead of sigma)
   └── If nothing converges
       └── STOP. Report all convergence attempts with diagnostics.
           Document: algorithm, iterations, final gradient norm, objective value.
   ```

5. **Dispatch the `numerical-auditor` agent** on the estimation code. The auditor checks:
   - Floating-point stability (log-likelihood, not raw likelihood; log-sum-exp tricks)
   - Condition number of key matrices (Hessian, weighting matrix, design matrix)
   - Gradient computation accuracy (do analytical and numerical gradients agree?)
   - RNG seeding (any simulation-based component must be seeded)

6. **Specialized dispatches** (when applicable):
   - For models with equilibrium computation: dispatch `identification-critic` to verify existence, uniqueness, and stability
   - For calibrated structural models: dispatch `econometric-reviewer` to verify parameter reasonableness and moment selection

### GATE: Convergence

**Do not proceed to Phase 4 until convergence is verified.** Specifically:

- The optimizer must report successful convergence (exit flag indicates convergence, not iteration limit)
- The gradient norm must be below the specified tolerance
- At least two starting value sets must converge to the same point (for nonlinear models)
- The `numerical-auditor` must not flag critical numerical instability (e.g., singular Hessian, condition number > 10^15)

If convergence cannot be achieved after exhausting the non-convergence protocol above, the pipeline stops. Do not compute standard errors or robustness checks on non-converged estimates — they are meaningless.

---

## Phase 4: Inference

**Purpose:** Compute standard errors that are appropriate to the data structure and estimation method. The SE method must be an explicit, justified choice.

### Steps

1. **Select SE method** using this decision table:

   | Data structure | Default SE method | When to override |
   |---------------|-------------------|-----------------|
   | Cross-section, no heteroskedasticity concern | Classical OLS SEs | Rarely appropriate; prefer robust |
   | Cross-section, general | HC1 (Eicker-Huber-White robust) | Default for cross-sectional work |
   | Panel with entity clustering | Clustered at entity level | Cluster at the level of treatment assignment |
   | Multi-way clustering needed | Two-way clustered (e.g., firm + time) | When shocks are correlated along two dimensions |
   | Spatial data | Conley SEs (HAC in space) | Requires distance cutoff specification |
   | Complex nonlinear model | Bootstrap (percentile or BCa) | Use at least 999 replications; 1999 is better |
   | GMM | Sandwich with optimal weighting matrix | Standard for GMM; check weighting matrix convergence |
   | MLE | Observed information matrix (Hessian-based) | Verify Hessian is positive definite first |

   **Auto-detection rule:** If panel structure was detected in Phase 1, default to clustered SEs at the highest level at which treatment varies. If cross-section, default to HC1. If nonlinear with no analytical SE formula, default to bootstrap. The SE method must be stated explicitly in the output — never silently default.

2. **SE diagnostics** — run all applicable checks:

   | Diagnostic | Check | Concern |
   |-----------|-------|---------|
   | Hessian positive definiteness | For MLE: eigenvalues of Hessian must all be positive | Non-PD Hessian means the SEs are unreliable; the model may not be at a maximum |
   | Robust vs classical comparison | Compute both; compare | Large discrepancy (ratio > 2) indicates heteroskedasticity or misspecification |
   | Cluster count | Report number of clusters | Fewer than 30 clusters: standard cluster-robust SEs have poor finite-sample properties; use wild cluster bootstrap |
   | Bootstrap distribution | For bootstrapped SEs: inspect the bootstrap distribution | Bimodality suggests multiple modes; extreme outliers suggest instability |

3. **Construct inference output:**
   - Point estimates with SEs, t/z-statistics, p-values
   - 95% confidence intervals (report 90% CI additionally for marginally significant results near conventional thresholds)
   - Significance indicators: * p<0.10, ** p<0.05, *** p<0.01

### GATE: Inference

**The SE method must be explicitly chosen and documented — not silently defaulted by the software.** Verify:

- The SE method is stated in the output
- The SE method is appropriate to the data structure (the table above was consulted)
- If MLE: the Hessian is positive definite
- If clustered: the number of clusters is reported and is at least 30 (or wild bootstrap is used)

If the Hessian is not positive definite for an MLE model, the standard errors are unreliable. Return to Phase 3 and investigate: the optimizer may not have found a true maximum (saddle point, boundary solution).

---

## Phase 5: Robustness

**Purpose:** Assess how sensitive the results are to specification, algorithm, sample, and starting value choices. This phase always produces output — there is no gate that stops the pipeline. Even negative robustness findings (fragile results) are informative and must be reported.

### Steps

1. **Starting value sensitivity** (nonlinear estimators only):
   - Confirm all starting value vectors from Phase 3 converge to the same optimum
   - If they do not: report each distinct optimum with its objective function value
   - Identify which optimum is the global one (lowest objective for minimization, highest for maximization)
   - Flag if the preferred estimate is at a local, not global, optimum

2. **Algorithm sensitivity:**
   - Re-estimate the converged model with at least one alternative optimization algorithm
   - Compare point estimates: they should agree to at least 3 significant digits
   - If they disagree materially: investigate (flat objective surface? boundary solution? numerical precision?)

3. **Subsample stability:**
   - Draw 3 random 80% subsamples (without replacement)
   - Re-estimate the model on each subsample
   - Compare key coefficients across subsamples
   - Flag any coefficient that changes sign across subsamples — this indicates fragile identification or influential observations
   - Report the maximum percentage deviation from the full-sample estimate

4. **Specification sensitivity** (where defensible alternatives exist):
   - Add or remove control variables that are commonly included in the literature
   - Try alternative functional forms (log vs level, polynomial vs linear)
   - Test alternative instrument sets (if IV) or alternative bandwidths (if RDD)
   - Document each specification choice and its result

5. **Compile robustness summary table:**

   | Check | Result | Concern level |
   |-------|--------|--------------|
   | Starting values | Same optimum / N distinct optima found | None / High |
   | Algorithm sensitivity | Estimates agree within X digits | None / Moderate / High |
   | Subsample stability | Max coefficient variation: X% | None (<10%) / Moderate (10–30%) / High (>30% or sign change) |
   | Specification sensitivity | Key result robust to N of M alternatives | None / Moderate / High |

6. **Dispatch `econometric-reviewer` agent** for final review of the full estimation:
   - Review estimation code quality and correctness
   - Check identification strategy implementation matches the stated strategy
   - Verify SE computation is appropriate
   - Flag any methodological concerns not caught in earlier phases

7. **Save results** to `docs/estimates/YYYY-MM-DD-<model-name>.md`:
   - Include coefficient table, diagnostic table, robustness summary
   - Cross-reference the estimation code file(s)
   - Record the full specification: variables, sample restrictions, SE method, optimizer, convergence diagnostics

---

## Pipeline Summary

```
Phase 1: Data Validation
  │  GATE: Critical data issues? → STOP
  ▼
Phase 2: Identification Check
  │  GATE: Identification clearly fails? → STOP
  ▼
Phase 3: Estimation with Convergence Monitoring
  │  GATE: Non-convergence after all alternatives? → STOP
  ▼
Phase 4: Inference
  │  GATE: SE method not explicitly chosen or Hessian non-PD? → RETURN TO PHASE 3
  ▼
Phase 5: Robustness
  │  No gate — always produce results
  ▼
  Results saved to docs/estimates/
```

Each gate is a hard decision point. The purpose of the gates is to prevent downstream waste: there is no value in computing standard errors on a non-converged model, and there is no value in running robustness checks on an unidentified specification. When a gate stops the pipeline, it must report what failed, why, and what the researcher should do next.

---

## Integration

**Agents dispatched by this pipeline:**
- `identification-critic` (Phase 2) — evaluates identification argument
- `numerical-auditor` (Phase 3) — checks floating-point stability and gradient accuracy
- `identification-critic` (Phase 3, if applicable) — verifies equilibrium properties
- `econometric-reviewer` (Phase 3, if applicable) — reviews calibration strategy
- `econometric-reviewer` (Phase 5) — final review of the full estimation

**Commands that invoke this pipeline:**
- `/estimate` — runs the full 5-phase pipeline autonomously

**Related skills:**
- `structural-modeling` — methodology reference for BLP, NFXP, MPEC, dynamic discrete choice
- `causal-inference` — implementation details for IV, DiD, RDD, synthetic control
- `empirical-playbook` (parent) — method selection, diagnostics by method, research design checklist

**Follow-up after estimation:**
- `empirical-playbook` skill → `diagnostic-battery.md` — additional diagnostic tests
- `empirical-playbook` skill → `sensitivity-analysis.md` — Oster bounds, specification curve, breakdown frontier
- `publication-output` skill → `table-generation.md` — format results for publication
- `/workflows:compound` — capture estimation insights into the solutions knowledge base

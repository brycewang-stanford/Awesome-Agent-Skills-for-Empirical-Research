---
name: empirical-playbook
argument-hint: "<method, research question, or diagnostic>"
description: >-
  This skill covers applied microeconomic empirical methods and research design. Use when the user is selecting an identification strategy, comparing estimators, running diagnostics, designing a research study, or evaluating an empirical strategy. Triggers on "which method", "what estimator", "how to choose", "method comparison", "empirical strategy", "research design", "applied micro", "identification strategy", "power analysis", "design-based", "model-based", "minimum detectable effect", "specification".
---

# Applied Micro Toolkit

Reference for applied micro research design: method selection, diagnostics, inference, pitfalls, reporting standards, and power analysis.

## When to Use This Skill

Use when the user is:
- Choosing between empirical methods for a causal question
- Evaluating which identification strategy fits their data and setting
- Running standard diagnostic tests and unsure which ones apply
- Designing a study and needs to calculate statistical power
- Reviewing or critiquing an empirical strategy
- Preparing the "Empirical Strategy" section of a paper
- Downloading macroeconomic or cross-national data (see `references/data-sources.md` for FRED/World Bank API access)

Skip when:
- Implementation details for a specific method are needed (use `causal-inference` skill for IV, DiD, RDD, SC, matching)
- The task is structural estimation (use `structural-modeling` skill)
- The task is manuscript preparation or journal logistics (use `submission-guide` skill)
- The task is formal identification proof (use `identification-proofs` skill)
- The task is Bayesian model specification (use `bayesian-estimation` skill)

After selecting a method, the `econometric-reviewer` agent can review the implementation and the `identification-critic` agent can evaluate the identification argument.

## Method Selection Decision Tree

Start with the fundamental question: **What source of variation identifies the causal effect?**

### Step 1: What is your source of variation?

| Source of Variation | Method Family | Key Assumption |
|--------------------|---------------|----------------|
| Randomized assignment (with full compliance) | Experimental analysis (OLS on treatment indicator) | Random assignment |
| Randomized assignment (with imperfect compliance) | IV / 2SLS using random assignment as instrument | Exclusion restriction, monotonicity |
| Policy change at a sharp threshold | Sharp RDD | Continuity of potential outcomes at cutoff |
| Policy change at a threshold with imperfect compliance | Fuzzy RDD (= IV at the cutoff) | Continuity + monotonicity at cutoff |
| Policy change at a point in time, with affected and unaffected groups | Difference-in-differences | Parallel trends |
| Staggered policy adoption across units over time | Staggered DiD (Callaway-Sant'Anna, Sun-Abraham, etc.) | Parallel trends (conditional on group and time) |
| Rare event affecting a single unit, long pre-treatment data | Synthetic control | Pre-treatment fit implies post-treatment counterfactual |
| Exogenous shifter of treatment that does not affect outcome directly | IV / 2SLS / GMM | Exclusion restriction, relevance, monotonicity |
| Rich set of observables that plausibly captures all confounders | Matching, IPW, AIPW (selection on observables) | Conditional independence (no unobserved confounders) |
| No credible exogenous variation | Sensitivity analysis, bounds, partial identification | Depends on bounding assumptions |

### Step 2: Refinements Within Method Families

**Within DiD:**

```
Is treatment timing staggered?
├── No → Classic 2x2 DiD (TWFE is fine)
└── Yes
    ├── Can treatment turn off (reversals)?
    │   ├── Yes → de Chaisemartin-D'Haultfoeuille (2020)
    │   └── No
    │       ├── Do you have never-treated units?
    │       │   ├── Yes → Callaway-Sant'Anna (2021) with never-treated controls
    │       │   └── No → Callaway-Sant'Anna with not-yet-treated controls
    │       │           or Sun-Abraham (2021)
    │       └── Are effects likely heterogeneous across cohorts?
    │           ├── Yes → Callaway-Sant'Anna or Sun-Abraham (NOT TWFE)
    │           └── No → TWFE is OK, but report Bacon decomposition
```

**Within IV:**

```
How many instruments for how many endogenous regressors?
├── Exactly identified (K instruments = K endogenous)
│   └── 2SLS (= IV = Wald estimator for single instrument)
├── Over-identified (K instruments > K endogenous)
│   ├── 2SLS (default)
│   ├── GMM (efficient, use if heteroskedasticity suspected)
│   └── LIML (less biased with weak instruments)
└── Under-identified (K instruments < K endogenous)
    └── Cannot identify all parameters — need more instruments or fewer endogenous regressors
```

**Within RDD:**

```
Does crossing the threshold guarantee treatment?
├── Yes → Sharp RDD
└── No → Fuzzy RDD
    └── Is the running variable continuous?
        ├── Yes → Standard rdrobust
        └── No (discrete / few mass points)
            └── Cattaneo-Idrobo-Titiunik (2019) discrete RD methods
```

**Within Matching / Selection on Observables:**

```
Is the selection-on-observables assumption plausible?
├── No → Need a different identification strategy
└── Yes
    ├── Do you need ATE or ATT?
    │   ├── ATE → IPW or AIPW
    │   └── ATT → Matching or IPW with ATT weights
    ├── Is the propensity score model well-specified?
    │   ├── Uncertain → Use AIPW (doubly robust)
    │   └── Confident → IPW or regression adjustment
    └── Many covariates or nonlinear confounding?
        ├── Yes → ML-based methods (causal forests, DML)
        └── No → Parametric PS model + AIPW
```

## Standard Diagnostics by Method

Key diagnostics to run for each method family. For full reporting checklists and minimum standards, see `references/reporting-standards.md`.

| Method | Must-Run Diagnostics | Key Concern |
|--------|---------------------|-------------|
| IV / 2SLS | First-stage F (KP), reduced form, overid test | Weak instruments (F < 10), exclusion restriction |
| DiD (classic) | Pre-trend F-test, event study plot, raw means by group/period | Parallel trends violation |
| Staggered DiD | Bacon decomposition, Callaway-Sant'Anna group-time ATTs | Negative TWFE weights with heterogeneous effects |
| RDD | McCrary density test, covariate balance at cutoff, bandwidth sensitivity | Manipulation of running variable, extrapolation bias |
| Synthetic Control | Pre-fit RMSPE, permutation p-value, leave-one-out | Pre-period fit quality, donor pool sensitivity |
| Matching / AIPW | Overlap plots, Love plot (SMD before/after), Oster/Rosenbaum bounds | Lack of overlap, unobserved confounders |
| Structural | Convergence, identification rank condition, robustness to starting values | Global vs local optimum, identification failure |

For implementation details and diagnostic code by method, see the `causal-inference` skill.

## Inference Frameworks

### Clustering Decision Rule

1. Identify the level at which treatment is assigned → cluster at that level (minimum)
2. If there are within-cluster correlations beyond treatment (e.g., spatial), consider multi-way clustering
3. If the number of clusters is small (< 30–40), use wild cluster bootstrap (Cameron-Gelbach-Miller 2008)
4. If the number of clusters is very small (< 10), cluster-robust methods may not work at all — consider randomization inference or aggregate to the cluster level

| Mistake | Consequence | Fix |
|---------|------------|-----|
| Clustering too fine (individual when treatment is at state level) | SEs too small; over-rejection | Cluster at the level of treatment assignment |
| Few clusters (< 30–40) with standard cluster-robust SEs | Poor finite-sample properties | Wild cluster bootstrap |
| Not clustering when treatment varies at group level | SEs dramatically understated | Always cluster at level of treatment assignment |

### Design-Based vs Model-Based Inference

| Dimension | Design-Based | Model-Based |
|-----------|-------------|-------------|
| Source of randomness | Treatment assignment mechanism | Outcome draws from a superpopulation |
| Key assumption | Known or modeled treatment assignment | Correct outcome model specification |
| Examples | Experiments, RCTs, RDD, DiD, natural experiments | Structural models, matching, cross-sectional surveys |
| Advantages | Transparent; does not require outcome model | More powerful; extends to complex settings |

Design-based is appropriate when the assignment mechanism is known (experiments, lotteries, cutoffs). Model-based when random sampling is reasonable. The standard in applied micro is hybrid: design-based identification + model-based inference. Doubly robust methods (AIPW) combine both.

## Power Analysis

The key quantity is the Minimum Detectable Effect (MDE) — the smallest effect detectable with 80% power at alpha = 0.05.

**Quick MDE formula (equal groups, two-sided test):**

```
MDE = 2.8 × sigma / sqrt(N)

Required N = (2.8 × sigma / MDE)²
```

For IV designs, the effective MDE is inflated by the inverse of the first-stage coefficient: `MDE_IV ≈ MDE_OLS / |pi|`. A weak first stage (small pi) dramatically reduces power.

For DiD designs, effective power increases with more post-treatment periods and higher within-group correlation (absorbed by FEs). For RDD, use effective N (observations within bandwidth), not total N.

For cluster-randomized designs, the design effect `(1 + (m-1) × ICC)` inflates variance — with ICC = 0.05 and cluster size m = 50, you need 3.45x as many observations.

For full MDE formulas (DiD, IV, RDD, cluster-randomized), power simulation code, and MDE interpretation tables, see `references/reporting-standards.md`.

## Research Design Checklist

### Before Touching Data

- [ ] **Research question**: What causal parameter are you trying to estimate? Write it as a formal estimand.
- [ ] **Identification strategy**: What source of variation identifies the effect? Draw the DAG.
- [ ] **Assumptions**: List all identification assumptions explicitly. Which are testable?
- [ ] **Threats**: For each assumption, what is the most plausible violation? How would you detect it?
- [ ] **Power**: Given your expected sample size, what is the MDE? Is it policy-relevant?
- [ ] **Pre-analysis plan**: For prospective studies, register the plan before seeing outcomes.

### During Analysis

- [ ] **Data cleaning documented**: Every sample restriction justified and recorded.
- [ ] **Summary statistics**: Know your data before running regressions.
- [ ] **Main specification**: Run the main spec first. Resist the urge to search for significance.
- [ ] **Diagnostics**: Run all standard diagnostics for your method (see table above).
- [ ] **Robustness**: Vary specification choices systematically.
- [ ] **Magnitude interpretation**: Can you explain the coefficient in plain language?

### Before Submission

- [ ] **All diagnostics reported**: See method-specific standards in `references/reporting-standards.md`.
- [ ] **Replication package**: Code runs from raw data to all tables and figures.
- [ ] **Seeds set**: All random number generators seeded for reproducibility.
- [ ] **Limitations discussed**: What are the strongest objections? Address them in the paper.
- [ ] **Literature positioned**: Have you cited and compared to the 5 closest papers?

## Common Pitfalls

### Bad Controls

A "bad control" is a variable that is itself an outcome of treatment. Conditioning on it introduces selection bias.

| Variable Type | Example | Why It Is Bad |
|--------------|---------|---------------|
| Post-treatment outcome | Controlling for occupation when estimating returns to education | Education affects occupation; conditioning selects on an outcome of treatment |
| Mediator | Controlling for wages when estimating effect of training on employment | Blocks part of the causal effect |
| Collider | Conditioning on "survived" when estimating health effects | Opens a non-causal path |

**Rule of thumb:** If you cannot be sure a variable is determined before treatment, do not include it as a control. When in doubt, draw the DAG.

### Staggered DiD with Heterogeneous Effects

| Mistake | Consequence | Fix |
|---------|------------|-----|
| Running TWFE with staggered timing | Already-treated units used as controls; negative weights; estimate can have wrong sign | Use Callaway-Sant'Anna, Sun-Abraham, or other modern DiD estimator |
| Using single post-treatment indicator for all cohorts | Masks heterogeneity in treatment effects across cohorts | Estimate group-time ATTs separately, then aggregate |
| Not reporting the Bacon decomposition | Reader cannot assess how much of the TWFE estimate comes from problematic comparisons | Report `bacondecomp` output |

### Forbidden Regressions

Never plug a manual first-stage into an OLS second stage (SEs are wrong — use proper 2SLS). Never use a nonlinear first stage with linear second stage (not consistent — use control function). Never include generated regressors without bootstrapping the full two-step procedure.

## Integration

For full minimum reporting standards (method-specific checklists for IV, DiD, RDD, SC, Matching) and complete power analysis code, see `references/reporting-standards.md`. For sensitivity analysis procedures (Oster bounds, Conley bounds, breakdown frontiers, specification curves), see `references/sensitivity-analysis.md`.

**Agents:**

- `econometric-reviewer`: Reviews identification strategy, standard errors, and diagnostic results
- `identification-critic`: Evaluates identification argument completeness and exclusion restrictions
- `numerical-auditor`: Designs power simulations for nonstandard study designs
- `journal-referee`: Reviews whether the empirical strategy meets journal standards

**Cross-references:**

- `identification-proofs` skill: Formalize an identification argument for the chosen method
- `references/diagnostic-battery.md`: Run the full diagnostic battery for the estimated specification
- `references/sensitivity-analysis.md`: Run sensitivity analysis (Oster bounds, specification curve, breakdown frontier)
- `publication-output` skill: Format regression tables and diagnostic output for publication

# Causal Inference Methodology

A practitioner's guide to causal reasoning in empirical research. This reference covers
when and why to use causal methods, the assumptions behind each design, and how to
evaluate the credibility of causal claims. For implementation syntax, load the
appropriate library skill (e.g., `pyfixest`, `statsmodels`).

## Contents

- [Acknowledgments](#acknowledgments)
- [The Fundamental Problem of Causal Inference](#the-fundamental-problem-of-causal-inference)
- [The Potential Outcomes Framework](#the-potential-outcomes-framework)
- [Directed Acyclic Graphs (DAGs)](#directed-acyclic-graphs-dags)
- [The Credibility Revolution](#the-credibility-revolution)
- [The Identification Problem](#the-identification-problem)
- [Method Selection Guide](#method-selection-guide)
- [Method-Specific Guidance](#instrumental-variables-key-diagnostics)
- [Modern Difference-in-Differences: A Practitioner's Guide](#modern-difference-in-differences-a-practitioners-guide)
- [Multiple Testing Corrections](#multiple-testing-corrections)
- [Machine Learning for Causal Inference](#machine-learning-for-causal-inference)
- [Causal vs Descriptive: Knowing the Difference](#causal-vs-descriptive-knowing-the-difference)
- [Threats to Validity Checklist](#threats-to-validity-checklist)
- [Partial Identification and Sensitivity Analysis](#partial-identification-and-sensitivity-analysis)
- [References and Further Reading](#references-and-further-reading)

## Acknowledgments

These materials draw extensively from several open-access resources that the authors
have generously made available to the research community:

- **Scott Cunningham's** *Causal Inference: The Mixtape* (freely available at
  mixtape.scunning.com), which provides an exceptionally accessible introduction to
  the potential outcomes framework and quasi-experimental methods
- **Nick Huntington-Klein's** *The Effect* (freely available at theeffectbook.net),
  which offers an intuitive, DAG-centered approach to research design and causality
- **Joshua Angrist and Jorn-Steffen Pischke's** *Mastering 'Metrics* and *Mostly
  Harmless Econometrics*, which established the pedagogical framework of the "furious
  five" quasi-experimental methods and articulated the credibility revolution
- **Pedro Sant'Anna's** comprehensive DiD lecture series (psantanna.com/did-resources),
  which provides the clearest available exposition of why traditional TWFE fails and
  how modern estimators solve the problem
- **Baker, Callaway, Cunningham, Goodman-Bacon, and Sant'Anna's** practitioner's
  guide to DiD, which unifies the modern DiD literature into a coherent framework

Their contributions to accessible econometrics education are immensely valuable and
have shaped how a generation of researchers thinks about causal inference.

## The Fundamental Problem of Causal Inference

The fundamental problem, as articulated by Holland (1986), is deceptively simple: we
can only ever observe one potential outcome per unit. A student either received a
scholarship or did not. A state either expanded Medicaid or did not. We never observe
the same unit under both conditions at the same time.

The counterfactual -- what *would have happened* under the alternative treatment
status -- is fundamentally unobservable. This is not a data limitation that can be
solved by collecting more data. It is a logical impossibility: we cannot simultaneously
observe a treated and untreated version of the same unit.

All of causal inference is about constructing credible approximations to this missing
counterfactual. The methods differ in *how* they approximate it:

- **Randomized experiments** create statistical equivalence between groups by design
- **Regression/matching** conditions on observed characteristics to make groups comparable
- **Instrumental variables** isolates exogenous variation in treatment
- **Regression discontinuity** exploits known policy cutoffs that create quasi-random variation
- **Difference-in-differences** uses parallel temporal trends and differential treatment timing
- **Fixed effects** exploits within-unit variation over time to remove time-invariant confounders
- **Synthetic control** constructs a weighted combination of control units to match the treated unit

Two complementary frameworks formalize this reasoning:

1. **Potential outcomes** (the Rubin causal model): Defines causality in terms of
   Y(1) and Y(0) -- what happens under treatment vs. control
2. **Directed acyclic graphs** (the Pearl framework): Defines causality in terms of
   causal paths, back doors, and d-separation rules

These frameworks are not competing -- they illuminate different aspects of the same
problem. Following Cunningham (2021, Chs. 3-4) and Huntington-Klein (2022, Chs. 5-10),
researchers benefit from fluency in both.

## The Potential Outcomes Framework

Following the notation in Cunningham (2021, Ch. 4) and Angrist and Pischke (2009,
Ch. 2):

**Core notation:**
- Y_i(1) = outcome for unit i if treated
- Y_i(0) = outcome for unit i if not treated
- D_i = treatment indicator (1 = treated, 0 = control)
- Y_i = D_i * Y_i(1) + (1 - D_i) * Y_i(0) -- the "switching equation" mapping
  potential outcomes to the single observed outcome

**Treatment effect parameters:**

| Parameter | Definition | What It Captures |
|-----------|-----------|------------------|
| Individual treatment effect | tau_i = Y_i(1) - Y_i(0) | Effect for a specific unit (never observed) |
| ATE | E[Y(1) - Y(0)] | Average effect across the entire population |
| ATT | E[Y(1) - Y(0) \| D=1] | Average effect for those who actually received treatment |
| ATU | E[Y(1) - Y(0) \| D=0] | Average effect for those who did not receive treatment |
| LATE | Effect for compliers (IV) | Average effect for units whose treatment status is changed by the instrument |
| CATE | E[Y(1) - Y(0) \| X=x] | Average effect conditional on characteristics -- heterogeneous effects |

**The Simple Difference in Means (SDO) decomposition** (Cunningham 2021) reveals why
naive comparisons fail:

```
E[Y|D=1] - E[Y|D=0] = ATE + Selection Bias + Heterogeneous Treatment Effect Bias
```

Where:
- **ATE** is the quantity of interest
- **Selection bias** = E[Y(0)|D=1] - E[Y(0)|D=0] -- systematic baseline differences
  between treated and control groups (e.g., students who seek scholarships may already
  be higher-performing)
- **Heterogeneous treatment effect bias** = (1 - pi)(ATT - ATU) -- arises when effects
  vary across units and sorting into treatment is non-random

The simple comparison only equals the ATE when both bias terms are zero --
which randomization ensures by design.

**Key assumptions:**
- **Independence**: (Y(1), Y(0)) independent of D -- treatment assignment is unrelated
  to potential outcomes. Randomization guarantees this.
- **SUTVA** (Stable Unit Treatment Value Assumption): (1) each unit receives the same
  treatment dose, (2) no spillovers between units, and (3) no general equilibrium
  effects. SUTVA violations arise in network settings, when implementation quality
  varies, or when scaling changes the effect.

## Directed Acyclic Graphs (DAGs)

DAGs provide a visual language for encoding causal assumptions, following Pearl's
framework as presented in Huntington-Klein (2022, Chs. 6-8) and Cunningham (2021,
Ch. 3).

**Core components:**
- **Nodes** represent variables
- **Directed edges** (arrows) represent causal effects
- The absence of an arrow is itself a causal claim (no direct effect)

**Three fundamental structures:**

| Structure | Pattern | Implication |
|-----------|---------|-------------|
| Chain | A -> B -> C | B mediates the effect of A on C |
| Fork | A <- B -> C | B confounds the relationship between A and C |
| Collider | A -> B <- C | Conditioning on B creates a spurious association between A and C |

**Back door paths** are non-causal paths from treatment to outcome that create bias.
The **back door criterion** (Pearl 1995) states: to identify the causal effect of X
on Y, close all back door paths by conditioning on appropriate variables.

**Collider bias** is a critical pitfall: conditioning on a collider *opens* a
previously closed path and creates bias that did not exist before. Common examples
include conditioning on an intermediate outcome (e.g., studying only college graduates
when analyzing the effect of high school quality on earnings) or controlling for a
"bad control" that is itself affected by treatment.

**d-separation rules** formalize when paths are open or closed (Cunningham 2021, Ch. 3):
- A **chain** (A -> B -> C) is *open* unless you condition on B
- A **fork** (A <- B -> C) is *open* unless you condition on B
- A **collider** (A -> B <- C) is *closed* unless you condition on B (or a descendant of B)
- A path is **blocked** (d-separated) if any node along the path blocks information flow
- Two variables are **d-separated** given a conditioning set if *all* paths between
  them are blocked -- this means conditioning removes the statistical association

The practical implication: to identify the causal effect of X on Y, find a
conditioning set that blocks all back-door paths (non-causal associations) while
leaving causal paths open. For complex graphs with more than 5-6 nodes, use
dagitty.net (a free web tool) to algorithmically determine valid adjustment sets.

**Practical DAG construction** (Huntington-Klein 2022, Ch. 7):
1. List all variables you believe are relevant to the treatment-outcome relationship
2. Draw arrows based on theory, domain knowledge, and prior literature
3. Simplify by removing variables that are redundant or pure mediators (unless
   mediation is the question)
4. Accept that DAGs encode assumptions -- be explicit about what you are assuming
   and what would change if an assumption is wrong

DAGs complement potential outcomes: the potential outcomes framework defines *what*
we want to estimate (ATE, ATT, etc.); DAGs clarify *what we need to condition on*
(or avoid conditioning on) to identify it.

## The Credibility Revolution

Angrist and Pischke (2010) named a paradigm shift in empirical economics: the move
from structural modeling toward **design-based research** that emphasizes transparent
identification strategies.

**The four fundamental questions** of empirical research (Angrist and Pischke 2009):
1. What is the causal relationship of interest?
2. What is the ideal experiment to capture it?
3. What is the identification strategy -- how does your observational data
   approximate that ideal experiment?
4. What is the mode of statistical inference?

The credibility revolution's central insight is that **transparency of assumptions
matters more than mathematical sophistication**. A simple difference-in-differences
with a clearly defended parallel trends assumption is more credible than a complex
structural model with opaque identifying restrictions.

As Angrist emphasized in his 2021 Nobel lecture, visual evidence is compelling:
"You should be able to see the treatment effect in a well-designed figure." If you
cannot, either the effect is small or the research design is not clean.

This revolution produced the modern toolkit: regression discontinuity designs
became standard for policy evaluation, DiD methods were formalized and improved,
and instrumental variables were held to stricter relevance standards. The common
thread is asking: "What is the source of identifying variation, and is it credible?"

## The Identification Problem

Following Angrist and Pischke (2009), selection bias is "the principal enemy" of
causal inference. Units that receive treatment typically differ systematically from
those that do not, and these differences contaminate naive comparisons.

**Identification** means isolating the meaningful variation in the data -- the
variation that allows a causal interpretation. As Huntington-Klein (2022) frames it,
every quasi-experimental method is a different strategy for approximating the
conditions of a randomized experiment using observational data.

**Hierarchy of evidence** (for internal validity):

| Design | Strength | Why |
|--------|----------|-----|
| Randomized Controlled Trial | Strongest | Randomization eliminates selection bias by design |
| Quasi-experimental (IV, RD, DiD) | Strong | Exploits plausibly exogenous variation from natural experiments |
| Observational with controls | Moderate | Relies on conditional independence assumption -- all confounders observed |
| Naive comparison | Weakest | Subject to both selection bias and omitted variable bias |

This hierarchy is about internal validity (did X cause Y in this sample?), not
external validity (does the finding generalize?). A well-identified local estimate
may not generalize; a poorly identified "representative" estimate may be wrong.

## Method Selection Guide

The table below maps research designs to their assumptions, estimands, and primary
threats. This is the central decision reference for Stage 8 analysis work.

| Design | When to Use | Key Assumptions | What It Estimates | Key Threats | Python Package |
|--------|-------------|-----------------|-------------------|-------------|----------------|
| **Randomized Controlled Trial** | You can randomize treatment | Random assignment, SUTVA, no attrition | ATE | Attrition, non-compliance, external validity | pyfixest, statsmodels |
| **Stratified RCT** | RCT with balance on key characteristics | Random assignment within strata | ATE (with precision gains) | Same as RCT plus stratification errors | pyfixest |
| **Regression with controls** | Selection on observables is plausible | Conditional independence (CIA) | ATE (if CIA holds) | Unobserved confounders, bad controls | pyfixest, statsmodels |
| **Matching / IPW** | Selection on observables, want nonparametric robustness | CIA + common support (overlap) | ATT (matching) or ATE (IPW) | Overlap violations, unobserved confounders | scikit-learn + manual* |
| **Fixed effects / panel** | Repeated observations, time-invariant confounders | Strict exogeneity (no feedback from Y to future X) | ATE (within-unit) | Time-varying confounders, Nickell bias | pyfixest (`feols`) |
| **Instrumental Variables** | Endogenous treatment, valid instrument exists | Relevance, independence, exclusion restriction, monotonicity | LATE (compliers only) | Weak instruments, exclusion restriction violations | pyfixest (IV formula) |
| **Regression Discontinuity** | Treatment assigned by score crossing a cutoff | Continuity at cutoff, no manipulation | LATE (at the cutoff) | Sorting/manipulation, bandwidth sensitivity | statsmodels + manual* |
| **Difference-in-Differences** | Policy change affects some units but not others | Parallel trends, no anticipation | ATT | Parallel trends violations, anticipation | pyfixest (did2s, lpdid) |
| **Synthetic Control** | Few treated units, long pre-treatment period | Weighted controls can match pre-treatment trajectory | ATT for treated unit(s) | No good match, interpolation bias | requires installation* |

**Implementation status note:** The DAAF environment includes `pyfixest` and `statsmodels`
as installed causal inference packages. Entries marked with * require either manual
implementation using available packages or installation of specialized packages:
- **pyfixest** covers: OLS/FE regression, IV (via `~` and `|` formula syntax), panel
  models (`feols` with fixed effects), DiD (`did2s`, `lpdid`, `event_study`), event
  studies, and multiple testing corrections (`rwolf`, `bonferroni`)
- **statsmodels** covers: OLS, GLM, WLS, GLS, and basic time series
- **Matching/IPW**: Propensity scores can be estimated with `scikit-learn`
  (LogisticRegression); matching and weighting require manual implementation
- **RD**: Local linear regression can be implemented with `statsmodels`; for
  robust bias-corrected inference, `rdrobust` must be installed (`pip install rdrobust`)
- **Synthetic control**: Requires installing `CausalPy` or `synthdid`
- **Callaway-Sant'Anna estimator**: Requires installing `csdid`; for staggered DiD
  within the installed environment, use pyfixest's `did2s` or `lpdid`

### Angrist's "Furious Five" Progression

Angrist and Pischke (2015) organize quasi-experimental methods as a pedagogical
progression, where each method is increasingly "clever" in how it approximates
random assignment:

1. **Randomized trials** -- the gold standard, but often infeasible or unethical
2. **Regression** -- controls for observables, but cannot handle unobserved confounders
3. **Instrumental variables** -- exploits exogenous variation to overcome endogeneity,
   but requires a valid instrument (strong first stage + exclusion restriction)
4. **Regression discontinuity** -- uses policy cutoffs as natural experiments, but
   estimates are local to the cutoff
5. **Difference-in-differences** -- uses policy changes over time, but requires
   parallel trends to hold

Each method addresses the limitations of the previous one, but introduces its own
assumptions. The progression teaches researchers to match the method to the available
variation in the data, not to pick a method and hope the assumptions hold.

### Huntington-Klein's "Template Matching" Approach

Rather than asking "which method should I use?", Huntington-Klein (2022) suggests
asking "which template matches my research design?" Each method corresponds to a
pattern in the causal diagram:

- **RCT**: Treatment is isolated from all back doors by randomization
- **Regression/matching**: Close all back doors by conditioning on observed variables
- **IV**: Route around back-door confounding by exploiting an exogenous instrument
  that affects treatment but has no direct path to the outcome
- **RD**: Exploit a known threshold that creates quasi-random variation near the cutoff
- **DiD**: Exploit parallel temporal trends and differential treatment timing
- **FE**: Exploit within-unit variation over time to close time-invariant back doors

The template approach emphasizes that the research design comes *before* the
statistical method. The DAG determines what you need to condition on; the method
is the tool for implementing that conditioning strategy.

### Instrumental Variables: Key Diagnostics

Beyond the method selection table, IV designs require specific diagnostics because
the assumptions are strong and largely untestable:

**First-stage strength:**
- The first-stage F-statistic tests whether the instrument actually predicts
  treatment. The traditional rule of thumb (Staiger and Stock 1997) is F > 10;
  modern practice prefers F > 100 or formal weak-instrument-robust inference.
- With F < 10, IV estimates are biased toward OLS and confidence intervals are
  unreliable. Consider LIML (Limited Information Maximum Likelihood), which is
  less biased than 2SLS with weak instruments.
- Stock and Yogo (2005) provide critical values for testing weak instruments under
  specific bias tolerance thresholds.

**Exclusion restriction:**
- The exclusion restriction (the instrument affects the outcome *only* through
  treatment) **cannot be tested statistically** -- it requires a theoretical defense.
- When multiple instruments are available, the Sargan/Hansen J-test checks
  overidentifying restrictions, but only tests whether instruments agree with
  each other, not whether they are individually valid.

**Monotonicity:**
- The LATE interpretation requires monotonicity: the instrument shifts everyone
  in the same direction (no "defiers" who do the opposite of what the instrument
  encourages). This is a substantive assumption that depends on the context.

**Practical decision rule:** If the first-stage F < 10, **stop and reconsider the
instrument** before interpreting IV results. Weak-instrument inference is an active
research area but the simplest solution is often finding a stronger instrument.

### Regression Discontinuity: Design Essentials

RD designs exploit known policy cutoffs where treatment is assigned based on a
running variable (score) crossing a threshold. Following Cattaneo, Idrobo, and
Titiunik (2020):

**Sharp vs. fuzzy RD:**
- **Sharp RD**: Treatment is a deterministic function of the score -- everyone
  above the cutoff is treated, everyone below is not. The estimand is the ATE
  at the cutoff.
- **Fuzzy RD**: The cutoff creates a *discontinuity in the probability* of
  treatment, but compliance is imperfect. Essentially an IV design where the
  cutoff is the instrument. The estimand is a LATE for compliers at the cutoff.

**Bandwidth selection:**
- The key implementation choice is the bandwidth -- how much data around the
  cutoff to use. Too narrow = imprecise; too wide = biased.
- Calonico, Cattaneo, and Titiunik (2014) provide data-driven optimal bandwidth
  selection with bias-corrected robust confidence intervals.
- Always report results at multiple bandwidths (e.g., 50%, 100%, 200% of optimal)
  to demonstrate robustness.

**Polynomial order:**
- Local linear regression (polynomial order 1) is strongly preferred over
  higher-order polynomials (Gelman and Imbens 2019), which can produce erratic
  extrapolation near the cutoff.
- Higher-order polynomials create a false sense of precision and are sensitive to
  observations far from the cutoff.

**Manipulation testing:**
- The McCrary (2008) density test checks whether units sort around the cutoff
  (bunching just above or below). If the density is discontinuous at the cutoff,
  the design is compromised -- units are manipulating their score to receive
  (or avoid) treatment.
- **If the McCrary test rejects, the entire RD design is questionable.** This is
  a hard stop, not a caveat to note in a robustness section.

**Visual presentation:**
- The standard RD plot: scatter of outcomes against the running variable with
  binned means and fitted curves on each side of the cutoff. The treatment
  effect should be visible as a discontinuity in the fitted curves.

### Matching and Inverse Probability Weighting

Matching and IPW are selection-on-observables strategies: they assume that
conditional on observed covariates X, treatment assignment is independent of
potential outcomes (the conditional independence assumption, CIA).

**Propensity score methods:**
- The propensity score e(X) = P(D=1|X) summarizes all covariates into a single
  balancing score (Rosenbaum and Rubin 1983). Treated and control units with
  similar propensity scores are comparable on observed covariates.
- Propensity scores can be estimated with logistic regression or flexible ML
  methods (`scikit-learn` LogisticRegression, gradient boosting, etc.)

**Common matching algorithms:**
- **Nearest neighbor**: Match each treated unit to the control with the closest
  propensity score. Simple but can produce poor matches in thin regions.
- **Caliper matching**: Nearest neighbor with a maximum distance threshold --
  unmatched treated units are dropped if no good match exists.
- **Coarsened exact matching (CEM)**: Coarsen continuous covariates into bins
  and match exactly within bins. Guarantees balance but may discard many observations.
- **Kernel matching**: Weight all controls by their distance from each treated
  unit using a kernel function. Uses more data but requires bandwidth choice.

**Balance diagnostics (critical step):**
- After matching/weighting, check covariate balance between treated and control:
  standardized mean differences should be < 0.1 (ideally < 0.05) for all covariates.
- Variance ratios should be close to 1.
- **If balance is not achieved, the matching has failed** -- do not proceed to
  outcome estimation without adequate balance.

**Common support (overlap):**
- The CIA requires common support: for every value of X, there must be both
  treated and control units. If propensity scores are near 0 or 1 for some
  units, treatment is nearly deterministic and matching is unreliable.
- Trim or restrict analysis to the region of overlap. Report how many
  observations are lost.

**The fundamental limitation:** Matching and IPW cannot address unobserved
confounders. If important variables are unmeasured, the CIA fails. Always
complement matching with sensitivity analysis (Rosenbaum bounds, Oster 2019).

### Synthetic Control: Core Principles

Synthetic control methods (Abadie, Diamond, and Hainmueller 2010) are designed for
settings with a small number of treated units (often just one) and many pre-treatment
periods.

**The idea:** Construct a synthetic version of the treated unit as a weighted average
of untreated "donor" units, chosen so the synthetic unit closely matches the treated
unit's pre-treatment trajectory. The treatment effect is the post-treatment gap
between the treated unit and its synthetic counterfactual.

**Key implementation decisions:**
- **Donor pool selection**: Include only units that are plausible comparisons.
  Including irrelevant donors can introduce interpolation bias.
- **Pre-treatment fit**: The synthetic control must closely match the treated
  unit's pre-treatment outcomes. Poor fit = unreliable counterfactual.
- **Predictor variables**: Match on outcome trajectory and key covariates that
  predict the outcome.

**Inference via placebo tests:**
- Standard inference (t-tests, p-values) does not apply with one treated unit.
- Instead, apply the synthetic control method to each untreated unit in turn
  (in-space placebos) and compare the treated unit's gap to the distribution
  of placebo gaps.
- In-time placebos reassign treatment to a pre-treatment date and check that
  no effect appears before the real treatment.

**When to prefer synthetic control over DiD:**
- Few treated units (1-5) where standard DiD inference is unreliable
- Long pre-treatment periods available for assessing fit quality
- Treatment effect is large enough to be visible against placebo distribution

### Multiple Testing Corrections

When running multiple specifications, testing multiple outcomes, or analyzing
multiple subgroups, the probability of finding at least one spurious significant
result increases rapidly. This is the multiple comparisons problem.

**Correction methods:**
- **Bonferroni**: Divide the significance threshold by the number of tests.
  Conservative but simple. Available in pyfixest: `bonferroni()`.
- **Holm (step-down Bonferroni)**: Less conservative than Bonferroni while still
  controlling the family-wise error rate. Order p-values and apply increasingly
  relaxed thresholds.
- **Benjamini-Hochberg**: Controls the false discovery rate (FDR) rather than
  the family-wise error rate. More powerful when testing many hypotheses and
  tolerating some false positives.
- **Romano-Wolf**: Accounts for dependence among test statistics using resampling.
  The gold standard for multiple testing in applied economics. Available in
  pyfixest: `rwolf()`.

**When corrections are appropriate:**
- Multiple outcomes tested for the same treatment effect
- Multiple subgroup analyses beyond what was pre-specified
- Specification searches or robustness checks presented as primary results

**When corrections may not be needed:**
- Pre-specified primary and secondary outcomes (report both, but note which is primary)
- Distinct research questions that happen to use the same data
- Exploratory analyses clearly labeled as hypothesis-generating

### Machine Learning for Causal Inference

A growing literature integrates machine learning with causal inference frameworks.
These methods use ML's flexibility for nuisance parameter estimation while
maintaining the statistical properties needed for valid causal inference.

**Double/debiased machine learning (DML):**
Chernozhukov et al. (2018) developed DML for estimating treatment effects in
high-dimensional settings. The key idea: use ML to estimate nuisance functions
(propensity scores, outcome models) while maintaining valid inference for the
causal parameter through cross-fitting and Neyman orthogonality. Appropriate
when the number of potential confounders is large relative to the sample size.

**Causal forests (Wager and Athey 2018):**
An extension of random forests designed to estimate conditional average treatment
effects (CATE) -- heterogeneous treatment effects across subpopulations. Useful
for discovering which subgroups benefit most from treatment, but requires a
valid experimental or quasi-experimental design as the foundation.

**When to use causal ML vs. traditional methods:**
- Use DML when you have many potential confounders and want to avoid functional
  form assumptions in nuisance estimation, but still have a clear identification
  strategy (the ML handles high dimensions, not identification)
- Use causal forests when exploring treatment effect heterogeneity after
  establishing a credible causal effect with traditional methods
- Traditional methods remain preferred when the covariate space is moderate,
  the identification strategy is well-understood, and interpretability is paramount
- Causal ML does NOT solve the fundamental problem of identification -- it
  complements, not replaces, credible research designs

**Python ecosystem:** `EconML` (Microsoft), `DoWhy` (Microsoft), `DoubleML`, and
`CausalML` (Uber) are the main packages. None are installed by default in the
DAAF environment; install as needed for specific projects.

## Modern Difference-in-Differences: A Practitioner's Guide

This section covers the most active area of methodological development in applied
econometrics. The material draws heavily from Sant'Anna's DiD lecture series,
Callaway and Sant'Anna (2021), and the Baker et al. (forthcoming) practitioner's
guide. Understanding this section is important because DiD is the most common
quasi-experimental design in applied research, and the traditional implementation
(two-way fixed effects regression) has been shown to produce misleading results
in common settings.

### Why Traditional TWFE Fails with Staggered Treatment

Two-way fixed effects (TWFE) regression with staggered treatment timing -- where
different units begin treatment at different times -- produces estimates that can
be severely biased when treatment effects are heterogeneous. The core problems:

1. **Already-treated units serve as controls**: TWFE implicitly uses units that were
   treated earlier as controls for units treated later, comparing post-treatment
   outcomes across groups that are all treated
2. **Negative weights**: Some group-time treatment effects receive negative weights
   in the TWFE estimate, meaning the aggregate coefficient can have the wrong sign
   even if all underlying effects are positive
3. **Conflation of heterogeneity with dynamics**: TWFE event study plots can show
   spurious pre-trends or post-treatment dynamics that are artifacts of the weighting
   problem, not real treatment effect patterns

Three key decomposition results formalize these problems:

- **Goodman-Bacon (2021)** decomposed the TWFE estimator into all the implicit 2x2
  DiD comparisons it combines, revealing that comparisons using already-treated units
  as controls receive substantial weight
- **de Chaisemartin and D'Haultfoeuille (2020)** showed directly that some individual
  treatment effects receive negative weights in TWFE, so the aggregate is not a
  convex combination of causal effects
- **Sun and Abraham (2021)** demonstrated that event-study specifications using TWFE
  inherit the same contamination, so pre-trend tests from TWFE event studies can be
  misleading

The implication, as Sant'Anna's lecture series emphasizes, is clear: **avoid TWFE
entirely for staggered designs**. Use modern estimators that separate identification,
estimation, and aggregation.

### The Modern DiD Framework

Following Sant'Anna's pedagogical approach, modern DiD cleanly separates three
steps that traditional TWFE conflates:

**Step 1 -- Identification: What are we estimating?**
The fundamental building block is the **group-time average treatment effect on the
treated**: ATT(g,t) for group g at time t, where group g is defined by the period in
which units first receive treatment. Each ATT(g,t) is a well-defined causal parameter
under parallel trends and no-anticipation assumptions.

**Step 2 -- Estimation: How do we compute it?**
Each ATT(g,t) can be estimated using:
- **Outcome regression**: model the untreated potential outcome and impute the
  counterfactual
- **Inverse probability weighting (IPW)**: weight observations to create balance
  between treated and control groups
- **Doubly robust (DR)**: combine both approaches -- consistent if *either* the outcome
  model or the propensity score model is correctly specified (Sant'Anna and Zhao 2020).
  DR is generally preferred for its robustness properties.

**Step 3 -- Aggregation: How do we summarize heterogeneous effects?**
The granular ATT(g,t) parameters are aggregated into interpretable summaries:
- **Overall ATT**: single summary measure (weighted average across all g,t)
- **Event-time ATT**: effects by time relative to treatment onset (the event study)
- **Group-specific ATT**: separate effects for each treatment cohort
- **Calendar-time ATT**: effects at each calendar time period

This separation is the core insight of the modern framework. Each step involves
explicit choices (what controls to use, which model specification, what weights for
aggregation), and making those choices transparent prevents the implicit, opaque
weighting that makes TWFE unreliable.

Baker et al. (forthcoming) reinforce this with a "forward-engineering" principle:
fix the target parameter first (e.g., ATT), then derive the appropriate estimator --
rather than starting from a familiar TWFE regression and reverse-engineering the
assumptions that would justify it.

### Choosing Among Modern Estimators

| Estimator | Best For | Key Feature | Reference |
|-----------|----------|-------------|-----------|
| **Callaway-Sant'Anna** | General staggered DiD | Group-time ATT with flexible aggregation; doubly robust; the most general-purpose modern estimator | Callaway and Sant'Anna (2021) |
| **Sun-Abraham** | Event studies with staggered timing | Saturated interaction-weighted estimator; corrects contamination in event-study coefficients | Sun and Abraham (2021) |
| **Gardner (did2s)** | Simple imputation approach | Two-stage: estimate unit/time FE from untreated observations, impute counterfactuals, then estimate treatment effects | Gardner (2022) |
| **Wooldridge ETWFE** | Regression-based approach | Extended TWFE with proper cohort-time interactions; familiar regression framework | Wooldridge (2021) |
| **Borusyak-Jaravel-Spiess** | Imputation with efficiency | OLS imputation estimator; efficient under homoskedasticity | Borusyak, Jaravel, and Spiess (2024) |
| **Local Projections DiD** | Flexible dynamics | Robust to model misspecification; allows non-absorbing (reversible) treatment | Dube et al. (2023) |

**Practical guidance on choosing:**
1. **Start with Callaway-Sant'Anna** as the default -- it is the most general, supports
   conditional parallel trends with covariates, and provides the clearest separation
   of the three steps
2. **Use did2s (Gardner)** when you want a simple, intuitive imputation approach and
   are comfortable with the stronger homogeneity assumptions
3. **Use Local Projections DiD** when treatment can turn on and off (non-absorbing
   treatment) or when you want minimal parametric assumptions on dynamics
4. **Use Sun-Abraham** when your primary output is an event study and you want to
   correct the contamination in TWFE event-study coefficients directly
5. For all estimators, **report ATT(g,t) disaggregated results** alongside any
   aggregate summary -- aggregation always loses information, and treatment effect
   heterogeneity is substantively interesting

### Parallel Trends

The parallel trends assumption is the linchpin of every DiD design: absent treatment,
treated and control groups would have followed the same outcome trajectory.

**Testing parallel trends:**
- Pre-treatment event study coefficients should be jointly insignificant -- this is
  the standard "pre-trends test"
- But this is a **necessary, not sufficient** condition: failing to reject does not
  mean parallel trends holds (it may simply reflect low statistical power)
- As Roth et al. (2023) emphasize: "pre-tests are informative but not definitive"

**Functional form sensitivity:**
Roth and Sant'Anna (2023, *Econometrica*) demonstrated a critical subtlety: parallel
trends can hold in levels but fail in logs, or vice versa. The choice of outcome
scale is not innocuous -- it changes whether the identifying assumption is satisfied.
This means researchers should test functional form sensitivity rather than assuming
it away.

**Sensitivity analysis for violations:**
Rambachan and Roth (2023) developed the "Honest DiD" framework, which asks: how
robust are the conclusions to plausible violations of parallel trends? Rather than
assuming parallel trends holds exactly, this approach bounds the treatment effect
under specified degrees of violation -- producing confidence sets that are honest
about the uncertainty introduced by potential parallel trends failures.

**Pre-trends are not pre-tests:**
A non-significant pre-trend does not validate the design. Roth (2022) showed that
standard pre-tests have low power against economically meaningful violations. The
absence of evidence (of a pre-trend) is not evidence of absence (of a parallel
trends violation). Researchers should complement pre-trend tests with:
- Substantive arguments for why parallel trends is plausible
- Sensitivity analysis for robustness to violations
- Covariate balance assessments between treated and control groups

### Continuous Treatment DiD

Callaway, Goodman-Bacon, and Sant'Anna (forthcoming, *AER*) extend the DiD framework
to continuous treatment variables -- settings where units receive different doses
rather than a binary treatment.

Key insights from this extension:
- Treatment-on-treated parameters (effects for units at their observed dose) are
  identifiable under parallel trends
- Comparing effects *across* treatment levels is more challenging and requires
  additional assumptions
- TWFE with continuous treatment admits multiple problematic interpretations -- the
  same negative-weighting issues apply, often more severely
- The framework maintains the three-step separation: identify group-dose ATTs,
  estimate them cleanly, and aggregate transparently

## Causal vs Descriptive: Knowing the Difference

Not every research question requires causal inference, and not every analysis that
*feels* causal actually identifies a causal effect. Distinguishing between causal
and descriptive work is a matter of intellectual honesty.

**When causal claims are warranted:**
- Your research design credibly addresses the identification problem
- You can articulate the source of identifying variation
- The assumptions required for a causal interpretation are defensible and transparent
- You have tested (or bounded) the sensitivity of results to assumption violations

**When descriptive analysis is the appropriate endpoint:**
- Prevalence questions: "How many students experience X?"
- Trend questions: "How has Y changed over time?"
- Disparity questions: "Does the distribution of Z differ across groups?"
- Distribution questions: "What does the distribution of W look like?"
- See `./descriptive-analysis.md` for comprehensive descriptive methodology guidance

**The "Schrodinger's causal inference" pitfall:**
Haber et al. (2022) identified a pervasive problem in observational research: studies
that use associational methods but make action-oriented recommendations that *imply*
causation. For example, concluding that a program "should be expanded" based on a
cross-sectional correlation is making an implicit causal claim. Either commit to a
causal design or be honest that descriptive findings are suggestive, not conclusive.

**Descriptive subgroup analysis is not causal heterogeneity analysis:**
Exploring how an association varies across subgroups (e.g., the gender gap in earnings
is larger in some industries than others) is a descriptive exercise. Estimating
heterogeneous *treatment effects* (e.g., the effect of a training program differs by
gender) requires a causal design that identifies effects within each subgroup.

**Know which parameter your design identifies:**
Following Huntington-Klein's (2022, Ch. 10) five rules of thumb:
1. Designs using random variation typically estimate ATE
2. Designs using variation specific to a treated group typically estimate ATT
3. IV estimates LATE -- the effect for compliers, not the full population
4. RD estimates a local effect at the cutoff -- not a global treatment effect
5. Variance-weighted averages from heterogeneous effects may not match any
   policy-relevant population parameter

For causal vs. correlational language guidance in communicating results, see
`./research-questions.md` > "Causal vs. Correlational Language."

## Threats to Validity Checklist

### Internal Validity (by design type)

| Design | Primary Threats | What to Check |
|--------|----------------|---------------|
| RCT | Attrition, non-compliance, spillovers, experimenter demand effects | Balance tables, attrition analysis, ITT vs. LATE comparison |
| Regression/matching | Unobserved confounders (the fundamental problem) | Sensitivity analysis (Oster 2019), robustness to specification |
| IV | Weak instruments, exclusion restriction violations, defiers | First-stage F-statistic (>10, ideally >100), exclusion restriction arguments, monotonicity defense |
| RD | Manipulation/sorting at cutoff, sensitivity to bandwidth and polynomial | McCrary density test, bandwidth sensitivity, multiple polynomial orders |
| DiD | Parallel trends violations, anticipation effects, compositional changes | Pre-trend tests + sensitivity analysis (Rambachan and Roth 2023), event study plots, composition checks |
| Synthetic control | No good match, interpolation bias, few donor units | Pre-treatment fit quality, donor pool restrictions, placebo tests |

### External Validity

- **LATE and local RD effects are inherently local**: IV identifies effects for
  compliers only (the subpopulation whose treatment is changed by the instrument),
  and RD identifies effects at the cutoff only. These may not generalize to the
  broader population.
- **Site-specific effects**: Results from one state's Medicaid expansion may not
  transfer to another state with different demographics and healthcare infrastructure
- **Time-specific effects**: Results from one time period may not hold in another
  (e.g., labor market effects during expansion vs. recession)
- **Scaling effects**: A program that works in a small pilot may not have the same
  effect at scale (general equilibrium effects, implementation quality variation)
- Generalizability requires **explicit argument**, not assumption. State clearly
  what population and setting the results apply to.

### Measurement and Data Quality

- **Classical measurement error** (random noise in the variable) attenuates
  coefficients toward zero -- a known bias direction
- **Non-classical measurement error** (systematic mismeasurement correlated with
  other variables) biases in unpredictable directions
- **Construct validity**: Does the variable actually measure the concept you intend?
  (e.g., "days absent" as a measure of student engagement)
- **Missing data**: Not a validity threat per se, but differential missingness
  between treatment and control groups can create bias. See
  `./descriptive-analysis.md` for the MCAR/MAR/MNAR framework.
- **SUTVA violations**: Spillover effects (one unit's treatment affects another
  unit's outcome) and general equilibrium effects (treatment at scale changes the
  environment for everyone) can invalidate standard estimators

## Partial Identification and Sensitivity Analysis

When point identification requires assumptions that are too strong to be credible,
partial identification and sensitivity analysis offer more honest alternatives.

**Oster (2019) -- Selection on unobservables:**
Asks: how much selection on unobservables would be needed to explain away the
observed result? Uses the change in coefficient and R-squared when adding controls
to bound the bias from unobserved confounders. A result is robust if the implied
degree of unobservable selection needed to eliminate the effect is implausibly large
relative to the observable selection.

**Cinelli and Hazlett (2020) -- Omitted variable bias via partial R-squared:**
Provides a framework for sensitivity analysis that asks: how strongly would an
omitted confounder need to be associated with both treatment and outcome to explain
away the result? Produces sensitivity contour plots that visually communicate
robustness.

**Rambachan and Roth (2023) -- Honest DiD for parallel trends:**
Specific to difference-in-differences designs. Rather than assuming parallel trends
holds exactly, this framework produces confidence sets that are valid under specified
degrees of violation. The researcher specifies a "breakdown frontier" -- how far
parallel trends could deviate from exact -- and the method reports whether the
qualitative conclusion survives.

**Rosenbaum bounds for matching estimators:**
For designs based on matching or propensity scores, Rosenbaum bounds quantify how
sensitive the conclusion is to a hidden confounder of a given strength. The "gamma"
parameter represents the factor by which an unobserved confounder could change the
odds of treatment; the analysis reports the gamma at which the conclusion would
be overturned.

**When to use sensitivity analysis:**
- For any observational study making causal claims (not optional -- this is a
  baseline expectation in credible empirical work)
- When assumptions are debatable (e.g., parallel trends, exclusion restriction)
- When the policy stakes are high and conclusions need to be defensible
- When reviewers or stakeholders are likely to question identifying assumptions

See Huntington-Klein (2022, Ch. 21) for an accessible overview of sensitivity
analysis across designs.

## References and Further Reading

### Textbooks (Open Access)

Cunningham, S. (2021). *Causal Inference: The Mixtape*. Yale University Press. https://mixtape.scunning.com/

Huntington-Klein, N. (2022). *The Effect: An Introduction to Research Design and Causality*. Chapman & Hall/CRC. https://theeffectbook.net/

### Textbooks

Angrist, J.D. and Pischke, J.-S. (2009). *Mostly Harmless Econometrics: An Empiricist's Companion*. Princeton University Press.

Angrist, J.D. and Pischke, J.-S. (2015). *Mastering 'Metrics: The Path from Cause to Effect*. Princeton University Press.

### Key Papers -- Foundations

Angrist, J.D. (2021). "Empirical Strategies in Economics: Illuminating the Path from Cause to Effect." Nobel Prize Lecture. https://www.nobelprize.org/prizes/economic-sciences/2021/angrist/lecture/

Angrist, J.D. and Pischke, J.-S. (2010). "The Credibility Revolution in Empirical Economics." *Journal of Economic Perspectives*, 24(2), 3-30.

Holland, P.W. (1986). "Statistics and Causal Inference." *Journal of the American Statistical Association*, 81(396), 945-960.

Imbens, G.W. and Angrist, J.D. (1994). "Identification and Estimation of Local Average Treatment Effects." *Econometrica*, 62(2), 467-475.

Pearl, J. (1995). "Causal Diagrams for Empirical Research." *Biometrika*, 82(4), 669-688.

### Key Papers -- Difference-in-Differences

Baker, A., Callaway, B., Cunningham, S., Goodman-Bacon, A., and Sant'Anna, P.H.C. (Forthcoming). "Difference-in-Differences Designs: A Practitioner's Guide." *Journal of Economic Literature*. arXiv:2503.13323.

Baker, A., Larcker, D.F., and Wang, C.C.Y. (2022). "How Much Should We Trust Staggered Difference-in-Differences Estimates?" *Journal of Financial Economics*, 144(2), 370-395.

Borusyak, K., Jaravel, X., and Spiess, J. (2024). "Revisiting Event-Study Designs: Robust and Efficient Estimation." *Review of Economic Studies*, 91(6), 3253-3285.

Caetano, C., Callaway, B., and Sant'Anna, P.H.C. (2024). "Difference-in-Differences with Time-Varying Covariates." arXiv:2202.02903.

Callaway, B. and Sant'Anna, P.H.C. (2021). "Difference-in-Differences with Multiple Time Periods." *Journal of Econometrics*, 225(2), 200-230. https://doi.org/10.1016/j.jeconom.2020.12.001

Callaway, B., Goodman-Bacon, A., and Sant'Anna, P.H.C. (Forthcoming). "Difference-in-Differences with a Continuous Treatment." *American Economic Review*. arXiv:2107.02637.

de Chaisemartin, C. and D'Haultfoeuille, X. (2020). "Two-Way Fixed Effects Estimators with Heterogeneous Treatment Effects." *American Economic Review*, 110(9), 2964-2996.

Gardner, J. (2022). "Two-Stage Differences in Differences." arXiv:2207.05943.

Goodman-Bacon, A. (2021). "Difference-in-Differences with Variation in Treatment Timing." *Journal of Econometrics*, 225(2), 254-277.

Roth, J. (2022). "Pretest with Caution: Event-Study Estimates after Testing for Parallel Trends." *American Economic Review: Insights*, 4(3), 305-322.

Roth, J. and Sant'Anna, P.H.C. (2023). "When Is Parallel Trends Sensitive to Functional Form?" *Econometrica*, 91(2), 737-747. https://doi.org/10.3982/ECTA19402

Roth, J., Sant'Anna, P.H.C., Bilinski, A., and Poe, J. (2023). "What's Trending in Difference-in-Differences?" *Journal of Econometrics*, 235(2), 2218-2244. https://doi.org/10.1016/j.jeconom.2023.03.008

Sant'Anna, P.H.C. and Zhao, J. (2020). "Doubly Robust Difference-in-Differences Estimators." *Journal of Econometrics*, 219(1), 101-122. https://doi.org/10.1016/j.jeconom.2020.06.003

Sun, L. and Abraham, S. (2021). "Estimating Dynamic Treatment Effects in Event Studies with Heterogeneous Treatment Effects." *Journal of Econometrics*, 225(2), 175-199.

Wooldridge, J.M. (2021). "Two-Way Fixed Effects, the Two-Way Mundlak Regression, and Difference-in-Differences Estimators." Working Paper. https://doi.org/10.2139/ssrn.3906345

### Key Papers -- Methods

Abadie, A., Diamond, A., and Hainmueller, J. (2010). "Synthetic Control Methods for Comparative Case Studies." *Journal of the American Statistical Association*, 105(490), 493-505.

Calonico, S., Cattaneo, M.D., and Titiunik, R. (2014). "Robust Nonparametric Confidence Intervals for Regression-Discontinuity Designs." *Econometrica*, 82(6), 2295-2326.

Cattaneo, M.D., Idrobo, N., and Titiunik, R. (2020). *A Practical Introduction to Regression Discontinuity Designs: Foundations*. Cambridge University Press.

Chernozhukov, V., Chetverikov, D., Demirer, M., Duflo, E., Hansen, C., Newey, W., and Robins, J. (2018). "Double/Debiased Machine Learning for Treatment and Structural Parameters." *Econometrics Journal*, 21(1), C1-C68.

Gelman, A. and Imbens, G.W. (2019). "Why High-Order Polynomials Should Not Be Used in Regression Discontinuity Designs." *Journal of Business & Economic Statistics*, 37(3), 447-456.

McCrary, J. (2008). "Manipulation of the Running Variable in the Regression Discontinuity Design: A Density Test." *Journal of Econometrics*, 142(2), 698-714.

Rosenbaum, P.R. and Rubin, D.B. (1983). "The Central Role of the Propensity Score in Observational Studies for Causal Effects." *Biometrika*, 70(1), 41-55.

Staiger, D. and Stock, J.H. (1997). "Instrumental Variables Regression with Weak Instruments." *Econometrica*, 65(3), 557-586.

Stock, J.H. and Yogo, M. (2005). "Testing for Weak Instruments in Linear IV Regression." In Andrews, D.W.K. and Stock, J.H. (Eds.), *Identification and Inference for Econometric Models*, 80-108. Cambridge University Press.

Wager, S. and Athey, S. (2018). "Estimation and Inference of Heterogeneous Treatment Effects Using Random Forests." *Journal of the American Statistical Association*, 113(523), 1228-1242.

### Key Papers -- Sensitivity Analysis

Cinelli, C. and Hazlett, C. (2020). "Making Sense of Sensitivity: Extending Omitted Variable Bias." *Journal of the Royal Statistical Society: Series B*, 82(1), 39-67.

Oster, E. (2019). "Unobservable Selection and Coefficient Stability: Theory and Evidence." *Journal of Business & Economic Statistics*, 37(2), 187-204.

Rambachan, A. and Roth, J. (2023). "A More Credible Approach to Parallel Trends." *Review of Economic Studies*, 90(5), 2555-2591.

### Causal Language in Research

Haber, N.A. et al. (2022). "Causal and Associational Language in Observational Health Research." *American Journal of Epidemiology*, 191(12), 2084-2097.

### Teaching Resources

Angrist, J.D. "Mastering Econometrics." Marginal Revolution University. https://mru.org/mastering-econometrics-joshua-angrist

LOST (Library of Statistical Techniques). https://lost-stats.github.io/

Sant'Anna, P.H.C. "DiD Resources: A 14-Lecture Course." https://psantanna.com/did-resources/

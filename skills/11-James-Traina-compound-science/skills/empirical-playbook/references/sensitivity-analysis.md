# Applied Micro Toolkit: Sensitivity Analysis

Procedural reference for stress-testing causal estimates. Covers baseline extraction, Oster bounds, Conley bounds, breakdown frontiers, specification curves, and additional sensitivity methods. Load this for sensitivity analysis or when a referee asks "how robust is this result?"

---

## 1. Baseline Extraction

Before running any sensitivity analysis, identify the baseline specification to test.

### Locate the Baseline

The baseline specification is the main result: the most fully controlled regression with the preferred sample, fixed effects, and standard errors. If ambiguous, choose the specification emphasized in the abstract or introduction.

### Extract Baseline Components

Record: target parameter (treatment effect, elasticity, LATE), point estimate beta-hat, SE and SE method, 95% CI, identification strategy (IV / DiD / RDD / selection-on-observables / structural), controls included and available, sample and N, fixed effects, clustering level.

### Strategy-to-Method Mapping

The identification strategy determines which sensitivity methods are primary and which are secondary.

| Identification Strategy | Primary Method | Secondary Methods |
|------------------------|----------------|-------------------|
| **Selection on observables** | Oster bounds | Specification curve, sensemakr, E-value |
| **IV / 2SLS / GMM** | Conley et al. bounds | Specification curve (instrument sets, controls) |
| **Difference-in-differences** | Oster bounds + Rambachan-Roth | Specification curve, pre-trend sensitivity |
| **Regression discontinuity** | Bandwidth + polynomial sensitivity | Donut hole, covariate-adjusted RD |
| **Structural estimation** | Parameter perturbation | Starting value sensitivity, moment selection |

Not all methods apply to all strategies. Skip inapplicable methods rather than forcing them.

---

## 2. Oster Bounds

Assess sensitivity to omitted variable bias using coefficient stability (Oster 2019, building on Altonji, Elder, and Taber 2005). Applicable to selection-on-observables and DiD designs. Skip for IV with strong instruments.

### Key Statistics

Run two regressions: (1) short (no controls), (2) controlled (baseline with all controls).

| Statistic | Definition | Source |
|-----------|-----------|--------|
| beta-tilde | Coefficient from short regression (no controls) | Uncontrolled regression |
| R-tilde-squared | R-squared from short regression | Same |
| beta-hat | Coefficient from controlled regression | Baseline specification |
| R-hat-squared | R-squared from controlled regression | Baseline specification |
| R-squared-max | Hypothetical R-squared if all relevant variables included | Set by researcher |

### Delta Computation

Delta measures the degree of selection on unobservables relative to observables needed to explain away the result entirely.

Compute: the delta such that beta-star(delta, R-squared-max) = 0. This is the proportionality factor at which the bias-adjusted treatment effect equals zero.

If delta > 1, unobservables would need to be more important than observables to nullify the result. This is the core robustness benchmark.

### Bias-Adjusted Estimate

Use the Oster (2019) recommended defaults from her calibration exercise across published RCTs:

| Parameter | Default Value | Rationale |
|-----------|--------------|-----------|
| **R-squared-max** | min(2.2 * R-hat-squared, 1) | Calibrated upper bound on explanatory power |
| **delta** | 1 | Proportional selection: unobservables equally important as observables |

Compute beta-star(delta=1, R-squared-max = 2.2 * R-hat-squared): this is the bias-adjusted point estimate assuming proportional selection.

The **identified set** is [beta-hat, beta-star(1, R-squared-max)]. If zero is not contained in this interval, the result survives the proportional selection benchmark.

### Interpretation Table

| Delta Value | Interpretation |
|-------------|---------------|
| delta > 2 | **Very robust**: unobservables would need to be twice as important as observables to nullify the result |
| 1 < delta < 2 | **Moderately robust**: passes the proportional selection benchmark |
| 0 < delta < 1 | **Fragile**: less-than-proportional selection would nullify the result |
| delta < 0 | **Strengthened**: adding omitted variables moves the coefficient away from zero (bias works against finding an effect) |

### Software

| Package | Language | Notes |
|---------|----------|-------|
| `psacalc` | Stata | Oster's own package; `psacalc depvar treatvar controllist` |
| `sensemakr` | R, Stata | Cinelli-Hazlett approach; also computes Oster-style bounds |
| Custom | Python | No canonical package; implement from the Oster (2019) formulas directly |

---

## 3. Conley et al. Bounds

Assess sensitivity to violations of the exclusion restriction in IV/2SLS/GMM designs (Conley, Hansen, and Rossi 2012). Skip if no instruments are used.

### Setup

Baseline IV model: Y = X * beta + Z * gamma + epsilon, where gamma = 0 is the exclusion restriction. Relaxed model: allow gamma != 0 and examine how beta changes.

### Three Approaches

| Approach | Description | When to Use |
|----------|------------|-------------|
| **Local-to-zero** | gamma ~ N(0, sigma-gamma-squared), with sigma-gamma-squared set by the researcher | Researcher has a prior about violation magnitude |
| **Union of confidence intervals** | Compute CI(beta) for each gamma in a grid | No strong prior; want to map full sensitivity |
| **Support restriction** | gamma in [gamma-L, gamma-U], bounded by researcher | Researcher can bound the direct effect of Z on Y |

### Grid Computation

Compute beta-hat(gamma) for a range of gamma values from zero to (at least) the reduced-form coefficient. Scale the grid relative to the reduced form: if the reduced-form effect of Z on Y is 0.15, test gamma from 0 to 0.15 or beyond. For each gamma, record beta-hat(gamma), 95% CI, and whether the CI includes zero.

### Breakdown Point

The **breakdown point** gamma-star is the value of gamma at which the confidence interval first includes zero.

Interpretation: "A direct effect of Z on Y equal to gamma-star would be needed to nullify the IV result."

Key comparison: express gamma-star as a fraction of the reduced-form effect. If gamma-star is a large fraction (e.g., > 50%) of the reduced form, the exclusion restriction can be substantially violated before the result breaks down.

| gamma-star / reduced form | Assessment |
|---------------------------|------------|
| > 50% | Result robust to substantial exclusion restriction violations |
| 20-50% | Moderate sensitivity; exclusion restriction matters |
| < 20% | Fragile; even small direct effects of Z on Y would overturn the result |

### Software

| Package | Language | Notes |
|---------|----------|-------|
| `plausexog` | Stata | Conley et al. implementation; `plausexog` with `uci` or `ltz` options |
| Custom | R, Python | Straightforward grid computation; loop over gamma values and re-estimate |

---

## 4. Breakdown Frontier

Compute how much assumption violations must combine to overturn a causal conclusion (Masten and Poirier 2021). Applicable to any causal estimation. Generalizes single-parameter sensitivity by considering multiple assumptions simultaneously.

### Definition

The **breakdown frontier** is the set of combinations of assumption violations at which the causal conclusion (sign, significance, or magnitude) just breaks down. Points inside the frontier preserve the result; points outside overturn it.

### Identify Dimensions

Choose two or more assumption dimensions relevant to the identification strategy:

| Dimension | Violation Parameter | Applies To |
|-----------|-------------------|------------|
| **Omitted variable bias** | delta (Oster proportionality) | Selection-on-observables, DiD |
| **Exclusion restriction** | gamma (direct effect of instrument) | IV / 2SLS |
| **Parallel trends** | Magnitude of differential trends | DiD |
| **Selection** | Degree of selection on unobservables | Matching, AIPW |
| **Measurement error** | Degree of attenuation / misclassification | Any |

### Compute the Frontier

For each pair of dimensions, compute the combinations (delta-1, delta-2) at which the result just breaks down. This traces a curve in two-dimensional assumption-violation space. Key points on the frontier: each axis intercept (breakdown via one dimension alone, holding the other at zero) and interior points (joint violations).

### Interpretation

A **wide frontier** (large violation magnitudes needed in each dimension) indicates a robust result. A **narrow frontier** (small violations sufficient) indicates fragility.

Compare the breakdown values to plausible violation magnitudes from the economic setting. If the breakdown requires implausibly large violations, the result is robust even allowing for multiple sources of misspecification.

---

## 5. Specification Curve

Enumerate all reasonable specifications and analyze the distribution of estimates (Simonsohn, Simmons, and Nelson 2020). Applicable to any method. Complements rather than replaces traditional robustness tables.

### Decision Space

Identify all defensible specification choices:

| Decision | Options to Vary |
|----------|----------------|
| **Control variables** | Include/exclude each non-essential control |
| **Functional form** | Linear, log, quadratic, spline |
| **Sample restrictions** | Full sample, trim outliers, drop specific subgroups |
| **Fixed effects** | None, unit FE, time FE, unit + time FE, unit-specific trends |
| **SE method** | Robust, clustered (at different levels), bootstrap |
| **Estimation method** | OLS vs IV, different instrument sets |
| **Outcome variable** | Alternative definitions or transformations |
| **Treatment variable** | Alternative definitions or timing |

### Enumeration Rules

- Include only specifications that a reasonable researcher might defend as the main specification.
- Exclude specifications that are clearly misspecified (e.g., OLS when endogeneity is established and a valid instrument exists).
- Target 50-500 total specifications. Fewer than 50 is too narrow; more than 500 usually includes implausible combinations.

### Summary Statistics

For all S specifications, compute:

| Statistic | Interpretation |
|-----------|---------------|
| **Median estimate** | Central tendency across specifications |
| **IQR of estimates** | Dispersion; tight IQR means the result is stable |
| **Share significant** | Fraction of specifications with p < 0.05 |
| **Share same sign** | Fraction with the same sign as baseline |
| **Range (min, max)** | Full extent of results |
| **Baseline rank** | Where the baseline falls among sorted estimates (e.g., 45th of 120) |

### Specification Curve Plot

Two-panel figure. **Top panel:** point estimates sorted by magnitude with 95% CIs, reference line at zero, baseline highlighted, significant estimates shaded. **Bottom panel:** indicator matrix (same x-axis) with rows for each specification choice and dots marking active choices, grouped by decision type.

### Joint Significance Test

Under the null of no effect, permute treatment assignment and re-run the entire specification curve. Compare observed curve statistics (share significant, median coefficient) to the null distribution. This tests whether the overall pattern is consistent with chance.

### Software

| Package | Language | Notes |
|---------|----------|-------|
| `specr` | R | Full specification curve analysis with built-in plotting |
| `specification_curve` | Python | Generates specification curve plots |
| `specurve` | Stata | Community-contributed specification curve package |
| Custom | Any | `itertools.product` over specification choices; straightforward to implement |

---

## 6. Additional Methods Reference

Methods beyond the core four, organized by the assumption they probe.

| Method | Reference | Key Idea | Assumption Tested | Software |
|--------|----------|----------|-------------------|----------|
| **Rambachan-Roth** | Rambachan and Roth (2023) | Bound treatment effects under violations of parallel trends; restrict how much differential trends can change between periods | Parallel trends (DiD) | `HonestDiD` (R) |
| **sensemakr** | Cinelli and Hazlett (2020) | OVB benchmarking: express confounding needed in terms of partial R-squared of observed covariates; provides robustness value (RV) | Unconfoundedness | `sensemakr` (R, Stata) |
| **E-value** | VanderWeele and Ding (2017) | Minimum strength of confounding (on the risk ratio scale) needed to explain away an observed association | Unconfoundedness (especially epidemiology) | `EValue` (R) |
| **Rosenbaum bounds** | Rosenbaum (2002) | Sensitivity parameter Gamma: how much an unobserved confounder would need to change treatment odds to alter the conclusion | Hidden bias in matching | `rbounds` (R), `sensemakr` |

### When to Use Each

- **Rambachan-Roth**: Any DiD or event study. Key parameter: M-bar (maximum slope change in differential trends between periods). Report alongside event study plots.
- **sensemakr**: Selection-on-observables. Benchmark against partial R-squared of strongest observed confounder. If robustness value exceeds the benchmark, the result is robust.
- **E-value**: Quick summary for any observational study. Easy to compute but less informative than Oster or sensemakr for regression-based studies.
- **Rosenbaum bounds**: Matched designs. Sensitivity parameter Gamma measures how much treatment odds must differ between matched pairs to change the conclusion.

---

## 7. Overall Robustness Assessment

After running all applicable sensitivity analyses, classify the result.

| Rating | Criteria |
|--------|---------|
| **ROBUST** | Oster delta > 1 (or sensemakr RV exceeds benchmarks); specification curve shows majority significant with consistent sign; breakdown frontier requires implausibly large violations; Conley breakdown point is a large fraction of reduced form |
| **MODERATELY ROBUST** | Oster delta close to 1; most specifications agree on sign; breakdown requires substantial (but not implausible) violations; some specifications lose significance |
| **FRAGILE** | Oster delta < 1; many specifications insignificant or show sign-switching; breakdown at small assumption violations; specification curve IQR spans zero |
| **NOT ROBUST** | Result overturned in most sensitivity analyses; identified set contains zero under standard benchmarks; specification curve median differs substantially from baseline |

### Reporting Guidance

- **Main text**: Report the primary sensitivity analysis for the identification strategy (Oster for selection-on-observables, Conley for IV, Rambachan-Roth for DiD).
- **Appendix**: Full specification curve, sensitivity tables across parameter grids, breakdown frontier plots.

### Actionable Response to Fragility

If FRAGILE or NOT ROBUST: (1) identify which assumption dimension drives fragility, (2) seek additional data or design features that strengthen it, (3) consider partial identification or bounds if point estimation is not credible, (4) discuss fragility transparently in the paper.

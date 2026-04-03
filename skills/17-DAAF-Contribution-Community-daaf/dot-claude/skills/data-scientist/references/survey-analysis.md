# Complex Survey Data Analysis

A practitioner's guide to analyzing data from complex probability surveys. This reference
covers how to recognize survey design features, select appropriate weights, estimate
correct standard errors, and avoid the most consequential errors in survey analysis. It is
written for the applied data analyst who *uses* survey data, not the survey methodologist
who *designs* surveys. For implementation syntax, load the `svy` skill; for weighted
descriptive statistics, see `./descriptive-analysis.md`.

**What this file does NOT cover:** survey design (sample size calculation, stratification
design, allocation), weight construction or calibration methodology, response rate
standards (AAPOR), or questionnaire design. Those are the survey methodologist's domain.
This file is about analyzing the data after the survey has already been fielded and
weighted.

## Contents

- [Acknowledgments](#acknowledgments)
- [Why Survey Analysis Requires Special Methods](#why-survey-analysis-requires-special-methods)
- [Complex Survey Design Anatomy](#complex-survey-design-anatomy)
- [Survey Weights: A Practitioner's Guide](#survey-weights-a-practitioners-guide)
- [Variance Estimation Methods](#variance-estimation-methods)
- [Design Effects and Effective Sample Size](#design-effects-and-effective-sample-size)
- [Domain (Subpopulation) Estimation](#domain-subpopulation-estimation)
- [Plausible Values](#plausible-values)
- [Survey-Weighted Regression](#survey-weighted-regression)
- [Common Federal Survey Data Sources](#common-federal-survey-data-sources)
- [Pitfalls Checklist](#pitfalls-checklist)
- [Cross-References to DAAF Skills](#cross-references-to-daaf-skills)
- [References and Further Reading](#references-and-further-reading)

## Acknowledgments

These materials draw extensively from several resources that the authors have generously
made available to the research community:

- **Thomas Lumley's** *Complex Surveys: A Guide to Analysis Using R* (2010), which
  provides the clearest single-volume treatment of complex survey analysis from the
  perspective of a practitioner, and whose `survey` package for R established the
  conceptual vocabulary that most modern survey analysis software follows
- **Steven Heeringa, Brady West, and Patricia Berglund's** *Applied Survey Data
  Analysis* (2nd ed., 2017), which is the most comprehensive applied textbook on the
  subject and the standard reference for analysts working with federal survey data
- **Sharon Lohr's** *Sampling: Design and Analysis* (3rd ed., 2022), which bridges
  sampling theory and applied analysis with exceptional clarity and is the leading
  graduate textbook in the field
- **Edward Korn and Barry Graubard's** *Analysis of Health Surveys* (1999), which
  remains the definitive treatment of survey analysis methods for health and biomedical
  data, with particularly strong coverage of subpopulation estimation and survey-weighted
  regression
- **Stephanie Zimmer, Rebecca Powell, and Isabella Velásquez's** *Exploring Complex
  Survey Data Analysis Using R* (2024, freely available at
  tidy-survey-r.github.io/tidy-survey-book/), which provides an accessible, modern
  introduction to complex survey analysis with practical worked examples

Their contributions to accessible survey methodology education have made rigorous survey
analysis far more approachable for applied researchers.

## Why Survey Analysis Requires Special Methods

The core issue is simple: most large-scale surveys are not simple random samples. They
use complex designs -- stratification, clustering, oversampling of subpopulations -- that
violate the independence assumptions underlying standard statistical methods. If you
analyze survey data as if it were a simple random sample, two things go wrong:

1. **Your standard errors will be wrong.** Clustering (e.g., sampling schools, then
   students within schools) introduces positive intra-cluster correlation: students in
   the same school are more alike than students in different schools. This means your
   data contains less independent information than the raw sample size suggests. Standard
   errors that ignore clustering are typically **too small by a factor of 1.5 to 5x**,
   depending on the intra-class correlation and cluster size. Your p-values will be too
   liberal and your confidence intervals too narrow -- you will claim precision you do
   not have.

2. **Your point estimates will be wrong.** Unequal selection probabilities (from
   oversampling, stratification, or nonresponse) mean that each observation represents a
   different number of people in the population. If Black students were oversampled at 2x
   their population share to ensure adequate subgroup precision, then treating each
   observation equally will overweight Black students in population estimates. Survey
   weights correct for this by telling you how many population members each respondent
   represents.

Stratification, by contrast, is the one design feature that *helps* you: it reduces
variance by ensuring representation across key subgroups. Ignoring stratification
produces standard errors that are slightly too large -- conservative but not wrong in
the way that ignoring clustering is wrong.

**The bottom line:** ignoring the survey design produces point estimates that do not
represent the population and standard errors that understate uncertainty. Both errors
propagate into every downstream analysis -- means, regressions, tests, confidence
intervals. There is no safe shortcut.

## Complex Survey Design Anatomy

As an analyst, you need to recognize these design features in survey documentation so
you can specify them correctly in your analysis software. You do not need to know how to
design a survey -- you need to know what to look for.

### Stratification

The population is divided into non-overlapping groups (strata) before sampling, and
independent samples are drawn within each stratum. Common stratification variables
include geography (state, region, urbanicity), institution type, or demographic
characteristics.

**What to look for in documentation:** A variable typically named something like
`STRATUM`, `STRAT`, `VSTRAT`, or `VARSTR`. Each unique value represents one stratum.

**Why it matters:** Stratification reduces sampling variance. Ignoring it produces
slightly conservative standard errors (too large), which is the least harmful of the
three design features to get wrong -- but you should still specify it correctly.

### Clustering (Primary Sampling Units)

In multistage designs, sampling proceeds hierarchically: first sample geographic areas
(PSUs), then institutions within PSUs, then individuals within institutions. Individuals
within the same PSU are correlated -- they share geography, local policies, economic
conditions. This correlation is the primary reason survey standard errors differ from
SRS standard errors.

**What to look for in documentation:** A variable typically named `PSU`, `CLUSTER`,
`VPSU`, `VARPSU`, or `SDMVPSU`. Each unique value identifies one primary sampling unit.

**Why it matters:** Ignoring clustering produces standard errors that are too small,
often drastically so. This is the most consequential design feature to get wrong.

### Multistage Designs

Most large federal surveys use multistage designs: first sample PSUs (counties or
groups of counties), then sample institutions (schools, hospitals) within PSUs, then
sample individuals within institutions. For variance estimation, only the first stage
of clustering typically needs to be specified -- first-stage sampling contributes the
dominant component of variance (Lohr 2022, Ch. 5). Most survey documentation provides
only first-stage stratum and PSU identifiers for exactly this reason.

### Finite Population Corrections

When the sampling fraction is large (more than about 5-10% of the population), the
finite population correction (FPC) reduces variance. Most national surveys have
negligibly small sampling fractions and the FPC is ignored. Apply the FPC only when
the survey documentation explicitly provides population sizes or sampling fractions
for it.

## Survey Weights: A Practitioner's Guide

Survey weights are the analyst's primary tool for producing population-representative
estimates. Every respondent carries a weight indicating approximately how many members
of the target population that respondent represents.

### Weight Types

Survey documentation typically describes weights that incorporate several sequential
adjustments. As an analyst, you rarely need to apply these adjustments yourself -- you
use the final weight variable. But understanding the components helps you select the
right weight and interpret what it does.

| Weight Component | What It Corrects For | How It Works |
|-----------------|---------------------|--------------|
| **Base weight** (design weight) | Unequal selection probabilities | Inverse of the probability of selection at each sampling stage. If a student had a 1/500 chance of being selected, their base weight is 500. |
| **Nonresponse adjustment** | Differential nonresponse across subgroups | Adjusts base weights upward for respondents whose characteristics match those of nonrespondents, so that the weighted respondent pool still represents the full sample. |
| **Post-stratification / raking** | Residual differences from known population totals | Adjusts weights so that weighted totals match known population benchmarks (e.g., Census totals by age, sex, race). Improves precision and reduces nonresponse bias for variables correlated with the benchmarks. |
| **Replicate weights** | Variance estimation (not point estimation) | Multiple perturbed versions of the main weight, used to estimate standard errors via replication methods. See [Variance Estimation Methods](#variance-estimation-methods). |

### The "Which Weight?" Problem

Most surveys provide multiple weight variables for different analytic purposes.
Longitudinal surveys are particularly confusing because they may include dozens of
weight variables spanning different waves, respondent types, and analytic subsets.

**The decision rule:** Use the weight that corresponds to your analytic sample and time
period. Ask three questions:

1. **What is your unit of analysis?** Student-level weights differ from school-level
   weights; household-level weights differ from person-level weights.
2. **Which wave(s) are you analyzing?** Cross-sectional weights are wave-specific;
   longitudinal weights adjust for attrition across waves.
3. **Which respondents are in your analysis?** Some weights are nonzero only for
   respondents who completed specific survey components.

**When in doubt:** The survey's user manual will have a "Guide to Weights" or
"Selecting the Appropriate Weight" section. Read it. NCES surveys provide clear weight
selection flowcharts in their user manuals.

### Probability Weights vs. Other "Weights"

This distinction trips up many Python users because general-purpose statistical software
sometimes uses the word "weight" for several unrelated concepts:

| Term | What It Means | When to Use |
|------|--------------|-------------|
| **Probability weight** (pweight, sampling weight) | Inverse of selection probability, adjusted for nonresponse and post-stratification. Represents population members. | Complex survey analysis -- the focus of this document. |
| **Frequency weight** (fweight) | Integer indicating that this row represents N identical observations. | Compressed data where identical rows are collapsed. Not the same as survey weights. |
| **Analytic weight** (aweight) | Inverse of the variance of an observation-level mean, used in WLS. | Heteroskedastic regression where each observation is an aggregate (e.g., group means with known group sizes). |
| **Importance weight** | Application-specific emphasis on certain observations. | Machine learning loss functions, not survey estimation. |

**The critical distinction:** Passing survey weights to an ordinary `WLS` or `GLM`
`weights=` argument **does not produce correct survey estimates** -- it ignores
clustering and stratification entirely. You must use dedicated survey estimation
procedures that handle all three design features (strata, PSUs, weights) together.

## Variance Estimation Methods

Correct standard errors require accounting for stratification, clustering, and
weighting simultaneously. Two families of methods dominate practice.

### Taylor Series Linearization (TSL)

The default method when strata and PSU variables are available. TSL approximates the
variance of a nonlinear statistic (like a ratio, regression coefficient, or log-odds)
using a first-order Taylor expansion, then computes the variance of the linearized
statistic accounting for the stratified, clustered design.

**When to use:** When the survey provides stratum and PSU variables (most federal
surveys do). TSL is computationally efficient and works well for smooth statistics.

**Key requirements:**
- Need at least 2 PSUs per stratum (the "lonely PSU" problem arises when a stratum
  contains only 1 PSU after subsetting, making variance estimation impossible within
  that stratum)
- For complex statistics, TSL uses influence functions or residuals to linearize the
  estimator

### Replication Methods

Replication methods (BRR, jackknife, bootstrap) estimate variance by re-estimating
the statistic many times, each time with a perturbed version of the weights. The
variance across replicate estimates approximates the sampling variance.

**Balanced Repeated Replication (BRR):**
Designed for designs with exactly 2 PSUs per stratum. Creates half-samples by
systematically selecting one PSU from each stratum, reweighting observations
accordingly. The Fay modification (Fay 1989) uses perturbation factors of k and
2-k (where 0 < k < 1) instead of 0 and 2, so that every replicate uses the full
sample. This avoids the problem of undefined estimates in half-samples (e.g., when
a domain falls entirely within one PSU). The Fay coefficient k is survey-specific
and documented alongside the replicate weights -- common values include 0.3 (NHANES)
and 0.5 (some NCES surveys).

**Jackknife:**
Removes one PSU at a time and reweights. More general than BRR (works with any
number of PSUs per stratum) but produces more replicate weights (one per PSU, which
can be hundreds).

**Survey bootstrap:**
Creates replicate weights by resampling PSUs within strata. More flexible than BRR
or jackknife but computationally heavier and requires more replicates for stable
estimates.

**Practical decision rule:** If the survey provides replicate weights, use them --
the survey methodologists chose the replication method that best fits their design,
and the replicate weights embed all design information. If replicate weights are
not provided, use Taylor series linearization with the provided stratum and PSU
variables. Do not improvise your own replication scheme.

**The ordinary bootstrap does not work for survey data.** Standard bootstrap
(resample with replacement from the full dataset) ignores the stratified, clustered
design and produces incorrect variance estimates. Survey-appropriate bootstrap
methods exist (Rao, Wu, and Yue 1992) but are substantially more complex than
naive resampling. If you need bootstrap inference, use a survey-aware implementation.

## Design Effects and Effective Sample Size

The design effect (DEFF) quantifies how much less efficient a complex design is
compared to a simple random sample of the same size. It is the ratio of the actual
sampling variance to the variance that would be obtained from an SRS of the same
size:

```
DEFF = Var_complex(estimate) / Var_SRS(estimate)
```

A DEFF of 3.0 means the complex design produces a variance 3 times larger than an
SRS would -- equivalently, you would need 3 times as many observations under SRS to
achieve the same precision as this complex design.

### Kish's Approximation

For a single-stage cluster design, the design effect due to clustering can be
approximated as:

```
DEFF_cluster ≈ 1 + (b - 1) * rho
```

where b is the average cluster size and rho (the intra-class correlation, or ICC) is
the correlation between observations within the same cluster. Even a modest ICC of
0.05 combined with a cluster size of 30 produces DEFF = 1 + 29 * 0.05 = 2.45 -- your
effective sample size is less than half the nominal sample size.

### Effective Sample Size

The effective sample size is:

```
n_eff = n / DEFF
```

This is the number of independent observations that would provide the same precision
as your complex sample of size n. Report the effective sample size alongside the
nominal sample size whenever you report survey results. A study with n = 10,000 but
DEFF = 4.0 has the precision of a simple random sample of 2,500.

**When DEFF matters most:** Power calculations, sample size justifications, and
interpreting the precision of estimates. If a funding agency asks "is your sample
large enough?", the answer depends on n_eff, not n.

## Domain (Subpopulation) Estimation

This is the single most common error in survey analysis: **never subset the dataframe
before running a survey-weighted analysis on a subpopulation.**

### Why Subsetting Is Wrong

When you filter the dataframe to only include observations in your subpopulation of
interest (e.g., `df = df[df["race"] == "Black"]`), you remove information that the
variance estimator needs:

- **PSUs that are empty in the subpopulation but not in the full sample are deleted.**
  The variance estimator relies on between-PSU variability within each stratum.
- **Strata that lose all observations become invisible.**
- **The lonely PSU problem becomes more severe.** A stratum that had two PSUs may have
  only one PSU with subpopulation members, creating an undefined variance.

The result: standard errors **biased in unpredictable directions**. As West, Berglund,
and Heeringa (2008) demonstrate with NHAMCS data, the differences can be substantively
meaningful.

### How to Do It Correctly

Use your survey software's built-in domain/subpopulation estimation mechanism. This
keeps the full sample in memory for variance estimation while restricting point
estimation to the subpopulation:

- **R (survey package):** `svyby()` with `~domain_var` or `subset()` on a survey
  design object (which handles domains correctly internally)
- **Stata:** The `subpop()` option on any `svy` command
- **Python:** Use the `subpop` parameter in survey-aware functions (see the `svy` skill)

**The rule is absolute:** define the subpopulation as a variable in the dataset and pass
it to the estimation function. Never filter rows before creating the survey design
object. This applies to every type of survey analysis without exception.

## Plausible Values

Plausible values are a specialized form of multiple imputation used in large-scale
educational assessments (NAEP, PISA, TIMSS, PIRLS) to estimate population-level
proficiency distributions when individual test scores are unreliable.

### Why Assessments Use Plausible Values

Large-scale assessments face a measurement problem: to cover a broad content domain
efficiently, they administer different subsets of items to different students (matrix
sampling). Each student answers too few items to estimate their individual proficiency
precisely. But the assessment's goal is not to score individuals -- it is to estimate
population and subgroup distributions of proficiency.

Plausible values (Mislevy et al. 1992) solve this by drawing random values from each
student's posterior distribution of proficiency, conditional on their item responses
and background characteristics. They are *not* point estimates of individual ability
-- they are draws from a distribution. Treating them as individual scores (e.g.,
ranking students by plausible values) is a misuse.

### How to Analyze Plausible Values

Each dataset provides multiple plausible values per student (NAEP provides 20; PISA
provides 10). The analysis protocol, based on Rubin's (1987) combining rules:

1. **Run the complete analysis separately for each plausible value.** If there are 20
   plausible values, run 20 separate regressions (or means, or whatever your analysis
   requires), each using one plausible value as the dependent variable.
2. **Combine point estimates.** The final point estimate is the simple average across
   the M plausible value analyses.
3. **Combine variance estimates.** The total variance has two components:
   - *Within-imputation variance*: the average of the M variance estimates from step 1
   - *Between-imputation variance*: the variance of the M point estimates from step 1
   - Total variance = within-imputation + (1 + 1/M) * between-imputation

This is identical to Rubin's combining rules for multiple imputation, because
plausible values *are* multiple imputations of a latent variable.

### Key Distinction from Regular Imputation

Standard multiple imputation replaces missing *observed* values (e.g., a missing income
field) with plausible draws from the predictive distribution of the observed variable.
Plausible values replace a *latent* variable -- proficiency -- that is never directly
observed for any student, even those who answered many items. The latent variable
framework means that plausible values incorporate both measurement error and sampling
uncertainty, making Rubin's combining rules the appropriate aggregation method.

### Practical Notes

- Plausible value analysis must still account for the complex survey design (weights,
  strata, PSUs). Each of the M replicate analyses should be survey-weighted.
- NAEP provides both plausible values and jackknife replicate weights. The correct
  approach combines both: run the analysis for each plausible value using each set of
  replicate weights, then combine using the NAEP-specific variance formula that
  accounts for both imputation variance and sampling variance.
- Most education researchers use the NAEP Data Explorer or the `EdSurvey` R package,
  which handles the plausible value and replicate weight combination automatically.
  In Python, the combination must be implemented manually (see the `svy` skill for
  guidance).

## Survey-Weighted Regression

Survey-weighted regression is not simply OLS with weights plugged in. It estimates a
different quantity and requires different inference.

### What Survey-Weighted Regression Estimates

An unweighted OLS regression estimates the conditional expectation function (CEF) in
the *sample*. A survey-weighted regression estimates the CEF in the *population* --
the regression you would obtain if you ran OLS on the entire target population (a
"census regression").

This is a population-average parameter: the average partial association between X and
Y in the population, weighted by each population member's contribution. It differs
from the sample-conditional parameter when the relationship between X and Y varies
across subpopulations that are sampled at different rates.

### The Solon-Haider-Wooldridge Perspective

Solon, Haider, and Wooldridge (2015) provide the most influential framework for
deciding when to weight regression estimates. They distinguish three motivations for
weighting:

1. **Correcting for heteroskedasticity** -- Survey weights are *not* optimal WLS
   weights (they correct for selection, not heteroskedasticity), so this motivation
   does not apply directly.
2. **Correcting for endogenous sampling** -- If selection probabilities depend on Y,
   unweighted estimates may be inconsistent. Weighting restores consistency.
3. **Recovering average partial effects** -- If effects are heterogeneous and the
   design oversamples subgroups with different effects, weighting recovers the
   population-average effect.

**Their practical advice:** Do not assume weighting is always necessary or always
beneficial. Report both weighted and unweighted results -- if they differ substantially,
that is informative about model specification or heterogeneity. As Pfeffermann (1993)
also argues, the comparison itself is a diagnostic.

### When to Weight Regression

| Goal | Weight? | Rationale |
|------|---------|-----------|
| Estimate population descriptive statistics (means, proportions, totals) | Always | The goal is a population parameter; weights are essential. |
| Estimate a population-average regression coefficient | Yes | You want the census regression; weights recover it. |
| Estimate a causal effect with a correctly specified model | Depends | If the model is correct and sampling is non-informative, weighting adds noise. If effects are heterogeneous and sampling is correlated with effect modification, weighting recovers the population ATT/ATE. Report both. |
| Estimate associations for prediction (machine learning) | Usually no | Prediction accuracy on new data depends on model fit, not population representativeness. |
| Estimate a model for an analytic subpopulation | Yes (with domain estimation) | The weights ensure the subpopulation estimate is representative of the subpopulation in the population. |

### Standard Errors in Survey-Weighted Regression

Even when weighted and unweighted point estimates are similar, standard errors will
differ because they must account for clustering and stratification. Always compute
survey regression standard errors using Taylor linearization or replicate weights --
never with heteroskedasticity-robust (HC) or cluster-robust (CR) standard errors
alone, which do not account for the full complex design.

## Common Federal Survey Data Sources

The following table provides a quick reference for analysts encountering common federal
surveys in education and social science research. It lists the design features you need
to specify when setting up your survey analysis.

| Survey | Full Name | Design Features | Weight Variable(s) | Variance Method | Key Documentation |
|--------|-----------|----------------|--------------------|-----------------|--------------------|
| **ECLS-K:2011** | Early Childhood Longitudinal Study, Kindergarten Class of 2010-11 | 3-stage: PSUs (counties) -> schools -> children; oversamples Asian, Pacific Islander, American Indian/Alaska Native | Multiple per wave and respondent type (e.g., `W1C0`, `W9C29P_2T0`); consult weight tables | Jackknife replicate weights (also provides TSL variables) | NCES User's Manuals (NCES 2015-074 and subsequent waves) |
| **HSLS:09** | High School Longitudinal Study of 2009 | 2-stage: schools -> students; stratified by school type, region, urbanicity | Multiple per wave (`W1STUDENT`, `W4W1STU`, etc.) | BRR replicate weights (also provides TSL on restricted-use files) | NCES User's Manual (NCES 2018-140) |
| **ELS:2002** | Education Longitudinal Study of 2002 | 2-stage: schools -> students; stratified by region, urbanicity, sector | Multiple per wave (`BYSTUWT`, `F3BYPNLWT`, etc.) | BRR replicate weights | NCES User's Manual (NCES 2014-364) |
| **NAEP** | National Assessment of Educational Progress | Complex multistage; matrix-sampled items | Student weight + jackknife replicate weights | Jackknife with plausible values | NAEP Technical Documentation (nces.ed.gov/nationsreportcard/tdw/) |
| **ACS PUMS** | American Community Survey Public Use Microdata Sample | Stratified systematic sampling from Census Master Address File; no clustering in PUMS | `PWGTP` (person) or `WGTP` (housing unit) + 80 successive-difference replicate weights | Successive-difference replication | Census Bureau ACS PUMS documentation |
| **CPS ASEC** | Current Population Survey Annual Social and Economic Supplement | Multistage: PSUs -> housing units; stratified by state and metropolitan status | `ASECWT` (supplement weight) + 160 replicate weights | Successive-difference replication | Census Bureau CPS Technical Paper 77 |
| **NHANES** | National Health and Nutrition Examination Survey | Multistage: counties -> segments -> households -> persons; oversamples minorities, elderly | Exam and interview weights per cycle (e.g., `WTMEC2YR`) | TSL with masked variance units (`SDMVSTRA`, `SDMVPSU`) | NCHS Analytic Guidelines |
| **MEPS** | Medical Expenditure Panel Survey | Multistage panel: drawn from NHIS respondents; oversamples minorities, elderly | `PERWT` (person-level) per year; pooled weights for multi-year | TSL (`VARSTR`, `VARPSU`) | AHRQ MEPS documentation (meps.ahrq.gov) |

**Notes:** Weight variable names are illustrative and may change across waves. Always
consult the current user's manual. "TSL" means Taylor series linearization variables
(strata + PSU) are provided. When both TSL and replicate weights are available, prefer
replicate weights. For NAEP, see [Plausible Values](#plausible-values) above.

## Pitfalls Checklist

The following errors are ordered roughly by severity and frequency. Each has destroyed
real research conclusions.

1. **Ignoring the survey design entirely.** Running standard OLS, t-tests, or chi-squared
   tests as if the data were an SRS. *Consequence:* Standard errors are biased downward
   (often 2-5x too small), producing inflated t-statistics and artificially significant
   results. Every published finding is suspect. *Fix:* Specify strata, PSU, and weights
   using survey-aware estimation commands.

2. **Subsetting the dataframe for domain estimation.** Filtering rows before analysis
   instead of using the subpopulation/domain mechanism. *Consequence:* Alters the
   effective number of PSUs and strata, producing biased standard errors that can go in
   either direction. *Fix:* Define a domain indicator variable and pass it to the
   estimation function. See [Domain Estimation](#domain-subpopulation-estimation).

3. **Using the wrong weight variable.** Applying a cross-sectional weight to a
   longitudinal analysis, a student-level weight to a school-level analysis, or a
   base-year weight to a follow-up analysis. *Consequence:* Point estimates do not
   represent the intended target population. *Fix:* Read the survey's weight selection
   guide. Match the weight to your analytic sample, time period, and unit of analysis.

4. **Passing survey weights to ordinary regression `weights=` arguments.** Using
   `statsmodels` WLS or `scikit-learn` `sample_weight` with survey weights. *Consequence:*
   Point estimates may approximate the weighted regression, but standard errors ignore
   clustering and stratification -- they will be too small and inference will be invalid.
   *Fix:* Use dedicated survey-aware estimation procedures that accept the full design
   specification (strata, PSU, weights). See the `svy` skill.

5. **Using the ordinary bootstrap on survey data.** Resampling observations with
   replacement from the full dataset. *Consequence:* Ignores the stratified clustered
   structure. Variance estimates have no theoretical justification for complex surveys.
   *Fix:* Use replicate weights if provided. If you need bootstrap inference, use a
   survey-appropriate bootstrap (Rao, Wu, and Yue 1992) that resamples PSUs within strata.

6. **Ignoring replicate weights when they are provided.** Constructing a TSL design
   object with strata and PSU variables when the survey also provides replicate weights.
   *Consequence:* TSL may be fine, but replicate weights encode the exact variance
   structure the survey methodologists intended and may handle complications (like
   certainty PSUs or collapsed strata) that TSL with the public-use variables does not.
   *Fix:* Use replicate weights when provided.

7. **Treating survey standard errors as SRS for power calculations or sample size
   determination.** Citing the nominal sample size without accounting for design effects.
   *Consequence:* Overstates the precision of the study. A survey with n = 10,000 and
   DEFF = 3.0 has the effective sample size of n = 3,333 for power purposes. *Fix:*
   Report effective sample sizes. Use design effects from pilot data or prior waves when
   planning analyses.

8. **Analyzing plausible values as point scores.** Using a single plausible value, or
   averaging plausible values into one score, instead of running separate analyses and
   combining with Rubin's rules. *Consequence:* Understates the total variance because
   the between-imputation component (measurement uncertainty) is ignored. *Fix:* Run M
   separate analyses, one per plausible value, and combine using Rubin's rules.

9. **Degrees of freedom issues.** Using normal-approximation (z-test) critical values
   for survey estimates when the effective degrees of freedom are small. *Consequence:*
   With few PSUs, the t-distribution with survey-appropriate degrees of freedom can
   differ materially from the normal. *Fix:* Use degrees of freedom based on the number
   of PSUs minus the number of strata. Some survey software computes this automatically.

10. **Combining survey cycles incorrectly.** Pooling multiple waves or cycles of a
    survey (e.g., combining 3 cycles of NHANES) without adjusting the weights.
    *Consequence:* Weighted totals will not sum to the correct population. *Fix:*
    Follow survey-specific guidance. For NHANES, divide weights by the number of
    combined cycles. For ACS, use the provided multi-year PUMS weights.

## Cross-References to DAAF Skills

| If you need to... | Go to |
|-------------------|-------|
| Write Python code for survey-weighted estimation | Load the `svy` skill for implementation syntax, design specification patterns, and worked examples |
| Compute weighted descriptive statistics (means, medians, proportions) | `./descriptive-analysis.md` > "Weighted Analysis" section, plus the `svy` skill for code |
| Run survey-weighted regression with covariates | Load the `svy` skill for design specification, plus `statsmodels` skill for model diagnostics |
| Apply causal inference methods to survey data | `./causal-inference.md` for methodology (DiD, IV, RD), plus the `svy` skill for survey-aware implementation |
| Understand a specific federal education survey's design | Load the relevant data source skill (e.g., `education-data-source-ccd`, `education-data-source-ipeds`) for survey-specific documentation |
| Produce publication-quality tables of survey estimates | `./descriptive-analysis.md` > "Summary Statistics That Tell a Story" for table design principles |
| Estimate models with fixed effects on survey data | Load `pyfixest` skill for FE estimation, noting that survey weight support requires additional configuration |

## References and Further Reading

### Primary Textbooks

Heeringa, S.G., West, B.T., and Berglund, P.A. (2017). *Applied Survey Data Analysis*
(2nd ed.). Chapman and Hall/CRC.
-- The most comprehensive applied textbook. Covers the full range of survey analysis
tasks with Stata, SAS, and R examples. The standard reference for analysts working with
federal survey microdata.

Korn, E.L. and Graubard, B.I. (1999). *Analysis of Health Surveys*. Wiley.
-- The definitive treatment for health survey analysis. Particularly strong on
subpopulation estimation, survey-weighted regression, and hypothesis testing.

Lohr, S.L. (2022). *Sampling: Design and Analysis* (3rd ed.). Chapman and Hall/CRC.
-- The leading graduate sampling textbook. Covers both design and analysis with
exceptional clarity. The third edition adds material on nonprobability sampling and
modern calibration methods.

Lumley, T. (2010). *Complex Surveys: A Guide to Analysis Using R*. Wiley.
-- Concise and practical. Written by the author of R's `survey` package. Best
single-volume introduction for a working analyst.

### Additional Textbooks

Kish, L. (1965). *Survey Sampling*. Wiley.
-- The foundational text on survey sampling. Introduced the design effect concept and
Kish's approximation formula. Still cited in every survey methods course.

Wolter, K.M. (2007). *Introduction to Variance Estimation* (2nd ed.). Springer.
-- The comprehensive reference on variance estimation methods for surveys: Taylor
linearization, jackknife, BRR, and bootstrap. The second edition adds extensive
bootstrap coverage.

Zimmer, S.A., Powell, R.J., and Velásquez, I.C. (2024). *Exploring Complex Survey Data
Analysis Using R: A Tidy Introduction with {srvyr} and {survey}*. Chapman and Hall/CRC.
https://tidy-survey-r.github.io/tidy-survey-book/
-- A modern, accessible introduction using tidyverse-style syntax. Freely available
online. Excellent worked examples with RECS, ANES, and NHANES data.

### Key Papers

Fay, R.E. (1989). "Theory and Application of Replicate Weighting for Variance
Calculations." *Proceedings of the Section on Survey Research Methods, American
Statistical Association*, 212-217.

Mislevy, R.J., Beaton, A.E., Kaplan, B., and Sheehan, K.M. (1992). "Estimating
Population Characteristics From Sparse Matrix Samples of Item Responses." *Journal of
Educational Measurement*, 29(2), 133-161.

Pfeffermann, D. (1993). "The Role of Sampling Weights When Modeling Survey Data."
*International Statistical Review*, 61(2), 317-337.

Rao, J.N.K., Wu, C.F.J., and Yue, K. (1992). "Some Recent Work on Resampling Methods
for Complex Surveys." *Survey Methodology*, 18(2), 209-217.

Rubin, D.B. (1987). *Multiple Imputation for Nonresponse in Surveys*. Wiley.

Rust, K.F. and Rao, J.N.K. (1996). "Variance Estimation for Complex Surveys Using
Replication Techniques." *Statistical Methods in Medical Research*, 5(3), 283-310.

Solon, G., Haider, S.J., and Wooldridge, J.M. (2015). "What Are We Weighting For?"
*Journal of Human Resources*, 50(2), 301-316.

West, B.T., Berglund, P.A., and Heeringa, S.G. (2008). "A Closer Examination of
Subpopulation Analysis of Complex-Sample Survey Data." *The Stata Journal*, 8(4),
520-531.

### Federal Agency Documentation

NCHS (National Center for Health Statistics). *NHANES Analytic Guidelines*.
https://wwwn.cdc.gov/nchs/nhanes/analyticguidelines.aspx

NCES (National Center for Education Statistics). *NAEP Technical Documentation*.
https://nces.ed.gov/nationsreportcard/tdw/

NCES. *NCES Handbook of Survey Methods*.
https://nces.ed.gov/statprog/handbook/

AHRQ (Agency for Healthcare Research and Quality). *MEPS Survey Documentation*.
https://meps.ahrq.gov/mepsweb/survey_comp/standard_errors.jsp

U.S. Census Bureau. *ACS PUMS Documentation*.
https://www.census.gov/programs-surveys/acs/microdata/documentation.html

### Teaching Resources

Stapleton, L.M. (2008). "Analysis of Data from Complex Surveys." In E.D. de Leeuw,
J.J. Hox, and D.A. Dillman (Eds.), *International Handbook of Survey Methodology*,
342-369. Taylor & Francis.

Zimmer, S.A. et al. "Tidy Survey Analysis in R." Short course materials.
https://tidy-survey-r.github.io/tidy-survey-short-course/

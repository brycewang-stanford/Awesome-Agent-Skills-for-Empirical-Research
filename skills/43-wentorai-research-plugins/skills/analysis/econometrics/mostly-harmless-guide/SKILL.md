---
name: mostly-harmless-guide
description: "Replication code and guide for Mostly Harmless Econometrics methods"
metadata:
  openclaw:
    emoji: "📘"
    category: "analysis"
    subcategory: "econometrics"
    keywords: ["econometrics", "causal-inference", "replication", "regression", "instrumental-variables", "difference-in-differences"]
    source: "https://github.com/vikjam/mostly-harmless-replication"
---

# Mostly Harmless Econometrics Guide

A skill providing replication code, explanations, and practical guidance for the econometric methods presented in Angrist and Pischke's "Mostly Harmless Econometrics" (MHE). Based on the mostly-harmless-replication repository (642 stars), this skill helps researchers understand and correctly apply core causal inference techniques.

## Overview

"Mostly Harmless Econometrics" is one of the most influential applied econometrics textbooks, providing accessible explanations of the methods that dominate modern empirical research in economics and increasingly in other social sciences. This skill translates the book's core methods into practical guidance that the agent can use to help researchers design studies, select appropriate estimators, and interpret results correctly.

The skill covers regression, instrumental variables, difference-in-differences, regression discontinuity, and related methods, with emphasis on the practical decisions researchers face when applying these techniques to real data.

## Regression Fundamentals

**Ordinary Least Squares (OLS)**
- OLS provides the best linear approximation to the conditional expectation function
- The regression anatomy theorem: each coefficient can be obtained from a bivariate regression of the outcome on the residualized regressor
- Omitted variable bias formula: bias equals the effect of the omitted variable times its correlation with the included regressor
- Control variables should be selected based on the conditional independence assumption, not on statistical significance
- Robust standard errors (Huber-White) should be the default; cluster when observations are not independent

**Regression Interpretation**
- The causal interpretation of regression requires the conditional independence assumption (CIA)
- CIA states that treatment is as good as randomly assigned after conditioning on controls
- Saturated models (fully interacted categorical variables) are always correctly specified
- Linear regression with continuous variables approximates the true conditional expectation
- Report both statistical and economic significance; a large t-statistic does not mean a large effect

**Practical Decisions**
- Include controls that are correlated with both the treatment and outcome
- Do not include controls that are consequences of treatment (bad controls)
- Use the most parsimonious specification that satisfies the CIA
- Test sensitivity to alternative control sets to assess robustness
- Report multiple specifications to demonstrate that results are not driven by a particular set of controls

## Instrumental Variables

**Core Concepts**
- IV addresses endogeneity when the treatment is correlated with unobserved factors affecting the outcome
- A valid instrument must be relevant (correlated with treatment) and excludable (affects outcome only through treatment)
- Two-stage least squares (2SLS) is the standard IV estimator
- The Wald estimator (reduced form divided by first stage) gives the IV estimate in the simplest case
- IV estimates the Local Average Treatment Effect (LATE) for compliers

**Implementation Guide**
- Always report the first-stage F-statistic; values below 10 indicate weak instruments
- Use the Anderson-Rubin test for inference robust to weak instruments
- Over-identification tests (Sargan-Hansen) can detect violations of the exclusion restriction with multiple instruments, but cannot validate a just-identified model
- Report the first stage, reduced form, and IV estimates together
- Compare OLS and IV estimates; if IV is much larger, consider LATE interpretation or measurement error

**Common Applications**
- Returns to education using quarter of birth as an instrument
- Effect of institutions on growth using settler mortality as an instrument
- Peer effects using random assignment to groups
- Supply and demand estimation using shift variables
- Policy evaluation using eligibility rules as instruments

## Difference-in-Differences

**Design Principles**
- DID compares changes in outcomes over time between treated and control groups
- The parallel trends assumption: absent treatment, both groups would have followed the same trend
- DID removes time-invariant unobserved confounders
- The standard estimator is a two-way fixed effects regression (unit and time fixed effects plus treatment indicator)
- Staggered adoption designs require careful attention to treatment timing heterogeneity

**Implementation**
- Always plot pre-treatment trends to assess the parallel trends assumption visually
- Include leads of the treatment indicator to test for pre-trends formally
- Cluster standard errors at the group level (state, firm, school)
- With few clusters (fewer than 50), use wild cluster bootstrap for inference
- Consider synthetic control methods when the control group is not a natural comparator

**Recent Developments**
- Callaway and Sant'Anna (2021): heterogeneity-robust DID with staggered treatment
- Sun and Abraham (2021): interaction-weighted estimator for event studies
- de Chaisemartin and D'Haultfoeuille (2020): decomposition of two-way FE estimator
- Goodman-Bacon (2021): DID with variation in treatment timing decomposition
- These methods address bias in standard two-way FE when treatment effects are heterogeneous

## Regression Discontinuity

**Sharp RD Design**
- Treatment is a deterministic function of a running variable at a known cutoff
- Causal effect is identified at the cutoff by comparing outcomes just above and just below
- Local linear regression is preferred over global polynomial fitting
- Bandwidth selection should use data-driven methods (Imbens-Kalyanaraman, Calonico-Cattaneo-Titiunik)
- Always show the RD plot: binned means of the outcome against the running variable

**Fuzzy RD Design**
- Treatment probability jumps at the cutoff but is not deterministic
- Fuzzy RD is analogous to IV where the instrument is being above the cutoff
- Estimates a LATE for units whose treatment status is changed by crossing the cutoff
- Report both the first stage (jump in treatment probability) and the reduced form (jump in outcome)
- Validity requires that other covariates do not jump at the cutoff (density test, covariate balance)

**Practical Guidance**
- Test for manipulation of the running variable using the McCrary density test
- Show robustness to alternative bandwidth choices
- Include covariates to improve precision but the estimate should not change substantially
- Avoid high-order polynomial specifications that can be misleading
- Report the effective sample size used in the local estimation

## Integration with Research-Claw

This skill enhances the Research-Claw econometric analysis workflow:

- Guide researchers in selecting the appropriate causal inference method for their question
- Help implement estimators correctly with proper standard errors and diagnostics
- Provide code templates for common econometric analyses in R, Stata, and Python
- Connect with data wrangling skills for cleaning and preparing analysis datasets
- Support writing skills with correctly formatted regression tables and result descriptions

## Best Practices

- Start by clearly stating the causal question and the source of identification
- Draw a directed acyclic graph (DAG) to clarify assumptions about causal relationships
- Report all relevant diagnostics (first-stage F, pre-trends, balance tests)
- Show robustness across specifications rather than selecting a single preferred model
- Distinguish between statistical significance, economic significance, and policy relevance
- Be transparent about the limitations of your identification strategy

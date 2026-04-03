---
description: Checklist of empirical robustness tests for finance/economics papers
---

# Robustness Test Checklist

Systematic checklist of robustness tests for empirical research. Use this to ensure comprehensive testing before submission.

---

## Core Robustness Categories

### 1. Alternative Samples

| Test | Description | When to Use |
|------|-------------|-------------|
| Exclude outliers | Winsorize/trim at different levels (0.5%, 2%, 5%) | Always |
| Drop financial firms | Exclude SIC 6000-6999 | If not already excluded |
| Drop regulated industries | Exclude utilities, telecoms | Industry-specific effects |
| Different time periods | Split sample pre/post crisis, early/late | Results may be period-specific |
| Geographic subsamples | By region, state, country | External validity |
| Size subsamples | Small vs. large firms | Heterogeneous effects |
| Balanced panel | Require continuous observations | Survivorship concerns |

### 2. Alternative Specifications

| Test | Description | When to Use |
|------|-------------|-------------|
| Different fixed effects | Firm, industry×year, state×year | Control for unobservables |
| Additional controls | Add variables referees might suggest | Omitted variable concerns |
| Drop controls | Verify not over-controlling | Mediator concerns |
| Different clustering | Firm, industry, state, two-way | Inference robustness |
| Different standard errors | Bootstrap, Newey-West, Driscoll-Kraay | Serial/cross-sectional correlation |
| Nonlinear specifications | Quadratic terms, splines | Linearity assumption |
| Log vs. level | Transform dependent variable | Skewed distributions |

### 3. Alternative Measures

| Test | Description | When to Use |
|------|-------------|-------------|
| Alternative dependent variable | Different proxy for same concept | Measurement concerns |
| Alternative treatment measure | Continuous vs. binary, different threshold | Treatment definition |
| Alternative control measures | Different proxies for size, leverage, etc. | Standard practice |
| Scaled differently | By assets, sales, employees | Scaling choice matters |

### 4. Identification Tests

| Test | Description | When to Use |
|------|-------------|-------------|
| **Placebo/Falsification** | | |
| Placebo timing | Fake treatment 1-3 years before actual | DiD parallel trends |
| Placebo outcome | Effect on outcome that shouldn't be affected | Specificity of mechanism |
| Placebo treatment | Random assignment of treatment | Rule out spurious correlation |
| **Pre-trends** | | |
| Event study plot | Coefficient for each pre/post period | Visual parallel trends |
| Joint F-test | Test pre-period coefficients = 0 | Statistical parallel trends |
| **Endogeneity** | | |
| Instrumental variables | Find exogenous variation | Selection concerns |
| Heckman selection | Model selection explicitly | Sample selection |
| Propensity score matching | Match treated/control | Observable selection |
| Entropy balancing | Reweight to balance covariates | Covariate imbalance |
| Regression discontinuity | If threshold exists | Sharp identification |

### 5. Inference Robustness

| Test | Description | When to Use |
|------|-------------|-------------|
| Wild cluster bootstrap | Small number of clusters | <50 clusters |
| Randomization inference | Permutation-based p-values | Few treated units |
| Conley standard errors | Spatial correlation | Geographic data |
| Multiple hypothesis correction | Bonferroni, FDR | Many outcomes tested |

---

## DiD-Specific Tests

For difference-in-differences designs:

- [ ] Event study with pre-treatment coefficients
- [ ] Parallel trends test (formal)
- [ ] Bacon decomposition (staggered treatment)
- [ ] Callaway-Sant'Anna or Sun-Abraham estimator (heterogeneous treatment effects)
- [ ] Placebo treatment timing
- [ ] Vary treatment window
- [ ] Triple-difference if possible
- [ ] Exclude always-treated or never-treated

---

## IV-Specific Tests

For instrumental variables:

- [ ] First-stage F-statistic (>10, prefer >100)
- [ ] Weak instrument robust inference (Anderson-Rubin)
- [ ] Overidentification test (if multiple IVs)
- [ ] Exclusion restriction discussion
- [ ] Reduced form results
- [ ] Compare OLS vs. IV magnitudes

---

## Quick Commands

- **"robustness checklist"** - Full checklist for current paper
- **"DiD robustness"** - DiD-specific tests only
- **"what tests for [method]"** - Tests for specific identification strategy
- **"referee-proof"** - Most commonly requested tests
- **"prioritize tests"** - Rank by importance for your setting

---

## Referee-Proof Minimum

At minimum, most papers should include:

1. **Sample robustness:** Exclude outliers, alternative time periods
2. **Specification robustness:** Alternative fixed effects, controls
3. **Measurement robustness:** Alternative variable definitions
4. **Inference robustness:** Alternative clustering
5. **Identification test:** At least one placebo or pre-trend test

---

## Reporting Template

For robustness tables:

```
Table X: Robustness Tests
Panel A: Alternative Samples
  (1) Baseline
  (2) Exclude financial firms
  (3) Exclude 2008-2009
  (4) Winsorize at 5%

Panel B: Alternative Specifications
  (5) Add industry×year FE
  (6) Control for firm age
  (7) Cluster by industry

Panel C: Alternative Measures
  (8) Alternative dependent variable
  (9) Continuous treatment measure
```

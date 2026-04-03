---
name: systematic-review-guide
description: "Systematic review methodology with PRISMA and evidence synthesis"
metadata:
  openclaw:
    emoji: "🔍"
    category: "research"
    subcategory: "deep-research"
    keywords: ["systematic review methodology", "evidence synthesis", "PRISMA flowchart", "risk of bias assessment"]
    source: "wentor-research-plugins"
---

# Systematic Review Guide

Conduct rigorous systematic reviews and meta-analyses following PRISMA 2020 guidelines, from protocol registration through evidence synthesis and reporting.

## What Is a Systematic Review?

A systematic review is a structured, transparent, and reproducible method for identifying, evaluating, and synthesizing all relevant research on a specific question. Unlike narrative reviews, systematic reviews:

- Follow a pre-registered protocol
- Use comprehensive, documented search strategies
- Apply explicit inclusion/exclusion criteria
- Assess risk of bias in included studies
- Synthesize findings quantitatively (meta-analysis) or narratively

## Step-by-Step Workflow

### Step 1: Define the Research Question

Use a structured framework to formulate your question:

| Framework | Components | Best For |
|-----------|-----------|----------|
| PICO | Population, Intervention, Comparator, Outcome | Clinical/intervention studies |
| PCC | Population, Concept, Context | Scoping reviews |
| SPIDER | Sample, Phenomenon of Interest, Design, Evaluation, Research type | Qualitative/mixed methods |
| PEO | Population, Exposure, Outcome | Observational studies |

**Example (PICO)**:
- P: Adults with Type 2 diabetes
- I: Telehealth-based self-management programs
- C: Standard in-person care
- O: HbA1c levels, quality of life

### Step 2: Register the Protocol

Register your protocol before conducting the search to reduce publication bias and selective reporting:

- **PROSPERO** (crd.york.ac.uk/prospero): Free registration for health-related systematic reviews
- **OSF Registries** (osf.io/registries): Open to all disciplines
- **Protocol paper**: Publish in BMJ Open, Systematic Reviews, or JMIR Research Protocols

Protocol should include:
- Research question and objectives
- Eligibility criteria
- Search strategy (databases, search terms)
- Screening process
- Data extraction plan
- Risk of bias assessment tool
- Synthesis method (meta-analysis or narrative)

### Step 3: Conduct the Search

```
Recommended minimum databases (health sciences):
1. PubMed / MEDLINE
2. Embase
3. Cochrane Central Register of Controlled Trials (CENTRAL)
4. At least one subject-specific database

Recommended minimum databases (social sciences):
1. Web of Science
2. Scopus
3. PsycINFO or ERIC (field-specific)
4. ProQuest Dissertations (for grey literature)

Additional sources:
- Reference lists of included studies (backward citation chaining)
- Forward citation searches
- Grey literature: conference proceedings, theses, reports
- Trial registries: ClinicalTrials.gov, WHO ICTRP
- Preprint servers: medRxiv, SSRN
```

Document each search with: database name, date, exact search string, and number of results.

### Step 4: Screen Studies

Two-stage screening, each conducted by at least two independent reviewers:

```
Stage 1: Title and Abstract Screening
- Apply inclusion/exclusion criteria based on title + abstract only
- Resolve disagreements by discussion or third reviewer
- Calculate inter-rater reliability (Cohen's kappa >= 0.60)

Stage 2: Full-Text Screening
- Retrieve full texts of all studies passing Stage 1
- Apply full eligibility criteria
- Document reasons for exclusion at this stage
- Calculate inter-rater reliability
```

Screening tools: Covidence (covidence.org), Rayyan (rayyan.ai), ASReview (AI-assisted)

### Step 5: Extract Data

Create a standardized data extraction form:

```markdown
| Field | Description |
|-------|-------------|
| Study ID | First author + year |
| Country | Where study was conducted |
| Study design | RCT, cohort, cross-sectional, etc. |
| Sample size | N in each group |
| Population | Demographics, inclusion criteria used |
| Intervention | Description, duration, intensity |
| Comparator | Description of control condition |
| Outcomes | Primary and secondary, measurement tools |
| Results | Effect sizes, confidence intervals, p-values |
| Funding | Source of funding |
| Conflicts of interest | Declared COIs |
```

Pilot the extraction form on 3-5 studies, then extract independently by two reviewers.

### Step 6: Assess Risk of Bias

Select the appropriate tool based on study design:

| Study Design | Tool | Developer |
|-------------|------|-----------|
| Randomized trials | RoB 2 | Cochrane |
| Non-randomized interventions | ROBINS-I | Cochrane |
| Observational (cohort, case-control) | Newcastle-Ottawa Scale (NOS) | Wells et al. |
| Cross-sectional | JBI Critical Appraisal Checklist | Joanna Briggs Institute |
| Qualitative studies | CASP Qualitative Checklist | CASP |
| Diagnostic accuracy | QUADAS-2 | Whiting et al. |

### Step 7: Synthesize Evidence

#### Narrative Synthesis

When meta-analysis is not appropriate (due to heterogeneity in study designs, populations, or outcomes):

1. Group studies by outcome, population, or intervention type
2. Describe patterns and consistencies across studies
3. Use vote counting only with direction of effect (not p-values)
4. Present findings in summary tables

#### Meta-Analysis

When studies are sufficiently similar to pool quantitatively:

```python
# Meta-analysis using Python (PythonMeta or custom)
# Example: Random-effects meta-analysis of standardized mean differences

import numpy as np
from scipy.stats import norm

def random_effects_meta(effects, variances):
    """DerSimonian-Laird random effects meta-analysis."""
    weights_fe = 1 / np.array(variances)
    theta_fe = np.sum(weights_fe * effects) / np.sum(weights_fe)

    # Estimate tau-squared (between-study variance)
    Q = np.sum(weights_fe * (effects - theta_fe)**2)
    df = len(effects) - 1
    C = np.sum(weights_fe) - np.sum(weights_fe**2) / np.sum(weights_fe)
    tau2 = max(0, (Q - df) / C)

    # Random effects weights
    weights_re = 1 / (np.array(variances) + tau2)
    theta_re = np.sum(weights_re * effects) / np.sum(weights_re)
    se_re = np.sqrt(1 / np.sum(weights_re))

    ci_lower = theta_re - 1.96 * se_re
    ci_upper = theta_re + 1.96 * se_re

    # Heterogeneity statistics
    I2 = max(0, (Q - df) / Q * 100) if Q > 0 else 0

    return {
        "pooled_effect": theta_re,
        "ci_lower": ci_lower,
        "ci_upper": ci_upper,
        "tau2": tau2,
        "I2": I2,
        "Q": Q,
        "p_heterogeneity": 1 - chi2.cdf(Q, df)
    }
```

```r
# Meta-analysis in R using metafor
library(metafor)

# Random-effects model (REML estimator)
res <- rma(yi = effect_sizes, vi = variances, method = "REML", data = dat)
summary(res)

# Forest plot
forest(res, slab = dat$study_label, header = TRUE)

# Funnel plot (publication bias assessment)
funnel(res)

# Egger's test for funnel plot asymmetry
regtest(res)
```

### Step 8: Report Using PRISMA 2020

The PRISMA 2020 flow diagram documents the study selection process:

```
Records identified from databases (n = X)
Records identified from other sources (n = X)
          |
Records after duplicates removed (n = X)
          |
Records screened (title/abstract) (n = X)
    -> Records excluded (n = X)
          |
Reports sought for retrieval (n = X)
    -> Reports not retrieved (n = X)
          |
Reports assessed for eligibility (n = X)
    -> Reports excluded with reasons (n = X)
       - Reason 1 (n = X)
       - Reason 2 (n = X)
       - Reason 3 (n = X)
          |
Studies included in review (n = X)
Studies included in meta-analysis (n = X)
```

## Common Pitfalls

| Pitfall | Solution |
|---------|----------|
| Incomplete search | Search at least 3 databases + grey literature |
| Single reviewer screening | Always use 2 independent reviewers |
| No protocol registration | Register on PROSPERO or OSF before searching |
| Ignoring heterogeneity | Report I-squared, conduct subgroup analyses |
| Publication bias unaddressed | Use funnel plots, Egger's test, trim-and-fill |
| Selective outcome reporting | Extract all pre-specified outcomes from protocol |

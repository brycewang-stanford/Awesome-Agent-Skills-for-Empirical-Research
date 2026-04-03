---
name: stata-accounting-research
description: |
  STATA code pattern library for empirical archival accounting research. Provides tested syntax from 126 peer-reviewed JAR (Journal of Accounting Research) replication files (2017-2025). Use when the user asks procedural questions like "How do I implement [method]?" or "Show me code for [technique]" — including: entropy balancing, propensity score matching (PSM), difference-in-differences (DiD), regression discontinuity (RDD), instrumental variables (IV), event studies (CAR/BHAR), survival analysis, Fama-MacBeth regressions, bootstrap, quantile regression, reghdfe/xtreg/areg, clustering standard errors, fixed effects, esttab/outreg2 table formatting, winsorization, leads/lags. Users can specify their variables (e.g., treatment, outcomes, controls) and receive adapted syntax. NOTE: This skill provides code patterns from published papers, not research design advice.
---

## Scope and Limitations

This skill is a **code pattern library**, not a methodological advisor.

| Can Do | Cannot Do |
|--------|-----------|
| Show *how* published papers implemented methods | Explain *when* to use one method over another |
| Provide tested STATA syntax | Advise on identification strategy |
| Indicate which robustness tests accompany analyses | Discuss research design trade-offs |
| Cite source papers for code patterns | Recommend optimal research design |

**When users ask methodology questions** (e.g., "Should I use entropy balancing or PSM?", "How do I address endogeneity?", "Is my identification strategy valid?"):

1. Acknowledge the limitation: "This skill provides code patterns from published papers, not research design guidance."
2. Show how different papers approached similar problems (code examples)
3. Suggest consulting methodology references: Breuer & deHaan (2024) for fixed effects, Angrist & Pischke for causal inference, or the user's methodologist/advisor
4. Offer to show multiple implementations so the user can see variation in approaches

## Workflow

Use `references/REFERENCES.md` as the primary index, then read targeted .do files.

### Stage 1: Index Search

Search `references/REFERENCES.md` to identify relevant papers. The index contains structured metadata:
- **Primary Method**: STATA commands used (reghdfe, psmatch2, stcox, etc.)
- **Identification Strategy**: DiD, PSM, IV, RDD, Event Study, etc.
- **Robustness/Special Features**: Winsorization levels, clustering specs, placebo tests, etc.

Example queries on REFERENCES.md:
- "entropy balancing" → finds JAR_60_alv, JAR_60_bl, JAR_61_ds, JAR_62_5_llz, JAR_63_2_npstv
- "stacked DiD" → finds JAR_61_ds, JAR_62_5_aov, JAR_62_5_gibbons
- "Cox hazard" → finds JAR_59_ctv, JAR_62_2_xyz

### Stage 2: Code Extraction

Read only the identified .do files to extract actual syntax. This reduces context usage and improves accuracy.

### Stage 3: Adaptation and Citation

1. Adapt patterns to the user's variable names and research context
2. Cite source: "Based on [Authors] ([Year]), JAR [Volume]([Issue])"

## Fallback: Direct Grep Patterns

For very specific syntax queries (e.g., "how does absorb() handle singletons?"), grep .do files directly:

| Task | Grep Pattern |
|------|--------------|
| Panel regressions | `reghdfe\|xtreg\|areg` |
| Fixed effects | `absorb\(\|i\.year\|i\.firm` |
| Clustering | `cluster\(\|vce\(cluster` |
| Matching/PSM | `psmatch2\|teffects\|cem\|ebalance\|pscore` |
| IV regression | `xtivreg\|ivregress\|ivreg2` |
| DiD | `post.*treat\|treat.*post\|parallel.*trend` |
| RDD | `rdrobust\|rddensity` |
| Event studies | `CAR\|BHAR\|abnormal.*return` |
| Survival | `stcox\|streg\|stset` |
| Fama-MacBeth | `fama.?macbeth\|newey.*west` |
| Bootstrap | `bootstrap\|bsample` |
| Quantile regression | `qreg\|sqreg\|bsqreg` |
| Table output | `esttab\|outreg2\|eststo` |
| Winsorization | `winsor\|winsor2` |

## Corpus Overview

126 STATA .do files from JAR Volumes 55-63 (2017-2025). See `references/REFERENCES.md` for complete catalog with paper titles and authors.

### File Naming Convention

- V55-61: `JAR_{volume}_{shortcode}.do`
- V62-63: `JAR_{volume}_{issue}_{shortcode}_{authors}.do`

### Volume Coverage

| Volume | Year | Papers |
|--------|------|--------|
| 55 | 2017 | 9 |
| 56 | 2018 | 12 |
| 57 | 2019 | 9 |
| 58 | 2020 | 13 |
| 59 | 2021 | 4 |
| 60 | 2022 | 22 |
| 61 | 2023 | 22 |
| 62 | 2024 | 25 |
| 63 | 2025 | 10 |

## Standard Patterns

### Clustering and Fixed Effects

```stata
* Firm and year FE with firm-clustered SEs (most common)
reghdfe depvar indepvar controls, absorb(firm year) cluster(firm)

* Industry-year FE
reghdfe depvar indepvar controls, absorb(ind_year) cluster(firm)
```

### Output Conventions

```stata
eststo clear
eststo: reghdfe depvar indepvar controls, absorb(firm year) cluster(firm)
esttab using "table.tex", replace star(* 0.10 ** 0.05 *** 0.01) se
```

### Winsorization

```stata
winsor2 varlist, cuts(1 99) replace
```

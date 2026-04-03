# STATA Accounting Research

A Claude Code skill providing STATA syntax patterns from 126 peer-reviewed JAR replication files (2017-2025).

## What is a Claude Skill?

A skill extends [Claude Code](https://claude.ai/code) with specialized knowledge and workflows. When installed, this skill enables natural language queries for STATA syntax patterns used in empirical accounting research.

### Installation

1. Download this repo as a zip file
2. In Claude, go to Settings > Capabilities > Skills > Add > Upload 

Alternatively, clone this repository to ~/.claude/skills

## What This Skill Does

| Provides | Does Not Provide |
|----------|------------------|
| STATA syntax from published papers | Research design advice |
| Multiple implementations of the same method | Identification strategy recommendations |
| Code adapted to your variable names | Methodological trade-off analysis |
| Source citations for patterns | Data or sample construction |

## Example

**Query:**
> How do I implement entropy balancing? My treatment variable is 'cyber_breach' and I want to balance on 'size', 'roa', and 'leverage'

**Response:**

```stata
* Step 1: Generate entropy balancing weights
ebalance cyber_breach size roa leverage, target(1) generate(ebw)

* Step 2: Use weights in regression
reghdfe depvar cyber_breach controls [aw=ebw], absorb(firm year) cluster(firm)
```

| Option | Meaning |
|--------|---------|
| `target(1)` | Balance means only (most common) |
| `target(2)` | Balance means + variances |
| `target(3)` | Balance means + variances + skewness |

**Alternative from Nessa et al. (2025), JAR 63(2)** — balance by year when treatment timing varies:

```stata
forvalues y = 2015/2022 {
    qui ebalance cyber_breach size roa leverage if year==`y', generate(ew`y') tar(1)
}
```

## Contents

This skill includes only STATA .do files. Other file types (SAS, R, Python, data files) from the original replication packages are not included.

```
references/
├── REFERENCES.md      # Index with methods and identification strategies
└── JAR_*.do           # 126 STATA replication files (Volumes 55-63)
```

## Method Coverage

| Method | Files |
|--------|-------|
| Panel fixed effects (reghdfe, xtreg, areg) | 54 |
| Difference-in-differences | 22 |
| Event studies (CAR/BHAR) | 19 |
| Propensity score matching | 10 |
| Entropy balancing | 5 |
| Survival/duration analysis | 4 |
| Instrumental variables | 3 |
| Regression discontinuity | 2 |

## File Naming Convention

- Volumes 55-61: `JAR_{volume}_{shortcode}.do`
- Volumes 62-63: `JAR_{volume}_{issue}_{shortcode}_{authors}.do`

## Original Source

The .do files are sourced from the Journal of Accounting Research Online Supplements:
https://www.chicagobooth.edu/research/chookaszian/journal-of-accounting-research/online-supplements-and-datasheets

## Methodological References

For research design guidance, consult:
- Breuer & deHaan (2024) on fixed effects interpretation
- Angrist & Pischke (2009) on causal inference

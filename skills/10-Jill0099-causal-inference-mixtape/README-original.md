# Causal Inference: The Mixtape — Claude Code Skill

A [Claude Code](https://claude.ai/code) skill providing ready-to-run code templates for causal inference methods, built from Scott Cunningham's *Causal Inference: The Mixtape* repository.

**Languages**: Python · R · Stata

---

## What It Does

This skill helps you:

1. **Implement causal inference methods** — DiD, RDD, IV, Synthetic Control, Matching, and more
2. **Choose the right language** — cross-language equivalents and coverage gap analysis
3. **Write robustness checks** — parallel trends, McCrary tests, Bacon decomposition, bandwidth robustness
4. **Avoid common pitfalls** — staggered DiD bias, weak instruments, missing diagnostics

## Methods Covered (10)

| Method | Python | R | Stata |
|--------|--------|---|-------|
| OLS / Regression | statsmodels | estimatr | reg/reghdfe |
| Difference-in-Differences | statsmodels | lfe/fixest | reghdfe |
| Event Study (Dynamic DiD) | manual lead/lag | fixest (sunab) | reghdfe + coefplot |
| Staggered DiD / TWFE | statsmodels | bacondecomp / did | bacondecomp / csdid |
| Regression Discontinuity | statsmodels | rdrobust | rdrobust |
| Instrumental Variables | linearmodels IV2SLS | AER/ivreg | ivregress 2sls |
| Synthetic Control | rpy2 → R Synth | Synth + SCtools | synth |
| Matching / PSM / IPW | manual logit + weights | MatchIt + ipw | teffects / cem |
| DAGs / Collider Bias | conceptual | dagitty + ggdag | — |
| Randomization Inference | permutation loop | ri2 | ritest |

## Trigger Phrases

Say any of the following to activate this skill:

- `implement a DiD regression`
- `write a causal inference pipeline`
- `set up an event study`
- `implement instrumental variables`
- `run a regression discontinuity design`
- `build a synthetic control model`
- `implement propensity score matching`
- `implement Bacon decomposition`

---

## Installation

Copy the skill folder to your Claude Code skills directory:

```bash
cp -r causal-inference-mixtape ~/.claude/skills/
```

Or clone directly:

```bash
git clone https://github.com/Jill0099/causal-inference-mixtape.git ~/.claude/skills/causal-inference-mixtape
```

---

## File Structure

```
causal-inference-mixtape/
├── SKILL.md                              # Core skill (auto-loaded when triggered)
├── references/
│   ├── method-patterns.md               # Full code templates for all 10 methods
│   └── r-stata-comparison.md            # Cross-language coverage gaps & packages
└── prompts/
    ├── 01-implement-method.md           # Copy-paste: implement any causal method
    └── 02-robustness-checks.md          # Copy-paste: DiD/RDD/IV robustness code
```

---

## Key Features

### Cross-Language Equivalents

| Task | Python | R | Stata |
|------|--------|---|-------|
| OLS with robust SE | `smf.ols().fit(cov_type='HC1')` | `lm_robust()` | `reg y x, robust` |
| Cluster SE | `fit(cov_type='cluster', ...)` | `felm(y ~ x \| 0 \| 0 \| cl)` | `reg y x, cluster(id)` |
| Two-way FE | `C(id) + C(time)` | `felm(y ~ x \| id + time)` | `reghdfe y x, absorb(id time)` |
| IV / 2SLS | `IV2SLS.from_formula(...)` | `ivreg(y ~ exog \| inst)` | `ivregress 2sls y (endog = inst)` |

### Python Gaps Documented

Some methods lack mature Python implementations:
- **Synthetic Control** → use `rpy2` to call R's `Synth`
- **Bacon Decomposition** → use R (`bacondecomp`) or Stata
- **Coarsened Exact Matching** → use Stata (`cem`) or R (`MatchIt`)
- **McCrary Density Test** → use R (`rdd`)

### Robustness Check Patterns

| Method | Required Checks |
|--------|----------------|
| DiD | Parallel trends (event study plot), placebo treatment dates |
| RDD | McCrary density test, bandwidth robustness, polynomial robustness |
| IV | First-stage F > 10, exclusion restriction, over-identification test |
| Synthetic Control | Pre-treatment RMSPE, placebo distribution, leave-one-out |
| Matching | Covariate balance table, caliper sensitivity |

---

## Prompts (Copy-Paste Ready)

The `prompts/` folder contains standalone prompts for use without Claude Code:

| File | Use Case |
|------|----------|
| `01-implement-method.md` | Implement any causal method with diagnostics |
| `02-robustness-checks.md` | Generate robustness check code for DiD / RDD / IV |

Each prompt has fill-in fields — replace with your paper's details and paste into any Claude chat.

---

## Source

Built from systematic analysis of Scott Cunningham's [Causal Inference: The Mixtape](https://mixtape.scunning.com/) repository:
- 58 Python scripts
- ~56 R scripts
- ~60 Stata .do files
- Full course curriculum (9 sections)

---

## License

MIT

# Empirical Strategy — Lalonde NSW (pre-registration)

**Frozen at**: 2026-04-29
**Population**: Lalonde NSW treated workers + PSID comparison sample, 1976–78
**Treatment**: `treat` (binary, NSW assignment)
**Outcome**:   `re78` (1978 real earnings, USD)
**Estimand**:  ATT — average treatment effect on the program's actual participants
**Design**:    selection on observables (cross-sectional X-adjustment)

## Estimating equation

```
re78_i = α + β · treat_i + X_i' γ + ε_i
X_i = (age, educ, black, hispan, married, nodegree, re74, re75)
```

## Identifying assumption

1. **Conditional unconfoundedness**: `Y(0), Y(1) ⊥ D | X` — outside the NSW experiment,
   PSID comparison units differ on observables; conditioning on `X` closes the back door.
2. **Overlap**: 0 < Pr(D=1 | X) < 1 for all X in the joint support — verified in §3
   via the propensity-score overlap plot.

## Auto-flagged threats (must defend in §6 robustness)

- **Selection on unobservables** (motivation, skill not in X) → **Oster δ** in §6
- **Functional-form sensitivity** (linear vs flexible) → progressive M1→M6 + spec curve
- **Outcome scale** (levels vs IHS / log) → robustness rows
- **PSID comparison group choice** (PSID-1 vs CPS-1) → out-of-scope here; flagged

## Fallback estimators (§6 / §7 robustness gauntlet)

- IPW (HC3-corrected) on logistic propensity
- AIPW / DR-Learner (selection-on-observables doubly robust)
- Entropy balancing (matches first 3 moments exactly)
- DML (econml.LinearDML) — partials out X via cross-fitted ML

## Reporting checklist (Step 8)

- Report β̂(ATT) under M1→M6 progressive controls (Pattern A)
- Show convergent evidence: OLS / IPW / PSM / Entropy balancing (Pattern B)
- Attach Oster δ, spec curve, sensitivity dashboard
- Persist `result.json` reproducibility stamp with dataset SHA256 + version pins

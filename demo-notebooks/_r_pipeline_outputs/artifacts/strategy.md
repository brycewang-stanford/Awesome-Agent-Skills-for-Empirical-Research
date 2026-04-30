# Empirical Strategy — Lalonde NSW (pre-registration)

**Frozen at**: 2026-04-29
**Population**: Lalonde NSW treated workers + PSID comparison sample, 1976-78
**Treatment**: `treat` (binary, NSW assignment)
**Outcome**:   `re78` (1978 real earnings, USD)
**Estimand**:  ATT — average treatment effect on the program's actual participants
**Design**:    selection on observables (cross-sectional X-adjustment)

## Estimating equation

```
re78_i = a + b * treat_i + X_i' * gamma + eps_i
X_i = (age, educ, black, hispan, married, nodegree, re74, re75)
```

## Identifying assumption

1. **Conditional unconfoundedness**: Y(0), Y(1) independent of D given X.
2. **Overlap**: 0 < Pr(D=1 | X) < 1 in the joint support — verified in §3
   via the propensity-score overlap plot.

## Auto-flagged threats (must defend in §6 robustness)

- Selection on unobservables (motivation, ability not in X) -> Oster delta
- Functional-form sensitivity -> progressive M1->M6 + spec curve
- Outcome scale (levels vs IHS / log) -> robustness rows
- PSID comparison group choice -> out-of-scope here; flagged

## Fallback estimators (§6 / §7 robustness)

- IPW (HC3-corrected) on logistic propensity (`WeightIt::weightit`)
- AIPW / DR-Learner (`grf::causal_forest`, `DoubleML::DoubleMLPLR`)
- Entropy balancing (`WeightIt::weightit(method = 'ebal')`)

## Reporting checklist (Step 8)

- Report beta(ATT) under M1->M6 progressive controls (Pattern A)
- Convergent evidence: feols / WeightIt / MatchIt / DoubleML (Pattern B)
- Attach Oster delta, spec curve, sensitivity dashboard
- Persist `result.json` reproducibility stamp


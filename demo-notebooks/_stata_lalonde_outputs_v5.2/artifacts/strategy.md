# Empirical Strategy — Lalonde NSW (pre-registration)

**Frozen at**: 2026-05-02
**Design (per skill §2.5 picker)**: selection-on-observables (cross-section)
**Population**: Lalonde NSW treated workers + PSID comparison, 1976-78
**Treatment**: `treat` (binary NSW assignment)
**Outcome**:   `re78` (1978 real earnings, USD)
**Estimand**:  ATT

## Estimating equation

    re78_i = a + b * treat_i + X_i' * gamma + eps_i
    X_i = (age, educ, black, hispan, married, nodegree, re74, re75)

## Identifying assumption

1. Conditional unconfoundedness: Y(0), Y(1) ⟂ D | X
2. Overlap: 0 < Pr(D=1 | X) < 1 in joint support

## Auto-flagged threats

- Selection on unobservables (motivation, ability) → Oster δ
- Functional-form sensitivity → progressive M1→M5 + spec curve
- Weak overlap in PS tails → common support trimming

## Fallback estimators (§6)

- teffects ipw / ipwra / aipw (DR)
- psmatch2 NN matching
- ebalance entropy balancing
- psacalc delta (Oster 2019 sensitivity)

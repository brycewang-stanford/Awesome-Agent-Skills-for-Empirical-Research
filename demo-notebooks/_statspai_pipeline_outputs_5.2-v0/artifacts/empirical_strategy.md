# Empirical Strategy (pre-registration)

**Population**: Lalonde NSW treated + PSID controls, 1976-78
**Estimand**: ATT — average treatment effect on the treated
**Design**: selection on observables (cross-sectional X-adjustment)

## Estimating equation

```
re78_i = alpha + beta * treat_i + X_i' * gamma + eps_i
X = (age, educ, black, hispan, married, nodegree, re74, re75)
```

## Identifying assumptions

- (Unconfoundedness | X)  treat ⊥ (re78(0), re78(1)) | X
- (Overlap)  0 < Pr(treat=1|X) < 1 ∀X in support
- (IV addendum) If IV is attempted: relevance (cov(Z,treat|X)≠0) + exclusion (Z→re78 only via treat) + exogeneity

## Threats to identification

- Selection on unobservables (motivation, soft skills, location shocks)
- Functional-form misspecification of propensity / outcome models
- Limited overlap on (re74, re75) — well-known Lalonde tail behaviour
- IV: no valid natural instrument in the Lalonde data; constructed instruments are weak

## Primary & fallback estimators

- Primary: AIPW (doubly robust — consistent if PS or outcome model correct)
- Fallbacks: OLS, PSM, DML-PLR, Entropy balancing, IV (constructed instrument for demonstration)

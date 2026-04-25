# Empirical Strategy (pre-registration)

**Population**: Lalonde NSW treated + PSID controls, 1976-78
**Estimand**: ATT - average treatment effect on the program's actual participants
**Design**: selection on observables (cross-sectional X-adjustment)

## Estimating equation

```
re78_i = alpha + beta * treat_i + X_i' * gamma + eps_i
X = (age, educ, black, hispan, married, nodegree, re74, re75)
```

## Identifying assumptions

- (Unconfoundedness | X)  treat ind (re78(0), re78(1)) | X
- (Overlap)                0 < Pr(treat = 1 | X) < 1 for all X in the support

## Threats to identification

- Selection on unobservables (motivation, soft skills, location shocks)
- Functional-form misspecification of the propensity / outcome models
- Limited overlap on (re74, re75) - well-known Lalonde tail behaviour

## Fallback estimators

- ipw
- regress
- match
- ebalance
- causal_forest

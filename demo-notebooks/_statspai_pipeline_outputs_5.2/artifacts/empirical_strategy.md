# Empirical Strategy (pre-registration)

**Population**: low-income males in the US National Supported Work demonstration, 1970s
**Treatment**: `treat`    **Outcome**: `re78`
**Estimand**: ATT

## Primary design: IV-2SLS
```
Y_i = α + β·D_i + X'γ + ε_i          (OLS)
D_i = π·Z_i + X'δ + u_i             (First stage)
  where Z = [re74, re75], D = treat (training), Y = re78 (earnings)

Identifying assumption: conditional on X, pre-treatment earnings (re74, re75)
affect training participation (relevance) but do not directly affect 1978 earnings
(exclusion restriction, conditional on X).

Fallback: OLS with progressive controls, PSM, and DML for robustness.
```

## Identification story
Conditional ignorability given ['age', 'educ', 'married', 'nodegree', 're74', 're75']; AIPW (doubly robust) is consistent if either the propensity score or outcome model is correctly specified.

## Fallback estimators
- OLS with progressive controls
- Propensity-score matching (PSM)
- Double/debiased ML (DML)

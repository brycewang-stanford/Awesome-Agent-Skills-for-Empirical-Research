# Empirical Strategy (pre-registration)

**Population**: NLSYM men aged 24-34 in 1976, with non-missing wage and education
**Treatment** : `educ` (years of schooling, continuous, 1-18)
**Outcome**   : `lwage` (log hourly wage, 1976)
**Instrument**: `nearc4` (1 if grew up in county with 4-yr college)
**Estimand**  : LATE — return to one extra year of schooling for the
sub-population whose schooling decision was changed by the proximity instrument.
**Estimator** : `sp.ivreg` (2SLS with cluster-robust SE)

## Estimating equation

First stage  : educ_i = pi_0 + pi_1 nearc4_i + X_i' gamma + u_i
Second stage : lwage_i = beta_0 + beta_1 educ_i_hat + X_i' delta + e_i

Controls X: exper, expersq, black, south, smsa, smsa66, region dummies (reg662-reg669).

## Identification story

College proximity (`nearc4`) is assumed to shift the cost of acquiring
education without affecting wages directly, so it identifies a LATE among
"compliers" whose schooling decision is sensitive to college access. Card
(1995) defends this exclusion restriction by conditioning on region,
SMSA-66 residence and family-background controls.

## Identifying assumptions (must defend in §2)

- Relevance: cov(nearc4, educ | X) != 0 — verified in the first stage F-stat.
- Exclusion: nearc4 affects lwage only through educ, conditional on X.
- Independence: nearc4 is as-good-as-randomly assigned conditional on X.
- Monotonicity: no defiers (proximity weakly increases schooling).

## Auto-flagged warnings

- (none)

## Fallback estimators (Step 7 robustness)

- OLS with progressive controls (selection-on-observables benchmark).
- DML — partially-linear regression with random forest nuisance models.
- Oster (2019) bound — proportional selection on unobservables.
- Cinelli-Hazlett sensitivity contour for the OLS estimate.

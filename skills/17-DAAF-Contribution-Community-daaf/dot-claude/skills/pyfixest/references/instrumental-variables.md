# Instrumental Variables

## Contents

- [IV Formula Syntax](#iv-formula-syntax)
- [First Stage Diagnostics](#first-stage-diagnostics)
- [Weak Instrument Tests](#weak-instrument-tests)
- [IV Diagnostics Summary](#iv-diagnostics-summary)
- [Common IV Designs](#common-iv-designs)

## IV Formula Syntax

pyfixest uses a three-part formula for IV estimation. The third part (after the second `|`) specifies `endogenous ~ instruments`:

### Basic IV (No Fixed Effects)

```python
import pyfixest as pf

# Y ~ exogenous | 0 (no FE) | endogenous ~ instruments
fit = pf.feols("Y ~ X_exog | 0 | X_endog ~ Z_instrument", data=df)
fit.summary()
```

Use `0` for the FE slot when you have no fixed effects but need IV.

### IV with Fixed Effects

```python
# Y ~ exogenous | FE | endogenous ~ instruments
fit = pf.feols("Y ~ X_exog | entity + year | X_endog ~ Z_instrument", data=df)
```

### Multiple Instruments (Over-Identification)

```python
# Two instruments for one endogenous variable
fit = pf.feols("Y ~ 1 | fe | X_endog ~ Z1 + Z2", data=df)
```

Over-identification (more instruments than endogenous variables) allows for Sargan/Hansen tests of instrument validity (though pyfixest does not currently implement these directly).

### No Exogenous Regressors

When the only non-FE regressor is the endogenous variable, use `1` for the exogenous part:

```python
# Only endogenous variable (plus FE)
fit = pf.feols("Y ~ 1 | entity + year | X_endog ~ Z1", data=df)
```

### IV with Clustered Standard Errors

```python
fit = pf.feols("Y ~ X_exog | entity + year | X_endog ~ Z1", data=df,
               vcov={"CRV1": "entity"})
```

Or switch post-estimation:

```python
fit = pf.feols("Y ~ X_exog | entity + year | X_endog ~ Z1", data=df)
fit.vcov({"CRV1": "entity"}).summary()
```

## First Stage Diagnostics

The first stage regression estimates the relationship between the instrument(s) and the endogenous variable. A strong first stage is essential for reliable IV estimates.

### Accessing First Stage Results

```python
fit = pf.feols("Y ~ 1 | fe | X_endog ~ Z1 + Z2", data=df)

# Access the first-stage Feols object (internal attribute)
first_stage = fit._model_1st_stage
first_stage.summary()

# Check first-stage F-statistic
# Rule of thumb: F > 10 suggests instruments are not weak
# (Staiger & Stock, 1997)
```

Note: The first-stage model is accessed via the `_model_1st_stage` attribute. While this is a private attribute (underscore prefix), it is the documented access pattern. The comprehensive `IV_Diag()` method (below) is the preferred entry point for all IV diagnostics.

### Interpreting First Stage

The first stage estimates: `X_endog = π₀ + π₁·Z1 + π₂·Z2 + FE + error`

Key checks:
- **Sign and significance of π**: Instruments should predict the endogenous variable in the expected direction
- **F-statistic**: Joint significance of excluded instruments
- **Partial R²**: How much variation in X_endog the instruments explain (beyond other covariates and FE)

## Weak Instrument Tests

Weak instruments produce unreliable IV estimates — biased toward OLS, with severely distorted inference.

### Effective F-Statistic and Weak Instrument Tests

The preferred approach is to use the comprehensive `IV_Diag()` method, which reports all relevant diagnostics:

```python
fit = pf.feols("Y ~ 1 | fe | X_endog ~ Z1 + Z2", data=df)

# Comprehensive diagnostic output — includes:
# - Effective F-statistic (Olea & Pflueger 2013)
# - Cragg-Donald F
# - Kleibergen-Paap rk Wald F
fit.IV_Diag()
```

- **Effective F-statistic**: Generalizes Stock-Yogo to non-homoskedastic settings. Critical values depend on the desired maximal bias/size distortion — consult Olea & Pflueger (2013) tables.
- **Cragg-Donald F**: Assumes iid errors — compare to Stock-Yogo critical values
- **Kleibergen-Paap rk Wald F**: Robust to heteroskedasticity/clustering — preferred with non-iid errors

### Anderson-Rubin Confidence Intervals

For weak-instrument-robust inference, Anderson-Rubin (AR) confidence intervals remain valid regardless of instrument strength. These are wider than standard IV CIs but have correct coverage even with weak instruments.

## IV Diagnostics Summary

```python
fit = pf.feols("Y ~ 1 | fe | X_endog ~ Z1 + Z2", data=df)

# Comprehensive IV diagnostic output
fit.IV_Diag()
```

`IV_Diag()` combines first-stage statistics, weak instrument tests, and other diagnostic information into a single summary.

## Common IV Designs

Brief descriptions of common instrument strategies. For methodology guidance on identification assumptions, load the `data-scientist` skill's causal inference references.

### Lottery / Randomization Instruments

An experimental or quasi-experimental lottery determines treatment eligibility, but not everyone complies.

```python
# Charter school lottery: lottery_win instruments for charter_attendance
fit = pf.feols("test_score ~ demographics | district | charter_attend ~ lottery_win",
               data=df, vcov={"CRV1": "school"})
```

**Identification:** Random assignment ensures the instrument is independent of potential outcomes. Estimates a Local Average Treatment Effect (LATE) for compliers.

### Geographic / Distance Instruments

Proximity to a facility instruments for use of that facility.

```python
# Distance to college instruments for years of education
fit = pf.feols("log_wage ~ experience | 0 | education ~ college_proximity",
               data=df, vcov="hetero")
```

**Key assumption:** Distance affects the outcome only through the endogenous variable (exclusion restriction). Threats: geographic sorting, distance correlated with local labor markets.

### Policy / Regulatory Instruments

Exogenous policy variation instruments for the behavior the policy targets.

```python
# Compulsory schooling laws instrument for education
fit = pf.feols("log_wage ~ 1 | birth_cohort + state | education ~ compulsory_years",
               data=df, vcov={"CRV1": "state"})
```

**Reference:** Angrist & Krueger (1991) quarter-of-birth design; Acemoglu & Angrist (2001) compulsory schooling.

### Shift-Share / Bartik Instruments

Combines local industry shares (exposure) with national industry trends (shifts):

```python
# Bartik instrument: local exposure to national industry shocks
# Construct the instrument as: sum(local_share_j * national_growth_j)
df["bartik"] = compute_bartik(df)  # user-constructed
fit = pf.feols("Y ~ controls | region + year | employment_change ~ bartik",
               data=df, vcov={"CRV1": "region"})
```

**Modern guidance:** Borusyak, Hull, & Jaravel (2022) and Goldsmith-Pinkham, Sorkin, & Swift (2020) provide complementary identification frameworks — one based on exogeneity of shares, the other on exogeneity of shifts.

### Judge / Examiner Fixed Effects

Random assignment of cases to judges with varying leniency instruments for the decision:

```python
# Judge leniency instruments for incarceration
# Construct leave-out judge leniency (excluding the current case)
df["judge_leniency"] = compute_leave_out_mean(df)
fit = pf.feols("Y ~ controls | court + year | incarcerated ~ judge_leniency",
               data=df, vcov={"CRV1": "judge"})
```

**Reference:** Kling (2006); Dobbie, Goldin, & Yang (2018); Stevenson (2018).

## References and Further Reading

- Staiger, D. and Stock, J.H. (1997). "Instrumental Variables Regression with Weak Instruments." *Econometrica*, 65(3), 557-586
- Olea, J.L.M. and Pflueger, C. (2013). "A Robust Test for Weak Instruments." *Journal of Business & Economic Statistics*, 31(3), 358-369
- Cunningham, S. (2021). *Causal Inference: The Mixtape*. Yale University Press. Ch. 7: Instrumental Variables. https://mixtape.scunning.com/
- Angrist, J.D. and Pischke, J.-S. (2009). *Mostly Harmless Econometrics*. Princeton University Press. Ch. 4: Instrumental Variables in Action
- Borusyak, K., Hull, P., and Jaravel, X. (2022). "Quasi-Experimental Shift-Share Research Designs." *Review of Economic Studies*, 89(1), 181-213
- Goldsmith-Pinkham, P., Sorkin, I., and Swift, H. (2020). "Bartik Instruments: What, When, Why, and How." *American Economic Review*, 110(8), 2586-2624
- pyfixest documentation — IV Estimation: https://pyfixest.org

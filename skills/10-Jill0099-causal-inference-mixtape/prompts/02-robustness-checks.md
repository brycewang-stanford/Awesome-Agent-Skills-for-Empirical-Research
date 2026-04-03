# Prompt 2: Generate Robustness Check Code

Copy and paste the relevant section below based on your identification strategy.

---

## For DiD Papers

```
You are an expert econometrician. Generate robustness check code in [Python / R / Stata] for my DiD analysis.

Produce code for ALL of the following:

1. EVENT STUDY (parallel trends):
   - Dynamic specification with lead/lag dummies
   - Plot coefficients with 95% CI
   - Pre-period joint F-test

2. PLACEBO TREATMENT DATE:
   - Re-estimate using a fake treatment date [N] years before actual treatment
   - Expect null result

3. BACON DECOMPOSITION (if staggered):
   - Decompose TWFE into 2x2 comparisons
   - Identify problematic "already-treated vs later-treated" weight

4. ALTERNATIVE CONTROL GROUP:
   - Re-estimate dropping [specific units] from control group
   - Verify results hold

5. ENTROPY BALANCING / PSM-DID:
   - Re-weight sample to achieve covariate balance
   - Re-estimate on balanced sample

My details:
- Treatment: [e.g., 2014 SOE reform]
- Treated group: [e.g., listed SOEs]
- Control group: [e.g., non-SOE listed firms]
- Treatment timing: [e.g., 2014 for all / staggered]
- Outcome: [e.g., abnormal investment]
- Pre-period: [e.g., 2010-2013]
- Post-period: [e.g., 2015-2018]
- Covariates for balancing: [e.g., size, leverage, ROA, age]
```

---

## For RDD Papers

```
You are an expert econometrician. Generate robustness check code in [Python / R / Stata] for my RDD analysis.

Produce code for ALL of the following:

1. McCRARY DENSITY TEST:
   - Test for manipulation at the cutoff
   - Report test statistic and p-value
   - Plot density

2. COVARIATE BALANCE:
   - Test each covariate for discontinuity at cutoff
   - Report coefficients and p-values in a table

3. BANDWIDTH ROBUSTNESS:
   - Re-estimate with bandwidths: h/2, h, 3h/2, 2h (h = IK optimal)
   - Table of estimates across bandwidths

4. POLYNOMIAL ROBUSTNESS:
   - Linear, quadratic, cubic specifications
   - Report all three estimates

5. PLACEBO CUTOFFS:
   - Re-estimate at false cutoffs (e.g., median of each side)
   - Expect null results

My details:
- Running variable: [e.g., vote share percentage]
- Cutoff: [e.g., 50% majority threshold]
- Outcome: [e.g., firm ESG score]
- IK optimal bandwidth: [e.g., 8.3 percentage points]
- Covariates for balance test: [e.g., firm size, age, leverage]
```

---

## For IV Papers

```
You are an expert econometrician. Generate robustness check code in [Python / R / Stata] for my IV analysis.

Produce code for ALL of the following:

1. FIRST-STAGE DIAGNOSTICS:
   - First-stage regression with F-statistic
   - Report coefficient on instrument(s)
   - Cragg-Donald / Kleibergen-Paap F-stat

2. EXCLUSION RESTRICTION SUPPORT:
   - Placebo test: regress outcome on instrument controlling for endogenous variable
   - If coefficient on instrument ≈ 0, supports exclusion

3. OVER-IDENTIFICATION TEST (if multiple instruments):
   - Hansen J / Sargan test
   - Report test statistic and p-value

4. REDUCED FORM:
   - Regress outcome directly on instrument(s)
   - Should have same sign as 2SLS estimate

5. OLS vs IV COMPARISON:
   - Report OLS and IV side by side
   - Wu-Hausman endogeneity test

My details:
- Endogenous variable: [e.g., corruption level]
- Instrument(s): [e.g., ethnic fractionalization, distance to coast]
- Outcome: [e.g., patent count]
- Controls: [e.g., GDP per capita, education, population]
- First-stage F: [e.g., 23.4]
```

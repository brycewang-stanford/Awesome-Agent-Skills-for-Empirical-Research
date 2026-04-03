# MEPS Methodology

How Model Estimates of Poverty in Schools (MEPS) are calculated, validated, and should be interpreted for research purposes.

## Overview of the Modeling Approach

MEPS uses a **linear probability model** to estimate the share of students in each school from households with incomes at or below **100% of the Federal Poverty Level (FPL)**.

### Core Concept

The model leverages two key data sources:
1. **School-level data** from CCD (enrollment, FRPL counts where reliable)
2. **District-level poverty** from Census SAIPE (ground truth for calibration)

The model estimates school-level poverty while ensuring district totals align with Census estimates.

## The MEPS Model

### Model Specification

MEPS uses a linear probability model of the form:

```
Poverty_school = α + β₁(FRPL_school) + β₂(Demographics) + β₃(Geography) + ε
```

Where:
- **Poverty_school**: Estimated share of students in poverty (0-1)
- **FRPL_school**: School-level FRPL rate (where reliable)
- **Demographics**: School demographic characteristics from CCD
- **Geography**: District-level variables including SAIPE poverty rate
- **ε**: Error term

### Key Methodological Features

1. **District-level calibration**: School estimates are constrained to sum to the Census SAIPE district estimate when weighted by enrollment

2. **FRPL adjustment**: The model accounts for systematic differences between FRPL and true poverty rates, which vary by:
   - State (due to policy differences)
   - Year (due to CEP adoption)
   - School type (charter vs traditional)

3. **Enrollment weighting**: Estimates are generated to be representative of student populations, not just school counts

## Model Training and Estimation

### Training Data

The model is trained on schools where reliable poverty information exists:
- Schools in states with consistent FRPL reporting
- Pre-CEP time periods where FRPL more closely tracked poverty
- Validation against independent poverty measures

### Estimation Process

1. **Estimate model coefficients** using training data
2. **Generate predicted values** for all schools
3. **Apply district constraints** so school estimates sum to SAIPE
4. **Calculate standard errors** for uncertainty quantification

## Modified MEPS (`meps_mod`)

### Why Modified MEPS Exists

The original MEPS model tends to **underestimate poverty** in districts with very high poverty rates. This occurs because:
- The linear model compresses extreme values
- Limited variation in predictors for very-high-poverty districts

### Modified MEPS Calculation

Modified MEPS adjusts estimates for schools in districts where the model systematically underestimates:

```
meps_mod = meps + adjustment_factor
```

The adjustment factor is larger for schools in districts where:
- District SAIPE poverty is very high (>30%)
- Original MEPS substantially underestimates district totals

### When to Use Modified MEPS

| Scenario | Recommendation |
|----------|---------------|
| General analysis | Use original `meps_poverty_pct` |
| Focus on high-poverty schools/districts | Consider `meps_mod_poverty_pct` |
| Comparing across poverty levels | Use original `meps_poverty_pct` for consistency |
| Policy analysis for Title I | Consider `meps_mod_poverty_pct` for high-poverty targeting |

## Validation Evidence

### Correlation with SAIPE

At the district level, MEPS aggregates correlate strongly with Census SAIPE:
- **Correlation**: 0.85-0.95 depending on year
- **Mean absolute error**: ~3-5 percentage points

### Comparison with Administrative Data

In states with reliable administrative data (e.g., tax records), MEPS shows:
- Strong correlation with actual poverty measures
- Better cross-state comparability than FRPL

### Face Validity

MEPS estimates are consistent with expected patterns:
- Higher in urban core and rural areas
- Lower in suburban areas
- Correlates with neighborhood characteristics

## Standard Errors (`meps_se`)

### Interpretation

The standard error (`meps_se`) quantifies estimation uncertainty:
- **68% confidence interval**: meps ± 1 × meps_se
- **95% confidence interval**: meps ± 1.96 × meps_se

### Factors Affecting Standard Errors

Standard errors tend to be larger for:
- Smaller schools (less data for estimation)
- Schools in districts with unusual characteristics
- Schools with missing predictor variables

### Using Standard Errors in Research

```python
import polars as pl

# Identify schools where estimates are precise (SE < 2 percentage points)
precise_schools = df.filter(pl.col("meps_poverty_se") < 2.0)

# Flag close comparisons between two schools
def compare_schools(pct_a: float, se_a: float, pct_b: float, se_b: float) -> str:
    diff = abs(pct_a - pct_b)
    se_combined = (se_a**2 + se_b**2)**0.5
    if diff < 1.96 * se_combined:
        return "Not statistically different"
    return "Statistically different"
```

## MEPS 2.0 Updates

### Key Improvements in MEPS 2.0 (December 2025)

> **Portal Status (Feb 2026):** MEPS 2.0 has not yet been integrated into the Education Data Portal mirrors. Portal data still reflects MEPS 1.0 (2009-2022). The improvements below apply to the Urban Institute's direct release, not yet to mirror-accessible data.

1. **Extended time coverage**: Additional years of data
2. **ISP integration**: Incorporates Identified Student Percentage data
3. **Improved CEP handling**: Better accounts for universal meal schools
4. **Updated calibration**: Uses more recent SAIPE data

### ISP (Identified Student Percentage)

MEPS 2.0 uses ISP data, which identifies students directly certified for free meals through:
- SNAP (food stamps)
- TANF (cash assistance)
- Medicaid (in some states)
- Foster care, homeless, migrant, runaway status

ISP provides a more direct poverty signal than FRPL application forms.

## Technical Notes

### Sample Restrictions

MEPS estimates are generated for:
- **Public schools only** (no private schools)
- **Regular schools** (excludes special education-only, alternative schools vary)
- **Schools with enrollment data** in CCD

### Missing Data Handling

- Schools missing key predictors may have imputed values
- Standard errors account for imputation uncertainty
- Flagged variables indicate imputation status

### Replication

The MEPS methodology is documented in:
- Gutierrez, Blagg, & Chingos (2022). "Model Estimates of Poverty in Schools." Urban Institute.
- Gutierrez & Blagg (2025). "Model Estimates of Poverty in Schools 2.0." Urban Institute.

## Methodological Limitations

1. **Model assumptions**: Linear model may not capture all relationships
2. **Data quality**: Depends on accuracy of CCD and SAIPE inputs
3. **Temporal stability**: Model coefficients assumed stable over time
4. **Private schools**: Not covered by MEPS
5. **Within-district variation**: Model captures some but not all variation

## Summary

MEPS provides a **rigorous, validated, and comparable** school-level poverty measure by:
- Using a statistical model calibrated to Census data
- Accounting for FRPL inconsistencies across states and time
- Providing uncertainty estimates via standard errors
- Offering modified estimates for high-poverty contexts

For most research purposes, MEPS provides a superior measure of school poverty compared to raw FRPL data, especially for cross-state comparisons or analyses spanning the CEP era (2010+).

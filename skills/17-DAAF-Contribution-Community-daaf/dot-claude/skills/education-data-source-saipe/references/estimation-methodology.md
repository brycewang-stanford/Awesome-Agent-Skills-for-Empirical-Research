# SAIPE Estimation Methodology

How the Census Bureau creates state and county poverty estimates using model-based small area estimation.

## Overview of Approach

SAIPE uses a **two-stage hierarchical estimation** process:

1. **State estimates**: Model poverty rates, multiply by population estimates
2. **County estimates**: Model number in poverty directly, constrained to state totals
3. **School district estimates**: Allocate county totals using within-county shares (see `school-district-estimates.md`)

The approach combines:
- Direct survey estimates from the American Community Survey (ACS)
- Administrative records (IRS tax data, SNAP participation, SSI)
- Statistical modeling (regression + shrinkage)

## Why Model-Based Estimation?

Direct ACS estimates are available only for areas with population > 65,000 (about 26% of counties, 85% of U.S. population). For smaller areas:

- ACS sample sizes are too small for reliable direct estimates
- Year-to-year volatility would be extreme
- Many districts/counties would have zero sampled households

Model-based estimation "borrows strength" from administrative data to produce estimates for all areas with:
- Greater precision than surveys alone
- Reduced year-to-year volatility
- Full coverage of all geographies

## Data Inputs

### Survey Data (Dependent Variable)

| Source | Time Period | Role |
|--------|-------------|------|
| ACS 1-year | 2005-present | Dependent variable for state/county models |
| CPS ASEC | Pre-2005 | Former dependent variable (replaced by ACS) |

### Administrative Records (Independent Variables)

| Source | Data Used | Why It Helps |
|--------|-----------|--------------|
| **IRS Tax Returns** | Exemptions by income level, adjusted gross income | Strong predictor of poverty via "tax-poor" indicator |
| **SNAP Benefits** | Participant counts by county | Direct poverty indicator; high correlation |
| **SSI Recipients** | Supplemental Security Income counts | Indicator of disabled/elderly poverty |
| **BEA Personal Income** | Aggregate income by county | Economic context indicator |

### Population Controls

| Source | Data Used |
|--------|-----------|
| Decennial Census | Base population, poverty universe benchmarks |
| Population Estimates Program | Annual postcensal population by age |
| ACS 5-year | School district population and poverty shares |

## State-Level Estimation

### Model Structure

States use a **ratio model** for poverty rates:

1. Estimate poverty **rates** (not counts) using regression
2. Multiply rates by population estimates to get counts
3. Control state totals to sum to national ACS estimate

### State Model Predictors

| Variable | Description |
|----------|-------------|
| Prior year ACS poverty rate | Survey-based poverty estimate |
| Tax-based poverty rate | IRS returns below poverty threshold |
| SNAP participation rate | Food assistance recipients / population |
| Residual from prior year | Model error term for shrinkage |

### State Estimates Produced

- Total population in poverty
- Children under age 5 in poverty (states only)
- Related children ages 5-17 in families in poverty
- Children under age 18 in poverty
- Median household income

## County-Level Estimation

### Model Structure

Counties use a **counts model** (not rates):

1. Model number of people in poverty directly
2. Combine model prediction with direct ACS estimate using shrinkage
3. Rake (ratio-adjust) county totals to controlled state estimates

### Why Counts Instead of Rates?

The Census Bureau does not model poverty rates for counties because:
- Population estimates for small counties have uncertain quality
- Rate models would compound population and poverty uncertainty
- Counts models provide better precision for allocation purposes

### County Model Form

The county model relates ACS poverty counts to administrative predictors:

```
ACS_poverty = f(tax_poor, SNAP, SSI, BEA_income, prior_census) + error
```

Key features:
- Single-year county observations from ACS
- Administrative records as predictors
- Log transformation for stability
- County and year effects

### Shrinkage Estimation

The final county estimate is a **weighted combination**:

```
Final estimate = w * (Model prediction) + (1-w) * (Direct ACS estimate)
```

Where the weight `w` depends on:
- Sampling variance of direct ACS estimate
- Model "lack of fit" variance

**Shrinkage logic**:
- If ACS estimate is precise (large county) → weight direct estimate more
- If ACS estimate is imprecise (small county) → weight model prediction more

This automatically calibrates uncertainty:
- Large counties: ~15-20% weight on model
- Small counties: ~80-95% weight on model

### Raking to Controls

After shrinkage estimation:
1. County poverty counts are ratio-adjusted (raked) to sum to state totals
2. State totals are already controlled to national ACS estimate
3. This ensures arithmetic consistency: districts → counties → states → national

## Model Fitting Process

### Annual Production Timeline

| Month | Activity |
|-------|----------|
| August | ACS 1-year estimates released |
| September-October | Administrative data processing |
| October-November | Model fitting and estimation |
| November | Quality review and disclosure |
| December | Public release |

### Quality Checks

1. **Internal consistency**: Districts sum to counties sum to states
2. **Temporal stability**: Large year-to-year changes flagged for review
3. **Outlier detection**: Extreme values investigated
4. **Disclosure review**: Confidentiality protection applied

## Technical Details

### ACS Data Usage

For 2005+ estimates, ACS provides:
- Published estimates for counties > 65,000 population
- Unpublished estimates for smaller counties (used in modeling)
- Both published and unpublished used as dependent variable

### Tax-Based Poverty Indicator

"Tax-poor" exemptions defined as:
- Child exemptions on returns where AGI < poverty threshold
- Poverty threshold based on family size implied by exemptions
- Does not include age of children (adjusted statistically)

### SNAP as Predictor

SNAP (Supplemental Nutrition Assistance Program) participation:
- Strong poverty correlation (income-tested program)
- Available at county level annually
- Captures poverty dynamics between census years

### Model Variance Estimation

Standard errors account for:
- Sampling variance of ACS estimates
- Model uncertainty (regression coefficient variance)
- Prediction variance (lack of fit)

Combined using Bayesian framework to produce confidence intervals.

## Comparison to Direct Survey Estimation

| Aspect | Direct ACS Estimate | SAIPE Model Estimate |
|--------|---------------------|----------------------|
| Data source | Survey responses only | Survey + administrative records |
| Precision | Limited by sample size | "Borrows strength" from admin data |
| Coverage | >65,000 pop only (1-year) | All counties/districts |
| Volatility | High year-to-year variation | Smoothed, more stable |
| Bias potential | Unbiased if well-designed | Model misspecification possible |

## Implications for Users

### Strengths

- Annual estimates for all geographies
- More precise than direct surveys for small areas
- Consistent with state and national totals
- Uses best available administrative data

### Limitations

- Model-based, not direct observation
- Assumes model correctly captures poverty patterns
- Administrative data has own measurement issues
- Cannot capture phenomena not in predictors

### Best Practices

1. **Always use confidence intervals** when available
2. **Check coefficient of variation** for small areas
3. **Understand this is an estimate**, not a census count
4. **Review methodology changes** before time series analysis

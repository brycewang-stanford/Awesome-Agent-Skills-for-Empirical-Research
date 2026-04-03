# SAIPE Data Quality and Limitations

Understanding estimation uncertainty, error sources, and appropriate use of SAIPE estimates.

## Fundamental Principle

**All SAIPE estimates contain error.** There has never been a complete census of income and poverty for all school districts. The methodology minimizes but cannot eliminate uncertainty.

## Types of Error

### Sampling Error

Survey-based components (ACS) introduce sampling variability:
- Larger areas have larger samples → lower sampling error
- Smaller areas may have few or no sampled households
- ACS 5-year reduces but doesn't eliminate sampling error

### Model Error

The regression models may not perfectly capture poverty patterns:
- Omitted variables (factors not in the model)
- Misspecified functional form
- Parameter estimation uncertainty
- Heterogeneous relationships across areas

### Measurement Error

Input data may not perfectly measure intended concepts:
- Tax-poor ≠ official poverty definition
- AGI includes income not counted in poverty
- SNAP participation varies by state policy
- Address geocoding failures

### Administrative Data Limitations

| Data Source | Limitation |
|-------------|------------|
| IRS Tax | Non-filers not captured; child ages unknown |
| SNAP | Participation rates vary; excludes some poor |
| SSI | Only captures specific populations |
| ACS | Sample coverage; response bias; processing error |

## State and County Confidence Intervals

### Interpretation

SAIPE publishes 90% confidence intervals for state and county estimates:

```
If: Estimate = 5,000
    Lower bound = 4,200
    Upper bound = 5,800

Then: We are 90% confident the true value is between 4,200 and 5,800
```

### Components of Uncertainty

Confidence intervals reflect:
1. ACS sampling variance
2. Model prediction variance
3. Shrinkage adjustment variance

### Interval Width Patterns

| Factor | Effect on CI Width |
|--------|-------------------|
| Larger population | Narrower |
| More ACS sample | Narrower |
| More tax returns geocoded | Narrower |
| More SNAP participation | Narrower (better signal) |
| Higher poverty rate | Wider (more uncertainty) |

## School District Error Estimates

### Why No Published Confidence Intervals

School district estimates do not have published confidence intervals because:
1. Share allocation doesn't produce standard errors directly
2. Multiple error sources are difficult to combine analytically
3. Evaluation studies provide alternative guidance

### Coefficient of Variation (CV)

CV = Standard Error / Estimate

Interpretation: A CV of 0.30 means the standard error is 30% of the estimate.

### CV by District Size

From Census Bureau evaluation studies:

| Population | Median CV | 90% CI Width Factor |
|------------|-----------|---------------------|
| 0-2,500 | 0.67 | 1.10 (110%) |
| 2,500-5,000 | 0.42 | 0.69 (69%) |
| 5,000-10,000 | 0.35 | 0.58 (58%) |
| 10,000-20,000 | 0.28 | 0.46 (46%) |
| 20,000-65,000 | 0.23 | 0.38 (38%) |
| 65,000+ | 0.15 | 0.25 (25%) |

**Calculating approximate CI**: 90% CI ≈ Estimate +/- (Estimate * CV * 1.645)

### Example Calculation

District with 4,000 population, 600 estimated children in poverty:
- CV ≈ 0.42 (from table)
- Standard error ≈ 600 * 0.42 = 252
- 90% CI ≈ 600 +/- (252 * 1.645) = 600 +/- 415
- Range: approximately 185 to 1,015

**Key insight**: For small districts, the uncertainty range can be very wide.

## Sources of School District Error

### Error Component Analysis

| Source | Description | Controllable? |
|--------|-------------|---------------|
| County estimate error | Inherited from parent county | No |
| ACS 5-year sampling | Sample variance in poverty shares | Somewhat |
| Tax geocoding rate | Non-geocoded returns allocated | Varies by area |
| Tax-poverty correlation | Tax-poor ≠ official poverty | No |
| Age allocation | Age→grade mapping imperfect | Minor |
| Boundary changes | Recent changes not yet in data | Timing dependent |

### Geocoding Rate Impact

Tax return geocoding varies by:
- Rural vs urban (rural often lower)
- State administrative practices
- Address completeness

Low geocoding rate → more reliance on ACS shares → older baseline data.

## Known Limitations

### What SAIPE Cannot Measure

| Limitation | Reason | Alternative |
|------------|--------|-------------|
| Poverty by race/ethnicity | Not estimated for districts | ACS 5-year |
| Poverty by gender | Not estimated for districts | ACS 5-year |
| Deep poverty (<50% threshold) | Not estimated | ACS |
| Near-poverty (100-150% threshold) | Not estimated | ACS |
| Enrollment-based poverty | Uses residential population | FRPL data |

### Temporal Limitations

| Limitation | Impact |
|------------|--------|
| 18-month lag | Data not current |
| Boundary updates | May not reflect recent changes |
| Economic shocks | Slow to reflect rapid changes |
| Year-to-year volatility | Single years may mislead |

### Geographic Limitations

| Limitation | Impact |
|------------|--------|
| No school-level estimates | District aggregates only |
| No sub-district geography | Cannot identify pockets of poverty |
| Boundary definition issues | School catchment ≠ district boundaries |
| Multi-county districts | Additional allocation uncertainty |

## Comparing Estimates

### Can I Compare Two Districts?

**Yes, with caution:**
1. Consider both CVs - overlap of uncertainty ranges
2. Similar-sized districts have similar error magnitudes
3. Very different sizes require careful interpretation

### Can I Compare Years?

**With significant caution:**
1. Methodology breaks make some comparisons invalid
2. Pre-2005 vs post-2005 not directly comparable
3. Pre-2010 vs post-2010 school districts not comparable
4. Even comparable years have correlated errors

See `historical-changes.md` for safe comparison guidance.

### Can I Compare SAIPE to ACS?

**Generally no:**
- Different methodologies
- Positively correlated (ACS is input to SAIPE)
- Standard difference tests don't apply

### Can I Compare SAIPE to FRPL?

**No - different constructs:**
- Different income thresholds
- Different populations (enrolled vs residential)
- Different definitions (eligibility vs poverty status)

See `comparison-other-sources.md` for details.

## Data Quality Indicators

### Signs of Potential Issues

| Indicator | Concern |
|-----------|---------|
| Zero poverty estimate | Possible but rare; may indicate data issue |
| Very high poverty rate (>50%) | Verify against other sources |
| Large year-to-year change | May be real; may be estimation artifact |
| Inconsistent with neighboring districts | Check for boundary or data issues |

### Validation Approaches

1. **Compare to ACS 5-year**: General alignment expected
2. **Compare to FRPL**: Direction should match (higher FRPL → higher SAIPE)
3. **Check county context**: District shouldn't dramatically differ from county
4. **Review trend**: Sudden changes warrant investigation

## Best Practices for Users

### Reporting

1. **Always report uncertainty** - use confidence intervals or note CV
2. **Avoid false precision** - round appropriately
3. **Acknowledge limitations** - estimates, not counts
4. **Contextualize** - compare similar-sized areas

### Analysis

1. **Group small districts** when analyzing patterns
2. **Use categories, not ranks** for small areas
3. **Consider alternative sources** for specific questions
4. **Document methodology changes** affecting your time period

### Interpretation

1. **"High poverty" classification** - consider uncertainty range
2. **Trend analysis** - methodology breaks may explain changes
3. **Outlier investigation** - may be real or artifact
4. **Policy implications** - uncertainty affects funding precision

## Census Bureau Quality Standards

SAIPE undergoes:
- Internal statistical review
- External academic evaluation (National Academy of Sciences)
- Annual methodology assessment
- Disclosure avoidance review

The Census Bureau considers SAIPE the best available source for annual small area poverty estimates, while acknowledging inherent limitations of model-based estimation.

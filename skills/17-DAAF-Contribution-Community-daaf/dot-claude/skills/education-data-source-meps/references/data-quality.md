# MEPS Data Quality and Appropriate Uses

Understanding the limitations, uncertainty, and appropriate applications of Model Estimates of Poverty in Schools.

> **Portal Encoding Note:** MEPS data uses **native nulls** for missing values, not the coded values (-1, -2, -3) used by CCD and other sources. Always use null checks rather than negative value filtering.

## Key Data Quality Considerations

### MEPS is a Modeled Estimate

MEPS values are **statistical estimates**, not direct counts:

- Generated from a linear probability model
- Subject to estimation error
- Standard errors quantify uncertainty
- Individual school estimates less reliable than aggregates

**Implication**: Use standard errors for statistical inference; don't treat point estimates as ground truth.

### Estimation Uncertainty (`meps_poverty_se`)

The standard error indicates reliability. Portal values are on a **percentage scale** (matching `meps_poverty_pct`):

| `meps_poverty_se` Range | Interpretation | Typical Context |
|-------------------------|----------------|-----------------|
| < 1.0 | Very reliable | Large schools, abundant data |
| 1.0 - 2.0 | Reliable | Typical schools |
| 2.0 - 3.0 | Moderate uncertainty | Smaller schools, unusual characteristics |
| > 3.0 | High uncertainty | Small schools, missing predictors |

> **Actual observed range:** 0.52 - 3.77 (percentage points). This is on the same scale as `meps_poverty_pct`.

**Using standard errors:**
```python
import polars as pl

# 95% confidence interval
df = df.with_columns([
    (pl.col("meps_poverty_pct") - 1.96 * pl.col("meps_poverty_se")).alias("ci_lower"),
    (pl.col("meps_poverty_pct") + 1.96 * pl.col("meps_poverty_se")).alias("ci_upper"),
    (pl.col("meps_poverty_se") < 2.0).alias("reliable"),
])
```

## Known Limitations

### 1. Public Schools Only

MEPS covers **only public schools**:
- No private schools
- No religious schools
- No home schools
- Limited alternative school coverage

**Impact**: Cannot compare public vs private school poverty; national totals exclude private sector.

### 2. Time Coverage

| Version | Years Available | Notes |
|---------|-----------------|-------|
| MEPS 1.0 | 2006-2019 | Original release |
| MEPS 2.0 | Extended range | December 2025 release |

> **Portal Status (Feb 2026):** MEPS 2.0 has not yet been integrated into the Education Data Portal mirrors. Portal data still reflects MEPS 1.0 (2009-2022). Check `datasets-reference.md` for current availability.

**Impact**: Cannot analyze poverty before 2006 or after available years with MEPS.

### 3. Data Lag

MEPS depends on CCD and SAIPE data, both of which have lag:
- CCD: ~1-2 years behind current year
- SAIPE: Released December for prior year
- MEPS: Additional processing time

**Impact**: Most recent year available is typically 2-3 years behind current date.

### 4. 100% FPL Only

MEPS measures **only students at or below 100% FPL**:
- Does not capture near-poverty (100-185% FPL)
- Lower threshold than FRPL
- Some economically disadvantaged students not counted

**Impact**: MEPS will show lower poverty rates than FRPL even when FRPL is reliable.

### 5. Model Assumptions

The linear probability model assumes:
- Relationships are approximately linear
- Coefficients are stable across schools and time
- Available predictors capture relevant variation

**Impact**: Estimates may be biased for schools with unusual characteristics not captured by the model.

### 6. High-Poverty District Bias

The original MEPS model **underestimates** poverty in very high-poverty districts:
- Use `meps_mod_poverty_pct` for analyses focused on high-poverty contexts
- Original `meps_poverty_pct` may undercount in districts >30% poverty

### 7. Small School Uncertainty

Smaller schools have larger estimation errors:
- Less information for the model
- Higher standard errors
- Consider combining small schools for analysis

## Appropriate Uses

### Strongly Appropriate

| Use Case | Why Appropriate |
|----------|-----------------|
| Cross-state poverty comparison | MEPS designed specifically for this |
| Time trends (2006-2019) | Consistent methodology |
| Poverty-achievement gap analysis | Better control than FRPL |
| Identifying high-poverty schools | More accurate than FRPL in CEP era |
| Research on school resources and poverty | Consistent measure |
| District-level aggregation | Calibrated to SAIPE |

### Appropriate with Caveats

| Use Case | Caveats |
|----------|---------|
| Individual school analysis | Use standard errors; acknowledge uncertainty |
| Small school analysis | High uncertainty; consider aggregation |
| Very high-poverty districts | Consider `meps_mod_poverty_pct` instead |
| Year-over-year changes for single school | Changes may be within uncertainty |
| Near-poverty analysis | MEPS only captures 100% FPL |

### Not Appropriate

| Use Case | Why Not | Alternative |
|----------|---------|-------------|
| Private school poverty | Not covered | Use other measures |
| Before 2006 | No data | Use FRPL (with caveats) |
| Real-time monitoring | Data lag | Use local data |
| 185% FPL threshold | Different threshold | Use FRPL (with CEP adjustment) |
| Meal program planning | Wrong measure | Use FRPL/ISP |
| Compliance with FRPL-based formulas | May not satisfy requirements | Use FRPL |

## Statistical Considerations

### Comparing Schools

When comparing poverty between schools:

```python
def statistically_different(pct_a: float, se_a: float, pct_b: float, se_b: float, alpha: float = 0.05) -> bool:
    """Test if two schools have significantly different poverty rates.

    Args:
        pct_a: meps_poverty_pct for school A
        se_a: meps_poverty_se for school A
        pct_b: meps_poverty_pct for school B
        se_b: meps_poverty_se for school B
        alpha: significance level (0.05 or 0.01)
    """
    diff = pct_a - pct_b
    se_diff = (se_a**2 + se_b**2)**0.5
    z_score = abs(diff) / se_diff
    z_critical = 1.96 if alpha == 0.05 else 2.58
    return z_score > z_critical
```

### Aggregating to Higher Levels

For district or state aggregation, use enrollment-weighted averages (requires joining with CCD enrollment data first):

```python
import polars as pl

# Enrollment-weighted aggregation with proper SE propagation
district_agg = (
    df.filter(
        pl.col("meps_poverty_pct").is_not_null()
        & pl.col("enrollment").is_not_null()
    )
    .group_by("leaid")
    .agg(
        ((pl.col("meps_poverty_pct") * pl.col("enrollment")).sum()
         / pl.col("enrollment").sum()).alias("meps_weighted"),
        pl.col("enrollment").sum().alias("total_enrollment"),
        # SE of weighted average (approximate)
        ((pl.col("meps_poverty_se").pow(2) * pl.col("enrollment").pow(2)).sum().sqrt()
         / pl.col("enrollment").sum()).alias("meps_se_agg"),
    )
)
```

### Regression with MEPS

When using MEPS as a control variable, note that `meps_poverty_pct` is a modeled estimate with known standard error (`meps_poverty_se`). Consider:
- **Simple approach:** Use `meps_poverty_pct` directly as a regressor (ignores measurement error)
- **Better approach:** Use errors-in-variables regression or sensitivity analysis varying MEPS within its confidence interval

## Data Validation Checks

### Before Using MEPS Data

> **Note:** MEPS uses native nulls, not negative coded values. Adjust validation accordingly.

1. **Check for missing values (MEPS uses nulls, not negative codes)**
```python
import polars as pl

null_pct = df["meps_poverty_pct"].null_count() / len(df)
print(f"Missing: {null_pct:.1%}")
```

2. **Verify reasonable ranges**
```python
valid = df.filter(pl.col("meps_poverty_pct").is_not_null())
assert valid["meps_poverty_pct"].min() >= 0, "Negative poverty values"
assert valid["meps_poverty_pct"].max() <= 100, "MEPS out of range"
assert valid["meps_poverty_se"].min() >= 0, "Negative SE values"
```

3. **Check coverage**
```python
print(f"Schools covered: {df['ncessch'].n_unique():,}")
print(f"States covered: {df['fips'].n_unique()}")
print(f"Years covered: {df['year'].unique().sort().to_list()}")
```

4. **Assess reliability distribution**
```python
print(df["meps_poverty_se"].describe())
reliable_pct = df.filter(pl.col("meps_poverty_se") < 2.0).height / len(df)
print(f"Reliable estimates (SE<2.0): {reliable_pct:.1%}")
```

## Reporting Recommendations

### In Research Papers

Always report:
1. MEPS version used
2. Years included
3. Sample restrictions applied
4. How standard errors were used
5. Acknowledgment that MEPS measures 100% FPL (not 185%)

Example text:
> "We measure school-level poverty using the Urban Institute's Model Estimates of Poverty in Schools (MEPS), which estimates the share of students from households with incomes at or below 100 percent of the federal poverty level. MEPS provides a consistent poverty measure across states and time, unlike FRPL data which is affected by policy variation and Community Eligibility Provision adoption (Gutierrez, Blagg, & Chingos, 2022)."

### In Policy Reports

Clarify:
1. Difference between MEPS and FRPL
2. Why MEPS is more comparable
3. Limitation that it measures 100% FPL
4. Data availability and recency

## Common Pitfalls

### 1. Ignoring Standard Errors

**Problem**: Treating MEPS point estimates as exact values
**Solution**: Always consider `meps_poverty_se` in comparisons and conclusions

### 2. Conflating with FRPL

**Problem**: Assuming MEPS and FRPL are interchangeable
**Solution**: Clearly distinguish; note different thresholds and methodologies

### 3. Single-School Conclusions

**Problem**: Making strong claims about individual schools
**Solution**: Use aggregations or acknowledge uncertainty

### 4. Outdated Data

**Problem**: Using MEPS for current policy without noting data lag
**Solution**: State the years covered; note lag

### 5. Ignoring Modified MEPS

**Problem**: Using original MEPS for high-poverty analysis
**Solution**: Use `meps_mod_poverty_pct` when focusing on high-poverty districts

## Quality Assurance Checklist

Before publishing analysis using MEPS:

- [ ] Documented MEPS version and years used
- [ ] Excluded or flagged missing/suppressed values
- [ ] Considered standard errors in key findings
- [ ] Noted 100% FPL threshold (different from FRPL)
- [ ] Acknowledged limitations in discussion
- [ ] Used appropriate aggregation methods
- [ ] Cited Urban Institute methodology report

## Summary

MEPS is a **high-quality, research-grade** poverty measure when used appropriately:

| Strength | Limitation |
|----------|------------|
| Cross-state comparable | Model-based (not direct counts) |
| Time-consistent | 2-3 year data lag |
| Calibrated to Census | 100% FPL only (not 185%) |
| Accounts for CEP | Public schools only |
| Standard errors provided | Some uncertainty for small schools |

**Bottom line**: MEPS is the best available school-level poverty measure for research requiring cross-state or temporal comparability. Use standard errors, acknowledge limitations, and choose appropriate use cases.

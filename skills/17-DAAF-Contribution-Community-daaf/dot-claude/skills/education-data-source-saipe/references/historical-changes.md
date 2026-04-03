# SAIPE Historical and Methodology Changes

Understanding methodology changes over time and their implications for longitudinal analysis.

## Major Methodology Breaks

### Overview of Key Dates

| Year | Change | Impact |
|------|--------|--------|
| 2005 | ACS replaces CPS ASEC | Major break in state/county series |
| 2006 | ACS adds group quarters | Minor comparability issue |
| 2010 | Decennial 2010 benchmark; ACS 5-year for districts | Major break in school district series |
| 2019 | Annual SDRP boundary updates begin | Minor improvement |

## 2005: ACS Integration

### What Changed

Before 2005:
- State/county models used CPS ASEC (Annual Social and Economic Supplement)
- CPS sample size: ~100,000 households nationally
- Limited geographic detail

After 2005:
- Models switched to ACS 1-year estimates
- ACS sample size: ~3,000,000 addresses nationally
- Much larger samples for most areas

### Why the Change

1. ACS became official basis for state poverty estimates
2. Larger sample sizes improve model precision
3. Better geographic coverage

### Implications for Users

**DO NOT compare 2004 and earlier to 2005 and later for states/counties.**

The change affects:
- Estimate precision (generally improved after 2005)
- Potential level shifts in some areas
- Standard error estimation methods

### Documentation

See: "2005 Estimation Procedure Changes" on Census SAIPE website

## 2006: Group Quarters Integration

### What Changed

ACS 2006 added group quarters (GQ) populations:
- College dormitories
- Military barracks
- Nursing homes
- Correctional facilities

Previously ACS covered only household population.

### Impact on Poverty Estimates

Group quarters residents generally have:
- Higher poverty rates (students, institutionalized)
- Different age distribution

This affected certain age groups:
- Ages 18-24 (college students)
- Ages 65+ (nursing home residents)

### Implications for Users

Minor comparability issue for:
- All-ages poverty estimates
- Age-specific poverty rates

Less impact on children 5-17 (fewer in group quarters).

## 2010: Decennial Update and ACS 5-Year

### What Changed

**State and County:**
- Population controls updated from 2000 Census to 2010 Census
- All denominators rebased to 2010 population

**School Districts (Major Change):**
- Census 2000 long-form sample replaced by ACS 5-year (2006-2010)
- New baseline for within-county poverty shares
- Updated school district boundaries from 2009-2010 SDRP

### Why This Matters

For school districts specifically:
1. Share estimates now based on much more recent data
2. Boundary definitions updated
3. Population distributions updated

### Implications for Users

**School district estimates from 2010 onward are NOT comparable to 2009 and earlier.**

- Different baseline years
- Different boundaries
- Different population denominators

**Safe school district comparisons:** 2010-present only (with caution for methodology tweaks)

### Documentation

See: "2010 Estimation Procedure Changes" on Census SAIPE website

## Annual Boundary Updates (2019+)

### What Changed

Before 2019:
- School District Review Program (SDRP) updated boundaries biennially
- Boundary updates could lag by 2+ years

After 2019:
- Annual SDRP updates
- More current boundaries in each release

### Implications for Users

Generally improves data quality. May create minor year-to-year changes when:
- Districts consolidate or split
- Boundaries are corrected
- New districts are created

## County Boundary Changes

### Significant Recent Changes

2022 estimates incorporated:
- Connecticut county equivalent changes
- Chugach Census Area split (Alaska)
- Copper River Census Area split (Alaska)

### How to Handle

When counties change:
- Historical data may not be directly comparable
- Sum of new counties may approximate old county
- Check SAIPE documentation for specific guidance

## Standard Error Methodology Change

### 2008-2009 Modification

Between 2008 and 2009, the method for calculating standard errors was modified:
- More accurate variance estimation
- May cause apparent changes in confidence intervals
- Does not affect point estimates

## Safe Comparison Periods

### State and County Estimates

| Period | Comparable Within? | Notes |
|--------|-------------------|-------|
| 1995-2004 | Yes, with caution | CPS-based methodology |
| 2005-2009 | Yes | ACS-based, pre-2010 Census |
| 2006-2009 | Better | GQ included throughout |
| 2010-present | Yes | Current methodology |

**DO NOT compare across 2004/2005 or 2009/2010 boundaries.**

### School District Estimates

| Period | Comparable Within? | Notes |
|--------|-------------------|-------|
| 1999-2009 | With caution | Census 2000 baseline |
| 2010-present | Yes | ACS 5-year baseline |

**DO NOT compare school districts across 2009/2010 boundary.**

## Making Year-to-Year Comparisons

### For States and Counties (2010+)

SAIPE provides guidance on statistically valid comparisons:

1. Must account for correlation between years
2. Standard error of difference ≠ simple combination
3. SAIPE publishes some state-level change significance tests

### Methodology for Change Testing

For state-level changes:
```
Significant change if: |Y2 - Y1| / SE(Y2-Y1) > critical value
```

Where SE(Y2-Y1) accounts for:
- Variance of each estimate
- Covariance between years (from shared model)

### For School Districts

**No official methodology exists for comparing school district estimates across years.**

Reasons:
- Share allocation doesn't produce standard errors
- Complex error structure
- Correlation structure unknown

**Practical guidance:**
- Large changes in large districts may be meaningful
- Small changes in small districts are likely noise
- Use with extreme caution

## Data Series Availability

### School Districts

| Years | Available | Notes |
|-------|-----------|-------|
| 1989, 1993 | Limited | Early estimates |
| 1995 | Yes | Regular series begins |
| 1997-present | Annual | Continuous annual series |
| 1999-present | Via Education Data Portal | Mirror data (parquet/CSV) |

### Counties

| Years | Available | Notes |
|-------|-----------|-------|
| 1989, 1993, 1995 | Yes | Early estimates |
| 1997-present | Annual | Even years added 1998 |
| 1996 | No county estimates | Gap year |

### States

| Years | Available |
|-------|-----------|
| 1989, 1993 | Yes |
| 1995-present | Annual |

## Accessing Historical Documentation

Census Bureau maintains methodology documentation for each year:
- Technical documentation by year
- Estimation procedure changes
- Working papers on methodology development

Access via: census.gov/programs-surveys/saipe/technical-documentation/methodology.html

## Best Practices for Longitudinal Analysis

### 1. Define Comparable Periods

Choose time periods within safe comparison windows:
- States/counties: 2010-present preferred
- School districts: 2010-present only

### 2. Document Methodology Context

Note in any analysis:
- Which SAIPE vintage
- Known methodology changes
- Boundary changes in study area

### 3. Use Appropriate Statistical Methods

- Account for estimation error in both time points
- Consider correlation between years
- Use Census-provided significance tests where available

### 4. Interpret with Caution

- Real economic changes vs methodology artifacts
- Boundary changes affecting populations
- Sample/administrative data changes

### 5. Consider Alternative Approaches

For trend analysis:
- ACS multi-year averages (more stable, but slower signal)
- Administrative data (SNAP, Medicaid) for direction
- Mixed approach validating multiple sources

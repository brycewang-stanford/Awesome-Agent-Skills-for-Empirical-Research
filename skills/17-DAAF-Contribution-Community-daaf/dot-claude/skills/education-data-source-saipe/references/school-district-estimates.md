# School District Estimates

How SAIPE produces poverty estimates for 13,000+ school districts using within-county share allocation.

## Overview

School district estimates use a fundamentally **different approach** than state/county estimates:

- State/county: Model-based regression with shrinkage
- School districts: **Share allocation** from county totals

This means school district estimates:
1. Depend entirely on county estimate quality
2. Add additional uncertainty from share estimation
3. Cannot be better than their parent county estimates

## Legal Mandate

The Every Student Succeeds Act (ESSA) requires:
- Department of Education to distribute Title I funds directly to districts
- Allocations based on Census Bureau poverty estimates
- SAIPE is the **only official source** for these allocations

This makes SAIPE school district estimates high-stakes data with real funding implications.

## Estimation Process

### Step 1: Define School District Pieces

School districts don't always align with county boundaries:
- Most districts are entirely within one county
- Some districts span multiple counties
- Some districts overlap geographically (elementary/secondary)

For estimation, districts are divided into **school district-county-pieces**:
- Piece = intersection of school district and county
- If district spans 2 counties, 2 separate pieces are estimated
- Pieces are recombined into district totals at the end

### Step 2: Compute Tax-Based Shares

Using IRS tax return data geocoded to school districts:

```
Tax share = (District piece child tax-poor) / (County child tax-poor)
```

Where "child tax-poor" means:
- Child exemptions on returns
- With adjusted gross income below poverty threshold
- For that geographic area

**Geocoding limitation**: Not all tax returns can be assigned to specific school districts within a county. Non-geocoded returns are allocated using the "Minimum Change" algorithm to minimize deviation from ACS-based shares.

### Step 3: Combine with ACS Shares

Tax shares are combined with ACS 5-year poverty shares:

```
Combined share = f(Tax share, ACS 5-year share, geocoding rate)
```

The relative weight depends on:
- **High geocoding rate** (most returns geocoded): Tax shares dominate
- **Low geocoding rate** (many returns not geocoded): ACS shares dominate

### Step 4: Apply Shares to County Estimates

```
District piece poverty = County poverty estimate * District share
```

This ensures district pieces sum exactly to county totals.

### Step 5: Rake to County Totals

Final adjustment using "controlled rounding":
1. Ensures pieces sum exactly to county estimate
2. Produces integer poverty counts
3. Maintains arithmetic consistency

### Step 6: Reassemble Districts

For districts spanning multiple counties:
```
District total = Sum of all district pieces
```

## Three Estimates Per District

SAIPE provides three estimates for each school district:

| Estimate | Description | Use Case |
|----------|-------------|----------|
| **Total population** | All residents in district boundaries | Small district provision (<20,000) |
| **Children ages 5-17** | School-age population | Denominator for poverty rate |
| **Related children 5-17 in poverty** | Children in poor families | Title I allocation numerator |

### Important Caveats

**Population is not enrollment**:
- SAIPE estimates residential population within district boundaries
- Includes children in private schools, homeschooled, not enrolled
- Excludes children who live outside but attend district schools

**"Related children"** excludes:
- Foster children
- Unrelated individuals in household
- Group quarters residents (institutions, dorms)

## Grade Relevance

### Handling Overlapping Districts

In some states, districts divide territory by grade level:
- "Elementary" districts (K-6 or K-8)
- "Secondary" districts (7-12 or 9-12)
- "Unified" districts (all grades)

SAIPE handles this through **grade assignment**:
1. Each child ages 5-17 is assigned a grade based on age (age 5 = K, age 6 = 1st, etc.)
2. Child is allocated to the district responsible for that grade
3. Only grades within district's range are counted

### States with Overlapping Districts

Overlapping district patterns exist in:
Arizona, California, Connecticut, Georgia, Illinois, Kentucky, Maine, Massachusetts, Montana, New Hampshire, New Jersey, New York, Oregon, Rhode Island, South Carolina, Tennessee, Texas, Vermont, Wisconsin

### States with Variable Grade Ranges

Some districts have different grade ranges in different parts of their territory:
California, Georgia, Illinois, Kentucky, Massachusetts, South Carolina, Tennessee, Texas

### Resolution Rules

When grade assignments are ambiguous:
1. If "unified" district exists → assign unclaimed grades there
2. If elementary + secondary overlap → assign to secondary
3. If elementary + secondary gap → assign to elementary

## Data Sources for School District Estimation

### ACS 5-Year Estimates

- Provide baseline poverty shares from sample data
- More stable than 1-year estimates
- Updated with each release cycle
- Currently using ACS 2006-2010 (updated for 2010+ SAIPE)

Previously used Census 2000 long-form sample (through 2009 SAIPE).

### IRS Tax Return Data

- Geocoded to school district level where possible
- "Tax-poor" indicator based on AGI vs poverty threshold
- Child exemptions (age not available on tax forms)
- Updated annually with ~1 year lag

### School District Boundaries

Updated through School District Review Program (SDRP):
- Annual boundary updates since 2019
- Biennial updates before 2019
- State education agency submissions
- Geographic validation

### Population Estimates

- Decennial Census base
- Postcensal estimates by age
- Applied to district geographies

## Sources of Uncertainty

School district estimates inherit uncertainty from multiple sources:

| Source | Description | Magnitude |
|--------|-------------|-----------|
| **County model error** | Uncertainty in parent county estimate | Varies by county size |
| **ACS sampling error** | Sample variance in 5-year shares | Higher for small districts |
| **Tax geocoding error** | Non-geocoded returns allocated | Higher in rural areas |
| **Tax-poverty correlation** | Tax-poor ≠ official poverty | Systematic bias possible |
| **Age allocation** | Child ages inferred, not known | Minor |
| **Boundary timing** | Districts may have changed | Usually minor |

### Why No Published Confidence Intervals?

Unlike state/county estimates, school district estimates do not have published confidence intervals because:
- Share allocation method doesn't produce standard errors directly
- Multiple uncertainty sources are difficult to combine
- Evaluation studies provide coefficient of variation estimates instead

## Coefficient of Variation by District Size

From Census Bureau evaluation studies:

| District Population | Median CV | Interpretation |
|---------------------|-----------|----------------|
| 0-2,500 | 0.67 | Very high uncertainty |
| 2,500-5,000 | 0.42 | High uncertainty |
| 5,000-10,000 | 0.35 | Moderate-high uncertainty |
| 10,000-20,000 | 0.28 | Moderate uncertainty |
| 20,000-65,000 | 0.23 | Moderate-low uncertainty |
| 65,000+ | 0.15 | Lower uncertainty |

**CV = standard error / estimate**

For 90% confidence interval: multiply CV by 1.645

Example: District with 3,000 population, estimated 500 children in poverty
- CV ≈ 0.42
- Standard error ≈ 210
- 90% CI ≈ 500 +/- 345 (155 to 845)

## Balance of County Areas

SAIPE produces estimates for:
- Named school districts in TIGER database
- "Balance of county" areas (territory not assigned to any district)

Balance areas:
- Not published on Census website
- Provided to Department of Education
- Available upon request
- May be single area or multiple disconnected pieces

## Implications for Users

### What SAIPE School District Estimates Are Good For

1. **Title I allocations** - official mandated source
2. **Cross-district comparisons** within similar size classes
3. **Identifying high-poverty districts** (with appropriate uncertainty)
4. **Annual monitoring** of district-level trends

### What They Are NOT Good For

1. **Precise poverty counts** - always estimates with uncertainty
2. **Very small districts** - CV often exceeds 50%
3. **Demographic breakdowns** - no race/ethnicity/gender detail
4. **School-level analysis** - district aggregates only
5. **Enrollment-based calculations** - population, not enrollment

### Best Practices

1. **Report ranges, not point estimates** for small districts
2. **Group similar-sized districts** when analyzing patterns
3. **Use ACS 5-year** for race/ethnicity breakdowns
4. **Understand the share allocation method** - district estimates cannot be better than county estimates
5. **Check SDRP timing** for recent boundary changes

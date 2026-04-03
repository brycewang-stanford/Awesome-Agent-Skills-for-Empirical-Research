# MEPS vs FRPL: Why MEPS is Superior for Cross-State Analysis

Detailed comparison of Model Estimates of Poverty in Schools (MEPS) and Free/Reduced-Price Lunch (FRPL) eligibility as school poverty measures.

## The FRPL Problem

### What is FRPL?

Free and Reduced-Price Lunch (FRPL) eligibility has traditionally been used to measure school poverty:
- **Free lunch**: Family income ≤130% FPL
- **Reduced-price lunch**: Family income 131-185% FPL
- **Combined FRPL**: Income ≤185% FPL

### Why FRPL Was Once Useful

Before 2010, FRPL was a reasonable poverty proxy because:
- Schools collected income verification forms from families
- Eligibility was relatively consistent across states
- The data was available at the school level
- It captured a meaningful economic threshold

### The Community Eligibility Provision (CEP) Problem

**CEP**, introduced in the Healthy, Hunger-Free Kids Act of 2010, allows schools to provide **free meals to ALL students** if they meet certain thresholds.

#### CEP Mechanics

1. Schools calculate their **Identified Student Percentage (ISP)** - students directly certified through SNAP, TANF, Medicaid, foster care, homeless, migrant status
2. If ISP ≥ 40%, the school can elect CEP
3. Under CEP, **100% of students** are reported as receiving free lunch
4. Schools no longer collect income forms

#### Impact on FRPL Data

| Metric | Pre-CEP | Post-CEP |
|--------|---------|----------|
| Data collection | Income forms from families | No forms collected |
| FRPL reported | Actual eligible students | ALL students (100%) |
| Poverty signal | Reasonable proxy | Completely inflated |

### CEP Adoption Rates

| Year | % of Schools in CEP |
|------|---------------------|
| 2014 | ~5% |
| 2016 | ~20% |
| 2018 | ~35% |
| 2020 | ~50% |
| 2022 | ~60% |

**Key insight**: As of 2022, approximately 60% of US public schools participate in CEP or similar universal meal programs, making FRPL data unreliable for the majority of schools.

## State-Level FRPL Variation

### Different States, Different Rules

Even before CEP, FRPL varied by state due to:

1. **Direct certification scope**
   - Some states auto-certify SNAP participants only
   - Others include TANF, Medicaid, foster care
   - Coverage varies significantly

2. **Form collection policies**
   - Some states require forms from all families
   - Others only collect from those seeking eligibility
   - Affects non-response rates

3. **Verification requirements**
   - Some states verify more applications
   - Affects who remains "eligible" after verification

4. **Categorical eligibility**
   - Some states have broader categorical eligibility
   - Certain populations auto-qualify regardless of income

### Example: California vs Texas

| Factor | California | Texas |
|--------|------------|-------|
| Direct certification programs | SNAP, TANF, Medicaid, foster, homeless | SNAP, TANF only |
| CEP adoption (2020) | 75% of eligible schools | 45% of eligible schools |
| FRPL rate (2020) | 62% | 60% |
| Actual poverty (SAIPE) | 16% | 17% |

The similar FRPL rates mask different underlying policies and actual poverty levels.

## Comparing FRPL and MEPS

### Fundamental Differences

| Dimension | FRPL | MEPS |
|-----------|------|------|
| **Source** | Administrative program data | Statistical model |
| **Poverty threshold** | 130-185% FPL | 100% FPL |
| **Consistency** | Varies by state/year | Standardized nationwide |
| **CEP impact** | Completely distorted | Accounts for CEP |
| **What it measures** | Program participation | Estimated true poverty |
| **Comparability** | Poor across states | Designed for comparison |

### Poverty Threshold Comparison

```
Federal Poverty Level (2024 for family of 4): ~$31,200

FRPL Free Lunch (130% FPL):     $40,560
FRPL Reduced Lunch (185% FPL):  $57,720
MEPS Threshold (100% FPL):      $31,200
```

**MEPS measures deeper poverty** - families at or below the official poverty line, not near-poverty.

### Correlation Between FRPL and MEPS

Pre-CEP (2010):
- Correlation: ~0.75-0.85
- FRPL was a reasonable proxy

Post-CEP (2020):
- Correlation: ~0.40-0.60 (declining)
- FRPL increasingly divorced from actual poverty

## When to Use Each Measure

### Use MEPS When:

1. **Comparing schools across different states**
   - MEPS is standardized; FRPL is not

2. **Analyzing trends over time (2010+)**
   - CEP adoption makes FRPL inconsistent over time

3. **Research requiring consistent poverty measurement**
   - MEPS provides comparability for statistical analysis

4. **Identifying high-poverty schools for targeting**
   - MEPS better identifies actual poverty concentration

5. **Controlling for socioeconomic status in regressions**
   - MEPS is a better control variable due to consistency

### Use FRPL When:

1. **Studying school meal program participation itself**
   - FRPL directly measures program participation

2. **Replicating historical studies using FRPL**
   - May need FRPL for comparability with prior research

3. **Federal formula compliance**
   - Some federal programs mandate FRPL-based calculations

4. **Understanding meal program operations**
   - FRPL data relevant for food service planning

### Use Both When:

1. **Studying CEP impact**
   - Compare MEPS (true poverty) vs FRPL (program measure)

2. **Examining state policy effects**
   - Differences reveal policy impacts

3. **Validating poverty measures**
   - Cross-validation between measures

## State-by-State FRPL Reliability

### States with Most Reliable FRPL (2020)

Higher reliability (lower CEP adoption, consistent policies):
- Utah
- Nebraska  
- Wyoming
- Idaho

### States with Least Reliable FRPL (2020)

Lower reliability (high CEP, varied policies):
- California
- New York
- Michigan
- Kentucky
- West Virginia

### Recommendation

Even in "reliable" states, **MEPS is preferred** for cross-state comparison because:
1. Consistent methodology nationwide
2. Calibrated to Census poverty data
3. Accounts for known FRPL biases

## The Direct Certification Problem

### What is Direct Certification?

Direct certification identifies students eligible for free meals based on participation in other programs:
- SNAP (Supplemental Nutrition Assistance Program)
- TANF (Temporary Assistance for Needy Families)
- Medicaid (in some states)
- Foster care
- Homeless status
- Migrant status

### Direct Certification Variation

| State | Programs Included | Coverage |
|-------|------------------|----------|
| California | SNAP, TANF, Medicaid, Foster, Homeless | Broad |
| Texas | SNAP, TANF | Narrow |
| New York | SNAP, TANF, Medicaid, Foster, Homeless, Migrant | Very Broad |
| Florida | SNAP, TANF | Narrow |

### Impact on FRPL Comparability

A school with 50% directly certified students means different things in different states:
- In California: May include Medicaid families (higher income threshold)
- In Texas: Only SNAP/TANF families (lower income threshold)

## Practical Guidance

### For Researchers

1. **Default to MEPS** for school poverty analysis
2. **Document your choice** and rationale
3. **Consider sensitivity analysis** using both measures
4. **Note the 100% vs 185% FPL threshold difference**

### For Policymakers

1. **Recognize FRPL limitations** in funding formulas
2. **Consider MEPS for resource allocation** decisions
3. **Understand CEP schools** are not necessarily 100% poor

### For Practitioners

1. **Use MEPS for needs assessment**
2. **Use FRPL for meal program operations**
3. **Don't assume high FRPL = high poverty** in CEP schools

## Summary

| Criterion | FRPL | MEPS |
|-----------|------|------|
| Cross-state comparison | Poor | Excellent |
| Temporal consistency | Declining | Good |
| Measures actual poverty | Increasingly poor | Yes |
| Data availability | All schools | Most public schools |
| Official metric status | Yes (federal programs) | No (research measure) |
| Recommended for research | Only pre-2010 | Yes (2006+) |

**Bottom line**: For any analysis requiring consistent, comparable school poverty measurement, MEPS is the superior choice. FRPL should only be used when program participation itself is the focus or when mandated by specific requirements.

# SAIPE Compared to Other Data Sources

Understanding how SAIPE relates to other poverty and income measures, and when to use each.

## Overview of Alternatives

| Source | Geography | Frequency | Key Strength |
|--------|-----------|-----------|--------------|
| **SAIPE** | State, county, district | Annual | Only annual source for all school districts |
| **ACS 1-Year** | Areas >65,000 pop | Annual | Direct survey estimate; demographics |
| **ACS 5-Year** | All areas | Annual (rolling) | Demographics; small area coverage |
| **FRPL** | School-level | Annual | School-specific; administrative data |
| **CPS ASEC** | National/state | Annual | Detailed income; long time series |
| **Decennial Census** | All areas | Every 10 years | Complete enumeration (short form) |

## SAIPE vs Free/Reduced-Price Lunch (FRPL)

### Key Differences

| Aspect | SAIPE | FRPL |
|--------|-------|------|
| **Definition** | Official Census poverty | Income eligibility for program |
| **Income threshold** | 100% of poverty line | 130% (free) / 185% (reduced) |
| **Population** | Residential (all children 5-17) | Enrolled students who apply |
| **Geography** | School district | Individual schools |
| **Source** | Model-based estimate | Administrative participation |
| **Timing** | ~18-month lag | School year |

### Why They Don't Match

1. **Different thresholds**: FRPL uses higher income cutoffs
   - Poverty (family of 4): ~$31,000
   - Free lunch eligible: ~$40,560
   - Reduced lunch eligible: ~$57,720

2. **Different populations**:
   - SAIPE: All children in district boundaries
   - FRPL: Only enrolled students who apply

3. **Participation effects**:
   - FRPL requires application
   - Some eligible families don't apply
   - Community Eligibility Provision (CEP) changes counts

4. **Direct certification**:
   - SNAP/TANF recipients automatically qualify
   - May inflate or deflate apparent rates

### When to Use Each

| Use Case | Better Source |
|----------|---------------|
| Title I allocations | SAIPE (legally mandated) |
| School-level analysis | FRPL |
| Policy-relevant poverty | SAIPE (official definition) |
| Current enrollment context | FRPL |
| Concentration of poverty | Both (triangulate) |

### Community Eligibility Provision (CEP)

CEP allows high-poverty schools to serve free meals to all students:
- Eliminates individual applications
- FRPL participation = 100% of enrollment
- Decouples FRPL from actual poverty

**Impact**: In CEP schools, FRPL no longer measures poverty.

## SAIPE vs American Community Survey (ACS)

### ACS 1-Year

| Aspect | SAIPE | ACS 1-Year |
|--------|-------|------------|
| **Coverage** | All areas | >65,000 population only |
| **Method** | Model-based | Direct survey |
| **Demographics** | No race/ethnicity | Full demographics |
| **Precision** | Higher for small areas | Limited by sample |
| **Consistency** | Controlled to state/national | Independent estimate |

**When ACS 1-Year is better**:
- Need demographic breakdowns
- Analyzing large counties/cities
- Need direct (unmodeled) estimate
- Need household/family characteristics

**When SAIPE is better**:
- Need all districts/counties
- Title I allocation context
- Want reduced volatility
- Comparing across district sizes

### ACS 5-Year

| Aspect | SAIPE | ACS 5-Year |
|--------|-------|------------|
| **Coverage** | All areas | All areas |
| **Time reference** | Single year | 5-year average |
| **Demographics** | No race/ethnicity | Full demographics |
| **Currency** | More current | 2-year older midpoint |
| **Volatility** | Smoothed (model) | Smoothed (pooling) |

**When ACS 5-Year is better**:
- Need demographics (race, ethnicity, gender)
- Need household characteristics
- Need consistent methodology with other ACS tables
- Analyzing very small areas

**When SAIPE is better**:
- Need more current single-year estimate
- Title I allocation compatibility
- Comparing annual changes
- Focus specifically on children 5-17

### Technical Relationship

SAIPE uses ACS as an input:
- ACS 1-year: Dependent variable in state/county models
- ACS 5-year: Baseline shares for school district allocation

This creates **positive correlation** between SAIPE and ACS estimates.

**Implication**: Cannot treat SAIPE and ACS as independent estimates for comparison.

## SAIPE vs CPS ASEC

### Historical Relationship

CPS ASEC was SAIPE's dependent variable before 2005:
- Smaller sample than ACS
- National focus, less state detail
- Long time series

### Current Role

CPS ASEC remains important for:
- National poverty statistics
- Income distribution analysis
- Long historical series
- Detailed income components

But not used in current SAIPE production.

### Key Differences

| Aspect | SAIPE | CPS ASEC |
|--------|-------|----------|
| **Geography** | State, county, district | National, state (limited) |
| **Sample size** | Via ACS (3M addresses) | ~100,000 addresses |
| **Income detail** | Limited (median only) | Detailed components |
| **Historical depth** | 1989-present | 1960s-present |

## SAIPE vs Decennial Census

### Decennial Poverty Data

Census 2000 long-form (last available):
- Asked income questions on ~1/6 sample
- Detailed small-area poverty
- Used as SAIPE baseline before ACS

Census 2010 and 2020:
- No income questions on census form
- ACS replaced long-form
- Decennial provides population counts only

### Current Relationship

SAIPE uses decennial for:
- Population benchmark controls
- Poverty universe denominators
- Updated every 10 years

## Choosing the Right Source

### Decision Framework

```
What do you need?
├─ Title I allocations
│   └─ Use SAIPE (required)
├─ School-level poverty
│   └─ Use FRPL or ACS 5-year
├─ District poverty by race/ethnicity
│   └─ Use ACS 5-year
├─ Most current annual estimate
│   ├─ Large area (>65K) → ACS 1-year
│   └─ Small area → SAIPE
├─ Long time series (20+ years)
│   └─ Use CPS ASEC (national) or SAIPE (state)
├─ Enrollment-based measure
│   └─ Use FRPL
└─ Household characteristics
    └─ Use ACS
```

### Comparison Table

| Need | SAIPE | ACS 1Y | ACS 5Y | FRPL | CPS |
|------|:-----:|:------:|:------:|:----:|:---:|
| All school districts | X | | X | | |
| Annual updates | X | X | X | X | X |
| Race/ethnicity | | X | X | X* | X |
| School-level | | | | X | |
| Direct estimate | | X | X | X | X |
| Detailed income | | | | | X |
| Title I official | X | | | | |
| Most current | | X | | X | |

*FRPL race data varies by state/district reporting

## Why Estimates Differ

### Conceptual Differences

1. **Population universe**: Who is counted
2. **Income definition**: What income is measured
3. **Threshold**: Poverty vs eligibility
4. **Geography**: Residence vs enrollment
5. **Timing**: Reference period differences

### Methodological Differences

1. **Survey vs administrative**: Data collection method
2. **Model-based vs direct**: Estimation approach
3. **Single-year vs pooled**: Time aggregation
4. **Sample design**: Different sampling frames

### When Differences Are Concerning

| Scenario | Concern Level | Action |
|----------|--------------|--------|
| SAIPE > FRPL | Low | Different thresholds explain |
| SAIPE << FRPL | Medium | Check CEP status |
| Large year-to-year swing | Medium | Check methodology changes |
| Large state variation | Low-Medium | May reflect real differences |
| Zero poverty in SAIPE | High | Verify data quality |

## Best Practices

### Triangulation

Use multiple sources to validate findings:
1. Check SAIPE direction against FRPL trends
2. Compare SAIPE to ACS 5-year for pattern consistency
3. Use administrative data (SNAP, Medicaid) as cross-check

### Transparent Reporting

When presenting poverty data:
1. State the source and year
2. Note definition (official poverty vs eligibility)
3. Acknowledge limitations
4. Compare to relevant alternatives if discrepant

### Source Selection Documentation

For research and policy analysis:
1. Justify source selection
2. Acknowledge alternatives
3. Note implications of choice
4. Consider sensitivity analysis with multiple sources

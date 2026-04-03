# College Scorecard Context

The College Scorecard provides federal data on student outcomes, focusing on earnings and debt for students who received federal financial aid. In this system, Scorecard data is accessed through the Urban Institute Education Data Portal, which restructures variable names to lowercase and applies integer encoding to categorical variables.

## Source Overview

| Attribute | Value |
|-----------|-------|
| Publisher | U.S. Department of Education |
| Data Sources | NSLDS (loans), IRS (earnings), IPEDS (institutional) |
| Coverage | Students receiving Title IV federal financial aid |
| Focus | Student outcomes, costs, debt |
| Primary Use | Earnings, debt, repayment, completion |

## Critical Coverage Limitation

**The single most important caveat for College Scorecard:**

### Title IV Recipients Only

Scorecard data covers ONLY students who received federal financial aid (Title IV). This includes:
- Pell Grants
- Federal student loans
- Federal work-study

### Who Is Excluded

| Excluded Group | Why It Matters |
|----------------|----------------|
| Students paying full price | Often higher-income; different outcomes |
| Students with only institutional/state aid | Missing from federal records |
| International students | Not eligible for federal aid |
| Students at non-Title IV schools | Not in system |
| Some graduate students | If no federal aid |

### Size of the Gap

At some institutions, Title IV recipients may represent:
- **Selective private colleges**: 30-50% of students
- **Community colleges**: 60-80% of students
- **For-profit colleges**: 80-90%+ of students
- **Public flagships**: 50-70% of students

**The data systematically overrepresents lower-income students** who are more likely to need federal aid.

## Earnings Data

### What Earnings Data Shows

Scorecard reports earnings from IRS W-2 records:
- Median earnings
- Earnings by percentile (25th, 75th)
- Earnings thresholds (above $25K, $28K, etc.)

### Earnings Caveats

| Issue | Impact |
|-------|--------|
| Title IV only | Lower-income students overrepresented |
| W-2 income only | Excludes self-employment, gig work |
| Working students only | Non-employed excluded from earnings |
| Suppression | <30 working students = suppressed |
| Time lag | 6-10 years after enrollment |

### What Earnings Excludes

- Self-employment income (1099)
- Gig economy earnings
- Non-reported income
- Graduate school students (not working)
- Stay-at-home parents
- Deceased individuals
- Those who left the country

### Earnings Timing

| Metric | Timing |
|--------|--------|
| Entry earnings | 1-2 years after entry (if available) |
| 6-year earnings | 6 years after entry |
| 8-year earnings | 8 years after entry |
| 10-year earnings | 10 years after entry |

**"After entry" means after first enrollment**, not after graduation.

### Interpreting Earnings

```python
# Earnings analysis caveats
def interpret_earnings(earnings_6yr, earnings_10yr, pct_employed):
    """
    Context for earnings interpretation:
    - These are Title IV recipients only
    - Only employed individuals included
    - Self-employment excluded
    """
    notes = []
    
    if pct_employed and pct_employed < 0.7:
        notes.append("WARNING: <70% employed; earnings may not be representative")
    
    if earnings_10yr and earnings_10yr < 30000:
        notes.append("NOTE: Low earnings may reflect part-time work or career fields")
    
    return notes
```

### Earnings Suppression

Earnings are suppressed when:
- Fewer than 30 students with positive earnings
- Privacy thresholds not met

This particularly affects:
- Small programs
- Fields with many graduate school attendees
- Newer programs without enough cohorts

## Debt and Repayment

### Federal Loans Only

Scorecard debt data includes ONLY federal loans:
- Direct Subsidized Loans
- Direct Unsubsidized Loans
- Perkins Loans
- PLUS Loans

### What Debt Excludes

| Excluded | Why It Matters |
|----------|----------------|
| Private student loans | Often 10-20% of total borrowing |
| Institutional loans | Not tracked federally |
| Credit card debt | Used for education expenses |
| Family loans | Informal borrowing |

### Debt Metrics

| Metric | Definition |
|--------|------------|
| Median debt | Median cumulative federal borrowing |
| Monthly payment | Estimated 10-year repayment |
| Debt-to-earnings | Debt relative to earnings |

### Repayment Rates

**Repayment rate definitions have changed over time.**

Current definition: Share of borrowers who have not defaulted and are making progress on principal.

Complexities:
- Income-driven repayment plans affect rates
- Deferment and forbearance affect timing
- Definition of "progress" has changed

### Default Rates

| Metric | Definition |
|--------|------------|
| CDR (Cohort Default Rate) | Federal 3-year default measure |
| Scorecard default | May use different windows |

Default rate limitations:
- Only counts formal default (270+ days delinquent)
- Income-driven plans prevent default but may not build equity
- Strategic behavior affects timing

## Cohort Definitions

### Scorecard vs. IPEDS

| Aspect | Scorecard | IPEDS |
|--------|-----------|-------|
| Who's tracked | Title IV recipients | First-time full-time |
| Includes part-time | Yes | No |
| Includes transfers | Entering transfers | No (at origin) |
| Entry point | Any entry | Fall entry |

### Cohort Year Meaning

For `year=2014` earnings data:
- Students who entered around 2008-2014
- 6-year earnings measured in 2020
- 10-year earnings measured in 2024

Cohort definitions can be complex; check documentation.

## Data Freshness

### Significant Lag

Scorecard data has inherent lag:

| Data Point | Typical Lag |
|------------|-------------|
| Enrollment cohort | 6-10 years ago |
| Earnings measurement | 1-2 years for processing |
| Data release | 1 year after measurement |

**Earnings for "newest" data may reflect students who entered 7+ years ago.**

### Implications

- Labor market conditions when measured may differ from now
- Fields with rapid change (tech) may be outdated
- Institutional changes not reflected in old cohorts

## Comparability Issues

### Do Not Compare Scorecard Earnings To:

| Source | Why Not Comparable |
|--------|-------------------|
| BLS occupation wages | Different populations, timing |
| Census income data | Different definitions, population |
| Alumni surveys | Different methodology, response bias |
| General population | Scorecard is not representative |

### Valid Comparisons

- Same institution over time (with caveats)
- Similar institutions with similar aid populations
- Same field across similar institution types

## Program-Level Data

### Field of Study Data

Scorecard provides some earnings by field (CIP code):
- 2-digit CIP level
- 4-digit CIP level (more specific)

### Field-Level Caveats

| Issue | Impact |
|-------|--------|
| Small programs suppressed | Many fields unavailable |
| Double majors | Counted in one field |
| Field changes | Student may have changed majors |
| Graduate school | Students in grad school not working |

### Using Field Data

```python
# Field-level analysis
def analyze_field_earnings(df, cip_level="2digit"):
    # Check suppression
    suppressed_pct = df.filter(pl.col("earnings_median").is_null()).height / df.height
    
    if suppressed_pct > 0.3:
        print(f"WARNING: {suppressed_pct:.0%} of fields suppressed")
        print("Results may not be representative")
    
    return df.filter(pl.col("earnings_median").is_not_null())
```

## Institutional Identifiers

### UNITID

Scorecard uses UNITID, same as IPEDS:

```python
# Link Scorecard to IPEDS
scorecard = fetch("college-university/scorecard/earnings/2014")
ipeds = fetch("college-university/ipeds/directory/2020")

merged = scorecard.join(ipeds, on="unitid", how="left")
```

### OPEID

Some Scorecard data may use OPEID:
- Links to financial aid system
- Main campus vs. branches may differ from IPEDS

## Common Analysis Mistakes

### Do Not:

1. **Claim Scorecard shows what "all graduates" earn**
   - Title IV recipients only

2. **Compare to general labor market data**
   - Different populations

3. **Use for small programs without checking suppression**
   - Many programs have no data

4. **Ignore the time lag**
   - Earnings reflect old cohorts

5. **Assume debt reflects total borrowing**
   - Federal only; private excluded

### Do:

1. **Note Title IV limitation prominently**
2. **Check suppression before analyzing**
3. **Use for relative comparisons**, not absolute claims
4. **Supplement with other data sources** for context
5. **Document data vintage clearly**

## Recommended Practices

### Before Analysis

1. Check coverage (how many institutions have data?)
2. Check suppression rates by variable
3. Understand cohort timing
4. Note data limitations prominently

### For Earnings Analysis

1. State population clearly (Title IV recipients)
2. Note employed students only
3. Provide context for time lag
4. Don't over-interpret small differences

### For Debt Analysis

1. Note federal loans only
2. Provide repayment context
3. Consider income-driven plan effects
4. Don't compare across very different institutions

### For Comparisons

1. Compare within similar institution types
2. Use relative rankings rather than absolute values
3. Document all limitations
4. Consider supplementing with IPEDS, institutional data

## Related Data Sources

| Source | Use When |
|--------|----------|
| IPEDS | Need enrollment, institutional characteristics |
| NSLDS | Need loan-level detail (restricted access) |
| Census | Need general population context |
| BLS | Need occupational wage context |
| Alumni surveys | Need richer outcome data |

## Quick Reference Card

| Task | Guidance |
|------|----------|
| Understanding coverage | Title IV recipients only |
| Interpreting earnings | Note population, suppression, lag |
| Using debt data | Federal loans only |
| Comparing institutions | Within similar types only |
| Field-level analysis | Check suppression first |
| Linking to IPEDS | Use UNITID |
| Time context | Earnings reflect cohorts from 6-10 years ago |
| General claims | Always note limitations |

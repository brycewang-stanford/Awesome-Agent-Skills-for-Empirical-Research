# EADA Data Limitations

Critical understanding of what EADA data can and cannot tell us.

## The Fundamental Limitation

**EADA data is NOT Title IX compliance data.**

This is the single most important limitation to understand. EADA was designed for consumer information and transparency, NOT for determining legal compliance with Title IX.

## EADA vs. Title IX: Critical Differences

### Purpose

| EADA | Title IX |
|------|----------|
| Consumer disclosure | Civil rights enforcement |
| Inform prospective students | Ensure equal opportunity |
| Public transparency | Legal compliance |
| Annual snapshot | Continuous obligation |

### Methodology

| Aspect | EADA | Title IX |
|--------|------|----------|
| Counting method | First day of first contest | Throughout competitive season |
| Verification | Self-reported | OCR investigation |
| Scope | Limited data points | Comprehensive program review |
| Standards | Report what is | Meet legal requirements |

### What You CANNOT Conclude from EADA Data

- Whether an institution is Title IX compliant
- Whether participation opportunities meet legal standards
- Whether treatment meets equity requirements
- Whether an institution passes the "three-prong test"
- Whether enforcement action is warranted

## Self-Reporting Issues

### No Independent Verification

EADA data is:
- Reported by the institution itself
- Not audited or verified by the government
- Subject to interpretation differences
- Potentially influenced by institutional interests

### Reporting Incentives

Institutions may have incentives to:
- Present data favorably
- Interpret ambiguous rules advantageously
- Minimize apparent disparities
- Highlight positive trends

### Common Reporting Variations

| Issue | How It Varies |
|-------|---------------|
| Expense allocation | Shared costs attributed differently |
| Salary calculation | Treatment of benefits, bonuses |
| Participation counting | Walk-ons, roster management |
| Revenue attribution | Conference distributions |

## Participation Counting Limitations

### EADA Counting ≠ Title IX Counting

EADA counts participants on a specific date. Title IX evaluates opportunities across the competitive season.

**Example**:
- EADA: 100 women on rosters October 15
- Title IX: May consider opportunities available, interest surveys, ability assessments

### Multi-Sport Athletes

| EADA | Result |
|------|--------|
| Institution total | Unduplicated (counted once) |
| Sport totals | Counted in each sport |

This creates confusion when summing sport-level data.

### Roster Management

Institutions may:
- Add participants to rosters without meaningful playing opportunities
- Cap men's team sizes
- Expand women's teams with practice players

**EADA cannot distinguish** between meaningful opportunities and roster padding.

### What Counts as a "Participant"?

Ambiguities include:
- Injured athletes
- Redshirts
- Walk-ons who rarely compete
- Multi-sport athletes
- Students who quit mid-season

## Financial Data Limitations

### Salary Comparisons

**The Football/Basketball Problem**:
- High-revenue sport coach salaries skew men's averages
- Comparing aggregate salary averages is misleading
- Better: Compare similar sports directly

**What's Not Captured**:
- Outside income (camps, media, endorsements)
- Deferred compensation
- Benefits packages
- Perquisites (cars, country club memberships)

### Expense Attribution

Challenges with:
- Shared facilities (how to allocate?)
- Administrative overhead
- Support services
- Capital vs. operating expenses

### Revenue Interpretation

**Caution**: Lower revenue does NOT justify lower investment.

Most sports (men's and women's) don't generate positive revenue. Comparing women's sports revenue to men's revenue ignores that:
- Few men's sports besides football/basketball generate revenue
- Revenue generation was never a requirement of Title IX
- Investment creates opportunity, which may generate future revenue

## Treatment Data Gaps

### The "Laundry List" is Missing

EADA does NOT capture critical equity factors:

| Not in EADA | Examples |
|-------------|----------|
| Facility quality | Locker rooms, weight rooms, fields |
| Scheduling | Practice times, game times |
| Travel quality | Hotels, transportation mode |
| Academic support | Tutoring access, study facilities |
| Medical care | Training staff, insurance |
| Publicity | Media guides, promotions |
| Equipment quality | Condition, replacement cycles |

### Why This Matters

An institution could show:
- Proportionate participation (EADA)
- Proportionate aid (EADA)
- But wildly unequal treatment (NOT in EADA)

## Comparability Limitations

### Cross-Institution Comparisons

Challenges comparing institutions:
- Different conference contexts
- Different enrollment sizes
- Different institutional missions
- Different regional cost structures
- Different sport sponsorship patterns

### Normalizing by Size

Even per-athlete metrics have issues:
- Roster sizes vary by sport
- Walk-on policies differ
- Scholarship limits affect roster composition

### Year-to-Year Comparisons

Annual changes may reflect:
- Actual program changes
- Reporting methodology changes
- One-time events (coach buyout, COVID)
- Roster fluctuations

## Data Quality Issues

### Missing Data (Portal Integer Encoding)

The Education Data Portal uses **integer codes** to represent missing data types:

| Code | Meaning | Action |
|------|---------|--------|
| `-1` | Missing/not reported | Exclude from calculations |
| `-2` | Not applicable | Exclude; item doesn't apply |
| `-3` | Suppressed | Exclude; privacy-protected |
| `NULL` | Null value | Handle per analysis needs |
| `0` | Zero | May be valid or indicate no activity |

```python
import polars as pl

# Always filter coded missing values before analysis
missing_codes = [-1, -2, -3]
df_valid = df.filter(
    ~pl.col("undup_athpartic_women").is_in(missing_codes) &
    ~pl.col("undup_athpartic_men").is_in(missing_codes)
)

# Calculate ratios only on valid data
df_clean = df_valid.with_columns(
    (pl.col("undup_athpartic_women") / (
        pl.col("undup_athpartic_men") + pl.col("undup_athpartic_women")
    )).alias("female_share")
)
```

| Situation | Interpretation Challenge |
|-----------|-------------------------|
| `-1` value | Truly not reported, or reporting error? |
| `0` value | Truly zero, or coded missing? |
| Extreme outliers | Error? Actual? |

### Lag Issues

- EADA data released after academic year
- Policies may have changed since data collection
- Current situation may differ from reported data

### Historical Comparability

Reporting requirements have evolved:
- Variable definitions may have changed
- Required fields have expanded
- Institutional coverage has changed

## Appropriate Uses of EADA Data

### Good Uses

- Identifying potential disparities for further investigation
- Tracking trends over time (within institution)
- Comparing similar institutions (with caution)
- Contextualizing financial investment
- Public accountability and transparency

### Inappropriate Uses

- Determining Title IX compliance
- Making definitive equity judgments
- Legal compliance assessments
- Replacing comprehensive equity audits

## Best Practices for Analysis

### Always Acknowledge Limitations

When reporting findings:
- State that EADA is self-reported
- Note that EADA ≠ compliance
- Acknowledge what's not captured
- Describe counting methodology

### Use Appropriate Language

| Instead of | Use |
|------------|-----|
| "Institution violates Title IX" | "Data shows disparity in..." |
| "Compliant with Title IX" | "Participation appears proportionate" |
| "Discrimination" | "Differences in investment" |

### Seek Additional Context

EADA data is most useful when combined with:
- IPEDS enrollment data
- NCAA data
- Institutional context (mission, conference)
- Trend analysis (not just one year)
- Qualitative information

### Consider Alternative Explanations

Before concluding inequity, consider:
- Sport sponsorship differences
- Regional factors
- Historical program development
- Conference requirements
- One-time events

## The Bottom Line

EADA data provides valuable transparency about college athletics programs. It can highlight potential equity concerns and track trends. However, it is:

- Not a compliance determination tool
- Not a comprehensive equity assessment
- Not verified or audited
- Not capturing all relevant factors

**Use it as one input among many**, not as definitive evidence of equity or inequity.

# EADA Data Elements

Comprehensive guide to data collected through the Equity in Athletics Disclosure Act.

> **CRITICAL: Portal Integer Encoding**
>
> EADA data from the Education Data Portal uses **integer codes** for categorical variables.
>
> | Variable | Code | Meaning |
> |----------|------|---------|
> | `ath_classification_code` | `1`-`20` | Athletic division (see variable-definitions.md) |
> | `fips` | `1`-`56` | State FIPS code |
> | Any variable | `-1` | Missing/not reported |
> | Any variable | `-2` | Not applicable |
> | Any variable | `-3` | Suppressed data |
>
> **Always filter coded missing values before calculations!**

## Data Categories Overview

| Category | Description | Key Variables |
|----------|-------------|---------------|
| Participation | Athletes by gender and sport | `undup_athpartic_*`, `athpartic_*` |
| Coaching | Staff counts and demographics | `*_fthdcoach_*`, `*_ftascoach_*` |
| Salaries | Coach compensation | `hdcoach_salary_*`, `ascoach_salary_*` |
| Expenses | Operating, recruiting, total | `ath_exp_*`, `ath_opexp_*` |
| Revenues | Income by team | `ath_rev_*` |
| Athletic Aid | Scholarships/grants | `ath_stuaid_*` |
| Recruiting | Recruiting expenses | `recruitexp_*` |

## Participation Data

### Institution-Level Counts

| Variable | Description |
|----------|-------------|
| `undup_athpartic_men` | Total male participants (unduplicated) |
| `undup_athpartic_women` | Total female participants (unduplicated) |
| `undup_athpartic_total` | Total participants (unduplicated; often `-1` coded) |
| `athpartic_men` | Male participants (duplicated/sport-level sum) |
| `athpartic_women` | Female participants (duplicated/sport-level sum) |
| `athpartic_coed_men` | Male participants on coed teams |
| `athpartic_coed_women` | Female participants on coed teams |

### Counting Rules

**Unduplicated Count**: A student who plays multiple sports is counted once for the institution total, but counted for each sport in sport-level data.

**Timing**: Count taken as of the first day of the first scheduled contest of the sport's season.

**Who Counts**:
- Varsity athletes only
- Walk-ons included
- Redshirts if on roster
- Practice squad if varsity designated

### Example Calculation

```python
import polars as pl

# Total unduplicated athletes
total_athletes = pl.col("undup_athpartic_men") + pl.col("undup_athpartic_women")

# Female participation rate
female_pct = pl.col("undup_athpartic_women") / total_athletes

# Compare to enrollment (enrollment columns are in EADA data)
enrollment_gap = (
    pl.col("enrollment_women") / pl.col("enrollment_total")
) - female_pct
```

## Coaching Data

### Head Coaches

| Variable | Description |
|----------|-------------|
| `hdcoach_salary_men` | Average head coach salary for men's teams |
| `hdcoach_salary_women` | Average head coach salary for women's teams |
| `hdcoach_salary_coed` | Average head coach salary for coed teams |
| `men_fthdcoach_male` | Full-time male head coaches of men's teams |
| `men_pthdcoach_male` | Part-time male head coaches of men's teams |
| `men_fthdcoach_fem` | Full-time female head coaches of men's teams |
| `men_pthdcoach_fem` | Part-time female head coaches of men's teams |
| `women_fthdcoach_male` | Full-time male head coaches of women's teams |
| `women_pthdcoach_male` | Part-time male head coaches of women's teams |
| `women_fthdcoach_fem` | Full-time female head coaches of women's teams |
| `women_pthdcoach_fem` | Part-time female head coaches of women's teams |
| `men_total_hdcoach` | Total head coaches of men's teams |
| `women_total_hdcoach` | Total head coaches of women's teams |

### Assistant Coaches

Same naming pattern with `ascoach` replacing `hdcoach`:

| Variable Pattern | Description |
|------------------|-------------|
| `{team}_ft/ptascoach_{gender}` | Assistant coaches by team, status, coach gender |
| `ascoach_salary_{team}` | Average assistant coach salary by team gender |

Employment Status:
- `ft` = Full-time
- `pt` = Part-time

### Coaching Demographics Analysis

```python
import polars as pl

# Female head coaches of women's teams
female_coaches_womens = (
    pl.col("women_fthdcoach_fem") + pl.col("women_pthdcoach_fem")
)

# Total head coaches of women's teams
total_coaches_womens = pl.col("women_total_hdcoach")

# Percentage female
pct_female = female_coaches_womens / total_coaches_womens
```

## Salary Data

### Salary Reporting Rules

Institutions report:
- **Institutional compensation only**: W-2 wages and bonuses from the institution
- **Excludes**: Media income, camps, endorsements, outside income
- **Calculated as average**: Total salaries / Number of paid positions

| Variable | Description |
|----------|-------------|
| `hdcoach_salary_men` | Average salary for head coaches of men's teams |
| `hdcoach_salary_women` | Average salary for head coaches of women's teams |
| `hdcoach_salary_coed` | Average salary for head coaches of coed teams |
| `ascoach_salary_men` | Average salary for assistant coaches of men's teams |
| `ascoach_salary_women` | Average salary for assistant coaches of women's teams |
| `ascoach_salary_coed` | Average salary for assistant coaches of coed teams |

### Salary Analysis Cautions

- **Football/basketball skew**: High-revenue sport coaches inflate men's averages
- **Part-time inclusion**: May lower averages
- **Non-institutional income**: Not captured (can be substantial)
- **Benefits**: Not typically included

### Meaningful Comparisons

Better approach: Compare coaches of similar sports
```python
# Example: Compare basketball coaches
# Rather than all men's vs all women's coaches
basketball_men_salary vs basketball_women_salary
```

## Expense Data

### Total Expenses

| Variable | Description |
|----------|-------------|
| `ath_exp_men` | Total expenses for men's teams |
| `ath_exp_women` | Total expenses for women's teams |
| `ath_grnd_total_exp` | Grand total athletic expenses |

Operating expenses include:
- Lodging, meals, transportation
- Uniforms and equipment
- Officials
- Game-day personnel

### Not Operating Expenses

- Salaries (reported separately)
- Athletic scholarships
- Facilities construction/maintenance
- Debt service

### Recruiting Expenses

| Variable | Description |
|----------|-------------|
| `recruitexp_men` | Recruiting expenses for men's teams |
| `recruitexp_women` | Recruiting expenses for women's teams |
| `recruitexp_coed` | Recruiting expenses for coed teams |
| `recruitexp_total` | Total recruiting expenses |

Recruiting includes:
- Transportation for prospects and staff
- Lodging for recruiting trips
- Entertainment of prospects
- Communication costs

### Total Expenses

Some datasets report total athletic expenditures:
- Operating + Salaries + Recruiting + Other
- Useful for overall investment comparison

## Revenue Data

### Revenue Sources

| Variable | Description |
|----------|-------------|
| `ath_rev_men` | Total revenues from men's teams |
| `ath_rev_women` | Total revenues from women's teams |
| `ath_grnd_total_rev` | Grand total of all athletic revenues |

Revenue includes:
- Ticket sales
- Broadcast rights
- NCAA/conference distributions
- Guarantees
- Program sales
- Concessions (if attributed)

### Revenue Interpretation

**Important**: Most women's sports programs don't generate significant independent revenue. This does NOT mean they're less worthy of investment—most men's non-revenue sports also don't generate income.

```
Common pattern:
- Football: Positive revenue (large programs)
- Men's basketball: Positive or break-even
- All other sports: Typically subsidized
```

## Athletic Aid Data

### Variables

| Variable | Description |
|----------|-------------|
| `ath_stuaid_men` | Total athletic aid to male students |
| `ath_stuaid_women` | Total athletic aid to female students |
| `ath_stuaid_coed` | Athletic aid for coed teams |
| `ath_stuaid_total` | Total athletic student aid |
| `ath_stuaid_men_ratio` | Ratio of male aid to total |
| `ath_stuaid_women_ratio` | Ratio of female aid to total |

### What Counts as Athletic Aid

- Scholarships
- Grants-in-aid
- Tuition waivers for athletics
- Room, board, books if athletically related

### Title IX Standard

Athletic aid should be proportional to participation:

```python
# If participation is 45% women, 55% men
# Aid should be approximately:
aid_women / (aid_men + aid_women) ≈ 0.45
```

Small deviations (1-2%) acceptable; larger gaps raise concerns.

## Derived Metrics

### Participation Equity

```python
import polars as pl

# Female participation share
female_share = pl.col("undup_athpartic_women") / (
    pl.col("undup_athpartic_men") + pl.col("undup_athpartic_women")
)

# Compare to enrollment (included in EADA data)
enrollment_gap = (
    pl.col("enrollment_women") / pl.col("enrollment_total")
) - female_share
```

### Financial Investment Per Athlete

```python
# Per-athlete operating expenses (pre-calculated in data)
# Use ath_opexp_perpart_men and ath_opexp_perpart_women directly

# Investment ratio
investment_ratio = pl.col("ath_opexp_perpart_women") / pl.col("ath_opexp_perpart_men")
```

### Coaching Investment

```python
# Average salary comparison
salary_ratio = pl.col("hdcoach_salary_women") / pl.col("hdcoach_salary_men")

# Coaches per athlete
coaches_per_male = pl.col("men_total_hdcoach") / pl.col("undup_athpartic_men")
coaches_per_female = pl.col("women_total_hdcoach") / pl.col("undup_athpartic_women")
```

### Aid Proportionality

```python
# Aid share vs participation share (pre-calculated ratio available)
# Use ath_stuaid_women_ratio directly, or calculate:
aid_share_women = pl.col("ath_stuaid_women") / (
    pl.col("ath_stuaid_men") + pl.col("ath_stuaid_women")
)
partic_share_women = pl.col("undup_athpartic_women") / (
    pl.col("undup_athpartic_men") + pl.col("undup_athpartic_women")
)

# Proportionality gap
aid_gap = partic_share_women - aid_share_women
```

## Data Quality Considerations

### Missing Values (Portal Integer Encoding)

| Code | Meaning |
|------|---------|
| `-1` | Missing/not reported |
| `-2` | Not applicable |
| `-3` | Suppressed |
| `NULL` | Null value |
| `0` | Reported as zero |

**Important distinctions:**
- Zero values may mean "not applicable" or "zero dollars"
- NULL vs 0 distinction important
- Always filter `-1`, `-2`, `-3` before calculations

### Self-Reporting

- No independent verification
- Interpretation differences across institutions
- Potential for errors or strategic reporting

### Year-to-Year Changes

May reflect:
- Actual changes in program
- Reporting methodology changes
- Roster fluctuations
- One-time events (coach buyouts, etc.)

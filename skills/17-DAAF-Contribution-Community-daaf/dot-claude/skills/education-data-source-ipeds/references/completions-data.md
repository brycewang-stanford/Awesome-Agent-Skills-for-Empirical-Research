# IPEDS Completions Data

Understanding degrees and certificates awarded, CIP codes, and completions analysis.

## Contents

- [Completions Survey Overview](#completions-survey-overview)
- [Completions vs Completers](#completions-vs-completers)
- [Award Levels](#award-levels)
- [CIP Codes](#cip-codes)
- [Data Disaggregation](#data-disaggregation)
- [Distance Education](#distance-education)
- [Common Analysis Uses](#common-analysis-uses)
- [Data Quality Issues](#data-quality-issues)
- [Variable Reference](#variable-reference)

## Completions Survey Overview

The Completions (C) survey collects data on postsecondary awards conferred during an academic year.

### Collection Period

Fall collection (August-October) for the prior academic year (July 1 - June 30).

### What's Collected

1. **Completions**: Count of awards by CIP code, award level, race/ethnicity, gender
2. **Completers**: Unduplicated count of individuals receiving awards
3. **Distance education indicator**: Whether program is offered via DE

### Key Distinction: Academic Year

Completions are for the academic year, not calendar year:
- 2022-23 completions = Awards conferred July 1, 2022 - June 30, 2023
- Data available fall 2023 (provisional), spring 2024 (final)

## Completions vs Completers

### Completions

**Count of awards conferred** - a student receiving two degrees counts as two completions.

```python
# If student earns BS in Biology and BA in Chemistry
completions = 2  # Two awards

# If student earns dual degree (single program)
completions = 1  # One award
```

### Completers

**Unduplicated count of individuals** - each person counted once regardless of awards.

```python
# Same student with two degrees
completers = 1  # One person

# Why different totals?
# completions >= completers (always)
# completions = completers + double majors + multiple awards
```

### When to Use Each

| Use Case | Measure | Why |
|----------|---------|-----|
| Degrees by field | Completions | Shows all awards in each field |
| Graduation outcomes | Completers | Counts individuals |
| Program productivity | Completions | Shows program output |
| Degree inflation analysis | Ratio | completions/completers trend |
| Labor market supply | Completions by CIP | Degrees in workforce fields |

### Double Counting Warning

Using completions can overcount individuals:

```python
# Example: Counting STEM graduates
stem_completions = bio_completions + chem_completions + physics_completions
# May count same person multiple times if double major

# Solution: Use completers for people count, completions for field analysis
```

## Award Levels

### Portal Award Level Codes

> **CRITICAL:** The Portal uses DIFFERENT award level codes than NCES raw documentation. The codes below are from actual observed data in the Portal `completions-2digcip` dataset. Always verify against the codebook.

| Code | Level | Typical Duration |
|------|-------|------------------|
| 4 | Postsecondary certificate (<1 year) | <1 academic year |
| 7 | Postsecondary certificate (1-<2 years) | 1-2 academic years |
| 8 | Associate's degree | 2 years |
| 9 | Postsecondary certificate (2-<4 years) | 2-4 years |
| 22 | Bachelor's degree | 4 years |
| 23 | Postbaccalaureate certificate | Post-bachelor's |
| 24 | Master's degree | 1-2 years post-bachelor's |
| 30 | Post-master's certificate | Post-master's |
| 31 | Doctor's degree - research/scholarship | PhD, EdD (research) |
| 32 | Doctor's degree - professional practice | MD, JD, DDS, etc. |
| 33 | Doctor's degree - other | Other doctoral |

> Verify these codes against the live codebook. Use `get_codebook_url()` from `fetch-patterns.md`:
> ```python
> url = get_codebook_url("ipeds/codebook_colleges_ipeds_completions-2digcip")
> ```

#### NCES Raw File Award Level Codes (for reference only)

NCES documentation and raw IPEDS data files use a different numbering system. The table below shows the mapping:

| NCES Code | Portal Code | Level |
|-----------|-------------|-------|
| 1 | 4 | Certificate (<1 year) |
| 2 | 7 | Certificate (1-<2 years) |
| 3 | 8 | Associate's |
| 4 | 9 | Certificate (2-<4 years) |
| 5 | 22 | Bachelor's |
| 6 | 23 | Postbaccalaureate certificate |
| 7 | 24 | Master's |
| 8 | 30 | Post-master's certificate |
| 17 | 31 | Doctor's - research/scholarship |
| 18 | 32 | Doctor's - professional practice |
| 19 | 33 | Doctor's - other |

### Award Level Groupings (Portal Codes)

```python
# Common groupings using PORTAL codes (not NCES codes)
certificates = [4, 7, 9, 23, 30]  # All certificate levels
associate = [8]
bachelor = [22]
master = [24]
doctoral = [31, 32, 33]

# Undergraduate vs graduate
undergraduate = [4, 7, 8, 9, 22]  # Through bachelor's
graduate = [23, 24, 30, 31, 32, 33]  # Post-bachelor's
```

## CIP Codes

### Classification of Instructional Programs

CIP (Classification of Instructional Programs) is a taxonomy of instructional programs.

### CIP Code Structure

| Level | Digits | Example | Meaning |
|-------|--------|---------|---------|
| 2-digit | XX | 52 | Business |
| 4-digit | XX.XX | 52.02 | Business Administration |
| 6-digit | XX.XXXX | 52.0201 | Business Admin & Management |

### Major CIP Families (2-digit)

| CIP | Field |
|-----|-------|
| 01 | Agriculture |
| 03 | Natural Resources |
| 04 | Architecture |
| 05 | Area/Ethnic/Cultural Studies |
| 09 | Communication |
| 10 | Communications Technologies |
| 11 | Computer Science |
| 13 | Education |
| 14 | Engineering |
| 15 | Engineering Technologies |
| 16 | Foreign Languages |
| 22 | Legal Professions |
| 23 | English |
| 24 | Liberal Arts |
| 26 | Biological Sciences |
| 27 | Mathematics |
| 30 | Interdisciplinary Studies |
| 31 | Parks and Recreation |
| 38 | Philosophy |
| 40 | Physical Sciences |
| 42 | Psychology |
| 43 | Security and Protective Services |
| 44 | Public Administration |
| 45 | Social Sciences |
| 50 | Visual and Performing Arts |
| 51 | Health Professions |
| 52 | Business |
| 54 | History |

### CIP Version Changes

CIP codes are updated periodically:
- CIP 2000
- CIP 2010
- CIP 2020

**Impact**: Programs may be reclassified; crosswalks available from NCES.

### STEM CIP Codes

DHS designates STEM fields for OPT purposes. Common STEM 2-digit CIPs:

```python
stem_cips = [
    1,   # Agriculture (some)
    3,   # Natural Resources
    11,  # Computer Science
    14,  # Engineering
    15,  # Engineering Tech
    26,  # Biology
    27,  # Math
    40,  # Physical Sciences
    41,  # Science Tech
]
```

## Data Disaggregation

### By Demographics

Completions are reported by:
- Race/ethnicity (9 categories)
- Gender (men, women)

```python
# Demographic breakdown
completions_by_race = df.group_by(["cip", "race"]).agg(pl.col("awards").sum())
completions_by_gender = df.group_by(["cip", "sex"]).agg(pl.col("awards").sum())
```

### Race/Ethnicity Categories (Portal Integer Encoding)

| Code | Category |
|------|----------|
| 1 | White |
| 2 | Black or African American |
| 3 | Hispanic/Latino |
| 4 | Asian |
| 5 | American Indian/Alaska Native |
| 6 | Native Hawaiian/Pacific Islander |
| 7 | Two or more races |
| 8 | Nonresident alien |
| 9 | Race/ethnicity unknown |
| 20 | Other |
| 99 | Total |
| -1 | Missing/not reported |
| -3 | Suppressed |

> **Note:** The ordering differs from some NCES documentation. Always use the Portal codebook values.

### By Age (Completers Only)

Completers are also reported by age category:
- Under 18
- 18-24
- 25-39
- 40 and over

## Distance Education

### What's Collected

For each CIP code and award level:
- Is the program offered entirely via distance education?
- If not, is it offered partially via distance education?

### Distance Education Flag

| Value | Meaning |
|-------|---------|
| 1 | Program offered entirely via DE |
| 2 | Program offered partially via DE |
| 3 | Program not offered via DE |

### Analysis Considerations

```python
# Filter to programs with DE option
de_programs = completions.filter(
    pl.col("distance_ed").is_in([1, 2])
)

# Count completions in fully online programs
online_only = completions.filter(
    pl.col("distance_ed") == 1
).select(pl.col("awards").sum())
```

## Common Analysis Uses

### Labor Market Supply

Estimate graduates entering workforce:

```python
# CS graduates available
cs_grads = completions.filter(
    pl.col("cip2") == 11
).select(pl.col("awards").sum())

# By degree level
cs_by_level = completions.filter(
    pl.col("cip2") == 11
).group_by("awlevel").agg(pl.col("awards").sum())
```

### Program Growth Analysis

Track field trends over time:

```python
# Year-over-year change
field_trend = completions.group_by(["year", "cip2"]).agg(
    pl.col("awards").sum().alias("total")
).sort(["cip2", "year"])

# Calculate growth rate
field_trend = field_trend.with_columns(
    (pl.col("total") / pl.col("total").shift(1) - 1).over("cip2").alias("growth")
)
```

### Diversity in Fields

Analyze representation:

```python
import polars as pl

# Percent women in engineering (sex=2 is Female in Portal integer encoding)
eng_by_gender = completions.filter(
    (pl.col("cipcode") == 14) &
    (pl.col("race") == 99)  # Total across races
).group_by("sex").agg(pl.col("awards").sum())

female_awards = eng_by_gender.filter(pl.col("sex") == 2)["awards"][0]
total_awards = eng_by_gender.filter(pl.col("sex") == 99)["awards"][0]
pct_women = female_awards / total_awards * 100
```

### Institution Program Mix

Understand institutional focus:

```python
# Programs by field at institution
inst_mix = completions.filter(
    pl.col("unitid") == 110635
).group_by("cip2").agg(
    pl.col("awards").sum().alias("completions")
).sort("completions", descending=True)
```

## Data Quality Issues

### Issue 1: Program Reporting vs Award Reporting

Some institutions may:
- Report programs not actually conferring awards
- Not report all programs

**Mitigation**: Focus on institutions with completions > 0.

### Issue 2: CIP Code Accuracy

Program classification may vary:
- Similar programs coded differently
- CIP updates change classifications
- Interdisciplinary programs difficult to classify

**Mitigation**: 
- Use 2-digit CIP for robustness
- Note CIP version in analysis

### Issue 3: Branch Campus Reporting

For multi-campus systems:
- Some report completions at campus level
- Some consolidate at system level

**Mitigation**: Check reporting patterns; aggregate to OPEID6 if needed.

### Issue 4: Double Majors

Double majors appear in completions for both fields.

```python
# Example
bio_chem_double_major_student = 1  # person
bio_completions += 1  # appears here
chem_completions += 1  # and here
total_completions += 2  # counts twice
total_completers += 1  # counts once
```

**Mitigation**: Use completers for people counts; note when using completions.

### Issue 5: Certificate Program Variability

Certificate programs vary widely:
- Some are a few weeks
- Some are nearly 2 years
- Industry certifications vs academic certificates

**Mitigation**: 
- Separate analysis by award level
- Focus on degree-level awards for comparability

## Variable Reference

> Verify these variable names against the live codebook. Use `get_codebook_url()` from `fetch-patterns.md`. Portal variable names differ from NCES documentation.

### Portal Completions Variables (2-digit CIP dataset)

The `completions-2digcip` (yearly) dataset contains disaggregated rows by race, sex, and award level:

| Portal Variable | Description |
|-----------------|-------------|
| `unitid` | Institution identifier |
| `year` | Data year |
| `cipcode` | CIP code (2-digit integer) |
| `award_level` | Award level code (Portal codes: 4, 7, 8, 9, 22-24, 30-33) |
| `majornum` | Major number (1=first major, 2=second major) |
| `awards` | Count of awards conferred |
| `race` | Race/ethnicity (integer codes: 1-9, 99=Total) |
| `sex` | Sex (1=Male, 2=Female, 99=Total) |
| `fips` | State FIPS code |

The `completions-6digcip` (yearly) dataset has the same structure but with 6-digit CIP codes for more granular field analysis.

#### NCES Raw File Names (for reference only)

The following variable names appear in NCES documentation and raw IPEDS data files but are NOT used in the Portal:

| NCES Name | Portal Equivalent | Notes |
|-----------|-------------------|-------|
| `AWLEVEL` | `award_level` | NCES uses codes 1-19; Portal uses codes 4-33 |
| `CTOTALT` | `awards` (filtered to totals) | Portal uses disaggregated rows |
| `CIPCODE` | `cipcode` | Same name, but 2-digit vs 6-digit depends on dataset |
| `MAJORNUM` | `majornum` | Same concept |

### Completers Dataset

The `completers` dataset counts unduplicated individuals. Consult the codebook for variables:

```python
url = get_codebook_url("ipeds/codebook_colleges_ipeds_completers")
```

### CIP-Related Resources

| Resource | Description |
|----------|-------------|
| CIP code lookup | nces.ed.gov/ipeds/cipcode |
| CIP crosswalk | NCES provides version crosswalks |
| STEM designation | DHS STEM Designated Degree Program List |

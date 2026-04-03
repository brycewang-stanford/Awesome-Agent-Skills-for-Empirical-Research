# CCD Historical Changes

This reference documents significant changes to CCD data collection, definitions, and coding over time. Essential for longitudinal analysis and understanding data comparability.

> **Portal vs NCES Codes:** This document references historical NCES string codes (AM, BL, PK, etc.) when explaining transitions. The Education Data Portal uses **integer codes** — see `variable-definitions.md` for current Portal mappings.

## Major Milestones Timeline

| Year | Change | Impact |
|------|--------|--------|
| 1986-87 | CCD nonfiscal data begins | Historical baseline |
| 1989-90 | Finance data collection begins | District finance available |
| 1991-92 | Dropout/completer collection begins | Completion data available |
| 1998-99 | English Language Learner variable added | ELL tracking starts |
| 2002-03 | School status codes 6, 7 added | Inactive/future schools tracked |
| 2005-06 | School status code 8 added | Reopened schools tracked |
| 2006-07 | **Locale codes revised** | Major discontinuity |
| 2006 | EDFacts system implemented | Data collection centralized |
| 2007-08 | LEA type codes revised | Charter agencies distinguished |
| 2007-08 | School type code 5 added | Reportable programs tracked |
| 2007 | ACGR introduced | Graduation rate methodology change |
| 2010-11 | **Race/ethnicity categories revised** | Major discontinuity |
| 2014-15 | Virtual school indicator added | Virtual schools tracked |
| 2014-15 | CEP nationwide | FRPL interpretation affected |
| 2016-17 | Long file format | Data structure changed |
| 2017-18 | LEA membership guidance changed | LEA totals methodology |
| 2017-18 | School level assignment logic changed | LEVEL variable affected |

---

## Locale Codes (2006)

### The Change

In 2006, NCES completely revised the locale code system from a "metro-centric" to an "urban-centric" framework.

### Before 2006: Metro-Centric Codes

| Code | Category |
|------|----------|
| 1 | Large city |
| 2 | Midsize city |
| 3 | Urban fringe of large city |
| 4 | Urban fringe of midsize city |
| 5 | Large town |
| 6 | Small town |
| 7 | Rural, outside CBSA |
| 8 | Rural, inside CBSA |

### After 2006: Urban-Centric Codes

| Code | Category | Definition |
|------|----------|------------|
| 11 | City, Large | Principal city, pop ≥250,000 |
| 12 | City, Midsize | Principal city, pop 100,000-249,999 |
| 13 | City, Small | Principal city, pop <100,000 |
| 21 | Suburb, Large | Outside principal city, UA ≥250,000 |
| 22 | Suburb, Midsize | Outside principal city, UA 100,000-249,999 |
| 23 | Suburb, Small | Outside principal city, UA <100,000 |
| 31 | Town, Fringe | Urban cluster, ≤10 mi from UA |
| 32 | Town, Distant | Urban cluster, 10-35 mi from UA |
| 33 | Town, Remote | Urban cluster, >35 mi from UA |
| 41 | Rural, Fringe | ≤5 mi from UA |
| 42 | Rural, Distant | 5-25 mi from UA |
| 43 | Rural, Remote | >25 mi from UA |

### Why There's No Crosswalk

The systems use fundamentally different geographic concepts:
- Old: Based on Metropolitan Statistical Areas (MSAs)
- New: Based on urbanized areas and distance calculations

A school classified as "rural" in the old system might be "town" or "suburb" in the new system, and vice versa.

### Recommendations for Longitudinal Analysis

1. **Preferred**: Analyze pre-2006 and post-2006 as separate periods
2. **Alternative**: Use broad categories (urban/suburban/town/rural) with caution
3. **Advanced**: Obtain geocodes and calculate custom locale measures

### Transition Files

NCES provides files for 2003-04 through 2005-06 that include both old and new codes, useful for understanding the transition.

---

## Race/Ethnicity Categories (2010)

### The Change

In 2010, CCD adopted new OMB standards for race/ethnicity reporting, adding a "Two or More Races" category and separating Asian and Pacific Islander.

### Before 2010: 5 Categories

| Code | Category |
|------|----------|
| AI | American Indian/Alaska Native |
| AS | Asian/Pacific Islander (combined) |
| BL | Black, non-Hispanic |
| HI | Hispanic |
| WH | White, non-Hispanic |

### After 2010: 7 Categories

| Code | Category |
|------|----------|
| HI | Hispanic/Latino (any race) |
| AM | American Indian/Alaska Native (non-Hispanic) |
| AS | Asian (non-Hispanic) |
| BL | Black or African American (non-Hispanic) |
| HP | Native Hawaiian/Pacific Islander (non-Hispanic) |
| TR | Two or More Races (non-Hispanic) |
| WH | White (non-Hispanic) |

### Key Differences

1. **Two-question format**: Hispanic ethnicity asked separately from race
2. **Two or More Races**: New category for multiracial students
3. **Asian/Pacific Islander split**: Separate categories for AS and HP
4. **Collection order**: Hispanic status collected first

### Transition Period (2007-2010)

States transitioned at different times:
- Some early adopters in 2007-08
- Most states by 2009-10
- Full implementation by 2010-11

**Data Issues During Transition**:
- Inconsistent categories across states
- Some students in "unknown" race
- Bridge coding attempts (mapping old to new)

### Impact on Time Series

| Analysis Need | Impact | Approach |
|---------------|--------|----------|
| Total by race | Can combine HP with AS for historical comparison | Loses HP detail |
| Multiracial students | TR category didn't exist pre-2010 | Cannot track historically |
| Hispanic students | Relatively consistent | Generally comparable |
| Detailed race analysis | Not comparable across periods | Separate analyses |

### Recommended Approach

```python
# Portal uses integer race codes (not NCES string codes)
# Current Portal codes: 1=White, 2=Black, 3=Hispanic, 4=Asian,
#                       5=AIAN, 6=NHPI, 7=Two+, 99=Total

# For time series spanning 2010
# Option 1: Collapse new categories to match old 5-category system
def collapse_to_5_categories(race_code: int) -> int:
    """Collapse 7-category (post-2010) to 5-category (pre-2010) equivalent."""
    mapping = {
        5: 5,   # American Indian/Alaska Native stays same
        4: 4,   # Asian stays Asian
        6: 4,   # Pacific Islander → Asian (combined pre-2010)
        2: 2,   # Black stays Black
        3: 3,   # Hispanic stays Hispanic
        1: 1,   # White stays White
        7: -1,  # Two or more → cannot map (treat as missing)
    }
    return mapping.get(race_code, -1)

# Option 2: Analyze pre-2010 and post-2010 separately
# Note the break in your time series documentation
```

---

## LEA Type Codes (2007)

### The Change

In 2007-08, LEA type codes were revised to specifically identify charter school agencies.

### Before 2007-08

| Code | Type |
|------|------|
| 1-6 | Various types (same as current) |
| 7 | Other education agencies |

### After 2007-08

| Code | Type |
|------|------|
| 1-6 | Same as before |
| 7 | **Charter agency** (all schools are charters) |
| 8 | Other education agencies |

### Impact

- Pre-2007-08: Charter agencies coded as "7" (Other) or regular districts
- Post-2007-08: Charter agencies specifically identifiable
- Historical charter LEA identification requires additional logic

### Identifying Historical Charter LEAs

For years before 2007-08:
1. Check if all schools have charter=1
2. Cross-reference with state charter authorizer records
3. Document uncertainty in analysis

---

## School Type Codes (2007)

### The Change

In 2007-08, school type code 5 was added for "Reportable Programs."

### Before 2007-08

| Code | Type |
|------|------|
| 1 | Regular |
| 2 | Special Education |
| 3 | Vocational |
| 4 | Alternative |

### After 2007-08

| Code | Type |
|------|------|
| 1-4 | Same as before |
| 5 | Reportable Program (within another school) |

### Impact

Programs that were previously reported as separate schools may now be coded as programs. This affects school counts.

---

## Status Codes

### Additions Over Time

| Year | Code | Meaning |
|------|------|---------|
| Original | 1-5 | Continuing, Closed, New, Added, Changed Agency |
| 2002-03 | 6 | Inactive (temporarily closed, may reopen ≤3 years) |
| 2002-03 | 7 | Future (scheduled to open within 2 years) |
| 2005-06 | 8 | Reopened (was closed, now operational) |

### Impact on School Counts

When comparing school counts over time:
- Pre-2002-03: Temporarily closed schools may appear as "Closed"
- Post-2002-03: "Inactive" status distinguishes temporary closures
- Pre-2005-06: Reopened schools counted as "New"
- Post-2005-06: "Reopened" status tracks these separately

---

## Graduation Rate Methodology (2007)

### AFGR (Averaged Freshman Graduation Rate)

**Used**: Before ACGR implementation

**Calculation**:
```
AFGR = Diploma Recipients / Averaged 9th Grade Enrollment
Where averaged enrollment = (8th grade y-4 + 9th grade y-3 + 9th grade y-2) / 3
```

**Limitations**:
- Uses enrollment approximation, not cohort tracking
- Doesn't account for transfers
- State implementation varied

### ACGR (Adjusted Cohort Graduation Rate)

**Required**: Under ESEA/ESSA

**Calculation**:
```
ACGR = (Cohort who graduated) / (First-time 9th graders, adjusted for transfers)
```

**Features**:
- Tracks actual student cohorts
- Adjusts for documented transfers in/out
- Standardized methodology

### Transition

- ACGR introduced 2007
- Phased in through 2011
- Both measures available during transition
- ACGR is now the standard measure

---

## File Format Change (2016-17)

### The Change

Starting 2016-17, CCD files are published in "long" format instead of "wide" format.

### Wide Format (Pre-2016-17)

One row per school, columns for each variable:
```
NCESSCH, AM_MALE_K, AM_MALE_1, ..., WH_FEMALE_12
```

### Long Format (2016-17+)

Multiple rows per school, disaggregation as columns:
```
NCESSCH, GRADE, SEX, RACE, STUDENT_COUNT
```

### Impact

- Easier to filter/aggregate
- Different data processing required
- NCES provides conversion programs

---

## Membership Reporting Guidance (2017-18)

### The Change

Guidance for reporting LEA-level membership changed between 2016-17 and 2017-18.

### Before 2017-18

States could report LEA totals that:
- Were independent of school sums
- Used different counting methods
- Might not equal sum of schools

### After 2017-18

LEA membership should equal sum of school membership within the LEA.

### Impact

Comparing LEA-level membership across this transition requires caution. Some states show apparent changes that reflect reporting methodology, not actual enrollment changes.

---

## School Level Assignment (2017-18)

### The Change

The logic for deriving the LEVEL variable (elementary, middle, high, other) changed in 2017-18.

### Impact

Some schools may be classified differently before and after this change. Check school-level time series for unexpected changes.

---

## FRPL Reporting Changes

### Timeline

| Year | Change |
|------|--------|
| Original | FRPL reported from applications |
| 2011-12 | CEP pilot begins (some states) |
| 2012-13 | Direct certification reported separately (optional) |
| 2014-15 | CEP nationwide |
| 2016-17+ | States may report FRPL, Direct Cert, or both |

### Impact on Poverty Analysis

- Pre-CEP: FRPL reasonably consistent poverty proxy
- Post-CEP: Schools with 100% FRPL may be CEP schools, not 100% poverty
- Current: Must interpret FRPL differently for CEP vs. non-CEP schools

---

## Handling Historical Changes in Analysis

### General Approach

1. **Document the relevant period** for your analysis
2. **Check for definition changes** during your period
3. **Account for changes** in methodology or interpretation
4. **Report limitations** clearly

### Code Pattern for Time-Sensitive Analysis

```python
def prepare_longitudinal_data(df, variable, start_year, end_year):
    """Prepare data accounting for known historical changes."""
    
    # Check for locale code issues
    if variable == "locale" and start_year < 2006 and end_year >= 2006:
        print("WARNING: Locale code methodology changed in 2006")
        print("Consider separate pre/post-2006 analysis")
    
    # Check for race/ethnicity issues
    if variable in ["race", "enrollment_by_race"] and start_year < 2010 and end_year >= 2010:
        print("WARNING: Race/ethnicity categories changed in 2010")
        print("Two or More Races (TR) and HP categories not available pre-2010")
    
    # Check for FRPL issues
    if variable in ["frpl", "free_lunch", "reduced_lunch"] and end_year >= 2014:
        print("NOTE: CEP implementation affects FRPL interpretation post-2014")
    
    return df
```

---

## Resources for Historical Research

### NCES Documentation

- Reference Library: Crosswalks and documentation
- Historical file documentation
- State notes by year

### Useful Publications

- "100 Years of American Education: A Statistical Portrait" (NCES)
- CCD overview documents
- Digest of Education Statistics (annual)

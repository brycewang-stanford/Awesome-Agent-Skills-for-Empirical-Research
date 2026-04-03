# Graduation Rates

Understanding the Adjusted Cohort Graduation Rate (ACGR) methodology, cohort definitions, and proper interpretation.

## Contents

- [What is ACGR?](#what-is-acgr)
- [ACGR Calculation](#acgr-calculation)
- [Cohort Adjustments](#cohort-adjustments)
- [Extended Graduation Rates](#extended-graduation-rates)
- [Diploma Types](#diploma-types)
- [Timing and Reporting](#timing-and-reporting)
- [Cross-State Comparability](#cross-state-comparability)
- [Subgroup Graduation Rates](#subgroup-graduation-rates)
- [Common Pitfalls](#common-pitfalls)

## What is ACGR?

The **Adjusted Cohort Graduation Rate (ACGR)** is the federal standard for calculating high school graduation rates, mandated since 2008 and reported via EDFacts.

### Purpose

- Provide standardized graduation rate calculation
- Enable meaningful comparisons (within states)
- Track student outcomes for accountability
- Required under ESSA for high school accountability

### Historical Context

| Period | Graduation Rate Method |
|--------|------------------------|
| Pre-2008 | States used various methods |
| 2008 | ACGR regulations issued |
| 2010-11 | First ACGR data reported |
| Present | ACGR is federal standard |

## ACGR Calculation

### Basic Formula

```
ACGR = (Graduates with Regular Diploma) / (Adjusted Cohort) × 100
```

### Step-by-Step Calculation

1. **Identify original cohort**: All first-time 9th graders in a given year
2. **Adjust cohort**: Add transfers in, subtract legitimate removals
3. **Count graduates**: Students earning regular diplomas within 4 years
4. **Calculate rate**: Graduates ÷ Adjusted Cohort × 100

### What Counts as "On-Time"

| 4-Year ACGR | Definition |
|-------------|------------|
| Cohort entry | Fall of 9th grade year |
| Graduate by | End of 4th year (typically summer) |
| Time allowed | 4 academic years |

### Example Calculation

| Component | Count |
|-----------|-------|
| Original 9th grade cohort (Fall 2019) | 500 |
| Transfers in | +25 |
| Transfers out (documented) | -20 |
| Emigrated | -5 |
| Deceased | -2 |
| **Adjusted cohort** | **498** |
| Graduates with regular diploma (by 2023) | 423 |
| **4-Year ACGR** | **84.9%** |

## Cohort Adjustments

### Legitimate Removals from Cohort

Students can be removed from the cohort only for specific reasons:

| Removal Reason | Documentation Required |
|----------------|------------------------|
| Transfer to another school | Documented enrollment elsewhere |
| Transfer to another country | Documentation of emigration |
| Transfer to private school | Confirmation from receiving school |
| Death | Death certificate |

### Important: What Does NOT Remove from Cohort

| Situation | Impact on Cohort |
|-----------|------------------|
| Dropout | Remains in cohort (non-graduate) |
| GED completion | Remains in cohort (non-graduate in ACGR) |
| Missing/unknown | Remains in cohort (non-graduate) |
| Incarceration | Remains in cohort |
| Homeschool (unverified) | Remains in cohort |

### Transfer Documentation Requirements

States must have documented confirmation that students:
- Enrolled in another public school, OR
- Enrolled in a private school, OR
- Left the country

**If undocumented, student remains in cohort as non-graduate.**

## Extended Graduation Rates

EDFacts also reports extended graduation rates for students who take longer:

### Rate Types

| Rate | Definition | First Available |
|------|------------|-----------------|
| 4-year ACGR | Graduate within 4 years | 2010-11 |
| 5-year ACGR | Graduate within 5 years | 2011-12 |
| 6-year ACGR | Graduate within 6 years | 2012-13 |
| 7-year ACGR | Graduate within 7 years | Some states |

### Why Extended Rates Matter

| Population | Why Important |
|------------|---------------|
| Students with disabilities | May need additional time |
| English learners | Language acquisition takes time |
| Credit-deficient students | May need extra time to recover credits |
| Over-age students | Started high school older |

### Comparing 4-Year to Extended Rates

```python
# Understanding the graduation rate progression
cohort_rates = {
    "4-year ACGR": 85.0,
    "5-year ACGR": 88.5,  # +3.5 pp
    "6-year ACGR": 89.2,  # +0.7 pp additional
}
# Most late graduates finish in year 5
```

### Using Extended Rates

| Use Case | Which Rate |
|----------|------------|
| On-time completion | 4-year ACGR |
| Ultimate completion | 5- or 6-year ACGR |
| Students with disabilities | Consider extended rates |
| Full picture | Report all available rates |

## Diploma Types

### Regular Diploma (Counts in ACGR)

Only students receiving a **regular high school diploma** count as graduates:

| Counts as Graduate | Does NOT Count |
|--------------------|----------------|
| Standard diploma | GED/equivalency |
| Endorsed diploma | Certificate of completion |
| Honors diploma | Certificate of attendance |
| State-approved regular diploma | Alternative credential |

### Why GED Doesn't Count

| Reason | Explanation |
|--------|-------------|
| Different credential | Not a high school diploma |
| Different pathway | Often pursued after dropout |
| Policy intent | Incentivize diploma completion |
| Federal definition | ACGR specifically requires diploma |

### Alternative Credentials

Students receiving these are counted as **non-graduates** in ACGR:
- General Educational Development (GED)
- High School Equivalency Test (HiSET)
- Certificate of completion
- IEP diploma (in most states)
- Special education certificate

### State Variation in Diploma Types

Some states have multiple diploma pathways:
- Standard diploma
- Advanced/honors diploma
- Career/technical diploma
- All count as graduates if state-approved regular diplomas

## Timing and Reporting

### Cohort Year vs. Graduation Year

| Cohort Enters 9th Grade | 4-Year Graduation | Data Reported |
|-------------------------|-------------------|---------------|
| Fall 2019 | Spring/Summer 2023 | 2023-24 school year |
| Fall 2020 | Spring/Summer 2024 | 2024-25 school year |

### Data Lag

Graduation data has a **1-year lag**:
- School year 2023-24 reporting includes 2022-23 graduates
- Data for Class of 2023 available in fall 2024

### Reporting Timeline

| Event | Typical Timing |
|-------|----------------|
| Students graduate | May-August |
| States compile data | September-December |
| EDFacts submission | January-March |
| Public release | Fall of following year |

## Cross-State Comparability

### Better Than Assessment Data

ACGR is **more comparable** across states than proficiency rates because:

| Factor | ACGR | Assessment |
|--------|------|------------|
| Definition | Federally standardized | State-specific |
| Calculation | Same formula everywhere | Different tests |
| Outcome | Diploma yes/no | Test score thresholds |

### Remaining Variations

Despite standardization, some variation exists:

| Source of Variation | Impact |
|---------------------|--------|
| Graduation requirements | States have different course requirements |
| Exit exams | Some states require, some don't |
| Documentation practices | Transfer tracking varies |
| State accountability pressure | May affect practices |

### Interpretation Guidance

| Comparison | Validity |
|------------|----------|
| Within state over time | Valid |
| Across states | Reasonably valid (use caution) |
| Subgroups across states | Reasonably valid (use caution) |

## Subgroup Graduation Rates

### Required Subgroups

ACGR must be reported for these subgroups. In the Portal data, subgroups are represented as **filter columns** with integer codes, not a single "subgroup" column with string codes.

| Subgroup | NCES Code | Portal Column | Portal Filter Value |
|----------|-----------|---------------|---------------------|
| All students | ALL | race (or any filter col) | `99` |
| Economically disadvantaged | ECODIS | econ_disadvantaged | `1` |
| Students with disabilities | CWD | disability | `1` |
| English learners | LEP | lep | `1` |
| Homeless | HOM | homeless | `1` |
| Foster care | FCS | foster_care | `1` |
| Each race/ethnicity | Multiple | race | `1-7` |

> **Note:** `migrant` and `military_connected` columns are NOT present in grad rate datasets (only in assessment datasets).

### Subgroup Graduation Gaps

Typical patterns in graduation data:

| Comparison | Typical Gap |
|------------|-------------|
| All students vs. SWD | 15-25 percentage points |
| White vs. Black students | 5-15 percentage points |
| White vs. Hispanic students | 5-15 percentage points |
| All students vs. EL | 10-20 percentage points |

### Suppression in Subgroup Data

Small subgroups are heavily suppressed:
- N-size requirements apply
- Smaller schools have more suppression
- Use range/midpoint variables when available

## Common Pitfalls

### Pitfall 1: Confusing Cohort Year and Graduation Year

```python
# Confusing: Which year is which?
# year=2022 in EDFacts refers to the reporting year
# The cohort entered 9th grade 4 years earlier

def cohort_entry_year(reporting_year):
    """Calculate when cohort entered 9th grade."""
    return reporting_year - 4
    
# Example: 2022 graduation data = Fall 2018 9th grade cohort
```

### Pitfall 2: Treating GED Completers as Graduates

```python
# WRONG: Including GED in graduation count
total_completers = diploma_grads + ged_completers  # INCORRECT

# CORRECT: ACGR uses only diploma graduates
acgr_numerator = diploma_grads  # Regular diploma only
```

### Pitfall 3: Ignoring Extended Rates

When analyzing students with disabilities or EL students:

```python
# Limited view
swd_4year = 65.0  # Students with disabilities, 4-year

# Better view
swd_rates = {
    "4-year": 65.0,
    "5-year": 72.0,  # Many complete in year 5
    "6-year": 74.5
}
```

### Pitfall 4: Comparing Pre- and Post-ACGR Data

| Period | Method | Comparability |
|--------|--------|---------------|
| Before 2010-11 | Various state methods | NOT comparable to ACGR |
| 2010-11 onward | ACGR | Comparable within ACGR era |

### Pitfall 5: Not Accounting for Cohort Adjustments

Schools with high mobility may have:
- Many transfers in/out
- Large cohort adjustments
- Rates affected by documentation quality

## Data Variables in EDFacts

### Graduation Rate Variables

> **Empirically verified** from 2019 grad rate parquet data.

| Variable | Description | Portal Type |
|----------|-------------|-------------|
| `grad_rate_midpt` | Graduation rate, midpoint or exact value | Int64 |
| `grad_rate_low` | Graduation rate, lower bound (null when exact) | Int64 |
| `grad_rate_high` | Graduation rate, upper bound (null when exact) | Int64 |
| `cohort_num` | Number of students in adjusted cohort | Int64 |

> **Note:** The cohort variable is `cohort_num`, NOT `cohort_count`. There is no `grad_count` column. The `grad_rate_midpt` is Int64, not Float64.

### Fetching Graduation Rate Data

```python
# Fetch graduation rate data via mirror system
grad_data = fetch_yearly_from_mirrors(
    path_template="edfacts/schools_edfacts_grad_rates_{year}",
    years=[2018, 2019],
)

# Filter to California
ca_grads = grad_data.filter(pl.col("fips") == 6)

# Use midpoint for analysis
ca_grads.select([
    "ncessch",
    "school_name",
    "grad_rate_midpt"  # Use midpoint
])
```

## Analysis Best Practices

### Recommended Approaches

1. **Use appropriate rate for question**
   - On-time completion: 4-year ACGR
   - Ultimate completion: Extended rates

2. **Account for subgroup differences**
   - Report disaggregated rates
   - Note suppression

3. **Consider cohort size**
   - Small cohorts have more variability
   - Weight by cohort size for aggregations

4. **Document limitations**
   - Note suppressed data
   - Acknowledge cross-state variation

### Example: Comprehensive Graduation Analysis

> **Note:** Grad rate data uses filter columns (race, lep, disability, econ_disadvantaged, etc.) with integer codes, NOT a single "subgroup" column with string codes.

```python
def comprehensive_grad_analysis(df, state_fips, year):
    """Analyze graduation rates with appropriate context."""

    state_data = (df
        .filter(pl.col("fips") == state_fips)
        .filter(pl.col("year") == year)
        .filter(pl.col("grad_rate_midpt") >= 0)  # Exclude missing codes
    )

    # Overall rate: race=99 (total), all other filter cols=99 (total)
    overall = state_data.filter(
        (pl.col("race") == 99) &
        (pl.col("lep") == 99) &
        (pl.col("disability") == 99) &
        (pl.col("econ_disadvantaged") == 99)
    )

    # Economically disadvantaged students
    econ_dis = state_data.filter(pl.col("econ_disadvantaged") == 1)

    # Students with disabilities
    cwd = state_data.filter(pl.col("disability") == 1)

    # English learners
    el = state_data.filter(pl.col("lep") == 1)

    all_rate = overall["grad_rate_midpt"].mean()

    # Note: gaps are calculated per-subgroup filter column
    print(f"Overall rate: {all_rate:.1f}")
    for label, subgroup_df in [("Econ Dis", econ_dis), ("CWD", cwd), ("EL", el)]:
        sub_rate = subgroup_df["grad_rate_midpt"].mean()
        print(f"{label}: {sub_rate:.1f} (gap: {sub_rate - all_rate:.1f})")
```

## Federal Guidance

### Key Regulations

| Regulation | Content |
|------------|---------|
| 34 CFR 200.19 | ACGR definition and calculation |
| ESSA Section 1111 | Graduation rate requirements |
| ED Guidance (2017) | Non-regulatory guidance on ACGR |

### Compliance Requirements

| Requirement | Details |
|-------------|---------|
| Report ACGR | Required for all high schools |
| Report subgroups | If n-size met |
| Include in accountability | High school indicator |
| Extended rates | Optional but encouraged |

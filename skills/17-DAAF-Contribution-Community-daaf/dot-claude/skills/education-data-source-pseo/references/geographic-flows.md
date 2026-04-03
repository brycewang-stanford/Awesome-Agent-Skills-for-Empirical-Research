# Geographic Flows

Where graduates work after completion: employment by Census Division and in-state retention.

> **Portal Integer Encoding:** The `census_division` column contains integers 1-9, plus `99` for aggregates across all divisions.

## Contents

- [Overview](#overview)
- [Census Divisions](#census-divisions)
- [Geographic Flow Variables](#geographic-flow-variables)
- [In-State Employment](#in-state-employment)
- [Analysis Patterns](#analysis-patterns)
- [Limitations](#limitations)

## Overview

The Employment Flows tabulations include geographic employment data showing where graduates work:

- **Census Division**: 9 regions covering the U.S.
- **In-state**: Whether graduate works in the same state as their institution

Geographic flows help answer:
- Are graduates staying in-state or leaving?
- Which regions attract graduates from specific programs?
- How do migration patterns vary by field of study?

## Census Divisions (Portal Integer Encoding)

PSEO reports employment by the 9 Census Divisions:

| Code | Division | States |
|------|----------|--------|
| `1` | New England | CT, ME, MA, NH, RI, VT |
| `2` | Middle Atlantic | NJ, NY, PA |
| `3` | East North Central | IL, IN, MI, OH, WI |
| `4` | West North Central | IA, KS, MN, MO, NE, ND, SD |
| `5` | South Atlantic | DE, DC, FL, GA, MD, NC, SC, VA, WV |
| `6` | East South Central | AL, KY, MS, TN |
| `7` | West South Central | AR, LA, OK, TX |
| `8` | Mountain | AZ, CO, ID, MT, NV, NM, UT, WY |
| `9` | Pacific | AK, CA, HI, OR, WA |
| `99` | All divisions | Aggregate across all divisions |

### Division Map Reference

```
┌─────────────────────────────────────────────────────────────┐
│     9              4                1                       │
│  Pacific    West North       New England                    │
│             Central                                         │
│     8              3           2                            │
│  Mountain   East North    Middle                            │
│             Central       Atlantic                          │
│     7              6           5                            │
│  West South  East South   South                             │
│  Central     Central      Atlantic                          │
└─────────────────────────────────────────────────────────────┘
```

## Geographic Flow Variables

### Employment by Division (Portal Schema)

In Portal data, employment counts are accessed via `employed_grads_count_f`, filtered by `years_after_grad` and `census_division`:

| Portal Variable | Description |
|-----------------|-------------|
| `employed_grads_count_f` | Employed graduates count (filter by `years_after_grad` for Y1/Y5/Y10) |
| `employed_instate_grads_count` | Employed in institution's state |
| `jobless_m_emp_grads_count` | Non-employed or marginally employed |
| `census_division` | Census Division of employment (1-9, 99 for aggregate) |
| `years_after_grad` | `1`, `5`, or `10` |

### Querying by Division

```python
import polars as pl

# Fetch PSEO data
df = fetch_from_mirrors("pseo/colleges_pseo_2020")

# Employment in Pacific Division (9), 1 year post-graduation
pacific = df.filter(
    (pl.col("census_division") == 9)
    & (pl.col("unitid") == 228778)       # UT Austin
    & (pl.col("degree_level") == 5)       # Bachelor's
    & (pl.col("years_after_grad") == 1)
    & (pl.col("employed_grads_count_f") > 0)
)

# Get all divisions for an institution
all_divisions = df.filter(
    (pl.col("unitid") == 228778)
    & (pl.col("years_after_grad") == 1)
    & (pl.col("census_division") != 99)   # Exclude aggregate
    & (pl.col("employed_grads_count_f") > 0)
).select("census_division", "employed_grads_count_f")
```

## In-State Employment

### In-State Variables (Portal Schema)

In Portal data, in-state employment is in the `employed_instate_grads_count` column, filtered by `years_after_grad`:

| Portal Variable | `years_after_grad` | Census API Equivalent |
|-----------------|--------------------|-----------------------|
| `employed_instate_grads_count` | `1` | `Y1_GRADS_EMP_INSTATE` |
| `employed_instate_grads_count` | `5` | `Y5_GRADS_EMP_INSTATE` |
| `employed_instate_grads_count` | `10` | `Y10_GRADS_EMP_INSTATE` |

### Calculating Retention Rate

```python
# In-state retention = employed_instate_grads_count / employed_grads_count_f
# Filter to census_division == 99 (aggregate) for total employed count
```

**Example** (using Portal variable names):
- `employed_grads_count_f` = 1,000 (where `years_after_grad=1`, `census_division=99`)
- `employed_instate_grads_count` = 650 (where `years_after_grad=1`)
- In-state retention = 65%

### Interpreting In-State Data

| Retention Rate | Interpretation |
|----------------|----------------|
| > 80% | High retention (likely strong local job market) |
| 60-80% | Moderate retention |
| < 60% | Low retention (graduates leaving for opportunities elsewhere) |

## Analysis Patterns

### Brain Drain Analysis

Compare in-state employment rates across institutions or programs:

```python
# Pseudo-code for brain drain analysis
retention_by_program = {}
for cip_code in programs:
    total_emp = get_y1_grads_emp(institution, cip_code)
    instate_emp = get_y1_grads_emp_instate(institution, cip_code)
    retention_by_program[cip_code] = instate_emp / total_emp
```

### Migration Flow Analysis

Show where graduates from an institution/state work:

| From Institution State | To Division | `employed_grads_count_f` |
|------------------------|-------------|--------------------------|
| Texas (48) | West South Central (7) | 8,500 |
| Texas (48) | Pacific (9) | 1,200 |
| Texas (48) | Mountain (8) | 800 |
| Texas (48) | South Atlantic (5) | 600 |

### Comparative Regional Analysis

Compare the same program across institutions in different regions:

```
Computer Science (CIP=11) Bachelor's, Y1 Employment by Division:
- UT Austin: 70% in West South Central
- UC Berkeley: 85% in Pacific
- Georgia Tech: 45% in South Atlantic
```

## Limitations

### Geographic Granularity

| Limitation | Impact |
|------------|--------|
| Division level only | Cannot distinguish California from Oregon |
| No state-level flows | Cannot track state-to-state migration precisely |
| No metro-area data | Cannot identify specific job markets |

### Interpretation Challenges

| Issue | Consideration |
|-------|---------------|
| Remote work | Employment location may not equal residence |
| Multi-state employers | Assignment to division may be headquarters vs. work site |
| Federal employment | OPM data may have different geographic coding |

### Missing Data

Flows data can be missing when:
- Fewer than 30 graduates in a cell (suppressed)
- Institution recently joined PSEO
- Program has insufficient completers

### Example: Complete Geographic Profile

For Texas Engineering Bachelor's graduates (hypothetical data):

```
Institution: Texas Higher Education Coordinating Board (State aggregate)
CIP: 14 (Engineering)
Degree Level: 5 (Bachelor's)
Cohort: "2016-2018"

Geographic Distribution (Y1):
┌────────────────────────┬────────────┬─────────┐
│ Division               │ Y1_EMP     │ Share   │
├────────────────────────┼────────────┼─────────┤
│ West South Central (7) │ 12,500     │ 62%     │
│ Pacific (9)            │ 2,800      │ 14%     │
│ Mountain (8)           │ 1,600      │ 8%      │
│ East North Central (3) │ 1,000      │ 5%      │
│ South Atlantic (5)     │ 900        │ 4%      │
│ Other divisions        │ 1,200      │ 6%      │
├────────────────────────┼────────────┼─────────┤
│ Total Employed         │ 20,000     │ 100%    │
│ In-State (Texas)       │ 11,500     │ 57.5%   │
│ Non-Employed/Marginal  │ 3,000      │ --      │
└────────────────────────┴────────────┴─────────┘
```

**Insights**:
- 62% stay in West South Central (includes Texas)
- 57.5% specifically stay in Texas
- Pacific region (14%) is second-largest destination (likely California tech)
- Mountain region (8%) attracts some (Colorado, Arizona tech hubs)

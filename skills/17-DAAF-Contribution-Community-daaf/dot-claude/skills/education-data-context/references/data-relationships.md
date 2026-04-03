# Education Data Portal: Data Relationships

This reference explains how Education Data Portal tables relate to each other, identifier formats, and how to properly join datasets.

## Identifier Relationships

### K-12 Identifier Hierarchy

```
State FIPS (2 digits)
  └── LEAID (7 chars) = State FIPS + District ID
        └── NCESSCH (12 chars) = LEAID + School ID
```

### NCESSCH (School Identifier)

**Format**: 12 characters

```
Position:  [01-02][03-07][08-12]
Content:   [FIPS ][DIST ][SCHL ]
Example:   06 00001 00100
           ├─ 06 = California
           ├─ 00001 = District portion
           └─ 00100 = School portion
```

**Key properties**:
- First 2 characters = State FIPS code
- First 7 characters = LEAID
- Unique nationally
- Can change when school moves districts, merges, or reopens

### LEAID (District Identifier)

**Format**: 7 characters

```
Position:  [01-02][03-07]
Content:   [FIPS ][DIST ]
Example:   06 00001
           ├─ 06 = California
           └─ 00001 = State-assigned district ID
```

**Key properties**:
- First 2 characters = State FIPS code
- Unique nationally
- Can change when districts merge, split

### Deriving Relationships

```python
import polars as pl

# Extract LEAID from NCESSCH
df = df.with_columns(
    pl.col("ncessch").str.slice(0, 7).alias("leaid")
)

# Extract State FIPS from LEAID
df = df.with_columns(
    pl.col("leaid").str.slice(0, 2).alias("fips")
)

# Extract State FIPS from NCESSCH
df = df.with_columns(
    pl.col("ncessch").str.slice(0, 2).alias("fips")
)
```

### Postsecondary Identifier Relationships

```
OPEID6 (6 digits) - Institution family
  └── OPEID (8 digits) - Specific branch/location
        └── UNITID - IPEDS reporting unit (may differ)
```

### UNITID

**Definition**: Unique identifier for IPEDS reporting unit

**Key properties**:
- Assigned by NCES
- Primary key for IPEDS data
- Generally one per campus
- Used by both IPEDS and College Scorecard

### OPEID

**Definition**: Office of Postsecondary Education ID

**Key properties**:
- Used for Title IV administration
- 8 digits (6-digit root + 2-digit branch)
- Main campus typically ends in 00
- Branches have different suffixes

### OPEID6

**Definition**: First 6 digits of OPEID

**Key properties**:
- Identifies institution family
- Main campus and all branches share same OPEID6
- Useful for grouping campuses

### UNITID vs. OPEID

| Scenario | UNITID | OPEID |
|----------|--------|-------|
| Single campus | 1 | 1 |
| Multi-branch (separate IPEDS reporting) | Multiple | 1 OPEID6, different full OPEIDs |
| Multi-branch (consolidated IPEDS reporting) | 1 | Multiple |

```python
# Note: UNITID and OPEID don't always have 1:1 relationship
# Always check your specific institutions
```

## Joining Tables

### Schools to Districts

```python
import polars as pl

# Load school-level CCD directory from mirror
schools = pl.read_parquet("data/raw/schools_ccd_directory.parquet").filter(
    pl.col("year") == 2020
)

# Load district-level CCD directory from mirror
districts = pl.read_parquet("data/raw/school-districts_lea_directory.parquet").filter(
    pl.col("year") == 2020
)

# Join on leaid and year
merged = schools.join(
    districts,
    on=["leaid", "year"],
    how="left",
    suffix="_district"
)

# Check for unmatched schools
unmatched = merged.filter(pl.col("lea_name_district").is_null()).height
print(f"Schools without district match: {unmatched}")
```

### Schools Across Sources (CCD to CRDC)

```python
import polars as pl

# Load CCD directory from mirror
ccd = pl.read_parquet("data/raw/schools_ccd_directory.parquet").filter(
    pl.col("year") == 2017
)

# Load CRDC discipline from mirror (yearly files)
crdc = pl.read_parquet("data/raw/schools_crdc_discipline_k12_2017.parquet")

# Join on ncessch (CRDC is biennial - verify year alignment)
merged = ccd.join(
    crdc,
    on="ncessch",
    how="left",
    suffix="_crdc"
)

# Check coverage
crdc_coverage = merged.filter(
    pl.col("tot_discw_iss").is_not_null()
).height / merged.height
print(f"CRDC coverage: {crdc_coverage:.1%}")
```

### Colleges Across Sources (IPEDS to Scorecard)

```python
import polars as pl

# Both IPEDS and Scorecard use UNITID
ipeds = pl.read_parquet("data/raw/colleges_ipeds_directory.parquet").filter(
    pl.col("year") == 2020
)

scorecard = pl.read_parquet("data/raw/colleges_scorecard_earnings.parquet").filter(
    pl.col("year") == 2014  # Cohort year
)

# Join on unitid
merged = ipeds.join(
    scorecard,
    on="unitid",
    how="left",
    suffix="_scorecard"
)

# Note: Not all institutions in both sources
```

## Year Alignment Issues

### Source Timing Differences

| Source 1 | Source 2 | Alignment Issue |
|----------|----------|-----------------|
| CCD | CRDC | CRDC is biennial |
| IPEDS enrollment | IPEDS grad rates | Grad rates are cohort-based |
| Scorecard earnings | IPEDS | Earnings lag enrollment by 6-10 years |
| CCD | EDFacts | Generally aligned |
| IPEDS | Scorecard | Cohort definitions differ |

### CRDC Biennial Alignment

```python
# CRDC available years: 2011, 2013, 2015, 2017, 2020, 2021
# Use matching CCD year

crdc_to_ccd_years = {
    2011: 2011,
    2013: 2013,
    2015: 2015,
    2017: 2017,
    2020: 2020,
    2021: 2021
}

def get_aligned_data(crdc_year):
    crdc = pl.read_parquet(
        f"data/raw/schools_crdc_discipline_k12_{crdc_year}.parquet"
    )

    ccd_year = crdc_to_ccd_years[crdc_year]
    ccd = pl.read_parquet("data/raw/schools_ccd_directory.parquet").filter(
        pl.col("year") == ccd_year
    )

    return crdc.join(ccd, on="ncessch", how="left")
```

### IPEDS Cohort Alignment

```python
# Graduation rates for year=2015 means cohort entered in 2015
# 150% completion measured 6 years later (2021 for 4-year schools)

def get_ipeds_with_outcomes(enrollment_year):
    """
    Get enrollment data aligned with graduation outcomes
    Note: Cohort outcomes not available until 6+ years later
    """
    enrollment = pl.read_parquet(
        "data/raw/colleges_ipeds_fall_enrollment.parquet"
    ).filter(pl.col("year") == enrollment_year)

    # Graduation rate cohort year = enrollment year
    # But outcomes measured later
    grad_rates = pl.read_parquet(
        "data/raw/colleges_ipeds_grad_rates_200pct.parquet"
    ).filter(pl.col("year") == enrollment_year)

    return enrollment.join(grad_rates, on="unitid", how="left")
```

### Scorecard Earnings Lag

```python
# Scorecard earnings are measured 6-10 years after entry
# year field refers to measurement year or cohort year depending on variable

# Example: If you want earnings for students who enrolled ~2014
# Look at ~2020 (6-year) or ~2024 (10-year) measurement years
# But data release lags by 1-2 additional years
```

## Common Join Pitfalls

### 1. ID Changes Over Time

```python
# Verify ID stability before joining across years
def check_id_stability(df_year1, df_year2, id_col, year1, year2):
    ids_y1 = set(df_year1[id_col].to_list())
    ids_y2 = set(df_year2[id_col].to_list())
    
    dropped = ids_y1 - ids_y2
    added = ids_y2 - ids_y1
    stable = ids_y1 & ids_y2
    
    print(f"IDs in {year1} but not {year2}: {len(dropped)}")
    print(f"IDs in {year2} but not {year1}: {len(added)}")
    print(f"Stable IDs: {len(stable)}")
    print(f"Stability rate: {len(stable)/len(ids_y1):.1%}")
    
    return {"dropped": dropped, "added": added, "stable": stable}
```

### 2. Year Misalignment

```python
# WRONG: Joining without considering year
merged = source1.join(source2, on="ncessch")  # May get wrong year match

# RIGHT: Always include year in join when merging same-year data
merged = source1.join(source2, on=["ncessch", "year"])

# OR when sources have different year granularity:
# Filter to specific years first, then join without year column
source1_2017 = source1.filter(pl.col("year") == 2017)
source2_2017 = source2.filter(pl.col("year") == 2017)
merged = source1_2017.join(source2_2017.drop("year"), on="ncessch")
```

### 3. Missing Coverage

```python
# Not all schools/colleges appear in all sources
# Always check join coverage

def check_join_coverage(left_df, merged_df, right_key_col):
    original = left_df.height
    matched = merged_df.filter(pl.col(right_key_col).is_not_null()).height
    
    coverage = matched / original * 100
    print(f"Join coverage: {coverage:.1f}%")
    
    if coverage < 90:
        print("WARNING: Significant data loss from join")
    
    return coverage
```

### 4. Duplicate Keys

```python
# Some sources have multiple rows per institution
# (e.g., branch campuses, reporting units)

# Check for duplicates before joining
def check_duplicates(df, key_col):
    dup_count = df.group_by(key_col).count().filter(
        pl.col("count") > 1
    )
    
    if dup_count.height > 0:
        print(f"WARNING: {dup_count.height} duplicate keys found")
        print("Consider aggregating or filtering before join")
    
    return dup_count
```

## Aggregation Relationships

### School to District Aggregation

```
Schools aggregate to → Districts → States
```

```python
# Aggregate school enrollment to district
district_enrollment = schools.group_by(["leaid", "year"]).agg(
    pl.col("enrollment").sum().alias("total_enrollment"),
    pl.col("ncessch").count().alias("school_count")
)

# IMPORTANT: Prefer district-level totals from district endpoints
# School sums may differ from official district totals
```

### Why Aggregated ≠ Reported

| Reason | Impact |
|--------|--------|
| Non-school students | District serves students not in schools |
| Reporting timing | Schools and districts may report at different times |
| Definition differences | District total may use different counting rules |
| Missing schools | Some schools may not report |

**Recommendation**: Use district-level data from district endpoints when available.

## Census Geography Links

### NHGIS Endpoints

The Education Data Portal links schools/colleges to Census geography via NHGIS:

```python
import polars as pl

# Get school-census geography crosswalk from mirror
nhgis = pl.read_parquet("data/raw/schools_nhgis_geog_2010.parquet").filter(
    pl.col("year") == 2020
)

# Join to get census tract for each school
schools_with_tract = schools.join(
    nhgis,
    on="ncessch",
    how="left"
)
```

### Census Vintage Matching

| Data Year | Census Vintage |
|-----------|----------------|
| 2011-2019 | 2010 Census |
| 2020+ | 2020 Census or 2010 (check documentation) |
| Pre-2011 | 2000 or 2010 Census |

Use appropriate vintage for your time period.

### Geographic Identifiers

| Level | Identifier Format |
|-------|-------------------|
| State | 2-digit FIPS |
| County | 5-digit FIPS (state + county) |
| Census tract | 11-digit GEOID |
| Block group | 12-digit GEOID |

## State FIPS Code Reference

Common FIPS codes:

| Code | State | Code | State |
|------|-------|------|-------|
| 01 | Alabama | 28 | Mississippi |
| 02 | Alaska | 29 | Missouri |
| 04 | Arizona | 30 | Montana |
| 05 | Arkansas | 31 | Nebraska |
| 06 | California | 32 | Nevada |
| 08 | Colorado | 33 | New Hampshire |
| 09 | Connecticut | 34 | New Jersey |
| 10 | Delaware | 35 | New Mexico |
| 11 | DC | 36 | New York |
| 12 | Florida | 37 | North Carolina |
| 13 | Georgia | 38 | North Dakota |
| 15 | Hawaii | 39 | Ohio |
| 16 | Idaho | 40 | Oklahoma |
| 17 | Illinois | 41 | Oregon |
| 18 | Indiana | 42 | Pennsylvania |
| 19 | Iowa | 44 | Rhode Island |
| 20 | Kansas | 45 | South Carolina |
| 21 | Kentucky | 46 | South Dakota |
| 22 | Louisiana | 47 | Tennessee |
| 23 | Maine | 48 | Texas |
| 24 | Maryland | 49 | Utah |
| 25 | Massachusetts | 50 | Vermont |
| 26 | Michigan | 51 | Virginia |
| 27 | Minnesota | 53 | Washington |
| | | 54 | West Virginia |
| | | 55 | Wisconsin |
| | | 56 | Wyoming |
| | | 72 | Puerto Rico |

Note: FIPS codes skip some numbers (e.g., no 03, 07, 14, etc.)

## Quick Reference: Common Joins

| Task | Join Key(s) | Notes |
|------|-------------|-------|
| Schools to districts | `leaid`, `year` | Same source |
| CCD to CRDC | `ncessch` | Check year alignment (CRDC biennial) |
| CCD to EDFacts | `ncessch`, `year` | Same year alignment |
| IPEDS to Scorecard | `unitid` | Different cohort definitions |
| Schools to census | `ncessch` | Via NHGIS; check vintage |
| Any source to state data | `fips` | Extract from identifiers |

## Portal Integer Encoding Note

When joining or filtering, remember that the Portal uses **integer codes**, not strings:

| Variable | Integer Values | NOT These Strings |
|----------|----------------|-------------------|
| Race | 1-7, 99 (total) | WH, BL, HI |
| Sex | 1, 2, 99 (total) | M, F |
| Grade | -1 to 13, 99 (total) | PK, KG, 01 |
| FIPS | Integers (6, 36, 48) | CA, NY, TX |

**SEMANTIC TRAP:** `grade = -1` means **Pre-K**, NOT missing data!

## Validation After Joining

```python
# --- Post-Join Validation ---
print(f"Join type: {join_type}")
print(f"Keys: {key_cols}")
print(f"Left rows: {left_df.height:,}")
print(f"Merged rows: {merged_df.height:,}")

if join_type == "left":
    if merged_df.height != left_df.height:
        print(f"[WARN] Row count changed: {left_df.height:,} → {merged_df.height:,} (duplicates in right?)")
    else:
        print("[PASS] Row count preserved")

# Check for unexpected nulls
null_counts = merged_df.select([
    pl.col(c).is_null().sum().alias(f"{c}_nulls")
    for c in merged_df.columns
])

print("\nNull counts after join:")
print(null_counts)
```

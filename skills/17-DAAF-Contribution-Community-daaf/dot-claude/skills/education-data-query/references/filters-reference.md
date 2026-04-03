# Filters Reference

Complete reference for all filter variables available in the Education Data Portal API.

## Filter Syntax

### Single Filter
```
?fips=6
```

### Multiple Filters (AND logic)
```
?fips=6&charter=1&school_level=3
```

### Multiple Values (OR logic)
```
?fips=6,36,48
```

### Year Filter
```
?year=2020
?year=2018,2019,2020
```

## Universal Filters

Available across all endpoints.

| Filter | Type | Description | Example |
|--------|------|-------------|---------|
| `year` | integer | Academic year | `?year=2020` |
| `fips` | integer | State FIPS code | `?fips=6` |

## School Filters (CCD)

### Identifier Filters

| Filter | Type | Description | Example |
|--------|------|-------------|---------|
| `ncessch` | string | NCES school ID (12 chars) | `?ncessch=060000000001` |
| `leaid` | string | District ID (7 chars) | `?leaid=0600001` |
| `ncessch_num` | integer | Numeric school ID | `?ncessch_num=60000000001` |

### School Type Filters

| Filter | Values | Description |
|--------|--------|-------------|
| `charter` | 0, 1 | Charter school (1=yes, 0=no) |
| `magnet` | 0, 1 | Magnet school |
| `virtual` | 0, 1, 2 | Virtual school (1=yes, 0=no, 2=supplemental) |
| `shared_time` | 0, 1 | Shared-time school |
| `school_level` | 0-4 | School level (see below) |
| `school_type` | 1-4 | School type (see below) |

**school_level values:**
| Value | Description |
|-------|-------------|
| 0 | Not applicable |
| 1 | Primary (elementary) |
| 2 | Middle |
| 3 | High |
| 4 | Other |

**school_type values:**
| Value | Description |
|-------|-------------|
| 1 | Regular school |
| 2 | Special education |
| 3 | Vocational |
| 4 | Alternative/other |

### Status Filters

| Filter | Values | Description |
|--------|--------|-------------|
| `school_status` | 1-8 | Operational status |
| `updated_status` | 1-8 | Updated operational status |

**school_status values:**
| Value | Description |
|-------|-------------|
| 1 | Open |
| 2 | Closed |
| 3 | New |
| 4 | Added |
| 5 | Changed boundary |
| 6 | Inactive |
| 7 | Future |
| 8 | Reopened |

### Title I Filters

| Filter | Values | Description |
|--------|--------|-------------|
| `title_i_eligible` | 0, 1 | Title I eligible |
| `title_i_school_wide` | 0, 1 | Title I school-wide program |

### Locale Filters

| Filter | Values | Description |
|--------|--------|-------------|
| `urban_centric_locale` | 11-43 | Urban-centric locale code |

**urban_centric_locale values:**
| Value | Description |
|-------|-------------|
| 11 | City, large |
| 12 | City, midsize |
| 13 | City, small |
| 21 | Suburb, large |
| 22 | Suburb, midsize |
| 23 | Suburb, small |
| 31 | Town, fringe |
| 32 | Town, distant |
| 33 | Town, remote |
| 41 | Rural, fringe |
| 42 | Rural, distant |
| 43 | Rural, remote |

## District Filters (CCD)

### Identifier Filters

| Filter | Type | Description | Example |
|--------|------|-------------|---------|
| `leaid` | string | NCES district ID (7 chars) | `?leaid=0600001` |
| `leaid_num` | integer | Numeric district ID | `?leaid_num=600001` |

### Agency Type Filter

| Filter | Values | Description |
|--------|--------|-------------|
| `agency_type` | 1-9 | Agency/district type |

**agency_type values:**
| Value | Description |
|-------|-------------|
| 1 | Regular local school district |
| 2 | Local school district component of supervisory union |
| 3 | Supervisory union |
| 4 | Regional education service agency |
| 5 | State-operated agency |
| 6 | Federally-operated agency |
| 7 | Charter school agency |
| 8 | Other education agency |
| 9 | Specialized public school district |

### Boundary Change Filter

| Filter | Values | Description |
|--------|--------|-------------|
| `boundary_change_indicator` | 0-3 | Boundary change type |

## College Filters (IPEDS)

### Identifier Filters

| Filter | Type | Description | Example |
|--------|------|-------------|---------|
| `unitid` | integer | IPEDS institution ID (6 digits) | `?unitid=166027` |
| `opeid` | string | OPE ID (8 chars) | `?opeid=00261100` |

### Sector Filter

| Filter | Values | Description |
|--------|--------|-------------|
| `sector` | 0-9 | Institution sector |

**sector values:**
| Value | Description |
|-------|-------------|
| 0 | Administrative unit |
| 1 | Public, 4-year or above |
| 2 | Private nonprofit, 4-year or above |
| 3 | Private for-profit, 4-year or above |
| 4 | Public, 2-year |
| 5 | Private nonprofit, 2-year |
| 6 | Private for-profit, 2-year |
| 7 | Public, less-than 2-year |
| 8 | Private nonprofit, less-than 2-year |
| 9 | Private for-profit, less-than 2-year |

### Control Filter

| Filter | Values | Description |
|--------|--------|-------------|
| `inst_control` | 1-3 | Institutional control |

**inst_control values:**
| Value | Description |
|-------|-------------|
| 1 | Public |
| 2 | Private nonprofit |
| 3 | Private for-profit |

### Institution Type Filters

| Filter | Values | Description |
|--------|--------|-------------|
| `hbcu` | 0, 1 | Historically Black College/University |
| `tribal_college` | 0, 1 | Tribal college |
| `degree_granting` | 0, 1 | Grants degrees |
| `hospital` | 0, 1 | Has hospital |
| `medical` | 0, 1 | Grants medical degree |
| `land_grant` | 0, 1 | Land grant institution |

### Carnegie Classification

| Filter | Values | Description |
|--------|--------|-------------|
| `inst_size` | 1-5 | Institution size category |
| `ccbasic` | various | Carnegie basic classification |

**inst_size values:**
| Value | Description |
|-------|-------------|
| 1 | Under 1,000 |
| 2 | 1,000-4,999 |
| 3 | 5,000-9,999 |
| 4 | 10,000-19,999 |
| 5 | 20,000 and above |

### Location Filters

| Filter | Values | Description |
|--------|--------|-------------|
| `locale` | 11-43 | Urban-centric locale (same as schools) |
| `region` | 0-9 | Bureau of Economic Analysis region |

## Enrollment Disaggregators

When fetching enrollment data, disaggregators are path parameters, not query filters.

**CRITICAL: URL Path Values vs. Data Column Values**

The Portal uses different representations in URL paths vs. actual data columns:

| Aspect | URL Path | Data Column |
|--------|----------|-------------|
| Pre-K | `grade-pk` | `grade = -1` |
| Kindergarten | `grade-k` | `grade = 0` |
| Grades 1-12 | `grade-1` to `grade-12` | `grade = 1` to `12` |
| Total | `grade-99` | `grade = 99` |

**SEMANTIC TRAP:** In the downloaded data, `grade = -1` means **Pre-Kindergarten**, NOT missing data!

```python
# WRONG - filters out Pre-K students!
df = df.filter(pl.col("grade") >= 0)

# RIGHT - Pre-K students have grade = -1
pre_k = df.filter(pl.col("grade") == -1)
k_12 = df.filter(pl.col("grade").is_between(0, 12))
total = df.filter(pl.col("grade") == 99)
```

### Grade Disaggregator

Use in path: `/enrollment/{year}/grade-{value}/`

| URL Path Value | Data Column Value | Description |
|----------------|-------------------|-------------|
| `pk` | -1 | Pre-kindergarten |
| `k` | 0 | Kindergarten |
| `1`-`12` | 1-12 | Grades 1-12 |
| `13` | 13 | Ungraded |
| `99` | 99 | Total (all grades) |

### Race Disaggregator

Use in path: `/enrollment/{year}/race/`

Returns records with `race` field (integer, not string codes):
| Value | Description |
|-------|-------------|
| 1 | White |
| 2 | Black |
| 3 | Hispanic |
| 4 | Asian |
| 5 | American Indian/Alaska Native |
| 6 | Native Hawaiian/Pacific Islander |
| 7 | Two or more races |
| 99 | Total |

**Note:** The Portal uses integers (1-7), NOT string codes like "WH", "BL", "HI", etc.

### Sex Disaggregator

Use in path: `/enrollment/{year}/sex/`

Returns records with `sex` field (integer, not string codes):
| Value | Description |
|-------|-------------|
| 1 | Male |
| 2 | Female |
| 3 | Another gender (IPEDS 2022+ only) |
| 4 | Unknown gender (IPEDS 2022+ only) |
| 9 | Unknown |
| 99 | Total |

**Note:** The Portal uses integers (1, 2), NOT string codes like "M", "F". Codes 3 and 4 appear only in IPEDS data starting 2022-23.

## Complete FIPS Code List

| Code | State | Code | State |
|------|-------|------|-------|
| 1 | Alabama | 28 | Mississippi |
| 2 | Alaska | 29 | Missouri |
| 4 | Arizona | 30 | Montana |
| 5 | Arkansas | 31 | Nebraska |
| 6 | California | 32 | Nevada |
| 8 | Colorado | 33 | New Hampshire |
| 9 | Connecticut | 34 | New Jersey |
| 10 | Delaware | 35 | New Mexico |
| 11 | District of Columbia | 36 | New York |
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

**Territories:**
| Code | Territory |
|------|-----------|
| 60 | American Samoa |
| 66 | Guam |
| 69 | Northern Mariana Islands |
| 72 | Puerto Rico |
| 78 | Virgin Islands |

## Filter Combinations

### Common School Queries

```python
# Charter high schools in California
"?fips=6&charter=1&school_level=3"

# Urban elementary schools
"?school_level=1&urban_centric_locale=11,12,13"

# Title I magnet schools in Texas
"?fips=48&title_i_eligible=1&magnet=1"

# Regular schools only (exclude special ed, vocational)
"?school_type=1"

# Open schools only
"?school_status=1"
```

### Common District Queries

```python
# Regular local districts in California
"?fips=6&agency_type=1"

# Charter school agencies
"?agency_type=7"
```

### Common College Queries

```python
# Public 4-year in California
"?fips=6&sector=1"

# HBCUs nationwide
"?hbcu=1"

# Large public universities
"?inst_control=1&inst_size=5"

# Community colleges in Texas
"?fips=48&sector=4"

# Private nonprofit 4-year
"?sector=2"

# All degree-granting institutions
"?degree_granting=1"
```

## Null Value Handling

Some filters accept special values for missing data:

- Use `-1` or `-2` to query for records with missing/null values
- Check API documentation for specific field behaviors

```python
# Schools with unknown charter status
"?charter=-1"
```

## Case Sensitivity

- Filter names are case-sensitive (use lowercase)
- String values are generally case-insensitive
- FIPS codes and IDs should match exactly

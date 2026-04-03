# Variable Codes Reference

Comprehensive reference for coded values used across Education Data Portal endpoints.

## Contents

- [State FIPS Codes](#state-fips-codes)
- [Grade Codes](#grade-codes)
- [Race/Ethnicity Codes](#raceethnicity-codes)
- [Sex Codes](#sex-codes)
- [School Level Codes](#school-level-codes)
- [School Type Codes](#school-type-codes)
- [Urban-Centric Locale Codes](#urban-centric-locale-codes)
- [Institution Control Codes](#institution-control-codes-colleges)
- [Institution Level Codes](#institution-level-codes-colleges)
- [Sector Codes](#sector-codes-colleges)
- [Award Level Codes](#award-level-codes)
- [Special Population Codes](#special-population-codes)
- [Missing Value Codes](#missing-value-codes)

---

## State FIPS Codes

Two-digit numeric codes for U.S. states and territories.

| FIPS | State | FIPS | State |
|------|-------|------|-------|
| 1 | Alabama | 30 | Montana |
| 2 | Alaska | 31 | Nebraska |
| 4 | Arizona | 32 | Nevada |
| 5 | Arkansas | 33 | New Hampshire |
| 6 | California | 34 | New Jersey |
| 8 | Colorado | 35 | New Mexico |
| 9 | Connecticut | 36 | New York |
| 10 | Delaware | 37 | North Carolina |
| 11 | District of Columbia | 38 | North Dakota |
| 12 | Florida | 39 | Ohio |
| 13 | Georgia | 40 | Oklahoma |
| 15 | Hawaii | 41 | Oregon |
| 16 | Idaho | 42 | Pennsylvania |
| 17 | Illinois | 44 | Rhode Island |
| 18 | Indiana | 45 | South Carolina |
| 19 | Iowa | 46 | South Dakota |
| 20 | Kansas | 47 | Tennessee |
| 21 | Kentucky | 48 | Texas |
| 22 | Louisiana | 49 | Utah |
| 23 | Maine | 50 | Vermont |
| 24 | Maryland | 51 | Virginia |
| 25 | Massachusetts | 53 | Washington |
| 26 | Michigan | 54 | West Virginia |
| 27 | Minnesota | 55 | Wisconsin |
| 28 | Mississippi | 56 | Wyoming |
| 29 | Missouri | | |

### Territories and Other

| FIPS | Territory |
|------|-----------|
| 60 | American Samoa |
| 64 | Federated States of Micronesia |
| 66 | Guam |
| 68 | Marshall Islands |
| 69 | Northern Mariana Islands |
| 70 | Palau |
| 72 | Puerto Rico |
| 74 | U.S. Minor Outlying Islands |
| 78 | U.S. Virgin Islands |
| 59 | Outlying Areas (aggregate) |

### Bureau of Indian Education

| FIPS | Description |
|------|-------------|
| 58 | Bureau of Indian Education (DoDEA) |

---

## Grade Codes

### Numeric Grade Codes

Used in response data:

| Code | Description |
|------|-------------|
| -1 | Pre-Kindergarten |
| 0 | Kindergarten |
| 1 | Grade 1 |
| 2 | Grade 2 |
| 3 | Grade 3 |
| 4 | Grade 4 |
| 5 | Grade 5 |
| 6 | Grade 6 |
| 7 | Grade 7 |
| 8 | Grade 8 |
| 9 | Grade 9 |
| 10 | Grade 10 |
| 11 | Grade 11 |
| 12 | Grade 12 |
| 13 | Adult Education |
| 14 | Ungraded |
| 99 | Total (all grades) |

### URL Grade Values

Used in endpoint URL paths:

| URL Value | Grade |
|-----------|-------|
| `grade-pk` | Pre-Kindergarten |
| `grade-k` | Kindergarten |
| `grade-1` | Grade 1 |
| `grade-2` | Grade 2 |
| `grade-3` | Grade 3 |
| `grade-4` | Grade 4 |
| `grade-5` | Grade 5 |
| `grade-6` | Grade 6 |
| `grade-7` | Grade 7 |
| `grade-8` | Grade 8 |
| `grade-9` | Grade 9 |
| `grade-10` | Grade 10 |
| `grade-11` | Grade 11 |
| `grade-12` | Grade 12 |
| `grade-13` | Adult Education |
| `grade-14` | Ungraded |
| `grade-99` | Total (all grades) |

**Example**: `/schools/ccd/enrollment/2022/grade-5/` for 5th grade enrollment

---

## Race/Ethnicity Codes

| Code | Description |
|------|-------------|
| 1 | White |
| 2 | Black or African American |
| 3 | Hispanic or Latino |
| 4 | Asian |
| 5 | American Indian or Alaska Native |
| 6 | Native Hawaiian or Other Pacific Islander |
| 7 | Two or More Races |
| 8 | Nonresident Alien (colleges only) |
| 9 | Unknown |
| 20 | Other / Not Specified |
| 99 | Total (all races) |

### Race Codes in Different Data Sources

| Source | Codes Available |
|--------|-----------------|
| CCD | 1-7, 20, 99 |
| CRDC | 1-7, 20, 99 |
| IPEDS | 1-9, 99 |
| EDFacts | 1-7, 99 |

### Historical Note

Prior to 2008, race categories differed. The current categories align with OMB standards for collecting race/ethnicity data.

---

## Sex Codes

| Code | Description |
|------|-------------|
| 1 | Male |
| 2 | Female |
| 3 | Another gender (IPEDS 2022+ only) |
| 4 | Unknown gender (IPEDS 2022+ only) |
| 9 | Unknown / Not Reported |
| 99 | Total (all sexes) |

> **Note:** Codes 3 and 4 were added to IPEDS starting with the 2022-23 collection. K-12 sources (CCD, CRDC, EDFacts) currently use only codes 1, 2, and 99.

---

## School Level Codes

CCD school level classification:

| Code | Description |
|------|-------------|
| 0 | Not applicable / Not reported |
| 1 | Primary (elementary: generally PK-5 or PK-6) |
| 2 | Middle (generally 6-8 or 7-8) |
| 3 | High (generally 9-12) |
| 4 | Other (ungraded, combined, or special) |

### Typical Grade Ranges by Level

| Level | Common Grade Ranges |
|-------|---------------------|
| Primary | PK-5, PK-6, K-5, K-6 |
| Middle | 5-8, 6-8, 7-8 |
| High | 9-12, 10-12 |
| Other | Varies (K-12, K-8, etc.) |

---

## School Type Codes

CCD school type classification:

| Code | Description |
|------|-------------|
| 1 | Regular School |
| 2 | Special Education School |
| 3 | Vocational/Technical School |
| 4 | Alternative/Other School |

### School Type Details

| Type | Typical Characteristics |
|------|------------------------|
| Regular | Standard K-12 curriculum |
| Special Ed | Primarily serves students with disabilities |
| Vocational | Career and technical education focus |
| Alternative | Nontraditional settings, dropout recovery |

---

## Urban-Centric Locale Codes

NCES urban-centric locale classification (12 categories):

### City

| Code | Description |
|------|-------------|
| 11 | City, Large (population ≥250,000) |
| 12 | City, Midsize (population 100,000-249,999) |
| 13 | City, Small (population <100,000) |

### Suburb

| Code | Description |
|------|-------------|
| 21 | Suburb, Large (outside large city) |
| 22 | Suburb, Midsize (outside midsize city) |
| 23 | Suburb, Small (outside small city) |

### Town

| Code | Description |
|------|-------------|
| 31 | Town, Fringe (≤10 miles from urbanized area) |
| 32 | Town, Distant (10-35 miles from urbanized area) |
| 33 | Town, Remote (>35 miles from urbanized area) |

### Rural

| Code | Description |
|------|-------------|
| 41 | Rural, Fringe (≤5 miles from urbanized area) |
| 42 | Rural, Distant (5-25 miles from urbanized area) |
| 43 | Rural, Remote (>25 miles from urbanized area) |

### Simplified Groupings

For analysis, often grouped as:

| Group | Codes |
|-------|-------|
| Urban | 11, 12, 13, 21, 22, 23 |
| Town | 31, 32, 33 |
| Rural | 41, 42, 43 |

---

## Institution Control Codes (Colleges)

| Code | Description |
|------|-------------|
| 1 | Public |
| 2 | Private nonprofit |
| 3 | Private for-profit |

---

## Institution Level Codes (Colleges)

| Code | Description |
|------|-------------|
| 1 | Four-year or above |
| 2 | Two-year (associates) |
| 3 | Less-than-two-year |

---

## Sector Codes (Colleges)

Combined control and level:

| Code | Description |
|------|-------------|
| 0 | Administrative unit |
| 1 | Public, 4-year or above |
| 2 | Private nonprofit, 4-year or above |
| 3 | Private for-profit, 4-year or above |
| 4 | Public, 2-year |
| 5 | Private nonprofit, 2-year |
| 6 | Private for-profit, 2-year |
| 7 | Public, less-than-2-year |
| 8 | Private nonprofit, less-than-2-year |
| 9 | Private for-profit, less-than-2-year |

---

## Award Level Codes

IPEDS award/degree level classifications:

| Code | Description |
|------|-------------|
| 1 | Award of less than 1 academic year |
| 2 | Award of 1-2 academic years |
| 3 | Associate's degree |
| 4 | Award of 2-4 academic years |
| 5 | Bachelor's degree |
| 6 | Post-baccalaureate certificate |
| 7 | Master's degree |
| 8 | Post-master's certificate |
| 9 | Doctor's degree - research/scholarship |
| 10 | Doctor's degree - professional practice |
| 11 | Doctor's degree - other |
| 12 | First professional degree (historical) |

---

## Special Population Codes

Used in EDFacts and CRDC for student subgroups:

### Disability Status

| Code | Description |
|------|-------------|
| 0 | Students without disabilities |
| 1 | Students with disabilities (IDEA) |
| 99 | Total (all students) |

### Economic Status

| Code | Description |
|------|-------------|
| 0 | Not economically disadvantaged |
| 1 | Economically disadvantaged |
| 99 | Total |

### English Proficiency

| Code | Description |
|------|-------------|
| 0 | Not limited English proficient |
| 1 | Limited English proficient (LEP) / English learner (EL) |
| 99 | Total |

### Other Populations

| Variable | Values |
|----------|--------|
| `homeless` | 0=No, 1=Yes, 99=Total |
| `migrant` | 0=No, 1=Yes, 99=Total |
| `foster_care` | 0=No, 1=Yes, 99=Total |

---

## Missing Value Codes

Standard codes for missing or suppressed data:

| Code | Meaning |
|------|---------|
| -1 | Missing / Not reported |
| -2 | Not applicable |
| -3 | Suppressed (privacy protection) |
| -4 | Derived / Imputed |
| -9 | Not available |

### Interpretation Guidelines

| Code | When Used | How to Handle |
|------|-----------|---------------|
| -1 | Data not collected or reported | Exclude from analysis |
| -2 | Question doesn't apply (e.g., no AP offered) | Exclude from analysis |
| -3 | Small cell size suppressed | May estimate or exclude |
| -4 | Value derived from other data | Use with caution |
| -9 | Historical data not available | Exclude from analysis |

### Suppression Rules

Data suppression for privacy varies by source:
- **CCD**: Cells with <3 students may be suppressed
- **CRDC**: Cells with <10 students may be suppressed
- **EDFacts**: Range reporting for small cells
- **IPEDS**: Varies by variable

---

## College Student Level Codes

### Enrollment Level (URL Path)

| URL Value | Description |
|-----------|-------------|
| `undergraduate` | Undergraduate students |
| `graduate` | Graduate students |
| `first-professional` | First professional (historical) |

### Attendance Status

| Code | Description |
|------|-------------|
| 1 | Full-time |
| 2 | Part-time |
| 99 | Total |

---

## Calendar System Codes (Colleges)

| Code | Description |
|------|-------------|
| 1 | Semester |
| 2 | Quarter |
| 3 | Trimester |
| 4 | Four-one-four plan |
| 5 | Other academic year |
| 6 | Differs by program |
| 7 | Continuous |

---

## Carnegie Basic Classification Codes (2021)

The `ccbasic` variable uses the 2021 Carnegie Classification. A 2025 update exists but is not yet reflected in Portal data.

| Code | Description |
|------|-------------|
| -2 | Not applicable |
| 1 | Associate's: High Transfer-High Traditional |
| 2 | Associate's: High Transfer-Mixed Trad/Nontrad |
| 3 | Associate's: High Transfer-High Nontraditional |
| 4 | Associate's: Mixed Transfer/Career & Tech-High Traditional |
| 5 | Associate's: Mixed Transfer/Career & Tech-Mixed Trad/Nontrad |
| 6 | Associate's: Mixed Transfer/Career & Tech-High Nontraditional |
| 7 | Associate's: High Career & Tech-High Traditional |
| 8 | Associate's: High Career & Tech-Mixed Trad/Nontrad |
| 9 | Associate's: High Career & Tech-High Nontraditional |
| 10 | Special Focus Two-Year: Health Professions |
| 11 | Special Focus Two-Year: Technical Professions |
| 12 | Special Focus Two-Year: Arts & Design |
| 13 | Special Focus Two-Year: Other Fields |
| 14 | Baccalaureate/Associate's: Associate's Dominant |
| 15 | Doctoral Universities: Very High Research Activity (R1) |
| 16 | Doctoral Universities: High Research Activity (R2) |
| 17 | Doctoral/Professional Universities |
| 18 | Master's Colleges & Universities: Larger Programs |
| 19 | Master's Colleges & Universities: Medium Programs |
| 20 | Master's Colleges & Universities: Small Programs |
| 21 | Baccalaureate Colleges: Arts & Sciences Focus |
| 22 | Baccalaureate Colleges: Diverse Fields |
| 23 | Baccalaureate/Associate's: Mixed |
| 24 | Special Focus Four-Year: Faith-Related Institutions |
| 25 | Special Focus Four-Year: Medical Schools & Centers |
| 26 | Special Focus Four-Year: Other Health Professions |
| 27 | Special Focus Four-Year: Engineering Schools |
| 28 | Special Focus Four-Year: Other Technology-Related |
| 29 | Special Focus Four-Year: Business & Management |
| 30 | Special Focus Four-Year: Arts, Music & Design |
| 31 | Special Focus Four-Year: Law Schools |
| 32 | Special Focus Four-Year: Other Special Focus |
| 33 | Tribal Colleges |

---

## Quick Code Lookup

### Common Filter Values

| Filter | Common Values |
|--------|---------------|
| California schools | `?fips=6` |
| Texas schools | `?fips=48` |
| New York schools | `?fips=36` |
| Charter schools | `?charter=1` |
| High schools | `?school_level=3` |
| Total enrollment | `/grade-99/` |
| All races | `/race/` with `race=99` or omit filter |
| Public colleges | `?inst_control=1` |
| 4-year colleges | `?inst_level=1` |
| HBCUs | `?hbcu=1` |

### Combining Filters

Filters can be combined with `&`:

```
?fips=6&charter=1&school_level=3
```

Gets California charter high schools.

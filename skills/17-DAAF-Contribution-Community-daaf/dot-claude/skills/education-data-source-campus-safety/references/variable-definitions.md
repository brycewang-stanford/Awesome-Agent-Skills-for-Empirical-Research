# Variable Definitions and Data Structure

> **CRITICAL: Portal vs Raw File Encoding**
>
> This document describes **Education Data Portal** integer encodings, which differ from Department of Education raw file string codes. The Portal converts categorical variables to integers for consistency across sources.
>
> | Context | Example: Bias Category | Crime Type |
> |---------|------------------------|------------|
> | **Portal (integers)** | `1` = Race, `2` = Religion | `1` = Murder, `13` = Intimidation |
> | Raw files (strings) | Text descriptions | Text descriptions |
>
> **Always use integer codes** when working with mirror data.

> **Codebook Authority:** The variable definitions in this document are summaries for convenience.
> The authoritative source for variable names, codes, and definitions is the codebook `.xls` file
> available in the data mirrors. Use `get_codebook_url("csafety/codebook_colleges_csafety_hate_crimes")` from `fetch-patterns.md`
> to download the codebook. If this document contradicts the codebook, trust the codebook and
> flag the discrepancy.

## Data Sources and Access

### Primary Source: Department of Education

The Campus Safety and Security (CSS) data is collected through an annual survey administered by the U.S. Department of Education, Office of Postsecondary Education.

**Official Data Portal**: https://ope.ed.gov/campussafety/

For data NOT available in the mirror system (primary offenses, VAWA, arrests/referrals, fire safety), access the Department of Education directly.

### Education Data Portal (Urban Institute) -- Mirror System

The Education Data Portal includes CSS hate crimes data integrated with other college-level data sources. Data is available via mirror downloads. See `datasets-reference.md` for canonical paths, `mirrors.yaml` for mirror configuration, and `fetch-patterns.md` for fetch code patterns.

**Available Dataset:**

| Dataset | Path | Codebook | Years |
|---------|------|----------|-------|
| Hate Crimes | `csafety/colleges_csafety_hate_crimes` | `csafety/codebook_colleges_csafety_hate_crimes` | 2005-2021 |

> **Note:** Only 1 campus safety dataset is available in the Portal mirrors. Consult `datasets-reference.md` for the authoritative list.

## Key Identifiers

### Identifiers in Portal Mirror Data (Hate Crimes Dataset)

The following columns are **empirically confirmed** in the `csafety/colleges_csafety_hate_crimes` dataset:

| Variable | Description | Type | Notes |
|----------|-------------|------|-------|
| `unitid` | IPEDS institution ID | Int64 | Primary identifier for joining with IPEDS data |
| `opeid` | OPE institution ID | String | 8-character; 126 null values in dataset |
| `inst_name` | Institution name | String | Official institution name |
| `fips` | State FIPS code | Int64 | 59 unique values (50 states + DC + territories) |

> **Note:** The Portal hate crimes data uses `inst_name` (not `instnm`). Columns such as `branch`, `address`, `city`, `zip`, `state`, `campus_id`, `main_campus`, `sector`, `control`, `enrollment`, `fte_enrollment`, `housing`, and `housing_capacity` are NOT present in the mirror dataset. Join with IPEDS directory data on `unitid` to obtain institutional characteristics.

### Identifiers in Full CSS Data (Department of Education Direct Access)

The full CSS survey data (available at https://ope.ed.gov/campussafety/) includes additional identifiers not present in the Portal mirror, such as `branch`, `address`, `city`, `state`, `zip`, `campus_id`, and `main_campus`. These are relevant when accessing data directly from the Department of Education rather than through the Portal mirrors.

## Institutional Characteristics

> **Not in Portal mirror data:** The variables below are available in the full CSS survey from the Department of Education but are NOT present in the Portal mirror hate crimes dataset. To obtain institutional characteristics, join the hate crimes data with the IPEDS directory dataset (`ipeds/colleges_ipeds_directory`) on `unitid`.

### Basic Characteristics (Full CSS / IPEDS Join)

| Variable | Description | Values |
|----------|-------------|--------|
| `sector` | Institution sector | Integer codes 1-9 (see sector codes below) |
| `level` | Institution level | 4-year, 2-year, Less than 2-year |
| `control` | Institution control | Public, Private nonprofit, Private for-profit |
| `enrollment` | Total enrollment | Integer |
| `fte_enrollment` | Full-time equivalent enrollment | Integer |

### Housing Information (Full CSS Only)

| Variable | Description | Values |
|----------|-------------|--------|
| `housing` | Has on-campus housing | Yes/No |
| `housing_capacity` | Housing bed capacity | Integer |

## Crime Statistics Variables

> **Not in Portal mirror data:** The individual crime count variables below (e.g., `murder`, `rape`, `robbery`) are available in the full CSS survey from the Department of Education but are NOT present in the Portal mirror hate crimes dataset. The mirror data contains only aggregate hate crime counts by location (see "Hate Crime Variables" section below).

### Criminal Offenses

| Variable | Description |
|----------|-------------|
| `murder` | Murder and non-negligent manslaughter |
| `negligent_manslaughter` | Manslaughter by negligence |
| `rape` | Rape |
| `fondling` | Fondling |
| `incest` | Incest |
| `statutory_rape` | Statutory rape |
| `robbery` | Robbery |
| `aggravated_assault` | Aggravated assault |
| `burglary` | Burglary |
| `motor_vehicle_theft` | Motor vehicle theft |
| `arson` | Arson |

### VAWA Offenses

| Variable | Description |
|----------|-------------|
| `domestic_violence` | Domestic violence |
| `dating_violence` | Dating violence |
| `stalking` | Stalking |

### Arrests and Referrals

| Variable | Description |
|----------|-------------|
| `weapons_arrests` | Weapons law violation arrests |
| `weapons_referrals` | Weapons law violation disciplinary referrals |
| `drug_arrests` | Drug law violation arrests |
| `drug_referrals` | Drug law violation disciplinary referrals |
| `liquor_arrests` | Liquor law violation arrests |
| `liquor_referrals` | Liquor law violation disciplinary referrals |

## Geographic Location Suffixes

> **Not in Portal mirror data:** The suffixed crime variables below (e.g., `robbery_oncampus`) are part of the full CSS survey, not the Portal mirror. In the Portal mirror hate crimes dataset, geographic breakdowns are provided as separate count columns: `on_campus_hate_crimes`, `residence_hall_hate_crimes`, `non_campus_hate_crimes`, `public_property_hate_crimes`, `other_hate_crimes`, and `total_hate_crimes`.

Crime variables in the full CSS data typically have suffixes indicating location:

| Suffix | Description |
|--------|-------------|
| `_oncampus` | On-campus (total) |
| `_oncampus_housing` or `_studenthousing` | On-campus student housing (subset of on-campus) |
| `_noncampus` | Noncampus property |
| `_publicproperty` | Public property |

### Example Variable Names

```
robbery_oncampus
robbery_oncampus_housing
robbery_noncampus
robbery_publicproperty
```

## Hate Crime Variables

> **This is the data available in Portal mirrors.** The hate crimes dataset is the only campus safety data in the mirror system.

### Structure

Hate crimes are reported by:
- Crime type (integer code)
- Bias category (integer code)
- Geographic location (as separate count columns)

### Bias Category Codes (Portal Integer Encoding)

| Code | Bias Category | Notes |
|------|---------------|-------|
| `1` | Race | Anti-Black, Anti-White, Anti-Asian, etc. |
| `2` | Religion | Anti-Jewish, Anti-Islamic, Anti-Catholic, etc. |
| `3` | Sexual Orientation | Anti-Gay, Anti-Lesbian, Anti-Bisexual, etc. |
| `4` | Gender | Bias based on actual or perceived gender |
| `5` | Gender Identity | Anti-Transgender, Anti-Gender Non-Conforming (2014+) |
| `6` | Ethnicity | Anti-Hispanic/Latino, etc. (separated from National Origin in 2014) |
| `7` | National Origin | Based on country of birth (separated from Ethnicity in 2014) |
| `8` | Disability | Anti-Physical Disability, Anti-Mental Disability |
| `9` | Unknown/Other | Bias category not specified |
| `99` | Total | All bias categories combined |
| `null` | Missing | Data not reported |

> **Historical Note:** Prior to 2014, National Origin (7) and Ethnicity (6) were combined. Gender Identity (5) was added in 2014.

### Crime Type Codes (Portal Integer Encoding)

| Code | Crime Type | Category |
|------|------------|----------|
| `1` | Murder/Non-negligent Manslaughter | Primary Offense |
| `2` | Manslaughter by Negligence | Primary Offense |
| `3` | Rape | Sex Offense |
| `4` | Fondling | Sex Offense |
| `5` | Incest | Sex Offense |
| `6` | Statutory Rape | Sex Offense |
| `7` | Robbery | Primary Offense |
| `8` | Aggravated Assault | Primary Offense |
| `9` | Burglary | Property Crime |
| `10` | Motor Vehicle Theft | Property Crime |
| `11` | Arson | Property Crime |
| `12` | Larceny-Theft | Hate Crime Only |
| `13` | Simple Assault | Hate Crime Only |
| `14` | Intimidation | Hate Crime Only |
| `15` | Destruction/Damage/Vandalism | Hate Crime Only |
| `16` | Domestic Violence | VAWA Offense (2014+) |
| `17` | Dating Violence | VAWA Offense (2014+) |
| `18` | Stalking | VAWA Offense (2014+) |

> **Note:** Crime types 12-15 (Larceny-Theft, Simple Assault, Intimidation, Vandalism) are only reported as hate crimes. They are not standalone Clery crimes unless bias-motivated.

> **Empirically verified:** The Portal mirror data contains crime_type values 1-18 only. Code `99` (Total) does NOT appear in the actual data, despite being documented in some references. Verify codes against the live codebook. Use `get_codebook_url()` from `fetch-patterns.md`.

### Hate Crime-Only Offenses

| Variable | Description |
|----------|-------------|
| `larceny_theft_hate` | Larceny-theft (hate crime only) |
| `simple_assault_hate` | Simple assault (hate crime only) |
| `intimidation_hate` | Intimidation (hate crime only) |
| `vandalism_hate` | Destruction/damage/vandalism of property (hate crime only) |

## Fire Safety Variables

> **Not in Portal mirror data:** Fire safety variables are NOT available in the Portal mirrors. Access the Department of Education CSS portal directly for fire data.

### Fire Statistics

| Variable | Description |
|----------|-------------|
| `fires_total` | Total number of fires |
| `fire_injuries` | Number of fire-related injuries |
| `fire_deaths` | Number of fire-related deaths |
| `fire_damage_value` | Property damage from fires |

### Fire Cause Categories

| Code | Description |
|------|-------------|
| `unintentional` | Accidental fire |
| `intentional` | Deliberately set |
| `undetermined` | Cause unknown |

### Fire Safety Systems

| Variable | Description | Values |
|----------|-------------|--------|
| `fire_alarm` | Fire alarm system present | Yes/No |
| `sprinklers` | Sprinkler system | Full/Partial/None |
| `smoke_detectors` | Smoke detection | Yes/No |
| `fire_extinguishers` | Fire extinguishers present | Yes/No |
| `evacuation_plans` | Evacuation plans posted | Yes/No |
| `fire_drills` | Number of fire drills | Integer |

## Time Variables

| Variable | Description | Format | In Mirror Data? |
|----------|-------------|--------|-----------------|
| `year` | Calendar year of data | YYYY (Int64) | Yes |
| `survey_year` | Year survey was submitted | YYYY | No (full CSS only) |

**Note**: Crime statistics are for calendar years (Jan 1 - Dec 31). The survey submitted in fall of year X contains data for year X-1. The Portal mirror data contains `year` (2005-2021) but not `survey_year`.

## Missing Data Codes

| Code | Meaning | When Used |
|------|---------|-----------|
| `null` | Missing/not reported | Data not submitted or not applicable |
| `0` | Zero incidents | Explicitly reported as zero (distinct from missing) |

> **Empirically verified:** The Portal mirror hate crimes dataset does NOT use `-1`, `-2`, or `-3` coded values for missing data. All missing data appears as `null` (e.g., 352,310 null values in the `bias` column). This differs from some other Portal datasets (e.g., CCD enrollment) that use negative integer codes. Always verify against the actual data.

## Data Quality Flags

> **Not in Portal mirror data:** The data quality flag columns (`imputed`, `revised`, `estimated`) are NOT present in the Portal mirror hate crimes dataset. These may be available in full CSS survey data from the Department of Education.

## Historical Variable Changes

### 2014 Changes (VAWA)

**Added Variables**:
- `dating_violence`
- `domestic_violence`
- `stalking`
- Hate crime bias: `gender_identity`
- Separate `national_origin` and `ethnicity`

**Changed Variables**:
- Sex offense definitions changed
- `rape` definition expanded
- Previous categories (forcible/non-forcible) restructured

### 2008 Changes (HEOA)

**Added Variables**:
- All fire safety variables
- Enhanced emergency notification data

### Pre-2014 Sex Offense Variables

Prior to 2014, sex offenses were categorized as:

**Forcible Sex Offenses**:
- Forcible rape
- Forcible sodomy
- Sexual assault with an object
- Forcible fondling

**Non-Forcible Sex Offenses**:
- Incest
- Statutory rape

**Note**: These categories are not directly comparable to post-2014 categories.

## Common Filters (Portal Mirror Data)

| Filter | Description | Example |
|--------|-------------|---------|
| `year` | Calendar year | `pl.col("year") == 2021` |
| `unitid` | Institution ID (IPEDS) | `pl.col("unitid") == 110635` |
| `fips` | State FIPS code | `pl.col("fips") == 6` (California) |
| `crime_type` | Crime type code (1-18) | `pl.col("crime_type") == 14` (Intimidation) |
| `bias` | Bias category code (1-9, 99) | `pl.col("bias") == 1` (Race) |

### Sector Codes (Portal Integer Encoding)

| Code | Description |
|------|-------------|
| `1` | Public, 4-year or above |
| `2` | Private nonprofit, 4-year or above |
| `3` | Private for-profit, 4-year or above |
| `4` | Public, 2-year |
| `5` | Private nonprofit, 2-year |
| `6` | Private for-profit, 2-year |
| `7` | Public, less-than 2-year |
| `8` | Private nonprofit, less-than 2-year |
| `9` | Private for-profit, less-than 2-year |

## Joining with Other Data

### Linking to IPEDS

Use `unitid` to join CSS data with IPEDS data:
- Directory information
- Enrollment data
- Financial data
- Graduation rates

### Linking to College Scorecard

Use `unitid` to join with College Scorecard data:
- Earnings outcomes
- Student debt
- Default rates

### Example Join Logic

```
CSS data (campus safety statistics)
  ↓ join on unitid
IPEDS directory (institutional characteristics)
  ↓ join on unitid
College Scorecard (outcomes data)
```

## Data Availability by Year

| Data Category | First Year Available |
|---------------|---------------------|
| Criminal offenses | 2001 |
| Arrests/referrals | 2001 |
| Hate crimes | 2001 (expanded 2008) |
| VAWA offenses | 2014 |
| Fire safety | 2009 |

**Note**: Data coverage and quality may vary in earlier years.

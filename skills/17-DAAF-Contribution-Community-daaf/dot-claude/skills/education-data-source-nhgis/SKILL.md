---
name: education-data-source-nhgis
description: >-
  NHGIS — census geography crosswalks via Portal: links schools (ncessch) and colleges (unitid) to tracts, block groups, CBSAs (1990-2020). Census demographics NOT in Portal — access NHGIS directly. Use for linking education data to census geography.
metadata:
  audience: any-agent
  domain: data-source
  skill-authored: "2026-02-09"
  skill-last-updated: "2026-02-09"
---

# NHGIS Data Source Reference

IPUMS NHGIS — census geography crosswalks and demographic data for education research. Via the Education Data Portal: geographic crosswalk tables linking K-12 schools (ncessch) and colleges (unitid) to census tracts, block groups, CBSAs, and regions (census 1990-2020). Census demographic variables (income, poverty, race, educational attainment) are NOT in the Portal — access directly from NHGIS via free IPUMS registration. Use when linking school or institutional data to census geography for contextual analysis.

Census geography and demographic data source for education research. NHGIS provides the foundation for linking schools to community characteristics via census tracts, block groups, and school district boundaries.

> **CRITICAL: Value Encoding**
>
> When accessing NHGIS data through the Education Data Portal (not NHGIS directly), categorical variables use **integer encodings**, not string labels. Always verify the exact codes in the mirror codebook.
>
> | Variable | Integer Code | Meaning |
> |----------|--------------|---------|
> | `census_region` | `1` | Northeast |
> | `census_region` | `2` | Midwest |
> | `census_region` | `3` | South |
> | `census_region` | `4` | West |
> | `cbsa_type` | `1` | Metropolitan |
> | `cbsa_type` | `2` | Micropolitan |
> | `geocode_accuracy` | `4` | Did not geocode |
>
> See `./references/variable-catalog.md` for complete encoding tables.

> **CRITICAL: Portal Data Scope**
>
> The Education Data Portal provides ONLY **geographic crosswalk tables** that link schools and colleges to census geography (tracts, block groups, regions, CBSAs). These contain geographic identifiers and assignment columns — approximately 35-47 columns per file.
>
> The Portal does **NOT** provide census demographic data (population, income, poverty, race, education attainment, housing, language, etc.). For demographic variables, you must access NHGIS directly via IPUMS (free registration required). See `./references/data-access.md` for direct access methods.
>
> This skill documents both contexts: Portal crosswalk data (with integer encodings above) and direct NHGIS census variables (in `./references/variable-catalog.md`, clearly marked as requiring direct NHGIS access).

## What is NHGIS?

NHGIS (from IPUMS, University of Minnesota) provides free access to census geography and demographic data.

- **Collector**: IPUMS, University of Minnesota
- **Coverage**: US census data from 1790-present (decennial census + ACS)
- **Content**: Summary tables, GIS boundary files, time series tables, geographic crosswalks
- **Frequency**: Decennial census (every 10 years) + ACS (annual, 5-year rolling)
- **Available years**: 1790-2020 (decennial), 2005-2023 (ACS 5-year)
- **Primary identifiers**: GISJOIN (NHGIS internal), GEOID (Census Bureau standard)
- **Education relevance**: Links school locations to community demographics via census tracts, block groups, and school district boundaries
- **Available through Education Data Portal**: Geographic crosswalk tables only (school-to-census and college-to-census links for census 1990, 2000, 2010, 2020). Census demographic data requires direct NHGIS access.

## Reference File Structure

| File | Purpose | When to Read |
|------|---------|--------------|
| `geographic-units.md` | Census geography hierarchy (tracts, blocks, districts) | Understanding census geography |
| `school-geography-links.md` | Linking schools to census areas | Connecting school data to demographics |
| `time-series.md` | Historical data, harmonization methods | Longitudinal analysis |
| `variable-catalog.md` | Key demographic variables, codes, special values | Selecting census variables or interpreting encodings |
| `boundary-changes.md` | How boundaries change between censuses | Handling geographic inconsistencies |
| `data-access.md` | Direct NHGIS access methods (registration, Data Finder, ipumspy) | Custom census analysis beyond Portal |

## Decision Trees

### What geographic level should I use?

```
Research question about...
├─ Individual schools
│   ├─ School's immediate neighborhood → Census tract or block group
│   ├─ School attendance zone → SABINS (limited years) or block-to-school crosswalk
│   └─ School district overall → School district boundaries
├─ School districts
│   ├─ District-level demographics → School district geographic level
│   ├─ Within-district variation → Census tracts within district
│   └─ District poverty estimates → SAIPE (via Education Data Portal)
├─ Regional patterns
│   ├─ County-level → County boundaries
│   ├─ Metro area → CBSA (Core Based Statistical Area)
│   └─ State-level → State boundaries
└─ Historical analysis
    ├─ Consistent boundaries needed → Geographically standardized tables
    └─ Original boundaries OK → Nominally integrated tables
```

### How do I link schools to census data?

```
Linking schools to census demographics?
├─ Have school coordinates (lat/lon)
│   ├─ Point-in-polygon → Spatial join to tract/block group boundaries
│   └─ Need tract ID only → Geocoding service or FCC API
├─ Have school NCES ID only
│   ├─ Use NCES EDGE files → School District Geographic Relationship Files
│   └─ Use Education Data Portal → NHGIS source provides tract links
├─ Need school attendance zones
│   ├─ 2009-2012 data → SABINS school areas
│   └─ Current data → Contact school district (no national source)
└─ See ./references/school-geography-links.md for details
```

### What time period data do I need?

```
Time period?
├─ Single recent year
│   ├─ Tract/block group level → ACS 5-year (most recent)
│   ├─ Larger areas (65K+ pop) → ACS 1-year
│   └─ Full census count → 2020 Decennial Census
├─ Historical comparison
│   ├─ Same boundaries across time → Geographically standardized tables (to 2010)
│   ├─ Original boundaries → Nominally integrated time series
│   └─ Custom standardization → Use geographic crosswalks
├─ Long time series (1970+)
│   └─ See ./references/time-series.md
└─ Pre-1970
    └─ Limited tract coverage; county/state more complete
```

## Quick Reference: Geographic Levels and Variables

### Geographic Levels

| Level | Typical Size | Education Use | NHGIS Coverage |
|-------|--------------|---------------|----------------|
| Block | ~40 people | Point locations | 1990-2020 |
| Block Group | ~1,500 people | School neighborhoods | 1990-2020 |
| Census Tract | ~4,000 people | Community context | 1910-2020 |
| County Subdivision | Varies | Rural areas | 1980-2020 |
| Place | City/town | Urban context | 1980-2020 |
| School District | Varies | District analysis | 2000-2020 |
| County | ~100,000 people | Regional patterns | 1790-2020 |
| State | Varies | Policy analysis | 1790-2020 |

### Key Identifiers

| ID | Format | Level | Example | Notes |
|----|--------|-------|---------|-------|
| `ncessch` | Int64 | School | `10000201704` | NCES school ID (schools Portal data) |
| `unitid` | Int64 | College | `100654` | IPEDS institution ID (colleges Portal data) |
| `GISJOIN` | String with prefix | Any | `G0600010` | NHGIS internal ID; use for direct NHGIS joins (not in Portal data) |
| `GEOID` | Numeric string | Any | `06001402100` | Census Bureau standard; use for non-NHGIS joins (not in Portal data) |
| `tract` | Int64 | Tract | `402100` | Census tract number (in Portal data) |
| `block_group` | Int64 | Block Group | `1` | Block group within tract (1-9; 0=unassigned) |
| `geoid_block` | Int64 | Block | `60014021001001` | Full block FIPS code (in Portal data — stored as Int64, not String) |
| `cbsa` | Int64 | Metro area | `41860` | Core Based Statistical Area code (2000+ census files only) |

### Key Education Variables

| Topic | Example Variables | Source |
|-------|-------------------|--------|
| Child population | Under 18, 5-17 school-age | Decennial, ACS |
| Race/ethnicity | Hispanic, White, Black, Asian, etc. | Decennial, ACS |
| Poverty | Persons below poverty, SNAP receipt | ACS (sample) |
| Education attainment | HS diploma, BA+ (adults) | ACS (sample) |
| Language | English proficiency, language at home | ACS (sample) |
| Housing | Owner/renter, median value, crowding | Decennial, ACS |
| Family structure | Single-parent, grandparent households | ACS (sample) |
| Immigration | Foreign-born, recent immigrants | ACS (sample) |

### Data Sources by Type

| Source | Years | Geographic Detail | Content |
|--------|-------|-------------------|---------|
| Decennial Census | 1790-2020 | Block (1990+) | 100% count: age, sex, race, housing |
| ACS 5-Year | 2005-2023 | Block group | Sample: income, education, language |
| ACS 1-Year | 2010-2023 | Areas 65K+ pop | Sample: same as 5-year |
| Time Series | 1790-2020 | Varies | Harmonized across years |
| Geographic Crosswalks | 1990-2020 | Block+ | Interpolation weights |

### Portal Variables (Schools NHGIS)

Key geographic and identifying columns in the schools NHGIS datasets. Census 2020 files have 47 columns; earlier census years have fewer (e.g., 1990 has 35 columns — no CBSA or legislative district fields).

| Variable | Description | Type |
|----------|-------------|------|
| `ncessch` | NCES school ID | Int64 |
| `leaid` | NCES district ID | Int64 |
| `tract` | Census tract number | Int64 |
| `block_group` | Block group number (1-9; 0 = unassigned) | Int64 |
| `geoid_block` | Full block FIPS identifier | Int64 |
| `census_region` | Census Bureau region (1-4, 9) | Int64 |
| `census_division` | Census Bureau division (1-9) | Int64 |
| `cbsa` | CBSA code (2000+ census files only) | Int64 |
| `cbsa_type` | Metropolitan (1) or Micropolitan (2) | Int64 |
| `cbsa_city` | Principal city indicator (0=No, 1=Yes; 2000+ only). See note below. | Int64 |
| `geocode_accuracy` | Geocode confidence (1=High, 2=Medium, 3=Low, 4=Did not geocode, -2=N/A) | Float64 |
| `geocode_accuracy_detailed` | Geocode match type (1-12) | Int64 |
| `class_code` | FIPS place class code | Int64 |
| `lower_chamber_type` | State legislative district lower chamber type (1-8; census 2010 only). See `variable-catalog.md` for code mapping. | Int64 |
| `geo_latitude` / `geo_longitude` | Geocoded coordinates | Float64 |
| `latitude` / `longitude` | CCD-reported coordinates (many nulls in early years) | Float64 |
| `fips` | State FIPS code | Int64 |
| `puma` | Public Use Microdata Area (2000+ census files only) | Int64 |

### Portal Variables (Colleges NHGIS)

Colleges NHGIS datasets have 38 columns (2020 census). Different identifier set from schools.

| Variable | Description | Type |
|----------|-------------|------|
| `unitid` | IPEDS institution ID | Int64 |
| `opeid` | Office of Postsecondary Education ID | String |
| `tract` | Census tract number | Int64 |
| `block_group` | Block group number (1-9) | Int64 |
| `geoid_block` | Full block FIPS identifier | Int64 |
| `census_region` | Census Bureau region (1-4, 9) | Int64 |
| `census_division` | Census Bureau division (1-9) | Int64 |
| `cbsa` | CBSA code | Int64 |
| `cbsa_type` | Metropolitan (1) or Micropolitan (2) | Int64 |
| `cbsa_city` | Principal city indicator (0=No, 1=Yes; 2000+ only) | Int64 |
| `geocode_accuracy` | Geocode match score (Int64 in colleges, Float64 in schools) | Int64 |
| `county_fips` | County FIPS code | Int64 |
| `county_name` | County name | String |
| `state_abbr` | State abbreviation | String |

### Missing Data Codes

| Code | Meaning | When Used |
|------|---------|-----------|
| `-2` | Not geocoded | `geocode_accuracy` field in Portal data |
| `-1` | Missing/not reported | General missing data indicator (e.g., `latitude`, `county_code`) |
| `0` | Unassigned | `block_group` (rare, ~4 rows in schools) |
| `null` | Not available | Variable not applicable to this record; many columns heavily null in early years |

> **Schema Difference:** Schools NHGIS 2020 files (47 columns) have a different schema than colleges NHGIS 2020 files (38 columns). Schools data includes school-specific identifiers (`ncessch`, `leaid`, `school_name`, mailing/location address fields) while colleges data includes institution-specific identifiers (`unitid`, `opeid`, `inst_name`, `county_name`). Both entity types have block-level geographic precision. Earlier census years have fewer columns (e.g., Schools 1990 has 35 columns — no CBSA or legislative district fields). Do not assume identical column structures when working across entities or census years.

## Data Access

Datasets for NHGIS are available via the mirror system. See `datasets-reference.md` for canonical paths, `mirrors.yaml` for mirror configuration, and `fetch-patterns.md` for fetch code patterns.

| Dataset | Type | Years | Path | Codebook |
|---------|------|-------|------|----------|
| Schools Census 1990 | Single | 1986-2023 | `nhgis/schools_nhgis_geog_1990` | `nhgis/codebook_schools_nhgis_census1990` |
| Schools Census 2000 | Single | 1986-2023 | `nhgis/schools_nhgis_geog_2000` | `nhgis/codebook_schools_nhgis_census2000` |
| Schools Census 2010 | Single | 1986-2023 | `nhgis/schools_nhgis_geog_2010` | `nhgis/codebook_schools_nhgis_census2010` |
| Schools Census 2020 | Single | 1986-2023 | `nhgis/schools_nhgis_geog_2020` | `nhgis/codebook_schools_nhgis_census2020` |
| Colleges Census 1990 | Single | 1980-2023 | `nhgis/colleges_nhgis_geog_1990` | `nhgis/codebook_colleges_nhgis_census1990` |
| Colleges Census 2000 | Single | 1980-2023 | `nhgis/colleges_nhgis_geog_2000` | `nhgis/codebook_colleges_nhgis_census2000` |
| Colleges Census 2010 | Single | 1980-2023 | `nhgis/colleges_nhgis_geog_2010` | `nhgis/codebook_colleges_nhgis_census2010` |
| Colleges Census 2020 | Single | 1980-2023 | `nhgis/colleges_nhgis_geog_2020` | `nhgis/codebook_colleges_nhgis_census2020` |

Codebooks are `.xls` files co-located with data in all mirrors. Use `get_codebook_url()` from `fetch-patterns.md` to construct download URLs.

> **Truth Hierarchy:** When interpreting variable values, apply this priority:
> 1. **Actual data file** (what you observe in the parquet/CSV) — this IS the truth
> 2. **Live codebook** (.xls in mirror) — authoritative documentation, may lag
> 3. **This skill documentation** — convenient summary, may drift from codebook
>
> If this documentation contradicts the codebook, trust the codebook. If the codebook contradicts observed data, trust the data and investigate.

### Filtering

```python
import polars as pl

# Filter to a specific school
school_census = df.filter(pl.col("ncessch") == 10000201704)

# Filter to metropolitan areas only (cbsa_type only in 2000+ census files)
metro = df.filter(pl.col("cbsa_type") == 1)

# Filter to a specific census region (South)
south = df.filter(pl.col("census_region") == 3)

# Filter to a specific year
recent = df.filter(pl.col("year") == 2023)
```

> **Note**: The Portal provides pre-processed school/college-to-census-geography links. For custom census analysis (tract-level demographics, time series, boundary files), use NHGIS directly via methods in `./references/data-access.md` (requires free IPUMS registration).

## Common Pitfalls

| Pitfall | Issue | Solution |
|---------|-------|----------|
| Boundary changes | Tracts split/merged between censuses break longitudinal analysis | Use crosswalks or geographically standardized tables |
| ACS margins of error | Small-area estimates have high uncertainty | Check MOE; aggregate areas if needed |
| Block data limitations | Only 100% count variables available (no income/poverty) | Use block groups for sample data (ACS) |
| GISJOIN vs GEOID | Different ID formats cause join failures | Use GISJOIN for NHGIS joins, GEOID for Census Bureau joins |
| 2020 Census noise | Differential privacy added noise to small-area counts | Check for negative values; prefer ACS for detailed characteristics |
| Schools vs colleges schema | Different column counts (47 vs 38 for 2020) and identifier sets | Check schema before joining; do not assume identical structures |
| Census year schema drift | Earlier census files have fewer columns (e.g., 1990 lacks CBSA/legislative fields) | Check available columns per census year before relying on them |
| geocode_accuracy type | Float64 in schools, Int64 in colleges | Cast to consistent type before cross-entity comparison |
| Using string codes | Portal data uses integer encodings, not string labels | Always verify codes against codebook (see encoding warning above) |

## Related Data Sources

| Source | Relationship | When to Use |
|--------|--------------|-------------|
| `education-data-source-ccd` | School identifiers for linking | Join school data to census geography via `ncessch` |
| `education-data-source-saipe` | District-level poverty | Use SAIPE for district poverty; NHGIS for tract/block group poverty |
| `education-data-source-meps` | School-level poverty | MEPS provides school-level poverty estimates; NHGIS provides community context |
| `education-data-source-ipeds` | College identifiers for linking | Join college data to census geography via `unitid` |
| `education-data-explorer` | Parent discovery skill | Finding available endpoints |
| `education-data-query` | Data fetching | Downloading parquet/CSV files |

## Topic Index

| Topic | Reference File |
|-------|---------------|
| Census tract definition | `./references/geographic-units.md` |
| Block group definition | `./references/geographic-units.md` |
| School district boundaries | `./references/geographic-units.md` |
| School-to-tract linking | `./references/school-geography-links.md` |
| SABINS attendance areas | `./references/school-geography-links.md` |
| NCES EDGE files | `./references/school-geography-links.md` |
| Time series tables | `./references/time-series.md` |
| Geographic standardization | `./references/time-series.md` |
| Geographic crosswalks | `./references/time-series.md` |
| Population variables | `./references/variable-catalog.md` |
| Income/poverty variables | `./references/variable-catalog.md` |
| Education variables | `./references/variable-catalog.md` |
| Tract boundary changes | `./references/boundary-changes.md` |
| 2022 Connecticut changes | `./references/boundary-changes.md` |
| TIGER/Line versions | `./references/boundary-changes.md` |
| Direct NHGIS access | `./references/data-access.md` |
| ipumspy Python package | `./references/data-access.md` |
| Data Finder workflow | `./references/data-access.md` |

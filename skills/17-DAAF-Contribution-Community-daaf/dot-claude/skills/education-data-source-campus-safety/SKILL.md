---
name: education-data-source-campus-safety
description: >-
  CSS — annual Clery Act crime/fire safety for Title IV institutions. Portal: hate crimes only (2005-2021); primary offenses, VAWA, arrests, fire safety need ope.ed.gov directly. Use for campus crime analysis. Identified by IPEDS unitid.
metadata:
  audience: any-agent
  domain: data-source
  skill-authored: "2026-02-09"
  skill-last-updated: "2026-02-09"
---

# Campus Safety Data Source Reference

Campus Safety and Security (CSS) — annual Clery Act crime and fire safety reporting for all Title IV postsecondary institutions. Full dataset covers primary offenses, VAWA offenses, hate crimes, arrests/referrals, and fire safety. Portal mirror provides only hate crimes data (2005-2021); primary offenses, VAWA, arrests, and fire safety require direct access to ope.ed.gov/campussafety. Use when analyzing campus hate crimes via Portal or understanding Clery Act reporting structure. Identified by IPEDS unitid.

Guide to understanding and using campus crime and fire safety data collected under the Clery Act.

> **CRITICAL: Value Encoding**
>
> The Education Data Portal mirrors use **integer codes** for categorical variables, not string labels:
>
> | Variable | Example Code | Meaning |
> |----------|--------------|---------|
> | `bias` | `1` | Race-based bias |
> | `crime_type` | `14` | Intimidation |
> | `fips` | `6` | California |
>
> See `./references/variable-definitions.md` for complete code mappings.

> **Truth Hierarchy:** When interpreting variable values, apply this priority:
> 1. **Actual data file** (what you observe in the parquet/CSV) -- this IS the truth
> 2. **Live codebook** (.xls in mirror) -- authoritative documentation, may lag
> 3. **This skill documentation** -- convenient summary, may drift from codebook
>
> If this documentation contradicts the codebook, trust the codebook. If the codebook contradicts observed data, trust the data and investigate. Use `get_codebook_url()` from `fetch-patterns.md` to download codebooks.

## What is Campus Safety and Security Data?

The Campus Safety and Security (CSS) data comes from the annual survey required by the Jeanne Clery Disclosure of Campus Security Policy and Campus Crime Statistics Act:

- **Federal mandate**: All Title IV institutions must report crime and fire statistics annually
- **Consumer protection**: Designed to inform students, parents, and employees about campus safety
- **Primary source**: U.S. Department of Education Office of Postsecondary Education
- **Coverage**: All postsecondary institutions receiving federal financial aid
- **Reporting period**: Calendar year (January 1 - December 31)
- **Available years**: 2005-2021 (hate crimes in Portal mirrors)
- **Primary identifier**: `unitid` (IPEDS institution ID, 6-digit integer)
- **Official portal**: https://ope.ed.gov/campussafety/
- **Portal mirror coverage**: Hate crimes only. For primary offenses, VAWA, arrests, and fire safety, access the Department of Education portal directly.

## Reference File Structure

| File | Purpose | When to Read |
|------|---------|--------------|
| `clery-act.md` | Legal framework, history, reporting requirements | Understanding compliance context |
| `crime-categories.md` | Criminal offenses, definitions, classification rules | Interpreting crime statistics |
| `vawa-offenses.md` | Dating violence, domestic violence, stalking | Analyzing gender-based violence data |
| `hate-crimes.md` | Bias categories, additional offenses, classification | Working with hate crime statistics |
| `campus-geography.md` | On-campus, residence halls, public property, noncampus | Understanding location categories |
| `fire-safety.md` | Fire statistics, safety systems, HEOA requirements | Analyzing residential fire data |
| `arrests-referrals.md` | Drug, alcohol, weapons violations | Working with disciplinary data |
| `variable-definitions.md` | Key variables, data structure, identifiers | Building queries |
| `limitations.md` | Underreporting, comparability issues, interpretation | Critical data analysis |

## Decision Trees

### What type of crime data do I need?

```
Crime data type?
├─ Violent crimes (murder, assault, robbery, sex offenses)
│   └─ See ./references/crime-categories.md
├─ Property crimes (burglary, motor vehicle theft, arson)
│   └─ See ./references/crime-categories.md
├─ Sex offenses (rape, fondling, incest, statutory rape)
│   └─ See ./references/crime-categories.md
├─ Dating/domestic violence, stalking
│   └─ See ./references/vawa-offenses.md
├─ Hate crimes (bias-motivated)
│   └─ See ./references/hate-crimes.md
├─ Drug/alcohol/weapons violations
│   └─ See ./references/arrests-referrals.md
└─ Fire incidents in residence halls
    └─ See ./references/fire-safety.md
```

### Where did the crime occur?

```
Understanding crime location?
├─ On-campus (main campus buildings/grounds)
│   └─ See ./references/campus-geography.md
├─ On-campus student housing (subset of on-campus)
│   └─ See ./references/campus-geography.md
├─ Public property (streets, sidewalks adjacent to campus)
│   └─ See ./references/campus-geography.md
├─ Noncampus (off-site but institution-controlled)
│   └─ See ./references/campus-geography.md
└─ Not sure which category
    └─ See ./references/campus-geography.md (definitions section)
```

### Can I compare schools?

```
Planning institutional comparisons?
├─ Want to rank schools by safety
│   └─ See ./references/limitations.md (CRITICAL: comparability issues)
├─ Comparing similar institution types
│   └─ See ./references/limitations.md (controlling for factors)
├─ Analyzing trends over time
│   └─ See ./references/limitations.md (reporting changes)
└─ Understanding what statistics mean
    └─ See ./references/limitations.md (interpretation guidance)
```

## Quick Reference: Crime Categories

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
| `16` | Domestic Violence | VAWA (2014+) |
| `17` | Dating Violence | VAWA (2014+) |
| `18` | Stalking | VAWA (2014+) |

> **Note:** Crime type code `99` (Total) is documented in some references but does NOT appear in the actual Portal mirror data. The data contains individual crime types 1-18 only.

### Bias Category Codes (Portal Integer Encoding)

| Code | Bias Category | Notes |
|------|---------------|-------|
| `1` | Race | Most common category |
| `2` | Religion | Anti-Jewish, Anti-Islamic, etc. |
| `3` | Sexual Orientation | Anti-Gay, Anti-Lesbian, etc. |
| `4` | Gender | Based on perceived gender |
| `5` | Gender Identity | Added 2014 |
| `6` | Ethnicity | Separated from National Origin in 2014 |
| `7` | National Origin | Based on country of birth |
| `8` | Disability | Physical or mental |
| `9` | Unknown/Other | |
| `99` | Total | All bias categories combined |

### VAWA Offenses (Added 2013)

| Code | Offense | Definition |
|------|---------|------------|
| `16` | Domestic Violence | Violence by current/former spouse, cohabitant, or similar |
| `17` | Dating Violence | Violence by person in romantic/intimate relationship |
| `18` | Stalking | Course of conduct causing fear for safety |

### Hate Crime-Only Offenses

Codes 12-15 are only reported as hate crimes. They are not standalone Clery crimes unless bias-motivated.

### Arrests and Disciplinary Referrals

| Category | What's Counted |
|----------|----------------|
| Liquor Law Violations | Arrests + Disciplinary referrals |
| Drug Law Violations | Arrests + Disciplinary referrals |
| Weapons Violations | Arrests + Disciplinary referrals |

### Key Identifiers (Hate Crimes Dataset)

| ID | Format | Level | Example | Notes |
|----|--------|-------|---------|-------|
| `unitid` | 6-digit integer | Institution | `100654` | IPEDS institution ID |
| `opeid` | 8-character String | Institution | `00100200` | OPE institution ID (126 nulls in data) |
| `inst_name` | String | Institution | `University of Alabama` | Institution name |
| `fips` | Integer | State | `6` | State FIPS code |

> **Note:** The hate crimes dataset uses `inst_name` (not `instnm`). Columns like `branch`, `address`, `city`, `zip`, `state`, `sector`, `enrollment` are NOT present in the Portal mirror data. Join with IPEDS directory on `unitid` to obtain institutional characteristics.

### Geographic Categories

| Location | Definition | Reported Separately? |
|----------|------------|---------------------|
| On-Campus | Buildings/property owned/controlled by institution, reasonably contiguous | Yes |
| On-Campus Student Housing | Residence halls (subset of on-campus) | Yes (as subset) |
| Noncampus | Institution-owned/controlled property not contiguous; student org properties | Yes |
| Public Property | Streets, sidewalks, parking within or immediately adjacent to campus | Yes |

### Fire Safety Data

Fire data is reported only for **on-campus student housing facilities**:

| Data Element | Description |
|--------------|-------------|
| Number of fires | Total fires per building per year |
| Cause of fire | Intentional, unintentional, undetermined |
| Injuries | Fire-related injuries requiring treatment |
| Deaths | Fire-related fatalities |
| Property damage | Estimated dollar value |
| Fire safety systems | Sprinklers, alarms, smoke detectors, etc. |

### Missing Data Codes

| Code | Meaning | When Used |
|------|---------|-----------|
| `null` | Missing/not reported | Data not submitted or not applicable (e.g., 352k null values in `bias` column) |
| `0` | Zero incidents | Explicitly reported as zero (distinct from missing) |

> **Empirically verified:** The hate crimes dataset in the Portal mirror does NOT use `-1`, `-2`, or `-3` coded values. All missing data appears as `null`. This differs from some other Portal datasets (e.g., CCD) that use negative integer codes. Always verify against the actual data.

## Data Access

Datasets for Campus Safety are available via the mirror system. See `datasets-reference.md` for canonical paths, `mirrors.yaml` for mirror configuration, and `fetch-patterns.md` for fetch code patterns.

| Dataset | Type | Years | Path | Codebook |
|---------|------|-------|------|----------|
| Hate Crimes | Single | 2005-2021 | `csafety/colleges_csafety_hate_crimes` | `csafety/codebook_colleges_csafety_hate_crimes` |

> **CRITICAL: Limited Data in Portal Mirrors** -- Only hate crimes data is available in the Portal mirrors (1 dataset). For other campus safety data (primary offenses, VAWA, arrests/referrals, fire safety), access the Department of Education directly at https://ope.ed.gov/campussafety/. Consult `datasets-reference.md` for the authoritative list of available mirror datasets.

Codebooks are `.xls` files co-located with data in all mirrors. Use `get_codebook_url()` from `fetch-patterns.md` to construct download URLs:

```python
url = get_codebook_url("csafety/codebook_colleges_csafety_hate_crimes")
```

### Fetching Data

Use the `fetch_from_mirrors()` pattern from `fetch-patterns.md`:

```python
import polars as pl

# Fetch hate crimes data (all years, single-file dataset)
df = fetch_from_mirrors("csafety/colleges_csafety_hate_crimes")

# Filter by year
df_2021 = df.filter(pl.col("year") == 2021)

# Filter by bias category (1 = Race)
race_crimes = df.filter(pl.col("bias") == 1)

# Filter by crime type (14 = Intimidation)
intimidation = df.filter(pl.col("crime_type") == 14)

# Filter by institution
institution = df.filter(pl.col("unitid") == 100654)

# Filter by state FIPS code (6 = California)
california = df.filter(pl.col("fips") == 6)
```

### Direct from Department of Education (Non-Mirror Data)

For data NOT available in Portal mirrors (primary offenses, VAWA, arrests, fire safety):

- **Web tool**: https://ope.ed.gov/campussafety/
- **Bulk download**: Available through Campus Safety website
- **Custom reports**: Generate by institution, state, or sector

## Common Pitfalls

| Pitfall | Issue | Solution |
|---------|-------|----------|
| Using string codes | Portal uses integer codes for `bias`, `crime_type`, etc. | Always map integers via `./references/variable-definitions.md` |
| Ranking schools by crime counts | Higher numbers may indicate better reporting, not worse safety | Normalize by enrollment; note reporting culture differences in `./references/limitations.md` |
| Comparing across years naively | Crime definitions changed over time (especially sex offenses in 2014, VAWA added 2013) | Restrict comparisons to consistent-definition periods; document breaks |
| Treating zero as missing | Zero means explicitly reported zero incidents; missing means not reported | Check for `null` (missing) vs `0` (zero incidents) before analysis |
| Comparing CSS to FBI UCR data | Different definitions, scope, and reporting requirements | Never equate CSS and FBI statistics; see `./references/limitations.md` |
| Assuming all crime data in mirror | Mirror only has hate crimes | Use Department of Education portal for primary offenses, VAWA, arrests, fire safety |
| Using `instnm` as column name | Hate crimes data uses `inst_name`, not `instnm` (which is the IPEDS convention) | Check actual column names with `df.columns` |
| Expecting `-1`/`-2` missing codes | Hate crimes data uses `null` for missing, not negative integer codes | Check for nulls with `pl.col("bias").is_null()`, not `pl.col("bias") == -1` |
| Ignoring multi-campus institutions | Branch campuses report separately; aggregating incorrectly inflates/deflates | Use `branch` field to distinguish campuses; see `./references/campus-geography.md` |
| Ignoring underreporting | Many crimes go unreported; CSS captures only reported incidents | Acknowledge underreporting as a limitation in all analyses |

## Reporting Timeline

| Date | Action |
|------|--------|
| Calendar year | Data collection period |
| October 1 | Annual Security Report (ASR) due |
| October 15 | CSS survey submission deadline |
| Following spring | Data available publicly |

## Related Data Sources

| Source | Relationship | When to Use |
|--------|--------------|-------------|
| `education-data-source-ipeds` | Institutional characteristics | Joining with IPEDS directory for enrollment, sector, control |
| `education-data-explorer` | Parent discovery skill | Finding available endpoints |
| `education-data-query` | Data fetching | Downloading parquet/CSV files |

## Topic Index

| Topic | Reference File |
|-------|---------------|
| Clery Act history and requirements | `./references/clery-act.md` |
| Criminal offense definitions | `./references/crime-categories.md` |
| Sex offense classification | `./references/crime-categories.md` |
| VAWA amendments | `./references/vawa-offenses.md` |
| Dating violence definition | `./references/vawa-offenses.md` |
| Domestic violence definition | `./references/vawa-offenses.md` |
| Stalking definition | `./references/vawa-offenses.md` |
| Hate crime bias categories | `./references/hate-crimes.md` |
| Hate crime offenses | `./references/hate-crimes.md` |
| On-campus definition | `./references/campus-geography.md` |
| Residence hall reporting | `./references/campus-geography.md` |
| Public property definition | `./references/campus-geography.md` |
| Noncampus property | `./references/campus-geography.md` |
| Fire statistics | `./references/fire-safety.md` |
| Fire safety systems | `./references/fire-safety.md` |
| Arrests vs referrals | `./references/arrests-referrals.md` |
| Drug/alcohol violations | `./references/arrests-referrals.md` |
| Weapons violations | `./references/arrests-referrals.md` |
| Variable names and codes | `./references/variable-definitions.md` |
| Underreporting issues | `./references/limitations.md` |
| Institutional comparisons | `./references/limitations.md` |
| Trend analysis caveats | `./references/limitations.md` |
| Data interpretation | `./references/limitations.md` |

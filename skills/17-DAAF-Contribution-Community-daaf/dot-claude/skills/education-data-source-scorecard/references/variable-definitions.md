# Variable Definitions

College Scorecard uses consistent naming conventions and special values. Understanding these is essential for building queries and interpreting results.

> **Truth Hierarchy:** When interpreting variable values, apply this priority:
> 1. **Actual data file** (what you observe in the parquet/CSV) — this IS the truth
> 2. **Live codebook** (.xls in mirror, via `get_codebook_url()`) — authoritative documentation, may lag
> 3. **This skill documentation** — convenient summary, may drift from codebook
>
> If this documentation contradicts the codebook, trust the codebook. If the codebook contradicts observed data, trust the data and investigate.

## CRITICAL: Original vs Portal Variable Names

The College Scorecard has TWO naming systems. The Education Data Portal **restructures** the original Scorecard data into a LONG format with **entirely different, lowercase column names**.

### Portal Column Names (What You Will See)

**Earnings dataset** (`scorecard/colleges_scorecard_earnings`):

| Portal Column | Description | Original Scorecard Equivalent |
|---------------|-------------|-------------------------------|
| `earnings_med` | Median earnings | `MD_EARN_WNE_P*` (time horizon was in name) |
| `earnings_mean` | Mean earnings | `MN_EARN_WNE_P*` |
| `earnings_sd` | Standard deviation | `SD_EARN_WNE_P*` |
| `earnings_pct10` | 10th percentile | `PCT10_EARN_WNE_P*` |
| `earnings_pct25` | 25th percentile | `PCT25_EARN_WNE_P*` |
| `earnings_pct75` | 75th percentile | `PCT75_EARN_WNE_P*` |
| `earnings_pct90` | 90th percentile | `PCT90_EARN_WNE_P*` |
| `count_working` | Count working & not enrolled | `COUNT_WNE_P*` |
| `count_not_working` | Count not working & not enrolled | `COUNT_NWNE_P*` |
| `earnings_lowinc_mean` | Mean earnings, low income | `MN_EARN_WNE_INC1_P*` |
| `earnings_midinc_mean` | Mean earnings, mid income | `MN_EARN_WNE_INC2_P*` |
| `earnings_highinc_mean` | Mean earnings, high income | `MN_EARN_WNE_INC3_P*` |
| `earnings_dep_mean` | Mean earnings, dependent | — |
| `earnings_ind_mean` | Mean earnings, independent | — |
| `earnings_female_mean` | Mean earnings, female | — |
| `earnings_male_mean` | Mean earnings, male | — |
| `years_after_entry` | Time horizon (6-10) | Was encoded in variable name |
| `cohort_year` | Entry cohort year | Was encoded in file name |

**Default dataset** (`scorecard/colleges_scorecard_repayment_fsa`):

| Portal Column | Description | Original Scorecard Equivalent |
|---------------|-------------|-------------------------------|
| `default_rate` | Default rate (Float64) | `CDR2`, `CDR3` |
| `default_rate_denom` | Borrowers in cohort | `CDR3_DENOM` |
| `years_since_entering_repay` | 2 or 3 years | Was in variable name |

**Repayment dataset** (`scorecard/colleges_scorecard_repayment_nslds`):

| Portal Column | Description | Original Scorecard Equivalent |
|---------------|-------------|-------------------------------|
| `repay_rate` | Repayment rate (Float64) | `RPY_*YR_RT` |
| `repay_count` | Count of borrowers | — |
| `repay_rate_pell` | Repayment rate, Pell | — |
| `repay_rate_nopell` | Repayment rate, non-Pell | — |
| `repay_rate_lowincome` | Repayment rate, low income | — |
| `repay_rate_firstgen` | Repayment rate, first-gen | — |
| `repay_rate_male` / `_female` | Repayment rate by sex | — |
| `years_since_entering_repay` | 1, 3, 5, or 7 years | Was in variable name |

**Institutional Characteristics** (`scorecard/colleges_scorecard_inst_characteristics`):

| Portal Column | Description | Original Scorecard Equivalent |
|---------------|-------------|-------------------------------|
| `inst_name` | Institution name | `INSTNM` |
| `city` | City | `CITY` |
| `state_abbr` | State abbreviation | `STABBR` |
| `zip` | ZIP code | `ZIP` |
| `pred_degree_awarded_ipeds` | Predominant degree (0-4) | `PREDDEG` |
| `religious_affiliation` | Religious affiliation code | `RELAFFIL` |
| `under_investigation` | Under investigation (0/1) | — |
| `min_serving_historic_black` | HBCU flag (0/1) | `HBCU` |
| `min_serving_tribal` | Tribal college flag (0/1) | `TRIBAL` |
| `min_serving_hispanic` | HSI flag (0/1) | `HSI` |
| `menonly` / `womenonly` | Single-sex (0/1) | `MENONLY` / `WOMENONLY` |
| `currently_operating` | Operating (0/1) | `CURROPER` |
| `accreditor` | Accreditor name | `ACCREDAGENCY` |
| `latitude` / `longitude` | Coordinates | `LATITUDE` / `LONGITUDE` |

**Student Body NSLDS** (`scorecard/colleges_scorecard_student_body_nslds` — 51 columns):

| Portal Column | Description |
|---------------|-------------|
| `faminc_mean` / `faminc_med` | Family income mean/median |
| `dependent_pct` / `independent_pct` | Dependency share |
| `lowincome_pct` / `midincome_pct` / `highincome_pct` | Income distribution |
| `first_gen_student_pct` | First-generation share |
| `female_pct` | Female share |
| `age_24orolder_pct` | Non-traditional age share |
| `parents_highest_ed_*` | Parent education levels |

**Student Body Treasury** (`scorecard/colleges_scorecard_student_body_treasury` — 17 columns):

| Portal Column | Description |
|---------------|-------------|
| `age_entry` | Average age at entry |
| `hhinc_home_zip_med` | Median household income in home ZIP |
| `poverty_rate_home_zip` | Poverty rate in home ZIP |
| `unemp_rate_home_zip` | Unemployment rate in home ZIP |
| `white_home_zip_pct` / `black_home_zip_pct` / etc. | Racial composition of home ZIP |
| `bach_home_zip_pct` | Bachelor's degree share in home ZIP |

### Original Scorecard Naming Conventions (Historical Reference)

The sections below document the original Scorecard naming patterns. These names appear in the College Scorecard bulk download files at `collegescorecard.ed.gov` but **do NOT appear in Portal mirror data**. They are preserved here for cross-referencing purposes.

```
[METRIC]_[POPULATION]_[TIMEFRAME]_[DISAGGREGATION]_[FLAGS]
```

### Common Prefixes (Original Scorecard)

| Prefix | Meaning | Example |
|--------|---------|---------|
| `MD_` | Median | `MD_EARN_WNE_P6` |
| `MN_` | Mean | `MN_EARN_WNE_P6` |
| `PCT_` | Percent/Proportion | `PCT_PELL` |
| `NUM_` | Count | `NUM4_PUB` |
| `C_` | Completion | `C150_4` |
| `RPY_` | Repayment | `RPY_3YR_RT` |
| `DEBT_` | Debt | `DEBT_MDN` |

### Population Suffixes (Original Scorecard)

| Suffix | Population |
|--------|------------|
| `_WNE` | Working and Not Enrolled |
| `_NWNE` | Not Working and Not Enrolled |
| `_PELL` | Pell Grant recipients |
| `_NOPELL` | Non-Pell students |
| `_DEP` | Dependent students |
| `_IND` | Independent students |
| `_MALE` | Male students |
| `_FEMALE` | Female students |

### Time Frame Suffixes (Original Scorecard)

| Suffix | Time Frame |
|--------|------------|
| `_P6` | 6 years after entry |
| `_P8` | 8 years after entry |
| `_P10` | 10 years after entry |
| `_1YR` | 1 year |
| `_3YR` | 3 years |
| `_5YR` | 5 years |

### Income Disaggregation (Original Scorecard)

| Suffix | Income Level | FAFSA Family Income |
|--------|--------------|---------------------|
| `_INC1` | Low income | $0-$30,000 |
| `_INC2` | Middle income | $30,001-$75,000 |
| `_INC3` | High income | $75,001+ |
| `_LO_INC` | Low income (alternate) | Bottom third |
| `_MD_INC` | Middle income (alternate) | Middle third |
| `_HI_INC` | High income (alternate) | Top third |

### Race/Ethnicity Suffixes (Original Scorecard)

| Suffix | Group |
|--------|-------|
| `_WHITE` | White |
| `_BLACK` | Black or African American |
| `_HISP` | Hispanic |
| `_ASIAN` | Asian |
| `_AIAN` | American Indian/Alaska Native |
| `_NHPI` | Native Hawaiian/Pacific Islander |
| `_2MOR` | Two or more races |
| `_NRA` | Non-resident alien |
| `_UNKN` | Unknown |

### Flag Suffixes (Original Scorecard)

| Suffix | Meaning |
|--------|---------|
| `_SUPP` | Suppression flag |
| `_N` | Count/denominator |
| `_POOLED` | Pooled cohort |

## Key Variable Categories

> **Note:** The sections below include both Portal column names (lowercase, actual data) and original Scorecard names (UPPERCASE, for cross-referencing bulk downloads). When working with Portal mirror data, always use the lowercase Portal names.

### Institutional Identifiers

| Portal Column | Original | Description | Format |
|---------------|----------|-------------|--------|
| `unitid` | `UNITID` | IPEDS institution ID | 6-digit integer |
| `opeid` | `OPEID` | OPE ID (Title IV) | 8-digit string (zero-padded) |
| `opeid6` | `OPEID6` | 6-digit OPE ID | Integer (no zero-padding in Portal) |
| `inst_name` | `INSTNM` | Institution name | String |
| `city` | `CITY` | City | String |
| `state_abbr` | `STABBR` | State abbreviation | 2-letter code |
| `zip` | `ZIP` | ZIP code | String |

> **Note:** `inst_name`, `city`, `state_abbr`, and `zip` are in the `inst_characteristics` dataset, NOT in the earnings dataset. Join on `unitid`.

### Institution Characteristics

> **Portal Encoding:** All categorical variables use **integer codes** in the Education Data Portal. The original Scorecard documentation may show string values, but Portal data returns integers.

| Portal Column | Original | Description | Values |
|---------------|----------|-------------|--------|
| (not in Portal) | `CONTROL` | Control type | 1=Public, 2=Private NP, 3=Private FP |
| `pred_degree_awarded_ipeds` | `PREDDEG` | Predominant degree | 0-4 (see below) |
| (not in Portal) | `HIGHDEG` | Highest degree | 0-4 |
| (not in Portal) | `LOCALE` | Urban/rural locale | 11-43 (see codes) |
| `min_serving_historic_black` | `HBCU` | HBCU indicator | 0, 1 |
| `menonly` | `MENONLY` | Men only | 0, 1 |
| `womenonly` | `WOMENONLY` | Women only | 0, 1 |
| `religious_affiliation` | `RELAFFIL` | Religious affiliation | Integer codes (see below) |

> **Note:** `CONTROL`, `HIGHDEG`, and `LOCALE` are NOT in the Portal `inst_characteristics` dataset. For control type, join to the IPEDS directory dataset.

### Predominant Degree Codes (`pred_degree_awarded_ipeds`)

| Code | Description |
|------|-------------|
| 0 | Not classified |
| 1 | Predominantly certificate-degree granting |
| 2 | Predominantly associate's-degree granting |
| 3 | Predominantly bachelor's-degree granting |
| 4 | Entirely graduate-degree granting |

### Yes/No Flag Codes

Many Scorecard fields use boolean indicators for institutional characteristics. In the Portal `inst_characteristics` dataset, these are stored as integers with `null` for missing:

| Code | Meaning |
|------|---------|
| 0 | No |
| 1 | Yes |
| `null` | Missing/not reported |

> **Empirical note:** The codebook documents `-1, -2, -3` codes, but the actual Portal parquet data uses only `0`, `1`, and `null` for these flag columns. The `-3/-2/-1` codes may appear in the original Scorecard bulk downloads but have been normalized to `null` in Portal mirrors.

**Variables using Yes/No encoding:**
- `under_investigation` - Schools on Heightened Cash Monitoring 2
- `min_serving_historic_black` - HBCU flag
- `min_serving_predominant_black` - Predominantly black institution
- `min_serving_annh` - Alaska Native Native Hawaiian-serving
- `min_serving_tribal` - Tribal college or university
- `min_serving_aanipi` - Asian American Native American Pacific Islander-serving
- `min_serving_hispanic` - Hispanic-serving institution
- `min_serving_na_nontribal` - Native American nontribal institution
- `menonly` - Men-only college
- `womenonly` - Women-only college
- `currently_operating` - Currently operating institution

### Religious Affiliation Codes

> **Source:** `scorecard/codebook_colleges_scorecard_institutional-characteristics.xls` (values sheet, format `religious_affiliation`). 76 positive codes documented; 62 appear in current Portal data (14 codebook-only codes marked with \*). Verified 2026-02-10.

| Code | Description |
|------|-------------|
| -3 | Suppressed data |
| -2 | Not applicable |
| -1 | Missing/not reported |
| 22 | American Evangelical Lutheran Church |
| 24 | African Methodist Episcopal Zion Church |
| 26 | Not applicable \* |
| 27 | Assemblies of God Church |
| 28 | Brethren Church |
| 29 | Brethren in Christ Church \* |
| 30 | Roman Catholic |
| 33 | Wisconsin Evangelical Lutheran Synod |
| 34 | Christ and Missionary Alliance Church |
| 35 | Christian Reformed Church |
| 36 | Evangelical Congregational Church |
| 37 | Evangelical Covenant Church of America |
| 38 | Evangelical Free Church of America |
| 39 | Evangelical Lutheran Church |
| 40 | International United Pentecostal Church \* |
| 41 | Free Will Baptist Church |
| 42 | Interdenominational |
| 43 | Mennonite Brethren Church |
| 44 | Moravian Church |
| 45 | North American Baptist |
| 46 | American Lutheran and Lutheran Church in America \* |
| 47 | Pentecostal Holiness Church |
| 48 | Christian Churches and Churches of Christ |
| 49 | Reformed Church in America |
| 50 | Episcopal Church |
| 51 | African Methodist Episcopal |
| 52 | American Baptist |
| 53 | American Lutheran \* |
| 54 | Baptist |
| 55 | Christian Methodist Episcopal |
| 56 | Church of Christ (Scientist) \* |
| 57 | Church of God |
| 58 | Church of Brethren |
| 59 | Church of the Nazarene |
| 60 | Cumberland Presbyterian |
| 61 | Christian Church (Disciples of Christ) |
| 64 | Free Methodist |
| 65 | Friends |
| 66 | Presbyterian Church (USA) |
| 67 | Lutheran Church in America |
| 68 | Lutheran Church - Missouri Synod |
| 69 | Mennonite Church |
| 70 | General Conference Mennonite Church \* |
| 71 | United Methodist |
| 73 | Protestant Episcopal |
| 74 | Churches of Christ |
| 75 | Southern Baptist |
| 76 | United Church of Christ |
| 77 | Protestant \* |
| 78 | Multiple Protestant Denomination |
| 79 | Other Protestant |
| 80 | Jewish |
| 81 | Reformed Presbyterian Church |
| 82 | Reorganized Latter Day Saints Church \* |
| 83 | Seventh Day Adventists Church \* |
| 84 | United Brethren Church |
| 86 | Independent Fundamental Church of America \* |
| 87 | Missionary Church Inc |
| 88 | Undenominational |
| 89 | Wesleyan |
| 91 | Greek Orthodox |
| 92 | Russian Orthodox |
| 93 | Unitarian Universalist |
| 94 | Latter Day Saints (Mormon Church) |
| 95 | Seventh Day Adventists |
| 97 | The Presbyterian Church in America |
| 98 | Salvation Army \* |
| 100 | Original Free Will Baptist |
| 101 | Ecumenical Christian \* |
| 102 | Evangelical Christian |
| 103 | Presbyterian |
| 105 | General Baptist |
| 106 | Muslim \* |
| 107 | Plymouth Brethren |
| 108 | Nondenominational |
| 200 | Other (none of the above) |

\* Code appears in codebook but not observed in current Portal mirror data (may appear in other years or original bulk downloads).

### Admissions

| Variable | Description |
|----------|-------------|
| `ADM_RATE` | Admission rate |
| `ADM_RATE_ALL` | Admission rate, all campuses |
| `SATVR25` | SAT verbal 25th percentile |
| `SATVR75` | SAT verbal 75th percentile |
| `SATMT25` | SAT math 25th percentile |
| `SATMT75` | SAT math 75th percentile |
| `ACTCM25` | ACT composite 25th percentile |
| `ACTCM75` | ACT composite 75th percentile |

### Enrollment

| Variable | Description |
|----------|-------------|
| `UGDS` | Undergraduate enrollment |
| `UG` | Undergraduate Title IV enrollment |
| `UGDS_WHITE` | White enrollment share |
| `UGDS_BLACK` | Black enrollment share |
| `UGDS_HISP` | Hispanic enrollment share |
| `UGDS_ASIAN` | Asian enrollment share |
| `PPTUG_EF` | Part-time share |
| `PFTFTUG1_EF` | Full-time, first-time share |

### Cost Variables

| Variable | Description |
|----------|-------------|
| `COSTT4_A` | Average cost (academic year) |
| `COSTT4_P` | Average cost (program year) |
| `TUITIONFEE_IN` | In-state tuition and fees |
| `TUITIONFEE_OUT` | Out-of-state tuition and fees |
| `TUITIONFEE_PROG` | Program-year tuition |
| `NPT4_PUB` | Net price, public |
| `NPT4_PRIV` | Net price, private |
| `NPT4_PROG` | Net price, program |

### Aid Variables

| Variable | Description |
|----------|-------------|
| `PCTPELL` | Percent receiving Pell grants |
| `PCTFLOAN` | Percent receiving federal loans |
| `PELL_EVER` | Ever received Pell |
| `LOAN_EVER` | Ever received loan |
| `FTFTPCTPELL` | First-time full-time Pell share |
| `FTFTPCTFLOAN` | First-time full-time loan share |

### Earnings Variables

| Variable | Description |
|----------|-------------|
| `MD_EARN_WNE_P6` | Median earnings at 6 years |
| `MD_EARN_WNE_P8` | Median earnings at 8 years |
| `MD_EARN_WNE_P10` | Median earnings at 10 years |
| `PCT10_EARN_WNE_P6` | 10th percentile earnings |
| `PCT25_EARN_WNE_P6` | 25th percentile earnings |
| `PCT75_EARN_WNE_P6` | 75th percentile earnings |
| `PCT90_EARN_WNE_P6` | 90th percentile earnings |
| `COUNT_WNE_P6` | Count working and not enrolled |

### Debt Variables

| Variable | Description |
|----------|-------------|
| `DEBT_MDN` | Median debt |
| `DEBT_MEAN` | Mean debt |
| `GRAD_DEBT_MDN` | Median debt, completers |
| `WDRAW_DEBT_MDN` | Median debt, withdrawals |
| `LO_INC_DEBT_MDN` | Median debt, low income |
| `MD_INC_DEBT_MDN` | Median debt, middle income |
| `HI_INC_DEBT_MDN` | Median debt, high income |

### Repayment Variables

| Variable | Description |
|----------|-------------|
| `RPY_1YR_RT` | 1-year repayment rate |
| `RPY_3YR_RT` | 3-year repayment rate |
| `RPY_5YR_RT` | 5-year repayment rate |
| `RPY_7YR_RT` | 7-year repayment rate |
| `CDR3` | 3-year cohort default rate |
| `DBRR1_FED_UG_RT` | Dollar-based repayment rate, 1 year |
| `DBRR4_FED_UG_RT` | Dollar-based repayment rate, 4 years |

### Completion Variables

| Variable | Description |
|----------|-------------|
| `C150_4` | 150% completion rate, 4-year |
| `C150_L4` | 150% completion rate, <4-year |
| `C200_4` | 200% completion rate, 4-year |
| `C200_L4` | 200% completion rate, <4-year |
| `C150_4_POOLED` | Pooled 150% rate |
| `RET_FT4` | Retention rate, 4-year full-time |
| `RET_PT4` | Retention rate, 4-year part-time |

## Special Values

### Missing Data Codes

> **CRITICAL: Missing data encoding differs by dataset.**
>
> Unlike most Portal datasets where `null` is the universal missing indicator, the Scorecard **earnings dataset** uses **`-3` integer codes** extensively for suppressed values in earnings and count columns. Yes/No flags in the `inst_characteristics` dataset use `null` for missing.

| Dataset | Suppression Indicator | Empirical Verification |
|---------|----------------------|----------------------|
| **Earnings** (earnings, counts) | `-3` integer code | Verified: ~24K rows have -3 in `earnings_mean` |
| **Inst Characteristics** (flags) | `null` | Verified: 170K+ nulls, values only 0/1 |
| **Default** (rates) | `null` | Verified: rates are Float64 with nulls |
| **Repayment** (rates, counts) | `null` | Verified: rates are Float64 with nulls |
| **Student Body** (percentages) | `null` | Verified: Float64 with nulls |

### Handling Special Values

```python
import polars as pl

# EARNINGS: Filter out -3 suppression codes AND nulls
valid_earnings = df.filter(
    pl.col("earnings_med").is_not_null() &
    (pl.col("earnings_med") != -3) &
    (pl.col("earnings_med") > 0)
)

# Also filter count columns for -3
valid_with_counts = valid_earnings.filter(
    pl.col("count_working").is_not_null() &
    (pl.col("count_working") != -3)
)

# INST CHARACTERISTICS: Filter out nulls for flag columns
operating = inst_df.filter(
    pl.col("currently_operating") == 1
)

# For yes/no flags, valid values are 0 and 1 (nulls = missing)
hbcus = inst_df.filter(
    pl.col("min_serving_historic_black") == 1
)

# RATES (default, repayment): Filter out nulls
valid_default = default_df.filter(
    pl.col("default_rate").is_not_null()
)
```

### Portal vs Original Scorecard Format

| Original Format | Portal Parquet |
|-----------------|----------------|
| `"PrivacySuppressed"` | `-3` (earnings) or `null` (other datasets) |
| `"NULL"` | `null` |
| Mixed-case column names | All lowercase |
| Wide format (time in name) | Long format (time as column) |
| String categories | Integer codes |

### Key Observation: Scorecard Data in Portal

**In Portal mirror parquet files:**
- Categorical variables use **integer codes** (e.g., `pred_degree_awarded_ipeds` = 0, 1, 2, 3, 4)
- Yes/No flags use **0 and 1** with `null` for missing (e.g., `min_serving_historic_black`)
- Earnings/count columns use **`-3` for suppression** (NOT null)
- Rate columns (default, repayment) use `null` for missing
- Religious affiliation has 62 unique integer values in actual data (22-200)

**Always verify actual data types and suppression patterns when working with Portal data.**

## Variable Data Types

### Numeric Variables

Most outcome variables should be numeric:
- Earnings: float
- Rates: float (0-1 or percentage)
- Counts: integer
- Debt: float

### Categorical Variables

| Variable | Type | Values |
|----------|------|--------|
| `CONTROL` | categorical | 1, 2, 3 |
| `PREDDEG` | categorical | 0-4 |
| `LOCALE` | categorical | 11-43 |
| `STABBR` | string | State codes |

### String Variables

| Variable | Type |
|----------|------|
| `INSTNM` | string |
| `CITY` | string |
| `ZIP` | string |
| `OPEID` | string (leading zeros) |

## Scorecard API Names (Historical Reference)

> **Note:** The College Scorecard has its own API at `api.data.gov/ed/collegescorecard/`. This API uses a nested naming system that differs from both the bulk download names and the Portal names. **This API is NOT used by the DAAF data pipeline** — all data access uses the Education Data Portal mirror system. These mappings are preserved for reference only.

| Download Name | API Name |
|---------------|----------|
| `MD_EARN_WNE_P6` | `latest.earnings.6_yrs_after_entry.median` |
| `C150_4` | `latest.completion.completion_rate_4yr_150nt` |
| `DEBT_MDN` | `latest.aid.median_debt.completers.overall` |

## Commonly Used Variable Sets (Portal Column Names)

### Earnings Analysis

```python
# From scorecard/colleges_scorecard_earnings (filter years_after_entry)
["unitid", "year", "years_after_entry", "earnings_med", "earnings_mean",
 "earnings_pct25", "earnings_pct75", "count_working"]
# Join to inst_characteristics for: inst_name, pred_degree_awarded_ipeds
# Join to IPEDS directory for: control type
```

### Default/Repayment Analysis

```python
# From scorecard/colleges_scorecard_repayment_fsa
["unitid", "year", "years_since_entering_repay", "default_rate", "default_rate_denom"]
# From scorecard/colleges_scorecard_repayment_nslds
["unitid", "year", "years_since_entering_repay", "repay_rate", "repay_count",
 "repay_rate_pell", "repay_rate_lowincome"]
```

### Institutional Context

```python
# From scorecard/colleges_scorecard_inst_characteristics
["unitid", "inst_name", "city", "state_abbr", "pred_degree_awarded_ipeds",
 "min_serving_historic_black", "religious_affiliation", "currently_operating"]
```

## Field-Level Variable Patterns

Field of study data uses CIP codes:

| Variable | Description |
|----------|-------------|
| `CIPCODE` | CIP code (4 or 6 digit) |
| `CIPDESC` | CIP description |
| `CREDLEV` | Credential level |
| `CREDDESC` | Credential description |
| `EARN_MDN_HI_1YR` | Median earnings, 1 year post-completion |
| `EARN_MDN_HI_2YR` | Median earnings, 2 years post-completion |
| `DEBT_ALL_STGP_ANY_MDN` | Median debt by program |

## Codebook Reference

For authoritative variable definitions, consult the codebook `.xls` files co-located with data in the mirrors. Use `get_codebook_url()` from `fetch-patterns.md` to construct download URLs.

| Dataset | Codebook Path |
|---------|---------------|
| Earnings | `scorecard/codebook_colleges_scorecard_earnings` |
| Default | `scorecard/codebook_colleges_scorecard_default` |
| Institutional Characteristics | `scorecard/codebook_colleges_scorecard_institutional-characteristics` |
| Repayment | `scorecard/codebook_colleges_scorecard_repayment` |
| Student Characteristics (Aid) | `scorecard/codebook_colleges_scorecard_student-characteristics_aid-applicants` |
| Student Characteristics (Home) | `scorecard/codebook_colleges_scorecard_student-characteristics_home-neighborhood` |

The original College Scorecard data dictionary is also available at `collegescorecard.ed.gov/assets/CollegeScorecardDataDictionary.xlsx`, but it documents the original Scorecard variable names, not Portal column names.

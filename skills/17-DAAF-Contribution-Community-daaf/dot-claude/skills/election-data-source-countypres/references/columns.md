# Column Reference: County Presidential Returns 2000-2024

## Column Summary

| Column | Type | Nulls | Null% | Unique | Description |
|--------|------|-------|-------|--------|-------------|
| state | String | 0 | 0.00% | 51 | Full state name (UPPERCASE) |
| county_name | String | 0 | 0.00% | 1,921 | County name (UPPERCASE) |
| year | Int64 | 0 | 0.00% | 7 | Presidential election year (2000-2024) |
| state_po | String | 0 | 0.00% | 51 | 2-letter USPS state abbreviation |
| county_fips | Int64 | 52 | 0.06% | 3,158 | County FIPS code (5-digit integer) |
| office | String | 0 | 0.00% | 1 | Constant: "US PRESIDENT" |
| candidate | String | 0 | 0.00% | 19 | Candidate name or meta-entry |
| party | String | 0 | 0.00% | 6 | Political party (UPPERCASE) |
| candidatevotes | Int64 | 37 | 0.04% | 22,108 | Votes received by candidate |
| totalvotes | Int64 | 0 | 0.00% | 16,846 | Total votes in county-year-mode |
| version | Int64 | 0 | 0.00% | 1 | Dataset version date (YYYYMMDD) |
| mode | String | 0 | 0.00% | 20 | Ballot mode (TOTAL or breakdown) |

**Note:** Column order in the actual data file differs from the codebook. The file
starts with `state, county_name, year, state_po, ...` while the codebook lists
`year, state, state_po, county_name, ...`.

## Detailed Column Profiles

### state (String)
- **Null rate:** 0%
- **Unique values:** 51 (50 states + DC)
- **Format:** Full state name, ALL UPPERCASE (e.g., "CALIFORNIA", "DISTRICT OF COLUMBIA")
- **Length range:** 4-20 characters
- **Top by row count:** TEXAS (8.09%), GEORGIA (5.40%), NORTH CAROLINA (5.20%)

### county_name (String)
- **Null rate:** 0%
- **Unique values:** 1,921
- **Format:** ALL UPPERCASE, no "County" suffix in most cases (25 exceptions)
- **Length range:** 3-21 characters
- **Note:** Names are not fully standardized; 25 rows contain "COUNTY" in the name

### year (Int64)
- **Null rate:** 0%
- **Values:** 2000, 2004, 2008, 2012, 2016, 2020, 2024
- **Row distribution:** 2020 has the most rows (22,093; 23.47%) due to mode breakdowns; 2004-2016 have identical counts (9,474 each)
- **Per-year row counts:**

  | Year | Raw Rows | After Mode Reconstruction | Candidates/County |
  |------|----------|--------------------------|-------------------|
  | 2000 | ~12,600 | ~12,600 (all TOTAL) | ~4 |
  | 2004-2016 | ~9,500 each | ~9,500 (all TOTAL) | ~3 |
  | 2020 | ~22,000 | ~10,000 | ~3-4 |
  | 2024 | ~21,500 | ~11,300 | ~3-4 |

  See `./mode-reconstruction.md` for the reconstruction approach

### state_po (String)
- **Null rate:** 0%
- **Unique values:** 51
- **Format:** 2-character USPS abbreviation (e.g., "CA", "NY", "DC")
- **Relationship:** Exact 1:1 mapping with `state`

### county_fips (Int64)
- **Null rate:** 0.06% (52 nulls)
- **Unique values:** 3,158
- **Range:** 1001 - 2938000
- **Standard format:** SSCCC (2-digit state FIPS * 1000 + 3-digit county)
- **Null pattern:** CT (16), ME (16), RI (20) — all in pre-2020/2024 years
- **Anomalies:**
  - Kansas City, MO: FIPS 2938000 (non-standard, not a real county FIPS)
  - Alaska 2004: FIPS 2001-2099 (state FIPS 02 + district number, not counties)
  - AR 2024 FIPS contamination: St. Francis County rows under FIPS 5135 (Sharp County) — see `./quality-notes.md`
- **Join preparation:** When converting `county_fips` to string for joins, **zero-pad to 5 characters**. Arkansas FIPS codes appear as `5xxx` (4 digits) without padding, causing join failures against 5-digit FIPS keys in Census, SAIPE, and other datasets.
  ```python
  # Always zero-pad before joining
  df = df.with_columns(
      pl.col("county_fips").cast(pl.Utf8).str.zfill(5).alias("county_fips_str")
  )
  ```

### office (String)
- **Null rate:** 0%
- **Single value:** "US PRESIDENT" (invariant — all rows)
- **Note:** Codebook describes this as "President"; actual value is "US PRESIDENT"

### candidate (String)
- **Null rate:** 0%
- **Unique values:** 19
- **Format:** ALL UPPERCASE full names (e.g., "BARACK OBAMA", "DONALD J TRUMP")
- **Naming inconsistency:** "DONALD TRUMP" (2016) vs "DONALD J TRUMP" (2020, 2024)
- **Non-candidate entries:** OTHER, TOTAL VOTES CAST, UNDERVOTES, OVERVOTES, SPOILED
- **Top by row count:** OTHER (29.26%), DONALD J TRUMP (10.94%), BARACK OBAMA (6.71%)

### party (String)
- **Null rate:** 0% (but 501 empty strings)
- **Values:** DEMOCRAT, REPUBLICAN, LIBERTARIAN, GREEN, OTHER, "" (empty)
- **Coverage varies by year** — see SKILL.md Party Values table

### candidatevotes (Int64)
- **Null rate:** 0.04% (37 nulls)
- **Range:** 0 - 3,028,885
- **Mean:** 10,440 | **Median:** 994
- **Zero values:** 3,908 (4.15%) — mostly minor parties/candidates
- **Max:** Los Angeles County, Biden 2020 (3,028,885)
- **Null pattern:** All 37 nulls are NM 2024 mode breakdown rows

### totalvotes (Int64)
- **Null rate:** 0%
- **Range:** 0 - 4,264,365
- **Mean:** 43,391 | **Median:** 11,467
- **Zero values:** 50 (0.05%)
- **Max:** Los Angeles County 2020 (4,264,365)

### version (Int64)
- **Null rate:** 0%
- **Single value:** 20260211 (all rows)
- **Format:** YYYYMMDD integer (represents 2026-02-11)
- **Note:** This is a dataset-wide version stamp, not per-row

### mode (String)
- **Null rate:** 0% (but 2,795 empty strings in 2024)
- **Unique values:** 20
- **Dominant value:** TOTAL (76.38% of all rows)
- **2020 breakdown modes (11 states):** ABSENTEE, ELECTION DAY, EARLY, PROVISIONAL, ABSENTEE BY MAIL, ONE STOP, ADVANCED VOTING, EARLY VOTE, FAILSAFE, FAILSAFE PROVISIONAL, IN-PERSON ABSENTEE, MAIL, 2ND ABSENTEE, PROV, EARLY VOTING
- **2024 breakdown modes:** ABSENTEE, ELECTION DAY, EARLY, EARLY VOTING, PROVISIONAL, FAILSAFE PROVISIONAL, MAIL-IN, VOTE CENTER, LATE EARLY VOTING, "" (empty)

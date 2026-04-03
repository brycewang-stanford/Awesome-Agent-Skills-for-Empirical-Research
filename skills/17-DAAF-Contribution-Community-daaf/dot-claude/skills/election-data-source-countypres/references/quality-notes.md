# Data Quality Notes: County Presidential Returns 2000-2024

## Overall Quality Assessment

| Dimension | Score | Notes |
|-----------|-------|-------|
| Completeness | 99.9% | 52 null FIPS, 37 null candidatevotes |
| Documentation accuracy | 85% | Several discrepancies between codebook and data |
| Coded value coverage | 90% | Empty strings in party and mode undocumented |
| Duplicate rate | 0.09% | 83 exact duplicate rows |

## Known Anomalies

### Alaska 2004

**Severity:** WARNING

Alaska 2004 reports by election district rather than county (borough). The `county_fips`
field stores state FIPS (02) + district number (01-40, 99) giving values 2001-2099. The
`county_name` field stores "DISTRICT 1" through "DISTRICT 40" and "DISTRICT 99".

**Impact:**
- FIPS codes 2001-2099 do NOT correspond to real county FIPS codes
- Vote totals are overstated per the codebook: "district returns significantly overstate the number of votes cast"
- Cannot join these rows to census/education data via `county_fips`
- Other Alaska years (2000, 2008-2024) report 41 unique FIPS/county combinations

**Recommendation:** Exclude Alaska 2004 from county-level analyses or handle separately.

### Arkansas FIPS Contamination: Sharp / St. Francis County (2024)

**Severity:** BLOCKER

MEDSL 2024 source data places St. Francis County, AR rows under FIPS 5135 (Sharp County)
instead of the correct FIPS 5123. Both counties' candidate rows appear under FIPS 5135,
and `totalvotes` reflects their combined total (13,416) rather than individual county totals.

**Impact:**
- Sharp County shows a spurious +33.8pp Democratic shift (6-sigma outlier) due to
  St. Francis County's more Democratic-leaning votes being attributed to it
- St. Francis County is entirely absent from analysis (no FIPS 5123 rows in 2024)
- Any county-level shift or trend analysis is corrupted for both counties

**Detection:** Filter FIPS 5135 + year 2024 and inspect `county_name` — rows for
"ST FRANCIS" appear alongside "SHARP" under the same FIPS code.

**Fix:**
```python
# 1. Reassign FIPS: 5135 -> 5123 where county_name is St. Francis
df = df.with_columns(
    pl.when(
        (pl.col("county_fips") == 5135) & (pl.col("year") == 2024)
        & (pl.col("county_name") == "ST FRANCIS")
    )
    .then(pl.lit(5123))
    .otherwise(pl.col("county_fips"))
    .alias("county_fips")
)

# 2. Recalculate totalvotes for both counties (sum of candidatevotes)
# Sharp: 7,437 total; St. Francis: 5,979 total (combined original: 13,416)
for fips in [5135, 5123]:
    fips_rows = df.filter((pl.col("county_fips") == fips) & (pl.col("year") == 2024))
    if fips_rows.shape[0] > 0:
        correct_total = int(fips_rows["candidatevotes"].sum())
        df = df.with_columns(
            pl.when((pl.col("county_fips") == fips) & (pl.col("year") == 2024))
            .then(pl.lit(correct_total))
            .otherwise(pl.col("totalvotes"))
            .alias("totalvotes")
        )
```

**County name normalization:** 2020 uses "ST. FRANCIS" (with period), 2024 uses
"ST FRANCIS" (without period). Normalize if joining across years.

**Note:** This is a source data error in MEDSL version 20260211. It may be corrected
in future releases — check before applying the fix.

### Connecticut FIPS Geography Mismatch (2022+)

**Severity:** WARNING

Connecticut reorganized from 8 legacy counties to 9 planning regions effective in the
2022 Census Bureau geography vintage. MEDSL county presidential returns still use legacy
county FIPS codes (09001-09015).

**Impact:**
- Joins to 2022+ TIGER/Line shapefiles fail for CT (8 legacy counties vs 9 planning regions)
- Does not affect the election data itself — only geographic joins and mapping

**Workaround:** Use 2020-vintage Census TIGER shapefiles when CT county coverage matters.

### Kansas City, MO (FIPS 2938000)

**Severity:** INFO

Kansas City, Missouri is an independent city that spans multiple counties. It is assigned
a non-standard FIPS code of 2938000 (standard MO county FIPS range: 29001-29510).

**Impact:**
- Will not join to standard census/education datasets
- Only affects MO rows for Kansas City

### Null county_fips (CT, ME, RI)

**Severity:** WARNING

| State | Null FIPS Rows | Years Affected |
|-------|----------------|----------------|
| CT | 16 | 2000, 2004, 2008, 2012, 2016 |
| ME | 16 | 2000, 2004, 2008, 2012, 2016 |
| RI | 20 | 2000, 2004, 2008, 2012, 2016, 2020 |

**Impact:** Cannot join these rows to other datasets via `county_fips`.
**Note:** CT and ME have FIPS in 2020 and 2024. RI has FIPS only in 2024.
**Workaround:** Use `state_po` + `county_name` as a fallback join key for these rows.

### Null candidatevotes (NM 2024)

**Severity:** INFO

37 rows in New Mexico 2024 have null `candidatevotes`. All are for non-TOTAL mode
breakdowns (ABSENTEE, EARLY, ELECTION DAY, TOTAL). The candidate in these rows is
"CHASE OLIVER" (Libertarian) with null votes across mode breakdowns.

### Duplicate Rows

**Severity:** WARNING

83 exact duplicate rows exist in the dataset. These should be deduplicated before
analysis. The duplicates likely arise from data processing artifacts.

### Non-Candidate Entries

**Severity:** WARNING

The `candidate` column contains entries that are not actual candidate names:
- `TOTAL VOTES CAST` (427 rows) -- county total, redundant with `totalvotes`
- `UNDERVOTES` (402 rows) -- blank/no-selection ballots
- `OVERVOTES` (380 rows) -- multiple-selection (invalidated) ballots
- `SPOILED` (14 rows) -- invalidated ballots

These inflate row counts and will skew candidate-level analyses if not filtered.

### Vote Total Inconsistencies

**Severity:** INFO

- 49 county-years where `sum(candidatevotes) > totalvotes` (TOTAL mode)
- 50 rows with `totalvotes = 0`
- 2 groups (2012, 2016) with null `county_fips` have inconsistent `totalvotes`

The sum > total cases are minor and likely due to rounding or write-in handling.

### Empty String Values

**Severity:** WARNING

| Column | Empty Rows | Year |
|--------|-----------|------|
| `party` | 501 | 2024 |
| `mode` | 2,795 | 2024 |

These are undocumented in the codebook. The empty `party` values correspond to
TOTAL VOTES CAST, UNDERVOTES, and OVERVOTES entries (which have no party affiliation).
The empty `mode` values appear to be a 2024 data processing artifact.

## Per-State Source Quality

The `sources-president.tab` file documents per-state data sources for the 2020 election:

- **Certified/official:** 45 states
- **Unofficial:** 1 state (SD)
- **Not stated:** 5 states
- **Missing votes flagged:** 16 states (AR, CO, IL, KS, KY, LA, MI, MS, NJ, NM, OK, PA, SD, TN, TX, WV)

"Missing votes" typically means write-in candidates, scattered votes, or minor candidates
whose vote counts were not available from the state source.

## Party Coverage Inconsistencies

The codebook states the dataset reports results for "three parties that achieved ballot
access in 50 states: Democrat, Republican, and Libertarian." However:

1. LIBERTARIAN appears as a named party only in 2020 and 2024 (not 2000-2016)
2. GREEN appears in 2000 (Ralph Nader) and 2020 but is not mentioned
3. For 2004-2016, Libertarian candidates appear to be folded into OTHER
4. The three-party statement may describe a practice that started later or applies
   inconsistently across years

## Documentation vs Data Discrepancies

| # | Category | Issue | Codebook Says | Data Shows |
|---|----------|-------|---------------|------------|
| 1 | Column order | Columns ordered differently | year first | state first |
| 2 | office value | Different text | "President" | "US PRESIDENT" |
| 3 | candidate scope | Non-candidates present | "name of the candidate" | Includes UNDERVOTES etc. |
| 4 | party values | Empty string | 5 named values | 6 including "" |
| 5 | party coverage | LIBERTARIAN/GREEN | "three parties" | Varies by year |
| 6 | mode years | Mode breakdown timing | "specified for 2020" | Also in 2024 |
| 7 | totalvotes scope | Definition scope | "county-year" | county-year-mode |
| 8 | version date | Date mismatch | Updated 2025-07-12 | Version 20260211 |

# Variable Definitions: County Presidential Returns 2000-2024

Complete encoding tables and formal definitions for all 12 columns.

## Source Information

- **Dataset:** County Presidential Election Returns 2000-2024
- **Producer:** MIT Election Data and Science Lab (MEDSL)
- **Harvard Dataverse DOI:** 10.7910/DVN/VOQCHQ
- **Data version:** 20260211 (February 11, 2026)
- **Codebook date:** 2025-07-12
- **QA methodology:** Baltz et al. (2022) Scientific Data, https://www.nature.com/articles/s41597-022-01745-0

## Column Definitions

### year
- **Type:** Int64
- **Description:** Year of the presidential general election
- **Values:** {2000, 2004, 2008, 2012, 2016, 2020, 2024}
- **Codebook:** "election year"

### state
- **Type:** String
- **Description:** Full name of the U.S. state or territory
- **Values:** 51 unique (50 states + District of Columbia)
- **Format:** ALL UPPERCASE
- **Codebook:** "state name"

### state_po
- **Type:** String (2-char)
- **Description:** USPS postal abbreviation for the state
- **Values:** 51 unique, exact 1:1 mapping with `state`
- **Codebook:** "U.S. postal code state abbreviation"

### county_name
- **Type:** String
- **Description:** Name of the county or county-equivalent
- **Values:** 1,921 unique
- **Format:** ALL UPPERCASE, generally no "County" suffix
- **Codebook:** "county name"

### county_fips
- **Type:** Int64 (nullable)
- **Description:** Federal Information Processing Standards county code
- **Format:** SSCCC where SS = state FIPS, CCC = county code (stored as integer, not zero-padded)
- **Range:** 1001 - 56045 (standard); 2938000 (Kansas City MO, non-standard)
- **Nulls:** 52 (CT, ME, RI in certain years)
- **Codebook:** "county FIPS code"
- **Special cases:**
  - Alaska 2004: Uses 2001-2099 (state FIPS 02 + district number, not county codes)
  - Kansas City, MO: Uses 2938000 (not a standard 5-digit FIPS)

### office
- **Type:** String
- **Description:** Office being contested
- **Values:** {"US PRESIDENT"} (constant, all rows)
- **Codebook:** "President" (note: actual value is "US PRESIDENT")

### candidate
- **Type:** String
- **Description:** Candidate name or ballot-related category
- **Named candidates:** AL GORE, GEORGE W. BUSH, RALPH NADER, JOHN KERRY, BARACK OBAMA, JOHN MCCAIN, MITT ROMNEY, HILLARY CLINTON, DONALD TRUMP, DONALD J TRUMP, JOSEPH R BIDEN JR, JO JORGENSEN, KAMALA D HARRIS, CHASE OLIVER
- **Aggregate/meta values:** OTHER, TOTAL VOTES CAST, UNDERVOTES, OVERVOTES, SPOILED
- **Codebook:** "name of the candidate"

### party
- **Type:** String
- **Description:** Political party affiliation of the candidate
- **Values:** {DEMOCRAT, REPUBLICAN, LIBERTARIAN, GREEN, OTHER, ""(empty)}
- **Codebook:** "party of the candidate; takes form of DEMOCRAT, REPUBLICAN, GREEN, LIBERTARIAN, or OTHER"
- **Note:** Empty string appears only in 2024 (501 rows); LIBERTARIAN named only in 2020-2024; GREEN only in 2000 and 2020

### candidatevotes
- **Type:** Int64 (nullable)
- **Description:** Number of votes received by this candidate for this party in this county-year-mode
- **Range:** 0 - 3,028,885
- **Nulls:** 37 (NM 2024 mode breakdown rows)
- **Zeros:** 3,908 (4.15%, mostly minor parties)
- **Codebook:** "votes received by this candidate for this particular party"

### totalvotes
- **Type:** Int64
- **Description:** Total number of votes cast in this county-year-mode combination
- **Range:** 0 - 4,264,365
- **Zeros:** 50 (0.05%)
- **Codebook:** "total number of votes cast in this county-year"
- **Note:** Codebook says "county-year" but value actually varies by mode within county-year
- **Deduplication warning:** `totalvotes` is repeated for every candidate row within a
  county-year-mode. When aggregating to state or national level, **deduplicate to one row
  per (county_fips, year) BEFORE summing** to avoid inflating totals by the number of
  candidates per county.
  ```python
  # WRONG: sums totalvotes once per candidate row (~3-4x inflation)
  state_totals = df.group_by("state_po", "year").agg(pl.col("totalvotes").sum())

  # CORRECT: deduplicate first, then sum
  state_totals = (
      df.unique(subset=["county_fips", "year"])
      .group_by("state_po", "year")
      .agg(pl.col("totalvotes").sum())
  )
  ```

### version
- **Type:** Int64
- **Description:** Date when dataset was finalized, in YYYYMMDD format
- **Values:** {20260211} (single value across all rows)
- **Codebook:** "date when dataset was finalized"

### mode
- **Type:** String
- **Description:** Ballot counting mode or method of voting
- **Values:** 20 unique values (see coded-values.md for complete list)
- **Default:** "TOTAL" (76.38% of all rows)
- **Codebook:** "mode of ballots cast; default is TOTAL, with different modes specified for 2020"
- **Note:** Codebook says "modes specified for 2020" but 2024 also has mode breakdowns

## Composite Key Analysis

No single column serves as a unique row identifier. The closest composite key is
`(year, state_po, county_name, party, candidate, mode)` with 93,010 unique combinations
vs 94,151 rows. The 1,141 non-unique rows include 83 exact duplicates and cases where
null `county_fips` values create ambiguity.

## Derived Metrics

| Metric | Formula | Notes |
|--------|---------|-------|
| Vote share | `candidatevotes / totalvotes` | Filter `mode='TOTAL'` and `totalvotes > 0` first |
| Two-party share | `candidatevotes / (dem_votes + rep_votes)` | Requires pivot; common for swing analysis |
| Turnout proxy | `totalvotes` | Not true turnout (no denominator of eligible voters in this dataset) |

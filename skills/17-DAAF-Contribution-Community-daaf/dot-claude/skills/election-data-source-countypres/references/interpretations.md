# Preliminary Semantic Interpretations

> **WARNING:** All interpretations in this file are PRELIMINARY HYPOTHESES based on
> column names, value patterns, and domain conventions. They MUST be reviewed and
> confirmed by the user before being treated as authoritative.

## Interpretation Summary

| Column | Preliminary Interpretation | Confidence | Basis |
|--------|---------------------------|------------|-------|
| year | Presidential election year (4-year cycle) | HIGH | Value pattern: {2000,2004,...,2024}, confirmed by codebook |
| state | Full U.S. state name, uppercase | HIGH | 51 unique, all valid state names, confirmed by codebook |
| state_po | USPS 2-letter state abbreviation | HIGH | 51 unique, 2-char format, confirmed by codebook |
| county_name | County/borough name, uppercase | HIGH | 1,921 unique, valid county names, confirmed by codebook |
| county_fips | Standard FIPS county code (SSCCC integer) | HIGH | Range 1001-56045 (standard), confirmed by codebook |
| office | Constant "US PRESIDENT" identifying contest | HIGH | Single value, confirmed by codebook |
| candidate | Candidate full name (uppercase), plus aggregates | MEDIUM | 14 named candidates + 5 meta-entries; codebook says "name of the candidate" but meta-entries contradict |
| party | Political party in uppercase | HIGH | 5 named values align with codebook; empty string is additional |
| candidatevotes | Raw vote count for candidate-county-year-mode | HIGH | Integer values, non-negative, confirmed by codebook |
| totalvotes | Total votes in county-year-mode | HIGH | Integer values, serves as denominator, confirmed with caveat on mode |
| version | Dataset version date in YYYYMMDD integer format | HIGH | Single value 20260211, confirmed by codebook ("date when dataset was finalized") |
| mode | Ballot counting method or aggregate | HIGH | "TOTAL" is default, breakdowns in 2020/2024, confirmed by codebook |

## Detailed Interpretations

### county_fips as Join Key

[PRELIMINARY] `county_fips` is the PRIMARY JOIN KEY for linking this dataset to census,
education, and other geographic datasets. The standard FIPS format (SSCCC where SS is
2-digit state code and CCC is 3-digit county code) is used by Census Bureau, SAIPE, CCD,
and ACS datasets.

**Basis:** Column name pattern ("_fips"), integer format matching standard FIPS range,
confirmed 1:1 state_po mapping via `county_fips // 1000`.

**Caveats for joins:**
- 52 null values (CT, ME, RI) will not join
- Alaska 2004 uses non-standard district codes (2001-2099)
- Kansas City, MO uses non-standard code (2938000)
- Zero-padded string FIPS in other datasets need `int()` conversion

### mode Column Behavior Change

[PRELIMINARY] The `mode` column represents a structural change in how election data was
reported starting in 2020. States that report by voting method provide both the breakdown
rows AND a TOTAL row, meaning naive row-level analysis would double-count votes.

**Basis:** 2000-2016 have only "TOTAL"; 2020 has 16 modes across 11 states plus TOTAL
for all states; 2024 continues the pattern with different states and modes.

### Non-Candidate Entries

[PRELIMINARY] The entries TOTAL VOTES CAST, UNDERVOTES, OVERVOTES, and SPOILED in the
`candidate` column represent ballot-level accounting categories, not actual candidates.
They LIKELY appear because the source data includes these as line items in official
election returns. The `party` column for these entries is empty string.

**Basis:** These values are semantically distinct from candidate names; they appear
consistently alongside empty `party` values; their `candidatevotes` represent ballot
counts rather than votes for a person.

### Party Coverage Pattern

[PRELIMINARY] The "three parties" statement in the codebook LIKELY describes a practice
that was formalized around 2020, when LIBERTARIAN and GREEN first appear as named
parties. For 2000-2016, third-party candidates appear to be grouped under OTHER
(with the exception of GREEN/Nader in 2000).

**Basis:** LIBERTARIAN absent 2000-2016; GREEN present only 2000, 2020; codebook
statement about "three parties" may describe current practice rather than historical.

### Vote Share Computation

[PRELIMINARY] The standard derived metric is `vote_share = candidatevotes / totalvotes`.
For TOTAL mode rows, this gives the county-level vote share per candidate. For two-party
analysis, researchers typically compute `dem_share = dem_votes / (dem_votes + rep_votes)`.

**Basis:** Standard political science methodology; confirmed vote shares range 0-100%
with no values exceeding 100% in TOTAL mode.

## Items Requiring User Confirmation

1. Are the non-candidate entries (UNDERVOTES, OVERVOTES, etc.) expected behavior or data issues?
2. Is the LIBERTARIAN/GREEN coverage pattern across years intentional?
3. What do the 501 empty-string `party` values in 2024 represent?
4. What do the 2,795 empty-string `mode` values in 2024 represent?
5. Is the Alaska 2004 data usable for any analysis, or should it always be excluded?
6. Is the Kansas City, MO FIPS 2938000 an intentional special case?

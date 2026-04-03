---
name: election-data-source-countypres
description: >-
  County Presidential Returns 2000-2024 (MIT MEDSL). Vote shares, party trends, turnout by county_fips (joins census/education data). Requires HARVARD_DATAVERSE_API_KEY. Critical: mode='TOTAL' drops ~1K counties post-2020 — use 3-pattern reconstruction
metadata:
  audience: any-agent
  domain: data-source
  skill-authored: "2026-02-23"
  skill-last-updated: "2026-02-24"
---

# County Presidential Data Source Reference

County Presidential Election Returns 2000-2024 from MIT Election Data and Science Lab (MEDSL). Use when analyzing county-level presidential vote shares, party trends, turnout, or geographic voting patterns. Key join column county_fips enables linking to census, education (CCD/SAIPE), and demographic datasets. Requires Harvard Dataverse API key (HARVARD_DATAVERSE_API_KEY env var). Categorical variables use uppercase strings, not Portal integer codes. Critical caveat: naive mode='TOTAL' filtering silently drops ~1,000 counties in 2020+ data — use 3-pattern reconstruction.

The authoritative source for county-level U.S. presidential election returns spanning 2000-2024. Provides candidate-level vote counts across all 50 states and DC, enabling vote share analysis, partisan trend mapping, and cross-domain geographic research via FIPS code joins.

> **CRITICAL: Value Encoding**
>
> This dataset uses **uppercase string codes** for categorical variables (party, mode,
> candidate, state) rather than integer codes. Empty strings (`""`) appear as
> undocumented values in `party` (501 rows, 2024) and `mode` (2,795 rows, 2024).
>
> | Context | party | mode | candidate |
> |---------|-------|------|-----------|
> | **Standard values** | `DEMOCRAT`, `REPUBLICAN` | `TOTAL` | `BARACK OBAMA` |
> | **Aggregate/meta values** | `OTHER`, `""` | `""`, `ELECTION DAY` | `OTHER`, `UNDERVOTES` |
>
> See `./references/variable-definitions.md` for complete encoding tables.

## Prerequisites

> **API Key Required:** This data source requires a **Harvard Dataverse API key** to fetch data.
> Unlike education data sources (which use the Urban Institute's free, unauthenticated API),
> election data is hosted on Harvard Dataverse and requires authentication.
>
> **Setup instructions:**
> 1. Create a free Harvard Dataverse account at https://dataverse.harvard.edu/
> 2. Log in, navigate to your account name (top-right) → API Token
> 3. Click "Create Token" and copy it
> 4. Set the environment variable **before launching Claude Code**:
>    ```bash
>    export HARVARD_DATAVERSE_API_KEY="your_token_here"
>    ```
>    For Docker users: run this inside the container after `docker compose exec daaf-docker bash`
>    but before `claude`. To make it persistent across sessions, add it to `~/.bashrc`.
>
> **If the key is missing**, any fetch script will fail with a `KeyError: 'HARVARD_DATAVERSE_API_KEY'`.
> The orchestrator should check for this variable's existence before dispatching Stage 5 fetch tasks
> that use this data source.

## What is the MEDSL County Presidential Returns Dataset?

- **Producer:** MIT Election Data and Science Lab (MEDSL)
- **Coverage:** County-level presidential election returns, 50 states + DC
- **Frequency:** Every 4 years (presidential election cycle)
- **Available years:** 2000, 2004, 2008, 2012, 2016, 2020, 2024
- **Primary identifier:** `county_fips` (5-digit FIPS code, stored as integer)
- **Record unit:** One row per county-year-candidate-party-mode combination
- **Total records:** 94,151 rows x 12 columns (~8.4 MB). Note: rows per year vary dramatically — 2020/2024 have ~2x rows due to mode breakdowns (~22K vs ~9.5K for earlier years)
- **Source:** Harvard Dataverse (DOI: 10.7910/DVN/VOQCHQ)

## Reference File Structure

| File | Purpose | When to Read |
|------|---------|--------------|
| `variable-definitions.md` | Complete column specs, party/mode/candidate value tables | Interpreting specific columns or coded values |
| `coded-values.md` | All categorical value mappings with frequencies | Filtering or recoding party, mode, candidate |
| `columns.md` | Detailed per-column profiling (types, nulls, ranges) | Understanding column characteristics |
| `quality-notes.md` | Known issues, anomalies, duplicates, null patterns | Assessing data reliability |
| `mode-reconstruction.md` | 3-pattern TOTAL mode reconstruction for 2020+ data | Cleaning any 2020+ analysis (CRITICAL) |
| `interpretations.md` | Preliminary semantic interpretations (flagged for review) | Understanding column meanings |

## Decision Trees

### What analysis do I need?

```
Analyzing presidential election data?
├─ County-level vote shares → Use 3-pattern mode reconstruction (./references/mode-reconstruction.md)
│   └─ Longitudinal (cross-year) → MUST reconstruct TOTAL for 2020+ (naive filter drops ~1,000 counties)
│   └─ Single year (pre-2020) → Safe to filter mode='TOTAL'
│   └─ Single year (2020/2024) → Reconstruct unless analyzing a known TOTAL-only state
├─ Party trends → Group by year + party, use party column (not candidate name)
│   └─ Third parties → See ./references/coded-values.md (GREEN/LIBERTARIAN vary by year)
├─ Turnout analysis → Use totalvotes column (dedup per county-year before summing!)
├─ Joining with other data → Use county_fips as join key (zero-pad to 5 chars first!)
│   └─ Census/ACS data → Join on county_fips (standard 5-digit string)
│   └─ Education data (CCD/SAIPE) → Join on county_fips
│   └─ Null FIPS? → See ./references/quality-notes.md (CT, ME, RI)
└─ Voting method analysis → 2020 and 2024 only, see mode breakdown
```

### Is this a data quality issue?

```
Unexpected values?
├─ county_fips is null → CT/ME/RI in pre-2020 years (52 rows)
├─ county_fips > 72999 → Kansas City MO (FIPS 2938000, non-standard)
├─ county_fips join failures → Zero-pad to 5 chars! (AR codes = 4 digits as int)
├─ AR FIPS 5135 has two counties → Source data error: St. Francis under Sharp County
│   └─ See ./references/quality-notes.md #arkansas-fips-contamination (BLOCKER)
├─ CT counties missing from shapefile → 2022+ TIGER uses planning regions, not counties
│   └─ See ./references/quality-notes.md #connecticut-fips-geography-mismatch
├─ ~1,000 counties missing after mode filter → Use 3-pattern reconstruction, not naive filter
│   └─ See ./references/mode-reconstruction.md
├─ candidate is not a person → UNDERVOTES/OVERVOTES/SPOILED/TOTAL VOTES CAST
│   └─ Filter these OUT for candidate-level analysis
├─ party is empty string → 501 rows in 2024, undocumented
├─ mode is empty string → 2,795 rows in 2024 (may be totals OR breakdowns per state)
├─ candidatevotes is null → 37 rows (NM 2024, mode breakdown)
├─ sum(candidatevotes) > totalvotes → 49 county-years (minor rounding)
├─ Duplicate rows → 83 exact duplicates exist
└─ Alaska 2004 → District-level data, not county; FIPS = 2001-2099
    └─ See ./references/quality-notes.md #alaska-2004
```

## Quick Reference: Election Variables

### Party Values by Year

| Year | DEMOCRAT | REPUBLICAN | LIBERTARIAN | GREEN | OTHER | `""` |
|------|----------|------------|-------------|-------|-------|------|
| 2000 | Y | Y | - | Y | Y | - |
| 2004-2016 | Y | Y | - | - | Y | - |
| 2020 | Y | Y | Y | Y | Y | - |
| 2024 | Y | Y | Y | - | Y | Y |

### Mode Values by Year

| Year | Modes Available |
|------|----------------|
| 2000-2016 | `TOTAL` only |
| 2020 | `TOTAL` + 15 breakdown modes (11 states) |
| 2024 | `TOTAL` + 9 breakdown modes + `""` (varies by state) |

For complete mode values see `./references/coded-values.md`.

### Key Identifiers

| ID | Format | Level | Example | Notes |
|----|--------|-------|---------|-------|
| `county_fips` | Int64 (5-digit) | County | `6037` (LA County, CA) | 52 nulls (CT/ME/RI); join key for census/education data |
| `state_po` | String (2-char) | State | `CA` | USPS abbreviation; 1:1 with `state` |
| `state` | String | State | `CALIFORNIA` | Full uppercase name |

> **WARNING: FIPS Zero-Padding Required for Joins**
>
> `county_fips` is stored as Int64. When converting to string for joins with Census,
> SAIPE, CCD, or other datasets, **zero-pad to 5 characters** or Arkansas and other
> small-FIPS states will produce 4-digit codes that fail to match.
> ```python
> df = df.with_columns(pl.col("county_fips").cast(pl.Utf8).str.zfill(5).alias("county_fips_str"))
> ```

### Missing Data Codes

| Code | Column(s) | Meaning | Frequency |
|------|-----------|---------|-----------|
| `null` | `county_fips` | FIPS not assigned | 52 rows (CT, ME, RI pre-2020) |
| `null` | `candidatevotes` | Vote count unavailable | 37 rows (NM 2024 mode breakdowns) |
| `0` | `totalvotes` | No votes recorded | 50 rows |
| `0` | `candidatevotes` | Zero votes for candidate | 3,908 rows (4.15%) |
| `""` | `party` | Party not specified | 501 rows (2024 only) |
| `""` | `mode` | Mode not specified | 2,795 rows (2024 only) |

### Non-Candidate Entries in candidate Column

| Value | Rows | Meaning |
|-------|------|---------|
| `OTHER` | 27,548 | Aggregate of minor candidates |
| `TOTAL VOTES CAST` | 427 | County total (redundant with totalvotes) |
| `UNDERVOTES` | 402 | Ballots with no presidential selection |
| `OVERVOTES` | 380 | Ballots with multiple presidential selections |
| `SPOILED` | 14 | Invalidated ballots |

**Filter these out** for candidate-level vote share analysis.

> **Best Practice: Party-Based Identification**
>
> Always use `party` column for identifying party affiliation, never `candidate` name.
> Candidate names are inconsistent across years (e.g., "DONALD TRUMP" in 2016 vs
> "DONALD J TRUMP" in 2020/2024). The `party` column (`DEMOCRAT`, `REPUBLICAN`) is
> stable across all years.
> ```python
> # CORRECT — stable across years
> dem = df.filter(pl.col("party") == "DEMOCRAT")
>
> # WRONG — misses 2016 or 2020/2024 depending on which name you use
> trump = df.filter(pl.col("candidate") == "DONALD TRUMP")
> ```

## Data Access

### Dataset Paths

| Topic | Type | Path |
|-------|------|------|
| County presidential returns | Single file | Harvard Dataverse DOI: `10.7910/DVN/VOQCHQ` |
| Codebook | Single file | Bundled: `County Presidential Returns 2000-2024.md` |
| Sources per state | Single file | Bundled: `sources-president.tab` |

### Codebooks

| Dataset | Codebook Path |
|---------|---------------|
| County presidential returns 2000-2024 | `County Presidential Returns 2000-2024.md` (bundled in Dataverse) |

> Codebook is a Markdown file bundled in the Harvard Dataverse deposit. For human
> reference. The QA methodology paper is at:
> https://www.nature.com/articles/s41597-022-01745-0

> **Truth Hierarchy:** When interpreting variable values, apply this priority:
> 1. **Actual data file** (what you observe in the TSV) -- this IS the truth
> 2. **Live codebook** (Markdown file in Dataverse) -- authoritative documentation, may lag
> 3. **This skill documentation** -- convenient summary, may drift from codebook
>
> If this documentation contradicts the codebook, trust the codebook.
> If the codebook contradicts observed data, trust the data and investigate.

### Example Fetch

```python
# Fetch from Harvard Dataverse API
import os, requests, polars as pl, io

api_key = os.environ["HARVARD_DATAVERSE_API_KEY"]
# Get file ID from dataset metadata first, then download
# File: countypres_2000-2024.tab (TSV format)
file_url = "https://dataverse.harvard.edu/api/access/datafile/{file_id}"
r = requests.get(file_url, params={"key": api_key, "format": "original"})
df = pl.read_csv(io.BytesIO(r.content), separator='\t')

# Filter to California, 2020, TOTAL mode only
ca_2020 = df.filter(
    (pl.col("state_po") == "CA") &
    (pl.col("year") == 2020) &
    (pl.col("mode") == "TOTAL")
)
```

### Filtering

```python
# Common filter patterns for county presidential data

# 1. Cross-year analysis: WARNING — naive filter drops ~1,000 counties in 2020+!
#    Use 3-pattern mode reconstruction instead. See ./references/mode-reconstruction.md
#    The single-line filter below is ONLY safe for single-year analysis on a state
#    known to have TOTAL rows (e.g., 2000-2016 data, or a confirmed TOTAL-only state).
longitudinal = df.filter(pl.col("mode") == "TOTAL")  # UNSAFE for 2020+ multi-state!

# 2. Remove non-candidate rows (UNDERVOTES, OVERVOTES, etc.)
candidates_only = df.filter(
    ~pl.col("candidate").is_in(["TOTAL VOTES CAST", "UNDERVOTES", "OVERVOTES", "SPOILED"])
)

# 3. Major party analysis — RECOMMENDED: use party column, not candidate name
#    Candidate names change across years (e.g., "DONALD TRUMP" vs "DONALD J TRUMP")
two_party = df.filter(pl.col("party").is_in(["DEMOCRAT", "REPUBLICAN"]))

# 4. Exclude Alaska 2004 anomaly
clean = df.filter(~((pl.col("state_po") == "AK") & (pl.col("year") == 2004)))

# 5. Exclude rows with null county_fips (for join operations)
joinable = df.filter(pl.col("county_fips").is_not_null())
```

## Common Pitfalls

| Pitfall | Issue | Solution |
|---------|-------|----------|
| Cross-year mode mismatch | 2000-2016 has only `TOTAL`; 2020/2024 have breakdowns. Mixing modes inflates counts | Always filter `mode == 'TOTAL'` for longitudinal analysis |
| Non-candidate rows | `UNDERVOTES`, `OVERVOTES`, `SPOILED`, `TOTAL VOTES CAST` appear as "candidates" | Filter out before computing candidate vote shares |
| Alaska 2004 | District-level data with non-standard FIPS codes (2001-2099); vote counts overstated | Exclude AK 2004 or handle separately; do not join on county_fips |
| Null FIPS for joins | CT, ME, RI have null `county_fips` in some years; breaks joins | Use `state_po` + `county_name` as fallback join key |
| Kansas City MO FIPS | Uses non-standard FIPS 2938000 (not a real county FIPS) | Handle as special case in joins; Kansas City is an independent city |
| Empty string party/mode | 2024 has `""` in party (501 rows) and mode (2,795 rows) | Treat as missing/undocumented; filter or investigate by state |
| Vote share > 100% | 49 county-years where sum(candidatevotes) > totalvotes | Minor rounding; use caution with strict validation |
| Duplicate rows | 83 exact duplicate rows exist in dataset | Deduplicate before analysis |
| FIPS zero-padding | Int64 → string without padding gives 4-digit codes for AR and other small-FIPS states | `pl.col("county_fips").cast(pl.Utf8).str.zfill(5)` before joins |
| Name-based party ID | Candidate names change across years ("DONALD TRUMP" vs "DONALD J TRUMP") | Always use `party` column, never `candidate` name |
| CT FIPS mismatch | 2022+ Census TIGER uses CT planning regions, not legacy counties | Use 2020-vintage TIGER shapefiles for CT county joins |
| totalvotes duplication | `totalvotes` is repeated per candidate row; summing without dedup inflates by ~3-4x | Deduplicate to one row per (county_fips, year) before aggregating |

## Critical: Mode Column Behavior Change

> **WARNING: Naive `mode == "TOTAL"` filtering drops ~1,000 counties in 2020+ data.**
> Multiple states report ONLY mode breakdowns (no TOTAL rows). A simple filter silently
> removes all their counties. Use 3-pattern mode reconstruction instead.
> See `./references/mode-reconstruction.md` for the full code pattern and validation.

The `mode` column behavior changed significantly starting in 2020:

- **2000-2016:** All rows have `mode = 'TOTAL'` (aggregate county totals only)
- **2020:** 11 states report by voting method alongside TOTAL; **10 states have ONLY breakdowns** (AR, AZ, GA, IA, KY, MD, NC, OK, SC, VA)
- **2024:** Additional breakdown states; some have empty string `mode` (which may represent totals OR breakdowns depending on the state)

**For any cross-year or multi-county analysis, use 3-pattern mode reconstruction:**
1. **Pattern 1:** TOTAL present → keep TOTAL, drop breakdowns
2. **Pattern 2:** Only breakdowns, no TOTAL → sum `candidatevotes` across modes
3. **Pattern 3:** Empty-string mode = totals → reclassify after per-state verification

**Empty-string detection must be per-state** — NC 2024 empty-string rows are breakdowns
(multiple per county-candidate), while other states' empty-string rows are totals (one per
county-candidate). See `./references/mode-reconstruction.md` for detection logic and code.

## Related Data Sources

| Source | Relationship | When to Use |
|--------|--------------|-------------|
| Census/ACS | Join via `county_fips` | County demographics, population, income |
| SAIPE (`education-data-source-saipe`) | Join via `county_fips` | County poverty estimates (cross-domain) |
| CCD (`education-data-source-ccd`) | Join via `county_fips` | School district data (cross-domain) |
| MEDSL Precinct Returns | Finer geographic resolution | When county-level is insufficient |
| MEDSL Senate/House Returns | Same producer, different office | When analyzing down-ballot races |

**Note:** This is the first election domain dataset in DAAF. Cross-domain joins with education data are possible via `county_fips`. No election-specific explorer or query skills exist yet.

## Topic Index

| Topic | Reference File |
|-------|---------------|
| Column specifications | `./references/columns.md` |
| Column types and ranges | `./references/columns.md` |
| Party values and year coverage | `./references/coded-values.md` |
| Mode values and year behavior | `./references/coded-values.md` |
| Candidate name mapping | `./references/coded-values.md` |
| Non-candidate entries | `./references/coded-values.md` |
| Complete encoding tables | `./references/variable-definitions.md` |
| Null county_fips patterns | `./references/quality-notes.md` |
| Alaska 2004 anomaly | `./references/quality-notes.md` |
| Kansas City MO FIPS | `./references/quality-notes.md` |
| Duplicate rows | `./references/quality-notes.md` |
| Null candidatevotes | `./references/quality-notes.md` |
| Per-state data sources | `./references/quality-notes.md` |
| Missing votes flags | `./references/quality-notes.md` |
| Mode reconstruction (3-pattern) | `./references/mode-reconstruction.md` |
| States without TOTAL rows | `./references/mode-reconstruction.md` |
| Empty-string mode detection | `./references/mode-reconstruction.md` |
| Row count estimation by year | `./references/mode-reconstruction.md` |
| FIPS zero-padding for joins | `./references/columns.md` |
| AR FIPS contamination (Sharp/St. Francis) | `./references/quality-notes.md` |
| CT geography mismatch (2022+) | `./references/quality-notes.md` |
| Party-based identification (best practice) | `./references/coded-values.md` |
| totalvotes deduplication | `./references/variable-definitions.md` |
| Preliminary interpretations | `./references/interpretations.md` |
| Data profiling scripts | `./scripts/` |

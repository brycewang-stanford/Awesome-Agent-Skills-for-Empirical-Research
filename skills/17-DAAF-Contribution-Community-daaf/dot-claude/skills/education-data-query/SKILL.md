---
name: education-data-query
description: >-
  Downloads education datasets from configured mirror sources (parquet/CSV) with local Polars filtering. Use when writing fetch scripts or retrieving CCD, IPEDS, CRDC, SAIPE data. Load after education-data-explorer — retrieval here, not discovery.
metadata:
  audience: research-coders
  domain: data-access
---

# Education Data Query

Downloads education datasets from configured mirror sources (parquet or CSV) using priority-ordered fallback, with local Polars filtering. Use when writing Stage 5 fetch scripts, downloading a specific CCD, IPEDS, CRDC, SAIPE, or other education dataset by path, discovering which files are available on a mirror, or retrieving codebook metadata. Load after using education-data-explorer to identify endpoints — this skill handles actual data retrieval, not endpoint discovery.

Download datasets from the Education Data Portal via configured mirror sources (defined in mirrors.yaml). Mirrors are tried in priority order. All filtering is done locally with Polars. The mirror data originates from the Urban Institute Education Data Portal (EDP), which is a curation and standardization layer over original federal data sources — data has been restructured with lowercase variable names, integer-encoded categoricals, and standardized missing value codes (`-1`, `-2`, `-3`).

## What This Skill Does

- Download education datasets from configured mirrors
- Handle multiple file formats (parquet, CSV) based on mirror read_strategy
- Apply year, state, and demographic filters locally with Polars
- Discover available files via each mirror's discovery endpoint

> **Skill Provenance Note:** Each `*-data-source-*` skill includes
> `provenance.skill_last_updated` in its frontmatter. Before fetching data,
> check this date — if it is more than a few months old, the source skill's
> documentation about column definitions, coded values, and quality patterns
> may have drifted from the current data. Consider re-running data-ingest to
> re-verify before relying on stale skill guidance for query construction.

## Reference File Structure

| File | Purpose | When to Read |
|------|---------|--------------|
| `mirrors.yaml` | Mirror URLs, priority, format, timeouts, metadata config | Understanding mirror configuration |
| `fetch-patterns.md` | Code patterns for mirror-based fetching | Writing Stage 5 fetch scripts |
| `datasets-reference.md` | Known dataset file paths by source | Finding the right file path for a dataset |
| `filters-reference.md` | Complete filter variables | Filtering downloaded data locally |
| `query-patterns.md` | Endpoint path structure reference | Understanding URL/path naming conventions |

## Mirror System Overview

Data is fetched by downloading files from mirrors:

```
Fetch Request (dataset, years, filters)
    → Try each mirror in priority order (per mirrors.yaml)
        → Build URL from mirror's url_template + dataset paths
        → Read using mirror's read_strategy (eager_parquet, lazy_csv, etc.)
    → If all mirrors fail: STOP and escalate
    → Save to data/raw/*.parquet
    → CP1 validation (source-agnostic)
```

### Mirror Configuration

Mirrors are defined in `./references/mirrors.yaml` with priority ordering. Each mirror specifies:
- `url_template` — how to build download URLs
- `read_strategy` — how Polars reads the format (eager_parquet, lazy_csv)
- `discovery` — how to check what files are available

See `./references/mirrors.yaml` for the full configuration and instructions on adding new mirrors.

### Mirror File Discovery

Before fetching, you can check what files are available using each mirror's discovery endpoint (defined in mirrors.yaml):

```python
# Generic discovery — works with any mirror that supports it
# See fetch-patterns.md for the full discover_mirror_files() function
from fetch_patterns import discover_mirror_files

# Check primary mirror
files = discover_mirror_files(MIRRORS[0])
if files is not None:
    print(f"Available files: {len(files)}")
```

This eliminates guessing — if the file exists in a mirror, use it; if not, fall through to the next.

## Decision Trees

### "How should I get this data?"

```
What dataset do you need?
├─ Know the exact file path?
│   └─ Use fetch_from_mirrors() with that path → ./references/fetch-patterns.md
├─ Know the source but not the exact filename?
│   └─ Check ./references/datasets-reference.md for known paths
├─ Not sure what's available?
│   └─ Query mirror discovery endpoint to list all files → ./references/fetch-patterns.md
├─ Need a codebook or metadata file?
│   └─ Check codebook column in ./references/datasets-reference.md → get_codebook_url() in ./references/fetch-patterns.md
└─ Dataset not in any mirror?
    └─ STOP and escalate — dataset may need to be added to mirror
```

### "Is my dataset a single file or yearly files?"

```
Check datasets-reference.md:
├─ Type = "Single" → One file with all years
│   └─ Use fetch_from_mirrors() → filter years locally
└─ Type = "Yearly" → One file per year
    └─ Use fetch_yearly_from_mirrors() → concatenate results
```

### "How do I filter results?"

All filtering is done locally with Polars after download:

```python
# By state
df = df.filter(pl.col("fips") == 6)  # California

# By year
df = df.filter(pl.col("year").is_in([2020, 2021, 2022]))

# By school type
df = df.filter(pl.col("charter") == 1)

# Multiple filters
df = df.filter(
    (pl.col("fips") == 6) &
    (pl.col("charter") == 1) &
    (pl.col("school_level") == 3)
)
```

## Dataset Path Structure

All mirrors use the same canonical path. Each mirror appends its own format extension (`.parquet`, `.csv`) via its `url_template` in mirrors.yaml:

```
{source}/{filename}
```

| Component | Description | Examples |
|-----------|-------------|----------|
| `source` | Data source | `ccd`, `ipeds`, `crdc`, `saipe`, `edfacts` |
| `filename` | Dataset file | `schools_ccd_directory`, `districts_saipe` |

Example paths:
- `saipe/districts_saipe` (SAIPE district poverty)
- `ccd/schools_ccd_directory` (CCD school directory)
- `ccd/schools_ccd_enrollment_2022` (CCD enrollment, yearly)

See `./references/datasets-reference.md` for the complete file path listing.

## Format Handling

Format-specific read behavior is driven by each mirror's `read_strategy` field (see `mirrors.yaml`):

### `eager_parquet`
```python
df = pl.read_parquet(url)  # Polars reads HTTP URLs natively
```

### `lazy_csv`
```python
# Always use lazy loading for large files
df = (
    pl.scan_csv(url, infer_schema_length=10000)
    .filter(pl.col("year").is_in(YEARS))
    .filter(pl.col("fips") == STATE_FIPS)
    .collect()
)
```

See `./references/fetch-patterns.md` for complete code patterns.

## Portal Integer Encoding

**CRITICAL:** The Portal uses integer codes, not string labels. This affects filtering and interpretation.

### Demographic Variable Encodings

| Variable | Integer Values | NOT These Strings |
|----------|----------------|-------------------|
| Race | 1-7, 99 (total) | WH, BL, HI, AS, etc. |
| Sex | 1 (Male), 2 (Female), 3 (Another gender, IPEDS 2022+), 4 (Unknown gender, IPEDS 2022+), 9 (Unknown), 99 (Total) | M, F |
| Grade | -1 to 13, 99 (total) | PK, KG, 01, etc. |

### Grade Encoding (SEMANTIC TRAP!)

| Value | Meaning | URL Path Equivalent |
|-------|---------|---------------------|
| -1 | Pre-K (**NOT missing!**) | `grade-pk` |
| 0 | Kindergarten | `grade-k` |
| 1-12 | Grades 1-12 | `grade-1` to `grade-12` |
| 99 | Total | `grade-99` |

```python
# WRONG - filters out Pre-K students!
df = df.filter(pl.col("grade") >= 0)

# RIGHT - Pre-K students have grade = -1
pre_k = df.filter(pl.col("grade") == -1)
total = df.filter(pl.col("grade") == 99)
```

### Variable Names Are Lowercase

Portal variable names are lowercase:
- `enrollment` not `MEMBER`
- `grade` not `GRADE`
- `fips` not `FIPS`

See `./references/filters-reference.md` for complete encoding tables.

## Common FIPS Codes

| Code | State | Code | State | Code | State |
|------|-------|------|-------|------|-------|
| 1 | Alabama | 17 | Illinois | 36 | New York |
| 2 | Alaska | 18 | Indiana | 37 | North Carolina |
| 4 | Arizona | 19 | Iowa | 39 | Ohio |
| 5 | Arkansas | 20 | Kansas | 40 | Oklahoma |
| 6 | California | 21 | Kentucky | 41 | Oregon |
| 8 | Colorado | 22 | Louisiana | 42 | Pennsylvania |
| 9 | Connecticut | 24 | Maryland | 44 | Rhode Island |
| 10 | Delaware | 25 | Massachusetts | 45 | South Carolina |
| 11 | DC | 26 | Michigan | 47 | Tennessee |
| 12 | Florida | 27 | Minnesota | 48 | Texas |
| 13 | Georgia | 29 | Missouri | 49 | Utah |
| 15 | Hawaii | 32 | Nevada | 51 | Virginia |
| 16 | Idaho | 34 | New Jersey | 53 | Washington |

See `./references/filters-reference.md` for complete list.

## Cross-References

- **Discover endpoints:** Load `education-data-explorer` skill to browse available endpoints and variables
- **Interpret data:** Load `education-data-context` skill after fetching for variable meanings and caveats
- **Deep source understanding:** Load `education-data-source-*` skills for comprehensive methodology

### Data Source Skills Quick Reference

| Source | Skill | Key Fetch Considerations |
|--------|-------|--------------------------|
| CCD | `education-data-source-ccd` | Use grade-99 for totals; FRPL affected by CEP |
| CRDC | `education-data-source-crdc` | Biennial only; 2015+ for complete coverage; CSV requires `schema_overrides` for ID cols (see CRDC skill) |
| EDFacts | `education-data-source-edfacts` | Use `_midpt` vars; states not comparable |
| IPEDS | `education-data-source-ipeds` | GRS limited to first-time full-time |
| Scorecard | `education-data-source-scorecard` | High suppression; Title IV recipients only |
| SAIPE | `education-data-source-saipe` | Model estimates; population not enrollment |
| FSA | `education-data-source-fsa` | Federal aid only; 1-3 year lag |
| MEPS | `education-data-source-meps` | Better than FRPL for cross-state |
| PSEO | `education-data-source-pseo` | Experimental; check state coverage |

## Topic Index

| Topic | Location |
|-------|----------|
| Mirror configuration | `./references/mirrors.yaml` |
| Fetch code patterns | `./references/fetch-patterns.md` |
| Dataset file paths | `./references/datasets-reference.md` |
| URL/path naming conventions | `./references/query-patterns.md` |
| Filter variables | `./references/filters-reference.md` |
| Codebook/metadata URLs | `./references/datasets-reference.md` (codebook column), `./references/fetch-patterns.md` (get_codebook_url) |
| FIPS codes | This file, `./references/filters-reference.md` |
| CCD source details | `education-data-source-ccd` skill |
| CRDC source details | `education-data-source-crdc` skill |
| EDFacts source details | `education-data-source-edfacts` skill |
| IPEDS source details | `education-data-source-ipeds` skill |
| Scorecard source details | `education-data-source-scorecard` skill |
| SAIPE source details | `education-data-source-saipe` skill |
| FSA source details | `education-data-source-fsa` skill |
| MEPS source details | `education-data-source-meps` skill |
| NHGIS source details | `education-data-source-nhgis` skill |

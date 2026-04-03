---
name: education-data-source-eada
description: >-
  EADA — college athletics gender equity (~2,000+ institutions, 2002-2021). Participation, coaching, salaries, expenses, revenues, athletic aid by gender. Not Title IX compliance data. No sector column; join IPEDS on unitid for institution type.
metadata:
  audience: any-agent
  domain: data-source
  skill-authored: "2026-02-09"
  skill-last-updated: "2026-02-09"
---

# EADA Data Source Reference

Equity in Athletics Disclosure Act (EADA) data for college athletics gender equity analysis covering ~2,000+ institutions (2002-2021). Use when analyzing athletic participation, coaching staff, salaries, expenses, revenues, or athletic aid by gender at colleges/universities, or understanding Title IX context in athletics. EADA is NOT Title IX compliance data. Note: no sector column; join to IPEDS on unitid to filter by institution type.

The EADA provides the only standardized, publicly available dataset on college athletics participation, coaching, finances, and athletic aid by gender across ~2,000+ postsecondary institutions, enabling gender equity analysis in intercollegiate athletics.

> **CRITICAL: Value Encoding**
>
> EADA data from the Education Data Portal uses **integer codes** for categorical
> variables. Original EADA web tools use string labels; the Portal converts these
> to integers. Always verify codes against the codebook (see Truth Hierarchy below).
>
> | Context | `ath_classification_code` | Missing values |
> |---------|--------------------------|----------------|
> | **Portal (integers)** | `1` = NCAA DI FBS | `-1`, `-2`, `-3` |
> | Original EADA | String labels | Blank / N/A |
>
> **Note:** There is no `sector` column in EADA Portal data. To filter by sector,
> join with IPEDS directory data on `unitid`.
>
> See `./references/variable-definitions.md` for complete encoding tables.

## What is EADA?

- **Collector**: U.S. Department of Education (Office of Postsecondary Education)
- **Coverage**: ~2,000+ coeducational postsecondary institutions with intercollegiate athletics
- **Mandate**: Institutions participating in Title IV aid with athletic programs must report
- **Frequency**: Annual (data publicly available by October 15 each year)
- **Available years**: 2002–2021 (Portal mirror)
- **Primary identifier**: `unitid` (6-digit IPEDS institution ID)
- **Content**: Athletic participation, coaching staff, salaries, expenses, revenues, and athletic aid — all reported by gender
- **Available through**: Education Data Portal mirrors

## Reference File Structure

| File | Purpose | When to Read |
|------|---------|--------------|
| `title-ix-context.md` | Legal framework, gender equity requirements | Understanding policy context |
| `data-elements.md` | Participation, coaches, salaries, expenses, revenues | Identifying available variables |
| `sport-level-data.md` | Data available by individual sport | Sport-specific analysis |
| `variable-definitions.md` | Key variables, codes, special values | Interpreting specific data elements |
| `limitations.md` | Data quality issues, comparability, self-reporting caveats | Assessing data reliability |
| `fetch-patterns.md` | Mirror URLs and fetch code patterns | Fetching data |

## Decision Trees

### What analysis am I conducting?

```
Research question?
├─ Gender equity overview → Start with participation + aid ratios
│   └─ See ./references/data-elements.md
├─ Coaching disparities → Coach counts + salaries by gender
│   └─ See ./references/data-elements.md (Coaching section)
├─ Financial investment → Expenses + revenues by team gender
│   └─ See ./references/data-elements.md (Financial section)
├─ Sport-specific analysis → Individual sport data
│   └─ See ./references/sport-level-data.md
├─ Title IX compliance assessment → CAUTION: EADA ≠ compliance data
│   └─ See ./references/limitations.md (Critical)
└─ Trend analysis → Year-over-year comparisons
    └─ See ./references/fetch-patterns.md
```

### What variables do I need?

```
Variable categories?
├─ Participation counts
│   ├─ Unduplicated by gender → `undup_athpartic_men`, `undup_athpartic_women`
│   ├─ Duplicated (sport-level sum) → `athpartic_men`, `athpartic_women`
│   ├─ Coed teams → `athpartic_coed_men`, `athpartic_coed_women`
│   └─ By sport → See ./references/sport-level-data.md
├─ Coaching
│   ├─ Head coaches → `men_fthdcoach_*`, `women_fthdcoach_*` variables
│   ├─ Assistant coaches → `men_ftascoach_*`, `women_ftascoach_*` variables
│   └─ Salaries → `hdcoach_salary_*`, `ascoach_salary_*` variables
├─ Financial
│   ├─ Expenses → `ath_exp_*` variables
│   ├─ Revenues → `ath_rev_*` variables
│   └─ Athletic aid → `ath_stuaid_*` variables
└─ Detailed definitions → See ./references/variable-definitions.md
```

### How do I interpret the data?

```
Interpretation question?
├─ What counts as "participation"?
│   └─ See ./references/variable-definitions.md
├─ Why don't participation ratios match enrollment?
│   └─ See ./references/limitations.md
├─ Is this institution Title IX compliant?
│   └─ CANNOT determine from EADA data alone
│       └─ See ./references/limitations.md (Critical)
├─ Why are some values missing or zero?
│   └─ See ./references/limitations.md
└─ How do I compare across institutions?
    └─ See ./references/limitations.md (Comparability section)
```

## Quick Reference: Key Metrics

### Participation Equity Indicators

| Metric | Calculation | Interpretation |
|--------|-------------|----------------|
| Female participation ratio | `undup_athpartic_women / (undup_athpartic_men + undup_athpartic_women)` | Compare to female enrollment ratio |
| Participation gap | Female enrollment % - Female participation % | Positive = underrepresentation |
| Opportunities per student | `undup_athpartic_total / enrollment_total` | Athletic opportunity rate |

### Financial Equity Indicators

| Metric | Calculation | Notes |
|--------|-------------|-------|
| Aid ratio | `ath_stuaid_women / (ath_stuaid_men + ath_stuaid_women)` | Should approximate participation ratio |
| Per-participant expense | `ath_opexp_perpart_men`, `ath_opexp_perpart_women` | Pre-calculated per-participant operating expense |
| Recruiting investment | `recruitexp_men`, `recruitexp_women` | Indicator of program investment |

### Coaching Equity Indicators

| Metric | Focus | Variables |
|--------|-------|-----------|
| Female coaches of women's teams | % female | `women_fthdcoach_fem`, `women_pthdcoach_fem` |
| Salary equity | Avg salary comparison | `hdcoach_salary_men`, `hdcoach_salary_women` |

### Key Identifiers

| ID | Format | Level | Example | Notes |
|----|--------|-------|---------|-------|
| `unitid` | 6-digit integer | Institution | `110635` | Same as IPEDS; primary join key |
| `opeid` | String | Institution | `"00123400"` | OPE ID (may be null for early years) |
| `year` | 4-digit integer | Reporting year | `2021` | Fiscal year ending |
| `fips` | Integer | State | `6` (California) | Federal FIPS code |
| `inst_name` | String | Institution | `"University of..."` | Institution name |

### Common Filters

| Filter | Variable | Example Values |
|--------|----------|----------------|
| Institution | `unitid` | 6-digit IPEDS ID |
| Year | `year` | 2002–2021 |
| State | `fips` | Integer FIPS code (e.g., `6` = California) |
| Athletic Division | `ath_classification_code` | Integer codes 1–20 (see below) |

> **Note:** There is no `sector` column in the EADA Portal data. To filter by institutional sector, join with IPEDS directory data on `unitid`.

### Athletic Classification Codes

| Code | Division | Code | Division |
|------|----------|------|----------|
| 1 | NCAA Division I FBS | 12 | NJCAA Division I |
| 2 | NCAA Division I FCS | 13 | NJCAA Division II |
| 3 | NCAA Division I (no football) | 14 | NJCAA Division III |
| 4 | NCAA Division II (with football) | 15 | NCCAA Division I |
| 5 | NCAA Division II (no football) | 16 | NCCAA Division II |
| 6 | NCAA Division III (with football) | 17 | CCCAA |
| 7 | NCAA Division III (no football) | 18 | Independent |
| 8 | Other (check `ath_classification_other`) | 19 | NWAC |
| 9 | NAIA Division I | 20 | USCAA |
| 10 | NAIA Division II | | |
| 11 | NAIA Division III | | |

> **Note:** Code 1 was historically labeled "NCAA Division I-A" and code 2 "NCAA Division I-AA" in earlier years. The `ath_classification_name` string column reflects the label used at the time of reporting.

### Missing Data Codes

| Code | Meaning | When Used |
|------|---------|-----------|
| `-1` | Missing/not reported | Data not submitted by institution |
| `-2` | Not applicable | Item doesn't apply (e.g., no men's team) |
| `-3` | Suppressed | Data suppressed for privacy |

### Data Availability

| Topic | Years Available | Update Frequency |
|-------|-----------------|------------------|
| Institution-level | 2002–2021 | Annual |
| Sport-level | 2002–2021 | Annual |
| Coaching details | 2002–2021 | Annual |
| Financial data | 2002–2021 | Annual |

> **Note:** Some columns (e.g., `num_sports`, aggregated totals with `_all` suffix) are null for earlier years (2002) and were added in later reporting cycles. The `opeid` column is null for 2002.

### Example Research Questions

| Question | Key Variables | Reference |
|----------|---------------|-----------|
| Are women underrepresented in athletics? | `undup_athpartic_*`, `enrollment_*` | `data-elements.md` |
| How much do institutions invest in women's sports? | `ath_exp_*`, `ath_rev_*` | `data-elements.md` |
| Are coaches of women's teams paid fairly? | `hdcoach_salary_*` | `variable-definitions.md` |
| Which sports have most female participants? | Sport-level data | `sport-level-data.md` |
| Has participation equity improved over time? | Multi-year trend | `fetch-patterns.md` |

## Data Access

Datasets for EADA are available via the Education Data Portal mirror system. All data fetching uses `fetch_from_mirrors()` from `fetch-patterns.md`, with mirrors defined in `mirrors.yaml` and canonical paths in `datasets-reference.md`.

**Key datasets:**

| Dataset | Path | Type | Codebook |
|---------|------|------|----------|
| Institutional Characteristics | `eada/colleges_eada_inst_characteristics` | Single | `eada/codebook_colleges_eada_inst-characteristics` |

> **EADA naming note:** The data path uses `inst_characteristics` (underscores) while the codebook path uses `inst-characteristics` (hyphens). Always use the exact paths from `datasets-reference.md`.

### Truth Hierarchy

When interpreting EADA variable definitions and coded values, apply this priority:

| Priority | Source | Rationale |
|----------|--------|-----------|
| 1 (highest) | **Actual data file** (parquet) | What you observe IS the truth |
| 2 | **Live codebook** (.xls via `get_codebook_url()`) | Authoritative documentation; may lag |
| 3 (lowest) | **This skill's reference docs** | Summarized; convenient but may drift |

Use `get_codebook_url("eada/codebook_colleges_eada_inst-characteristics")` from `fetch-patterns.md` to construct the codebook download URL.

### Filtering

```python
import polars as pl

# Filter by athletic division (NCAA Division I FBS only)
df_d1_fbs = df.filter(pl.col("ath_classification_code") == 1)

# Exclude coded missing values before calculations
df_clean = df.filter(
    (pl.col("undup_athpartic_men") >= 0) &
    (pl.col("undup_athpartic_women") >= 0)
)

# Note: No `sector` column in EADA data. To filter by sector,
# join with IPEDS directory data on unitid first.
```

## Common Pitfalls

| Pitfall | Issue | Solution |
|---------|-------|----------|
| Including coded missing values | `-1`, `-2`, `-3` treated as real numbers skew totals and ratios | Filter `>= 0` on all numeric columns before aggregation |
| Assuming Title IX compliance | EADA data cannot determine Title IX compliance — it is a disclosure tool, not an enforcement mechanism | Read `./references/limitations.md`; use EADA for descriptive analysis only |
| Comparing across institutions naively | Different reporting practices, program sizes, and classification levels make raw comparisons misleading | Normalize by enrollment, filter to same classification, and note caveats |
| Using wrong variable names | Portal variable names differ from EADA source documentation (e.g., `undup_athpartic_men` not `partic_men`) | Always verify column names against actual data or codebook; see `./references/variable-definitions.md` |
| Self-reported data accuracy | Institutions self-report without independent verification; errors and inconsistencies exist | Cross-check outliers against institution websites or IPEDS data |
| Ignoring zero values | Zero may mean "no team" or "not reported" depending on context | Distinguish between true zeros and missing data using `-1`/`-2` codes |
| Assuming `sector` column exists | EADA data has no `sector` column | Join with IPEDS directory on `unitid` to get sector |

## EADA vs. Title IX Compliance

```
EADA Data                          Title IX Compliance
──────────────────────────────────────────────────────────
Self-reported                      OCR investigation
Snapshot (Oct 15)                  Continuous obligation
Participation counts only          Participation + interest + ability
No "laundry list" items           13+ treatment areas
Public disclosure                  Enforcement mechanism
```

**Always read**: `./references/limitations.md` before drawing compliance conclusions.

### Key Limitations Summary

- **Self-reported**: No independent verification
- **Counting methods**: Differ from Title IX counting
- **Not comprehensive**: Misses many equity factors
- **Comparability issues**: Different reporting practices across institutions

## Related Data Sources

| Source | Relationship | When to Use |
|--------|--------------|-------------|
| `education-data-source-ipeds` | Complementary institution data | Joining enrollment, demographics, finances via `unitid` |
| `education-data-explorer` | Parent discovery skill | Finding available endpoints across all sources |
| `education-data-query` | Data fetching | Downloading parquet/CSV files from mirrors |

## Topic Index

| Topic | Reference File |
|-------|---------------|
| Title IX law | `./references/title-ix-context.md` |
| Gender equity requirements | `./references/title-ix-context.md` |
| Three-prong test | `./references/title-ix-context.md` |
| Participation variables | `./references/data-elements.md` |
| Coaching variables | `./references/data-elements.md` |
| Salary variables | `./references/data-elements.md` |
| Expense variables | `./references/data-elements.md` |
| Revenue variables | `./references/data-elements.md` |
| Athletic aid | `./references/data-elements.md` |
| Sport-specific data | `./references/sport-level-data.md` |
| Variable definitions | `./references/variable-definitions.md` |
| Integer encoding tables | `./references/variable-definitions.md` |
| Data limitations | `./references/limitations.md` |
| Self-reporting issues | `./references/limitations.md` |
| EADA vs Title IX | `./references/limitations.md` |
| Fetch patterns | `./references/fetch-patterns.md` |
| Mirror URLs | `./references/fetch-patterns.md` |

---
name: education-data-source-nacubo
description: >-
  NACUBO endowment data (~650 institutions, 2012-2022). Portal: 7 columns only (total endowment, per-FTE, YoY change). Use for endowment size/trends. Full investment/spending needs direct NACUBO access. For all-institution coverage use IPEDS finance.
metadata:
  audience: any-agent
  domain: data-source
  skill-authored: "2026-02-09"
  skill-last-updated: "2026-02-09"
---

# NACUBO Data Source Reference

NACUBO endowment data for U.S. college and university endowments (~650 institutions). Portal mirror provides only 7 market-value columns (total endowment, per-FTE endowment, year-over-year change; 2012-2022). Use when analyzing institution-level endowment size or trends. Full investment returns, asset allocations, spending rates, and governance data require separate NACUBO study access. For comprehensive endowment coverage across all institutions, use IPEDS finance data.

The NACUBO-Commonfund Study of Endowments (NCSE) is the most comprehensive annual survey of U.S. college and university endowments, covering ~650 institutions representing over $870 billion in assets. The Education Data Portal mirrors a limited subset (7 market-value columns); full investment, allocation, spending, and governance data requires direct NACUBO access.

> **CRITICAL: Portal Mirror Scope**
>
> The Education Data Portal mirrors contain **only 7 columns** of endowment data,
> focused on market values. Full investment data (returns, asset allocations,
> spending rates, governance) requires access to the complete NACUBO study.
>
> **Portal columns:** `year`, `unitid`, `inst_name_nacubo`, `fips`, `endow_total`,
> `endow_per_fte`, `endow_chg_mktval`
>
> **Value Encoding:**
>
> | Variable | Portal Format | Notes |
> |----------|---------------|-------|
> | `fips` | Integer (`6` = California) | Not string abbreviations ("CA") |
> | `year` | Integer (`2022`) | Fiscal year ending year |
> | `endow_total` | Float64 (USD) | Full dollar amount, NOT thousands |
> | `endow_chg_mktval` | Float64 (decimal fraction) | `0.059` = 5.9% change, NOT `5.9` |
> | Missing data | `null` | NOT -1, -2, -3 |
>
> See `./references/variable-definitions.md` for complete encoding tables.

## What is NACUBO?

The National Association of College and University Business Officers (NACUBO) is a nonprofit professional organization representing chief administrative and financial officers at higher education institutions.

- **Collector**: NACUBO with Commonfund Institute (currently); TIAA partnership FY2018-2022
- **Coverage**: ~650 participating colleges, universities, and affiliated foundations (voluntary)
- **Scope**: Investment returns, asset allocations, spending rates, governance practices, market values
- **Frequency**: Annual survey (September-December collection, February publication)
- **Available years**: 1974-present (50+ years of study); Portal mirror covers 2012-2022 (11 years)
- **Primary identifier**: `unitid` (IPEDS 6-digit institution ID)
- **FY2024 total**: 658 participants representing $873.7 billion in assets

## Reference File Structure

| File | Purpose | When to Read |
|------|---------|--------------|
| `endowment-study.md` | NCSE methodology, participation, history | Understanding data source context |
| `endowment-metrics.md` | Market values, returns, spending rates | Interpreting performance data |
| `variable-definitions.md` | Key variables, size categories, institution types | Building queries, filtering data |
| `data-quality.md` | Coverage limitations, data caveats | Assessing data reliability |
| `asset-allocation.md` | Investment categories, alternative strategies | Analyzing portfolio composition |

## Decision Trees

### What endowment data do I need?

```
Endowment research topic?
├─ Market values / fund size
│   ├─ Individual institution values → NCSE public tables
│   ├─ Size distribution → ./references/variable-definitions.md
│   └─ Historical trends → ./references/endowment-metrics.md
├─ Investment returns
│   ├─ One-year returns → ./references/endowment-metrics.md
│   ├─ Multi-year returns (3/5/10/25-year) → ./references/endowment-metrics.md
│   └─ Returns by size/type → ./references/variable-definitions.md
├─ Asset allocation
│   ├─ Traditional vs alternative → ./references/asset-allocation.md
│   ├─ Private equity/VC allocation → ./references/asset-allocation.md
│   └─ ESG/responsible investing → ./references/asset-allocation.md
├─ Spending and distributions
│   ├─ Spending rates → ./references/endowment-metrics.md
│   ├─ Spending purposes (aid, faculty, etc.) → ./references/endowment-metrics.md
│   └─ Budget contribution → ./references/endowment-metrics.md
└─ Data quality concerns
    ├─ Coverage/participation → ./references/data-quality.md
    ├─ Self-reported data issues → ./references/data-quality.md
    └─ Comparability across years → ./references/data-quality.md
```

### Which data source should I use?

```
Comparing NACUBO vs IPEDS for endowment data?
├─ Need ALL institutions → Use IPEDS (mandatory reporting)
├─ Need investment returns → Use NACUBO (IPEDS doesn't have)
├─ Need asset allocations → Use NACUBO (IPEDS doesn't have)
├─ Need spending rates → Use NACUBO (IPEDS doesn't have)
├─ Need just market values → Either works
│   ├─ More institutions → IPEDS
│   └─ More detail → NACUBO
└─ Need governance/policies → Use NACUBO (IPEDS doesn't have)
```

### Understanding study name changes

```
Which study by year?
├─ FY2023-present → NACUBO-Commonfund Study of Endowments (NCSE)
├─ FY2018-FY2022 → NACUBO-TIAA Study of Endowments (NTSE)
├─ FY2009-FY2017 → NACUBO-Commonfund Study of Endowments (NCSE)
└─ Before FY2009 → NACUBO Endowment Study (NES)
```

## Quick Reference: NACUBO Data

> **Portal Coverage Note:** The Education Data Portal mirrors contain only **7 columns** focused on endowment market values. Full investment data (returns, asset allocations, spending rates, governance) requires access to the complete NACUBO study. See "Full Report Access" section below.

### Portal Mirror Columns (Verified)

These are the **only** columns available in the Portal mirror (`nacubo/colleges_nacubo_endow`):

| Column | Type | Description | Nulls |
|--------|------|-------------|-------|
| `year` | Int64 | Fiscal year ending year (2012-2022) | 0 |
| `unitid` | Int64 | IPEDS 6-digit institution ID | 0 |
| `inst_name_nacubo` | String | NACUBO institution name | 0 |
| `fips` | Int64 | State FIPS code (1-56, territories: 72, 78) | 1 |
| `endow_total` | Float64 | Total endowment market value in USD (full dollars, NOT thousands) | 0 |
| `endow_per_fte` | Float64 | Endowment per FTE student in USD | 1,260 (~15%) |
| `endow_chg_mktval` | Float64 | Year-over-year market value change as decimal fraction (0.059 = 5.9%) | 3,972 (~48%) |

**Important format notes:**
- `endow_total` is in **full USD** (e.g., `1.05e9` = $1.05 billion), not in thousands
- `endow_chg_mktval` is a **decimal fraction**, not a percentage (multiply by 100 for display)
- Missing data uses **null**, not coded values (-1/-2/-3)

```python
# Correct: convert decimal fraction to percentage for display
df = df.with_columns(
    (pl.col("endow_chg_mktval") * 100).alias("pct_change")
)

# Correct: endow_total is already in full USD
df.filter(pl.col("endow_total") > 1_000_000_000)  # Endowments over $1B
```

### Key Metrics Available

| Metric | Description | In Portal Mirror? | Granularity |
|--------|-------------|-------------------|-------------|
| Market Value | Total endowment assets (FMV) | **Yes** (`endow_total`) | Institution-level |
| Market Value Per FTE | Endowment per FTE student | **Yes** (`endow_per_fte`) | Institution-level |
| Market Value Change | Year-over-year change | **Yes** (`endow_chg_mktval`) | Institution-level |
| Investment Return | Time-weighted return, net of fees | No (full study only) | 1, 3, 5, 10, 25-year periods |
| Effective Spending Rate | Annual withdrawal as % of market value | No (full study only) | Institution type, size |
| Asset Allocation | Portfolio composition by asset class | No (full study only) | Size category, type |
| New Gifts | Donations added to endowment | No (full study only) | Aggregate by size/type |
| Budget Support | Endowment % of operating budget | No (full study only) | Size category, type |

### Key Identifiers

| ID | Format | Level | Example | Notes |
|----|--------|-------|---------|-------|
| `unitid` | Integer (6-digit) | Institution | `166027` | IPEDS institution ID; primary join key |
| `inst_name_nacubo` | String | Institution | `Harvard University` | NACUBO version of name |
| `fips` | Integer (1-56) | State | `25` (Massachusetts) | State FIPS code |

### Endowment Size Categories

| Category Code | Range | FY24 Count | % of Participants |
|---------------|-------|------------|-------------------|
| 1 | Over $5 Billion | ~25 | ~4% |
| 2 | $1 Billion to $5 Billion | ~107 | ~16% |
| 3 | $501 Million to $1 Billion | ~77 | ~12% |
| 4 | $251 Million to $500 Million | ~97 | ~15% |
| 5 | $101 Million to $250 Million | ~161 | ~24% |
| 6 | $51 Million to $100 Million | ~111 | ~17% |
| 7 | Under $50 Million | ~80 | ~12% |

### Institution Types

| Type Code | Type Name | Description |
|-----------|-----------|-------------|
| 1 | Private | Private colleges and universities |
| 2 | Public | Public colleges and universities |
| 3 | IRF | Institutionally Related Foundations |
| 4 | Combined | Combined endowment/foundation |

### Typical Return Ranges (Historical)

| Period | Average Range | Notes |
|--------|---------------|-------|
| 1-year | -8% to +31% | High volatility |
| 3-year | 3% to 15% | Less volatile |
| 5-year | 5% to 12% | More stable |
| 10-year | 6% to 9% | Most commonly cited |
| 25-year | 6% to 9% | Long-term benchmark |

### Missing Data Codes

| Code | Meaning | When Used |
|------|---------|-----------|
| `null` | Not reported / missing | Standard for all NACUBO variables |

> **Note:** Unlike other Education Data Portal sources (CCD, CRDC, etc.), NACUBO data uses **null values** for missing data rather than coded values like -1, -2, -3. NACUBO is a voluntary survey with simpler missing data patterns; the Portal preserves null rather than applying coded values.

```python
# Correct: Check for null
df.filter(pl.col("endow_per_fte").is_null())

# Incorrect: Checking for -1/-2/-3 (these don't exist in NACUBO)
# df.filter(pl.col("endow_per_fte") == -1)  # Won't find anything
```

## Data Access

Datasets for NACUBO are available via the mirror system. See `datasets-reference.md` for canonical paths, `mirrors.yaml` for mirror configuration, and `fetch-patterns.md` for fetch code patterns.

| Dataset | Type | Years | Path | Codebook |
|---------|------|-------|------|----------|
| Endowments | Single | 2012-2022 | `nacubo/colleges_nacubo_endow` | `nacubo/codebook_colleges_nacubo_endowments` |

Codebooks are `.xls` files co-located with data in all mirrors. Use `get_codebook_url()` from `fetch-patterns.md` to construct download URLs:

```python
url = get_codebook_url("nacubo/codebook_colleges_nacubo_endowments")
```

> **Truth Hierarchy:** When interpreting variable values, apply this priority:
> 1. **Actual data file** (what you observe in the parquet/CSV) -- this IS the truth
> 2. **Live codebook** (.xls in mirror) -- authoritative documentation, may lag
> 3. **This skill documentation** -- convenient summary, may drift from codebook
>
> If this documentation contradicts the codebook, trust the codebook. If the codebook contradicts observed data, trust the data and investigate.

### Public NACUBO Tables

Free tables available at: https://www.nacubo.org/Research/2024/Public-NCSE-Tables

Includes:
- Participating institutions by market value
- Average/median returns by size and type
- Asset allocation summaries
- Spending rate summaries

### Full Report Access

- **Participants**: Free access
- **NACUBO Members**: $250
- **Non-members**: $1,500
- **Academic researchers**: Contact Commonfund Institute

## Common Pitfalls

| Pitfall | Issue | Solution |
|---------|-------|----------|
| Using NCES-style codes | Portal uses integer FIPS, not string state abbreviations | Use integer fips codes (1-56) |
| Expecting coded missing values | NACUBO in Portal uses nulls, not -1/-2/-3 | Check for null, not negative codes |
| Treating `endow_chg_mktval` as percentage | Column is a decimal fraction (0.059), not a percentage (5.9) | Multiply by 100 for display: `pl.col("endow_chg_mktval") * 100` |
| Treating `endow_total` as thousands | Column is in full USD (1.05e9 = $1.05B) | No division needed; value is already in dollars |
| Comparing to IPEDS values | NACUBO is voluntary (~650-813), IPEDS is mandatory (~6,000+) | Note sample differences in analysis |
| Year interpretation | FY2024 = July 2023 - June 2024 | Align fiscal year definitions carefully |
| Assuming comprehensive coverage | Only ~650-813 of ~4,000+ institutions participate | Use IPEDS for population-level analysis |
| Ignoring partner changes | TIAA (2018-22) vs Commonfund (other years) may change methodology | Check methodology for specific years |
| Expecting investment returns in Portal | Portal only has market values, not returns/allocations/spending | Use full NCSE study for investment analysis |

## Key Caveats

| Issue | Impact | Mitigation |
|-------|--------|------------|
| **Portal subset** | Only 7 columns mirrored (market values only) | Full study required for returns, allocations, spending, governance |
| Voluntary participation | ~650-813 of ~4,000+ institutions per year | Use IPEDS for comprehensive coverage |
| Self-reported data | Unverified accuracy | Cross-reference with IPEDS where possible |
| Selection bias | Larger, well-resourced institutions overrepresented | Analyze by size category |
| Partner changes | TIAA (2018-22), Commonfund (other years) | Check methodology changes |
| Fiscal year timing | July 1 - June 30 | Match to other data sources carefully |
| Declining participation | 813 in 2012 to 652 in 2021 in Portal data | Account for sample size changes in trend analysis |

## Common Use Cases

| Research Question | Primary Variables | Reference File |
|-------------------|-------------------|----------------|
| How do endowment returns vary by size? | Return rates, size category | `endowment-metrics.md` |
| What drives endowment spending decisions? | Spending rate, spending policy | `endowment-metrics.md` |
| How are endowments invested? | Asset allocation percentages | `asset-allocation.md` |
| Which schools have the largest endowments? | Market value, institution name | Public tables |
| How has endowment performance changed? | Historical return series | `endowment-metrics.md` |
| What portion of budgets come from endowments? | Budget support percentage | `endowment-metrics.md` |

## Related Data Sources

| Source | Relationship | When to Use |
|--------|--------------|-------------|
| `education-data-source-ipeds` | Complementary; mandatory reporting covers all institutions | Need all institutions or just market values |
| `education-data-source-scorecard` | Complementary; student outcomes | Linking endowment size to student outcomes |
| `education-data-explorer` | Parent discovery skill | Finding available endpoints |
| `education-data-query` | Data fetching | Downloading parquet/CSV files |

## Topic Index

| Topic | Reference File |
|-------|---------------|
| Study methodology | `./references/endowment-study.md` |
| Partnership history | `./references/endowment-study.md` |
| Participation criteria | `./references/endowment-study.md` |
| Investment returns | `./references/endowment-metrics.md` |
| Spending rates | `./references/endowment-metrics.md` |
| Market values | `./references/endowment-metrics.md` |
| Size categories | `./references/variable-definitions.md` |
| Institution types | `./references/variable-definitions.md` |
| Variable list | `./references/variable-definitions.md` |
| Asset classes | `./references/asset-allocation.md` |
| Alternative investments | `./references/asset-allocation.md` |
| ESG investing | `./references/asset-allocation.md` |
| Selection bias | `./references/data-quality.md` |
| Coverage gaps | `./references/data-quality.md` |
| Comparability issues | `./references/data-quality.md` |

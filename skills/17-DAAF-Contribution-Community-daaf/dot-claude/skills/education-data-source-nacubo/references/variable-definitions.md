# Variable Definitions

Reference for NACUBO endowment study variables, size categories, institution types, and data classifications.

> **Truth Hierarchy:** When interpreting variable values, apply this priority:
> 1. **Actual data file** (what you observe in the parquet/CSV) -- this IS the truth
> 2. **Live codebook** (.xls in mirror) -- authoritative documentation, may lag
> 3. **This document** -- convenient summary, may drift from codebook
>
> If this document contradicts the codebook, trust the codebook. If the codebook contradicts observed data, trust the data and investigate. Codebook URL: use `get_codebook_url("nacubo/codebook_colleges_nacubo_endowments")` from `fetch-patterns.md`.

> **CRITICAL: Portal Encoding**
>
> This document covers both **Portal mirror columns** (7 columns available via the mirror system) and **full NCSE study variables** (available only through the complete NACUBO study). Sections are clearly labeled.
>
> The Portal uses:
> - **Integer FIPS codes** (1-56) for states, not string abbreviations
> - **Null values** for missing data (NOT coded -1/-2/-3 like other sources)
>
> | Variable | Format | Example Values |
> |----------|--------|----------------|
> | `fips` | Integer | `1` (Alabama), `6` (California), `36` (New York) |
> | `year` | Integer | `2012`, `2022` |
> | `endow_total` | Float64 (USD) | `1054900000.0` (full dollars, NOT thousands) |
> | `endow_chg_mktval` | Float64 (decimal) | `0.059` = 5.9% change (NOT `5.9`) |
> | Missing data | Null | `null` (not -1, -2, -3) |

## Primary Identifiers

### Institution Identifier

| Variable | Format | Description |
|----------|--------|-------------|
| `unitid` | Integer | IPEDS institution identifier (6 digits) |
| `inst_name_nacubo` | String | Institution name (NACUBO version) |
| `fips` | Integer | State FIPS code (1-56, see below) |

**Joining with Other Data**: Use `unitid` to link NACUBO data with IPEDS, College Scorecard, and other Education Data Portal sources.

### State FIPS Codes

The `fips` column uses integer FIPS codes, NOT string state abbreviations:

| FIPS | State | FIPS | State | FIPS | State |
|------|-------|------|-------|------|-------|
| 1 | Alabama | 19 | Iowa | 37 | North Carolina |
| 2 | Alaska | 20 | Kansas | 38 | North Dakota |
| 4 | Arizona | 21 | Kentucky | 39 | Ohio |
| 5 | Arkansas | 22 | Louisiana | 40 | Oklahoma |
| 6 | California | 23 | Maine | 41 | Oregon |
| 8 | Colorado | 24 | Maryland | 42 | Pennsylvania |
| 9 | Connecticut | 25 | Massachusetts | 44 | Rhode Island |
| 10 | Delaware | 26 | Michigan | 45 | South Carolina |
| 11 | DC | 27 | Minnesota | 46 | South Dakota |
| 12 | Florida | 28 | Mississippi | 47 | Tennessee |
| 13 | Georgia | 29 | Missouri | 48 | Texas |
| 15 | Hawaii | 30 | Montana | 49 | Utah |
| 16 | Idaho | 31 | Nebraska | 50 | Vermont |
| 17 | Illinois | 32 | Nevada | 51 | Virginia |
| 18 | Indiana | 33 | New Hampshire | 53 | Washington |
| | | 34 | New Jersey | 54 | West Virginia |
| | | 35 | New Mexico | 55 | Wisconsin |
| | | 36 | New York | 56 | Wyoming |

**Territories**: 72 (Puerto Rico), 78 (Virgin Islands)

## Endowment Size Categories

### Standard Size Cohorts

NACUBO segments institutions into seven size categories based on fiscal year-end market value:

| Category Code | Size Range | Description |
|---------------|------------|-------------|
| 1 | Over $5 Billion | Mega-endowments |
| 2 | $1 Billion to $5 Billion | Large endowments |
| 3 | $501 Million to $1 Billion | Upper-mid endowments |
| 4 | $251 Million to $500 Million | Mid-size endowments |
| 5 | $101 Million to $250 Million | Lower-mid endowments |
| 6 | $51 Million to $100 Million | Small endowments |
| 7 | Under $50 Million | Very small endowments |

**Note**: Some historical data uses slightly different breakpoints. Always verify category definitions for specific study years.

### Alternative Size Groupings

Simplified three-category grouping sometimes used:

| Group | Size Range | Typical Count |
|-------|------------|---------------|
| Large | Over $1 Billion | ~130-140 |
| Medium | $101 Million to $1 Billion | ~350 |
| Small | Under $100 Million | ~180-200 |

### Distribution by Size (FY24)

| Size Category | Count | % of Participants | % of Total Assets |
|---------------|-------|-------------------|-------------------|
| Over $5B | ~25 | ~4% | ~35% |
| $1B to $5B | ~107 | ~16% | ~49% |
| $501M to $1B | ~77 | ~12% | ~7% |
| $251M to $500M | ~97 | ~15% | ~4% |
| $101M to $250M | ~161 | ~24% | ~3% |
| $51M to $100M | ~111 | ~17% | ~1% |
| Under $50M | ~80 | ~12% | <1% |

**Key Insight**: ~20% of participants (>$1B) control ~84% of total endowment assets.

## Institution Types

### Primary Type Classification

| Type Code | Type Name | Description |
|-----------|-----------|-------------|
| 1 | Private | Private colleges and universities |
| 2 | Public | Public colleges and universities |
| 3 | IRF | Institutionally Related Foundations |
| 4 | Combined | Combined endowment/foundation |

### Type Definitions

**Private**: Independent colleges and universities with institutional endowment funds.

**Public**: State colleges and universities with institutional endowment funds directly managed by the institution.

**Institutionally Related Foundation (IRF)**: Separate 501(c)(3) organization that holds and manages endowment assets on behalf of a (typically public) institution. Common structure for public universities.

**Combined**: Institutions reporting combined endowment and foundation data together (may include both institutional funds and IRF).

### Type Distribution (FY24)

| Type | Count | % of Participants |
|------|-------|-------------------|
| Private | ~400 | ~60% |
| Public | ~100 | ~15% |
| IRF | ~130 | ~20% |
| Combined | ~30 | ~5% |

## Portal Mirror Variables (7 Columns)

These are the **only** variables available in the Portal mirror dataset (`nacubo/colleges_nacubo_endow`). All other variable sections below describe the full NCSE study and are NOT available in the Portal mirror.

| Variable | Type | Description | Unit | Nulls |
|----------|------|-------------|------|-------|
| `year` | Int64 | Fiscal year ending year | YYYY | 0 |
| `unitid` | Int64 | IPEDS institution identifier (6 digits) | — | 0 |
| `inst_name_nacubo` | String | Institution name (NACUBO version) | — | 0 |
| `fips` | Int64 | State FIPS code (1-56, territories: 72, 78) | — | 1 |
| `endow_total` | Float64 | Total endowment market value at fiscal year end | **Full USD** (NOT thousands) | 0 |
| `endow_per_fte` | Float64 | Endowment per FTE student | USD | ~15% null |
| `endow_chg_mktval` | Float64 | Year-over-year market value change | **Decimal fraction** (0.059 = 5.9%) | ~48% null |

**Format warnings:**
- `endow_total` is in **full USD** (e.g., `1054900000.0` = ~$1.05 billion). Do NOT divide by 1000.
- `endow_chg_mktval` is a **decimal fraction**, not a percentage. Multiply by 100 for display: `pl.col("endow_chg_mktval") * 100`.
- `endow_per_fte` is in **full USD** (e.g., `48784.99` = ~$48,785 per FTE student).

**Note**: `year` in the Portal corresponds to the fiscal year ending year. FY2022 = July 1, 2021 - June 30, 2022.

---

## Full NCSE Study Variables (NOT in Portal Mirror)

> **The following variable sections describe the complete NACUBO study data, which is NOT available through the Education Data Portal mirrors.** These variables require purchasing or requesting the full NCSE dataset from NACUBO. They are documented here to provide context for understanding the broader study and to support research that may combine Portal data with full NCSE data.

### Investment Return Variables (Full Study Only)

| Variable | Description | Unit |
|----------|-------------|------|
| `return_1yr` | One-year investment return (net of fees) | % |
| `return_3yr` | Three-year annualized return | % |
| `return_5yr` | Five-year annualized return | % |
| `return_10yr` | Ten-year annualized return | % |
| `return_25yr` | Twenty-five-year annualized return | % |

### Spending Variables (Full Study Only)

| Variable | Description | Unit |
|----------|-------------|------|
| `effective_spending_rate` | Actual spending as % of market value | % |
| `target_spending_rate` | Policy target spending rate | % |
| `total_spending` | Total endowment distributions | USD |
| `spending_financial_aid` | Spending on student financial aid | USD or % |
| `spending_academic` | Spending on academic programs | USD or % |
| `spending_faculty` | Spending on endowed positions | USD or % |
| `spending_operations` | Spending on operations/maintenance | USD or % |
| `spending_other` | Other spending | USD or % |

### Budget Variables (Full Study Only)

| Variable | Description | Unit |
|----------|-------------|------|
| `budget_support_pct` | Endowment as % of operating budget | % |
| `operating_budget` | Total institutional operating budget | USD |

### Gift Variables (Full Study Only)

| Variable | Description | Unit |
|----------|-------------|------|
| `new_gifts` | New contributions to endowment | USD |
| `gifts_restricted` | Donor-restricted new gifts | USD |
| `gifts_unrestricted` | Unrestricted new gifts | USD |

### Asset Allocation Variables (Full Study Only)

#### Major Asset Classes

| Variable | Description | Typical Range |
|----------|-------------|---------------|
| `alloc_us_equity` | U.S. public equities | 10-25% |
| `alloc_non_us_equity` | Non-U.S. developed market equities | 5-15% |
| `alloc_emerging_equity` | Emerging market equities | 3-10% |
| `alloc_global_equity` | Global equity strategies | 0-10% |
| `alloc_fixed_income` | Bonds and fixed income | 8-15% |

#### Alternative Investment Classes

| Variable | Description | Typical Range |
|----------|-------------|---------------|
| `alloc_private_equity` | Private equity (buyout, growth) | 10-25% |
| `alloc_venture_capital` | Venture capital | 5-15% |
| `alloc_marketable_alts` | Hedge funds, liquid alternatives | 10-20% |
| `alloc_real_assets` | Real estate, natural resources | 8-15% |
| `alloc_private_credit` | Private debt strategies | 0-5% |

#### Aggregated Categories

| Variable | Components | Typical Range |
|----------|------------|---------------|
| `alloc_public_equity` | US + Non-US + EM + Global | 25-45% |
| `alloc_alternatives` | PE + VC + Alts + Real + Credit | 40-60% |
| `alloc_traditional` | Public equity + Fixed income | 35-55% |

### Governance Variables (Full Study Only)

#### Investment Committee

| Variable | Description |
|----------|-------------|
| `committee_size` | Number of investment committee members |
| `committee_meetings` | Annual meeting frequency |
| `has_student_managed` | Whether students manage portion of endowment |
| `student_managed_value` | Market value of student-managed funds |

#### Management Structure

| Variable | Description |
|----------|-------------|
| `num_external_managers` | Number of external investment managers |
| `has_ocio` | Uses outsourced CIO |
| `internal_management_pct` | Percentage managed internally |

#### Policy Variables

| Variable | Description |
|----------|-------------|
| `spending_policy_type` | Type of spending policy (moving avg, etc.) |
| `smoothing_period` | Years/quarters in smoothing formula |
| `rebalancing_frequency` | How often portfolio rebalanced |

### ESG/Responsible Investing Variables (Full Study Only)

| Variable | Description |
|----------|-------------|
| `has_esg_policy` | Implements ESG considerations |
| `has_negative_screening` | Uses negative/exclusionary screening |
| `has_impact_investing` | Allocates to impact investments |
| `esg_policy_type` | Type of ESG integration |

## Missing Data Handling

> **Note:** Unlike other Education Data Portal sources (CCD, CRDC, etc.), NACUBO data uses **null values** for missing data rather than coded values like -1, -2, -3.

| Value | Meaning | Handling |
|-------|---------|----------|
| `null` | Not reported / missing | Standard null handling in Polars |
| Valid number | Reported value | Use directly |

**Why different?** NACUBO is a voluntary survey with simpler missing data patterns. The Portal preserves null rather than applying coded values.

**Null prevalence in Portal mirror:**
- `endow_per_fte`: ~15% null (1,260 of 8,197 rows) -- FTE data not always available
- `endow_chg_mktval`: ~48% null (3,972 of 8,197 rows) -- requires consecutive years of participation
- `fips`: 1 null row in entire dataset

```python
# Correct: Check for null
df.filter(pl.col("endow_per_fte").is_null())

# Incorrect: Checking for -1/-2/-3 (these don't exist in NACUBO)
# df.filter(pl.col("endow_per_fte") == -1)  # Won't find anything
```

## Data Types

### Portal Mirror Column Types

| Column | Polars Type | Format Notes |
|--------|-------------|--------------|
| `year` | Int64 | Fiscal year ending year (2012-2022) |
| `unitid` | Int64 | 6-digit IPEDS institution ID |
| `inst_name_nacubo` | String | Institution name |
| `fips` | Int64 | State FIPS code |
| `endow_total` | Float64 | Full USD (NOT thousands) |
| `endow_per_fte` | Float64 | Full USD per FTE student |
| `endow_chg_mktval` | Float64 | Decimal fraction (NOT percentage) |

### Full NCSE Study Variable Types (NOT in Portal)

| Variable Type | Examples | Notes |
|---------------|----------|-------|
| Currency | Spending, gifts, operating budget | Reported in USD |
| Percentage | Returns, allocations, spending rates | 0-100 scale |
| Count | Committee size, managers | Integer |
| Category | Size category, institution type | Integer coded values |
| Boolean | Has OCIO, Has ESG policy | Yes/No or 1/0 |

## Derived Variables

Common calculations:

```
market_value_change_pct = (market_value - market_value_prior) / market_value_prior * 100

effective_spending_rate = total_spending / market_value_prior * 100

budget_support_pct = total_spending / operating_budget * 100

market_value_per_fte = market_value / fte_enrollment
```

## Historical Variable Changes

Some variables have changed over study history:

| Period | Change |
|--------|--------|
| Pre-2018 | Fewer alternative investment categories |
| 2018-2022 | TIAA added governance questions |
| 2023+ | Commonfund expanded ESG questions |

Always check documentation for specific years when analyzing historical trends.

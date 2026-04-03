---
name: education-data-source-nccs
description: >-
  NCCS — Form 990 data for private nonprofit colleges (Portal: IPEDS-matched, 1993-2016). Revenue, expenses, assets, endowment, governance beyond IPEDS. Use when IRS financial depth needed. Portal ends 2016; public institutions excluded (no Form 990).
metadata:
  audience: any-agent
  domain: data-source
  skill-authored: "2026-02-09"
  skill-last-updated: "2026-02-09"
---

# NCCS Data Source Reference

National Center for Charitable Statistics (NCCS) Form 990 data for private nonprofit colleges and universities (Portal mirror: IPEDS-matched institutions, 1993-2016). Use when IRS-based financial data — revenue, expenses, assets, endowment details — or governance information (board composition, executive compensation) is needed beyond what IPEDS provides. Portal data ends at 2016; for current filings use full NCCS directly. Public institutions do not file Form 990 and are excluded.

The NCCS (National Center for Charitable Statistics) is the principal U.S. repository for empirical data on the nonprofit sector, derived from IRS Form 990 filings. It provides financial depth, governance detail, and historical coverage for private nonprofit colleges and universities that goes well beyond what IPEDS collects.

> **CRITICAL: Value Encoding**
>
> The Education Data Portal encodes ALL categorical variables as **integers**, not strings.
> Variable names are **lowercase** in Portal data. Always verify codes against codebooks.
>
> | Context | `fips` | `mult_ein_flag` |
> |---------|--------|-----------------|
> | **Portal integer** | `6` (California) | `1` (Yes) |
> | Original NCCS | `"06"` or string | N/A |
>
> See `./references/variable-definitions.md` for complete encoding tables.

## What is NCCS?

- **Operator**: Urban Institute, Center on Nonprofits and Philanthropy
- **Coverage**: All U.S. tax-exempt nonprofit organizations (~3.8M in BMF)
- **Primary data source**: IRS Form 990 tax filings
- **Frequency**: Annual (with filing lag)
- **Available years**: 1989-present (Core Series); 2012-present (Efile); 1993-2016 (Portal)
- **Primary identifier**: EIN (Employer Identification Number, 9-digit)
- **Education relevance**: Private nonprofit colleges/universities are 501(c)(3) orgs filing Form 990; NTEE codes B40-B50 cover higher education

## Reference File Structure

| File | Purpose | When to Read |
|------|---------|--------------|
| `nonprofit-data.md` | NCCS datasets and what they contain | Understanding available data sources |
| `form-990.md` | IRS Form 990 structure and data elements | Understanding what information is collected |
| `education-relevance.md` | How NCCS relates to higher education | Connecting nonprofit data to education research |
| `ntee-codes.md` | Nonprofit classification system | Finding and filtering educational institutions |
| `variable-definitions.md` | Key financial and organizational variables, codes, special values | Interpreting specific data elements or building queries |

## Decision Trees

### What data am I looking for?

```
Research need?
├─ Financial data for private colleges → ./references/form-990.md
│   ├─ Revenue breakdown → Part VIII (Statement of Revenue)
│   ├─ Expenses by function → Part IX (Statement of Functional Expenses)
│   ├─ Assets and liabilities → Part X (Balance Sheet)
│   └─ Endowment details → Schedule D
├─ Governance/leadership → ./references/form-990.md
│   ├─ Board members → Part VII (Compensation)
│   ├─ Executive compensation → Part VII, Schedule J
│   └─ Policies and procedures → Part VI (Governance)
├─ Organizational characteristics → ./references/nonprofit-data.md
│   ├─ Basic info (name, address, EIN) → BMF
│   ├─ Tax-exempt type → BMF (SUBSECCD)
│   └─ NTEE classification → BMF (NTEECC)
└─ Identify institutions → ./references/ntee-codes.md
    ├─ All higher education → NTEE B40-B50
    ├─ Universities → B40, B41, B42, B43
    └─ Community colleges → B44
```

### Which NCCS dataset should I use?

```
Dataset selection?
├─ Need universe of all nonprofits?
│   └─ Business Master File (BMF) → ./references/nonprofit-data.md
├─ Need detailed financial variables?
│   ├─ Large organizations (full 990 filers) → Core PC files
│   ├─ All organizations (990 + 990EZ) → Core PZ files
│   └─ Maximum detail (2000+ fields) → Efile database
├─ Need private foundations?
│   └─ Core PF or 990-PF Efile data
└─ Need small grassroots orgs?
    └─ 990-N ePostcard database
```

### How do I connect NCCS to other education data?

```
Linking NCCS to education data?
├─ Need to match to IPEDS?
│   └─ See ./references/education-relevance.md (EIN-UNITID crosswalk)
├─ Need geographic analysis?
│   └─ Use BMF geocoded addresses + Census crosswalks
├─ Want institutional comparisons?
│   └─ Filter by NTEE codes B40-B50 for higher ed
└─ Analyzing trends over time?
    └─ Use Core data panel (1989-present)
```

## Quick Reference: NCCS Datasets and Variables

### Available Datasets

**Portal mirror** (via `fetch_from_mirrors()`):

| Dataset | Description | Coverage | Rows |
|---------|-------------|----------|------|
| 990 Forms (`nccs/colleges_nccs_all`) | Form 990 data for higher ed institutions matched to IPEDS | 1993-2016, ~2,600 institutions | ~30K |

**Full NCCS** (direct download, outside Portal):

| Dataset | Description | Coverage | Key Use |
|---------|-------------|----------|---------|
| Business Master File (BMF) | All active tax-exempt organizations | ~3.8M orgs | Sampling frame, basic info |
| NCCS Core Series | 990/990EZ filer financials | 1989-2022 | Historical financial analysis |
| IRS 990 Efile | Full electronic filings (2000+ fields) | 2012-present | Detailed governance, programs |
| Form 990-N ePostcard | Small nonprofits (<$50K revenue) | 2007-present | Grassroots organizations |
| Pub78 | Organizations eligible for tax-deductible donations | Current | Verify charitable status |

> **Scope note:** The Portal mirror dataset contains NCCS Form 990 data matched to IPEDS institutions only (~2,600 institutions). It does NOT include the full NCCS universe of ~3.8M nonprofits. For non-education nonprofits, NTEE-based filtering, or BMF/Core/Efile data, download directly from NCCS.

### Key Identifiers

**Portal dataset:**

| ID | Format | Level | Example | Notes |
|----|--------|-------|---------|-------|
| `unitid` | Integer | Institution | `110635` | IPEDS institution ID (Portal addition) |
| `ein` | Integer | Organization | `10211484` | Employer Identification Number |
| `fips` | Integer | State | `6` (California) | State FIPS code |

**Full NCCS** (direct download, outside Portal):

| ID | Format | Level | Example | Notes |
|----|--------|-------|---------|-------|
| `EIN` | 9-digit number | Organization | `123456789` | Unique to each nonprofit |
| `NTEECC` | Letter + 2 digits | Classification | `B42` (4-year college) | May be imprecise (~25%); NOT in Portal data |
| `SUBSECCD` | 2-digit code | Tax subsection | `03` (501(c)(3) charity) | NOT in Portal data |
| `FIPS` | 5-digit code | Geography | `06037` (LA County) | State + county; Portal uses state-level integer |

### Education NTEE Codes

| Code | Description |
|------|-------------|
| B20-B29 | Elementary & Secondary Schools |
| B40 | Higher Education Institutions (General) |
| B41 | Two-Year Colleges |
| B42 | Undergraduate Colleges (4-year) |
| B43 | Universities |
| B50 | Graduate/Professional Schools |
| B60 | Adult/Continuing Education |
| B70 | Libraries |
| B80 | Student Services/Organizations |
| B90 | Educational Services/Schools N.E.C. |

### Portal Variable Name Mapping (Selected)

The Portal dataset has 161 columns. Key mappings from original NCCS/990 names to Portal lowercase names:

| Portal Name | Original NCCS/990 | Description |
|-------------|-------------------|-------------|
| `year` | `FISYR` | Academic year (fall semester) — Portal-aligned year (1993-2016) |
| `fiscal_year` | — | IRS fiscal year ending year from 990 filing (1994-2017); typically `year` + 1 |
| `unitid` | — | IPEDS institution ID (Portal addition) |
| `ein` | `EIN` | Employer Identification Number |
| `fips` | `FIPS` | State FIPS code (integer) |
| `inst_name_nccs` | `NAME` | Organization name from 990 filing |
| `mult_ein_flag` | — | Multiple-EIN indicator (0=No, 1=Yes) |
| `contributions_total` | `CONT` | Total contributions |
| `prog_serv_rev` | `PROGREV` | Program service revenue |
| `revenue_total` | `TOTREV` | Total revenue |
| `expenses_total` | `EXPS` | Total expenses |
| `total_assets_eoy` | `TOTASS` | Total assets (end of year) |
| `net_assets_eoy` | `NETASS` | Net assets (end of year) |
| `compensation_officers` | `COMPENS` | Officer compensation |
| `salaries_other` | `OTHSAL` | Other salaries |

> **Note:** The full 161 columns include detailed revenue breakdowns (Part VIII), expense breakdowns (Part IX), and balance sheet items (Part X). Consult the codebook for the complete list. Use `get_codebook_url("nccs/codebook_colleges_nccs_form_990")` from `fetch-patterns.md` to download it.

### Missing Data Codes

| Code | Meaning | When Used |
|------|---------|-----------|
| `-1` | Data unavailable | Not collected for this form/year |
| `-2` | Not applicable | Field doesn't apply to this entity |
| `-3` | Suppressed | Confidentiality restriction |
| `null` | Not reported | Organization did not report (may have data) |
| `0` | Zero value | Explicitly reported as zero |

> **Important:** In Portal data, `-1`/`-2`/`-3` are integer values. However, empirically these codes are **rare** in the NCCS Portal dataset — most missing data appears as `null` rather than negative codes. Only a handful of financial columns (e.g., `sale_sec_gross_net`, `changes_net_assets_other`) contain any `-1`/`-2`/`-3` values. A `0` means the organization reported zero; `null` means the organization did not report. These are distinct conditions.

## Data Access

Datasets for NCCS are available via the mirror system. See `datasets-reference.md` for canonical paths, `mirrors.yaml` for mirror configuration, and `fetch-patterns.md` for fetch code patterns.

| Dataset | Type | Years | Path | Codebook |
|---------|------|-------|------|----------|
| 990 Forms | Single | 1993-2016 | `nccs/colleges_nccs_all` | `nccs/codebook_colleges_nccs_form_990` |

Codebooks are `.xls` files co-located with data in all mirrors. Use `get_codebook_url()` from `fetch-patterns.md` to construct download URLs.

> **Truth Hierarchy:** When interpreting variable values, apply this priority:
> 1. **Actual data file** (what you observe in the parquet/CSV) — this IS the truth
> 2. **Live codebook** (.xls in mirror) — authoritative documentation, may lag
> 3. **This skill documentation** — convenient summary, may drift from codebook
>
> If this documentation contradicts the codebook, trust the codebook. If the codebook contradicts observed data, trust the data and investigate.

### Filtering

The Portal dataset is **pre-filtered** to higher education institutions matched to IPEDS UNITIDs. NTEE codes are NOT included in the Portal data — for NTEE-based filtering, use the full NCCS BMF directly.

```python
import polars as pl

# Filter by year
df_2015 = df.filter(pl.col("year") == 2015)

# Filter by state (integer FIPS codes)
df_ca = df.filter(pl.col("fips") == 6)  # California

# Filter out null values from financial columns
df_valid = df.filter(
    (pl.col("revenue_total").is_not_null()) &
    (pl.col("revenue_total") >= 0)  # Excludes rare -1/-2/-3 codes
)

# Replace negative codes with null for analysis (precautionary)
df = df.with_columns(
    pl.when(pl.col("revenue_total") < 0)
    .then(None)
    .otherwise(pl.col("revenue_total"))
    .alias("revenue_total_clean")
)
```

## Common Pitfalls

| Pitfall | Issue | Solution |
|---------|-------|----------|
| Using string codes | Portal uses integer FIPS (`6`), not string (`"CA"` or `"06"`) | Always use integer comparisons; filter `>= 1` to exclude missing codes |
| Filing threshold confusion | Organizations under $200K revenue may file 990-EZ with fewer variables | Check form type; use Core PZ files for combined 990/990-EZ coverage |
| Fiscal year variation | Nonprofits have different fiscal year ends (June 30 common for colleges) | `year` = Portal academic year (fall semester); `fiscal_year` = IRS fiscal year end (typically `year` + 1). Filter on `year` for IPEDS joins. |
| No NTEE in Portal data | Portal dataset does not include NTEE codes; pre-filtered to higher ed institutions | Cannot filter by NTEE code; use full NCCS BMF for NTEE-based filtering |
| NTEE classification accuracy | ~25% of NTEE codes estimated to be imprecise | Use NCCS-corrected codes (`NTEE_NCCS`) over IRS-assigned codes when available |
| Consolidated filings | Some university systems file consolidated 990s covering multiple campuses | Check `mult_ein_flag`; one EIN may represent multiple institutions |
| Form version changes | Form 990 was redesigned in 2008; variable definitions changed | Be cautious comparing pre-2008 and post-2008 data for governance variables |
| Missing vs. zero | `0` means explicitly reported zero; `null` means not reported | Distinguish between zero-value and not-reported before aggregating |

## Key Differences: NCCS vs. IPEDS

| Aspect | NCCS (Form 990) | IPEDS |
|--------|-----------------|-------|
| **Coverage** | All 501(c)(3) nonprofits | Title IV institutions only |
| **Reporting Basis** | IRS fiscal year | IPEDS survey cycles |
| **Financial Framework** | Nonprofit accounting (GAAP) | Education-specific categories |
| **Governance** | Detailed board/compensation data | Limited HR data |
| **Programs** | Mission statements, activities | Degree programs, enrollment |
| **Identifier** | EIN | UNITID |
| **Update Frequency** | Annual (with lag) | Annual |

## Exploration Workflow

### Using Portal Data (Recommended for Education Research)

1. **Fetch data** via `fetch_from_mirrors("nccs/colleges_nccs_all")`
   - Data is pre-filtered to higher education institutions matched to IPEDS
   - Already includes `unitid` for IPEDS joining
   - 161 financial/organizational variables, 1993-2016

2. **Filter and clean**
   - Filter by year, state (FIPS), or institution
   - Handle nulls (primary missing data form in Portal)
   - Check for rare negative codes (-1/-2/-3) in financial columns

3. **Link to IPEDS** using `unitid` and `year` columns
   - Join with IPEDS directory, enrollment, finance, etc.

4. **Analyze** — See variable definitions for meaning and limitations

### Using Full NCCS (for Non-Education or Pre-Portal Research)

1. **Identify target organizations**
   - Filter BMF by NTEE codes (B40-B50 for higher ed)
   - Verify 501(c)(3) status (SUBSECCD = 03)
   - Note EINs for organizations of interest

2. **Select appropriate dataset**
   - Core PZ for broad coverage
   - Core PC for detailed financials (larger orgs)
   - Efile for maximum detail (governance, compensation)

3. **Extract and clean data**
   - Download relevant years from NCCS directly
   - Merge with BMF for organizational attributes
   - Handle missing data codes

4. **Analyze** — See variable definitions for meaning and limitations

## Related Data Sources

| Source | Relationship | When to Use |
|--------|--------------|-------------|
| `education-data-source-ipeds` | Complementary institution data | Join on EIN-UNITID crosswalk for enrollment, degrees, and education-specific financials |
| `education-data-explorer` | Parent discovery skill | Finding available endpoints |
| `education-data-query` | Data fetching | Downloading parquet/CSV files |

## Topic Index

| Topic | Reference File |
|-------|---------------|
| BMF overview | `./references/nonprofit-data.md` |
| Core data series | `./references/nonprofit-data.md` |
| Efile database | `./references/nonprofit-data.md` |
| Form 990 structure | `./references/form-990.md` |
| Revenue variables | `./references/form-990.md` |
| Expense variables | `./references/form-990.md` |
| Balance sheet | `./references/form-990.md` |
| Governance data | `./references/form-990.md` |
| Schedule details | `./references/form-990.md` |
| Linking to IPEDS | `./references/education-relevance.md` |
| Private college identification | `./references/education-relevance.md` |
| Supplementing education research | `./references/education-relevance.md` |
| NTEE code structure | `./references/ntee-codes.md` |
| Education NTEE codes | `./references/ntee-codes.md` |
| NTEEV2 format | `./references/ntee-codes.md` |
| Financial variables | `./references/variable-definitions.md` |
| Variable naming conventions | `./references/variable-definitions.md` |
| Data quality issues | `./references/variable-definitions.md` |

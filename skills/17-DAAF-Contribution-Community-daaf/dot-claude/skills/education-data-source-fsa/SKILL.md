---
name: education-data-source-fsa
description: >-
  FSA — Title IV aid at institution level (~5,500 institutions, 1999-2021). Pell Grants, Direct/PLUS loans, campus-based aid, financial responsibility scores, 90/10 metrics. Use for aid distribution, loan volume, or for-profit analysis. By unitid.
metadata:
  audience: any-agent
  domain: data-source
  skill-authored: "2026-02-09"
  skill-last-updated: "2026-02-09"
---

# FSA Data Source Reference

Federal Student Aid (FSA) — institutional-level Title IV aid data for ~5,500 postsecondary institutions, covering Pell Grants, Direct and PLUS loans, campus-based aid (FWS, FSEOG, Perkins), financial responsibility composite scores, and 90/10 revenue metrics (1999-2021, varies by dataset). Use when analyzing Pell Grant distribution by institution type, student loan volume, campus-based aid allocation, or for-profit financial health and 90/10 compliance. Identified by IPEDS unitid.

Reference guide for FSA data available through the Urban Institute Education Data Portal. FSA data provides institutional-level information on Title IV federal student aid programs administered by the U.S. Department of Education.

> **CRITICAL: Value Encoding**
>
> The Education Data Portal converts categorical variables to **integers**. This differs from original FSA documentation which may use string codes. All categorical columns in the Portal parquet files are integer-typed.
>
> | Variable | Example Value | Meaning |
> |----------|---------------|---------|
> | `grant_type` | `1` | Federal Pell Grant |
> | `loan_type` | `1` | Subsidized Direct Loan - Undergraduate |
> | `award_type` | `1` | Federal Supplemental Educational Opportunity Grants |
> | `fips` | `6` | California |
> | `allocation_flag` | `1` | Yes |
>
> **Missing data codes** (`-1`, `-2`, `-3`) apply to `numeric` format variables, not categorical codes.
>
> See `./references/variable-definitions.md` for complete encoding tables.

## Truth Hierarchy

When interpreting FSA data values and resolving discrepancies between this skill documentation and observed data, apply this priority:

| Priority | Source | Rationale |
|----------|--------|-----------|
| 1 (highest) | **Actual data file** (parquet) | What you observe IS the truth |
| 2 | **Live codebook/metadata** (.xls in mirror) | Authoritative documentation; may lag behind data |
| 3 (lowest) | **This skill documentation** (variable-definitions.md, etc.) | Summarized; convenient but may drift |

- When this skill contradicts observed data: trust the data, flag the discrepancy
- When codebook contradicts observed data: trust the data, but investigate
- When this skill contradicts codebook: trust the codebook, update this skill

**Codebook Access:** Use `get_codebook_url()` from `fetch-patterns.md` with paths from `datasets-reference.md`:

```python
# Example: Get codebook for FSA grants
url = get_codebook_url("fsa/codebook_colleges_fsa_grants")
```

| Dataset | Codebook Path |
|---------|---------------|
| Grants | `fsa/codebook_colleges_fsa_grants` |
| Loans | `fsa/codebook_colleges_fsa_loans` |
| Campus-Based Volume | `fsa/codebook_colleges_fsa_campus_based_volume` |
| Financial Responsibility | `fsa/codebook_colleges_fsa_financial_responsibility` |
| 90/10 Revenue | `fsa/codebook_colleges_fsa_90-10_revenue_percentages` |

> **FSA naming note:** The Financial Responsibility dataset uses `composite_scores` in its data path but `financial_responsibility` in its codebook path. The 90/10 Revenue dataset uses underscores (`90_10`) in the data path but hyphens (`90-10`) in the codebook path. Always use the exact paths shown above.

## What is Federal Student Aid?

Federal Student Aid (FSA) is the office within the U.S. Department of Education that administers Title IV aid programs:

- **Title IV Programs**: Federal financial aid authorized under Title IV of the Higher Education Act (HEA)
- **Institutional Coverage**: All Title IV-eligible postsecondary institutions (approximately 5,500+ schools)
- **Data Types**: Aid disbursements, recipient counts, loan/grant volumes, financial responsibility metrics
- **Primary Identifier**: `unitid` (6-digit IPEDS institution ID)
- **Years Available**: 1999-2021 depending on dataset

## Reference File Structure

| File | Purpose | When to Read |
|------|---------|--------------|
| `title-iv-programs.md` | Pell Grants, Direct Loans, PLUS, campus-based aid | Understanding aid program types |
| `financial-responsibility.md` | Composite scores, institutional oversight | Analyzing institutional financial health |
| `90-10-rule.md` | For-profit revenue requirements | Working with proprietary institutions |
| `variable-definitions.md` | Key variables, aid types, amounts | Building queries, interpreting results |
| `data-quality.md` | Known issues, coverage, timing | Understanding data limitations |

## Decision Trees

### What FSA topic am I researching?

```
FSA research topic?
├─ Grant programs
│   ├─ Federal Pell Grants → ./references/title-iv-programs.md
│   ├─ FSEOG (campus-based) → ./references/title-iv-programs.md
│   └─ Grant amounts/recipients → ./references/variable-definitions.md
├─ Loan programs
│   ├─ Direct Subsidized/Unsubsidized → ./references/title-iv-programs.md
│   ├─ Parent PLUS loans → ./references/title-iv-programs.md
│   ├─ Graduate PLUS loans → ./references/title-iv-programs.md
│   ├─ Perkins Loans (legacy) → ./references/title-iv-programs.md
│   └─ Loan volumes/disbursements → ./references/variable-definitions.md
├─ Campus-based programs
│   ├─ Federal Work-Study → ./references/title-iv-programs.md
│   ├─ FSEOG → ./references/title-iv-programs.md
│   └─ Program allocations → ./references/variable-definitions.md
├─ Institutional oversight
│   ├─ Financial responsibility scores → ./references/financial-responsibility.md
│   ├─ 90/10 rule compliance → ./references/90-10-rule.md
│   └─ Eligibility/participation → ./references/data-quality.md
└─ Data quality concerns
    └─ Coverage, timing, limitations → ./references/data-quality.md
```

### Which FSA dataset do I need?

```
FSA dataset selection?
├─ Need grant data (Pell, FSEOG)
│   └─ fsa/colleges_fsa_grants (single-file, 1999-2021)
├─ Need loan data (Direct, PLUS)
│   └─ fsa/colleges_fsa_loans (single-file, 1999-2021)
├─ Need campus-based program data
│   └─ fsa/colleges_fsa_campus_based_volume (single-file, 2001-2021)
├─ Need institutional financial health
│   └─ fsa/colleges_fsa_composite_scores (single-file, 2006-2016)
└─ Need 90/10 compliance (for-profits)
    └─ fsa/colleges_fsa_90_10_revenue_percentages (single-file, 2014-2021)
```

## Quick Reference: FSA Datasets and Codes

### Datasets

| Dataset Path | Description | Years | Key Variables |
|--------------|-------------|-------|---------------|
| `fsa/colleges_fsa_grants` | Grant recipients and amounts by type | 1999-2021 | `grant_type`, `grant_recipients_unitid`, `value_grants_disbursed_unitid` |
| `fsa/colleges_fsa_loans` | Loan recipients and volumes by type | 1999-2021 | `loan_type`, `loan_recipients_unitid`, `value_loan_disbursements_unitid` |
| `fsa/colleges_fsa_campus_based_volume` | FWS, FSEOG, Perkins by award type | 2001-2021 | `award_type`, `campus_award_recipients_unitid`, `value_campus_disbursed_unitid` |
| `fsa/colleges_fsa_composite_scores` | Composite scores by institution | 2006-2016 | `financial_resp_score` |
| `fsa/colleges_fsa_90_10_revenue_percentages` | For-profit Title IV revenue ratios | 2014-2021 | `rev_pct_90_10` |

> **Data access:** All FSA datasets are single-file (all years in one file). Fetch using `fetch_from_mirrors()` from `fetch-patterns.md` with the canonical path from `datasets-reference.md`. See `mirrors.yaml` for mirror configuration.

### Key Identifiers

| ID | Format | Level | Example | Notes |
|----|--------|-------|---------|-------|
| `unitid` | 6-digit integer | Institution | `110635` | IPEDS institution ID; primary join key across FSA datasets and to IPEDS/Scorecard |
| `fips` | 2-digit integer | State | `6` | State FIPS code |

### Title IV Programs

| Program | Type | Eligibility | Max Amount (2025-26) |
|---------|------|-------------|----------------------|
| Federal Pell Grant | Need-based grant | Undergrad with financial need | $7,395 |
| Direct Subsidized Loan | Need-based loan | Undergrad with financial need | $3,500-$5,500/yr |
| Direct Unsubsidized Loan | Non-need loan | Undergrad/Grad students | $5,500-$20,500/yr |
| Parent PLUS Loan | Credit-based loan | Parents of dependent undergrads | Cost of attendance |
| Graduate PLUS Loan | Credit-based loan | Graduate/professional students | Cost of attendance |
| FSEOG | Need-based grant | Undergrad with exceptional need | $100-$4,000/yr |
| Federal Work-Study | Employment program | Students with financial need | Varies by school |
| Perkins Loan | Need-based loan | Discontinued (no new loans after 2017) | N/A |

### Financial Responsibility Scores

| Score Range | Classification | Meaning |
|-------------|----------------|---------|
| 1.5 to 3.0 | Financially Responsible | Meets all standards |
| 1.0 to 1.49 | In the Zone | Provisionally certified, monitoring required |
| Below 1.0 | Not Financially Responsible | Must post letter of credit or face sanctions |
| -1.0 | Minimum score | Lowest possible composite score |

### Grant Type Codes (grants dataset)

| Code | Grant Type |
|------|------------|
| `1` | Federal Pell Grant |
| `2` | Federal Supplemental Educational Opportunity Grant (FSEOG) |
| `3` | TEACH Grant |
| `4` | Iraq and Afghanistan Service Grant |
| `5` | Children of Fallen Heroes Grant |

### Loan Type Codes (loans dataset)

| Code | Loan Type |
|------|-----------|
| `1` | Subsidized Direct Loan - Undergraduate |
| `2` | Subsidized Direct Loan - Graduate |
| `3` | Subsidized Direct Loan - Total |
| `4` | Unsubsidized Direct Loan - Undergraduate |
| `5` | Unsubsidized Direct Loan - Graduate |
| `6` | Unsubsidized Direct Loan - Total |
| `7` | Direct Loan, Parent PLUS |
| `8` | Direct Loan, Grad PLUS |
| `9` | Direct Loan PLUS (sum of Parent PLUS and Grad PLUS) |
| `10` | Subsidized Federal Family Education Loans |
| `11` | Unsubsidized Federal Family Education Loans |
| `12` | Parent PLUS Federal Family Education Loans |
| `13` | Grad PLUS Federal Family Education Loans |
| `14` | PLUS Federal Family Education Loans |

### Award Type Codes (campus-based-volume dataset)

| Code | Award Type |
|------|------------|
| `1` | Federal Supplemental Educational Opportunity Grants |
| `2` | Federal Work-Study |
| `3` | Perkins Loans |

### Yes/No Codes (allocation_flag, combined_flag)

| Code | Meaning |
|------|---------|
| `0` | No |
| `1` | Yes |
| `null` | Not reported |

### Missing Data Codes

| Code | Meaning | When Used |
|------|---------|-----------|
| `-1` | Missing/not reported | Data not reported by institution |
| `-2` | Not applicable | Item doesn't apply to this entity |
| `-3` | Suppressed data | Data suppressed for privacy |
| `null` | Not available | Field not populated for this record |

## Data Access

All FSA datasets are fetched via the **mirror system**. Three reference files govern data access:

| Reference File | Purpose |
|----------------|---------|
| `mirrors.yaml` | Mirror URLs, read strategies, timeouts, discovery endpoints |
| `datasets-reference.md` | Canonical dataset paths and codebook paths |
| `fetch-patterns.md` | `fetch_from_mirrors()` function and codebook URL helper |

**Key datasets (all single-file, all years in one file):**

| Dataset | Canonical Path | Years | Codebook Path |
|---------|---------------|-------|---------------|
| Grants | `fsa/colleges_fsa_grants` | 1999-2021 | `fsa/codebook_colleges_fsa_grants` |
| Loans | `fsa/colleges_fsa_loans` | 1999-2021 | `fsa/codebook_colleges_fsa_loans` |
| Campus-Based Volume | `fsa/colleges_fsa_campus_based_volume` | 2001-2021 | `fsa/codebook_colleges_fsa_campus_based_volume` |
| Financial Responsibility | `fsa/colleges_fsa_composite_scores` | 2006-2016 | `fsa/codebook_colleges_fsa_financial_responsibility` |
| 90/10 Revenue | `fsa/colleges_fsa_90_10_revenue_percentages` | 2014-2021 | `fsa/codebook_colleges_fsa_90-10_revenue_percentages` |

> **Naming mismatches (intentional):** Financial Responsibility uses `composite_scores` in data path but `financial_responsibility` in codebook path. 90/10 Revenue uses underscores (`90_10`) in data path but hyphens (`90-10`) in codebook path.

### Fetch Example

```python
import polars as pl

# Using fetch_from_mirrors() from fetch-patterns.md
df_grants = fetch_from_mirrors("fsa/colleges_fsa_grants", years=[2019, 2020, 2021])

# Filter by grant type (1 = Federal Pell Grant)
df_pell = df_grants.filter(pl.col("grant_type") == 1)

# Filter by institution
df_inst = df_grants.filter(pl.col("unitid") == 110635)

# Filter by year range
df_recent = df_grants.filter(pl.col("year").is_between(2015, 2021))
```

## Common Pitfalls

| Pitfall | Issue | Solution |
|---------|-------|----------|
| Using string codes | Portal encodes categoricals as integers; original FSA docs may reference string labels | Always use integer codes (e.g., `grant_type == 1` not `"Pell"`) |
| Ignoring missing data codes | `-1`, `-2`, `-3` in numeric columns are sentinel values, not real amounts | Filter or handle missing codes before aggregation; exclude negative values from sums/means |
| Stale financial responsibility data | `colleges_fsa_composite_scores` only covers 2006-2016 | Check year coverage before analysis; do not assume current availability |
| 90/10 percentage is a proportion | `rev_pct_90_10` is stored as 0-1 (e.g., 0.87), NOT 0-100 | Multiply by 100 for display; compare to 0.90 threshold, not 90 |
| Perkins Loan discontinuation | Perkins Loans ended after 2017; campus-based data still includes historical records | Filter by year or award_type to avoid mixing discontinued and active programs |
| Data lag | FSA data typically lags 1-2 years behind the current award year | Verify latest available year before planning analysis |
| Mixing aggregate and detail loan types | Loan type codes include both individual types (1-8, 10-13) and aggregate totals (3, 6, 9, 14) | Filter to specific types or aggregates, never sum both together |
| Pell recipient counts unavailable for 2020+ | `grant_recipients_unitid` is 100% NULL for Pell grants (`grant_type==1`) in the 2020-2021 data year. Disbursement amounts also appear null | Use IPEDS SFA (`sfa_grants_and_net_price`) as a proxy for grant recipient counts. Note that SFA `type_of_aid=9` captures all grant/scholarship aid, not Pell-specific (see IPEDS skill) |

## Joining FSA Data with Other Sources

| Source 1 | Source 2 | Join Key | Use Case |
|----------|----------|----------|----------|
| FSA Grants | IPEDS Directory | `unitid` | Aid by institution type |
| FSA Loans | IPEDS Enrollment | `unitid` | Loan volume per student |
| FSA Financial Responsibility | IPEDS Finance | `unitid` | Financial health analysis |
| FSA 90/10 | IPEDS Directory | `unitid` | For-profit compliance |
| FSA | College Scorecard | `unitid` | Aid and student outcomes |

## Common Research Applications

| Research Question | FSA Datasets | Complementary Data |
|-------------------|-------------|-------------------|
| Pell Grant distribution by institution type | `fsa/colleges_fsa_grants` | IPEDS Directory |
| Student loan burden by sector | `fsa/colleges_fsa_loans` | IPEDS Enrollment |
| Financial stability of for-profit schools | `fsa/colleges_fsa_composite_scores`, `fsa/colleges_fsa_90_10_revenue_percentages` | IPEDS Directory |
| Campus-based aid allocation patterns | `fsa/colleges_fsa_campus_based_volume` | IPEDS Directory |
| Title IV participation trends | `fsa/colleges_fsa_grants`, `fsa/colleges_fsa_loans` | Multiple years |

## Data Update Schedule

- FSA data typically lags 1-2 years behind the current award year
- Financial responsibility scores published annually
- 90/10 percentages updated after institutional fiscal year audits
- Campus-based data tied to FISAP reporting cycle

## Related Data Sources

| Source | Relationship | When to Use |
|--------|--------------|-------------|
| `education-data-source-ipeds` | Institutional characteristics and enrollment | Joining aid data with institution type, enrollment, or finances via `unitid` |
| `education-data-source-scorecard` | Student outcomes after enrollment | Linking aid patterns to post-college earnings and repayment |
| `education-data-source-fsa` | Self (cross-dataset joins) | Combining grants + loans + campus-based for holistic aid picture |
| `education-data-explorer` | Parent discovery skill | Finding available FSA datasets and variables |
| `education-data-query` | Data fetching | Downloading FSA data from mirrors via `fetch_from_mirrors()` |

## Topic Index

| Topic | Reference File |
|-------|---------------|
| Pell Grant program | `./references/title-iv-programs.md` |
| Direct Loan program | `./references/title-iv-programs.md` |
| PLUS loans | `./references/title-iv-programs.md` |
| Federal Work-Study | `./references/title-iv-programs.md` |
| FSEOG grants | `./references/title-iv-programs.md` |
| Perkins Loans | `./references/title-iv-programs.md` |
| Composite score calculation | `./references/financial-responsibility.md` |
| Primary reserve ratio | `./references/financial-responsibility.md` |
| Equity ratio | `./references/financial-responsibility.md` |
| Net income ratio | `./references/financial-responsibility.md` |
| 90/10 rule requirements | `./references/90-10-rule.md` |
| For-profit revenue sources | `./references/90-10-rule.md` |
| Grant variables | `./references/variable-definitions.md` |
| Loan variables | `./references/variable-definitions.md` |
| Campus-based variables | `./references/variable-definitions.md` |
| Data coverage | `./references/data-quality.md` |
| Missing data handling | `./references/data-quality.md` |
| Year coverage by dataset | `./references/data-quality.md` |

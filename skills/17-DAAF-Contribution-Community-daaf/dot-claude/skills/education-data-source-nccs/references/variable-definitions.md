# NCCS Variable Definitions

This reference provides definitions for key variables in NCCS datasets, including naming conventions, common financial measures, and data quality considerations.

> **Truth Hierarchy:** When interpreting variable values, apply this priority:
> 1. **Actual data file** (what you observe in the parquet/CSV) — this IS the truth
> 2. **Live codebook** (.xls in mirror, via `get_codebook_url("nccs/codebook_colleges_nccs_form_990")`) — authoritative documentation, may lag
> 3. **This file** — convenient summary, may drift from codebook
>
> If this documentation contradicts the codebook or observed data, trust the higher-priority source.

## Education Data Portal vs. Direct NCCS Access

> **CRITICAL:** Variable names and encodings differ between the Education Data Portal and direct NCCS downloads.

| Aspect | Education Data Portal | Direct NCCS |
|--------|----------------------|-------------|
| **Variable case** | lowercase (`contributions_total`) | UPPERCASE (`CONT`) |
| **Naming style** | Descriptive (`prog_serv_rev`) | Abbreviated (`PROGREV`) |
| **FIPS encoding** | Integer (`6` for California) | May be string (`"06"`) |
| **Missing codes** | Integer (`-1`, `-2`, `-3`) | Integer or blank |
| **Data format** | Parquet (via Portal mirror) | CSV |

### Portal Variable Mapping

| Portal Name | NCCS Name | Description |
|-------------|-----------|-------------|
| `year` | `FISYR` | Academic year — the Portal-aligned year corresponding to the fall semester of the academic year the filing is associated with (range 1993-2016). The codebook labels this "Academic year (fall semester)." |
| `fiscal_year` | — | Fiscal year — the IRS fiscal year ending year from the Form 990 filing (range 1994-2017). Typically differs from `year` by +1 because a fiscal year ending in e.g. June 2015 corresponds to the 2014-2015 academic year (`year`=2014, `fiscal_year`=2015). |
| `unitid` | — | IPEDS institution ID (Portal addition) |
| `ein` | `EIN` | Employer Identification Number (Int64) |
| `fips` | `FIPS` | State FIPS code (integer in Portal, 1-78) |
| `inst_name_nccs` | `NAME` | Organization name from 990 filing (String) |
| `mult_ein_flag` | — | Multiple-EIN indicator (0=No, 1=Yes) |
| `contributions_total` | `CONT` | Total contributions |
| `prog_serv_rev` | `PROGREV` | Program service revenue |
| `revenue_total` | `TOTREV` | Total revenue |
| `expenses_total` | `EXPS` | Total expenses |
| `total_assets_eoy` | `TOTASS` | Total assets (end of year) |
| `net_assets_eoy` | `NETASS` | Net assets |
| `compensation_officers` | `COMPENS` | Officer compensation |
| `salaries_other` | `OTHSAL` | Other salaries |

> **Note:** The Portal dataset has 161 columns total. The table above shows selected key variables. Consult the codebook for the complete list. The full dataset includes detailed Part VIII revenue breakdowns (e.g., `prog_serv_rev_amt2a` through `prog_serv_rev_amt2f`), Part IX expense breakdowns, Part X balance sheet items, and support test variables (170/509).

## Contents

- [Variable Naming Conventions](#variable-naming-conventions)
- [Core Data Series Variables](#core-data-series-variables)
- [Business Master File Variables](#business-master-file-variables)
- [Efile Variable Naming](#efile-variable-naming)
- [Financial Measure Definitions](#financial-measure-definitions)
- [Missing Data Codes](#missing-data-codes)
- [Data Quality and Validation](#data-quality-and-validation)

---

## Variable Naming Conventions

### Core Data Series

Core data variables use abbreviated names that evolved over time. Common patterns:

| Pattern | Meaning | Examples |
|---------|---------|----------|
| TOT* | Total | TOTREV (total revenue), TOTASS (total assets) |
| NET* | Net | NETINC (net income), NETASS (net assets) |
| *REV | Revenue | PROGREV (program revenue), INVREV (investment revenue) |
| *EXP | Expenses | FUNEXP (functional expenses) |
| *INC | Income | INVINC (investment income) |
| *ASS | Assets | TOTASS (total assets), SECASS (securities assets) |
| *LIAB | Liabilities | TOTLIAB (total liabilities) |

### Efile Database

Efile variables follow a structured naming convention:

```
XX_XX_XX_VARIABLE_NAME
│  │  │  └── Descriptive name
│  │  └───── Part number (00-12)
│  └──────── Scope (PC, EZ, PZ, PF, HD)
└─────────── Form (F9, SA-SR for schedules)
```

**Examples**:
| Variable | Meaning |
|----------|---------|
| `F9_HD_00_EIN` | Form 990, Header, EIN |
| `F9_PC_01_TOTREV` | Form 990, Full filers, Part I, Total Revenue |
| `F9_PC_08_CONT` | Form 990, Full filers, Part VIII, Contributions |
| `SD_PC_05_ENDOW_EOY` | Schedule D, Full filers, Part V, Endowment End of Year |

---

## Core Data Series Variables

### Identification Variables

| Variable | Description | Notes |
|----------|-------------|-------|
| `EIN` | Employer Identification Number | 9-digit unique ID |
| `EIN2` | EIN with consistent formatting | Use for merging |
| `NCCSKEY` | Unique key (EIN + return date) | Identifies specific filing |
| `NAME` | Organization name | Legal name from 990 |
| `SEC_NAME` | Secondary/DBA name | If applicable |
| `FISYR` | Fiscal year (ending year) | YYYY format |
| `TAXPER` | Tax period end date | YYYYMM format |

### Location Variables

| Variable | Description | Notes |
|----------|-------------|-------|
| `ADDRESS` | Street address | From 990 header |
| `CITY` | City | |
| `STATE` | Two-letter state code | |
| `ZIP` | ZIP code | May include ZIP+4 |
| `ZIP5` | First 5 digits of ZIP | |
| `FIPS` | State + County FIPS code | 5 digits |
| `MSA_NECH` | Metro Statistical Area | NCCS assignment |

### Classification Variables

| Variable | Description | Values |
|----------|-------------|--------|
| `NTEE1` | NTEE major group | A-Z |
| `NTEECC` | Full NTEE code | Letter + 2 digits |
| `NTEE_IRS` | Official IRS NTEE | From BMF |
| `NTEE_NCCS` | NCCS-corrected NTEE | Research quality |
| `SUBSECCD` | IRS subsection | 03 = 501(c)(3), etc. |
| `FNDNCD` | Foundation code | See BMF documentation |
| `ORGCD` | Organization form | Corporation, trust, etc. |

### Revenue Variables

| Variable | Description | 990 Location |
|----------|-------------|--------------|
| `TOTREV` | Total revenue | Part I, Line 12 |
| `TOTREV2` | Total revenue (alt calculation) | Sum of components |
| `CONT` | Contributions and grants | Part VIII, Line 1 |
| `PROGREV` | Program service revenue | Part VIII, Line 2 |
| `DUES` | Membership dues | Part VIII, Line 1b |
| `INVINC` | Investment income | Part VIII, Lines 3-5 |
| `DIVID` | Dividend income | Part VIII, Line 4 |
| `INTINC` | Interest income | Part VIII, Line 3 |
| `NETRENT` | Net rental income | Part VIII, Line 6 |
| `SALESEXP` | Net gain/loss from sales | Part VIII, Lines 7-8 |
| `OTHREV` | Other revenue | Part VIII, Line 11 |
| `GRSRCPTS` | Gross receipts | Part I, Line 6 |

### Expense Variables

| Variable | Description | 990 Location |
|----------|-------------|--------------|
| `EXPS` | Total expenses | Part I, Line 18 |
| `TOTEXP` | Total functional expenses | Part IX, Line 25 |
| `FUNEXP` | Functional expenses | Part IX |
| `PROGEXP` | Program service expenses | Part IX, Col B |
| `MGTEXP` | Management/general expenses | Part IX, Col C |
| `FUNDEXP` | Fundraising expenses | Part IX, Col D |
| `GRNTS` | Grants and allocations | Part IX, Lines 1-3 |
| `COMPENS` | Compensation (officers) | Part IX, Line 5 |
| `OTHSAL` | Other salaries | Part IX, Line 7 |
| `PAIDSRV` | Professional fees | Part IX, Line 11 |
| `OCCUP` | Occupancy expenses | Part IX, Line 16 |
| `TRAVEL` | Travel expenses | Part IX, Line 17 |
| `DEPREC` | Depreciation | Part IX, Line 22 |
| `INTEREST` | Interest expense | Part IX, Line 20 |

### Balance Sheet Variables

| Variable | Description | 990 Location |
|----------|-------------|--------------|
| `TOTASS` | Total assets (EOY) | Part X, Line 16 |
| `TOTASSBEG` | Total assets (BOY) | Part X, Line 16 |
| `TOTLIAB` | Total liabilities (EOY) | Part X, Line 26 |
| `TOTLIABBEG` | Total liabilities (BOY) | Part X, Line 26 |
| `NETASS` | Net assets (EOY) | Part X, Line 33 |
| `NETASSBEG` | Net assets (BOY) | Part X, Line 33 |
| `FUNDSBAL` | Fund balance (BOY) | |
| `CASH` | Cash | Part X, Lines 1-2 |
| `SECUR` | Securities | Part X, Lines 11-12 |
| `LANDBNB` | Land, buildings, equipment (net) | Part X, Line 10c |
| `RETEARN` | Retained earnings/endowment | |
| `ACCTSPAY` | Accounts payable | Part X, Line 17 |
| `MORTG` | Mortgages and notes | Part X, Lines 23-24 |

### Computed Variables

| Variable | Description | Calculation |
|----------|-------------|-------------|
| `NETINC` | Net income | TOTREV - EXPS |
| `PROGREV_PCT` | Program revenue ratio | PROGREV / TOTREV |
| `ADMIN_PCT` | Administrative expense ratio | MGTEXP / TOTEXP |
| `FUNDR_PCT` | Fundraising expense ratio | FUNDEXP / TOTEXP |

---

## Business Master File Variables

### Core BMF Variables

| Variable | Description | Notes |
|----------|-------------|-------|
| `EIN` | Employer ID Number | Primary key |
| `NAME` | Organization name | Legal name |
| `ICO` | In care of name | Contact person |
| `STREET` | Street address | |
| `CITY` | City | |
| `STATE` | State | 2-letter code |
| `ZIP` | ZIP code | |
| `GROUP` | Group exemption number | For affiliated orgs |
| `SUBSECTION` | IRS code subsection | 501(c)(3), etc. |
| `AFFILIATION` | Affiliation code | Independent, central, subordinate |
| `CLASSIFICATION` | Classification code | |
| `RULING` | Ruling date | YYYYMM format |
| `DEDUCTIBILITY` | Deductibility code | 1 = contributions deductible |
| `FOUNDATION` | Foundation code | See FNDNCD |
| `ACTIVITY` | Activity codes | Historical (pre-NTEE) |
| `ORGANIZATION` | Organization type | Corporation, trust, etc. |
| `STATUS` | Tax-exempt status | Active, revoked, etc. |
| `TAX_PERIOD` | Tax period | Most recent filing |
| `ASSET_CD` | Asset code | Size category |
| `INCOME_CD` | Income code | Size category |
| `FILING_REQ_CD` | Filing requirement | 990, 990-EZ, 990-N |
| `PF_FILING_REQ_CD` | PF filing requirement | |
| `ACCT_PD` | Accounting period | Month fiscal year ends |
| `ASSET_AMT` | Asset amount | Most recent |
| `INCOME_AMT` | Gross receipts | Most recent |
| `REVENUE_AMT` | Revenue amount | Most recent |
| `NTEE_CD` | NTEE code | Official IRS code |

### NCCS Unified BMF Additions

| Variable | Description | Notes |
|----------|-------------|-------|
| `BLOCK_FIPS` | Census Block FIPS | 15-digit geocode |
| `TRACT_FIPS` | Census Tract FIPS | Derived from Block |
| `COUNTY_FIPS` | County FIPS | 5-digit |
| `CBSA` | Core-Based Statistical Area | Metro/micro area |
| `LAT` | Latitude | Geocoded |
| `LON` | Longitude | Geocoded |
| `FIRST_YEAR_CORE` | First year in Core data | |
| `LAST_YEAR_CORE` | Last year in Core data | |
| `ACTIVE` | Currently active | Boolean |

---

## Efile Variable Naming

### Form and Schedule Prefixes

| Prefix | Source |
|--------|--------|
| `F9_` | Form 990 |
| `SA_` | Schedule A (Public Charity Status) |
| `SB_` | Schedule B (Contributors) - restricted |
| `SC_` | Schedule C (Political Activity) |
| `SD_` | Schedule D (Supplemental Financials) |
| `SE_` | Schedule E (Schools) |
| `SF_` | Schedule F (Foreign Activities) |
| `SG_` | Schedule G (Fundraising/Gaming) |
| `SH_` | Schedule H (Hospitals) |
| `SI_` | Schedule I (Grants) |
| `SJ_` | Schedule J (Compensation) |
| `SK_` | Schedule K (Tax-Exempt Bonds) |
| `SL_` | Schedule L (Related Party Transactions) |
| `SM_` | Schedule M (Non-Cash Contributions) |
| `SN_` | Schedule N (Liquidation/Dissolution) |
| `SO_` | Schedule O (Supplemental Information) |
| `SR_` | Schedule R (Related Organizations) |

### Scope Codes

| Code | Meaning |
|------|---------|
| `HD` | Header (common across forms) |
| `PC` | Full Form 990 filers only |
| `EZ` | Form 990-EZ filers only |
| `PZ` | Both PC and EZ filers |
| `PF` | Form 990-PF (private foundations) |

### Part Numbers

| Part | Content |
|------|---------|
| `00` | Header/outside of parts |
| `01` | Part I - Summary |
| `03` | Part III - Program Accomplishments |
| `04` | Part IV - Checklist |
| `05` | Part V - Other Filings |
| `06` | Part VI - Governance |
| `07` | Part VII - Compensation |
| `08` | Part VIII - Revenue |
| `09` | Part IX - Expenses |
| `10` | Part X - Balance Sheet |
| `11` | Part XI - Reconciliation |
| `12` | Part XII - Financial Statements |

---

## Financial Measure Definitions

### Revenue Measures

**Total Revenue** (`TOTREV`):
- All income from all sources
- Includes contributions, program revenue, investment income
- Before expenses

**Contributions and Grants** (`CONT`):
- Donations from individuals, corporations, foundations
- Government grants (non-exchange)
- Does NOT include government contracts (those are program revenue)

**Program Service Revenue** (`PROGREV`):
- Revenue from mission-related activities
- Tuition and fees for educational institutions
- Government contracts
- Fee-for-service activities

**Investment Income** (`INVINC`):
- Interest, dividends, royalties
- Does NOT include capital gains (separate line)

### Expense Measures

**Total Functional Expenses** (`TOTEXP` or `FUNEXP`):
- All operating expenses
- Allocated to program, management, fundraising

**Program Expenses** (`PROGEXP`):
- Direct costs of mission delivery
- Educational instruction, student services

**Management and General** (`MGTEXP`):
- Administrative overhead
- Board expenses, finance, HR

**Fundraising** (`FUNDEXP`):
- Costs of soliciting contributions
- Development office, events

### Balance Sheet Measures

**Total Assets** (`TOTASS`):
- All resources owned
- Cash, investments, property, receivables

**Net Assets** (`NETASS`):
- Assets minus liabilities
- Equivalent to "fund balance" or "equity"
- Two categories:
  - Without donor restrictions (unrestricted)
  - With donor restrictions (restricted)

### Derived Ratios

| Ratio | Calculation | Interpretation |
|-------|-------------|----------------|
| Program Ratio | PROGEXP / TOTEXP | Higher = more efficient |
| Admin Ratio | MGTEXP / TOTEXP | Lower = less overhead |
| Fundraising Efficiency | FUNDEXP / CONT | Lower = more efficient fundraising |
| Revenue Concentration | Max source / TOTREV | Higher = more dependent |
| Liquidity | Cash / TOTEXP | Months of operating reserves |

---

## Missing Data Codes

### NCCS Standard Codes (Integer in Portal)

| Code | Meaning |
|------|---------|
| `-1` | Data unavailable (not collected) |
| `-2` | Not applicable (field doesn't apply) |
| `-3` | Suppressed (confidentiality) |
| `null` | Not reported by organization |
| `0` | Zero value (explicitly reported) |

> **Portal Note:** In the Portal dataset, `-1`/`-2`/`-3` are integer values but are **empirically rare** — most missing data appears as `null`. Only a handful of financial columns (e.g., `sale_sec_gross_net`, `changes_net_assets_other`) contain any negative coded values. Always check for both `null` and negative codes when cleaning.

### Interpreting Missing Data

**Important distinctions** (using Portal variable names):

| Observation | Interpretation |
|-------------|----------------|
| `invest_inc_total = 0` | Organization reported zero investment income |
| `invest_inc_total = null` | Organization did not report (may have income) |
| `invest_inc_total = -1` | Variable not available for this form/year |

### Handling Missing Data

**Using Portal data (Polars):**

```python
import polars as pl

# Load NCCS data via unified mirror system
DATASET_PATH = "nccs/colleges_nccs_all"
df = fetch_from_mirrors(DATASET_PATH)

# Filter out null and rare negative codes
df_clean = df.filter(
    (pl.col("invest_inc_total").is_not_null()) &
    (pl.col("invest_inc_total") >= 0)  # Excludes rare -1, -2, -3 codes
)

# Or replace negative codes with null (precautionary)
df = df.with_columns(
    pl.when(pl.col("invest_inc_total") < 0)
    .then(None)
    .otherwise(pl.col("invest_inc_total"))
    .alias("invest_inc_total_clean")
)

# Distinguish zero from missing
df = df.with_columns(
    (pl.col("invest_inc_total").is_not_null() & (pl.col("invest_inc_total") > 0))
    .alias("has_inv_income")
)
```

**Using direct NCCS data (Polars):**

```python
import polars as pl

# Replace negative codes with null
df = df.with_columns(
    pl.when(pl.col("INVINC") < 0)
    .then(None)
    .otherwise(pl.col("INVINC"))
    .alias("INVINC")
)
```

---

## Data Quality and Validation

### Common Data Issues

| Issue | Description | Detection |
|-------|-------------|-----------|
| **Outliers** | Extreme values (errors or real) | Check against organization size |
| **Sign errors** | Negative revenue or assets | Values should be positive |
| **Rounding** | Values rounded to nearest thousand | Small values may be imprecise |
| **Duplicates** | Same filing multiple times | Check NCCSKEY uniqueness |
| **Fiscal year mismatch** | Comparing different periods | Verify TAXPER alignment |

### Validation Checks

**Using Portal data (Polars, lowercase variable names):**

**Balance sheet identity**:
```python
import polars as pl

# Assets should equal Liabilities + Net Assets
df = df.with_columns(
    (pl.col("total_assets_eoy") - pl.col("total_liab_eoy") - pl.col("net_assets_eoy"))
    .abs()
    .alias("balance_check")
)
balance_errors = df.filter(pl.col("balance_check") > 100)  # Allow small rounding
```

**Revenue reconciliation**:
```python
# Total revenue should approximate sum of components
df = df.with_columns(
    (pl.col("contributions_total") + pl.col("prog_serv_rev") + pl.col("invest_inc_total"))
    .alias("rev_sum")
)
df = df.with_columns(
    (pl.col("revenue_total") - pl.col("rev_sum")).abs().alias("rev_check")
)
# Note: revenue_total includes other categories not shown here; some gap is expected
```

**Year-over-year reasonableness**:
```python
# Flag large year-over-year changes (sorted by ein and year)
df = df.sort(["ein", "year"])
df = df.with_columns(
    (pl.col("revenue_total") / pl.col("revenue_total").shift(1).over("ein") - 1)
    .alias("rev_change")
)
unusual = df.filter(pl.col("rev_change").abs() > 1.0)  # >100% change
```

**Using direct NCCS data (UPPERCASE variable names):** Replace Portal names with NCCS names (e.g., `TOTASS`, `TOTLIAB`, `NETASS`, `TOTREV`, `CONT`, etc.).

### Error Checking Recommendations

1. **Check totals vs. components**: Sum of parts should equal reported total
2. **Verify balance sheet**: Assets = Liabilities + Net Assets
3. **Look for negative values**: Most financial variables should be positive
4. **Examine outliers**: Top/bottom 1% may include errors
5. **Compare to prior year**: Large changes warrant investigation
6. **Cross-check with audited financials**: When available for key institutions
7. **Verify against external sources**: IPEDS, institution websites

### Known Data Issues

**Form version changes (2008)**:
- Governance questions added
- Compensation reporting expanded
- Some variable definitions changed

**Efile transition period (2012-2021)**:
- Not all organizations filed electronically
- Large orgs more likely to efile
- Sample may not be representative

**Fiscal year variation**:
- Organizations have different year-ends
- June 30 common for colleges
- December 31 common for others
- Some file on different cycles

### Documentation Resources

- **NCCS Data Guide**: https://nccs.urban.org/pubs/nccs-data-guide.pdf
- **Core Data Dictionary**: https://nccsdata.s3.amazonaws.com/harmonized/core/CORE-HRMN_dd.csv
- **Efile Data Dictionary**: https://nonprofit-open-data-collective.github.io/irs990efile/data-dictionary/
- **Master Concordance File**: https://github.com/Nonprofit-Open-Data-Collective/irs-efile-master-concordance-file

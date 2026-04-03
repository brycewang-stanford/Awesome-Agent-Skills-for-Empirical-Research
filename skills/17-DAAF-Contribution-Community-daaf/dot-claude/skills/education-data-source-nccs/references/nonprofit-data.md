# NCCS Nonprofit Data Sources

The National Center for Charitable Statistics maintains multiple datasets derived from IRS administrative records. This reference covers what data is available and how to access it.

## Contents

- [Business Master File (BMF)](#business-master-file-bmf)
- [NCCS Core Data Series](#nccs-core-data-series)
- [IRS 990 Efile Database](#irs-990-efile-database)
- [Form 990-N ePostcard](#form-990-n-epostcard)
- [Publication 78](#publication-78)
- [SOI Microdata](#soi-microdata)
- [Data Access Methods](#data-access-methods)

---

## Business Master File (BMF)

The BMF is the universe of all organizations granted tax-exempt status by the IRS. It serves as the primary sampling framework for nonprofit research.

### Overview

| Attribute | Value |
|-----------|-------|
| **Coverage** | ~3.8 million organizations (all-time) |
| **Active orgs** | ~1.8 million currently active |
| **Update frequency** | Monthly from IRS |
| **Time span** | NCCS Unified BMF: 1989-present |
| **File size** | ~1.3 GB (unified version) |

### Key Variables

| Variable | Description |
|----------|-------------|
| `EIN` | Employer Identification Number (9-digit unique ID) |
| `NAME` | Organization legal name |
| `ADDRESS`, `CITY`, `STATE`, `ZIP` | Location information |
| `NTEE_IRS` | Official IRS NTEE classification |
| `NTEE_NCCS` | NCCS-corrected NTEE code |
| `SUBSECCD` | IRS subsection code (03 = 501(c)(3), etc.) |
| `FNDNCD` | Foundation code (type of public charity/foundation) |
| `RULEDATE` | Date IRS granted tax-exempt status |
| `ACCPER` | Accounting period (fiscal year end month) |
| `INCOME_AMT` | Most recent reported gross receipts |
| `ASSET_AMT` | Most recent reported total assets |

### NCCS Unified BMF Enhancements

The NCCS Unified BMF adds:

- **Geocoded addresses**: Matched to Census Block level
- **Census FIPS codes**: State, county, tract identifiers
- **Metro area codes**: CBSA metropolitan/micropolitan definitions
- **First/last year indicators**: When organization appears in Core data
- **Historical record**: Includes inactive organizations removed from current IRS BMF

### Foundation Codes (FNDNCD)

| Code | Description |
|------|-------------|
| 00 | All organizations (most common) |
| 02 | Private operating foundation |
| 03 | Private non-operating foundation |
| 04 | Private non-operating foundation (4947(a)(1) trust) |
| 10 | Church (170(b)(1)(A)(i)) |
| 11 | School (170(b)(1)(A)(ii)) |
| 12 | Hospital (170(b)(1)(A)(iii)) |
| 13 | Government unit support org |
| 14 | Public safety testing organization |
| 15 | Publicly supported charity (170(b)(1)(A)(vi)) |
| 16 | Organization supporting public charities |
| 17 | Agricultural research organization |
| 21 | Publicly supported charity (509(a)(2)) |

**For higher education**: Most private colleges have FNDNCD = 11 (School) or 15/21 (publicly supported charity).

### Download

**Via Education Data Portal mirror (recommended for education research):**

```python
import polars as pl

# Download NCCS 990 data from Portal mirror
DATASET_PATH = "nccs/colleges_nccs_all"
nccs = fetch_from_mirrors(DATASET_PATH)

# Data is pre-filtered to higher education institutions matched to IPEDS
# Variables are lowercase (e.g., fips, unitid, contributions_total)
# 161 columns, 1993-2016, ~30K institution-year rows
```

**Direct download from NCCS (for BMF, Core, Efile — outside Portal):**

```python
import polars as pl

# BMF universe file (large — ~1.3 GB)
url = "https://nccsdata.s3.amazonaws.com/harmonized/bmf/unified/BMF_UNIFIED_V1.1.csv"
bmf = pl.read_csv(url)

# Filter to higher education by NTEE code (NOT available in Portal data)
higher_ed = bmf.filter(pl.col("NTEECC").str.starts_with("B4"))
```

> **Note:** The Portal mirror dataset contains NCCS Form 990 data matched to IPEDS institutions (~2,600 institutions). It does NOT include NTEE codes, BMF attributes, or the full nonprofit universe. For the full NCCS universe, NTEE-based filtering, or non-education nonprofits, download directly from NCCS.

---

## NCCS Core Data Series

The Core Data Series provides standardized financial information from Form 990 filings spanning 30+ years.

### Overview

| Attribute | Value |
|-----------|-------|
| **Coverage** | 990 and 990-EZ filers |
| **Time span** | 1989-2022 (ongoing) |
| **Variables** | ~150 (PZ) to ~300 (PC) |
| **Organizations per year** | ~200K (PC) to ~400K (PZ) |

### Data File Types

| Type | Form Scope | Description | Variable Count |
|------|------------|-------------|----------------|
| **PC** | Full 990 only | Larger organizations, more detail | ~300 |
| **PZ** | 990 + 990-EZ | Broader coverage, fewer variables | ~150 |
| **PF** | 990-PF | Private foundations only | ~200 |

### Organizational Scope

| Scope | Description |
|-------|-------------|
| **501C3-CHARITIES** | 501(c)(3) public charities (donations tax-deductible) |
| **501CE-NONPROFIT** | All other 501(c) types (c)(4), (c)(6), etc. |
| **PRIVATE-FOUNDATIONS** | 501(c)(3) private foundations (990-PF filers) |

### Key Financial Variables (Common)

| Variable | Description |
|----------|-------------|
| `TOTREV` | Total revenue |
| `TOTREV2` | Total revenue (alternative calculation) |
| `EXPS` | Total expenses |
| `TOTASS` | Total assets (end of year) |
| `TOTLIAB` | Total liabilities (end of year) |
| `NETASS` | Net assets (assets - liabilities) |
| `CONT` | Contributions and grants |
| `PROGREV` | Program service revenue |
| `DUES` | Membership dues |
| `INVINC` | Investment income |
| `OTHINC` | Other income |
| `GRSRCPTS` | Gross receipts |
| `FUNDSBAL` | Fund balance/net assets (beginning of year) |

### Key Financial Variables (PC Only)

| Variable | Description |
|----------|-------------|
| `COMPENS` | Compensation of officers, directors, etc. |
| `OTHSAL` | Other salaries and wages |
| `PAIDSRV` | Professional fees |
| `OCCUP` | Occupancy expenses |
| `TRAVEL` | Travel expenses |
| `CONF` | Conferences and meetings |
| `INTEREST` | Interest expense |
| `DEPREC` | Depreciation and depletion |
| `GRANTS` | Grants paid |
| `ALLOC` | Payments to affiliates |
| `FUNDFEES` | Fundraising fees |
| `SECUR` | Securities (investments) |
| `LANDBNB` | Land, buildings, equipment (net) |
| `RETEARN` | Retained earnings/endowment |

### File Organization

Files are named with convention: `SCOPE_FORMTYPE_YEAR.csv`

Example: `CHARITIES_PC_2021.csv` = 501(c)(3) charities, full 990 filers, 2021 tax year

### Download

**Via Education Data Portal mirror (recommended for education research):**

```python
import polars as pl

# NCCS data for higher education institutions
DATASET_PATH = "nccs/colleges_nccs_all"
nccs = fetch_from_mirrors(DATASET_PATH)

# Variables use Portal naming (lowercase, descriptive)
# e.g., contributions_total, prog_serv_rev, revenue_total
```

**Direct from NCCS (for full Core series — outside Portal):**

```python
import polars as pl

# NCCS provides a data catalog for browsing
# https://urbaninstitute.github.io/nccs/catalogs/catalog-core.html

# Individual year download
url = "https://nccsdata.s3.amazonaws.com/harmonized/core/CHARITIES_PC_2021.csv"
core_pc = pl.read_csv(url)
```

---

## IRS 990 Efile Database

The most comprehensive source with 2000+ fields from electronic filings.

### Overview

| Attribute | Value |
|-----------|-------|
| **Coverage** | Electronic filers (mandatory for large orgs since 2022) |
| **Time span** | 2012-present |
| **Variables** | 2000+ fields across forms and schedules |
| **Format** | XML → converted to relational tables |

### Coverage Growth

| Year | 990 | 990EZ | 990PF | 990T |
|------|-----|-------|-------|------|
| 2012 | 179,688 | 93,750 | 39,933 | 0 |
| 2015 | 233,519 | 124,894 | 58,815 | 0 |
| 2019 | 284,515 | 152,689 | 87,790 | 0 |
| 2022 | 348,034 | 205,532 | 122,533 | 22,611 |

**Note**: E-filing became mandatory in 2022, so coverage is now comprehensive.

### Data Organization

Efile data is organized into 126 relational tables corresponding to Form 990 sections:

| Table Category | Examples |
|----------------|----------|
| **Header** | Basic org info, tax year, form type |
| **Part I** | Summary (revenue, expenses, assets) |
| **Part VII** | Compensation (officers, directors, employees) |
| **Part VIII** | Statement of Revenue |
| **Part IX** | Statement of Functional Expenses |
| **Part X** | Balance Sheet |
| **Schedule A** | Public Charity Status |
| **Schedule D** | Supplemental Financials (endowment) |
| **Schedule J** | Compensation Information |
| **Schedule R** | Related Organizations |

### Variable Naming Convention

Variables use a standardized prefix: `XX_XX_XX_NAME`

| Position | Meaning | Examples |
|----------|---------|----------|
| 1-2 | Form | F9 (990), SA-SR (Schedules A-R) |
| 4-5 | Scope | PC, EZ, PZ, PF, HD (header) |
| 7-8 | Part/Location | 01-12 (Part I-XII), 00 (header) |
| 10+ | Variable name | Descriptive name |

Example: `F9_PC_08_TOTREV` = Form 990, Full 990 filers, Part VIII, Total Revenue

### Access via R Package (Direct NCCS, Not Portal)

```r
# Install the irs990efile package
# devtools::install_github("Nonprofit-Open-Data-Collective/irs990efile")

library(irs990efile)

# Get data for specific organizations by EIN
data <- get_990_data(ein = c("123456789", "987654321"), year = 2021)
```

---

## Form 990-N ePostcard

Small nonprofits (under $50K gross receipts) file Form 990-N, a minimal electronic filing.

### Overview

| Attribute | Value |
|-----------|-------|
| **Eligibility** | Gross receipts normally ≤ $50,000 |
| **Information collected** | Name, EIN, address, website, principal officer, tax year |
| **What's missing** | All financial data |

### Key Points

- **Not in Core data**: 990-N filers excluded from Core series (no financial disclosure)
- **Important for research design**: Many grassroots organizations (PTAs, little leagues, block associations) file only 990-N
- **Compliance tracking**: Filing 990-N maintains tax-exempt status

### Download

Available from NCCS: https://nccs.urban.org/nccs/datasets/postcard/

---

## Publication 78

IRS Publication 78 lists organizations eligible to receive tax-deductible charitable contributions.

### Overview

| Attribute | Value |
|-----------|-------|
| **Purpose** | Verify charitable donation eligibility |
| **Content** | Name, city, state, EIN, deductibility code |
| **Update** | Monthly |

### Use Cases

- Verify an organization's current tax-exempt status
- Identify organizations that have lost exempt status
- Sampling frame for 501(c)(3) public charities

---

## SOI Microdata

Statistics of Income (SOI) Division extracts from IRS administrative files.

### Overview

The SOI produces statistical samples and extracts used for official IRS statistics on exempt organizations. NCCS provides access to historical SOI extract files.

| Attribute | Value |
|-----------|-------|
| **Source** | IRS Statistics of Income Division |
| **Sample** | Stratified by asset size |
| **Variables** | Curated financial measures |

### Historical Context

Before the Efile era, SOI extracts were the primary source of 990 data for researchers. The NCCS Core files were built from these extracts combined with paper filing digitization.

---

## Data Access Methods

### Education Data Portal Mirror (Recommended for Education Research)

The Portal mirror provides NCCS data for higher education institutions in parquet format. See `datasets-reference.md` for the canonical path, `mirrors.yaml` for mirror configuration, and `fetch-patterns.md` for the `fetch_from_mirrors()` function.

```python
import polars as pl

# NCCS Form 990 data for colleges/universities
DATASET_PATH = "nccs/colleges_nccs_all"
nccs = fetch_from_mirrors(DATASET_PATH)

# Data is pre-matched to IPEDS UNITID
# Covers 1993-2016 (24 years)
# ~30K institution-year observations, 161 columns
```

**Important:** Portal data uses integer encodings for categorical variables:
- `fips`: Integer state FIPS codes (1-78, including territories); no -1/-2/-3 codes observed
- `mult_ein_flag`: 0 (No) or 1 (Yes)
- All variable names are lowercase
- NTEE codes, SUBSECCD, and FNDNCD are NOT included (data is pre-filtered to higher ed)

### Direct NCCS Download (For Full Nonprofit Universe)

Most NCCS data is available as CSV files from AWS S3:

```
Base URL: https://nccsdata.s3.amazonaws.com/
```

### Data Catalogs

- **Core Series**: https://urbaninstitute.github.io/nccs/catalogs/catalog-core.html
- **BMF by State**: https://urbaninstitute.github.io/nccs/catalogs/catalog-bmf.html
- **Efile**: https://urbaninstitute.github.io/nccs/catalogs/catalog-efile-v2_1.html

### Sector in Brief Dashboard

Interactive dashboard for exploring and downloading nonprofit data with filtering:

https://nccs-urban.shinyapps.io/sector-in-brief/

### R Package: nccsdata

> **Note:** The `get_data()` function in R downloads directly from NCCS, not from the Education Data Portal mirrors. For Portal-based research, use the `fetch_from_mirrors()` approach above. The R package provides access to the full NCCS universe including BMF, Core, and Efile data with NTEE codes.

```r
# devtools::install_github("UrbanInstitute/nccsdata")
library(nccsdata)

# Download Core data with filters (direct from NCCS, not Portal)
data <- get_data(
  geo_scope = "state",
  geo_code = "CA",
  ntee_scope = "B",  # Education
  years = 2018:2021
)
```

### GitHub Repository

Code, documentation, and data processing scripts:

https://github.com/UrbanInstitute/nccs

---

## Recommended Dataset by Research Need

| Research Need | Recommended Dataset |
|---------------|---------------------|
| Identify universe of nonprofits | BMF |
| Historical financial trends | Core PZ (broad) or PC (detailed) |
| Governance and compensation | Efile |
| Private foundation grants | Core PF or Efile 990-PF |
| Geographic analysis | BMF (geocoded) + Census crosswalks |
| Maximum variable detail | Efile |
| Quick sampling frame | BMF or Pub78 |
| Small grassroots organizations | 990-N ePostcard |

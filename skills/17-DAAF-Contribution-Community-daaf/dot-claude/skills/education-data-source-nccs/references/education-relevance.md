# NCCS Data for Higher Education Research

This reference explains how NCCS nonprofit data relates to higher education institutions and how to use it to supplement traditional education data sources like IPEDS.

## Contents

- [Private Nonprofit Colleges as 501(c)(3) Organizations](#private-nonprofit-colleges-as-501c3-organizations)
- [What NCCS Adds to Education Research](#what-nccs-adds-to-education-research)
- [Identifying Higher Education Institutions](#identifying-higher-education-institutions)
- [Linking NCCS to IPEDS](#linking-nccs-to-ipeds)
- [Key Research Applications](#key-research-applications)
- [Data Comparability Considerations](#data-comparability-considerations)
- [Example Queries](#example-queries)

---

## Private Nonprofit Colleges as 501(c)(3) Organizations

Private nonprofit colleges and universities operate as tax-exempt organizations under IRS Section 501(c)(3). This status:

- **Exempts** them from federal income tax
- **Allows** donors to deduct contributions
- **Requires** annual Form 990 filing (or 990-N for very small schools)

### Organizational Structure

Most private colleges are classified as:
- **IRS Subsection**: 501(c)(3)
- **Foundation Code**: 11 (School under 170(b)(1)(A)(ii)) or 15/21 (publicly supported)
- **NTEE Codes**: B40-B50 (higher education)

### What's Included in NCCS

| Institution Type | In NCCS? | Notes |
|------------------|----------|-------|
| Private nonprofit 4-year colleges | Yes | Full 990 filers (most) |
| Private nonprofit universities | Yes | Often file consolidated 990 |
| Private 2-year colleges | Yes | Full 990 or 990-EZ |
| Public colleges/universities | No | Government entities, don't file 990 |
| For-profit colleges | No | File corporate tax returns, not 990 |
| Religious colleges | Mixed | Some file 990, some claim church exemption |

### Important Exclusions

**Public institutions** (state universities, community colleges) are not in NCCS because:
- They are government instrumentalities
- They don't file Form 990
- Use IPEDS exclusively for these institutions

**For-profit institutions** are not in NCCS because:
- They are taxable corporations
- They file Form 1120 (corporate tax return), not 990

---

## What NCCS Adds to Education Research

NCCS provides data not available through IPEDS:

### Financial Depth

| Data Element | NCCS (990) | IPEDS |
|--------------|------------|-------|
| Endowment details | Schedule D Part V | Summary totals only |
| Investment income breakdown | Part VIII | Limited |
| Fundraising expenses | Part IX column D | Not separated |
| Functional expense allocation | Full breakdown | Different categories |
| Executive compensation | Part VII, Schedule J | Aggregated only |
| Related party transactions | Schedule L | Not collected |
| Debt details | Part X | Limited |

### Governance Information

| Data Element | NCCS (990) | IPEDS |
|--------------|------------|-------|
| Board size | Part VI | Not collected |
| Board independence | Part VI | Not collected |
| Conflict of interest policy | Part VI | Not collected |
| CEO compensation review | Part VI | Not collected |
| Individual board members | Part VII | Not collected |
| Key employee compensation | Part VII | Not collected |

### Organizational Context

| Data Element | NCCS (990) | IPEDS |
|--------------|------------|-------|
| Related organizations | Schedule R | Limited |
| Mission statement | Part III | Not collected |
| Program descriptions | Part III | Different format |
| Affiliations | Schedule R | Not collected |

---

## Identifying Higher Education Institutions

### Using NTEE Codes

Filter NCCS data by education NTEE codes:

| Code | Description | Examples |
|------|-------------|----------|
| B40 | Higher Education Institutions (General) | Small colleges |
| B41 | Two-Year Colleges | Private community colleges |
| B42 | Undergraduate Colleges | Liberal arts colleges |
| B43 | Universities | Research universities |
| B50 | Graduate/Professional Schools | Law schools, medical schools |

### NTEEV2 Format

In the newer NTEEV2 format, higher education is tagged:

```
UNI - Universities (B40, B41, B42, B43, B50)
```

This makes filtering easier (full NCCS data only, not Portal):
```python
import polars as pl

# Filter for universities using NTEEV2 industry group
universities = df.filter(pl.col("NTEE_V2").str.starts_with("UNI-"))
```

### Using Foundation Code

Many colleges have foundation code 11 (School):
```python
import polars as pl

# Schools under 170(b)(1)(A)(ii) — full NCCS BMF data only
schools = bmf.filter(pl.col("FNDNCD") == "11")
```

### Filtering Strategy

> **Note:** These filters apply to **full NCCS BMF/Core data**, not the Portal dataset. The Portal dataset (`nccs/colleges_nccs_all`) is already pre-filtered to higher education institutions matched to IPEDS UNITIDs — no NTEE filtering needed.

Recommended approach for full NCCS data:
```python
import polars as pl

# Step 1: Filter by NTEE
higher_ed = bmf.filter(pl.col("NTEECC").str.contains(r"^B4[0-9]|^B50"))

# Step 2: Verify 501(c)(3) status
higher_ed = higher_ed.filter(pl.col("SUBSECCD") == "03")

# Step 3: Exclude tiny organizations (likely support orgs, not colleges)
higher_ed = higher_ed.filter(pl.col("INCOME_AMT") > 1_000_000)  # >$1M revenue
```

---

## Linking NCCS to IPEDS

### Identifier Mapping

| System | Identifier | Format |
|--------|------------|--------|
| NCCS/IRS | EIN | 9-digit number (e.g., 123456789) |
| IPEDS | UNITID | 6-digit number (e.g., 110635) |

There is **no official crosswalk** between EIN and UNITID. Linking requires:

### Linking Methods

**1. Portal Dataset (Pre-linked)**

The Portal dataset already includes `unitid` for IPEDS matching. No fuzzy matching needed:

```python
import polars as pl

# Portal data already has unitid
nccs = fetch_from_mirrors("nccs/colleges_nccs_all")
ipeds = fetch_from_mirrors("ipeds/colleges_ipeds_directory")

# Direct join on unitid and year
combined = nccs.join(
    ipeds.select(["unitid", "year", "inst_name", "sector"]),
    on=["unitid", "year"],
    how="left"
)
```

**2. Full NCCS Data (Fuzzy Matching Required)**

When working with the full NCCS universe (outside Portal), linking requires fuzzy name/location matching since there is no official EIN-UNITID crosswalk:

```python
# Fuzzy matching on name and location (uses rapidfuzz or fuzzywuzzy)
from rapidfuzz import fuzz

# This is inherently row-level work; consider converting to pandas for iterrows()
# or use Polars with map_elements for small datasets
```

**3. Address Matching**

Use geocoded addresses to narrow matches:
```python
import polars as pl

# Match on city + state first, then name (full NCCS data)
same_location = ipeds_df.filter(
    (pl.col("CITY") == nccs_city) &
    (pl.col("STABBR") == nccs_state)
)
```

**3. Published Crosswalks**

Some researchers have created EIN-UNITID crosswalks:
- Check data repositories (ICPSR, Dataverse)
- Academic publications with supplementary data
- ProPublica Nonprofit Explorer (sometimes includes IPEDS match)

### Linking Challenges

| Challenge | Description | Mitigation |
|-----------|-------------|------------|
| **Name variations** | "University of X" vs "X University" | Fuzzy matching, standardization |
| **Multiple EINs** | University systems with separate EINs | Identify parent organization |
| **Consolidated filings** | One 990 for entire system | Map to multiple UNITIDs |
| **Support organizations** | Foundations, athletics, etc. | Filter by NTEE, revenue size |
| **Name changes** | Mergers, rebranding | Check historical names |

### Related Organizations

Many universities have multiple EINs for:
- Main institution
- Foundation/development office
- Hospital/medical center
- Athletic association
- Alumni association

Schedule R of Form 990 lists related organizations.

---

## Key Research Applications

### 1. Executive Compensation Studies

NCCS provides individual-level compensation data:

```python
# Get compensation for college presidents
# Use Efile Part VII or Schedule J data

compensation = efile_partVII[
    efile_partVII['TITLE'].str.contains('President|Chancellor', case=False)
]
```

**Research questions**:
- How does president pay vary by institution size?
- Is there a relationship between endowment size and compensation?
- How has executive pay changed over time?

### 2. Endowment Analysis

Schedule D provides endowment details not in IPEDS:

```python
# Endowment data from Schedule D Part V
endowment_cols = [
    'F9_SD_05_ENDOWMENT_BOY',      # Beginning balance
    'F9_SD_05_ENDOWMENT_CONTRIB',   # Contributions
    'F9_SD_05_ENDOWMENT_INVEST',    # Investment return
    'F9_SD_05_ENDOWMENT_GRANTS',    # Grants/scholarships
    'F9_SD_05_ENDOWMENT_ADMIN',     # Admin expenses
    'F9_SD_05_ENDOWMENT_EOY'        # Ending balance
]
```

**Research questions**:
- What is the endowment spending rate?
- How much comes from new gifts vs. investment returns?
- How do administrative costs compare across institutions?

### 3. Governance Research

NCCS uniquely provides governance data:

```python
# Governance indicators from Part VI
governance_vars = [
    'F9_PC_06_VOTING_MEMBERS',          # Board size
    'F9_PC_06_INDEP_VOTING_MEMBERS',    # Independent members
    'F9_PC_06_FAMILY_RELATIONSHIP',     # Family on board
    'F9_PC_06_CONFLICT_POLICY',         # COI policy
    'F9_PC_06_WHISTLEBLOWER',           # Whistleblower policy
    'F9_PC_06_CEO_COMP_REVIEW'          # CEO comp reviewed
]
```

**Research questions**:
- Does board composition affect institutional outcomes?
- Do governance practices correlate with financial health?
- How do governance structures vary by institution type?

### 4. Financial Efficiency Studies

Functional expense allocation enables efficiency analysis:

```python
# Calculate fundraising efficiency
df['fundraising_ratio'] = (
    df['F9_PC_09_FUNC_EXP_FUNDRAISING'] / 
    df['F9_PC_08_CONTRIBUTIONS']
)

# Program expense ratio
df['program_ratio'] = (
    df['F9_PC_09_FUNC_EXP_PROGRAM'] / 
    df['F9_PC_09_FUNC_EXP_TOTAL']
)
```

### 5. Related Party Analysis

Schedule L and R reveal related party transactions:

**Research questions**:
- What is the relationship between college and affiliated foundation?
- How are hospital revenues reflected in university finances?
- Do athletics generate net revenue or costs?

---

## Data Comparability Considerations

### NCCS vs. IPEDS Financial Differences

| Item | Form 990 | IPEDS |
|------|----------|-------|
| **Accounting basis** | Tax reporting (modified cash or accrual) | GAAP, GASB, or FASB |
| **Consolidation** | Varies | Full consolidation |
| **Fiscal year** | Tax year (may differ) | Institution fiscal year |
| **Revenue categories** | IRS-defined | Education-specific |
| **Expense categories** | Functional (program/admin/fundraising) | Natural + functional |

### Common Discrepancies

**Total revenue differences**:
- IPEDS includes unrealized investment gains; 990 may not
- IPEDS may consolidate hospital; 990 may be separate
- Timing differences if fiscal years don't align

**Expense differences**:
- 990 requires functional allocation (program/admin/fundraising)
- IPEDS uses education-specific categories (instruction, research, etc.)
- Depreciation treatment may differ

### Reconciliation Tips

1. **Check fiscal year ends**: Ensure comparing same time periods
2. **Identify consolidation scope**: Review Schedule R for related orgs
3. **Note accounting method**: Part XII indicates cash vs. accrual
4. **Compare to audited financials**: Often available on institution websites

---

## Example Queries

### Using Education Data Portal

**Get NCCS Data for Higher Education:**

```python
import polars as pl

# Load NCCS data via unified mirror system
DATASET_PATH = "nccs/colleges_nccs_all"
nccs = fetch_from_mirrors(DATASET_PATH)

# Filter to California (FIPS = 6) - note: integer codes!
ca_institutions = nccs.filter(pl.col("fips") == 6)

# Get latest year data
latest = nccs.filter(pl.col("year") == nccs["year"].max())

# Financial summary
print(f"Total Revenue: ${latest['revenue_total'].mean():,.0f}")
print(f"Total Assets: ${latest['total_assets_eoy'].mean():,.0f}")
```

**Join with IPEDS:**

```python
import polars as pl

# NCCS data includes unitid for IPEDS matching
NCCS_PATH = "nccs/colleges_nccs_all"
nccs = fetch_from_mirrors(NCCS_PATH)

# IPEDS directory for institution names
IPEDS_PATH = "ipeds/colleges_ipeds_directory"
ipeds = fetch_from_mirrors(IPEDS_PATH)

# Join on unitid and year
combined = nccs.join(
    ipeds.select(["unitid", "year", "inst_name", "sector"]),
    on=["unitid", "year"],
    how="left"
)
```

### Using Direct NCCS Data

> **Note:** These examples use full NCCS data downloaded directly (not the Portal mirror). Variable names are UPPERCASE. For Portal data, use the lowercase Portal variable names shown in the "Using Education Data Portal" section above.

**Find All Private Universities in a State:**

```python
import polars as pl

# Load BMF
bmf = pl.read_csv("BMF_UNIFIED_V1.1.csv")

# Filter to California private universities
ca_universities = bmf.filter(
    (pl.col("STATE") == "CA") &
    (pl.col("SUBSECCD") == "03") &  # 501(c)(3)
    (pl.col("NTEECC").str.contains(r"^B4[0-3]")) &
    (pl.col("INCOME_AMT") > 1_000_000)  # Revenue > $1M
)

print(f"Found {ca_universities.height} private universities in California")
```

**Get Financial Data for a Specific Institution:**

```python
# Find Stanford University
stanford = bmf.filter(pl.col("NAME").str.contains("(?i)STANFORD UNIVERSITY"))
stanford_ein = stanford["EIN"][0]

# Load Core data
core = pl.read_csv("CHARITIES_PC_2021.csv")
stanford_990 = core.filter(pl.col("EIN") == stanford_ein)

print(f"Total Revenue: ${stanford_990['TOTREV'][0]:,.0f}")
print(f"Total Assets: ${stanford_990['TOTASS'][0]:,.0f}")
```

**Compare Endowments Across Institutions:**

```python
# Load Efile Schedule D data
sched_d = pl.read_csv("efile_schedule_d_part_v.csv")

# Join with BMF for institution names
endowments = sched_d.join(
    bmf.select(["EIN", "NAME", "STATE"]),
    on="EIN"
)

# Filter to higher ed
endowments = endowments.filter(pl.col("EIN").is_in(ca_universities["EIN"]))

# Sort by endowment size
endowments = endowments.sort("ENDOWMENT_EOY", descending=True)
```

**Analyze Executive Compensation:**

```python
# Load Part VII compensation data
part_vii = pl.read_csv("efile_part_vii.csv")

# Filter to presidents/chancellors at universities
presidents = part_vii.filter(
    (pl.col("TITLE").str.contains("(?i)President|Chancellor")) &
    (pl.col("EIN").is_in(higher_ed["EIN"]))
)

# Calculate total compensation
presidents = presidents.with_columns(
    (pl.col("BASE_COMP") + pl.col("BONUS") + pl.col("OTHER_COMP")
     + pl.col("DEFERRED_COMP") + pl.col("NONTAXABLE"))
    .alias("TOTAL_COMP")
)

# Summary statistics
print(presidents["TOTAL_COMP"].describe())
```

---

## Best Practices

### For Linking to IPEDS

1. Start with known institutions to validate matching approach
2. Use multiple matching criteria (name + location + size)
3. Manually verify matches for key institutions
4. Document matching methodology and success rate
5. Note unmatched institutions and potential reasons

### For Financial Analysis

1. Always check fiscal year alignment
2. Verify consolidation scope using Schedule R
3. Compare to audited financials when available
4. Account for form version changes (pre-2008 vs. post-2008)
5. Use multiple years to identify outliers/errors

### For Governance Research

1. Note that governance questions were added in 2008 redesign
2. Board composition data is self-reported
3. Policy existence doesn't indicate implementation quality
4. Compare across similar institution types

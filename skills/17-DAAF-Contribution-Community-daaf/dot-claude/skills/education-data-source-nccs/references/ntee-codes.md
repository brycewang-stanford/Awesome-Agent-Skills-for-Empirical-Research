# NTEE Codes: Nonprofit Classification System

The National Taxonomy of Exempt Entities (NTEE) is the classification system used by the IRS and NCCS to categorize nonprofit organizations by their mission and activities.

## Contents

- [NTEE Overview](#ntee-overview)
- [NTEE Structure](#ntee-structure)
- [Major Groups](#major-groups)
- [Education Codes (B)](#education-codes-b)
- [NTEEV2: Updated Format](#nteev2-updated-format)
- [Code Accuracy and Limitations](#code-accuracy-and-limitations)
- [Selecting and Changing NTEE Codes](#selecting-and-changing-ntee-codes)
- [Alternative Taxonomies](#alternative-taxonomies)

---

## NTEE Overview

The NTEE system was developed by NCCS in the late 1980s to provide a standardized classification for nonprofit organizations. It replaced the earlier IRS Activity Code system.

### Key Characteristics

| Aspect | Description |
|--------|-------------|
| **Purpose** | Descriptive taxonomy for statistical analysis |
| **Maintained by** | IRS (official), NCCS (enhanced version) |
| **Format** | Letter + 2-digit number (e.g., B42) |
| **Categories** | 10 major groups, ~400 specific codes |
| **Assignment** | Self-selected or IRS-assigned |

### Important Caveat

NTEE codes are **descriptive**, not **prescriptive**:
- They categorize organizations for analysis purposes
- They do NOT restrict what activities an organization can conduct
- Many organizations have missions spanning multiple categories
- ~25% of codes are estimated to be imprecise

**Do not** use NTEE codes as the sole criterion for:
- Excluding organizations from funding consideration
- Determining eligibility for programs
- Making definitive statements about an organization's activities

---

## NTEE Structure

### Basic Format

```
X00  Major group default
X01  Alliance/Advocacy Organizations
X02  Management and Technical Assistance
X03  Professional Societies, Associations
X05  Research Institutes and/or Public Policy Analysis
X11  Monetary Support - Single Organization
X12  Monetary Support - Multiple Organizations
X19  Nonmonetary Support Not Elsewhere Classified (N.E.C.)
X20+ Specific activity codes within group
```

### Common Codes (01-19)

Codes 01-19 represent organizational types that exist across all major groups:

| Code Suffix | Organizational Type |
|-------------|---------------------|
| 01 | Alliance/Advocacy Organizations |
| 02 | Management and Technical Assistance |
| 03 | Professional Societies, Associations |
| 05 | Research Institutes and/or Public Policy Analysis |
| 11 | Monetary Support - Single Organization (e.g., "Friends of...") |
| 12 | Monetary Support - Multiple Organizations |
| 19 | Nonmonetary Support N.E.C. |

**Example**: B01 = Education alliance/advocacy; E01 = Health alliance/advocacy

---

## Major Groups

| Letter | Major Group | Examples |
|--------|-------------|----------|
| **A** | Arts, Culture, and Humanities | Museums, performing arts, historical societies |
| **B** | Education | Schools, colleges, libraries, educational support |
| **C** | Environment and Animals | Conservation, zoos, animal welfare |
| **D** | Animal-Related | (Merged with C in some versions) |
| **E** | Health | Hospitals, clinics, health support |
| **F** | Mental Health, Crisis Intervention | Mental health centers, addiction services |
| **G** | Diseases, Disorders, Medical Disciplines | Disease-specific organizations |
| **H** | Medical Research | Research institutes |
| **I** | Crime, Legal Related | Legal aid, crime prevention |
| **J** | Employment, Job Related | Vocational training, employment services |
| **K** | Food, Agriculture, and Nutrition | Food banks, agricultural organizations |
| **L** | Housing, Shelter | Housing development, homeless shelters |
| **M** | Public Safety | Disaster relief, emergency services |
| **N** | Recreation, Sports, Leisure, Athletics | Sports leagues, recreation programs |
| **O** | Youth Development | Youth organizations, scouts, mentoring |
| **P** | Human Services | Multi-purpose social services |
| **Q** | International, Foreign Affairs | International development, relief |
| **R** | Civil Rights, Social Action, Advocacy | Civil liberties, voter education |
| **S** | Community Improvement, Capacity Building | Community foundations, neighborhood groups |
| **T** | Philanthropy, Voluntarism, Grantmaking | Private foundations, donor-advised funds |
| **U** | Science and Technology | Science museums, research |
| **V** | Social Science | Think tanks, policy research |
| **W** | Public, Society Benefit | Government-related, consumer protection |
| **X** | Religion Related | Churches, religious education |
| **Y** | Mutual/Membership Benefit | Fraternal organizations, cemeteries |
| **Z** | Unknown, Unclassified | Organizations not otherwise classified |

---

## Education Codes (B)

The B major group covers educational organizations:

### B01-B19: Common Codes (Education Sector)

| Code | Description |
|------|-------------|
| B01 | Alliance/Advocacy Organizations (Education) |
| B02 | Management and Technical Assistance |
| B03 | Professional Societies, Associations |
| B05 | Research Institutes and/or Public Policy Analysis |
| B11 | Single Organization Support |
| B12 | Fund Raising and/or Fund Distribution |
| B19 | Nonmonetary Support N.E.C. |

### B20-B29: Elementary and Secondary Education

| Code | Description |
|------|-------------|
| B20 | Elementary, Secondary Education (General) |
| B21 | Preschool Programs |
| B24 | Primary, Elementary Schools |
| B25 | Secondary, High Schools |
| B28 | Specialized Education Institutions |
| B29 | Charter Schools |

### B30-B39: Vocational and Technical Schools

| Code | Description |
|------|-------------|
| B30 | Vocational, Technical Schools |

### B40-B50: Higher Education

| Code | Description | Examples |
|------|-------------|----------|
| **B40** | Higher Education Institutions (General) | Small colleges, general |
| **B41** | Two-Year Colleges | Private community colleges |
| **B42** | Undergraduate Colleges | Four-year liberal arts colleges |
| **B43** | Universities | Research universities |
| **B50** | Graduate, Professional Schools | Law schools, medical schools, business schools (standalone) |

### B60-B69: Adult and Continuing Education

| Code | Description |
|------|-------------|
| B60 | Adult, Continuing Education |

### B70-B79: Libraries

| Code | Description |
|------|-------------|
| B70 | Libraries |

### B80-B89: Student Services and Organizations

| Code | Description |
|------|-------------|
| B80 | Student Services, Organizations of Students |
| B82 | Scholarships, Student Financial Aid |
| B83 | Student Sororities, Fraternities |
| B84 | Alumni Associations |

### B90-B99: Educational Services

| Code | Description |
|------|-------------|
| B90 | Educational Services and Schools - Other |
| B92 | Remedial Reading, Encouragement |
| B94 | Parent/Teacher Group |
| B99 | Education N.E.C. |

---

## NTEEV2: Updated Format

NCCS developed NTEEV2 (NTEE Version 2.0) to improve the taxonomy for data analysis.

### Changes from Original NTEE

| Aspect | Original NTEE | NTEEV2 |
|--------|---------------|--------|
| Format | Letter + 2 digits (B42) | Industry-Code-Type (EDU-B42-RG) |
| Org type | Mixed into code | Explicit suffix |
| Industry | Implied by letter | Explicit prefix |
| Readability | Requires lookup | More self-documenting |

### NTEEV2 Structure

```
XXX-Xxx-XX
│   │   └── Organizational Type (2 letters)
│   └────── NTEE Code (letter + 2 digits)
└────────── Industry Group (3 letters)
```

### Industry Group Prefixes

| Prefix | Industry | Original Letters |
|--------|----------|------------------|
| ART | Arts, Culture, Humanities | A |
| EDU | Education (excluding universities) | B (excluding B40-B50) |
| UNI | Universities | B40, B41, B42, B43, B50 |
| ENV | Environment and Animals | C, D |
| HEL | Health (excluding hospitals) | E, F, G, H (excluding E20-E24) |
| HOS | Hospitals | E20, E21, E22, E24 |
| HMS | Human Services | I, J, K, L, M, N, O, P |
| IFA | International, Foreign Affairs | Q |
| PSB | Public, Societal Benefit | R, S, T, U, V, W |
| REL | Religion Related | X |
| MMB | Mutual/Membership Benefit | Y |
| UNU | Unknown, Unclassified | Z |

### Organizational Type Suffixes

| Suffix | Type | Original Code |
|--------|------|---------------|
| RG | Regular Nonprofit | Default (no suffix) |
| AA | Alliance/Advocacy | 01 |
| MT | Management and Technical Assistance | 02 |
| PA | Professional Societies/Associations | 03 |
| RP | Research Institutes/Public Policy | 05 |
| MS | Monetary Support - Single | 11 |
| MM | Monetary Support - Multiple | 12 |
| NS | Nonmonetary Support N.E.C. | 19 |

### Example Conversions

| Original | NTEEV2 | Description |
|----------|--------|-------------|
| B42 | EDU-B42-RG | Undergraduate college (regular) |
| B43 | UNI-B43-RG | University (regular) |
| B01 | EDU-B00-AA | Education advocacy organization |
| B82 | EDU-B82-RG | Scholarship organization |
| B11 | EDU-B00-MS | Education support (single org) |

### Filtering with NTEEV2

> **Note:** NTEEV2 is available in full NCCS data, not in the Portal mirror dataset.

```python
import polars as pl

# Filter for all universities
universities = df.filter(pl.col("NTEE_V2").str.starts_with("UNI-"))

# Filter for hospitals
hospitals = df.filter(pl.col("NTEE_V2").str.starts_with("HOS-"))

# Filter for advocacy organizations in any sector
advocacy = df.filter(pl.col("NTEE_V2").str.ends_with("-AA"))

# Filter for education sector (excluding universities)
education = df.filter(pl.col("NTEE_V2").str.starts_with("EDU-"))
```

---

## Code Accuracy and Limitations

### Sources of Inaccuracy

**~25% of NTEE codes are estimated to be incomplete or inaccurate.**

| Source | Description |
|--------|-------------|
| **Self-selection** | New organizations choose their own code during 1023 filing |
| **IRS assignment** | IRS officers assign based on limited application info |
| **Historical conversion** | Pre-NTEE Activity Codes converted via crosswalk |
| **Mission evolution** | Organizations change focus but code remains |
| **Multi-mission orgs** | Single code can't capture multiple activities |

### Two NTEE Variables in NCCS Data

| Variable | Description |
|----------|-------------|
| `NTEE_IRS` | Official code from IRS records |
| `NTEE_NCCS` | NCCS-corrected code (may differ) |

The `NTEE_NCCS` variable reflects manual corrections made by NCCS staff over time, but should be considered a research-quality estimate, not an official designation.

### Best Practices

1. **Don't rely solely on NTEE** for critical research decisions
2. **Verify key organizations** manually when possible
3. **Use multiple filters** (NTEE + size + foundation code + name)
4. **Consider mission statements** from Part III for verification
5. **Document NTEE limitations** in research methodology

---

## Selecting and Changing NTEE Codes

### For Organizations Filing Form 1023

When applying for 501(c)(3) status, organizations:
1. Review NTEE code descriptions
2. Select the code that best fits their primary mission
3. IRS may accept or modify the selection

### Requesting a Change

Per IRS Publication 557:

> Organizations wishing to modify their NTEE code should send a written request to:

```
Internal Revenue Service
Attn: Correspondence Unit
P.O. Box 2508, Room 6403
Cincinnati, Ohio 45201
```

Include:
- Current NTEE code (if known)
- Requested code
- Explanation of why the change is appropriate
- Who originally selected the current code (if known)

### NCCS Role

**NCCS does NOT:**
- Assign official NTEE codes
- Have authority to change IRS records
- Process code change requests

**NCCS does:**
- Maintain enhanced `NTEE_NCCS` variable for research
- Provide documentation and resources
- Develop improvements like NTEEV2

---

## Alternative Taxonomies

### IRS Activity Codes (Historical)

Used before NTEE (pre-1995). Organizations had up to 3 activity codes.

NCCS provides a [crosswalk from Activity Codes to NTEE](https://github.com/Nonprofit-Open-Data-Collective/irs-exempt-org-business-master-file#activity-codes).

### Philanthropy Classification System (PCS)

Developed by Candid (Foundation Center + GuideStar):
- Covers both nonprofits and grants
- Includes population/beneficiary codes
- Includes auspice codes (religious, government affiliation)

[PCS Documentation](https://taxonomy.candid.org/)

### North American Industry Classification System (NAICS)

Generic industry taxonomy used for economic analysis:
- More granular in some areas
- Used by Census Bureau and BLS
- NCCS provides [NTEE-NAICS crosswalk](https://nccs.urban.org/nccs/widgets/ntee_tables/ntee-naics_table.html)

### ICNPO Codes

International Classification of Nonprofit Organizations:
- Developed for cross-national comparison
- Less detailed than NTEE
- Useful for international research

---

## Quick Reference: Education NTEE Codes

| Code | Description | NTEEV2 |
|------|-------------|--------|
| B20 | Elementary/Secondary General | EDU-B20-RG |
| B21 | Preschool | EDU-B21-RG |
| B24 | Elementary Schools | EDU-B24-RG |
| B25 | High Schools | EDU-B25-RG |
| B28 | Special Education | EDU-B28-RG |
| B29 | Charter Schools | EDU-B29-RG |
| B30 | Vocational/Technical | EDU-B30-RG |
| B40 | Higher Ed General | UNI-B40-RG |
| B41 | Two-Year Colleges | UNI-B41-RG |
| B42 | Four-Year Colleges | UNI-B42-RG |
| B43 | Universities | UNI-B43-RG |
| B50 | Graduate/Professional Schools | UNI-B50-RG |
| B60 | Adult/Continuing Ed | EDU-B60-RG |
| B70 | Libraries | EDU-B70-RG |
| B80 | Student Services | EDU-B80-RG |
| B82 | Scholarships | EDU-B82-RG |
| B83 | Sororities/Fraternities | EDU-B83-RG |
| B84 | Alumni Associations | EDU-B84-RG |
| B90 | Educational Services | EDU-B90-RG |
| B99 | Education N.E.C. | EDU-B99-RG |

### Filtering Examples

> **Important:** NTEE codes are NOT included in the Portal dataset (`nccs/colleges_nccs_all`), which is already pre-filtered to higher education institutions. The filtering examples below apply to the **full NCCS BMF/Core data** downloaded directly from NCCS.

```python
import polars as pl

# --- Full NCCS data (NOT Portal) ---

# All higher education (B40-B50)
higher_ed = df.filter(pl.col("NTEECC").str.contains(r"^B4[0-9]|^B50"))

# Just universities (B43)
universities = df.filter(pl.col("NTEECC") == "B43")

# All K-12 schools (B20-B29)
k12 = df.filter(pl.col("NTEECC").str.contains(r"^B2[0-9]"))

# All education (B)
all_education = df.filter(pl.col("NTEECC").str.starts_with("B"))

# Using NTEEV2 for universities
universities_v2 = df.filter(pl.col("NTEE_V2").str.starts_with("UNI-"))
```

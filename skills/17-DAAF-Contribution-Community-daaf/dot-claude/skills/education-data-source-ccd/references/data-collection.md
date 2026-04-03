# CCD Data Collection

This reference covers how CCD data is collected, processed, and released.

## Data Collection System

### EDFacts

Since 2006, CCD nonfiscal data has been collected through the **EDFacts** system, which centralizes data collection across multiple Department of Education programs.

**EDFacts Features**:
- Centralized data submission portal
- Standardized file specifications
- Automated validation checks
- Single submission for multiple federal requirements

**Submission Portal**: States submit through EDFacts Submission System (ESS), accessed via EDPass authentication.

### Pre-EDFacts Collection (Before 2006)

Prior to EDFacts, CCD data was collected directly by NCES through:
- Paper forms
- Direct electronic submission
- State data extracts

The transition to EDFacts improved standardization but created some discontinuities in historical data.

## Respondent Universe

### Who Reports CCD Data?

**Primary Respondents**: State Education Agencies (SEAs)

States are responsible for:
1. Collecting data from Local Education Agencies (LEAs)
2. Validating and compiling state-level files
3. Submitting to NCES via EDFacts
4. Responding to quality review inquiries

**Data Flow**:
```
Individual Schools
      ↓
Local Education Agencies (LEAs/Districts)
      ↓
State Education Agencies (SEAs)
      ↓
EDFacts/NCES
      ↓
Public CCD Data Files
```

### Universe Definition

CCD is a **universe survey**, not a sample. It aims to include:

**Schools**:
- All public elementary schools
- All public secondary schools
- All public combined schools
- Charter schools (public)
- Magnet schools
- Alternative schools
- Virtual schools
- Special education schools (public)
- Vocational/career-technical schools (public)

**Local Education Agencies**:
- Regular school districts
- Supervisory unions
- Regional education service agencies
- State-operated agencies (schools for deaf, blind, incarcerated)
- Federally-operated agencies (BIE, DoDEA)
- Charter school agencies

**Jurisdictions**:
- 50 states
- District of Columbia
- Puerto Rico (nonfiscal data)
- Bureau of Indian Education (BIE) schools
- Department of Defense Education Activity (DoDEA) schools
- Other territories (American Samoa, Guam, Northern Mariana Islands, Virgin Islands)

### Exclusions

CCD does **not** include:
- Private schools (covered by Private School Universe Survey)
- Home-schooled students
- Postsecondary institutions (covered by IPEDS)
- Preschool programs not operated by public schools
- Adult education programs (unless part of K-12 system)

## Data Collection Timeline

### Nonfiscal Data (Directory, Membership, Staffing)

| Activity | Timing | Notes |
|----------|--------|-------|
| Reference Date | October 1 | Snapshot date for counts |
| State Submission Window | December - April | Following reference date |
| Preliminary Release | July - August | ~9 months after reference |
| Quality Review | Ongoing | NCES contacts states |
| Provisional Release | December - January | ~14 months after reference |

**Example**: For school year 2023-24 (October 1, 2023 snapshot):
- States submit: Winter/Spring 2024
- Preliminary release: Summer 2024
- Provisional release: Winter 2024-25

### Fiscal Data (Finance)

Finance data has a longer lag due to fiscal year-end reporting requirements.

| Activity | Timing | Notes |
|----------|--------|-------|
| Fiscal Year End | June 30 | Most states |
| State Submission | Following fall/winter | After audits |
| Data Release | 18-24 months after FY end | |

**Example**: For fiscal year 2022 (July 2021 - June 2022):
- States submit: Late 2022 - Early 2023
- Data release: Late 2023 - 2024

## Data Submission Specifications

### EDFacts File Specifications

Each data element has detailed submission specifications including:
- **Data Group**: Category of data (e.g., membership, staff FTE)
- **File Number**: Unique identifier (e.g., FS029 for membership)
- **Permitted Values**: Valid codes and ranges
- **Business Rules**: Validation logic

**Key File Specifications**:

| File | Description | Level |
|------|-------------|-------|
| FS029 | Membership by Grade | School, LEA |
| FS039 | Membership by Race/Ethnicity | School, LEA |
| FS033 | Free/Reduced Lunch | School, LEA |
| FS052 | Staff FTE | School, LEA |
| FS059 | Dropout/Completers | LEA |
| FS070 | Directory | School, LEA |

### Submission Modes

**Level 1 (Aggregate)**: State provides aggregate counts
**Level 2 (Detail)**: State provides school/district-level data

Most states submit Level 2 data for CCD.

## Quality Review Process

### NCES Data Review

After submission, NCES performs:

1. **Automated Validation**
   - Range checks
   - Internal consistency (e.g., grade enrollment sums)
   - Year-to-year comparisons
   - Cross-file consistency

2. **Manual Review**
   - Outlier investigation
   - Trend analysis
   - State-specific notes review

3. **State Follow-up**
   - Questions sent to state coordinators
   - Resolution of discrepancies
   - Resubmission if needed

### Common Quality Checks

| Check Type | Example | Action |
|------------|---------|--------|
| Range | Enrollment > 0 for operational schools | Flag for review |
| Consistency | Membership by grade ≈ Total | Investigate difference |
| Year-to-Year | >20% change from prior year | Contact state |
| Cross-file | School counts match directory | Verify |

### Imputation

NCES may impute missing values using:
- Prior year data
- Similar school/district averages
- State averages

Imputation flags indicate which values were imputed.

## State Coordinators

Each state has designated **CCD Coordinators**:
- **Nonfiscal Coordinator**: Handles directory, membership, staffing
- **Fiscal Coordinator**: Handles finance data

Coordinators are responsible for:
- Compiling state data
- Validating before submission
- Responding to NCES inquiries
- Communicating data limitations

## Data Release Process

### Preliminary vs. Provisional

| Release Type | Description | Use Case |
|--------------|-------------|----------|
| Preliminary (0x) | First release, limited quality review | Timely access, subject to revision |
| Provisional (1x) | Quality-reviewed, considered final | Research, official statistics |

**Version Letters**: Multiple releases within a type (0a, 0b, 1a, 1b) indicate updates/corrections.

### Publication Formats

CCD data is available through:

1. **Data Files**: CSV/SAS files for download from NCES
2. **ELSI (Elementary/Secondary Information System)**: NCES online query tool
3. **School/District Locators**: Individual entity lookup on NCES site
4. **Publications**: NCES reports and tables
5. **Education Data Portal mirrors**: Processed CCD data available via HuggingFace (parquet) and Urban Institute (CSV) mirrors. See `datasets-reference.md` for canonical paths and `mirrors.yaml` for mirror configuration.

### Documentation

Each release includes:
- Record layouts
- Variable definitions
- State notes
- Change logs
- Imputation information

## Special Reporting Situations

### Bureau of Indian Education (BIE) Schools

BIE schools are reported both by:
- BIE directly to NCES
- States where schools are located (in some cases)

**Double-counting issue**: Some BIE schools appear in both BIE and state files. NCES provides crosswalk documentation to identify duplicates.

### Department of Defense Schools (DoDEA)

DoDEA operates schools on military installations:
- Domestic (DDESS)
- Overseas (DoDDS)

Only domestic DoDEA schools are included in main CCD files.

### Virtual Schools

Starting 2014-15, CCD includes virtual school indicator:
- Full-time virtual
- Supplemental virtual
- Not virtual

Virtual school enrollment counting varies significantly by state.

### Charter Schools

Charter school reporting has improved over time:
- Early years (pre-2000): Many charters missing or miscoded
- 2000-2010: Improving but inconsistent
- 2010+: Generally complete coverage

**Charter Agency Type**: Starting 2007-08, LEA type code 7 specifically identifies charter school agencies.

## State-Specific Notes

Each CCD release includes state notes documenting:
- Known data quality issues
- Reporting methodology differences
- Missing data explanations
- Definition variations

**Examples**:
- State X reports all students in grade 13 as ungraded
- State Y unable to provide race/ethnicity for certain schools
- State Z includes prekindergarten differently than other states

Always check state notes before interpreting outliers or unexpected values.

## Contact Information

**NCES CCD Staff**:
- Nonfiscal data: Chen-Su Chen
- Fiscal data: Stephen Cornman
- Data tools: Patrick Keaton

**EDFacts Partner Support Center (PSC)**: edfacts@ed.gov

**State Coordinators**: Contact information available on NCES CCD website.

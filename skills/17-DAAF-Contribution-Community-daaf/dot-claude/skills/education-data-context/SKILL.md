---
name: education-data-context
description: >-
  Interpretation guidance for Urban Institute Portal datasets. Coded values (-1/-2/-3), year definitions, grade encoding, suppression, licensing, cross-source joins. Use when interpreting Portal data before analysis. Routes to source-specific skills.
metadata:
  audience: any-agent
  domain: data-documentation
---

# Education Data Context

Data origin, caveats, and interpretation guidance for Urban Institute Education Data Portal datasets. Use when interpreting Portal coded values (-1/-2/-3 missing/not-applicable/suppressed), understanding year definitions (fall vs. academic year), applying correct grade encoding (grade=-1 means Pre-K, not missing), assessing suppression rates, citing data under ODC-By license, or reviewing any Portal data before analysis. Also covers joining identifiers across CCD, IPEDS, CRDC, and other sources, and routes to source-specific deep-dive skills.

This skill provides critical context for interpreting data from the Urban Institute Education Data Portal. Education data has source-specific limitations that can significantly affect analysis validity.

## Why Data Context Matters

- **Source-specific limitations**: Each data source (CCD, IPEDS, CRDC, etc.) has unique constraints
- **Missing values have meaning**: Codes like -1, -2, -3 indicate specific conditions, not random missingness
- **Definitions change over time**: Variable definitions, categories, and coding schemes evolve
- **State comparisons require caution**: State-level data often cannot be directly compared
- **Citation is required**: The ODC Attribution License mandates proper citation
- **Skill provenance matters**: Each `*-data-source-*` skill includes `provenance.skill_last_updated` in its frontmatter. If this date is more than a few months old, treat the skill's claims about coded values, suppression patterns, and data quality with caution — data sources evolve and skill documentation may have drifted. Consider re-running data-ingest to re-verify.

## Data Provenance: The Education Data Portal

All education data currently accessible through this system is obtained from the **Urban Institute Education Data Portal (EDP)**, not directly from original source agencies (NCES, Census Bureau, Department of Education, etc.). The EDP is a curation and standardization layer that:

- **Renames variables** to lowercase (e.g., `enrollment` not `MEMBER`)
- **Re-encodes categoricals** as integers (e.g., `1` not `"Regular school"`)
- **Standardizes missing values** using codes `-1` (missing), `-2` (not applicable), `-3` (suppressed)
- **May subset** each source's full variable catalog — not all variables from the original source are necessarily available through the Portal

Each `education-data-source-*` skill documents what is available through the Portal for that source, including any known gaps relative to the original data collection. When a skill also documents variables or components only available from the original source directly, this is clearly noted.

> **Note:** This provenance applies specifically to the current education data source skills. Future data source skills may access data from other providers with different characteristics.

## Reference File Structure

### Quick Context (This Skill)

| File | Content | When to Read |
|------|---------|--------------|
| `./references/ccd-context.md` | K-12 schools/districts caveats | After pulling CCD data |
| `./references/ipeds-context.md` | College/university caveats | After pulling IPEDS data |
| `./references/crdc-context.md` | Civil rights data caveats | After pulling CRDC data |
| `./references/scorecard-context.md` | College Scorecard caveats | After pulling Scorecard data |
| `./references/edfacts-context.md` | Assessment/graduation caveats | After pulling EDFacts data |
| `./references/data-relationships.md` | Joining tables, identifiers | When merging datasets |

### Deep-Dive Source Skills (Comprehensive Documentation)

These skills document both EDP-available data and original source context. Each skill notes when content applies only to the original source (not available through the Portal).

For comprehensive understanding beyond the quick context files above, load the dedicated data source skill:

| Data Source | Deep-Dive Skill | Key Deep Topics |
|-------------|-----------------|-----------------|
| CCD | `education-data-source-ccd` | Survey components, EDFacts submission, state variations, historical changes |
| CRDC | `education-data-source-crdc` | Civil rights legal context, underreporting issues, year-to-year evolution |
| EDFacts | `education-data-source-edfacts` | ESSA/NCLB context, why states aren't comparable, ACGR methodology |
| IPEDS | `education-data-source-ipeds` | All 12+ surveys, graduation rate population limits, GASB vs FASB |
| Scorecard | `education-data-source-scorecard` | IRS earnings methodology, Title IV selection bias, suppression rules |
| SAIPE | `education-data-source-saipe` | Model-based estimation, no district confidence intervals |
| FSA | `education-data-source-fsa` | Title IV programs, financial responsibility scores, 90/10 rule |
| MEPS | `education-data-source-meps` | Superior to FRPL for cross-state poverty comparison |
| NHGIS | `education-data-source-nhgis` | Census geography links, boundary changes over time |
| NACUBO | `education-data-source-nacubo` | Endowment study methodology, voluntary participation bias |
| NCCS | `education-data-source-nccs` | Form 990 data, NTEE codes, private college relevance |
| EADA | `education-data-source-eada` | Title IX context, not same as compliance data |
| Campus Safety | `education-data-source-campus-safety` | Clery Act, underreporting, geography definitions |
| PSEO | `education-data-source-pseo` | LEHD methodology, experimental status, state coverage |

**When to load deep-dive skills:**
- Need to understand data collection methodology in detail
- Analyzing historical trends and need to know about definition changes
- Encountering data quality issues that require deeper investigation
- Writing documentation or reports that require precise methodology descriptions

## Decision Trees

### What data source did I pull from?

```
What endpoint did you use?
├─ schools/ccd/* → Read ./references/ccd-context.md
│   └─ Need more depth? → Load education-data-source-ccd skill
├─ school-districts/* → Read ./references/ccd-context.md
│   └─ Need more depth? → Load education-data-source-ccd skill
├─ schools/crdc/* → Read ./references/crdc-context.md
│   └─ Need more depth? → Load education-data-source-crdc skill
├─ schools/edfacts/* → Read ./references/edfacts-context.md
│   └─ Need more depth? → Load education-data-source-edfacts skill
├─ schools/meps/* → Load education-data-source-meps skill
├─ college-university/ipeds/* → Read ./references/ipeds-context.md
│   └─ Need more depth? → Load education-data-source-ipeds skill
├─ college-university/scorecard/* → Read ./references/scorecard-context.md
│   └─ Need more depth? → Load education-data-source-scorecard skill
├─ college-university/fsa/* → Load education-data-source-fsa skill
├─ college-university/nacubo/* → Load education-data-source-nacubo skill
├─ college-university/eada/* → Load education-data-source-eada skill
├─ college-university/pseo/* → Load education-data-source-pseo skill
├─ school-districts/saipe/* → Load education-data-source-saipe skill
└─ Multiple sources → Read ./references/data-relationships.md first
```

### How do I interpret missing values?

```
What value do you see?
├─ In a CATEGORICAL column (grade, race, sex)?
│   └─ These use integer encoding, NOT coded missing values!
│       ├─ grade = -1 means Pre-K (NOT missing!)
│       ├─ race = 1-7 (NOT WH, BL, HI strings)
│       └─ sex = 1-2 (NOT M, F strings)
├─ In a NUMERIC column (enrollment, FTE, counts)?
│   ├─ -1 → Missing/not reported (treat as NULL)
│   ├─ -2 → Not applicable (exclude from that variable's analysis)
│   └─ -3 → Suppressed for privacy (cannot recover)
├─ null/blank?
│   └─ Source matters:
│       ├─ CCD, CRDC, EDFacts → Should use -1/-2/-3 codes
│       └─ Scorecard, MEPS, NACUBO → Use native nulls
├─ Ranges (e.g., "10-20") → EDFacts suppression bounds
└─ Unsure → Check source-specific reference file
```

### What are the limitations?

```
What type of analysis are you doing?
├─ Cross-state comparison
│   ├─ K-12 assessments → INVALID (states not comparable)
│   ├─ K-12 other metrics → Check state reporting consistency
│   └─ College data → Generally valid (federal definitions)
├─ Time series
│   ├─ Check for definition changes
│   ├─ Check for ID changes (schools/districts merge/split)
│   └─ Check COVID-19 impact (2020-2021)
├─ Subgroup analysis
│   ├─ Check suppression rates
│   ├─ Smaller groups = more suppression
│   └─ Cannot impute suppressed values accurately
└─ Graduate outcomes
    ├─ IPEDS → First-time full-time only
    └─ Scorecard → Title IV recipients only
```

## Universal Data Caveats

### Portal Integer Encoding System

**CRITICAL:** The Education Data Portal uses integer codes, not string labels, for categorical variables. This applies to all sources.

#### Demographic Variable Encodings

| Variable | Integer Values | NOT Strings |
|----------|----------------|-------------|
| Race | 1-7, 99 (total) | Not WH, BL, HI, AS, etc. |
| Sex | 1 (Male), 2 (Female), 3 (Another gender, IPEDS 2022+), 4 (Unknown gender, IPEDS 2022+), 9 (Unknown), 99 (Total) | Not M, F |
| Grade | -1 to 13, 99 (total) | Not PK, KG, 01, etc. |

**Race codes:**
| Value | Meaning |
|-------|---------|
| 1 | White |
| 2 | Black |
| 3 | Hispanic |
| 4 | Asian |
| 5 | American Indian/Alaska Native |
| 6 | Native Hawaiian/Pacific Islander |
| 7 | Two or more races |
| 8 | Nonresident alien (postsecondary only) |
| 9 | Unknown |
| 99 | Total (all races) |

**Grade codes:**
| Value | Meaning |
|-------|---------|
| -1 | Pre-K (**SEMANTIC TRAP: NOT missing data!**) |
| 0 | Kindergarten |
| 1-12 | Grades 1-12 |
| 13 | Ungraded |
| 99 | Total (all grades) |

**SEMANTIC TRAP - Grade -1:**
In CCD enrollment data, `grade = -1` means **Pre-Kindergarten**, NOT missing data. This is a common source of errors. Missing data in enrollment uses the separate coded value system (-1/-2/-3) only for numeric fields like enrollment counts, not for the grade categorical variable.

```python
# WRONG - filters out Pre-K students!
df = df.filter(pl.col("grade") >= 0)

# RIGHT - Pre-K students have grade = -1
pre_k = df.filter(pl.col("grade") == -1)
k_12 = df.filter(pl.col("grade").is_between(0, 12))
total = df.filter(pl.col("grade") == 99)
```

#### Variable Names Are Lowercase

Portal variable names are lowercase, not the uppercase names from original NCES documentation:
- `enrollment` not `MEMBER` or `ENROLLMENT`
- `grade` not `GRADE`
- `fips` not `FIPS` or `STATE`

### Rate and Proportion Normalization

The Portal normalizes certain rate and proportion variables to a 0-1 scale, while the original IPEDS surveys report them as 0-100 percentages. This is a Portal transformation, not an IPEDS source issue.

**Known affected variables:**

| Variable | Source Survey | Portal Scale | Original IPEDS Scale |
|----------|-------------|-------------|---------------------|
| `completion_rate_150pct` | GRS (Graduation Rates) | 0-1 | 0-100 |
| `retention_rate` | EF (Fall Enrollment / Retention) | 0-1 | 0-100 |

**Guidance:**
- Always check the actual range of rate variables after fetching -- if `max <= 1.0`, the variable is on a 0-1 scale and may need rescaling to 0-100 for interpretability
- Do not assume all rate variables across all datasets are normalized -- this finding is specific to the IPEDS variables listed above
- Quality checks testing `value > 100` will not catch invalid data on 0-1 scaled variables; adjust thresholds accordingly (e.g., test `value > 1.0` instead)

### Missing Value Codes

| Code | Meaning | How to Handle |
|------|---------|---------------|
| -1 | Missing/not reported | Treat as NULL; document missingness rate |
| -2 | Not applicable | Exclude from analysis of that variable |
| -3 | Suppressed (privacy) | Cannot be recovered; affects small-cell analyses |
| null/blank | Genuinely missing | Treat as NULL |

**IMPORTANT:** Coded values (-1/-2/-3) apply to **numeric measure columns** (enrollment counts, FTE, etc.), NOT to categorical identifier columns like `grade`, `race`, or `sex`. Those use the integer encoding system above.

**Missing Data Handling Varies by Source:**

| Source | Missing Data Pattern |
|--------|---------------------|
| CCD, CRDC, EDFacts | Use -1/-2/-3 coded values for numeric fields |
| Scorecard, MEPS, NACUBO | Use native `null` values |
| IPEDS | Mix of both (check specific variables) |

**Important**: Filter coded values BEFORE calculating statistics:

```python
# WRONG - includes coded values in mean
df["enrollment"].mean()

# RIGHT - exclude coded missing values
df.filter(pl.col("enrollment") >= 0)["enrollment"].mean()
```

### Year Definitions

- `year` refers to the **FALL** of the academic year
- `year=2020` means the **2020-21 school year**
- Graduation rates use cohort entry year (cohort started 4-6 years prior)
- Finance data may use fiscal year (varies by institution)

| Data Type | Year Interpretation |
|-----------|---------------------|
| Fall enrollment | Fall of indicated year |
| Academic year totals | Full year starting fall of indicated year |
| Graduation rates | Cohort entry year (outcomes measured later) |
| Completions | Degrees awarded during indicated academic year |

### Suppression

Data is suppressed to protect student privacy:

- **Small cell sizes**: Typically fewer than 5-10 students
- **Affects disaggregated data**: Race, disability, gender breakdowns
- **More suppression in smaller schools**: Rural areas most affected
- **Cannot be imputed accurately**: Do not attempt to recover
- **Complementary suppression**: Other cells may be suppressed to prevent calculation

### State Reporting Variation

State education agencies interpret federal definitions differently:

- Dropout definitions vary (CCD covers grades 7-12, CPS covers 10-12)
- Average daily attendance calculated differently by state law
- Discipline categories interpreted inconsistently
- Missing data tends to cluster by state

## Data Quality Checklist

Before analyzing any Education Data Portal data:

- [ ] **Check coded values**: Filter out -1, -2, -3 before calculations
- [ ] **Understand year definition**: Fall of academic year vs. cohort year
- [ ] **Note suppression rates**: Calculate % suppressed by variable
- [ ] **Check definition changes**: Compare codebooks across years
- [ ] **Verify identifier consistency**: NCES IDs can change when schools/districts merge
- [ ] **Document state anomalies**: Note any state-specific reporting issues
- [ ] **Check coverage**: Not all schools appear in all sources
- [ ] **Consider COVID-19**: 2020-2021 data may not be comparable to prior years

### Quick Coverage Check

```python
# Check missingness and suppression by state
df.group_by("fips").agg([
    pl.col("variable").filter(pl.col("variable") == -1).count().alias("missing"),
    pl.col("variable").filter(pl.col("variable") == -3).count().alias("suppressed"),
    pl.col("variable").count().alias("total")
])
```

## Citation Requirements

### Full Citation Format

Use for publications, reports, and formal documents:

```
[Dataset name(s)], Education Data Portal (Version X.X.X), 
Urban Institute, accessed [Month DD, YYYY], 
https://educationdata.urban.org/documentation/, 
made available under the ODC Attribution License.
```

**Example:**
```
Common Core of Data (CCD) School Directory, Education Data Portal 
(Version 0.20.0), Urban Institute, accessed January 15, 2026, 
https://educationdata.urban.org/documentation/, 
made available under the ODC Attribution License.
```

### Short Citation Format

Use for visualizations, dashboards, and space-constrained contexts:

```
Source: [Dataset name(s)], Education Data Portal v.X.X.X, 
Urban Institute, ODC-By License.
```

**Example:**
```
Source: CCD School Directory, Education Data Portal v.0.20.0, 
Urban Institute, ODC-By License.
```

### License Terms

**License**: Open Data Commons Attribution License (ODC-By) v1.0

Key requirements:
- Must attribute the Urban Institute as data source
- Must indicate if data was modified
- May use for any purpose including commercial
- May redistribute with attribution

### Notification

**Email educationdata@urban.org** with any published work using the data. This helps the Urban Institute track usage and improve the portal.

## Quick Reference: Source-Specific Caveats

| Source | Key Limitation | Critical For | Quick Reference | Deep Dive |
|--------|---------------|--------------|-----------------|-----------|
| CCD | Public schools only; state reporting varies | K-12 enrollment, demographics | `./references/ccd-context.md` | `education-data-source-ccd` |
| IPEDS | First-time full-time students only for grad rates | College graduation analysis | `./references/ipeds-context.md` | `education-data-source-ipeds` |
| CRDC | Biennial; self-reported; underreporting | Equity/discipline analysis | `./references/crdc-context.md` | `education-data-source-crdc` |
| Scorecard | Title IV recipients only; earnings suppressed | Earnings/outcomes analysis | `./references/scorecard-context.md` | `education-data-source-scorecard` |
| EDFacts | State assessments NOT comparable across states | Achievement analysis | `./references/edfacts-context.md` | `education-data-source-edfacts` |
| SAIPE | Model-based estimates; no district CIs | District poverty | — | `education-data-source-saipe` |
| FSA | Federal aid only; timing varies | Student aid analysis | — | `education-data-source-fsa` |
| MEPS | Model estimates; 100% FPL only | School poverty (cross-state) | — | `education-data-source-meps` |
| NHGIS | Boundary changes over time | Geography linking | — | `education-data-source-nhgis` |
| EADA | Self-reported; NOT Title IX compliance | Athletics equity | — | `education-data-source-eada` |
| Campus Safety | Underreporting; comparability issues | Campus crime | — | `education-data-source-campus-safety` |
| PSEO | Experimental; partial state coverage | Employment outcomes | — | `education-data-source-pseo` |

### What Each Source Covers

| Source | Universe | Update Frequency |
|--------|----------|------------------|
| CCD | All public schools and districts | Annual |
| IPEDS | All Title IV postsecondary institutions | Annual |
| CRDC | Sample/universe of public schools | Biennial |
| Scorecard | Title IV aid recipients | Annual |
| EDFacts | Public schools with state assessments | Annual |

## Data Lag Reference

Data availability lags behind the current year. As of January 2026:

| Source | Survey Component | Typical Lag | Latest Available |
|--------|------------------|-------------|------------------|
| **IPEDS** | Directory | ~1 year | 2023 |
| **IPEDS** | Admissions-Enrollment | ~2 years | 2022 |
| **IPEDS** | Fall Enrollment | ~2-3 years | 2021 |
| **IPEDS** | Finance | ~2-3 years | Varies |
| **CCD** | Directory/Enrollment | ~1-2 years | 2022 |
| **CCD** | Finance | ~2-3 years | 2020 |
| **CRDC** | All (biennial) | ~1-2 years | 2021 |
| **EDFacts** | Assessments | ~1-2 years | 2020 |
| **EDFacts** | Graduation Rates | ~1-2 years | 2020 |
| **SAIPE** | Poverty estimates | ~18 months | 2023 |
| **Scorecard** | Earnings/outcomes | ~2-3 years | 2020 |
| **MEPS** | School poverty | ~2-3 years | 2019 |

**Always verify year availability** before building pipelines. Use mirror discovery endpoints (see mirrors.yaml) or filter downloaded data to confirm which years are present. See `education-data-query` skill for mirror-based fetch patterns.

## Common Analysis Mistakes

### DO NOT:

1. **Compare state assessment scores across states** (EDFacts)
   - Each state has different tests and cut scores

2. **Use IPEDS graduation rates to represent all students**
   - Only tracks first-time, full-time students

3. **Assume Scorecard earnings represent all graduates**
   - Only covers Title IV aid recipients

4. **Calculate statistics without filtering coded values**
   - -1, -2, -3 are not zeros; they corrupt calculations

5. **Compare 2020-2021 data to prior years without noting COVID**
   - Testing waivers, discipline changes, enrollment shifts

6. **Merge data across years assuming stable identifiers**
   - Schools and districts merge, split, and change IDs

7. **Assume Portal rate variables are on a 0-100 percentage scale**
   - Some IPEDS rate variables (e.g., `completion_rate_150pct`, `retention_rate`) are normalized to 0-1 proportions in the Portal, even though the original IPEDS surveys use 0-100. Always check the actual range after fetching. See "Rate and Proportion Normalization" above.

### DO:

1. **Check suppression rates before disaggregating**
2. **Use within-state comparisons for assessment data**
3. **Document all data limitations in your analysis**
4. **Verify identifier stability for longitudinal analyses**
5. **Cite the data source properly**

## Cross-References

- **Variable definitions**: Load `education-data-explorer` skill to understand what variables measure
- **Query assistance**: Load `education-data-query` skill to re-fetch data with different parameters
- **Joining data**: Read `./references/data-relationships.md` for identifier mappings
- **Deep source context**: Load the appropriate `education-data-source-*` skill for comprehensive methodology, historical changes, and detailed variable definitions
- **Source-specific gotchas**: Load the relevant `education-data-source-*` skill for variable name mappings, data lags, and endpoint-specific behaviors

## Topic Index

| Topic | Location |
|-------|----------|
| Bureau of Indian Education schools | `./references/ccd-context.md` |
| Charter school coverage | `./references/ccd-context.md` |
| Chronic absenteeism | `./references/crdc-context.md` |
| Citation format | This file: Citation Requirements |
| COVID-19 data impact | `./references/crdc-context.md` |
| Discipline data | `./references/crdc-context.md` |
| Dropout definitions | `./references/ccd-context.md` |
| Earnings data limitations | `./references/scorecard-context.md` |
| Finance data (colleges) | `./references/ipeds-context.md` |
| GASB vs FASB accounting | `./references/ipeds-context.md` |
| Graduation rate caveats | `./references/ipeds-context.md` |
| Identifier relationships | `./references/data-relationships.md` |
| Joining tables | `./references/data-relationships.md` |
| LEAID format | `./references/data-relationships.md` |
| Locale codes | `./references/ccd-context.md` |
| Missing value codes | This file: Universal Data Caveats |
| NCESSCH format | `./references/data-relationships.md` |
| Net price calculation | `./references/ipeds-context.md` |
| ODC-By License | This file: Citation Requirements |
| OPEID vs UNITID | `./references/data-relationships.md` |
| Private schools | `./references/ccd-context.md` (not covered) |
| Proficiency data | `./references/edfacts-context.md` |
| Race category changes | `./references/ccd-context.md` |
| Sampling (CRDC) | `./references/crdc-context.md` |
| State assessment comparability | `./references/edfacts-context.md` |
| State FIPS codes | `./references/data-relationships.md` |
| Student financial aid | `./references/ipeds-context.md` |
| Suppression | This file: Universal Data Caveats |
| Title IV institutions | `./references/ipeds-context.md` |
| Transfer students | `./references/ipeds-context.md` |
| UNITID changes | `./references/ipeds-context.md` |
| Year definitions | This file: Universal Data Caveats |

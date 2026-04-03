# CCD Data Quality

Understanding data quality issues is essential for valid analysis. This reference covers missing data patterns, state variations, suppression, and known limitations.

> **Codebook Authority:** When resolving ambiguities about data quality or coded values, consult
> the codebook `.xls` file in the mirror. Use `get_codebook_url()` from `fetch-patterns.md`.

## Missing Data Patterns

### State-Level Clustering

**Key Insight**: Missing data in CCD tends to cluster by state.

If one district in a state is missing a variable, other districts in that state likely are too. This is because:
- State-level reporting systems differ in capability
- SEAs have different data collection priorities
- Some states don't collect certain items

**Implication**: Always check missingness BY STATE before comparing states.

```python
# Check missingness by state for a variable
def check_state_missingness(df, variable):
    missing_codes = [-1, -2, -3, -9]
    return df.group_by("fips").agg([
        pl.col(variable).is_in(missing_codes).sum().alias("missing_count"),
        pl.col(variable).count().alias("total_count"),
    ]).with_columns(
        (pl.col("missing_count") / pl.col("total_count") * 100).alias("missing_pct")
    ).sort("missing_pct", descending=True)
```

### High-Missingness Variables

| Variable | Typical Issue | Most Affected Years |
|----------|---------------|---------------------|
| Free/reduced lunch | Reporting methodology changes | 2012+ (CEP) |
| FTE staff counts | Inconsistent state definitions | All years |
| Enrollment by grade | Some states report as "ungraded" | Varies |
| Race/ethnicity detail | Suppression for small groups | All years |
| Finance data | Reporting lag | Most recent 1-2 years |
| Dropout counts | Definition variation | All years |

### Variables More Likely to Be Complete

- Total enrollment (membership)
- School name and address
- School type and status
- Grade span
- NCES identifiers

---

## State Variations

### Definition Differences

Many CCD variables have state-level variation in how they're defined or measured.

| Variable | Issue | Impact |
|----------|-------|--------|
| **Dropouts** | States define "dropout" differently | Cross-state comparison invalid |
| **Average Daily Attendance** | Different state calculation methods | Cannot compare across states |
| **Ungraded Students** | Some states assign all to one grade | Grade-level analysis affected |
| **Virtual Enrollment** | Counting methods vary widely | Virtual school counts not comparable |
| **FTE Staff** | FTE definition varies | Staff comparisons problematic |
| **Pre-K** | Inclusion criteria differ | Early childhood counts vary |

### Dropout Definition Variation

The CCD dropout rate has specific limitations:

1. **Grade Coverage**: CCD covers grades 7-12; other surveys cover different grades
2. **Calculation Method**: Event dropout rate (annual) vs. status dropout rate (point-in-time)
3. **State Definitions**: Each state defines "dropout" differently
4. **GED Treatment**: States handle GED completers inconsistently
5. **Transfer Tracking**: Difficult to distinguish dropout from transfer

**Recommendation**: Use dropout rates for within-state comparisons only.

### Known State Reporting Anomalies

| State | Year(s) | Issue |
|-------|---------|-------|
| Puerto Rico | Various | Inconsistent reporting; sometimes excluded |
| Hawaii | All | Single statewide district; school=district for aggregation |
| DC | All | Single district; treated as both state and district |
| New York | Pre-2010 | NYC charter schools sometimes aggregated differently |
| California | Various | Large district reporting delays |
| Texas | Various | Charter network reporting changes |

---

## Free/Reduced Price Lunch (FRPL) Limitations

FRPL eligibility is commonly used as a poverty proxy, but has significant limitations.

### Direct Certification

**What it is**: Students automatically enrolled in NSLP based on participation in other programs (SNAP, TANF, etc.) without submitting an application.

**Impact**: Schools with high direct certification may show lower FRPL counts than actual eligibility because:
- Not all eligible families are auto-certified
- Some students eligible but not in linked programs

### Community Eligibility Provision (CEP)

**Enacted**: 2014-15 nationwide (phased in from 2011-12)

**What it is**: High-poverty schools (≥40% directly certified) can provide free meals to all students.

**Impact on Data**:
- CEP schools may report 100% eligibility
- Comparison between CEP and non-CEP schools is problematic
- FRPL loses meaning as poverty measure for CEP schools

### FRPL Reporting Changes

| Period | Reporting Method | Notes |
|--------|------------------|-------|
| Pre-2012 | Application-based | Standard FRPL applications |
| 2012-2016 | Transition | States began reporting direct certification separately |
| 2016+ | Split reporting | States report FRPL, Direct Cert, or both |

### Alternative Poverty Measures

For district-level poverty analysis, consider:

| Source | Measure | Advantages |
|--------|---------|------------|
| SAIPE | Census poverty estimates | Consistent methodology |
| MEPS | Model-based school poverty | Available for schools |
| ACS | Community characteristics | Detailed demographics |

---

## Data Suppression

### Why Data is Suppressed

- **Privacy Protection**: Small cell sizes could identify individuals
- **State Policy**: State-specific suppression rules
- **Complementary Suppression**: Prevent back-calculation

### Suppression Rules

Common thresholds:
- Fewer than 3-5 students in a subgroup
- Percentage would identify individuals
- State-specific rules may be stricter

### Suppression Impact by Data Type

| Data Type | Suppression Frequency | Impact |
|-----------|----------------------|--------|
| Total enrollment | Rare | Minimal |
| Enrollment by grade | Low | Some |
| Enrollment by race | Moderate | Significant for small schools |
| Enrollment by grade×race×sex | High | Major limitation for disaggregation |
| Small school totals | Moderate | Affects rural analysis |

### Handling Suppression

```python
# Identify suppression impact
def suppression_analysis(df: pl.DataFrame, variable: str) -> dict:
    total = df.height
    suppressed = df.filter(pl.col(variable) == -3).height

    if suppressed / total > 0.1:
        print(f"WARNING: {suppressed/total:.1%} of {variable} is suppressed")
        print("Disaggregated analysis may be unreliable")

    return {
        "total_records": total,
        "suppressed": suppressed,
        "suppression_rate": suppressed / total
    }
```

---

## Charter School Coverage

### Historical Coverage Issues

| Period | Coverage Quality | Notes |
|--------|------------------|-------|
| Pre-2000 | Poor | Many charters missing or miscoded |
| 2000-2010 | Improving | Inconsistent state-to-state |
| 2010+ | Good | Generally complete |

### Charter Identification Issues

- **Early Years**: No dedicated charter indicator
- **LEA Type**: Charter agencies not distinguished until 2007-08
- **State Variation**: Some states reported charters inconsistently

### Best Practices for Charter Analysis

1. Verify counts against state records for years before 2010
2. Check charter indicator AND charter LEA type
3. Document any discrepancies found
4. Consider state-specific charter definitions

---

## Virtual School Data

### Reporting Challenges

- **Enrollment Counting**: Full-time vs. part-time students
- **Location Assignment**: Where to count students
- **Multi-State Operations**: Some virtuals operate across states
- **Program vs. School**: Distinguishing virtual programs from schools

### Virtual Indicator Limitations (2014-15+)

| Classification | What it Captures | Limitations |
|----------------|------------------|-------------|
| Full-time Virtual | All instruction online | Doesn't capture hybrid models |
| Supplemental Virtual | Online courses | May miss some arrangements |
| Not Virtual | Traditional | Some virtual components not captured |

---

## Finance Data Quality

### Reporting Lag

Finance data has the longest lag of any CCD component:
- Fiscal year ends June 30
- States complete audits fall/winter
- Data typically 2 years behind enrollment data

### Comparability Issues

| Issue | Impact | Mitigation |
|-------|--------|------------|
| Accounting practices | State variation | Use within-state comparisons |
| Revenue classification | Federal/state/local boundaries | Check state methodology |
| Capital vs. current | Definition variation | Focus on current expenditure |
| Fund inclusion | Which funds reported | Review state documentation |

### Inflation Adjustment

Finance data is reported in nominal (current year) dollars. For time series:
- Apply CPI or education-specific deflator
- Use consistent base year
- Document deflator used

---

## Longitudinal Data Quality

### ID Stability

School and district IDs are generally stable but can change due to:
- Mergers/consolidations
- Splits
- Boundary changes
- Reporting corrections

**Check Before Building Panels**:
```python
def check_id_stability(df_year1: pl.DataFrame, df_year2: pl.DataFrame, id_col: str) -> dict:
    ids_y1 = set(df_year1.get_column(id_col).unique().to_list())
    ids_y2 = set(df_year2.get_column(id_col).unique().to_list())

    return {
        "dropped": len(ids_y1 - ids_y2),
        "added": len(ids_y2 - ids_y1),
        "stable": len(ids_y1 & ids_y2),
        "pct_stable": len(ids_y1 & ids_y2) / len(ids_y1) * 100
    }
```

### Definition Changes Over Time

Before longitudinal analysis, check:
- Variable definition changes (see historical-changes.md)
- Code value changes (locale, race, type)
- Collection methodology changes

---

## Recommended Data Quality Checks

### Before Any Analysis

1. **Check missingness by state** for key variables
2. **Verify year availability** for your variables
3. **Review state notes** for your states of interest
4. **Check for definition changes** if time series

### For Cross-State Comparisons

1. **Document state exclusions** due to data quality
2. **Use consistent definitions** (or document differences)
3. **Consider rankings/percentiles** rather than absolute values
4. **Check suppression rates** by state

### For Longitudinal Analysis

1. **Verify ID stability** across years
2. **Account for definition changes**
3. **Document attrition** from panel
4. **Use NCES crosswalks** for ID changes

### For Disaggregated Analysis

1. **Check suppression rates** for subgroups
2. **Assess sample sizes** before calculating statistics
3. **Consider aggregation** if suppression is high
4. **Document limitations** of disaggregated results

---

## Data Quality Resources

### NCES Documentation

- State notes in each file release
- Reference library crosswalks
- Online documentation
- Technical documentation for each survey

### Quality Indicators in Data

- Imputation flags (indicate imputed values)
- Status codes (indicate reporting status)
- Missing data codes (indicate type of missingness)

### External Validation

Consider validating against:
- State education agency reports
- Census Bureau data
- Other federal surveys

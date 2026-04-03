# Data Quality and Limitations

Reference for understanding coverage gaps, selection bias, and data quality issues in NACUBO endowment data.

> **Portal Scope Note:** These quality considerations apply to both the Portal mirror subset (7 market-value columns) and the full NCSE study. The Portal mirror inherits all limitations of the underlying NACUBO data, including voluntary participation, selection bias, and self-reporting. The Portal mirror covers 2012-2022 (8,197 rows, 652-813 institutions per year with a declining trend).

## Coverage Limitations

### Voluntary Participation

**Critical Limitation**: NACUBO data comes from voluntary survey responses, not mandatory reporting.

| Metric | Value |
|--------|-------|
| U.S. degree-granting institutions | ~4,000+ |
| Institutions with endowments (IPEDS) | ~2,500+ |
| NACUBO survey invitations | ~1,500 |
| Typical NCSE respondents | 650-700 |
| Coverage rate (of institutions) | ~15-20% |
| Coverage rate (of endowed assets) | ~90%+ |

**Key Insight**: NACUBO covers most endowed *assets* but a minority of *institutions* due to asset concentration at large institutions.

### Who is Missing

Institutions less likely to participate:

| Category | Reason | Impact |
|----------|--------|--------|
| Very small endowments | Limited resources for survey | Underrepresentation of small funds |
| Community colleges | Many lack significant endowments | Sector underrepresented |
| For-profit institutions | Generally no endowments | Excluded by design |
| Non-NACUBO members | Less awareness/incentive | Some private schools missing |
| Struggling institutions | May avoid transparency | Survivorship bias |

### Who is Overrepresented

| Category | Reason |
|----------|--------|
| Large endowments | Benchmarking value, resources |
| Research universities | Active investment programs |
| Wealthy private colleges | Endowment-dependent model |
| NACUBO members | Direct survey access |

## Selection Bias

### Participation Bias

Institutions that choose to participate may systematically differ from non-participants:

**Positive Bias Factors**:
- Better-performing endowments may be more willing to report
- Better-resourced institutions more able to complete survey
- Institutions with investment staff more engaged

**Negative Bias Factors**:
- Very top performers may be secretive
- Some institutions avoid any external reporting

### Survivorship Bias

Historical data may exclude:
- Institutions that closed
- Institutions that merged
- Endowments that were spent down

This can make historical returns appear better than actual experience.

### Size-Based Selection

Participation rates vary significantly by endowment size:

| Size Category | Estimated Participation Rate |
|---------------|------------------------------|
| Over $1 Billion | >90% |
| $500M to $1B | ~80% |
| $100M to $500M | ~60% |
| $50M to $100M | ~40% |
| Under $50M | ~20% |

## Self-Reported Data Issues

### Accuracy Concerns

All NCSE data is self-reported with no independent verification:

| Issue | Description | Mitigation |
|-------|-------------|------------|
| Calculation errors | Institutions may calculate metrics differently | Use detailed instructions |
| Timing errors | Returns may be for wrong period | Survey specifies periods |
| Classification errors | Assets may be miscategorized | Provide definitions |
| Rounding | Small variations from rounding | Generally minor |

### Return Reporting Issues

**Private Investment Lag**: Despite instructions to report June 30 returns, some institutions may:
- Use lagged valuations for illiquid assets
- Report returns for periods ending before June 30
- Estimate unrealized gains differently

This can affect comparability, especially for institutions with high alternative allocations.

### Asset Allocation Issues

- Categories have changed over time
- "Other" category varies in composition
- Some institutions may not break out all categories
- Cash and equivalents treatment varies

## Comparability Issues

### Across Institutions

Direct comparisons are complicated by:

| Factor | Issue |
|--------|-------|
| Size | Different investment opportunities by scale |
| Type | Public vs private different constraints |
| Age | Newer programs vs established |
| Risk tolerance | Different mandates and constraints |
| Asset allocation | Different strategies |

### Across Time

Historical comparisons complicated by:

| Period | Issue |
|--------|-------|
| Pre-2000 | Limited alternative investments |
| 2008-2009 | Financial crisis distortions |
| 2020-2021 | COVID market volatility |
| Partner changes | Methodology variations |

### Category Definition Changes

Asset allocation categories have evolved:

| Era | Categories |
|-----|------------|
| 1970s-1980s | Stocks, bonds, cash, real estate |
| 1990s-2000s | Added hedge funds, private equity |
| 2010s | Granular alternatives breakdown |
| 2020s | ESG categories added |

## Data Quality by Variable

### High Quality Variables

| Variable | Quality | Notes |
|----------|---------|-------|
| Market value | High | Audited financial statements |
| Institution type | High | Objective classification |
| Size category | High | Based on market value |

### Medium Quality Variables

| Variable | Quality | Notes |
|----------|---------|-------|
| Investment returns | Medium | Calculation variations |
| Asset allocation | Medium | Classification judgment |
| Spending rate | Medium | Timing/definition issues |

### Lower Quality Variables

| Variable | Quality | Notes |
|----------|---------|-------|
| Governance details | Lower | Subjective responses |
| ESG policies | Lower | Definition varies |
| Strategy descriptions | Lower | Self-characterization |

## IPEDS Comparison

### Overlap with IPEDS

IPEDS Finance survey also collects endowment market values:

| Attribute | NACUBO | IPEDS |
|-----------|--------|-------|
| Mandatory | No | Yes (Title IV) |
| Coverage | ~650 institutions | ~6,500 institutions |
| Asset detail | Yes | No |
| Returns | Yes | No |
| Spending | Yes | Limited |
| Governance | Yes | No |

### When to Use Each

| Research Need | Recommended Source |
|---------------|-------------------|
| All institutions | IPEDS |
| Investment returns | NACUBO |
| Asset allocation | NACUBO |
| Spending analysis | NACUBO |
| Market value trends | Either (check coverage) |
| Small institution focus | IPEDS |
| Large institution detail | NACUBO |

### Reconciliation Issues

NACUBO and IPEDS market values may not match exactly due to:
- Different reporting dates
- Different fund inclusions
- Consolidated vs unconsolidated reporting
- Foundation vs institution reporting

## Addressing Data Limitations

### For Research

1. **Acknowledge limitations** in methodology sections
2. **Use size categories** to control for selection bias
3. **Focus on within-NCSE comparisons** rather than generalizing
4. **Supplement with IPEDS** for coverage concerns
5. **Consider time period** carefully for historical analysis

### For Benchmarking

1. **Compare within size category** only
2. **Compare same institution type**
3. **Use multi-year averages** to reduce noise
4. **Focus on 10-year returns** for performance assessment
5. **Consider asset allocation differences**

### Red Flags in Data

Watch for:
- Extreme return outliers (may be errors)
- Large year-over-year allocation changes (may be reclassification)
- Missing data patterns (may indicate issues)
- Inconsistent market value changes vs returns

## Data Access Constraints

### Public Data

Available at no cost:
- Institution names and market values
- Aggregate averages by size/type
- Historical summary tables

### Restricted Data

Requires purchase or application:
- Individual institution returns (anonymized)
- Detailed asset allocations
- Governance responses
- Full survey responses

### Academic Access

Researchers can request:
- Anonymized institution-level data
- Subject to data use agreement
- Contact: Allison.Kaspriske@commonfund.org

## Quality Improvement Over Time

The study has improved quality through:
- Detailed survey instructions
- Online survey validation
- Outlier detection
- Participant feedback
- Methodology documentation

However, fundamental limitations of voluntary self-reporting remain.

## Recommended Citations

When using NACUBO data, cite:
- Specific study year
- Correct study name (NCSE, NTSE, or NES)
- Partners (NACUBO-Commonfund or NACUBO-TIAA)
- Note voluntary participation and sample size

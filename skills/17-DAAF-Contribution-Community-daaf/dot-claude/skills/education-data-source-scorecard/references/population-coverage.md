# Population Coverage

Understanding who is and isn't included in College Scorecard data is essential for interpreting results correctly. The Title IV limitation fundamentally shapes all Scorecard metrics.

## The Title IV Limitation

### What Title IV Means

Title IV of the Higher Education Act authorizes federal student aid programs:

| Program | Type |
|---------|------|
| Pell Grants | Need-based grant |
| Federal Supplemental Educational Opportunity Grant (FSEOG) | Campus-based grant |
| Federal Work-Study | Campus-based employment |
| Direct Subsidized Loans | Need-based loans |
| Direct Unsubsidized Loans | Non-need-based loans |
| Direct PLUS Loans | Parent and graduate loans |
| Perkins Loans | Campus-based loans (ended 2017) |

### Who Receives Title IV Aid

To receive Title IV aid, students must:
- Be U.S. citizens or eligible non-citizens
- Have a valid Social Security number
- Complete the FAFSA
- Demonstrate eligibility (varies by program)
- Enroll at a Title IV-participating institution
- Make satisfactory academic progress

### Who Is in Scorecard Data

**Included:** Students who received any Title IV federal financial aid
- Pell Grant recipients
- Federal loan borrowers
- Federal work-study participants
- Students with subsidized or unsubsidized loans

**NOT Included:** Students who did not receive any federal aid

## Who Is Excluded

### Students Paying Without Federal Aid

| Group | Why Excluded | Likely Characteristics |
|-------|--------------|----------------------|
| Full-pay students | Didn't need/want federal aid | Higher family income |
| Students with only institutional aid | No FAFSA/federal aid | Varies |
| Students with only state aid | No federal programs | Depends on state |
| Students using 529 plans only | No federal aid needed | Higher wealth |

### Ineligible Students

| Group | Why Excluded |
|-------|--------------|
| International students | Not eligible for Title IV |
| Undocumented students | Not eligible for Title IV |
| Incarcerated students | Limited eligibility |
| Students lacking documentation | Can't complete FAFSA |

### Students Who Chose Not to Apply

| Group | Why No Federal Aid |
|-------|-------------------|
| Low-information students | Didn't know about FAFSA |
| Students fearing debt | Avoided loans |
| Students with privacy concerns | Didn't want to share financial info |
| Late applicants | Missed deadlines |

## Coverage Rates by Institution Type

### Approximate Title IV Coverage

| Institution Type | Typical Coverage | Why |
|-----------------|------------------|-----|
| For-profit colleges | 80-95% | Aid-dependent enrollment |
| Community colleges | 60-80% | Mixed, some don't apply |
| Public 4-year (non-flagship) | 60-75% | State aid available |
| Public flagship | 50-70% | More full-pay students |
| Private non-profit | 50-70% | Institutional aid common |
| Elite/selective private | 30-50% | Many full-pay families |

### Extreme Cases

| Institution | Coverage | Implications |
|-------------|----------|--------------|
| For-profit with >90% | Near-complete | Data fairly representative |
| Elite college with 35% | Large gap | Data excludes most students |
| School with 50% | Half missing | Significant selection bias |

## Selection Bias

### Systematic Differences

Students receiving Title IV aid systematically differ from those who don't:

| Title IV Recipients | Non-Recipients |
|--------------------|----------------|
| Lower family income on average | Higher family income on average |
| More likely first-generation | More likely continuing-generation |
| More likely underrepresented minorities | More likely white/Asian at elite schools |
| More likely to work during school | More likely to not work |
| Different enrollment patterns | Different enrollment patterns |

### Direction of Bias

**Earnings Data:**
- Title IV recipients likely have **lower** average earnings than full student body
- Because: lower family income → lower average post-college earnings
- Selection bias direction: **Scorecard earnings likely understated** for whole institution

**Debt Data:**
- Title IV recipients by definition have debt or aid
- Full-pay students have **zero** federal debt
- Selection bias direction: **Scorecard debt overstated** for whole institution

**Completion Data:**
- Lower-income students face more completion barriers
- Selection bias direction: **Scorecard completion likely understated** for whole institution

## Implications for Analysis

### When Coverage Matters Most

| Analysis Type | Coverage Impact |
|---------------|----------------|
| Institution rankings | High - comparing different populations |
| Field-of-study comparisons | Medium - coverage varies by field |
| Trend analysis | Lower - bias consistent over time |
| Policy analysis | High - depends on policy target |

### Adjusting Expectations

```
Example: Elite Private University
- Scorecard 6-year earnings: $70,000
- Title IV coverage: 40%

Interpretation:
- $70,000 is median for Title IV recipients only
- Non-recipients (60%) likely have higher earnings
- True institutional median likely higher than $70,000
- Scorecard underestimates whole-institution earnings
```

### When Low Coverage Is Acceptable

- Analyzing outcomes specifically for aid recipients
- Policy questions about federal aid programs
- Comparing similar institutions with similar coverage
- Studying student debt (only borrowers have debt anyway)

### When Low Coverage Is Problematic

- Claiming results represent "all graduates"
- Ranking institutions with very different coverage rates
- Making claims about institutional quality overall
- Comparing schools with 90% vs 40% coverage

## Validating Coverage

### IPEDS Comparison

IPEDS reports total enrollment; Scorecard reports Title IV recipients:

```python
import polars as pl

# Estimate coverage rate using count_working from earnings data
# vs IPEDS enrollment
coverage_estimate = scorecard_count / ipeds_total_enrollment

# Flag institutions with low coverage
if coverage_estimate < 0.5:
    print("WARNING: Less than half of students in Scorecard data")
```

### Variables Indicating Coverage

> **Portal note:** Many of these variables are from the original Scorecard bulk downloads. The Portal `student_body_nslds` dataset contains `count_total_FAFSA_applicants` which can be used as a proxy for coverage.

| Variable | Description | Portal Availability |
|----------|-------------|---------------------|
| `count_total_FAFSA_applicants` | Total FAFSA applicants | In `student_body_nslds` dataset |
| `count_family_income` | Count with family income data | In `student_body_nslds` dataset |
| `UGDS` | Undergraduate enrollment | IPEDS directory (join on `unitid`) |
| `PCTFLOAN` | Percent receiving federal loans | Not in Portal Scorecard datasets |
| `PCTPELL` | Percent receiving Pell grants | Not in Portal Scorecard datasets |

### Red Flags for Coverage

- Very low Pell percentage at need-aware institution
- Large discrepancy between IPEDS enrollment and Scorecard counts
- High percentage of international students
- Elite institution with high sticker price

## Graduate Student Coverage

### Unique Graduate Issues

Graduate students in Scorecard:
- Only those with federal loans or aid
- Many graduate students self-funded
- Many funded by assistantships (not Title IV)
- Coverage even lower than undergraduate

### When Graduate Data Available

| Variable Pattern | Applies To |
|-----------------|------------|
| `_ALL` | All students (may include graduate) |
| `_UG` | Undergraduate only |
| `_GRAD` | Graduate only (where available) |

## Recommendations for Handling Coverage

### Always Do

1. **State coverage limitation** in any analysis
2. **Check coverage rates** before comparing institutions
3. **Use relative comparisons** within similar institution types
4. **Acknowledge direction of bias**

### Reporting Template

```
"This analysis uses College Scorecard data, which tracks 
outcomes for students who received federal financial aid 
(Title IV). At [institution], approximately [X]% of students 
receive federal aid. Results may not be representative of 
all students, particularly those from higher-income families 
who attend without federal aid."
```

### For Different Audiences

**Academic/Research:**
- Discuss selection bias explicitly
- Consider sensitivity analyses
- Acknowledge limitations in conclusions

**Policy:**
- Clarify that results apply to aid recipients
- Note implications for policy targeting
- Consider whether policy affects non-recipients

**Consumer/Student:**
- Explain that results are for "students like them" (if they'll get aid)
- Note limitations for full-pay families
- Suggest supplementary data sources

## Supplementary Data Sources

For more complete institutional pictures:

| Source | What It Adds |
|--------|--------------|
| IPEDS | Full enrollment, all students |
| Alumni surveys | Self-reported outcomes, all graduates |
| LinkedIn | Career outcomes (biased toward active users) |
| State longitudinal data | State-specific outcomes, all students |
| Institutional research | Internal data, full student body |

## Key Takeaways

1. **Scorecard = Title IV recipients only** - never claim it represents all students
2. **Coverage varies dramatically** - from 30% to 95% by institution
3. **Selection bias is systematic** - lower-income students overrepresented
4. **Direction depends on metric** - earnings understated, debt overstated, completion understated
5. **Compare carefully** - only between institutions with similar coverage
6. **State limitations** - in every analysis and report

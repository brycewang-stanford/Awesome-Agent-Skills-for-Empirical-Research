# Completion Rates

College Scorecard provides completion metrics that differ significantly from IPEDS graduation rates. Understanding these differences is critical for valid analysis.

> **Portal note:** Completion rate variables (e.g., `C150_4`, `C150_4_POOLED`) are from the original Scorecard naming scheme. The Portal mirror datasets do not include a separate completion rates dataset. Completion data may be embedded in other Scorecard bulk downloads available at `collegescorecard.ed.gov`. The Portal's 6 Scorecard datasets focus on earnings, default, repayment, institutional characteristics, and student body characteristics. For completion rates, consider using the IPEDS graduation rates dataset (`ipeds/colleges_ipeds_grad-rates`).

## Scorecard vs IPEDS: Key Differences

| Aspect | College Scorecard | IPEDS Graduation Rate |
|--------|------------------|----------------------|
| **Population** | Title IV aid recipients | First-time, full-time degree-seeking |
| **Part-time students** | Included | Excluded |
| **Transfer students** | Included (at receiving institution) | Excluded (counted at origin) |
| **Entry timing** | Any entry during year | Fall cohort only |
| **Data source** | NSLDS tracking | Institution-reported |
| **Completion anywhere** | Can track to any institution | Same institution only |

### Why This Matters

**IPEDS tends to undercount success** for:
- Transfer students (success at new school doesn't count)
- Part-time students (not in cohort)
- Spring/summer entrants (not in fall cohort)

**Scorecard captures these students** but only tracks Title IV recipients.

## Scorecard Completion Cohorts

### Who Is Included

Students in Scorecard completion cohorts:
- Received Title IV aid
- First-time undergraduate enrollment
- Both full-time AND part-time
- All entry terms (not just fall)

### Who Is Excluded

| Excluded Group | Why |
|----------------|-----|
| Non-Title IV students | Not in NSLDS |
| Transfer students (at origin) | Counted at receiving institution |
| Continuing students | Only first-time undergraduates |

## Completion Time Frames

### Standard Metrics

| Variable | Time Frame | Applicable To |
|----------|-----------|---------------|
| `C150_4` | 150% of normal time | 4-year institutions |
| `C150_L4` | 150% of normal time | Less-than-4-year institutions |
| `C200_4` | 200% of normal time | 4-year institutions |
| `C200_L4` | 200% of normal time | Less-than-4-year institutions |

### What "150% Normal Time" Means

| Program Length | 150% Time | Example |
|---------------|-----------|---------|
| 4-year degree | 6 years | Bachelor's: 6 years to complete |
| 2-year degree | 3 years | Associate's: 3 years to complete |
| 1-year certificate | 1.5 years | Certificate: 18 months |

### Extended Time Frames

| Variable | Description |
|----------|-------------|
| `COMP_ORIG_YR2_RT` | Completion rate within 2 years |
| `COMP_ORIG_YR3_RT` | Completion rate within 3 years |
| `COMP_ORIG_YR4_RT` | Completion rate within 4 years |
| `COMP_ORIG_YR6_RT` | Completion rate within 6 years |
| `COMP_ORIG_YR8_RT` | Completion rate within 8 years |

## Completion Variables

### Institution-Level

| Variable | Description |
|----------|-------------|
| `C150_4` | 150% completion rate, 4-year |
| `C150_L4` | 150% completion rate, <4-year |
| `C150_4_POOLED` | Pooled 150% rate, 4-year |
| `C150_4_POOLED_SUPP` | Suppression indicator |

### By Student Characteristics

| Variable Pattern | Description |
|-----------------|-------------|
| `C150_4_WHITE` | Completion by race |
| `C150_4_HISP` | Hispanic students |
| `C150_4_BLACK` | Black students |
| `C150_4_2MOR` | Two or more races |
| `C150_4_PELL` | Pell Grant recipients |
| `C150_4_LOAN` | Loan recipients |
| `C150_4_NRA` | Non-resident aliens |

### By Completion Status

| Variable | Description |
|----------|-------------|
| `COMPL_RPY_*` | Completers repayment rate |
| `NONCOM_RPY_*` | Non-completers repayment rate |
| `COMP_ORIG_YR*_RT` | Completion by year |

## Pooled vs Annual Cohorts

### Annual Cohorts

- Single entry year
- Higher suppression rates
- More volatility

### Pooled Cohorts

- Multiple entry years combined
- Lower suppression rates
- More stable estimates
- Variables contain `_POOLED`

**Recommendation:** Use pooled cohorts when available for more reliable estimates.

## Transfer-Adjusted Completion

### Transfer Tracking

Scorecard can track completion at ANY institution because NSLDS follows students:

| Scenario | IPEDS | Scorecard |
|----------|-------|-----------|
| Start at CC, complete at 4-year | Counts as non-completer at CC, not counted at 4-year | Counted as completion |
| Start at School A, transfer to School B, complete | Non-completer at A, not in cohort at B | Counted as completion |

### Transfer-Out Rate

| Variable | Description |
|----------|-------------|
| `TRANS_4_POOLED` | Transfer rate, 4-year |
| `TRANS_L4_POOLED` | Transfer rate, <4-year |

## Completion by Pell Status

Critical for equity analysis:

| Variable | Description |
|----------|-------------|
| `C150_4_PELL` | Completion rate, Pell recipients |
| `C150_4_NOPELL` | Completion rate, non-Pell |
| `PELL_COMP_ORIG_YR*_RT` | Pell completion by year |

### Pell Completion Gap

Most institutions show completion gaps:
- Pell recipients typically complete at lower rates
- Gap size varies by institution type
- Closing this gap is policy priority

## Outcome Measures Beyond Completion

### Completion OR Transfer

| Variable | Description |
|----------|-------------|
| `OMACHT6_FTFT` | Completed or transferred within 6 years, FTFT |
| `OMACHT8_FTFT` | Completed or transferred within 8 years, FTFT |

### Still Enrolled

| Variable | Description |
|----------|-------------|
| `ENRL_ORIG_YR*_RT` | Still enrolled at N years |

### Withdrawal

| Variable | Description |
|----------|-------------|
| `WDRAW_ORIG_YR*_RT` | Withdrawal rate by year |

## Interpreting Completion Rates

### Low Completion Rate May Indicate

| Possibility | Implication |
|-------------|-------------|
| Poor student support | Negative |
| Serves at-risk population | Context needed |
| High transfer-out rate | May complete elsewhere |
| Part-time student body | Takes longer to complete |
| Open admissions | Broader access mission |

### High Completion Rate May Indicate

| Possibility | Implication |
|-------------|-------------|
| Strong student support | Positive |
| Selective admissions | Prepared students |
| Traditional student body | Full-time, on-campus |
| Favorable demographics | May not be replicable |

## Comparing Completion Rates

### Valid Comparisons

- Similar institution types (4-year public to 4-year public)
- Similar missions (open-access to open-access)
- Same time frame (150% to 150%)
- Same cohort definition (Scorecard to Scorecard)

### Invalid Comparisons

| Comparison | Problem |
|------------|---------|
| Scorecard to IPEDS | Different cohort definitions |
| 4-year to 2-year | Different time expectations |
| Selective to open-access | Different student preparation |
| Annual to pooled | Different aggregation |

## Suppression in Completion Data

### When Suppression Occurs

| Condition | Action |
|-----------|--------|
| < 30 students in cohort | Rate suppressed |
| Small subgroup cells | Disaggregated rates suppressed |
| Very small programs | May lack any completion data |

### Variables Indicating Suppression

> **Note:** Completion rate variables from the original Scorecard use various suppression indicators. In Portal mirror data, check the actual data for suppression patterns — some datasets use `null`, others use `-3`. Always verify against the codebook (use `get_codebook_url()` from `fetch-patterns.md`).

| Data Pattern | Meaning | Notes |
|--------------|---------|-------|
| `null` | Suppressed or missing | Common in rate columns |
| `-3` | Suppressed for privacy | Common in earnings/count columns |
| Valid rate (0-1) | Actual completion rate | Valid data |

## Recommended Practices

### For Completion Analysis

1. **Know your cohort** - Scorecard ≠ IPEDS
2. **Use pooled rates** when available for stability
3. **Consider transfers** - Low completion may mean high transfer
4. **Check suppression** - Small cohorts may lack data
5. **Note Title IV limitation** - Only aid recipients included

### For Equity Analysis

1. **Disaggregate by Pell status** - Critical equity indicator
2. **Compare gaps within institution types**
3. **Consider context** - Access vs completion trade-offs
4. **Use multiple years** - Single-year data volatile

### Reporting Recommendations

```
Adequate: "The 6-year graduation rate is 65%"

Better: "The 6-year completion rate for Title IV aid recipients 
        (150% time) is 65%, per College Scorecard"

Best: "The 6-year completion rate for Title IV aid recipients is 65% 
      (150% of normal time). This differs from IPEDS graduation rates 
      which track first-time, full-time students only. Completion rates 
      for Pell recipients (55%) trail non-Pell recipients (72%)."
```

## Common Pitfalls

| Pitfall | Why It's Wrong |
|---------|---------------|
| Comparing Scorecard to IPEDS rates | Different populations tracked |
| Ignoring transfer-out rates | Students may complete elsewhere |
| Treating all institutions equally | Mission and selectivity vary |
| Using annual rates for small schools | High volatility, suppression |
| Ignoring equity gaps | Overall rates mask disparities |

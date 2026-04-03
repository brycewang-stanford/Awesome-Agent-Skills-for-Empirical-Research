# Statistical Reporting Standard

## Minimum reporting package

For every major comparison, report:
- metric definition and direction,
- unit of analysis,
- sample size / run count,
- descriptive statistics,
- uncertainty estimate,
- inferential test,
- effect size,
- correction strategy when multiple contrasts exist,
- limitation if assumptions or sample size are weak.

## Required fields

### Descriptive
- `mean ± std` when repeated runs are comparable
- `95% CI` when inference is discussed
- median / IQR when distribution is strongly non-normal

### Inferential
- exact test name
- test statistic and degrees of freedom when applicable
- p-value format
- effect size
- correction method for multiple comparisons

## Do not do these
- report only best run
- report only p-values
- hide non-significant comparisons
- treat unstable trends as conclusions
- switch tests without stating why

## Default wording rule

Use three layers:
1. **Observation** — what changed numerically
2. **Support** — what the test/effect size says
3. **Boundary** — what remains uncertain

# Card (1995) — Returns to schooling, replication

# §1. Descriptive statistics

## Table 1. Summary statistics

|          |    Mean |   Std. Dev. |    N |
|:---------|--------:|------------:|-----:|
| lwage    |   6.262 |       0.444 | 3010 |
| wage     | 577.282 |     262.958 | 3010 |
| educ     |  13.263 |       2.677 | 3010 |
| exper    |   8.856 |       4.142 | 3010 |
| age      |  28.12  |       3.137 | 3010 |
| black    |   0.234 |       0.423 | 3010 |
| south    |   0.404 |       0.491 | 3010 |
| smsa     |   0.713 |       0.452 | 3010 |
| smsa66   |   0.65  |       0.477 | 3010 |
| fatheduc |  10.003 |       3.721 | 2320 |
| motheduc |  10.348 |       3.18  | 2657 |
| IQ       | 102.45  |      15.424 | 2061 |

## Table 1b. Balance by college proximity

**Table 1b. Balance by college proximity**

| | Control | Treated | Diff | p-value |
|---|---:|---:|---:|---:|
| educ | 12.698 (2.792) | 13.527 (2.580) | 0.829*** | 0.000 |
| exper | 9.230 (4.282) | 8.682 (4.064) | -0.548*** | 0.001 |
| black | 0.280 (0.449) | 0.212 (0.409) | -0.068*** | 0.000 |
| south | 0.563 (0.496) | 0.329 (0.470) | -0.234*** | 0.000 |
| smsa | 0.479 (0.500) | 0.822 (0.382) | 0.344*** | 0.000 |
| smsa66 | 0.328 (0.470) | 0.799 (0.401) | 0.471*** | 0.000 |
| fatheduc | 9.222 (3.868) | 10.357 (3.598) | 1.135*** | 0.000 |
| motheduc | 9.940 (3.307) | 10.533 (3.103) | 0.594*** | 0.000 |
| N | 957 | 2,053 | | |

*\* p<0.10, \*\* p<0.05, \*\*\* p<0.01*

# §2-3. Empirical strategy

## Methods

We estimate the Mincer wage equation by OLS and instrument years of schooling with a binary indicator for growing up in a county with a 4-year college (Card, 1995). All controls and region dummies follow Card's Table 2.

# §4. Main results

## Table 2. OLS Mincer wage equation

**Table 2. OLS Mincer wage equation**

| | (1) | (2) | (3) | (4) |
|---|---:|---:|---:|---:|
| educ | 0.052*** | 0.093*** | 0.074*** | 0.075*** |
| | (0.003) | (0.004) | (0.004) | (0.004) |
| N | 3,010 | 3,010 | 3,010 | 3,010 |
| R² | 0.099 | 0.196 | 0.291 | 0.300 |

*Standard errors in parentheses*
** p<0.10, ** p<0.05, *** p<0.01*

## Table 2-bis. IV reporting triplet

**Table 2-bis. IV reporting triplet**

| | First stage | Reduced form | 2SLS |
|---|---:|---:|---:|
| nearc4 | 0.320*** | 0.042** |  |
| | (0.085) | (0.018) |  |
| educ |  |  | 0.132** |
| |  |  | (0.054) |
| First-stage F |  |  | 13.26 |
| N | 3,010 | 3,010 | 3,010 |
| R² | 0.477 | 0.195 | 0.238 |
| Adj. R² | 0.474 | 0.191 |  |
| F | 182.129 | 48.254 |  |

*Standard errors in parentheses*
** p<0.10, ** p<0.05, *** p<0.01*

# §5. Heterogeneity

## Table 3. Heterogeneous effects

**Table 3. Heterogeneous effects**

| | (1) All | (2) Black | (3) Non-black | (4) South | (5) Non-south | (6) SMSA | (7) Non-SMSA |
|---|---:|---:|---:|---:|---:|---:|---:|
| educ | 0.074*** | 0.071*** | 0.074*** | 0.259 | 0.070*** | 0.075*** | 0.070*** |
| | (0.004) | (0.008) | (0.004) | () | (0.005) | (0.004) | (0.007) |
| N | 3,010 | 703 | 2,307 | 1,215 | 1,795 | 2,146 | 864 |
| R² | 0.291 | 0.266 | 0.216 | -0.609 | 0.187 | 0.233 | 0.294 |
| Adj. R² | 0.289 | 0.260 | 0.214 | -0.617 | 0.185 | 0.231 | 0.289 |
| F | 204.932 | 42.099 | 105.401 | -76.191 | 68.674 | 108.488 | 59.603 |

*Standard errors in parentheses*
** p<0.10, ** p<0.05, *** p<0.01*

# §7. Robustness

## Table A1. Robustness gauntlet

**Table A1. Robustness gauntlet**

| | (1) Baseline OLS | (2) +Family bg | (3) Drop top 1% wage | (4) Drop bottom 1% wage | (5) Black only | (6) Non-black | (7) IQ-controlled | (8) 2SLS (nearc4) | (9) 2SLS (nearc2+nearc4) | (10) DML-PLR |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| educ | 0.075*** | 0.074*** | 0.069*** | 0.072*** | 0.071*** | 0.074*** | 0.070*** | 0.132** | 0.157*** |  |
| | (0.004) | (0.005) | (0.004) | (0.004) | (0.008) | (0.004) | (0.005) | (0.054) | (0.053) |  |
| First-stage F |  |  |  |  |  |  |  | 13.26 | 7.89 |  |
| Hansen J p-value |  |  |  |  |  |  |  |  | 0.264 |  |
| N | 3,010 | 2,220 | 2,977 | 2,977 | 703 | 2,307 | 2,061 | 3,010 | 3,010 | 3,010 |
| R² | 0.300 | 0.274 | 0.285 | 0.296 | 0.266 | 0.216 | 0.237 | 0.238 | 0.170 |  |
| Adj. R² | 0.296 | 0.269 | 0.281 | 0.292 | 0.260 | 0.214 | 0.231 |  |  |  |
| F | 85.476 | 48.967 | 78.534 | 83.021 | 42.099 | 105.401 | 39.663 |  |  |  |

*Standard errors in parentheses*
** p<0.10, ** p<0.05, *** p<0.01*

## Notes

Heteroskedasticity-robust standard errors (HC1) in parentheses. *** p<0.01, ** p<0.05, * p<0.10. Sample restrictions and variable definitions documented in artifacts/sample_construction.json and artifacts/data_contract.json.

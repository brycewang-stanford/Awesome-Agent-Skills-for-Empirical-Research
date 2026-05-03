# Lalonde NSW Replication — StatsPAI v2 Pipeline

# §1. Descriptive statistics

## Table 1. Summary statistics by treatment

|          |     Mean |   Std. Dev. |   N |
|:---------|---------:|------------:|----:|
| re78     | 6792.83  |    7470.73  | 614 |
| age      |   27.363 |       9.881 | 614 |
| educ     |   10.269 |       2.628 | 614 |
| black    |    0.396 |       0.489 | 614 |
| hispan   |    0.117 |       0.322 | 614 |
| married  |    0.415 |       0.493 | 614 |
| nodegree |    0.63  |       0.483 | 614 |
| re74     | 4557.55  |    6477.96  | 614 |
| re75     | 2184.94  |    3295.68  | 614 |

## Table 1b. Balance by treatment

**Table 1b. Balance by treatment**

| | Control | Treated | Diff | p-value |
|---|---:|---:|---:|---:|
| age | 28.030 (10.787) | 25.816 (7.155) | -2.214*** | 0.003 |
| educ | 10.235 (2.855) | 10.346 (2.011) | 0.111 | 0.585 |
| black | 0.203 (0.403) | 0.843 (0.365) | 0.640*** | 0.000 |
| hispan | 0.142 (0.350) | 0.059 (0.237) | -0.083*** | 0.001 |
| married | 0.513 (0.500) | 0.189 (0.393) | -0.324*** | 0.000 |
| nodegree | 0.597 (0.491) | 0.708 (0.456) | 0.111*** | 0.007 |
| re74 | 5619.237 (6788.751) | 2095.574 (4886.620) | -3523.663*** | 0.000 |
| re75 | 2466.484 (3291.996) | 1532.055 (3219.251) | -934.429*** | 0.001 |
| N | 429 | 185 | | |

*\* p<0.10, \*\* p<0.05, \*\*\* p<0.01*

# §4. Main results

## Table 2. Progressive controls (Pattern A)

**Table 2. Progressive controls (Pattern A)**

| | (1) Baseline | (2) +Demog. | (3) +Race | (4) +Marital/Edu | (5) +Earn. hist. |
|---|---:|---:|---:|---:|---:|
| Job training (β̂) | -635.026 | -480.729 | 821.954 | 1163.922 | 1548.244** |
| | (676.748) | (662.516) | (733.269) | (741.281) | (740.576) |
| N | 614 | 614 | 614 | 614 | 614 |
| R² | 0.002 | 0.043 | 0.056 | 0.071 | 0.148 |
| DV mean |  |  |  |  |  |

*Standard errors in parentheses*
**** p<0.01, ** p<0.05, * p<0.10*

# §5. Heterogeneity

## Table 3. Subgroup heterogeneity

**Table 3. Subgroup heterogeneity**

| | (1) All | (2) Black | (3) Non-black | (4) Married | (5) Unmarried | (6) HS dropout | (7) Has degree | (8) re74 > 0 |
|---|---:|---:|---:|---:|---:|---:|---:|---:|
| Training | 1548.244** | 1371.454 | 1806.983 | 3046.002* | 1052.227 | 1082.432 | 2597.122* | -1293.622 |
| | (740.576) | (927.942) | (1321.279) | (1670.884) | (804.743) | (879.124) | (1374.305) | (1122.589) |
| N | 614 | 243 | 371 | 255 | 359 | 387 | 227 | 371 |
| R² | 0.148 | 0.062 | 0.216 | 0.270 | 0.049 | 0.077 | 0.243 | 0.244 |
| Adj. R² | 0.135 | 0.026 | 0.196 | 0.243 | 0.024 | 0.055 | 0.211 | 0.225 |
| F | 11.636 | 1.718 | 11.032 | 10.083 | 1.981 | 3.497 | 7.732 | 12.930 |

*Standard errors in parentheses*
**** p<0.01, ** p<0.05, * p<0.10*

# §7. Robustness

## Table A1. Robustness master

**Table A1. Robustness master**

| | (1) Baseline | (2) Drop top 1% re78 | (3) re74 > 0 only | (4) Drop nodegree | (5) log(1+re78) | (6) PSM | (7) AIPW | (8) DML-PLR | (9) Ebalance |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| Training (β̂) | 1548.244** | 747.338 | -1293.622 | 1569.957** | 0.893** |  |  |  |  |
| | (740.576) | (647.554) | (1122.589) | (744.447) | (0.403) |  |  |  |  |
| N | 614 | 596 | 371 | 614 | 614 | 614 | 614 | 614 | 614 |
| R² | 0.148 | 0.096 | 0.244 | 0.148 | 0.082 |  |  |  |  |
| Adj. R² | 0.135 | 0.082 | 0.225 | 0.136 | 0.068 |  |  |  |  |
| F | 11.636 | 6.902 | 12.930 | 13.098 | 5.961 |  |  |  |  |

*Standard errors in parentheses*
**** p<0.01, ** p<0.05, * p<0.10*

## Notes

Standard errors: HC1 robust. Stars: * p<0.10, ** p<0.05, *** p<0.01. Sample restrictions in artifacts/sample_construction.json. Data contract in artifacts/data_contract.json. StatsPAI 1.12.2, seed=7.

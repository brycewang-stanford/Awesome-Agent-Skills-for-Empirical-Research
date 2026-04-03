# svy Design and Weights Reference

svy v0.13.0 — syntax and library guidance only.

---

## Contents

1. [Core Concepts](#core-concepts)
2. [Creating a Taylor Linearization Design](#creating-a-taylor-linearization-design)
3. [Creating a Replicate Weight Design](#creating-a-replicate-weight-design)
4. [Finite Population Correction (FPC)](#finite-population-correction-fpc)
5. [Weight Types and Selection](#weight-types-and-selection)
6. [Calibration and Post-Stratification](#calibration-and-post-stratification)
7. [Singleton PSU Handling](#singleton-psu-handling)
8. [Reading Survey Data Files](#reading-survey-data-files)
9. [Federal Survey Design Quick-Reference](#federal-survey-design-quick-reference)
10. [Combining Survey Cycles](#combining-survey-cycles)
11. [Polars Integration Notes](#polars-integration-notes)
12. [Migration from samplics](#migration-from-samplics)

---

## Core Concepts

Every svy analysis starts with two objects:

1. **`svy.Design`** — describes the sampling structure (how units were selected)
2. **`svy.Sample`** — binds data to a design, enabling estimation

The design determines how variance is estimated. Two approaches:

| Approach | When to Use | What You Need |
|----------|-------------|---------------|
| **Taylor linearization** | Default; most common | Stratum, PSU, and weight columns in the data |
| **Replicate weights** | When provided by data producer, or when Taylor assumptions are problematic | Pre-computed replicate weight columns + main weight |

Both produce valid design-based inference. Taylor linearization requires design variables (strata, PSU); replicate weights encode the design information within the weight columns themselves.

---

## Creating a Taylor Linearization Design

Taylor linearization (also called the "ultimate cluster" method) is the default and most common approach. It requires knowing the stratification and primary sampling unit (PSU) variables.

### Minimal Design (Weight Only)

```python
import svy

# Simple random sample with unequal weights
design = svy.Design(wgt="weight")
sample = svy.Sample(data=data, design=design)
```

This assumes no stratification and no clustering — only unequal selection probabilities. Variance is computed using a with-replacement approximation.

### Stratified Design (No Clustering)

```python
# Stratified random sample
design = svy.Design(stratum="region", wgt="weight")
sample = svy.Sample(data=data, design=design)
```

### Clustered Design (No Stratification)

```python
# Cluster sample (e.g., schools as PSUs)
design = svy.Design(psu="school_id", wgt="weight")
sample = svy.Sample(data=data, design=design)
```

### Full Complex Design (Stratified Clustered)

```python
# Complex multi-stage design — most federal surveys
design = svy.Design(
    stratum="sdmvstra",
    psu="sdmvpsu",
    wgt="wtmec2yr"
)
sample = svy.Sample(data=data, design=design)
```

### Multiple Stratification Variables

Some designs have nested stratification (e.g., region within urban/rural):

```python
# Multiple strata specified as a tuple
design = svy.Design(
    stratum=("region_id", "urban_rural"),
    psu="psu_id",
    wgt="final_weight"
)
sample = svy.Sample(data=data, design=design)
```

### svy.Design Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `stratum` | `str` or `tuple[str, ...]` | Stratification variable(s). Optional. |
| `psu` | `str` | Primary sampling unit (cluster) variable. Optional. |
| `wgt` | `str` | Survey weight column name. Required. |
| `pop_size` | `str` | Finite population correction column name. Optional. See FPC section. **Non-functional in v0.13.0.** |

---

## Creating a Replicate Weight Design

When the data provider supplies replicate weights (common for public-use files from NCES, Census, BLS), use them instead of Taylor linearization. Replicate weights encode the design information and often provide more accurate variance estimates for complex statistics.

### Bootstrap Replicate Weights

```python
# Create a RepWeights object specifying the column prefix, count, and method
rep_wgts = svy.RepWeights(
    prefix="pwgtp",                       # Column name prefix (matches pwgtp1, pwgtp2, ...)
    n_reps=80,                            # Number of replicate weight columns
    method=svy.EstimationMethod.BOOTSTRAP # Replication method
)
design = svy.Design(
    wgt="pwgtp",                          # Main analysis weight
    rep_wgts=rep_wgts                     # RepWeights object
)
sample = svy.Sample(data=data, design=design)
```

### BRR (Balanced Repeated Replication) Weights

```python
rep_wgts = svy.RepWeights(
    prefix="brr_wt",                      # Column name prefix (matches brr_wt1, brr_wt2, ...)
    n_reps=64,                            # Number of replicate weight columns
    method=svy.EstimationMethod.BRR       # BRR method
)
design = svy.Design(wgt="finalwgt", rep_wgts=rep_wgts)
sample = svy.Sample(data=data, design=design)
```

### Fay's BRR Modification

Fay's method is a variant of BRR that perturbs rather than deletes half-samples, reducing instability for small domains. The Fay coefficient (rho) is typically between 0.3 and 0.5.

```python
rep_wgts = svy.RepWeights(
    prefix="brr_wt",
    n_reps=64,
    method=svy.EstimationMethod.BRR,
    fay_coef=0.5                          # Fay's rho (parameter name is fay_coef)
)
design = svy.Design(wgt="finalwgt", rep_wgts=rep_wgts)
sample = svy.Sample(data=data, design=design)
```

### Jackknife Replicate Weights

```python
rep_wgts = svy.RepWeights(
    prefix="jk_wt",
    n_reps=50,
    method=svy.EstimationMethod.JACKKNIFE # JKn (delete-one-PSU jackknife)
)
design = svy.Design(wgt="finalwgt", rep_wgts=rep_wgts)
sample = svy.Sample(data=data, design=design)
```

Jackknife methods:
- **JK1**: Delete-one jackknife (unstratified designs)
- **JKn**: Delete-one-PSU jackknife (stratified designs — most common)

### Replicate Weight Column Specification

Replicate weight columns are specified through the `svy.RepWeights` object using a `prefix` and `n_reps` count. The prefix must match the column naming pattern in the data (e.g., prefix `"pwgtp"` matches columns `pwgtp1`, `pwgtp2`, ..., `pwgtp80`).

```python
# Specify columns by prefix and count
rep_wgts = svy.RepWeights(prefix="pwgtp", n_reps=80, method=svy.EstimationMethod.BOOTSTRAP)
design = svy.Design(wgt="pwgtp", rep_wgts=rep_wgts)
```

**Available `EstimationMethod` values:** `TAYLOR`, `BRR`, `BOOTSTRAP`, `JACKKNIFE`, `SDR`

### When to Use Replicate Weights vs. Taylor

| Scenario | Recommended Method |
|----------|-------------------|
| Replicate weights provided in the data | Use replicate weights |
| Only design variables available (strata, PSU) | Use Taylor linearization |
| Estimating medians or other nonsmooth statistics | Prefer replicate weights (more robust) |
| Complex derived statistics (ratios of subgroup estimates) | Prefer replicate weights |
| Want to match published estimates exactly | Use whichever method the publisher used |
| No design information at all | Cannot do design-based inference — reconsider |

---

## Finite Population Correction (FPC)

The FPC adjusts variance estimates when a substantial fraction of the population is sampled (typically > 5-10%). Without FPC, variance estimates are conservative (too large).

```python
# The Design parameter for FPC is `pop_size` (not `fpc`):
design = svy.Design(
    stratum="stratum",
    psu="psu_id",
    wgt="weight",
    pop_size="pop_size"                   # Column name containing population size
)
sample = svy.Sample(data=data, design=design)
```

> **Known issue (v0.13.0):** The `pop_size` parameter is accepted by `svy.Design` as a column name string (type `str | None`), but `Sample._calculate_fpc()` performs `isinstance(value, Number)` on the raw string rather than resolving the column from the DataFrame, causing a `TypeError`. FPC is non-functional in 0.13.0. **Workaround:** Omit `pop_size` and note in your analysis that variance estimates are conservative (not FPC-adjusted). If FPC is critical, apply the finite population correction factor manually to variance estimates. Monitor future releases for a fix.

**When to apply FPC:**
- Sampling fraction > 5% of the population within strata
- Self-representing (certainty) strata where all units are selected
- Small population surveys (e.g., all schools in a small state)

**When to skip FPC:**
- Large national surveys sampling << 1% of the population (NHANES, CPS, etc.)
- When population size is unknown
- When a conservative variance estimate is acceptable

---

## Weight Types and Selection

### Common Weight Types in Federal Surveys

| Weight Type | Purpose | When to Use |
|-------------|---------|-------------|
| **Base weight** | Inverse of selection probability (1/pi) | Rarely used directly; starting point for adjustments |
| **Nonresponse-adjusted weight** | Base weight adjusted for unit nonresponse | When nonresponse adjustment is the final step |
| **Post-stratified / calibrated weight** | Adjusted to match population totals | Most analyses — this is usually the "final" weight |
| **Replicate weight** | Perturbed version of the final weight for variance estimation | Used alongside the main weight for replicate variance |
| **Subsample weight** | Weight for a subset who completed additional measures | When analyzing variables only collected from the subsample |

### Choosing the Right Weight

1. **Identify the analysis population**: Which respondents have non-missing data for your variables?
2. **Match the weight to the population**: Use the weight designed for that subset
3. **Consult the survey documentation**: Weight variable names and usage instructions are survey-specific

**Example — NHANES weight selection:**
- Interview data only: use `wtint2yr` (interview weight)
- Examination data: use `wtmec2yr` (MEC exam weight)
- Fasting subsample: use `wtsaf2yr` (fasting subsample weight)
- Diet recall (day 1): use `wtdrd1` (dietary day 1 weight)

Using the wrong weight produces biased estimates. The weight must correspond to the most restrictive component of data collection used in your analysis.

---

## Calibration and Post-Stratification

svy supports weight adjustment methods to improve estimates by incorporating known population totals.

### Post-Stratification

Post-stratification adjusts weights so that weighted sample totals match known population totals (e.g., Census counts by age/sex/race).

```python
# Post-stratification via the weighting accessor
sample = sample.weighting.poststratify(
    controls={"18-34": 50_000_000, "35-64": 60_000_000, "65+": 40_000_000},
    by="age_group"
)
```

### Raking (Iterative Proportional Fitting)

Raking adjusts weights to match marginal distributions of multiple variables simultaneously.

```python
# Raking via the weighting accessor — controls is a dict of {variable: {level: target_total}}
sample = sample.weighting.rake(
    controls={
        "gender": {"Male": 160_000_000, "Female": 165_000_000},
        "age_group": {"18-34": 50_000_000, "35-64": 60_000_000, "65+": 40_000_000},
        "region": {"NE": 55_000_000, "MW": 65_000_000, "S": 75_000_000, "W": 80_000_000},
    }
)
```

### GREG (Generalized Regression Estimator)

GREG calibration uses a regression model to adjust weights, incorporating both categorical and continuous auxiliary variables.

```python
# GREG calibration via the weighting accessor
sample = sample.weighting.calibrate(
    controls={svy.Cat("gender"): {"Male": 160_000_000, "Female": 165_000_000}}
)
```

**Note:** Calibration is typically performed by the data producer before public release. Analysts working with public-use files usually do not need to calibrate — the provided weights already incorporate these adjustments. Only calibrate if you are working with raw sampling weights or need to adjust for a specific target population.

---

## Singleton PSU Handling

A "singleton PSU" (or "lonely PSU") occurs when a stratum contains only one primary sampling unit. This makes within-stratum variance undefined, because variance estimation requires at least two PSUs per stratum.

### Common Causes

- Rare subpopulations where domain estimation leaves some strata with only one PSU
- Data subsetting that removes PSUs from strata
- Design strata that genuinely have only one PSU (certainty selections)

### Handling Options

Singleton handling is on the `sample.singleton` accessor, not on `Design`:

```python
# Detect singleton strata
if sample.singleton.exists():
    print(sample.singleton.summary())

    # Handle singletons — choose one method:
    sample = sample.singleton.certainty()    # zero variance contribution (for true certainty strata)
    sample = sample.singleton.center()       # center at grand mean (equivalent to R's "adjust")
    sample = sample.singleton.combine()      # combine singleton strata
    sample = sample.singleton.collapse()     # collapse into other strata
    sample = sample.singleton.pool()         # pool with neighboring strata
    sample = sample.singleton.scale()        # scale variance contribution
    sample = sample.singleton.skip()         # skip singleton strata
```

**`SingletonHandling` enum values:** `ERROR`, `CERTAINTY`, `SKIP`, `COMBINE`, `COLLAPSE`, `POOL`, `SCALE`, `CENTER`

**Best practice:** The `center()` or `pool()` approach is generally safest. The `certainty()` approach (zero variance contribution) is appropriate only when the stratum truly is a certainty selection. Always report how singleton PSUs were handled.

### Prevention

- Avoid domain estimation on very small subgroups
- If subsetting is necessary, consider collapsing strata before analysis
- Use replicate weights when available (the replication method handles singletons implicitly)

---

## Reading Survey Data Files

svy provides `svy.io` methods for reading common survey data formats. These return Polars DataFrames.

### Stata (.dta)

```python
data = svy.io.read_stata("nhanes_2017_2020.dta")
```

Most federal surveys distribute data in Stata format. Value labels and variable labels may be preserved as metadata.

### SAS (.sas7bdat)

```python
data = svy.io.read_sas("meps_h233.sas7bdat")
```

MEPS and some NCES surveys use SAS format. Ensure the SAS format catalog (.sas7bcat) is in the same directory if needed for value labels.

### SPSS (.sav)

```python
data = svy.io.read_spss("ecls_k_2011.sav")
```

NCES surveys (ECLS-K, ELS, HSLS) often distribute data in SPSS format.

### CSV with Metadata

```python
data = svy.io.read_csv("survey_data.csv", metadata="codebook.json")
```

### Parquet (Via Polars Directly)

svy does not have a dedicated parquet reader — use Polars directly:

```python
import polars as pl
data = pl.read_parquet("data/raw/survey_data.parquet")
```

In DAAF research pipelines, data is typically stored as parquet after initial conversion. Use `svy.io` for the initial read from the original format, then save as parquet for subsequent use.

---

## Federal Survey Design Quick-Reference

A quick-reference table for setting up svy designs for commonly used federal surveys. **Always verify against the current survey documentation** — design variable names can change across survey cycles.

| Survey | Strata | PSU | Weight(s) | Variance Method | Notes |
|--------|--------|-----|-----------|-----------------|-------|
| **NHANES** | `sdmvstra` | `sdmvpsu` | `wtmec2yr`, `wtint2yr`, subsample weights | Taylor | Pseudo-strata/PSU for confidentiality; use appropriate weight for analysis domain |
| **ACS PUMS** | None (use replicate weights) | None | `pwgtp` (person) / `wgtp` (household) | Bootstrap (80 reps) | `pwgtp1`-`pwgtp80` replicate weights; no design variables in public-use file |
| **CPS ASEC** | `gestfips` + `gtco` (approx.) | Implicit | `marsupwt` (March supplement) | Replicate (160 reps) | Replicate weights preferred; design variables partially available |
| **MEPS** | `varstr` | `varpsu` | `perwt__f` (person), `famwt__f` (family) | Taylor | Panel design; weight suffix varies by year |
| **ECLS-K:2011** | Survey-specific strata var | Survey-specific PSU var | Multiple (round-specific) | Taylor or JKn | Consult documentation for variable names per round; NCES provides jackknife replicate weights |
| **BRFSS** | `_ststr` | `_psu` | `_llcpwt` (landline + cell) | Taylor | State-level stratification; combined landline/cell design post-2011 |
| **NHIS** | `strat_p` | `psu_p` | `wtfa_sa` (sample adult) | Taylor | Redesigned in 2019; variable names differ pre/post redesign |
| **NSDUH** | Provided | Provided | `analwt_c` | Taylor | Design variables vary by public-use file version |

### NHANES Example

```python
import svy
import polars as pl

data = pl.read_parquet("data/raw/nhanes_demo.parquet")

# INTENT: Standard NHANES complex design for MEC-examined participants
# REASONING: sdmvstra and sdmvpsu are masked design variables;
#   wtmec2yr is the 2-year MEC exam weight for exam-based analyses
# ASSUMES: All analysis variables were collected during the MEC examination
design = svy.Design(stratum="sdmvstra", psu="sdmvpsu", wgt="wtmec2yr")
sample = svy.Sample(data=data, design=design)
```

### ACS PUMS Example (Replicate Weights)

```python
import svy
import polars as pl

data = pl.read_parquet("data/raw/acs_pums_2022.parquet")

# INTENT: ACS PUMS uses successive-difference replication (SDR)
# REASONING: No design variables in public-use file; must use replicate weights
# ASSUMES: Person-level analysis using person weight and person replicate weights
rep_wgts = svy.RepWeights(prefix="pwgtp", n_reps=80, method=svy.EstimationMethod.SDR)
design = svy.Design(wgt="pwgtp", rep_wgts=rep_wgts)
sample = svy.Sample(data=data, design=design)
```

### MEPS Example

```python
import svy

data = svy.io.read_sas("h233.sas7bdat")

# INTENT: MEPS household component, full-year consolidated file
# REASONING: varstr/varpsu are the standard MEPS design variables
# ASSUMES: Person-level analysis for FY 2021
design = svy.Design(stratum="varstr", psu="varpsu", wgt="perwt21f")
sample = svy.Sample(data=data, design=design)
```

---

## Combining Survey Cycles

Some analyses require combining multiple cycles of a survey (e.g., NHANES 2017-2018 + 2019-2020) to increase sample size for rare subpopulations.

### Weight Adjustment

When combining N two-year cycles, divide the survey weight by N:

```python
import polars as pl

# Combine two NHANES cycles
cycle1 = pl.read_parquet("data/raw/nhanes_2017_2018.parquet")
cycle2 = pl.read_parquet("data/raw/nhanes_2019_2020.parquet")
combined = pl.concat([cycle1, cycle2])

# INTENT: Adjust weights for combined 4-year analysis
# REASONING: NHANES analytic guidelines require dividing 2-year weights by
#   the number of cycles combined to produce correct population estimates
# ASSUMES: Both cycles use the same design structure and weight definitions
combined = combined.with_columns(
    (pl.col("wtmec2yr") / 2).alias("wtmec4yr")
)

design = svy.Design(stratum="sdmvstra", psu="sdmvpsu", wgt="wtmec4yr")
sample = svy.Sample(data=combined, design=design)
```

### Important Caveats

- Only combine cycles with the same design structure
- Consult survey-specific guidelines for the correct weight adjustment
- For NHANES: the analytic guidelines at `wwwn.cdc.gov/nchs/nhanes/tutorials/` provide detailed instructions
- For ACS: combining 1-year and 5-year estimates requires separate methodology
- The variance structure may change across cycles — check for redesign years

---

## Polars Integration Notes

### svy Expects Polars DataFrames

`svy.Sample` expects a Polars DataFrame as the `data` argument. Data loaded via `svy.io` methods returns Polars DataFrames automatically.

### Converting from Other Formats

```python
import polars as pl

# From pandas
import pandas as pd
pd_df = pd.read_csv("survey.csv")
pl_df = pl.from_pandas(pd_df)

# From numpy arrays
import numpy as np
arr = np.load("survey_data.npz")
pl_df = pl.DataFrame({"var1": arr["var1"], "var2": arr["var2"]})

# From parquet (native Polars)
pl_df = pl.read_parquet("data.parquet")
```

### Column Type Requirements

- **Weight column**: Must be numeric (Float64 or Int64)
- **Strata column**: Can be string or integer; treated as categorical
- **PSU column**: Can be string or integer; treated as categorical
- **Analysis variables**: Numeric for estimation; string/categorical for proportions and grouping

### Accessing the Underlying DataFrame

```python
# Access the data within a Sample object
sample.data  # Returns the Polars DataFrame
```

---

## Migration from samplics

svy replaces samplics with a fundamentally different API. Key migration points:

### Design Specification

```python
# samplics (OLD — archived)
from samplics.estimation import TaylorEstimator
estimator = TaylorEstimator("mean")
estimator.estimate(
    y=data["income"].to_numpy(),
    samp_weight=data["weight"].to_numpy(),
    stratum=data["stratum"].to_numpy(),
    psu=data["psu"].to_numpy()
)

# svy (NEW)
import svy
design = svy.Design(stratum="stratum", psu="psu", wgt="weight")
sample = svy.Sample(data=data, design=design)
result = sample.estimation.mean("income")
```

### Key Differences

| Aspect | samplics | svy |
|--------|---------|-----|
| Data format | numpy arrays | Polars DataFrames |
| Design specification | Per-call parameters | Persistent Design + Sample objects |
| Estimation | `TaylorEstimator("mean").estimate(y=..., ...)` | `sample.estimation.mean("var")` |
| Replicate estimation | `ReplicateEstimator("mean").estimate(...)` | Same API — design determines method |
| Regression | `SurveyGLM(...)` | `sample.glm.fit(...)` |
| Tabulation | `Tabulation(...)` | `sample.estimation.prop(var, by=...)` |

### Why the Change Matters

samplics required passing design variables on every estimation call. svy's `Sample` object binds data and design once, then all estimation and regression methods automatically use the correct design. This reduces errors from inconsistent design specification across calls.

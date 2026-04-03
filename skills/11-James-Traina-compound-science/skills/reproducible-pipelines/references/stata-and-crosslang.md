# Stata Pipelines and Cross-Language Replication

## Stata Projects

Stata pipelines have different conventions from Python/R. The core principle is the same — single entry point, numbered scripts, no manual steps — but the execution model (interactive GUI vs batch) requires extra care.

### Stata Project Structure

```
project/
├── master.do                  # Single entry point: runs the entire pipeline
├── code/
│   ├── 01_clean.do            # Data cleaning
│   ├── 02_build.do            # Variable construction
│   ├── 03_estimate.do         # Main estimation
│   ├── 04_robustness.do       # Robustness checks
│   └── 05_tables.do           # Table output
├── ado/                       # Custom ado-files (project-specific Stata programs)
├── data/
│   ├── raw/                   # Immutable raw data (.dta, .csv)
│   └── intermediate/          # Cleaned data (gitignored)
├── output/
│   ├── tables/                # Exported tables (.tex, .xlsx)
│   └── figures/               # Exported figures (.pdf, .eps)
└── logs/                      # Log files from do-file runs (gitignored)
```

### master.do — The Single Entry Point

```stata
* master.do — Run the entire pipeline
* Usage: stata -b do master.do  (batch mode, no GUI)

version 17.0          // Pin Stata version — critical for reproducibility

* === PATHS ===
* Use relative paths from project root
global root    "."
global code    "$root/code"
global data    "$root/data"
global output  "$root/output"
global logs    "$root/logs"

* === SETTINGS ===
set more off           // Never pause — required for batch mode
set matsize 11000      // Increase matrix size for large datasets
set linesize 120       // Wider output for tables

* === LOGGING ===
capture mkdir "$logs"
local logfile = "$logs/master_" + c(current_date) + ".log"
log using "`logfile'", replace text

* === PIPELINE ===
di "Starting pipeline: $S_DATE $S_TIME"

do "$code/01_clean.do"
do "$code/02_build.do"
do "$code/03_estimate.do"
do "$code/04_robustness.do"
do "$code/05_tables.do"

di "Pipeline complete: $S_DATE $S_TIME"
log close
```

### do-file Conventions

Each do-file should have a standard header and operate on global macros for paths:

```stata
* 03_estimate.do
* Purpose: Baseline DiD estimation with two-way FE
* Input:   $data/intermediate/panel_clean.dta
* Output:  $output/tables/table1_did.tex, $data/intermediate/estimates.dta
* Author:  [Name], [Date]
* Updated: [Date] — [change description]

version 17.0
set more off

* Load data
use "$data/intermediate/panel_clean.dta", clear

* Baseline DiD with reghdfe
reghdfe y treated##post controls, absorb(unit_fe time_fe) vce(cluster unit_id)

* Export table
estimates store main_did
esttab main_did using "$output/tables/table1_did.tex", ///
    replace label star(* 0.10 ** 0.05 *** 0.01) se ///
    title("Main DiD Results") booktabs
```

### Running Stata in Batch Mode (for reproducibility)

Never rely on interactive clicks. Always run via batch:

```bash
# Run full pipeline (no GUI)
stata -b do master.do

# Or stata-mp for parallel processing
stata-mp -b do master.do

# Check exit code
echo $?   # 0 = success, non-zero = error

# Integrate with Make
output/tables/table1_did.tex: code/03_estimate.do data/intermediate/panel_clean.dta
	stata -b do code/03_estimate.do
	@[ -f output/tables/table1_did.tex ] || (echo "Stata failed — check logs/" && exit 1)
```

### ado-file Versioning

Custom programs (ado-files) must be version-controlled and loaded before estimation:

```stata
* In master.do, before any do-files:
adopath + "$root/ado"   // Load project-specific ado-files first

* In your ado/ directory: myprog.ado, myprog.sthlp
* This ensures project ado-files take precedence over user-installed packages

* Document installed packages in a setup do-file:
* code/00_setup.do
ssc install reghdfe, replace
ssc install ftools, replace
ssc install estout, replace
ssc install rdrobust, replace
```

### Stata Anti-Patterns

| Anti-Pattern | Problem | Fix |
|---|---|---|
| No `version` statement | Results may change across Stata versions | Add `version 17.0` to every do-file |
| `set more on` (default) | Pipeline hangs waiting for keypress in batch | Always `set more off` in master.do |
| Absolute paths (`/Users/me/...`) | Breaks on collaborator machines | Use global macros from master.do |
| Interactive graph window (`graph display`) | Batch mode crashes | Use `graph export filename.pdf, replace` |
| Missing `log close` | Log file left open if error occurs | Add `cap log close` at top, `log close` at bottom |
| Point-and-click menu operations | Not reproducible | Everything in do-files |

## CROSS-LANGUAGE REPLICATION STANDARDS

### Tolerance Thresholds (Stata ↔ R ↔ Python)
When verifying results across languages, use these tolerance thresholds:

| Result type | Tolerance | Notes |
|-------------|-----------|-------|
| Integer counts | Exact match | Row counts, group sizes |
| Point estimates | \|diff\| < 0.01 (absolute) OR < 0.001% (relative) | Use stricter when estimates are small |
| Standard errors | \|diff\| < 0.05 OR < 0.01% relative | Different finite-sample corrections are acceptable if documented |
| P-values | Same significance conclusion at 1/5/10% | Exact p-values may differ across implementations |
| Confidence intervals | Overlap by >99% of interval width | Not just point equality |

### Stata-to-R Translation Trap Table
Known systematic differences that produce real numeric discrepancies:

| Issue | Stata behavior | R equivalent | Fix |
|-------|----------------|--------------|-----|
| Cluster SE df adjustment | Uses g-1 (groups minus 1) | `feols` uses g-1 by default; `lm_robust` varies | Use `feols` in R, not `lm_robust` with default |
| `areg` absorbed FE dof | Subtracts N_absorbed from residual df | `feols` handles automatically | Switch from `areg` to `reghdfe`/`feols` |
| Probit MFX | `margins, dydx(*)` = average marginal effect | `margins::margins()` or manual AME computation | Verify using AME, not marginal at mean |
| Multi-way clustering | `reghdfe` Cameron-Gelbach-Miller | `feols` multiway: `vcov = ~id+time` | Formulas differ; document which is used |
| Bootstrap sampling | `bsample` with `set seed` | `set.seed` before `boot()` or manual bootstrap | Seed must be set identically in both |
| Wild cluster bootstrap | `boottest` (Roodman) | `fwildclusterboot` (Fischer) | Different algorithms; expect SE-level (not exact) agreement |
| Time-series operators | `L.` / `D.` operators | `dplyr::lag()` with explicit group | Verify panel lag handles unbalanced panels identically |
| Balanced panel enforcement | `xtset` warns, `xtbalance` required | `is.pbalanced()` check | Unbalanced panels produce different within estimators |

### Anti-patterns
- Manually editing generated tables (breaks automation trail)
- `qui regress` without `eststo` in a loop (results not captured)
- `save` without `compress` (file size; use `saveold` for v12 compatibility if needed)
- `use data.dta, clear` at top of do-file without checking working directory first
- Cross-language replication using the same base code (defeats the orthogonality purpose)

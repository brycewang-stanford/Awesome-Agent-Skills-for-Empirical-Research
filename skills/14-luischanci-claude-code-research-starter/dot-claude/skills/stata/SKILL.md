---
name: stata
description: >
  Comprehensive Stata reference for writing correct .do files, data management,
  econometrics, causal inference, graphics, Mata programming, and 17+ community
  packages (reghdfe, estout, did, rdrobust, etc.). Covers syntax, options,
  gotchas, and idiomatic patterns. Use this skill whenever the user asks you to
  write, debug, or explain Stata code.
triggers:
  - stata
  - .do file
  - do-file
  - regress
  - regression in stata
  - panel data
  - fixed effects
  - reghdfe
  - estout
  - esttab
  - outreg2
  - difference-in-differences
  - event study
  - propensity score
  - rdrobust
  - synthetic control
  - xtset
  - merge
  - reshape
  - collapse
  - egen
  - ssc install
  - mata
  - putexcel
  - putdocx
  - graph export
  - survival analysis
  - heckman
  - tobit
  - logit
  - probit
  - arima
  - var model
  - gmm estimation
  - bootstrap stata
  - survey weights
  - multiple imputation
  - lasso stata
---

# Stata Skill

You have access to comprehensive Stata reference files. **Do not load all files.**
Read only the 1-3 files relevant to the user's current task using the routing table below.

---

## Critical Gotchas

These are Stata-specific pitfalls that lead to silent bugs. Internalize these before writing any code.

### Missing Values Sort to +Infinity
Stata's `.` (and `.a`-`.z`) are **greater than all numbers**.
```stata
* WRONG — includes observations where income is missing!
gen high_income = (income > 50000)

* RIGHT
gen high_income = (income > 50000) if !missing(income)

* WRONG — missing ages appear in this list
list if age > 60

* RIGHT
list if age > 60 & !missing(age)
```

### `=` vs `==`
`=` is assignment; `==` is comparison. Mixing them up is a syntax error or silent bug.
```stata
* WRONG — syntax error
gen employed = 1 if status = 1

* RIGHT
gen employed = 1 if status == 1
```

### Local Macro Syntax
Locals use `` `name' `` (backtick + single-quote). Globals use `$name` or `${name}`.
Forgetting the closing quote is the #1 macro bug.
```stata
local controls "age education income"
regress wage `controls'        // correct
regress wage `controls         // WRONG — missing closing quote
regress wage 'controls'        // WRONG — wrong quote characters
```

### `by` Requires Prior Sort (Use `bysort`)
```stata
* WRONG — error if data not sorted by id
by id: gen first = (_n == 1)

* RIGHT — bysort sorts automatically
bysort id: gen first = (_n == 1)

* Also RIGHT — explicit sort
sort id
by id: gen first = (_n == 1)
```

### Factor Variable Notation (`i.` and `c.`)
Use `i.` for categorical, `c.` for continuous. Omitting `i.` treats categories as continuous.
```stata
* WRONG — treats race as continuous (e.g., race=3 has 3x effect of race=1)
regress wage race education

* RIGHT — creates dummies automatically
regress wage i.race education

* Interactions
regress wage i.race##c.education    // full interaction
regress wage i.race#c.education     // interaction only (no main effects)
```

### `generate` vs `replace`
`generate` creates new variables; `replace` modifies existing ones. Using `generate` on an existing variable name is an error.
```stata
gen x = 1
gen x = 2          // ERROR: x already defined
replace x = 2      // correct
```

### String Comparison Is Case-Sensitive
```stata
* May miss "Male", "MALE", etc.
keep if gender == "male"

* Safer
keep if lower(gender) == "male"
```

### `merge` Always Check `_merge`
```stata
merge 1:1 id using other.dta
tab _merge                      // always inspect
assert _merge == 3              // or handle mismatches
drop _merge
```

### `preserve` / `restore` for Temporary Changes
```stata
preserve
collapse (mean) income, by(state)
* ... do something with collapsed data ...
restore   // original data is back
```

### Weights Are Not Interchangeable
- `fweight` — frequency weights (replication)
- `aweight` — analytic/regression weights (inverse variance)
- `pweight` — probability/sampling weights (survey data, implies robust SE)
- `iweight` — importance weights (rarely used)

### `capture` Swallows Errors
```stata
capture some_command
if _rc != 0 {
    di as error "Failed with code: " _rc
    exit _rc
}
```

### Line Continuation Uses `///`
```stata
regress y x1 x2 x3 ///
    x4 x5 x6, ///
    vce(robust)
```

### Stored Results: `r()` vs `e()` vs `s()`
- `r()` — r-class commands (summarize, tabulate, etc.)
- `e()` — e-class commands (estimation: regress, logit, etc.)
- `s()` — s-class commands (parsing)

A new estimation command **overwrites** previous `e()` results. Store them first:
```stata
regress y x1 x2
estimates store model1
```

---

## Routing Table

Read only the files relevant to the user's task. Paths are relative to this SKILL.md file.

### Data Operations
| File | Topics & Key Commands |
|------|----------------------|
| `references/basics-getting-started.md` | `use`, `save`, `describe`, `browse`, `sysuse`, basic workflow |
| `references/data-import-export.md` | `import delimited`, `import excel`, ODBC, `export`, web data |
| `references/data-management.md` | `generate`, `replace`, `merge`, `append`, `reshape`, `collapse`, `recode`, `egen`, `encode`/`decode` |
| `references/variables-operators.md` | Variable types, `byte`/`int`/`long`/`float`/`double`, operators, missing values (`.<.a`), `if`/`in` qualifiers |
| `references/string-functions.md` | `substr()`, `regexm()`, `strtrim()`, `split`, `ustrlen()`, regex, Unicode |
| `references/date-time-functions.md` | `date()`, `clock()`, `%td`/`%tc` formats, `mdy()`, `dofm()`, business calendars |
| `references/mathematical-functions.md` | `round()`, `log()`, `exp()`, `abs()`, `mod()`, `cond()`, distributions, random numbers |

### Statistics & Econometrics
| File | Topics & Key Commands |
|------|----------------------|
| `references/descriptive-statistics.md` | `summarize`, `tabulate`, `correlate`, `tabstat`, `codebook`, weighted stats |
| `references/linear-regression.md` | `regress`, `vce(robust)`, `vce(cluster)`, `test`, `lincom`, `margins`, `predict`, `ivregress` |
| `references/panel-data.md` | `xtset`, `xtreg fe`/`re`, Hausman test, `xtabond`, dynamic panels |
| `references/time-series.md` | `tsset`, ARIMA, VAR, `dfuller`, `pperron`, `irf`, forecasting |
| `references/limited-dependent-variables.md` | `logit`, `probit`, `tobit`, `poisson`, `nbreg`, `mlogit`, `ologit`, `margins` for nonlinear |
| `references/bootstrap-simulation.md` | `bootstrap`, `simulate`, `permute`, Monte Carlo |
| `references/survey-data-analysis.md` | `svyset`, `svy:`, `subpop()`, complex survey design, replicate weights |
| `references/missing-data-handling.md` | `mi impute`, `mi estimate`, FIML, `misstable`, diagnostics |
| `references/maximum-likelihood.md` | `ml model`, custom likelihood functions, `ml init`, gradient-based optimization |
| `references/gmm-estimation.md` | `gmm`, moment conditions, `estat overid`, J-test |

### Causal Inference
| File | Topics & Key Commands |
|------|----------------------|
| `references/treatment-effects.md` | `teffects ra/ipw/ipwra/aipw`, `stteffects`, ATE/ATT/ATET |
| `references/difference-in-differences.md` | DiD, parallel trends, event studies, staggered adoption |
| `references/regression-discontinuity.md` | Sharp/fuzzy RD, bandwidth selection, `rdplot` |
| `references/matching-methods.md` | PSM, nearest neighbor, kernel matching, `teffects nnmatch` |
| `references/sample-selection.md` | `heckman`, `heckprobit`, treatment models, exclusion restrictions |

### Advanced Methods
| File | Topics & Key Commands |
|------|----------------------|
| `references/survival-analysis.md` | `stset`, `stcox`, `streg`, Kaplan-Meier, parametric models |
| `references/sem-factor-analysis.md` | `sem`, `gsem`, CFA, path analysis, `alpha`, reliability |
| `references/nonparametric-methods.md` | `kdensity`, rank tests, `qreg`, `npregress` |
| `references/spatial-analysis.md` | `spmatrix`, `spregress`, spatial weights, Moran's I |
| `references/machine-learning.md` | `lasso`, `elasticnet`, `cvlasso`, cross-validation |

### Graphics
| File | Topics & Key Commands |
|------|----------------------|
| `references/graphics.md` | `twoway`, `scatter`, `line`, `bar`, `histogram`, `graph combine`, `graph export`, schemes |

### Programming
| File | Topics & Key Commands |
|------|----------------------|
| `references/programming-basics.md` | `local`, `global`, `foreach`, `forvalues`, `program define`, `syntax`, `return` |
| `references/advanced-programming.md` | `syntax`, `mata`, classes, `_prefix`, dialog boxes, `tempfile`/`tempvar` |
| `references/mata-introduction.md` | Mata basics, when to use Mata vs ado, data types |
| `references/mata-programming.md` | Mata functions, flow control, structures, pointers |
| `references/mata-matrix-operations.md` | Matrix creation, decompositions, solvers, `st_matrix()` |
| `references/mata-data-access.md` | `st_data()`, `st_view()`, `st_store()`, performance tips |

### Output & Workflow
| File | Topics & Key Commands |
|------|----------------------|
| `references/tables-reporting.md` | `putexcel`, `putdocx`, `putpdf`, LaTeX integration, `collect` |
| `references/workflow-best-practices.md` | Project structure, master do-files, version control, debugging, common mistakes |
| `references/external-tools-integration.md` | Python via `python:`, R via `rsource`, shell commands, Git |

### Community Packages
| File | What It Does |
|------|-------------|
| `packages/reghdfe.md` | High-dimensional fixed effects OLS (absorbs multiple FE sets efficiently) |
| `packages/estout.md` | `esttab`/`estout`: publication-quality regression tables |
| `packages/outreg2.md` | Alternative regression table exporter (Word, Excel, TeX) |
| `packages/asdoc.md` | One-command Word document creation for any Stata output |
| `packages/tabout.md` | Cross-tabulations and summary tables to file |
| `packages/coefplot.md` | Coefficient plots from stored estimates |
| `packages/graph-schemes.md` | `grstyle`, `schemepack`, `plotplain` — better graph themes |
| `packages/did.md` | Modern DiD: `csdid`, `did_multiplegt`, `did_imputation` (Callaway-Sant'Anna, de Chaisemartin-D'Haultfoeuille, Borusyak-Jaravel-Spiess) |
| `packages/event-study.md` | `eventstudyinteract`, `eventdd` — event study estimators |
| `packages/rdrobust.md` | Robust RD estimation with optimal bandwidth (`rdrobust`, `rdplot`, `rdbwselect`) |
| `packages/psmatch2.md` | Propensity score matching (nearest neighbor, kernel, radius) |
| `packages/synth.md` | Synthetic control method (`synth`, `synth_runner`) |
| `packages/ivreg2.md` | Enhanced IV/2SLS: `ivreg2`, `xtivreg2` with additional diagnostics |
| `packages/xtabond2.md` | Dynamic panel GMM (Arellano-Bond/Blundell-Bond) |
| `packages/binsreg.md` | Binned scatter plots with CI (`binsreg`, `binstest`) |
| `packages/nprobust.md` | Nonparametric kernel estimation and inference |
| `packages/diagnostics.md` | `bacondecomp`, `xttest3`, collinearity, heteroskedasticity tests |
| `packages/winsor.md` | Winsorizing and trimming: `winsor2`, `winsor` |
| `packages/data-manipulation.md` | `gtools` (fast collapse/egen), `rangestat`, `egenmore` |
| `packages/package-management.md` | `ssc install`, `net install`, `ado update`, finding packages |

---

## Common Patterns

### Regression Table Workflow
```stata
* Estimate models
eststo clear
eststo: regress y x1 x2, vce(robust)
eststo: regress y x1 x2 x3, vce(robust)
eststo: regress y x1 x2 x3 x4, vce(cluster id)

* Export table
esttab using "results.tex", replace ///
    se star(* 0.10 ** 0.05 *** 0.01) ///
    label booktabs ///
    title("Main Results") ///
    mtitles("(1)" "(2)" "(3)")
```

### Panel Data Setup
```stata
xtset panelid timevar          // declare panel structure
xtdescribe                      // check balance
xtsum outcome                   // within/between variation

* Fixed effects
xtreg y x1 x2, fe vce(cluster panelid)
* Or with reghdfe (preferred for multiple FE)
reghdfe y x1 x2, absorb(panelid timevar) vce(cluster panelid)
```

### Difference-in-Differences
```stata
* Classic 2x2 DiD
gen post = (year >= treatment_year)
gen treat_post = treated * post
regress y treated post treat_post, vce(cluster id)

* Modern staggered DiD (Callaway & Sant'Anna)
csdid y x1 x2, ivar(id) time(year) gvar(first_treat) agg(event)
csdid_plot
```

### Graph Export
```stata
* Publication-quality scatter with fit line
twoway (scatter y x, mcolor(navy%50) msize(small)) ///
       (lfit y x, lcolor(cranberry) lwidth(medthick)), ///
    title("Title Here") ///
    xtitle("X Label") ytitle("Y Label") ///
    legend(off) scheme(s2color)
graph export "figure1.pdf", replace as(pdf)
graph export "figure1.png", replace as(png) width(2400)
```

### Data Cleaning Pipeline
```stata
* Load and inspect
import delimited "raw_data.csv", clear varnames(1)
describe
codebook, compact

* Clean
rename *, lower                 // lowercase all varnames
destring income, replace force  // convert string to numeric
replace income = . if income < 0

* Label
label variable income "Annual household income (USD)"
label define yesno 0 "No" 1 "Yes"
label values employed yesno

* Save
compress
save "clean_data.dta", replace
```

### Multiple Imputation
```stata
mi set mlong
mi register imputed income education
mi impute chained (regress) income (ologit) education = age i.gender, add(20) rseed(12345)
mi estimate: regress wage income education age i.gender
```

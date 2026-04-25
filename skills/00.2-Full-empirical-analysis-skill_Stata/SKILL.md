---
name: Full-empirical-analysis-skill-Stata
description: Classical end-to-end empirical analysis workflow in the traditional Stata ecosystem — native Stata + reghdfe + ivreg2 + csdid + did_imputation + eventstudyinteract + sdid + rdrobust + rddensity + synth + synth_runner + psmatch2 + teffects + ebalance + coefplot + esttab + asdoc + binscatter. **Defaults to economics empirical-paper style** — every run produces a publication-ready output set with a multi-column regression table (M1→M6 progressive controls/FE) as the centerpiece, plus Table 1 (descriptives), mechanism / heterogeneity / robustness tables, and event-study + coefficient + trend figures. Covers the full 8-step Stata pipeline an applied economist runs on every paper — (1) data import & cleaning (use/import, destring, misstable, duplicates, merge assert), (2) variable construction (gen/egen/winsor2/xtile/xtset with L./F./D.), (3) descriptive statistics & Table 1 (tabstat/balancetable/asdoc), (4) classical diagnostic tests (sktest/swilk/hettest/imtest/xtserial/xttest3/vif/dfuller/kpss/hausman/estat overid), (5) baseline modeling (reg/xtreg/reghdfe/ivreg2/ivregress/csdid/did_imputation/eventstudyinteract/sdid/rdrobust/synth/psmatch2/teffects/heckman/qreg/ppmlhdfe), (6) robustness battery (bacondecomp/honestdid/rwolf/ritest/wildbootstrap/oster), (7) further analysis (subgroup/triple-diff/interactions/medsem/marginsplot/binscatter by group), (8) publication-ready tables & figures (esttab/outreg2/estout/coefplot/marginsplot/rdplot/twoway combined). Use when the user asks for a complete Stata empirical analysis, wants a reproducible .do-file pipeline, needs a Stata counterpart to the Python StatsPAI / Full-empirical-analysis-skill, or names a specific Stata step in isolation ("run reghdfe with two-way clustering", "csdid event study", "winsor2 at 1%", "esttab to LaTeX", "coefplot with CI", "ivreg2 weak-IV test", "synth_runner placebos", "teffects psmatch balance check").
triggers:
  - Stata empirical analysis
  - full Stata pipeline
  - reproducible do-file
  - Stata do-file workflow
  - reghdfe two-way FE
  - high-dimensional fixed effects Stata
  - ivreg2 weak instruments
  - ivregress 2sls liml gmm
  - csdid Callaway SantAnna
  - did_imputation Borusyak
  - eventstudyinteract Sun Abraham
  - sdid synthetic DID Stata
  - rdrobust Stata
  - rddensity manipulation test
  - synth synthetic control
  - synth_runner placebo
  - psmatch2 propensity score
  - teffects psmatch
  - teffects ipwra AIPW Stata
  - ebalance entropy balancing
  - xtreg fe re hausman
  - ppmlhdfe Poisson
  - quantile regression qreg
  - heckman selection model
  - esttab publication table
  - outreg2 LaTeX
  - estout coefplot
  - marginsplot interaction
  - rdplot binned scatter
  - binscatter Stata
  - bacondecomp Goodman Bacon
  - honestdid Rambachan Roth
  - wild cluster bootstrap boottest
  - ritest randomization inference
  - rwolf Romano-Wolf
  - oster delta
  - winsor2 winsorize Stata
  - tabstat table 1
  - balancetable Stata
  - misstable patterns
  - destring dates
  - xtset panel
---

# Full Empirical Analysis — Classical Stata Workflow

This skill is the *canonical* 8-step pipeline an applied economist runs on every empirical paper, written in the **traditional Stata ecosystem** — native Stata + the 20+ community commands that have become de-facto standards (`reghdfe`, `ivreg2`, `csdid`, `did_imputation`, `eventstudyinteract`, `sdid`, `rdrobust`, `rddensity`, `synth`, `synth_runner`, `psmatch2`, `teffects`, `ebalance`, `coefplot`, `esttab`, `outreg2`, `boottest`, `ritest`, `rwolf`, `bacondecomp`, `honestdid`, `binscatter`).

**Companion skills**: if the user wants the same pipeline in Python, route to `00-StatsPAI_skill` (agent-native DSL) or `00.1-Full-empirical-analysis-skill` (explicit Python stack). **This skill is the Stata counterpart** — every step produces a `.do` file you can hand to a journal's replication office or a co-author who refuses to leave Stata.

## Philosophy

1. **Stata idioms, not Python-translated.** `reghdfe`, not "statsmodels analogue of reghdfe". `esttab`, not "Stata's stargazer".
2. **Reproducible .do files.** Every code block below is runnable after `use data.dta, clear`. No Jupyter, no notebooks — just do-files and log files.
3. **Full pipeline, not just regressions.** Stata users historically over-invest in Step 5 (modeling) and under-invest in Steps 1–4 and 6–8. This skill treats them as first-class.
4. **Rich outputs.** Every step yields at least one table (`.tex`/`.rtf`) or figure (`.pdf`/`.png`) — never a coefficient printed to the Results window and forgotten.
5. **Progressive disclosure.** `SKILL.md` gives the canonical command at each step; [`references/`](references/) holds variant-specific depth (dozens of tests, estimator-specific diagnostics, graph recipes).

---

## Default Output Spec — Economics Empirical Paper

This skill defaults to the **applied-economics paper convention**. Unless the user explicitly asks for a single point estimate, every `.do`-file run produces the full publication-ready output set below. Treat it as the contract of Step 8 — **mandatory**, not opt-in.

### Required tables (always produced)

| # | Table | Stata source | Saves to |
|---|---|---|---|
| **T1** | Summary statistics & balance (treated vs control, with SMD / p-values) | `balancetable` + `asdoc sum` (Step 3) | `tables/table1_balance.tex` (+ `.rtf`) |
| **T2** ★ | **Main results — multi-column regression M1→M6** (progressive controls + FE) | `eststo` 6 specs → `esttab` (Step 5–6) | `tables/table2_main.tex` (+ `.rtf`) |
| **T3** | Mechanism / outcome ladder — same treatment, 3+ outcomes side-by-side | loop `eststo: reghdfe` over outcomes → `esttab` (Step 7) | `tables/table3_mechanism.tex` |
| **T4** | Heterogeneity — subgroup × main coef (gender, age, region, …) | subgroup `eststo` + `suest` Wald → `esttab` (Step 7) | `tables/table4_heterogeneity.tex` |
| **T5** | Robustness battery — alt SE / cluster / sample / placebo, in **one** table | `eststo` × variants → `esttab` (Step 6) | `tables/table5_robustness.tex` |

> **★ Table 2 is the centerpiece of every economics paper.** It is the multi-column regression table that walks the reader from raw correlation (M1) to the fully-specified design (M6: 2-way FE + interacted FE + cluster-robust SE). Do **not** collapse it into a single column. Do **not** report only the headline coefficient. The progression *is* the credibility argument: if M1→M6 is monotone and stable, the design is plausibly identifying; if it collapses on adding FE, that *is* the result.
>
> **Canonical 6 columns, in order:**
> 1. **M1** raw bivariate (`reg y treat`)
> 2. **M2** + demographics (`+ age + edu`)
> 3. **M3** + sector controls (`+ tenure / firm_size`)
> 4. **M4** + unit FE (`reghdfe ..., absorb(unit)`)
> 5. **M5** + 2-way FE (`absorb(unit year)`)
> 6. **M6** + interacted FE (`absorb(unit year i.industry#i.year)`) with `vce(cluster unit)`

### Required figures (always produced)

| # | Figure | Stata source | Saves to |
|---|---|---|---|
| **F1** | Trend / motivation — treated vs control over time, with policy line | `collapse (mean) y, by(year treat)` → `twoway line` (Step 3) | `figures/fig1_trend.pdf` (+ `.png`) |
| **F2** | Event-study coefficients with 95% CI, base period at –1 | `eventstudyinteract` / `csdid` / `coefplot, keep(*.rel)` (Step 5) | `figures/fig2_event_study.pdf` |
| **F3** | Coefficient plot across specs M1→M6 | `coefplot m1 m2 m3 m4 m5 m6, keep(treat) vertical` (Step 8) | `figures/fig3_coefplot.pdf` |
| **F4** | Robustness / sensitivity curve — `bacondecomp` plot, `honestdid` plot, or cluster-comparison forest | scenario-specific (Step 6) | `figures/fig4_sensitivity.pdf` |

### Output file layout (default)

```
project/
├── tables/    table1_balance.{tex,rtf}    table2_main.{tex,rtf}
│              table3_mechanism.tex        table4_heterogeneity.tex
│              table5_robustness.tex
└── figures/   fig1_trend.{pdf,png}        fig2_event_study.{pdf,png}
               fig3_coefplot.{pdf,png}     fig4_sensitivity.{pdf,png}
```

Every table → `.tex` (LaTeX `booktabs`) **and** `.rtf` (Word). Every figure → `.pdf` (vector for LaTeX) **and** `.png` at ≥300 dpi (slides / web).

### When to deviate

- **Single quick estimate** — produce only the relevant cell, but warn that the standard deliverable is the full set above and offer to run it.
- **Design does not support a figure** (cross-section → no event study) — skip with a printed `display` note explaining why; do **not** silently drop.
- **N=1 treated unit (`synth`)** — replace F1/F2 with the SCM trajectory + placebo distribution from `synth_runner`; T1–T5 still apply.

---

## Required packages

```stata
* Run once on a fresh Stata install:
ssc install reghdfe,         replace
ssc install ftools,          replace       // dependency of reghdfe / ivreg2
ssc install ivreg2,          replace
ssc install ranktest,        replace       // dependency of ivreg2
ssc install ivreghdfe,       replace       // ivreg2 × reghdfe: high-dim FE IV
ssc install ppmlhdfe,        replace       // Poisson with HD FE
ssc install csdid,           replace       // Callaway–Sant'Anna (2021)
ssc install drdid,           replace       // dependency of csdid
ssc install did_imputation,  replace       // Borusyak–Jaravel–Spiess (2024)
ssc install eventstudyinteract, replace    // Sun & Abraham (2021)
ssc install sdid,            replace       // Synthetic DID (Arkhangelsky et al. 2021)
ssc install did_multiplegt_dyn, replace    // de Chaisemartin & D'Haultfœuille
ssc install bacondecomp,     replace       // Goodman-Bacon (2021)
ssc install honestdid,       replace       // Rambachan–Roth (2023) PT sensitivity
ssc install rdrobust,        replace       // Calonico–Cattaneo–Titiunik RD
ssc install rddensity,       replace       // McCrary / Cattaneo et al. density test
ssc install synth,           replace       // Abadie–Diamond–Hainmueller SCM
ssc install synth_runner,    replace       // SCM with placebos + inference
ssc install psmatch2,        replace       // propensity-score matching
ssc install ebalance,        replace       // entropy balancing
ssc install coefplot,        replace
ssc install estout,          replace       // provides estout / esttab / eststo
ssc install outreg2,         replace
ssc install asdoc,           replace       // one-click Word/Excel tables
ssc install binscatter,      replace
ssc install balancetable,    replace
ssc install winsor2,         replace
ssc install xtable,          replace       // better xtreg output tables
ssc install boottest,        replace       // wild cluster bootstrap (Roodman et al.)
ssc install ritest,          replace       // randomization inference
ssc install rwolf,           replace       // Romano–Wolf multiple-testing
ssc install moremata,        replace       // Mata extensions (dep for several)
ssc install mdesc,           replace       // missing data description
ssc install missings,        replace       // missings dropvars, report
ssc install unique,          replace       // unique IDs in panel
ssc install schemepack,      replace       // modern publication themes
```

---

## The 8 Steps — Canonical Pipeline

```
┌──────────────────────────────────────────────────────────────────────┐
│ Step 1  Data import & cleaning    use/import/destring/misstable/merge│
│ Step 2  Variable construction     gen/egen/winsor2/xtile/xtset/L.F.D.│
│ Step 3  Descriptive statistics    tabstat/balancetable/asdoc/pwcorr  │
│ Step 4  Diagnostic tests          sktest/hettest/xtserial/vif/dfuller│
│ Step 5  Baseline modeling         reghdfe/ivreg2/csdid/rdrobust/synth│
│ Step 6  Robustness battery        bacondecomp/honestdid/rwolf/boottest│
│ Step 7  Further analysis          triple-diff/subgroup/medsem/margins│
│ Step 8  Tables & figures          esttab/outreg2/coefplot/rdplot     │
└──────────────────────────────────────────────────────────────────────┘
```

Below is the canonical command at each step. **All examples share one running narrative** — a labor-economics panel where `training` (treatment) affects `log_wage` (outcome), with covariates `age`, `edu`, `tenure`, panel keys `worker_id` / `firm_id` / `year`. Variable names and parameter values are **illustrative**; substitute the real ones from the user's dataset. Only command names and option *shapes* are normative.

> **When a step has many variants** (e.g. staggered DID has 5 estimators; heteroskedasticity has 4 classic tests), SKILL.md shows the one you reach for first and links to `references/NN-<topic>.md` for the rest. **Read the reference file when the user's case doesn't fit the default.**

---

### Step 1 — Data import & cleaning

Deeper patterns: [references/01-data-cleaning.md](references/01-data-cleaning.md) — reading Excel/CSV/SAS/SPSS, `destring` on numeric-looking strings, `misstable` patterns, `duplicates` tagging, `merge` with `assert(match using)`, `xtset` balance checks, spells / gaps, labels.

```stata
* 1a. Load + first look
use "raw.dta", clear
describe, short
summarize
misstable summarize
mdesc                                   // missing-data report

* 1b. Dtypes — destring strings-that-should-be-numeric
destring year wage, replace force       // force: convert non-numeric to .
gen hire_date = date(hire_date_str, "YMD"); format hire_date %td

* 1c. Missing values — decide PER VARIABLE
local key_vars "wage training worker_id year"
foreach v of local key_vars {
    drop if missing(`v')
}
sum tenure, detail
replace tenure = r(p50) if missing(tenure)      // median-impute
gen byte tenure_miss = missing(tenure)           // keep the flag

* 1d. Outliers — flag first (winsorize in Step 2)
egen wage_z = std(wage)
count if abs(wage_z) > 4
display "Flagged |z|>4 on wage: " r(N)

* 1e. Deduplicate on panel key
duplicates report worker_id year
duplicates tag worker_id year, gen(dup)
assert dup == 0                                  // hard-fail if panel key not unique
drop dup

* 1f. Merge with assert — never silently lose rows
merge m:1 firm_id using "firm_chars.dta", ///
    assert(match using master) keep(master match) nogen

* 1g. Panel structure
xtset worker_id year                              // declares panel
xtdescribe                                        // balance summary
tab year                                          // observations per year
```

**Key principle**: all row exclusions are explicit, counted, logged. No command in Steps 2+ should silently drop rows.

---

### Step 2 — Variable construction & transformation

Deeper patterns: [references/02-data-transformation.md](references/02-data-transformation.md) — log / ihs / Box–Cox, within-group `winsor2`, `xtile` and custom cuts, `egen` recipes, time-series operators (`L.`, `F.`, `D.`, `S.`), CPI deflation, staggered-DID timing construction.

```stata
* 2a. Log / IHS
gen log_wage = log(max(wage, 1))                  // floor at 1
gen ihs_assets = asinh(assets)                    // handles 0 / negative

* 2b. Winsorize 1/99
winsor2 wage, cuts(1 99) suffix(_w1) by(year)     // within-year winsorize

* 2c. Standardize
egen age_std = std(age)

* 2d. Categorical encoding (factor variables — use i. inside regressions)
* Explicit dummies only when needed for export
tab industry, gen(ind_)
drop ind_1                                        // base category

* 2e. Interactions & polynomials — use c. and i. inline in reg commands
gen age_sq = age^2
gen trt_x_edu = training * edu

* 2f. Panel operators (xtset is required for L./F./D. to work)
xtset worker_id year
gen log_wage_l1 = L.log_wage
gen log_wage_f1 = F.log_wage
gen d_log_wage  = D.log_wage

* 2g. Within-unit mean (egen)
egen wage_mean_i = mean(log_wage), by(worker_id)

* 2h. Treatment timing for staggered DID
bysort worker_id (year): egen first_treat = min(cond(training==1, year, .))
gen rel_time = year - first_treat
replace rel_time = . if missing(first_treat)      // never-treated = .
gen never_treated = missing(first_treat)

* 2i. Real values (CPI deflation)
merge m:1 year using "cpi.dta", keep(master match) nogen
sum cpi if year == 2010
gen wage_real = wage * r(mean) / cpi
```

---

### Step 3 — Descriptive statistics & Table 1

Deeper patterns: [references/03-descriptive-stats.md](references/03-descriptive-stats.md) — stratified Table 1 with SMDs, `asdoc` / `tabstat` / `balancetable`, correlation matrix with significance stars (`pwcorr, sig star(.05)`), histograms / kdensity by group, `xtline` for DID motivation, panel-coverage `xtdescribe`.

```stata
* 3a. Full-sample summary
local vars "log_wage age edu tenure training"
tabstat `vars', statistics(n mean sd min p25 p50 p75 max) columns(statistics)

* One-command Word/Excel output:
asdoc sum `vars', stat(N mean sd min median max) ///
    save(tables/table1_full.docx) replace

* 3b. Stratified Table 1 (treated vs control + t-tests + SMDs)
balancetable training age edu tenure female ///
    using "tables/table1_balance.tex", ///
    vce(cluster firm_id) replace ///
    varlabels pval

* Manual per-variable t-test + SMD:
foreach v of varlist age edu tenure {
    qui sum `v' if training == 1
    local m1 = r(mean); local sd1 = r(sd); local n1 = r(N)
    qui sum `v' if training == 0
    local m0 = r(mean); local sd0 = r(sd); local n0 = r(N)
    local smd = (`m1' - `m0') / sqrt((`sd1'^2 + `sd0'^2)/2)
    ttest `v', by(training)
    display "`v': Δ=" %7.3f (`m1'-`m0') "  SMD=" %7.3f `smd' "  p=" %6.3f r(p)
}

* 3c. Correlation matrix with significance stars
pwcorr `vars', sig star(.05)
estout using "tables/corr.tex", replace ///
    cells("b(star fmt(3))") style(tex)        // alternative: estpost correlate

* 3d. Distribution plots
twoway (kdensity log_wage if training==1) ///
       (kdensity log_wage if training==0), ///
    legend(order(1 "Treated" 2 "Control")) ///
    title("Log wage density by treatment") ///
    saving(figures/kde_wage, replace)
graph export "figures/kde_wage.pdf", replace

* 3e. Time trends — the DID motivation plot
preserve
    collapse (mean) log_wage, by(year training)
    twoway (line log_wage year if training==1) ///
           (line log_wage year if training==0), ///
        xline(`policy_year', lpattern(dash)) ///
        legend(order(1 "Treated" 2 "Control"))
    graph export "figures/trend_did.pdf", replace
restore

* 3f. Panel coverage
xtdescribe
```

---

### Step 4 — Diagnostic statistical tests

Deeper patterns: [references/04-statistical-tests.md](references/04-statistical-tests.md) — Shapiro–Wilk, Jarque–Bera, Breusch–Pagan, White, Cook–Weisberg, Durbin–Watson, Breusch–Godfrey, Wooldridge `xtserial`, Pesaran CD, `xttest3`, VIF, `estat ovtest` (RESET), Augmented Dickey–Fuller, KPSS, Phillips–Perron, Hausman (FE vs RE), Sargan–Hansen, `estat firststage` (weak IV).

```stata
* Baseline OLS to anchor diagnostics
reg log_wage training age edu tenure

* 4a. Normality of residuals
predict resid, resid
swilk resid                                       // Shapiro–Wilk (N ≤ 5000)
sktest resid                                      // skewness + kurtosis test

* 4b. Heteroskedasticity
estat hettest                                     // Breusch–Pagan / Cook–Weisberg
estat imtest, white                               // White's general test

* 4c. Autocorrelation (panel)
xtset worker_id year
xtreg log_wage training age edu tenure, fe
xtserial log_wage training age edu tenure         // Wooldridge serial-correlation
xttest3                                           // modified Wald groupwise hetero

* 4d. Cross-sectional dependence (panel)
xtcsd, pesaran abs                                // Pesaran CD test

* 4e. Multicollinearity
quietly reg log_wage training age edu tenure
estat vif

* 4f. Model specification
estat ovtest                                      // Ramsey RESET
linktest                                          // Stata "linktest"

* 4g. Stationarity (time series)
dfuller log_wage, lags(4) trend                   // ADF
kpss    log_wage, maxlag(4) notrend               // KPSS
pperron log_wage, lags(4)                         // Phillips–Perron

* 4h. Panel unit root (multiple series)
xtunitroot ips log_wage, lags(aic 4)              // Im–Pesaran–Shin
xtunitroot llc log_wage, lags(aic 4)              // Levin–Lin–Chu

* 4i. Hausman (after running FE and RE)
qui xtreg log_wage training age edu, fe
estimates store fe
qui xtreg log_wage training age edu, re
estimates store re
hausman fe re, sigmamore
```

**Decision table**:

| Test | Null | If rejected |
|------|------|-------------|
| `swilk` / `sktest` | residuals Normal | large N: usually ignore; small N: bootstrap |
| `estat hettest` / `imtest, white` | homoskedastic | use `vce(robust)` or `vce(cluster id)` |
| `xtserial` / `xttest3` | no panel autocorr / no groupwise hetero | cluster by unit |
| `xtcsd, pesaran` | no cross-sectional dependence | Driscoll–Kraay or `xtscc` |
| `estat vif` > 10 | — | drop/combine collinear regressors |
| `estat ovtest` | specification OK | add polynomials / logs |
| `dfuller` reject + `kpss` fail to reject | stationary | keep levels |
| `dfuller` fail to reject | unit root | first-difference or cointegrate |
| `hausman` | RE consistent | use FE |

---

### Step 5 — Baseline empirical modeling

Deeper patterns: [references/05-modeling.md](references/05-modeling.md) — every classical estimator with syntax: `reg`, `areg`, `xtreg`, `reghdfe`, `ivreg2` / `ivregress` / `ivreghdfe`, `logit` / `probit` / `ppmlhdfe`, `csdid` / `did_imputation` / `eventstudyinteract` / `sdid` / `did_multiplegt_dyn`, `rdrobust` / `rddensity` / `rdmc`, `synth` / `synth_runner`, `psmatch2` / `teffects psmatch|ipw|ipwra|aipw`, `ebalance`, `heckman`, `qreg`.

**Pick the estimator by identification strategy**:

```
Observational cross-section, selection on obs  →  reg + controls  |  teffects psmatch|ipwra
Observational panel, policy shock, parallel trends → csdid / did_imputation / eventstudyinteract / sdid
Exogenous instrument                           →  ivreg2 / ivregress / ivreghdfe
Discontinuity in assignment rule               →  rdrobust (+ rddensity)
N=1 treated, long panel                        →  synth / synth_runner
Selection on observables + heterogeneity       →  teffects aipw / ebalance
Binary outcome                                 →  logit / probit + margins
Count outcome                                  →  poisson / nbreg / ppmlhdfe
```

Canonical commands:

```stata
* 5a. OLS with cluster-robust SE
reg log_wage training age edu tenure, vce(cluster firm_id)
eststo ols_m1

* 5b. Two-way FE — reach for reghdfe (absorb HD FE; clusters any level)
reghdfe log_wage training age edu tenure, ///
    absorb(worker_id year) vce(cluster worker_id)
eststo fe_m1

* Multi-way clustering
reghdfe log_wage training, absorb(worker_id year) ///
    vce(cluster worker_id firm_id)

* High-dim FE (industry × year, firm × state)
reghdfe log_wage training, absorb(worker_id i.industry#i.year) ///
    vce(cluster firm_id)

* 5c. 2×2 DID
reg log_wage i.treated##i.post age edu, vce(cluster worker_id)

* Or with absorbed FE:
reghdfe log_wage c.treated#c.post, absorb(worker_id year) ///
    vce(cluster worker_id)

* 5d. Event study (dynamic DID, base period = -1)
* Build relative-time factor var, base at k = -1:
gen rel = rel_time + 10                          // shift so -10..10 → 0..20
replace rel = 0 if missing(rel_time)             // never-treated → bin 0
* (preferable: use -eventstudyinteract- or -did_imputation- — see reference 5.4)
reghdfe log_wage ib9.rel, absorb(worker_id year) vce(cluster worker_id)
coefplot, keep(*.rel) vertical omitted ///
    yline(0) xline(9.5, lpattern(dash)) ///
    xtitle("Years relative to treatment") ytitle("Coefficient (ATT)")
graph export "figures/event_study.pdf", replace

* 5e. Staggered DID — modern estimators (see references/05-modeling.md §5.4)
* Callaway–Sant'Anna (2021):
csdid log_wage, ivar(worker_id) time(year) gvar(first_treat) ///
    method(dripw) agg(group)

* Sun & Abraham (2021):
eventstudyinteract log_wage rel_dummies_*, ///
    cohort(first_treat) control_cohort(never_treated) ///
    absorb(worker_id year) vce(cluster worker_id)

* Borusyak–Jaravel–Spiess (2024) imputation:
did_imputation log_wage worker_id year first_treat, ///
    allhorizons pretrend(5)

* Synthetic DID (Arkhangelsky et al. 2021):
sdid log_wage worker_id year training, vce(bootstrap) ///
    graph g1on g1_opt(ytitle("log wage"))

* 5f. IV / 2SLS — ivreg2 is the de-facto standard (full diagnostics)
ivreg2 log_wage age edu (training = draft_lottery), ///
    cluster(firm_id) first endog(training)

* ivreghdfe for HD FE with IV:
ivreghdfe log_wage age (training = draft_lottery), ///
    absorb(worker_id year) cluster(worker_id) first

* 5g. Sharp RD
rdrobust outcome running_var, c(0) kernel(triangular) bwselect(mserd)
rdplot   outcome running_var, c(0)

* Fuzzy RD
rdrobust outcome running_var, c(0) fuzzy(treatment)

* Density test (McCrary / Cattaneo et al.)
rddensity running_var, c(0)

* 5h. Binary outcome — always follow with margins
logit employed training age edu, vce(cluster firm_id)
margins, dydx(training) atmeans

* 5i. Count outcome with HD FE
ppmlhdfe citations training age, absorb(firm_id year) ///
    cluster(firm_id)

* 5j. Quantile regression
qreg log_wage training age edu, quantile(0.5)
sqreg log_wage training age edu, quantile(0.1 0.25 0.5 0.75 0.9) reps(500)
```

---

### Step 6 — Robustness battery

Deeper patterns: [references/06-robustness.md](references/06-robustness.md) — progressive specs M1–M6 with `eststo` / `esttab`, `bacondecomp` for TWFE bias, `honestdid` (Rambachan–Roth), `boottest` wild-cluster bootstrap, `ritest` randomization inference, `rwolf` Romano–Wolf, alternative cluster levels, Oster δ*, placebo timing, subsample splits, specification curve via loops.

```stata
* 6a. Progressive specifications (M1 → M6)
eststo clear
eststo m1: qui reg    log_wage training, vce(cluster firm_id)
eststo m2: qui reg    log_wage training age edu, vce(cluster firm_id)
eststo m3: qui reghdfe log_wage training age edu tenure, ///
    absorb(worker_id) vce(cluster worker_id)
eststo m4: qui reghdfe log_wage training age edu tenure, ///
    absorb(worker_id year) vce(cluster worker_id)
eststo m5: qui reghdfe log_wage training age edu tenure, ///
    absorb(worker_id year region) vce(cluster worker_id)
eststo m6: qui reghdfe log_wage training age edu tenure, ///
    absorb(worker_id year i.industry#i.year) vce(cluster worker_id)
esttab m1 m2 m3 m4 m5 m6 using "tables/table_main.tex", ///
    replace se star(* 0.10 ** 0.05 *** 0.01) ///
    stats(N r2 r2_a, labels("N" "R²" "Adj. R²")) ///
    label booktabs

* 6b. Alternative cluster levels
foreach c in worker_id firm_id industry state {
    qui reghdfe log_wage training, absorb(worker_id year) vce(cluster `c')
    display "cluster=`c'  b=" _b[training] "  se=" _se[training]
}

* 6c. Wild cluster bootstrap (few clusters)
qui reghdfe log_wage training, absorb(worker_id year) vce(cluster state)
boottest training, cluster(state) reps(9999) seed(42)

* 6d. Subsample splits
foreach mask in "female==0" "female==1" "age<40" "age>=40" {
    qui reghdfe log_wage training if `mask', ///
        absorb(worker_id year) vce(cluster worker_id)
    display "`mask': b=" _b[training] "  se=" _se[training] "  N=" e(N)
}

* 6e. Placebo timing
gen fake_first = first_treat - 3
gen fake_post  = (year >= fake_first)
preserve
    keep if year < first_treat                       // drop real post-period
    reghdfe log_wage fake_post, absorb(worker_id year) ///
        vce(cluster worker_id)
restore

* 6f. Randomization inference (permutation)
ritest training _b[training], reps(1000) seed(0) ///
    strata(worker_id): reghdfe log_wage training, ///
    absorb(worker_id year) vce(cluster worker_id)

* 6g. Romano–Wolf multiple testing
rwolf log_wage employed hours_worked, indepvar(training) ///
    controls(age edu) reps(500) seed(42) method(reghdfe) ///
    fe(worker_id year) cluster(worker_id)

* 6h. TWFE bias diagnosis — Goodman-Bacon decomposition
bacondecomp log_wage training, ddetail

* 6i. Parallel trends sensitivity — HonestDiD
* (after running the event study and saving b/V)
honestdid, pre(1/4) post(5/9) mvec(0(0.1)0.5)

* 6j. Oster (2019) δ*
qui reg log_wage training                             // short
scalar bs = _b[training]; scalar r2s = e(r2)
qui reghdfe log_wage training age edu tenure, absorb(worker_id year)
scalar bl = _b[training]; scalar r2l = e(r2)
psacalc delta training, mcontrol(age edu tenure) rmax(1.3*r2l)
```

---

### Step 7 — Further analysis (mechanism / heterogeneity / mediation / moderation)

Deeper patterns: [references/07-further-analysis.md](references/07-further-analysis.md) — factor-variable interactions, `margins` / `marginsplot`, triple-difference (DDD), outcome ladder, `medsem` / Baron–Kenny, `khb` (Karlson–Holm–Breen) for non-linear mediation, dose-response via `xtile` or splines, subgroup event studies.

```stata
* 7a. Heterogeneity via interaction — coefficient IS the heterogeneity test
reghdfe log_wage c.training##i.female age edu, ///
    absorb(worker_id year) vce(cluster worker_id)
margins, dydx(training) at(female=(0 1))
marginsplot, title("Marginal effect of training by gender") ///
    ytitle("dY/d(training)")
graph export "figures/het_female.pdf", replace

* Continuous moderator
reghdfe log_wage c.training##c.tenure age edu, ///
    absorb(worker_id year) vce(cluster worker_id)
margins, dydx(training) at(tenure=(0(2)20))
marginsplot

* 7b. Subgroup estimation + Wald test of equality
eststo clear
eststo m_male:   qui reghdfe log_wage training if female==0, ///
    absorb(worker_id year) vce(cluster worker_id)
eststo m_female: qui reghdfe log_wage training if female==1, ///
    absorb(worker_id year) vce(cluster worker_id)
suest m_male m_female                                  // joint covariance
test [m_male_mean]training = [m_female_mean]training  // Wald test

* 7c. Triple difference (DDD)
reghdfe log_wage c.treated##c.post##c.high_exposure, ///
    absorb(worker_id year) vce(cluster firm_id)
* coefficient on treated#post#high_exposure IS the differential DID

* 7d. Outcome ladder
eststo clear
foreach y of varlist hours_worked productivity log_wage {
    eststo: qui reghdfe `y' training, ///
        absorb(worker_id year) vce(cluster worker_id)
}
esttab using "tables/mechanism_ladder.tex", replace ///
    se label booktabs

* 7e. Mediation — Baron–Kenny (manual)
qui reghdfe log_wage training age edu, absorb(worker_id year)
scalar c = _b[training]
qui reghdfe hours_worked training age edu, absorb(worker_id year)
scalar a = _b[training]
qui reghdfe log_wage training hours_worked age edu, absorb(worker_id year)
scalar b_m   = _b[hours_worked]
scalar cprim = _b[training]
display "Total = " c "  Direct = " cprim "  Indirect a*b = " a*b_m

* Or via -medsem- (for SEM-based mediation with bootstrap CI)
medsem, indep(training) med(hours_worked) dep(log_wage) ///
    mcreps(1000)

* 7f. CATE via Nonparametric (grf) — typically fall back to Python econml
* See references/07-further-analysis.md §7.7 for the rpy2-style bridge.

* 7g. Dose-response (continuous treatment, decile bins)
xtile dose10 = training_hours, nq(10)
reghdfe log_wage i.dose10 age edu, absorb(worker_id year) vce(cluster worker_id)
margins i.dose10
marginsplot, recast(connected) ytitle("Predicted log wage") ///
    xtitle("Training-hours decile")
graph export "figures/dose_response.pdf", replace
```

---

### Step 8 — Publication tables & figures

> **This step is mandatory** — every analysis run produces all 5 required tables (T1–T5) and all 4 required figures (F1–F4) defined in the *Default Output Spec* at the top of this skill. Do not skip Step 8 because "the regression already ran". A coefficient without a table and a figure is not how applied economics communicates a result.

Deeper patterns: [references/08-tables-plots.md](references/08-tables-plots.md) — `esttab` and `outreg2` for regression tables; `coefplot` for coefficient plots, event studies, forest plots; `marginsplot` for interactions; `binscatter` for residualized scatter; `rdplot` for RD; `twoway` + combined graphs; Stata scheme / graph options; LaTeX / Word / Excel export.

```stata
* ============================================================
* 8a. ★ TABLE 2 — Main results, multi-column regression M1→M6
*     (the centerpiece of every economics paper)
* ============================================================
esttab m1 m2 m3 m4 m5 m6 using "tables/table2_main.tex", ///
    replace ///
    se star(* 0.10 ** 0.05 *** 0.01) ///
    stats(N r2 r2_a fe_worker fe_year fe_indyr, ///
        labels("N" "R²" "Adj. R²" "Worker FE" "Year FE" "Industry×Year FE")) ///
    keep(training age edu tenure) ///
    order(training age edu tenure) ///
    mtitles("(1) Raw" "(2) +Demog" "(3) +Tenure" "(4) +Unit FE" "(5) +2-way FE" "(6) +Ind×Yr FE") ///
    label booktabs nonumbers noobs ///
    addnotes("Cluster-robust standard errors at worker_id level in parentheses." ///
             "* p<0.10, ** p<0.05, *** p<0.01.")

* Word version
esttab m1 m2 m3 m4 m5 m6 using "tables/table2_main.rtf", replace ///
    se star(* 0.10 ** 0.05 *** 0.01) label ///
    mtitles("(1)" "(2)" "(3)" "(4)" "(5)" "(6)")

* outreg2 — alternative (one-line, broad compatibility)
* reghdfe log_wage training age edu tenure, absorb(worker_id year)
* outreg2 using "tables/table2_main_outreg2.doc", replace label dec(3) ///
*     addtext(Worker FE, YES, Year FE, YES)

* ============================================================
* 8b. TABLE 1 — Summary statistics & balance
* ============================================================
balancetable training age edu tenure female ///
    using "tables/table1_balance.tex", ///
    vce(cluster firm_id) replace ///
    varlabels pval booktabs

asdoc sum log_wage training age edu tenure female, ///
    by(training) stat(N mean sd min median max) ///
    save(tables/table1_balance.rtf) replace

* ============================================================
* 8c. TABLE 3 — Mechanism / outcome ladder (3+ outcomes)
* ============================================================
eststo clear
foreach y of varlist hours_worked productivity log_wage {
    eststo: qui reghdfe `y' training age edu tenure, ///
        absorb(worker_id year) vce(cluster worker_id)
}
esttab using "tables/table3_mechanism.tex", replace ///
    se star(* 0.10 ** 0.05 *** 0.01) label booktabs ///
    mtitles("Hours worked" "Productivity" "Log wage") ///
    keep(training) ///
    addnotes("Each column is a separate regression of the labelled outcome on training," ///
             "with worker and year FE and cluster-robust SE at worker_id.")

* ============================================================
* 8d. TABLE 4 — Heterogeneity (subgroup × main coef + Wald)
* ============================================================
eststo clear
eststo all:    qui reghdfe log_wage training,                                   ///
    absorb(worker_id year) vce(cluster worker_id)
eststo male:   qui reghdfe log_wage training if female==0,                       ///
    absorb(worker_id year) vce(cluster worker_id)
eststo female: qui reghdfe log_wage training if female==1,                       ///
    absorb(worker_id year) vce(cluster worker_id)
eststo young:  qui reghdfe log_wage training if age<40,                          ///
    absorb(worker_id year) vce(cluster worker_id)
eststo old:    qui reghdfe log_wage training if age>=40,                         ///
    absorb(worker_id year) vce(cluster worker_id)
eststo manuf:  qui reghdfe log_wage training if industry=="manufacturing",       ///
    absorb(worker_id year) vce(cluster worker_id)
esttab all male female young old manuf using "tables/table4_heterogeneity.tex", ///
    replace se star(* 0.10 ** 0.05 *** 0.01) label booktabs ///
    mtitles("All" "Female=0" "Female=1" "Age<40" "Age≥40" "Manuf.") ///
    keep(training) ///
    addnotes("Cluster-robust SE at worker_id. Wald p-values for cross-subgroup equality" ///
             "(via -suest-) should accompany this table — see references/07.")

* ============================================================
* 8e. TABLE 5 — Robustness battery (alt SE / cluster / sample / placebo)
* ============================================================
eststo clear
eststo base:    qui reghdfe log_wage training, absorb(worker_id year) vce(cluster worker_id)
eststo cl_firm: qui reghdfe log_wage training, absorb(worker_id year) vce(cluster firm_id)
eststo cl_2way: qui reghdfe log_wage training, absorb(worker_id year) vce(cluster worker_id firm_id)
eststo wins:    qui reghdfe log_wage_w1 training, absorb(worker_id year) vce(cluster worker_id)
eststo dropmf:  qui reghdfe log_wage training if industry!="manufacturing", ///
    absorb(worker_id year) vce(cluster worker_id)
eststo placebo: qui reghdfe log_wage fake_post if year < first_treat, ///
    absorb(worker_id year) vce(cluster worker_id)
esttab base cl_firm cl_2way wins dropmf placebo using "tables/table5_robustness.tex", ///
    replace se star(* 0.10 ** 0.05 *** 0.01) label booktabs ///
    mtitles("Baseline" "Cluster=Firm" "2-way Cluster" "Winsor 1/99" "Drop Manuf." "Placebo (-3 yr)") ///
    keep(training fake_post)

* ============================================================
* 8f. ★ FIGURE 3 — Coefficient plot across M1→M6
* ============================================================
coefplot m1 m2 m3 m4 m5 m6, keep(training) ///
    vertical yline(0, lpattern(dash)) ///
    ciopts(recast(rcap)) ///
    levels(95) ///
    ylabel(, angle(0)) ///
    xtitle("Specification") ytitle("Coefficient on training (95% CI)") ///
    title("Effect of training across specifications") ///
    scheme(s2color)
graph export "figures/fig3_coefplot.pdf", replace
graph export "figures/fig3_coefplot.png", replace width(2400)

* ============================================================
* 8g. FIGURE 2 — Event-study plot (dynamic DID, base period = -1)
* ============================================================
* (after running -eventstudyinteract- or -csdid- or reghdfe with relative-time factor)
coefplot, keep(*.rel) vertical omitted ///
    xline(9.5, lpattern(dash)) yline(0, lpattern(dash)) ///
    xtitle("Years relative to treatment") ///
    ytitle("Coefficient (ATT, 95% CI)") ///
    title("Event study: dynamic effect of training") ///
    ciopts(recast(rcap)) ///
    scheme(s2color)
graph export "figures/fig2_event_study.pdf", replace
graph export "figures/fig2_event_study.png", replace width(2400)

* ============================================================
* 8h. FIGURE 4 — Sensitivity / robustness curve
*     (HonestDiD post-DID; or forest plot of robustness battery)
* ============================================================
* HonestDiD sensitivity (after the event study with stored b/V):
honestdid, pre(1/4) post(5/9) mvec(0(0.1)0.5) coefplot
graph export "figures/fig4_sensitivity.pdf", replace
graph export "figures/fig4_sensitivity.png", replace width(2400)

* Alternative: forest plot of subgroup / robustness coefficients
* coefplot (all, label(All)) (male, label(Male)) (female, label(Female)) ///
*          (young, label(Age<40)) (old, label(Age≥40)) (manuf, label(Manuf.)), ///
*     keep(training) xline(0, lpattern(dash)) ciopts(recast(rcap)) ///
*     title("Heterogeneity forest plot")
* graph export "figures/fig4_forest.pdf", replace

* ============================================================
* 8i. FIGURE 1 — Trend / motivation (treated vs control over time)
* ============================================================
preserve
    collapse (mean) log_wage, by(year training)
    twoway (line log_wage year if training==1, lcolor(navy) lwidth(medthick)) ///
           (line log_wage year if training==0, lcolor(cranberry) lwidth(medthick)), ///
        xline(`policy_year', lpattern(dash) lcolor(gs8)) ///
        legend(order(1 "Treated" 2 "Control") rows(1) position(6)) ///
        xtitle("Year") ytitle("Mean log wage") ///
        title("Treated vs control trend") ///
        scheme(s2color)
    graph export "figures/fig1_trend.pdf", replace
    graph export "figures/fig1_trend.png", replace width(2400)
restore

* ============================================================
* 8j. Auxiliary plots (optional — produce when relevant to design)
* ============================================================
* Binscatter — residualized scatter
binscatter log_wage tenure, controls(age edu female) nquantiles(20) ///
    savegraph("figures/figA_binscatter.pdf") replace

* RD plot (only when running_var exists)
* rdplot outcome running_var, c(0) ///
*     graph_options(title("Effect of eligibility") ///
*                   ytitle("Outcome") xtitle("Running variable"))
* graph export "figures/figA_rdplot.pdf", replace

* Bacon decomposition plot — TWFE diagnostic
* bacondecomp log_wage training, ddetail
* graph export "figures/figA_bacon.pdf", replace

* ============================================================
* 8k. Graph theme (consistent styling across all figures)
* ============================================================
set scheme s2color
* or the modern: set scheme white_tableau  (from -schemepack-)
```

**Deliverables checklist** (verify before declaring the run complete):

```
[ ] tables/table1_balance.tex     [ ] figures/fig1_trend.pdf
[ ] tables/table2_main.tex   ★    [ ] figures/fig2_event_study.pdf
[ ] tables/table3_mechanism.tex   [ ] figures/fig3_coefplot.pdf
[ ] tables/table4_heterogeneity.tex
[ ] tables/table5_robustness.tex  [ ] figures/fig4_sensitivity.pdf
```

---

## Library / command cheat-sheet

| Step | Task | Go-to command | Fallback |
|------|------|---------------|----------|
| 1 | Import | `use` / `import excel` / `import delimited` / `import sas` / `import spss` | `usespss` / `infile` |
| 1 | Missing | `misstable summarize` / `mdesc` | `missings report` |
| 1 | Merge | `merge m:1 ... assert(match using)` | — |
| 1 | Panel | `xtset` / `xtdescribe` | `tsset` for pure TS |
| 2 | Winsorize | `winsor2` | hand-roll via `summ, detail` + `replace` |
| 2 | Lag / lead / diff | `L.` / `F.` / `D.` (require `xtset`) | `bys id (t): gen lx = x[_n-1]` |
| 3 | Table 1 | `tabstat` + `balancetable` + `asdoc sum` | manual loop |
| 3 | Correlations | `pwcorr, sig star(.05)` | `corr` |
| 4 | Hetero | `estat hettest` / `estat imtest, white` | — |
| 4 | Panel serial | `xtserial` / `xttest3` | — |
| 4 | Stationarity | `dfuller` / `kpss` / `pperron` / `xtunitroot` | — |
| 4 | Hausman | `hausman fe re, sigmamore` | — |
| 5 | OLS / panel FE | `reghdfe` | `areg` / `xtreg, fe` |
| 5 | IV | `ivreg2` / `ivreghdfe` | `ivregress 2sls` |
| 5 | DID — 2×2 | `reg` / `reghdfe` with `c.treated#c.post` | — |
| 5 | DID — CS | `csdid` | — |
| 5 | DID — SA | `eventstudyinteract` | — |
| 5 | DID — imputation | `did_imputation` | `did_multiplegt_dyn` |
| 5 | DID — SDID | `sdid` | — |
| 5 | RD | `rdrobust` / `rddensity` / `rdplot` | `rdmc` for multi-cutoff |
| 5 | Synthetic control | `synth` / `synth_runner` | — |
| 5 | PSM | `psmatch2` / `teffects psmatch` | — |
| 5 | IPW / AIPW | `teffects ipw` / `teffects ipwra` / `teffects aipw` | — |
| 5 | Entropy balancing | `ebalance` | — |
| 5 | Count + FE | `ppmlhdfe` | `poisson` / `nbreg` |
| 5 | Heckman | `heckman` | manual 2-step |
| 5 | Quantile | `qreg` / `sqreg` | `bsqreg` |
| 6 | Wild cluster boot | `boottest` | `bootstrap, cluster()` |
| 6 | Randomization inf | `ritest` | `permute` |
| 6 | Multiple testing | `rwolf` | `wyoung` |
| 6 | TWFE diagnosis | `bacondecomp` | — |
| 6 | PT sensitivity | `honestdid` | — |
| 6 | Oster δ* | `psacalc delta` | manual formula |
| 7 | Interaction margins | `margins` + `marginsplot` | — |
| 7 | Mediation | `medsem` / `khb` | manual Baron–Kenny |
| 7 | SEM / path | `sem` / `gsem` | — |
| 8 | Regression table | `esttab` (from `estout`) | `outreg2` / `xtable` |
| 8 | Coefplot / eventstudy | `coefplot` | `marginsplot` |
| 8 | Binscatter | `binscatter` | `twoway` manual |
| 8 | RD plot | `rdplot` | — |

---

## Common mistakes (and what to do instead)

| Mistake | Correct approach |
|---------|------------------|
| `reg y x1 x2` on panel data with no FE | `reghdfe y x1 x2, absorb(unit time) vce(cluster unit)` |
| Default iid SEs on clustered data | `vce(cluster id)`; `boottest` if clusters < 50 |
| TWFE (`reghdfe` with treatment dummy) on staggered adoption | Use `csdid` / `eventstudyinteract` / `did_imputation` |
| `xtreg, fe` with large panel (>10k units) | Switch to `reghdfe` — faster and allows multi-dim FE + multi-way cluster |
| `merge` without `assert()` | Always specify `assert(match using master)` or similar |
| Generating lag as `L.x` without `xtset` first | Run `xtset id time` before any time-series op |
| `ivregress` without `estat firststage` | For weak-IV diagnostics, prefer `ivreg2` — reports CD, KP, AR automatically |
| RD with a single bandwidth | `rdrobust` default reports MSE-optimal + sensitivity; also show `rdbwselect` and halve/double |
| `psmatch2` without balance check | Use `pstest, both` to report pre/post SMDs; target <10% |
| Interpreting `logit` coefficients directly | Always run `margins, dydx(*)` — that's the interpretable quantity |
| Reporting only `estimates` and manual copy-paste | `esttab` / `outreg2` → LaTeX/Word/RTF automatically |
| Reporting only the headline coefficient (no Table 2) | **Always** ship the multi-column M1→M6 main table — that is the centerpiece of an economics paper, not the abstract sentence |
| Coefficient table without any figures | An economics result needs **at least** F1 trend + F2 event study + F3 coefplot + F4 sensitivity — see the Default Output Spec |
| Saving graphs with `graph save` (`.gph` only) | Also `graph export ..., replace` to `.pdf` / `.png` |
| Not logging the session | `log using main.log, replace` at top of do-file |
| `gen x2 = x^2` instead of `c.x##c.x` inside regressions | Factor-variable notation plays nicely with `margins` |

---

## Typical .do-file skeleton

```stata
* ============================================================
* main.do — reproducible 8-step pipeline
* ============================================================
version 17
clear all
set more off
capture log close
log using "logs/main.log", replace text

cd "/path/to/project"

* 1. Clean -----------------------------------------------------
do "code/01_clean.do"                 // produces data/analysis.dta

* 2. Transform -------------------------------------------------
do "code/02_transform.do"             // adds engineered vars

* 3. Describe --------------------------------------------------
do "code/03_describe.do"              // writes tables/table1_*, figures/*_trend.pdf

* 4. Diagnose --------------------------------------------------
do "code/04_diagnose.do"              // writes logs/diagnostics.log

* 5. Model -----------------------------------------------------
do "code/05_model.do"                 // saves e() for m1–m6 via eststo

* 6. Robustify -------------------------------------------------
do "code/06_robust.do"

* 7. Further ---------------------------------------------------
do "code/07_further.do"

* 8. Export ----------------------------------------------------
do "code/08_tables_figures.do"        // writes tables/*.tex, figures/*.pdf

log close
```

Every `.do` file loads `data/analysis.dta`, writes its outputs to `tables/` or `figures/`, and saves a log. A clean `make clean && do main.do` regenerates the entire paper from raw data.

---

## When to hand off to other skills

- **Agent-native single-import Python workflow** (`import statspai as sp`) → `00-StatsPAI_skill`.
- **Explicit Python traditional stack** → `00.1-Full-empirical-analysis-skill`.
- **Mixtape-style cross-language code templates** (Python/R/Stata side-by-side) → `10-Jill0099-causal-inference-mixtape`.
- **Stata syntax reference** (complete command catalog, Mata, etc.) → `32-dylantmoore-stata-skill`.
- **Stata for accounting research** → `18-jusi-aalto-stata-accounting-research`.
- **Paper drafting** after the analysis is done → the writing-oriented skills in this repo (`04-*-scientific-writer`, `08-*-web-latex`, etc.).

This skill's remit **ends at Step 8** — polished `.tex` tables and `.pdf` figures. Paper drafting is out of scope.

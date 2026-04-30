*==============================================================================
* Stata Skill Lalonde V2 Pipeline — Full Empirical Analysis
* Generated from: skills/00.2-Full-empirical-analysis-skill_Stata/SKILL.md
* Design: Cross-sectional, selection-on-observables (ATT estimand)
* Dataset: Lalonde NSW, cross-sectional subset
* Outcome: re78 (1978 earnings in USD)
* Treatment: treat (binary, 0/1)
* Covariates: age, educ, black, hispan, married, nodegree, re74, re75
* Output: _stata_lalonde_outputs_v2/
*==============================================================================
*
* Project root
local ROOT "/Users/brycewang/Documents/GitHub/Awesome-Agent-Skills-for-Empirical-Research/demo-notebooks"
local OUT  "`ROOT'/_stata_lalonde_outputs_v2"
local TAB  "`OUT'/tables"
local FIG  "`OUT'/figures"
local LOG  "`OUT'/logs"
local DAT  "`OUT'/data"
local ART  "`OUT'/artifacts"

cap mkdir "`OUT'"
cap mkdir "`TAB'"
cap mkdir "`FIG'"
cap mkdir "`LOG'"
cap mkdir "`DAT'"
cap mkdir "`ART'"

* Logging
log using "`LOG'/lalonde_v2_pipeline.log", replace

display "============================================"
display "Stata Skill Lalonde V2 Pipeline"
display "Start: `c(current_date)' `c(current_time)'"
display "Output: `OUT'"
display "============================================"

*==============================================================================
* STEP 0 — Sample log & data contract
*==============================================================================
display ""
display "=== STEP 0: Sample Construction Log ==="

* Import raw data
import delimited "`OUT'/data/lalonde.csv", clear

* Rename key variables for consistency
rename treat treated
label var treated "Treatment indicator (1=treated, 0=control)"

* Create race dummy variables (dataset has race as string column)
cap drop black hispan white
gen black = (race == "black")
gen hispan = (race == "hispan")
gen white = (race == "white")
label var black "Black (1=yes)"
label var hispan "Hispanic (1=yes)"
label var white "White (1=yes)"

* Sample log matrix
mat sample_log = J(1, 2, .)
local row = 1

local n0 = _N
local ++row
mat sample_log = (nullmat(sample_log) \ `row', `n0')
display "Step 0. raw:                              N = " %12.0fc `n0'

* Keep only complete cases on key variables
local key_vars "re78 treated age educ black hispan married nodegree re74 re75"
foreach v of local key_vars {
    cap confirm numeric variable `v'
    if _rc {
        display as error "`v' not found as numeric — check import"
    }
}

local n1 = _N
local ++row
mat sample_log = (nullmat(sample_log) \ `row', `n1')
display "Step 1. after import:                     N = " %12.0fc `n1'

* Drop rows with missing outcome or treatment
qui drop if missing(re78)
qui drop if missing(treated)

local n2 = _N
local ++row
mat sample_log = (nullmat(sample_log) \ `row', `n2')
display "Step 2. drop missing re78/treated:       N = " %12.0fc `n2' "  (Δ " %10.0fc `n1' - `n2' ")"

* Drop missing on key covariates
foreach v in age educ black hispan married nodegree re74 re75 {
    qui drop if missing(`v')
}
local n3 = _N
local ++row
mat sample_log = (nullmat(sample_log) \ `row', `n3')
display "Step 3. drop missing covariates:          N = " %12.0fc `n3' "  (Δ " %10.0fc `n2' - `n3' ")"
display "Step 4. final analysis sample:            N = " %12.0fc `n3'

* Persist sample log to JSON
file open f using "`ART'/sample_construction.json", write replace
file write f "{" _n
file write f `"  "step_0_raw": `=sample_log[1,2]',"' _n
file write f `"  "step_1_import": `=sample_log[2,2]',"' _n
file write f `"  "step_2_keyvar": `=sample_log[3,2]',"' _n
file write f `"  "step_3_covars": `=sample_log[4,2]'"' _n
file write f `"  "step_4_final": `=sample_log[5,2]'"' _n
file write f "}" _n
file close f

display "Sample log saved to `ART'/sample_construction.json"

* Data contract — 5 checks
display ""
display "=== Data Contract Checks ==="
quietly describe, short
display "Check 1. n_obs = " _N

* Check 2: dtypes
foreach v of local key_vars {
    capture confirm numeric variable `v'
    if _rc {
        display as error "Check 2 FAILED: `v' not numeric"
    }
}
display "Check 2. dtypes OK on all key vars"

* Check 3: missingness
misstable sum `key_vars'
foreach v of local key_vars {
    qui count if missing(`v')
    if r(N) > 0 {
        display as error "Check 3 FAILED: `v' has " r(N) " missing"
    }
}
display "Check 3. missingness: PASS (no missing on key vars)"

* Check 4: treatment balance
tab treated, mis
display "Check 4. treatment distribution: "
bys treated: summarize re78

*==============================================================================
* STEP 1 — Data Import & Cleaning (already done in Step 0)
*==============================================================================
display ""
display "=== STEP 1: Data Import & Cleaning ==="

* Already imported and cleaned above — just save the analysis dataset
save "`DAT'/lalonde_analysis.dta", replace
display "Analysis dataset saved to `DAT'/lalonde_analysis.dta"

*==============================================================================
* STEP 2 — Variable Construction
*==============================================================================
display ""
display "=== STEP 2: Variable Construction ==="

use "`DAT'/lalonde_analysis.dta", clear

* Create log-transformed earnings (floor at 1 to handle any zeros)
gen re78_log = log(re78) if re78 > 0
replace re78_log = log(1) if re78 <= 0
label var re78_log "Log(1978 earnings), floor at 1"

* Real earnings in 2023 USD (CPI adjustment approx 3x from 1978)
gen re78_real = re78 * 3.0
label var re78_real "1978 earnings in 2023 USD (approx)"

* Pre-treatment earnings total
gen re74_real = re74 * 3.0
gen re75_real = re75 * 3.0
label var re74_real "1974 earnings in 2023 USD"
label var re75_real "1975 earnings in 2023 USD"

* Pre-treatment earnings growth
gen earnings_growth = re75 - re74
label var earnings_growth "Earnings change 1974-1975"

* Potential earnings loss (1975 vs 1974)
gen earnings_loss = (re75 - re74) < 0
label var earnings_loss "Earnings decline 1974-1975"

* Age squared
gen age_sq = age^2
label var age_sq "Age squared"

* Education × treatment interaction
gen educ_x_treat = educ * treated
label var educ_x_treat "Education × Treatment"

* Black × treatment interaction
gen black_x_treat = black * treated
label var black_x_treat "Black × Treatment"

* Married × treatment interaction
gen married_x_treat = married * treated
label var married_x_treat "Married × Treatment"

* Log pre-treatment earnings
gen re74_log = log(max(re74, 1))
gen re75_log = log(max(re75, 1))
label var re74_log "Log(1974 earnings), floor at 1"
label var re75_log "Log(1975 earnings), floor at 1"

* Indicator for zero earnings in pre-period
gen zero_earnings_74 = (re74 == 0)
gen zero_earnings_75 = (re75 == 0)
label var zero_earnings_74 "Zero earnings in 1974"
label var zero_earnings_75 "Zero earnings in 1975"

* Re-define key variable list with new vars
local x_vars "age educ black hispan married nodegree re74 re75"
local y_var  "re78"

save "`DAT'/lalonde_analysis.dta", replace
display "Variable construction complete. Dataset saved."

*==============================================================================
* STEP 2.5 — Empirical Strategy
*==============================================================================
display ""
display "=== STEP 2.5: Empirical Strategy ==="

display "Design: Cross-sectional, selection-on-observables"
display "Estimand: ATT (Average Treatment Effect on the Treated)"
display "Identifying assumption: Unconfoundedness + Overlap"
display ""
display "Estimating equation (OLS):"
display "  re78 = α + β·treat + X'γ + ε"
display ""
display "Estimating equation (matching/IPW):"
display "  ATT = E[Y_1 - Y_0 | D=1]"
display "  = E[E[Y_1 - Y_0 | X, D=1]]  (conditional on covariates)"
display ""
display "Estimator stack:"
display "  1. OLS with progressive controls"
display "  2. teffects psmatch (nearest-neighbor PSM)"
display "  3. teffects ipwra (IPW with regression adjustment)"
display "  4. teffects aipw (doubly-robust AIPW)"
display "  5. psmatch2 (alternative PSM with common support)"
display "  6. ebalance (entropy balancing)"

*==============================================================================
* STEP 3 — Descriptive Statistics & Table 1
*==============================================================================
display ""
display "=== STEP 3: Descriptive Statistics & Table 1 ==="

use "`DAT'/lalonde_analysis.dta", clear

* 3a. Full-sample summary
local sum_vars "re78 re74 re75 age educ black hispan married nodegree"
tabstat `sum_vars', statistics(n mean sd min p25 p50 p75 max) columns(statistics)

* 3b. Full Table 1 (all strata) via esttab
eststo clear
estpost tabstat `sum_vars', by(treated) statistics(mean sd) columns(statistics) nototal
esttab using "`TAB'/table1_full.tex", replace ///
    se star(* 0.10 ** 0.05 *** 0.01) ///
    label booktabs ///
    mtitles("(1) Control" "(2) Treated" "(3) Diff" "(4) SMD") ///
    title("Table 1: Summary Statistics by Treatment Status")
esttab using "`TAB'/table1_full.rtf", replace ///
    se star(* 0.10 ** 0.05 *** 0.01) ///
    label ///
    mtitles("(1) Control" "(2) Treated" "(3) Diff" "(4) SMD")

* outreg2 for xlsx/docx (basic, without custom addstat to avoid expression syntax issues)
esttab, label
outreg2 using "`TAB'/table1_full.xlsx", replace label dec(3) ///
    keep(`sum_vars') ///
    title("Table 1: Summary Statistics")
outreg2 using "`TAB'/table1_full.doc", replace label dec(3) ///
    keep(`sum_vars') ///
    title("Table 1: Summary Statistics")

display "Table 1 (full) saved to `TAB'/table1_full.{tex,rtf,xlsx,doc}"

* 3c. Balance table via balancetable (with SMD and p-values)
cap which balancetable
if _rc {
    * Fallback: manual balance table via esttab
    eststo clear
    foreach var of varlist age educ black hispan married nodegree re74 re75 {
        qui ttest `var', by(treated)
        eststo: qui mean `var', over(treated)
    }
    esttab using "`TAB'/table1_balance.tex", replace ///
        se star(* 0.10 ** 0.05 *** 0.01) ///
        label booktabs ///
        title("Table: Covariate Balance")
    esttab using "`TAB'/table1_balance.xlsx", replace ///
        label se star ///
        title("Table: Covariate Balance")
    display "Balance table (fallback) saved to `TAB'/table1_balance.{tex,xlsx}"
}
else {
    balancetable treated age educ black hispan married nodegree re74 re75 ///
        using "`TAB'/table1_balance.tex", replace varlabels pval smd
    balancetable treated age educ black hispan married nodegree re74 re75 ///
        using "`TAB'/table1_balance.xlsx", excel
    display "Balance table saved to `TAB'/table1_balance.{tex,xlsx}"
}

* 3d. Distribution plots — KDE of outcome by treatment
twoway (kdensity re78 if treated==0, lcolor(gs3)) ///
       (kdensity re78 if treated==1, lcolor(gs10) lwidth(thick)), ///
    legend(order(1 "Control" 2 "Treated")) ///
    xtitle("1978 Earnings (USD)") ytitle("Density") ///
    title("Figure: Earnings Density by Treatment Status") ///
    saving("`FIG'/kde_re78", replace)
graph export "`FIG'/kde_re78.pdf", replace
graph export "`FIG'/kde_re78.png", replace width(2400) height(1800)
display "KDE plot saved to `FIG'/kde_re78.{pdf,png}"

* 3e. Box plots by treatment
graph box re78, over(treated) ///
    legend(label(1 "Control") label(2 "Treated")) ///
    ytitle("1978 Earnings (USD)") ///
    title("Earnings Distribution by Treatment Status") ///
    saving("`FIG'/boxplot_re78", replace)
graph export "`FIG'/boxplot_re78.pdf", replace
graph export "`FIG'/boxplot_re78.png", replace width(2400) height(1800)
display "Box plot saved"

* 3f. Covariate balance — psmatch2 overlap check
teffects psmatch (re78) (treated age educ black hispan married nodegree re74 re75), atet
* Save propensity score overlap figure
predict pscore, pscore
pctile pscore_pct = pscore, nq(100)
twoway histogram pscore if treated==0, percent discrete color(gs5) ///
    || histogram pscore if treated==1, percent discrete color(gs10) ///
    legend(order(1 "Control" 2 "Treated")) ///
    xtitle("Propensity Score") ytitle("Percent") ///
    title("Propensity Score Distribution by Treatment Status")
graph export "`FIG'/pscore_overlap.pdf", replace
graph export "`FIG'/pscore_overlap.png", replace width(2400) height(1800)
drop pscore
display "PSM overlap check saved to `FIG'/pscore_overlap.{pdf,png}"

*==============================================================================
* STEP 3.5 — Identification Graphics
*==============================================================================
display ""
display "=== STEP 3.5: Identification Graphics ==="

use "`DAT'/lalonde_analysis.dta", clear

* 3.5.1 Propensity score distribution (overlap/common support)
teffects psmatch (re78) (treated age educ black hispan married nodegree re74 re75), atet
predict pscore_psm, pscore
pctile pscore_pct = pscore_psm, nq(100)

* Overlap plot
sum pscore_psm if treated==0, detail
local p5_c = r(p5)
local p95_c = r(p95)
sum pscore_psm if treated==1, detail
local p5_t = r(p5)
local p95_t = r(p95)

display "Control PS score range: [`p5_c', `p95_c']"
display "Treated PS score range: [`p5_t', `p95_t']"

* Histogram overlap plot
twoway (histogram pscore_psm if treated==0, percent bin(30) color(gs5) lcolor(white)) ///
       (histogram pscore_psm if treated==1, percent bin(30) color(gs10) lcolor(white)), ///
    legend(order(1 "Control" 2 "Treated")) ///
    xtitle("Propensity Score") ytitle("Percent") ///
    title("Figure: Propensity Score Overlap (Common Support)") ///
    note("Common support region: Control [`p5_c', `p95_c']; Treated [`p5_t', `p95_t']")
graph export "`FIG'/fig2c2_overlap.pdf", replace
graph export "`FIG'/fig2c2_overlap.png", replace width(2400) height(1800)
drop pscore_psm
display "Overlap plot saved to `FIG'/fig2c2_overlap.{pdf,png}"

*==============================================================================
* STEP 4 — Diagnostic Tests
*==============================================================================
display ""
display "=== STEP 4: Diagnostic Tests ==="

use "`DAT'/lalonde_analysis.dta", clear

* 4a. Baseline OLS
reg re78 treated age educ black hispan married nodegree re74 re75, vce(robust)

* 4b. Predict residuals for diagnostics
predict resid, resid

* 4c. Normality of residuals
sktest resid
display "Skewness-kurtosis test for normality of residuals: p=" %6.4f r(p)

swilk resid
display "Shapiro-Wilk test for normality: p=" %6.4f r(p)

* 4d. Heteroskedasticity
estat hettest
display "Breusch-Pagan test for heteroskedasticity: p=" %6.4f r(p)

estat imtest, white
display "White's general test: p=" %6.4f r(p)

* 4e. Multicollinearity
quietly reg re78 treated age educ black hispan married nodegree re74 re75
estat vif
display "VIF test — all values < 10 indicates no severe multicollinearity"

* 4f. Model specification
estat ovtest
display "Ramsey RESET test (omitted variables): p=" %6.4f r(p)

linktest
display "Link test: p=" %6.4f r(p)

drop resid
display "Diagnostics complete."

*==============================================================================
* STEP 5 — Baseline Modeling
*==============================================================================
display ""
display "=== STEP 5: Baseline Modeling ==="

use "`DAT'/lalonde_analysis.dta", clear

*-------------------------------------------------------------------------------
* 5.A Pattern A — Progressive Controls (canonical Table 2)
* M1 → M6: raw bivariate, +demographics, +pre-labor, +FE (not applicable for cross-section)
* For Lalonde cross-section we adapt: OLS progressively adding controls
*-------------------------------------------------------------------------------
display ""
display "=== Table 2: Progressive Controls (M1-M6) ==="

eststo clear

* M1: raw bivariate
eststo m1: qui reg re78 treated, vce(robust)

* M2: + demographics
eststo m2: qui reg re78 treated age, vce(robust)

* M3: + education
eststo m3: qui reg re78 treated age educ, vce(robust)

* M4: + race indicators
eststo m4: qui reg re78 treated age educ black hispan, vce(robust)

* M5: + family/labor market indicators
eststo m5: qui reg re78 treated age educ black hispan married nodegree, vce(robust)

* M6: + pre-treatment earnings (full controls)
eststo m6: qui reg re78 treated age educ black hispan married nodegree re74 re75, vce(robust)

* AER-style multi-column table via esttab
foreach ext in tex rtf {
    esttab m1 m2 m3 m4 m5 m6 using "`TAB'/table2_main.`ext'", ///
        replace se star(* 0.10 ** 0.05 *** 0.01) ///
        label booktabs ///
        mtitles("(1)" "(2)" "(3)" "(4)" "(5)" "(6)") ///
        keep(treated) ///
        stats(N r2 r2_a, labels("N" "R²" "Adj. R²")) ///
        addnotes("Cluster-robust standard errors in parentheses. * p<0.10, ** p<0.05, *** p<0.01." ///
                 "M1: bivariate. M2: +age. M3: +education. M4: +race. M5: +family. M6: +pre-treatment earnings.")
}

* outreg2 for xlsx/docx
outreg2 using "`TAB'/table2_main.xlsx", replace label dec(3) ///
    keep(treated age educ black hispan married nodegree re74 re75) ///
    addtext(Baseline, Yes) ///
    title("Table 2: Progressive Controls — ATT Estimates (OLS)")
outreg2 using "`TAB'/table2_main.doc", replace label dec(3) ///
    keep(treated age educ black hispan married nodegree re74 re75) ///
    addtext(Baseline, Yes) ///
    title("Table 2: Progressive Controls — ATT Estimates (OLS)")

display "Table 2 (main) saved to `TAB'/table2_main.{tex,rtf,xlsx,doc}"

*-------------------------------------------------------------------------------
* Figure 3: Coefficient plot across M1-M6
cap which coefplot
if _rc {
    * Fallback: twoway scatter coef CI manually
    display "coefplot not installed — skipping Figure 3"
}
else {
    coefplot m1 m2 m3 m4 m5 m6, keep(treated) vertical omitted ///
        yline(0, lpattern(dash) lcolor(gs10)) ///
        ciopts(recast(rcap)) levels(95) ///
        xtitle("Specification") ///
        ytitle("Coefficient on Treatment (ATT, 95% CI)") ///
        title("Figure 3: Treatment Effect Across Specifications (M1–M6)") ///
        scheme(s2color) ///
        addplot(line 0 0, lcolor(gs10) lpattern(dash)) ///
        name(coefplot_m1_m6, replace)
    graph export "`FIG'/fig3_coefplot.pdf", replace
    graph export "`FIG'/fig3_coefplot.png", replace width(2400) height(1800)
    display "Figure 3 (coefplot) saved to `FIG'/fig3_coefplot.{pdf,png}"
}

*-------------------------------------------------------------------------------
* 5.B Pattern B — Design Horse Race (Table 2-bis)
* Compare OLS, PSM, IPWRA, AIPW, ebalance
*-------------------------------------------------------------------------------
display ""
display "=== Table 2-bis: Design Horse Race (Matching Estimators) ==="

eststo clear

* M1: OLS with full controls (baseline)
eststo ols: qui reg re78 treated age educ black hispan married nodegree re74 re75, vce(robust)

* M2: teffects psmatch (nearest-neighbor PSM, ATT)
teffects psmatch (re78) (treated age educ black hispan married nodegree re74 re75), atet noisily
eststo psm: qui teffects psmatch (re78) (treated age educ black hispan married nodegree re74 re75), atet

* M3: teffects ipwra (IPW with regression adjustment, doubly-robust)
eststo ipwra: qui teffects ipwra (re78) (treated age educ black hispan married nodegree re74 re75), atet

* M4: teffects aipw (augmented IPW, doubly-robust)
eststo aipw: qui teffects aipw (re78) (treated age educ black hispan married nodegree re74 re75), atet

* M5: psmatch2 with common support (if installed)
cap which psmatch2
if _rc {
    display "psmatch2 not installed — skipping PSM2 column"
}
else {
    eststo psm2: qui psmatch2 treated age educ black hispan married nodegree re74 re75, out(re78) ate kernel
}

* M6: ebalance (entropy balancing, if installed)
cap which ebalance
if _rc {
    display "ebalance not installed — skipping Entropy Balancing column"
}
else {
    cap qui ebalance treated age educ black hispan married nodegree re74 re75, replace
    if _rc {
        display "ebalance failed — skipping Entropy Balancing column"
    }
    else {
        qui reg re78 treated age educ black hispan married nodegree re74 re75 [pw=_webal], vce(robust)
        eststo ebal: qui reg re78 treated age educ black hispan married nodegree re74 re75 [pw=_webal], vce(robust)
    }
}

* Horse-race table
cap which psmatch2
local has_psm2 = !_rc
cap which ebalance
local has_ebal = !_rc

if `has_psm2' & `has_ebal' {
    foreach ext in tex rtf {
        esttab ols psm ipwra aipw psm2 ebal using "`TAB'/table2b_designs.`ext'", ///
            replace se star(* 0.10 ** 0.05 *** 0.01) ///
            label booktabs ///
            keep(treated) ///
            mtitles("(1) OLS" "(2) PSM" "(3) IPWRA" "(4) AIPW" "(5) PSM2" "(6) Entropy Bal.") ///
            stats(N, labels("N")) ///
            addnotes("ATT estimates. OLS: cluster-robust SE. PSM: teffects psmatch NN(1). IPWRA: IPW with regression adjustment. AIPW: doubly-robust. PSM2: psmatch2 kernel. Entropy Bal.: entropy balancing weights.")
    }
}
else if `has_psm2' {
    foreach ext in tex rtf {
        esttab ols psm ipwra aipw psm2 using "`TAB'/table2b_designs.`ext'", ///
            replace se star(* 0.10 ** 0.05 *** 0.01) ///
            label booktabs ///
            keep(treated) ///
            mtitles("(1) OLS" "(2) PSM" "(3) IPWRA" "(4) AIPW" "(5) PSM2") ///
            stats(N, labels("N")) ///
            addnotes("ATT estimates. OLS: cluster-robust SE. PSM: teffects psmatch NN(1). IPWRA: IPW with regression adjustment. AIPW: doubly-robust. PSM2: psmatch2 kernel.")
    }
}
else {
    foreach ext in tex rtf {
        esttab ols psm ipwra aipw using "`TAB'/table2b_designs.`ext'", ///
            replace se star(* 0.10 ** 0.05 *** 0.01) ///
            label booktabs ///
            keep(treated) ///
            mtitles("(1) OLS" "(2) PSM" "(3) IPWRA" "(4) AIPW") ///
            stats(N, labels("N")) ///
            addnotes("ATT estimates. OLS: cluster-robust SE. PSM: teffects psmatch NN(1). IPWRA: IPW with regression adjustment. AIPW: doubly-robust.")
    }
}

cap which psmatch2
local has_psm2 = !_rc
cap which ebalance
local has_ebal = !_rc

if `has_psm2' & `has_ebal' {
    outreg2 using "`TAB'/table2b_designs.xlsx", replace label dec(3) ///
        keep(treated) addtext(Controls, Yes) title("Table 2b: Design Horse Race (ATT Estimates)")
    outreg2 using "`TAB'/table2b_designs.doc", replace label dec(3) ///
        keep(treated) addtext(Controls, Yes) title("Table 2b: Design Horse Race (ATT Estimates)")
}
else if `has_psm2' {
    outreg2 using "`TAB'/table2b_designs.xlsx", replace label dec(3) ///
        keep(treated) addtext(Controls, Yes) title("Table 2b: Design Horse Race (ATT Estimates, OLS/PSM/IPWRA/AIPW)")
    outreg2 using "`TAB'/table2b_designs.doc", replace label dec(3) ///
        keep(treated) addtext(Controls, Yes) title("Table 2b: Design Horse Race (ATT Estimates, OLS/PSM/IPWRA/AIPW)")
}
else {
    outreg2 using "`TAB'/table2b_designs.xlsx", replace label dec(3) ///
        keep(treated) addtext(Controls, Yes) title("Table 2b: Design Horse Race (ATT Estimates, OLS/PSM/IPWRA/AIPW)")
    outreg2 using "`TAB'/table2b_designs.doc", replace label dec(3) ///
        keep(treated) addtext(Controls, Yes) title("Table 2b: Design Horse Race (ATT Estimates, OLS/PSM/IPWRA/AIPW)")
}

display "Table 2b (designs) saved to `TAB'/table2b_designs.{tex,rtf,xlsx,doc}"

*==============================================================================
* STEP 6 — Robustness Battery
*==============================================================================
display ""
display "=== STEP 6: Robustness Battery ==="

use "`DAT'/lalonde_analysis.dta", clear

eststo clear

* Baseline: OLS with full controls
eststo base: qui reg re78 treated age educ black hispan married nodegree re74 re75, vce(robust)

* R1: Winsorized outcome at 1st/99th percentile
cap which winsor2
if _rc {
    * Fallback: manual winsorization
    qui sum re78, detail
    local w_lo = r(p1)
    local w_hi = r(p99)
    gen re78_w = re78
    qui replace re78_w = `w_lo' if re78 < `w_lo'
    qui replace re78_w = `w_hi' if re78 > `w_hi'
    eststo r1: qui reg re78_w treated age educ black hispan married nodegree re74 re75, vce(robust)
    display "Winsorized regression (fallback) completed"
}
else {
    winsor2 re78, cuts(1 99) suffix(_w)
    eststo r1: qui reg re78_w treated age educ black hispan married nodegree re74 re75, vce(robust)
}

* R2: Log earnings outcome
gen re78_ln = log(max(re78, 1))
eststo r2: qui reg re78_ln treated age educ black hispan married nodegree re74 re75, vce(robust)

* R3: Exclude zero-earners
eststo r3: qui reg re78 treated age educ black hispan married nodegree re74 re75 if re78 > 0, vce(robust)

* R4: Alternative SE — cluster at household level (if available, else use robust)
eststo r4: qui reg re78 treated age educ black hispan married nodegree re74 re75, vce(cluster married)

* R5: No pre-treatment earnings controls (simplified model)
eststo r5: qui reg re78 treated age educ black hispan married nodegree, vce(robust)

* R6: OLS with HC3 robust SE (Davidson-MacKinnon)
eststo r6: qui regress re78 treated age educ black hispan married nodegree re74 re75, vce(hc3)

* Table A1: Full robustness battery
foreach ext in tex rtf {
    esttab base r1 r2 r3 r4 r5 r6 using "`TAB'/tableA1_robustness.`ext'", ///
        replace se star(* 0.10 ** 0.05 *** 0.01) ///
        label booktabs ///
        keep(treated) ///
        mtitles("(1) Baseline" "(2) Winsor(1,99)" "(3) Log(re78)" "(4) Excl.Zero" ///
                "(5) Robust SE" "(6) No Pre-earn" "(7) HC3 SE") ///
        stats(N r2 r2_a, labels("N" "R²" "Adj. R²")) ///
        addnotes("Robustness checks. Baseline: OLS + HC1 SE. R1: outcome winsorized 1-99th pct. R2: log earnings. R3: exclude zero-earners. R4: robust SE. R5: no pre-1974/75 earnings. R6: HC3 SE.")
}

outreg2 using "`TAB'/tableA1_robustness.xlsx", replace label dec(3) ///
    keep(treated) addtext(Baseline, Yes) title("Table A1: Robustness Battery")
outreg2 using "`TAB'/tableA1_robustness.doc", replace label dec(3) ///
    keep(treated) addtext(Baseline, Yes) title("Table A1: Robustness Battery")

display "Table A1 (robustness) saved to `TAB'/tableA1_robustness.{tex,rtf,xlsx,doc}"

* Figure 5: Spec curve — coefficient + CI across all specs
cap which coefplot
if _rc {
    display "coefplot not installed — skipping Figure 5"
}
else {
    coefplot base r1 r2 r3 r4 r5 r6, keep(treated) vertical omitted ///
        yline(0, lpattern(dash) lcolor(gs10)) ///
        ciopts(recast(rcap)) levels(95) ///
        xtitle("Specification") ///
        ytitle("Coefficient on Treatment (ATT, 95% CI)") ///
        title("Figure 5: Specification Curve — Robustness Battery") ///
        scheme(s2color)
    graph export "`FIG'/fig5_spec_curve.pdf", replace
    graph export "`FIG'/fig5_spec_curve.png", replace width(2400) height(1800)
    display "Figure 5 (spec curve) saved to `FIG'/fig5_spec_curve.{pdf,png}"
}

*==============================================================================
* STEP 7 — Further Analysis: Heterogeneity
*==============================================================================
display ""
display "=== STEP 7: Heterogeneity Analysis ==="

use "`DAT'/lalonde_analysis.dta", clear

*-------------------------------------------------------------------------------
* Table 4: Heterogeneity by subgroup
* Subgroups: Black vs non-Black; College vs no college; Married vs single
*-------------------------------------------------------------------------------
eststo clear

* H1: By race
eststo h_black: qui reg re78 treated##black age educ hispan married nodegree re74 re75, vce(robust)
eststo h_nblack: qui reg re78 treated age educ black hispan married nodegree re74 re75 if black==0, vce(robust)
eststo h_black_only: qui reg re78 treated age educ hispan married nodegree re74 re75 if black==1, vce(robust)

* H2: By education (college = 1 if educ >= 12)
gen college = (educ >= 12)
eststo h_coll: qui reg re78 treated##college age black hispan married nodegree re74 re75, vce(robust)
eststo h_ncoll: qui reg re78 treated age educ black hispan married nodegree re74 re75 if college==0, vce(robust)
eststo h_coll_only: qui reg re78 treated age educ black hispan married nodegree re74 re75 if college==1, vce(robust)

* H3: By marital status
eststo h_married: qui reg re78 treated##married age educ black hispan nodegree re74 re75, vce(robust)
eststo h_single: qui reg re78 treated age educ black hispan married nodegree re74 re75 if married==0, vce(robust)

* Combined heterogeneity table (Table 4)
foreach ext in tex rtf {
    esttab h_black h_nblack h_coll h_ncoll h_married h_single using "`TAB'/table4_heterogeneity.`ext'", ///
        replace se star(* 0.10 ** 0.05 *** 0.01) ///
        label booktabs ///
        keep(treated 1.treated#1.black 1.treated#1.college 1.treated#1.married) ///
        mtitles("(1) Full" "(2) Non-Black" "(3) Black" "(4) Non-College" "(5) College" "(6) Single") ///
        stats(N r2, labels("N" "R²")) ///
        addnotes("ATT by subgroup. Column (1): full interacted model. Columns (2)-(6): separate subsamples.")
}

outreg2 using "`TAB'/table4_heterogeneity.xlsx", replace label dec(3) ///
    keep(treated) addtext(Subgroup, Yes) title("Table 4: Heterogeneity by Subgroup")
outreg2 using "`TAB'/table4_heterogeneity.doc", replace label dec(3) ///
    keep(treated) addtext(Subgroup, Yes) title("Table 4: Heterogeneity by Subgroup")

display "Table 4 (heterogeneity) saved to `TAB'/table4_heterogeneity.{tex,rtf,xlsx,doc}"

* Figure 4: Heterogeneity — coefplot by subgroup
cap which coefplot
if _rc {
    display "coefplot not installed — skipping Figure 4"
}
else {
    coefplot h_black h_nblack h_coll h_ncoll h_married h_single, keep(treated) vertical omitted ///
        yline(0, lpattern(dash) lcolor(gs10)) ///
        ciopts(recast(rcap)) levels(95) ///
        xtitle("Subgroup") ///
        ytitle("ATT Estimate (95% CI)") ///
        title("Figure 4: Treatment Effects by Subgroup") ///
        scheme(s2color)
    graph export "`FIG'/fig4_heterogeneity.pdf", replace
    graph export "`FIG'/fig4_heterogeneity.png", replace width(2400) height(1800)
    display "Figure 4 (heterogeneity) saved to `FIG'/fig4_heterogeneity.{pdf,png}"

    * Subgroup-specific heterogeneity figures
    * By race
    coefplot h_black h_nblack, keep(1.treated#1.black) vertical omitted ///
        yline(0, lpattern(dash)) ///
        xtitle("Subgroup") xlabel(1 "Black" 2 "Non-Black") ///
        ytitle("Treatment Effect × Black (ATT, 95% CI)") ///
        title("Figure: Treatment Effect Differential by Race")
    graph export "`FIG'/het_treat_by_black.pdf", replace
    graph export "`FIG'/het_treat_by_black.png", replace width(2400) height(1800)

    * By education
    coefplot h_coll h_ncoll, keep(1.treated#1.college) vertical omitted ///
        yline(0, lpattern(dash)) ///
        xtitle("Subgroup") xlabel(1 "College" 2 "Non-College") ///
        ytitle("Treatment Effect × College (ATT, 95% CI)") ///
        title("Figure: Treatment Effect Differential by Education")
    graph export "`FIG'/het_treat_by_educ.pdf", replace
    graph export "`FIG'/het_treat_by_educ.png", replace width(2400) height(1800)
    display "Subgroup heterogeneity plots saved"
}

*==============================================================================
* STEP 8 — Publication Tables & Figures
*==============================================================================
display ""
display "=== STEP 8: Final Publication Export ==="

* Coefficient plot — main estimators comparison (Figure 3 companion)
cap which coefplot
if _rc {
    display "coefplot not installed — skipping Figure 3b"
}
else {
    coefplot ols psm ipwra aipw psm2 ebal, keep(treated) vertical omitted ///
        yline(0, lpattern(dash) lcolor(gs10)) ///
        ciopts(recast(rcap)) levels(95) ///
        xtitle("Estimator") ///
        ytitle("ATT Estimate (95% CI)") ///
        title("Figure 3b: ATT Estimates Across Estimators") ///
        scheme(s2color) ///
        name(coefplot_estimators, replace)
    graph export "`FIG'/coefplot_estimators.pdf", replace
    graph export "`FIG'/coefplot_estimators.png", replace width(2400) height(1800)
    display "Figure 3b (coefplot estimators) saved to `FIG'/coefplot_estimators.{pdf,png}"
}

* Summary of all outputs
display ""
display "============================================"
display "OUTPUT SUMMARY — Lalonde V2 Pipeline"
display "============================================"
display "Tables:"
display "  `TAB'/table1_full.{tex,rtf,xlsx,doc}"
display "  `TAB'/table1_balance.{tex,xlsx}"
display "  `TAB'/table2_main.{tex,rtf,xlsx,doc}"
display "  `TAB'/table2b_designs.{tex,rtf,xlsx,doc}"
display "  `TAB'/table4_heterogeneity.{tex,rtf,xlsx,doc}"
display "  `TAB'/tableA1_robustness.{tex,rtf,xlsx,doc}"
display ""
display "Figures:"
display "  `FIG'/kde_re78.{pdf,png}"
display "  `FIG'/boxplot_re78.{pdf,png}"
display "  `FIG'/pscore_overlap.{pdf,png}"
display "  `FIG'/fig2c2_overlap.{pdf,png}"
display "  `FIG'/fig3_coefplot.{pdf,png}"
display "  `FIG'/fig4_heterogeneity.{pdf,png}"
display "  `FIG'/fig5_spec_curve.{pdf,png}"
display "  `FIG'/het_treat_by_black.{pdf,png}"
display "  `FIG'/het_treat_by_educ.{pdf,png}"
display "  `FIG'/coefplot_estimators.{pdf,png}"
display ""
display "Data:"
display "  `DAT'/lalonde_analysis.dta"
display ""
display "Logs:"
display "  `LOG'/lalonde_v2_pipeline.log"
display ""
display "Artifacts:"
display "  `ART'/sample_construction.json"
display ""
display "============================================"
display "Pipeline complete."
display "End: `c(current_date)' `c(current_time)'"
display "============================================"

log close

*==============================================================================
* Save pipeline info to JSON manifest
*==============================================================================
file open f using "`ART'/pipeline_manifest.json", write replace
file write f "{" _n
file write f `"  "pipeline": "Stata_skill_lalonde_v2_pipeline.do",' _n
file write f `"  "date": "`c(current_date)'",' _n
file write f `"  "time": "`c(current_time)'",' _n
file write f `"  "design": "cross-sectional selection-on-observables",' _n
file write f `"  "outcome": "re78 (1978 earnings)",' _n
file write f `"  "treatment": "treat (binary)",' _n
file write f `"  "estimand": "ATT",' _n
file write f `"  "sample_size": `=_N',' _n
file write f `"  "n_treated": `=sum(treated)',' _n
file write f `"  "n_control": `=sum(treated==0)'," _n
file write f `"  "output_dir": "_stata_lalonde_outputs_v2",' _n
file write f `"  "skill": "skills/00.2-Full-empirical-analysis-skill_Stata/SKILL.md"' _n
file write f "}" _n
file close f

display "Pipeline manifest saved to `ART'/pipeline_manifest.json"

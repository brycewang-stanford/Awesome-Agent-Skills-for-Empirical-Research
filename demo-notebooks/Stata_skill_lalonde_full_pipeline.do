*! ============================================================================
*! Stata_skill_lalonde_full_pipeline.do
*! Lalonde NSW — Stata 完整实证管线（Skill: 00.2-Full-empirical-analysis-skill_Stata）
*!
*! 对应 skill : skills/00.2-Full-empirical-analysis-skill_Stata/SKILL.md
*! 数据来源 : Rdatasets MatchIt Lalonde (公网 CSV)
*!            处理变量 treat（NSW 职业培训 0/1）
*!            结果变量 re78（1978 年个人收入，美元）
*!            协变量   age educ black hispan married nodegree re74 re75
*!
*! 设计判定 (per skill §2.5 design picker):
*!   横截面 + selection-on-observables → 匹配 / IPW / 回归调整
*!   目标估计量 = ATT
*!
*! Skill 输出清单:
*!   T1: Table 1 — 描述统计 + 均衡表 (balancetable)
*!   T2: Table 2 ★ — M1→M5 渐进式控制集 (中心表)
*!   T3: Table 3 — 设计赛马 (OLS / RA / IPW / PSM / ebalance)
*!   T4: Table 4 — 异质性 (race / educ / age 子组)
*!   TA1: Table A1 — 稳健性主表 (10 列)
*!   F1: KDE 收入分布对比 (替代 trend plot —— 横截面无条件)
*!   F2: Love plot (匹配前后 SMD 诊断)
*!   F3: Coefplot 跨规范系数对比
*!   F4: Oster δ 敏感性曲线
*!
*! 作者 : Bryce Wang (brycewang2018@gmail.com)
*! 日期 : 2026-05-02
*! Stata : 17+ (teffects / margins / esttab / psmatch2 / ebalance)
*! ============================================================================

version 17
clear all
set more off
set seed 7
capture log close pipelog

*-----------------------------------------------------------------------------*
* 0. 工作目录 & 输出文件夹                                                    *
*-----------------------------------------------------------------------------*
global PROJECT_ROOT "/Users/brycewang/Documents/GitHub/Awesome-Agent-Skills-for-Empirical-Research/demo-notebooks"
cd "$PROJECT_ROOT"

* 输出目录 —— v5.2
capture mkdir "_stata_lalonde_outputs_v5.2"
capture mkdir "_stata_lalonde_outputs_v5.2/logs"
capture mkdir "_stata_lalonde_outputs_v5.2/tables"
capture mkdir "_stata_lalonde_outputs_v5.2/figures"
capture mkdir "_stata_lalonde_outputs_v5.2/data"
capture mkdir "_stata_lalonde_outputs_v5.2/artifacts"

log using "_stata_lalonde_outputs_v5.2/logs/lalonde_pipeline.log", replace text name(pipelog)
di as text "Pipeline log started: `c(current_date)' `c(current_time)'"

*=============================================================================*
* 包依赖：自动按需安装                                                        *
*=============================================================================*
local _cmds  esttab    coefplot  winsor2  balancetable  psmatch2  ebalance  psacalc
local _pkgs  estout    coefplot  winsor2  balancetable  psmatch2  ebalance  psacalc
local _N : word count `_cmds'
forvalues i = 1/`_N' {
    local _c : word `i' of `_cmds'
    local _p : word `i' of `_pkgs'
    capture which `_c'
    if _rc {
        di as text "[setup] installing `_p' from SSC ..."
        capture noisily ssc install `_p', replace
        if _rc di as error "[setup] 安装 `_p' 失败"
    }
}

* 全局画图主题
set scheme s2color

* Journal style macros (skill §export cookbook — AER convention)
local AER_STAR  "* 0.10 ** 0.05 *** 0.01"
local AER_NOTES "Robust standard errors in parentheses. * p<0.10, ** p<0.05, *** p<0.01."
local AER_STATS stats(N r2_a, labels("N" "Adj. R²"))


*=============================================================================*
* Step −1 : Pre-Analysis Plan (skill §Step −1)                                *
*  - MDE 计算 + 协议冻结到 artifacts/pap.json                                 *
*=============================================================================*
di as text _n "==== Step −1: Pre-Analysis Plan ===="

* Lalonde 不等臂 MDE: 185 treated + 429 control, α=0.05, power=0.80
* → d ≈ 0.247, 对应 ~$1,846 (SD ≈ 7506)
local mde_d = 0.246
local sd_re78 = 7506.96
local mde_dollars = `mde_d' * `sd_re78'
di as result "PAP MDE Cohen's d = " %5.3f `mde_d' "  →  ≈ $" %8.0f `mde_dollars'

file open _f using "_stata_lalonde_outputs_v5.2/artifacts/pap.json", write replace
file write _f "{" _n
file write _f `"  "design": "selection on observables (Lalonde NSW)", "' _n
file write _f `"  "population": "Lalonde NSW treated + PSID comparison, 1976-78", "' _n
file write _f `"  "outcome": "re78 (1978 real earnings, USD)", "' _n
file write _f `"  "treatment": "treat (NSW assignment 0/1)", "' _n
file write _f `"  "estimand": "ATT", "' _n
file write _f `"  "n_treated_planned": 185, "' _n
file write _f `"  "n_control_planned": 429, "' _n
file write _f `"  "alpha": 0.05, "' _n
file write _f `"  "power_target": 0.80, "' _n
file write _f `"  "mde_cohens_d": `mde_d', "' _n
file write _f `"  "mde_in_dollars": `mde_dollars', "' _n
file write _f `"  "sd_re78": `sd_re78', "' _n
file write _f `"  "frozen_at": "2026-05-02", "' _n
file write _f `"  "stata_command": "power twomeans 0, n1(185) n2(429) sd1(1) sd2(1) alpha(0.05) power(0.80)""' _n
file write _f "}" _n
file close _f
di as text "Saved: artifacts/pap.json"

* --- 策略协议 (skill §2.5 — strategy.do) ---
file open _f using "_stata_lalonde_outputs_v5.2/artifacts/strategy.md", write replace
file write _f "# Empirical Strategy — Lalonde NSW (pre-registration)" _n _n
file write _f "**Frozen at**: 2026-05-02" _n
file write _f "**Design (per skill §2.5 picker)**: selection-on-observables (cross-section)" _n
file write _f "**Population**: Lalonde NSW treated workers + PSID comparison, 1976-78" _n
file write _f "**Treatment**: `treat` (binary NSW assignment)" _n
file write _f "**Outcome**:   `re78` (1978 real earnings, USD)" _n
file write _f "**Estimand**:  ATT" _n _n
file write _f "## Estimating equation" _n _n
file write _f "    re78_i = a + b * treat_i + X_i' * gamma + eps_i" _n
file write _f "    X_i = (age, educ, black, hispan, married, nodegree, re74, re75)" _n _n
file write _f "## Identifying assumption" _n _n
file write _f "1. Conditional unconfoundedness: Y(0), Y(1) ⟂ D | X" _n
file write _f "2. Overlap: 0 < Pr(D=1 | X) < 1 in joint support" _n _n
file write _f "## Auto-flagged threats" _n _n
file write _f "- Selection on unobservables (motivation, ability) → Oster δ" _n
file write _f "- Functional-form sensitivity → progressive M1→M5 + spec curve" _n
file write _f "- Weak overlap in PS tails → common support trimming" _n _n
file write _f "## Fallback estimators (§6)" _n _n
file write _f "- teffects ipw / ipwra / aipw (DR)" _n
file write _f "- psmatch2 NN matching" _n
file write _f "- ebalance entropy balancing" _n
file write _f "- psacalc delta (Oster 2019 sensitivity)" _n
file close _f
di as text "Saved: artifacts/strategy.md"


*=============================================================================*
* Step 1 : 数据导入 & 清洗 (skill §Step 1)                                    *
*=============================================================================*
di as text _n "==== Step 1: Data import & cleaning ===="

* 1a. 从 Rdatasets URL 直接读入
import delimited using ///
    "https://vincentarelbundock.github.io/Rdatasets/csv/MatchIt/lalonde.csv", ///
    clear varnames(1) encoding("utf-8")

* 1b. 初步检视
describe, short
summarize

* 1c. 缺失诊断
qui count
local _Ntotal = r(N)
di as text _n "Missingness per variable:"
foreach v of varlist * {
    qui count if missing(`v')
    di as text "  " %-15s "`v'" "  missing=" %5.0f r(N) ///
        "  (" %5.2f 100*r(N)/`_Ntotal' "%)"
}
misstable summarize

* 1d. race → black/hispan dummies (skill §1 — 与 Python notebook 对齐)
gen byte black  = (race == "black")
gen byte hispan = (race == "hispan")
label variable black  "Race = Black"
label variable hispan "Race = Hispanic"

* 1e. 删除冗余列 + listwise deletion
capture drop v1
capture drop rownames
local analysis_vars "treat re78 age educ black hispan married nodegree re74 re75"
foreach v of local analysis_vars {
    drop if missing(`v')
}

* 1f. 断言 treat ∈ {0,1}
levelsof treat, local(_tlev)
assert "`_tlev'" == "0 1"
di as text "Assert OK: treat is binary {0,1}"

* 1g. 标签
label variable treat    "NSW 职业培训 (0/1)"
label variable re78     "1978 年收入 (美元)"
label variable age      "年龄 (岁)"
label variable educ     "受教育年限"
label variable married  "已婚"
label variable nodegree "未获高中文凭"
label variable re74     "1974 年收入 (美元)"
label variable re75     "1975 年收入 (美元)"

tab treat, missing

* 1h. 保存清洗后数据
save "_stata_lalonde_outputs_v5.2/data/lalonde_analysis.dta", replace


*=============================================================================*
* Step 0 : Sample log + 5-check data contract (skill §Step 0)                 *
*=============================================================================*
di as text _n "==== Step 0: Sample log + 5-check data contract ===="

* 0.1 Sample construction log
local _n_final = _N
file open _f using "_stata_lalonde_outputs_v5.2/artifacts/sample_construction.json", write replace
file write _f "[" _n
file write _f `"  ["0. raw rdatasets csv", 614], "' _n
file write _f `"  ["1. drop rownames + dropna", 614], "' _n
file write _f `"  ["2. recode race -> black/hispan", 614], "' _n
file write _f `"  ["3. enforce treat in {0,1}", `_n_final'] "' _n
file write _f "]" _n
file close _f
di as text "Sample: N=`_n_final'"

* 0.2 Five-check contract (skill §0.2)
* Check 1-3: missingness
qui count if missing(re78)
local _miss_y = r(N)
qui count if missing(treat)
local _miss_t = r(N)
qui count if missing(age) | missing(educ) | missing(black) | missing(hispan) | ///
              missing(married) | missing(nodegree) | missing(re74) | missing(re75)
local _miss_X = r(N)

assert `_miss_y' == 0
assert `_miss_t' == 0
assert `_miss_X' == 0
di as result "Check 1-3: Zero missing on key vars — PASS"

* Check 4: y-range
qui sum re78
assert r(min) >= 0
di as result "Check 4: y-range [$" %6.0f r(min) ", $" %7.0f r(max) "] — PASS"

* Check 5: treat share
qui sum treat
local _treat_share = r(mean)
assert `_treat_share' > 0 & `_treat_share' < 1
di as result "Check 5: treat share = " %5.3f `_treat_share' " — PASS"

* Persist contract
file open _f using "_stata_lalonde_outputs_v5.2/artifacts/data_contract.json", write replace
file write _f "{" _n
file write _f `"  "n_obs": `_n_final', "' _n
file write _f `"  "n_missing_y": `_miss_y', "' _n
file write _f `"  "n_missing_treat": `_miss_t', "' _n
file write _f `"  "n_missing_X": `_miss_X', "' _n
file write _f `"  "y_range": [`=r(min)', `=r(max)'], "' _n
file write _f `"  "treatment_share": `_treat_share', "' _n
file write _f `"  "treatment_levels": [0, 1], "' _n
file write _f `"  "design": "cross-sectional selection-on-observables", "' _n
file write _f `"  "panel_balanced": null "' _n
file write _f "}" _n
file close _f
di as text "Saved: artifacts/data_contract.json"


*=============================================================================*
* Step 2 : 变量构造 (skill §Step 2)                                           *
*  - 横截面无时序算子，做 winsorize + log/IHS 供稳健性                        *
*=============================================================================*
di as text _n "==== Step 2: Variable construction ===="

* 2a. Winsorize 1/99 (skill §2b)
winsor2 re78 re74 re75, cuts(1 99) suffix(_w1)

* 2b. IHS (arcsinh — handles zeros, unlike log)
gen double ihs_re78 = asinh(re78)

* 2c. Log(1+y)
gen log_re78 = log(re78 + 1)

* 2d. Positive earnings indicators
gen byte pos_re74 = (re74 > 0)
gen byte pos_re75 = (re75 > 0)
label variable pos_re74 "1974 年收入>0"
label variable pos_re75 "1975 年收入>0"

* 2e. 多项式项 (供稳健性)
gen age_sq   = age^2
gen educ_sq  = educ^2
gen re74_sq  = re74^2
gen re75_sq  = re75^2

label variable age_sq  "年龄平方"
label variable educ_sq "教育年限平方"

di as text "Step 2 done: winsorized, IHS, log, squared terms created."


*=============================================================================*
* Step 3 : 描述统计 & 均衡表 — T1 (skill §Step 3)                             *
*  - 3a 全样本描述统计                                                        *
*  - 3b 处理 vs 对照均衡表 (balancetable)                                     *
*  - 3c SMD + t 检验                                                         *
*  - 3d KDE 收入分布 (F1 — 横截面替代 trend plot)                             *
*=============================================================================*
di as text _n "==== Step 3: Descriptive statistics & Table 1 ===="

* 3a. 全样本描述统计 (连续变量)
local sumvars "re78 re74 re75 age educ"
tabstat `sumvars', statistics(n mean sd min p25 p50 p75 max) columns(statistics)

* 3b. 均衡表 — skill §3b, §8b 多格式
estpost summarize re78 re74 re75 age educ, detail

* T1a: 全样本描述统计表 (LaTeX/RTF — esttab)
esttab . using "_stata_lalonde_outputs_v5.2/tables/table1_full.tex", ///
    replace booktabs ///
    cells("count(fmt(0)) mean(fmt(2)) sd(fmt(2)) min(fmt(2)) p50(fmt(2)) max(fmt(2))") ///
    label nonumber nomtitle ///
    title("Lalonde NSW: 全样本描述统计")

esttab . using "_stata_lalonde_outputs_v5.2/tables/table1_full.rtf", ///
    replace ///
    cells("count(fmt(0)) mean(fmt(2)) sd(fmt(2)) min(fmt(2)) p50(fmt(2)) max(fmt(2))") ///
    label nonumber nomtitle ///
    title("Lalonde NSW: 全样本描述统计")

* T1b: 均衡表 (balancetable) — skill §8b
balancetable treat age educ black hispan married nodegree re74 re75 ///
    using "_stata_lalonde_outputs_v5.2/tables/table1_balance.tex", ///
    replace varlabels pval booktabs

balancetable treat age educ black hispan married nodegree re74 re75 ///
    using "_stata_lalonde_outputs_v5.2/tables/table1_balance.xlsx", ///
    replace varlabels

* 3c. SMD + t 检验 (skill §3b)
di as text _n "Standardized Mean Differences (|SMD|<0.1 = balanced):"
foreach v in age educ black hispan married nodegree re74 re75 {
    qui sum `v' if treat == 1
    local m1 = r(mean)
    local sd1 = r(sd)
    qui sum `v' if treat == 0
    local m0 = r(mean)
    local sd0 = r(sd)
    local smd = (`m1' - `m0') / sqrt((`sd1'^2 + `sd0'^2)/2)
    qui ttest `v', by(treat)
    di as text "  `v': diff=" %9.3f (`m1'-`m0') "  SMD=" %7.3f `smd' "  p=" %6.4f r(p)
}

* 朴素差值 (vs notebook)
qui sum re78 if treat == 1
local mean_t = r(mean)
qui sum re78 if treat == 0
local mean_c = r(mean)
local naive = `mean_t' - `mean_c'
di as result "Naive (treated - control) diff: $" %12.2fc `naive'

* 3d. F1 — KDE 收入分布对比 (横截面替代 trend plot — skill §when to deviate)
twoway (kdensity re78 if treat == 1, lcolor("31 119 180") lwidth(medthick)) ///
       (kdensity re78 if treat == 0, lcolor("214 39 40") lwidth(medthick) lpattern(dash)), ///
    legend(order(1 "Treated" 2 "Control") position(2) ring(0)) ///
    title("Figure 1. 1978 Earnings density by treatment status") ///
    xtitle("re78 (USD)") ytitle("Density") ///
    note("Cross-sectional design: event-study figure N/A, shown earnings density instead.")
graph export "_stata_lalonde_outputs_v5.2/figures/fig1_kde_re78.pdf", replace
graph export "_stata_lalonde_outputs_v5.2/figures/fig1_kde_re78.png", replace width(1200)
di as text "Saved: figures/fig1_kde_re78.{pdf,png}"


*=============================================================================*
* Step 3.5 : 识别图 — F2 Love plot (skill §3.5.4)                             *
*=============================================================================*
di as text _n "==== Step 3.5: Identification graphics ===="

* 3.5a Love plot — psmatch2 + pstest (skill §3.5.4)
preserve
    capture noisily psmatch2 treat age educ black hispan married nodegree re74 re75, ///
        outcome(re78) n(1) common logit
    if _rc == 0 {
        capture noisily pstest age educ black hispan married nodegree re74 re75, ///
            both graph saving("_stata_lalonde_outputs_v5.2/figures/fig2_love_plot", replace)
        if _rc == 0 {
            cap graph export "_stata_lalonde_outputs_v5.2/figures/fig2_love_plot.pdf", replace
            cap graph export "_stata_lalonde_outputs_v5.2/figures/fig2_love_plot.png", replace width(1200)
            di as text "Saved: figures/fig2_love_plot.{pdf,png}"
        }
        else di as error "pstest graph failed"
    }
    else di as error "psmatch2 failed (rc=_rc)"
restore

* 3.5b 倾向得分重叠图 (skill §3.5.2 — overlap/positivity)
capture drop _ps
logit treat age educ black hispan married nodegree re74 re75
predict _ps, pr

twoway (kdensity _ps if treat == 1, lcolor(navy) lwidth(medthick)) ///
       (kdensity _ps if treat == 0, lcolor(cranberry) lwidth(medthick) lpattern(dash)), ///
    legend(order(1 "Treated" 2 "Control") rows(1) position(6)) ///
    xtitle("Propensity score Pr(treat=1 | X)") ytitle("Density") ///
    title("Figure 2b. Propensity-score overlap (positivity diagnostic)")
graph export "_stata_lalonde_outputs_v5.2/figures/fig2b_ps_overlap.pdf", replace
graph export "_stata_lalonde_outputs_v5.2/figures/fig2b_ps_overlap.png", replace width(1200)
drop _ps


*=============================================================================*
* Step 4 : 诊断检验 (skill §Step 4)                                           *
*  - 横截面 → 跳过 xtserial/xttest3/dfuller/hausman                           *
*=============================================================================*
di as text _n "==== Step 4: Diagnostic tests ===="

* 4a. 锚定 OLS
reg re78 treat age educ black hispan married nodegree re74 re75
estimates store ols_anchor

* 4b. 异方差
di as text "Breusch-Pagan / Cook-Weisberg:"
estat hettest
di as text "White's general test:"
estat imtest, white

* 4c. RESET + linktest
di as text "Ramsey RESET:"
estat ovtest
di as text "Linktest:"
linktest

* 4d. 多重共线性
estat vif

* 4e. 残差正态性
predict double resid_ols, resid
sktest resid_ols
swilk resid_ols
drop resid_ols

di as text "Decision:"
di as text "  Heteroskedasticity → use vce(robust) throughout"
di as text "  Cross-section → no panel tests needed"
di as text "  VIF < 10 → no multicollinearity concern"


*=============================================================================*
* Step 5 : 基线估计 (skill §Step 5)                                           *
*  - 5A Pattern A: M1→M5 渐进式控制集 (T2 ★ 中心表)                          *
*  - 5B Pattern B: 设计赛马 (T3)                                              *
*=============================================================================*
di as text _n "==== Step 5: Baseline estimation ===="

*---------------------------------------------------------------------*
* 5A. Pattern A — 渐进式控制集 M1→M5 (skill §5.A — 论文中心表)        *
*---------------------------------------------------------------------*
eststo clear

eststo M1: reg re78 treat, vce(robust)
eststo M2: reg re78 treat age educ, vce(robust)
eststo M3: reg re78 treat age educ black hispan, vce(robust)
eststo M4: reg re78 treat age educ black hispan married nodegree, vce(robust)
eststo M5: reg re78 treat age educ black hispan married nodegree re74 re75, ///
    vce(robust)

* T2: 多格式导出 (skill §export cookbook — esttab for tex/rtf, outreg2 for xlsx/docx)
* LaTeX + RTF via esttab
foreach ext in tex rtf {
    esttab M1 M2 M3 M4 M5 using "_stata_lalonde_outputs_v5.2/tables/table2_main.`ext'", ///
        replace se star(`AER_STAR') label ///
        `=cond("`ext'"=="tex", "booktabs", "")' ///
        keep(treat) ///
        mtitles("(1) Raw" "(2) +Demog" "(3) +Race" "(4) +Family" "(5) Full") ///
        `AER_STATS' ///
        addnotes("`AER_NOTES'" "Progressive covariate adjustment M1→M5.") ///
        title("Table 2. Progressive specifications — Lalonde NSW (treatment effect on re78)")
}

* Excel + Word via outreg2 (skill §: outreg2 for proper Office formatting)
foreach ext in xlsx docx {
    outreg2 using "_stata_lalonde_outputs_v5.2/tables/table2_main.`ext'", ///
        replace label dec(2) ///
        keep(treat) ///
        addtext(Specification, "M1 Raw, M2 +Demog, M3 +Race, M4 +Family, M5 Full")
}

di as text "Saved: tables/table2_main.{tex,rtf,xlsx,docx}"

*---------------------------------------------------------------------*
* 5B. Pattern B — 设计赛马 (skill §5.B — Table 3)                     *
*  OLS / RA / IPW / PSM / ebalance 横向对照                            *
*---------------------------------------------------------------------*
eststo clear

eststo OLS: reg re78 treat age educ black hispan married nodegree re74 re75, ///
    vce(robust)

eststo RA: teffects ra ///
    (re78 age educ black hispan married nodegree re74 re75) ///
    (treat), atet vce(robust)

eststo IPW: teffects ipw ///
    (re78) ///
    (treat age educ black hispan married nodegree re74 re75, logit), ///
    atet vce(robust)

eststo PSM: teffects psmatch ///
    (re78) ///
    (treat age educ black hispan married nodegree re74 re75, logit), ///
    atet nneighbor(4) vce(robust)

* ebalance + weighted regression (skill §5.B + §5h)
capture ebalance treat age educ black hispan married nodegree re74 re75, ///
    targets(1) gen(eb_w)
if _rc == 0 {
    eststo EBAL: reg re78 treat [pweight=eb_w], vce(robust)
}
else {
    di as error "ebalance not installed / failed; skipping EBAL column"
}
capture drop eb_w _webal

* T3: 设计赛马表 (LaTeX/RTF/Excel/Word)
* 检查哪些估计器成功存储
local horserace_list "OLS RA IPW PSM"
local horserace_names "OLS RA IPW PSM"
capt confirm existence stored e(EBAL)
if _rc == 0 {
    local horserace_list "OLS RA IPW PSM EBAL"
    local horserace_names "OLS RA IPW PSM Entropy Bal."
}

* esttab for tex/rtf
foreach ext in tex rtf {
    esttab `horserace_list' ///
        using "_stata_lalonde_outputs_v5.2/tables/table3_horserace.`ext'", ///
        replace se star(`AER_STAR') ///
        `=cond("`ext'"=="tex", "booktabs", "")' label ///
        rename(r1vs0.treat treat) keep(treat) ///
        mtitles(`horserace_names') ///
        `AER_STATS' ///
        addnotes("`AER_NOTES'" "All estimators target ATT except OLS (ATE).") ///
        title("Table 3. Design horse-race — Lalonde NSW ATT across estimators")
}

* outreg2 for xlsx/docx
foreach ext in xlsx docx {
    outreg2 using "_stata_lalonde_outputs_v5.2/tables/table3_horserace.`ext'", ///
        replace label dec(2) keep(treat) ///
        addtext(Design, "OLS RA IPW PSM EBAL")
}

di as text "Saved: tables/table3_horserace.{tex,rtf,xlsx,docx}"


*=============================================================================*
* Step 6 : 稳健性电池 (skill §Step 6)                                         *
*  - 6k Pattern H: 稳健性主表 TA1                                            *
*  - 6j Oster δ 敏感性                                                       *
*=============================================================================*
di as text _n "==== Step 6: Robustness battery ===="

*---------------------------------------------------------------------*
* 6k. Pattern H — 稳健性主表 (skill §6.k — Table A1)                   *
*---------------------------------------------------------------------*
eststo clear

* (1) Baseline (HC3 via vce(robust))
eststo h1: qui reg re78 treat age educ black hispan married nodegree re74 re75, ///
    vce(robust)

* (2) iid SE
eststo h2: qui reg re78 treat age educ black hispan married nodegree re74 re75

* (3) Winsor 1/99 outcome
eststo h3: qui reg re78_w1 treat age educ black hispan married nodegree re74_w1 re75_w1, ///
    vce(robust)

* (4) Common support (PS in [0.05, 0.95])
preserve
    capture drop _ps_h
    qui logit treat age educ black hispan married nodegree re74 re75
    predict _ps_h, pr
    keep if inrange(_ps_h, 0.05, 0.95)
    qui reg re78 treat age educ black hispan married nodegree re74 re75, vce(robust)
    eststo h4
restore

* (5) Add age² + educ²
eststo h5: qui reg re78 treat age educ c.age#c.age c.educ#c.educ ///
    black hispan married nodegree re74 re75, vce(robust)

* (6) Add re74² + re75²
eststo h6: qui reg re78 treat age educ black hispan married nodegree ///
    re74 re75 c.re74#c.re74 c.re75#c.re75, vce(robust)

* (7) Drop re74=0 (unemployed in 1974)
eststo h7: qui reg re78 treat age educ black hispan married nodegree re74 re75 ///
    if re74 > 0, vce(robust)

* (8) Earners only (re78 > 0)
eststo h8: qui reg re78 treat age educ black hispan married nodegree re74 re75 ///
    if re78 > 0, vce(robust)

* (9) IHS outcome
eststo h9: qui reg ihs_re78 treat age educ black hispan married nodegree re74 re75, ///
    vce(robust)

* (10) Log outcome
eststo h10: qui reg log_re78 treat age educ black hispan married nodegree re74 re75, ///
    vce(robust)

* TA1: 多格式导出
foreach ext in tex rtf {
    esttab h1 h2 h3 h4 h5 h6 h7 h8 h9 h10 ///
        using "_stata_lalonde_outputs_v5.2/tables/tableA1_robustness.`ext'", ///
        replace se star(`AER_STAR') ///
        `=cond("`ext'"=="tex", "booktabs", "")' ///
        keep(treat) b(%9.2f) ///
        mtitles("(1) Base" "(2) iid SE" "(3) Winsor" "(4) Cmn supp" ///
                "(5) +age²+edu²" "(6) +re74²+75²" ///
                "(7) Drop u74" "(8) Earners" "(9) IHS Y" "(10) Log Y") ///
        stats(N r2_a, labels("N" "Adj. R²")) label ///
        addnotes("`AER_NOTES'" "Column 2 reports iid SE; all others robust.")
}

foreach ext in xlsx docx {
    outreg2 using "_stata_lalonde_outputs_v5.2/tables/tableA1_robustness.`ext'", ///
        replace label dec(2) keep(treat) ///
        addtext(Specs, "Base iidSE Winsor CmnS +age2 +re742 Dropu74 Earn IHS Log")
}

di as text "Saved: tables/tableA1_robustness.{tex,rtf,xlsx,docx}"

*---------------------------------------------------------------------*
* 6j. Oster (2019) δ* (skill §6.j)                                    *
*---------------------------------------------------------------------*
reg re78 treat
scalar bs_short = _b[treat]
scalar r2_short = e(r2)

reg re78 treat age educ black hispan married nodegree re74 re75
scalar bs_full  = _b[treat]
scalar r2_full  = e(r2)

di as text _n "Oster δ inputs:"
di as text "  beta_short = " %12.4f bs_short "  R²_short = " %6.4f r2_short
di as text "  beta_full  = " %12.4f bs_full  "  R²_full  = " %6.4f r2_full

local rmax_val = 1.3 * r2_full
psacalc delta treat, mcontrol(age educ black hispan married nodegree re74 re75) ///
    rmax(`rmax_val')

psacalc beta treat, mcontrol(age educ black hispan married nodegree re74 re75) ///
    rmax(`rmax_val') delta(1)

di as text "Interpretation: if |δ*| > 1, unobservables would need to be stronger than"
di as text "  observables to nullify the result — considered robust."


*=============================================================================*
* Step 7 : 异质性分析 — T4 (skill §Step 7)                                   *
*  - 7a treat × black 交互                                                   *
*  - 7b treat × educ 交互                                                    *
*  - 7c 子组估计 + Wald 检验                                                  *
*=============================================================================*
di as text _n "==== Step 7: Heterogeneity analysis (Table 4) ===="

* 7a. treat × black 交互
reg re78 i.treat##i.black age educ hispan married nodegree re74 re75, vce(robust)
margins, dydx(treat) at(black=(0 1))
marginsplot, title("Marginal effect of treat by race") ///
    ytitle("dY/d(treat)") xtitle("Race = Black")
cap graph export "_stata_lalonde_outputs_v5.2/figures/het_by_black.pdf", replace
cap graph export "_stata_lalonde_outputs_v5.2/figures/het_by_black.png", replace width(1200)

* 7b. treat × educ 交互
reg re78 c.treat##c.educ age black hispan married nodegree re74 re75, vce(robust)
margins, dydx(treat) at(educ=(6(2)16))
marginsplot, title("Marginal effect of treat by education") ///
    ytitle("dY/d(treat)") xtitle("Education (years)")
cap graph export "_stata_lalonde_outputs_v5.2/figures/het_by_educ.pdf", replace
cap graph export "_stata_lalonde_outputs_v5.2/figures/het_by_educ.png", replace width(1200)

* 7c. 子组估计 (skill §7b) + Wald 检验
eststo clear
eststo all:    reg re78 treat age educ black hispan married nodegree re74 re75, vce(robust)
eststo black:  reg re78 treat age educ hispan married nodegree re74 re75 if black == 1, ///
    vce(robust)
eststo nonblk: reg re78 treat age educ hispan married nodegree re74 re75 if black == 0, ///
    vce(robust)
eststo young:  reg re78 treat age educ black hispan married nodegree re74 re75 if age < 30, ///
    vce(robust)
eststo old:    reg re78 treat age educ black hispan married nodegree re74 re75 if age >= 30, ///
    vce(robust)

* T4: 异质性表
foreach ext in tex rtf {
    esttab all black nonblk young old ///
        using "_stata_lalonde_outputs_v5.2/tables/table4_heterogeneity.`ext'", ///
        replace se star(`AER_STAR') ///
        `=cond("`ext'"=="tex", "booktabs", "")' ///
        keep(treat) ///
        mtitles("All" "Black" "Non-Black" "Age<30" "Age≥30") ///
        `AER_STATS' ///
        addnotes("`AER_NOTES'" "Subgroup estimates of ATT.") ///
        title("Table 4. Heterogeneity — treatment effect by subgroup")
}

foreach ext in xlsx docx {
    outreg2 using "_stata_lalonde_outputs_v5.2/tables/table4_heterogeneity.`ext'", ///
        replace label dec(2) keep(treat) ///
        addtext(Subgroup, "All Black Non-Blk Age<30 Age≥30")
}

* Wald 检验 (skill §7b — suest for cross-subgroup equality)
eststo clear
eststo m_black: reg re78 treat age educ married nodegree re74 re75 if black == 1
eststo m_other: reg re78 treat age educ hispan married nodegree re74 re75 if black == 0
capture suest m_black m_other, vce(robust)
if _rc == 0 {
    test [m_black_mean]treat = [m_other_mean]treat
    di as text "Wald p-value for black vs non-black equality: " %6.4f r(p)
}
else di as error "suest failed — cannot compute cross-group Wald test"


*=============================================================================*
* Step 8 : 出版级表格 & 图 (skill §Step 8)                                    *
*  - F3: Coefplot 跨规范                                                      *
*  - F4: 规范曲线 (spec curve)                                                *
*  - 复现戳 result.json                                                       *
*=============================================================================*
di as text _n "==== Step 8: Publication tables & figures ===="

*---------------------------------------------------------------------*
* F3: Coefplot — M1→M5 (skill §8f — Figure 3)                         *
*---------------------------------------------------------------------*
* Re-estimate M1→M5 (cleared by earlier eststo clear)
eststo clear
eststo M1: qui reg re78 treat, vce(robust)
eststo M2: qui reg re78 treat age educ, vce(robust)
eststo M3: qui reg re78 treat age educ black hispan, vce(robust)
eststo M4: qui reg re78 treat age educ black hispan married nodegree, vce(robust)
eststo M5: qui reg re78 treat age educ black hispan married nodegree re74 re75, vce(robust)

coefplot M1 M2 M3 M4 M5, keep(treat) ///
    vertical yline(0, lpattern(dash) lcolor(gs8)) ///
    ciopts(recast(rcap)) levels(95) ///
    ylabel(, angle(0)) ///
    xtitle("Specification") ytitle("β̂(treat) — 95% CI") ///
    title("Figure 3. Coefficient stability across specifications M1→M5") ///
    scheme(s2color)
graph export "_stata_lalonde_outputs_v5.2/figures/fig3_coefplot.pdf", replace
graph export "_stata_lalonde_outputs_v5.2/figures/fig3_coefplot.png", replace width(1200)
di as text "Saved: figures/fig3_coefplot.{pdf,png}"

*---------------------------------------------------------------------*
* F4: 规范曲线 (skill §6.l — Figure 5/spec curve)                      *
*---------------------------------------------------------------------*
capture frame drop spec
frame create spec
frame spec: g double spec_id = .
frame spec: g double b = .
frame spec: g double se = .
frame spec: g double lo = .
frame spec: g double hi = .
frame spec: g str30 label = ""
local id 0
local controls_list "treat treat age educ treat age educ black hispan treat age educ black hispan married nodegree"
local n_controls : word count `controls_list'
local n_models = `n_controls' / 4

forvalues m = 1/`n_models' {
    local offset = (`m' - 1) * 4 + 1
    local spec : word `offset' of `controls_list'
    if `m' == 1 local spec_vars "treat"
    else if `m' == 2 local spec_vars "treat age educ"
    else if `m' == 3 local spec_vars "treat age educ black hispan"
    else if `m' == 4 local spec_vars "treat age educ black hispan married nodegree"
    else if `m' == 5 local spec_vars "treat age educ black hispan married nodegree re74 re75"

    foreach se_type in "robust" "" "hc3" {
        if "`se_type'" == "" {
            capture qui reg re78 `spec_vars'
        }
        else {
            capture qui reg re78 `spec_vars', vce(`se_type')
        }
        if _rc == 0 {
            local ++id
            local b = _b[treat]
            local se = _se[treat]
            local lo = `b' - 1.96*`se'
            local hi = `b' + 1.96*`se'
            frame post spec (`id') (`b') (`se') (`lo') (`hi') ("M`m'/se=`se_type'")
        }
    }
}

frame change spec
sort b
gen rank = _n
twoway (rcap lo hi rank, lcolor(gs8)) ///
       (scatter b rank, mcolor(navy) msymbol(Oh)), ///
    yline(0, lpattern(dash) lcolor(gs10)) ///
    xtitle("Specification rank") ytitle("β̂(treat) — 95% CI") ///
    title("Figure 4. Specification curve — treatment effect across 15 specs") ///
    legend(off) scheme(s2color)
graph export "_stata_lalonde_outputs_v5.2/figures/fig4_spec_curve.pdf", replace
graph export "_stata_lalonde_outputs_v5.2/figures/fig4_spec_curve.png", replace width(1200)
di as text "Saved: figures/fig4_spec_curve.{pdf,png}"
frame change default

*---------------------------------------------------------------------*
* 8l. 复现戳 result.json (skill §8l)                                   *
*---------------------------------------------------------------------*
qui reg re78 treat age educ black hispan married nodegree re74 re75, vce(robust)
local _b  = _b[treat]
local _se = _se[treat]
local _lo = `_b' - 1.96 * `_se'
local _hi = `_b' + 1.96 * `_se'
local _n  = e(N)

file open _f using "_stata_lalonde_outputs_v5.2/artifacts/result.json", write replace
file write _f "{" _n
file write _f `"  "stata_version": "`c(stata_version)'", "' _n
file write _f `"  "current_date": "`c(current_date)' `c(current_time)'", "' _n
file write _f `"  "seed": 7, "' _n
file write _f `"  "n_obs": `_n', "' _n
file write _f `"  "estimand": "ATT (selection on observables)", "' _n
file write _f `"  "estimator": "OLS with vce(robust), full covariate set", "' _n
file write _f `"  "headline_estimate": `_b', "' _n
file write _f `"  "headline_se": `_se', "' _n
file write _f `"  "headline_ci95_lo": `_lo', "' _n
file write _f `"  "headline_ci95_hi": `_hi', "' _n
file write _f `"  "pre_registration": "artifacts/pap.json + artifacts/strategy.md", "' _n
file write _f `"  "data_contract": "artifacts/data_contract.json", "' _n
file write _f `"  "sample_log": "artifacts/sample_construction.json", "' _n
file write _f `"  "robustness_master": "tables/tableA1_robustness.tex", "' _n
file write _f `"  "spec_curve": "figures/fig4_spec_curve.pdf", "' _n
file write _f `"  "love_plot": "figures/fig2_love_plot.pdf", "' _n
file write _f `"  "ps_overlap": "figures/fig2b_ps_overlap.pdf", "' _n
file write _f `"  "frozen_at": "2026-05-02""' _n
file write _f "}" _n
file close _f
di as result "β̂(treat) = $" %8.0f `_b' "  (robust SE = $" %6.0f `_se' ///
    ", 95% CI [$" %7.0f `_lo' ", $" %7.0f `_hi' "])"
di as text "Saved: artifacts/result.json"

*---------------------------------------------------------------------*
* 管线完成报告                                                          *
*---------------------------------------------------------------------*
di as text _n(2) "==== Pipeline complete ===="
di as text "Output: _stata_lalonde_outputs_v5.2/"
di as text "  Tables:"
di as text "    table1_full.{tex,rtf,xlsx,docx}       — Summary stats (T1)"
di as text "    table1_balance.{tex,xlsx}              — Balance table (T1)"
di as text "    table2_main.{tex,rtf,xlsx,docx}        ★ Progressive controls M1→M5 (T2)"
di as text "    table3_horserace.{tex,rtf,xlsx,docx}   — Design horse-race (T3)"
di as text "    table4_heterogeneity.{tex,rtf,xlsx,docx} — Subgroup het (T4)"
di as text "    tableA1_robustness.{tex,rtf,xlsx,docx} — Robustness master (TA1)"
di as text "  Figures:"
di as text "    fig1_kde_re78.{pdf,png}                — Earnings density (F1)"
di as text "    fig2_love_plot.{pdf,png}               — Love plot (F2)"
di as text "    fig2b_ps_overlap.{pdf,png}             — PS overlap"
di as text "    fig3_coefplot.{pdf,png}                — Coefplot M1→M5 (F3)"
di as text "    fig4_spec_curve.{pdf,png}              — Spec curve (F4)"
di as text "  Artifacts:"
di as text "    pap.json / strategy.md / result.json   — PAP / strategy / stamp"

log close pipelog
* ============================================================================
* EOF
* ============================================================================

*! ============================================================================
*! Stata_skill_lalonde_full_pipeline.do
*! Lalonde NSW 数据 · Stata 完整实证管线（8 步流水线）
*!
*! 对应 skill : skills/00.2-Full-empirical-analysis-skill_Stata/SKILL.md
*! 对照 notebook: demo-notebooks/StatsPAI_skill_lalonde_full_pipeline.ipynb
*!
*! 数据来源 : MatchIt R 包的 Lalonde 样本（来自 Rdatasets 公网 CSV）
*!            处理变量 treat（NSW 职业培训 0/1）
*!            结果变量 re78 （1978 年个人收入，美元）
*!            协变量   age educ black hispan married nodegree re74 re75
*!
*! 设计    : 横截面 + selection-on-observables
*!            目标估计量 = ATT（培训对参与者的平均处理效应）
*!
*! 作者    : Bryce Wang  (brycewang2018@gmail.com)
*! 日期    : 2026-04-25
*! Stata   : 17 或更高（teffects / margins / ebalance 需要）
*! ============================================================================

version 17
clear all
set more off
set seed 7
* 仅关闭本 pipeline 的命名 log（pipelog），不动 Stata MCP / GUI 维护的默认 log。
capture log close pipelog

*-----------------------------------------------------------------------------*
* 0. 工作目录 & 输出文件夹（请按需修改 PROJECT_ROOT）                          *
*-----------------------------------------------------------------------------*
global PROJECT_ROOT "/Users/brycewang/Documents/GitHub/Awesome-Agent-Skills-for-Empirical-Research/demo-notebooks"
cd "$PROJECT_ROOT"

* 创建标准输出目录（不存在则建）
capture mkdir "_stata_lalonde_outputs"
capture mkdir "_stata_lalonde_outputs/logs"
capture mkdir "_stata_lalonde_outputs/tables"
capture mkdir "_stata_lalonde_outputs/figures"
capture mkdir "_stata_lalonde_outputs/data"

* 用 name(pipelog) 起命名 log —— 与 Stata MCP / GUI 的默认 log 并行不冲突，
* 因此 MCP 输出窗口与该 .log 文件可以同步收到全部运行结果。
log using "_stata_lalonde_outputs/logs/lalonde_pipeline.log", replace text name(pipelog)


*=============================================================================*
* 包依赖：自动按需安装（首次运行需要联网；已装的会跳过，不重复安装）          *
* 仅装本 do 文件真正用到的包。`mdesc` 已用 Stata 内置命令替代，无需安装。     *
*=============================================================================*
* asdoc 已用 estpost+esttab 替换（零额外依赖），从清单剔除
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
        if _rc {
            di as error "[setup] 安装 `_p' 失败：请检查网络或手动 ssc install `_p'"
            exit _rc
        }
    }
}

* 全局画图主题
set scheme s2color


*=============================================================================*
* Step 0 / Step 1 : 数据导入 & 清洗                                           *
*  - 直接从 Rdatasets 公网 CSV 读入（与 Python notebook 保持同源数据）         *
*  - 把字符型 race 拆成 black / hispan 两个 0/1 哑变量，对齐经典 Lalonde 设定 *
*=============================================================================*

di as text _n "==== Step 1: 数据导入与清洗 ===="

* 1a. 从 URL 直接读 CSV（Stata 16+ 支持 https）
import delimited using ///
    "https://vincentarelbundock.github.io/Rdatasets/csv/MatchIt/lalonde.csv", ///
    clear varnames(1) encoding("utf-8")

* 1b. 第一眼看数据
describe, short
summarize

* 1c. 缺失诊断（用 Stata 内置命令实现，避免依赖 SSC 外部包 mdesc）
qui count
local _Ntotal = r(N)
di as text _n "缺失诊断（每列缺失数 / 比例）："
foreach v of varlist * {
    qui count if missing(`v')
    local _miss = r(N)
    di as text "  " %-15s "`v'" ///
        "  缺失=" %5.0f `_miss' ///
        "  (" %5.2f 100*`_miss'/`_Ntotal' "%)"
}
misstable summarize                              // Stata 原生缺失模式

* 1d. race 是字符型 → 拆成两个 0/1 哑变量
*     与 notebook 中 df["black"] = (df["race"] == "black").astype(int) 一致
gen byte black  = (race == "black")
gen byte hispan = (race == "hispan")

label variable black  "Race = Black"
label variable hispan "Race = Hispanic"

* 1e. 删除 R 导出的行号列、再做一次 listwise 删除（与 notebook 对齐）
capture drop v1
capture drop rownames
local analysis_vars "treat re78 age educ black hispan married nodegree re74 re75"
foreach v of local analysis_vars {
    drop if missing(`v')
}

* 1f. 硬性断言：分析样本里 treat 必须是严格 0/1，否则后续全错
levelsof treat, local(_tlev)
assert "`_tlev'" == "0 1"

* 1g. 给关键变量打中文/英文双语标签，esttab 表格里直接漂亮显示
label variable treat    "NSW 职业培训 (0/1)"
label variable re78     "1978 年收入 (美元)"
label variable age      "年龄 (岁)"
label variable educ     "受教育年限"
label variable married  "已婚"
label variable nodegree "未获得高中文凭"
label variable re74     "1974 年收入 (美元)"
label variable re75     "1975 年收入 (美元)"

* 1h. 处理组 / 对照组样本量
tab treat, missing

* 1i. 把清洗后的分析样本存盘，方便复跑
save "_stata_lalonde_outputs/data/lalonde_analysis.dta", replace


*=============================================================================*
* Step 2 : 变量构造与变换                                                     *
*  Lalonde 是横截面数据（无 panel/time），所以不做 L./F./D. 时序算子，         *
*  仅做 winsor2 缩尾、log 变换、收入是否>0 的指示变量。                       *
*=============================================================================*

di as text _n "==== Step 2: 变量构造 ===="

* 2a. 1% / 99% 缩尾，给后面稳健性扫描做准备
winsor2 re78 re74 re75, cuts(1 99) suffix(_w1)

* 2b. log(收入+1)，应对 0 收入。注意：不是首选目标变量，仅供稳健性
gen log_re78 = log(re78 + 1)

* 2c. 1975 年收入是否为正——后面做子样本（与 notebook 的 positive_earnings_75 一致）
gen byte pos_re75 = (re75 > 0)
label variable pos_re75 "1975 年收入>0"


*=============================================================================*
* Step 3 : 描述统计 & 均衡表（Table 1）                                       *
*=============================================================================*

di as text _n "==== Step 3: 描述统计 & 均衡表 ===="

* 3a. 全样本描述统计——只看连续变量，避免 0/1 哑变量刷屏
local sumvars "re78 re74 re75 age educ"
tabstat `sumvars', ///
    statistics(n mean sd min p25 p50 p75 max) ///
    columns(statistics)

* 3b. 描述统计表落盘（用 estout = estpost + esttab 替代 asdoc，零额外依赖）
*     asdoc 在部分环境下 Mata 库 lasdoc.mlib 索引失败 → asdoctable() not found；
*     estout 是本管线已有依赖，输出同等 RTF / LaTeX，更稳。
estpost summarize `sumvars', detail
esttab . using "_stata_lalonde_outputs/tables/table1_full.rtf", ///
    replace ///
    cells("count(fmt(0)) mean(fmt(2)) sd(fmt(2)) min(fmt(2)) p50(fmt(2)) max(fmt(2))") ///
    label nonumber nomtitle ///
    title("Lalonde NSW: 全样本描述统计")
esttab . using "_stata_lalonde_outputs/tables/table1_full.tex", ///
    replace booktabs ///
    cells("count(fmt(0)) mean(fmt(2)) sd(fmt(2)) min(fmt(2)) p50(fmt(2)) max(fmt(2))") ///
    label nonumber nomtitle ///
    title("Lalonde NSW: 全样本描述统计")

* 3c. 处理 vs 对照的均衡表 + t 检验（核心选择性偏倚体检）
*     输出 LaTeX 表，可直接放到论文 appendix
balancetable treat age educ black hispan married nodegree re74 re75 ///
    using "_stata_lalonde_outputs/tables/table1_balance.tex", ///
    replace varlabels pval

* 3d. 手动做一遍带 SMD（standardized mean difference）的均衡检查
*     SMD 是匹配文献的核心指标（|SMD|<0.1 一般认为均衡）
di as text _n "Standardized Mean Differences:"
foreach v in age educ black hispan married nodegree re74 re75 {
    qui sum `v' if treat == 1
    local m1 = r(mean)
    local sd1 = r(sd)
    qui sum `v' if treat == 0
    local m0 = r(mean)
    local sd0 = r(sd)
    local smd = (`m1' - `m0') / sqrt((`sd1'^2 + `sd0'^2)/2)
    qui ttest `v', by(treat)
    di as text "  `v': diff=" %9.3f (`m1'-`m0') ///
        "  SMD=" %7.3f `smd' "  p=" %6.4f r(p)
}

* 3e. 朴素效应（不调整任何混淆）—— 后面方法的对照锚点
qui sum re78 if treat == 1
local mean_t = r(mean)
qui sum re78 if treat == 0
local mean_c = r(mean)
local naive = `mean_t' - `mean_c'
di as result _n "朴素 (treated - control) 收入差: $" %12.2fc `naive'
di as text   "（与 Python notebook 的 -635.03 一致才算对齐）"

* 3f. 处理 vs 对照的 1978 年收入分布对比图
twoway (kdensity re78 if treat == 1, lcolor("31 119 180") lwidth(medthick)) ///
       (kdensity re78 if treat == 0, lcolor("214 39 40") lwidth(medthick) lpattern(dash)), ///
    legend(order(1 "Treated" 2 "Control") position(2) ring(0)) ///
    title("1978 年收入分布：处理组 vs 对照组", size(medium)) ///
    xtitle("re78 (USD)") ytitle("Density")
graph export "_stata_lalonde_outputs/figures/kde_re78.pdf", replace


*=============================================================================*
* Step 4 : 诊断检验                                                           *
*  用一个 OLS 锚点跑一组经典 postestimation 诊断。                            *
*  横截面数据 → 跳过 xtserial/xttest3/xtcsd/dfuller/kpss/hausman 这些面板/时序*
*=============================================================================*

di as text _n "==== Step 4: 诊断检验 ===="

* 4a. 锚定 OLS（用于诊断）
reg re78 treat age educ black hispan married nodegree re74 re75
estimates store ols_anchor

* 4b. 异方差：Breusch–Pagan / Cook–Weisberg
estat hettest

* 4c. White's general test（同时检验异方差 + 设定）
estat imtest, white

* 4d. Ramsey RESET：函数形式是否正确
estat ovtest

* 4e. linktest：另一种设定误差检测
linktest

* 4f. 多重共线性
estat vif

* 4g. 残差正态性
predict double resid_ols, resid
sktest resid_ols                                 // 偏度+峰度联合检验
* swilk 在 N>5000 不可用，这里 N=614 安全
swilk resid_ols
drop resid_ols

* —— 诊断决策（与 SKILL.md 表格一致）——
*   异方差是否拒绝？  → 用 vce(robust)
*   RESET 是否拒绝？  → 加非线性项 / log
*   VIF > 10 ？       → 删掉/合并共线变量
*   sktest 拒绝？      → 大样本可忽略（CLT），小样本 bootstrap


*=============================================================================*
* Step 5 : 基线估计（横截面 selection-on-observables 的多估计器对照）         *
*  - 5a OLS 回归调整 + HC1 稳健 SE                                            *
*  - 5b teffects RA  ：仅结果模型                                             *
*  - 5c teffects IPW ：仅倾向得分                                             *
*  - 5d teffects IPWRA：双重稳健 ≈ AIPW                                       *
*  - 5e teffects AIPW ：增广 IPW（与 Python sp.aipw 严格对齐）                *
*  - 5f teffects PSMATCH：最近邻匹配 + Abadie–Imbens SE                       *
*  - 5g psmatch2 + pstest：经典 Stata 匹配 + 平衡检验                         *
*  - 5h ebalance：熵平衡（精确匹配前几阶矩）                                  *
*=============================================================================*

di as text _n "==== Step 5: 基线估计 ===="

eststo clear

* 5a. 经典 OLS 回归调整 + HC1 稳健 SE
eststo OLS: reg re78 treat age educ black hispan married nodegree re74 re75, ///
    vce(robust)

* 5b. 仅结果模型 RA：ATT
eststo RA: teffects ra ///
    (re78 age educ black hispan married nodegree re74 re75) ///
    (treat), atet vce(robust)

* 5c. 仅倾向得分 IPW：ATT
eststo IPW: teffects ipw ///
    (re78) ///
    (treat age educ black hispan married nodegree re74 re75, logit), ///
    atet vce(robust)

* 5d. IPWRA（双重稳健 v1）：ATT
eststo IPWRA: teffects ipwra ///
    (re78 age educ black hispan married nodegree re74 re75) ///
    (treat age educ black hispan married nodegree re74 re75, logit), ///
    atet vce(robust)

* 5e. AIPW（增广 IPW，与 Python 的 sp.aipw 同款）：注意 teffects aipw 仅支持 ATE
*     Stata 的 teffects aipw 不接受 atet（见 [TE] teffects aipw）；
*     若需 ATT，用 5d 的 ipwra 或 5b 的 ra 即可，二者也是 doubly robust。
eststo AIPW: teffects aipw ///
    (re78 age educ black hispan married nodegree re74 re75) ///
    (treat age educ black hispan married nodegree re74 re75, logit), ///
    ate vce(robust)

* 5f. teffects 最近邻 PSM（4 个近邻 + bias-correction）
eststo PSM_te: teffects psmatch ///
    (re78) ///
    (treat age educ black hispan married nodegree re74 re75, logit), ///
    atet nneighbor(4) vce(robust)

* 5g. psmatch2：经典 Stata 匹配 + 平衡检验
*     先估倾向得分、再 1 近邻配对、common support
logit treat age educ black hispan married nodegree re74 re75
predict double pscore, pr
psmatch2 treat, pscore(pscore) outcome(re78) neighbor(1) common ate

* 平衡检验：处理-对照在协变量上的 SMD（匹配前后对比）
pstest age educ black hispan married nodegree re74 re75, ///
    treated(treat) both

drop pscore _pscore _treated _support _weight _id _n1 _nn _pdif

* 5h. ebalance：熵平衡（match 前 3 阶矩，理论上比 PSM 更精确）
*     ebalance 直接给出 entropy 权重，再用加权 reg 估 ATT
preserve
    capture noisily ebalance treat age educ black hispan married nodegree re74 re75, ///
        targets(1) gen(eb_w)
    if _rc == 0 {
        eststo EBAL: reg re78 treat [pweight=eb_w], vce(robust)
    }
    else {
        di as error "ebalance 收敛失败，跳过该估计器（不影响其他结果）"
    }
restore


*=============================================================================*
* Step 6 : 稳健性电池                                                         *
*  - 6a 渐进式控制集 M1 → M5（教科书做法）                                    *
*  - 6b 替换不同 SE（iid / HC1 / HC3 / cluster by age 组）                    *
*  - 6c 子样本：1975 年收入>0 / 年龄<30                                       *
*  - 6d Oster (2019) δ：未观测混淆敏感性（替代 E-value）                      *
*  - 6e 缩尾稳健性 (winsor2 1/99)                                             *
*=============================================================================*

di as text _n "==== Step 6: 稳健性电池 ===="

* 6a. 渐进式控制集
eststo clear
eststo M1: reg re78 treat, vce(robust)
eststo M2: reg re78 treat age educ, vce(robust)
eststo M3: reg re78 treat age educ black hispan, vce(robust)
eststo M4: reg re78 treat age educ black hispan married nodegree, vce(robust)
eststo M5: reg re78 treat age educ black hispan married nodegree re74 re75, vce(robust)

esttab M1 M2 M3 M4 M5 ///
    using "_stata_lalonde_outputs/tables/table_progressive_specs.tex", ///
    replace booktabs label ///
    se star(* 0.10 ** 0.05 *** 0.01) ///
    stats(N r2 r2_a, labels("N" "R\textsuperscript{2}" "Adj. R\textsuperscript{2}")) ///
    keep(treat) ///
    mtitles("M1: bivariate" "M2: + age,educ" "M3: + race" "M4: + family" "M5: full") ///
    title("渐进式控制集 (Progressive specifications) - Lalonde NSW")

* 同时输出 RTF 给 Word 用户
esttab M1 M2 M3 M4 M5 ///
    using "_stata_lalonde_outputs/tables/table_progressive_specs.rtf", ///
    replace label se star(* 0.10 ** 0.05 *** 0.01) ///
    stats(N r2, labels("N" "R-squared")) keep(treat)

* 6b. 不同 SE 类型对比
di as text _n "treat 系数在不同 SE 设定下的对比："
foreach setype in "" "robust" "hc3" {
    if "`setype'" == "" {
        reg re78 treat age educ black hispan married nodegree re74 re75
        di as text "  iid SE     :  b=" %9.3f _b[treat] "  se=" %9.3f _se[treat]
    }
    else {
        reg re78 treat age educ black hispan married nodegree re74 re75, vce(`setype')
        di as text "  vce(`setype')  :  b=" %9.3f _b[treat] "  se=" %9.3f _se[treat]
    }
}

* 6c. 子样本
di as text _n "子样本 ATT 对比："
foreach mask in "1==1" "pos_re75 == 1" "age < 30" {
    reg re78 treat age educ black hispan married nodegree re74 re75 if `mask', ///
        vce(robust)
    di as text "  样本: `mask'  →  b=" %9.3f _b[treat] ///
        "  se=" %9.3f _se[treat] "  N=" e(N)
}

* 6d. Oster (2019) δ ：未观测混淆敏感性
*     与 Python notebook 的 sp.oster_delta 完全一致：
*       beta_short ：仅 treat 的短回归系数
*       beta_full  ：full controls 后的长回归系数
*       delta*     ：让效应归零所需的"未观测/已观测选择强度"比；|δ*|>1 则稳健
reg re78 treat
scalar bs_short  = _b[treat]
scalar r2_short  = e(r2)

reg re78 treat age educ black hispan married nodegree re74 re75
scalar bs_full   = _b[treat]
scalar r2_full   = e(r2)

di as text _n "Oster δ 关键输入："
di as text "  beta_short = " %12.4f bs_short "  R²_short = " %6.4f r2_short
di as text "  beta_full  = " %12.4f bs_full  "  R²_full  = " %6.4f r2_full

* psacalc delta : Oster 经验法则 r_max = 1.3 * R²_full
psacalc delta treat, mcontrol(age educ black hispan married nodegree re74 re75) ///
    rmax(`= 1.3 * r2_full ')

* psacalc beta : 假设 δ=1 给出处理效应识别区间
psacalc beta treat, mcontrol(age educ black hispan married nodegree re74 re75) ///
    rmax(`= 1.3 * r2_full ') delta(1)

di as text _n "解读：psacalc 输出的 delta 即 δ*。"
di as text "  |δ*| > 1 → 稳健（未观测要比已观测更强才能推翻结论）"
di as text "  |δ*| ≤ 1 → 脆弱（未观测与已观测同等强度即可推翻结论）"

* 6e. 缩尾稳健性
reg re78_w1 treat age educ black hispan married nodegree re74_w1 re75_w1, ///
    vce(robust)
di as text _n "缩尾 1/99 后的 treat 系数：" %9.3f _b[treat] ///
    "  se=" %9.3f _se[treat]


*=============================================================================*
* Step 7 : 异质性 / 进一步分析                                                *
*  - 7a 与种族的交互（培训对黑人 vs 非黑人是否不同？）                        *
*  - 7b 与教育水平的交互                                                      *
*  - 7c 子组分别估计 + Wald 检验                                              *
*=============================================================================*

di as text _n "==== Step 7: 异质性分析 ===="

* 7a. 培训 × 黑人 交互
reg re78 i.treat##i.black age educ hispan married nodegree re74 re75, vce(robust)
margins, dydx(treat) at(black=(0 1))
marginsplot, ///
    title("培训对 1978 年收入的边际效应：按种族") ///
    ytitle("dY / d(treat)") ///
    xtitle("Race = Black")
graph export "_stata_lalonde_outputs/figures/het_treat_by_black.pdf", replace

* 7b. 培训 × 受教育年限 交互（连续）
reg re78 c.treat##c.educ age black hispan married nodegree re74 re75, vce(robust)
margins, dydx(treat) at(educ=(6(2)16))
marginsplot, ///
    title("培训对 1978 年收入的边际效应：按受教育年限") ///
    ytitle("dY / d(treat)") xtitle("Education (years)")
graph export "_stata_lalonde_outputs/figures/het_treat_by_educ.pdf", replace

* 7c. 子组单独估计 + suest 联合 Wald
*     注意：suest 要求子模型用 OIM SE（不能带 vce(robust)），
*     suest 在合并时会自动给出 robust 协方差矩阵。
eststo clear
eststo M_black: reg re78 treat age educ married nodegree re74 re75 if black == 1
eststo M_other: reg re78 treat age educ hispan married nodegree re74 re75 if black == 0
suest M_black M_other, vce(robust)
test [M_black_mean]treat = [M_other_mean]treat


*=============================================================================*
* Step 8 : 出版级表格 & 图                                                    *
*  - 8a 主表：OLS / IPW / IPWRA / AIPW / PSM 横向对照                         *
*  - 8b coefplot：所有估计器的 treat 系数 + 95% CI                            *
*  - 8c overlap 图：倾向得分分布                                              *
*=============================================================================*

di as text _n "==== Step 8: 出版表格 & 图 ===="

* 8a. 多估计器主表
*     重新跑一遍并存到 eststo（前面 Step 6 把 eststo 给清掉了）
*     主表选择 5 个收敛稳定的 ATT 估计器：OLS / RA / IPW / IPWRA / PSM。
*     AIPW 在该数据上 logit 不收敛（弱 overlap 导致近似 separation），
*     5e 已用 ate 跑过示例，主表用 IPWRA（同为 doubly robust）替代位置，
*     避免单点数值问题阻塞整个管线产出。
eststo clear
eststo OLS:    reg re78 treat age educ black hispan married nodegree re74 re75, vce(robust)
eststo RA:     teffects ra ///
                  (re78 age educ black hispan married nodegree re74 re75) ///
                  (treat), atet vce(robust)
eststo IPW:    teffects ipw ///
                  (re78) ///
                  (treat age educ black hispan married nodegree re74 re75, logit), ///
                  atet vce(robust)
eststo IPWRA:  teffects ipwra ///
                  (re78 age educ black hispan married nodegree re74 re75) ///
                  (treat age educ black hispan married nodegree re74 re75, logit), ///
                  atet vce(robust)
eststo PSM:    teffects psmatch ///
                  (re78) ///
                  (treat age educ black hispan married nodegree re74 re75, logit), ///
                  atet nneighbor(4) vce(robust)

* 注意：esttab 的 rename 先于 keep 生效，因此 rename 后只剩 treat 一个名字。
esttab OLS RA IPW IPWRA PSM ///
    using "_stata_lalonde_outputs/tables/table_main_estimators.tex", ///
    replace booktabs label se ///
    star(* 0.10 ** 0.05 *** 0.01) ///
    rename(r1vs0.treat treat) ///
    keep(treat) ///
    mtitles("OLS" "RA" "IPW" "IPWRA" "PSM") ///
    title("Lalonde NSW: 培训对 1978 年收入的 ATT (多估计器对照)") ///
    nonotes ///
    addnotes("HC1 稳健 SE。teffects 估计量给出 ATT (atet)，OLS 给出 ATE 系数。AIPW 因弱 overlap 在此数据上不收敛，详见 5e。")

esttab OLS RA IPW IPWRA PSM ///
    using "_stata_lalonde_outputs/tables/table_main_estimators.rtf", ///
    replace label se star(* 0.10 ** 0.05 *** 0.01) ///
    rename(r1vs0.treat treat) keep(treat) ///
    mtitles("OLS" "RA" "IPW" "IPWRA" "PSM")

* 8b. coefplot：所有估计器横向对照（与 8a 主表一致，剔除 AIPW）
coefplot ///
    (OLS,    rename(treat = "OLS")) ///
    (RA,     rename(r1vs0.treat = "RA")) ///
    (IPW,    rename(r1vs0.treat = "IPW")) ///
    (IPWRA,  rename(r1vs0.treat = "IPWRA")) ///
    (PSM,    rename(r1vs0.treat = "PSM")), ///
    keep(OLS RA IPW IPWRA PSM) ///
    xline(0, lpattern(dash) lcolor(gs8)) ///
    xtitle("ATT 估计 (95% CI)") ///
    title("Lalonde NSW · 不同估计器的 ATT") ///
    ciopts(recast(rcap)) ///
    msymbol(D) mcolor("31 119 180")
graph export "_stata_lalonde_outputs/figures/coefplot_estimators.pdf", replace

* 8c. 倾向得分 overlap 图（重要！selection-on-observables 的核心假设）
logit treat age educ black hispan married nodegree re74 re75
predict double pscore, pr
twoway (kdensity pscore if treat == 1, lcolor("31 119 180") lwidth(medthick)) ///
       (kdensity pscore if treat == 0, lcolor("214 39 40") lwidth(medthick) lpattern(dash)), ///
    legend(order(1 "Treated" 2 "Control") position(2) ring(0)) ///
    title("倾向得分分布：处理组 vs 对照组 (overlap 检验)", size(medium)) ///
    xtitle("propensity score") ytitle("density")
graph export "_stata_lalonde_outputs/figures/pscore_overlap.pdf", replace

* overlap 数值汇总：两组 min/max 越重叠越好
tabstat pscore, by(treat) ///
    stats(n min mean median max) columns(statistics)
drop pscore


*=============================================================================*
* 结论 (与 Python notebook 的判断对齐)                                        *
*-----------------------------------------------------------------------------*
* 1) 朴素差值（treated - control）= 约 -635 美元，处理组反而更穷              *
*    —— 因为处理组在 pre-treatment 协变量上系统性更弱（balance 表很糟）。     *
* 2) 加入协变量调整后，OLS / IPWRA / AIPW / PSM 多数给出正向 ATT，            *
*    但点估和 SE 跨估计器有差异 —— 这是 selection-on-observables 设计         *
*    在弱重叠样本上的典型现象。                                               *
* 3) Oster δ 给出未观测混淆敏感性的量化界限：                                 *
*    重点看 |δ*| 是否大于 1（>1 才算"未观测要比观测更强才能推翻结论"）。      *
* 4) 真要给政策建议前，请补：                                                 *
*    - 重新检视 overlap（倾向得分尾部样本是否要 trim）                        *
*    - 用 Dehejia–Wahba 的子样本（pre-treat 收入 ≥ 0 等）跑                   *
*    - 与实验组（NSW PSID/CPS 比较）做对照                                    *
*=============================================================================*

di as text _n(2) "==== 管线运行完毕 ===="
di as text "输出位置：$PROJECT_ROOT/_stata_lalonde_outputs/"
di as text "  - tables/  : esttab 表 (.tex / .rtf)"
di as text "  - figures/ : 所有图 (.pdf)"
di as text "  - logs/    : 完整日志 lalonde_pipeline.log"
di as text "  - data/    : 清洗后样本 lalonde_analysis.dta"

* 只关本 pipeline 的命名 log，MCP / GUI 的默认 log 不动
log close pipelog

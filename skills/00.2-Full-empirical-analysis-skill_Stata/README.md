# Full Empirical Analysis Skill for Claude Code — Stata edition

This folder is a **Claude Code Skill** that teaches Claude (or any compatible
agent harness) how to drive a complete empirical analysis end-to-end in
**Stata** — the canonical applied-economics workflow on `.do` files, using
the de-facto-standard community ecosystem (`reghdfe`, `ivreg2`, `csdid`,
`did_imputation`, `eventstudyinteract`, `sdid`, `rdrobust`, `synth`,
`psmatch2`, `teffects`, `ebalance`, `coefplot`, `esttab`, `outreg2`,
`boottest`, `ritest`, `rwolf`, `bacondecomp`, `honestdid`, `binscatter`).

The skill covers **three domain modes** that share the same 8-step
scaffolding:

- **Default — Applied Econ (AER / QJE / AEJ).** The canonical 8-step
  pipeline: import / cleaning → variable construction → Table 1 →
  diagnostic tests → baseline modeling (`reghdfe` HDFE / `ivreg2` IV /
  `csdid` DID / `rdrobust` RD / `synth` SCM / `teffects` matching) →
  robustness gauntlet (`bacondecomp` / `honestdid` / `boottest` /
  `ritest` / `rwolf` / `oster`) → mechanism + heterogeneity →
  publication-ready `esttab` / `outreg2` / `coefplot` bundle.
- **Mode A — Epidemiology / public health (§A).** Target-trial
  emulation in `.do`, IPTW + IPWRA + AIPW + TMLE doubly-robust
  triplet via `teffects ipw` / `teffects aipw` / `teffects ipwra` /
  `eltmle`, Mendelian randomization (IVW / Egger / weighted median /
  outlier-robust) via `mrrobust` / `mregger` / `mrpresso`, KM / Cox /
  AFT / RMST survival via `sts` / `stcox` / `streg` / `strmst2`,
  E-value sensitivity via `evalue`, `gformula` for time-varying
  confounding — under STROBE / TRIPOD-AI reporting conventions.
- **Mode B — ML causal inference (§B).** DML via `ddml` (with
  `pystacked` learners) and `pdslasso` for high-dim controls, causal
  forest via `crforest` / `cforest`, BART / BCF / Dragonnet / TARNet /
  CEVAE / conformal causal / fairness audit via Stata 18's `python:`
  callout to Python (`econml` / `causalml` / `mapie` / `fairlearn`),
  CATE distribution + policy tree (R callout to `policytree` or
  Python `econml.policy`), DAG learning via `pcalg` / Python
  `causal-learn`.

All three modes reuse the same Step 1–4 (cleaning → Table 1 → diagnostics)
and Step 8 (publication tables / figures via `esttab` + `coefplot`)
scaffolding — switching modes only changes which Step-5 estimator command
family you reach for.

## Philosophy

This is the **Stata counterpart** to the Python-side siblings in this repo:

| Skill | Language / Stack |
|-------|-------------------|
| [`00-StatsPAI_skill`](../00-StatsPAI_skill/) | Python — agent-native one-import DSL (`import statspai as sp`) |
| [`00.1-Full-empirical-analysis-skill`](../00.1-Full-empirical-analysis-skill/) | Python — explicit traditional stack (pandas + statsmodels + linearmodels + pyfixest + …) |
| **`00.2-Full-empirical-analysis-skill_Stata`** *(this skill)* | **Stata — explicit do-file pipeline (reghdfe + ivreg2 + csdid + …)** |

Same 8-step pipeline, different ecosystem. All three coexist. Pick by your
audience:

- Reviewer / co-author insists on Stata for replication ⇒ **this skill**
- Need the same analysis in Python with explicit control ⇒ `00.1`
- Want a one-import DSL with self-describing API ⇒ `00`

## Install

```bash
# Option 1: copy
cp -r 00.2-Full-empirical-analysis-skill_Stata \
      ~/.claude/skills/Full-empirical-analysis-skill_Stata

# Option 2: symlink (auto-follow upstream updates)
ln -s "$(pwd)/00.2-Full-empirical-analysis-skill_Stata" \
      ~/.claude/skills/Full-empirical-analysis-skill_Stata
```

Install the Stata community packages (run once on a fresh Stata install):

```stata
* Core
ssc install reghdfe,            replace
ssc install ftools,             replace
ssc install ivreg2,             replace
ssc install ranktest,           replace
ssc install ivreghdfe,          replace
ssc install ppmlhdfe,           replace

* DID / event-study family
ssc install csdid,              replace
ssc install drdid,              replace
ssc install did_imputation,     replace
ssc install eventstudyinteract, replace
ssc install sdid,               replace
ssc install did_multiplegt_dyn, replace
ssc install bacondecomp,        replace
ssc install honestdid,          replace

* RD / SCM / matching
ssc install rdrobust,           replace
ssc install rddensity,          replace
ssc install synth,              replace
ssc install synth_runner,       replace
ssc install psmatch2,           replace
ssc install ebalance,           replace

* Robustness / inference
ssc install boottest,           replace
ssc install ritest,             replace
ssc install rwolf,              replace
ssc install psacalc,            replace

* Tables / figures
ssc install coefplot,           replace
ssc install estout,             replace
ssc install outreg2,            replace
ssc install asdoc,              replace
ssc install binscatter,         replace
ssc install balancetable,       replace
ssc install winsor2,            replace
ssc install schemepack,         replace
ssc install heatplot,           replace
ssc install palettes,           replace
ssc install colrspace,          replace

* Misc utilities
ssc install mdesc,              replace
ssc install missings,           replace
ssc install unique,             replace
ssc install moremata,           replace
```

## Activate

Triggers: *"run a full empirical analysis in Stata"*, *"reghdfe two-way FE"*,
*"csdid event study"*, *"ivreg2 weak instruments"*, *"esttab to LaTeX"*,
*"coefplot with CI"*, *"winsor2 at 1%"*, *"boottest wild bootstrap"*,
*"bacondecomp"*, *"honestdid"*, etc. Full list in the `triggers:` block of
[`SKILL.md`](SKILL.md).

## Scope

**In scope** — the canonical 8-step Stata pipeline (mapped to AER paper sections, with Step −1 / Step 0 / Step 2.5 / Step 3.5 sub-stages added in v2 to mirror the StatsPAI reference skill):

```
Step −1 Pre-Analysis Plan          power/sampsi/clustersampsi → protocol.do
Step 0  Sample log + data contract sample_log/assert/xtdescribe → JSON
Step 1  Data import & cleaning     use/import/destring/misstable/merge assert/xtset
Step 2  Variable construction      gen/egen/winsor2/xtile/L./F./D./CPI deflation
Step 2.5 Empirical strategy        equation × ID assumption × estimator → strategy.do
Step 3  Descriptive statistics     tabstat/balancetable/asdoc/pwcorr/twoway
Step 3.5 Identification graphics   event-study/1st-stage F/McCrary/love/SCM trajectory
Step 4  Diagnostic tests           sktest/hettest/xtserial/xttest3/vif/dfuller/kpss/hausman
Step 5  Baseline modeling          reghdfe/ivreg2/csdid/rdrobust/synth/psmatch2/teffects
        Patterns A–H               progressive ctrls / horse race / multi-Y / IV triplet / ...
Step 6  Robustness battery         bacondecomp/honestdid/boottest/ritest/rwolf/psacalc
        + Pattern H Master Table A1 + spec curve + sensitivity dashboard
Step 7  Further analysis           margins/marginsplot/medsem/SEM/Stata-Python bridge
Step 8  Tables & figures           esttab/outreg2/coefplot/marginsplot/rdplot
        + reproducibility stamp (artifacts/result.json)
```

**Out of scope** — Stata syntax tutorials (use the
[`32-dylantmoore-stata-skill`](../32-dylantmoore-stata-skill/) instead),
DSGE / numerical macro (Python-only here), and paper drafting (LaTeX
prose). This skill ends at Step 8 with `.tex` tables and `.pdf` figures
ready to drop into a manuscript.

## Files

- [`SKILL.md`](SKILL.md) — frontmatter + full agent playbook (8-step workflow + library cheat-sheet + common mistakes + .do-file skeleton)
- `README.md` — this file
- `references/` — deep per-step references, loaded on demand
  - [`01-data-cleaning.md`](references/01-data-cleaning.md)
  - [`02-data-transformation.md`](references/02-data-transformation.md)
  - [`03-descriptive-stats.md`](references/03-descriptive-stats.md)
  - [`04-statistical-tests.md`](references/04-statistical-tests.md)
  - [`05-modeling.md`](references/05-modeling.md)
  - [`06-robustness.md`](references/06-robustness.md)
  - [`07-further-analysis.md`](references/07-further-analysis.md)
  - [`08-tables-plots.md`](references/08-tables-plots.md)

---

# Stata 完整实证分析技能（中文）

本文件夹是一份 **Claude Code Skill**，教 Claude（或任何兼容的 agent
运行时）端到端地用 **Stata** 完成一次实证分析 —— 即应用经济学里最经典
的 `.do` 文件工作流，使用社区事实标准生态：`reghdfe`、`ivreg2`、`csdid`、
`did_imputation`、`eventstudyinteract`、`sdid`、`rdrobust`、`synth`、
`psmatch2`、`teffects`、`ebalance`、`coefplot`、`esttab`、`outreg2`、
`boottest`、`ritest`、`rwolf`、`bacondecomp`、`honestdid`、`binscatter`。

本 skill 覆盖**三种领域模式**，共用同一套 8 步骨架（清洗 / Table 1
/ 诊断 / 出表）：

- **默认 — 应用经济学（AER / QJE / AEJ）**。8 步流程：导入清洗 →
  变量构造 → Table 1 → 诊断检验 → 基准建模（`reghdfe` HDFE /
  `ivreg2` IV / `csdid` DID / `rdrobust` RD / `synth` SCM /
  `teffects` 匹配）→ 稳健 gauntlet（`bacondecomp` / `honestdid` /
  `boottest` / `ritest` / `rwolf` / `oster`）→ 机制 + 异质性 →
  论文级 `esttab` / `outreg2` / `coefplot` 三件套。
- **模式 A — 流行病学 / 公共健康（§A）**。`.do` 写 target-trial
  协议，`teffects ipw` / `teffects aipw` / `teffects ipwra` /
  `eltmle` 跑 IPTW + IPWRA + AIPW + TMLE 双稳健三件套，`mrrobust`
  / `mregger` / `mrpresso` 做孟德尔随机化（IVW / Egger / 加权中位数
  / 离群鲁棒），`sts` / `stcox` / `streg` / `strmst2` 做 KM /
  Cox / AFT / RMST 生存分析，`evalue` 做 E-value 敏感性，
  `gformula` 处理时变混杂——按 STROBE / TRIPOD-AI 报告规范输出。
- **模式 B — 因果机器学习（§B）**。`ddml`（搭配 `pystacked` 学习器）
  + `pdslasso` 处理 DML 与高维控制，`crforest` / `cforest` 跑因果森林；
  BART / BCF / Dragonnet / TARNet / CEVAE / conformal causal /
  fairness audit 通过 Stata 18 的 `python:` 块外挂 Python 生态
  （`econml` / `causalml` / `mapie` / `fairlearn`）；CATE 分布
  + policy tree 通过 R/Python 外挂（`policytree` 或 `econml.policy`）；
  DAG 学习走 `pcalg` 或 Python `causal-learn`。

三种模式共用同一套 Step 1–4（清洗 / Table 1 / 诊断）和 Step 8
（出表 / 出图）骨架——切换模式只换 Step-5 估计器命令族。

## 哲学

本 skill 是仓库中三联 skill 的 **Stata 版本**：

| Skill | 语言 / 生态 |
|-------|-------------|
| [`00-StatsPAI_skill`](../00-StatsPAI_skill/) | Python — agent-native 一键 DSL（`import statspai as sp`） |
| [`00.1-Full-empirical-analysis-skill`](../00.1-Full-empirical-analysis-skill/) | Python — 显式传统生态（pandas + statsmodels + linearmodels + pyfixest + …） |
| **`00.2-Full-empirical-analysis-skill_Stata`**（本 skill） | **Stata — 显式 do-file pipeline（reghdfe + ivreg2 + csdid + …）** |

同一套 8 步流程，三种生态实现，并行收录，互不替代。按受众选：

- 审稿人 / 合作者只接受 Stata 复现 ⇒ **本 skill**
- 同样的分析在 Python 里要逐行控制 ⇒ `00.1`
- 想要一键 DSL + 自描述 API ⇒ `00`

## 安装

```bash
# 方式 1：复制
cp -r 00.2-Full-empirical-analysis-skill_Stata \
      ~/.claude/skills/Full-empirical-analysis-skill_Stata

# 方式 2：软链
ln -s "$(pwd)/00.2-Full-empirical-analysis-skill_Stata" \
      ~/.claude/skills/Full-empirical-analysis-skill_Stata
```

Stata 包的安装命令见上文英文区，一次跑完即可。

## 激活

触发词包括：*"用 Stata 跑一次完整实证分析"*、*"reghdfe 双向固定效应"*、
*"csdid 事件研究"*、*"ivreg2 弱工具变量"*、*"esttab 输出 LaTeX"*、
*"coefplot 系数图"*、*"winsor2 1% 缩尾"*、*"boottest wild bootstrap"*、
*"bacondecomp"*、*"honestdid"* 等。完整列表见 `SKILL.md` 中的
`triggers:` 字段。

## 覆盖范围

**覆盖** —— Stata 经典 8 步 pipeline（v2 对齐 StatsPAI 参考 skill，新增 Step −1 / Step 0 / Step 2.5 / Step 3.5 子阶段）：

```
Step −1 预分析计划（PAP）     power/sampsi/clustersampsi → protocol.do
Step 0  样本日志 + 数据契约  sample_log/assert/xtdescribe → JSON
Step 1  数据导入 / 清洗       use/import/destring/misstable/merge assert/xtset
Step 2  变量构造              gen/egen/winsor2/xtile/L./F./D./CPI 平减
Step 2.5 实证策略            方程式 × 识别假设 × 估计器 → strategy.do
Step 3  描述统计              tabstat/balancetable/asdoc/pwcorr/twoway
Step 3.5 识别图              event-study / 1st-stage F / McCrary / love / SCM 轨迹
Step 4  诊断检验              sktest/hettest/xtserial/xttest3/vif/dfuller/kpss/hausman
Step 5  基准建模              reghdfe/ivreg2/csdid/rdrobust/synth/psmatch2/teffects
        八种 regtable 模式 A–H  渐进控制 / 设计赛马 / 多 Y / IV 三联 / ...
Step 6  稳健性电池            bacondecomp/honestdid/boottest/ritest/rwolf/psacalc
        + Pattern H 稳健性主表 A1 + 规范曲线 + 敏感性面板
Step 7  进一步分析            margins/marginsplot/medsem/SEM/Stata-Python 桥
Step 8  表与图                esttab/outreg2/coefplot/marginsplot/rdplot
        + 复现戳（artifacts/result.json）
```

**不覆盖** —— Stata 语法入门（请用
[`32-dylantmoore-stata-skill`](../32-dylantmoore-stata-skill/)）、DSGE /
数值宏观（仅 Python 覆盖）、以及正文撰写（LaTeX 文字）。本 skill 在
Step 8 结束，交付的是 `.tex` 表和 `.pdf` 图，可直接嵌入正文。

## 文件

- `SKILL.md` — frontmatter + 完整 agent 操作手册（8 步流程 + 选包表 + 常见坑 + .do 骨架）
- `README.md` — 本文件
- `references/` — 每步的深层参考，按需加载
  - `01-data-cleaning.md`
  - `02-data-transformation.md`
  - `03-descriptive-stats.md`
  - `04-statistical-tests.md`
  - `05-modeling.md`
  - `06-robustness.md`
  - `07-further-analysis.md`
  - `08-tables-plots.md`

# Full Empirical Analysis Skill for Claude Code — R edition

This folder is a **Claude Code Skill** that teaches Claude (or any compatible
agent harness) how to drive a complete empirical analysis end-to-end in
**R**, using the modern tidyverse + econometrics ecosystem: `dplyr` /
`tidyr` / `haven` for data, `fixest` as the panel/IV/DID workhorse,
`did` / `bacondecomp` / `HonestDiD` for modern DID, `rdrobust` /
`rddensity` for RD, `Synth` / `gsynth` / `synthdid` for synthetic
control, `MatchIt` / `WeightIt` / `cobalt` / `ebal` for matching,
`grf` / `DoubleML` for ML causal, `mediation` / `lavaan` for mediation,
`marginaleffects` for post-estimation, `modelsummary` /
`kableExtra` / `gt` for publication tables, `ggplot2` / `iplot` /
`binsreg` for figures.

## Philosophy

This is the **R counterpart** to the four-skill family in this repo:

| Skill | Language / Stack |
|-------|-------------------|
| [`00-StatsPAI_skill`](../00-StatsPAI_skill/) | Python — agent-native one-import DSL (`import statspai as sp`) |
| [`00.1-Full-empirical-analysis-skill`](../00.1-Full-empirical-analysis-skill/) | Python — explicit traditional stack (pandas + statsmodels + linearmodels + pyfixest + …) |
| [`00.2-Full-empirical-analysis-skill_Stata`](../00.2-Full-empirical-analysis-skill_Stata/) | Stata — explicit `.do` pipeline (reghdfe + ivreg2 + csdid + …) |
| **`00.3-Full-empirical-analysis-skill_R`** *(this skill)* | **R — tidyverse + fixest pipeline (feols + did + grf + modelsummary + …)** |

Same 8-step pipeline, four ecosystems. All four coexist; pick by your
audience or workflow:

- Need a Quarto / R Markdown reproducible report ⇒ **this skill**
- Reviewer expects Stata `.do` files ⇒ `00.2`
- Want explicit Python control ⇒ `00.1`
- Want a one-import DSL with self-describing API ⇒ `00`

## Install

```bash
# Option 1: copy
cp -r 00.3-Full-empirical-analysis-skill_R \
      ~/.claude/skills/Full-empirical-analysis-skill_R

# Option 2: symlink
ln -s "$(pwd)/00.3-Full-empirical-analysis-skill_R" \
      ~/.claude/skills/Full-empirical-analysis-skill_R
```

Install the R packages (run once on a fresh R; consider `renv::init()` for
project-level locking):

```r
install.packages(c(
  # Data
  "tidyverse", "haven", "readxl", "data.table", "janitor",
  "naniar", "VIM", "mice", "validate", "assertr", "DescTools",
  # Description / tables
  "gtsummary", "tableone", "modelsummary", "kableExtra", "gt",
  "stargazer", "texreg", "flextable", "psych", "summarytools",
  "ggcorrplot", "corrplot",
  # Tests
  "lmtest", "sandwich", "car", "tseries", "urca", "plm",
  "clubSandwich", "fwildclusterboot", "skedastic",
  # Modeling — workhorses
  "fixest",                                       # primary
  "AER", "ivreg", "ivmodel",                      # IV
  # Modern DID
  "did", "didimputation", "synthdid",
  "bacondecomp", "HonestDiD", "DIDmultiplegtDYN",
  # RD
  "rdrobust", "rddensity", "rdmulti", "rdlocrand",
  # Synthetic control
  "Synth", "gsynth", "tidysynth",
  # Matching / weighting
  "MatchIt", "WeightIt", "cobalt", "ebal",
  # ML causal
  "grf", "DoubleML", "mlr3", "mlr3learners", "ranger",
  # Mediation / SEM
  "mediation", "lavaan", "semTools",
  # Robustness / inference
  "robomit", "ri2", "randomizr", "boot", "multcomp",
  # Margins / post-estimation
  "marginaleffects",
  # Plotting
  "ggplot2", "ggpubr", "cowplot", "patchwork", "ggdist",
  "binsreg", "ggrepel", "showtext",
  # Survival / quantile
  "quantreg", "survival",
  # Quarto rendering
  "quarto", "knitr", "rmarkdown", "broom"
))
```

## Activate

Triggers: *"run a full empirical analysis in R"*, *"feols with two-way FE"*,
*"Callaway-Sant'Anna in R"*, *"MatchIt nearest neighbor"*, *"modelsummary
to LaTeX"*, *"plot_slopes for marginal effects"*, *"gtsummary Table 1"*,
*"binsreg in R"*, *"bacondecomp R"*, *"HonestDiD R"*, *"causal forest grf"*,
*"mediation Imai"*, etc. Full list in the `triggers:` field of `SKILL.md`.

## Scope

**In scope** — the canonical 8-step R pipeline:

```
Step 1  Data import & cleaning   read_dta/read_csv/janitor/naniar/validate/assertr
Step 2  Variable construction    dplyr mutate/across/Winsorize/scale/lag/lead
Step 3  Descriptive statistics   gtsummary/datasummary_balance/cor_pmat/ggdist
Step 4  Diagnostic tests         shapiro/bptest/dwtest/vif/adf/kpss/Hausman
Step 5  Baseline modeling        feols/ivreg/att_gt/sunab/synthdid/MatchIt/grf
Step 6  Robustness battery       fwildclusterboot/ri2/bacondecomp/HonestDiD/robomit
Step 7  Further analysis         marginaleffects/mediation/lavaan/grf
Step 8  Tables & figures         modelsummary/iplot/ggplot2/cowplot/Quarto
```

**Out of scope** — Bayesian R workflows (`brms`/`rstan` — see
[`23-Learning-Bayesian-Statistics-baygent-skills`](../23-Learning-Bayesian-Statistics-baygent-skills/)),
agent-native one-import DSLs (`00`), and paper drafting (LaTeX prose).
This skill ends at Step 8 with `.tex` / `.docx` tables and `.pdf` figures
ready for the manuscript.

## Files

- [`SKILL.md`](SKILL.md) — frontmatter + agent playbook (8-step workflow + library cheat-sheet + common mistakes + project skeleton + Quarto pointer)
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

# R 完整实证分析技能（中文）

本文件夹是一份 **Claude Code Skill**，教 Claude（或任何兼容的 agent
运行时）端到端地用 **R** 完成一次实证分析，使用现代 tidyverse +
计量经济学 R 生态：`dplyr`/`tidyr`/`haven` 处理数据，`fixest` 作为面板
/IV/DID 主力，`did`/`bacondecomp`/`HonestDiD` 处理现代 DID，`rdrobust`
/`rddensity` 处理 RD，`Synth`/`gsynth`/`synthdid` 处理合成控制，
`MatchIt`/`WeightIt`/`cobalt`/`ebal` 处理匹配，`grf`/`DoubleML`
处理 ML 因果，`mediation`/`lavaan` 处理中介，`marginaleffects` 处理
后估计，`modelsummary`/`kableExtra`/`gt` 出版级表格，`ggplot2`/
`iplot`/`binsreg` 出图。

## 哲学

本 skill 是仓库中四联 skill 的 **R 版本**：

| Skill | 语言 / 生态 |
|-------|-------------|
| [`00-StatsPAI_skill`](../00-StatsPAI_skill/) | Python — agent-native 一键 DSL（`import statspai as sp`） |
| [`00.1-Full-empirical-analysis-skill`](../00.1-Full-empirical-analysis-skill/) | Python — 显式传统生态 |
| [`00.2-Full-empirical-analysis-skill_Stata`](../00.2-Full-empirical-analysis-skill_Stata/) | Stata — 显式 .do pipeline |
| **`00.3-Full-empirical-analysis-skill_R`**（本 skill） | **R — tidyverse + fixest pipeline** |

同一 8 步流程、四种生态实现，并行收录、互不替代。按场景选：

- 要 Quarto / R Markdown 一体化复现报告 ⇒ **本 skill**
- 审稿人 / 合作者只接受 Stata ⇒ `00.2`
- Python 显式逐行控制 ⇒ `00.1`
- 一键 DSL + 自描述 API ⇒ `00`

## 安装

英文区已给出 `install.packages(...)` 大清单，复制粘贴一次跑完即可。
推荐用 `renv::init()` 在项目级别锁定包版本。

## 激活

触发词包括：*"用 R 跑一次完整实证分析"*、*"feols 双向固定效应"*、
*"Callaway-Sant'Anna R 版"*、*"MatchIt 最近邻匹配"*、*"modelsummary 导出
LaTeX"*、*"plot_slopes 边际效应图"*、*"gtsummary Table 1"*、
*"binsreg R 版"*、*"bacondecomp"*、*"HonestDiD"*、*"grf 因果森林"*、
*"Imai 中介"* 等。完整列表见 `SKILL.md` 中的 `triggers:`。

## 覆盖范围

**覆盖** —— R 经典 8 步 pipeline：

```
Step 1  数据导入 / 清洗     read_dta/read_csv/janitor/naniar/validate/assertr
Step 2  变量构造           dplyr mutate/across/Winsorize/scale/lag/lead
Step 3  描述统计           gtsummary/datasummary_balance/cor_pmat/ggdist
Step 4  诊断检验           shapiro/bptest/dwtest/vif/adf/kpss/Hausman
Step 5  基准建模           feols/ivreg/att_gt/sunab/synthdid/MatchIt/grf
Step 6  稳健性电池         fwildclusterboot/ri2/bacondecomp/HonestDiD/robomit
Step 7  进一步分析         marginaleffects/mediation/lavaan/grf
Step 8  表与图             modelsummary/iplot/ggplot2/cowplot/Quarto
```

**不覆盖** —— Bayesian R 工作流（`brms`/`rstan`，见
[`23-Learning-Bayesian-Statistics-baygent-skills`](../23-Learning-Bayesian-Statistics-baygent-skills/)）、
agent-native 一键 DSL（见 `00`）、以及正文撰写（LaTeX 文字）。本 skill
在 Step 8 结束，交付 `.tex` / `.docx` 表和 `.pdf` 图。

## 文件

- `SKILL.md` — frontmatter + 完整 agent 操作手册（8 步流程 + 选包速查表 + 常见坑 + 项目骨架 + Quarto 入口）
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

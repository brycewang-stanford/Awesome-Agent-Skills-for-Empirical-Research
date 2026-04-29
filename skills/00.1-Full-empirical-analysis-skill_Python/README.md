# Full Empirical Analysis Skill for Claude Code (Python)

This folder is a **Claude Code Skill** that teaches Claude (or any compatible
agent harness) how to drive a complete empirical analysis end-to-end in the
**traditional Python econometric stack** — `pandas + numpy + scipy +
statsmodels + linearmodels + pyfixest + rdrobust + econml + causalml +
matplotlib/seaborn` — with explicit control at every step, covering
**three domain modes** that share the same 8-step scaffolding:

- **Default — Applied Econ (AER / QJE / AEJ).** The canonical 8-step pipeline:
  cleaning → variable construction → Table 1 → diagnostic tests → baseline
  modeling (OLS / `pyfixest.feols` HDFE / IV / DID / RD / SCM / matching /
  DML) → robustness gauntlet (placebo / Oster / `honest_did` / spec curve /
  alt-SE) → mechanism + heterogeneity → publication-ready Word / Excel /
  LaTeX bundle.
- **Mode A — Epidemiology / public health (§A).** Target-trial emulation
  in `pandas`, IPTW + g-formula + TMLE doubly-robust triplet via `zepid`
  / `econml`, Mendelian randomization (IVW / Egger / weighted median) via
  `pymr` or `rpy2`+`TwoSampleMR`, KM / Cox / AFT / RMST survival via
  `lifelines`, E-value sensitivity, principal stratification — under
  STROBE / TRIPOD-AI reporting conventions.
- **Mode B — ML causal inference (§B).** DML (`econml.dml` / `doubleml`),
  S/T/X/R/DR meta-learners (`econml.metalearners` / `causalml`), causal
  forest (`econml.grf`), Dragonnet / TARNet / CEVAE neural causal
  (`causalml`), BCF, matrix completion, CATE distribution + policy tree
  (`econml.policy` / `policytree-py`) + off-policy evaluation, conformal
  causal prediction (`mapie`), fairness audit (`fairlearn`), and DAG
  learning (`causal-learn` PC / `cdt` NOTEARS / LLM-assisted).

All three modes reuse the same Step 1–4 (cleaning → Table 1 → diagnostics)
and Step 8 (publication tables / figures) scaffolding — switching modes
only changes which Step-5 estimator family you reach for, not the surrounding
paper structure.

## Philosophy

This skill is the *companion opposite* of the `00-StatsPAI_skill` in the same
repository:

| | `00-StatsPAI_skill` | `00.1-Full-empirical-analysis-skill` |
|-|---------------------|--------------------------------------|
| Import style | `import statspai as sp` (one package) | explicit, per-library imports |
| Abstraction | agent-native high-level DSL | raw, inspectable classical calls |
| Three modes | Default Econ + §A Epi + §B ML causal | Default Econ + §A Epi + §B ML causal (parallel) |
| Scope       | EDA → DSL → DAG → estimate → robust | **cleaning → transforms → descriptive → tests → model → robust → mechanism → tables** |
| Best when   | you want a one-shot pipeline | you want full control, or need to teach / audit each step |

Both co-exist and ship the same three domain modes: use StatsPAI when you
trust the DSL; use this skill when you want every line explicit and every
library choice visible.

## Install

```bash
# Option 1: copy
cp -r 00.1-Full-empirical-analysis-skill ~/.claude/skills/Full-empirical-analysis-skill

# Option 2: symlink (auto-follow upstream updates)
ln -s "$(pwd)/00.1-Full-empirical-analysis-skill" \
      ~/.claude/skills/Full-empirical-analysis-skill
```

Install the Python stack:

```bash
pip install pandas numpy scipy matplotlib seaborn \
            statsmodels linearmodels pyfixest \
            rdrobust rddensity \
            econml causalml \
            stargazer tableone missingno \
            pingouin arch binsreg
# Optional
pip install pyreadstat pysynth ebal
```

## Activate

The skill auto-activates on natural-language triggers such as
*"run a full empirical analysis in Python"*, *"replicate an applied economics
paper"*, *"build a Table 1 balance table"*, *"winsorize at 1/99%"*,
*"run Breusch-Pagan"*, *"placebo test"*, *"event study plot"*,
*"mediation analysis"*, etc. Full list in the `triggers:` block of `SKILL.md`.

## Scope

**In scope** — the canonical 8-step pipeline (v2 adds Step −1 / Step 0 / Step 2.5 / Step 3.5 sub-stages mirroring the StatsPAI reference skill):

```
Step −1 Pre-Analysis Plan         statsmodels.stats.power → pap.json
Step 0  Sample log + data contract sample_log + 5-check asserts → JSON
Step 1  Data cleaning              missing / outliers / dtype / join / panel
Step 2  Variable construction      log / winsorize / standardize / encode / lags
Step 2.5 Empirical strategy        equation × ID assumption × estimator → strategy.md
Step 3  Descriptive statistics     summary / Table 1 / correlation / distributions
Step 3.5 Identification graphics   event-study / 1st-stage F / McCrary / love / SCM trajectory
Step 4  Diagnostic tests           normality / hetero / autocorr / VIF / stationarity
Step 5  Baseline modeling          OLS / panel FE / IV / DID / RD / SC / matching / DML
        Patterns A–H               progressive ctrls / horse race / multi-Y / IV triplet / ...
Step 6  Robustness battery         placebo / subsample / spec curve / Oster δ*
        + Pattern H Master Table A1 + spec curve + sensitivity dashboard
Step 7  Further analysis           mechanism / heterogeneity / mediation / moderation
Step 8  Tables & figures           stargazer / coefplot / event study / forest plot
        + reproducibility stamp (artifacts/result.json)
```

**Out of scope** — paper drafting (LaTeX prose), DSGE / HANK numerical macro
(see `20-wenddymacro-python-econ-skill`), and opinionated agent-native DSLs
(see `00-StatsPAI_skill`). This skill hands you the polished tables and
figures, not the written manuscript.

## Files

- `SKILL.md` — frontmatter + full agent playbook (8-step workflow + library cheat-sheet + common mistakes)
- `README.md` — this file
- `references/` — deep per-step references, loaded on demand
  - `01-data-cleaning.md`
  - `02-data-transformation.md`
  - `03-descriptive-stats.md`
  - `04-statistical-tests.md`
  - `05-modeling.md`
  - `06-robustness.md`
  - `07-further-analysis.md`
  - `08-tables-plots.md`

## When to read the references

`SKILL.md` alone covers the canonical call at each step. Reach for the
matching `references/NN-*.md` file when:

- The user's case doesn't fit the default (e.g. multi-cutoff RD → `05-modeling.md §6`)
- You need a variant-specific diagnostic (e.g. wild cluster bootstrap → `06-robustness.md §2`)
- You want the full table of alternatives (e.g. every normality test → `04-statistical-tests.md §1`)

Each reference file is organized by section number so you can grep directly:

```bash
grep -n "^## " references/05-modeling.md
```

---

# 完整实证分析技能（中文，Python）

本文件夹是一份 **Claude Code Skill**，教 Claude（或任何兼容的 agent 运行时）
端到端地完成一次实证分析，使用的是**传统 Python 计量生态** —— `pandas +
numpy + scipy + statsmodels + linearmodels + pyfixest + rdrobust + econml
+ causalml + matplotlib/seaborn`，每一步都显式可控。覆盖**三种领域模式**，
共用同一套 8 步骨架（清洗 / Table 1 / 诊断 / 出表）：

- **默认 — 应用经济学（AER / QJE / AEJ）**。8 步流程：清洗 → 变量构造 →
  Table 1 → 诊断检验 → 基准建模（OLS / `pyfixest.feols` HDFE / IV / DID /
  RD / SCM / 匹配 / DML）→ 稳健 gauntlet（安慰剂 / Oster / `honest_did` /
  规范曲线 / 替代 SE）→ 机制 + 异质性 → 论文级 Word / Excel / LaTeX 三件套。
- **模式 A — 流行病学 / 公共健康（§A）**。`pandas` 写 target-trial 协议、
  `zepid` / `econml` 跑 IPTW + g-formula + TMLE 双稳健三件套，
  `pymr` 或 `rpy2`+`TwoSampleMR` 做孟德尔随机化（IVW / Egger / 加权中位数），
  `lifelines` 做 KM / Cox / AFT / RMST 生存分析，E-value 敏感性，
  principal stratification——按 STROBE / TRIPOD-AI 报告规范输出。
- **模式 B — 因果机器学习（§B）**。DML（`econml.dml` / `doubleml`），
  S/T/X/R/DR meta-learner（`econml.metalearners` / `causalml`），
  causal forest（`econml.grf`），Dragonnet / TARNet / CEVAE 神经因果
  （`causalml`），BCF，matrix completion，CATE 分布 + policy tree
  （`econml.policy` / `policytree-py`）+ off-policy 评估，conformal causal
  预测区间（`mapie`），fairness audit（`fairlearn`），DAG 学习
  （`causal-learn` PC / `cdt` NOTEARS / LLM 辅助）。

三种模式共用同一套 Step 1–4（清洗 / Table 1 / 诊断）和 Step 8（出表 / 出图）
骨架——切换模式只换 Step-5 估计器组合，前后骨架保持一致。

## 哲学

本 skill 与同仓库中的 `00-StatsPAI_skill` 互为补位：

| | `00-StatsPAI_skill` | `00.1-Full-empirical-analysis-skill` |
|-|---------------------|--------------------------------------|
| 引入风格 | `import statspai as sp` | 各库显式引入 |
| 抽象层次 | 面向 agent 的高层 DSL | 原始、可审计的经典调用 |
| 三种模式 | 默认 Econ + §A 流行病 + §B ML 因果 | 默认 Econ + §A 流行病 + §B ML 因果（一一对应） |
| 覆盖步骤 | EDA → DSL → DAG → 估计 → 稳健 | **清洗 → 变量构造 → 描述 → 检验 → 建模 → 稳健 → 机制 → 出表** |
| 适用场景 | 一键跑完整 pipeline | 需要全量控制、审计每一步、或做教学 |

两者并行存在，且三种领域模式一一对应：信任 DSL 时用 StatsPAI；要逐行审计、
展示每个库选择时用本 skill。

## 安装

```bash
# 方式 1：复制
cp -r 00.1-Full-empirical-analysis-skill ~/.claude/skills/Full-empirical-analysis-skill

# 方式 2：软链
ln -s "$(pwd)/00.1-Full-empirical-analysis-skill" \
      ~/.claude/skills/Full-empirical-analysis-skill
```

## 激活

触发词包括 *"在 Python 里跑一次完整实证分析"*、*"复现一篇应用经济学文章"*、
*"做一个 Table 1 平衡性表"*、*"1/99 缩尾"*、*"Breusch-Pagan 检验"*、
*"安慰剂检验"*、*"事件研究图"*、*"中介分析"* 等。完整列表见 `SKILL.md`
frontmatter 中的 `triggers:`。

## 覆盖范围

**覆盖** —— 经典 8 步 pipeline（v2 对齐 StatsPAI 参考 skill，新增 Step −1 / Step 0 / Step 2.5 / Step 3.5 子阶段）：

```
Step −1 预分析计划（PAP）  statsmodels.stats.power → pap.json
Step 0  样本日志 + 数据契约 sample_log + 5 项 assert → JSON
Step 1  数据清洗            缺失 / 异常 / dtype / 合并 / 面板
Step 2  变量构造            log / 缩尾 / 标准化 / 编码 / 滞后
Step 2.5 实证策略           方程式 × 识别假设 × 估计器 → strategy.md
Step 3  描述统计            summary / Table 1 / 相关 / 分布
Step 3.5 识别图            事件研究 / 一阶段 F / McCrary / love / SCM 轨迹
Step 4  诊断检验            正态 / 异方差 / 自相关 / VIF / 平稳
Step 5  基准建模            OLS / 面板 FE / IV / DID / RD / SC / 匹配 / DML
        八种 regtable 模式 A–H  渐进控制 / 设计赛马 / 多 Y / IV 三联 / ...
Step 6  稳健性检验          安慰剂 / 子样本 / 规范曲线 / Oster δ*
        + Pattern H 稳健性主表 A1 + 规范曲线 + 敏感性面板
Step 7  进一步分析          机制 / 异质性 / 中介 / 调节
Step 8  表与图              stargazer / 系数图 / 事件研究图 / 森林图
        + 复现戳（artifacts/result.json）
```

**不覆盖** —— 正文撰写（LaTeX 文字）、DSGE / HANK 数值宏观
（见 `20-wenddymacro-python-econ-skill`）、以及 agent-native DSL
（见 `00-StatsPAI_skill`）。本 skill 交付的是**打磨好的表和图**，不包括正文。

## 文件

- `SKILL.md` — frontmatter + 完整 agent 手册（8 步流程 + 选库表 + 常见坑）
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

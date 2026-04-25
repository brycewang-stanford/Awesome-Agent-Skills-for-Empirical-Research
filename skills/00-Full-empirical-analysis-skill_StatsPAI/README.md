# StatsPAI Skill for Claude Code

This folder is a **Claude Code Skill** that teaches Claude (or any
compatible agent harness) how to drive [StatsPAI](https://github.com/brycewang-stanford/StatsPAI)
end-to-end through the **canonical pipeline of an applied AER /
QJE / AEJ empirical paper** — pre-analysis plan, Table 1 summary
statistics, written-out estimating equation and identifying
assumption, identification graphics (event-study / first-stage F /
McCrary / SCM trajectory / love plot), the AER multi-regression
"Table 2" gauntlet (progressive controls / design horse-race /
multi-outcome / IV first-stage triplet), heterogeneity (subgroup
table + CATE figure), mechanisms, and a full robustness battery
(placebo / Oster / honest_did / E-value / Conley / two-way SE /
spec curve / sensitivity dashboard) — ending in a paper-ready
replication package.

## Install

```bash
# Option 1: copy
cp -r StatsPAI_skill ~/.claude/skills/StatsPAI_skill

# Option 2: symlink (auto-follow upstream updates)
ln -s "$(pwd)/StatsPAI_skill" ~/.claude/skills/StatsPAI_skill
```

Then install the Python package itself:

```bash
pip install statspai
```

## Activate

The skill auto-activates on natural-language triggers such as
*"run a DID analysis"*, *"AER empirical analysis"*, *"applied
microeconomics pipeline"*, *"instrumental variables regression"*,
*"event-study plot"*, *"first-stage F"*, *"Oster bound"*,
*"estimand-first DSL"*, etc. See the `triggers:` block in
`SKILL.md` for the full list.

## Scope

**In scope** — the canonical AER 8-section empirical pipeline:

```text
§-1 Pre-Analysis Plan      →  §0 Data construction & contract
§1  Table 1 (descriptives) →  §2 Empirical strategy (equation + identifying assumption)
§3  Identification graphics (event-study / first-stage / McCrary / SCM trajectory / love plot)
§4  Multi-regression main tables (progressive controls / design horse-race / multi-outcome /
                                  panel A-B / IV first-stage triplet) + coefplot
§5  Heterogeneity (subgroup table + CATE / dose-response figure)
§6  Mechanisms (mediation / decomposition)
§7  Robustness gauntlet (placebo / Oster / honest_did / E-value / 2-way & Conley SE /
                         spec curve / sensitivity dashboard) + robustness master table
§8  Replication package (LaTeX tables + figures + reproducibility stamp)
```

**Out of scope** — data cleaning (use pandas first) and end-to-end
paper drafting (`sp.paper()`; the skill stops at diagnostics and
hands the `CausalResult` back to you).

## Files

- `SKILL.md` — frontmatter + full agent playbook (8 paper sections, 8 multi-regression `regtable` patterns, 17 standard figures, Method Catalog, Common Mistakes)
- `README.md` — this file

---

## StatsPAI Skill for Claude Code（中文版）

本文件夹是一份 **Claude Code Skill**，教 Claude（或任何兼容的 agent
运行时）端到端地驱动 [StatsPAI](https://github.com/brycewang-stanford/StatsPAI)
按照 **典型的应用经济学（AER / QJE / AEJ）实证论文套路** 完成一次完整
分析——从预分析计划、样本构造、Table 1 描述统计、写出回归方程与识别
假设，到事件研究图 / 一阶段 F / McCrary 密度 / SCM 轨迹 / love plot
等识别图、AER 多回归主表火力全开（progressive controls / 设计赛马
/ 多结果 / 面板 A-B / IV 三件套）、异质性（子样本表 + CATE 图）、
机制分解、完整 robustness gauntlet（placebo / Oster / honest_did /
E-value / Conley / 二维聚类 / spec curve / sensitivity dashboard），
最终交付一份可复现的论文级 replication package。

### 安装

```bash
# 方式 1：复制
cp -r StatsPAI_skill ~/.claude/skills/StatsPAI_skill

# 方式 2：软链（自动跟随上游更新）
ln -s "$(pwd)/StatsPAI_skill" ~/.claude/skills/StatsPAI_skill
```

再装 Python 包本体：

```bash
pip install statspai
```

### 激活

Skill 会被自然语言触发词自动激活，例如 *"run a DID analysis"*、
*"AER empirical analysis"*、*"applied microeconomics pipeline"*、
*"instrumental variables regression"*、*"event-study plot"*、
*"first-stage F"*、*"Oster bound"*、*"estimand-first DSL"* 等。
完整列表见 `SKILL.md` 开头 frontmatter 的 `triggers:` 字段。

### 适用范围

**覆盖**——AER 风格的 8 段式实证分析闭环：

```text
§-1 预分析计划          →  §0 样本构造与 data contract
§1  Table 1 描述统计     →  §2 实证策略（方程 + 识别假设）
§3  识别图（event-study / 一阶段 / McCrary / SCM 轨迹 / love plot）
§4  多回归主表（progressive controls / 设计赛马 / 多结果 / 面板 A-B
              / IV 一阶段+简化式+2SLS 三件套） + 系数图
§5  异质性（子样本表 + CATE / 剂量反应图）
§6  机制（中介 / 分解）
§7  Robustness gauntlet（placebo / Oster / honest_did / E-value /
                       二维 & Conley SE / spec curve / sensitivity 面板）
                       + Robustness master 主表
§8  Replication package（LaTeX 表格 + 图 + 复现戳）
```

**不覆盖**——数据清洗（先用 pandas 处理）和端到端论文生成
（`sp.paper()`；skill 在诊断这一步停住，把 `CausalResult`
交还给用户）。

### 文件

- `SKILL.md` — frontmatter + 完整 agent 操作手册（8 个论文 section、8 套 `regtable` 多回归 pattern、17 张标准图、Method Catalog、Common Mistakes）
- `README.md` — 本文件

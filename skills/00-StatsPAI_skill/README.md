# StatsPAI Skill for Claude Code

This folder is a **Claude Code Skill** that teaches Claude (or any
compatible agent harness) how to drive [StatsPAI](https://github.com/brycewang-stanford/StatsPAI)
end-to-end for a complete empirical analysis — from EDA and
estimand-first research-question DSL, through LLM-assisted DAG
discovery and estimation, to diagnostics and robustness.

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
*"run a DID analysis"*, *"automate a complete empirical analysis"*,
*"instrumental variables regression"*, *"estimand-first DSL"*, etc.
See the `triggers:` block in `SKILL.md` for the full list.

## Scope

**In scope** — the canonical six-step loop:

```
EDA & descriptives  →  pre-flight checks  →  estimand-first question
   →  LLM-assisted DAG discovery  →  estimation  →  diagnostics & robustness
```

**Out of scope** — data cleaning (use pandas first) and end-to-end
paper drafting (`sp.paper()`; the skill stops at diagnostics and
hands the `CausalResult` back to you).

## Files

- `SKILL.md` — frontmatter + full agent playbook (Step 0–6 workflow + Method Catalog)
- `README.md` — this file

---

# StatsPAI Skill for Claude Code（中文）

本文件夹是一份 **Claude Code Skill**，教 Claude（或任何兼容的 agent
运行时）端到端地驱动 [StatsPAI](https://github.com/brycewang-stanford/StatsPAI)
完成一次完整的实证分析——从描述性统计和 estimand-first 研究问题
DSL，到 LLM 辅助的 DAG 发现、估计，再到诊断与稳健性检验。

## 安装

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

## 激活

Skill 会被自然语言触发词自动激活，例如 *"run a DID analysis"*、
*"automate a complete empirical analysis"*、*"instrumental variables
regression"*、*"estimand-first DSL"* 等。完整列表见 `SKILL.md` 开头
frontmatter 的 `triggers:` 字段。

## 适用范围

**覆盖**——标准的六步闭环：

```
描述性统计 → 预检查 → estimand-first 研究问题
   → LLM 辅助 DAG 发现 → 估计 → 诊断与稳健性
```

**不覆盖**——数据清洗（先用 pandas 处理）和端到端论文生成
（`sp.paper()`；skill 在诊断这一步停住，把 `CausalResult`
交还给用户）。

## 文件

- `SKILL.md` — frontmatter + 完整 agent 操作手册（Step 0–6 流程 + Method Catalog）
- `README.md` — 本文件

# AER-Skills（中文版）

[![License: MIT](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![聚焦](https://img.shields.io/badge/focus-AER%20%2F%20AER%3AInsights%20%2F%20AEJ-1f6feb)](docs/workflow-map.md)
[![工作流](https://img.shields.io/badge/workflow-识别驱动-blue)](docs/design-principles.md)

[English](README.md) | 简体中文

面向 *American Economic Review*（AER）、*AER: Insights* 以及 *AEJ* 系列期刊的 **agent skill 包**：覆盖**选题、识别策略、写作、表图规范、AEA 复现包、投稿审计、审稿回复**全流程。

本仓库**不是**通用经济学写作工具箱，而是一套**面向 top-5 经济学**的 skill 栈：识别优先的实证、AEA 政策合规的复现包、Keith Head 引言公式、AER 风格的 booktabs 表格、以及对编辑友好的 rebuttal 文体。

> ⚠️ **完整文档以英文 [README.md](README.md) 为准**。本文档是中文导航 + 关键差异速查，便于中文用户快速判断"这个 skill 是不是我要的"。

---

## 为什么需要单独的 AER skill 栈？

Top-5 经济学期刊的硬约束在生命科学类期刊中并不存在：

| 约束维度          | AER                | AER: Insights       | 含义                                              |
|-----------------|--------------------|---------------------|-------------------------------------------------|
| 摘要字数          | **100 词**         | 100 词              | 4-5 句话。卖结果，不卖动机。                          |
| 正文长度          | ~40 排印页         | **≤ 7,000 词减每个 exhibit 200 词** | 行文要紧；5 个 exhibits 时上限为 6,000 词。          |
| 拒稿率            | 高                 | **~45% 直接 desk** | 前三页决定生死。                                    |
| 复现要求          | 强制               | 强制                | AEA 数据与代码可用性政策有专人审核。                   |
| 识别策略          | 因果、设计驱动      | 因果、设计驱动        | TWFE、弱 IV、朴素 RDD 直接 desk-reject。            |
| Cover letter    | 可选               | 可选                | 仅用于 COI 披露或数据访问限制说明。                   |
| Disclosure statements | 必需          | 必需                | 每位合作者单独提交 PDF；无冲突也要明说。              |

通用的 "scientific writing" skill（例如 [Nature-Paper-Skills](https://github.com/Boom5426/Nature-Paper-Skills)、[nature-skills](https://github.com/Yuan1z0825/nature-skills)）通常不覆盖这些 AEA/AER 特定约束。

---

## 快速上手

### 1. Clone

```bash
git clone https://github.com/brycewang-stanford/AER-skills.git
cd AER-skills
```

### 2. 装到 Claude Code

```bash
mkdir -p ~/.claude/skills
cp -R skills/aer-* ~/.claude/skills/
```

### 3. 装到 Codex

```bash
mkdir -p ~/.codex/skills
cp -R skills/aer-* ~/.codex/skills/
```

手动复制只安装 skill 指令本体。如果需要使用 skill 中提到的 `templates/`
和 `examples/` 资源，请保留这个 cloned repository。

### 4. 第一个提示词

重启 agent 后，直接说：

```text
用 aer-workflow 告诉我这篇稿子下一步该用哪个 skill。
```

---

## 默认工作流

```text
aer-topic-selection     # 选题 + AER/Insights/AEJ 路由
    -> aer-identification    # 识别策略选型 + 现代实证
        -> aer-robustness        # 稳健性 / 异质性 / 机制
            -> aer-introduction      # 引言五段式 + 100 词摘要
                -> aer-tables-figures    # 表图规范
                    -> aer-replication       # AEA 复现包
                        -> aer-submission        # 投稿审计
                            -> aer-rebuttal          # 审稿回复
```

核心默认假设：

- **识别先于写作** — 设计有问题，写得再漂亮也救不回来
- **AER vs AER:Insights vs AEJ** 是个**选刊路由**问题，要在写摘要之前先决定
- **复现包质量是论文的一部分**，不是事后补的工作
- **审稿回复信永远针对修改后的稿件**，不要对着旧稿写

---

## 全部 Skill

| Skill | 用途 |
|---|---|
| [`aer-workflow`](skills/aer-workflow/SKILL.md) | 路由总表。下一步该用哪个 skill 由它决定。 |
| [`aer-topic-selection`](skills/aer-topic-selection/SKILL.md) | Top-5 标准检测、新颖性审计、AER/Insights/AEJ 路由。 |
| [`aer-introduction`](skills/aer-introduction/SKILL.md) | Keith Head 五段式引言 + 100 词摘要起草。 |
| [`aer-identification`](skills/aer-identification/SKILL.md) | DiD（错时）、IV（弱 IV 稳健）、RDD、SCM、shift-share/Bartik。 |
| [`aer-robustness`](skills/aer-robustness/SKILL.md) | 稳健性、异质性、机制、安慰剂 — 提前回应审稿人。 |
| [`aer-tables-figures`](skills/aer-tables-figures/SKILL.md) | AER booktabs 风格、`etable`/`estout`/`modelsummary`、figure notes。 |
| [`aer-replication`](skills/aer-replication/SKILL.md) | AEA 数据与代码可用性政策、README、openICPSR。 |
| [`aer-submission`](skills/aer-submission/SKILL.md) | 格式预审、cover letter、长度审计、利益冲突声明。 |
| [`aer-rebuttal`](skills/aer-rebuttal/SKILL.md) | R&R 回复信、分类、让步 / 澄清 / 反驳的决策规则。 |

---

## 设计哲学

- **识别驱动，不是叙事驱动** — 写文章之前先把识别策略压力测试通过
- **一篇论文只讲一个贡献** — AER 编辑会枪毙"合格但是常规的扩展"
- **跨领域可读性是硬筛选** — 一篇 labor 文章必须能让 public、macro、IO 经济学家也读懂
- **用现代计量，不要用 1990 年代的默认值** — TWFE → Callaway-Sant'Anna；first-stage F → Anderson-Rubin；朴素 RDD → 协变量调整的 local linear
- **复现包是论文的一部分** — README 跑不通 = AEA Data Editor 卡你
- **编辑的时间是最稀缺资源** — Cover letter ≤ 200 词。回复信先引用 comment、再说 action、再标出修改位置。

---

## 适用 / 不适用

**适用：**

- *American Economic Review*（长文，≤ 40 页）
- *American Economic Review: Insights*（短文，≤ 7,000 词减每个 exhibit 200 词；5 个 exhibits 时 ≤ 6,000 词）
- *American Economic Journal* 系列（Applied / Policy / Macro / Micro）
- 实证或理论经济学稿件
- 田野实验（含 AEA RCT Registry 流程）

**不适用：**

- 金融三大刊（JF / JFE / RFS 有自己的规范）
- 纯理论稿件（没有证明撰写助手）
- 通用 "academic writing" 库

---

## 致谢

Skill 架构参考自 [Boom5426/Nature-Paper-Skills](https://github.com/Boom5426/Nature-Paper-Skills) 与 [Yuan1z0825/nature-skills](https://github.com/Yuan1z0825/nature-skills)。方法论提炼自 **Keith Head**、**Marc F. Bellemare**、**Susan Athey**、**Berk-Harvey-Hirshleifer**、**AEA Data Editor's Office** 以及 *Annual Review of Economics* 的公开资料。

---

## 协议

[MIT](LICENSE)

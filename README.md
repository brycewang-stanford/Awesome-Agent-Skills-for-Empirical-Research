# Awesome Agent Skills for Empirical Research

[![Awesome](https://awesome.re/badge.svg)](https://awesome.re)
[![License: CC BY-SA 4.0](https://img.shields.io/badge/License-CC%20BY--SA%204.0-lightgrey.svg)](https://creativecommons.org/licenses/by-sa/4.0/)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](CONTRIBUTING.md)
[![Maintained by CoPaper.AI](https://img.shields.io/badge/Maintained%20by-CoPaper.AI-blue)](https://copaper.ai)

**实证研究全流程 AI Agent Skills 大全**

> A curated, opinionated list of AI Agent Skills for empirical research in economics, social science, and public policy — organized by research workflow, from topic selection to journal submission.

做实证研究的你，可能已经发现：2026 年的"标配工具箱"和三年前完全不一样了。Stata 19 新增了因果森林命令，Python 因果推断生态（DoWhy + EconML）被顶刊广泛采用，而 AI Agent 的 Skills 系统甚至能 **10 分钟自动复现一篇 AER 论文**。

这个仓库，就是一份面向实证研究者的 **Agent Skills 完整清单**。无论你是刚入门的硕士生，还是已发过 SSCI 的青年学者，都能找到提升效率的工具。

> **[CoPaper.AI](https://copaper.ai)** 是本仓库的维护方。CoPaper.AI 内置了 **20 个经济学方法论 Skills**（DID、IV、RDD、PSM、DML 等完整分析流程），支持一句话触发、多代理协作、结果自动输出。如果你想要开箱即用的实证分析体验，可以直接试试：[copaper.ai](https://copaper.ai)

---

## 目录

- [为什么需要这个列表？](#为什么需要这个列表)
- [按研究流程速查](#按研究流程速查)
- **Skills 分类详解**
  - [01 - 选题与研究设计](docs/01-选题与研究设计.md)
  - [02 - 文献检索与综述](docs/02-文献检索与综述.md)
  - [03 - 论文阅读与拆解](docs/03-论文阅读与拆解.md)
  - [04 - 数据获取与清洗](docs/04-数据获取与清洗.md)
  - [05 - 统计分析与因果推断](docs/05-统计分析与因果推断.md)
  - [06 - 论文写作](docs/06-论文写作.md)
  - [07 - 论文修改与润色](docs/07-论文修改与润色.md)
  - [08 - 引用管理与排版](docs/08-引用管理与排版.md)
  - [09 - 论文复现与可复现研究](docs/09-论文复现与可复现研究.md)
  - [10 - 审稿回复与学术答辩](docs/10-审稿回复与学术答辩.md)
- [综合型 Skill 套件](#综合型-skill-套件)
- [多代理协作系统](#多代理协作系统)
- [Skill 聚合平台与发现工具](#skill-聚合平台与发现工具)
- [传统工具生态速查](#传统工具生态速查)
- [学习资源](#学习资源)
- [Contributing](#contributing)

---

## 为什么需要这个列表？

西北大学经济学博士 Aniket Panjwani 在 2026 年 CEPR/VoxDev 讲座中指出：

> *"AI 编程代理对经济学研究已经有实际用处，入门成本已经足够低，而那些迟迟不动手的人，将在一个疲软的就业市场中学得更慢。"*

他给出的数据很残酷：**2025-2026 学年经济学博士招聘岗位暴跌 31%**。AI 正在替代半技术型白领任务，传统入门级岗位需求永久性萎缩。

但好消息是：**Skills 把最佳实践编码成了可复用的工作流**。你不需要每次都从头向 AI 解释"做 DID 要先检验平行趋势"——装一个 Skill，说一句话，它自己按流程走完。

**先开始的人，积累速度更快。**

---

## 按研究流程速查

> 不确定该用哪个 Skill？从你当前所处的研究阶段出发：

```
选题构思 → 文献检索 → 文献精读 → 研究设计 → 数据获取
   │           │          │          │          │
   ▼           ▼          ▼          ▼          ▼
  01          02         03         01         04
                                              
数据清洗 → 统计分析 → 论文初稿 → 修改润色 → 排版引用
   │           │          │          │          │
   ▼           ▼          ▼          ▼          ▼
  04          05         06         07         08

论文复现 → 投稿审稿 → 审稿回复 → 答辩展示
   │           │          │          │
   ▼           ▼          ▼          ▼
  09          10         10         10
```

### 一站式方案

如果你不想逐个挑选 Skills，以下方案可以直接覆盖全流程：

| 方案 | 覆盖范围 | 特点 | 链接 |
|------|---------|------|------|
| **CoPaper.AI** | 数据分析 → 论文写作 | 20 个方法论 Skills 内置，多代理架构，一句话触发完整分析流程 | [copaper.ai](https://copaper.ai) |
| **Claude Scholar** | 选题 → 投稿 | 25+ Skills 覆盖研究全生命周期，集成 Zotero MCP | [GitHub](https://github.com/Galaxy-Dawn/claude-scholar) |
| **K-Dense Scientific Skills** | 跨学科科学研究 | 140+ Skills，28+ 科学数据库，55+ Python 包 | [GitHub](https://github.com/K-Dense-AI/claude-scientific-skills) |
| **AI-Research-SKILLs** | AI/ML 研究 | 22 个类别、87 个技能，完整研究周期 | [GitHub](https://github.com/Orchestra-Research/AI-Research-SKILLs) |

---

## 综合型 Skill 套件

这些是包含多个 Skills 的综合型仓库，通常覆盖研究的多个阶段：

### 学术研究专用

| 套件 | Stars | Skills 数 | 核心特色 | 社科适配 |
|------|-------|----------|---------|---------|
| [K-Dense-AI/claude-scientific-skills](https://github.com/K-Dense-AI/claude-scientific-skills) | 8,799 | 140+ | 28+ 科学数据库（OpenAlex、PubMed），scientific-writing + literature-review + statistical-analysis | ⭐⭐⭐⭐ |
| [Orchestra-Research/AI-Research-SKILLs](https://github.com/Orchestra-Research/AI-Research-SKILLs) | 3,637 | 87 | 22 个类别，ML 论文写作，LaTeX 模板，引文验证 | ⭐⭐⭐ |
| [Imbad0202/academic-research-skills](https://github.com/Imbad0202/academic-research-skills) | ~1,790 | 多个 | 完整论文管线（research → write → review → revise → finalize），风格校准，幻觉检测 | ⭐⭐⭐⭐ |
| [Galaxy-Dawn/claude-scholar](https://github.com/Galaxy-Dawn/claude-scholar) | - | 25+ | 研究全生命周期：选题 → 综述 → 实验 → 写作 → 审稿回复，集成 Zotero MCP | ⭐⭐⭐⭐⭐ |
| [luwill/research-skills](https://github.com/luwill/research-skills) | 209 | 3 | 研究提案生成（research-proposal）、医学综述写作、论文转幻灯片，双语支持 | ⭐⭐⭐⭐⭐ |
| [lishix520/academic-paper-skills](https://github.com/lishix520/academic-paper-skills) | 22 | 2 | Strategist（7 维度审稿人模拟）+ Composer（系统化写作），适合人文社科 | ⭐⭐⭐⭐ |
| [Data-Wise/claude-plugins](https://github.com/Data-Wise/claude-plugins) | - | 17 | 统计研究专用：arXiv 搜索、DOI 查询、BibTeX 管理、方法论写作、审稿回复 | ⭐⭐⭐⭐⭐ |

### 经济学/因果推断专用

| 套件 | 核心特色 | 适用场景 |
|------|---------|---------|
| **[CoPaper.AI](https://copaper.ai)** | **20 个方法论 Skills**（OLS、DID、交错DID、IV、RDD、PSM、SCM、DML、因果森林等），多代理架构（Supervisor + 4 子代理），智能路由，结果自动输出 | 经济学实证研究全流程 |
| [claesbackman/AI-research-feedback](https://github.com/claesbackman/AI-research-feedback) | 2 代理经济学论文预审：因果过度声称检测、识别策略评估；支持 AER/QJE/JPE/Econometrica/REStud；6 代理基金评审 | 论文投稿前自审、基金申请 |
| [fuhaoda/stats-paper-writing-agent-skills](https://github.com/fuhaoda/stats-paper-writing-agent-skills) | LaTeX 统计论文写作，前端草稿生成 | 统计学、计量经济学论文 |

### 通用 Agent 能力增强

| 套件 | Stars | 核心特色 |
|------|-------|---------|
| [lyndonkl/claude](https://github.com/lyndonkl/claude) | - | 85 skills + 6 编排代理，含因果推断、贝叶斯推理、实验设计、多准则分析 |
| [alirezarezvani/claude-skills](https://github.com/alirezarezvani/claude-skills) | ~5,200 | 220+ skills + 298 CLI 脚本，含金融分析和数据处理 |
| [rohitg00/awesome-claude-code-toolkit](https://github.com/rohitg00/awesome-claude-code-toolkit) | - | 135 agents 含数据科学家代理（EDA、DID、RDD），35 skills，42 commands |

---

## 多代理协作系统

单个 Skill 是"单兵武器"，多代理系统是"军事编队"。以下是专为研究设计的多代理架构：

### 论文修改与写作

| 系统 | 架构 | 核心特色 |
|------|------|---------|
| **copy-edit-master** (连享会) | 3 子代理：structure-editor + line-editor + quality-reviewer | 文档类型自动检测，底层编码 Strunk & White / McCloskey 规则，每阶段 git 检查点，审阅循环（最多 2 次迭代） |
| **introduction-writer** (连享会) | 4 子代理：strategist → drafter → reviewer → reviser | Keith Head 公式起草引言，审阅者与起草者独立形成质量闭环 |
| **CoPaper.AI PaperAgent** | Supervisor + 4 子代理（preparation / modeling / visualization / writing） | Skill 按 target_agent 精准路由，每个子代理只看到相关方法论指导，减少上下文干扰 |

### 数据分析与研究

| 系统 | 来源 | 核心特色 |
|------|------|---------|
| [ruc-datalab/DeepAnalyze](https://github.com/ruc-datalab/DeepAnalyze) | 中国人民大学 | 自主数据分析 Agent，原始数据 → 专业报告，支持 CSV/Excel/JSON/数据库，开源模型 DeepAnalyze-8B |
| [business-science/ai-data-science-team](https://github.com/business-science/ai-data-science-team) | Business Science | 多代理数据科学团队：EDA Agent + SQL Agent + MLflow Agent，LangChain 集成 |
| [HungHsunHan/claude-code-data-science-team](https://github.com/HungHsunHan/claude-code-data-science-team) | 社区 | Claude Code 多代理系统，模拟数据科学团队，自动清洗 → 建模 → 生成报告 |
| [HKUDS/AI-Researcher](https://github.com/HKUDS/AI-Researcher) | 港大 (NeurIPS 2025 Spotlight) | 全自主研究管线：文献综述 → 假设生成 → 算法实现 → 论文撰写 |
| [wanshuiyin/Auto-claude-code-research-in-sleep (ARIS)](https://github.com/wanshuiyin/Auto-claude-code-research-in-sleep) | 社区 | 隔夜自主 ML 研究，跨模型审阅循环（Claude + 外部 LLM 做批评者） |

---

## Skill 聚合平台与发现工具

不知道去哪找 Skills？这些平台是你的"技能商店"：

| 平台 | 规模 | 特色 |
|------|------|------|
| [VoltAgent/awesome-agent-skills](https://github.com/VoltAgent/awesome-agent-skills) | 1,000+ skills | 13,700 stars，官方团队和社区精选 |
| [sickn33/antigravity-awesome-skills](https://github.com/sickn33/antigravity-awesome-skills) | 1,340+ skills | 28,000 stars，CLI 一键安装 `npx antigravity-awesome-skills` |
| [skills.sh](https://skills.sh/) | 在线市场 | 可搜索的 Skill 市场 |
| [ClawHub (clawhub.com)](https://clawhub.com) | 在线市场 | 开源 AI 技能市场，一行命令安装 |
| [Agent Skills 标准](https://agentskills.io/) | 规范文档 | Agent Skills 通用规范 |
| [Anthropic 官方 Skills](https://github.com/anthropics/skills) | 官方 | PDF/DOCX/XLSX/PPTX 文档处理 |
| [Anthropic Knowledge Work Plugins](https://github.com/anthropics/knowledge-work-plugins) | 官方 | 11 个插件含 Data Plugin（SQL 查询、数据探索） |

---

## 传统工具生态速查

Agent Skills 很强大，但实证研究的"硬功夫"仍然离不开传统统计工具。以下是 2026 年三大工具的核心定位：

### Stata / R / Python 对比

| 维度 | Stata | R | Python |
|------|-------|---|--------|
| **核心优势** | 学术计量黄金标准，命令简洁 | 因果推断包生态最完整 | 全栈能力，ML+因果推断一条龙 |
| **2026 新特性** | v19: CATE、弱IV稳健推断、HDFE、面板VAR | fixest 持续更新，did/fect/grf 生态 | DoWhy 2.0、EconML、CausalML |
| **DID** | `didregress`, `csdid` | `did`, `did2s`, `fect`, `fixest` | `differences`, `pyfixest` |
| **IV** | `ivregress 2sls` | `fixest::feols()` | `linearmodels.IV2SLS` |
| **RDD** | `rdrobust` | `rdrobust` | `rdrobust` |
| **DML/因果森林** | `cate` (v19), `ddml` | `grf`, `DoubleML` | `EconML`, `CausalML` |
| **就业市场信号** | 学术界必备 | 数据科学+学术研究 | 科技公司+跨学科 |

> **建议**：至少掌握两种工具。会一种已经不够了——越来越多的高价值岗位要求 "Stata/R" 或 "Python + 计量" 的组合技能。

### 因果推断方法速查

| 方法 | 核心思想 | Stata | R | Python |
|------|---------|-------|---|--------|
| OLS | 控制可观测混淆 | `reg` / `areg` | `lm()` / `fixest` | `statsmodels.OLS` |
| IV/2SLS | 外生变量替代内生变量 | `ivregress 2sls` | `fixest::feols()` | `linearmodels.IV2SLS` |
| DID | 处理组vs对照组 + 前vs后 | `diff` / `didregress` | `did` / `fixest` | `differences` |
| 交错 DID | 不同时间受处理 | `csdid` / `did_multiplegt` | `did` / `fect` | `pyfixest` |
| RDD | 断点处不连续性 | `rdrobust` | `rdrobust` | `rdrobust` |
| PSM | 倾向得分构造对照组 | `psmatch2` / `teffects` | `MatchIt` | `causalml` |
| SCM | 加权组合对照单元 | `synth` | `Synth` / `gsynth` | `SparseSC` |
| DML | ML 残差化因果估计 | `ddml` | `DoubleML` | `EconML.dml` |
| 因果森林 | CATE 异质处理效应 | `cate` (v19) | `grf` | `EconML.CausalForest` |
| Heckman | 样本选择偏差修正 | `heckman` | `sampleSelection` | `statsmodels.Heckman` |

### 常用数据源

<details>
<summary>点击展开全球宏观经济数据</summary>

| 数据源 | 说明 |
|--------|------|
| **FRED** | 美联储圣路易斯分行，超 80 万个时间序列 |
| **世界银行开放数据** | 200+ 国家的经济、人口、发展指标 |
| **IMF 数据** | 国际货币基金组织数据库 |
| **OECD.Stat** | 经合组织统计数据库 |
| **Our World in Data** | 全球问题研究数据 |
| **国家统计局** | 中国统计年鉴、宏观经济月度数据 |

</details>

<details>
<summary>点击展开微观调查与面板数据</summary>

| 数据源 | 说明 |
|--------|------|
| **NLSY** | 美国青年纵向调查 |
| **HRS** | 健康与退休研究，追踪约 2 万人 |
| **CFPS** | 中国家庭追踪调查（北大主持） |
| **CGSS** | 中国综合社会调查 |
| **CHARLS** | 中国健康与养老追踪调查 |
| **CHIP** | 中国住户收入调查 |

</details>

<details>
<summary>点击展开专业数据平台</summary>

| 平台 | 特色 |
|------|------|
| **NBER 数据档案** | 经济学工作论文配套数据集 |
| **ICPSR** | 密歇根大学社科数据中心 |
| **Google Dataset Search** | 跨平台数据集搜索引擎 |
| **马克数据网** | 社科数据共享平台 |
| **Wind / CSMAR** | 中国金融经济数据库（付费） |

</details>

---

## 学习资源

### 官方文档

- [Claude Code Skills 完全指南](https://resources.anthropic.com/hubfs/The-Complete-Guide-to-Building-Skill-for-Claude.pdf) — Anthropic 官方 32 页完整指南
- [Agent Skills 标准规范](https://agentskills.io/)
- [Claude Code 官方文档](https://docs.anthropic.com/en/docs/agents-and-tools/agent-skills)

### 学术讲座

- [AI Agents for Economics Research](https://cepr.org/) — Aniket Panjwani, CEPR/VoxDev, 2026.03.12
- [用 AI Agent 做文献综述与顶刊论文拆解](https://www.lianxh.cn/) — 连享会 T5 专题（3 小时）
- [用 AI Agent 系统修改论文](https://www.lianxh.cn/) — 连享会 T6 专题（3 小时）

### 因果推断教材

- [Causal Inference for the Brave and True](https://github.com/xieliaing/CausalInferenceIntro) — 中文翻译版，Python 代码
- [Statistical Tools for Causal Inference](https://chabefer.github.io/STCI/) — 开源教材
- [Causal Inference and Machine Learning Book](https://www.causalmlbook.com/)

### 综述论文

- [A Survey of Data Agents](https://github.com/HKUSTDial/awesome-data-agents) — 数据代理综述（HKUST）
- [From AI for Science to Agentic Science](https://github.com/AgenticScience/Awesome-Agent-Scientists) — arXiv:2508.14111
- [From Automation to Autonomy](https://github.com/HKUST-KnowComp/Awesome-LLM-Scientific-Discovery) — LLM 科学发现综述（EMNLP 2025）

### 社区

- [Awesome Claude Skills](https://github.com/travisvn/awesome-claude-skills) — 社区精选
- [Reddit r/ClaudeCode](https://www.reddit.com/r/ClaudeCode/)
- 计量经济圈（公众号 econometrics666） — 中文实证研究社区

---

## Contributing

欢迎贡献！请阅读 [CONTRIBUTING.md](CONTRIBUTING.md) 了解如何提交新的 Skill 推荐。

我们特别欢迎：
- 经济学、政治学、社会学、公共管理等社会科学领域的专用 Skills
- 因果推断方法的新 Skill 实现
- 中文友好的 Skills
- 多代理协作系统的案例分享

---

## Star History

如果这个列表对你有帮助，请给一个 Star 让更多人看到。

---

<div align="center">

**工具改变的是速度，不改变方向。方向是你自己定的。**

由 [CoPaper.AI](https://copaper.ai) 团队维护 | 实证研究 AI 助手

</div>

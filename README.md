# Awesome Agent Skills for Empirical Research

<div align="center">

**🌐 语言 / Language: 中文 | [English](README-en.md)**

<br/>

  <table>
    <tr>
      <td align="center">
        <a href="https://copaper.ai"><img src="images/copaper-logo.png" alt="CoPaper.AI" width="260" /></a>
      </td>
      <td width="60"></td>
      <td align="center">
        <img src="images/stanford-reap-logo.png" alt="Stanford REAP - Center on China's Economy & Institutions" width="380" />
      </td>
    </tr>
  </table>
  <br/>
</div>

[![Awesome](https://awesome.re/badge.svg)](https://awesome.re)
[![License: CC BY-SA 4.0](https://img.shields.io/badge/License-CC%20BY--SA%204.0-lightgrey.svg)](https://creativecommons.org/licenses/by-sa/4.0/)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](CONTRIBUTING.md)
[![Maintained by CoPaper.AI from Stanford REAP](https://img.shields.io/badge/Maintained%20by-CoPaper.AI%20from%20Stanford%20REAP-blue)](https://copaper.ai)

**实证研究全流程 AI Agent Skills 大全 — 收录 119 个 GitHub 仓库 / 覆盖 23,000+ Skills**

> A curated, opinionated list of **119 GitHub repositories** and **23,000+ AI Agent Skills** for empirical research in economics, political science, sociology, psychology, public health, education, management, finance, and public policy — organized by research workflow, from topic selection to journal submission.

2026 年，实证研究的工作方式正在被重新定义。[CoPaper.AI](https://copaper.ai) 已经做到 **20 分钟完成一篇主流期刊级别的实证论文**——从数据导入、描述性统计、因果推断模型、稳健性检验到结果表格一步到位。这背后的秘密不是更强的模型，而是 **Skills**：把资深研究者的方法论经验编码成结构化工作流，让 AI 知道"一个完整的 DID 分析应该包含哪些步骤"，而不是每次都等你一步步提醒。

这个仓库，是我们在构建 CoPaper.AI 过程中整理的一份 **Agent Skills 全景图**。我们把散落在 GitHub、社区和学术圈的数百个 Skills 仓库和上万个 Skills 按实证研究流程梳理归类，方便你按需取用。

> **[CoPaper.AI](https://copaper.ai)** 内置了 **20 个经济学方法论 Skills**（DID、IV、RDD、PSM、DML 等完整分析流程），支持一句话触发、多代理协作、结果自动输出。想要开箱即用？直接试试：[copaper.ai](https://copaper.ai)

---

## 目录

- [这份列表能帮你什么？](#这份列表能帮你什么)
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
- [学习资源](#学习资源)
- [Contributing](#contributing)

---

## 这份列表能帮你什么？

如果你正在做实证研究，大概经历过这些场景：

- 让 AI 帮你跑一个 DID，它给了基准回归就停了。你说"平行趋势呢"，它补一个。"安慰剂检验呢"，再补一个。**每次都像挤牙膏。**
- 好不容易写完初稿，引用格式一塌糊涂，还夹了几条 AI 编造的假引用。
- 想复现一篇顶刊的识别策略到自己的研究里，但从读懂到落地隔了一座山。

**问题不在于 AI 不会做——在于它不知道完整的流程应该包含哪些步骤。**

Skill 就是解决这个问题的：它是给 AI 的**方法论操作手册**。有了 Skill，AI 知道"跑 DID 应该先做平行趋势检验，再做基准回归，再做 4 项稳健性检验，再做异质性分析，再做机制分析，每一步的输出格式是什么"。你只需要说"帮我做 DID 分析"，剩下的它自己按流程走完。

这份列表按照实证研究的完整流程，帮你找到每个阶段最好用的 Skills。

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

如果你不想逐个挑选，以下方案直接覆盖全流程：

| 方案 | 覆盖范围 | 特点 | 链接 |
|------|---------|------|------|
| **CoPaper.AI** | 数据分析 → 论文写作 | 20 个方法论 Skills 内置，多代理架构，20 分钟完成主流期刊级别实证论文 | [copaper.ai](https://copaper.ai) |
| **Claude Scholar** | 选题 → 投稿 | 25+ Skills 覆盖研究全生命周期，集成 Zotero MCP | [GitHub](https://github.com/Galaxy-Dawn/claude-scholar) |
| **K-Dense Scientific Skills** | 跨学科科学研究 | 140+ Skills，28+ 科学数据库，55+ Python 包 | [GitHub](https://github.com/K-Dense-AI/claude-scientific-skills) |
| **AI-Research-SKILLs** | AI/ML 研究 | 22 个类别、87 个技能，完整研究周期 | [GitHub](https://github.com/Orchestra-Research/AI-Research-SKILLs) |
| **OpenClaw Medical Skills** | 生物医学/公共健康 | **869 个 Skills**，流行病学、临床研究、药物安全、生物统计 | [GitHub](https://github.com/FreedomIntelligence/OpenClaw-Medical-Skills) |
| **Agent Laboratory** | 全自主研究 | 文献综述 → 实验 → 报告，研究成本降低 84% | [GitHub](https://github.com/SamuelSchmidgall/AgentLaboratory) |

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
| [dylantmoore/stata-skill](https://github.com/dylantmoore/stata-skill) | Stata 全覆盖：语法、数据管理、计量经济学、因果推断、图形、Mata、20+ 社区包 | Stata 用户 |
| [SepineTam/stata-mcp](https://github.com/SepineTam/stata-mcp) | LLM 通过 MCP 直接操作 Stata 回归，"从回归猴进化为因果思考者" | Stata 计量分析 |

### 金融与投资研究

| 套件 | 核心特色 | 适用场景 |
|------|---------|---------|
| [anthropics/financial-services-plugins](https://github.com/anthropics/financial-services-plugins) | Anthropic 官方金融服务插件：投资银行、股权研究、私募、财富管理 | 金融服务全流程 |
| [OctagonAI/skills](https://github.com/OctagonAI/skills) | Octagon 代理式金融研究 Claude Skills | 机构级金融研究 |
| [tradermonty/claude-trading-skills](https://github.com/tradermonty/claude-trading-skills) | 股票投资与交易：市场分析、技术图表、经济日历、筛选器、策略开发 | 量化交易研究 |
| [himself65/finance-skills](https://github.com/himself65/finance-skills) | Agent Skills 开放标准，盈利前后分析、共识预估、分析师情绪 | 金融分析 |
| [quant-sentiment-ai/claude-equity-research](https://github.com/quant-sentiment-ai/claude-equity-research) | 机构级股权研究插件：基本面分析、技术指标、风险评估 | 股权研究 |

### 教育与公共健康

| 套件 | 核心特色 | 适用场景 |
|------|---------|---------|
| [GarethManning/claude-education-skills](https://github.com/GarethManning/claude-education-skills) | 循证教育 Claude Skills，专为教师和代理编排设计 | 教育研究、教学设计 |
| [FreedomIntelligence/OpenClaw-Medical-Skills](https://github.com/FreedomIntelligence/OpenClaw-Medical-Skills) | **869 个**医学 AI Skills：流行病学、公共健康监测、临床研究、药物安全、生物统计 | 公共健康、医学研究 |

### 治理、合规与法律

| 套件 | 核心特色 | 适用场景 |
|------|---------|---------|
| [Sushegaad/Claude-Skills-Governance-Risk-and-Compliance](https://github.com/Sushegaad/Claude-Skills-Governance-Risk-and-Compliance) | GRC Skills：ISO 27001、SOC 2、GDPR、HIPAA 等合规指导（94% vs 基准 72%） | 合规研究、政策分析 |
| [zubair-trabzada/ai-legal-claude](https://github.com/zubair-trabzada/ai-legal-claude) | 法律助手：合同审查、风险分析、NDA 生成、合规审计，14 Skills + 5 代理 | 法律经济学、规制研究 |
| [evolsb/claude-legal-skill](https://github.com/evolsb/claude-legal-skill) | AI 合同审查：CUAD 风险检测、市场基准、律师级红线标注 | 法经济学研究 |

### 营销与消费者行为

| 套件 | 核心特色 | 适用场景 |
|------|---------|---------|
| [coreyhaines31/marketingskills](https://github.com/coreyhaines31/marketingskills) | CRO、文案、SEO、分析和增长工程 | 市场营销研究 |
| [zubair-trabzada/ai-marketing-claude](https://github.com/zubair-trabzada/ai-marketing-claude) | 15 Skills + 并行子代理：网站审计、文案、邮件序列、竞争情报 | 消费者行为分析 |
| [ericosiu/ai-marketing-skills](https://github.com/ericosiu/ai-marketing-skills) | 增长实验、销售管线、内容运营、SEO、财务自动化 | 营销策略研究 |

### 产品管理与组织行为

| 套件 | 核心特色 | 适用场景 |
|------|---------|---------|
| [phuryn/pm-skills](https://github.com/phuryn/pm-skills) | 100+ 代理 Skills：发现到战略、执行、发布、增长，65 PM Skills + 36 链式工作流 | 产品管理、组织研究 |
| [mastepanoski/claude-skills](https://github.com/mastepanoski/claude-skills) | UX/UI 评估（Nielsen 启发式、WCAG）、AI 治理（NIST AI RMF、ISO 42001） | 用户体验研究 |

### 通用 Agent 能力增强

| 套件 | Stars | 核心特色 |
|------|-------|---------|
| [lyndonkl/claude](https://github.com/lyndonkl/claude) | - | 85 skills + 6 编排代理，含因果推断、贝叶斯推理、实验设计、多准则分析 |
| [alirezarezvani/claude-skills](https://github.com/alirezarezvani/claude-skills) | ~5,200 | 220+ skills + 298 CLI 脚本，含金融分析和数据处理 |
| [rohitg00/awesome-claude-code-toolkit](https://github.com/rohitg00/awesome-claude-code-toolkit) | - | 135 agents 含数据科学家代理（EDA、DID、RDD），35 skills，42 commands |
| [jeremylongshore/claude-code-plugins-plus-skills](https://github.com/jeremylongshore/claude-code-plugins-plus-skills) | - | 340 plugins + **1,367 agent skills**，CCPI 包管理器 |
| [affaan-m/everything-claude-code](https://github.com/affaan-m/everything-claude-code) | - | Skills、直觉、记忆、安全、研究优先开发框架 |
| [posit-dev/skills](https://github.com/posit-dev/skills) | - | Posit 官方：modern-r-tidyverse、predictive-modeling、quarto-authoring、shiny-bslib |

---

## 多代理协作系统

单个 Skill 解决单点问题，多代理系统解决**端到端流程**。以下系统让多个 AI 角色分工协作，互相审查，输出质量远超单 Agent：

### 论文修改与写作

| 系统 | 架构 | 核心特色 |
|------|------|---------|
| **copy-edit-master** | 3 子代理：structure-editor + line-editor + quality-reviewer | 文档类型自动检测，底层编码 Strunk & White / McCloskey 规则，每阶段 git 检查点，审阅循环（最多 2 次迭代） |
| **introduction-writer** | 4 子代理：strategist → drafter → reviewer → reviser | Keith Head 公式起草引言，审阅者与起草者独立形成质量闭环 |
| **CoPaper.AI PaperAgent** | Supervisor + 4 子代理（preparation / modeling / visualization / writing） | Skill 按 target_agent 精准路由，每个子代理只看到相关方法论指导，减少上下文干扰 |

> **为什么多代理比单 Agent 好？** 同一个 Agent 既写又审，倾向于认为自己写的都对。角色分离后，审阅者独立于起草者，才能形成真正的质量闭环。这和学术界同行评审的逻辑一样。

### 数据分析与研究

| 系统 | 来源 | 核心特色 |
|------|------|---------|
| [ruc-datalab/DeepAnalyze](https://github.com/ruc-datalab/DeepAnalyze) | 中国人民大学 | 自主数据分析 Agent，原始数据 → 专业报告，支持 CSV/Excel/JSON/数据库，开源模型 DeepAnalyze-8B |
| [business-science/ai-data-science-team](https://github.com/business-science/ai-data-science-team) | Business Science | 多代理数据科学团队：EDA Agent + SQL Agent + MLflow Agent，LangChain 集成 |
| [HungHsunHan/claude-code-data-science-team](https://github.com/HungHsunHan/claude-code-data-science-team) | 社区 | Claude Code 多代理数据科学团队，自动清洗 → 建模 → 生成可执行 Notebook |
| [HKUDS/AI-Researcher](https://github.com/HKUDS/AI-Researcher) | 港大 (NeurIPS 2025 Spotlight) | 全自主研究管线：文献综述 → 假设生成 → 算法实现 → 论文撰写 |
| [wanshuiyin/Auto-claude-code-research-in-sleep (ARIS)](https://github.com/wanshuiyin/Auto-claude-code-research-in-sleep) | 社区 | 隔夜自主研究，跨模型审阅循环（Claude + 外部 LLM 做批评者） |
| [SamuelSchmidgall/AgentLaboratory](https://github.com/SamuelSchmidgall/AgentLaboratory) | 学术 (ICLR) | 端到端自主研究：文献综述 → 实验 → 报告，集成 arXiv/Hugging Face/LaTeX，研究成本降低 84% |
| [SakanaAI/AI-Scientist-v2](https://github.com/SakanaAI/AI-Scientist-v2) | Sakana AI | 全自动科学发现：假设生成 → 实验 → 论文，首篇 AI 论文通过同行评审 |
| [assafelovic/gpt-researcher](https://github.com/assafelovic/gpt-researcher) | 社区 | 自主深度研究代理，支持任意 LLM 提供商 |
| [LitLLM/LitLLM](https://github.com/LitLLM/LitLLM) | 学术 | AI 文献综述助手：关键词提取 + 多策略检索 + 重排序归属，基于 RAG |
| [pedrohcgs/claude-code-my-workflow](https://github.com/pedrohcgs/claude-code-my-workflow) | Emory 大学 | 学术 LaTeX/Beamer + R 模板，多代理审查 + 质量门控，15+ 研究组采用 |
| [hugosantanna/clo-author](https://github.com/hugosantanna/clo-author) | 社区 | 将 Sant'Anna 工作流从课件扩展到全社科实证研究发表 |

### 学术数据 MCP 服务器

| 系统 | 核心特色 |
|------|---------|
| [xingyulu23/Academix](https://github.com/xingyulu23/Academix) | 聚合 OpenAlex + DBLP + Semantic Scholar + arXiv + CrossRef 为统一学术研究接口 |
| [Eclipse-Cj/paper-distill-mcp](https://github.com/Eclipse-Cj/paper-distill-mcp) | 11 源并行搜索，4 维加权排名（相关性/时效性/影响力/新颖性） |
| [oksure/openalex-research-mcp](https://github.com/oksure/openalex-research-mcp) | OpenAlex API：搜索 2.4 亿+ 学术作品、引用分析、趋势追踪、协作网络 |
| [zongmin-yu/semantic-scholar-fastmcp-mcp-server](https://github.com/zongmin-yu/semantic-scholar-fastmcp-mcp-server) | Semantic Scholar API 完整访问：论文、作者、引用网络 |
| [openags/paper-search-mcp](https://github.com/openags/paper-search-mcp) | 搜索 20+ 来源：arXiv、PubMed、bioRxiv、Google Scholar、SSRN、Unpaywall 等 |
| [aringadre76/mcp-for-research](https://github.com/aringadre76/mcp-for-research) | 整合 PubMed + Google Scholar + ArXiv + JSTOR，NPM 发布 |
| [blazickjp/arxiv-mcp-server](https://github.com/blazickjp/arxiv-mcp-server) | arXiv 论文搜索与分析 MCP |
| [lzinga/us-gov-open-data-mcp](https://github.com/lzinga/us-gov-open-data-mcp) | 40+ 美国政府 API（FRED/Census/CDC/FDA/FEC 等），250+ 工具 |
| [stefanoamorelli/fred-mcp-server](https://github.com/stefanoamorelli/fred-mcp-server) | FRED 80 万+ 经济时间序列直接访问 |
| [llnOrmll/world-bank-data-mcp](https://github.com/llnormll/world-bank-data-mcp) | 世界银行 Data360，1000+ 经济社会指标、200+ 国家 |
| [54yyyu/zotero-mcp](https://github.com/54yyyu/zotero-mcp) | Zotero 文献库与 AI 助手连接：论文评审、摘要、引用分析、PDF 标注 |
| [datagouv/datagouv-mcp](https://github.com/datagouv/datagouv-mcp) | 法国国家开放数据平台 MCP |

---

## Skill 聚合平台与发现工具

不知道去哪找 Skills？这些平台是你的起点：

| 平台 | 规模 | 特色 |
|------|------|------|
| [VoltAgent/awesome-agent-skills](https://github.com/VoltAgent/awesome-agent-skills) | 1,000+ skills | 13,700 stars，官方团队和社区精选 |
| [sickn33/antigravity-awesome-skills](https://github.com/sickn33/antigravity-awesome-skills) | 1,340+ skills | 28,000 stars，CLI 一键安装 `npx antigravity-awesome-skills` |
| [VoltAgent/awesome-openclaw-skills](https://github.com/VoltAgent/awesome-openclaw-skills) | **5,400+ skills** | 从 OpenClaw 官方注册表（ClawHub 13,729 Skills）筛选分类 |
| [jeremylongshore/claude-code-plugins-plus-skills](https://github.com/jeremylongshore/claude-code-plugins-plus-skills) | 1,367 skills | 340 plugins + CCPI 包管理器 |
| [skills.sh](https://skills.sh/) | 在线市场 | 可搜索的 Skill 市场 |
| [ClawHub (clawhub.com)](https://clawhub.com) | **13,729 skills** | 开源 AI 技能市场，一行命令安装 |
| [Agent Skills 标准](https://agentskills.io/) | 规范文档 | Agent Skills 通用规范 |
| [Anthropic 官方 Skills](https://github.com/anthropics/skills) | 官方 | PDF/DOCX/XLSX/PPTX 文档处理 |
| [Anthropic 官方插件市场](https://github.com/anthropics/claude-plugins-official) | 官方 | Anthropic 管理的高质量 Claude Code 插件目录 |
| [Anthropic Knowledge Work Plugins](https://github.com/anthropics/knowledge-work-plugins) | 官方 | 11 个插件含 Data Plugin（SQL 查询、数据探索） |
| [Anthropic Financial Services Plugins](https://github.com/anthropics/financial-services-plugins) | 官方 | 金融服务插件：投行、股研、私募、财管 |

---

## 学习资源

### 官方文档

- [Claude Code Skills 完全指南](https://resources.anthropic.com/hubfs/The-Complete-Guide-to-Building-Skill-for-Claude.pdf) — Anthropic 官方 32 页指南
- [Agent Skills 标准规范](https://agentskills.io/)
- [Claude Code 官方文档](https://docs.anthropic.com/en/docs/agents-and-tools/agent-skills)

### 学术讲座与课程

- [AI Agents for Economics Research](https://cepr.org/) — Aniket Panjwani, CEPR/VoxDev, 2026.03
- [Claude Code & Cowork for Academic Research — A Practical Guide](https://cornwl.github.io/files/claude-academic-guide.html) — 经济学家和社科研究者实操指南，2026.02
- [Building Claude Code Workflow for Economics Scholars](https://zhiyuanryanchen.github.io/claude-code-workflow.html) — 经济学研究者的 Claude Code 工作流构建

### 因果推断教材

- [Causal Inference for the Brave and True](https://github.com/xieliaing/CausalInferenceIntro) — 中文翻译版，Python 代码
- [Statistical Tools for Causal Inference](https://chabefer.github.io/STCI/) — 开源教材
- [Causal Inference and Machine Learning Book](https://www.causalmlbook.com/)

### 综述论文与 Awesome Lists

- [A Survey of Data Agents](https://github.com/HKUSTDial/awesome-data-agents) — 数据代理综述（HKUST）
- [From AI for Science to Agentic Science](https://github.com/AgenticScience/Awesome-Agent-Scientists) — arXiv:2508.14111
- [From Automation to Autonomy](https://github.com/HKUST-KnowComp/Awesome-LLM-Scientific-Discovery) — LLM 科学发现综述（EMNLP 2025）
- [Awesome Agents for Science](https://github.com/OSU-NLP-Group/awesome-agents4science) — LLM 和代理在科学研发中的论文列表
- [Awesome AI for Science](https://github.com/ai-boost/awesome-ai-for-science) — AI 加速科学发现工具、论文、数据集
- [Awesome AI for Economists](https://github.com/hanlulong/awesome-ai-for-economists) — 经济学 AI 工具、库和资源列表（OpenEcon 团队）
- [Awesome Econ AI Stuff](https://github.com/meleantonio/awesome-econ-ai-stuff) — 经济学家 AI Skills 集合，遵循 SKILL.md 标准
- [AI for Grant Writing](https://github.com/eseckel/ai-for-grant-writing) — LLM 辅助基金申请资源策展列表
- [Awesome AI Scientist Papers](https://github.com/openags/Awesome-AI-Scientist-Papers) — AI 科学家 / 机器人科学家论文集
- [FreedomIntelligence/OpenClaw-Medical-Skills](https://github.com/FreedomIntelligence/OpenClaw-Medical-Skills) — **869 个**医学 AI Skills，覆盖流行病学、公共健康、生物统计

### 社区与参考来源

- [Awesome Claude Skills](https://github.com/travisvn/awesome-claude-skills) — 社区精选
- [Awesome Claude Skills (ComposioHQ)](https://github.com/ComposioHQ/awesome-claude-skills) — 策展 Claude Skills 列表
- [Awesome Claude Skills (BehiSecc)](https://github.com/BehiSecc/awesome-claude-skills) — 策展 Claude Skills 列表
- [Awesome Claude Code](https://github.com/hesreallyhim/awesome-claude-code) — Skills、Hooks、斜杠命令、代理编排器
- [Reddit r/ClaudeCode](https://www.reddit.com/r/ClaudeCode/)
- [Anthropic 官方 Claude Code Skills Cookbook](https://github.com/anthropics/claude-cookbooks/blob/main/skills/notebooks/02_skills_financial_applications.ipynb) — 金融应用 Skills 教程

---

## Contributing

欢迎贡献！请阅读 [CONTRIBUTING.md](CONTRIBUTING.md) 了解如何提交新的 Skill 推荐。

我们特别欢迎：
- 经济学、政治学、社会学、心理学、教育学、公共管理、公共健康等社会科学领域的专用 Skills
- 因果推断方法的新 Skill 实现
- 金融、管理学、市场营销、法经济学等商科领域的 Skills
- 文献综述、基金申请、研究提案等通用学术 Skills
- MCP 服务器（学术数据库、政府数据 API）
- 中文友好的 Skills
- 多代理协作系统的案例分享

---

## Star History

如果这个列表对你有帮助，请给一个 Star 让更多研究者看到。

---

<div align="center">

**AI 是放大器，不是替代品。它替你做最耗时的"搬砖"，你保留最核心的"判断"。**

<br/>

<a href="https://copaper.ai">
  <img src="images/copaper-logo.png" alt="CoPaper.AI" width="240" />
</a>

<br/>

<table>
  <tr>
    <td align="center">
      <a href="https://copaper.ai"><img src="images/copaper-qrcode.png" alt="扫码访问 copaper.ai" width="180" /></a><br/>
      <strong>扫码访问 <a href="https://copaper.ai">copaper.ai</a></strong>
    </td>
    <td align="center">
      <img src="images/copaper-wechat.jpg" alt="CoPaper.AI 公众号" width="180" /><br/>
      <strong>关注公众号「CoPaper.AI」</strong>
    </td>
  </tr>
</table>

内置 20 个方法论 Skills，20 分钟完成实证论文

<br/>

由 [CoPaper.AI](https://copaper.ai) 团队维护 | 实证研究 AI 助手

</div>

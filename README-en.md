# Awesome Agent Skills for Empirical Research

<div align="center">

**🌐 Language / 语言: English | [中文](README.md)**

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

**The Definitive Collection of AI Agent Skills for Empirical Research — 119 GitHub Repos / 23,000+ Skills**

> A curated, opinionated list of **119 GitHub repositories** and **23,000+ AI Agent Skills** for empirical research in economics, political science, sociology, psychology, public health, education, management, finance, and public policy — organized by research workflow, from topic selection to journal submission.

In 2026, the way we do empirical research is being redefined. [CoPaper.AI](https://copaper.ai) can **complete a publication-quality empirical paper in 20 minutes** — from data import, descriptive statistics, causal inference models, robustness checks to formatted result tables, all in one go. The secret isn't a more powerful model — it's **Skills**: encoding senior researchers' methodological expertise into structured workflows, so the AI knows "what a complete DID analysis should include" instead of waiting for you to remind it step by step.

This repository is the **Agent Skills landscape** we compiled while building CoPaper.AI. We organized hundreds of Skills repos and tens of thousands of Skills scattered across GitHub, communities, and academia by research workflow stages, so you can pick what you need.

> **[CoPaper.AI](https://copaper.ai)** ships with **20 built-in econometric methodology Skills** (DID, IV, RDD, PSM, DML, and more), supports one-sentence triggers, multi-agent collaboration, and automatic result output. Want it out of the box? Try it: [copaper.ai](https://copaper.ai)

---

## 🆕 Changelog

<details open>
<summary><b>2026-04-12: Added StatsPAI Agent-Native Econometrics Package + Anti-AIGC Detection Skills</b></summary>

- **🔥 [StatsPAI](https://github.com/brycewang-stanford/StatsPAI)**: Our own **agent-native causal inference & econometrics Python package**. 390+ functions, one `import`, self-describing API (`list_functions()` / `describe_function()` / `function_schema()`). Covers OLS, IV, DID (Callaway-Sant'Anna / Sun-Abraham / Bacon / HonestDID / continuous DID), RDD, PSM, SCM, DML, Causal Forest, Meta-Learners, TMLE, neural causal models (TARNet/CFRNet/DragonNet), and more. Published in JOSS, MIT license. [→ PyPI](https://pypi.org/project/StatsPAI/) | [→ GitHub](https://github.com/brycewang-stanford/StatsPAI)
- **📝 Anti-AIGC Detection Skills** (3 new, see [07-Paper Revision & Polishing](docs/07-论文修改与润色.md)):
  - [humanizer_academic](https://github.com/matsuikentaro1/humanizer_academic) — Academic paper specialist, 23 AI writing pattern detectors, adapted for medical/scientific papers
  - [skill-deslop](https://github.com/stephenturner/skill-deslop) — Scientific writing de-AI, respects discipline conventions (e.g., passive voice in methods sections)
  - [stop-slop](https://github.com/hardikpandya/stop-slop) — 3-layer detection + 5-dimension scoring (directness/rhythm/trust/authenticity/density), rewrite if below 35/50
- **🛡️ [revision-guard](https://github.com/ShiyanW/ai-revision-guard)**: Prevents AI over-refinement, limits revision rounds + 7-point homogenization checklist (community PR contribution)

</details>

<details>
<summary><b>2026-04-11: Expanded from 43 collections to 119 repos, covering 23,000+ Skills</b></summary>

- Added 76 GitHub repositories across 8 social science disciplines (economics, political science, sociology, psychology, education, public health, management, finance)
- Added skill suites for finance, law, marketing, product management, education, public health
- Added 13 academic data MCP servers (OpenAlex, Semantic Scholar, FRED, World Bank, etc.)
- Added 11 multi-agent collaboration systems (Agent Laboratory, AI-Scientist-v2, etc.)
- Added bilingual Chinese/English README

</details>

---

## Table of Contents

- [🆕 Changelog](#-changelog)
- [What Can This List Do for You?](#what-can-this-list-do-for-you)
- [Quick Lookup by Research Stage](#quick-lookup-by-research-stage)
- **Skills by Category**
  - [01 - Topic Selection & Research Design](docs/01-选题与研究设计.md)
  - [02 - Literature Search & Review](docs/02-文献检索与综述.md)
  - [03 - Paper Reading & Analysis](docs/03-论文阅读与拆解.md)
  - [04 - Data Collection & Cleaning](docs/04-数据获取与清洗.md)
  - [05 - Statistical Analysis & Causal Inference](docs/05-统计分析与因果推断.md)
  - [06 - Paper Writing](docs/06-论文写作.md)
  - [07 - Paper Revision & Polishing](docs/07-论文修改与润色.md)
  - [08 - Citation Management & Typesetting](docs/08-引用管理与排版.md)
  - [09 - Replication & Reproducible Research](docs/09-论文复现与可复现研究.md)
  - [10 - Peer Review Response & Defense](docs/10-审稿回复与学术答辩.md)
- [Comprehensive Skill Suites](#comprehensive-skill-suites)
- [Multi-Agent Collaboration Systems](#multi-agent-collaboration-systems)
- [Skill Aggregation Platforms & Discovery Tools](#skill-aggregation-platforms--discovery-tools)
- [Learning Resources](#learning-resources)
- [Contributing](#contributing)

---

## What Can This List Do for You?

If you do empirical research, you've probably experienced these scenarios:

- You ask AI to run a DID, and it gives you the baseline regression and stops. You say "parallel trends?" — it adds one. "Placebo test?" — another one. "Event study plot?" — yet another. **Every time, it's like squeezing toothpaste.**
- You finally finish a draft, but citations are a mess, with a few hallucinated references mixed in.
- You want to replicate an identification strategy from a top journal, but the gap between understanding it and implementing it feels like a mountain.

**The problem isn't that AI can't do it — it doesn't know what a complete workflow should include.**

A Skill solves this: it's a **methodological playbook for AI**. With a Skill, AI knows "running DID means first testing parallel trends, then baseline regression, then 4 robustness checks, then heterogeneity analysis, then mechanism analysis, with specific output formats at each step." You just say "run a DID analysis" and it follows the complete workflow.

This list helps you find the best Skills for every stage of the empirical research workflow.

---

## Quick Lookup by Research Stage

> Not sure which Skill to use? Start from your current research stage:

```
Topic Ideation → Lit Search → Deep Reading → Research Design → Data Collection
      │              │             │              │                │
      ▼              ▼             ▼              ▼                ▼
     01             02            03             01               04

Data Cleaning → Statistical Analysis → First Draft → Revision → Typesetting
      │              │                    │            │            │
      ▼              ▼                    ▼            ▼            ▼
     04             05                   06           07           08

Replication → Submission → Peer Review Response → Defense
      │           │              │                   │
      ▼           ▼              ▼                   ▼
     09          10             10                  10
```

### One-Stop Solutions

If you don't want to pick Skills one by one, these solutions cover the full workflow:

| Solution | Coverage | Highlights | Link |
|----------|----------|------------|------|
| **CoPaper.AI** | Data Analysis → Paper Writing | 20 built-in methodology Skills, multi-agent architecture, complete publication-quality empirical paper in 20 minutes | [copaper.ai](https://copaper.ai) |
| **StatsPAI** | Causal Inference & Econometrics | **390+ functions, one import**, agent-native API (self-describing schemas), covers OLS/IV/DID/RDD/PSM/SCM/DML/Causal Forest/neural causal models, publication-ready output (Word/Excel/LaTeX) | [GitHub](https://github.com/brycewang-stanford/StatsPAI) |
| **Claude Scholar** | Ideation → Submission | 25+ Skills covering the full research lifecycle, Zotero MCP integration | [GitHub](https://github.com/Galaxy-Dawn/claude-scholar) |
| **K-Dense Scientific Skills** | Cross-disciplinary Science | 140+ Skills, 28+ scientific databases, 55+ Python packages | [GitHub](https://github.com/K-Dense-AI/claude-scientific-skills) |
| **AI-Research-SKILLs** | AI/ML Research | 22 categories, 87 skills, full research cycle | [GitHub](https://github.com/Orchestra-Research/AI-Research-SKILLs) |
| **OpenClaw Medical Skills** | Biomedical/Public Health | **869 Skills**, epidemiology, clinical research, drug safety, biostatistics | [GitHub](https://github.com/FreedomIntelligence/OpenClaw-Medical-Skills) |
| **Agent Laboratory** | Fully Autonomous Research | Lit review → Experiments → Report, 84% reduction in research costs | [GitHub](https://github.com/SamuelSchmidgall/AgentLaboratory) |

---

## Comprehensive Skill Suites

These repositories contain multiple Skills and typically cover several research stages:

### Academic Research

| Suite | Stars | # Skills | Key Features | Social Science Fit |
|-------|-------|----------|-------------|-------------------|
| [K-Dense-AI/claude-scientific-skills](https://github.com/K-Dense-AI/claude-scientific-skills) | 8,799 | 140+ | 28+ scientific databases (OpenAlex, PubMed), scientific-writing + literature-review + statistical-analysis | ⭐⭐⭐⭐ |
| [Orchestra-Research/AI-Research-SKILLs](https://github.com/Orchestra-Research/AI-Research-SKILLs) | 3,637 | 87 | 22 categories, ML paper writing, LaTeX templates, citation verification | ⭐⭐⭐ |
| [Imbad0202/academic-research-skills](https://github.com/Imbad0202/academic-research-skills) | ~1,790 | Multiple | Full paper pipeline (research → write → review → revise → finalize), style calibration, hallucination detection | ⭐⭐⭐⭐ |
| [Galaxy-Dawn/claude-scholar](https://github.com/Galaxy-Dawn/claude-scholar) | - | 25+ | Full research lifecycle: ideation → review → experiments → writing → peer review response, Zotero MCP | ⭐⭐⭐⭐⭐ |
| [luwill/research-skills](https://github.com/luwill/research-skills) | 209 | 3 | Research proposal generation, medical review writing, paper-to-slides, bilingual | ⭐⭐⭐⭐⭐ |
| [lishix520/academic-paper-skills](https://github.com/lishix520/academic-paper-skills) | 22 | 2 | Strategist (7-dimension reviewer simulation) + Composer (systematic writing) | ⭐⭐⭐⭐ |
| [Data-Wise/claude-plugins](https://github.com/Data-Wise/claude-plugins) | - | 17 | Statistical research: arXiv search, DOI lookup, BibTeX management, methodology writing, referee response | ⭐⭐⭐⭐⭐ |

### Economics / Causal Inference

| Suite | Key Features | Use Case |
|-------|-------------|----------|
| **[CoPaper.AI](https://copaper.ai)** | **20 methodology Skills** (OLS, DID, staggered DID, IV, RDD, PSM, SCM, DML, causal forest, etc.), multi-agent architecture (Supervisor + 4 sub-agents), smart routing, automatic output | Full empirical economics workflow |
| **[StatsPAI](https://github.com/brycewang-stanford/StatsPAI)** 🔥 | **Agent-native econometrics Python package**: 390+ functions, self-describing API (`list_functions()` / `describe_function()` / `function_schema()`), unified `CausalResult` objects. Covers OLS, IV, panel data, DID (Callaway-Sant'Anna / Sun-Abraham / Bacon / HonestDID / continuous DID), RDD (Sharp/Fuzzy/multi-cutoff/Kink), PSM, SCM, SDID, DML, Causal Forest, Meta-Learners, TMLE, AIPW, neural causal models (TARNet/CFRNet/DragonNet), Heckman, structural estimation (BLP). **Published in JOSS, MIT license** | Full causal inference coverage, agent-driven analysis pipelines |
| [claesbackman/AI-research-feedback](https://github.com/claesbackman/AI-research-feedback) | 2-agent economics paper pre-review: causal overclaiming detection, identification strategy assessment; supports AER/QJE/JPE/Econometrica/REStud; 6-agent grant review | Pre-submission self-review, grant applications |
| [fuhaoda/stats-paper-writing-agent-skills](https://github.com/fuhaoda/stats-paper-writing-agent-skills) | LaTeX statistical paper writing, front-end draft generation | Statistics & econometrics papers |
| [dylantmoore/stata-skill](https://github.com/dylantmoore/stata-skill) | Full Stata coverage: syntax, data management, econometrics, causal inference, graphics, Mata, 20+ community packages | Stata users |
| [SepineTam/stata-mcp](https://github.com/SepineTam/stata-mcp) | LLM operates Stata regression directly via MCP, "evolve from regression monkey to causal thinker" | Stata econometrics |

### Finance & Investment Research

| Suite | Key Features | Use Case |
|-------|-------------|----------|
| [anthropics/financial-services-plugins](https://github.com/anthropics/financial-services-plugins) | Anthropic official: investment banking, equity research, private equity, wealth management | Financial services |
| [OctagonAI/skills](https://github.com/OctagonAI/skills) | Octagon agentic financial research Claude Skills | Institutional financial research |
| [tradermonty/claude-trading-skills](https://github.com/tradermonty/claude-trading-skills) | Stock investing & trading: market analysis, technical charts, economic calendar, strategy development | Quantitative trading research |
| [himself65/finance-skills](https://github.com/himself65/finance-skills) | Agent Skills open standard, earnings analysis, consensus estimates, analyst sentiment | Financial analysis |
| [quant-sentiment-ai/claude-equity-research](https://github.com/quant-sentiment-ai/claude-equity-research) | Institutional equity research: fundamental analysis, technical indicators, risk assessment | Equity research |

### Education & Public Health

| Suite | Key Features | Use Case |
|-------|-------------|----------|
| [GarethManning/claude-education-skills](https://github.com/GarethManning/claude-education-skills) | Evidence-based education Claude Skills, designed for teachers and agent orchestration | Education research |
| [FreedomIntelligence/OpenClaw-Medical-Skills](https://github.com/FreedomIntelligence/OpenClaw-Medical-Skills) | **869** medical AI Skills: epidemiology, public health surveillance, clinical research, drug safety, biostatistics | Public health, medical research |

### Governance, Compliance & Law

| Suite | Key Features | Use Case |
|-------|-------------|----------|
| [Sushegaad/Claude-Skills-Governance-Risk-and-Compliance](https://github.com/Sushegaad/Claude-Skills-Governance-Risk-and-Compliance) | GRC Skills: ISO 27001, SOC 2, GDPR, HIPAA compliance guidance (94% vs 72% baseline) | Compliance research, policy analysis |
| [zubair-trabzada/ai-legal-claude](https://github.com/zubair-trabzada/ai-legal-claude) | Legal assistant: contract review, risk analysis, NDA generation, compliance audit, 14 Skills + 5 agents | Law & economics, regulatory research |
| [evolsb/claude-legal-skill](https://github.com/evolsb/claude-legal-skill) | AI contract review: CUAD risk detection, market benchmarks, attorney-grade red-lining | Law & economics research |

### Marketing & Consumer Behavior

| Suite | Key Features | Use Case |
|-------|-------------|----------|
| [coreyhaines31/marketingskills](https://github.com/coreyhaines31/marketingskills) | CRO, copywriting, SEO, analytics, and growth engineering | Marketing research |
| [zubair-trabzada/ai-marketing-claude](https://github.com/zubair-trabzada/ai-marketing-claude) | 15 Skills + parallel sub-agents: website audit, copy, email sequences, competitive intelligence | Consumer behavior analysis |
| [ericosiu/ai-marketing-skills](https://github.com/ericosiu/ai-marketing-skills) | Growth experiments, sales pipeline, content operations, SEO, financial automation | Marketing strategy research |

### Product Management & Organizational Behavior

| Suite | Key Features | Use Case |
|-------|-------------|----------|
| [phuryn/pm-skills](https://github.com/phuryn/pm-skills) | 100+ agent Skills: discovery → strategy → execution → launch → growth, 65 PM Skills + 36 chained workflows | Product management, organizational research |
| [mastepanoski/claude-skills](https://github.com/mastepanoski/claude-skills) | UX/UI evaluation (Nielsen heuristics, WCAG), AI governance (NIST AI RMF, ISO 42001) | UX research |

### General Agent Capabilities

| Suite | Stars | Key Features |
|-------|-------|-------------|
| [lyndonkl/claude](https://github.com/lyndonkl/claude) | - | 85 skills + 6 orchestration agents, incl. causal inference, Bayesian reasoning, experimental design, multi-criteria analysis |
| [alirezarezvani/claude-skills](https://github.com/alirezarezvani/claude-skills) | ~5,200 | 220+ skills + 298 CLI scripts, incl. financial analysis and data processing |
| [rohitg00/awesome-claude-code-toolkit](https://github.com/rohitg00/awesome-claude-code-toolkit) | - | 135 agents incl. data scientist agent (EDA, DID, RDD), 35 skills, 42 commands |
| [jeremylongshore/claude-code-plugins-plus-skills](https://github.com/jeremylongshore/claude-code-plugins-plus-skills) | - | 340 plugins + **1,367 agent skills**, CCPI package manager |
| [affaan-m/everything-claude-code](https://github.com/affaan-m/everything-claude-code) | - | Skills, intuition, memory, security, research-first development framework |
| [posit-dev/skills](https://github.com/posit-dev/skills) | - | Posit official: modern-r-tidyverse, predictive-modeling, quarto-authoring, shiny-bslib |

---

## Multi-Agent Collaboration Systems

A single Skill solves a point problem; multi-agent systems solve **end-to-end workflows**. These systems let multiple AI roles divide work, cross-review, and produce output quality far beyond what a single agent can achieve:

### Paper Revision & Writing

| System | Architecture | Key Features |
|--------|-------------|-------------|
| **copy-edit-master** | 3 sub-agents: structure-editor + line-editor + quality-reviewer | Auto document type detection, Strunk & White / McCloskey rules encoded, git checkpoints per phase, review loop (max 2 iterations) |
| **introduction-writer** | 4 sub-agents: strategist → drafter → reviewer → reviser | Keith Head formula for drafting introductions, reviewer independent from drafter for quality loop |
| **CoPaper.AI PaperAgent** | Supervisor + 4 sub-agents (preparation / modeling / visualization / writing) | Skills routed by target_agent, each sub-agent sees only relevant methodology guidance, reduced context noise |

> **Why multi-agent beats single agent?** When the same agent writes and reviews, it tends to approve its own work. Role separation means the reviewer is independent from the drafter — forming a genuine quality loop. Same logic as academic peer review.

### Data Analysis & Research

| System | Source | Key Features |
|--------|--------|-------------|
| [ruc-datalab/DeepAnalyze](https://github.com/ruc-datalab/DeepAnalyze) | Renmin Univ. | Autonomous data analysis agent, raw data → professional report, CSV/Excel/JSON/DB support, open-source DeepAnalyze-8B |
| [business-science/ai-data-science-team](https://github.com/business-science/ai-data-science-team) | Business Science | Multi-agent data science team: EDA Agent + SQL Agent + MLflow Agent, LangChain integration |
| [HungHsunHan/claude-code-data-science-team](https://github.com/HungHsunHan/claude-code-data-science-team) | Community | Claude Code multi-agent data science team, auto cleaning → modeling → executable Notebook |
| [HKUDS/AI-Researcher](https://github.com/HKUDS/AI-Researcher) | HKU (NeurIPS 2025 Spotlight) | Fully autonomous research pipeline: lit review → hypothesis → algorithm → paper |
| [wanshuiyin/Auto-claude-code-research-in-sleep (ARIS)](https://github.com/wanshuiyin/Auto-claude-code-research-in-sleep) | Community | Overnight autonomous research, cross-model review loops (Claude + external LLM as critic) |
| [SamuelSchmidgall/AgentLaboratory](https://github.com/SamuelSchmidgall/AgentLaboratory) | Academic (ICLR) | End-to-end autonomous research: lit review → experiments → report, arXiv/HuggingFace/LaTeX integration, 84% cost reduction |
| [SakanaAI/AI-Scientist-v2](https://github.com/SakanaAI/AI-Scientist-v2) | Sakana AI | Fully automated scientific discovery: hypothesis → experiments → paper, first AI-generated paper accepted via peer review |
| [assafelovic/gpt-researcher](https://github.com/assafelovic/gpt-researcher) | Community | Autonomous deep research agent, supports any LLM provider |
| [LitLLM/LitLLM](https://github.com/LitLLM/LitLLM) | Academic | AI literature review assistant: keyword extraction + multi-strategy retrieval + re-ranking, RAG-based |
| [pedrohcgs/claude-code-my-workflow](https://github.com/pedrohcgs/claude-code-my-workflow) | Emory Univ. | Academic LaTeX/Beamer + R template, multi-agent review + quality gates, adopted by 15+ research groups |
| [hugosantanna/clo-author](https://github.com/hugosantanna/clo-author) | Community | Extends Sant'Anna's workflow from lecture production to full social science empirical research publication |

### Academic Data MCP Servers

| System | Key Features |
|--------|-------------|
| [xingyulu23/Academix](https://github.com/xingyulu23/Academix) | Unified academic research interface aggregating OpenAlex + DBLP + Semantic Scholar + arXiv + CrossRef |
| [Eclipse-Cj/paper-distill-mcp](https://github.com/Eclipse-Cj/paper-distill-mcp) | 11-source parallel search, 4-dimension weighted ranking (relevance/recency/impact/novelty) |
| [oksure/openalex-research-mcp](https://github.com/oksure/openalex-research-mcp) | OpenAlex API: search 240M+ academic works, citation analysis, trend tracking, collaboration networks |
| [zongmin-yu/semantic-scholar-fastmcp-mcp-server](https://github.com/zongmin-yu/semantic-scholar-fastmcp-mcp-server) | Full Semantic Scholar API access: papers, authors, citation networks |
| [openags/paper-search-mcp](https://github.com/openags/paper-search-mcp) | Search 20+ sources: arXiv, PubMed, bioRxiv, Google Scholar, SSRN, Unpaywall, etc. |
| [aringadre76/mcp-for-research](https://github.com/aringadre76/mcp-for-research) | Integrates PubMed + Google Scholar + ArXiv + JSTOR, published on NPM |
| [blazickjp/arxiv-mcp-server](https://github.com/blazickjp/arxiv-mcp-server) | arXiv paper search and analysis MCP |
| [lzinga/us-gov-open-data-mcp](https://github.com/lzinga/us-gov-open-data-mcp) | 40+ US government APIs (FRED/Census/CDC/FDA/FEC, etc.), 250+ tools |
| [stefanoamorelli/fred-mcp-server](https://github.com/stefanoamorelli/fred-mcp-server) | Direct access to FRED's 800K+ economic time series |
| [llnOrmll/world-bank-data-mcp](https://github.com/llnormll/world-bank-data-mcp) | World Bank Data360, 1000+ socioeconomic indicators, 200+ countries |
| [54yyyu/zotero-mcp](https://github.com/54yyyu/zotero-mcp) | Connect Zotero library with AI assistants: paper review, summaries, citation analysis, PDF annotation |
| [datagouv/datagouv-mcp](https://github.com/datagouv/datagouv-mcp) | French national open data platform MCP |

---

## Skill Aggregation Platforms & Discovery Tools

Don't know where to find Skills? These platforms are your starting point:

| Platform | Scale | Features |
|----------|-------|----------|
| [VoltAgent/awesome-agent-skills](https://github.com/VoltAgent/awesome-agent-skills) | 1,000+ skills | 13,700 stars, curated by official team and community |
| [sickn33/antigravity-awesome-skills](https://github.com/sickn33/antigravity-awesome-skills) | 1,340+ skills | 28,000 stars, one-click install `npx antigravity-awesome-skills` |
| [VoltAgent/awesome-openclaw-skills](https://github.com/VoltAgent/awesome-openclaw-skills) | **5,400+ skills** | Curated from OpenClaw registry (ClawHub 13,729 Skills) |
| [jeremylongshore/claude-code-plugins-plus-skills](https://github.com/jeremylongshore/claude-code-plugins-plus-skills) | 1,367 skills | 340 plugins + CCPI package manager |
| [skills.sh](https://skills.sh/) | Online market | Searchable Skill marketplace |
| [ClawHub (clawhub.com)](https://clawhub.com) | **13,729 skills** | Open-source AI skill marketplace, one-line install |
| [Agent Skills Standard](https://agentskills.io/) | Spec docs | Universal Agent Skills specification |
| [Anthropic Official Skills](https://github.com/anthropics/skills) | Official | PDF/DOCX/XLSX/PPTX document processing |
| [Anthropic Official Plugin Market](https://github.com/anthropics/claude-plugins-official) | Official | Anthropic-managed high-quality Claude Code plugin catalog |
| [Anthropic Knowledge Work Plugins](https://github.com/anthropics/knowledge-work-plugins) | Official | 11 plugins incl. Data Plugin (SQL queries, data exploration) |
| [Anthropic Financial Services Plugins](https://github.com/anthropics/financial-services-plugins) | Official | Financial services plugins: IB, equity research, PE, wealth mgmt |

---

## Learning Resources

### Official Documentation

- [Claude Code Skills Complete Guide](https://resources.anthropic.com/hubfs/The-Complete-Guide-to-Building-Skill-for-Claude.pdf) — Anthropic's official 32-page guide
- [Agent Skills Standard Specification](https://agentskills.io/)
- [Claude Code Official Docs](https://docs.anthropic.com/en/docs/agents-and-tools/agent-skills)

### Academic Talks & Courses

- [AI Agents for Economics Research](https://cepr.org/) — Aniket Panjwani, CEPR/VoxDev, 2026.03
- [Claude Code & Cowork for Academic Research — A Practical Guide](https://cornwl.github.io/files/claude-academic-guide.html) — Practical guide for economists and social scientists, 2026.02
- [Building Claude Code Workflow for Economics Scholars](https://zhiyuanryanchen.github.io/claude-code-workflow.html) — Building Claude Code workflows for economics researchers

### Causal Inference Textbooks

- [Causal Inference for the Brave and True](https://github.com/xieliaing/CausalInferenceIntro) — Chinese translation, Python code
- [Statistical Tools for Causal Inference](https://chabefer.github.io/STCI/) — Open-source textbook
- [Causal Inference and Machine Learning Book](https://www.causalmlbook.com/)

### Survey Papers & Awesome Lists

- [A Survey of Data Agents](https://github.com/HKUSTDial/awesome-data-agents) — Data agent survey (HKUST)
- [From AI for Science to Agentic Science](https://github.com/AgenticScience/Awesome-Agent-Scientists) — arXiv:2508.14111
- [From Automation to Autonomy](https://github.com/HKUST-KnowComp/Awesome-LLM-Scientific-Discovery) — LLM scientific discovery survey (EMNLP 2025)
- [Awesome Agents for Science](https://github.com/OSU-NLP-Group/awesome-agents4science) — Papers on LLMs and agents in scientific R&D
- [Awesome AI for Science](https://github.com/ai-boost/awesome-ai-for-science) — AI tools, papers, datasets for accelerating scientific discovery
- [Awesome AI for Economists](https://github.com/hanlulong/awesome-ai-for-economists) — AI tools, libraries, and resources for economics (OpenEcon team)
- [Awesome Econ AI Stuff](https://github.com/meleantonio/awesome-econ-ai-stuff) — AI Skills collection for economists, follows SKILL.md standard
- [AI for Grant Writing](https://github.com/eseckel/ai-for-grant-writing) — Curated resources for LLM-assisted grant writing
- [Awesome AI Scientist Papers](https://github.com/openags/Awesome-AI-Scientist-Papers) — AI scientist / robot scientist papers
- [FreedomIntelligence/OpenClaw-Medical-Skills](https://github.com/FreedomIntelligence/OpenClaw-Medical-Skills) — **869** medical AI Skills, covering epidemiology, public health, biostatistics

### Community & References

- [Awesome Claude Skills](https://github.com/travisvn/awesome-claude-skills) — Community curated
- [Awesome Claude Skills (ComposioHQ)](https://github.com/ComposioHQ/awesome-claude-skills) — Curated Claude Skills list
- [Awesome Claude Skills (BehiSecc)](https://github.com/BehiSecc/awesome-claude-skills) — Curated Claude Skills list
- [Awesome Claude Code](https://github.com/hesreallyhim/awesome-claude-code) — Skills, Hooks, slash commands, agent orchestrators
- [Reddit r/ClaudeCode](https://www.reddit.com/r/ClaudeCode/)
- [Anthropic Claude Code Skills Cookbook](https://github.com/anthropics/claude-cookbooks/blob/main/skills/notebooks/02_skills_financial_applications.ipynb) — Financial applications Skills tutorial

---

## Contributing

Contributions welcome! Please read [CONTRIBUTING.md](CONTRIBUTING.md) to learn how to submit new Skill recommendations.

We especially welcome:
- Skills for social science disciplines: economics, political science, sociology, psychology, education, public administration, public health
- New Skill implementations for causal inference methods
- Skills for business disciplines: finance, management, marketing, law & economics
- General academic Skills: literature review, grant writing, research proposals
- MCP servers (academic databases, government data APIs)
- Chinese-friendly Skills
- Multi-agent collaboration system case studies

---

## Star History

If this list helps you, please give it a Star so more researchers can find it.

---

<div align="center">

**AI is an amplifier, not a replacement. It handles the heavy lifting; you keep the core judgment.**

<br/>

<a href="https://copaper.ai">
  <img src="images/copaper-logo.png" alt="CoPaper.AI" width="240" />
</a>

<br/>

<table>
  <tr>
    <td align="center">
      <a href="https://copaper.ai"><img src="images/copaper-qrcode.png" alt="Visit copaper.ai" width="180" /></a><br/>
      <strong>Visit <a href="https://copaper.ai">copaper.ai</a></strong>
    </td>
    <td align="center">
      <img src="images/copaper-wechat.jpg" alt="CoPaper.AI WeChat" width="180" /><br/>
      <strong>WeChat: CoPaper.AI</strong>
    </td>
  </tr>
</table>

20 built-in methodology Skills, complete an empirical paper in 20 minutes

<br/>

Maintained by [CoPaper.AI](https://copaper.ai) | AI Assistant for Empirical Research

</div>

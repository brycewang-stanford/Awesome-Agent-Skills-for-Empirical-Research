<div align="center">

<img src="assets/logo.png" width="160" alt="科研龙虾 · Research-Claw" />

# 最全的学术科研领域技能插件库

**科研龙虾的大脑 — 438 个学术技能 + 34 个 API 工具**

为 [Research-Claw (科研龙虾)](https://github.com/wentorai/Research-Claw) 及 40+ AI Agent 框架提供即插即用的科研能力

[![npm](https://img.shields.io/npm/v/@wentorai/research-plugins?style=flat-square&color=EF4444&logo=npm)](https://www.npmjs.com/package/@wentorai/research-plugins)
[![License](https://img.shields.io/badge/license-MIT-3B82F6?style=flat-square)](LICENSE)
[![Skills](https://img.shields.io/badge/skills-438-EF4444?style=flat-square)](https://www.npmjs.com/package/@wentorai/research-plugins)
[![Tools](https://img.shields.io/badge/API_tools-34-3B82F6?style=flat-square)](#智能体工具34-个)

[🌐 wentor.ai](https://wentor.ai) · [🇬🇧 English](README.en.md) · [🦞 Research-Claw](https://github.com/wentorai/Research-Claw) · [🪲 Issues](https://github.com/wentorai/research-plugins/issues)

</div>

---

## 快速开始

### 安装（Research-Claw / OpenClaw 用户）

```bash
openclaw plugins install @wentorai/research-plugins
```

插件安装到 `~/.openclaw/extensions/`，重启 gateway 后自动加载所有技能 + 工具。

### 安装（Claude Code / Cursor / Windsurf / OpenCode 用户）

```bash
npx skills add wentorai/research-plugins
```

> 此方式仅安装 SKILL.md 技能文件（无 API 工具），适用于 41 个支持 skills 协议的 Agent 框架。

### 卸载

```bash
# OpenClaw / Research-Claw — 手动删除插件目录
rm -rf ~/.openclaw/extensions/research-plugins

# npx skills — 手动删除技能目录
rm -rf .skills/wentorai/research-plugins
```

> **pnpm 项目注意**：请勿将本包作为 `pnpm` 依赖并通过 `plugins.load.paths` 从 `node_modules` 加载。pnpm 的硬链接机制会被 OpenClaw 安全校验拒绝 (`unsafe plugin manifest path`)。请始终使用 `openclaw plugins install`。

---

## 包含什么

### 学术技能（438 个）

覆盖科研全流程的结构化 SKILL.md 指南，按需自动加载：

| 类别 | 技能数 | 覆盖范围 |
|:--|:--|:--|
| **文献** (literature) | 87 | 多库联搜 · 引文追踪 · 全文获取 · 开放获取 |
| **研究方法** (research) | 79 | DID · RDD · IV · 元分析 · 系统综述 · 基金申请 |
| **数据分析** (analysis) | 68 | Python · R · STATA · 可视化 · 面板数据 · 计量经济 |
| **学术写作** (writing) | 74 | 论文各章节 · LaTeX · 参考文献 · 审稿意见回复 |
| **学科领域** (domains) | 93 | 16 个学科：CS · AI/ML · 生物医学 · 经济 · 法学 · 物理 等 |
| **效率工具** (tools) | 51 | 流程图 · PDF 解析 · 知识图谱 · OCR · 爬虫 |

技能通过 **渐进式加载** 机制工作：6 个类别入口 → 40 个子分类索引 → 438 个具体技能。Agent 按需加载，不会一次性注入全部内容。

### 智能体工具（34 个）

直连 18 个免费学术数据库 API 的 TypeScript 工具，作为 OpenClaw 插件自动注册：

| 模块 | 工具 | 数据源 |
|:--|:--|:--|
| `openalex` | `search_openalex` · `get_work` · `get_author_openalex` | OpenAlex (250M+ 作品) |
| `crossref` | `resolve_doi` · `search_crossref` | CrossRef (150M+ DOI) |
| `arxiv` | `search_arxiv` · `get_arxiv_paper` | arXiv |
| `pubmed` | `search_pubmed` · `get_article` | PubMed / NCBI |
| `unpaywall` | `find_oa_version` | Unpaywall (开放获取) |
| `europe-pmc` | `search_europe_pmc` · `get_epmc_citations` · `get_epmc_references` | Europe PMC (33M+) |
| `opencitations` | `get_citations_open` · `get_references_open` · `get_citation_count` | OpenCitations (2B+ 引用) |
| `dblp` | `search_dblp` · `search_dblp_author` | DBLP (7M+ CS 文献) |
| `doaj` | `search_doaj` | DOAJ (9M+ OA 文章) |
| `biorxiv` | `search_biorxiv` · `search_medrxiv` · `get_preprint_by_doi` | bioRxiv / medRxiv |
| `openaire` | `search_openaire` | OpenAIRE (170M+, EU 资助筛选) |
| `zenodo` | `search_zenodo` · `get_zenodo_record` | Zenodo |
| `orcid` | `search_orcid` · `get_orcid_works` | ORCID |
| `inspire-hep` | `search_inspire` · `get_inspire_paper` | INSPIRE-HEP (高能物理) |
| `hal` | `search_hal` | HAL (法国开放档案) |
| `osf-preprints` | `search_osf_preprints` | OSF Preprints |
| `datacite` | `search_datacite` · `resolve_datacite_doi` | DataCite (数据集 DOI) |
| `ror` | `search_ror` | ROR (研究机构) |

### 精选资源（6 套）

每个技能类别附带一套手工精选的优质资源列表，见 `curated/` 目录。

---

## 架构

```
@wentorai/research-plugins
├── skills/                    ← 438 SKILL.md (6 类别 × 40 子分类)
│   ├── literature/            ← 文献检索/追踪/获取
│   ├── writing/               ← 学术写作/引用/LaTeX
│   ├── analysis/              ← 数据分析/统计/可视化
│   ├── research/              ← 研究方法/综述/基金
│   ├── domains/               ← 16 学科领域
│   └── tools/                 ← 效率工具/图表/OCR
├── src/tools/                 ← 34 API 工具 (18 模块)
├── curated/                   ← 6 套精选资源列表
├── catalog.json               ← 全量索引 (462 entries)
├── index.ts                   ← 插件入口 (OpenClaw Plugin SDK)
└── openclaw.plugin.json       ← 插件清单
```

**加载方式**：
- **Research-Claw / OpenClaw**：作为完整插件加载（技能 + API 工具），通过 `openclaw plugins install`
- **其他 Agent 框架**：仅加载 SKILL.md 文件（无 API 工具），通过 `npx skills add`

---

## 社区致谢

本项目对互联网上公开可用的学术资源进行了遴选、整理和增强。

- **技能** 基于成熟研究方法、公开 API 文档和广泛使用的学术工作流编写。凡内容源自特定开源项目的，SKILL.md frontmatter 中 `source` 字段标注了原始链接。
- **精选列表** 汇集社区资源链接，仅供发现和参考。

所有原创内容以 [MIT 许可证](LICENSE) 发布。引用的第三方项目保留各自许可证。

---

## 贡献

请查阅 [CONTRIBUTING.md](CONTRIBUTING.md) 了解添加技能和资源的指南。

## 许可证

[MIT](LICENSE) — Copyright (c) 2026 Wentor AI

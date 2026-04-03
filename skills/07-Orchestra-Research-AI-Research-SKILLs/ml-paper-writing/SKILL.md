<!--
  ╔══════════════════════════════════════════════════════════════╗
  ║  本文件为开源 Skill 原始文档，收录仅供学习与研究参考        ║
  ║  CoPaper.AI 收集整理 | https://copaper.ai                  ║
  ╚══════════════════════════════════════════════════════════════╝

  来源仓库: https://github.com/Orchestra-Research/AI-Research-SKILLs
  项目名称: AI-Research-SKILLs
  开源协议: Apache License 2.0
  收录日期: 2026-04-02

  声明: 本文件版权归原作者所有。此处收录旨在为社会科学实证研究者
  提供 AI Agent Skills 的集中参考。如有侵权，请联系删除。
-->

---
name: ml-paper-writing
description: Write publication-ready ML/AI/Systems papers for NeurIPS, ICML, ICLR, ACL, AAAI, COLM, OSDI, NSDI, ASPLOS, SOSP. Use when drafting papers from research repos, structuring arguments, verifying citations, or preparing camera-ready submissions. Includes LaTeX templates, reviewer guidelines, and citation verification workflows.
version: 1.1.0
author: Orchestra Research
license: MIT
tags: [Academic Writing, NeurIPS, ICML, ICLR, ACL, AAAI, COLM, OSDI, NSDI, ASPLOS, SOSP, LaTeX, Paper Writing, Citations, Research, Systems]
dependencies: [semanticscholar, arxiv, habanero, requests]
---

# ML Paper Writing for Top AI & Systems Conferences

Expert-level guidance for writing publication-ready papers targeting **NeurIPS, ICML, ICLR, ACL, AAAI, COLM** (ML/AI venues) and **OSDI, NSDI, ASPLOS, SOSP** (Systems venues). This skill combines writing philosophy from top researchers (Nanda, Farquhar, Karpathy, Lipton, Steinhardt) with practical tools: LaTeX templates, citation verification APIs, and conference checklists.

## Core Philosophy: Collaborative Writing

**Paper writing is collaborative, but Claude should be proactive in delivering drafts.**

The typical workflow starts with a research repository containing code, results, and experimental artifacts. Claude's role is to:

1. **Understand the project** by exploring the repo, results, and existing documentation
2. **Deliver a complete first draft** when confident about the contribution
3. **Search literature** using web search and APIs to find relevant citations
4. **Refine through feedback cycles** when the scientist provides input
5. **Ask for clarification** only when genuinely uncertain about key decisions

**Key Principle**: Be proactive. If the repo and results are clear, deliver a full draft. Don't block waiting for feedback on every section—scientists are busy. Produce something concrete they can react to, then iterate based on their response.

---

## ⚠️ CRITICAL: Never Hallucinate Citations

**This is the most important rule in academic writing with AI assistance.**

### The Problem
AI-generated citations have a **~40% error rate**. Hallucinated references—papers that don't exist, wrong authors, incorrect years, fabricated DOIs—are a serious form of academic misconduct that can result in desk rejection or retraction.

### The Rule
**NEVER generate BibTeX entries from memory. ALWAYS fetch programmatically.**

| Action | ✅ Correct | ❌ Wrong |
|--------|-----------|----------|
| Adding a citation | Search API → verify → fetch BibTeX | Write BibTeX from memory |
| Uncertain about a paper | Mark as `[CITATION NEEDED]` | Guess the reference |
| Can't find exact paper | Note: "placeholder - verify" | Invent similar-sounding paper |

### When You Can't Verify a Citation

If you cannot programmatically verify a citation, you MUST:

```latex
% EXPLICIT PLACEHOLDER - requires human verification

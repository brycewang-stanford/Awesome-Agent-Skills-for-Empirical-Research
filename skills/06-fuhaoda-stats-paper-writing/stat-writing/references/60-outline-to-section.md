<!--
  ╔══════════════════════════════════════════════════════════════╗
  ║  本文件为开源 Skill 原始文档，收录仅供学习与研究参考        ║
  ║  CoPaper.AI 收集整理 | https://copaper.ai                  ║
  ╚══════════════════════════════════════════════════════════════╝

  来源仓库: https://github.com/fuhaoda/stats-paper-writing-agent-skills
  项目名称: stats-paper-writing-agent-skills
  开源协议: MIT License
  收录日期: 2026-04-02

  声明: 本文件版权归原作者所有。此处收录旨在为社会科学实证研究者
  提供 AI Agent Skills 的集中参考。如有侵权，请联系删除。
-->

# Outline → full section drafting

## Goal
Turn a bullet outline into fluent LaTeX prose that follows statistical-writing norms.

## Ground rules
- Do **not** invent results, data details, or citations.
- If needed, insert `	odo{...}` placeholders.
- Keep notation light unless the outline includes it.

## Workflow
1. **Identify section type** (Intro/Data/Methods/Simulation/Results/Discussion). This determines expected elements.
2. **Convert each bullet group to a paragraph**
   - one main idea per paragraph
   - topic sentence first
   - add a transition sentence to connect to the previous paragraph
3. **Add missing “expected elements”** using placeholders
   - Methods: estimand, assumptions, inference
   - Simulation: ADEMP fields
   - Results: narrative interpretation of tables/figures
4. **Second pass: polish**
   - tighten sentences
   - check tense
   - ensure figure/table references use `~ef{}`

## Micro-templates

### Methods section skeleton
1. Overview paragraph: what the method does and why.
2. Notation + data structure.
3. Model/estimand.
4. Estimation procedure.
5. Inference/uncertainty.

### Simulation section skeleton (ADEMP)
- Aim
- Data generating mechanism
- Estimand
- Methods compared
- Performance measures

### Results section skeleton
- Restate analysis goal.
- Present key figure/table with interpretation.
- Summarize what is robust / sensitive.

## Output format
Return a LaTeX-ready `\section{...}` or `\subsection{...}` block.

If the user gave only a partial outline, explicitly state what information is missing and leave `	odo{...}` placeholders.

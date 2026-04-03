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

# Introduction guidance

## Core job of the Introduction
A strong Introduction should answer (explicitly or implicitly):
1) **Why does this matter?**
2) **What has already been done?**
3) **What is new here?**

Then it should end with a **roadmap**.

## Recommended structure (5–8 paragraphs)
1. **Context + importance**: broad to narrow.
2. **Problem statement**: what is hard/unsolved.
3–4. **Related work** grouped by theme (not a laundry list).
5. **Gap/limitation** in existing work.
6. **Contributions**: make them explicit (often as bullet-like sentences embedded in text).
7. **Roadmap**: one sentence per major section.

## How to write contributions clearly
Write 3–6 contributions, each starting with a verb:
- “We propose …”
- “We establish …”
- “We provide …”
- “We demonstrate …”

Avoid vague claims like “We improve performance” without specifying **relative to what** and **how**.

## Literature framing tips
- Group prior work by approach/assumptions/application.
- Explain relationships: “X handles … but assumes …; Y relaxes … but …”
- Cite **old + recent** work to show awareness.

## Roadmap template (LaTeX-ready)
A common final paragraph:

> “Section~ef{sec:data} describes the data … Section~ef{sec:methods} presents the methodology … Section~ef{sec:sim} reports simulations … Section~ef{sec:disc} concludes.”

## Common reviewer complaints (and fixes)
- **“No clear contribution.”** → Add an explicit contributions paragraph.
- **“Motivation unclear.”** → Strengthen the importance + gap paragraphs.
- **“Related work is a list.”** → Reorganize by themes and contrast approaches.
- **“No roadmap.”** → Add a roadmap paragraph.

## Output expectations
If rewriting:
- Provide a short bullet “what changed” summary.
- Return the revised Introduction in LaTeX.

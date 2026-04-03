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

# English usage pitfalls (common in statistical writing)

## Tense
- Use **present tense** for general statements and paper structure (“Section 2 describes …”).
- Use **past tense** for what you did (data collection, experiments) (“We collected …”, “We simulated …”).

## “significant”
Use “(statistically) significant” only when you mean statistical significance.
If you mean “large/important”, consider:
- substantial, pronounced, considerable, meaningful (context-dependent)

## “data”
In many scientific styles, “data” is treated as plural:
- “the data are …”, “these data show …”

## Clarity
- Prefer active voice when it improves clarity.
- Avoid long noun stacks (“high-dimensional sparse penalized regression estimator ...”).
- Define acronyms once, then reuse.

## Script check
`scripts/check_tex.py` flags:
- “data is/was/has”
- “significant” without “statistically” nearby

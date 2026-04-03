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

# Application / Results section guidance

## Goal
Tell the reader what the data analysis shows and how it answers the substantive question.

## Minimum checklist
1. Restate the analysis goal and how the methods connect to it.
2. Describe preprocessing / model fitting choices (briefly, with pointers to Methods).
3. Present results via a small number of well-designed tables/figures.
4. For each table/figure:
   - explicitly refer to it in the text,
   - summarise the *main trend* (do not just say “see Table 1”),
   - interpret the results in the domain context.
5. Include sensitivity checks if appropriate.

## Figure/table integration rules
- Every figure/table should be **mentioned and contextualised** in the text.
- Captions should be reasonably self-contained.
- Use non-breaking spaces: `Figure~ef{fig:...}`.

## Common pitfalls
- Dumping results without narrative.
- Over-interpreting noisy effects.
- Using a table where a plot would communicate better (or vice versa).

## Output format hints
- Prefer a “big-picture then details” flow.
- If venue is applied: focus on interpretation, not derivations.

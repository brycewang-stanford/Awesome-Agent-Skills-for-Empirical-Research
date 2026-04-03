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

# Data section guidance

## Goal
Describe the data well enough that a reader understands:
- where the data came from,
- what population/time period it covers,
- what variables/outcomes are used,
- what preprocessing was done,
- and why the data are appropriate for the research question.

## Minimum contents checklist
1. **Source**: dataset name, owner, collection mechanism.
2. **Units and sample size**: number of subjects/rows/events, inclusion/exclusion criteria.
3. **Time/space coverage**: dates, geography, follow-up time.
4. **Outcomes and covariates**: define key variables.
5. **Missingness and filtering**: how much missing data, how handled.
6. **Ethics**: IRB/consent/de-identification if relevant.
7. **Exploratory summary**: key summary stats/plots that motivate the modeling.

## Writing tips
- Use **past tense** for data collection (what you did), present tense for general facts.
- Prefer a small number of informative figures/tables over long prose lists.
- If you transform variables, state the transformation and rationale.

## Output format hints (LaTeX)
- Use `\subsection{Data}` (or template section).
- Reference figures/tables in text (e.g., `Figure~ef{fig:eda}`).

## Placeholders (if info missing)
If some details are unknown, insert:
- `	odo{report sample size}`
- `	odo{describe inclusion criteria}`

Never invent data details.

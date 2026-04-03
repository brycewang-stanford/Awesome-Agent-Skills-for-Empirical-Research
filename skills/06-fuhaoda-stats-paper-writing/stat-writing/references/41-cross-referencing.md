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

# Labels and cross-referencing guidance

## Label conventions

Use prefix conventions consistently:

- `sec:` for sections
- `fig:` for figures
- `tab:` for tables
- `eq:` for equations
- `alg:` for algorithms
- `app:` for appendix items

Examples:

- `\label{sec:methods}`
- `\label{fig:simulation-rmse}`

## Placement rules

- Put `\label{...}` after `\caption{...}` for figures/tables.
- Keep labels unique across the project.

## Referencing in prose

- Use `Figure~\ref{fig:...}`, `Table~\ref{tab:...}`, `Section~\ref{sec:...}`.
- Use `\eqref{eq:...}` for equations.
- Avoid hard-coded references like "Figure 2" or "Table 3".

## Review-time checks

- Undefined references.
- Duplicate labels.
- Defined-but-unused labels.
- Prefix convention violations.

## Script

`python scripts/check_tex.py path/to/main.tex` flags these issues.

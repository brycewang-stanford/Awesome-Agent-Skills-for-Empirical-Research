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

# Methods section guidance

## Goal
A strong Methods section lets a reader understand **what is being estimated**, **under what assumptions**, **how it is estimated**, and **how uncertainty is quantified**.

## Principle: intuition before notation
Start with a plain-language overview (what the method does, what problem it solves) before introducing full notation.

## Minimum elements checklist
1. **Problem setup & estimand**
   - Define the target quantity (estimand) in words.
2. **Assumptions**
   - State modeling or identification assumptions explicitly.
3. **Notation**
   - Define symbols once, keep consistent.
4. **Model / procedure**
   - Specify the model or algorithm steps.
5. **Inference / uncertainty**
   - Standard errors, confidence intervals, tests, or posterior summaries.
6. **Tuning / implementation details**
   - Only what is necessary to reproduce.

## Suggested paragraph outline
1. High-level method summary.
2. Notation and data structure.
3. Model/estimand.
4. Estimation procedure.
5. Uncertainty + inference.
6. Practical notes (computation, hyperparameters, diagnostics).

## Writing tips
- Keep each paragraph focused on one idea.
- If you introduce new notation, define it immediately.
- If you compare to existing methods, explicitly state what differs.

## Output format tips (LaTeX)
- Use `\subsection{Method}` etc.
- Put long derivations in an appendix.

## Placeholders
- `	odo{define estimand}`
- `	odo{state assumptions}`
- `	odo{add algorithm pseudo-code}`

Never invent theoretical guarantees.

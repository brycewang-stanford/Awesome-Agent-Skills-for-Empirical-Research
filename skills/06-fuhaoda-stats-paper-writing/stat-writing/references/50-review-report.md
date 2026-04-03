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

# Writing a peer review / referee report

## Goal
A strong referee report helps the editor make a decision and helps authors improve the manuscript.

The report should be specific, constructive, professional, and actionable.

## Recommended structure

1. **Summary paragraph**
   - Paper topic and claimed contributions.
   - Evidence type (theory, simulation, application, software).

2. **Overall assessment paragraph**
   - Strengths.
   - Main weaknesses.
   - Suitability for the target journal.

3. **Major comments (numbered)**
   - For each issue: what is wrong, why it matters, what to fix.

4. **Minor comments (numbered)**
   - Presentation, language, missing references, notation cleanups, typo-level issues.

5. **Optional confidential note to editor**
   - Decision recommendation and context not intended for authors.

## Major-comment checklist for statistical papers

- Is the motivation clear and important?
- Is the literature review complete and fairly positioned?
- Are contributions explicit and defensible?
- Is the estimand clear?
- Are assumptions stated and justified?
- Are competing methods compared fairly?
- If simulations exist, is ADEMP coverage adequate?
- Are results interpreted, not just displayed?
- Are references and cross-references clean?
- Is reproducibility support adequate (code/data/supplement where possible)?

## Tone rules

- Keep language neutral and professional.
- Avoid sarcasm or dismissive wording.
- Even if recommending rejection, provide constructive next steps.

## Practical style rules

- Number every comment.
- Prefer concrete references to section/page/line locations.
- Group related concerns together instead of scattering them.

## Templates

- Markdown template: `assets/reviewer-report-template.md`
- LaTeX template: `assets/reviewer-report-template.tex`

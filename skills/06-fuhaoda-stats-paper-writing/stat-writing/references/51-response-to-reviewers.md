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

# Response to reviewers (point-by-point)

## Non-negotiables

1. Start with an overview of major changes.
2. Respond to every comment.
3. Quote each reviewer/editor comment before the response.
4. Keep tone calm and professional.
5. Accept responsibility for unclear writing.
6. Quote manuscript revisions directly.
7. Provide change locations (section/page/line when available).

## Recommended structure

- Header: manuscript title, ID, decision type, date.
- Overview of major revisions.
- Section for Editor comments.
- Section for Associate Editor comments (if present).
- Section(s) for Reviewer 1, Reviewer 2, etc.
- Within each section: numbered comment-response units.

## Comment-response unit

### Markdown pattern

```md
**Reviewer 1, Comment 1.2**
> (verbatim comment)

**Response:** ...

**Change in manuscript (quoted):**
> "..."

**Location:** Section X, page Y, lines Z1-Z2
```

### LaTeX template

Use `assets/response-letter-template.tex` for a submission-ready PDF letter.

## How to disagree politely

1. Acknowledge the concern.
2. State why you disagree with evidence.
3. Offer a compromise (clarification, sensitivity check, added citation, limitation statement).

## Common failure modes

- Missing a sub-question inside a multi-part comment.
- No quoted revised text.
- Defensive tone.
- Vague locations like "we changed it above".

## JDS-aligned reminders

- Mention reproducibility-related changes explicitly (code, data, supplement).
- If no fix is possible, state limitation and future work clearly.

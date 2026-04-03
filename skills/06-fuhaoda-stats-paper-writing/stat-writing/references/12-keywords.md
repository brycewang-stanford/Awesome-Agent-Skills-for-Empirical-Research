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

# Keywords guidance

## Purpose
Keywords exist to improve **discoverability**: they help the right readers find your paper in search engines and databases.

## Rules of thumb
- Prefer **6–10** keywords unless the venue specifies otherwise.
- Do **not** repeat the exact words already in the title (unless unavoidable).
- Sort keywords **alphabetically** (case‑insensitive) unless the venue says otherwise.
- Use **standard, widely-used terms**; avoid idiosyncratic phrases.

## What to include
Mix three types:
1. **Methodology** (e.g., “Bayesian inference”, “regularization”)
2. **Model/setting** (e.g., “generalized linear models”, “high-dimensional data”)
3. **Application/domain/task** (e.g., “electronic health records”, “causal inference”)

If the paper is applied, include at least 1–3 domain keywords.

## Practical checklist
- [ ] 6–10 items
- [ ] Alphabetical
- [ ] Not identical to title terms
- [ ] Covers methods + setting + task/domain

## Output format (LaTeX)
Return:
```tex
\keywords{keyword 1; keyword 2; ...}
```
(If your template uses commas instead of semicolons, match the template.)

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

# Book manuscript workflow (LaTeX)

## Goal

Turn a chapter plan into a maintainable book manuscript structure with frontmatter, mainmatter, and backmatter.

## Starter asset

Use:

- `assets/book-manuscript-template.tex`

This template is generic by default and includes an optional block for custom notation.

## Recommended workflow

1. Define audience, level, and chapter learning goals.
2. Build frontmatter (title page, preface, table of contents).
3. Draft chapter skeletons with one clear objective each.
4. Add figures/tables and cross-references.
5. Add bibliography strategy (single global `.bib` or chapter-level approach).
6. Finalize backmatter (appendix, references, index notes if needed).

## Chapter drafting checklist

- Chapter objective stated at the top.
- Consistent notation across chapters.
- Minimal forward references to unpublished chapters.
- End each chapter with a short summary and optional exercises.

## Suggested folder strategy

- `chapters/` for chapter files.
- `sections/` for reusable section fragments.
- `figures/` for graphics.
- `bib/` for bibliography files.
- `styles/` for custom style files.

## Optional custom notation block

If the user has house notation, add it as a dedicated block in the preamble.
Keep it separated from standard packages so it can be switched on/off easily.

## Guardrails

- Do not invent references or historical claims.
- Mark missing content with `\todo{...}`.
- Keep chapter order and naming stable once cross-references are in place.

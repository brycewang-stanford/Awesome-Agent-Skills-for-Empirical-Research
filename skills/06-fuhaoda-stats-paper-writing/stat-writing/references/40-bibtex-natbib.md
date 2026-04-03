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

# BibTeX, natbib, and compilation workflow

## Citation commands (natbib)

- `\citep{KEY}`: parenthetical citation.
- `\citet{KEY}`: textual citation.
- `\citep[see][p.~26]{KEY}`: citation with notes.

Use citation commands consistently. Do not manually type author-year text.

## Build order

- Recommended: `latexmk -pdf main.tex`
- Manual sequence: `pdflatex -> bibtex -> pdflatex -> pdflatex`

## BibTeX hygiene checklist

- Stable key naming convention.
- No duplicate keys.
- Protect capitalization with braces for acronyms/proper nouns.
- Use page ranges with double dash (`110--118`).
- Fill required fields by type (`@article` volume/pages; `@book` publisher/address when style requires).
- Avoid literal `et al.` in author fields.
- Avoid duplicate DOI values across unrelated entries.

## JDS-aligned checklist

- Clean and minimal bibliography with only cited references.
- No noisy or malformed entries in submitted `.bib`.
- Ensure references can compile without manual edits.

## Script

Run:

```bash
python scripts/check_bib.py --tex main.tex --bib refs.bib
```

The script reports missing citations, unused entries, and hygiene warnings.

## Guardrail

Never invent citations. If a citation is needed but unknown, use `\todo{add citation}`.

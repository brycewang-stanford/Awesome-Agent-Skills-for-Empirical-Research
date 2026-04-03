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

# Tooling for statistical paper workflows

## Build and compile

Preferred command:

```bash
latexmk -pdf main.tex
```

Optional Makefile:

```make
paper:
	latexmk -pdf main.tex
clean:
	latexmk -C
```

## Review-ready manuscript checks

Before submission or revision:

- Enable line numbers in review draft.
- Ensure figures are vector when appropriate.
- Verify all labels/refs compile cleanly.
- Verify bibliography compiles cleanly.

## Reproducibility expectations

- Include code and data availability statement when possible.
- Provide supplement or repository instructions.
- Record random seeds and environment assumptions.
- Keep figure/table generation scripts versioned.

## Version control

- Use git from the start.
- Commit in small, meaningful units.
- Tag submission and revision states.

## Skill scripts

This skill includes:

- `scripts/check_tex.py` for manuscript heuristics.
- `scripts/check_bib.py` for citation/BibTeX consistency.
- `scripts/audit_paper.py` for combined audit.

Suggested run:

```bash
python scripts/audit_paper.py --tex main.tex --bib refs.bib
```

Fix HIGH findings first, then MED, then LOW.

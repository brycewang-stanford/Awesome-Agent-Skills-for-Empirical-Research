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

# Statistical Writing Workbench (One Skill)

This repository ships one skill, `stat-writing`, for statistical writing in LaTeX.

It supports:

1. Front matter drafting (title, abstract, keywords)
2. Manuscript audits (structure, refs, notation, reproducibility cues)
3. Reviewer report drafting
4. Point-by-point response letters
5. Outline-to-section expansion
6. Book manuscript scaffolding

The skill is journal-agnostic by default, with an optional JDS-aligned profile for review-readiness checks.

## Repository structure

```
skills/
  stat-writing/
    SKILL.md
    references/
    scripts/
    assets/
docs/
  USAGE.md
install.sh
```

## Install

### Symlink install (recommended)

```bash
./install.sh link --codex
```

### Copy install

```bash
./install.sh copy --codex
```

### Override destination/source

```bash
./install.sh link --codex --dest ~/.codex/skills
./install.sh link --codex --source /path/to/skills
```

Restart Codex after install so skills are reloaded.

## Quickstart prompts

### 1) Abstract + keywords

```text
Use stat-writing. Read main.tex and draft:
(1) a submission-ready abstract (default 6-8 sentences, acceptable 4-10; no citations; no math notation),
(2) 6-10 keywords in alphabetical order.
Output LaTeX blocks for egin{abstract}...nd{abstract} and \keywords{...}.
Then include a short compliance checklist.
```

### 2) Full manuscript audit

```text
Use stat-writing. Audit main.tex (+ refs.bib if available).
Run scripts/check_tex.py and scripts/check_bib.py if possible.
Return top issues ranked HIGH/MED/LOW, each with location + why it matters + concrete LaTeX edits.
```

### 3) Reviewer report

```text
Use stat-writing. Draft a referee report with:
- summary paragraph,
- overall assessment,
- numbered major comments,
- numbered minor comments,
- optional confidential note to editor.
```

### 4) Response to reviewers

```text
Use stat-writing. Draft a point-by-point response letter.
Start with overview of major changes, then sections for Editor/Associate Editor/Reviewers.
For each comment: quote verbatim, respond, quote revised text, and give change location.
```

### 5) Outline to section

```text
Use stat-writing. Expand this Methods outline into complete LaTeX prose.
Do not invent results or citations; add 	odo{...} placeholders for missing details.
```

### 6) Book manuscript scaffold

```text
Use stat-writing. Build a book manuscript starter from this chapter plan.
Use frontmatter/mainmatter/backmatter, create chapter placeholders,
and keep notation generic unless I ask for custom macros.
```

## Included templates

- `skills/stat-writing/assets/manuscript-template.tex`
- `skills/stat-writing/assets/book-manuscript-template.tex`
- `skills/stat-writing/assets/reviewer-report-template.md`
- `skills/stat-writing/assets/reviewer-report-template.tex`
- `skills/stat-writing/assets/response-letter-template.tex`
- `skills/stat-writing/assets/section-skeleton.tex`

## Optional scripts

```bash
python skills/stat-writing/scripts/check_tex.py path/to/main.tex
python skills/stat-writing/scripts/check_bib.py --tex path/to/main.tex --bib path/to/refs.bib
python skills/stat-writing/scripts/audit_paper.py --tex path/to/main.tex --bib path/to/refs.bib
```

### What `check_tex.py` now flags (heuristics)

- abstract constraints
- keyword order/duplicates/redundancy
- labels and references
- missing float caption/label
- line-number readiness
- raster figure usage
- hard-coded refs like "Figure 2"
- possible missing equation punctuation
- reproducibility/supplement cue absence
- citation-style usage hints
- selected English/unicode pitfalls

### What `check_bib.py` now flags (heuristics)

- cited-but-missing keys
- unused bib entries
- page range formatting
- missing common entry fields
- duplicate DOI values
- author fields containing literal `et al.`
- title capitalization-risk warnings

## License

CC0-1.0.

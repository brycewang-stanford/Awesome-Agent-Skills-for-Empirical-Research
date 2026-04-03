<!--
  ╔══════════════════════════════════════════════════════════════╗
  ║  本文件为开源 Skill 原始文档，收录仅供学习与研究参考        ║
  ║  CoPaper.AI 收集整理 | https://copaper.ai                  ║
  ╚══════════════════════════════════════════════════════════════╝

  来源仓库: https://github.com/ndpvt-web/latex-document-skill
  项目名称: latex-document-skill
  开源协议: MIT License
  收录日期: 2026-04-02

  声明: 本文件版权归原作者所有。此处收录旨在为社会科学实证研究者
  提供 AI Agent Skills 的集中参考。如有侵权，请联系删除。
-->

<p align="center">
  <img src="assets/capy-professor.png" alt="Professor Capybara — your LaTeX document expert" width="400"/>
</p>

<h1 align="center">LaTeX Document Skill</h1>

<p align="center">
  <strong>The capybara sat down at the typewriter. When it stood up, there was a thesis.</strong>
</p>

<p align="center">
  <em>Turn handwritten notes, scanned textbooks, and raw data into publication-ready LaTeX -- without knowing a single LaTeX command.</em>
</p>

<p align="center">
  27 templates &middot; 27 automation scripts &middot; 26 reference guides &middot; 4 OCR profiles &middot; 217 tests &middot; 0 LaTeX commands required
</p>

---

## The 10-Second Pitch

You describe a document in plain English. This skill produces a compiled PDF.

- An 80-page handwritten math PDF becomes color-coded lecture notes with proper equations and TikZ diagrams.
- A 162-page textbook becomes a 2-page cheat sheet.
- A CSV becomes nine chart types.
- A one-line prompt becomes a thesis, a resume, a conference poster, or a 37-page book with drop caps.

No LaTeX knowledge required. The capybara handles the semicolons.

---

## What Can It Actually Do?

*(Spoiler: more than most humans with a PhD in LaTeX.)*

| You say... | What happens under the hood |
|---|---|
| "Create my resume" | Selects from 5 ATS-optimized templates, compiles with `pdflatex`, generates PDF + PNG preview |
| "Convert my 80-page handwritten math notes into beautiful LaTeX" | `pdf_to_images.sh` renders at 200 DPI -> batch-7 parallel OCR agents -> `math-notes.md` profile generates colored `tcolorbox` theorems (blue), definitions (green), examples (orange) -> `compile_latex.sh` runs multi-pass pdflatex -> polished PDF with proper equations, proofs, and TikZ diagrams |
| "Turn this 162-page scan into a 2-page cheat sheet" | `pdf_to_images.sh` splits PDF -> vision OCR per page -> extracts key content -> symbol substitution -> telegram-style compression -> fits into `cheatsheet.tex` with 3-column landscape 7pt layout |
| "Build a quarterly report with charts" | `generate_chart.py` creates bar/line/pie charts from JSON/CSV -> `csv_to_latex.py` converts data into `booktabs` tables -> Mermaid/TikZ flowcharts compiled inline -> all embedded in `report.tex` with TOC |
| "Generate 9 charts from my sales CSV" | `generate_chart.py` reads CSV -> outputs bar, line, scatter, pie, heatmap, box, histogram, area, radar charts -> multi-series, legends, colorblind-safe Tol palette |
| "Convert my old PDF to LaTeX" | Pages split at 200 DPI -> parallel OCR agents -> clean `.tex` with profile-tuned formatting -> 0 errors per 7-page batch (validated on 115-page PDF) |
| "Send personalized letters to 500 candidates" | `mail_merge.py` loads template + CSV -> Jinja2 rendering -> 4 parallel `pdflatex` workers -> `qpdf --pages` merge into single PDF |
| "What changed between v1 and v2 of my thesis?" | `latex_diff.sh` runs `latexdiff` -> highlighted change-tracked PDF with additions in blue, deletions in red |
| "Make a NeurIPS poster" | Interactive: asks orientation -> layout -> color scheme -> generates A0 `tikzposter` with correct dimensions and QR codes |
| "Create a calculus final exam with answer key" | `exam` class with `\printanswers` toggle, grading table, 6 question types (MCQ, T/F, fill-blank, matching, short, essay) |
| "Fetch BibTeX for these DOIs" | `fetch_bibtex.sh` hits `doi.org` with `Accept: application/x-bibtex` header -> appends to `.bib` -> cross-refs every `
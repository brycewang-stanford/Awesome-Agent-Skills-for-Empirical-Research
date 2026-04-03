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

---
name: latex-document
description: >
  Universal LaTeX document skill: create, compile, and convert any document to
  professional PDF with PNG previews. Supports resumes, reports, cover letters,
  invoices, academic papers, theses/dissertations, academic CVs, presentations
  (Beamer), scientific posters, formal letters, exams/quizzes, books,
  cheat sheets, reference cards, exam formula sheets,
  fillable PDF forms (hyperref form fields), conditional content (etoolbox toggles),
  mail merge from CSV/JSON (Jinja2 templates), version diffing (latexdiff),
  charts (pgfplots + matplotlib), tables (booktabs + CSV import), images (TikZ),
  Mermaid diagrams, AI-generated images, watermarks, landscape pages,
  bibliography/citations (BibTeX/biblatex), multi-language/CJK (auto XeLaTeX),
  algorithms/pseudocode, colored boxes (tcolorbox), SI units (siunitx),
  Pandoc format conversion (Markdown/DOCX/HTML ↔ LaTeX),
  and PDF-to-LaTeX conversion of handwritten or printed documents (math, business,
  legal, general). Compile script supports pdflatex, xelatex, lualatex with
  auto-detection, latexmk backend, texfot log filtering, PDF/A output, and
  verbosity control (--verbose/--quiet). Empirically optimized scaling: single agent 1-10 pages, split
  11-20, batch-7 pipeline 21+. Use when user asks to: (1) create a resume/CV/cover
  letter, (2) write a LaTeX document, (3) create PDF with tables/charts/images,
  (4) compile a .tex file, (5) make a report/invoice/presentation, (6) anything
  involving LaTeX or pdflatex, (7) convert/OCR a PDF to LaTeX, (8) convert
  handwritten notes, (9) create charts/graphs/diagrams, (10) create slides,
  (11) write a thesis or dissertation, (12) create an academic CV, (13) create
  a poster, (14) create an exam/quiz, (15) create a book, (16) convert between
  document formats (Markdown, DOCX, HTML to/from LaTeX), (17) generate Mermaid
  diagrams for LaTeX, (18) create a formal business letter, (19) create a cheat
  sheet or reference card, (20) create an exam formula sheet or crib sheet,
  (21) condense lecture notes/PDFs into a cheat sheet,
  (22) create a fillable PDF form with text fields/checkboxes/dropdowns,
  (23) create a document with conditional content/toggles (show/hide sections),
  (24) generate batch/mail-merge documents from CSV/JSON data,
  (25) create a version diff PDF (latexdiff) highlighting changes between documents,
  (26) create a homework or assignment submission with problems and solutions,
  (27) create a lab report with data tables, graphs, and error analysis,
  (28) encrypt or password-protect a PDF,
  (29) merge multiple PDFs into one,
  (30) optimize/compress a PDF for web or email,
  (31) lint or check a LaTeX document for common issues,
  (32) count words in a LaTeX document,
  (33) analyze document statistics (figures, tables, citations),
  (34) fetch BibTeX from a DOI,
  (35) convert a Graphviz .dot file to PDF/PNG,
  (36) convert a PlantUML .puml file to PDF/PNG,
  (37) create a one-pager/fact sheet/executive summary,
  (38) create a datasheet or product specification sheet,
  (39) extract pages from a PDF (page ranges, odd/even),
  (40) check LaTeX package availability before compiling,
  (41) analyze citations and cross-reference with .bib files,
  (42) debug LaTeX compilation errors,
  (43) make a document accessible (PDF/A, tagged PDF),
  (44) create lecture notes or course handouts,
  (45) fill an existing PDF form (fillable fields or non-fillable with annotations),
  (46) extract text or tables from a PDF (pdfplumber, pypdf),
  (47) OCR a scanned PDF to text (pytesseract),
  (48) create a PDF programmatically with reportlab (Canvas, Platypus),
  (49) rotate or crop PDF pages (pypdf),
  (50) add a watermark to an existing PDF,
  (51) extract metadata from a PDF (title, author, subject).
---

# LaTeX Document Skill

Create any LaTeX document, compile to PDF, and generate PNG previews. Convert PDFs of any type to LaTeX.

## Workflow: Create Documents

1. Determine document type (resume, report, letter, invoice, article, thesis, academic CV, presentation, poster, exam, book, cheat sheet)
2. **If poster:** Run the poster sub-workflow (see [Poster Sub-Workflow](#poster-sub-workflow) below), then skip to step 5.
3. **If cheat sheet / reference card:** Run the cheat sheet sub-workflow (see [Cheat Sheet / Reference Card Sub-Workflow](#cheat-sheet--reference-card-sub-workflow) below), then skip to step 5.
4. **Ask the user which enrichment elements they want** (use AskUserQuestion tool with multiSelect). Offer relevant options based on document type:
   - **AI-generated images** -- custom illustrations, diagrams, photos (uses generate-image skill)
   - **Charts/graphs** -- bar, line, pie, scatter, heatmap (pgfplots or matplotlib)
   - **Flowcharts/diagrams** -- process flows, architecture, decision trees (TikZ or Mermaid)
   - **Citations/bibliography** -- academic references, footnotes, works cited (BibTeX/biblatex)
   - **Tables with data** -- comparison matrices, financial data, statistics (booktabs)
   - **Watermarks** -- DRAFT, CONFIDENTIAL, or company logo background
   - Skip this step for simple documents (cover letters, invoices) or when the user has already specified exactly what they want.
5. Copy the appropriate template from `assets/templates/` or write from scratch
6. Customize content based on user requirements
7. Generate external assets based on user's element choices:
   - AI images: `python3 <skill_path>/../generate-image/scripts/generate_image.py "prompt" --output ./outputs/figure.png`
   - matplotlib charts: `python3 <skill_path>/scripts/generate_chart.py <type> --data '<json>' --output chart.png`
   - Mermaid diagrams: `bash <skill_path>/scripts/mermaid_to_image.sh diagram.mmd output.png`
8. **For documents 5+ pages:** Review the [Long-Form Document Anti-Patterns](#long-form-document-anti-patterns-must-read-for-reports-theses-books) section and run the Content Generation Checklist before compiling. Key rules: prefer prose over bullets, include global list compaction, escape `<`/`>` in text mode, vary section formats, limit `
ewpage`, size images at 0.75-0.85 textwidth.
9. Compile with `scripts/compile_latex.sh` (auto-detects XeLaTeX for CJK/RTL, glossaries, bibliography)
10. Show PNG preview to user, deliver PDF

### Poster Sub-Workflow

When the user requests a poster: read [references/poster-design-guide.md](references/poster-design-guide.md) for the complete workflow including conference size presets (NeurIPS/ICML/CVPR/ICLR dimensions), layout archetypes (Traditional/BetterPoster/Visual-Heavy), color schemes, and typography standards. Use `poster.tex` (portrait) or `poster-landscape.tex` (landscape). Ask the user for conference/orientation, layout style, and color scheme using AskUserQuestion, then proceed to step 5.

### Cheat Sheet / Reference Card Sub-Workflow

When the user requests a cheat sheet, reference card, or formula sheet:

1. Read [references/cheatsheet-guide.md](references/cheatsheet-guide.md) for the complete workflow including template selection, content budgets, typography rules, and the PDF-to-cheatsheet pipeline.
2. Select template: `cheatsheet.tex` (general, 3-col landscape), `cheatsheet-exam.tex` (exam formula, 2-col portrait), or `cheatsheet-code.tex` (programming, 4-col landscape).
3. Follow the guide's workflow steps, then return to main workflow step 5.

## Workflow: Mail Merge (Batch Personalized Documents)

Generate N personalized documents from a LaTeX template + CSV/JSON data source using `scripts/mail_merge.py`. Template syntax: `{{variable}}` for simple substitution, Jinja2 (`<< >>`, `<% %>`) for conditionals/loops. See `assets/templates/mail-merge-letter.tex` for an example. Full guide: [references/interactive-features.md](references/interactive-features.md).

## Workflow: Version Diffing (latexdiff)

Generate highlighted change-tracked PDFs using `scripts/latex_diff.sh`. Supports file-to-file diff, git revision diff, multi-file flatten, and custom markup styles. Full guide: [references/interactive-features.md](references/interactive-features.md).

## Workflow: Convert Document Formats

Convert between Markdown, DOCX, HTML, and LaTeX using `scripts/convert_document.sh`. Full guide: [references/format-conversion.md](references/format-conversion.md).

## Workflow: Convert PDF to LaTeX

Convert existing PDFs (handwritten notes, printed reports, legal docs) to LaTeX. Full pipeline: [references/pdf-conversion.md](references/pdf-conversion.md).

**Quick steps**: Split PDF into page images (`scripts/pdf_to_images.sh`), select a conversion profile, create shared preamble, apply scaling strategy, validate with `scripts/validate_latex.py`, concatenate, compile.

**Scaling strategy**: 1-10 pages = single agent; 11-20 pages = split in half (2 agents); 21+ pages = batch-7 pipeline (ceil(N/7) agents with `run_in_background: true`).

**Conversion profiles** (in `references/profiles/`): `math-notes.md` (equations, theorems -- has beautiful mode), `business-document.md` (reports, memos), `legal-document.md` (contracts, statutes), `general-notes.md` (handwritten, mixed content).

## Workflow: Fill PDF Forms

Fill existing PDF forms -- both fillable (with form fields) and non-fillable (image-based). Full guide: [references/pdf-operations.md](references/pdf-operations.md).

**Step 1: Check form type:**
```bash
python3 <skill_path>/scripts/pdf_check_form.py form.pdf
```

**If fillable** (has form fields):
```bash
# Extract field metadata
python3 <skill_path>/scripts/pdf_extract_fields.py form.pdf field_info.json
# Create field_values.json with values for each field, then fill
python3 <skill_path>/scripts/pdf_fill_form.py form.pdf field_values.json output.pdf
```

**If non-fillable** (no form fields):
```bash
# Convert to images for visual analysis
bash <skill_path>/scripts/pdf_to_images.sh form.pdf ./tmp/pages
# Visually identify fields, create fields.json with bounding boxes
# Validate bounding boxes (+ optional validation image)
python3 <skill_path>/scripts/pdf_validate_boxes.py fields.json --image page_1.png --output validation.png --page 1
# Fill with text annotations
python3 <skill_path>/scripts/pdf_fill_annotations.py form.pdf fields.json output.pdf
```

## Workflow: Advanced PDF Operations

For text/table extraction (pdfplumber), OCR (pytesseract), programmatic PDF creation (reportlab), watermarking, page rotation/cropping, metadata extraction, JavaScript libraries (pdf-lib, pdfjs-dist), and batch processing, see [references/pdf-operations.md](references/pdf-operations.md).

## Compile Script

```bash
# Basic compile (auto-detects engine)
bash <skill_path>/scripts/compile_latex.sh document.tex

# Compile + generate PNG previews
bash <skill_path>/scripts/compile_latex.sh document.tex --preview

# Compile + PNG in specific directory
bash <skill_path>/scripts/compile_latex.sh document.tex --preview --preview-dir ./outputs

# Force a specific engine
bash <skill_path>/scripts/compile_latex.sh document.tex --engine xelatex
bash <skill_path>/scripts/compile_latex.sh document.tex --engine lualatex

# Use latexmk for automatic multi-pass (recommended for complex documents)
bash <skill_path>/scripts/compile_latex.sh document.tex --use-latexmk --preview

# PDF/A output for thesis submissions and archival compliance
bash <skill_path>/scripts/compile_latex.sh document.tex --pdfa

# Verbose output for debugging compilation issues
bash <skill_path>/scripts/compile_latex.sh document.tex --verbose

# Quiet mode for batch/CI jobs (only errors shown)
bash <skill_path>/scripts/compile_latex.sh document.tex --quiet

# Clean auxiliary files only (no compilation)
bash <skill_path>/scripts/compile_latex.sh document.tex --clean
```

### Compilation Flags

| Flag | Description |
|---|---|
| `--preview` | Generate PNG previews of each page after compilation |
| `--preview-dir DIR` | Directory for PNG output (default: same as .tex file) |
| `--engine ENGINE` | Force engine: `pdflatex`, `xelatex`, or `lualatex` |
| `--use-latexmk` | Use `latexmk` as compilation backend (auto multi-pass, bibliography, index) |
| `--verbose` | Show full compilation output (all engine logs) |
| `--quiet` | Suppress all non-error output |
| `--clean` | Remove auxiliary files (.aux, .log, .bbl, .fdb_latexmk, etc.) and exit |
| `--pdfa` | Produce PDF/A-2b compliant output (auto-injects `pdfx` package) |
| `--auto-fix` | Auto-fix common compilation errors (float placement, encoding) |

### Compilation Backends

**Manual multi-pass (default):** Runs the engine multiple times with bibliography/index/glossary passes as needed. This is the traditional approach and works without `latexmk` installed.

**latexmk (`--use-latexmk`):** Uses `latexmk` for automatic dependency-driven compilation. Recommended for complex documents with bibliographies, indexes, glossaries, or cross-references -- latexmk determines the correct number of passes automatically. Requires `latexmk` (included with TeX Live).

### Log Filtering (texfot)

When `texfot` is installed (included with TeX Live), compilation output is automatically filtered to show only relevant warnings and errors, suppressing noisy package loading messages. This applies in the default verbosity mode. Use `--verbose` to see unfiltered output, or `--quiet` to suppress all non-error output.

**Engine auto-detection**: If the .tex file uses `fontspec`, `xeCJK`, or `polyglossia`, the script automatically uses `xelatex`. If it uses `luacode` or `luatextra`, it uses `lualatex`. Otherwise defaults to `pdflatex`. Override with `--engine`.

The script auto-installs `texlive` (including `texlive-science`, `texlive-xetex`, `texlive-luatex`, `biber`) and `poppler-utils` if missing. It auto-detects `ibliography{}` (runs bibtex), `ddbibresource{}` (runs biber), `\makeindex` (runs makeindex), `\makeglossaries` (runs makeglossaries), runs the correct number of passes, generates PNG previews with `pdftoppm`, and cleans auxiliary files.

## Script & Tool Reference

For PDF utilities (encrypt, merge, optimize, extract pages, pdf-to-images), LaTeX quality tools (lint, word count, analysis, package check, citations), compilation auto-fix, bibliography fetching, and diagram scripts (Mermaid, Graphviz, PlantUML), see [references/script-tools.md](references/script-tools.md).

## Templates

Copy from `assets/templates/` and customize.

### Resume Templates (5 ATS-Compatible Options)

Select based on experience level, industry, and ATS requirements. See [references/resume-ats-guide.md](references/resume-ats-guide.md) for full ATS guidance.

| Template | Best For | Key Feature | ATS Score |
|---|---|---|---|
| **`resume-classic-ats.tex`** | Finance, law, government, any ATS portal | Zero graphics, plain text only, maximum parse safety | 10/10 |
| **`resume-modern-professional.tex`** | Tech, corporate, general professional | Subtle color accents, clean design, good ATS + human appeal | 9/10 |
| **`resume-executive.tex`** | VP, Director, C-suite (5-15+ years) | Two-page, executive summary, board roles, P&L focus | 9/10 |
| **`resume-technical.tex`** | Software, data, engineering roles | Skills-first hybrid, projects section, tech stack emphasis | 9/10 |
| **`resume-entry-level.tex`** | New graduates, career starters | Education-first, one page, coursework, activities | 9/10 |

All 5 templates follow ATS rules: single-column, no graphics/images, no tables for layout, standard section headings, contact info in body (not header/footer).

### STEM Student Templates

- **`homework.tex`** -- Homework/assignment submission template (`article` class, 11pt) with toggle-able solutions (`\showsolutionstrue`/`\showsolutionsfalse`), custom problem/solution environments, honor code section, `fancyhdr` headers, `amsmath`+`amssymb`+`amsthm` math, `listings` code highlighting (Python, Java, C++, Matlab styles), `enumitem` for (a), (b), (c) sub-parts, `hyperref`. Customization via `
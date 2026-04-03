# Academic Writing Skills for Claude Code

[中文版](README_CN.md)

> Post-writing polish and validation for academic papers — format checks, grammar analysis, de-AI editing, bibliography verification, and experiment narrative generation. Focused on enhancing existing text quality, not generating from scratch.
>
> Recommended platforms: **Claude Code · Codex · Antigravity**

## Skills at a Glance

| Skill | Best For | Input Formats |
|---|---|---|
| [`latex-paper-en`](#latex-paper-en) | English papers — IEEE / ACM / NeurIPS / ICML / Springer | `.tex` |
| [`latex-thesis-zh`](#latex-thesis-zh) | Chinese degree theses — GB/T 7714 / thuthesis / pkuthss | `.tex` |
| [`typst-paper`](#typst-paper) | Fast-compile bilingual papers | `.typ` |
| [`paper-audit`](#paper-audit) | Deep-review-first paper audit and submission gate | `.tex` `.typ` `.pdf` |
| [`industrial-ai-research`](#industrial-ai-research) | Industrial AI literature synthesis & gap analysis | — |

---

## Installation

### Method 1: skills (Recommended)

Install via [skills](https://github.com/bahayonghang/skills), the community skill manager for Claude Code:

```bash
# Install individual skills
npx skills add github.com/bahayonghang/academic-writing-skills/latex-paper-en
npx skills add github.com/bahayonghang/academic-writing-skills/latex-thesis-zh
npx skills add github.com/bahayonghang/academic-writing-skills/typst-paper
npx skills add github.com/bahayonghang/academic-writing-skills/paper-audit
npx skills add github.com/bahayonghang/academic-writing-skills/industrial-ai-research

# Or install everything at once
npx skills add github.com/bahayonghang/academic-writing-skills
```

### Method 2: Manual Installation

```bash
git clone https://github.com/bahayonghang/academic-writing-skills.git
cd academic-writing-skills/academic-writing-skills
```

**Linux / macOS**

```bash
mkdir -p ~/.claude/skills
cp -r latex-paper-en latex-thesis-zh typst-paper paper-audit industrial-ai-research ~/.claude/skills/
```

**Windows (PowerShell)**

```powershell
New-Item -ItemType Directory -Path "$env:USERPROFILE/.claude/skills" -Force
foreach ($skill in @("latex-paper-en","latex-thesis-zh","typst-paper","paper-audit","industrial-ai-research")) {
    Copy-Item -Recurse $skill "$env:USERPROFILE/.claude/skills/"
}
```

---

## Features

### latex-paper-en

English academic paper editing for IEEE, ACM, Springer, NeurIPS, and ICML venues.

| Category | Capability |
|---|---|
| **Format & Compile** | ChkTeX linting; pdfLaTeX / XeLaTeX / LuaLaTeX via latexmk |
| **Grammar** | Chinglish detection, weak-verb replacement, subject-verb agreement |
| **Sentences** | Complex sentence decomposition (auto-triggers at > 50 words) |
| **Expression** | Academic tone improvement, expression restructuring |
| **Logic** | Paragraph coherence (AXES model), introduction funnel checks, methodological depth, abstract/conclusion alignment |
| **Title** | IEEE/ACM/Springer best-practice generation; removes filler words; scores 0–100 |
| **Captions** | Title/Sentence-case, AI-flavor-free figure and table captions |
| **Pseudocode** | IEEE-safe review for `algorithm2e`, `algorithmicx`, `algpseudocodex`; checks float usage, caption/label/reference hygiene, long comments, and advisory line-number defaults |
| **Experiments** | Cohesive result paragraphs with SOTA comparison, ablation analysis, discussion layering, and conclusion completeness |
| **De-AI** | Humanize AI-written passages while preserving all LaTeX syntax; flags low-information boilerplate |
| **Anti-Citation-Stacking** | Max 2 clustered citations per sentence; flags stacking in Introduction/Related Work |
| **References** | Undefined `\ref{}`, unreferenced `\label{}`, missing captions; BibTeX format validation |
| **Online Verify** | CrossRef + Semantic Scholar bibliography verification (no API key required) |
| **Translation** | Chinese → English academic translation with domain-term awareness |

### latex-thesis-zh

Chinese degree thesis editing conforming to GB/T 7714-2015 and major university templates.

| Category | Capability |
|---|---|
| **Structure** | Multi-file thesis mapping; chapter/section completeness check |
| **Bibliography** | GB/T 7714-2015 compliance; BibTeX format validation |
| **Templates** | thuthesis / pkuthss / ustcthesis / fduthesis auto-detection |
| **Chinese Style** | Oral-expression detection, terminology consistency |
| **Logic** | Paragraph coherence (AXES model), introduction funnel, chapter mainline checks, cross-section closure |
| **Title** | GB/T 7713.1-2006 compliant; Chinese & English bilingual candidates |
| **Captions** | Bilingual English/Chinese captions following top-conference standards |
| **Experiments** | Chinese core-journal narrative paragraphs with baseline/ablation coverage, discussion layering, and conclusion completeness |
| **De-AI** | Reduce AI writing traces; preserves all LaTeX commands; flags low-information rhetoric |
| **Anti-Citation-Stacking** | Max 2 clustered citations per sentence; flags stacking in Introduction/Related Work chapters |
| **Compile** | XeLaTeX / LuaLaTeX with full CJK font support |
| **References** | Same integrity checks as `latex-paper-en`; online verification supported |

**Supported university templates**

| University | Template | Notes |
|---|---|---|
| Tsinghua | thuthesis | Figure numbering: 图 3-1 |
| Peking | pkuthss | Nomenclature chapter required |
| USTC | ustcthesis | — |
| Fudan | fduthesis | — |
| Generic | ctexbook | GB/T 7713.1-2006 baseline |

### typst-paper

Bilingual Typst paper editing with millisecond-level compilation.

| Category | Capability |
|---|---|
| **Compile** | Typst CLI wrapper with error summarization |
| **Format** | Page settings, text formatting, citation syntax |
| **Grammar** | Same checks as `latex-paper-en`, adapted for Typst syntax |
| **Logic** | AXES paragraph coherence, introduction funnel, abstract/conclusion alignment, cross-section closure |
| **Title** | Bilingual (English/Chinese) title generation and optimization |
| **Captions** | Bilingual captions following IEEE/ACM standards |
| **Pseudocode** | IEEE-like review for `algorithmic`, `algorithm-figure`, and `lovelace`, including wrapper, caption, style hook, and comment-length checks |
| **Experiments** | Cohesive result paragraphs for journal/conference papers, including discussion layering checks |
| **De-AI** | Humanize AI-written passages in English or Chinese; preserves `@cite`, `<label>`, `$...$` |
| **Anti-Citation-Stacking** | Max 2 clustered citations per sentence; flags stacking in Introduction/Related Work |
| **Venues** | IEEE, ACM, Springer, NeurIPS template guidance |
| **References** | Undefined `@ref`, unreferenced labels; online verification supported |

### paper-audit

Deep-review-first paper audit with layered checks, structured issue bundles, and submission gating.

| Category | Capability |
|---|---|
| **Input** | `.tex`, `.typ`, `.pdf` files |
| **Modes** | `quick-audit` (fast screen) · `deep-review` (reviewer-style critique) · `gate` (submission gate) · `re-audit` (revision verification) |
| **Visual Layout** | Margin overflow, text/image overlaps, font inconsistency, low-res images, blank pages |
| **Reference Integrity** | Undefined refs, unreferenced labels, missing captions, numbering gaps |
| **Caption Audit** | Title/Sentence case enforcement; AI-flavor removal |
| **Pseudocode Audit** | IEEE gate checks for floating algorithm environments, caption/label/reference hygiene, plus advisory checks for line numbers and long comments |
| **Experiment Narrative** | Checks paragraph cohesion, baseline comparisons, discussion depth/layering, and conclusion completeness |
| **Deep Review Outputs** | `final_issues.json`, `overall_assessment.txt`, `review_report.md`, `revision_roadmap.md` |
| **ScholarEval** | 8-dimension quality scoring (1–10) with publication readiness label |
| **NeurIPS Scoring** | Quality / Clarity / Significance / Originality on 1–6 scale |
| **Online Verify** | CrossRef + Semantic Scholar (add `--online`); no API key required |
| **De-AI** | Reduce AI writing traces across the whole document |
| **Citation Stacking** | Detects 3+ clustered citations without individual discussion in Introduction/Related Work |
| **Review Scope Note** | Phase 0 is script-backed; `deep-review` adds quote-anchored reviewer lanes for claims-vs-evidence, notation/numeric consistency, evaluation fairness, self-consistency, and prior-art grounding |

**Audit workflow layers**

| Layer | Check |
|---|---|
| L0 | Quick audit / gate script pass |
| L1 | Deep-review workspace prep (sections, summary, claim map) |
| L2 | Section review lanes |
| L3 | Cross-cutting review lanes |
| L4 | Consolidation + quote verification |
| L5 | Final report + roadmap + optional score summary |

**Quick usage**

| Mode | Use when | Main output |
|---|---|---|
| `quick-audit` | You want a fast readiness screen | Script-backed report + checklist + score summary |
| `deep-review` | You want reviewer-style critique | Structured issue bundle + roadmap |
| `gate` | You only care about blockers | PASS/FAIL + blocking issues |
| `re-audit` | You want to verify revisions | Issue-status comparison |

```bash
uv run python academic-writing-skills/paper-audit/scripts/audit.py paper.tex --mode quick-audit
uv run python academic-writing-skills/paper-audit/scripts/audit.py paper.tex --mode deep-review --scholar-eval
uv run python academic-writing-skills/paper-audit/scripts/audit.py paper.tex --mode gate --venue ieee
uv run python academic-writing-skills/paper-audit/scripts/audit.py paper.tex --mode re-audit --previous-report report_v1.md
```

Compatibility aliases:

- `self-check` -> `quick-audit`
- `review` -> `deep-review`

Docs:

- [Overview](docs/skills/paper-audit/index.md)
- [Workflow](docs/skills/paper-audit/resources/WORKFLOW.md)
- [Outputs](docs/skills/paper-audit/resources/OUTPUTS.md)

### industrial-ai-research

Structured literature synthesis focused on Industrial AI domains.

| Category | Capability |
|---|---|
| **Domains** | Predictive maintenance, intelligent scheduling, anomaly detection, smart manufacturing, CPS, robotics |
| **Intake** | Asks for report language, deliverable mode, time window, and emphasis before synthesizing |
| **Retrieval** | Prioritizes recent arXiv + top IEEE/automation venues (T-ASE, CASE, T-II) |
| **Outputs** | research-brief · literature-map · venue-ranked survey · research-gap memo · survey-draft |
| **Survey Draft** | Taxonomy-driven outline → per-section evidence packs → section-by-section writing → merge with quality gate; optional LaTeX handoff |
| **Report Structure** | Search scope → source buckets → shortlisted papers → synthesis → next-step recommendations |

---

## Quick Start

Skills auto-trigger from natural language. Just open Claude Code and describe your task.

### Compilation

```
compile my paper with xelatex-biber
build the LaTeX document
```

| Recipe | Steps | Use Case |
|---|---|---|
| `xelatex` | XeLaTeX only | Quick Chinese compile |
| `pdflatex` | PDFLaTeX only | Quick English compile |
| `latexmk` | LaTeXmk auto | Auto dependency handling |
| `xelatex-biber` | xelatex → biber → xelatex × 2 | Chinese + Biber (Recommended) |
| `xelatex-bibtex` | xelatex → bibtex → xelatex × 2 | Chinese + BibTeX |
| `pdflatex-biber` | pdflatex → biber → pdflatex × 2 | English + Biber |
| `pdflatex-bibtex` | pdflatex → bibtex → pdflatex × 2 | English + BibTeX |

### De-AI Editing

```
deai check my introduction
humanize this paragraph
reduce AI writing traces in Section 3
```

Removes empty phrases, over-confident expressions, and mechanical parallel structures. Preserves all LaTeX/Typst commands.

### Grammar & Style

```
check grammar in abstract
improve academic tone in the related work section
detect Chinglish in Section 2
```

### Logic & Methodology

```
check logical coherence in my introduction
analyze methodological depth
verify paragraph structure with AXES model
```

### Title Optimization

```
optimize my paper title
generate 5 title candidates for this paper
```

Follows IEEE/ACM/Springer/NeurIPS best practices. Removes ineffective words ("Novel", "A Study of", "Research on"). Scores candidates 0–100. Ensures key terms appear in the first 65 characters (English) / 20 characters (Chinese).

### Experiment Analysis

```
analyze my experiment data and write results section
generate ablation study analysis paragraph
write a SOTA comparison paragraph from this table
```

Output: cohesive narrative paragraphs (LaTeX/Typst), not bullet lists.

### Caption Optimization

```
generate IEEE-standard figure captions
optimize this table caption
generate bilingual caption for Figure 3
```

### Pseudocode & Algorithm Blocks

```
check whether this IEEE pseudocode still uses algorithm2e floats
review this algorithm-figure block for caption and line-number issues
make this pseudocode IEEE-safe without inventing a fake Algorithm 1 rule
```

### Reference & Bibliography

```
check figure references in my paper
find undefined labels
verify my bibliography
```

### Paper Audit

```
run a full audit on my paper
check paper quality before submission
audit my PDF for layout issues
run paper-audit --online --scholar-eval
```

### Translation

```
translate this section to English
中译英这个段落
```

Auto-detects domain terminology (Deep Learning, Time Series, Industrial Control).

---

## Output Protocol

All suggestions use diff-comment style with mandatory severity and priority fields:

```latex
% <MODULE> (Line <N>) [Severity: Critical|Major|Minor] [Priority: P0|P1|P2]: <Issue summary>
% Before: <original text>
% After:  <suggested text>
% Rationale: <brief explanation>
% ⚠️ [PENDING VERIFICATION]: <if evidence/metric is required>
```

| Severity | Meaning |
|---|---|
| Critical | Blocks submission (compilation failure, undefined reference, missing required section) |
| Major | Significantly affects quality (grammar error, logic gap, non-compliant format) |
| Minor | Polish-level improvement (word choice, style consistency) |

---

## Requirements

### LaTeX Skills (`latex-paper-en`, `latex-thesis-zh`)

- Python 3.10+
- TeX Live or MiKTeX (with `latexmk`, `chktex`)
- Chinese documents: XeLaTeX + CJK fonts (SimSun, SimHei, KaiTi)

### Typst Skill (`typst-paper`)

- Python 3.10+
- Typst CLI (`cargo install typst-cli` or system package manager)
- Chinese documents: Source Han Serif / Noto Serif CJK SC

### Paper Audit (`paper-audit`)

- Python 3.10+
- `pdfplumber` for PDF visual analysis (`uv sync` or `pip install pdfplumber`)

---

## Project Structure

```
academic-writing-skills/
├── latex-paper-en/
│   ├── SKILL.md                    # Skill entry point & trigger keywords
│   ├── agents/                     # Agent metadata
│   ├── evals/                      # Evaluation cases
│   ├── examples/                   # Example prompts
│   ├── references/                 # Style guides, venue rules, forbidden terms
│   └── scripts/
│       ├── parsers.py              # LatexParser / TypstParser base
│       ├── compile.py              # Unified compiler (pdflatex/xelatex/latexmk)
│       ├── check_format.py         # ChkTeX wrapper
│       ├── verify_bib.py           # BibTeX format validation
│       ├── online_bib_verify.py    # CrossRef / Semantic Scholar lookup
│       ├── check_references.py     # \ref / \label / caption integrity
│       ├── check_figures.py        # Figure usage analysis
│       ├── check_pseudocode.py     # IEEE-aware pseudocode checks
│       ├── analyze_grammar.py      # Chinglish, weak verbs, agreement
│       ├── analyze_sentences.py    # Long sentence decomposition
│       ├── analyze_logic.py        # AXES coherence, transition signals
│       ├── improve_expression.py   # Academic tone restructuring
│       ├── optimize_title.py       # Title generation & scoring
│       ├── analyze_experiment.py   # Experiment narrative generation
│       ├── deai_check.py           # Single-passage de-AI
│       ├── deai_batch.py           # Batch de-AI over full document
│       ├── translate_academic.py   # CN→EN domain-aware translation
│       └── extract_prose.py        # Plain-text extraction (skip math/env)
│
├── latex-thesis-zh/
│   ├── SKILL.md
│   ├── agents/ · evals/ · examples/ · references/
│   └── scripts/                    # Same toolset as latex-paper-en plus:
│       ├── map_structure.py        # Multi-file thesis structure mapper
│       ├── detect_template.py      # Template auto-detection
│       └── check_consistency.py    # Terminology & notation consistency
│
├── typst-paper/
│   ├── SKILL.md
│   ├── agents/ · evals/ · examples/
│   ├── references/                 # STYLE_GUIDE.md, TYPST_SYNTAX.md, DEAI_GUIDE.md
│   └── scripts/                    # Same toolset, Typst-syntax aware
│       └── check_pseudocode.py     # IEEE-like Typst pseudocode checks
│
├── paper-audit/
│   ├── SKILL.md
│   ├── agents/ · examples/ · templates/
│   ├── references/
│   │   └── SCHOLAR_EVAL_GUIDE.md
│   └── scripts/
│       ├── audit.py                # Main orchestrator
│       ├── parsers.py              # Shared parser base
│       ├── pdf_parser.py           # PDF text & metadata extraction
│       ├── visual_check.py         # PDF layout & rendering analysis
│       ├── check_pseudocode.py     # Routed from sibling skills for IEEE pseudocode checks
│       ├── check_references.py     # Reference integrity
│       ├── detect_language.py      # Language detection
│       ├── scholar_eval.py         # 8-dimension ScholarEval scoring
│       └── report_generator.py     # Structured audit report output
│
└── industrial-ai-research/
    ├── SKILL.md
    ├── agents/ · examples/
    └── references/                 # Source policy, venue priority list
```

---

## Failure Handling

| Problem | Fix |
|---|---|
| Missing LaTeX tools | Install TeX Live / MiKTeX; ensure `latexmk` and `chktex` are in `PATH` |
| Missing Typst CLI | `cargo install typst-cli` or install via package manager |
| Compilation error | Summarize the first error block and request the relevant `.log` snippet |
| Missing script | Verify working directory points to the skill's root folder |
| PDF analysis fails | Install `pdfplumber` (`uv sync --extra dev`) |

---

## Contributing

Issues and pull requests are welcome. Please keep changes scoped to the relevant skill and run `just ci` before submitting.

## License

Academic Use Only — Not for commercial use.

---

## Documentation

Full documentation is available at the [docs](https://github.com/bahayonghang/academic-writing-skills/tree/main/docs) directory.

**Run locally:**

```bash
cd docs
npm install
npm run docs:dev
# Open http://localhost:5173
```

---
name: latex-paper-en
description: English LaTeX academic paper assistant for existing `.tex` projects. Use this skill whenever the user wants to compile, lint, audit, or improve an English LaTeX conference or journal paper such as IEEE, ACM, Springer, NeurIPS, or ICML submissions. Trigger even when the user only mentions one paper issue, such as bibliography errors, grammar cleanup, sentence splitting, logic review, expression polishing, translation, title optimization, figure checks, pseudocode review, algorithm block cleanup, de-AI editing, experiment-section review, table structure validation, three-line table generation, abstract structure diagnosis, or journal adaptation. Also trigger for "proofread my paper", "fix my LaTeX", "prepare for submission", "check my manuscript", "improve my writing", "three-line table", "booktabs", "check abstract", "reformat for another journal", "换投", `algorithm2e`, `algorithmicx`, `algpseudocodex`, `Require/Ensure`, or "Algorithm 1" when the user has a .tex file.
metadata:
  category: academic-writing
  tags: [latex, paper, english, ieee, acm, springer, neurips, icml, compilation, grammar, bibliography, figures, pseudocode, algorithmicx, algpseudocodex]
argument-hint: "[main.tex] [--section SECTION] [--module MODULE]"
allowed-tools: Read, Glob, Grep, Bash(uv *), Bash(pdflatex *), Bash(xelatex *), Bash(latexmk *), Bash(bibtex *), Bash(biber *), Bash(chktex *)
---

# LaTeX Academic Paper Assistant (English)

Use this skill for targeted work on an existing English LaTeX paper project. Keep the workflow low-friction: identify the right module, run the smallest useful check, and return actionable comments in LaTeX-friendly review format.

## Capability Summary

- Compile and diagnose LaTeX build failures.
- Audit formatting, bibliography, grammar, sentence length, argument logic, and figure quality.
- Review IEEE-style pseudocode blocks, figure-wrapped algorithms, captions, labels, comments, and algorithm package choices.
- Improve expression, translate academic prose, optimize titles, and reduce AI-writing traces.
- Review experiment sections without rewriting citations, labels, or math.

## Triggering

Use this skill when the user has an existing English `.tex` paper project and wants help with:

- compiling or fixing build errors
- format or venue compliance
- bibliography and citation validation
- grammar, sentence, logic, or expression review
- translation of academic prose
- title optimization
- figure or caption quality checks
- pseudocode and algorithm-block review
- de-AI editing of visible prose
- experiment-section analysis

## Do Not Use

Do not use this skill for:

- planning or drafting a paper from scratch
- deep literature research or fact-finding without a paper project
- Chinese thesis-specific structure/template work
- Typst-first paper workflows
- DOCX/PDF conversion tasks that do not involve the LaTeX source
- multi-perspective review, scoring, or submission gate decisions (use `paper-audit`)
- standalone algorithm design from scratch without a paper project

## Module Router

| Module | Use when | Primary command | Read next |
| --- | --- | --- | --- |
| `compile` | Build fails or the user wants a fresh compile | `uv run python -B $SKILL_DIR/scripts/compile.py main.tex` | `references/modules/COMPILE.md` |
| `format` | User asks for LaTeX or venue formatting review | `uv run python -B $SKILL_DIR/scripts/check_format.py main.tex` | `references/modules/FORMAT.md` |
| `bibliography` | Missing citations, unused entries, BibTeX validation | `uv run python -B $SKILL_DIR/scripts/verify_bib.py references.bib --tex main.tex` | `references/modules/BIBLIOGRAPHY.md` |
| `grammar` | Grammar and surface-level language fixes | `uv run python -B $SKILL_DIR/scripts/analyze_grammar.py main.tex --section introduction` | `references/modules/GRAMMAR.md` |
| `sentences` | Long, dense, or hard-to-read sentences | `uv run python -B $SKILL_DIR/scripts/analyze_sentences.py main.tex --section introduction` | `references/modules/SENTENCES.md` |
| `logic` | Weak argument flow, unclear transitions, introduction funnel problems, or abstract/conclusion misalignment | `uv run python -B $SKILL_DIR/scripts/analyze_logic.py main.tex --section methods` | `references/modules/LOGIC.md` |
| `expression` | Academic tone polish without changing claims | `uv run python -B $SKILL_DIR/scripts/improve_expression.py main.tex --section related` | `references/modules/EXPRESSION.md` |
| `translation` | Chinese-to-English academic translation or bilingual polishing | `uv run python -B $SKILL_DIR/scripts/translate_academic.py input.txt --domain deep-learning` | `references/modules/TRANSLATION.md` |
| `title` | Generate, compare, or optimize paper titles | `uv run python -B $SKILL_DIR/scripts/optimize_title.py main.tex --check` | `references/modules/TITLE.md` |
| `figures` | Figure existence, extension, DPI, or caption review | `uv run python -B $SKILL_DIR/scripts/check_figures.py main.tex` | `references/REVIEWER_PERSPECTIVE.md` |
| `pseudocode` | IEEE-safe pseudocode review, `algorithm2e` cleanup, caption/label/reference checks, and comment-length review | `uv run python -B $SKILL_DIR/scripts/check_pseudocode.py main.tex --venue ieee` | `references/modules/PSEUDOCODE.md` |
| `deai` | Reduce AI-writing traces while preserving LaTeX syntax | `uv run python -B $SKILL_DIR/scripts/deai_check.py main.tex --section introduction` | `references/modules/DEAI.md` |
| `experiment` | Inspect experiment design/write-up quality, discussion depth, discussion layering, and conclusion completeness | `uv run python -B $SKILL_DIR/scripts/analyze_experiment.py main.tex --section experiments` | `references/modules/EXPERIMENT.md` |
| `tables` | Table structure validation, three-line table generation, or booktabs review | `uv run python -B $SKILL_DIR/scripts/check_tables.py main.tex` | `references/modules/TABLES.md` |
| `abstract` | Abstract five-element structure diagnosis and word count validation | `uv run python -B $SKILL_DIR/scripts/analyze_abstract.py main.tex` | `references/modules/ABSTRACT.md` |
| `adapt` | Journal adaptation: reformat paper for a different venue | (LLM-driven workflow) | references/modules/ADAPT.md |

## Required Inputs

- `main.tex` or the paper entrypoint.
- Optional `--section SECTION` when the request is section-specific.
- Optional bibliography path when the request targets references.
- Optional venue/context when the user cares about IEEE, ACM, Springer, NeurIPS, or ICML conventions.

If arguments are missing, ask only for the file path and the target module.

## Output Contract

- Return findings in LaTeX diff-comment style whenever possible: `% MODULE (Line N) [Severity] [Priority]: Issue ...`
- Keep comments surgical and source-aware.
- Report the exact command used and the exit code when a script fails.
- Preserve `\cite{}`, `\ref{}`, `\label{}`, custom macros, and math environments unless the user explicitly asks for source edits.

## Workflow

1. Parse `$ARGUMENTS` and identify the smallest matching module.
2. Read only the reference file needed for that module.
3. Run the module script with `uv run python -B ...`.
4. Summarize issues, suggested fixes, and blockers in LaTeX-friendly comments.
5. If the user asks for a different concern, switch modules instead of overloading one run.

## Safety Boundaries

- Never invent citations, metrics, baselines, or experimental results.
- Never rewrite bibliography keys, references, labels, or math by default.
- Treat generated text as proposals; keep source-preserving checks separate from prose rewriting.

## Reference Map

- `references/STYLE_GUIDE.md`: tone and style defaults.
- `references/VENUES.md`: venue-specific expectations.
- `references/CITATION_VERIFICATION.md`: citation verification workflow.
- `references/REVIEWER_PERSPECTIVE.md`: reviewer-style heuristics for figures and clarity.
- `references/modules/`: module-by-module commands and decision notes.
- `references/modules/PSEUDOCODE.md`: IEEE-safe defaults for LaTeX pseudocode.

Read only the file that matches the active module.

## Example Requests

- “Compile my IEEE paper and tell me why `main.tex` still fails after BibTeX.”
- “Check the introduction section for grammar and sentence length, but do not rewrite equations.”
- “Audit figures and references in this ACM submission before I submit.”
- “Check whether this IEEE pseudocode still uses `algorithm2e` floats and tell me how to make it IEEE-safe.”
- “Review the experiments section for overclaiming, missing ablations, and weak baseline comparisons.”

See `examples/` for complete request-to-command walkthroughs.

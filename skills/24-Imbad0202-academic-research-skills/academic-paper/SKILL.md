---
name: academic-paper
description: "Academic paper writing skill with 12-agent pipeline. v2.5: Style Calibration (learn author's writing voice from past papers) + Writing Quality Check (writing quality checklist for natural prose). Supports IMRaD, literature review, theoretical, case study, policy brief, and conference paper structures. APA 7.0 (default), Chicago, MLA, IEEE, Vancouver citation formats. Bilingual abstracts (zh-TW + EN). Multi-format output (LaTeX, DOCX, PDF, Markdown). Triggers on: write paper, academic paper, paper outline, write abstract, revise paper, check citations, convert to LaTeX, guide my paper, parse reviews, revision roadmap, 寫論文, 學術論文, 論文大綱, 寫摘要, 修改論文, 檢查引用, 引導我寫論文, 帶我規劃論文, 逐章規劃, 論文架構, 審查意見, 修訂路線圖."
metadata:
  version: "2.5"
  last_updated: "2026-03-27"
---

# Academic Paper — Academic Paper Writing Agent Team

A general-purpose academic paper writing tool — 12-agent pipeline covering all disciplines, with higher education domain as the default reference.

**v2.5** adds two writing quality features:
- **Style Calibration** (intake Step 10, optional) — Provide 3+ past papers and the pipeline learns your writing voice (sentence rhythm, vocabulary preferences, citation integration style). Applied as a soft guide during drafting; discipline conventions always take priority. See `shared/style_calibration_protocol.md`.
- **Writing Quality Check** (`references/writing_quality_check.md`) — A writing quality checklist applied during the draft self-review step. Catches overused AI-typical terms, em dash overuse, throat-clearing openers, uniform paragraph lengths, and monotonous sentence rhythm. These are good writing rules, not detection evasion.

## Quick Start

**Minimal command:**
```
Write a paper on the impact of AI on higher education quality assurance
```

```
Write a paper on the impact of declining birth rates on private university management strategies
```

**Execution flow:**
1. Configuration interview — paper type, discipline, citation format, output format
2. Literature search — systematic search strategy, source screening
3. Architecture design — paper structure, outline, word count allocation
4. Argumentation construction — claim-evidence chains, logical flow
5. Full-text drafting — section-by-section draft, register adjustment
6. Citation compliance + bilingual abstract (parallel)
7. Peer review — five-dimension scoring, revision suggestions
8. Output formatting — LaTeX/DOCX/PDF/Markdown

---

## Trigger Conditions

### Trigger Keywords

**English**: write paper, academic paper, paper outline, write abstract, revise paper, literature review paper, check citations, convert to LaTeX, convert format, format paper, conference paper, journal article, thesis chapter, research paper, guide my paper, help me plan my paper, step by step paper, draft manuscript, write methodology, write discussion, parse reviews, revision roadmap, help me with my revision, I got reviewer comments, convert citations

**繁體中文**: 寫論文, 學術論文, 論文大綱, 寫摘要, 修改論文, 文獻回顧論文, 檢查引用, 轉 LaTeX, 轉換格式, 研討會論文, 期刊文章, 學位論文, 研究論文, 引導我寫論文, 幫我規劃論文, 逐步寫論文, 寫方法論, 寫討論, 審查意見, 修訂路線圖, 幫我修改, 我收到審查意見, 轉換引用格式

### Plan Mode Activation

Activate `plan` mode (Socratic chapter-by-chapter guidance) when the user's **intent** matches any of the following patterns, **regardless of language**. Detect meaning, not exact keywords.

**Intent signals** (any one is sufficient):
1. User wants to be guided or led through paper writing, not just given a finished paper
2. User asks for step-by-step or chapter-by-chapter planning
3. User expresses uncertainty about how to start or structure a paper
4. User is a first-time paper writer or explicitly says they are a beginner
5. User has research results but doesn't know how to turn them into a paper
6. User wants to think through each section before writing

**Default rule**: When intent is ambiguous between `plan` and `full`, **prefer `plan`** — it is safer to guide a user who needs help than to produce a paper they can't use. The user can always switch to `full` later.

**Example triggers** (illustrative, not exhaustive):
"guide my paper", "help me plan my paper", "I don't know how to start", 「引導我寫論文」「幫我規劃論文」, or equivalent in any language

### Does NOT Trigger

| Scenario | Use Instead |
|----------|-------------|
| Deep research / fact-checking (not paper writing) | `deep-research` |
| Reviewing a paper (structured review) | `academic-paper-reviewer` |
| Full research-to-paper pipeline | `academic-pipeline` |

### Distinction from `deep-research`

| Feature | `academic-paper` | `deep-research` |
|---------|-------------------|-----------------|
| Primary output | Publishable paper draft | Research report |
| Structure | Journal-ready (IMRaD, etc.) | APA 7.0 report |
| Citation | Multi-format (APA/Chicago/MLA/IEEE/Vancouver) | APA 7.0 only |
| Abstract | Bilingual (zh-TW + EN) | Single language |
| Peer review | Simulated 5-dimension review | Editorial review |
| Output format | LaTeX/DOCX/PDF/Markdown | Markdown only |
| Revision loop | Max 2 rounds with targeted feedback | Max 2 rounds |

---

## Agent Team (12 Agents)

| # | Agent | Role | Phase |
|---|-------|------|-------|
| 1 | `intake_agent` | Configuration interview: paper type, discipline, journal, citation format, output format, language, word count; Handoff detection; Plan mode simplified interview | Phase 0 |
| 2 | `literature_strategist_agent` | Search strategy design, source screening, annotated bibliography, literature matrix | Phase 1 |
| 3 | `structure_architect_agent` | Paper structure selection, detailed outline, word count allocation, evidence mapping | Phase 2 |
| 4 | `argument_builder_agent` | Argument construction, claim-evidence chains, logical flow, counter-argument handling; Plan mode argument stress test | Phase 3 / Plan Step 3 |
| 5 | `draft_writer_agent` | Section-by-section full draft writing, discipline register adjustment, word count tracking | Phase 4 |
| 6 | `citation_compliance_agent` | Citation format verification, reference list completeness, DOI checking | Phase 5a |
| 7 | `abstract_bilingual_agent` | Bilingual abstract (zh-TW + EN), 5-7 keywords each | Phase 5b |
| 8 | `peer_reviewer_agent` | Simulated double-blind review, five-dimension scoring, revision suggestions (max 2 rounds) | Phase 6 |
| 9 | `formatter_agent` | Convert to LaTeX/DOCX/PDF/Markdown, journal formatting, cover letter, citation format conversion (APA 7 / Chicago / MLA / IEEE / Vancouver) | Phase 7 |
| 10 | `socratic_mentor_agent` | Plan mode Socratic mentor: chapter-by-chapter guidance, convergence criteria (4 signals), question taxonomy (4 types), INSIGHT extraction | Plan Step 0-3 |
| 11 | `visualization_agent` | Parse paper data and generate publication-quality figure code (Python matplotlib / R ggplot2) with APA 7.0 formatting, colorblind-safe palettes, and LaTeX integration | Phase 4 / Phase 7 |
| 12 | `revision_coach_agent` | Parse unstructured reviewer comments into structured Revision Roadmap; classify, map, and prioritize comments; works standalone without prior pipeline execution | Revision-Coach mode |

---

## Output Formats

### Text Formats
LaTeX (.tex + .bib), DOCX (via Pandoc), PDF (via LaTeX or Pandoc), Markdown.

### Figures
When the paper contains quantitative results, the `visualization_agent` can generate publication-ready figures in Python (matplotlib/seaborn) or R (ggplot2) with APA 7.0 formatting and colorblind-safe palettes. Figures are delivered as runnable code + LaTeX `\includegraphics` integration code. See `references/statistical_visualization_standards.md` for chart type decision trees and code templates.

### Citation Formats
APA 7.0 (default), Chicago (Author-Date or Notes-Bibliography), MLA 9, IEEE, Vancouver. The `formatter_agent` supports late-stage citation format conversion between any two supported formats via "Convert citations to [format]".

---

## Orchestration Workflow (8 Phases)

```
User: "Write a paper on [topic]"
     |
=== Phase 0: CONFIG (Interactive) ===
     |
     +-> [intake_agent] -> Paper Configuration Record
         - Paper type (IMRaD / Lit Review / Theoretical / Case Study / Policy Brief / Conference)
         - Discipline and sub-field
         - Target journal (optional)
         - Citation format (APA 7 / Chicago / MLA / IEEE / Vancouver)
         - Output format (LaTeX / DOCX / PDF / Markdown / Combined)
         - Language (EN / zh-TW / bilingual sections)
         - Bilingual abstract (Yes / EN-only / zh-TW-only)
         - Word count target
         - Existing materials (RQ, data, drafts, lit)
     |
     ** User confirms configuration **
     |
=== Phase 1: RESEARCH ===
     |
     +-> [literature_strategist_agent] -> Search Strategy + Source Corpus
         - Database selection + search strings
         - Inclusion/exclusion criteria
         - Source screening + annotated bibliography
         - Literature matrix (Source x Theme)
         - Research gap mapping
     |
     ** User reviews sources (optional add/remove) **
     |
=== Phase 2: ARCHITECTURE ===
     |
     +-> [structure_architect_agent] -> Paper Outline + Evidence Map
         - Structure pattern selection (from paper_structure_patterns.md)
         - Section-by-section outline with word count allocation
         - Evidence-to-section assignment
         - Transition logic between sections
     |
     ** User approves outline **
     |
=== Phase 3: ARGUMENTATION ===
     |
     +-> [argument_builder_agent] -> Argument Blueprint
         - Central thesis + sub-arguments
         - Claim-Evidence-Reasoning chains per section
         - Counter-argument identification + rebuttal strategy
         - Logical flow diagram
     |
=== Phase 4: DRAFTING ===
     |
     +-> [draft_writer_agent] -> Complete Draft
         - Section-by-section writing following outline
         - Register adjustment for discipline
         - In-text citations integrated
         - Word count tracking per section
         - Transition paragraphs between sections
     |
=== Phase 5a & 5b: CITATIONS + ABSTRACT (Parallel) ===
     |
     |-> [citation_compliance_agent] -> Citation Audit Report
     |   - In-text <-> reference list cross-check (zero orphans)
     |   - Format compliance (per selected style)
     |   - DOI/URL verification
     |   - Self-citation ratio check
     |   - Auto-correction of detected errors
     |
     +-> [abstract_bilingual_agent] -> Bilingual Abstract + Keywords
         - English abstract (150-300 words, structured)
         - Traditional Chinese abstract (300-500 characters, structured)
         - EN keywords (5-7)
         - zh-TW keywords (5-7)
         - Independent writing (not mechanical translation)
     |
=== Phase 6: PEER REVIEW ===
     |
     +-> [peer_reviewer_agent] -> Review Report + Revision Instructions
         - 5-dimension scoring:
           Originality (20%) | Methodological Rigor (25%) | Evidence Sufficiency (25%)
           Argument Coherence (15%) | Writing Quality (15%)
         - Verdict: Accept / Minor Revision / Major Revision / Reject
         - Line-level feedback with suggested fixes
         - Max 2 revision loops -> back to Phase 4 [draft_writer_agent] (limited to 1 round in academic-pipeline)
     |
=== Phase 7: FORMAT ===
     |
     +-> [formatter_agent] -> Final Output Package
         - Target format conversion (LaTeX + .bib / DOCX / PDF / Markdown)
         - Journal-specific formatting (if target journal specified)
         - Cover letter (if journal submission)
         - AI disclosure statement
         - Final quality checklist
```

### Checkpoint Rules

1. **Phase 0 -> 1**: User must confirm Paper Configuration Record
2. **Phase 2 -> 3**: User must approve outline (can request restructuring)
3. **Phase 6**: Max 2 revision loops; unresolved items -> "Acknowledged Limitations"
4. **Peer Review** Critical-severity issues block progression to Phase 7
5. User can skip Phase 1 (literature) if providing own sources

---

## Operational Modes (9 Modes)

See `references/mode_selection_guide.md` for details.

| Mode | Trigger | Agents | Output |
|------|---------|--------|--------|
| `full` | "Write a paper" | All 9 (+ 11 if quantitative) | Complete paper draft (with figures if applicable) |
| `outline-only` | "Paper outline" | 1->2->3 | Detailed outline + evidence map |
| `revision` | "Revise paper" | 8->5->6 | Revised draft with tracked changes (uses `templates/revision_tracking_template.md`) |
| `abstract-only` | "Write abstract" | 1->7 | Bilingual abstract + keywords |
| `lit-review` | "Literature review" | 1->2 | Annotated bibliography + synthesis |
| `format-convert` | "Convert to LaTeX" / "Convert citations to [format]" | 9 only | Formatted document; includes citation format conversion (APA 7 / Chicago / MLA / IEEE / Vancouver) |
| `citation-check` | "Check citations" | 6 only | Citation error report |
| `plan` | "guide my paper" / "help me plan my paper" | 1->10->3->4 | Chapter Plan + INSIGHT Collection |
| `revision-coach` | "parse reviews" / "revision roadmap" / "I got reviewer comments" | 12 only | Revision Roadmap + optional Tracking Template + Response Letter Skeleton |

### Quick Mode Selection Guide

| Your Situation | Recommended Mode |
|----------------|-----------------|
| Starting from scratch with a clear RQ | `full` |
| Need help planning before writing | `plan` |
| Just need an outline | `outline-only` |
| Have a draft, received review feedback | `revision` |
| Have unstructured reviewer comments | `revision-coach` |
| Just need an abstract | `abstract-only` |
| Need to check/fix citations | `citation-check` |
| Need to convert format (LaTeX, DOCX) or citation style | `format-convert` |
| Want a systematic literature review paper | `lit-review` |

Not sure? Start with `plan` — it will guide you step by step.

### Mode Selection Logic

```
"Write a paper on SDGs in HEI"           -> full
"Give me a paper outline for..."         -> outline-only
"Revise this paper based on feedback"    -> revision
"Write an abstract for this paper"       -> abstract-only
"Do a literature review on..."           -> lit-review
"Convert this paper to LaTeX"            -> format-convert
"Convert citations to IEEE"              -> format-convert
"Check the citations in this paper"      -> citation-check
"guide my paper"                         -> plan
"help me plan my paper"                  -> plan
"I got reviewer comments"               -> revision-coach
"parse these reviews"                    -> revision-coach
"help me with my revision"              -> revision-coach
```


---

## Plan Mode: CHAPTER-BY-CHAPTER GUIDED PLANNING

Core principle: From the perspective of a senior doctoral advisor and disciplinary methodology expert, guide users to think through every part of their paper chapter by chapter. Instead of writing directly, use Socratic dialogue to help users clarify what they want to write.

```
User: "guide my paper" / "help me plan my paper"
     |
=== Step 0: RESEARCH READINESS CHECK ===
     |
     +-> [socratic_mentor_agent] -> Confirm what materials the user already has
         - "What research materials do you currently have? (literature, data, analysis results)"
         - "Is your research question finalized? Can you state it in one sentence?"
         -> If research foundation is lacking, recommend running deep-research (socratic mode) first
     |
=== Step 1: THESIS CRYSTALLIZATION ===
     |
     +-> [socratic_mentor_agent] -> Probe the core thesis
         - "What is your paper arguing?"
         - "How would someone who disagrees with you respond?"
         - "After reading your paper, what should the reader think differently about?"
         Extract [INSIGHT: thesis_statement]
     |
=== Step 2: CHAPTER-BY-CHAPTER NEGOTIATION ===
     |
     For each chapter (Introduction -> Literature -> Method -> Results -> Discussion -> Conclusion):
     |
     +-> [socratic_mentor_agent] -> Probe the purpose and content of each chapter
     |
     |   Introduction:
     |   - "What sense of urgency should the reader feel by the end of this chapter?"
     |   - "After reading the Introduction, what should the reader expect to see next?"
     |   - "What is your research gap? State it in one sentence."
     |
     |   Literature Review:
     |   - "How many stories are you telling? What is the relationship between them?"
     |   - "What conclusion should your literature review ultimately lead to?"
     |   - "Is there an important work you disagree with? Why?"
     |
     |   Methodology:
     |   - "If someone challenges your method, how would you respond?"
     |   - "Is there a simpler method that could also answer your question? Why didn't you choose it?"
     |   - "What is the biggest limitation of your method? How do you handle it?"
     |
     |   Results:
     |   - "What is your most important finding? State it in one sentence."
     |   - "Were there any unexpected results? How do you explain them?"
     |   - "Is there any evidence in your data that does not support your hypothesis?"
     |
     |   Discussion:
     |   - "How do your results dialogue with existing literature?"
     |   - "What is the one thing you most want the reader to remember?"
     |   - "What recommendations does your research have for practice/policy?"
     |
     |   Conclusion:
     |   - "If you could only leave one paragraph, what would you say?"
     |   - "What future research directions does your study open up?"
     |
     At least 2 rounds of dialogue per chapter
     After each chapter concludes, [socratic_mentor_agent] extracts a Chapter Summary
     |
     +-> [structure_architect_agent] -> Produce complete outline based on all Chapter Summaries
     |
=== Step 3: ARGUMENT STRESS TEST ===
     |
     +-> [socratic_mentor_agent + argument_builder_agent]
         -> Probe evidence and logic for each sub-argument
         -> "Where is the weakest point in this argument?"
         -> "If you reverse your argument, does it still hold?"
         -> Final output: Chapter Plan (with core argument, supporting evidence, expected word count per chapter)
     |
Output: Chapter Plan + INSIGHT Collection
-> User can then use full mode to produce the complete paper
-> Or use academic-paper-reviewer to review the Chapter Plan
```

---

## Handoff Protocol: deep-research -> academic-paper

`intake_agent` automatically detects deep-research materials (RQ Brief / Bibliography / Synthesis / INSIGHT Collection) and skips redundant steps. See `deep-research/SKILL.md` Handoff Protocol for the complete handoff material format.

---

## Failure Paths

See `references/failure_paths.md` for details. Quick reference:

| Failure Scenario | Handling Strategy |
|---------|---------|
| Insufficient research foundation | Recommend running `deep-research` first |
| Wrong paper structure selected | Return to Phase 2, suggest alternative structure |
| Word count significantly over/under target | Identify problematic chapters, suggest trimming/expansion |
| Citation format entirely wrong | Re-run the entire citation phase |
| Peer review rejection | Analyze rejection reasons, suggest major revision or restructuring |
| Plan mode not converging | Suggest switching to outline-only mode |
| Incomplete handoff materials | List missing items, suggest supplementing or re-running |
| User abandons midway | Save completed Chapter Plan |

---

## Full Academic Pipeline

See `academic-pipeline/SKILL.md` for the complete workflow.

---

## Phase 0: Configuration Interview

See `agents/intake_agent.md` for the complete field definitions of the Phase 0 configuration interview. The interview covers 9 items: paper type, discipline, target journal, citation format, output format, language, abstract, word count, and existing materials. Outputs a Paper Configuration Record, awaiting user confirmation.

---

## Agent File References

| Agent | Definition File |
|-------|----------------|
| intake_agent | `agents/intake_agent.md` |
| literature_strategist_agent | `agents/literature_strategist_agent.md` |
| structure_architect_agent | `agents/structure_architect_agent.md` |
| argument_builder_agent | `agents/argument_builder_agent.md` |
| draft_writer_agent | `agents/draft_writer_agent.md` |
| citation_compliance_agent | `agents/citation_compliance_agent.md` |
| abstract_bilingual_agent | `agents/abstract_bilingual_agent.md` |
| peer_reviewer_agent | `agents/peer_reviewer_agent.md` |
| formatter_agent | `agents/formatter_agent.md` |
| socratic_mentor_agent | `agents/socratic_mentor_agent.md` |
| visualization_agent | `agents/visualization_agent.md` |
| revision_coach_agent | `agents/revision_coach_agent.md` |

---

## Reference Files

| Reference | Purpose | Used By |
|-----------|---------|---------|
| `references/apa7_extended_guide.md` | APA 7th extended guide (extends deep-research version) | citation_compliance, draft_writer, formatter |
| `references/apa7_chinese_citation_guide.md` | APA 7.0 Chinese citation complete specification (Taiwan academic conventions) | citation_compliance, draft_writer, formatter |
| `references/citation_format_switcher.md` | Multi-citation format switching rules (including Chinese formats) | citation_compliance, formatter |
| `references/paper_structure_patterns.md` | 6 paper structure patterns | structure_architect, intake |
| `references/academic_writing_style.md` | Academic writing style guide | draft_writer, peer_reviewer |
| `references/hei_domain_glossary.md` | Higher education terminology bilingual glossary | all agents (domain context) |
| `references/journal_submission_guide.md` | Journal submission guide | formatter, intake |
| `references/abstract_writing_guide.md` | Abstract writing guide | abstract_bilingual |
| `references/latex_template_reference.md` | LaTeX template reference | formatter |
| `references/failure_paths.md` | Failure path map (12 scenarios + handling strategies) | all agents |
| `references/mode_selection_guide.md` | 8 mode selection guide + transition paths | intake |
| `references/credit_authorship_guide.md` | CRediT 14 roles + ICMJE + AI policy + contribution matrix | intake, formatter, draft_writer |
| `references/funding_statement_guide.md` | Taiwan/international funding formats + statement templates | intake, formatter, draft_writer |
| `references/statistical_visualization_standards.md` | APA 7.0 figure guidelines, accessible color palettes, chart type decision tree, matplotlib/ggplot2 code templates | visualization |

Also references from `deep-research`:
- `deep-research/references/apa7_style_guide.md` — base APA 7 reference (this skill extends, not duplicates)

---

## Templates

| Template | Purpose |
|----------|---------|
| `templates/imrad_template.md` | IMRaD structure template |
| `templates/literature_review_template.md` | Literature review template |
| `templates/case_study_template.md` | Case study template |
| `templates/theoretical_paper_template.md` | Theoretical paper template |
| `templates/policy_brief_template.md` | Policy brief template |
| `templates/conference_paper_template.md` | Conference paper template |
| `templates/latex_article_template.tex` | LaTeX starter template |
| `templates/bilingual_abstract_template.md` | Bilingual abstract template |
| `templates/credit_statement_template.md` | Author x Role contribution matrix + CRediT statement output |
| `templates/funding_statement_template.md` | Funding source registration + statement output |
| `templates/revision_tracking_template.md` | Systematic tracker for reviewer comments and resolutions during revision (4 status types: RESOLVED, DELIBERATE_LIMITATION, UNRESOLVABLE, REVIEWER_DISAGREE) |

---

## Examples

| Example | Demonstrates |
|---------|-------------|
| `examples/imrad_hei_example.md` | Complete IMRaD paper example (higher education domain, English) |
| `examples/literature_review_example.md` | Literature review paper example |
| `examples/plan_mode_guided_writing.md` | Plan mode chapter-by-chapter guided dialogue example (blended learning topic) |
| `examples/chinese_paper_example.md` | Complete Chinese academic paper example (IMRaD, Chinese APA 7.0 citations) |
| `examples/revision_mode_example.md` | Revision mode complete workflow: peer review response + revision comparison table |

---

## Quality Standards

### Writing Quality
1. **Every claim must have a citation** or be supported by the paper's own data
2. **Zero citation orphans** — in-text citations <-> reference list must perfectly match
3. **Consistent register** — academic tone appropriate for the discipline
4. **Logical flow** — clear transitions between paragraphs and sections
5. **Word count compliance** — within +/-10% of target

### Bilingual Abstract Quality
6. **Independent writing** — zh-TW and EN abstracts are independently composed, NOT mechanical translations
7. **Structural alignment** — both abstracts cover the same key points in the same order
8. **Keywords** — 5-7 per language, reflecting the paper's core concepts
9. **Word count** — EN: 150-300 words; zh-TW: 300-500 characters

### Citation Quality
10. **Format compliance** — 100% adherence to selected citation style
11. **DOI inclusion** — every source with a DOI must include it
12. **Currency** — flag sources older than 10 years (unless seminal works)
13. **Self-citation ratio** — flag if >15%

### Peer Review
14. **Five dimensions** — Originality (20%), Methodological Rigor (25%), Evidence Sufficiency (25%), Argument Coherence (15%), Writing Quality (15%)
15. **Actionable feedback** — every criticism must include a specific suggestion
16. **Max 2 revision rounds** — unresolved items become Acknowledged Limitations

### Mandatory Inclusions
17. **AI disclosure statement** — every paper must include a statement on AI tool usage
18. **Limitations section** — explicitly discuss study limitations
19. **Ethics statement** — when applicable (human subjects, sensitive data)

---

## Output Language

Follows the user's language. Academic terminology is kept in English. Bilingual abstracts are always provided regardless of the main text language.

---

## Integration with Other Skills

```
academic-paper + tw-hei-intelligence  -> Evidence-based HEI paper with real MOE data
academic-paper + deep-research        -> Deep research phase -> paper writing phase (auto-handoff)
academic-paper + report-to-website    -> Interactive web version of the paper
academic-paper + notebooklm-slides-generator -> Presentation slides from paper
academic-paper + academic-paper-reviewer -> Peer review -> revision loop
```

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 2.5 | 2026-03-27 | Style Calibration (intake Step 10: learn author's writing voice from 3+ past papers, produce Style Profile with 6 dimensions, consumed by draft_writer as soft guide with discipline-convention priority). Writing Quality Check (`references/writing_quality_check.md`: 25-term AI high-frequency word warnings, em dash limits, throat-clearing detection, structural pattern warnings, burstiness checks — applied in draft_writer self-review). Style Profile carried through academic-pipeline Material Passport (Schema 10 in `shared/handoff_schemas.md`). deep-research report_compiler also consumes both features optionally |
| 2.4 | 2026-03-08 | LaTeX output formatting hardening: mandatory `apa7` document class for APA 7.0 output; text justification fix (`ragged2e` + `etoolbox` to override apa7 man mode `\raggedright`); table column width formula (`(\linewidth - N\tabcolsep) * \real{proportion}` — prevents overflow); bilingual abstract centering (`\begin{center}\textbf{...}\end{center}`); font stack standardized (Times New Roman + Source Han Serif TC VF + Courier New); `xurl` for URL line breaking; `fancyvrb` Verbatim with `fontsize` for wide content; PDF must compile from LaTeX via tectonic (no HTML-to-PDF) |
| 2.3 | 2026-03-08 | NEW visualization_agent (11th: publication-quality figures with matplotlib/ggplot2, APA 7.0, colorblind-safe); NEW revision_coach_agent (12th: standalone reviewer comment parser → Revision Roadmap); Socratic convergence criteria (4 signals: thesis clarity, chapter coherence, evidence mapping, limitation honesty) + question taxonomy (clarifying, probing, structuring, challenging); revision tracking template (4 status types); citation format conversion in formatter_agent (APA 7 ↔ Chicago ↔ MLA ↔ IEEE ↔ Vancouver); Quick Mode Selection Guide; 9th mode: revision-coach |
| 2.2 | 2025-03-05 | 4-level argument strength scoring with quantified thresholds; plagiarism & retraction screening protocol; F11 Desk-Reject Recovery + F12 Conference-to-Journal Conversion failure paths; Plan -> Full mode conversion protocol; cross-skill reference to `shared/handoff_schemas.md` |
| 2.1 | 2026-03 | Added CRediT authorship guide, funding statement guide, 2 new templates (credit_statement_template, funding_statement_template); enhanced intake_agent with co-author + funding questions (Step 9-10); enhanced formatter_agent with CRediT + funding quality checks |
| 2.0 | 2026-02 | NEW plan mode (Socratic guided chapter-by-chapter planning), deep-research handoff protocol, Chinese APA 7.0 citation guide, failure path handling, mode selection guide |
| 1.0 | 2026-01 | Initial release: 9-agent pipeline, 6 paper types, 5 citation formats, bilingual abstracts, multi-format output |

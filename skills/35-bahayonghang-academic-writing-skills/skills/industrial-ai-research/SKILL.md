---
name: industrial-ai-research
description: >
  Industrial AI literature research with mandatory intake questions, venue-aware
  source prioritization, structured report outputs, and survey draft generation.
  Use when the user needs up-to-date research on predictive maintenance,
  intelligent scheduling, industrial anomaly detection, smart manufacturing,
  cyber-physical systems, edge AI for automation, or crossover
  robotics-for-industry topics. Also trigger for adjacent terms: "digital twin",
  "industrial IoT", "Industry 4.0", "manufacturing AI", "factory automation",
  "process optimization", or "survey draft" in industrial contexts.
metadata:
  category: academic-writing
  tags: [industrial-ai, research, literature-review, predictive-maintenance, scheduling, anomaly-detection, smart-manufacturing, cps, arxiv, ieee, survey, survey-draft]
  version: "1.1"
  last_updated: "2026-03-12"
argument-hint: "[topic] [--mode MODE] [--lang LANG] [--window WINDOW] [--output-dir DIR]"
allowed-tools: Read, Glob, Grep, WebSearch, WebFetch
---

# Industrial AI Research

Run a lean, source-aware research workflow for Industrial AI.

## Capability Summary

- Structured literature research for Industrial AI and automation topics
- Mandatory four-question intake before any search or synthesis
- Venue-aware source prioritization (arXiv, IEEE, automation venues)
- Four deliverable modes: research-brief, literature-map, venue-ranked survey, research-gap memo
- Contrarian synthesis pass to surface contradictions and under-explored gaps
- Survey draft generation: outline-first writing with per-section evidence packs and optional LaTeX export

## Triggering

Use this skill when the user wants to:
- Survey Industrial AI literature on a specific subtopic
- Compare papers across venues or methods within Industrial AI
- Identify research gaps in predictive maintenance, scheduling, anomaly detection, or smart manufacturing
- Produce a structured research report with source-backed evidence
- Draft a structured survey on an Industrial AI subtopic
- Produce a survey manuscript with taxonomy, evidence packs, and section-by-section writing

## Do Not Use

- Writing or compiling LaTeX/Typst papers (use `latex-paper-en`, `latex-thesis-zh`, or `typst-paper`).
  Note: survey-draft mode produces Markdown by default; for LaTeX output, it delegates final formatting to `latex-paper-en`.
- Auditing paper quality or formatting (use `paper-audit`)
- Systematic reviews or meta-analyses requiring IRB or clinical ethics
- Topics outside the Industrial AI and automation domain
- Auditing an existing paper's quality or formatting (use `paper-audit`)
- Editing LaTeX/Typst source files (use the appropriate writing skill)

## Safety Boundaries

- Never fabricate paper metadata (title, authors, venue, year, DOI)
- Never present preprints as peer-reviewed publications
- Never start synthesis before intake questions are answered
- Never suppress contradictions or conflicting evidence
- Never use Tier 4 sources (blogs, press releases) as primary evidence

## Core Rules

1. Ask the user the four intake questions (see `references/question-flow.md`) before starting any search or synthesis.
2. Keep the skill workflow in English only, even when the requested report language is not English.
3. Prefer recent arXiv plus top IEEE and automation venues over generic web articles.
4. Default to the last 3 years, but keep seminal older work when it is still necessary for context.
5. Cite every substantive claim and separate verified evidence from inference.
6. In survey-draft mode, complete all structure and evidence phases before generating any prose. Structure phases produce YAML/tables only.

## Intake Contract

Always start by asking the four intake questions defined in `references/question-flow.md`:
1. Report language (English / Simplified Chinese / Bilingual summary)
2. Deliverable mode (research-brief / literature-map / venue-ranked survey / research-gap memo / survey-draft)
3. Time window (last 12 months / last 3 years / last 5 years / custom)
4. Industrial AI emphasis (predictive maintenance / intelligent scheduling / industrial anomaly detection / smart manufacturing and process optimization / CPS and edge AI / robotics crossover)

If the user does not choose, default to `last 3 years` and the subdomain implied by their prompt.

## Required Inputs

- A concrete Industrial AI topic or question.
- User choices for report language, deliverable mode, time window, and domain emphasis.
- Optional preferences on peer-reviewed-only filtering, benchmarks vs deployment evidence, or desired output format.

If any intake item is missing, ask the mandatory questions from `references/question-flow.md` before you search.

## Source Strategy

Read these files before searching:
- `references/source-priority.md`
- `references/venue-map.md`

Primary sources:
- arXiv: `eess.SY`, `cs.AI`
- IEEE and automation anchors: `T-ASE`, `CASE`

Supporting crossover sources:
- arXiv: `cs.RO`, `cs.LG`
- IEEE robotics venues: `ICRA`, `IROS`, `RA-L`, `T-RO`
- Adjacent industrial and control venues listed in `references/venue-map.md`

When the user asks for the latest work, prefer:
1. arXiv recent streams for rapid updates
2. top IEEE and automation venues for stronger publication filtering
3. secondary crossover venues only when they materially improve coverage

## Workflow

### Phase 1. Scope

- Rewrite the request as a precise Industrial AI research objective.
- Lock the report language, deliverable mode, time window, and domain emphasis.
- State explicit in-scope and out-of-scope boundaries.

### Phase 2. Search Plan

- Build venue buckets and keyword groups from `references/source-priority.md`.
- Separate primary sources from secondary crossover sources.
- State the recency policy and any seminal-paper exceptions.

### Phase 3. Source Collection

- Gather papers from the prioritized source buckets.
- Prefer official venue pages, arXiv recent listings, IEEE Xplore landing pages, and publisher or conference pages.
- Record why each paper was included.

### Phase 4. Verification and Triage

- Check venue quality, publication type, year, and relevance.
- Remove weak matches, duplicates, and generic blog-style sources.
- Mark unreviewed preprints as preprints.

### Phase 5. Synthesis

- Cluster the shortlisted papers by problem, method, dataset, deployment setting, and evaluation style.
- Surface trends, gaps, contradictions, and under-explored opportunities.
- Run a contrarian pass: what would challenge the dominant conclusion?

### Phase 6. Report Assembly

Use the stable report structure from `references/report-modes.md`.

Every final report must include:
- search scope
- source buckets by venue
- shortlisted papers
- synthesis of trends and gaps
- recommended next reading or next experiments

### Survey-Draft Workflow (Phases S1–S4)

When the user selects `survey-draft`, Phases 1–4 (Scope, Search Plan, Source Collection, Verification) execute as normal, then S1–S4 replace the original Phases 5–6.

#### Phase S1. Outline Building

Read `references/modules/SURVEY_OUTLINE.md`.

- Extract a taxonomy from the verified literature.
- Build the section skeleton as structured YAML.
- Present the outline to the user for approval.
- **CHECKPOINT**: do not enter S2 until the user approves the outline.

#### Phase S2. Evidence Pack Assembly

Read `references/modules/SURVEY_EVIDENCE.md`.

- Assemble an evidence pack for every H3 subsection.
- Lock the citation scope for each subsection.
- Produce structured evidence bundles (no prose).

#### Phase S3. Section-by-Section Writing

Read `references/modules/SURVEY_WRITER.md`.

- Draft each H3 independently, grounded in its evidence pack.
- Run the self-check gate on every H3 (depth, citation scope, tone).
- Produce one Markdown file per H2 section.

#### Phase S4. Merge and Quality Gate

Read `references/modules/SURVEY_MERGE.md`.

- Merge all section drafts into a single document.
- Run cross-section consistency checks.
- Apply the final quality checklist.
- If the user requested LaTeX output, delegate to `latex-paper-en`.

## Deliverable Modes

Read `references/report-modes.md` and follow the selected mode exactly.

- `research-brief`: short, decision-ready overview
- `literature-map`: thematic map across methods and subproblems
- `venue-ranked survey`: grouped by source quality and venue tier
- `research-gap memo`: open problems, design space, and next-step opportunities
- `survey-draft`: taxonomy-driven survey manuscript with outline-first writing and optional LaTeX export

## Output Contract

- State the locked intake choices and any defaults you applied before synthesis.
- Distinguish verified evidence from inference in every deliverable.
- Label preprints explicitly as preprints.
- For non-survey modes, produce a structured report that includes: scope, source buckets, shortlisted papers, synthesis, and next reading or next experiments.
- For `survey-draft`, keep stage outputs format-specific:
  - S1: YAML outline only
  - S2: evidence packs or tables only
  - S3: section Markdown drafts grounded in the evidence packs
  - S4: merged Markdown survey with cross-section consistency notes
- If sources are sparse, inaccessible, or off-scope, say so directly and report the exact fallback you used.

## Module Router

| Module | Use when | Primary action | Read next |
|--------|----------|---------------|-----------|
| `research` | User selects any of the 4 report modes | Execute Phase 1–6 workflow | `references/report-modes.md` |
| `survey-outline` | User selects survey-draft (Phase S1) | Build taxonomy and section skeleton | `references/modules/SURVEY_OUTLINE.md` |
| `survey-evidence` | Outline approved by user (Phase S2) | Assemble per-H3 evidence packs | `references/modules/SURVEY_EVIDENCE.md` |
| `survey-write` | Evidence packs complete (Phase S3) | Draft prose per H3 | `references/modules/SURVEY_WRITER.md` |
| `survey-merge` | All sections complete (Phase S4) | Merge, quality gate, optional LaTeX handoff | `references/modules/SURVEY_MERGE.md` |

## Quality Bar

Read `references/quality-checklist.md` before finalizing.

Non-negotiable standards:
- no unsupported claims
- no venue-blind source mixing
- no hiding contradictions
- no synthesized report before intake questions are answered
- no generic "latest research says" language without source-backed evidence

## Error Handling

- **Zero results**: Broaden keywords, relax the time window by one tier, and try adjacent venues. If still empty, report the negative result with the exact queries attempted.
- **Off-subdomain topic**: State that the topic falls outside Industrial AI scope, suggest the closest supported subdomain, and ask the user whether to proceed or abort.
- **Inaccessible databases**: Note which sources were unreachable, proceed with available sources, and flag the gap in the final report.
- **Too few papers (<5 shortlisted)**: Lower the time window threshold, include Tier 2/3 venues, and explicitly note the thin evidence base in the synthesis.

## Reference Map

| File | Phase | When to read |
|------|-------|-------------|
| `references/question-flow.md` | Intake | Before asking the user any questions |
| `references/source-priority.md` | Search Plan | Before building venue buckets |
| `references/venue-map.md` | Search Plan | Before selecting specific venues |
| `references/report-modes.md` | Report Assembly | Before structuring the final output |
| `references/quality-checklist.md` | Report Assembly | Before finalizing the report |
| `references/modules/SURVEY_OUTLINE.md` | Survey S1 | When building the survey outline |
| `references/modules/SURVEY_EVIDENCE.md` | Survey S2 | When assembling evidence packs |
| `references/modules/SURVEY_WRITER.md` | Survey S3 | When drafting survey sections |
| `references/modules/SURVEY_MERGE.md` | Survey S4 | When merging and running quality gate |
| `references/SURVEY_WRITING_GUIDE.md` | Survey S1–S4 | Survey writing philosophy reference |

## Examples

- `examples/predictive-maintenance.md`
- `examples/intelligent-scheduling.md`
- `examples/industrial-anomaly-detection.md`
- `examples/survey-predictive-maintenance.md`

## Example Requests

- “Research recent predictive maintenance papers from the last 3 years and return a research-brief.”
- “Compare industrial anomaly detection papers across arXiv and IEEE automation venues, and show contradictions in evaluation setups.”
- “Draft a survey on intelligent scheduling for researchers new to the subfield, but stop after the YAML outline for approval.”
- “My topic is warehouse picking robotics. If that is outside scope, tell me the closest supported Industrial AI framing and proceed only with that.”

## Boundaries

This v1 skill does not implement:
- systematic review mode
- meta-analysis
- IRB-heavy or clinical ethics branches
- standalone automation scripts

If the user needs those, state the boundary and continue with the closest supported research mode.

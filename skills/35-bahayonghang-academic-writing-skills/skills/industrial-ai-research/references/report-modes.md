# Report Modes

Use the selected mode exactly.

## Stable Sections for Every Report

Every final report must contain these sections in this order:

1. `Search Scope`
2. `Source Buckets by Venue`
3. `Shortlisted Papers`
4. `Synthesis of Trends and Gaps`
5. `Recommended Next Reading / Next Experiments`

## Mode: research-brief

Use when the user wants a fast answer.

- Target length: 700 to 1200 words
- Focus: direct findings, paper shortlist, quick recommendation
- Keep tables compact

## Mode: literature-map

Use when the user wants a structured overview.

- Target length: 1200 to 2200 words
- Focus: themes, clusters, methods, datasets, evaluation patterns
- Include a theme-by-paper or method-by-paper map

## Mode: venue-ranked survey

Use when the user wants stronger source discrimination.

- Target length: 1200 to 2500 words
- Group papers by venue tier and source bucket
- Make venue quality and publication type highly visible

## Mode: research-gap memo

Use when the user wants opportunities and next steps.

- Target length: 900 to 1800 words
- Focus: unresolved gaps, weak evidence areas, and concrete future work ideas
- End with an ordered list of the most promising next experiments or reading tracks

## Mode: survey-draft

Use when the user wants a structured survey manuscript draft.

- Target length: 3000–15000 words (user-selected: short / standard / comprehensive)
- Focus: taxonomy-driven survey with per-section evidence packs and structured argumentation
- Output: Markdown by default; optional LaTeX via `latex-paper-en` handoff
- Requires human checkpoint after outline approval

### Survey-Draft Stable Sections

1. `Title and Abstract`
2. `Introduction` (problem scope, motivation, contribution of the survey, reading guide)
3. `Background and Scope` (key definitions, inclusion/exclusion criteria, search methodology)
4. `Taxonomy` (organizing framework — method-based, problem-based, or hybrid)
5. `Body Sections` (one H2 per taxonomy branch, H3 per sub-branch)
6. `Comparative Analysis` (cross-cutting comparison tables, quantitative summaries)
7. `Open Challenges and Future Directions`
8. `Conclusion`
9. `References`

### Survey-Draft Artifact Contract

| Phase | Artifact | Format | Location |
|-------|----------|--------|----------|
| S1 | `outline.yml` | YAML | `{output-dir}/outline.yml` |
| S1 | `taxonomy.md` | Markdown table | `{output-dir}/taxonomy.md` |
| S2 | `evidence/{section-slug}.md` | Markdown per H3 | `{output-dir}/evidence/` |
| S2 | `citation-map.md` | Section-to-citation binding | `{output-dir}/citation-map.md` |
| S3 | `drafts/{section-slug}.md` | Markdown per H2 | `{output-dir}/drafts/` |
| S4 | `survey-draft.md` | Final merged Markdown | `{output-dir}/survey-draft.md` |
| S4 | `survey-draft.tex` (optional) | LaTeX via handoff | `{output-dir}/survey-draft.tex` |
| S4 | `quality-report.md` | Quality gate results | `{output-dir}/quality-report.md` |

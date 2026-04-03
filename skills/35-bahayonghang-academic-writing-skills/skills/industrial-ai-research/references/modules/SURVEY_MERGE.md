# Module: Survey Merge and Quality Gate (Phase S4)

Merge all section drafts into a single survey document, run quality checks, and optionally hand off to LaTeX.

## Prerequisites

- Phase S3 complete: all `drafts/{section-slug}.md` files produced.
- `outline.yml` and `citation-map.md` available.

## Step 1: Merge Sections

Assemble the final document in `outline.yml` section order:

1. **Title and Abstract**: generate a concise abstract (150–300 words) summarizing scope, method, key findings, and implications.
2. **Front-matter sections**: Introduction, Background and Scope (from Phase S3 drafts).
3. **Body sections**: each H2 with its H3 subsections (from Phase S3 drafts).
4. **Insert transition sentences**: 1–2 sentences between each H2 section connecting the logical flow from the previous branch to the next.
5. **Comparative Analysis**: build from the cross-cutting comparison table.
   - Aggregate per-H3 comparison tables into a unified cross-cutting table.
   - Add 2–4 paragraphs of cross-branch analysis highlighting patterns, trade-offs, and dominant approaches.
6. **Open Challenges and Future Directions** (from Phase S3 draft).
7. **Conclusion** (from Phase S3 draft).
8. **References**: collect all cited paper IDs from all evidence packs, deduplicate, and format as a numbered reference list.

Output: `{output-dir}/survey-draft.md`

## Step 2: Quality Gate

Run every check below and record results in `{output-dir}/quality-report.md`:

### Quality Checklist

| # | Check | Criterion | Status |
|---|-------|-----------|--------|
| 1 | Outline alignment | Every H2/H3 in `outline.yml` appears in the final draft | PASS / FAIL |
| 2 | Citation health | 0 undefined citations, 0 duplicate keys | PASS / FAIL |
| 3 | Placeholder leak | 0 occurrences of TODO, TBD, PLACEHOLDER, XXX, FIXME | PASS / FAIL |
| 4 | Generator tone | 0 pipeline/planner tone leaks (see SURVEY_WRITER.md forbidden patterns) | PASS / FAIL |
| 5 | Citation density | Total unique citations ≥ tier minimum (see below) | PASS / FAIL |
| 6 | Comparison tables | ≥1 cross-cutting comparison table in Comparative Analysis | PASS / FAIL |
| 7 | Section balance | Longest H2 word count ≤ 3× shortest H2 word count | PASS / WARN |
| 8 | Abstract present | Abstract exists and is 150–300 words | PASS / FAIL |
| 9 | No orphan sections | No H2/H3 with zero citations | PASS / FAIL |

### Global Citation Density Requirements

| Length Tier | Minimum unique citations |
|-------------|------------------------|
| Short | 30 |
| Standard | 60 |
| Comprehensive | 100 |

### Quality Report Format

```markdown
# Quality Report: [Survey Title]

## Summary

- Length tier: [short / standard / comprehensive]
- Total word count: [N]
- Total unique citations: [N]
- Overall status: ALL PASS / HAS FAILURES / HAS WARNINGS

## Detailed Results

| # | Check | Criterion | Status | Details |
|---|-------|-----------|--------|---------|
| 1 | Outline alignment | ... | PASS | All 12 sections present |
| 2 | Citation health | ... | PASS | 67 unique, 0 duplicates |
| ... | ... | ... | ... | ... |

## Recommendations

- [Any WARN or FAIL items with suggested fixes]
```

### Handling Failures

- **FAIL on checks 1–6, 8–9**: do not deliver the draft. Fix the issue and re-run the quality gate.
- **WARN on check 7**: deliver with a note to the user about section imbalance.
- After fixing, re-run the full checklist to confirm all items pass.

## Step 3: LaTeX Handoff (Optional)

If the user requested LaTeX output during intake:

1. Confirm that `survey-draft.md` passes all quality gate checks.
2. Inform the user:
   > The Markdown draft is complete and has passed all quality checks. I will now delegate to the `latex-paper-en` skill for LaTeX formatting.
3. Provide `survey-draft.md` path to `latex-paper-en` for:
   - Template selection (IEEE / ACM / Springer / NeurIPS / ICML or user-specified).
   - BibTeX generation from the reference list.
   - Compilation to PDF.
4. This skill does NOT directly create or edit `.tex` files. All LaTeX work is handled by `latex-paper-en`.

Output (if LaTeX requested): `{output-dir}/survey-draft.tex` (produced by `latex-paper-en`).

## Artifacts Produced

| Artifact | Format | Location |
|----------|--------|----------|
| `survey-draft.md` | Merged Markdown | `{output-dir}/survey-draft.md` |
| `quality-report.md` | Quality gate results | `{output-dir}/quality-report.md` |
| `survey-draft.tex` | LaTeX (optional) | `{output-dir}/survey-draft.tex` |

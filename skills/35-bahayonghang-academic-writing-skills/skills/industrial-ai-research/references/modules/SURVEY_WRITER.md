# Module: Survey Section-by-Section Writer (Phase S3)

Draft each H3 subsection as narrative prose, grounded entirely in the evidence packs from Phase S2.

## Prerequisites

- Phase S1 complete: `outline.yml` approved.
- Phase S2 complete: all evidence packs and `citation-map.md` finalized.

## Writing Procedure

Process sections in `outline.yml` order. For each H2 body section:

### 1. Write the H2 Lead Block

Before writing any H3, draft a 1–2 paragraph lead block for the H2 section:

- Preview the organizing principle of this taxonomy branch.
- State the comparison axes and key findings that will emerge.
- Reference the number of papers covered and the time span.

### 2. Write Each H3 Subsection

For each H3 under the current H2:

1. **Load** the evidence pack from `{output-dir}/evidence/{section-slug}.md`.
2. **Start from claim candidates** — do not write from a blank page.
3. **Draft paragraphs** following these rules:
   - Every paragraph must contain at least one citation.
   - Comparison sentences must use data from the comparison table.
   - Quantitative claims must use exact values from anchor facts.
   - Citation scope: prefer Primary → Chapter-level → Global (sparingly).
4. **Include the comparison table** from the evidence pack (may be reformatted for flow).
5. **End with a synthesis paragraph** that connects findings to the broader taxonomy branch.

### 3. Run Self-Check Gate

After completing each H3, verify against these thresholds:

| Check | Short | Standard | Comprehensive |
|-------|-------|----------|---------------|
| Minimum paragraphs | 3 | 5 | 8 |
| Minimum unique citations | 5 | 8 | 12 |
| Max uncited paragraph ratio | 20% | 10% | 5% |
| Min in-sentence citation ratio | 20% | 30% | 30% |
| Placeholder/TODO leaks | 0 | 0 | 0 |

If any check fails, revise the H3 before moving to the next one.

## Forbidden Patterns

The following patterns must never appear in the draft:

### Generator Tone
- "In this section, we will discuss..."
- "It is worth noting that..."
- "As mentioned earlier..."
- "The following subsection presents..."

### Template Phrase Overuse
- "Taken together" — max 2 occurrences in the entire draft.
- "Notably" — max 3 occurrences in the entire draft.
- "Interestingly" — max 2 occurrences in the entire draft.

### Citation Format Errors
- Adjacent citation blocks: `[1] [2]` is forbidden; merge to `[1, 2]`.
- Orphan citations: a citation that appears in the text but not in the evidence pack's allowed list.

### Unsupported Generalizations
- Any claim without a citation that makes a general statement about the field.
- Phrases like "it is well known that..." or "research has shown that..." without a specific reference.

## THIN_EVIDENCE Handling

When an evidence pack is flagged as `THIN_EVIDENCE`:

- Reduce the expected paragraph count by 40%.
- Explicitly acknowledge the limited evidence: "The literature on [topic] remains sparse, with only [N] studies addressing..."
- Do NOT pad with tangential content or speculative claims.

## Output Format

Produce one Markdown file per H2 section at `{output-dir}/drafts/{section-slug}.md`:

```markdown
# [H2 Title]

[H2 lead block — 1-2 paragraphs]

## [H3.1 Title]

[Narrative paragraphs with inline citations]

[Comparison table]

[Synthesis paragraph]

## [H3.2 Title]

...
```

## Front-Matter and Back-Matter Sections

### Introduction
- Problem scope and motivation (why this survey, why now).
- Contribution statement (what this survey adds beyond existing surveys).
- Reading guide (brief description of each major section).

### Background and Scope
- Key definitions relevant to the subdomain.
- Inclusion/exclusion criteria used during source collection.
- Brief search methodology summary (venues, time window, query terms).

### Open Challenges and Future Directions
- Synthesize gaps from all evidence packs.
- Organize by: near-term (1–2 years), medium-term (3–5 years), long-term (5+ years).
- Each challenge must cite at least one paper that identifies or implies the gap.

### Conclusion
- Summarize key findings (one sentence per H2 branch).
- State limitations of this survey.
- Final recommendation for practitioners and researchers.

## Artifacts Produced

| Artifact | Format | Location |
|----------|--------|----------|
| `drafts/{section-slug}.md` | Markdown per H2 | `{output-dir}/drafts/` |

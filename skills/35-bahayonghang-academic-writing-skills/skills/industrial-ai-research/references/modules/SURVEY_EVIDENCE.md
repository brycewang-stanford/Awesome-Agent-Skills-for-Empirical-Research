# Module: Survey Evidence Pack Assembly (Phase S2)

Assemble structured evidence for every H3 subsection. This phase produces data artifacts only — no prose.

## Prerequisites

- Phase S1 complete: `outline.yml` approved by user, `taxonomy.md` finalized.
- Verified paper set available with full metadata.

## Evidence Pack Structure

For each H3 subsection in `outline.yml`, produce one evidence file at `{output-dir}/evidence/{section-slug}.md`:

```markdown
# Evidence Pack: [Section ID] — [Sub-branch Title]

## Claim Candidates

- **[Claim 1]**: [Paper ID] — "[verbatim or close-paraphrase snippet from abstract/conclusion]"
- **[Claim 2]**: [Paper ID] — "[snippet]"
- ...

## Comparison Table

| Paper | Method | Dataset | Key Metric | Result | Deployment Evidence |
|-------|--------|---------|------------|--------|---------------------|
| ... | ... | ... | ... | ... | None / Simulation / Pilot / Production |

## Anchor Facts

Quantitative facts that the writer must use:

- [Fact 1]: [Paper ID] — [exact number and context]
- [Fact 2]: [Paper ID] — [exact number and context]
- ...

## Gaps and Limitations

- **[Gap 1]**: evidence from [Paper IDs] — [brief description]
- **[Limitation 1]**: [Paper IDs] — [brief description]
- ...

## Allowed Citations

- **Primary** (this H3): [list of paper IDs]
- **Chapter-level** (parent H2): [list of paper IDs]
- **Global** (use sparingly): [list of paper IDs]

## Evidence Density Flag

- Status: SUFFICIENT | THIN_EVIDENCE
- If THIN_EVIDENCE: [explanation of what is missing]
```

## Key Rules

### No Prose

Evidence packs contain only structured data: bullet lists, tables, and tagged citations. The writer module (Phase S3) converts these into narrative text.

### No Fabrication

- Every claim candidate must trace to a specific snippet from a verified paper.
- Every anchor fact must include the exact quantitative value from the source.
- If a claim cannot be sourced, do not include it.

### Citation Scope Locking

The writer (Phase S3) is restricted to citations listed in the evidence pack:

- **Primary citations**: directly relevant to this H3. Use freely.
- **Chapter-level citations**: relevant to the parent H2 but not specific to this H3. Use for context.
- **Global citations**: foundational or cross-cutting papers. Use sparingly (max 2 per H3).

### Thin Evidence Handling

If a subsection has fewer claims or citations than the minimum required by the length tier, mark it as `THIN_EVIDENCE` and:

- Do NOT pad with filler claims or tangential papers.
- Flag explicitly so the writer can adjust depth expectations.
- Consider suggesting to the user that this subsection be merged with a sibling.

## Evidence Density Requirements

Minimum thresholds per H3 subsection, by length tier:

| Length Tier | Min claim candidates | Min unique citations | Min comparison table rows |
|-------------|---------------------|---------------------|--------------------------|
| Short | 3 | 5 | 3 |
| Standard | 5 | 8 | 5 |
| Comprehensive | 8 | 12 | 8 |

## Citation Map

After all evidence packs are assembled, produce `{output-dir}/citation-map.md`:

```markdown
# Citation Map

## Section-to-Citation Binding

| Section ID | Section Title | Primary Citations | Chapter Citations | Global Citations |
|-----------|--------------|-------------------|-------------------|------------------|
| S3.1 | [title] | [IDs] | [IDs] | [IDs] |
| S3.2 | [title] | [IDs] | [IDs] | [IDs] |
| ... | ... | ... | ... | ... |

## Citation Frequency

| Paper ID | First Author | Year | Sections Referenced | Role |
|----------|-------------|------|--------------------|----- |
| ... | ... | ... | [list] | Primary / Chapter / Global |
```

## Artifacts Produced

| Artifact | Format | Location |
|----------|--------|----------|
| `evidence/{section-slug}.md` | Markdown per H3 | `{output-dir}/evidence/` |
| `citation-map.md` | Markdown table | `{output-dir}/citation-map.md` |

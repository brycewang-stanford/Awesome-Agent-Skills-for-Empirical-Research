# Module: Survey Outline (Phase S1)

Build the survey skeleton before any prose is written. This phase produces structured YAML and a taxonomy table — no narrative text.

## Prerequisites

- Phase 1–4 (Scope, Search Plan, Source Collection, Verification) are complete.
- A verified paper set is available.

## Step 1: Extract Taxonomy

1. Read `references/SURVEY_WRITING_GUIDE.md` — load the taxonomy pattern library.
2. Identify which subdomain the verified papers belong to.
3. Select two classification axes from the pattern library (or propose custom axes if none fit).
4. Assign every verified paper to exactly one primary cell in the axis matrix.
5. Produce `taxonomy.md`:

```markdown
# Taxonomy: [Topic]

## Classification Axes

- Axis 1: [name] — [definition]
- Axis 2: [name] — [definition]

## Paper-to-Cell Mapping

| Paper ID | First Author | Year | Axis 1 Value | Axis 2 Value | Primary Cell |
|----------|-------------|------|--------------|--------------|-------------|
```

### Taxonomy Quality Checks

- Top-level branches (H2): 3–7. Fewer than 3 means the taxonomy is too coarse; more than 7 means it is too fragmented.
- Sub-branches per H2 (H3): 2–5.
- No cell should contain more than 40% of all papers. If it does, split the dominant axis.
- Every paper must map to exactly one primary sub-branch.

## Step 2: Build Outline YAML

Produce `outline.yml` following this schema:

```yaml
title: "Survey: [Topic]"
audience: researchers_new | practitioners | reviewers
length_tier: short | standard | comprehensive
taxonomy:
  axis_1: "[name]"
  axis_2: "[name]"
sections:
  - id: S1
    title: "Introduction"
    type: front-matter
    guidance: "Problem scope, motivation, contribution of this survey, reading guide"
  - id: S2
    title: "Background and Scope"
    type: front-matter
    guidance: "Key definitions, inclusion/exclusion criteria, search methodology summary"
  - id: S3
    title: "[Taxonomy Branch 1]"
    type: body
    subsections:
      - id: S3.1
        title: "[Sub-branch]"
        paper_count: N
        key_papers: ["paper_id_1", "paper_id_2"]
      - id: S3.2
        title: "[Sub-branch]"
        paper_count: N
        key_papers: ["paper_id_3"]
  # ... more body sections ...
  - id: SN-2
    title: "Comparative Analysis"
    type: analysis
    guidance: "Cross-cutting comparison tables, quantitative summaries across branches"
  - id: SN-1
    title: "Open Challenges and Future Directions"
    type: discussion
    guidance: "Gaps, emerging trends, recommended research directions"
  - id: SN
    title: "Conclusion"
    type: closing
    guidance: "Key takeaways, limitations of this survey, final recommendations"
```

### Outline Validation Rules

- Every body section (`type: body`) must have at least 2 subsections.
- Every subsection must list at least 2 `key_papers`.
- The sum of all `paper_count` values must equal or exceed the total verified paper count (a paper may appear in multiple subsections as secondary, but has exactly one primary).
- Front-matter sections (Introduction, Background) have no subsections.

## Step 3: Human Checkpoint

Present both `outline.yml` and `taxonomy.md` to the user with this exact prompt:

> Please review the survey outline and taxonomy. You can:
> - **Approve** to proceed to evidence pack assembly (Phase S2).
> - **Adjust branches** — request merging, splitting, or renaming taxonomy branches.
> - **Reorder sections** — change the sequence of body sections.
> - **Add/remove papers** — adjust paper assignments.
>
> I will not proceed to Phase S2 until you approve the outline.

### Checkpoint Rules

- **NEVER** proceed to Phase S2 without explicit user approval.
- If the user requests changes, regenerate the affected parts of `outline.yml` and `taxonomy.md`, then re-present for approval.
- Track the approval status: `outline_approved: true | false`.

## Artifacts Produced

| Artifact | Format | Location |
|----------|--------|----------|
| `taxonomy.md` | Markdown table | `{output-dir}/taxonomy.md` |
| `outline.yml` | YAML | `{output-dir}/outline.yml` |

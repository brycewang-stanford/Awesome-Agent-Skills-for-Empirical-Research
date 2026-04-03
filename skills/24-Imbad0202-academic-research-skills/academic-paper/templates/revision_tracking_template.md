# Revision Tracking Template

## Usage

Use this template to systematically track all reviewer comments and their resolutions during the revision process. Copy this template at the start of each revision round, fill in the paper information, then add one row per reviewer comment.

This template works with both:
- **Revision mode** (`revision` in SKILL.md): when you have a draft and structured reviewer feedback
- **Revision Coach mode** (`revision-coach` in SKILL.md): when you have unstructured reviewer comments that need parsing first

---

## Paper Information

| Field | Value |
|-------|-------|
| Paper Title | [title] |
| Revision Round | [1 / 2] |
| Date | [YYYY-MM-DD] |
| Previous Decision | [Major Revision / Minor Revision] |
| Target Journal | [journal name] |
| Original Word Count | [N words] |
| Revised Word Count | [N words] |

---

## Revision Tracking Table

| # | Issue Description | Reviewer | Type | Section | Resolution Summary | Location of Change | Status | Reason (if not resolved) |
|---|-------------------|----------|------|---------|-------------------|-------------------|--------|--------------------------|
| 1 | [description] | [R1/R2/R3/DA] | [Major/Minor/Editorial] | [section] | [what was done] | [page/paragraph] | [status] | [if applicable] |
| 2 | [description] | [R1/R2/R3/DA] | [Major/Minor/Editorial] | [section] | [what was done] | [page/paragraph] | [status] | [if applicable] |
| 3 | [description] | [R1/R2/R3/DA] | [Major/Minor/Editorial] | [section] | [what was done] | [page/paragraph] | [status] | [if applicable] |

---

## Status Values

### RESOLVED
Change made; reviewer concern fully addressed.
- **Must specify**: exact location of change (section, paragraph, page number)
- **Must include**: brief description of what was changed
- **Example**: "Added three additional references supporting the methodology choice (Section 3.2, paragraph 2)"

### DELIBERATE_LIMITATION
Acknowledged as a boundary condition of the study design (not a flaw).
- **Must provide**: justification for why this is a design boundary, not an oversight
- **Must include**: reference to the Limitations section where this is discussed
- **Example**: "Cross-sectional design is acknowledged in Limitations (Section 5.3). Longitudinal follow-up is recommended as future research."

### UNRESOLVABLE
Would require fundamentally different research design to address.
- **Must explain**: the specific constraint that prevents resolution
- **Must recommend**: as a direction for future research
- **Example**: "Addressing this would require a randomized controlled trial, which was not feasible given ethical constraints. Added to Future Research (Section 5.4)."

### REVIEWER_DISAGREE
Respectful disagreement with the reviewer's suggestion on methodological or theoretical grounds.
- **Must provide**: evidence-based rebuttal with citations
- **Must demonstrate**: that the reviewer's concern was carefully considered
- **Example**: "We respectfully maintain our analytical approach. Smith (2022) and Chen (2023) both validate this method for our sample size and data structure. Response letter includes detailed justification."

---

## Response Letter Structure

When preparing the response letter to accompany the revised manuscript, use this structure:

```
Dear Editor and Reviewers,

Thank you for the thoughtful and constructive feedback on our manuscript
"[Paper Title]" (Manuscript ID: [ID]).

We have carefully addressed all comments and provide point-by-point
responses below. Changes in the manuscript are highlighted in [yellow/
tracked changes].

---

## Response to Reviewer 1

### Comment R1-1: [Brief summary of comment]
**Type**: [Major/Minor/Editorial]
**Response**: [Your response]
**Changes made**: [Location and description of changes]

### Comment R1-2: ...

---

## Response to Reviewer 2
[Same format]

---

## Summary of Changes
- Total comments addressed: [N]
- Word count change: [±N words]
- New references added: [N]
- New figures/tables added: [N]

We believe these revisions have substantially strengthened the manuscript
and look forward to your further evaluation.

Sincerely,
[Author(s)]
```

---

## Summary Statistics

| Metric | Count |
|--------|-------|
| Total items | [N] |
| Resolved | [N] |
| Deliberate Limitation | [N] |
| Unresolvable | [N] |
| Reviewer Disagree | [N] |
| Word count change | [±N words] |
| New references added | [N] |
| New figures/tables added | [N] |

---

## Revision Completeness Checklist

Before submitting the revision, verify:

- [ ] Every reviewer comment has a corresponding row in the tracking table
- [ ] Every RESOLVED item specifies the exact location of the change
- [ ] Every DELIBERATE_LIMITATION item is discussed in the Limitations section
- [ ] Every UNRESOLVABLE item is mentioned in Future Research
- [ ] Every REVIEWER_DISAGREE item has an evidence-based rebuttal
- [ ] The response letter addresses all comments in order
- [ ] Word count is within the journal's limit after revisions
- [ ] All new references are added to the reference list
- [ ] No new errors were introduced during revision (re-run citation check)
- [ ] AI disclosure statement is updated to reflect revision assistance

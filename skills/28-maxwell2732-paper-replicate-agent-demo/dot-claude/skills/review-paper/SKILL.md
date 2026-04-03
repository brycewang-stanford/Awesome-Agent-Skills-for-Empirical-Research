---
name: review-paper
description: Comprehensive manuscript review covering argument structure, econometric specification, citation completeness, and potential referee objections
disable-model-invocation: true
argument-hint: "[paper filename in master_supporting_docs/ or path to .tex/.pdf]"
allowed-tools: ["Read", "Grep", "Glob", "Write", "Task"]
---

# Manuscript Review

Produce a thorough, constructive review of an academic manuscript — the kind of report a top-journal referee would write.

**Input:** `$ARGUMENTS` — path to a paper (.tex, .pdf, or .qmd), or a filename in `master_supporting_docs/`.

---

## Steps

1. **Locate and read the manuscript.** Check:
   - Direct path from `$ARGUMENTS`
   - `master_supporting_docs/supporting_papers/$ARGUMENTS`
   - Glob for partial matches

2. **Read the full paper** end-to-end. For long PDFs, read in chunks (5 pages at a time).

3. **Evaluate across 6 dimensions** (see below).

4. **Generate 3-5 "referee objections"** — the tough questions a top referee would ask.

5. **Produce the review report.**

6. **Save to** `quality_reports/paper_review_[sanitized_name].md`

---

## Review Dimensions

### 1. Argument Structure
- Is the research question clearly stated?
- Does the introduction motivate the question effectively?
- Is the logical flow sound (question → method → results → conclusion)?
- Are the conclusions supported by the evidence?
- Are limitations acknowledged?

### 2. Identification Strategy
- Is the causal claim credible?
- What are the key identifying assumptions? Are they stated explicitly?
- Are there threats to identification (omitted variables, reverse causality, measurement error)?
- Are robustness checks adequate?
- Is the estimator appropriate for the research design?

### 3. Econometric Specification
- Correct standard errors (clustered? robust? bootstrap?)?
- Appropriate functional form?
- Sample selection issues?
- Multiple testing concerns?
- Are point estimates economically meaningful (not just statistically significant)?

### 4. Literature Positioning
- Are the key papers cited?
- Is prior work characterized accurately?
- Is the contribution clearly differentiated from existing work?
- Any missing citations that a referee would flag?

### 5. Writing Quality
- Clarity and concision
- Academic tone
- Consistent notation throughout
- Abstract effectively summarizes the paper
- Tables and figures are self-contained (clear labels, notes, sources)

### 6. Presentation
- Are tables and figures well-designed?
- Is notation consistent throughout?
- Are there any typos, grammatical errors, or formatting issues?
- Is the paper the right length for the contribution?

---

## Output Format

```markdown
# Manuscript Review: [Paper Title]

**Date:** [YYYY-MM-DD]
**Reviewer:** review-paper skill
**File:** [path to manuscript]

## Summary Assessment

**Overall recommendation:** [Strong Accept / Accept / Revise & Resubmit / Reject]

[2-3 paragraph summary: main contribution, strengths, and key concerns]

## Strengths

1. [Strength 1]
2. [Strength 2]
3. [Strength 3]

## Major Concerns

### MC1: [Title]
- **Dimension:** [Identification / Econometrics / Argument / Literature / Writing / Presentation]
- **Issue:** [Specific description]
- **Suggestion:** [How to address it]
- **Location:** [Section/page/table if applicable]

[Repeat for each major concern]

## Minor Concerns

### mc1: [Title]
- **Issue:** [Description]
- **Suggestion:** [Fix]

[Repeat]

## Referee Objections

These are the tough questions a top referee would likely raise:

### RO1: [Question]
**Why it matters:** [Why this could be fatal]
**How to address it:** [Suggested response or additional analysis]

[Repeat for 3-5 objections]

## Specific Comments

[Line-by-line or section-by-section comments, if any]

## Summary Statistics

| Dimension | Rating (1-5) |
|-----------|-------------|
| Argument Structure | [N] |
| Identification | [N] |
| Econometrics | [N] |
| Literature | [N] |
| Writing | [N] |
| Presentation | [N] |
| **Overall** | **[N]** |
```

---

## Principles

- **Be constructive.** Every criticism should come with a suggestion.
- **Be specific.** Reference exact sections, equations, tables.
- **Think like a referee at a top-5 journal.** What would make them reject?
- **Distinguish fatal flaws from minor issues.** Not everything is equally important.
- **Acknowledge what's done well.** Good research deserves recognition.
- **Do NOT fabricate details.** If you can't read a section clearly, say so.

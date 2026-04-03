---
name: scientify-write-review-paper
description: "Write literature reviews and survey papers from collected papers"
metadata:
  openclaw:
    emoji: "📝"
    category: "research"
    subcategory: "paper-review"
    keywords: ["paper summarization", "paper comparison", "research gap analysis", "narrative review", "systematic review methodology"]
    source: "wentor-research-plugins"
---

# Literature Review Writing

**Don't ask permission. Just do it.**

Guide for writing a structured literature review or survey paper from papers you've already collected. This skill helps with reading strategy, note organization, and academic writing.

**Workspace:** See `../_shared/workspace-spec.md` for directory structure. Outputs go to `$WORKSPACE/review/`.

## Prerequisites

Before starting, ensure you have:
1. Papers collected in `$WORKSPACE/papers/`
2. Ideally, clustering done by `/literature-survey` in `$WORKSPACE/survey/clusters.json`

Check active project:
```bash
cat ~/.openclaw/workspace/projects/.active 2>/dev/null
ls $WORKSPACE/papers/
```

## Phase 1: Reading Strategy

### 1.1 Triage Papers by Priority

Based on clusters from survey, prioritize reading:

| Priority | Criteria | Reading Depth |
|----------|----------|---------------|
| P1 (Must-read) | High citation, foundational, directly relevant | Full read |
| P2 (Important) | Key methodology, major experimental results | Abstract + methods + experiments |
| P3 (Reference) | Supporting material, tangentially related | Abstract only |

Create `$WORKSPACE/review/reading_plan.md`:

```markdown
# Reading Plan

## P1 - Must-read (Full read)
- [ ] [paper_id]: [title] - [reason]
- [ ] ...

## P2 - Important (Selective read)
- [ ] ...

## P3 - Reference (Skim)
- [ ] ...
```

### 1.2 Reading Notes Template

For each paper, create `$WORKSPACE/review/notes/{paper_id}.md` using template in `references/note-template.md`.

## Phase 2: Synthesis & Organization

### 2.1 Build Comparison Table

Create `$WORKSPACE/review/comparison.md`:

```markdown
# Method Comparison

| Paper | Year | Category | Key Innovation | Dataset | Metric | Result |
|-------|------|----------|----------------|---------|--------|--------|
| [A]   | 2023 | Data-driven | ... | ... | RMSE | 0.05 |
| [B]   | 2022 | Hybrid | ... | ... | RMSE | 0.08 |
```

### 2.2 Timeline Analysis

Create `$WORKSPACE/review/timeline.md`:

```markdown
# Research Timeline

## 2018-2019: Early Exploration
- [Paper A]: First proposal of method X
- [Paper B]: Introduction of technique Y

## 2020-2021: Method Maturation
- [Paper C]: Proposed SOTA method
- ...

## 2022-2023: New Trends
- [Paper D]: Began addressing problem Z
- ...

## Key Milestones
1. [Year]: [Event/Paper] - [Significance]
```

### 2.3 Taxonomy Design

Create `$WORKSPACE/review/taxonomy.md`:

```markdown
# Taxonomy of Approaches

## Dimension 1: Method Type
- Data-driven
  - Statistical (e.g., GPR, SVM)
  - Deep Learning
    - CNN-based
    - RNN/LSTM-based
    - Transformer-based
  - Hybrid
- Model-based
  - Electrochemical
  - Equivalent Circuit

## Dimension 2: Data Source
- Laboratory Data
- Real-world Driving Data
- Synthetic Data

## Dimension 3: Prediction Horizon
- Short-term (< 100 cycles)
- Medium-term (100-500 cycles)
- Long-term (> 500 cycles)
```

## Phase 3: Writing Structure

### 3.1 Survey Paper Template

Create `$WORKSPACE/review/draft.md` using template in `references/survey-template.md`.

Key sections: Abstract -> Introduction -> Background -> Taxonomy -> Comparison -> Datasets -> Future Directions -> Conclusion

### 3.2 Thesis Literature Review Template

For a thesis chapter:
```markdown
# Chapter 2: Literature Review
## 2.1 Introduction
## 2.2 [Topic Area 1]
## 2.3 [Topic Area 2]
## 2.4 Summary and Research Gaps
```

## Phase 4: Writing Tips

### Citation Density Guidelines

| Section | Citation Density |
|---------|------------------|
| Abstract | 0 citations |
| Introduction | 10-20 citations |
| Background | 5-10 citations |
| Main Survey | 50-100+ citations |
| Conclusion | 2-5 citations |

### Transition Phrases

**Introducing similar work:**
- "Similarly, [Author] proposed..."
- "Following this direction, ..."
- "Building upon [X], [Author] extended..."

**Introducing contrasting work:**
- "In contrast, [Author] argued..."
- "However, [Author] took a different approach..."
- "Unlike previous methods, ..."

**Summarizing:**
- "In summary, existing methods can be categorized into..."
- "The key insight from these works is..."

### Common Mistakes to Avoid

1. **List-style writing** - Don't just say "A did X, B did Y, C did Z"
2. **Lack of comparison** - Analyze relationships and differences between methods
3. **Tense confusion** - Use present tense for methods, past tense for results
4. **Over-citing** - Not every sentence needs a citation
5. **Missing important work** - Ensure coverage of foundational works in the field

## Output Files

```
$WORKSPACE/review/
├── reading_plan.md       # Reading plan
├── notes/                # Reading notes
│   ├── {paper_id}.md
│   └── ...
├── comparison.md         # Comparison table
├── timeline.md           # Timeline analysis
├── taxonomy.md           # Taxonomy
├── draft.md              # Review draft
└── bibliography.bib      # References
```

## Commands

- "Help me write a review" -> Full workflow from reading to writing
- "Generate reading plan" -> Create reading_plan.md
- "Compare these papers" -> Generate comparison.md
- "Write review draft" -> Generate draft.md
- "Polish this section" -> Polish specific section

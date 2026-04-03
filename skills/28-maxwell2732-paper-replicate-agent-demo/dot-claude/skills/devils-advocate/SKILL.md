---
name: devils-advocate
description: Challenge a slide deck design with 5-7 specific pedagogical questions. Checks ordering, prerequisites, gaps, alternatives, notation conflicts, cognitive load, and book readiness.
disable-model-invocation: true
argument-hint: "[Lecture filename or topic description]"
allowed-tools: ["Read", "Grep", "Glob"]
---

# Devil's Advocate Review

Critically examine a slide deck and challenge its design with 5-7 specific pedagogical questions.

**Philosophy:** "We arrive at the best possible presentation through active dialogue."

---

## Setup

1. **Read the target file** (the lecture being challenged)
2. **Read the knowledge base** in `.claude/rules/` for notation conventions and narrative arc
3. If applicable, **read adjacent lectures** for narrative continuity

---

## Challenge Categories

Generate 5-7 challenges from these categories:

### 1. Ordering Challenges
> "Could students understand this better if we showed X before Y?"

### 2. Prerequisite Challenges
> "Do students have the background for this notation at this point?"

### 3. Gap Challenges
> "Should we include an intuitive example before this formal proof?"

### 4. Alternative Presentation Challenges
> "Here are 2 other ways to visualize/present this concept."

### 5. Notation Conflict Challenges
> "This symbol conflicts with earlier lecture usage."

### 6. Cognitive Load Challenges
> "This slide has too many new symbols. Can we split?"

### 7. Book Vision Challenges
> "If this becomes a book chapter, does this section stand alone?"

---

## Output Format

```markdown
# Devil's Advocate: [Lecture Title]

## Challenges

### Challenge 1: [Category] — [Short title]
**Question:** [The specific pedagogical question]
**Why it matters:** [What could go wrong]
**Suggested resolution:** [Specific action]
**Slides affected:** [Numbers or titles]
**Severity:** [High / Medium / Low]

[Repeat for 5-7 challenges]

## Summary Verdict
**Strengths:** [2-3 things done well]
**Critical changes:** [0-2 changes before teaching]
**Suggested improvements:** [2-3 nice-to-have changes]
```

---

## Principles

- **Be specific:** Reference exact slides and notation
- **Be constructive:** Every challenge has a suggested resolution
- **Be honest:** If the deck is good, say so
- **Prioritize:** Notation conflicts > missed metaphors
- **Think like a student:** Where do they get lost?

# Domain-Specific Deck Patterns

## Academic Seminar (60-90 minutes, critical audience)

### Recommended structure
1. **Title slide**
2. **The Puzzle** — one surprising fact or unanswered question. NOT "Motivation" with bullets.
3. **What This Paper Does** — one slide, three contributions max
4. **Related Literature** — why existing work is insufficient (not a list of papers)
5. **Data and Setting** — show the data visually, not just describe it
6. **Identification Strategy** — show the variation: a map, a timeline, an event study
7. **Main Results** — one coefficient prominent, supporting info subordinate
8. **Robustness** — key checks only. Full battery in appendix.
9. **Devil's Advocate** — strongest objection + your response. Builds credibility.
10. **Implications**
11. **Closing** — one takeaway, not "Questions?"

### Domain-specific rules
- Lead with the QUESTION, not the literature
- Identification strategy appears by slide 6 — skeptics want it early
- Regression tables: highlight 1-2 coefficients, not the full table
- Acknowledge limitations BEFORE Q&A — preempt Referee 2
- Every title is an assertion: "Policy X increased Y by Z%"
- Figures: readable from back row, treatment date marked, pre/post distinguished, key pattern annotated, confidence intervals shaded, title states the claim

---

## Teaching Lecture (50-75 minutes, learners)

### How this differs from a seminar
- **Clarity over compression** — more text per slide is acceptable because students take notes from slides
- **Repetition is OK** — learning requires revisiting concepts
- **Progressive revelation** — use `\pause` (Beamer overlays) for step-by-step derivations
- **Definitions get their own slides** with block environments
- **"Why does this matter?"** should appear frequently

### Domain-specific rules
- Font size floor is 18pt (lower than seminars because students sit closer)
- Bullet points are acceptable for lists of properties, axioms, or steps
- Show derivations step by step, not just final results
- Include worked examples
- Proofs use `align` environments revealed step by step with `\pause`

---

## Working Deck (coauthors, variable length)

### How this differs from external
- MORE detail is acceptable and expected
- Document choices: "We chose X over Y because..."
- Preserve uncertainty: "This could be Z but we haven't verified"
- Flag unknowns explicitly with a consistent visual marker (e.g., a colored box)
- Include data quality notes, merge diagnostics, sample construction details
- Regression tables can be fuller — coauthors will scrutinize
- Still follow visual hierarchy — dense does NOT mean ugly

### Domain-specific rules
- Titles still assert, but can be more technical
- Include appendix slides with backup analyses
- Date everything — assume forgotten context when revisited later
- Include the "why" behind methodological decisions

---

## The Dual Audience Problem

All decks increasingly circulate beyond their live audience. Strategies:
- **Assertion titles** carry the argument for readers who skim
- **Figures should be self-interpreting** — title, labels, annotations, source notes
- **Footnotes** in small text provide context for later readers
- **Appendix slides** after `\appendix` for backup material

---

## Opening and Closing Patterns

### Openings that work
- **The surprising number**: "In 2024, 47% of..." (big, centered, no decoration)
- **The puzzle**: "Why did X happen when theory predicts Y?"
- **The provocative claim**: "Everything we thought about Z is wrong."
- **The human story**: "When Maria arrived at the clinic..." (then zoom out to data)

### Openings that fail
- "Motivation" with four bullet points
- "Outline" listing every section
- "Thank you for inviting me to speak"

### Closings that work
- One sentence the audience will remember tomorrow
- A call to action or implication for their work
- A return to the opening puzzle, now resolved

### Closings that fail
- "Questions?"
- "Thank you!"
- A summary slide restating every finding

---

## The Devil's Advocate Slide

This is the most underused persuasion technique in academic presentations. It works because it builds credibility (ethos) through transparency:

1. State the strongest objection to your argument
2. Acknowledge what makes it compelling
3. Explain why it doesn't hold, or how you've addressed it

Format:
> "A skeptic would say: [strongest objection]"
> "This is a fair concern because [why it's reasonable]"
> "Here is how we address it: [your response]"

This should appear BEFORE Q&A, not as a response to it.

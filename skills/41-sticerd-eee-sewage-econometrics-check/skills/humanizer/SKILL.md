---
name: humanizer
description: Strip AI writing patterns from text. Checks 24 patterns across 4 categories (structural, lexical, rhetorical, formatting) with academic economics adaptation. This skill should be used on any text that reads too "AI-generated", or as a final pass on drafted sections. Triggers on "humanize", "de-AI", "make it sound natural", or "strip AI patterns".
argument-hint: "[file path to .tex, .md, .txt, or .qmd file]"
allowed-tools: ["Read", "Write", "Edit", "Grep", "Glob"]
---

# Humanizer

Strip AI writing patterns from academic text while preserving economics content and formal structure.

**Input:** `$ARGUMENTS` — path to file to humanize.

---

## Workflow

### Step 1: Read the File

Read the target file from `$ARGUMENTS`. Support `.tex`, `.md`, `.txt`, and `.qmd` files.

### Step 2: Scan for AI Patterns

Check all 24 patterns across 4 categories:

#### Category 1: Structural Tics (6 patterns)
1. **Triplet lists** — "X, Y, and Z" appearing 3+ times in a section
2. **Formulaic transitions** — "Moreover", "Furthermore", "Additionally" as sentence starters
3. **Echo conclusions** — final paragraph restates every point
4. **Uniform paragraph length** — all paragraphs suspiciously similar in length
5. **Topic sentence + support** — every paragraph follows identical structure
6. **Numbered/bulleted reasoning** — "First... Second... Third..." in prose

#### Category 2: Lexical Tells (6 patterns)
7. **"Delve"** — almost never used by humans in academic writing
8. **"Landscape"** — as metaphor ("the policy landscape")
9. **"Crucial/pivotal/vital"** — overused intensifiers
10. **"Multifaceted"** — AI favourite
11. **"Underscores"** — as verb ("this underscores the importance")
12. **"Navigate"** — metaphorical ("navigate the challenges")

#### Category 3: Rhetorical Patterns (6 patterns)
13. **Excessive hedging** — "it is worth noting", "interestingly", "arguably"
14. **Performative enthusiasm** — "fascinating", "remarkable", "exciting"
15. **False balance** — "while X, it is also true that Y" for every claim
16. **Hollow acknowledgment** — "this raises important questions" without answering them
17. **Premature synthesis** — summarising before enough evidence is presented
18. **Universal agreement** — "scholars agree", "it is widely recognised"

#### Category 4: Formatting Tells (6 patterns)
19. **Over-signposting** — "In this section, we will discuss..."
20. **Excessive parallelism** — every sentence in a list has identical structure
21. **Definitional opening** — starting sections with dictionary-style definitions
22. **Disclaimer stacking** — multiple caveats before making a point
23. **Summary before content** — "This section covers X, Y, and Z" at the start
24. **Colon-list pattern** — "There are three key factors: (1)... (2)... (3)..."

### Step 3: Apply Fixes

For each detected pattern:
1. Identify the specific instance with line number
2. Rewrite to sound more natural/human
3. Preserve the academic content and meaning

#### Academic Economics Adaptation Rules
- **Preserve formal structure** where genuinely needed (equations, proofs, identification arguments)
- **Keep technical terms** — do not simplify econometric vocabulary (heteroskedasticity-robust, LSOA fixed effects, hedonic pricing, etc.)
- **Maintain citation density** — do not remove scholarly references
- **Vary sentence structure** — mix short and long, simple and complex
- **Allow imperfection** — real writing has slight asymmetries and personality
- **Respect economics conventions** — "we estimate", "we find", "column (3) shows" are standard, not AI patterns
- **Keep LaTeX intact** — do not modify `\textcite{}`, `\parencite{}`, `\label{}`, `\ref{}`, or equation environments

### Step 4: Report Changes

Present a summary of changes:

```markdown
## Humanizer Report: [filename]
**Patterns found:** N / 24
**Changes made:** N

| # | Pattern | Category | Location | Change |
|---|---------|----------|----------|--------|
| 1 | Triplet lists | Structural | Section 3, para 2 | Varied list lengths |
| 2 | "Delve" | Lexical | Line 47 | Replaced with "examine" |
...
```

### Step 5: Save

Overwrite the original file with the humanised version (the user can review via `git diff`).

---

## Principles

- **Preserve meaning.** The content must be identical — only the expression changes.
- **Do not over-correct.** Some formal academic patterns are normal, not AI tells.
- **Context-aware.** "Moreover" in a proof derivation is fine. "Moreover" as every paragraph opener is not.
- **Reversible.** User can always `git checkout` to undo.
- **Light touch for good writing.** If only 2-3 patterns found, the text is probably fine. Focus effort on heavily AI-patterned text.
- **Economics-aware.** Standard economics phrasing ("we exploit variation in...", "we instrument...") is conventional, not AI-generated.

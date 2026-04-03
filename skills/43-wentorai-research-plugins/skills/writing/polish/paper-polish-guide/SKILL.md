---
name: paper-polish-guide
description: "Review and polish LaTeX research papers for clarity and style"
metadata:
  openclaw:
    emoji: "💎"
    category: "writing"
    subcategory: "polish"
    keywords: ["paper polishing", "academic editing", "LaTeX review", "writing quality", "style guide", "proofreading"]
    source: "wentor-research-plugins"
---

# Paper Polish Guide

## Overview

The difference between a good paper and a great paper often lies in the final polishing stage. After the scientific content is solid and the structure is sound, a thorough polish pass addresses clarity, conciseness, consistency, and correctness at the sentence and paragraph level. This is where awkward phrasing is smoothed, redundancies are eliminated, and the prose is tightened to convey ideas with maximum precision and minimum friction.

This skill provides a systematic approach to polishing research papers, with a particular focus on LaTeX manuscripts. It covers common writing issues in academic papers, a multi-pass review strategy, specific patterns to search for and fix, and tools that can assist the process. The techniques apply across all academic disciplines but include LaTeX-specific advice for formatting and typographic polish.

The skill is designed for the final stages of writing, after the content and structure are complete. It is not about rewriting sections—it is about refining the existing prose to its best possible form.

## Multi-Pass Review Strategy

Polish your paper in multiple focused passes rather than trying to fix everything at once. Each pass targets a specific aspect of the writing:

### Pass 1: Structural Coherence

Read each paragraph and check:
- Does the first sentence state the paragraph's main point?
- Does every subsequent sentence support or develop that point?
- Does the last sentence transition to the next paragraph?
- Could this paragraph be split into two (if it covers multiple ideas)?
- Could this paragraph be merged with an adjacent one (if it makes only a minor point)?

### Pass 2: Sentence-Level Clarity

Read each sentence and check:
- Is the subject of the sentence clear? Who or what is performing the action?
- Is the sentence shorter than 35 words? If not, split it.
- Are there any dangling modifiers or ambiguous pronoun references?
- Is the main verb strong and specific? Replace weak verbs ("is," "has," "makes") with precise ones.
- Is there unnecessary hedging? Remove "it should be noted that," "it is interesting that," "it is important to mention."

### Pass 3: Word-Level Precision

Review word choice throughout:
- **Eliminate redundancy**: "past history" → "history"; "future prospects" → "prospects"; "end result" → "result"
- **Prefer concrete over abstract**: "The algorithm processes data" → "The algorithm classifies images"
- **Remove filler words**: "very," "quite," "rather," "somewhat," "basically," "actually," "really"
- **Use precise quantifiers**: "many" → "47%"; "significantly" → "p < 0.01"; "fast" → "in 3.2 seconds"
- **Consistent terminology**: Pick one term for each concept and use it throughout. Do not alternate between "method," "approach," "technique," and "framework" for the same thing.

### Pass 4: LaTeX-Specific Polish

For LaTeX manuscripts, check these formatting details:

```latex
% Non-breaking spaces before citations and references
as shown in prior work~\cite{smith2024}
in Figure~\ref{fig:architecture}
in Table~\ref{tab:results}
in Section~\ref{sec:methods}

% Correct dash usage
pages 1--10       % en-dash for ranges
state-of-the-art  % hyphen for compound adjectives
--- and           % em-dash for parenthetical (or use --)

% Math mode consistency
$n$-dimensional   % variable in math mode even in text
$O(n \log n)$     % Big-O in math mode

% Consistent use of \emph{} vs \textit{}
% Use \emph{} for emphasis, \textit{} only when italic is the content (e.g., species names)
```

### Pass 5: Reference and Citation Check

- Every claim that is not your own contribution or common knowledge needs a citation
- Citations should be positioned at the end of the specific claim, not at the end of a paragraph about multiple claims
- Check that all `\cite{}` keys resolve to entries in your `.bib` file
- Verify that author names and years in the compiled PDF match the actual publications
- Ensure consistent citation style (Author (Year) vs. [Number])

## Common Patterns to Fix

### Wordy Constructions

| Wordy | Concise |
|-------|---------|
| "In order to" | "To" |
| "Due to the fact that" | "Because" |
| "A large number of" | "Many" |
| "In the event that" | "If" |
| "At the present time" | "Now" / "Currently" |
| "It is possible that" | "May" / "Could" |
| "Has the ability to" | "Can" |
| "With regard to" | "Regarding" / "About" |
| "For the purpose of" | "To" / "For" |
| "On the basis of" | "Based on" |

### Weak Sentence Openings

Avoid starting sentences with:
- "It is..." or "There are..." (expletive constructions) — Rewrite with a real subject
- "This" without a noun — "This shows..." → "This result shows..."
- "We can see that..." — Just state what is seen
- "As we know..." — If it is known, just state it

### Passive Voice Overuse

Academic writing traditionally uses passive voice, but overuse makes prose sluggish. Use active voice for your contributions and passive for standard procedures:

- Active (preferred for claims): "We propose a new architecture that..."
- Passive (acceptable for procedures): "The data were preprocessed using..."
- Passive (avoid): "It was found that the results were improved by..."
  → Active: "Our method improved results by..."

## Automated Assistance Tools

Complement manual review with these tools:

- **LaTeX linting**: Use `chktex` or `lacheck` to catch common LaTeX issues (missing tildes, inconsistent quotes, etc.)
- **Spell check**: Use `aspell` or your editor's built-in spell checker with a custom dictionary for technical terms
- **Style checking**: `textlint` or `writegood` can flag passive voice, weasel words, and other style issues
- **Grammar**: Grammarly or LanguageTool can catch grammatical errors, but review their suggestions critically—they sometimes "fix" correct academic constructions
- **Consistency checker**: Search your document for variant spellings ("dataset" vs "data set", "pretrained" vs "pre-trained") and standardize

```bash
# Find common issues with chktex
chktex -v3 main.tex

# Check spelling with aspell
aspell --mode=tex check main.tex

# Find inconsistent terminology
grep -n "data set\|dataset" main.tex
grep -n "pre-train\|pretrain" main.tex
```

## Final Quality Checklist

Before declaring the paper polished:

- [ ] No sentence exceeds 40 words
- [ ] No paragraph exceeds 200 words (with rare exceptions)
- [ ] All figures and tables are referenced in order
- [ ] Non-breaking spaces before all `\cite`, `\ref`, and `\eqref` commands
- [ ] Consistent number formatting (commas for thousands: 10,000 not 10000)
- [ ] Units separated from numbers by a thin space: `$3.2\,\text{ms}$`
- [ ] No orphaned or widowed lines (single lines at top/bottom of page)
- [ ] PDF renders correctly with all fonts embedded

## References

- Writing Style Guide: wentor-research-plugins
- Strunk, W. & White, E.B. "The Elements of Style"
- Zobel, J. "Writing for Computer Science" (Springer)
- Chktex LaTeX linter: https://www.nongnu.org/chktex/

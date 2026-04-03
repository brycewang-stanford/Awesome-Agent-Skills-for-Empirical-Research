# Compile Deck: Beamer Presentations Following the Rhetoric of Decks

*Beautiful slides are functional slides.*

---

## What This Skill Does

Compile Deck creates and compiles Beamer presentations following the **Rhetoric of Decks** philosophy — a set of non-negotiable constraints that produce slides where every element earns its presence.

**Invoke it with:** `/compiledeck topic-or-path-to-tex-file`

The skill handles the full workflow: audience and tone assessment → structure → LaTeX generation → compile → fix warnings → visual check → recompile until clean. It will not report success until the `.log` file shows zero overfull/underfull hbox warnings.

---

## The Philosophy

The full intellectual framework is in [`presentations/rhetoric_of_decks.md`](../../presentations/rhetoric_of_decks.md). The short version:

**Beauty is function.** A beautiful slide captures attention. Attention enables communication. There is no tension between aesthetics and effectiveness — they are the same thing.

**One idea per slide.** If a slide has two ideas, split it. No exceptions. If someone reads only the slide titles in sequence, they should understand the entire argument.

**Titles are assertions, not labels.**
- Bad: "Results"
- Good: "Treatment increased distance by 61 miles on average"

**MB/MC equivalence.** Every slide should have roughly the same marginal benefit relative to its cognitive cost. No slide should be a wall of text while another is nearly empty.

**Bullets are a confession.** They mean you haven't found the structure. Look for a sequence (flow diagram), a contrast (two columns), a hierarchy (size/color), or a causal chain (arrows).

---

## What the Skill Enforces

### Non-Negotiable Rules

- **One idea per slide** — split anything that has two
- **Titles are assertions** — the title sequence tells the full story
- **Typography minimums** — 24pt body text, 18pt absolute floor (footnotes)
- **No bullet lists unless unavoidable** — find the structure hiding in the list
- **Generous white space** — density is the enemy of clarity

### The Compile Loop

The skill will not stop until:
1. `pdflatex` runs without errors
2. The `.log` file (read directly, not grepped from terminal) shows zero overfull/underfull hbox warnings
3. TikZ coordinates are verified — no overlapping labels, no clipped text, no curves passing through annotation boxes

### TikZ Rules

See `tikz_rules.md` in `.claude/skills/compiledeck/` for the full collision-prevention protocol. The key rule: for any plotted curve, **calculate** the curve's y-value at each annotation's x-coordinate — never eyeball it. Clearance minimums: label↔label 0.3cm, label↔axis 0.3cm, any object↔slide edge 0.5cm.

---

## Palettes

The skill supports two tone modes:

**Professional/Academic** — Scott's house style for outward-facing work:
```latex
\definecolor{harvardcrimson}{HTML}{A51C30}  % Accent only
\definecolor{slate}{HTML}{4A5568}           % Primary text
\definecolor{charcoal}{HTML}{2D3748}        % Headers
\definecolor{forest}{HTML}{276749}          % Positive/success
\definecolor{ocean}{HTML}{2B6CB0}           % Links, emphasis
\definecolor{warmgray}{HTML}{718096}        % De-emphasized
\definecolor{lightbg}{HTML}{F7FAFC}         % Background tint
```
Crimson is accent only — never dominant. Authority through restraint.

**Colorful/Expressive** — something new each time. See `palette_reference.md` in `.claude/skills/compiledeck/` for options.

---

## Referee 2 and Compile Deck

Referee 2 has a **deck mode** (`/referee2 deck path/to/deck.tex`) that audits existing slide presentations for:
- Rhetoric compliance (one idea per slide, assertion titles)
- Compile cleanliness (reads the log directly, fixes all warnings)
- TikZ coordinate verification
- Visual overflow and label positioning

Compile Deck creates presentations following these rules from the start. Referee 2 audits them after. Both read from the same philosophy document (`presentations/rhetoric_of_decks.md`).

---

## Installation

The skill lives at `.claude/skills/compiledeck/SKILL.md`. Additional reference files in the same directory:
- `domain_patterns.md` — audience-specific guidance (seminar vs. lecture vs. working deck)
- `palette_reference.md` — color palette options
- `tikz_rules.md` — collision-prevention protocol for TikZ coordinates

See the [skills README](../README.md) for general installation instructions.

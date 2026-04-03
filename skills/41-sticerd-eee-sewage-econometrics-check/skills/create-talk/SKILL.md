---
name: create-talk
description: Generate Beamer presentations for the sewage-house-prices project by dispatching the Storyteller agent (creator) and Discussant agent (critic). Supports 4 formats — job market, seminar, short, lightning. Derives all content from the paper.
disable-model-invocation: true
argument-hint: "[format: job-market | seminar | short | lightning] [paper path (optional)]"
allowed-tools: ["Read", "Grep", "Glob", "Write", "Edit", "Task", "Bash"]
---

# Create Talk

Generate a Beamer presentation by dispatching the **Storyteller** (creator) and **Discussant** (critic).

**Input:** `$ARGUMENTS` — format name, optionally followed by paper path.

---

## Workflow

### Step 1: Parse Arguments

- **Format** (required): `job-market` | `seminar` | `short` | `lightning`
- **Paper path** (optional): defaults to `docs/overleaf/_main.tex`
- If no format specified, ask the user.

### Format Constraints

| Format | Slides | Duration | Content Scope |
|--------|--------|----------|---------------|
| Job market | 40-50 | 45-60 min | Full story, all results, mechanism, robustness |
| Seminar | 25-35 | 30-45 min | Motivation, main result, 2 robustness, conclusion |
| Short | 10-15 | 15 min | Question, method, key result, implication |
| Lightning | 3-5 | 5 min | Hook, one result, so-what |

### Step 2: Launch Storyteller Agent

Delegate to the `storyteller` agent via Task tool:

```
Prompt: Create a [format] talk from [paper].
Read the paper (docs/overleaf/_main.tex) and extract:
  - Research question: causal effect of sewage spills on house prices and rents in England
  - Data: EDM (Event Duration Monitoring) spill records 2021-2024+, Land Registry prices, Zoopla rentals
  - Identification strategy: hedonic pricing, repeat sales, long-difference, DiD/event study
  - Spatial matching: spill sites within radius (250m–10km) linked to properties
  - Key treatment variables: spill_count, spill_hrs, n_spill_sites, min_dist
  - Main results and effect sizes (house prices and rents separately)
  - Robustness checks: upstream/downstream, dry spill placebo, rainfall controls
  - Institutional context: England's water companies, EDM permit system, regulatory failure
  - Key figures: output/figures/, docs/overleaf/figures/, docs/overleaf/maps/
Design narrative arc for [format] format.
Build Beamer .tex file with shared preamble if available.
Compile with XeLaTeX.
Save to docs/conferences/[format]_talk.tex
```

The Storyteller follows these principles:
- One idea per slide
- Figures > tables (tables in backup); prefer maps and scatter plots from output/figures/
- Build tension: motivation (regulatory failure) → question → EDM data → method → findings → policy implications
- Transition slides between major sections
- All claims must appear in the paper (single source of truth)
- Treatment variable definitions (12/24hr counting) explained clearly on methods slide

### Step 3: Launch Discussant Agent (Talk Critic)

After Storyteller returns, delegate to the `discussant` agent:

```
Prompt: Review the talk at docs/conferences/[format]_talk.tex.
Check 5 categories:
  1. Narrative flow — does the story build properly from EDM data → identification → results?
  2. Visual quality — overflow, readability, consistency
  3. Content fidelity — every claim (coefficient, standard error, N) traceable to paper
  4. Scope for format — right amount of content for duration
  5. Compilation — does it compile cleanly?
Score as advisory (non-blocking).
Save report to docs/conferences/quality_reports/[format]_talk_review.md
```

### Step 4: Fix Critical Issues

If Discussant finds Critical issues (compilation failures, content not in paper):
1. Re-dispatch Storyteller with specific fixes (max 3 rounds)
2. Re-run Discussant to verify

### Step 5: Present Results

1. Generated `.tex` file path
2. Slide count and format compliance
3. Discussant score (advisory, non-blocking)
4. TODO items (missing figures, tables not yet generated)

---

## Output

Save to `docs/conferences/[format]_talk.tex` (e.g., `docs/conferences/seminar_talk.tex`).
Quality report to `docs/conferences/quality_reports/[format]_talk_review.md`.

---

## Principles

- **Paper is authoritative.** Every claim must appear in `docs/overleaf/_main.tex`.
- **Less is more.** Especially for short and lightning — ruthlessly cut.
- **Audience calibration.** Job market = identification rigor. Seminar = interesting result. Lightning = sell the idea.
- **Advisory scoring.** Talk scores don't block commits.
- **Worker-critic pairing.** Storyteller creates, Discussant critiques. Never skip the review.
- **Figures first.** Prefer maps (docs/overleaf/maps/), event study plots, and scatter plots over regression tables.

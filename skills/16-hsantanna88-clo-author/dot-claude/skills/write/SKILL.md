---
name: write
description: Draft academic paper sections with notation protocol, anti-hedging, and humanizer pass. Replaces /draft-paper and /humanizer.
argument-hint: "[section or mode: intro | strategy | results | conclusion | abstract | full | humanize] [file path (optional)]"
allowed-tools: Read,Grep,Glob,Write,Edit,Task
---

# Write

Draft paper sections or apply humanizer pass by dispatching the **Writer** agent.

**Input:** `$ARGUMENTS` — section name or mode, optionally followed by file path.

---

## Modes

### `/write [section]` — Draft Paper Section
Draft a specific section: `intro`, `strategy`, `results`, `conclusion`, `abstract`, or `full`.

**Agent:** Writer
**Output:** LaTeX section file in paper/sections/

Workflow:

#### 1. Context Gathering

Before drafting, read all available context:
1. Read existing paper draft in `paper/` (if it exists)
2. Read `master_supporting_docs/` for notes, outlines, research specs
3. Read most recent `quality_reports/research_spec_*.md` or `quality_reports/lit_review_*.md`
4. Read `.claude/references/domain-profile.md` for field conventions
5. Check `Bibliography_base.bib` for available citations
6. Scan `paper/tables/` and `paper/figures/` for generated output
7. Read `quality_reports/results_summary.md` if it exists (from Coder)

#### 2. Section Routing

Based on `$ARGUMENTS`:
- **`full`**: Draft all sections in sequence, pausing between major sections for user feedback
- **`intro`**: Draft introduction (most common request)
- **`strategy`**: Draft identification and estimation section
- **`results`**: Draft results from available output
- **`conclusion`**: Draft conclusion
- **`abstract`**: Draft abstract (must have other sections first)
- **No argument**: Ask user which section to draft

#### 3. Dispatch Writer

Dispatch Writer with section standards, notation protocol, and anti-hedging rules. Humanizer pass runs automatically before finalizing. Save to `paper/sections/[section].tex`.

#### 4. Quality Self-Check

Before presenting the draft:
- [ ] Every displayed equation is numbered (`\label{eq:...}`)
- [ ] All `\cite{}` keys exist in `Bibliography_base.bib`
- [ ] Introduction contribution paragraph names specific papers
- [ ] Effect sizes stated with units
- [ ] No banned hedging phrases
- [ ] Notation consistent throughout
- [ ] All tables/figures referenced actually exist in `paper/tables/` or `paper/figures/`

#### 5. Present to User

Present each section for feedback. Flag items that need attention:
- **TBD items:** Where empirical results are needed but not yet available
- **VERIFY items:** Citations that need user confirmation
- **PLACEHOLDER items:** Effect sizes awaiting final estimates

### `/write humanize [file]` — Humanizer Pass Only
Strip AI writing patterns from existing text without rewriting content.

**Agent:** Writer (humanizer mode)
**Output:** Edited file with AI patterns removed

Strips 24 patterns across 4 categories:
- Structural: forced narrative arcs, artificial progression
- Lexical: "delve,leverage,nuanced,robust"
- Rhetorical: rule-of-three, negative parallelisms, em dash overuse
- Formatting: excessive bullet points, promotional language

---

## Section Standards

| Section | Length | Key Requirements |
|---------|--------|-----------------|
| Introduction | 1000-1500 words | Hook → question → method → finding → contribution → roadmap |
| Strategy | 800-1200 words | Formal assumption, numbered equation, threats addressed |
| Results | 800-1500 words | Main spec, effect sizes in economic terms, heterogeneity |
| Conclusion | 500-700 words | Restate with effect size, policy, limitations, future |
| Abstract | 100-150 words | Question, method, finding with magnitude, implication |

---

## LaTeX Conventions

- `\citet{}` for textual citations ("Smith (2024) shows...")
- `\citep{}` for parenthetical citations ("...is well documented (Smith, 2024)")
- `booktabs` rules (`\toprule`, `\midrule`, `\bottomrule`) — never `\hline`
- Notation protocol: `Y_{it}`, `D_{it}`, `\gamma_i`, `\delta_t`, `\varepsilon_{it}`

---

## Principles
- **This is the user's paper, not Claude's.** Match their voice and style.
- **Never fabricate results.** Use TBD placeholders.
- **Citations must be verifiable.** Only cite confirmed papers.
- **Humanizer is automatic.** Every draft gets de-AI-ified.

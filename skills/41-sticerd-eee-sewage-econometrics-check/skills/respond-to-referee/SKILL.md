---
name: respond-to-referee
description: Structure point-by-point referee responses for the sewage-house-prices paper. Classifies each comment (NEW ANALYSIS / CLARIFICATION / REWRITE / DISAGREE / MINOR), produces a tracking document, drafts a response letter in LaTeX, and flags items needing new analysis or user judgment. This skill should be used when asked to "respond to referees", "draft revision", "address referee comments", or "R&R".
argument-hint: "[referee report file path]"
allowed-tools: ["Read", "Grep", "Glob", "Write", "Edit", "Agent"]
---

# Respond to Referee

Structure a point-by-point response to referee reports for the sewage-house-prices manuscript.

**Input:** `$ARGUMENTS` — path to referee report file(s).

---

## Project-Specific Context

### Manuscript
- Main document: `docs/overleaf/_main.tex`
- Sections: `docs/overleaf/*.tex`
- Bibliography: `docs/overleaf/refs.bib`

### Analysis
- Scripts: `scripts/R/09_analysis/`
- Tables: `output/tables/`
- Figures: `output/figures/`

### Common Referee Concerns for This Paper
- Short EDM panel (2021-2024) — limited time variation
- LSOA FE may not capture neighbourhood-level sorting
- Spill count vs hours as treatment — which matters more?
- External validity beyond England
- Dry spill identification — rainfall threshold sensitivity
- Multiple testing across 6 radii and multiple specifications

---

## Workflow

### Step 1: Parse Inputs

1. Read referee report(s) from `$ARGUMENTS`
2. Read the manuscript (`docs/overleaf/_main.tex` and section files)
3. Scan existing analysis scripts to know what already exists

### Step 2: Classify Every Comment

Assign each referee point a classification:

| Class | Action |
|-------|--------|
| **NEW ANALYSIS** | Flag for user — requires new R script or specification |
| **CLARIFICATION** | Draft revised text for the relevant section |
| **REWRITE** | Draft structural revision of a section |
| **DISAGREE** | Draft diplomatic pushback — flag for user review (mandatory) |
| **MINOR** | Draft fix directly (typos, formatting, minor edits) |

### Step 3: Build Tracking Document

Save to `output/log/referee_response_tracker.md`:

```markdown
# Referee Response Tracker
**Date:** YYYY-MM-DD
**Journal:** [if known]
**Decision:** [R&R / Major / Minor]

## Summary
- Referee 1: N comments (X new analysis, Y clarification, Z disagree, W minor)
- Referee 2: N comments (...)
- Editor: N comments (...)
- **Total new analyses required:** X

## Action Items (Priority Order)

### HIGH: New Analysis Required
| # | Ref | Point | Status |
|---|-----|-------|--------|
| 1 | R1.3 | [Brief] | TODO |

### MEDIUM: Clarification / Rewriting
| # | Ref | Point | Status |
|---|-----|-------|--------|
| 1 | R1.1 | [Brief] | TODO |

### FLAGGED: Disagreements (require user review)
| # | Ref | Point | Draft Response |
|---|-----|-------|---------------|
| 1 | R2.5 | [Brief] | [Draft] |

### LOW: Minor Edits
- [ ] R1.7: Fix typo on p. 12
```

### Step 4: Draft Response Letter

Generate LaTeX response letter:

```latex
\documentclass[12pt]{article}
\usepackage[margin=1in]{geometry}
\usepackage{xcolor}
\definecolor{response}{RGB}{0,0,128}

\begin{document}

\title{Response to Referee Reports: Sewage in Our Waters}
\author{[Authors]}
\date{\today}
\maketitle

Dear Editor,

We thank the editor and referees for their careful and constructive comments.
We have revised the manuscript to address all points raised.

\bigskip

\textbf{Summary of major changes:}
\begin{enumerate}
\item [Major change 1 — addresses R1.3, R2.1]
\item [Major change 2 — addresses R1.5]
\end{enumerate}

\newpage
\section*{Response to Referee 1}

\subsection*{Comment 1.1}
\textit{[Exact quote of referee comment]}

\medskip
\textcolor{response}{%
\textbf{Response:} [Draft response]

\textbf{Paper change:} [Section X, page Y]
}

\end{document}
```

Save to `output/log/referee_response_[date].tex`.

### Step 5: Diplomatic Disagreement Protocol

When classification is **DISAGREE**:
1. Open with acknowledgment of the referee's point
2. Provide specific evidence (data, results, published work)
3. Offer partial concession where possible
4. **Never say:** "The referee is wrong" or "misunderstood"
5. **Instead say:** "We respectfully note...", "Upon reflection, we believe..."
6. **FLAG prominently** for user review

---

## Principles

- **The response letter is the authors' voice.** Match their academic tone.
- **Never fabricate results.** Mark NEW ANALYSIS items as TBD until implemented.
- **Flag all DISAGREE items.** These need human judgment — never resolve disagreements autonomously.
- **Prioritize editor's comments.** The editor signals which concerns matter most.
- **Track everything.** Every referee comment appears in both tracker and response letter.

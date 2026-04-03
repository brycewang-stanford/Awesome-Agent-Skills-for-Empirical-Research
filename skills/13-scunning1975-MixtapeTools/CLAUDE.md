# CLAUDE.md Template for Research Projects

> Copy this file to your project root and fill in the sections below.

---

## Communication Guidelines

- Refer to the user as **[Your Name]**
- Collaborators: [List collaborators and their roles]

---

## Estimation Philosophy

**Design before results.** During estimation and analysis:

- Do NOT express concern or excitement about point estimates
- Do NOT interpret results as "good" or "bad" until the design is intentional
- Focus entirely on whether the specification is correct
- Results are meaningless until we're confident the "experiment" is designed on purpose
- Objectivity means being attached to getting the design right, not to any particular finding

---

## Project Overview

[2-3 paragraph description of your project]

### Research Question

[What are you trying to answer?]

### Data Sources

[What data are you using? Time periods? Geographic coverage?]

### Identification Strategy

[How are you identifying causal effects? What's the source of variation?]

---

## Key Decisions Made

Document important methodological decisions so AI maintains context:

| Date | Decision | Rationale |
|------|----------|-----------|
| YYYY-MM-DD | [What you decided] | [Why] |

---

## Dropped Analyses

Things you tried but abandoned (so AI doesn't suggest them again):

- **[Analysis name]**: [Why dropped]

---

## Key Files

- **Main analysis**: `path/to/script.R` or `script.py`
- **Data cleaning**: `path/to/cleaning.R`
- **Paper draft**: `path/to/paper.tex`
- **Presentation**: `path/to/slides.tex`

---

## Variable Definitions

[Define key variables, especially constructed ones]

| Variable | Definition | Source |
|----------|------------|--------|
| `treatment` | [How defined] | [Where from] |
| `outcome` | [How defined] | [Where from] |

---

## Sample Restrictions

[Who's in your sample and why? Who's excluded?]

---

## Meeting Schedule

[Regular meetings with collaborators, advisors, etc.]

---

## Current Status

**Phase**: [Data collection / Cleaning / Estimation / Writing / Revisions]

[Brief description of where you are]

---

## Referee 2 Correspondence

This project uses the Referee 2 audit protocol. Correspondence is stored at:

```
correspondence/referee2/
├── YYYY-MM-DD_round1_report.md      # Referee 2's detailed written report
├── YYYY-MM-DD_round1_deck.pdf       # Referee 2's visual presentation of findings
├── YYYY-MM-DD_round1_response.md    # Author's revision response
├── YYYY-MM-DD_round2_report.md      # Referee 2's second-round assessment
├── YYYY-MM-DD_round2_deck.pdf
└── ...
```

Replication scripts created by Referee 2 are stored at:
```
code/replication/
├── referee2_replicate_main_results.do
├── referee2_replicate_main_results.R
├── referee2_replicate_main_results.py
└── ...
```

**Current Status:** [Not yet audited / Round 1 complete / Round 2 in progress / Accepted]

**Critical Rule:** Referee 2 NEVER modifies author code. It only reads, runs, and creates its own replication scripts in `code/replication/`. Only the author (you) modifies your own code in response to referee concerns.

**Important:** Referee reports do NOT belong in this CLAUDE.md file. They are standalone documents in the correspondence directory. This section only tracks status.

---

## Notes for Claude

[Any specific instructions, quirks, or reminders]

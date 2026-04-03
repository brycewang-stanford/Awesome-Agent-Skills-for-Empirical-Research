---
name: target-journal
description: Journal targeting analysis for the sewage-house-prices paper. Recommends ranked journal list across 3 tiers with formatting requirements, submission strategy, and desk rejection risk assessment. This skill should be used when asked to "target a journal", "where should we submit", "journal fit", or "submission strategy".
argument-hint: "[optional: paper path or abstract text]"
allowed-tools: ["Read", "Grep", "Glob", "Write", "WebSearch", "WebFetch", "Agent"]
---

# Target Journal

Analyse the sewage-house-prices paper and recommend journals for submission.

**Input:** `$ARGUMENTS` — path to paper `.tex` file or abstract text. Defaults to `docs/overleaf/_main.tex`.

---

## Project-Specific Context

### Paper Profile
- **Topic:** Causal impact of sewage spills on house prices and rents
- **Country:** England
- **Data:** EDM (2021-2024+), Land Registry transactions, Zoopla rentals, Met Office rainfall
- **Methods:** Hedonic, repeat sales, long difference, DiD, upstream/downstream, dry spills
- **Contribution:** First paper to estimate sewage spill capitalisation using comprehensive EDM data

### Relevant Journal Landscape

**Tier 1 — General Interest (reach):**
AER, QJE, JPE, REStud, Econometrica (if methodological contribution warrants)

**Tier 2 — Strong Field:**
- Journal of Environmental Economics and Management (JEEM) — primary target for environmental capitalisation
- Journal of Urban Economics (JUE) — housing market focus
- Regional Science and Urban Economics (RSUE) — spatial analysis
- Journal of Real Estate Finance and Economics (JREFE) — property valuation
- Environmental and Resource Economics (ERE) — European environmental economics
- Ecological Economics (EE) — broader sustainability angle

**Tier 3 — Solid Alternatives:**
- JEEA — European applied economics
- Journal of Applied Econometrics — methodological emphasis
- Land Economics — natural resource / real estate
- Economics Letters — short-format results
- Environment and Planning B — policy-oriented
- Journal of Housing Economics — housing market specialisation

---

## Workflow

### Step 1: Context Gathering

1. Read the paper (or abstract) from `$ARGUMENTS` or `docs/overleaf/_main.tex`
2. Read existing manuscript sections for contribution framing
3. Check which analyses are complete (scan `output/tables/` and `output/figures/`)

### Step 2: Analyse Paper Fit

Extract:
- Primary contribution type (empirical, methodological, policy)
- Identification strategy strength
- Data novelty (EDM data availability)
- Scope and generalisability
- UK vs international relevance

### Step 3: Journal Recommendations (3 Tiers)

For each recommended journal:
- Why it fits this paper
- Recent similar publications in the journal
- Desk rejection risk (Low / Medium / High)
- Typical turnaround time
- Special considerations

### Step 4: Formatting Requirements (Top 3)

For the top 3 recommended journals:

| Requirement | Details |
|-------------|---------|
| Word/page limit | |
| Abstract limit | |
| Citation style | |
| LaTeX class | |
| Figure format | |
| Data availability | |
| Submission portal | |
| Double-blind | |

### Step 5: Submission Checklist

For the top journal choice:
- [ ] Manuscript formatting compliance
- [ ] Cover letter (addressed to current editor)
- [ ] JEL codes and keywords
- [ ] Data availability statement
- [ ] Replication package (if required at submission)
- [ ] Suggested/excluded referees

### Step 6: Strategic Notes

- **Desk rejection risk** — honest assessment by journal
- **Suggested referees** — 3-5 names with expertise in hedonic pricing, environmental valuation, or UK housing
- **Competing papers** — recent work on sewage/water quality and house prices
- **Resubmission strategy** — if rejected from Tier 2 primary, which journal next?
- **Timing** — any relevant deadlines or conference cycles

Save to `output/log/journal_targeting_[date].md`.

---

## Principles

- **Be honest about fit.** Don't suggest AER unless the contribution genuinely warrants it.
- **Field-specific knowledge.** JEEM and JUE are the natural homes — rank within that context.
- **Recent publications matter.** Check if journals recently published on water quality, pollution capitalisation, or UK housing.
- **The best journal is one that publishes the paper.** Don't over-optimise.
- **Formatting details change.** Flag any uncertain requirements for user verification.

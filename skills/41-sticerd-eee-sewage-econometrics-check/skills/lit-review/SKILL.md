---
name: lit-review
description: Structured literature search and synthesis for the sewage-house-prices project. Searches top-5 journals, field journals (JEEM, JUE, JREFE, EE), NBER/SSRN, and citation chains. Produces annotated bibliography with proximity scores, gap identification, and BibTeX entries. This skill should be used when asked to "review the literature", "find papers on X", or "lit review".
argument-hint: "[topic, paper title, or research question]"
allowed-tools: ["Read", "Grep", "Glob", "Write", "WebSearch", "WebFetch", "Agent"]
---

# Literature Review

Conduct a structured literature search and synthesis for the sewage-house-prices project.

**Input:** `$ARGUMENTS` — a topic, paper title, research question, or phenomenon.

---

## Project-Specific Context

### Core Literature Strands

1. **Environmental disamenity capitalisation** — Hedonic pricing of pollution, noise, flood risk on house prices
2. **Water quality and property values** — Clean/dirty water effects on housing markets
3. **UK water industry** — Privatisation, regulation, sewage overflows, EDM monitoring
4. **Hedonic pricing methodology** — Rosen (1974), Palmquist (1982), repeat sales, spatial approaches
5. **Infrastructure and house prices** — Transport, utilities, public goods capitalisation
6. **Rental market effects** — Disamenity capitalisation in rental vs owner-occupied markets
7. **Media and information effects** — How news coverage affects price discovery

### Target Journals (by tier)

**Tier 1 (General):** AER, Econometrica, QJE, JPE, REStud
**Tier 2 (Field):** JEEM, Journal of Urban Economics, Regional Science and Urban Economics, Journal of Real Estate Finance and Economics, Ecological Economics, Environmental and Resource Economics
**Tier 3 (Applied/Policy):** JEEA, Journal of Applied Econometrics, Economics Letters, Land Economics, Environment and Planning B

### Existing Bibliography
- Check `docs/overleaf/refs.bib` for papers already in the project
- Check `docs/lit_review/` for any literature notes

---

## Workflow

### Step 1: Context Gathering

1. Parse the topic from `$ARGUMENTS`
2. Read `docs/overleaf/refs.bib` for papers already in the project
3. Check the manuscript sections in `docs/overleaf/` for existing literature discussion

### Step 2: Search Protocol

Search in this order:
1. Top-5 general interest journals (AER, Econometrica, QJE, JPE, REStud)
2. Field journals (JEEM, JUE, RSUE, JREFE, EE, ERE)
3. NBER/SSRN/IZA working papers
4. Citation chains (forward + backward from key papers found)
5. UK-specific policy sources (Ofwat, Environment Agency, DEFRA)

Use web search to find recent and relevant papers.

### Step 3: Assess and Annotate

For each paper found, assign a proximity score (1-5):
- **1** = Directly competes (same question, similar data/method)
- **2** = Closely related (same outcome or same treatment, different context)
- **3** = Methodologically relevant (same identification strategy, different topic)
- **4** = Background context (theoretical foundation, institutional detail)
- **5** = Tangentially related

### Step 4: Identify Gaps

Check for:
- Missing seminal papers in hedonic pricing or environmental capitalisation
- Missing recent UK water quality studies
- Missing methodological context for the identification strategies used
- Coverage across journal quality tiers

### Step 5: Present Results

```markdown
# Literature Review: [Topic]
**Date:** YYYY-MM-DD
**Query:** [Original query]

## Summary
[2-3 paragraph overview of the state of the literature]

## Key Papers
### [Author (Year)] — [Short Title]
- **Journal:** [venue]
- **Proximity:** [1-5 score]
- **Contribution:** [1-2 sentences]
- **Identification:** [DiD / IV / RDD / hedonic / descriptive]
- **Key finding:** [result with effect size]
- **Relevance to sewage project:** [specific connection]

## Thematic Organization
### Environmental Disamenity Capitalisation
### Water Quality and Property Values
### Identification Strategy Literature
### UK Water Industry Context

## Gaps and Opportunities
1. [Gap 1 — what's missing and how our paper fills it]
2. [Gap 2]

## Research Frontier
### Active Debates
### Recent Working Papers
### Emerging Methods

## BibTeX Entries
```bibtex
@article{...}
```
```

Save to `output/log/lit_review_[topic].md`.

---

## Principles

- **Be honest about uncertainty.** If a citation cannot be verified, mark as `% UNVERIFIED`.
- **Prioritize published work** over working papers. Note publication status.
- **Do NOT fabricate citations.** Flag any uncertain details.
- **Identification strategy is key.** Always note how each paper identifies effects.
- **Effect sizes matter.** Report magnitudes, not just signs.
- **Project relevance.** Score proximity specifically to the sewage-house-prices question.

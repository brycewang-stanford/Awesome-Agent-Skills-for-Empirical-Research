---
name: draft-paper
description: Draft sections of the sewage-house-prices academic paper. Handles section drafting for the Overleaf LaTeX manuscript, notation protocol, anti-hedging, and humanizer pass. This skill should be used when asked to "draft the paper", "write up the results", "write the intro", or draft any section of the manuscript.
argument-hint: "[section: intro | background | motivating-evidence | instrument | research-question | results | conclusion | abstract | appendix | full] [optional notes]"
allowed-tools: ["Read", "Grep", "Glob", "Write", "Edit", "Agent"]
---

# Draft Paper

Draft a section (or full draft) of the "Sewage in Our Waters" academic paper on the causal impact of sewage spills on house prices and rents in England.

**Input:** `$ARGUMENTS` — section name optionally followed by specific instructions or notes.

---

## Project-Specific Context

### Paper Structure

The manuscript lives in `docs/overleaf/` with this structure:
- `_main.tex` — Master document (KOMA-Script `scrartcl`, APA biblatex, `libertinus` font)
- `01_introduction.tex` — Introduction
- `02_background_context.tex` — UK sewage policy and institutional background
- `03_motivating_evidence.tex` — Descriptive evidence and stylised facts
- `04_hydraulics_instrument.tex` — Hydraulic capacity instrument
- `05_research_question.tex` — Identification strategy and empirical specification
- `100_appendix_descriptives.tex` — Appendix: descriptive statistics
- `101_appendix_results.tex` — Appendix: supplementary results
- `102_appendix_dry_spills.tex` — Appendix: dry spill analysis
- `103_appendix_data.tex` — Appendix: data documentation
- `glossary.tex` — Glossary of terms
- `refs.bib` — Bibliography (APA style via `biblatex`)

### Generated Output

- `output/tables/*.tex` — Regression tables (modelsummary → LaTeX with tabularray)
- `output/figures/` — Figures (maps, event studies, scatter plots)
- `book/` — Quarto website with exploratory analysis (`.qmd` files)

### Econometric Approaches

The paper uses multiple identification strategies:
1. **Hedonic regressions** — Cross-sectional: spill count/hours (continuous + bins) × prior/full period, with LSOA FE
2. **Repeat sales** — Within-property variation (Palmquist 1982 approach)
3. **Long difference** — 250m grid-level changes, weighted/unweighted × all/exposed grids
4. **News/media DiD** — Google Trends and LexisNexis media coverage as treatment
5. **Upstream/downstream** — Directional spillover via river network topology
6. **Dry spills** — Spills occurring without rainfall as identification variation

### Key Variables and Notation

- Outcome: `log(price)` for sales, `log(rent)` for rentals
- Treatment: `spill_count`, `spill_hrs`, `spill_count_daily_avg`, `spill_hrs_daily_avg`
- Geography: `n_spill_sites` within radius, `min_dist` / `mean_dist` to nearest site
- Radii: 250m, 500m, 1000m, 2000m, 5000m, 10000m
- Fixed effects: LSOA (`lsoa`), MSOA (`msoa`), year-quarter
- Standard errors: heteroskedasticity-robust (`vcov = "hetero"`) via `fixest::feols()`

### LaTeX Conventions

- Citations: `\textcite{}` for textual, `\parencite{}` for parenthetical (APA biblatex)
- Tables: `tabularray` format with `booktabs`, `[H]` float placement
- Equations: numbered with `\label{eq:...}`

---

## Workflow

### Step 1: Context Gathering

Before drafting:
1. Read the existing section file in `docs/overleaf/` (if it exists)
2. Read `_main.tex` to understand document structure and preamble
3. Scan `output/tables/` for available regression output
4. Scan `output/figures/` for available figures
5. Check `refs.bib` for available citations
6. Read relevant `.qmd` files in `book/` for analysis context and results interpretation
7. Read relevant analysis scripts in `scripts/R/09_analysis/` for methodology details

### Step 2: Section Routing

Based on `$ARGUMENTS`:
- **`intro`**: Draft `01_introduction.tex`
- **`background`**: Draft `02_background_context.tex`
- **`motivating-evidence`**: Draft `03_motivating_evidence.tex`
- **`instrument`**: Draft `04_hydraulics_instrument.tex`
- **`research-question`**: Draft `05_research_question.tex`
- **`results`**: Draft results section(s) from regression output
- **`conclusion`**: Draft conclusion
- **`abstract`**: Draft abstract (requires other sections to exist)
- **`appendix`**: Draft or extend appendix sections
- **`full`**: Draft all sections in sequence, pausing between for user feedback
- **No argument**: Ask which section to draft

### Step 3: Drafting Standards

#### Introduction (~1,000-1,500 words)
- Hook with UK sewage crisis context → research question → methodology overview → key findings → contribution → road map
- Contribution paragraph names specific papers being advanced (environmental disamenity capitalisation, hedonic pricing literature)
- Effect sizes with magnitudes and units (percentage impact on house prices per additional spill)

#### Background & Context (~800-1,200 words)
- UK privatised water industry structure
- EDM monitoring requirements and data availability (2021+)
- Scale of the sewage spill problem
- Policy and regulatory responses

#### Empirical Strategy (~800-1,200 words)
- Identification assumption stated formally
- Estimating equation displayed and numbered
- Each approach (hedonic, repeat sales, long diff) with clear specification
- Threats to identification addressed (sorting, omitted variables, measurement error)

#### Results (~800-1,500 words per approach)
- Main specification with economic interpretation
- Effect sizes in meaningful terms (£ impact, percentage change)
- Robustness across radii, time periods, and specifications
- Heterogeneity results

#### Conclusion (~500-700 words)
- Restate headline effect sizes
- Policy implications for water regulation
- Limitations and future work (rental market, long-run effects)

### Step 4: Humanizer Pass

Apply automatically as final pass:
- Strip AI writing patterns (see `/humanizer` skill for full 24-pattern checklist)
- Preserve formal academic structure where genuinely needed
- Maintain citation density and technical vocabulary

### Step 5: Quality Self-Check

Before presenting the draft:
- [ ] Every displayed equation is numbered (`\label{eq:...}`)
- [ ] All `\textcite{}` / `\parencite{}` keys exist in `refs.bib`
- [ ] Effect sizes stated with units and magnitudes
- [ ] No banned hedging phrases ("interestingly", "it is worth noting")
- [ ] Notation consistent with project conventions (LSOA, MSOA, radius distances)
- [ ] All referenced tables/figures actually exist in `output/`
- [ ] LaTeX compiles cleanly with the KOMA-Script setup

### Step 6: Present to User

Present each section for feedback. Flag:
- **TBD:** Where empirical results are needed but not yet available
- **VERIFY:** Citations that need user confirmation
- **PLACEHOLDER:** Effect sizes awaiting final estimates

---

## Principles

- **This is the authors' paper (Balboni & Dhingra), not Claude's.** Match their voice and style from existing sections.
- **Never fabricate results.** Use TBD placeholders. Cross-check numbers against `output/tables/`.
- **Citations must be verifiable.** Only cite papers confirmed in `refs.bib` or the literature review in `docs/lit_review/`.
- **Humanizer is automatic.** Every draft gets de-AI-ified before presentation.
- **Match existing conventions.** Read existing `.tex` files first to match style, formatting, and level of formality.

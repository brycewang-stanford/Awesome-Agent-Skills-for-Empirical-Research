# Journal-Specific Formatting Reference

## Economics — Top 5

| Feature | AER | Econometrica | QJE | JPE | ReStud |
|---------|-----|-------------|-----|-----|--------|
| Spacing | 1.5 | Double | Double | Double | Double |
| Abstract limit | 100 words | 150 words | None stated | 100 words | 150 words |
| Page limit | None | None | None | None | None |
| Math notation | Standard LaTeX | Numbered theorems, proof environments required | Standard LaTeX | Standard LaTeX | Standard LaTeX |
| SE reporting | Parentheses | Parentheses | Parentheses or brackets | Parentheses | Parentheses |
| Stars convention | Standard 1/5/10% | Discouraged in some areas | Discouraged — report exact p-values | Standard 1/5/10% | Standard 1/5/10% |
| Figures format | PDF/EPS | PDF/EPS | PDF/EPS | PDF/EPS | PDF/EPS |
| Online appendix | Yes, separate | Yes, separate supplement | Yes, separate | Yes, separate | Yes, separate |
| Submission system | Editorial Express | Editorial Express | ScholarOne | ScholarOne | Editorial Express |
| Anonymized | Yes | Yes | Yes | Yes | Yes |
| Replication package | AEA Data Editor review, required at acceptance | Required at acceptance | Required at acceptance | Required at acceptance | Required at acceptance |

**AER specifics:**
- 1.5-line spacing (unusual — most journals want double).
- AEA journals (AER, AEJ: Applied, AEJ: Policy, AEJ: Macro, AEJ: Micro) share the same data and code availability policy. Replication packages are reviewed by the AEA Data Editor before final acceptance.
- Use `\documentclass[12pt]{article}` with `\usepackage{setspace}\onehalfspacing`.
- JEL codes required. Keywords optional.

**Econometrica specifics:**
- Formal proof environments required for theoretical results. Use `\begin{theorem}...\end{theorem}`, `\begin{proof}...\end{proof}`.
- Number all assumptions, theorems, lemmas, propositions, and corollaries consecutively.
- Regularity conditions must be stated explicitly, not buried in footnotes.
- Supplemental Material is the standard term (not "Online Appendix").
- Uses the Econometric Society's LaTeX class `ecta.cls` for final publication (not required for submission, but available).

**QJE specifics:**
- No significance stars preferred — report coefficients and standard errors; let readers judge significance.
- Tends to favor papers with clean natural experiments and policy relevance.
- No strict page limit, but papers over 60 pages are unusual.
- ScholarOne submission system.

**JPE specifics:**
- University of Chicago Press formatting for accepted papers.
- Relatively strict on exposition quality — clear, concise writing valued.
- ScholarOne submission system.
- Generally expects structural or quasi-experimental work with clear economic content.

**ReStud specifics:**
- Editorial Express submission.
- Known for long review times (6-12 months common).
- Strong emphasis on theoretical contribution even in empirical papers.

---

## Economics — AEJ Journals

| Feature | AEJ: Applied | AEJ: Policy | AEJ: Macro | AEJ: Micro |
|---------|-------------|-------------|------------|------------|
| Focus | Empirical applied micro | Policy evaluation | Macro empirical/theory | Micro theory + empirical |
| Spacing | 1.5 | 1.5 | 1.5 | 1.5 |
| Page limit | None | None | None | None |
| Replication | AEA Data Editor | AEA Data Editor | AEA Data Editor | AEA Data Editor |
| Turnaround | 3-6 months | 3-6 months | 3-6 months | 3-6 months |

All AEJ journals follow AEA-wide policies on data availability, formatting, and submission through Editorial Express.

---

## Economics — Field Journals

| Feature | JHR | JDE | JOLE | JUE | JEEA |
|---------|-----|-----|------|-----|------|
| Focus | Human resources, labor, education, health | Development economics | Labor economics | Urban economics | European economic research |
| Spacing | Double | Double | Double | Double | Double |
| Abstract limit | 100 words | 100 words | 150 words | 100 words | 100 words |
| Submission system | ScholarOne | Editorial Manager (Elsevier) | ScholarOne | Editorial Manager (Elsevier) | ScholarOne |
| Formatting | Standard LaTeX/Word | Elsevier template available | Standard LaTeX | Elsevier template available | Standard LaTeX |
| Special notes | JEL codes required | Requires IRB/ethics statement for field experiments | — | — | — |

---

## Finance — Top Journals

| Feature | JF | JFE | RFS |
|---------|-----|-----|-----|
| Focus | Broad finance | Corporate, asset pricing, financial institutions | Broad finance, slightly more theoretical |
| Spacing | Double | Double | Double |
| Abstract limit | 200 words | 200 words | 200 words |
| Submission system | ScholarOne | SSRN/Editorial Manager | ScholarOne |
| Special requirement | — | **Highlights**: 3-5 bullet points summarizing key findings (required at submission) | — |
| Internet appendix | Yes | Yes | Yes, called "Internet Appendix" |
| Stars convention | Standard 1/5/10% | Standard 1/5/10% | Standard 1/5/10% |

**JFE specifics:**
- Requires "Highlights" — 3-5 bullet point findings, each under 85 characters.
- Uses Elsevier Editorial Manager.
- Data availability statement required.
- Relatively fast turnaround (3-4 months for first decision).

**JF specifics:**
- American Finance Association journal.
- ScholarOne submission.
- Associate Editor system: the AE writes a recommendation letter that the Editor often follows closely.

**RFS specifics:**
- Dual submission with conferences (e.g., SFS Cavalcade) sometimes fast-tracked.
- Internet Appendix is the standard term for supplementary material.

---

## Political Science

| Feature | APSR | AJPS | JOP | Political Analysis |
|---------|------|------|-----|--------------------|
| Focus | Broad political science | Broad political science | Broad political science | Quantitative methods for polisci |
| Abstract format | **Structured**: separate sections for purpose, methods, results | **Structured** | Standard | Standard |
| Word limit | 12,000 words (including notes, excluding references) | 10,000 words | 10,000 words | 10,000 words |
| Anonymized | Yes | Yes | Yes | Yes |
| Replication | Dataverse deposit required at acceptance | Dataverse deposit | Dataverse deposit | Dataverse deposit |
| Submission system | ScholarOne | Editorial Manager | ScholarOne | ScholarOne |

**APSR/AJPS structured abstract:**
Both require a structured abstract with clearly labeled sections. Typical format:
```
Purpose: [What question does this paper address?]
Design/Methods: [What data and methods are used?]
Findings: [What are the main results?]
Value: [What is the contribution?]
```

**Political Analysis specifics:**
- Methods journal — emphasis on methodological innovation with political science application.
- Code and data must be deposited in the Political Analysis Dataverse.
- LaTeX or Word accepted, but LaTeX strongly preferred for mathematical content.

---

## Sociology

| Feature | ASR | AJS |
|---------|-----|-----|
| Focus | Broad sociology | Broad sociology, slightly more theoretical |
| Word limit | 11,000 words (text + notes) | 12,000-15,000 words |
| Abstract limit | 200 words | 200 words |
| Spacing | Double | Double |
| Anonymized | Yes | Yes |
| Submission system | ScholarOne | Editorial Manager |
| Formatting notes | ASA style (author-date citations) | Chicago style |

**Key differences from econ journals:**
- Sociology journals use author-date citation format (Smith 2020), not numbered references.
- Tables include descriptive statistics more prominently.
- Variable names in tables use plain English (not shorthand abbreviations).
- Discussion sections are longer and more interpretive.
- Word limits are strictly enforced.

---

## Marketing

| Feature | Marketing Science | JMR | JCR |
|---------|-------------------|-----|-----|
| Focus | Quantitative marketing, structural models | Broad marketing research | Consumer behavior |
| Spacing | Double | Double | Double |
| Submission system | ScholarOne | ScholarOne | ScholarOne |
| Special notes | Welcomes structural estimation, field experiments | Requires managerial implications section | Primarily behavioral/experimental |
| Replication | Code sharing encouraged | Code sharing encouraged | — |

**Marketing Science specifics:**
- Strong tradition of structural empirical modeling (BLP-style demand, dynamic models).
- Accepts longer papers than most econ journals.
- Requires a "managerial relevance" statement in many cases.
- Closely related to economics in methods but distinct in framing.

---

## Statistics

| Feature | JASA | Annals of Statistics | Biometrika | JRSS-B |
|---------|------|---------------------|------------|--------|
| Focus | Applied and theoretical statistics | Theoretical statistics | Statistical methodology | Statistical methodology |
| Spacing | Double | Double | Double | Double |
| Abstract limit | 200 words | 100 words | 200 words | 200 words |
| Page limit | ~30 pages (main), supplement OK | ~30 pages | ~20 pages | ~25 pages |
| Submission system | ScholarOne | IMS system | Editorial Manager | ScholarOne |
| Supplement | Yes | Yes | Yes | Yes |

**JASA specifics:**
- Two tracks: "Applications and Case Studies" (applied) and "Theory and Methods" (methodology).
- The applied track requires genuine data analysis, not just simulations.
- The theory track requires mathematical proofs.
- Supplementary materials can be extensive.

**Annals of Statistics specifics:**
- Purely theoretical — proofs are the core contribution.
- Very high bar for theoretical novelty.
- IMS (Institute of Mathematical Statistics) format.
- LaTeX required, use `imsart.cls`.

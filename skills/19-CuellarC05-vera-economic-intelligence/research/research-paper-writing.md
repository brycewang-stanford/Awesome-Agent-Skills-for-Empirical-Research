
---
name: research-paper-writing
description: Structured workflow for planning, drafting and refining research papers and academic articles. It helps applied economists design strong research, prepare reproducible analysis and produce manuscripts suitable for journals or conference presentations.
category: writing
trigger:
  - "write a research paper"
  - "journal article"
  - "academic paper"
  - "submit to journal"
  - "draft a thesis chapter"
output:
  - research_paper_outline
  - draft_sections
  - final_manuscript
success_criteria:
  - research question is clear, novel and policy‑relevant
  - methodology and data are well‑documented and reproducible
  - results are correctly interpreted and discussed
  - paper complies with submission guidelines and meets the needs of reviewers and readers
---

# Research Paper Writing Workflow

This skill guides you through the stages of planning, drafting and finalizing a research paper.  It is designed for applied economic and policy research, such as studies on childcare affordability, maternal labor supply, regional labor markets or AI adoption.  The workflow emphasizes clear research design, rigorous analysis and effective communication.

## Stage 1 — Concept and Literature Review

### Define the Research Question
Work with the user to articulate a precise question.  Consider:
- Why is this question important?  How does it relate to economic theory and policy debates?
- What population, region or time period will be studied?
- What hypotheses or mechanisms will be tested?

### Preliminary Literature Review
Assist in identifying key papers, reports and datasets related to the topic.  Encourage the user to summarize how their work will contribute to existing knowledge.  If connected tools are available, offer to search academic databases or fetch relevant articles.

### Feasibility and Data Assessment
Discuss data availability.  Will the project use national surveys (e.g. ACS), administrative data, or proprietary sources?  Assess whether the data have the variables necessary to answer the question.  Identify potential challenges in measurement, sample selection or merging datasets.

## Stage 2 — Data and Methods

### Data Preparation Plan
Outline a strategy for cleaning and preparing data:
- Define units of analysis (individuals, counties, jobs).
- Plan variable construction, crosswalks and index building (e.g. childcare affordability index).
- Document any sample restrictions or weighting schemes.

### Methodological Framework
Select appropriate methods based on the research question:
- Econometric models (OLS, probit, multilevel models).
- Causal inference methods (difference‑in‑differences, regression discontinuity, instrumental variables).
- Machine learning methods for prediction or pattern detection.
- Structural models if behavioral responses need to be simulated.

Ensure that identification assumptions are clear and discuss potential threats.

## Stage 3 — Analysis and Writing

### Analysis Execution
Guide the user through the execution of their analysis:
- Run descriptive statistics and exploratory plots to understand the data.
- Estimate econometric models or train machine learning models.
- Conduct robustness checks, sensitivity analyses and subgroup analyses.
- Interpret results in light of economic theory and policy relevance.

### Drafting the Manuscript
Use the document co‑authoring skill to structure the paper:
- **Introduction:** Motivate the research question and summarize key findings.
- **Literature Review:** Situate the work in the existing literature.
- **Data and Methods:** Describe data sources, variable construction and empirical strategy.
- **Results:** Present tables, figures and narrative interpretation.
- **Discussion:** Explain implications for policy, theory and future research.
- **Conclusion:** Summarize contributions and suggest next steps.

Iterate on each section with the user until they are satisfied.

## Stage 4 — Revision and Submission

### Internal Review
Encourage the user to have colleagues or advisors read the manuscript.  Address their feedback and revise accordingly.

### Formatting and Compliance
Ensure that the paper meets the formatting guidelines of the target journal or conference (e.g. citation style, section headings, table formats).

### Cover Letter and Submission
Help craft a concise cover letter explaining the paper’s contribution and fit for the venue.  Prepare required files (manuscript, appendices, replication code) and assist with the submission process if needed.

## Stage 5 — Post‑Submission and Publication

If reviewers request revisions:
- Analyze reviewer comments and plan responses.
- Revise the manuscript, highlight changes and prepare a response letter.
After acceptance:
- Provide final proofs, address copyediting queries and promote the published research through presentations, blogs or policy briefs.

## Conclusion

Following this structured workflow will help produce high‑quality research papers that advance knowledge and inform policy.  The assistant serves as a collaborator in planning, analysis and writing, ensuring methodological rigor and clarity of communication.

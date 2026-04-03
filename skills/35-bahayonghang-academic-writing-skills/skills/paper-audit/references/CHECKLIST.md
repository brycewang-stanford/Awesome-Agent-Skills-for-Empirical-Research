# Pre-Submission Checklists

Consolidated checklists for paper audit across venues.

## Universal Checklist (All Venues)

### Compilation & Formatting
- [ ] Paper compiles without errors
- [ ] No overfull/underfull hbox warnings (LaTeX)
- [ ] Page limit respected (excluding references)
- [ ] Correct style file / template used
- [ ] Consistent font sizes and margins

### Content Integrity
- [ ] No placeholder text (TODO, FIXME, XXX)
- [ ] All figures referenced in text
- [ ] All tables referenced in text
- [ ] No orphaned citations (every `\cite` has a bib entry)
- [ ] No unused bibliography entries
- [ ] All equations referenced if numbered
- [ ] Consistent notation throughout

### Writing Quality
- [ ] All acronyms defined on first use
- [ ] No overly long sentences (> 60 words)
- [ ] Abstract is self-contained
- [ ] Abstract contains all 5 structural elements (Background / Objective / Methods / Results / Conclusion)
- [ ] Abstract Results section includes at least one quantitative finding
- [ ] Abstract within venue word count limit
- [ ] Contributions clearly stated in introduction
- [ ] No citation stacking in Introduction/Related Work (max 2 clustered citations per sentence without individual discussion)
- [ ] Limitations section included
- [ ] Figure/Table captions are concise, without AI-like redundancy, and use consistent casing
- [ ] Tables use three-line format (booktabs / no vertical lines)
- [ ] Table captions placed above table, notes placed below
- [ ] Number precision consistent within each table column
- [ ] Statistical significance markers defined in table note when used
- [ ] Literature review uses thematic organization, not author/year enumeration (A1)
- [ ] Each literature theme cluster ends with critical analysis (A2)
- [ ] Related Work concludes with explicit research gap derivation (A3)
- [ ] Discussion contains causal/attribution analysis, not just data repetition (B3)
- [ ] Related Work citations reappear in Discussion for results contextualization (B4)
- [ ] Conclusion contains all three elements: findings summary + implications + limitations/future work (B5)
- [ ] Introduction contribution claims are answered in Conclusion (C3)

### Theory & Conceptual Framework
- [ ] Core theoretical concepts defined clearly and unambiguously (A5)
- [ ] Theoretical framework engages with existing theories, not just cites them (A6)
- [ ] Paper's theoretical contribution is identifiable and stated explicitly (A7)
- [ ] Research gap is genuine and supported by literature evidence, not fabricated by selective citation

### Qualitative Methodology (apply when paper uses qualitative or mixed methods)
- [ ] Sampling strategy described with theoretical/methodological rationale (B6)
- [ ] Data saturation discussed or sample size justified (B7)
- [ ] Coding/analysis process described with sufficient detail: stages, coders, examples (B8)
- [ ] Trustworthiness strategies reported (triangulation, member checking, audit trail, etc.) (B9)
- [ ] Researcher reflexivity addressed for studies involving human participants or sensitive topics (B10)

### Experiment Analysis
- [ ] Experiment section uses cohesive paragraph narratives, not itemized lists
- [ ] Appropriate, up-to-date SOTA baseline methods are included and justified
- [ ] Ablation studies effectively validate the contribution of core components
- [ ] Statistical significance/confidence intervals are reported where applicable

### Submission Compliance
- [ ] Anonymous submission (no author names in blind review)
- [ ] Supplementary material within size limits
- [ ] Code submission prepared (if applicable)
- [ ] Ethics review flagged if applicable

## NeurIPS Specific

- [ ] Paper checklist completed (Appendix)
- [ ] Broader Impact Statement included
- [ ] Lay summary prepared (for accepted papers)
- [ ] Main paper <= 9 pages (+ unlimited references/appendix)
- [ ] Uses official NeurIPS style file
- [ ] Reproducibility details: random seeds, compute, datasets
- [ ] Error bars included with methodology specified
- [ ] Statistical significance tests where appropriate
- [ ] Dataset licensing and consent documented
- [ ] Potential negative societal impacts discussed
- [ ] Comparison with appropriate baselines
- [ ] Ablation studies for key design choices

## ICLR Specific

- [ ] Uses official ICLR style file
- [ ] Double-blind review compliance
- [ ] Main paper <= 10 pages (+ unlimited appendix)
- [ ] Reproducibility statement included
- [ ] Code submission URL provided (if applicable)

## ICML Specific

- [ ] Uses official ICML style file
- [ ] Main paper <= 8 pages (+ unlimited appendix)
- [ ] Impact statement included
- [ ] Supplementary <= 50MB

## IEEE Specific

- [ ] IEEE style file used (conference or journal)
- [ ] Abstract <= 250 words
- [ ] Keywords provided (3-5 terms)
- [ ] References follow IEEE format
- [ ] Figure captions below figures, table captions above tables
- [ ] All figures are high resolution (>= 300 DPI)
- [ ] No floating `algorithm` / `algorithm2e` environment in IEEE pseudocode
- [ ] Pseudocode blocks use a caption and label
- [ ] Pseudocode blocks are referenced in text before appearing
- [ ] Pseudocode line numbers are enabled when helpful for review (recommended, not mandatory)
- [ ] Pseudocode comments are short; paragraph-level explanation stays in the main text

## ACM Specific

- [ ] ACM Computing Classification System (CCS) concepts included
- [ ] ACM Reference Format citation in footer
- [ ] Uses `acmart` document class
- [ ] Rights management information included

## Chinese Thesis Specific (中文学位论文)

- [ ] Bibliography follows GB/T 7714-2015 standard
- [ ] Chinese abstract and English abstract both present
- [ ] Abstract bilingual consistency verified
- [ ] Full-width punctuation used in Chinese text
- [ ] Half-width punctuation used in English text and formulas
- [ ] University template compliance verified
- [ ] Declaration of originality included
- [ ] Acknowledgments section present
- [ ] Keywords in both Chinese and English
- [ ] No author/year enumeration pattern in literature review (A1-ZH: "张三（2019）提出..." consecutive pattern)

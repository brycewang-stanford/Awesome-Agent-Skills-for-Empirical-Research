---
name: in-depth-research-guide
description: "Structured methodology for conducting exhaustive multi-source investigations"
metadata:
  openclaw:
    emoji: "🔬"
    category: "research"
    subcategory: "deep-research"
    keywords: ["deep research", "systematic investigation", "multi-source research", "evidence synthesis", "research methodology", "source evaluation"]
    source: "wentor-research-plugins"
---

# In-Depth Research Methodology

## Overview

In-depth research goes beyond surface-level literature review to conduct exhaustive, multi-source investigations that synthesize evidence from academic papers, grey literature, industry reports, datasets, and primary sources. This methodology is used when a research question requires comprehensive coverage — for systematic reviews, policy briefs, competitive analyses, or foundational literature surveys in a new research direction.

## The 5-Phase Investigation Framework

### Phase 1: Scope Definition (10% of effort)

Before searching, define boundaries explicitly:

```markdown
## Research Brief Template

**Central Question**: [One sentence, specific and falsifiable]
**Sub-Questions** (3-5):
  1. [Decomposed aspect 1]
  2. [Decomposed aspect 2]
  3. [Decomposed aspect 3]

**Inclusion Criteria**:
  - Time range: [e.g., 2018-present]
  - Languages: [e.g., English, Chinese]
  - Document types: [peer-reviewed, preprints, reports, patents]
  - Disciplines: [e.g., CS, cognitive science, linguistics]

**Exclusion Criteria**:
  - [Opinion pieces, blog posts without data]
  - [Studies with n < 30 unless qualitative]
  - [Duplicate publications of same study]

**Expected Deliverable**: [Literature review / Evidence map / Policy brief / State-of-art report]
**Depth Target**: [Exhaustive / Representative / Exploratory]
```

### Phase 2: Multi-Source Collection (30% of effort)

Search systematically across source tiers:

| Tier | Source Type | Examples | Purpose |
|------|-----------|---------|---------|
| **1** | Academic databases | OpenAlex, PubMed, Scopus, Web of Science | Peer-reviewed primary research |
| **2** | Preprint servers | arXiv, bioRxiv, SSRN, medRxiv | Cutting-edge, not yet reviewed |
| **3** | Grey literature | WHO reports, World Bank, NBER working papers | Policy and institutional knowledge |
| **4** | Patents and standards | Google Patents, USPTO, IEEE standards | Technical implementations |
| **5** | Data repositories | Zenodo, Figshare, Kaggle, ICPSR | Raw data and reproducibility |
| **6** | Expert knowledge | Conference talks, interviews, personal communication | Tacit knowledge, emerging trends |

**Search strategy per source**:

```markdown
For each source:
1. Construct 3-5 query variants (synonyms, related terms, translated terms)
2. Apply inclusion/exclusion filters
3. Record: query string, date, results count, relevant hits
4. Download and tag all relevant items
5. Snowball: check references of key papers (backward) and citing papers (forward)
```

### Phase 3: Source Evaluation (20% of effort)

Rate each source on a standardized evidence hierarchy:

```
Level 1: Systematic reviews and meta-analyses
Level 2: Randomized controlled trials / controlled experiments
Level 3: Cohort studies / quasi-experimental designs
Level 4: Case-control studies / cross-sectional surveys
Level 5: Case reports / case series / expert opinion
Level 6: Anecdotal evidence / grey literature without methodology
```

**Credibility checklist per source**:

```markdown
□ Author credentials and affiliation
□ Publication venue (impact factor, peer-review process)
□ Methodology transparency (can you replicate it?)
□ Sample size and representativeness
□ Conflict of interest disclosure
□ Recency (is the data still relevant?)
□ Citation count and reception (supportive vs. critical citations)
□ Consistency with other sources (does it converge or contradict?)
```

### Phase 4: Evidence Synthesis (30% of effort)

Organize findings into structured artifacts:

#### Evidence Matrix

| Finding | Source(s) | Evidence Level | Strength | Notes |
|---------|-----------|---------------|----------|-------|
| LLMs improve code quality by 20-40% | [A], [B], [C] | Level 2-3 | Strong (convergent) | Effect varies by task complexity |
| Developers trust AI suggestions less for security-critical code | [D], [E] | Level 4 | Moderate | Small sample sizes |
| No significant effect on debugging time | [F] | Level 2 | Weak (single study) | Contradicts [A] — needs reconciliation |

#### Contradiction Log

When sources disagree, document systematically:

```markdown
## Contradiction: Effect of X on Y

**Position A**: X increases Y (Smith 2023, Jones 2024)
  - Evidence: RCT with n=500, effect size d=0.4
  - Context: University students, controlled setting

**Position B**: X has no effect on Y (Lee 2024)
  - Evidence: Field study with n=1200, p=0.34
  - Context: Industry practitioners, naturalistic setting

**Resolution hypothesis**: The effect is moderated by expertise level.
  Position A's sample (students) shows the effect;
  Position B's sample (practitioners) does not.
  → Need: Study that measures expertise as a moderator.
```

#### Knowledge Map

Visualize the landscape of your findings:

```
Central Question
├── Sub-Q1: [Strong evidence — 8 sources, convergent]
│   ├── Finding 1.1 (Level 2, 3 sources)
│   ├── Finding 1.2 (Level 3, 2 sources)
│   └── Finding 1.3 (Level 4, 3 sources)
├── Sub-Q2: [Mixed evidence — 5 sources, 1 contradiction]
│   ├── Finding 2.1 (Level 2, 2 sources)
│   └── Finding 2.2 ⚠️ CONTRADICTED by Finding 2.3
├── Sub-Q3: [Weak evidence — 2 sources, emerging area]
│   └── Finding 3.1 (Level 5, 2 sources)
└── Unexpected: [Theme that emerged during research]
    └── Finding 4.1 (Level 3, 1 source) → needs further investigation
```

### Phase 5: Deliverable Production (10% of effort)

Compile findings into the target deliverable format:

**For a Literature Review**:
1. Organize by themes (not chronologically)
2. Synthesize across sources (not paper-by-paper summaries)
3. Identify gaps explicitly ("No studies have examined...")
4. State implications for your research

**For a State-of-the-Art Report**:
1. Current landscape with taxonomy
2. Key advances and timelines
3. Open problems and active debates
4. Future directions with evidence basis

**For a Policy Brief**:
1. Executive summary (1 paragraph)
2. Evidence summary (1-2 pages)
3. Policy options with trade-offs
4. Recommended action with justification

## Iteration Protocol

Deep research is inherently iterative. After Phase 4, reassess:

```
After synthesis:
  □ Are all sub-questions adequately answered?
  □ Are there new sub-questions that emerged?
  □ Are there critical gaps requiring additional search?
  □ Are contradictions resolved or at least documented?

If gaps remain:
  → Return to Phase 2 with refined queries
  → Maximum 3 iteration cycles before declaring scope complete
  → Document what remains unknown (future work)
```

## Quality Indicators

A well-executed in-depth investigation should demonstrate:

- **Breadth**: Multiple source tiers consulted (not just Google Scholar)
- **Depth**: Key papers read in full, not just abstracts
- **Rigor**: Evidence levels assessed, contradictions documented
- **Transparency**: Search strategy reproducible, decisions justified
- **Currency**: Most recent relevant work included
- **Balance**: Competing viewpoints represented fairly

## References

- Petticrew, M., & Roberts, H. (2006). *Systematic Reviews in the Social Sciences*. Blackwell.
- Grant, M. J., & Booth, A. (2009). "A typology of reviews." *Health Information & Libraries Journal*, 26(2), 91-108.
- Snyder, H. (2019). "Literature review as a research methodology." *Journal of Business Research*, 104, 333-339.

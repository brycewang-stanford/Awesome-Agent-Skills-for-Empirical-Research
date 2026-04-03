---
name: parsifal-slr-guide
description: "Plan and manage systematic literature reviews with Parsifal platform"
metadata:
  openclaw:
    emoji: "📋"
    category: "research"
    subcategory: "methodology"
    keywords: ["Parsifal", "systematic review", "SLR", "review protocol", "PICO", "research methodology"]
    source: "https://github.com/vitorfs/parsifal"
---

# Parsifal Systematic Literature Review Guide

## Overview

Parsifal is a web-based tool for planning and managing systematic literature reviews (SLRs) following established protocols (Kitchenham, PRISMA). It guides researchers through the complete SLR process: defining research questions, setting inclusion/exclusion criteria, planning search strings, and tracking the screening process. Open-source and self-hostable.

## SLR Process with Parsifal

### Phase 1: Planning

#### Define Research Questions

Structure questions using PICO framework:
- **P**opulation: What group/domain?
- **I**ntervention: What technique/method?
- **C**omparison: Compared to what?
- **O**utcome: What results measured?

```
Example:
P: Software development teams
I: AI-assisted code review
C: Manual code review
O: Defect detection rate, review time

Research Questions:
RQ1: Does AI-assisted code review improve defect detection?
RQ2: What is the time savings compared to manual review?
RQ3: What types of defects are best detected by AI tools?
```

#### Set Criteria

```
Inclusion Criteria:
IC1: Studies comparing AI vs manual code review
IC2: Published in peer-reviewed venues (2020-2026)
IC3: Reports quantitative metrics

Exclusion Criteria:
EC1: Grey literature / blog posts
EC2: Studies with fewer than 10 participants
EC3: Non-English publications
```

### Phase 2: Search Strategy

#### Build Search String

```
("artificial intelligence" OR "machine learning" OR "deep learning")
AND
("code review" OR "code inspection" OR "static analysis")
AND
("defect detection" OR "bug finding" OR "software quality")
```

#### Database Mapping

| Database | Adapted Query | Expected Results |
|----------|--------------|-----------------|
| Scopus | TITLE-ABS-KEY(...) | ~500 |
| IEEE Xplore | querytext=... | ~300 |
| ACM DL | [[Abstract: ...]] | ~200 |
| Web of Science | TS=(...) | ~400 |

### Phase 3: Selection

#### Screening Steps

1. **Remove duplicates** — Match by DOI, title similarity
2. **Title screening** — Quick relevance assessment
3. **Abstract screening** — Apply inclusion/exclusion criteria
4. **Full-text review** — Detailed evaluation

#### Quality Assessment

Define quality criteria and scoring:

| Criterion | Score |
|-----------|-------|
| Clear research question stated | 0/0.5/1 |
| Methodology described in detail | 0/0.5/1 |
| Threats to validity discussed | 0/0.5/1 |
| Results statistically analyzed | 0/0.5/1 |
| Study replicable from description | 0/0.5/1 |

### Phase 4: Extraction

#### Data Extraction Form

```
For each included paper, extract:
- Study ID
- Authors, Year, Venue
- Study type (experiment/case study/survey)
- Population size
- AI technique used
- Metrics reported (precision, recall, F1, time)
- Key findings
- Limitations noted
```

### Phase 5: Synthesis

#### Report with PRISMA

```
Identification: 1,400 records
  ↓ Remove duplicates: -350
Screening: 1,050 titles/abstracts
  ↓ Exclude irrelevant: -900
Eligibility: 150 full-text assessed
  ↓ Exclude by criteria: -108
Included: 42 studies in final review
```

## Self-Hosting Parsifal

```bash
git clone https://github.com/vitorfs/parsifal.git
cd parsifal
pip install -r requirements.txt
python manage.py migrate
python manage.py runserver
# Access at http://localhost:8000
```

## SLR Best Practices

1. **Register protocol** before starting (PROSPERO for health, OSF for others)
2. **Two independent reviewers** for screening to reduce bias
3. **Track inter-rater agreement** (Cohen's kappa > 0.8)
4. **Document deviations** from the original protocol
5. **Use PRISMA checklist** for reporting completeness

## References

- [Parsifal](https://github.com/vitorfs/parsifal)
- Kitchenham, B. & Charters, S. (2007). "Guidelines for performing Systematic Literature Reviews in Software Engineering."
- [PRISMA Statement](http://www.prisma-statement.org/)
- [PROSPERO Registry](https://www.crd.york.ac.uk/prospero/)

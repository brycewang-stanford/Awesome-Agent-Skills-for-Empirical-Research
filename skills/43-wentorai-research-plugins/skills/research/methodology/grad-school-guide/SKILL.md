---
name: grad-school-guide
description: "Practical advice for thriving in PhD programs and academic research"
metadata:
  openclaw:
    emoji: "🎓"
    category: "research"
    subcategory: "methodology"
    keywords: ["research question formulation", "hypothesis formulation", "theoretical framework", "conceptual model"]
    source: "https://github.com/poloclub/awesome-grad-school"
---

# Graduate School Research Guide

## Overview

Graduate school -- particularly a PhD program -- is a multi-year commitment that demands not only technical skills but also effective research methodology, advisor management, paper writing strategies, and career planning. The difference between thriving and merely surviving often comes down to having the right mental models and practical frameworks for the research process.

This guide distills wisdom from the awesome-grad-school repository (450+ stars, maintained by the Polo Club of Data Science at Georgia Tech) and supplements it with actionable frameworks for formulating research questions, developing hypotheses, structuring a theoretical framework, and managing the end-to-end research lifecycle. The advice here applies broadly across STEM and social-science disciplines.

Whether you are an incoming PhD student, a mid-program researcher seeking to improve your productivity, or an advanced candidate preparing for the job market, this skill provides concrete tools for each stage of the journey.

## Formulating Research Questions

A strong research question is the foundation of any good paper. It should be specific, answerable, and significant.

### The FINER Criteria

| Criterion | Description | Example Check |
|-----------|-------------|---------------|
| **F**easible | Can be answered with available resources | Do you have the data, compute, and time? |
| **I**nteresting | Engages the research community | Would peers read this at a top venue? |
| **N**ovel | Not already answered | Has OpenAlex/CrossRef search been done? |
| **E**thical | Follows research ethics standards | Does it require IRB approval? |
| **R**elevant | Advances the field meaningfully | Does it connect to open problems? |

### From Topic to Question: A Step-by-Step Process

1. **Survey the landscape.** Read 20-30 recent papers in your area.
2. **Identify gaps.** Look for "future work" sections and limitations.
3. **Narrow progressively.** Topic -> Sub-topic -> Specific question.
4. **Phrase as a question.** "Does X improve Y compared to Z in context W?"
5. **Test with the "so what?" check.** If the answer is yes or no, does it matter?

Example progression:

```
Topic:    Natural language processing
Sub-topic: Low-resource language translation
Gap:      Few-shot methods underperform on morphologically rich languages
Question: Can morphological decomposition improve few-shot translation
          quality for agglutinative languages?
```

## Developing Hypotheses and Theoretical Frameworks

### From Question to Hypothesis

A hypothesis is a testable, falsifiable prediction derived from your research question:

- **Directional:** "Method A will achieve higher BLEU scores than Method B on agglutinative language pairs."
- **Non-directional:** "There will be a significant difference in BLEU scores between Method A and Method B."
- **Null (H0):** "There is no significant difference in BLEU scores between Method A and Method B."

### Building a Conceptual Model

A conceptual model maps the relationships between your key variables:

```
Independent Variable      Moderator        Dependent Variable
[Morphological           [Language         [Translation
 Decomposition]  ------> Typology]  -----> Quality (BLEU)]
        |                                        ^
        |          Mediator                      |
        +-------> [Vocabulary                    |
                   Coverage] --------------------+
```

Document your conceptual model with:
1. **Constructs:** The abstract concepts (e.g., "translation quality").
2. **Operationalizations:** How you measure each construct (e.g., BLEU, COMET scores).
3. **Relationships:** Hypothesized causal or correlational links.
4. **Boundary conditions:** Where the model applies and where it does not.

## Managing Your Advisor and Research Workflow

### Communication Frameworks

**The Weekly Update Email:**

```
Subject: Weekly Update - [Your Name] - Week of [Date]

1. ACCOMPLISHED THIS WEEK
   - Completed experiment X with results Y
   - Drafted Section 3 of the paper

2. BLOCKERS
   - Need access to GPU cluster for large-scale runs
   - Waiting on co-author feedback on Section 2

3. PLAN FOR NEXT WEEK
   - Run ablation study on components A, B, C
   - Begin writing Section 4

4. DISCUSSION ITEMS FOR MEETING
   - Should we include dataset Z in our evaluation?
   - Timeline for submission to [Conference]
```

### Research Productivity System

| Practice | Cadence | Tool |
|----------|---------|------|
| Daily progress log | End of each day | Plain text file or Notion |
| Literature reading | 2-3 papers/week | Zotero + annotations |
| Experiment tracking | Per run | Weights & Biases or MLflow |
| Writing | 30 min daily minimum | LaTeX or Markdown |
| Advisor meeting prep | Weekly | Structured update email |
| Research talks | Monthly (lab meeting) | 15-min presentation |

## Paper Writing Strategy

### The Reverse-Outline Method

1. Write bullet points for each section (1-2 sentences per paragraph).
2. Order bullets by logical flow.
3. Expand each bullet into a full paragraph.
4. Revise for transitions and coherence.

### Section-by-Section Tips

- **Introduction:** Open with a concrete problem, not "In recent years..."
- **Related Work:** Organize by theme, not chronologically. Compare approaches, do not just list them.
- **Methods:** Write so a competent researcher can reproduce your work.
- **Results:** Lead with the most important finding. Use tables for exact numbers, figures for trends.
- **Discussion:** Address limitations honestly. Reviewers respect self-awareness.

### Handling Rejection

Paper rejection is a normal part of academic life. The awesome-grad-school community recommends:

1. **Allow 24-48 hours to process emotions.** Do not respond immediately.
2. **Categorize each review comment** as: (a) valid and fixable, (b) valid but requires new experiments, (c) misunderstanding to clarify, or (d) subjective disagreement.
3. **Create an action plan** for addressing category (a) and (b) items.
4. **Resubmit to the next venue** with improvements, not just the same paper.

## Career Planning

### Timeline for a 5-Year PhD

| Year | Focus | Milestones |
|------|-------|-----------|
| 1 | Coursework + exploration | Pass qualifying exam, identify area |
| 2 | First project + first paper | Submit to workshop or conference |
| 3 | Core research + publications | 1-2 papers at top venues |
| 4 | Thesis writing + job market prep | Draft thesis proposal, internship |
| 5 | Defense + job search | Submit thesis, interview |

### Building Visibility

- Maintain a personal academic website with publications and blog posts.
- Present at conferences and workshops.
- Share preprints on arXiv before publication.
- Engage constructively on academic social media.

## Best Practices

- **Start writing early.** The paper is not separate from the research -- writing clarifies thinking.
- **Build a library of reusable code.** Experiment templates, plotting scripts, and data loaders save hours on each project.
- **Invest in relationships.** Collaborators, mentors, and peers are your most valuable resource.
- **Take care of your health.** PhD burnout is real. Set boundaries and maintain activities outside research.
- **Read broadly.** Some of the best ideas come from adjacent fields.
- **Track your accomplishments.** Maintain a running CV and a "brag document" for annual reviews and job applications.

## References

- [awesome-grad-school](https://github.com/poloclub/awesome-grad-school) -- Curated grad school advice (450+ stars)
- [A Survival Guide to a PhD](http://karpathy.github.io/2016/09/07/phd/) -- Andrej Karpathy
- [Modest Advice for New Graduate Students](https://stearnslab.yale.edu/modest-advice) -- Stephen Stearns, Yale
- [De-Mystifying Good Research](https://bigaidream.gitbooks.io/tech-blog/content/2014/de-mystifying-good-research.html) -- Fei-Fei Li
- [How to Write a Great Research Paper](https://www.microsoft.com/en-us/research/academic-program/write-great-research-paper/) -- Simon Peyton Jones

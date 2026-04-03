---
name: meta-synthesis-guide
description: "Conduct qualitative meta-synthesis and evidence synthesis methods"
metadata:
  openclaw:
    emoji: "⛓️"
    category: "research"
    subcategory: "deep-research"
    keywords: ["meta-synthesis", "qualitative evidence synthesis", "meta-ethnography", "thematic synthesis", "systematic review"]
    source: "wentor-research-plugins"
---

# Meta-Synthesis Guide

A skill for conducting qualitative meta-synthesis -- the systematic integration of findings across multiple qualitative studies. Covers meta-ethnography (Noblit & Hare), thematic synthesis (Thomas & Harden), framework synthesis, and quality appraisal of qualitative studies.

## What Is Qualitative Meta-Synthesis?

### Overview

```
Meta-synthesis is to qualitative research what meta-analysis
is to quantitative research -- it systematically combines
findings from multiple studies to produce higher-order
interpretations.

Key differences from meta-analysis:
  - Interpretive, not statistical aggregation
  - Aims to generate new understanding, not average effect sizes
  - Synthesizes themes, concepts, and metaphors across studies
  - Product is a new interpretation, not a pooled statistic
```

### When to Use Meta-Synthesis

```
Appropriate when:
  - Multiple qualitative studies exist on a topic
  - You want to build theory or deepen understanding
  - Individual studies have limited scope but collectively cover a phenomenon
  - Policy or practice needs an integrated evidence base from qualitative work

Not appropriate when:
  - Studies are too heterogeneous in topic to meaningfully compare
  - Fewer than 3 qualitative studies exist
  - The goal is to measure effect sizes (use meta-analysis instead)
```

## Meta-Ethnography (Noblit & Hare)

### Seven-Step Process

```python
def meta_ethnography_steps() -> dict:
    """
    The seven steps of meta-ethnography (Noblit & Hare, 1988).
    """
    return {
        "step_1_getting_started": {
            "description": "Identify the research question and intellectual interest",
            "output": "Clear synthesis question"
        },
        "step_2_deciding_what_is_relevant": {
            "description": "Systematic search and selection of qualitative studies",
            "output": "Final set of included studies",
            "note": "Use PRISMA flow diagram to document selection"
        },
        "step_3_reading_the_studies": {
            "description": (
                "Read and re-read included studies carefully. "
                "Identify key metaphors, themes, and concepts in each."
            ),
            "output": "List of first-order (participant quotes) and "
                      "second-order (author interpretations) constructs"
        },
        "step_4_determining_how_studies_are_related": {
            "description": (
                "Create a grid mapping constructs across studies. "
                "Determine if studies are reciprocal (about similar things), "
                "refutational (contradictory), or form a line of argument."
            ),
            "output": "Construct comparison table"
        },
        "step_5_translating_studies": {
            "description": (
                "Translate the concepts of one study into the terms of another. "
                "This is the core analytical step -- finding common meaning "
                "expressed in different language."
            ),
            "output": "Translated constructs across all studies"
        },
        "step_6_synthesizing_translations": {
            "description": (
                "Develop third-order constructs -- new interpretations "
                "that go beyond what any single study found."
            ),
            "output": "Third-order constructs (the synthesis)"
        },
        "step_7_expressing_the_synthesis": {
            "description": "Write up the synthesis in a form accessible to the audience",
            "output": "Published meta-synthesis paper"
        }
    }
```

### Types of Synthesis

```
Reciprocal translation:
  Studies are about similar things. Translate them into each other.
  "Study A calls it 'navigating uncertainty'; Study B calls it
   'managing ambiguity'; Study C calls it 'living with not knowing'.
   The overarching construct is 'Tolerating the Unknown.'"

Refutational synthesis:
  Studies contradict each other. Explore why.
  "Study A found empowerment through peer support; Study B found
   peer support increased anxiety. This refutation may be explained
   by the stage of illness at which support was received."

Line of argument synthesis:
  Studies address different aspects that together form a whole.
  "Study A covers diagnosis, B covers treatment, C covers recovery.
   Together they reveal a trajectory of 'Reconstructing Identity.'"
```

## Thematic Synthesis (Thomas & Harden)

### Three-Stage Approach

```
Stage 1: Free coding of findings
  - Treat the findings sections of included studies as data
  - Code them line by line, as in primary qualitative analysis

Stage 2: Organizing codes into descriptive themes
  - Group codes into descriptive themes
  - These are "close to" the original studies

Stage 3: Generating analytical themes
  - Go beyond the content of the original studies
  - Generate new interpretive constructs
  - Answer the synthesis research question
```

## Quality Appraisal

### Assessing Qualitative Studies

```
Tools for appraising qualitative study quality:

  CASP Qualitative Checklist (10 items):
    - Was there a clear statement of aims?
    - Is a qualitative methodology appropriate?
    - Was the research design appropriate?
    - Was the recruitment strategy appropriate?
    - Was data collected in a way that addressed the research issue?
    - Was the relationship between researcher and participants considered?
    - Were ethical issues considered?
    - Was data analysis sufficiently rigorous?
    - Was there a clear statement of findings?
    - How valuable is the research?

  JBI Checklist for Qualitative Research (10 criteria)

Decision: Include all studies or exclude low-quality studies?
  - Sensitivity analysis: Run the synthesis with and without
    lower-quality studies to see if conclusions change.
```

## Reporting Standards

Use the ENTREQ (Enhancing Transparency in Reporting the Synthesis of Qualitative Research) statement. Report: the synthesis methodology used, the search strategy and selection criteria, quality appraisal results, a table of included studies with their key constructs, the synthesis process with clear evidence trails, and how third-order constructs were derived from the primary studies.

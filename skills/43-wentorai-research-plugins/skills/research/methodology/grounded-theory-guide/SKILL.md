---
name: grounded-theory-guide
description: "Apply grounded theory methodology to develop theory from data"
metadata:
  openclaw:
    emoji: "🌱"
    category: "research"
    subcategory: "methodology"
    keywords: ["grounded theory", "qualitative methodology", "theoretical sampling", "constant comparison", "coding"]
    source: "wentor-research-plugins"
---

# Grounded Theory Guide

A skill for applying grounded theory methodology (GTM) to generate theory grounded in empirical data. Covers the three major schools (Glaser, Strauss/Corbin, Charmaz), coding procedures, theoretical sampling, memo writing, and criteria for evaluating grounded theories.

## Three Schools of Grounded Theory

### Comparing Approaches

| Aspect | Classic (Glaser) | Straussian (Strauss & Corbin) | Constructivist (Charmaz) |
|--------|-----------------|------------------------------|-------------------------|
| Ontology | Objective reality | Pragmatist | Relativist/constructivist |
| Literature review | Delay until theory emerges | Early but non-constraining | Early, reflexive engagement |
| Coding paradigm | Open, selective, theoretical | Open, axial, selective | Initial, focused, theoretical |
| Verification | Emergent fit | Systematic validation | Co-construction with participants |
| Core output | Substantive theory | Process model | Interpretive theory |
| Key text | Glaser (1978) | Strauss & Corbin (1998) | Charmaz (2014) |

### Choosing an Approach

```
Use Classic GTM when:
  - You want the theory to emerge with minimal preconception
  - You are studying a process in a substantive area

Use Straussian GTM when:
  - You need a structured, systematic coding procedure
  - Your discipline values replicable analytical steps

Use Constructivist GTM when:
  - You acknowledge the researcher's role in co-creating meaning
  - You study experiences, identities, or social processes
  - You work in health, education, or social science
```

## The Coding Process

### Three-Stage Coding

```python
def grounded_theory_coding_stages() -> dict:
    """
    Describe the three stages of grounded theory coding.
    """
    return {
        "stage_1_initial_coding": {
            "also_called": "Open coding",
            "description": (
                "Examine data line by line or incident by incident. "
                "Generate codes that stay close to the data. "
                "Use gerunds (action words ending in -ing) to capture processes."
            ),
            "example": {
                "data": "I started looking for help online because the doctor "
                        "did not explain anything to me.",
                "codes": [
                    "Seeking information online",
                    "Experiencing communication gap with provider",
                    "Taking initiative in own care"
                ]
            },
            "tips": [
                "Code quickly -- do not overthink individual codes",
                "Stay open; do not force data into preexisting categories",
                "Code actions and processes, not topics",
                "Write memos about ideas that arise during coding"
            ]
        },
        "stage_2_focused_coding": {
            "also_called": "Axial coding (Strauss) or Focused coding (Charmaz)",
            "description": (
                "Select the most frequent and significant initial codes. "
                "Use them to sort and synthesize larger amounts of data. "
                "Identify relationships between categories."
            ),
            "tasks": [
                "Elevate initial codes to categories",
                "Identify properties and dimensions of each category",
                "Compare categories across cases",
                "Begin developing a conceptual framework"
            ]
        },
        "stage_3_theoretical_coding": {
            "also_called": "Selective coding",
            "description": (
                "Identify the core category that integrates all other "
                "categories into a coherent theoretical framework. "
                "Specify relationships between categories."
            ),
            "output": "A substantive theory explaining the phenomenon"
        }
    }
```

## Theoretical Sampling

### Sampling Driven by Emerging Theory

```
Traditional sampling: Decide sample before data collection
Theoretical sampling: Let the emerging theory guide who/what to sample next

Process:
  1. Collect initial data (purposive sampling)
  2. Analyze data, identify emerging categories
  3. Ask: "Where should I look next to develop these categories?"
  4. Sample deliberately to fill gaps in the emerging theory
  5. Continue until theoretical saturation

Example:
  Initial interviews: Patients with chronic illness
  Emerging category: "Navigating insurance barriers"
  Next sample: Interview insurance navigators and social workers
  Emerging category: "Stigma in seeking help"
  Next sample: Interview patients who avoided seeking help
```

## Memo Writing

### The Engine of Grounded Theory

Memos are the researcher's running commentary on codes, categories, and theoretical ideas. They are the primary mechanism for developing theory.

```
Memo types:
  - Code memos: Define and elaborate a code or category
  - Theoretical memos: Explore relationships between categories
  - Operational memos: Record methodological decisions
  - Reflexive memos: Examine researcher influence on the analysis

Memo example:
  MEMO: "Becoming an expert patient" (2026-03-05)

  Several participants describe a transition from passive
  recipient of care to active manager of their condition.
  This process seems to involve three phases: (1) initial
  confusion and dependence, (2) information seeking and
  experimentation, (3) confident self-management. The trigger
  appears to be a critical incident (a misdiagnosis, a bad
  interaction with a provider) that motivates the person to
  take control. Compare with Corbin & Strauss's trajectory
  framework. Need to sample someone early in the trajectory
  to test whether the trigger is consistent.
```

## Evaluating Grounded Theory

### Quality Criteria

| Criterion | Description | How to Demonstrate |
|-----------|------------|-------------------|
| Fit | Theory fits the data it was derived from | Show clear evidence trail from data to codes to categories |
| Relevance | Theory addresses a real concern of participants | Member checking, resonance with practitioners |
| Workability | Theory explains the process and enables prediction | Apply the theory to new cases |
| Modifiability | Theory can be updated with new data | Show how the theory evolved during the study |
| Credibility | Analysis is thorough and systematic | Audit trail, reflexive memos, theoretical saturation |

## Reporting a Grounded Theory Study

Include: a clear description of the coding process and how categories were derived, a diagram or model of the theory, representative quotes for each major category, an explanation of theoretical sampling decisions, and a discussion of how the theory relates to existing literature. Use the SRQR (Standards for Reporting Qualitative Research) checklist to ensure completeness.

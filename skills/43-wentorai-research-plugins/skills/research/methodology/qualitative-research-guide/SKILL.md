---
name: qualitative-research-guide
description: "Design and conduct qualitative research using grounded theory and case studies"
metadata:
  openclaw:
    emoji: "🔍"
    category: "research"
    subcategory: "methodology"
    keywords: ["qualitative research design", "case study", "grounded theory", "phenomenology", "thematic analysis"]
    source: "wentor"
---

# Qualitative Research Guide

A skill for designing and conducting rigorous qualitative research. Covers major qualitative traditions, data collection methods, coding and analysis techniques, and quality criteria for trustworthy qualitative findings.

## Major Qualitative Traditions

### Choosing an Approach

| Approach | Research Question Type | Unit of Analysis | Sample Size | Output |
|----------|----------------------|-----------------|-------------|--------|
| Grounded Theory | How does a process work? | Process/action | 20-60 | Theory |
| Phenomenology | What is the lived experience? | Experience | 5-25 | Essence description |
| Case Study | How/why does this case work? | Bounded system | 1-5 cases | Case description |
| Ethnography | How does this culture work? | Cultural group | Extended fieldwork | Cultural portrait |
| Narrative | What is this person's story? | Individual life | 1-5 | Narrative account |
| Thematic Analysis | What patterns exist in this data? | Themes across data | Variable | Theme map |

### Grounded Theory Process

```
Data Collection (interviews, observations)
       |
       v
Open Coding: Line-by-line coding of raw data
       |
       v
Axial Coding: Grouping codes into categories,
              identifying relationships
       |
       v
Selective Coding: Identifying the core category
                  that integrates all others
       |
       v
Theoretical Saturation: Stop when new data
                        no longer generates new codes
       |
       v
Substantive Theory: A grounded explanation of the phenomenon
```

## Interview Design

### Semi-Structured Interview Protocol

```python
def create_interview_protocol(research_questions: list[str],
                                n_questions: int = 10) -> dict:
    """
    Generate a semi-structured interview protocol template.

    Args:
        research_questions: The study's research questions
        n_questions: Target number of interview questions
    """
    protocol = {
        'opening': {
            'rapport_building': [
                "Thank you for participating. Before we begin, could you "
                "tell me a little about yourself and your background?",
                "How did you first become involved in [topic]?"
            ],
            'time_estimate': '60-90 minutes'
        },
        'main_questions': [],
        'closing': {
            'wrap_up': [
                "Is there anything else you would like to share that we "
                "have not covered?",
                "Looking back, what stands out most to you about [topic]?",
                "Do you have any questions for me?"
            ]
        },
        'guidelines': [
            'Ask open-ended questions (how, what, tell me about)',
            'Avoid leading questions',
            'Use probes: "Can you give me an example?"',
            'Use follow-ups: "You mentioned X, tell me more about that"',
            'Allow silences -- do not rush to fill pauses',
            'Record field notes immediately after each interview'
        ]
    }

    # Generate question structure
    for i, rq in enumerate(research_questions):
        protocol['main_questions'].append({
            'research_question': rq,
            'interview_questions': [
                f'Grand tour question for RQ{i+1}',
                f'Follow-up probe for RQ{i+1}',
                f'Example-seeking probe for RQ{i+1}'
            ]
        })

    return protocol
```

### Sampling Strategies

| Strategy | Description | When to Use |
|----------|------------|------------|
| Purposive | Select information-rich cases | Most qualitative studies |
| Maximum variation | Select cases that differ on key dimensions | Capture range of experiences |
| Snowball | Participants refer others | Hard-to-reach populations |
| Theoretical | Driven by emerging theory | Grounded theory studies |
| Critical case | Select cases that are pivotal | Testing theoretical propositions |
| Convenience | Readily available participants | Pilot studies only |

## Coding and Analysis

### Thematic Analysis (Braun & Clarke, 2006)

```python
def thematic_analysis_workflow(transcripts: list[str]) -> dict:
    """
    Outline the six phases of reflexive thematic analysis.
    """
    phases = {
        'phase_1_familiarization': {
            'actions': [
                'Read and re-read all transcripts',
                'Note initial impressions in a research journal',
                'Transcribe recordings if not already done'
            ],
            'output': 'Familiarity with data, initial notes'
        },
        'phase_2_coding': {
            'actions': [
                'Code every data segment systematically',
                'Use open coding (inductive) or deductive codes from framework',
                'Code inclusively -- same segment can have multiple codes',
                'Maintain a codebook with definitions and examples'
            ],
            'output': 'Coded dataset, codebook'
        },
        'phase_3_generating_themes': {
            'actions': [
                'Collate codes into potential themes',
                'Create a thematic map showing relationships',
                'Distinguish between semantic and latent themes'
            ],
            'output': 'Candidate themes and sub-themes'
        },
        'phase_4_reviewing_themes': {
            'actions': [
                'Check themes against coded extracts',
                'Check themes against entire dataset',
                'Merge, split, or discard themes as needed'
            ],
            'output': 'Refined thematic map'
        },
        'phase_5_defining_themes': {
            'actions': [
                'Write a detailed description of each theme',
                'Identify the essence of each theme',
                'Name themes concisely and informatively'
            ],
            'output': 'Theme definitions and names'
        },
        'phase_6_writing_up': {
            'actions': [
                'Weave together analytic narrative and data extracts',
                'Select vivid, compelling quotes for each theme',
                'Connect themes to research questions and literature'
            ],
            'output': 'Final analysis write-up'
        }
    }

    return {
        'phases': phases,
        'n_transcripts': len(transcripts),
        'estimated_time': f'{len(transcripts) * 4}-{len(transcripts) * 8} hours'
    }
```

### Codebook Structure

```yaml
codebook:
  - code: "ADAPT"
    definition: "Participant describes adapting their behavior in response to a challenge"
    inclusion_criteria: "Explicit mention of changing approach or strategy"
    exclusion_criteria: "Passive acceptance without behavioral change"
    example_quote: "I started doing things differently after that..."
    theme: "Resilience Strategies"

  - code: "BARR"
    definition: "Participant identifies a barrier or obstacle"
    inclusion_criteria: "Something that prevented or hindered progress"
    exclusion_criteria: "General complaints without specific barrier"
    example_quote: "The main thing holding me back was..."
    theme: "Challenges"
```

## Quality Criteria

### Trustworthiness (Lincoln & Guba, 1985)

| Criterion | Quantitative Equivalent | Strategies |
|-----------|------------------------|-----------|
| Credibility | Internal validity | Member checking, triangulation, prolonged engagement |
| Transferability | External validity | Thick description, purposive sampling |
| Dependability | Reliability | Audit trail, peer debriefing |
| Confirmability | Objectivity | Reflexivity journal, negative case analysis |

### Inter-Coder Reliability

For team-based coding, calculate Cohen's kappa or percent agreement on a subset of data (at least 10-20% of the corpus). Aim for kappa > 0.70 before independent coding proceeds.

## Software Tools

- **NVivo**: Full-featured qualitative analysis (commercial)
- **ATLAS.ti**: Comprehensive coding and analysis (commercial)
- **MAXQDA**: Mixed-methods capable (commercial)
- **Dedoose**: Cloud-based, collaborative (subscription)
- **Taguette**: Free, open-source qualitative coding
- **QualCoder**: Free, open-source Python-based tool

## Reporting Standards

Follow the COREQ (Consolidated Criteria for Reporting Qualitative Research) checklist: report researcher positionality, sampling strategy, data collection methods, analysis approach, and provide sufficient quotations to evidence each theme.

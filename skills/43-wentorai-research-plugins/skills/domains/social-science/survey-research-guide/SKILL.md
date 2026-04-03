---
name: survey-research-guide
description: "Design, deploy, and analyze surveys for social science and organizational res..."
metadata:
  openclaw:
    emoji: "📋"
    category: "domains"
    subcategory: "social-science"
    keywords: ["communication studies", "anthropology", "management", "sociology", "survey design", "questionnaire"]
    source: "wentor"
---

# Survey Research Guide

A practical skill for conducting rigorous survey research from instrument design through data analysis. Covers questionnaire construction, sampling strategies, administration methods, response bias mitigation, and analytical techniques commonly used in communication studies, anthropology, management, and sociology.

## Survey Design Process

### Phase 1: Conceptualization

Map your research questions to survey constructs:

```python
def create_survey_blueprint(research_questions: list[dict]) -> dict:
    """
    Generate a survey blueprint mapping RQs to constructs and items.

    Args:
        research_questions: List of dicts with 'rq', 'constructs', 'hypothesized_relationship'
    """
    blueprint = {'sections': [], 'total_estimated_items': 0}

    for rq in research_questions:
        section_items = 0
        constructs = []
        for construct in rq['constructs']:
            n_items = construct.get('n_items', 4)  # default 4 items per construct
            constructs.append({
                'name': construct['name'],
                'type': construct.get('type', 'latent'),
                'scale': construct.get('scale', 'Likert 7-point'),
                'validated_instrument': construct.get('instrument', None),
                'items_needed': n_items
            })
            section_items += n_items

        blueprint['sections'].append({
            'research_question': rq['rq'],
            'constructs': constructs,
            'total_items': section_items
        })
        blueprint['total_estimated_items'] += section_items

    # Estimate completion time (3-4 items per minute)
    blueprint['estimated_minutes'] = round(blueprint['total_estimated_items'] / 3.5, 1)
    return blueprint

# Example
rqs = [
    {
        'rq': 'How does organizational culture affect employee innovation?',
        'constructs': [
            {'name': 'organizational_culture', 'instrument': 'OCAI (Cameron & Quinn)'},
            {'name': 'employee_innovation', 'instrument': 'Innovative Work Behavior Scale'}
        ],
        'hypothesized_relationship': 'positive'
    }
]
print(create_survey_blueprint(rqs))
```

### Phase 2: Item Writing

Rules for writing effective survey items:

```
DO:
  - Use simple, unambiguous language (8th grade reading level)
  - Ask about one concept per item
  - Provide a reference period ("In the past 30 days...")
  - Include both positively and negatively worded items (reverse-coded)
  - Match response options to the question stem

DO NOT:
  - Use double negatives ("I do not disagree...")
  - Use absolutes ("always", "never")
  - Ask hypothetical questions when actual behavior data is available
  - Include two ideas in one question (double-barreled)
  - Assume knowledge or use jargon
```

### Phase 3: Response Scale Design

| Scale Type | Use Case | Example |
|-----------|----------|---------|
| Likert (agreement) | Attitudes, beliefs | Strongly Disagree to Strongly Agree |
| Frequency | Behavioral frequency | Never / Rarely / Sometimes / Often / Always |
| Semantic differential | Perceptions | Cold ------- Warm |
| Visual analog (VAS) | Continuous measurement | 0-100mm line |
| Ranking | Relative preferences | Rank items 1 through N |

## Survey Administration

### Mode Selection

| Mode | Response Rate | Cost | Data Quality | Best For |
|------|-------------|------|-------------|----------|
| Online (Qualtrics/SurveyMonkey) | 10-30% | Low | Moderate | General population, students |
| Telephone (CATI) | 15-40% | High | High | Older adults, nationally representative |
| In-person (CAPI) | 50-70% | Very high | Highest | Sensitive topics, low-literacy populations |
| Mail | 20-40% | Moderate | Moderate | Rural populations, older adults |
| Mixed-mode | 30-60% | Moderate-high | High | Coverage optimization |

## Response Bias Detection

```python
def detect_response_patterns(responses: pd.DataFrame,
                              reverse_items: list[str]) -> dict:
    """
    Flag potential problematic response patterns.
    """
    flags = {}

    # 1. Straight-lining detection
    row_variance = responses.var(axis=1)
    flags['straight_liners'] = (row_variance < 0.1).sum()

    # 2. Speeding (if timing data available)
    if 'completion_seconds' in responses.columns:
        median_time = responses['completion_seconds'].median()
        flags['speeders'] = (responses['completion_seconds'] < median_time * 0.33).sum()

    # 3. Inconsistency (reverse-coded item pairs)
    if reverse_items:
        for rev_item in reverse_items:
            original = rev_item.replace('_R', '')
            if original in responses.columns and rev_item in responses.columns:
                max_scale = responses[original].max()
                expected = max_scale + 1 - responses[rev_item]
                diff = abs(responses[original] - expected)
                flags[f'inconsistent_{original}'] = (diff > 2).sum()

    # 4. Missing data pattern
    flags['pct_missing'] = responses.isnull().mean().mean() * 100

    return flags
```

## Analysis Techniques

### Structural Equation Modeling (SEM)

For testing hypothesized relationships between latent constructs:

```python
# Using semopy for SEM in Python
# pip install semopy

model_spec = """
    # Measurement model
    org_culture =~ oc1 + oc2 + oc3 + oc4
    innovation =~ inn1 + inn2 + inn3 + inn4
    job_satisfaction =~ js1 + js2 + js3

    # Structural model
    innovation ~ org_culture + job_satisfaction
    job_satisfaction ~ org_culture
"""

# Fit indices to report:
# - Chi-square (p > 0.05)
# - CFI > 0.95
# - TLI > 0.95
# - RMSEA < 0.06
# - SRMR < 0.08
```

Report reliability (Cronbach's alpha, composite reliability), convergent validity (AVE > 0.50), and discriminant validity (Fornell-Larcker criterion) for all latent constructs.

## Reporting Standards

Follow the AAPOR (American Association for Public Opinion Research) reporting guidelines: report response rate, sampling method, margin of error, field dates, mode of administration, and weighting procedures. For academic publication, include the full survey instrument as supplementary material.

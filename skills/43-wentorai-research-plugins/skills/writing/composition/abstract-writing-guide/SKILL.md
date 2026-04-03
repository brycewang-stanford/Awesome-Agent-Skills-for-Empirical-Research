---
name: abstract-writing-guide
description: "Craft structured research abstracts that maximize clarity and journal acceptance"
metadata:
  openclaw:
    emoji: "📝"
    category: "writing"
    subcategory: "composition"
    keywords: ["abstract writing", "summary writing", "research abstract", "paper title writing", "structured abstract"]
    source: "wentor"
---

# Abstract Writing Guide

A skill for writing effective research abstracts that clearly communicate your study's purpose, methods, results, and significance. Covers structured and unstructured formats, word count optimization, and common pitfalls.

## Abstract Structures

### Structured Abstract (IMRaD)

Most journals in science and medicine require a structured abstract:

```
BACKGROUND/OBJECTIVE: 1-2 sentences on the problem and study aim
METHODS: 2-3 sentences on study design, participants, and analysis
RESULTS: 2-4 sentences with key quantitative findings
CONCLUSION: 1-2 sentences on implications and significance

Total: typically 150-300 words (check journal requirements)
```

### Unstructured Abstract

Common in social sciences and humanities:

```
Sentence 1: Context and problem statement
Sentence 2: Research gap or objective
Sentence 3: Methods overview
Sentence 4-5: Key findings
Sentence 6: Implications and significance

Total: typically 150-250 words
```

## Writing Process

### Step-by-Step Framework

```python
def generate_abstract_outline(study_info: dict) -> dict:
    """
    Generate an abstract outline from study information.

    Args:
        study_info: Dict with keys: 'problem', 'gap', 'objective',
                    'design', 'sample', 'methods', 'key_findings',
                    'implications', 'word_limit'
    Returns:
        Structured abstract outline with estimated word counts
    """
    word_limit = study_info.get('word_limit', 250)

    # Allocate words proportionally
    sections = {
        'background': {
            'allocation_pct': 0.15,
            'content': [study_info['problem'], study_info['gap']],
            'template': "Despite {problem}, {gap}. This study aimed to {objective}."
        },
        'methods': {
            'allocation_pct': 0.25,
            'content': [study_info['design'], study_info['sample'], study_info['methods']],
            'template': "A {design} was conducted with {sample}. {methods}."
        },
        'results': {
            'allocation_pct': 0.35,
            'content': study_info['key_findings'],
            'template': "Results showed {findings}."
        },
        'conclusion': {
            'allocation_pct': 0.25,
            'content': study_info['implications'],
            'template': "These findings suggest {implications}."
        }
    }

    for section in sections.values():
        section['target_words'] = round(word_limit * section['allocation_pct'])

    return {
        'sections': sections,
        'word_limit': word_limit,
        'tips': [
            'Write the Results section first (most important)',
            'Use past tense for methods and results',
            'Avoid abbreviations unless space-saving is critical',
            'Include at least one quantitative result with effect size',
            'Do not include citations in the abstract'
        ]
    }
```

### Example: Well-Written Abstract

```
Background: Chronic low back pain affects 23% of the global adult population,
yet optimal exercise interventions remain unclear. This systematic review and
meta-analysis aimed to compare the effectiveness of yoga, Pilates, and
general exercise for reducing pain and disability in chronic low back pain.

Methods: We searched PubMed, CINAHL, Cochrane Library, and PEDro from
inception to December 2025. Randomized controlled trials comparing yoga,
Pilates, or general exercise to usual care were included. Pain (VAS/NRS)
and disability (ODI/RMDQ) were pooled using random-effects meta-analysis.

Results: Thirty-seven RCTs (N = 3,421) met inclusion criteria. All exercise
types significantly reduced pain compared to usual care: yoga (SMD = -0.73,
95% CI [-0.94, -0.52]), Pilates (SMD = -0.62, 95% CI [-0.81, -0.43]),
and general exercise (SMD = -0.48, 95% CI [-0.63, -0.33]). Yoga showed
significantly greater pain reduction than general exercise (p = 0.03)
but not Pilates (p = 0.28). Heterogeneity was moderate (I-squared = 48-61%).

Conclusion: Yoga, Pilates, and general exercise all effectively reduce
chronic low back pain, with yoga showing a modest advantage over general
exercise. Clinicians should consider patient preferences when recommending
exercise modalities.
```

## Title Writing

### Title Construction Principles

```python
def evaluate_title(title: str) -> dict:
    """Evaluate a paper title against best practices."""
    checks = {}

    # Length check
    word_count = len(title.split())
    checks['word_count'] = word_count
    checks['length_ok'] = 10 <= word_count <= 20

    # Key content checks
    checks['has_colon'] = ':' in title  # Structured titles often use colons
    checks['starts_with_article'] = title.lower().startswith(('a ', 'an ', 'the '))
    checks['has_abbreviation'] = any(w.isupper() and len(w) > 1 for w in title.split())

    # Title type classification
    if '?' in title:
        checks['type'] = 'question'
    elif ':' in title:
        checks['type'] = 'compound'
    elif title.split()[0].endswith('ing'):
        checks['type'] = 'gerund'
    else:
        checks['type'] = 'declarative'

    checks['recommendations'] = []
    if word_count > 20:
        checks['recommendations'].append('Consider shortening -- aim for 10-15 words')
    if word_count < 8:
        checks['recommendations'].append('Consider adding specificity')
    if checks['starts_with_article']:
        checks['recommendations'].append('Avoid starting with articles (A/An/The)')
    if checks['has_abbreviation']:
        checks['recommendations'].append('Spell out abbreviations in titles')

    return checks
```

### Title Patterns by Discipline

| Pattern | Example | Common In |
|---------|---------|-----------|
| Method: Finding | "Deep Learning for Protein Structure: A Comparative Study" | CS, Engineering |
| Declarative | "Mindfulness Reduces Cortisol in College Students" | Psychology, Medicine |
| Question | "Does Remote Work Improve Productivity?" | Social Sciences |
| Descriptive | "Gene Expression Patterns in Early-Stage Lung Cancer" | Biology, Medicine |

## Common Mistakes to Avoid

1. **Vague conclusions**: "More research is needed" -- instead, state specific implications
2. **Missing numbers**: Always include at least one quantitative finding
3. **New information**: Never introduce information not in the paper
4. **Excessive background**: Readers know the field -- get to your contribution quickly
5. **Passive voice overuse**: Use active voice where possible ("We found" not "It was found")
6. **Promising more than delivering**: The abstract must accurately represent the paper's scope

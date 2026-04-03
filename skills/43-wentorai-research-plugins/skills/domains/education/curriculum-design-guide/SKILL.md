---
name: curriculum-design-guide
description: "Systematic approaches to curriculum design using backward design and alignment"
metadata:
  openclaw:
    emoji: "📚"
    category: "domains"
    subcategory: "education"
    keywords: ["curriculum design", "pedagogy", "education", "study methods", "backward design"]
    source: "wentor"
---

# Curriculum Design Guide

A structured skill for designing research-informed curricula using backward design, constructive alignment, and competency-based frameworks. Applicable to higher education course design, training program development, and educational research.

## Backward Design Framework

Understanding by Design (Wiggins & McTighe, 2005) reverses the traditional content-first approach:

### Stage 1: Identify Desired Results

Define what students should know, understand, and be able to do:

```yaml
course: "Introduction to Research Methods"
big_ideas:
  - "Research is a systematic process of inquiry"
  - "Methodology must align with research questions"

essential_questions:
  - "How do we know what we know?"
  - "What makes evidence credible?"
  - "When should we use qualitative vs. quantitative methods?"

learning_outcomes:
  - "Formulate testable research questions (Apply)"
  - "Select appropriate research designs for given questions (Evaluate)"
  - "Critically appraise published research methodology (Analyze)"
  - "Design and defend a research proposal (Create)"
```

### Stage 2: Determine Acceptable Evidence

Design assessments before planning instruction:

```python
# Assessment blueprint generator
def create_assessment_blueprint(outcomes: list[str], bloom_levels: list[str],
                                 weights: list[float]) -> dict:
    """
    Generate an assessment blueprint mapping outcomes to
    assessment types and weights.
    """
    assessment_types = {
        'Remember': 'quiz',
        'Understand': 'reflection_paper',
        'Apply': 'problem_set',
        'Analyze': 'case_study',
        'Evaluate': 'peer_review',
        'Create': 'research_proposal'
    }
    blueprint = []
    for outcome, level, weight in zip(outcomes, bloom_levels, weights):
        blueprint.append({
            'outcome': outcome,
            'bloom_level': level,
            'assessment_type': assessment_types.get(level, 'portfolio'),
            'weight_pct': weight * 100
        })
    return {'blueprint': blueprint, 'total_weight': sum(weights) * 100}

outcomes = [
    "Formulate research questions",
    "Select research designs",
    "Appraise methodology",
    "Design research proposal"
]
levels = ['Apply', 'Evaluate', 'Analyze', 'Create']
weights = [0.15, 0.20, 0.25, 0.40]
print(create_assessment_blueprint(outcomes, levels, weights))
```

### Stage 3: Plan Learning Experiences

Sequence activities that build toward assessment readiness. Use the WHERETO framework:

- **W** -- Where are we going? Why?
- **H** -- Hook and hold interest
- **E** -- Equip with experience, tools, knowledge
- **R** -- Rethink, reflect, revise
- **E** -- Evaluate understanding
- **T** -- Tailor to individual needs
- **O** -- Organize for maximum engagement

## Constructive Alignment

Biggs' Constructive Alignment (1996) ensures coherence between intended learning outcomes (ILOs), teaching/learning activities (TLAs), and assessment tasks (ATs):

```
ILO: "Students will analyze case studies using SWOT framework"
  |
  +--> TLA: Workshop where students collaboratively analyze
  |         a real company case in small groups
  |
  +--> AT:  Individual case analysis report (1500 words)
            assessed with rubric mapping to ILO verbs
```

Misalignment is the most common curriculum design failure. Audit each ILO to verify it has at least one matching TLA and one matching AT.

## Competency-Based Curriculum Mapping

For programs with multiple courses, create a curriculum map:

```
Competency              | Course 1 | Course 2 | Course 3 | Course 4
------------------------|----------|----------|----------|--------
Research question design|    I     |    D     |    M     |    A
Literature review       |    I     |    D     |    D     |    M
Data collection         |    -     |    I     |    D     |    M
Statistical analysis    |    -     |    I     |    D     |    A
Academic writing        |    I     |    D     |    D     |    A

Legend: I = Introduced, D = Developed, M = Mastered, A = Applied
```

Ensure every competency reaches at least "Mastered" level by program completion, and identify gaps where competencies are introduced but never developed further.

## Quality Assurance

Validate curriculum designs through:

1. External review by discipline experts and industry advisors
2. Student feedback surveys (mid-semester and end-of-semester)
3. Learning analytics -- track completion rates, grade distributions, and DFW rates
4. Periodic program-level assessment with rubric-scored capstone artifacts

Document all revisions in a curriculum changelog to maintain institutional memory and support accreditation reporting.

## References

- Wiggins, G., & McTighe, J. (2005). *Understanding by Design* (2nd ed.). ASCD.
- Biggs, J. (1996). Enhancing teaching through constructive alignment. *Higher Education*, 32(3), 347-364.

---
name: learning-science-guide
description: "Evidence-based learning science principles for educational research and practice"
metadata:
  openclaw:
    emoji: "🧠"
    category: "domains"
    subcategory: "education"
    keywords: ["education", "pedagogy", "learning science", "curriculum design", "study methods", "cognitive load"]
    source: "wentor"
---

# Learning Science Guide

A comprehensive skill for applying evidence-based learning science principles to educational research, instructional design, and teaching practice. Grounded in cognitive psychology and educational neuroscience.

## Foundational Learning Theories

### Cognitive Load Theory (Sweller, 1988)

Working memory has limited capacity. Effective instruction manages three types of cognitive load:

| Load Type | Definition | Design Strategy |
|-----------|-----------|-----------------|
| Intrinsic | Complexity inherent to the material | Sequence from simple to complex; chunk information |
| Extraneous | Load from poor instructional design | Eliminate redundancy; use spatial contiguity |
| Germane | Load from schema construction | Use worked examples; encourage self-explanation |

```python
# Estimate cognitive load using element interactivity
def estimate_intrinsic_load(elements: list, interactions: list) -> str:
    """
    elements: list of knowledge components
    interactions: list of (element_i, element_j) tuples that must be
                  processed simultaneously
    """
    interactivity = len(interactions) / max(len(elements), 1)
    if interactivity < 0.3:
        return "low intrinsic load - suitable for independent study"
    elif interactivity < 0.7:
        return "moderate intrinsic load - scaffold with worked examples"
    else:
        return "high intrinsic load - use fading strategy and segmenting"

# Example: teaching statistical regression
elements = ['variable', 'coefficient', 'intercept', 'residual', 'R-squared']
interactions = [('coefficient', 'variable'), ('intercept', 'residual'),
                ('coefficient', 'R-squared'), ('residual', 'R-squared')]
print(estimate_intrinsic_load(elements, interactions))
```

### Constructivism and Active Learning

Constructivist approaches emphasize that learners build knowledge through experience. Key active learning strategies with measured effect sizes (Freeman et al., 2014, PNAS):

- **Think-Pair-Share**: d = 0.41
- **Problem-Based Learning (PBL)**: d = 0.68
- **Peer Instruction (Mazur)**: d = 0.74
- **Inquiry-Based Labs**: d = 0.52

## Evidence-Based Study Methods

### Retrieval Practice

Testing is not just assessment -- it is a powerful learning tool (Roediger & Karpicke, 2006). Implement the testing effect:

```
Study Session Structure:
  1. Initial encoding (read/watch)          - 15 min
  2. Free recall (close materials, write)   - 10 min
  3. Check accuracy and fill gaps           -  5 min
  4. Spaced retrieval after 1 day           - 10 min
  5. Spaced retrieval after 7 days          - 10 min
  6. Spaced retrieval after 30 days         - 10 min
```

### Spaced Repetition Algorithms

Implement optimal review scheduling:

```python
def next_review_interval(repetition: int, ease_factor: float = 2.5,
                          quality: int = 4) -> float:
    """
    SM-2 inspired algorithm.
    repetition: number of successful reviews
    ease_factor: item difficulty (>= 1.3)
    quality: response quality 0-5
    """
    if quality < 3:
        return 1  # reset to 1 day
    if repetition == 0:
        return 1
    elif repetition == 1:
        return 6
    else:
        interval = 6 * (ease_factor ** (repetition - 1))
        # Adjust ease factor
        new_ef = ease_factor + (0.1 - (5 - quality) * (0.08 + (5 - quality) * 0.02))
        return round(interval, 1)

# Schedule for a moderately difficult concept
for rep in range(6):
    days = next_review_interval(rep)
    print(f"Review {rep + 1}: after {days} days")
```

### Interleaving and Desirable Difficulties

Research shows interleaved practice (mixing problem types) outperforms blocked practice for long-term retention (Rohrer & Taylor, 2007):

- Blocked: AAABBBCCC -> short-term gains, long-term forgetting
- Interleaved: ABCBACACB -> harder during practice, better retention

## Assessment Design

### Bloom's Taxonomy Alignment

Map learning objectives to assessment items across cognitive levels:

```yaml
remember:
  verbs: [define, list, recall, identify]
  assessment: "Multiple choice, matching"
understand:
  verbs: [explain, summarize, compare, classify]
  assessment: "Short answer, concept maps"
apply:
  verbs: [solve, demonstrate, use, implement]
  assessment: "Problem sets, simulations"
analyze:
  verbs: [differentiate, organize, attribute, deconstruct]
  assessment: "Case studies, data interpretation"
evaluate:
  verbs: [judge, critique, justify, appraise]
  assessment: "Peer review, rubric-based essays"
create:
  verbs: [design, construct, produce, formulate]
  assessment: "Research projects, portfolios"
```

### Item Analysis

After administering assessments, compute item difficulty (p-value) and discrimination index to validate question quality. Target p-values between 0.30 and 0.70 and discrimination indices above 0.30 for optimal measurement.

## References

- Sweller, J. (1988). Cognitive load during problem solving. *Cognitive Science*, 12(2), 257-285.
- Freeman, S., et al. (2014). Active learning increases student performance in science. *PNAS*, 111(23), 8410-8415.
- Roediger, H. L., & Karpicke, J. D. (2006). Test-enhanced learning. *Psychological Science*, 17(3), 249-255.

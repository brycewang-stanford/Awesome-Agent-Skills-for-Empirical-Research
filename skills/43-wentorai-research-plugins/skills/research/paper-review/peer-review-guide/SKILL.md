---
name: peer-review-guide
description: "Conduct thorough, constructive peer reviews and evaluate research papers"
metadata:
  openclaw:
    emoji: "🕵️"
    category: "research"
    subcategory: "paper-review"
    keywords: ["peer review", "reviewer comments", "paper evaluation", "paper reading assistant", "manuscript assessment"]
    source: "wentor"
---

# Peer Review Guide

A skill for conducting thorough, fair, and constructive peer reviews of academic manuscripts. Covers systematic evaluation frameworks, writing effective reviewer reports, and common evaluation criteria across disciplines.

## Review Process Overview

### Systematic Reading Strategy

```
First Pass (30 min): Skim for overall assessment
  - Read title, abstract, introduction, conclusion
  - Scan figures and tables
  - Assess: Is this paper in scope? Is the question important?

Second Pass (60-90 min): Detailed critical reading
  - Read the full paper carefully
  - Annotate unclear points, potential errors, missing references
  - Check methodology, statistical analyses, interpretation

Third Pass (30-60 min): Constructive feedback
  - Formulate your major and minor comments
  - Identify strengths to highlight
  - Draft your review report
```

## Evaluation Framework

### Core Assessment Dimensions

```python
def evaluate_manuscript(assessments: dict) -> dict:
    """
    Structured manuscript evaluation across key dimensions.

    Args:
        assessments: Dict mapping dimension to score (1-5) and comments
    """
    dimensions = {
        'novelty': {
            'weight': 0.20,
            'questions': [
                'Does this paper present new findings, methods, or perspectives?',
                'How does it advance beyond existing work?',
                'Is the contribution incremental or substantial?'
            ]
        },
        'significance': {
            'weight': 0.20,
            'questions': [
                'Is the research question important to the field?',
                'Will this work influence future research or practice?',
                'Is the scope appropriate for this journal?'
            ]
        },
        'methodology': {
            'weight': 0.25,
            'questions': [
                'Is the study design appropriate for the research question?',
                'Are methods described in sufficient detail to reproduce?',
                'Are statistical analyses appropriate and correctly applied?',
                'Are there threats to validity that are not addressed?'
            ]
        },
        'presentation': {
            'weight': 0.15,
            'questions': [
                'Is the paper clearly written and well organized?',
                'Are figures and tables informative and properly labeled?',
                'Is the paper an appropriate length?'
            ]
        },
        'literature': {
            'weight': 0.10,
            'questions': [
                'Is the related work section comprehensive?',
                'Are key prior studies cited and discussed?',
                'Is the paper properly positioned within the literature?'
            ]
        },
        'reproducibility': {
            'weight': 0.10,
            'questions': [
                'Are data and code available or described sufficiently?',
                'Could another researcher replicate this study?',
                'Are all materials, procedures, and analyses documented?'
            ]
        }
    }

    overall_score = 0
    evaluation = {}
    for dim, info in dimensions.items():
        score = assessments.get(dim, {}).get('score', 3)
        comment = assessments.get(dim, {}).get('comment', '')
        overall_score += score * info['weight']
        evaluation[dim] = {
            'score': score,
            'weight': info['weight'],
            'weighted_score': score * info['weight'],
            'comment': comment
        }

    evaluation['overall_score'] = round(overall_score, 2)
    evaluation['recommendation'] = (
        'Accept' if overall_score >= 4.0
        else 'Minor Revision' if overall_score >= 3.5
        else 'Major Revision' if overall_score >= 2.5
        else 'Reject'
    )

    return evaluation
```

## Writing the Review Report

### Structure Template

```
SUMMARY (2-3 sentences)
Briefly describe what the paper does and its main contribution.
This shows the authors you read and understood their work.

STRENGTHS (3-5 bullet points)
- Specific positive aspects
- "The experimental design is rigorous, with appropriate controls..."
- "The visualization in Figure 3 effectively communicates..."

MAJOR COMMENTS (numbered, typically 2-5)
Issues that must be addressed before the paper can be accepted.
These concern correctness, validity, or significant gaps.

1. [Specific concern with reference to section/page]
   "In Section 3.2, the assumption that X holds is questionable
    because [reason]. The authors should either provide evidence
    for this assumption or discuss what happens if it is relaxed."

2. [Another major concern]

MINOR COMMENTS (numbered, typically 3-10)
Suggestions for improvement that are not critical but would
strengthen the paper.

1. "On page 5, line 23: consider citing Smith et al. (2023)
    who address a similar phenomenon."

TYPOS AND FORMATTING (optional, brief list)
- Page 3, line 14: "effect" should be "affect"
- Table 2: column headers are cut off

CONFIDENTIAL COMMENTS TO THE EDITOR (separate section)
Overall assessment, conflicts of interest, ethical concerns.
This is NOT shared with the authors.
```

### Writing Effective Comments

```python
def format_review_comment(comment_type: str, section: str,
                           issue: str, suggestion: str) -> str:
    """
    Format a review comment following best practices.

    Args:
        comment_type: 'major' or 'minor'
        section: Where in the paper (e.g., 'Section 3.2, page 7')
        issue: What the problem is
        suggestion: How to address it
    """
    return (
        f"[{comment_type.upper()}] {section}\n"
        f"Issue: {issue}\n"
        f"Suggestion: {suggestion}\n"
    )

# Good review comment (specific, actionable, constructive):
print(format_review_comment(
    'major',
    'Section 4.1, Table 3',
    'The comparison with baseline methods uses different evaluation metrics '
    '(accuracy for the proposed method, F1 for baselines), making the '
    'comparison unfair.',
    'Please report the same set of metrics (precision, recall, F1, accuracy) '
    'for all methods, including the proposed approach, to enable fair comparison.'
))
```

## Common Red Flags to Check

### Statistical Issues
- p-hacking: Multiple comparisons without correction
- Selective reporting: Only positive results shown
- Inappropriate tests: Parametric tests on non-normal data
- Missing effect sizes: Only p-values reported
- Small sample with large claims: Low power, inflated effects

### Methodological Issues
- Lack of control group or baseline
- Data leakage in ML (test data used during training/validation)
- Confounding variables not addressed
- Circular reasoning in analysis

### Writing Issues
- Claims not supported by the data presented
- Overclaiming in the title or abstract
- Missing limitations section
- Insufficient detail for reproducibility

## Ethical Responsibilities of Reviewers

- Declare conflicts of interest promptly
- Maintain confidentiality -- do not share the manuscript or discuss it
- Complete reviews within the agreed timeline (typically 2-4 weeks)
- Be constructive -- the goal is to improve the paper, not to display superiority
- Do not use ideas from the manuscript under review in your own work
- If you suspect misconduct (fabrication, falsification, plagiarism), report to the editor confidentially

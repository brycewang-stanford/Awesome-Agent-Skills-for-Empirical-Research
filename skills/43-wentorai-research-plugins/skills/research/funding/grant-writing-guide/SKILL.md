---
name: grant-writing-guide
description: "Write competitive research proposals with clear objectives and budgets"
metadata:
  openclaw:
    emoji: "💰"
    category: "research"
    subcategory: "funding"
    keywords: ["research proposal writing", "grant proposal", "grant writing", "budget planning", "funding application"]
    source: "wentor"
---

# Grant Writing Guide

A skill for preparing competitive research grant proposals. Covers proposal structure, writing strategies, budget preparation, and common evaluation criteria used by major funding agencies (NSF, NIH, ERC, NSFC).

## Proposal Structure

### Generic Proposal Template

Most funding agencies require these core components:

```
1. Cover Page / Project Summary (1 page)
   - Title (concise, descriptive, no jargon)
   - PI name, institution, co-PIs
   - Total budget and duration
   - Abstract (250 words)
   - Keywords (5-8)

2. Project Description / Research Plan (10-15 pages typically)
   a. Introduction and Background
   b. Specific Aims / Research Questions
   c. Research Design and Methods
   d. Timeline and Milestones
   e. Expected Outcomes and Significance
   f. Broader Impacts (NSF) / Societal Relevance

3. Literature Cited / References

4. Budget and Budget Justification

5. Biographical Sketches / CVs

6. Data Management Plan

7. Facilities and Equipment

8. Supplementary Materials (letters of support, etc.)
```

## Writing the Specific Aims

### The Critical First Page

The specific aims page is the most important page of any NIH-style proposal. Reviewers often form their opinion based on this page alone.

```python
def specific_aims_template(project_info: dict) -> str:
    """
    Generate a specific aims page structure.

    Args:
        project_info: Dict with 'problem', 'gap', 'approach', 'aims', 'impact'
    """
    template = f"""
SPECIFIC AIMS

[Opening paragraph: The big picture problem]
{project_info['problem']}

[Gap paragraph: What is unknown/unsolved]
{project_info['gap']}

[Approach paragraph: What will you do and why]
{project_info['approach']}

The long-term goal of this research is [long-term vision].
The objective of this proposal is [specific objective].
The central hypothesis is [testable hypothesis],
based on [preliminary data / rationale].

The following specific aims will test this hypothesis:

Aim 1: {project_info['aims'][0]['title']}
  {project_info['aims'][0]['description']}
  Hypothesis: {project_info['aims'][0]['hypothesis']}

Aim 2: {project_info['aims'][1]['title']}
  {project_info['aims'][1]['description']}
  Hypothesis: {project_info['aims'][1]['hypothesis']}

[Impact paragraph]
{project_info['impact']}
"""
    return template
```

## Budget Preparation

### Common Budget Categories

```python
def create_budget(personnel: list[dict], equipment: list[dict],
                   travel: list[dict], other: list[dict],
                   indirect_rate: float = 0.55,
                   years: int = 3) -> dict:
    """
    Create a research budget with indirect costs.

    Args:
        personnel: List of {'role', 'salary', 'effort_pct', 'fringe_rate'}
        equipment: List of {'item', 'cost'}
        travel: List of {'purpose', 'cost_per_year'}
        other: List of {'item', 'cost_per_year'}
        indirect_rate: F&A rate (decimal)
        years: Project duration in years
    """
    budget = {'years': {}}

    for year in range(1, years + 1):
        year_budget = {'categories': {}}

        # Personnel (with annual salary increases of 3%)
        personnel_total = 0
        for person in personnel:
            salary = person['salary'] * (1.03 ** (year - 1))
            cost = salary * person['effort_pct'] / 100
            fringe = cost * person['fringe_rate']
            personnel_total += cost + fringe

        year_budget['categories']['personnel'] = round(personnel_total)

        # Equipment (Year 1 only for major items)
        equip_total = sum(e['cost'] for e in equipment) if year == 1 else 0
        year_budget['categories']['equipment'] = equip_total

        # Travel
        travel_total = sum(t['cost_per_year'] for t in travel)
        year_budget['categories']['travel'] = travel_total

        # Other direct costs
        other_total = sum(o['cost_per_year'] for o in other)
        year_budget['categories']['other'] = other_total

        # Modified total direct costs (MTDC excludes equipment >$5000)
        mtdc = personnel_total + travel_total + other_total
        if equip_total < 5000:
            mtdc += equip_total

        # Indirect costs
        indirect = mtdc * indirect_rate
        year_budget['categories']['indirect'] = round(indirect)

        year_budget['direct_total'] = round(
            personnel_total + equip_total + travel_total + other_total
        )
        year_budget['total'] = round(
            year_budget['direct_total'] + indirect
        )

        budget['years'][year] = year_budget

    budget['grand_total'] = sum(y['total'] for y in budget['years'].values())
    return budget

# Example budget
budget = create_budget(
    personnel=[
        {'role': 'PI', 'salary': 120000, 'effort_pct': 20, 'fringe_rate': 0.30},
        {'role': 'Postdoc', 'salary': 56000, 'effort_pct': 100, 'fringe_rate': 0.25},
        {'role': 'PhD Student', 'salary': 34000, 'effort_pct': 50, 'fringe_rate': 0.10}
    ],
    equipment=[{'item': 'GPU server', 'cost': 15000}],
    travel=[{'purpose': 'Conference attendance', 'cost_per_year': 3000}],
    other=[
        {'item': 'Publication charges', 'cost_per_year': 2000},
        {'item': 'Cloud computing', 'cost_per_year': 5000}
    ],
    indirect_rate=0.55,
    years=3
)
```

## Evaluation Criteria by Agency

### NSF Review Criteria

| Criterion | Weight | Key Questions |
|-----------|--------|---------------|
| Intellectual Merit | ~50% | Does it advance knowledge? Is the approach sound? |
| Broader Impacts | ~50% | Societal benefit? Education? Diversity? Infrastructure? |

### NIH Review Criteria (Scored 1-9)

| Criterion | Key Questions |
|-----------|---------------|
| Significance | Does it address an important problem? |
| Investigator(s) | Are PI and team qualified? |
| Innovation | Novel approaches or concepts? |
| Approach | Is the strategy well-reasoned and feasible? |
| Environment | Does the institution support the work? |

## Timeline and Milestones

### Gantt Chart Data Structure

```python
def create_project_timeline(aims: list[dict], total_months: int = 36) -> list[dict]:
    """Create a project timeline for a grant proposal."""
    timeline = []
    for aim in aims:
        for task in aim['tasks']:
            timeline.append({
                'aim': aim['name'],
                'task': task['name'],
                'start_month': task['start'],
                'end_month': task['end'],
                'milestone': task.get('milestone', ''),
                'deliverable': task.get('deliverable', '')
            })
    return timeline
```

## Common Mistakes to Avoid

1. **Overly ambitious scope**: Reviewers can tell when 3 years of funding is covering 10 years of work
2. **Weak preliminary data**: Show feasibility with pilot results
3. **Vague methods**: Specify exact techniques, sample sizes, and analysis plans
4. **Missing contingency plans**: Address "what if" scenarios for risky approaches
5. **Budget-narrative mismatch**: Every budget item must connect to the research plan
6. **Late submission**: Submit at least 24 hours before the deadline to avoid system crashes
7. **Ignoring reviewer feedback**: If resubmitting, address every prior critique explicitly

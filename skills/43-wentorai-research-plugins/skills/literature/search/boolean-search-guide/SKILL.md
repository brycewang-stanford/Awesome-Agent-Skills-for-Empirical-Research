---
name: boolean-search-guide
description: "Master Boolean operators and advanced search syntax for academic databases"
metadata:
  openclaw:
    emoji: "🔎"
    category: "literature"
    subcategory: "search"
    keywords: ["boolean search", "search operators", "database search", "PubMed", "Web of Science", "search strategy"]
    source: "wentor-research-plugins"
---

# Boolean Search Guide

A skill for constructing precise, reproducible search queries using Boolean operators across major academic databases. Covers AND, OR, NOT logic, proximity operators, truncation, field codes, and strategies for building systematic search strings.

## Boolean Operator Fundamentals

### Core Operators

```
AND  — Narrows results. Both terms must appear.
       "machine learning" AND "drug discovery"

OR   — Broadens results. Either term may appear.
       "deep learning" OR "neural network"

NOT  — Excludes results. Removes records containing the term.
       cancer NOT "lung cancer"

()   — Groups terms to control evaluation order.
       (COVID-19 OR SARS-CoV-2) AND (vaccine OR vaccination)
```

### Operator Precedence

Databases evaluate Boolean expressions in this order unless parentheses override:

1. Proximity operators (NEAR, ADJ, W/n)
2. NOT
3. AND
4. OR

Always use parentheses to make your intent explicit:

```
# Ambiguous (results depend on database precedence):
sleep disorders OR insomnia AND cognitive performance

# Clear (intended meaning explicit):
(sleep disorders OR insomnia) AND cognitive performance
```

## Advanced Search Syntax

### Truncation and Wildcards

```
*  — Truncation (unlimited characters)
     therap*  matches therapy, therapies, therapeutic, therapeutics

?  — Single-character wildcard
     wom?n  matches woman, women

$  — Optional character (some databases)
     behavio$r  matches behavior, behaviour
```

### Proximity Operators by Database

| Database | Operator | Example | Meaning |
|----------|----------|---------|---------|
| PubMed | Not supported | -- | Use phrase search instead |
| Web of Science | NEAR/n | climate NEAR/3 adaptation | Within 3 words |
| Scopus | W/n | gene W/5 therapy | Within 5 words, ordered |
| Scopus | PRE/n | drug PRE/3 resistance | First term precedes second |
| ProQuest | N/n, P/n | poverty N/5 education | Within 5 words |
| EBSCO | Nn | mental N3 health | Within 3 words |

### Field-Specific Searching

```
PubMed:
  "machine learning"[Title]
  "Smith J"[Author]
  "Nature"[Journal]
  "2020/01/01"[Date - Publication] : "2024/12/31"[Date - Publication]

Web of Science:
  TI=("deep learning")
  AU=(Smith, John)
  SO=(Nature)
  PY=(2020-2024)

Scopus:
  TITLE("deep learning")
  AUTH(Smith)
  SRCTITLE(Nature)
  PUBYEAR > 2019
```

## Building a Systematic Search Strategy

### PICO Framework for Query Construction

```python
def build_pico_search(population: str, intervention: str,
                      comparison: str, outcome: str) -> str:
    """
    Construct a Boolean search string from PICO components.

    Args:
        population: Target population terms (OR-separated)
        intervention: Intervention terms (OR-separated)
        comparison: Comparator terms (OR-separated, may be empty)
        outcome: Outcome terms (OR-separated)

    Returns:
        Complete Boolean search string
    """
    blocks = []

    blocks.append(f"({population})")
    blocks.append(f"({intervention})")

    if comparison:
        blocks.append(f"({comparison})")

    blocks.append(f"({outcome})")

    return " AND ".join(blocks)


# Example: Effect of mindfulness on anxiety in college students
query = build_pico_search(
    population='"college students" OR "university students" OR undergraduates',
    intervention='mindfulness OR "mindfulness-based stress reduction" OR MBSR',
    comparison='"wait list" OR "waitlist" OR "usual care" OR "control group"',
    outcome='anxiety OR "generalized anxiety" OR GAD OR "anxiety symptoms"'
)
print(query)
```

### Iterative Refinement Workflow

```
1. Identify key concepts from your research question
2. List synonyms, related terms, and variant spellings for each concept
3. Combine synonyms within each concept using OR
4. Connect concept blocks using AND
5. Test the search in your target database
6. Review the first 50 results for relevance
7. If recall is too low: add more synonyms, use truncation
8. If precision is too low: add more AND blocks, use field limits
9. Document the final search string with date and result count
```

## Search Filters and Limits

### Common Filters Across Databases

```
Language:        English, Chinese, Spanish, etc.
Date range:      Publication year or date added
Document type:   Journal article, review, conference paper
Study design:    RCT, cohort, case-control (PubMed clinical queries)
Species:         Human, animal (PubMed)
Open access:     Free full text available
```

### PubMed Clinical Query Filters

PubMed provides validated search filters (hedges) for specific study types. Append these to your search:

```
# Therapy/Intervention (sensitive):
AND (randomized controlled trial[pt] OR controlled clinical trial[pt]
OR randomized[tiab] OR randomly[tiab] OR trial[tiab])

# Diagnosis (specific):
AND (sensitivity and specificity[MeSH] OR predictive value of tests[MeSH]
OR accuracy[tiab])

# Systematic Reviews:
AND (systematic review[pt] OR meta-analysis[pt] OR systematic[sb])
```

## Documenting and Reproducing Searches

For systematic reviews and reproducible research, always record:

- Database name and interface version
- Date the search was executed
- Complete search string with line numbers
- Number of results retrieved
- Any filters or limits applied
- Name of the person who ran the search

Store search strategies in a version-controlled file alongside your project so they can be independently verified and updated.

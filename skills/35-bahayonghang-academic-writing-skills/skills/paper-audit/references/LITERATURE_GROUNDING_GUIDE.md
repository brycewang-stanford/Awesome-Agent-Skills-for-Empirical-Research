# Literature Grounding Scoring Guide

New 9th dimension for ScholarEval v3.0: evaluates how well a paper is grounded in existing literature.

## Overview

Literature Grounding measures the extent to which a paper:
1. Covers relevant prior work comprehensively
2. Cites recent developments in the field
3. Accurately positions itself relative to existing literature
4. Identifies and fills genuine research gaps

## Scoring Rubric (1-10)

### Score Components

Literature Grounding uses a **mixed** source (Script + LLM):

- **Script component** (from `literature_compare.py`): Automated coverage analysis
  - Coverage ratio (cited papers found in search results)
  - Recency score (fraction of recent papers cited)
  - Missing references penalty
  - Freshness distribution

- **LLM component** (from Domain Reviewer): Qualitative assessment
  - Thematic organization quality
  - Critical analysis depth
  - Research gap derivation
  - Citation context accuracy

### Scoring Criteria

| Score | Level | Behavioral Indicators |
|-------|-------|----------------------|
| 9-10 | Excellent | Comprehensive coverage of seminal and recent works; thematically organized; clear gap derivation; no important missing references |
| 7-8 | Good | Solid coverage with minor gaps; mostly thematic organization; adequate gap identification; 1-2 missing recent papers |
| 5-6 | Fair | Reasonable coverage but notable gaps; some enumeration instead of thematic analysis; weak gap derivation; several missing references |
| 3-4 | Poor | Incomplete coverage; predominantly enumerated; no clear gap derivation; many important references missing |
| 1-2 | Failing | Minimal literature review; critical foundational works missing; no connection between literature and contribution |

### Script Score Computation

The script component (`compute_literature_grounding_score`) uses these weights:

| Factor | Weight | Description |
|--------|--------|-------------|
| Coverage ratio | 40% | `cited_and_found / total_found` -- higher is better |
| Recency | 20% | Fraction of results from last 3 years |
| Missing refs penalty | 30% | Penalizes `found_not_cited` important papers |
| Freshness | 10% | Distribution of publication years |

### LLM Evaluation Prompt

> Evaluate the literature grounding of this paper. Consider:
> - Does the paper cite foundational works with correct attribution?
> - Are key papers from the last 3 years covered?
> - Is the literature organized thematically with critical analysis?
> - Is there an explicit research gap connecting literature to this paper's contribution?
> - Are there obvious omissions in the related work section?

### Merge Rule

Final score = average(script_partial, llm_score) when both available.
Use whichever is available when only one source has data.

## Relationship to Domain Reviewer

The Domain Reviewer agent provides the LLM component of Literature Grounding through its existing literature assessment criteria (A1-A4):
- A1: Thematic vs enumerated organization
- A2: Critical analysis completeness
- A3: Research gap derivation
- A4: Citation density funnel

## Integration

- CLI flag: `--literature-search` enables the script component
- Without `--literature-search`, Literature Grounding shows "N/A (awaiting literature search)"
- In review mode, the Domain Reviewer always provides the LLM component

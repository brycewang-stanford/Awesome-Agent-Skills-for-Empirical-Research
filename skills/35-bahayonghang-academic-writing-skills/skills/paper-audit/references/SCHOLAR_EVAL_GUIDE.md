# ScholarEval 8-Dimension Scoring Guide

Based on ScholarEval (arXiv:2510.16234), adapted for the Paper Audit skill.

## Overview

ScholarEval evaluates academic papers across 8 dimensions using a hybrid
script + LLM approach. Script-based dimensions use automated issue detection;
LLM-based dimensions require reading the full paper.

## Dimensions

### 1. Soundness (20%, Script)

**What it measures**: Technical correctness, logical validity, well-supported claims.

**Scoring criteria**:
| Score | Description |
|-------|-------------|
| 9-10 | Flawless logic, all claims rigorously supported |
| 7-8 | Sound methodology with minor gaps |
| 5-6 | Some logical issues or unsupported claims |
| 3-4 | Significant methodological concerns |
| 1-2 | Fundamental logical errors |

**Script source**: Deductions from LOGIC module issues.

### 2. Clarity (15%, Script)

**What it measures**: Writing quality, readability, organization.

**Scoring criteria**:
| Score | Description |
|-------|-------------|
| 9-10 | Exceptionally clear, well-organized, precise language |
| 7-8 | Clear writing with minor grammar/style issues |
| 5-6 | Readable but has notable style problems |
| 3-4 | Difficult to follow, significant language issues |
| 1-2 | Incomprehensible or severely disorganized |

**Script source**: Deductions from GRAMMAR, SENTENCES, FORMAT, DEAI modules.

### 3. Presentation (10%, Script)

**What it measures**: Visual quality, figure/table clarity, reference integrity.

**Scoring criteria**:
| Score | Description |
|-------|-------------|
| 9-10 | Professional figures, perfect references, clean layout |
| 7-8 | Good presentation with minor issues |
| 5-6 | Some figure/reference problems |
| 3-4 | Poor visual quality, broken references |
| 1-2 | Missing figures, numerous broken references |

**Script source**: Deductions from FIGURES, VISUAL, REFERENCES modules.

### 4. Novelty (15%, LLM)

**What it measures**: Originality of contributions, distinction from prior work.

**LLM evaluation prompt** (used in SKILL.md):
> Evaluate the novelty of this paper. Consider:
> - How different is the approach from existing methods?
> - Are the contributions genuinely new or incremental?
> - Does the paper clearly articulate what is novel?

**Scoring criteria**:
| Score | Description |
|-------|-------------|
| 9-10 | Paradigm-shifting contribution |
| 7-8 | Significant novelty, clearly beyond prior art |
| 5-6 | Moderate novelty, some overlap with existing work |
| 3-4 | Mostly incremental, limited differentiation |
| 1-2 | No novelty, rehashes known approaches |

### 5. Significance (15%, LLM)

**What it measures**: Potential impact on the field, community benefit.

**Scoring criteria**:
| Score | Description |
|-------|-------------|
| 9-10 | Likely to reshape the field |
| 7-8 | High impact, addresses important problem |
| 5-6 | Moderate impact, useful contribution |
| 3-4 | Limited impact, niche application |
| 1-2 | Negligible impact |

### 6. Reproducibility (10%, Mixed)

**What it measures**: Can others reproduce the results?

**Script component**: Checks for methodology-related issues in LOGIC module.
**LLM component**: Evaluates experimental description completeness, code/data availability.

**Scoring criteria**:
| Score | Description |
|-------|-------------|
| 9-10 | Complete code, data, and detailed methodology |
| 7-8 | Sufficient detail for reproduction with some effort |
| 5-6 | Key details present but gaps exist |
| 3-4 | Difficult to reproduce, missing key information |
| 1-2 | Impossible to reproduce from the paper alone |

### 7. Ethics (5%, LLM)

**What it measures**: Ethical considerations, conflicts of interest, data privacy.

**Scoring criteria**:
| Score | Description |
|-------|-------------|
| 9-10 | Thorough ethics discussion, no concerns |
| 7-8 | Adequate ethics consideration |
| 5-6 | Some ethical aspects overlooked |
| 3-4 | Notable ethical concerns unaddressed |
| 1-2 | Serious ethical violations |

### 8. Literature Grounding (12%, Mixed) -- NEW in v3.0

**What it measures**: How well the paper is grounded in and positioned within existing literature.

**Script component**: Automated literature search coverage analysis via `literature_compare.py`.
**LLM component**: Domain Reviewer's qualitative literature assessment.

**Requires**: `--literature-search` flag for script component.

**Scoring criteria**:
| Score | Description |
|-------|-------------|
| 9-10 | Comprehensive coverage, thematic organization, clear gap derivation |
| 7-8 | Solid coverage with minor gaps, adequate organization |
| 5-6 | Reasonable coverage but notable gaps, weak gap identification |
| 3-4 | Incomplete coverage, enumerated rather than thematic |
| 1-2 | Minimal or absent literature review |

See `references/LITERATURE_GROUNDING_GUIDE.md` for detailed scoring rubric.

### 9. Overall (10%, Computed)

Weighted average of all available dimension scores, normalized for missing values.

## Publication Readiness Scale

| Score | Label | Meaning |
|-------|-------|---------|
| 9.0+ | Strong Accept | Ready for top venue submission |
| 8.0-8.9 | Accept | Publication ready with confidence |
| 7.0-7.9 | Minor Revisions | Ready after addressing minor issues |
| 6.0-6.9 | Major Revisions | Significant improvements needed |
| 5.0-5.9 | Significant Rework | Substantial revision required |
| <5.0 | Not Ready | Not suitable for submission |

## Deduction Rules (Script Dimensions)

Issues detected by automated checks reduce scores from a base of 10:

| Severity | Deduction |
|----------|-----------|
| Critical | -2.5 |
| Major | -1.25 |
| Minor | -0.5 |

Minimum score is 1.0 (floor).

## LLM Evaluation JSON Format

When using `--llm-json`, provide a file with this structure:

```json
{
  "novelty": {
    "score": 7.5,
    "evidence": "The paper introduces a novel attention mechanism..."
  },
  "significance": {
    "score": 8.0,
    "evidence": "Addresses a critical gap in real-time processing..."
  },
  "reproducibility_llm": {
    "score": 6.5,
    "evidence": "Code is promised but not yet released..."
  },
  "ethics": {
    "score": 9.0,
    "evidence": "No ethical concerns identified..."
  }
}
```

## Relationship to NeurIPS 4-Dimension Scoring

ScholarEval is **complementary** to the existing 4-dimension NeurIPS scoring:
- NeurIPS: Quality, Clarity, Significance, Originality (1-6 scale)
- ScholarEval: 8 dimensions (1-10 scale)

Both systems run independently and appear in the report side by side.
Enable ScholarEval with the `--scholar-eval` flag.

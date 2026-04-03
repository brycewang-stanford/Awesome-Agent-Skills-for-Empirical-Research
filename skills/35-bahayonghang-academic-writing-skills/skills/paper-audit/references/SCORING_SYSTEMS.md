# Scoring Systems

## 4-Dimension Score (1.0-6.0, base 6.0 with deductions)

| Dimension | Weight | Primary Checks |
|-----------|--------|---------------|
| Quality | 30% | logic, bib, gbt7714 |
| Clarity | 30% | format, grammar, sentences, consistency, references, visual, figures |
| Significance | 20% | logic, checklist |
| Originality | 20% | deai, checklist |

## 9-Dimension ScholarEval (1.0-10.0, optional via `--scholar-eval`)

> **v3.0**: Now supports 9 dimensions with Literature Grounding. Use `--literature-search` for automated literature verification.

| Dimension | Weight | Source |
|-----------|--------|--------|
| Soundness | 18% | Script |
| Clarity | 13% | Script |
| Presentation | 8% | Script |
| Novelty | 13% | LLM |
| Significance | 13% | LLM |
| Reproducibility | 8% | Mixed |
| Ethics | 5% | LLM |
| Literature Grounding | 12% | Mixed (NEW) |
| Overall | 10% | Computed |

See `$SKILL_DIR/references/quality_rubrics.md` for score-level descriptors and decision mapping.

# Review Criteria

`paper-audit` now uses a **deep-review-first** standard.

There are two layers:

1. **Issue taxonomy** for actual reviewer findings
2. **Score mapping** for readiness summaries and gates

## Core Principles

- Understand the author's intended claim before flagging an issue.
- Prioritize evidence-backed findings over stylistic commentary.
- Flag ambiguity only when it could mislead a careful reader.
- Treat scores as indicators; treat issue bundles as the primary product.
- Keep `[Script]` and `[LLM]` findings separate.

## Deep Review Taxonomy

Check for:

1. mathematical or derivation errors
2. notation inconsistencies
3. prose vs equation / table / formal definition mismatch
4. numerical inconsistencies
5. insufficient justification for non-trivial choices or derivations
6. claim inaccuracy or overclaim
7. ambiguity that could mislead a careful reader
8. missing methodological detail or reproducibility-critical information
9. internal contradictions across sections
10. self-consistency of standards

## Scoring Layer

### 4-Dimension Summary

- **Quality**
  - soundness of claims
  - fairness of evaluation
  - correctness of derivations, statistics, and comparisons
- **Clarity**
  - notation consistency
  - organization
  - missing definitions and missing method detail
- **Significance**
  - whether the contribution matters if true
  - whether claims are scoped honestly
- **Originality**
  - novelty relative to prior work
  - honest differentiation from close baselines or precedents

### 9-Dimension ScholarEval Layer

Use ScholarEval when requested, but do not let score production displace issue finding. The issue bundle remains primary.

## Severity Calibration

- **major**
  - threatens a paper-level claim, methodology, comparison, or conclusion
- **moderate**
  - real issue, localized and fixable, but not paper-fatal
- **minor**
  - framing or clarity problem that still deserves attention

## Script vs Reviewer Judgment

### Typically script-backed

- undefined refs / labels / captions
- venue checklist failures
- visual layout issues
- some cross-section closure heuristics
- some literature-grounding or citation-stacking heuristics

### Typically reviewer-judgment

- overclaim
- evidence sufficiency
- fairness of comparisons
- self-consistency of standards
- prior-art overlap significance
- ambiguity severity

## Leniency Rules

Be lenient with:

- introductory simplifications
- forward references that are resolved later
- prose summaries that intentionally paraphrase formal statements
- OCR artifacts or isolated symbol noise when PDF parsing is imperfect

Do not flag:

- formatting trivia
- capitalization-only issues
- domain-obvious shorthand that no careful reviewer would misunderstand

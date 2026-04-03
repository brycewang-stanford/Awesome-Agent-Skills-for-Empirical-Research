# Review Lane Guide

Default `deep-review` lanes:

## Section lanes

- `section_intro_related`
  - check framing, novelty positioning, and promises made early in the paper
- `section_methods`
  - check definitions, assumptions, derivations, and method detail
- `section_results`
  - check metric computation, evidence sufficiency, and comparison fairness
- `section_discussion_conclusion`
  - check interpretation, limitation handling, and claim closure
- `section_appendix`
  - check whether appendix material supports or contradicts headline claims

## Cross-cutting lanes

- `claims_vs_evidence`
- `notation_and_numeric_consistency`
- `evaluation_fairness_and_reproducibility`
- `self_standard_consistency`
- `prior_art_and_novelty_grounding`

## Output rule

Every lane must output JSON findings matching `ISSUE_SCHEMA.md`.

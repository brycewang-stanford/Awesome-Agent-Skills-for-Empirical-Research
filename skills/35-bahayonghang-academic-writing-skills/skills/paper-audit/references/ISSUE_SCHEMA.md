# Issue Schema

Canonical schema for `deep-review` findings.

```json
{
  "title": "short issue title",
  "quote": "exact quote from paper",
  "explanation": "reasoned explanation",
  "comment_type": "methodology|claim_accuracy|presentation|missing_information",
  "severity": "major|moderate|minor",
  "confidence": "high|medium|low",
  "source_kind": "script|llm",
  "source_section": "methods",
  "related_sections": ["results", "appendix"],
  "root_cause_key": "normalized-shared-key",
  "review_lane": "claims_vs_evidence",
  "gate_blocker": false,
  "quote_verified": true
}
```

## Required fields

- `title`
- `quote`
- `explanation`
- `comment_type`
- `severity`
- `source_kind`

## Guidance

- `root_cause_key` should stay stable across re-audits when the same issue persists.
- `gate_blocker` is only for issues that should fail a submission gate.
- `quote_verified` should be added after running `verify_quotes.py`.

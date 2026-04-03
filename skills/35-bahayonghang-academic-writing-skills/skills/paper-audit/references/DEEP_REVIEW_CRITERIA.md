# Deep Review Criteria

Use this file when running `deep-review`.

## What to check

1. **Formula / derivation errors**
2. **Notation inconsistency**
3. **Prose vs formal object mismatch**
4. **Numerical inconsistency**
5. **Insufficient justification**
6. **Claim accuracy / overclaim**
7. **Misleading ambiguity**
8. **Missing information / reproducibility gap**
9. **Internal contradiction**
10. **Self-consistency of standards**
11. **Table structure violations** — missing three-line format (booktabs), vertical lines present, inconsistent number precision within columns, caption placed below instead of above
12. **Abstract structural incompleteness** — missing elements in the five-element model (Background / Objective / Methods / Results / Conclusion), data-free results section, hollow conclusion that merely restates results
13. **Theory contribution deficiency** — core concepts undefined or ambiguous, no substantive dialogue with existing theories, theoretical increment not identifiable (see A5-A7 in domain_reviewer_agent.md)
14. **Qualitative methodology opacity** — sampling rationale missing, coding process undescribed, no saturation discussion, absent reflexivity in sensitive research (see B6-B10 in methodology_reviewer_agent.md)
15. **Pseudo-innovation / straw man** — fabricated research gap, mischaracterized prior work, selective citation that hides overlap with existing methods (see prior_art_reviewer_agent.md)
16. **Paragraph-level argument incoherence** — logical jumps between adjacent paragraphs, causal inversions, evidence that does not support the stated claim (see C5 in critical_reviewer_agent.md)

## Editor-in-Chief screening (gate mode)

For `gate` mode, an EIC screening pass runs before the detailed checklist. Read `agents/editor_in_chief_agent.md` for the full protocol. The EIC evaluates:

- Pitch quality: does the paper hook the reader within the first three paragraphs?
- Venue fit: is the paper appropriate for the target journal/conference?
- Fatal flaws: any issue that guarantees rejection regardless of technical merit?
- Presentation baseline: does the manuscript meet minimum professional standards?

A desk-reject verdict from EIC screening is a gate blocker.

## Reasoning style

For each finding:

- state what initially raised concern
- explain what context you checked
- say what remains unresolved
- keep the strongest evidence
- prefer one well-developed finding over several shallow duplicates

## What not to do

- do not report copy-editing trivia
- do not report obvious OCR glitches as author errors unless the issue survives the most charitable correction
- do not criticize a section for omitting content that clearly appears later

## Reviewer calibration

A strong paper may still have several major issues if they each threaten different conclusions. Do not over-merge distinct arguments.

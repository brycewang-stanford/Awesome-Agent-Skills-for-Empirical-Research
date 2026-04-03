# Figure Interpretation in Results Reports

A results report should not dump figures.

For each major figure, write four blocks:
- **Why this figure exists**
- **What to notice**
- **What interpretation is supported**
- **What this changes in the project decision**

## Example micro-structure

### Figure X
- Purpose: compare adapter vs freezing under the same transfer setting.
- Observation: adapter improves mean WER and reduces variance.
- Interpretation: subject-specific adaptation likely resolves part of the transfer mismatch.
- Decision implication: prioritize adapter ablations before expanding frozen-only variants.

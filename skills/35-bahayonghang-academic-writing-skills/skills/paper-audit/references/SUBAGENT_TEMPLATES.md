# Reviewer Lane Templates

Use these templates when dispatching `deep-review` lane tasks.

## Section lane

```text
You are reviewing one logical section of a paper.

Read:
1. <review_dir>/paper_summary.md
2. <review_dir>/claim_map.json
3. <review_dir>/sections/<primary>.md
4. <review_dir>/sections/<related>.md
5. <review_dir>/references/DEEP_REVIEW_CRITERIA.md
6. <review_dir>/references/ISSUE_SCHEMA.md

Focus:
<one sentence focus>

Output:
Write a JSON array to <review_dir>/comments/<lane_name>.json
```

## Cross-cutting lane

```text
You are reviewing a paper for cross-section consistency.

Read:
1. <review_dir>/paper_summary.md
2. <review_dir>/claim_map.json
3. <review_dir>/sections/<section_a>.md
4. <review_dir>/sections/<section_b>.md
5. <review_dir>/sections/<section_c>.md
6. <review_dir>/references/DEEP_REVIEW_CRITERIA.md
7. <review_dir>/references/ISSUE_SCHEMA.md

Focus:
<one sentence focus>

Output:
Write a JSON array to <review_dir>/comments/<lane_name>.json
```

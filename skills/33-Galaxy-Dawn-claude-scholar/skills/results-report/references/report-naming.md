# Report Naming Standard

## Filename

Use:

```text
YYYY-MM-DD--{experiment-line}--r{round}--{purpose}.md
```

Rules:
- date must be the report date,
- `experiment-line` should be short and stable,
- `round` should be zero-padded only if that is already the project convention; otherwise `r3` / `r03` are both acceptable if used consistently,
- `purpose` should describe why the report exists, not a vague label like `summary` unless that is truly the purpose.

Recommended purpose values:
- `transfer-summary`
- `ablation-report`
- `failure-analysis`
- `robustness-check`
- `round-review`

## Title

Use:

```text
{Experiment Line} / Round {N} / {Purpose} / {YYYY-MM-DD}
```

## Frontmatter fields

Required:
- `type: results-report`
- `date`
- `experiment_line`
- `round`
- `purpose`
- `status`
- `source_artifacts`
- `linked_experiments`
- `linked_results`

## Placement in Obsidian

Internal reports go to:

```text
Results/Reports/{filename}
```

Do not put internal experiment reports in `Writing/` unless they are already manuscript/slides/rebuttal material.

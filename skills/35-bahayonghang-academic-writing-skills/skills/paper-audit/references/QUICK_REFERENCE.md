# Quick Reference

## Modes

| Mode | Purpose |
|---|---|
| `quick-audit` | fast readiness screen |
| `deep-review` | reviewer-style structured critique |
| `gate` | PASS/FAIL submission gate |
| `re-audit` | compare current paper against earlier audit |
| `polish` | precheck before a polishing workflow |

Legacy aliases:

- `self-check` -> `quick-audit`
- `review` -> `deep-review`

## CLI

```bash
python audit.py <file> --mode quick-audit
python audit.py <file> --mode deep-review --scholar-eval --literature-search
python audit.py <file> --mode gate --format json
python audit.py <file> --mode re-audit --previous-report old_report.md
```

## Deep-review scripts

```bash
python prepare_review_workspace.py paper.tex --output-dir ./review_results
python consolidate_review_findings.py ./review_results/paper-slug
python verify_quotes.py ./review_results/paper-slug --write-back
python render_deep_review_report.py ./review_results/paper-slug
python diff_review_issues.py old_final_issues.json new_final_issues.json
```

## Main outputs

- `final_issues.json`
- `overall_assessment.txt`
- `review_report.md`
- `revision_roadmap.md`

# Deep Review Example Output

Example output from:

```bash
uv run python -B "$SKILL_DIR/scripts/prepare_review_workspace.py" paper.tex --output-dir ./review_results
uv run python -B "$SKILL_DIR/scripts/audit.py" paper.tex --mode deep-review --scholar-eval
uv run python -B "$SKILL_DIR/scripts/consolidate_review_findings.py" ./review_results/paper
uv run python -B "$SKILL_DIR/scripts/verify_quotes.py" ./review_results/paper --write-back
uv run python -B "$SKILL_DIR/scripts/render_deep_review_report.py" ./review_results/paper
```

---

# Deep Review Report

**Paper**: `paper.tex` | **Language**: EN | **Mode**: deep-review

## Overall Assessment

The paper addresses an important problem and the empirical setup is substantial, but the central contribution is currently weakened by three issues: the abstract claims broader gains than the experiments support, the comparison protocol gives the proposed method extra flexibility relative to baselines, and one appendix table does not reconcile with the headline improvement numbers. These are fixable, but they are not cosmetic.

- **Major**: 3
- **Moderate**: 2
- **Minor**: 2

## Major Issues

### M1: Headline efficiency claim outruns the evidence
- **Type**: claim_accuracy
- **Source**: [LLM] via `claims_vs_evidence`
- **Section**: abstract
- **Quote**: `Our method achieves state-of-the-art efficiency across long-document understanding tasks.`
- **Explanation**: The results table only supports this claim for sequences above 8K tokens. For shorter sequences, the best baseline is comparable.

### M2: Comparison protocol is asymmetric
- **Type**: methodology
- **Source**: [LLM] via `evaluation_fairness_and_reproducibility`
- **Section**: experiment
- **Quote**: `We tune our method over three retry runs while reporting each baseline once.`
- **Explanation**: This gives the proposed system more chances to succeed than the baselines and weakens the fairness of the headline comparison.

## Moderate Issues

### O1: Appendix totals do not reconcile with headline improvements
- **Type**: claim_accuracy
- **Source**: [LLM] via `notation_and_numeric_consistency`
- **Section**: appendix
- **Quote**: `Average gain: 12.4`
- **Explanation**: The per-dataset gains listed in the appendix average to a different value.

## Revision Roadmap

### Priority 1
- [ ] Qualify the headline efficiency claim in the abstract and conclusion.
- [ ] Re-run the main comparison under symmetric evaluation conditions.

### Priority 2
- [ ] Reconcile appendix totals with headline metrics.
- [ ] Add a short note on when the method does not dominate the baseline.

#!/usr/bin/env python3
"""
ScholarEval 8-Dimension Assessment Framework.

Based on ScholarEval (arXiv:2510.16234), provides an 8-dimension evaluation
for academic papers using a script + LLM two-stage approach.

Stage 1 (Script): Computes scores for Soundness, Clarity, Presentation,
    and partial Reproducibility from audit issue data.
Stage 2 (LLM): Claude evaluates Novelty, Significance, Ethics,
    and full Reproducibility via structured prompts in SKILL.md.

Usage:
    python scholar_eval.py --audit-json audit_result.json
    python scholar_eval.py --audit-json audit_result.json --llm-json llm_scores.json
    python scholar_eval.py --audit-json audit_result.json --json
"""

from __future__ import annotations

import argparse
import json
import sys
from dataclasses import dataclass, field
from pathlib import Path

# --- Dimension Configuration ---

SCHOLAR_EVAL_DIMENSIONS: dict[str, dict] = {
    "soundness": {"weight": 0.18, "source": "script", "base": 10},
    "clarity": {"weight": 0.13, "source": "script", "base": 10},
    "presentation": {"weight": 0.08, "source": "script", "base": 10},
    "novelty": {"weight": 0.13, "source": "llm", "base": None},
    "significance": {"weight": 0.13, "source": "llm", "base": None},
    "reproducibility": {"weight": 0.08, "source": "mixed", "base": 10},
    "ethics": {"weight": 0.05, "source": "llm", "base": None},
    "literature_grounding": {"weight": 0.12, "source": "mixed", "base": 10},
    "overall": {"weight": 0.10, "source": "computed", "base": None},
}

READINESS_LABELS: list[tuple[float, str]] = [
    (9.0, "Strong Accept — Ready for top venue"),
    (8.0, "Accept — Publication ready"),
    (7.0, "Ready with minor revisions"),
    (6.0, "Major revisions needed"),
    (5.0, "Significant rework required"),
    (0.0, "Not ready for submission"),
]

# Deduction rules (on 1-10 scale)
DEDUCTIONS_10: dict[str, float] = {
    "Critical": 2.5,
    "Major": 1.25,
    "Minor": 0.5,
}


# --- Data Models ---


@dataclass
class ScholarEvalResult:
    """Complete ScholarEval assessment result."""

    script_scores: dict[str, float | None] = field(default_factory=dict)
    llm_scores: dict | None = None
    merged_scores: dict[str, float | None] = field(default_factory=dict)
    readiness_label: str = ""
    evidence: dict[str, str] = field(default_factory=dict)
    literature_context: object | None = None


# --- Score Computation ---


def _deduct_score(base: float, issues: list[dict]) -> float:
    """Compute score by deducting from base based on issue severities."""
    total_deduction = sum(DEDUCTIONS_10.get(i.get("severity", ""), 0) for i in issues)
    return max(1.0, base - total_deduction)


def _check_reproducibility_signals(issues: list[dict]) -> float:
    """Heuristic check for reproducibility signals from audit issues."""
    method_issues = [
        i
        for i in issues
        if i.get("module", "").upper() == "LOGIC" and "method" in i.get("message", "").lower()
    ]
    return _deduct_score(10, method_issues)


def evaluate_from_audit(
    audit_issues: list[dict],
    literature_grounding_score: float | None = None,
) -> dict[str, float | None]:
    """
    Compute script-evaluable dimension scores from audit issues.

    Args:
        audit_issues: List of issue dicts with keys: module, severity, message.
        literature_grounding_score: Optional score from literature_compare.py.

    Returns:
        Dict mapping dimension names to scores (1-10 scale).
    """
    # Group issues by module
    by_module: dict[str, list[dict]] = {}
    for issue in audit_issues:
        mod = issue.get("module", "").upper()
        by_module.setdefault(mod, []).append(issue)

    scores: dict[str, float | None] = {}

    # Soundness <- logic issues
    scores["soundness"] = _deduct_score(10, by_module.get("LOGIC", []))

    # Clarity <- grammar + sentences + format + deai
    clarity_issues = (
        by_module.get("GRAMMAR", [])
        + by_module.get("SENTENCES", [])
        + by_module.get("FORMAT", [])
        + by_module.get("DEAI", [])
    )
    scores["clarity"] = _deduct_score(10, clarity_issues)

    # Presentation <- figures + visual + references
    presentation_issues = (
        by_module.get("FIGURES", []) + by_module.get("VISUAL", []) + by_module.get("REFERENCES", [])
    )
    scores["presentation"] = _deduct_score(10, presentation_issues)

    # Reproducibility (partial) <- method-related issues
    scores["reproducibility_partial"] = _check_reproducibility_signals(audit_issues)

    # Literature Grounding (partial) <- from literature_compare.py
    scores["literature_grounding_partial"] = literature_grounding_score

    return scores


def merge_scores(
    script_scores: dict[str, float | None],
    llm_scores: dict | None = None,
) -> dict[str, float | None]:
    """
    Merge script scores and LLM scores into final per-dimension scores.

    Args:
        script_scores: Scores from evaluate_from_audit().
        llm_scores: Optional dict from LLM evaluation with keys like
            "novelty", "significance", "reproducibility_llm", "ethics",
            each containing {"score": float, "evidence": str}.
    """
    final: dict[str, float | None] = {}

    for dim, cfg in SCHOLAR_EVAL_DIMENSIONS.items():
        if dim == "overall":
            continue

        if cfg["source"] == "script":
            final[dim] = script_scores.get(dim)

        elif cfg["source"] == "llm":
            if llm_scores and dim in llm_scores:
                score_data = llm_scores[dim]
                if isinstance(score_data, dict):
                    final[dim] = score_data.get("score")
                else:
                    final[dim] = float(score_data) if score_data is not None else None
            else:
                final[dim] = None

        elif cfg["source"] == "mixed":
            # Reproducibility = avg(script_partial, llm) or whichever is available
            if dim == "reproducibility":
                sp = script_scores.get("reproducibility_partial")
                lp = None
                if llm_scores and "reproducibility_llm" in llm_scores:
                    lp_data = llm_scores["reproducibility_llm"]
                    if isinstance(lp_data, dict):
                        lp = lp_data.get("score")
                    else:
                        lp = float(lp_data) if lp_data is not None else None
            elif dim == "literature_grounding":
                sp = script_scores.get("literature_grounding_partial")
                lp = None
                if llm_scores and "literature_grounding_llm" in llm_scores:
                    lp_data = llm_scores["literature_grounding_llm"]
                    if isinstance(lp_data, dict):
                        lp = lp_data.get("score")
                    else:
                        lp = float(lp_data) if lp_data is not None else None
            else:
                sp = None
                lp = None

            if sp is not None and lp is not None:
                final[dim] = (sp + lp) / 2
            else:
                final[dim] = sp if sp is not None else lp

    # Overall = weighted average (skip None values)
    final["overall"] = _weighted_average(final)
    return final


def _weighted_average(scores: dict[str, float | None]) -> float | None:
    """Compute weighted average of available scores."""
    total_weight = 0.0
    weighted_sum = 0.0

    for dim, cfg in SCHOLAR_EVAL_DIMENSIONS.items():
        if dim == "overall":
            continue
        score = scores.get(dim)
        if score is not None:
            weighted_sum += score * cfg["weight"]
            total_weight += cfg["weight"]

    if total_weight == 0:
        return None

    # Normalize to account for missing dimensions
    return round(weighted_sum / total_weight, 1)


def get_readiness_label(overall_score: float | None) -> str:
    """Map overall score to publication readiness label."""
    if overall_score is None:
        return "Insufficient data for assessment"
    for threshold, label in READINESS_LABELS:
        if overall_score >= threshold:
            return label
    return "Not ready for submission"


def build_result(
    script_scores: dict[str, float | None],
    llm_scores: dict | None = None,
    use_regression: bool = False,
) -> ScholarEvalResult:
    """Build a complete ScholarEvalResult."""
    merged = merge_scores(script_scores, llm_scores)
    overall = merged.get("overall")
    label = get_readiness_label(overall)

    # Optionally use regression model for overall score
    if use_regression:
        try:
            from scoring_model import RegressionScorer

            model_path = Path(__file__).parent / "models" / "scoring_model.json"
            if model_path.exists():
                scorer = RegressionScorer.load_model(model_path)
            else:
                scorer = RegressionScorer()  # fallback mode
            prediction = scorer.predict(merged)
            merged["overall"] = prediction.predicted_score
            label = prediction.decision
        except Exception:
            pass  # Fall back to weighted average

    # Collect evidence from LLM scores
    evidence: dict[str, str] = {}
    if llm_scores:
        for dim in (
            "novelty",
            "significance",
            "reproducibility_llm",
            "ethics",
            "literature_grounding_llm",
        ):
            if dim in llm_scores and isinstance(llm_scores[dim], dict):
                ev = llm_scores[dim].get("evidence", "")
                # Map internal keys to display names
                display_dim = dim.replace("_llm", "")
                evidence[display_dim] = ev

    return ScholarEvalResult(
        script_scores=script_scores,
        llm_scores=llm_scores,
        merged_scores=merged,
        readiness_label=label,
        evidence=evidence,
    )


# --- Report Rendering ---


def render_scholar_eval_report(result: ScholarEvalResult) -> str:
    """Render ScholarEval assessment as Markdown table."""
    lines = ["## ScholarEval Assessment (9-Dimension)", ""]
    lines.append("| Dimension | Score | Weight | Source | Evidence |")
    lines.append("|-----------|-------|--------|--------|----------|")

    for dim, cfg in SCHOLAR_EVAL_DIMENSIONS.items():
        score = result.merged_scores.get(dim)
        score_str = f"{score:.1f}/10" if score is not None else "N/A (awaiting LLM)"
        weight_str = f"{cfg['weight']:.0%}"
        source = cfg["source"]
        evidence = result.evidence.get(dim, "—")
        if len(evidence) > 60:
            evidence = evidence[:57] + "..."
        lines.append(f"| {dim.title()} | {score_str} | {weight_str} | {source} | {evidence} |")

    lines.append("")
    lines.append(f"**Publication Readiness**: {result.readiness_label}")

    # Show which dimensions need LLM evaluation
    missing = [
        dim
        for dim, cfg in SCHOLAR_EVAL_DIMENSIONS.items()
        if cfg["source"] in ("llm", "mixed") and result.merged_scores.get(dim) is None
    ]
    if missing:
        lines.append("")
        lines.append(
            f"*Note: {', '.join(d.title() for d in missing)} require LLM evaluation "
            f"for complete assessment.*"
        )

    return "\n".join(lines)


# --- CLI ---


def main() -> int:
    """CLI entry point."""
    parser = argparse.ArgumentParser(
        description="ScholarEval 8-Dimension Assessment Framework",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  python scholar_eval.py --audit-json audit_result.json
  python scholar_eval.py --audit-json audit_result.json --llm-json llm_scores.json
  python scholar_eval.py --audit-json audit_result.json --json
        """,
    )
    parser.add_argument(
        "--audit-json",
        required=True,
        help="Path to audit result JSON (list of issue dicts)",
    )
    parser.add_argument(
        "--llm-json",
        help="Path to LLM evaluation JSON (optional)",
    )
    parser.add_argument(
        "--json",
        action="store_true",
        help="Output raw JSON instead of Markdown",
    )

    args = parser.parse_args()

    # Load audit issues
    audit_path = Path(args.audit_json)
    if not audit_path.exists():
        print(f"[ERROR] File not found: {args.audit_json}", file=sys.stderr)
        return 1

    try:
        audit_data = json.loads(audit_path.read_text(encoding="utf-8"))
    except json.JSONDecodeError as e:
        print(f"[ERROR] Invalid JSON: {e}", file=sys.stderr)
        return 1

    # Handle both list-of-issues and full-result formats
    if isinstance(audit_data, list):
        audit_issues = audit_data
    elif isinstance(audit_data, dict) and "issues" in audit_data:
        audit_issues = audit_data["issues"]
    else:
        print("[ERROR] Expected a list of issues or a dict with 'issues' key", file=sys.stderr)
        return 1

    # Stage 1: Script evaluation
    script_scores = evaluate_from_audit(audit_issues)

    # Stage 2: LLM evaluation (optional)
    llm_scores = None
    if args.llm_json:
        llm_path = Path(args.llm_json)
        if llm_path.exists():
            try:
                llm_scores = json.loads(llm_path.read_text(encoding="utf-8"))
            except json.JSONDecodeError as e:
                print(f"[WARNING] Invalid LLM JSON: {e}", file=sys.stderr)

    # Build result
    result = build_result(script_scores, llm_scores)

    # Output
    if args.json:
        output = {
            "script_scores": dict(result.script_scores.items()),
            "merged_scores": dict(result.merged_scores.items()),
            "readiness_label": result.readiness_label,
            "evidence": result.evidence,
        }
        if result.llm_scores:
            output["llm_scores"] = result.llm_scores
        print(json.dumps(output, indent=2, ensure_ascii=False))
    else:
        print(render_scholar_eval_report(result))

    return 0


if __name__ == "__main__":
    sys.exit(main())

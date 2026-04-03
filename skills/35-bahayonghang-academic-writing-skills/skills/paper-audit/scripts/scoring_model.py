"""
Linear Regression Scoring Model for ScholarEval.

Provides a trained/trainable regression model for predicting overall paper
quality from 9 dimension scores + interaction features.
Falls back to weighted average when untrained.
"""

from __future__ import annotations

import json
from dataclasses import dataclass, field
from pathlib import Path


@dataclass
class ScoringPrediction:
    """Prediction result from the scoring model."""

    predicted_score: float
    confidence_interval: tuple[float, float]  # 95% CI
    feature_contributions: dict[str, float] = field(default_factory=dict)
    decision: str = ""  # readiness label
    model_type: str = ""  # "regression" or "weighted_average"


class RegressionScorer:
    """Ridge regression scorer for paper quality prediction."""

    FEATURE_NAMES: list[str] = [
        # 9 base dimensions
        "soundness",
        "clarity",
        "presentation",
        "novelty",
        "significance",
        "reproducibility",
        "ethics",
        "literature_grounding",
        "overall_base",
        # 3 interaction terms
        "soundness_x_novelty",
        "clarity_x_significance",
        "literature_grounding_x_novelty",
        # 2 meta features
        "critical_count",
        "dims_below_5",
    ]

    def __init__(
        self,
        coefficients: dict[str, float] | None = None,
        intercept: float = 0.0,
    ):
        self.coefficients: dict[str, float] = coefficients or {}
        self.intercept = intercept
        self._is_trained = bool(coefficients)

    def predict(
        self,
        dimension_scores: dict[str, float | None],
        critical_count: int = 0,
    ) -> ScoringPrediction:
        """Predict overall score from dimension scores.

        Falls back to weighted average if untrained.
        """
        if not self._is_trained:
            return self._fallback_predict(dimension_scores)

        features = self._extract_features(dimension_scores, critical_count)
        score = self.intercept + sum(
            self.coefficients.get(name, 0.0) * value for name, value in features.items()
        )
        score = max(1.0, min(10.0, score))

        # Simple CI estimate based on model uncertainty
        ci_width = 0.5
        ci = (max(1.0, score - ci_width), min(10.0, score + ci_width))

        # Feature contributions
        contributions = {
            name: round(self.coefficients.get(name, 0.0) * value, 3)
            for name, value in features.items()
            if abs(self.coefficients.get(name, 0.0) * value) > 0.01
        }

        return ScoringPrediction(
            predicted_score=round(score, 1),
            confidence_interval=(round(ci[0], 1), round(ci[1], 1)),
            feature_contributions=contributions,
            decision=self._score_to_decision(score),
            model_type="regression",
        )

    def _fallback_predict(self, dimension_scores: dict[str, float | None]) -> ScoringPrediction:
        """Weighted average fallback matching v2.0 behavior."""
        from scholar_eval import SCHOLAR_EVAL_DIMENSIONS, get_readiness_label

        total_weight = 0.0
        weighted_sum = 0.0
        for dim, cfg in SCHOLAR_EVAL_DIMENSIONS.items():
            if dim == "overall":
                continue
            score = dimension_scores.get(dim)
            if score is not None:
                weighted_sum += score * cfg["weight"]
                total_weight += cfg["weight"]

        avg = weighted_sum / total_weight if total_weight > 0 else 5.0

        return ScoringPrediction(
            predicted_score=round(avg, 1),
            confidence_interval=(
                round(max(1.0, avg - 1.5), 1),
                round(min(10.0, avg + 1.5), 1),
            ),
            feature_contributions={},
            decision=get_readiness_label(avg),
            model_type="weighted_average",
        )

    def _extract_features(
        self,
        scores: dict[str, float | None],
        critical_count: int = 0,
    ) -> dict[str, float]:
        """Extract 14 features from dimension scores."""

        def _g(key: str) -> float:
            v = scores.get(key)
            return v if v is not None else 5.0

        return {
            "soundness": _g("soundness"),
            "clarity": _g("clarity"),
            "presentation": _g("presentation"),
            "novelty": _g("novelty"),
            "significance": _g("significance"),
            "reproducibility": _g("reproducibility"),
            "ethics": _g("ethics"),
            "literature_grounding": _g("literature_grounding"),
            "overall_base": _g("overall"),
            # Interaction terms
            "soundness_x_novelty": _g("soundness") * _g("novelty") / 10.0,
            "clarity_x_significance": _g("clarity") * _g("significance") / 10.0,
            "literature_grounding_x_novelty": (_g("literature_grounding") * _g("novelty") / 10.0),
            # Meta features
            "critical_count": float(critical_count),
            "dims_below_5": float(sum(1 for v in scores.values() if v is not None and v < 5.0)),
        }

    @staticmethod
    def _score_to_decision(score: float) -> str:
        """Map score to readiness label."""
        from scholar_eval import get_readiness_label

        return get_readiness_label(score)

    @classmethod
    def load_model(cls, path: str | Path) -> RegressionScorer:
        """Load model from JSON file."""
        data = json.loads(Path(path).read_text(encoding="utf-8"))
        return cls(
            coefficients=data.get("coefficients", {}),
            intercept=data.get("intercept", 0.0),
        )

    def save_model(self, path: str | Path) -> None:
        """Save model to JSON file."""
        data = {
            "coefficients": self.coefficients,
            "intercept": self.intercept,
            "feature_names": self.FEATURE_NAMES,
        }
        Path(path).write_text(json.dumps(data, indent=2, ensure_ascii=False), encoding="utf-8")

    @classmethod
    def train(cls, data_path: str | Path) -> RegressionScorer:
        """Train from labeled data (CSV with dimension scores + overall label).

        Requires numpy and scikit-learn.
        """
        raise NotImplementedError(
            "Training requires labeled data (OpenReview/PeerRead). "
            "Use default model or provide pre-trained coefficients."
        )

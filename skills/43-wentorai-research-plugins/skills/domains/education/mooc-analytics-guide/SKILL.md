---
name: mooc-analytics-guide
description: "Analyzing MOOC data, learning analytics, and online education metrics"
metadata:
  openclaw:
    emoji: "📈"
    category: "domains"
    subcategory: "education"
    keywords: ["mooc", "learning-analytics", "online-education", "edx", "coursera", "clickstream"]
    source: "wentor"
---

# MOOC Analytics Guide

A skill for analyzing Massive Open Online Course data, implementing learning analytics pipelines, and extracting actionable insights from online education platforms. Covers clickstream processing, engagement modeling, dropout prediction, and A/B testing for course design.

## Data Sources and Formats

### Common MOOC Data Schemas

MOOC platforms export several standard data types:

| Data Type | Description | Typical Format |
|-----------|-------------|----------------|
| Clickstream logs | Page views, video plays, pauses, seeks | JSON event logs |
| Forum posts | Discussion text, timestamps, thread structure | CSV/JSON |
| Grade records | Assignment scores, quiz attempts, certificates | CSV |
| Course structure | Module hierarchy, release dates, prerequisites | XML/JSON |
| Survey responses | Pre/post course surveys, demographics | CSV |

### Accessing Open MOOC Datasets

Several open datasets are available for research:

- **MOOCdb**: Standardized schema from MIT, includes clickstream, forum, and grade data
- **Stanford MOOCPosts**: 30,000+ labeled forum posts for sentiment and urgency classification
- **Open University Learning Analytics (OULAD)**: Anonymized data for 30,000+ students across 7 courses
- **edX Research Data Exchange**: Available to institutional partners via application

```python
import pandas as pd

# Load OULAD dataset (publicly available)
students = pd.read_csv("studentInfo.csv")
assessments = pd.read_csv("assessments.csv")
interactions = pd.read_csv("studentVle.csv")

# Basic engagement metric: total clicks per student per course
engagement = (
    interactions
    .groupby(["id_student", "code_module", "code_presentation"])
    .agg(total_clicks=("sum_click", "sum"),
         active_days=("date", "nunique"))
    .reset_index()
)
print(engagement.describe())
```

## Engagement and Retention Analysis

### Defining Engagement Metrics

Key metrics used in learning analytics research:

- **Session count**: Number of distinct learning sessions (gap-based, e.g., 30-min inactivity threshold)
- **Time on task**: Total seconds spent on content pages and videos
- **Video completion ratio**: Fraction of video duration actually watched
- **Forum participation rate**: Posts + replies per student per week
- **Assignment submission rate**: Fraction of graded assignments submitted on time
- **Regularity index**: Entropy of daily activity distribution (lower entropy = more regular)

```python
import numpy as np

def regularity_index(daily_counts: np.ndarray) -> float:
    """
    Compute regularity index based on Shannon entropy.
    Lower values indicate more regular study patterns.
    daily_counts: array of click counts per day over the course.
    """
    total = daily_counts.sum()
    if total == 0:
        return float("nan")
    probs = daily_counts / total
    probs = probs[probs > 0]
    entropy = -np.sum(probs * np.log2(probs))
    max_entropy = np.log2(len(daily_counts))
    return round(entropy / max_entropy, 4)  # normalized [0, 1]
```

### Dropout Prediction

Predicting which learners will drop out is a central MOOC analytics task:

```python
from sklearn.ensemble import GradientBoostingClassifier
from sklearn.model_selection import TimeSeriesSplit
from sklearn.metrics import roc_auc_score

# Feature engineering: weekly aggregates
features = [
    "clicks_week", "video_time_week", "forum_posts_week",
    "assignments_submitted", "avg_score", "days_since_last_login",
    "regularity_index", "week_number"
]

X = weekly_features[features]
y = weekly_features["dropped_next_week"]

# Time-aware cross-validation (no future leakage)
tscv = TimeSeriesSplit(n_splits=5)
aucs = []
for train_idx, test_idx in tscv.split(X):
    model = GradientBoostingClassifier(
        n_estimators=200, max_depth=4, learning_rate=0.1
    )
    model.fit(X.iloc[train_idx], y.iloc[train_idx])
    pred = model.predict_proba(X.iloc[test_idx])[:, 1]
    aucs.append(roc_auc_score(y.iloc[test_idx], pred))

print(f"Mean AUC: {np.mean(aucs):.3f} +/- {np.std(aucs):.3f}")
```

## Video Analytics

### Clickstream Processing for Video Events

Video interaction is the primary learning activity in MOOCs. Analyzing play, pause, seek, and speed-change events reveals learning patterns:

```python
def compute_video_metrics(events: pd.DataFrame) -> dict:
    """
    Process video clickstream events into engagement metrics.
    events: DataFrame with columns [user_id, video_id, event_type,
            timestamp, position_seconds, video_duration]
    """
    plays = events[events.event_type == "play"]
    pauses = events[events.event_type == "pause"]
    seeks = events[events.event_type == "seek"]

    total_duration = events.video_duration.iloc[0]
    watched_positions = set()

    for _, row in plays.iterrows():
        start = int(row.position_seconds)
        # Estimate 10-second watch window per play event
        for sec in range(start, min(start + 10, int(total_duration))):
            watched_positions.add(sec)

    return {
        "play_count": len(plays),
        "pause_count": len(pauses),
        "seek_count": len(seeks),
        "coverage_ratio": len(watched_positions) / max(total_duration, 1),
        "replay_indicator": len(plays) > 1,
    }
```

### Optimal Video Length

Research findings on video engagement (Guo et al., 2014):

- Videos under 6 minutes have the highest engagement
- Informal talking-head videos outperform studio productions
- Tablet drawing (Khan Academy style) is more engaging than slides
- Pre-production planning matters more than production quality

## A/B Testing for Course Design

### Experimental Design in MOOCs

MOOCs provide large sample sizes ideal for randomized experiments:

1. **Unit of randomization**: Typically the learner, but can be section or cohort
2. **Outcome metrics**: Completion rate, quiz scores, time to completion, forum engagement
3. **Duration**: Run for at least one full module cycle (typically 1-2 weeks)
4. **Power analysis**: With 10,000+ enrollees, even small effects (d=0.05) are detectable

```python
from scipy.stats import norm

def mooc_power_analysis(effect_size: float, n_per_group: int,
                        alpha: float = 0.05) -> float:
    """Compute statistical power for a two-sample t-test in MOOC A/B test."""
    z_alpha = norm.ppf(1 - alpha / 2)
    z_beta = effect_size * (n_per_group ** 0.5) / 2 - z_alpha
    power = norm.cdf(z_beta)
    return round(power, 4)

# Example: 5000 per group, small effect
print(mooc_power_analysis(0.1, 5000))  # ~0.94
```

## Tools and Platforms

- **edX Insights**: Built-in analytics dashboard for edX course teams
- **Google BigQuery** + **Coursera Research Exports**: SQL-based analysis at scale
- **Open edX**: Self-hosted platform with full database access (MySQL + MongoDB)
- **Learning Locker**: Open-source Learning Record Store (xAPI compliant)
- **MORF (MOOC Replication Framework)**: Docker-based reproducible analytics pipeline from University of Michigan

## Key References

- Guo, P.J., Kim, J., and Rubin, R. (2014). How video production affects student engagement. *ACM L@S*.
- Gardner, J. and Brooks, C. (2018). Student success prediction in MOOCs. *User Modeling and User-Adapted Interaction*.
- Reich, J. and Ruiperez-Valiente, J.A. (2019). The MOOC pivot. *Science*.

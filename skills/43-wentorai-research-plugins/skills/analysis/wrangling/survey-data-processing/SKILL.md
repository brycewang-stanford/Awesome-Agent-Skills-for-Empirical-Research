---
name: survey-data-processing
description: "Clean, recode, and prepare survey response data for analysis"
metadata:
  openclaw:
    emoji: "📋"
    category: "analysis"
    subcategory: "wrangling"
    keywords: ["survey data", "questionnaire coding", "Likert scale", "response validation", "recoding", "survey analysis"]
    source: "wentor-research-plugins"
---

# Survey Data Processing

A skill for cleaning, recoding, and preparing survey response data for statistical analysis. Covers handling common survey data issues such as incomplete responses, attention check failures, reverse-coded items, scale construction, open-ended response coding, and export to analysis-ready formats compatible with SPSS, Stata, and R.

## Survey Data Quality Assessment

### Initial Inspection Workflow

Survey data from platforms like Qualtrics, SurveyMonkey, REDCap, and Google Forms each have their own export formats and quirks. The first step is always standardization.

```python
import pandas as pd
import numpy as np

def assess_survey_quality(df, duration_col="duration_seconds",
                          min_duration=60):
    """
    Generate a survey data quality report.

    Checks:
    - Completion rates per question
    - Response duration (speeders and slow responders)
    - Straight-line responding patterns
    - Attention check failures
    """
    report = {}

    # Overall completion
    total_respondents = len(df)
    complete = df.dropna(thresh=int(len(df.columns) * 0.8))
    report["total_responses"] = total_respondents
    report["substantially_complete"] = len(complete)
    report["completion_rate"] = f"{len(complete)/total_respondents*100:.1f}%"

    # Duration analysis
    if duration_col in df.columns:
        durations = df[duration_col].dropna()
        report["median_duration_seconds"] = durations.median()
        report["speeders"] = (durations < min_duration).sum()
        report["speeder_pct"] = f"{(durations < min_duration).mean()*100:.1f}%"

    # Missing data per question
    missing_by_col = df.isna().sum().sort_values(ascending=False)
    report["most_skipped_questions"] = missing_by_col.head(10).to_dict()

    return report
```

### Identifying Low-Quality Responses

```python
def detect_straightlining(df, likert_columns, threshold=0.9):
    """
    Detect respondents who select the same answer for nearly
    all Likert-scale questions (straight-line responding).

    A respondent is flagged if the proportion of their most
    common response exceeds the threshold.
    """
    flagged = []
    for idx, row in df[likert_columns].iterrows():
        responses = row.dropna()
        if len(responses) == 0:
            continue
        most_common_pct = responses.value_counts().iloc[0] / len(responses)
        if most_common_pct >= threshold:
            flagged.append(idx)

    return flagged


def check_attention_items(df, attention_checks):
    """
    Validate attention check (trap) questions.

    Args:
        attention_checks: dict of {column_name: correct_answer}
        Example: {"q15_attention": 4, "q32_trap": "strongly agree"}
    """
    failed = pd.Series(False, index=df.index)
    for col, correct in attention_checks.items():
        failed = failed | (df[col] != correct)

    return df.index[failed].tolist()
```

## Recoding and Transformation

### Reverse Coding

Many validated psychological scales include reverse-coded items to detect acquiescence bias. These must be recoded before computing scale scores.

```python
def reverse_code(df, columns, scale_max, scale_min=1):
    """
    Reverse-code specified columns for Likert-type scales.

    Formula: reversed = (scale_max + scale_min) - original

    Example for a 1-5 scale:
      1 -> 5, 2 -> 4, 3 -> 3, 4 -> 2, 5 -> 1
    """
    df_recoded = df.copy()
    for col in columns:
        df_recoded[col] = (scale_max + scale_min) - df[col]
    return df_recoded


# Example usage with a Big Five personality scale
reverse_items = {
    "extraversion": ["ext_2", "ext_4", "ext_6"],
    "neuroticism": ["neur_1", "neur_3", "neur_5"],
    "agreeableness": ["agree_3", "agree_5"],
}

# For a 1-7 Likert scale:
for construct, items in reverse_items.items():
    df = reverse_code(df, items, scale_max=7, scale_min=1)
```

### Scale Construction

```python
def compute_scale_scores(df, scale_definitions, method="mean"):
    """
    Compute composite scale scores from individual items.

    Args:
        scale_definitions: dict mapping scale name to list of columns
        method: "mean" or "sum"

    Returns:
        DataFrame with new scale score columns
    """
    for scale_name, items in scale_definitions.items():
        if method == "mean":
            df[scale_name] = df[items].mean(axis=1)
        elif method == "sum":
            df[scale_name] = df[items].sum(axis=1)

        # Also compute Cronbach's alpha for reliability
        alpha = cronbachs_alpha(df[items])
        print(f"{scale_name}: alpha = {alpha:.3f} "
              f"(n_items = {len(items)})")

    return df


def cronbachs_alpha(item_df):
    """
    Compute Cronbach's alpha for internal consistency reliability.
    Values above 0.70 are generally considered acceptable.
    """
    item_df = item_df.dropna()
    n_items = item_df.shape[1]
    if n_items < 2:
        return np.nan

    item_variances = item_df.var(axis=0, ddof=1)
    total_variance = item_df.sum(axis=1).var(ddof=1)

    alpha = (n_items / (n_items - 1)) * (
        1 - item_variances.sum() / total_variance
    )
    return alpha
```

## Open-Ended Response Processing

### Coding Qualitative Responses

```python
def code_open_responses(df, text_column, codebook):
    """
    Apply a predefined codebook to open-ended responses using
    keyword matching. For research-quality coding, this should
    be supplemented with manual coding by trained raters.

    Args:
        codebook: dict mapping code names to keyword lists
        Example: {
            "financial_concern": ["money", "cost", "expensive", "afford"],
            "time_constraint": ["time", "busy", "schedule", "hours"],
            "quality_issue": ["quality", "broken", "defect", "poor"],
        }
    """
    for code_name, keywords in codebook.items():
        pattern = "|".join(keywords)
        df[f"code_{code_name}"] = (
            df[text_column]
            .str.lower()
            .str.contains(pattern, na=False)
            .astype(int)
        )

    return df
```

### Inter-Rater Reliability

```
When multiple coders classify open-ended responses:

Cohen's Kappa (2 raters):
  - < 0.20: poor agreement
  - 0.21-0.40: fair
  - 0.41-0.60: moderate
  - 0.61-0.80: substantial
  - 0.81-1.00: almost perfect

Fleiss' Kappa (3+ raters):
  - Same interpretation scale as Cohen's
  - Use when more than two raters code the same responses

Process:
  1. Develop codebook with definitions and examples
  2. Train coders on 10-20 practice responses
  3. Code 20% of responses independently (overlap set)
  4. Calculate inter-rater reliability on the overlap set
  5. If kappa < 0.70, discuss disagreements and refine codebook
  6. Repeat until acceptable reliability is achieved
  7. Divide remaining responses among coders
```

## Data Reshaping for Analysis

### Wide to Long Format

Survey data is typically exported in wide format (one row per respondent, one column per question). Many analyses require long format.

```python
def reshape_repeated_measures(df, id_col, time_points,
                              measure_prefix):
    """
    Reshape repeated-measures survey data from wide to long.

    Example: columns q1_pre, q1_post -> long format with
    time column ("pre", "post") and value column.
    """
    value_vars = [f"{measure_prefix}_{t}" for t in time_points]

    long_df = pd.melt(
        df,
        id_vars=[id_col],
        value_vars=value_vars,
        var_name="time_point",
        value_name=measure_prefix
    )

    # Clean time_point column
    long_df["time_point"] = (
        long_df["time_point"]
        .str.replace(f"{measure_prefix}_", "")
    )

    return long_df
```

## Export for Statistical Software

```
Export formats by software:

SPSS (.sav):
  - Use pyreadstat: pyreadstat.write_sav(df, "output.sav")
  - Include variable labels and value labels
  - Set measurement level (nominal, ordinal, scale)

Stata (.dta):
  - Use pandas: df.to_stata("output.dta")
  - Include variable labels via write_stata with labels dict

R (.csv with codebook):
  - Export CSV plus a separate codebook document
  - Or use pyreadstat to write .rds format
  - Include factor level definitions

General best practices:
  - Include a unique respondent ID column
  - Use numeric codes for categorical variables (with labels)
  - Document all recoding in a companion codebook
  - Save both raw and processed versions
  - Include a timestamp column for data versioning
```

Proper survey data processing is essential for valid statistical inference. Decisions made during cleaning and recoding directly affect research conclusions, making transparent documentation of every step a methodological requirement rather than a convenience.

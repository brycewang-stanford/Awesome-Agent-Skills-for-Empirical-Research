---
name: questionnaire-design-guide
description: "Questionnaire and survey design with Likert scales and coding"
metadata:
  openclaw:
    emoji: "📋"
    category: "analysis"
    subcategory: "wrangling"
    keywords: ["questionnaire design", "survey design", "Likert scale", "data transformation"]
    source: "wentor-research-plugins"
---

# Questionnaire Design Guide

Design valid and reliable survey instruments with proper question types, Likert scale construction, response coding, and data preparation for analysis.

## Survey Design Principles

### Question Types

| Type | Example | Best For | Analysis |
|------|---------|----------|----------|
| **Likert scale** | "Rate your agreement: 1-5" | Attitudes, perceptions | Ordinal/interval statistics |
| **Multiple choice** | "Select your field" | Demographics, categories | Frequencies, chi-square |
| **Ranking** | "Rank these 5 options" | Preferences, priorities | Rank correlations |
| **Open-ended** | "Describe your experience" | Exploratory, rich data | Qualitative coding |
| **Matrix/grid** | Multiple items, same scale | Efficient battery of items | Factor analysis, reliability |
| **Slider/VAS** | 0-100 visual analog scale | Continuous measures | Parametric statistics |
| **Semantic differential** | "Easy __ __ __ __ __ Difficult" | Bipolar attitudes | Factor analysis |

### The Four C's of Good Questions

1. **Clear**: Avoid jargon, double-barreled questions, and ambiguity
2. **Concise**: Keep questions short (ideally under 20 words)
3. **Complete**: Include all relevant response options
4. **Consistent**: Use the same scale direction and format throughout

## Likert Scale Design

### Scale Points

| Points | Scale Example | Recommended Use |
|--------|---------------|-----------------|
| 4-point | Strongly Disagree to Strongly Agree | Forces choice (no neutral), less discriminating |
| 5-point | SD, D, Neutral, A, SA | Most common, good balance of simplicity and discrimination |
| 7-point | SD, D, Somewhat D, Neutral, Somewhat A, A, SA | More discriminating, better for experienced respondents |
| 11-point (0-10) | Not at all to Completely | NPS, continuous-like measures |

### Anchoring Labels

```
5-Point Agreement Scale:
1 = Strongly Disagree
2 = Disagree
3 = Neither Agree nor Disagree
4 = Agree
5 = Strongly Agree

5-Point Frequency Scale:
1 = Never
2 = Rarely
3 = Sometimes
4 = Often
5 = Always

5-Point Satisfaction Scale:
1 = Very Dissatisfied
2 = Dissatisfied
3 = Neutral
4 = Satisfied
5 = Very Satisfied
```

### Reverse-Coded Items

Include 2-3 reverse-coded items per construct to detect acquiescence bias:

```
Regular:  "I find research methods interesting."        (1-5: SD to SA)
Reversed: "I find research methods tedious and dull."   (1-5: SD to SA)

# Recode reversed items before analysis:
# reversed_score = (max_scale + 1) - raw_score
# For a 5-point scale: reversed_score = 6 - raw_score
```

## Constructing a Multi-Item Scale

### Step-by-Step Process

1. **Define the construct**: Write a clear conceptual definition
2. **Generate items**: Write 1.5-2x the number of items you plan to keep (e.g., write 15 items for an 8-item scale)
3. **Expert review**: Have 3-5 experts rate each item for relevance (Content Validity Index)
4. **Pilot test**: Administer to 30-50 respondents
5. **Item analysis**: Calculate item-total correlations, check reliability
6. **Exploratory Factor Analysis (EFA)**: Confirm dimensionality
7. **Finalize scale**: Remove weak items, re-test reliability

### Example: Research Self-Efficacy Scale

```
Construct: Belief in one's ability to conduct academic research

Items (5-point Likert, Strongly Disagree to Strongly Agree):
RSE1: I can formulate clear research questions.
RSE2: I can design an appropriate research methodology.
RSE3: I can analyze data using statistical software.
RSE4: I can write a publishable research paper.
RSE5: I can critically evaluate published research.
RSE6: I can present research findings at a conference.
RSE7R: I struggle to interpret statistical results. [REVERSED]
RSE8R: I find it difficult to synthesize literature. [REVERSED]
```

## Data Coding and Preparation

### Coding Scheme

```python
import pandas as pd
import numpy as np

# Define coding scheme
likert_coding = {
    "Strongly Disagree": 1,
    "Disagree": 2,
    "Neither Agree nor Disagree": 3,
    "Agree": 4,
    "Strongly Agree": 5
}

# Apply coding
df["Q1_coded"] = df["Q1_raw"].map(likert_coding)

# Reverse code specific items
reverse_items = ["RSE7R", "RSE8R"]
max_scale = 5
for item in reverse_items:
    df[f"{item}_recoded"] = (max_scale + 1) - df[item]

# Calculate composite score (mean of items)
scale_items = ["RSE1", "RSE2", "RSE3", "RSE4", "RSE5", "RSE6",
               "RSE7R_recoded", "RSE8R_recoded"]
df["RSE_mean"] = df[scale_items].mean(axis=1)
```

### Missing Data Handling

```python
# Check missing data patterns
print(df[scale_items].isnull().sum())
print(f"Complete cases: {df[scale_items].dropna().shape[0]} / {df.shape[0]}")

# Common strategies:
# 1. Listwise deletion (if < 5% missing)
df_complete = df.dropna(subset=scale_items)

# 2. Mean imputation per item (simple but biased)
df[scale_items] = df[scale_items].fillna(df[scale_items].mean())

# 3. Person-mean imputation (if < 20% of items missing per person)
def person_mean_impute(row, items, max_missing=2):
    if row[items].isnull().sum() <= max_missing:
        return row[items].fillna(row[items].mean())
    return row[items]  # leave as NaN if too many missing

df[scale_items] = df.apply(lambda r: person_mean_impute(r, scale_items), axis=1)
```

## Reliability Analysis

### Cronbach's Alpha

```python
import pingouin as pg

# Calculate Cronbach's alpha
alpha = pg.cronbach_alpha(df[scale_items])
print(f"Cronbach's alpha: {alpha[0]:.3f}")
# Interpretation: >= 0.70 acceptable, >= 0.80 good, >= 0.90 excellent
```

```r
library(psych)

# Cronbach's alpha with item-level diagnostics
alpha_result <- alpha(data[, scale_items])
print(alpha_result)
# Check "raw_alpha if item dropped" to identify weak items
```

### Item-Total Correlations

```r
# Corrected item-total correlations (should be > 0.30)
item_stats <- alpha_result$item.stats
print(item_stats[, c("r.drop", "raw.alpha")])
# r.drop < 0.30: consider removing the item
# raw.alpha increases if dropped: item is weakening the scale
```

## Validity Assessment

| Validity Type | Method | Criterion |
|--------------|--------|-----------|
| **Content validity** | Expert panel rating (CVI) | I-CVI >= 0.78, S-CVI/Ave >= 0.90 |
| **Construct validity** | Exploratory Factor Analysis (EFA) | Eigenvalue > 1, loadings > 0.40 |
| **Convergent validity** | Correlation with related construct | r > 0.30 |
| **Discriminant validity** | Correlation with unrelated construct | r < 0.30 |
| **Criterion validity** | Correlation with external criterion | Significant correlation |
| **Test-retest reliability** | ICC or Pearson r over 2-4 weeks | ICC > 0.70 |

## Common Design Mistakes

| Mistake | Example | Fix |
|---------|---------|-----|
| Double-barreled question | "This course is interesting and useful" | Split into two separate items |
| Leading question | "Don't you agree that X is important?" | "How important is X to you?" |
| Absolute terms | "Do you always check citations?" | "How often do you check citations?" |
| Missing option | No "Not Applicable" when needed | Add N/A option or filter logic |
| Inconsistent scale direction | Some items 1=good, others 1=bad | Standardize direction; clearly mark reversed items |
| Too many items | 100-item survey | Aim for 5-8 items per construct, 15-30 min total |
| No pilot test | Skip straight to full deployment | Always pilot with 30-50 respondents |

## Survey Platform Comparison

| Platform | Cost | Features | Best For |
|----------|------|----------|----------|
| Qualtrics | Institutional | Advanced logic, panels, API | Large academic studies |
| SurveyMonkey | Freemium | Easy to use, basic analysis | Quick surveys |
| Google Forms | Free | Simple, integrates with Sheets | Classroom, pilot testing |
| LimeSurvey | Free/self-hosted | Open source, full control | Privacy-sensitive research |
| REDCap | Free (academic) | Clinical data, HIPAA compliant | Medical/clinical research |
| Prolific | Per-response | Participant recruitment | Online experiments |

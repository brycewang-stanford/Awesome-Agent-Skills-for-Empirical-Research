---
name: streamline-analyst-guide
description: "End-to-end data analysis AI agent with Streamlit UI"
metadata:
  openclaw:
    emoji: "📈"
    category: "analysis"
    subcategory: "wrangling"
    keywords: ["data analysis", "Streamlit", "automated EDA", "machine learning", "data science", "AI analyst"]
    source: "https://github.com/Wilson-ZheLin/Streamline-Analyst"
---

# Streamline Analyst Guide

## Overview

Streamline Analyst is an end-to-end data analysis AI agent with a Streamlit web interface. Upload a dataset and describe your analysis goal in natural language — the agent handles data cleaning, EDA, feature engineering, model training, evaluation, and report generation. Provides an interactive UI for reviewing each step and adjusting parameters.

## Installation

```bash
git clone https://github.com/Wilson-ZheLin/Streamline-Analyst.git
cd Streamline-Analyst
pip install -r requirements.txt
streamlit run app.py
```

## Workflow

```
Upload Dataset (CSV, Excel, Parquet)
         ↓
   Data Profiling
   ├── Column types and distributions
   ├── Missing value analysis
   ├── Correlation matrix
   └── Outlier detection
         ↓
   Data Cleaning (interactive)
   ├── Handle missing values
   ├── Remove/fix outliers
   ├── Type conversions
   └── Feature encoding
         ↓
   EDA (automated + custom)
   ├── Univariate analysis
   ├── Bivariate relationships
   ├── Statistical tests
   └── Custom visualizations
         ↓
   Modeling (if applicable)
   ├── Train/test split
   ├── Model selection + training
   ├── Hyperparameter tuning
   └── Evaluation metrics
         ↓
   Report Generation
```

## Features

```python
# Streamline Analyst provides:

# 1. Smart data profiling
# - Auto-detect column types (numeric, categorical, datetime)
# - Distribution analysis per column
# - Missing value patterns (MCAR, MAR, MNAR hints)
# - Correlation analysis with significance

# 2. Interactive cleaning
# - Imputation strategies (mean, median, mode, KNN, model)
# - Outlier handling (IQR, Z-score, isolation forest)
# - Encoding (one-hot, label, target, ordinal)
# - Scaling (standard, minmax, robust)

# 3. Automated EDA
# - Distribution plots (histogram, KDE, box, violin)
# - Relationship plots (scatter, pair, heatmap)
# - Time series decomposition
# - Statistical tests (t-test, ANOVA, chi-square, Mann-Whitney)

# 4. Model pipeline
# - Classification: LR, RF, GBM, SVM, MLP
# - Regression: LR, RF, GBM, SVR, ElasticNet
# - Cross-validation with confidence intervals
# - Feature importance visualization
# - SHAP explanations

# 5. Report
# - HTML report with all plots and findings
# - Downloadable cleaned dataset
# - Model artifacts (pickle)
```

## Natural Language Interface

```markdown
### Example Prompts
- "Show me the distribution of all numeric columns"
- "Is there a significant difference in income between genders?"
- "Build a classifier to predict churn using all features"
- "What are the top 5 most important features for prediction?"
- "Clean the data: fill missing values and remove outliers"
- "Generate a summary report of this dataset"
```

## Use Cases

1. **Quick EDA**: Rapid exploration of unfamiliar datasets
2. **Data cleaning**: Interactive preprocessing with AI guidance
3. **Baseline models**: Quick ML prototyping without coding
4. **Report generation**: Automated analysis reports
5. **Teaching**: Interactive data science demonstrations

## References

- [Streamline-Analyst GitHub](https://github.com/Wilson-ZheLin/Streamline-Analyst)
- [Streamlit](https://streamlit.io/)

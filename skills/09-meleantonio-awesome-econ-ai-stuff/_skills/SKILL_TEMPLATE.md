---
name: skill-name
description: One-line description for AI agent discovery (keep under 100 chars)
workflow_stage: analysis  # ideation | literature | theory | data | analysis | writing | communication
compatibility:
  - claude-code
  - cursor
  - codex
  - gemini-cli
author: Your Name <your.email@example.com>
version: 1.0.0
tags:
  - tag1
  - tag2
---

# Skill Name

## Purpose

Describe what this skill does and when an economist should use it. Be specific about the problem it solves.

## When to Use

- Use this skill when you need to...
- This is especially helpful for...

## Instructions

Follow these steps to complete the task:

### Step 1: Understand the Context

Before generating any code, ask the user:
- What is the research question?
- What data format are you working with?
- What software/language preference do you have?

### Step 2: Generate the Output

Based on the context, generate [code/document/analysis] that:

1. **Follows best practices** - Use standard conventions for [Stata/R/Python/LaTeX]
2. **Is reproducible** - Include comments explaining each step
3. **Handles edge cases** - Check for missing data, outliers, etc.

### Step 3: Verify and Explain

After generating output:
- Explain what the code does
- Highlight any assumptions made
- Suggest next steps or improvements

## Example Prompts

Users might invoke this skill with prompts like:

- "Run a difference-in-differences analysis on my treatment data"
- "Clean this dataset and create summary statistics"
- "Write the methodology section for my regression analysis"

## Example Output

```stata
* Example Stata code this skill might generate
* ============================================

* Load data
use "data.dta", clear

* Summary statistics
summarize var1 var2 var3

* Main regression
regress y x1 x2 x3, robust
eststo model1

* Export results
esttab model1 using "results.tex", replace
```

## Requirements

### Software
- Stata 17+ / R 4.0+ / Python 3.10+

### Packages
- For R: `tidyverse`, `fixest`, `modelsummary`
- For Python: `pandas`, `statsmodels`, `linearmodels`
- For Stata: Built-in commands

## Best Practices

When using this skill, ensure:

1. **Data is properly formatted** - Variables named clearly, no special characters
2. **Sample is defined** - Clear inclusion/exclusion criteria
3. **Output is documented** - All results are reproducible

## Common Pitfalls

Avoid these mistakes:
- ❌ Running analysis without checking data quality first
- ❌ Ignoring missing values or outliers
- ❌ Not specifying robust standard errors when needed

## References

- [Relevant documentation or textbook]
- [Academic paper on methodology]
- [Software package documentation]

## Changelog

### v1.0.0
- Initial release

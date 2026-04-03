---
name: abstract
description: Reads the manuscript and notebooks to generate a structured abstract. Use when writing or updating the abstract.
argument-hint: "[word count]"
allowed-tools: Bash, Read, Write, Edit, Glob, Grep
---

# Generate Abstract

Read the manuscript and generate a structured abstract.

## Arguments

- `$ARGUMENTS` — optional target word count (default: 150 words)

## Steps

1. Parse the target word count from arguments (default 150 if not specified).

2. Read `index.qmd` in full:
   - Identify the research question from the Introduction
   - Identify the data and methods from the Data/Methods sections
   - Identify key results from the Results section
   - Identify the contribution from the Conclusion

3. Read the registered notebooks to extract key quantitative findings:
   - Main coefficient estimates and significance levels
   - Sample size
   - Key figures or descriptive statistics

4. Draft a structured abstract with these components:
   - **Motivation** (1–2 sentences): What problem or question does this paper address? Why does it matter?
   - **Data and methods** (1–2 sentences): What data, sample, and empirical approach are used?
   - **Key results** (2–3 sentences): What are the main findings? Include specific numbers where possible.
   - **Contribution** (1 sentence): What is the paper's contribution to the literature or policy?

5. Verify the word count is within ±10% of the target. Adjust if needed.

6. Present the draft to the user for review.

7. On approval, update the `abstract:` field in the YAML front matter of `index.qmd`:
   ```yaml
   abstract: |
     <drafted abstract text>
   ```

## Error handling

- If `index.qmd` has only `[FILL:]` placeholders in the body sections, inform the user that the manuscript needs more content before an abstract can be generated.
- If the current abstract field already contains real content (not a `[FILL:]` placeholder), show it and ask whether to replace or refine it.

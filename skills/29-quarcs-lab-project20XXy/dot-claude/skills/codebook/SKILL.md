---
name: codebook
description: Auto-generates a Markdown codebook from a dataset (CSV, DTA, Excel, Parquet) with types and summary statistics. Use when documenting variables.
argument-hint: <path to dataset>
allowed-tools: Bash, Read, Write, Glob, Grep
---

# Generate Variable Codebook

Auto-generate a Markdown codebook documenting all variables in a dataset.

## Arguments

- `$ARGUMENTS` — path to a dataset file (e.g., `data/rawData/sample_data.csv`, `data/panel.dta`)

## Steps

1. Determine the file format from the extension:
   - `.csv` — read with pandas `read_csv`
   - `.dta` — read with pandas `read_stata`
   - `.xlsx` / `.xls` — read with pandas `read_excel`
   - `.parquet` — read with pandas `read_parquet`
   - Other formats: ask the user how to load it

2. Load the dataset using `uv run python` and extract metadata for each variable:
   - Variable name
   - Data type (numeric, string, categorical, datetime)
   - Non-missing count and missing count
   - Number of unique values
   - For numeric variables: min, max, mean, median, standard deviation
   - For categorical/string variables: top 5 most frequent values with counts
   - For datetime variables: min and max date

3. Generate a Markdown codebook with:
   - **Header:** Dataset name, file path, number of observations, number of variables, date generated
   - **Summary table:** Variable name | Type | Non-missing | Unique | Description (placeholder)
   - **Detailed sections per variable:** Full statistics and a `[FILL: description]` placeholder for the user to add a human-readable description

4. Derive the output filename from the dataset name:
   - `data/rawData/sample_data.csv` → `references/sample-data-codebook.md`

5. Save to `references/<dataset-name>-codebook.md`

6. Report the file path and the number of variables documented.

## Error handling

- If the file does not exist, report the error and suggest checking the path.
- If the file cannot be read (corrupt, unsupported format), report the error and ask for guidance.
- Never modify the source data file. This command is read-only with respect to data.

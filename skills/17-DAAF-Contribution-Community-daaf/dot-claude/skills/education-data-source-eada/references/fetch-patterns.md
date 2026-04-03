# EADA Data Access

EADA data is fetched from mirrors via the `education-data-query` skill. All fetching uses `fetch_from_mirrors()` from `fetch-patterns.md`, with mirror configuration in `mirrors.yaml` and canonical paths in `datasets-reference.md`.

## Dataset Path

| Dataset | Path | Codebook |
|---------|------|----------|
| Institutional Characteristics | `eada/colleges_eada_inst_characteristics` | `eada/codebook_colleges_eada_inst-characteristics` |

> **EADA naming note:** The data path uses `inst_characteristics` (underscores) while the codebook path uses `inst-characteristics` (hyphens). Always use the exact paths from `datasets-reference.md`.

## Example Fetch

```python
import polars as pl

# Fetch EADA institutional data via unified mirror system
DATASET_PATH = "eada/colleges_eada_inst_characteristics"
df = fetch_from_mirrors(DATASET_PATH)

# Filter by year and state
df = df.filter(
    (pl.col("year") == 2021) &
    (pl.col("fips") == 6)  # California
)

print(f"Shape: {df.shape}")
print(f"Columns: {len(df.columns)}")
```

## Available Years

2002-2021 (institutional characteristics). 165 columns, ~40,600 rows total.

## Key Columns

The Portal uses different column names than EADA source documentation. Key mappings:

| Category | Portal Columns |
|----------|---------------|
| Participation | `undup_athpartic_men`, `undup_athpartic_women`, `athpartic_men`, `athpartic_women` |
| Coaching | `men_fthdcoach_male`, `women_fthdcoach_fem`, `men_ftascoach_male`, etc. |
| Salaries | `hdcoach_salary_men`, `hdcoach_salary_women`, `ascoach_salary_men`, `ascoach_salary_women` |
| Expenses | `ath_exp_men`, `ath_exp_women`, `ath_opexp_perpart_men`, `ath_opexp_perpart_women` |
| Revenues | `ath_rev_men`, `ath_rev_women`, `ath_grnd_total_rev` |
| Student Aid | `ath_stuaid_men`, `ath_stuaid_women`, `ath_stuaid_total` |
| Recruiting | `recruitexp_men`, `recruitexp_women`, `recruitexp_total` |
| Enrollment | `enrollment_men`, `enrollment_women`, `enrollment_total` |
| Classification | `ath_classification_code`, `ath_classification_name` |

See `variable-definitions.md` for complete column documentation.

## Missing Values

EADA data uses **both** null values AND integer coded missing values (`-1`, `-2`, `-3`). The coded values are widespread -- many columns have hundreds of rows with `-1` (missing/not reported), `-2` (not applicable), or `-3` (suppressed). Coed-related columns have particularly high rates of `-1`/`-2` codes (~85% of rows) since most institutions do not have coed teams.

```python
import polars as pl

# Filter out BOTH nulls AND coded missing values
missing_codes = [-1, -2, -3]

valid = df.filter(
    pl.col("ath_exp_men").is_not_null() &
    ~pl.col("ath_exp_men").is_in(missing_codes)
)
```

## Codebook Access

```python
# Get the codebook URL for manual reference
codebook_url = get_codebook_url("eada/codebook_colleges_eada_inst-characteristics")
print(f"Codebook: {codebook_url}")
```

## Important Notes

- **No `sector` column:** EADA data does not include institutional sector. Join with IPEDS directory on `unitid` if sector filtering is needed.
- **Single-file dataset:** All years are in one file. Filter locally with `pl.col("year").is_in(years)`.
- **165 columns:** The dataset is wide. Use column selection to reduce memory usage for focused analyses.
- **Early years sparse:** Some columns are null for 2002 (e.g., `opeid`, `num_sports`, `_all` aggregates).

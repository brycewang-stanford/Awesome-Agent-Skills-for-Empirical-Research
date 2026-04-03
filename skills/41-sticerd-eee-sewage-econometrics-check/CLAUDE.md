# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Academic research project estimating the causal impact of sewage spills on house prices and rents in England. Uses Event Duration Monitoring (EDM) data (2021-2024+), Land Registry house prices, and Zoopla rental listings. Primary language is R; Python is used for spatial river network processing.

Website: https://jacopo-olivieri.github.io/sewage/

## Running Scripts

No build system or Makefile. Scripts are run individually:

```bash
Rscript scripts/R/<layer>/<script_name>.R
```

Or sourced in an R session:
```r
source(here::here("scripts", "R", "<layer>", "<script_name>.R"))
```

Restore R packages with `renv::restore()`. Python environment is managed with `uv` in `scripts/python/`.

The Quarto book (project website) is built from `book/` and deployed via GitHub Actions to gh-pages.

## Architecture

### 6-Layer Data Pipeline

Scripts in `scripts/R/` are organised into sequential layers with explicit dependencies (extended documentation in `docs/pipeline_documentation.md`):

1. **`01_data_ingestion/`** — Raw data collection (EDM archives, APIs)
2. **`02_data_cleaning/`** — Format standardisation, geocoding, validation
3. **`03_data_enrichment/`** — Temporal aggregation, lookup tables, rainfall metrics, dry spill identification
4. **`04_feature_engineering/`** — 10km spatial matching (house/rental ↔ spill sites), spill statistics
5. **`05_data_integration/`** — Merging historical (2021-2023) and API (2024+) EDM data, location integration
6. **`06_analysis_datasets/`** — Final dataset assembly: cross-sectional, panel, grid-level, within-radius

**Key dependency note:** Layer 05 integration scripts actually run during Layer 03 for dependency reasons (steps 11-12 in the execution order).

### Analysis Scripts (`scripts/R/09_analysis/`)

Organised by econometric approach:
- `01_descriptive/` — Maps, scatter plots, Google Trends figures
- `02_hedonic/` — Cross-sectional hedonic regressions (continuous/bins × prior/full period)
- `03_repeat_sales/` — Repeat-transaction regressions (Palmquist 1982)
- `04_long_difference/` — 250m grid-level long-difference (weighted/unweighted × all/exposed)
- `05_news/` — DiD and event studies with media coverage (Google Trends, LexisNexis)
- `06_upstream_downstream/` — Directional spillover analysis

All analysis scripts estimate effects on both house sales and rental prices unless noted otherwise.

### Shared Utilities (`scripts/R/utils/`)

- `postcode_processing_utils.R` — Geocoding via PostcodesioR with retry/backoff, batch processing, shared cache at `data/cache/postcodes/`
- `spill_aggregation_utils.R` — 12/24 hour spill counting, temporal boundary handling, monthly record splitting

### Docker Pipelines

- `RiverNetworks/` and `upstream_downstream/` — PostGIS-based spatial river network analysis, run via `run_pipeline.sh`

## R Coding Conventions

### Pipeline scripts (layers 01-06) use this structure:
```
Header block (########) → roxygen description → initialise_environment() → setup_logging() → CONFIG list → functions → main() → conditional execution
```

- `CONFIG` list holds all file paths and parameters at the top of each script
- `initialise_environment()` handles renv + package loading
- `setup_logging()` writes to `output/log/`
- `main()` wraps execution; guarded by `if (sys.nframe() == 0)`

### Analysis scripts (09_analysis) use a flatter structure:
Numbered sections with `# ===` separators, inline package loading, direct execution (no `main()` wrapper).

### General conventions:
- **Paths:** Always use `here::here()` — never relative paths
- **Data formats:** Parquet via `arrow` for intermediate/final data; DuckDB for large joins
- **Pipe:** Native R pipe `|>`
- **Naming:** snake_case for functions/variables, UPPER_SNAKE_CASE for constants
- **Econometrics:** `fixest::feols()` for regressions, heteroskedasticity-robust SEs (`vcov = "hetero"`)
- **Tables:** `modelsummary` → LaTeX with `tabularray` format, manual post-processing for `[H]` placement, labels, colsep, and custom notes
- **Factors:** Use `forcats::as_factor()` / `forcats::fct_drop()` for categorical variables

## Data Layout

```
data/raw/          — Original immutable data (EDM, Land Registry, Met Office, shapefiles)
data/processed/    — Intermediate pipeline outputs (parquet, RData)
data/final/        — Analysis-ready datasets
data/cache/        — Shared caches (postcode geocoding)
data/temp/         — Temporary processing files
```

All data directories are gitignored. Outputs go to `output/{figures,tables,html_plots,regs,log}/`.

## Key Identifiers

- `house_id` — Unique property identifier (sales)
- `rental_id` — Unique rental listing identifier
- `unique_id` — Unique spill site identifier
- `lsoa` / `msoa` — Geographic fixed effects (Lower/Middle Super Output Areas)
- `radius` — Spatial matching distance in metres (commonly 250, 500, 1000, 2000, 5000, 10000)

## Treatment Variables

- `spill_count` / `spill_count_daily_avg` — Number of spill events (12/24 counting methodology)
- `spill_hrs` / `spill_hrs_daily_avg` — Total spill duration in hours
- `n_spill_sites` — Number of overflow sites within radius
- `min_dist` / `mean_dist` — Distance metrics to nearest/average spill site

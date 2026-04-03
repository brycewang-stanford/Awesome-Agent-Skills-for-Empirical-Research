---
name: data-deposit
description: Prepare a replication package for the sewage-house-prices project. Generates AEA-compliant README, master script, numbered script order, install script, and deposit checklist. Validates the package against 10 verification checks. This skill should be used when asked to "prepare replication", "data deposit", "create replication package", or "package for submission".
argument-hint: "[optional: output directory]"
allowed-tools: ["Read", "Grep", "Glob", "Write", "Edit", "Bash", "Agent"]
---

# Data Deposit Preparation

Prepare an AEA Data Editor compliant replication package for the sewage-house-prices project.

**Input:** `$ARGUMENTS` — output directory (defaults to `Replication/`).

---

## Project-Specific Context

### Pipeline Structure

The project has a 6-layer data pipeline in `scripts/R/`:
1. `01_data_ingestion/` — Raw data collection (EDM archives, APIs)
2. `02_data_cleaning/` — Format standardisation, geocoding, validation
3. `03_data_enrichment/` — Temporal aggregation, rainfall metrics, dry spill identification
4. `04_feature_engineering/` — Spatial matching (house/rental ↔ spill sites)
5. `05_data_integration/` — Merging historical and API EDM data
6. `06_analysis_datasets/` — Final dataset assembly

Analysis scripts: `scripts/R/09_analysis/` (6 subdirectories by approach)
Utilities: `scripts/R/utils/`
Python scripts: `scripts/python/` (river network processing)
Docker pipelines: `RiverNetworks/`, `upstream_downstream/`

### Data Layout

```
data/raw/          — Original immutable data (EDM, Land Registry, Met Office, shapefiles)
data/processed/    — Intermediate pipeline outputs (parquet)
data/final/        — Analysis-ready datasets
data/cache/        — Postcode geocoding cache
```

### Key Dependencies
- R packages managed via `renv` (`renv.lock`)
- Python environment via `uv` in `scripts/python/`
- PostGIS via Docker for river network analysis

---

## Workflow

### Step 1: Inventory

1. Read all scripts in `scripts/R/` and parse data file references
2. Read `renv.lock` for package versions
3. Scan `output/tables/` and `output/figures/` for output files
4. Read the manuscript (`docs/overleaf/_main.tex`) for table/figure references
5. Check `scripts/python/` for Python dependencies

### Step 2: Analyse Dependencies

1. Parse script dependencies (which scripts create files that others load)
2. Map the execution order (follows the 6-layer pipeline, then analysis scripts)
3. Cross-reference the full execution order documented in `ReadMe.md`

### Step 3: Assemble Package

Create in `Replication/` (or specified directory):

1. **README.md** — AEA format:
   - Data availability statement (which data is public vs restricted)
   - Computational requirements (R version, packages, PostGIS, Python)
   - Program descriptions (what each script does)
   - Replication instructions (step-by-step)
   - Expected runtime

2. **master.R** — Runs everything in order:
   ```r
   # Master replication script for "Sewage in Our Waters"
   # Estimated runtime: [X hours]

   source(here::here("scripts", "R", "01_data_ingestion", "script.R"))
   # ... through all layers
   source(here::here("scripts", "R", "09_analysis", "subdir", "script.R"))
   ```

3. **install_packages.R** — If renv is not used:
   ```r
   install.packages(c("tidyverse", "fixest", "modelsummary", ...))
   ```

4. **DEPOSIT_CHECKLIST.md** — Pre-deposit verification

### Step 4: Validate

Run the 10 verification checks (equivalent to `/audit-replication`):
1. Script execution order is correct
2. All data file references resolve
3. All output files are generated
4. Package versions documented
5. No hardcoded absolute paths
6. Data provenance documented
7. README completeness (AEA format)
8. Output cross-reference (every table/figure traced to a script)
9. Restricted data properly flagged
10. Master script runs without modification

### Step 5: Present Results

1. **Package contents** — All files in `Replication/`
2. **Script order** — Numbered sequence with dependency graph
3. **Data availability** — Public vs restricted datasets
4. **Verification result** — X/10 checks passed
5. **Deposit steps** — openICPSR / Zenodo instructions

---

## Principles

- **AEA Data Editor standards are the target.** README format, versions, data access statements.
- **Don't rename scripts without approval.** Present ordering first, let the user decide.
- **Thorough data provenance.** Every dataset documented with source, access date, and restrictions.
- **Test before declaring ready.** Always validate after assembly.
- **Document restricted data clearly.** Land Registry and Zoopla data may have access restrictions.

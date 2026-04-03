---
description: Document datasets, variables, sources, and merge keys for replication
---

# Data Documentation Assistant

Help document datasets systematically for replication packages, co-author handoffs, and future reference.

## Dataset Documentation Template

When documenting a dataset, capture:

### 1. Dataset Overview
- **Name:** (e.g., `firm_year_panel.parquet`)
- **Location:** (relative path from project root)
- **Created by:** (script that generates it)
- **Last updated:**
- **Unit of observation:** (firm-year, loan-quarter, etc.)
- **N observations:**
- **Time coverage:**

### 2. Source Data
| Source | Access | Raw File | Notes |
|--------|--------|----------|-------|
| WRDS Compustat | Subscription | `raw/compustat_funda.csv` | Annual fundamentals |
| Revelio Labs | Licensed | `raw/revelio_positions.parquet` | Via BU server |
| Hand-collected | Manual | `raw/manual_coding.xlsx` | See coding protocol |

### 3. Key Variables

| Variable | Type | Description | Source | Notes |
|----------|------|-------------|--------|-------|
| `gvkey` | str | Compustat firm identifier | Compustat | Primary key |
| `fyear` | int | Fiscal year | Compustat | |
| `at` | float | Total assets ($ millions) | Compustat | Winsorized 1/99 |
| `treated` | int | =1 if treated firm | Constructed | See section 4 |

### 4. Variable Construction

For constructed/derived variables, document:

```
Variable: treated
Definition: =1 if firm received first PE investment in year t
Construction:
  1. Merge PitchBook deals to Compustat on EIN
  2. Keep first deal per firm
  3. Flag year of first investment
Script: 2a_construct_treatment.py, lines 45-78
```

### 5. Sample Filters

Document all filters applied:

| Filter | Observations Dropped | Remaining |
|--------|---------------------|-----------|
| Raw data | - | 150,000 |
| Drop financials (SIC 6000-6999) | 25,000 | 125,000 |
| Require non-missing assets | 5,000 | 120,000 |
| Require 2+ years in panel | 10,000 | 110,000 |

### 6. Merge Keys

| Dataset A | Dataset B | Key(s) | Match Rate | Notes |
|-----------|-----------|--------|------------|-------|
| Compustat | CRSP | gvkey | 95% | Via CCM link table |
| Compustat | PitchBook | EIN | 72% | Manual cleaning needed |
| Revelio | Compustat | company_name | 68% | Fuzzy match, see script |

---

## Quick Commands

- **"document this dataset"** - Generate full template for a dataset
- **"variable list"** - Create variable table only
- **"merge documentation"** - Focus on merge keys and match rates
- **"sample flow"** - Generate sample filter table
- **"codebook"** - Formal codebook format for replication package

---

## Codebook Format (for Replication Packages)

```
================================================================================
CODEBOOK: firm_year_panel.dta
Generated: 2026-01-15
================================================================================

IDENTIFICATION
  gvkey         Compustat permanent firm identifier
  fyear         Fiscal year

OUTCOME VARIABLES
  roa           Return on assets = ni/at (winsorized 1/99)
  investment    Capex/lagged assets = capx/L.at

TREATMENT VARIABLES
  post          =1 for years after treatment
  treated       =1 for firms ever treated
  treat_post    Interaction: treated × post (DiD coefficient)

CONTROLS
  size          Log total assets = ln(at)
  leverage      Book leverage = (dltt+dlc)/at
  mtb           Market-to-book = (prcc_f×csho)/ceq

FIXED EFFECTS
  ff48          Fama-French 48 industry classification
  state         State of incorporation
================================================================================
```

---

## Data Provenance Checklist

Before finalizing a dataset, verify:

- [ ] All source files documented with access instructions
- [ ] Variable definitions are unambiguous
- [ ] Sample filters documented with observation counts
- [ ] Merge match rates reported
- [ ] Winsorization/trimming documented
- [ ] Missing value treatment documented
- [ ] Script that creates dataset is identified
- [ ] Date of creation recorded

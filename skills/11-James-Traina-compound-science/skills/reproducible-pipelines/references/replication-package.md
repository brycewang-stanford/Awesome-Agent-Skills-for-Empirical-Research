# Replication Package Standards

## AEA Data Editor Requirements

The AEA (American Economic Association) has the most detailed replication requirements. Following these satisfies most other journals too.

**Required components:**

1. **README.md** — Must include:
   - Data availability statement (where to obtain each dataset)
   - Computational requirements (time, memory, software)
   - Instructions to reproduce all results
   - List of all tables and figures with the script that produces each

2. **Data citations** — Cite every dataset used, including:
   - Provider and access conditions
   - DOI or persistent URL
   - Date accessed
   - Any restrictions on redistribution

3. **Code** — Must produce every number in the paper:
   - Every table (including appendix tables)
   - Every figure
   - Every in-text statistic ("We find a 3.2% effect...")

4. **License** — Include a license file (typically MIT or CC-BY for code)

## README Template

```markdown
# Replication Package for "[Paper Title]"

## Authors
[Names and affiliations]

## Data Availability

| Dataset | Source | Access | Included |
|---------|--------|--------|----------|
| CPS March Supplement | IPUMS | Public (registration) | No — download from [URL] |
| State policy dates | Hand-collected | — | Yes (`data/raw/policy_dates.csv`) |

### Instructions for restricted data
[If any data requires DUA or restricted access, explain the process]

## Computational Requirements

- **Software:** Python 3.11, packages in `environment.yml`
- **Hardware:** [X] GB RAM, [Y] CPU hours
- **OS:** Tested on Ubuntu 22.04 and macOS 14

## Instructions

\`\`\`bash
# 1. Set up environment
conda env create -f environment.yml
conda activate my-project

# 2. Obtain data
# Download CPS data from [URL] to data/raw/

# 3. Run full pipeline
make all

# Expected runtime: ~[X] hours on [hardware description]
\`\`\`

## Output Map

| Output | Script | Table/Figure |
|--------|--------|-------------|
| `output/tables/main_results.tex` | `code/03_estimate.py` | Table 1 |
| `output/tables/robustness.tex` | `code/04_robustness.py` | Table 2 |
| `output/figures/event_study.pdf` | `code/05_tables_figures.py` | Figure 1 |
```

## Pre-Submission Checklist

Run this before submitting the replication package:

- [ ] **Clean build**: `make clean && make all` succeeds from scratch
- [ ] **Fresh environment**: Create environment from `environment.yml` on a clean machine; all packages install
- [ ] **Data documentation**: Every raw data file has source, access instructions, and citation
- [ ] **Output map**: Every table, figure, and in-text statistic mapped to a script
- [ ] **No absolute paths**: `grep -r '/Users\|/home\|C:\\' code/` returns nothing
- [ ] **No manual steps**: Every intermediate file is produced by code, not hand-edited
- [ ] **Seeds documented**: Master seed stated in README; all stochastic code is seeded
- [ ] **Runtime estimate**: README states expected runtime and hardware requirements
- [ ] **License**: LICENSE file included
- [ ] **Sensitive data**: No IRB-restricted or proprietary data included without authorization
- [ ] **Large files**: Data files either included (if small + redistributable) or documented (if large/restricted)
- [ ] **Version pinned**: `environment.yml` or `requirements.txt` has exact version numbers

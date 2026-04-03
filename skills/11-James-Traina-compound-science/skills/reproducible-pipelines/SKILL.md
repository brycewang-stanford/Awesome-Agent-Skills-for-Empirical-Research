---
name: reproducible-pipelines
argument-hint: "<pipeline tool or reproducibility concern>"
description: >-
  This skill covers reproducible research pipelines and replication packages. Use when the user is setting up a research project directory structure, configuring workflow managers (Make, Snakemake, DVC), managing computational environments, preparing replication packages for journal submission, or debugging reproducibility failures. Triggers on "reproducible", "replication package", "Makefile", "Snakemake", "DVC", "pipeline", "workflow manager", "data versioning", "conda environment", "Docker", "seed management", "AEA data editor", "replication", "project structure", or "submission checklist".
---

# Reproducible Pipelines

Reference for building reproducible research pipelines: from project directory structure to automated workflows to journal-ready replication packages. Every computational result should be regenerable from raw data by running a single command.

## When to Use This Skill

Use when the user is:
- Setting up a new empirical research project
- Building or debugging a Makefile/Snakemake/DVC pipeline
- Preparing a replication package for journal submission
- Managing computational environments (conda, Docker, renv)
- Tracking data provenance or versioning large datasets
- Debugging "works on my machine" reproducibility failures

Skip when:
- The task is about estimation methodology (use `causal-inference` or `structural-modeling` skill)
- The task is git workflow management (see `workflows-work/references/worktree-patterns.md`)
- The task is about orchestrating Claude agents (see `slfg/references/orchestration-patterns.md`)

## Where to Start
- **New project?** Start with Directory Structure below
- **Adding a workflow manager?** Jump to [Workflow Managers](#workflow-managers) (Make / Snakemake / DVC)
- **Preparing for submission?** Jump to [Pre-Submission Checklist](#pre-submission-checklist)

## Project Directory Structure

Use a standardized layout from the start. This is the structure expected by most replication reviewers:

```
project/
├── README.md                 # Master documentation (how to replicate)
├── Makefile                  # Or Snakefile — single entry point
├── environment.yml           # Conda environment (or requirements.txt)
├── data/
│   ├── raw/                  # Original, immutable data files
│   │   └── README.md         # Data sources, access instructions, citations
│   ├── intermediate/         # Cleaned/transformed data (gitignored, regenerable)
│   └── final/                # Analysis-ready datasets (gitignored, regenerable)
├── code/
│   ├── 01_clean.py           # Data cleaning
│   ├── 02_build.py           # Variable construction, merges
│   ├── 03_estimate.py        # Main estimation
│   ├── 04_robustness.py      # Robustness checks
│   └── 05_tables_figures.py  # Output generation
├── output/
│   ├── tables/               # LaTeX/CSV tables (gitignored, regenerable)
│   └── figures/              # PDF/PNG figures (gitignored, regenerable)
├── docs/
│   ├── brainstorms/          # Research brainstorming docs
│   ├── plans/                # Implementation plans
│   └── codebook.md           # Variable definitions
├── tests/                    # Validation tests
│   ├── test_clean.py
│   └── test_estimates.py
└── paper/
    └── manuscript.tex        # The paper itself
```

**Key principles:**
- `data/raw/` is **immutable** — never modify raw data files
- Everything in `intermediate/`, `final/`, `output/` is **regenerable** — gitignore it
- Number scripts to indicate execution order (or rely on the workflow manager)
- Keep `README.md` as the single entry point for replicators

### .gitignore for Research Projects

```gitignore
# Data (too large for git; document in README how to obtain)
data/raw/*.csv
data/raw/*.dta
data/raw/*.parquet
data/intermediate/
data/final/

# Generated output (reproducible from code)
output/tables/
output/figures/

# Environment
.conda/
__pycache__/
*.pyc
.ipynb_checkpoints/

# Large files managed by DVC
*.dvc

# OS
.DS_Store
Thumbs.db

# IDE
.vscode/
.idea/
```

## Workflow Managers

### Make (Recommended Default)

Make is universally available, well-understood, and sufficient for most research pipelines. Use it unless you have a specific reason for something else.

```makefile
# Makefile — Top-level research pipeline

.PHONY: all clean tables figures

# Default target: reproduce everything
all: output/tables/main_results.tex output/figures/event_study.pdf

# === DATA CLEANING ===
data/intermediate/clean.parquet: data/raw/survey_2020.csv code/01_clean.py
	python code/01_clean.py

# === VARIABLE CONSTRUCTION ===
data/final/analysis.parquet: data/intermediate/clean.parquet code/02_build.py
	python code/02_build.py

# === ESTIMATION ===
output/estimates/main.pkl: data/final/analysis.parquet code/03_estimate.py
	python code/03_estimate.py

output/estimates/robustness.pkl: data/final/analysis.parquet code/04_robustness.py
	python code/04_robustness.py

# === TABLES AND FIGURES ===
output/tables/main_results.tex: output/estimates/main.pkl output/estimates/robustness.pkl code/05_tables_figures.py
	python code/05_tables_figures.py --tables

output/figures/event_study.pdf: output/estimates/main.pkl code/05_tables_figures.py
	python code/05_tables_figures.py --figures

# === UTILITIES ===
clean:
	rm -rf data/intermediate/ data/final/ output/

tables: output/tables/main_results.tex
figures: output/figures/event_study.pdf
```

**Make best practices:**
- Each target lists its **exact** dependencies (both data and code)
- Changing any dependency triggers recomputation of downstream targets
- `make -j4` runs independent targets in parallel (e.g., tables and figures simultaneously)
- `make -n` dry run shows what would be executed without running anything
- Use `.PHONY` for targets that don't correspond to files

### Snakemake (For Complex Pipelines)

Use Snakemake when the pipeline has many steps, parameter sweeps, or needs cluster execution.

```python
# Snakefile

configfile: "config.yaml"

rule all:
    input:
        "output/tables/main_results.tex",
        "output/figures/event_study.pdf"

rule clean_data:
    input:
        raw="data/raw/survey_2020.csv"
    output:
        clean="data/intermediate/clean.parquet"
    script:
        "code/01_clean.py"

rule build_analysis:
    input:
        clean="data/intermediate/clean.parquet"
    output:
        analysis="data/final/analysis.parquet"
    script:
        "code/02_build.py"

rule estimate:
    input:
        data="data/final/analysis.parquet"
    output:
        estimates="output/estimates/{spec}.pkl"
    params:
        seed=config["seed"]
    script:
        "code/03_estimate.py"

# Snakemake advantages over Make:
# - Python syntax (easier for researchers)
# - Built-in wildcards for parameter sweeps
# - Cluster execution (SLURM, SGE)
# - Conda environment per rule
# - Automatic DAG visualization: snakemake --dag | dot -Tpdf > dag.pdf
```

### DVC (Data Version Control)

Use DVC when you need to version large data files that don't fit in git.

```bash
# Initialize DVC in an existing git repo
dvc init

# Track a large data file
dvc add data/raw/survey_2020.csv
# Creates data/raw/survey_2020.csv.dvc (small metadata file, tracked by git)
# The actual data is in .dvc/cache

# Configure remote storage
dvc remote add -d myremote s3://my-bucket/dvc-cache

# Push data to remote
dvc push

# Collaborator pulls data
dvc pull
```

**DVC pipeline integration:**

```yaml
# dvc.yaml
stages:
  clean:
    cmd: python code/01_clean.py
    deps:
      - data/raw/survey_2020.csv
      - code/01_clean.py
    outs:
      - data/intermediate/clean.parquet

  estimate:
    cmd: python code/03_estimate.py
    deps:
      - data/final/analysis.parquet
      - code/03_estimate.py
    outs:
      - output/estimates/main.pkl
    params:
      - seed
      - n_bootstrap
```

**Enhanced DVC: remote storage and experiment tracking:**

```bash
# Remote storage options
dvc remote add -d s3remote s3://my-bucket/dvc-cache      # AWS S3
dvc remote add -d gcsremote gs://my-bucket/dvc-cache     # Google Cloud
dvc remote add -d sshremote ssh://server.edu/path/cache  # SSH server (common for university HPC)
dvc remote add -d localremote /data/shared/dvc-cache     # Shared NFS mount

# Visualize pipeline DAG
dvc dag                        # ASCII DAG in terminal
dvc dag --dot | dot -Tpdf > pipeline.pdf  # PDF visualization

# Parameter tracking and comparison
# params.yaml — centralize all tunable parameters
# DVC auto-tracks params files listed in dvc.yaml

dvc params diff HEAD~1         # Compare current params to last commit
dvc params diff main feature-branch  # Compare across branches

# Metrics: track experiment outcomes
# In dvc.yaml: add metrics: [output/metrics.json] to a stage
dvc metrics show               # Show all tracked metrics
dvc metrics diff HEAD~3        # Compare metrics across commits

# Partial pipeline execution
dvc repro estimate             # Run only the 'estimate' stage and its deps
dvc repro --force              # Re-run even if inputs haven't changed

# Pull only what you need (for large datasets)
dvc pull data/final/analysis.parquet.dvc  # Pull only one file
dvc fetch --run-cache          # Prefetch cached stage outputs
```

**DVC best practices for research:**
- Commit `dvc.lock` to git — it records the exact state of all outputs
- Use `params.yaml` for all tunable parameters (seeds, model specs, sample cutoffs); DVC tracks changes automatically
- On HPC clusters: configure SSH remote pointing at shared storage so collaborators don't re-run expensive stages
- `dvc metrics` is useful for tracking bias/RMSE across Monte Carlo runs; commit `metrics.json` to see history

### Which Workflow Manager to Use

| Factor | Make | Snakemake | DVC | pytask |
|--------|------|-----------|-----|--------|
| Complexity | Simple pipelines (< 20 targets) | Complex pipelines, parameter sweeps | Data-heavy pipelines | Mixed-language projects |
| Learning curve | Low (most researchers know it) | Medium (Python-like syntax) | Medium (git-like commands) | Medium (Python decorators) |
| Cluster support | Manual (submit scripts) | Built-in (SLURM, SGE) | Via CML | Via plugins |
| Data versioning | No | No | Yes (core feature) | No |
| Availability | Everywhere | pip install | pip install | pip install |
| Reviewer familiarity | Very high | Medium | Lower | Lower |

### pytask (Python-Native DAG)

pytask — Python-native DAG manager using decorated functions with type-annotated dependencies. First-class plugins for Stata, R, Julia. `pixi run pytask` rebuilds the entire project. Good for mixed-language economics projects.

**Recommendation:** Start with Make. Switch to Snakemake if you need cluster execution or parameter sweeps. Add DVC if data files are too large for git. Consider pytask if your team prefers Python-native tooling and works across multiple languages.

## Additional References

- `references/stata-and-crosslang.md` — Stata master.do patterns, batch mode, ado versioning, Stata anti-patterns; cross-language tolerance thresholds (R/Stata/Python) and systematic discrepancy trap table
- `references/environment-and-seeds.md` — conda/renv/Docker environment management, random seed management by language, results caching strategies
- `references/replication-package.md` — AEA-compliant replication package structure: README template, data availability statement, computational requirements, output map

## Common Anti-Patterns

| Anti-Pattern | Problem | Better Approach |
|--------------|---------|-----------------|
| Jupyter notebooks as the pipeline | Non-linear execution, hidden state, hard to automate | Use .py scripts orchestrated by Make; notebooks only for exploration |
| Absolute file paths (`/Users/me/data/...`) | Breaks on any other machine | Use relative paths from project root; configure data directory in a single config file |
| `pip install` without version pinning | Package updates break code silently months later | Pin exact versions: `pandas==2.2.0` |
| Modifying raw data files | Destroys provenance; can't rerun from original | `data/raw/` is immutable; all cleaning produces new files in `data/intermediate/` |
| Committing large data files to git | Bloats repository, slow clones | Use DVC, git-lfs, or document download instructions |
| Hardcoded random seeds scattered across files | Hard to find, easy to miss one | Centralize in config.py, derive all seeds from one master seed |
| "It works on my laptop" | Different OS, library versions, locale settings | Test in Docker or CI; provide `environment.yml` |
| Results tables copy-pasted into paper | Tables get stale when estimates change | Generate LaTeX tables directly from estimation code |
| Pipeline only tested by the author | Missing implicit dependencies | Have a co-author or RA run from scratch; or use CI |

The `reproducibility-auditor` agent can audit pipelines for these anti-patterns and verify replication packages before submission.

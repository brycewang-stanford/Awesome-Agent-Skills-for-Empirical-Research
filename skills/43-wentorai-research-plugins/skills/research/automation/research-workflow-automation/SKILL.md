---
name: research-workflow-automation
description: "Automate repetitive research tasks with pipelines, schedulers, and scripting"
metadata:
  openclaw:
    emoji: "⚙️"
    category: "research"
    subcategory: "automation"
    keywords: ["workflow management", "pipeline scheduler", "research automation", "scientific workflow", "task automation"]
    source: "wentor"
---

# Research Workflow Automation

A skill for automating repetitive research tasks using workflow managers, pipeline tools, and scripting. Covers data pipeline design, experiment tracking, automated reporting, and reproducible research workflows.

## Workflow Management Tools

### Tool Comparison

| Tool | Language | Best For | Complexity | License |
|------|----------|----------|-----------|---------|
| Snakemake | Python | Bioinformatics, data pipelines | Medium | MIT |
| Nextflow | Groovy/DSL | Genomics, HPC | Medium | Apache 2.0 |
| Prefect | Python | Data engineering, ML | Medium | Apache 2.0 |
| Airflow | Python | Scheduled ETL pipelines | High | Apache 2.0 |
| Make | Makefile | Simple file-based pipelines | Low | GPL |
| DVC | YAML/CLI | ML experiment tracking | Low | Apache 2.0 |

### Snakemake: Scientific Workflow Example

```python
# Snakefile for a research data pipeline

# Configuration
configfile: "config.yaml"

# Define the final outputs
rule all:
    input:
        "results/figures/main_figure.pdf",
        "results/tables/summary_table.csv",
        "results/manuscript_stats.json"

# Step 1: Download and preprocess data
rule download_data:
    output:
        "data/raw/{dataset}.csv"
    params:
        url = lambda wildcards: config["datasets"][wildcards.dataset]["url"]
    shell:
        "curl -L {params.url} -o {output}"

rule clean_data:
    input:
        "data/raw/{dataset}.csv"
    output:
        "data/cleaned/{dataset}.parquet"
    script:
        "scripts/clean_data.py"

# Step 2: Run analysis
rule statistical_analysis:
    input:
        expand("data/cleaned/{dataset}.parquet",
               dataset=config["datasets"].keys())
    output:
        "results/analysis/statistics.json",
        "results/analysis/model_fits.pkl"
    threads: 4
    resources:
        mem_mb = 8000
    script:
        "scripts/run_analysis.py"

# Step 3: Generate figures
rule create_figures:
    input:
        "results/analysis/statistics.json"
    output:
        "results/figures/main_figure.pdf"
    script:
        "scripts/create_figures.py"

# Step 4: Generate summary table
rule summary_table:
    input:
        "results/analysis/statistics.json"
    output:
        "results/tables/summary_table.csv"
    script:
        "scripts/create_tables.py"
```

```bash
# Execute the full pipeline
snakemake --cores 8 --use-conda

# Visualize the workflow DAG
snakemake --dag | dot -Tpdf > workflow.pdf

# Dry run to see what would be executed
snakemake -n
```

## Make-Based Pipelines

### Simple Makefile for Research

```makefile
# Makefile for a research project
.PHONY: all clean data analysis figures paper

# Default target
all: paper

# Data acquisition and cleaning
data/cleaned/dataset.parquet: data/raw/dataset.csv scripts/clean.py
	python scripts/clean.py --input $< --output $@

# Analysis
results/statistics.json: data/cleaned/dataset.parquet scripts/analyze.py
	python scripts/analyze.py --input $< --output $@

# Figures
results/figures/%.pdf: results/statistics.json scripts/plot_%.py
	python scripts/plot_$*.py --input $< --output $@

# Compile paper
paper: results/figures/main.pdf results/figures/supplement.pdf
	cd paper && latexmk -pdf main.tex

# Clean all generated files
clean:
	rm -rf data/cleaned/ results/ paper/*.pdf paper/*.aux paper/*.log
```

## Experiment Tracking

### MLflow for Research Experiments

```python
import mlflow
import json

def track_experiment(experiment_name: str, params: dict,
                      metrics: dict, artifacts: list[str] = None):
    """
    Track a research experiment with MLflow.

    Args:
        experiment_name: Name of the experiment series
        params: Hyperparameters or configuration
        metrics: Results metrics
        artifacts: Paths to output files to log
    """
    mlflow.set_experiment(experiment_name)

    with mlflow.start_run():
        # Log parameters
        for key, value in params.items():
            mlflow.log_param(key, value)

        # Log metrics
        for key, value in metrics.items():
            mlflow.log_metric(key, value)

        # Log artifacts (figures, data files, etc.)
        if artifacts:
            for artifact_path in artifacts:
                mlflow.log_artifact(artifact_path)

        # Log the full configuration as JSON
        mlflow.log_dict(params, "config.json")

        run_id = mlflow.active_run().info.run_id
        print(f"Experiment logged: {run_id}")
        return run_id

# Example: track a statistical analysis
track_experiment(
    experiment_name="treatment_effect_study",
    params={
        'model': 'linear_regression',
        'covariates': 'age,sex,baseline_score',
        'alpha': 0.05,
        'data_version': 'v2.3'
    },
    metrics={
        'r_squared': 0.42,
        'treatment_effect': 0.35,
        'p_value': 0.003,
        'n_subjects': 245
    },
    artifacts=['results/figures/main.pdf']
)
```

## Automated Reporting

### Generate Reports from Analysis Results

```python
from jinja2 import Template
from datetime import datetime

def generate_report(results: dict, template_path: str,
                     output_path: str):
    """
    Auto-generate a research report from analysis results.
    """
    report_template = Template("""
# Analysis Report
Generated: {{ timestamp }}

## Summary Statistics
- Sample size: {{ results.n }}
- Mean outcome: {{ "%.2f"|format(results.mean) }}
- Standard deviation: {{ "%.2f"|format(results.std) }}

## Main Results
- Treatment effect: {{ "%.3f"|format(results.effect) }}
  (95% CI: {{ "%.3f"|format(results.ci_lower) }} to {{ "%.3f"|format(results.ci_upper) }})
- p-value: {{ "%.4f"|format(results.p_value) }}
- Effect size (Cohen's d): {{ "%.2f"|format(results.cohens_d) }}

## Interpretation
{% if results.p_value < 0.05 %}
The treatment effect is statistically significant at the 5% level.
{% else %}
The treatment effect is not statistically significant at the 5% level.
{% endif %}
""")

    report = report_template.render(
        results=results,
        timestamp=datetime.now().strftime('%Y-%m-%d %H:%M')
    )

    with open(output_path, 'w') as f:
        f.write(report)

    return output_path
```

## Scheduling and Cron Jobs

### Automated Data Collection

```bash
# Crontab entry: run daily at 6 AM
0 6 * * * cd /home/researcher/project && python scripts/daily_data_fetch.py >> logs/fetch.log 2>&1

# Weekly analysis update (every Monday at 9 AM)
0 9 * * 1 cd /home/researcher/project && snakemake --cores 4 >> logs/pipeline.log 2>&1
```

## Best Practices

1. **Version everything**: Code, data, configurations, and environments
2. **Idempotent pipelines**: Running the same pipeline twice produces the same output
3. **Fail fast**: Validate inputs early; do not process bad data silently
4. **Log everything**: Record timestamps, parameters, and random seeds
5. **Separate configuration from code**: Use YAML/JSON config files, not hardcoded values
6. **Test with small data first**: Use a 1% sample to verify the pipeline before full runs
7. **Document the workflow**: A README explaining how to run the full pipeline from scratch

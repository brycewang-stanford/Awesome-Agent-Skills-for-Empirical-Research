---
name: jupyter-notebook-guide
description: "Best practices for computational research notebooks with reproducible workflows"
metadata:
  openclaw:
    emoji: "📓"
    category: "tools"
    subcategory: "code-exec"
    keywords: ["sandbox execution", "code runner", "Jupyter notebook", "computational notebook", "reproducible research"]
    source: "wentor"
---

# Jupyter Notebook Guide

A skill for using Jupyter notebooks effectively in research contexts. Covers notebook organization, reproducibility best practices, collaboration workflows, and integration with research computing infrastructure.

## Notebook Organization

### Recommended Structure

Every research notebook should follow a consistent structure:

```
01_data_collection.ipynb     # Data acquisition and initial storage
02_data_cleaning.ipynb       # Preprocessing, validation, transformations
03_exploratory_analysis.ipynb # EDA, descriptive statistics, initial plots
04_modeling.ipynb             # Model training, evaluation, selection
05_results_visualization.ipynb # Publication-quality figures
06_supplementary.ipynb       # Additional analyses, robustness checks
```

### Cell Organization Within a Notebook

```python
# === CELL 1: Header and metadata ===
"""
# Analysis: Effect of Treatment on Outcome Variable
Author: [Name]
Date: 2026-03-09
Data: experiment_results_v2.csv
Dependencies: pandas>=2.0, scipy>=1.11, matplotlib>=3.8
"""

# === CELL 2: Imports and configuration ===
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from scipy import stats

# Reproducibility
np.random.seed(42)
pd.set_option('display.max_columns', 50)
plt.rcParams.update({
    'figure.figsize': (10, 6),
    'figure.dpi': 150,
    'font.size': 12,
    'axes.titlesize': 14,
    'savefig.dpi': 300,
    'savefig.bbox': 'tight'
})

# === CELL 3: Data loading ===
DATA_PATH = '../data/raw/experiment_results_v2.csv'
df = pd.read_csv(DATA_PATH)
print(f"Loaded {len(df)} rows, {len(df.columns)} columns")
df.head()
```

## Reproducibility Best Practices

### Environment Management

Always pin your dependencies:

```bash
# Create environment from scratch
conda create -n research python=3.11
conda activate research

# Install and pin
pip install pandas==2.1.4 scipy==1.11.4 matplotlib==3.8.2 jupyterlab==4.0.9

# Export for reproducibility
pip freeze > requirements.txt

# Or use conda
conda env export --no-builds > environment.yml
```

### Kernel and Execution Order

```python
# Add this cell at the top of every notebook to catch execution order issues
import IPython
print(f"Python: {IPython.sys.version}")
print(f"IPython: {IPython.__version__}")
print(f"Working directory: {os.getcwd()}")

# Run all cells from top to bottom before sharing
# Menu: Kernel -> Restart & Run All
# This verifies the notebook executes cleanly in order
```

### Parameterized Notebooks

Use `papermill` for parameterized execution:

```python
# Parameters cell (tag with "parameters" in cell metadata)
input_file = "data/experiment_001.csv"
alpha = 0.05
n_bootstrap = 1000
output_dir = "results/experiment_001"
```

```bash
# Execute with different parameters
papermill 04_modeling.ipynb output/run_001.ipynb \
  -p input_file "data/experiment_001.csv" \
  -p alpha 0.01 \
  -p n_bootstrap 5000

# Batch execution
for i in $(seq 1 10); do
  papermill 04_modeling.ipynb "output/run_${i}.ipynb" \
    -p input_file "data/experiment_${i}.csv"
done
```

## JupyterLab Extensions for Research

| Extension | Purpose | Install |
|-----------|---------|---------|
| jupyterlab-git | Version control integration | `pip install jupyterlab-git` |
| jupyterlab-lsp | Code intelligence (autocomplete) | `pip install jupyterlab-lsp` |
| nbdime | Notebook diffing and merging | `pip install nbdime` |
| jupytext | Pair notebooks with .py scripts | `pip install jupytext` |
| jupyter-book | Convert notebooks to publications | `pip install jupyter-book` |

## Version Control for Notebooks

Jupyter notebooks contain output cells, which create noisy diffs. Solutions:

```bash
# Option 1: Strip outputs before committing
pip install nbstripout
nbstripout --install  # adds git filter

# Option 2: Use jupytext to maintain .py mirrors
jupytext --set-formats ipynb,py:percent notebook.ipynb
# Now edit the .py file and sync: jupytext --sync notebook.ipynb

# Option 3: Use nbdime for meaningful diffs
nbdime config-git --enable --global
git diff notebook.ipynb  # now shows structured diff
```

## Remote Computing Integration

### Connecting to HPC Clusters

```bash
# SSH tunnel to remote Jupyter server
ssh -N -L 8888:localhost:8888 user@cluster.university.edu

# On the cluster:
jupyter lab --no-browser --port=8888

# Then open http://localhost:8888 in your local browser
```

### Google Colab Integration

For quick sharing and GPU access, export notebooks to Colab format. Add a Colab badge to your repository README for one-click access. Remember that Colab environments are ephemeral -- always save results to Google Drive or download locally.

## Converting to Publications

Use `jupyter-book` or `nbconvert` to transform notebooks into LaTeX, HTML, or PDF outputs suitable for supplementary materials in journal submissions. Always run the full notebook from a clean kernel before conversion to ensure all outputs are current and reproducible.

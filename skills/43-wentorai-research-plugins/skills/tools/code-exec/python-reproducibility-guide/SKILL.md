---
name: python-reproducibility-guide
description: "Reproducible Python environments, notebooks, and literate programming"
metadata:
  openclaw:
    emoji: "🐍"
    category: "tools"
    subcategory: "code-exec"
    keywords: ["sandbox execution", "Jupyter notebook", "computational notebook", "literate programming"]
    source: "wentor-research-plugins"
---

# Python Reproducibility Guide

Set up reproducible Python environments for research computing, using virtual environments, dependency management, Jupyter notebooks, and literate programming practices.

## Environment Management

### Virtual Environments

```bash
# Option 1: venv (built-in, lightweight)
python -m venv .venv
source .venv/bin/activate       # macOS/Linux
# .venv\Scripts\activate        # Windows
pip install -r requirements.txt

# Option 2: conda (includes non-Python dependencies)
conda create -n myproject python=3.11
conda activate myproject
conda install numpy pandas scipy matplotlib
conda env export > environment.yml

# Option 3: uv (fast, modern Python package manager)
uv venv
source .venv/bin/activate
uv pip install -r requirements.txt
```

### Dependency Pinning

```bash
# requirements.txt with exact versions (pip freeze)
pip freeze > requirements.txt

# Better: use pip-tools for compiled dependencies
pip install pip-tools

# Create requirements.in (human-readable, loose constraints)
cat > requirements.in << 'EOF'
numpy>=1.24
pandas>=2.0
scipy>=1.11
matplotlib>=3.7
scikit-learn>=1.3
EOF

# Compile to requirements.txt (pinned, reproducible)
pip-compile requirements.in --output-file requirements.txt

# Install from compiled requirements
pip-sync requirements.txt
```

### pyproject.toml (Modern Standard)

```toml
[project]
name = "my-research-project"
version = "0.1.0"
description = "Analysis code for paper: Title"
requires-python = ">=3.10"
dependencies = [
    "numpy>=1.24",
    "pandas>=2.0",
    "scipy>=1.11",
    "matplotlib>=3.7",
    "scikit-learn>=1.3",
    "statsmodels>=0.14",
]

[project.optional-dependencies]
dev = ["pytest", "black", "ruff", "jupyter"]
gpu = ["torch>=2.0", "torchvision"]

[tool.ruff]
line-length = 88
select = ["E", "F", "I"]
```

## Jupyter Notebooks for Research

### Best Practices

```python
# Cell 1: Imports and configuration (always the first cell)
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from pathlib import Path

# Configuration
DATA_DIR = Path("./data")
OUTPUT_DIR = Path("./outputs")
OUTPUT_DIR.mkdir(exist_ok=True)

RANDOM_SEED = 42
np.random.seed(RANDOM_SEED)

# Matplotlib defaults
plt.rcParams.update({
    "figure.figsize": (10, 6),
    "figure.dpi": 150,
    "font.size": 12,
    "axes.spines.top": False,
    "axes.spines.right": False,
})

print(f"NumPy: {np.__version__}")
print(f"Pandas: {pd.__version__}")
```

### Notebook Structure Template

```markdown
# Paper Title: Analysis Notebook

## 1. Setup and Data Loading
[Import libraries, set seeds, load data]

## 2. Data Exploration
[Summary statistics, distributions, missing data check]

## 3. Preprocessing
[Cleaning, transformation, feature engineering]

## 4. Analysis
### 4.1 Primary Analysis
[Main statistical tests or model training]
### 4.2 Sensitivity Analysis
[Robustness checks]
### 4.3 Supplementary Analysis
[Additional analyses for appendix]

## 5. Visualization
[Publication-quality figures]

## 6. Export Results
[Save tables, figures, and summary statistics]
```

### Converting Notebooks to Scripts

```bash
# Convert notebook to Python script
jupyter nbconvert --to script analysis.ipynb

# Convert notebook to HTML report
jupyter nbconvert --to html --no-input analysis.ipynb

# Convert notebook to PDF
jupyter nbconvert --to pdf analysis.ipynb

# Execute notebook from command line (and save output)
jupyter nbconvert --execute --to notebook --inplace analysis.ipynb
```

## Reproducible Random Seeds

```python
import numpy as np
import random
import os

def set_global_seed(seed=42):
    """Set random seeds for full reproducibility."""
    random.seed(seed)
    np.random.seed(seed)
    os.environ["PYTHONHASHSEED"] = str(seed)

    # PyTorch (if used)
    try:
        import torch
        torch.manual_seed(seed)
        torch.cuda.manual_seed_all(seed)
        torch.backends.cudnn.deterministic = True
        torch.backends.cudnn.benchmark = False
    except ImportError:
        pass

    # TensorFlow (if used)
    try:
        import tensorflow as tf
        tf.random.set_seed(seed)
    except ImportError:
        pass

set_global_seed(42)
```

## Containerization with Docker

### Dockerfile for Research

```dockerfile
FROM python:3.11-slim

WORKDIR /app

# System dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    git \
    && rm -rf /var/lib/apt/lists/*

# Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy project code
COPY . .

# Default: run the analysis
CMD ["python", "run_analysis.py"]
```

```bash
# Build and run
docker build -t my-analysis .
docker run -v $(pwd)/data:/app/data -v $(pwd)/outputs:/app/outputs my-analysis

# Interactive Jupyter inside Docker
docker run -p 8888:8888 -v $(pwd):/app my-analysis \
    jupyter notebook --ip=0.0.0.0 --allow-root --no-browser
```

## Project Structure

```
research-project/
├── README.md                 # Project overview and how to reproduce
├── pyproject.toml            # Dependencies and project metadata
├── requirements.txt          # Pinned dependencies
├── Dockerfile                # Containerized environment
├── Makefile                  # Automation (make data, make analysis, make figures)
├── data/
│   ├── raw/                  # Original, immutable data
│   ├── processed/            # Cleaned, transformed data
│   └── external/             # Third-party data sources
├── notebooks/
│   ├── 01_exploration.ipynb  # Data exploration
│   ├── 02_analysis.ipynb     # Main analysis
│   └── 03_figures.ipynb      # Publication figures
├── src/
│   ├── __init__.py
│   ├── data.py               # Data loading and preprocessing
│   ├── models.py             # Statistical models and ML
│   ├── visualization.py      # Plotting functions
│   └── utils.py              # Shared utilities
├── tests/
│   ├── test_data.py          # Data pipeline tests
│   └── test_models.py        # Model correctness tests
├── outputs/
│   ├── figures/              # Generated figures (PDF, PNG)
│   ├── tables/               # Generated tables (CSV, LaTeX)
│   └── models/               # Saved model artifacts
└── configs/
    ├── experiment_1.yaml     # Experiment configuration
    └── experiment_2.yaml     # Experiment configuration
```

## Makefile for Automation

```makefile
.PHONY: all data analysis figures clean

all: data analysis figures

data:
	python src/data.py --input data/raw/ --output data/processed/

analysis: data
	python -m jupyter nbconvert --execute notebooks/02_analysis.ipynb \
		--to notebook --inplace

figures: analysis
	python src/visualization.py --output outputs/figures/

clean:
	rm -rf data/processed/ outputs/

# Reproduce the full pipeline from scratch
reproduce: clean all
	@echo "All results reproduced successfully."

# Run tests
test:
	pytest tests/ -v

# Format code
format:
	ruff check --fix src/ tests/
	ruff format src/ tests/
```

## Logging and Experiment Tracking

```python
import logging
from datetime import datetime

# Set up logging
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(message)s",
    handlers=[
        logging.FileHandler(f"outputs/logs/run_{datetime.now():%Y%m%d_%H%M%S}.log"),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)

# Log experiment parameters
logger.info(f"Random seed: {RANDOM_SEED}")
logger.info(f"Data file: {DATA_DIR / 'dataset.csv'}")
logger.info(f"Model: Linear Regression with L2 regularization (alpha=0.1)")
logger.info(f"Train/test split: 80/20")
```

## Reproducibility Checklist

- [ ] All dependencies are pinned in `requirements.txt` or `pyproject.toml`
- [ ] Random seeds are set at the beginning of every script/notebook
- [ ] Raw data is stored separately and never modified
- [ ] Data preprocessing steps are scripted (not manual)
- [ ] Analysis can be re-run with a single command (`make all` or `python run_analysis.py`)
- [ ] Environment is documented (Python version, OS, hardware specs)
- [ ] Figures are generated programmatically (not edited manually)
- [ ] Code is tested (at least smoke tests for critical functions)
- [ ] A README explains how to set up the environment and reproduce results
- [ ] Version control (git) tracks all code changes with meaningful commits

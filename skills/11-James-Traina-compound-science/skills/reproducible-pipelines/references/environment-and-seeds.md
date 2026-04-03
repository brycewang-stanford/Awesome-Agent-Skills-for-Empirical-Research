# Environment Management, Seeds, and Results Caching

## Environment Management

### Conda (Recommended for Python/R Mixed Projects)

```yaml
# environment.yml
name: my-project
channels:
  - conda-forge
  - defaults
dependencies:
  - python=3.11.7        # Pin exact version
  - numpy=1.26.4
  - pandas=2.2.0
  - scipy=1.12.0
  - statsmodels=0.14.1
  - scikit-learn=1.4.0
  - matplotlib=3.8.3
  - pip:
    - linearmodels==6.0
    - pyblp==1.1.0
    - rdrobust==1.1.1
```

```bash
# Create environment
conda env create -f environment.yml

# Export exact versions (for reproducibility)
conda env export --no-builds > environment.lock.yml

# Recreate exact environment
conda env create -f environment.lock.yml
```

**Best practices:**
- Pin **exact** versions in the lock file (not `>=` or `~=`)
- Use `conda-forge` channel for most scientific packages
- Test on a clean machine (or CI) to verify the environment file is complete
- `environment.yml` is for human editing; `environment.lock.yml` is the machine-exact specification

### pip + venv (Lighter Weight)

```bash
# Create virtual environment
python -m venv .venv
source .venv/bin/activate

# Install and freeze
pip install numpy==1.26.4 pandas==2.2.0 statsmodels==0.14.1
pip freeze > requirements.txt

# Recreate
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

### renv (For R Projects)

```r
# Initialize renv in project
renv::init()

# Install packages (recorded in renv.lock)
install.packages("fixest")
install.packages("did")

# Snapshot current state
renv::snapshot()

# Collaborator restores exact environment
renv::restore()
```

### Docker (Maximum Reproducibility)

Use Docker when the computational environment itself must be exactly reproducible (OS-level dependencies, system libraries).

```dockerfile
# Dockerfile
FROM continuumio/miniconda3:24.1.2-0

WORKDIR /project

# Copy environment specification first (for caching)
COPY environment.yml .
RUN conda env create -f environment.yml

# Activate environment in subsequent commands
SHELL ["conda", "run", "-n", "my-project", "/bin/bash", "-c"]

# Copy project files
COPY . .

# Default: run the full pipeline
CMD ["make", "all"]
```

```bash
# Build and run
docker build -t my-project .
docker run -v $(pwd)/output:/project/output my-project

# Or run interactively
docker run -it -v $(pwd):/project my-project bash
```

## Random Seed Management

Every stochastic operation must be seeded and logged.

```python
# config.py — Central seed management
import numpy as np
import random
import os

MASTER_SEED = 20240215  # Date-based seeds are easy to document

def set_all_seeds(seed=MASTER_SEED):
    """Set seeds for all random number generators."""
    np.random.seed(seed)
    random.seed(seed)
    os.environ['PYTHONHASHSEED'] = str(seed)

    # If using PyTorch
    try:
        import torch
        torch.manual_seed(seed)
        torch.cuda.manual_seed_all(seed)
        torch.backends.cudnn.deterministic = True
    except ImportError:
        pass

def get_rng(seed=None):
    """Create an independent RNG for a specific task.

    Use this instead of global np.random to avoid seed contamination
    between different parts of the pipeline.
    """
    if seed is None:
        seed = MASTER_SEED
    return np.random.default_rng(seed)
```

```python
# In estimation code
from config import get_rng, MASTER_SEED

# Each bootstrap/simulation gets a deterministic, independent seed
rng = get_rng(MASTER_SEED + 1)  # +1 for bootstrap, +2 for simulation, etc.

bootstrap_estimates = []
for b in range(n_bootstrap):
    idx = rng.choice(n, size=n, replace=True)
    # ... estimate on bootstrap sample
```

**Rules:**
1. **One master seed** defined in a config file, documented in README
2. **Derived seeds** for different pipeline stages (bootstrap, simulation, sample splits)
3. **Use `np.random.default_rng()`** not `np.random.seed()` — the new API creates independent generators that don't interfere with each other
4. **Log the seed** in output metadata: `results['seed'] = MASTER_SEED`
5. **Test reproducibility**: run the pipeline twice and diff the outputs

## Results Caching

Avoid re-running expensive computations during development.

```python
import joblib
from pathlib import Path

def cached_computation(func, cache_key, cache_dir="output/cache", **kwargs):
    """Cache expensive computations with dependency-aware keys."""
    cache_path = Path(cache_dir) / f"{cache_key}.joblib"
    cache_path.parent.mkdir(parents=True, exist_ok=True)

    if cache_path.exists():
        return joblib.load(cache_path)

    result = func(**kwargs)
    joblib.dump(result, cache_path)
    return result

# Usage
estimates = cached_computation(
    run_estimation,
    cache_key="main_2sls_v3",  # version the cache key when code changes
    data=df, instruments=['z1', 'z2']
)
```

**Important:** Caching is for development speed only. The final replication run must execute everything from scratch (`make clean && make all`).

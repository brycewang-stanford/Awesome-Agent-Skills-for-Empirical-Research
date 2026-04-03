---
name: sandbox-execution-guide
description: "Secure sandboxed code execution environments for reproducible research computing"
metadata:
  openclaw:
    emoji: "🛡️"
    category: "tools"
    subcategory: "code-exec"
    keywords: ["sandbox execution", "code runner", "literate programming", "containerization", "reproducible computing"]
    source: "wentor"
---

# Sandbox Execution Guide

A skill for setting up and using sandboxed code execution environments for research computing. Covers containerized execution, security considerations, resource management, and integration with research workflows.

## Why Sandboxed Execution?

Research code often requires:
- Isolation from the host system for security
- Reproducible environments across machines
- Resource limits to prevent runaway computations
- Multi-language support (Python, R, Julia, MATLAB)

## Docker-Based Sandboxes

### Creating a Research Container

```dockerfile
# Dockerfile for a reproducible research environment
FROM python:3.11-slim

# System dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    gfortran \
    libopenblas-dev \
    && rm -rf /var/lib/apt/lists/*

# Create non-root user for security
RUN useradd -m -s /bin/bash researcher
USER researcher
WORKDIR /home/researcher

# Pin all dependencies
COPY requirements.txt .
RUN pip install --user --no-cache-dir -r requirements.txt

# Copy project files
COPY --chown=researcher:researcher . /home/researcher/project
WORKDIR /home/researcher/project

# Resource limits set at runtime, not build time
CMD ["python", "main.py"]
```

### Running with Resource Limits

```bash
# Run with CPU, memory, and time constraints
docker run \
  --cpus="2.0" \
  --memory="4g" \
  --memory-swap="4g" \
  --pids-limit=100 \
  --network=none \
  --read-only \
  --tmpfs /tmp:size=512m \
  --timeout 3600 \
  research-sandbox:latest python analysis.py

# Mount data as read-only, output directory as writable
docker run \
  -v /data/raw:/data:ro \
  -v /data/results:/output:rw \
  --cpus="4.0" \
  --memory="16g" \
  research-sandbox:latest python pipeline.py
```

## Python Sandbox with Resource Limits

### Process-Level Isolation

```python
import subprocess
import resource
import signal
import tempfile
import os

def run_sandboxed(code: str, timeout: int = 60,
                   max_memory_mb: int = 512) -> dict:
    """
    Execute Python code in a sandboxed subprocess with resource limits.

    Args:
        code: Python code string to execute
        timeout: Maximum execution time in seconds
        max_memory_mb: Maximum memory in megabytes
    """
    with tempfile.NamedTemporaryFile(mode='w', suffix='.py', delete=False) as f:
        f.write(code)
        script_path = f.name

    try:
        result = subprocess.run(
            ['python', '-u', script_path],
            capture_output=True,
            text=True,
            timeout=timeout,
            env={
                'PATH': '/usr/bin:/usr/local/bin',
                'HOME': '/tmp',
                'PYTHONDONTWRITEBYTECODE': '1'
            }
        )
        return {
            'stdout': result.stdout,
            'stderr': result.stderr,
            'returncode': result.returncode,
            'timed_out': False
        }
    except subprocess.TimeoutExpired:
        return {
            'stdout': '',
            'stderr': f'Execution timed out after {timeout}s',
            'returncode': -1,
            'timed_out': True
        }
    finally:
        os.unlink(script_path)

# Example usage
result = run_sandboxed("""
import numpy as np
data = np.random.randn(1000)
print(f"Mean: {data.mean():.4f}")
print(f"Std:  {data.std():.4f}")
""", timeout=30, max_memory_mb=256)
print(result['stdout'])
```

## Nix-Based Reproducible Environments

For maximum reproducibility, use Nix to pin every dependency including system libraries:

```nix
# shell.nix for a research project
{ pkgs ? import (fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/nixos-23.11.tar.gz";
  }) {} }:

pkgs.mkShell {
  buildInputs = with pkgs; [
    python311
    python311Packages.numpy
    python311Packages.scipy
    python311Packages.pandas
    python311Packages.matplotlib
    python311Packages.scikit-learn
    R
    rPackages.ggplot2
    rPackages.dplyr
  ];

  shellHook = ''
    echo "Research sandbox activated"
    echo "Python: $(python --version)"
    echo "R: $(R --version | head -1)"
  '';
}
```

```bash
# Enter the reproducible environment
nix-shell shell.nix

# Or use flakes for even better reproducibility
nix develop
```

## Security Best Practices

When running untrusted or third-party code:

1. **Network isolation**: Use `--network=none` in Docker to prevent data exfiltration
2. **Filesystem restrictions**: Mount data as read-only, limit writable paths
3. **Resource caps**: Always set CPU, memory, and time limits
4. **User isolation**: Run as non-root user inside the container
5. **Syscall filtering**: Use seccomp profiles to restrict system calls
6. **Output sanitization**: Validate and sanitize all output before processing

## Integration with CI/CD

Automate research pipeline execution with GitHub Actions:

```yaml
name: Research Pipeline
on:
  push:
    paths: ['src/**', 'data/**']

jobs:
  run-analysis:
    runs-on: ubuntu-latest
    container:
      image: research-sandbox:latest
      options: --cpus 4 --memory 8g
    steps:
      - uses: actions/checkout@v4
      - run: python src/01_preprocess.py
      - run: python src/02_analyze.py
      - run: python src/03_visualize.py
      - uses: actions/upload-artifact@v4
        with:
          name: results
          path: output/
```

This ensures every commit triggers a fresh, sandboxed execution of the full pipeline, catching environment-dependent bugs and ensuring reproducibility.

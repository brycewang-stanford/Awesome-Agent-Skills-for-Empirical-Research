---
name: google-colab-guide
description: "Run and manage Google Colab notebooks for Python and ML research"
metadata:
  openclaw:
    emoji: "🖥️"
    category: "tools"
    subcategory: "code-exec"
    keywords: ["Google Colab", "Jupyter", "GPU", "machine learning", "Python", "cloud computing"]
    source: "https://colab.research.google.com"
---

# Google Colab Guide

Run Python code, train machine learning models, and perform data analysis using Google Colab's free cloud-hosted Jupyter notebooks with GPU and TPU access. This skill covers setup, resource management, persistent storage, and best practices for reproducible research computing.

## Overview

Google Colab (Colaboratory) provides free access to GPU-accelerated Jupyter notebooks running on Google's cloud infrastructure. For academic researchers, Colab eliminates the barrier of expensive hardware for machine learning experiments, large-scale data processing, and computationally intensive statistical analyses. The free tier includes NVIDIA T4 GPUs, and paid tiers (Colab Pro, Pro+) offer A100 GPUs and extended runtime.

Colab notebooks run in ephemeral virtual machines that are recycled after inactivity or maximum runtime. This creates unique challenges for research: managing persistent data, saving checkpoints, reproducing results, and working with large datasets. This skill addresses these challenges with proven patterns used by ML researchers worldwide.

Colab integrates natively with Google Drive for storage, GitHub for version control, and supports the full Python scientific computing ecosystem (NumPy, pandas, scikit-learn, PyTorch, TensorFlow, JAX). Each notebook runs in an isolated environment with root access, allowing installation of any Linux package or Python library.

## Getting Started

### Runtime Configuration

```python
# Check current runtime type
import subprocess
result = subprocess.run(['nvidia-smi'], capture_output=True, text=True)
print(result.stdout)  # Shows GPU info if GPU runtime is selected

# Check available resources
import psutil
print(f"RAM: {psutil.virtual_memory().total / 1e9:.1f} GB")
print(f"CPU cores: {psutil.cpu_count()}")
print(f"Disk: {psutil.disk_usage('/').total / 1e9:.1f} GB")
```

### Runtime Selection Guide

| Runtime | GPU | RAM | Use Case |
|---------|-----|-----|----------|
| CPU | None | ~12 GB | Data cleaning, text processing, small models |
| T4 GPU (free) | 16 GB VRAM | ~12 GB | Training medium models, inference |
| A100 GPU (Pro) | 40 GB VRAM | ~50 GB | Large model training, LLM fine-tuning |
| TPU v2 (free) | 8 cores | ~12 GB | JAX/TensorFlow distributed training |

### Google Drive Mount

```python
from google.colab import drive
drive.mount('/content/drive')

# Access files in Drive
import pandas as pd
df = pd.read_csv('/content/drive/MyDrive/research/dataset.csv')
```

## Data Management

### Downloading Datasets

```python
# From URL
!wget -q https://example.com/dataset.zip -O /content/dataset.zip
!unzip -q /content/dataset.zip -d /content/data/

# From Kaggle
!pip install -q kaggle
!mkdir -p ~/.kaggle
# Upload kaggle.json API key first
!kaggle datasets download -d user/dataset-name -p /content/data/

# From Hugging Face
!pip install -q datasets
from datasets import load_dataset
dataset = load_dataset("scientific_papers", "arxiv")
```

### Persistent Storage Patterns

Since Colab VMs are ephemeral, always save important outputs to Google Drive:

```python
import shutil
from pathlib import Path

DRIVE_BASE = Path("/content/drive/MyDrive/research/experiment_001")
DRIVE_BASE.mkdir(parents=True, exist_ok=True)

def save_checkpoint(model, optimizer, epoch, loss):
    """Save training checkpoint to Google Drive."""
    checkpoint = {
        'epoch': epoch,
        'model_state_dict': model.state_dict(),
        'optimizer_state_dict': optimizer.state_dict(),
        'loss': loss
    }
    path = DRIVE_BASE / f"checkpoint_epoch_{epoch}.pt"
    torch.save(checkpoint, path)
    print(f"Checkpoint saved to {path}")

def save_results(df, name):
    """Save results DataFrame to Drive."""
    path = DRIVE_BASE / f"{name}.csv"
    df.to_csv(path, index=False)
    print(f"Results saved to {path}")
```

## Machine Learning Workflows

### PyTorch Training Loop

```python
!pip install -q torch torchvision

import torch
import torch.nn as nn
from torch.utils.data import DataLoader

# Automatic device selection
device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
print(f"Using device: {device}")

model = MyModel().to(device)
optimizer = torch.optim.AdamW(model.parameters(), lr=1e-4)
criterion = nn.CrossEntropyLoss()

for epoch in range(num_epochs):
    model.train()
    total_loss = 0
    for batch in train_loader:
        inputs, labels = batch[0].to(device), batch[1].to(device)
        optimizer.zero_grad()
        outputs = model(inputs)
        loss = criterion(outputs, labels)
        loss.backward()
        optimizer.step()
        total_loss += loss.item()

    avg_loss = total_loss / len(train_loader)
    print(f"Epoch {epoch+1}/{num_epochs}, Loss: {avg_loss:.4f}")

    # Save checkpoint every 5 epochs
    if (epoch + 1) % 5 == 0:
        save_checkpoint(model, optimizer, epoch + 1, avg_loss)
```

### Hugging Face Transformers

```python
!pip install -q transformers accelerate

from transformers import AutoTokenizer, AutoModelForSequenceClassification, Trainer

model_name = "allenai/scibert_scivocab_uncased"
tokenizer = AutoTokenizer.from_pretrained(model_name)
model = AutoModelForSequenceClassification.from_pretrained(
    model_name, num_labels=5
)

trainer = Trainer(
    model=model,
    args=training_args,
    train_dataset=train_dataset,
    eval_dataset=eval_dataset,
    tokenizer=tokenizer
)
trainer.train()

# Save to Drive
model.save_pretrained(str(DRIVE_BASE / "fine_tuned_scibert"))
```

## Environment Management

### Installing Packages

```python
# Install specific versions for reproducibility
!pip install -q transformers==4.40.0 datasets==2.18.0 evaluate==0.4.1

# Install from GitHub
!pip install -q git+https://github.com/huggingface/peft.git

# Install system packages
!apt-get -qq install -y graphviz texlive-latex-base
```

### Reproducibility Setup

```python
import random
import numpy as np
import torch

def set_seed(seed=42):
    """Set all random seeds for reproducibility."""
    random.seed(seed)
    np.random.seed(seed)
    torch.manual_seed(seed)
    torch.cuda.manual_seed_all(seed)
    torch.backends.cudnn.deterministic = True
    torch.backends.cudnn.benchmark = False

set_seed(42)
```

### Requirements File

```python
# Generate requirements for reproducibility
!pip freeze > /content/drive/MyDrive/research/requirements.txt

# Restore environment in new session
!pip install -q -r /content/drive/MyDrive/research/requirements.txt
```

## Performance Optimization

### Memory Management

```python
# Monitor GPU memory
!nvidia-smi

# Clear GPU cache
torch.cuda.empty_cache()

# Use mixed precision training for 2x speedup
from torch.cuda.amp import autocast, GradScaler
scaler = GradScaler()

for batch in train_loader:
    optimizer.zero_grad()
    with autocast():
        outputs = model(inputs)
        loss = criterion(outputs, labels)
    scaler.scale(loss).backward()
    scaler.step(optimizer)
    scaler.update()
```

### Preventing Disconnection

Colab disconnects after 90 minutes of inactivity (free tier). Strategies:

1. Use `tqdm` progress bars to show activity
2. Save checkpoints frequently to Google Drive
3. Structure experiments to complete within single sessions
4. Use Colab Pro for longer runtimes (24 hours)

## GitHub Integration

```python
# Clone a research repository
!git clone https://github.com/user/research-repo.git /content/repo

# Push results back
%cd /content/repo
!git config user.email "researcher@university.edu"
!git config user.name "Researcher"
!git add results/
!git commit -m "Add experiment results from Colab"
!git push
```

## References

- Google Colab documentation: https://colab.research.google.com/notebooks/intro.ipynb
- Colab resource limits FAQ: https://research.google.com/colaboratory/faq.html
- PyTorch on Colab: https://pytorch.org/tutorials/beginner/colab
- Hugging Face + Colab: https://huggingface.co/docs/transformers/notebooks

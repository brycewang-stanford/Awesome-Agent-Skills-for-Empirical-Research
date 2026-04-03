---
name: pytorch-guide
description: "Avoid common PyTorch mistakes and apply robust training patterns"
metadata:
  openclaw:
    emoji: "🔥"
    category: "domains"
    subcategory: "ai-ml"
    keywords: ["PyTorch", "deep learning", "training loop", "GPU", "debugging", "autograd"]
    source: "https://github.com/pytorch/pytorch"
---

# PyTorch Guide

## Overview

PyTorch is the dominant deep learning framework in academic research, used in the majority of papers at NeurIPS, ICML, and ICLR. Its eager execution model, Pythonic API, and seamless integration with the Python scientific stack make it the default choice for prototyping and publishing research code.

However, PyTorch's flexibility is a double-edged sword. Subtle bugs -- forgetting `model.eval()`, accumulating gradients across batches, incorrect device placement, memory leaks from detached tensors -- can silently corrupt results without raising errors. These issues are especially dangerous in research settings where ground truth is unknown.

This guide catalogs the most common PyTorch mistakes, provides battle-tested training patterns, and covers performance optimization techniques that every researcher should know. The patterns here are drawn from top-tier ML research codebases and the PyTorch team's own best practice recommendations.

## Common Mistakes and Fixes

### The Big Five Mistakes

```python
# MISTAKE 1: Forgetting model.eval() and torch.no_grad()
# This causes dropout and batch norm to behave incorrectly during evaluation
# and wastes memory by tracking gradients

# WRONG
def evaluate(model, dataloader):
    total_correct = 0
    for x, y in dataloader:
        output = model(x)  # Dropout still active! BN using batch stats!
        total_correct += (output.argmax(1) == y).sum().item()

# RIGHT
@torch.no_grad()
def evaluate(model, dataloader):
    model.eval()
    total_correct = 0
    for x, y in dataloader:
        output = model(x)
        total_correct += (output.argmax(1) == y).sum().item()
    model.train()  # Restore training mode
    return total_correct
```

```python
# MISTAKE 2: Not zeroing gradients (they accumulate by default!)
# WRONG - gradients from previous batch add to current batch
for x, y in dataloader:
    loss = criterion(model(x), y)
    loss.backward()
    optimizer.step()

# RIGHT
for x, y in dataloader:
    optimizer.zero_grad()        # Clear previous gradients
    loss = criterion(model(x), y)
    loss.backward()
    optimizer.step()

# BETTER (slightly faster, avoids memset)
for x, y in dataloader:
    optimizer.zero_grad(set_to_none=True)
    loss = criterion(model(x), y)
    loss.backward()
    optimizer.step()
```

```python
# MISTAKE 3: Memory leaks from tensor operations in metrics
# WRONG - keeps entire computation graph in memory
losses = []
for x, y in dataloader:
    loss = criterion(model(x), y)
    losses.append(loss)  # Retains computation graph!

# RIGHT - detach from graph and move to CPU
losses = []
for x, y in dataloader:
    loss = criterion(model(x), y)
    losses.append(loss.item())  # .item() extracts Python scalar
```

```python
# MISTAKE 4: Incorrect device placement
# WRONG - model on GPU, data on CPU
model = model.cuda()
for x, y in dataloader:
    output = model(x)  # RuntimeError: tensors on different devices

# RIGHT
device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
model = model.to(device)
for x, y in dataloader:
    x, y = x.to(device), y.to(device)
    output = model(x)
```

```python
# MISTAKE 5: Mutable default arguments in dataset transforms
# WRONG
class MyDataset(Dataset):
    def __init__(self, data, transforms=[]):  # Shared mutable list!
        self.transforms = transforms

# RIGHT
class MyDataset(Dataset):
    def __init__(self, data, transforms=None):
        self.transforms = transforms or []
```

## Robust Training Template

```python
import torch
import torch.nn as nn
from torch.utils.data import DataLoader
from torch.cuda.amp import autocast, GradScaler
import time

def train(
    model: nn.Module,
    train_loader: DataLoader,
    val_loader: DataLoader,
    optimizer: torch.optim.Optimizer,
    scheduler,
    num_epochs: int,
    device: torch.device,
    use_amp: bool = True,
):
    """Production-quality training loop with mixed precision and checkpointing."""
    criterion = nn.CrossEntropyLoss()
    scaler = GradScaler(enabled=use_amp)
    best_val_loss = float("inf")

    for epoch in range(num_epochs):
        # --- Training ---
        model.train()
        train_loss = 0.0
        t0 = time.time()

        for batch_idx, (x, y) in enumerate(train_loader):
            x, y = x.to(device, non_blocking=True), y.to(device, non_blocking=True)

            optimizer.zero_grad(set_to_none=True)

            with autocast(enabled=use_amp):
                output = model(x)
                loss = criterion(output, y)

            scaler.scale(loss).backward()
            scaler.unscale_(optimizer)
            torch.nn.utils.clip_grad_norm_(model.parameters(), max_norm=1.0)
            scaler.step(optimizer)
            scaler.update()

            train_loss += loss.item()

        scheduler.step()
        avg_train_loss = train_loss / len(train_loader)

        # --- Validation ---
        model.eval()
        val_loss = 0.0
        correct = 0
        total = 0

        with torch.no_grad():
            for x, y in val_loader:
                x, y = x.to(device, non_blocking=True), y.to(device, non_blocking=True)
                with autocast(enabled=use_amp):
                    output = model(x)
                    loss = criterion(output, y)
                val_loss += loss.item()
                correct += (output.argmax(1) == y).sum().item()
                total += y.size(0)

        avg_val_loss = val_loss / len(val_loader)
        val_acc = correct / total

        # --- Checkpoint ---
        if avg_val_loss < best_val_loss:
            best_val_loss = avg_val_loss
            torch.save({
                "epoch": epoch,
                "model_state_dict": model.state_dict(),
                "optimizer_state_dict": optimizer.state_dict(),
                "val_loss": avg_val_loss,
            }, "best_checkpoint.pt")

        elapsed = time.time() - t0
        print(f"Epoch {epoch+1}/{num_epochs} | "
              f"Train Loss: {avg_train_loss:.4f} | "
              f"Val Loss: {avg_val_loss:.4f} | "
              f"Val Acc: {val_acc:.4f} | "
              f"Time: {elapsed:.1f}s")
```

## Performance Optimization

| Technique | Speedup | Effort | When to Use |
|-----------|---------|--------|-------------|
| Mixed precision (AMP) | 1.5-3x | Low | Always on modern GPUs |
| `torch.compile()` | 1.2-2x | Low | PyTorch 2.0+, stable models |
| `pin_memory=True` in DataLoader | 1.1-1.3x | Trivial | Always with GPU training |
| `non_blocking=True` in `.to()` | 1.05-1.1x | Trivial | Always with pinned memory |
| Gradient accumulation | N/A | Low | When batch size limited by memory |
| `torch.backends.cudnn.benchmark = True` | 1.1-1.5x | Trivial | Fixed input sizes |
| Distributed Data Parallel | Near-linear | Medium | Multi-GPU training |

### GPU Memory Management

```python
# Check GPU memory usage
print(f"Allocated: {torch.cuda.memory_allocated() / 1e9:.2f} GB")
print(f"Cached: {torch.cuda.memory_reserved() / 1e9:.2f} GB")

# Force garbage collection when debugging OOM
torch.cuda.empty_cache()
import gc; gc.collect()

# Gradient accumulation for effective large batch sizes
accumulation_steps = 4
for i, (x, y) in enumerate(dataloader):
    loss = criterion(model(x.to(device)), y.to(device)) / accumulation_steps
    loss.backward()
    if (i + 1) % accumulation_steps == 0:
        optimizer.step()
        optimizer.zero_grad(set_to_none=True)
```

## Reproducibility Checklist

```python
import torch
import numpy as np
import random

def seed_everything(seed=42):
    random.seed(seed)
    np.random.seed(seed)
    torch.manual_seed(seed)
    torch.cuda.manual_seed_all(seed)
    torch.backends.cudnn.deterministic = True
    torch.backends.cudnn.benchmark = False
    # For DataLoader workers
    def seed_worker(worker_id):
        worker_seed = seed + worker_id
        np.random.seed(worker_seed)
        random.seed(worker_seed)
    return seed_worker

seed_worker = seed_everything(42)
dataloader = DataLoader(
    dataset, batch_size=32, shuffle=True,
    worker_init_fn=seed_worker,
    generator=torch.Generator().manual_seed(42),
)
```

## Best Practices

- **Always use `torch.no_grad()` for inference.** It reduces memory usage by ~50%.
- **Prefer `model.to(device)` over `.cuda()`.** It is device-agnostic and works on CPU, CUDA, and MPS.
- **Use `torch.compile(model)` on PyTorch 2.0+** for free speedups on stable architectures.
- **Profile before optimizing.** Use `torch.profiler` to find actual bottlenecks.
- **Pin your PyTorch version in `requirements.txt`.** Different versions can produce different numerical results.
- **Use `torchinfo` for model summary** instead of printing the model object.

## References

- [PyTorch documentation](https://pytorch.org/docs/stable/) -- Official API reference
- [PyTorch tutorials](https://pytorch.org/tutorials/) -- End-to-end examples from the PyTorch team
- [PyTorch best practices](https://pytorch.org/docs/stable/notes/cuda.html) -- CUDA semantics and best practices
- [Effective PyTorch](https://github.com/vahidk/EffectivePyTorch) -- Community best practices guide
- [PyTorch Lightning](https://lightning.ai/) -- High-level training framework built on PyTorch

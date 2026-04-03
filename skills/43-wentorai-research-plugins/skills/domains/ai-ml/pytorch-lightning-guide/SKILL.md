---
name: pytorch-lightning-guide
description: "PyTorch Lightning framework for scalable model training and research"
metadata:
  openclaw:
    emoji: "⚡"
    category: "domains"
    subcategory: "ai-ml"
    keywords: ["pytorch-lightning", "training", "distributed", "finetuning", "scalability", "research"]
    source: "https://github.com/Lightning-AI/pytorch-lightning"
---

# PyTorch Lightning Guide

## Overview

PyTorch Lightning is a deep learning framework with over 31,000 GitHub stars that provides a high-level interface for PyTorch, enabling researchers to focus on model design rather than engineering boilerplate. Developed by Lightning AI, it decouples the science (model architecture, loss functions, data processing) from the engineering (distributed training, mixed precision, gradient accumulation, checkpointing) through a structured `LightningModule` abstraction.

For academic researchers, Lightning eliminates the need to write repetitive training loops, device management code, and distributed training logic. You define your model, training step, and data loaders, and Lightning handles everything else -- from single GPU to multi-node distributed training, from FP32 to mixed precision, from local development to cloud deployment. This means faster iteration on research ideas with production-quality training infrastructure.

Lightning is used extensively in AI research labs and has become a standard tool for reproducible deep learning experiments. It integrates seamlessly with experiment tracking tools like Weights & Biases, MLflow, and TensorBoard, and supports all PyTorch-compatible model architectures.

## Installation and Setup

```bash
# Install PyTorch Lightning
pip install lightning

# Or install with specific extras
pip install lightning[extra]

# For development/research with all features
pip install lightning[all]
```

Lightning requires Python 3.9+ and PyTorch 2.1+. For GPU training, ensure your PyTorch installation includes CUDA support:

```bash
# Check GPU availability
python -c "import torch; print(torch.cuda.is_available())"
```

Verify your installation:

```python
import lightning as L
print(L.__version__)
```

## Core Architecture

### The LightningModule

The `LightningModule` is the central abstraction. It organizes your PyTorch code into clearly defined methods:

```python
import lightning as L
import torch
import torch.nn.functional as F
from torch import nn

class ResearchModel(L.LightningModule):
    def __init__(self, input_dim, hidden_dim, output_dim, lr=1e-3):
        super().__init__()
        self.save_hyperparameters()
        self.encoder = nn.Sequential(
            nn.Linear(input_dim, hidden_dim),
            nn.ReLU(),
            nn.Dropout(0.2),
            nn.Linear(hidden_dim, hidden_dim),
            nn.ReLU(),
        )
        self.classifier = nn.Linear(hidden_dim, output_dim)
        self.lr = lr

    def forward(self, x):
        features = self.encoder(x)
        return self.classifier(features)

    def training_step(self, batch, batch_idx):
        x, y = batch
        logits = self(x)
        loss = F.cross_entropy(logits, y)
        acc = (logits.argmax(dim=-1) == y).float().mean()
        self.log("train_loss", loss, prog_bar=True)
        self.log("train_acc", acc, prog_bar=True)
        return loss

    def validation_step(self, batch, batch_idx):
        x, y = batch
        logits = self(x)
        loss = F.cross_entropy(logits, y)
        acc = (logits.argmax(dim=-1) == y).float().mean()
        self.log("val_loss", loss, prog_bar=True)
        self.log("val_acc", acc, prog_bar=True)

    def configure_optimizers(self):
        optimizer = torch.optim.AdamW(self.parameters(), lr=self.lr)
        scheduler = torch.optim.lr_scheduler.CosineAnnealingLR(
            optimizer, T_max=self.trainer.max_epochs
        )
        return [optimizer], [scheduler]
```

### The LightningDataModule

Encapsulate all data processing in a reusable `LightningDataModule`:

```python
class ResearchDataModule(L.LightningDataModule):
    def __init__(self, data_dir, batch_size=32, num_workers=4):
        super().__init__()
        self.data_dir = data_dir
        self.batch_size = batch_size
        self.num_workers = num_workers

    def setup(self, stage=None):
        # Load and split data
        dataset = load_research_dataset(self.data_dir)
        self.train_data, self.val_data, self.test_data = random_split(
            dataset, [0.8, 0.1, 0.1]
        )

    def train_dataloader(self):
        return DataLoader(self.train_data, batch_size=self.batch_size,
                         shuffle=True, num_workers=self.num_workers)

    def val_dataloader(self):
        return DataLoader(self.val_data, batch_size=self.batch_size,
                         num_workers=self.num_workers)
```

### The Trainer

The `Trainer` orchestrates everything with a rich set of configuration options:

```python
trainer = L.Trainer(
    max_epochs=100,
    accelerator="gpu",
    devices=4,
    strategy="ddp",
    precision="16-mixed",
    gradient_clip_val=1.0,
    accumulate_grad_batches=4,
    callbacks=[
        L.callbacks.EarlyStopping(monitor="val_loss", patience=10),
        L.callbacks.ModelCheckpoint(monitor="val_loss", save_top_k=3),
        L.callbacks.LearningRateMonitor(),
    ],
    logger=L.loggers.WandbLogger(project="my-research"),
)

# Train the model
trainer.fit(model, datamodule=data_module)

# Test with best checkpoint
trainer.test(model, datamodule=data_module, ckpt_path="best")
```

## Advanced Research Features

### Distributed Training Strategies

Lightning supports multiple distributed training strategies out of the box:

- **DDP (Distributed Data Parallel)**: Standard multi-GPU training
- **FSDP (Fully Sharded Data Parallel)**: Memory-efficient training for large models
- **DeepSpeed**: ZeRO optimization stages 1, 2, and 3

```python
# FSDP for large model training
trainer = L.Trainer(
    strategy="fsdp",
    devices=8,
    precision="bf16-mixed",
)
```

### Custom Training Loops

Override the training loop for non-standard research workflows like GANs, reinforcement learning, or meta-learning:

```python
class GANModule(L.LightningModule):
    def training_step(self, batch, batch_idx):
        optimizer_g, optimizer_d = self.optimizers()

        # Train discriminator
        real_loss = self.discriminator_loss(batch, real=True)
        fake_loss = self.discriminator_loss(batch, real=False)
        d_loss = (real_loss + fake_loss) / 2
        optimizer_d.zero_grad()
        self.manual_backward(d_loss)
        optimizer_d.step()

        # Train generator
        g_loss = self.generator_loss(batch)
        optimizer_g.zero_grad()
        self.manual_backward(g_loss)
        optimizer_g.step()

    @property
    def automatic_optimization(self):
        return False
```

### Profiling and Debugging

Built-in profiling tools help identify bottlenecks:

```python
trainer = L.Trainer(
    profiler="advanced",  # or "simple", "pytorch"
    detect_anomaly=True,
    overfit_batches=10,   # Quick sanity check
)
```

## Experiment Reproducibility

Lightning has built-in support for reproducibility, which is critical for academic research:

```python
# Seed everything for reproducibility
L.seed_everything(42, workers=True)

# Hyperparameters are automatically saved
model = ResearchModel(input_dim=768, hidden_dim=256, output_dim=10)
# model.hparams is automatically populated and logged

# Checkpoints include full training state
# Resume training from a checkpoint
trainer.fit(model, ckpt_path="path/to/checkpoint.ckpt")
```

The `save_hyperparameters()` call in your module's `__init__` automatically tracks all constructor arguments, making experiment comparison straightforward.

## References

- Repository: https://github.com/Lightning-AI/pytorch-lightning
- Documentation: https://lightning.ai/docs/pytorch/stable/
- Lightning AI platform: https://lightning.ai/
- Migration guide from vanilla PyTorch: https://lightning.ai/docs/pytorch/stable/starter/converting.html

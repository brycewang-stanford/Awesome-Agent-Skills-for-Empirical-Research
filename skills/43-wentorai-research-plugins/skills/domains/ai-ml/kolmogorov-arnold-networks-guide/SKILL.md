---
name: kolmogorov-arnold-networks-guide
description: "Papers and tutorials on KAN learnable activation networks"
metadata:
  openclaw:
    emoji: "📐"
    category: "domains"
    subcategory: "ai-ml"
    keywords: ["KAN", "Kolmogorov-Arnold", "learnable activations", "spline networks", "neural architecture", "interpretability"]
    source: "https://github.com/mintisan/awesome-kan"
---

# Kolmogorov-Arnold Networks (KAN) Guide

## Overview

Kolmogorov-Arnold Networks (KANs) are a novel neural network architecture that places learnable activation functions on edges (weights) instead of fixed activations on nodes. Based on the Kolmogorov-Arnold representation theorem, KANs use B-spline functions as learnable edge activations, achieving better accuracy and interpretability than MLPs with fewer parameters in certain domains. This collection tracks the rapidly growing KAN literature.

## Core Concept

```
Traditional MLP:
  x → [fixed activation(linear transform)] → y
  Activations on nodes, weights on edges

KAN:
  x → [learnable spline functions on edges] → sum → y
  Each edge learns its own activation function (B-spline)

Kolmogorov-Arnold Theorem:
  f(x₁,...,xₙ) = Σ Φᵢ(Σ φᵢⱼ(xⱼ))
  Any multivariate continuous function = composition of
  univariate functions and addition
```

## Key Papers

```bibtex
@article{liu2024kan,
  title={KAN: Kolmogorov-Arnold Networks},
  author={Liu, Ziming and Wang, Yixuan and Vaidya, Sachin and
          Ruehle, Fabian and Halverson, James and
          Solja{\v{c}}i{\'c}, Marin and Hou, Thomas Y. and
          Tegmark, Max},
  journal={arXiv:2404.19756},
  year={2024}
}
```

## Implementation

```python
# Using pykan (official implementation)
# pip install pykan

from kan import KAN
import torch

# Create a KAN model
model = KAN(
    width=[2, 5, 1],    # Input: 2, Hidden: 5, Output: 1
    grid=5,               # Spline grid resolution
    k=3,                  # Spline order (cubic)
)

# Training data
x = torch.randn(1000, 2)
y = torch.sin(x[:, 0]) + torch.cos(x[:, 1])
y = y.unsqueeze(1)

# Train
dataset = {"train_input": x[:800], "train_label": y[:800],
           "test_input": x[800:], "test_label": y[800:]}
model.train(dataset, steps=100, lr=0.01)

# Visualize learned functions
model.plot()

# Prune and simplify
model = model.prune()
model.plot()
```

## KAN vs MLP Comparison

```python
# Comparison on function approximation
from kan import KAN
import torch.nn as nn

# KAN: learnable activations on edges
kan_model = KAN(width=[2, 5, 1], grid=5, k=3)
# Parameters: ~150 (spline coefficients)

# MLP: fixed activations on nodes
class MLP(nn.Module):
    def __init__(self):
        super().__init__()
        self.net = nn.Sequential(
            nn.Linear(2, 50),
            nn.ReLU(),
            nn.Linear(50, 50),
            nn.ReLU(),
            nn.Linear(50, 1),
        )
    def forward(self, x):
        return self.net(x)

mlp_model = MLP()
# Parameters: ~2,700

# KAN advantages:
# - Fewer parameters for same accuracy
# - Interpretable (visualize learned functions)
# - Better for scientific discovery (symbolic regression)
# - Grid refinement for progressive accuracy

# MLP advantages:
# - Faster training
# - Better scaling to high dimensions
# - More mature tooling and optimization
```

## Extensions and Variants

| Variant | Innovation | Application |
|---------|-----------|-------------|
| **KAN 2.0** | MultKAN with multiplication nodes | Improved scaling |
| **Temporal KAN** | Time-series adaptation | Forecasting |
| **ConvKAN** | KAN + convolutions | Image processing |
| **GraphKAN** | KAN on graph structures | Graph learning |
| **FourierKAN** | Fourier basis instead of splines | Periodic functions |
| **WavKAN** | Wavelet-based activations | Signal processing |
| **BSRBF-KAN** | B-spline + radial basis | Function approximation |

## Scientific Applications

```python
# KAN for symbolic regression (discovering equations)
from kan import KAN

# Generate data from unknown equation: f(x,y) = x*exp(y)
import torch
x = torch.rand(1000, 2) * 2
y = x[:, 0:1] * torch.exp(x[:, 1:2])

dataset = {"train_input": x[:800], "train_label": y[:800],
           "test_input": x[800:], "test_label": y[800:]}

model = KAN(width=[2, 1, 1], grid=10, k=3)
model.train(dataset, steps=200)

# Symbolic fitting — discover the equation
model.auto_symbolic()
# Output: f(x₁, x₂) = x₁ * exp(x₂)
# KAN can discover symbolic expressions from data
```

## Research Landscape

```markdown
### Key Research Directions
1. **Scaling** — Making KANs work at LLM scale
2. **Efficiency** — Reducing spline computation overhead
3. **Theory** — Understanding approximation guarantees
4. **Architecture search** — Optimal KAN topologies
5. **Hybrid models** — Combining KAN and MLP strengths
6. **Domain applications** — Physics, chemistry, biology
7. **Interpretability** — Extracting symbolic knowledge
```

## Use Cases

1. **Scientific discovery**: Extract equations from experimental data
2. **Function approximation**: High-accuracy low-parameter models
3. **Interpretable ML**: Understand what the network learned
4. **Physics-informed**: Embed physical constraints in activations
5. **Education**: Teach alternative neural network architectures

## References

- [awesome-kan](https://github.com/mintisan/awesome-kan)
- [KAN Paper](https://arxiv.org/abs/2404.19756)
- [pykan Implementation](https://github.com/KindXiaoming/pykan)
- [KAN 2.0 Paper](https://arxiv.org/abs/2408.10205)

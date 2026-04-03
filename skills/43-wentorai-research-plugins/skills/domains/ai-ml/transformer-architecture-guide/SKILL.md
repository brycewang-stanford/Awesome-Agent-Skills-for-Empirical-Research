---
name: transformer-architecture-guide
description: "Guide to Transformer architectures for NLP and computer vision"
metadata:
  openclaw:
    emoji: "🧠"
    category: "domains"
    subcategory: "ai-ml"
    keywords: ["Transformer", "neural network", "deep learning", "NLP", "computer vision"]
    source: "wentor-research-plugins"
---

# Transformer Architecture Guide

Understand, implement, and adapt Transformer architectures for NLP, computer vision, and multimodal research, from the original attention mechanism to modern variants.

## The Original Transformer

The Transformer (Vaswani et al., 2017, "Attention Is All You Need") replaced recurrence and convolution with self-attention as the primary sequence modeling mechanism.

### Core Components

| Component | Function | Key Parameters |
|-----------|----------|---------------|
| Multi-Head Self-Attention | Computes attention weights across all positions | d_model, n_heads, d_k, d_v |
| Feed-Forward Network | Position-wise nonlinear transformation | d_model, d_ff |
| Positional Encoding | Injects sequence order information | Sinusoidal or learned |
| Layer Normalization | Stabilizes training | Pre-norm or post-norm |
| Residual Connections | Enables gradient flow in deep networks | Add before or after norm |

### Self-Attention Mechanism

```python
import torch
import torch.nn as nn
import torch.nn.functional as F
import math

class MultiHeadAttention(nn.Module):
    def __init__(self, d_model=512, n_heads=8):
        super().__init__()
        self.d_model = d_model
        self.n_heads = n_heads
        self.d_k = d_model // n_heads

        self.W_q = nn.Linear(d_model, d_model)
        self.W_k = nn.Linear(d_model, d_model)
        self.W_v = nn.Linear(d_model, d_model)
        self.W_o = nn.Linear(d_model, d_model)

    def forward(self, Q, K, V, mask=None):
        batch_size = Q.size(0)

        # Linear projections and reshape for multi-head
        Q = self.W_q(Q).view(batch_size, -1, self.n_heads, self.d_k).transpose(1, 2)
        K = self.W_k(K).view(batch_size, -1, self.n_heads, self.d_k).transpose(1, 2)
        V = self.W_v(V).view(batch_size, -1, self.n_heads, self.d_k).transpose(1, 2)

        # Scaled dot-product attention
        scores = torch.matmul(Q, K.transpose(-2, -1)) / math.sqrt(self.d_k)
        if mask is not None:
            scores = scores.masked_fill(mask == 0, -1e9)
        attn_weights = F.softmax(scores, dim=-1)
        context = torch.matmul(attn_weights, V)

        # Concatenate heads and project
        context = context.transpose(1, 2).contiguous().view(batch_size, -1, self.d_model)
        return self.W_o(context)
```

### Complete Transformer Block

```python
class TransformerBlock(nn.Module):
    def __init__(self, d_model=512, n_heads=8, d_ff=2048, dropout=0.1):
        super().__init__()
        self.attention = MultiHeadAttention(d_model, n_heads)
        self.norm1 = nn.LayerNorm(d_model)
        self.norm2 = nn.LayerNorm(d_model)
        self.ffn = nn.Sequential(
            nn.Linear(d_model, d_ff),
            nn.GELU(),
            nn.Dropout(dropout),
            nn.Linear(d_ff, d_model),
            nn.Dropout(dropout)
        )
        self.dropout = nn.Dropout(dropout)

    def forward(self, x, mask=None):
        # Pre-norm architecture (GPT-style)
        attn_out = self.attention(self.norm1(x), self.norm1(x), self.norm1(x), mask)
        x = x + self.dropout(attn_out)
        ffn_out = self.ffn(self.norm2(x))
        x = x + ffn_out
        return x
```

## Major Transformer Variants

### Architecture Taxonomy

| Architecture | Type | Key Innovation | Representative Model |
|-------------|------|---------------|---------------------|
| Encoder-only | Bidirectional | Masked language modeling | BERT, RoBERTa |
| Decoder-only | Autoregressive | Causal language modeling | GPT, LLaMA, Claude |
| Encoder-Decoder | Seq2seq | Cross-attention between encoder and decoder | T5, BART, mBART |

### Encoder-Only (BERT Family)

```python
# BERT-style masked language modeling
from transformers import BertTokenizer, BertForMaskedLM

tokenizer = BertTokenizer.from_pretrained("bert-base-uncased")
model = BertForMaskedLM.from_pretrained("bert-base-uncased")

text = "The Transformer architecture has [MASK] natural language processing."
inputs = tokenizer(text, return_tensors="pt")
outputs = model(**inputs)

# Get predictions for [MASK]
mask_idx = (inputs.input_ids == tokenizer.mask_token_id).nonzero(as_tuple=True)[1]
logits = outputs.logits[0, mask_idx]
top_tokens = logits.topk(5).indices[0]
print([tokenizer.decode(t) for t in top_tokens])
```

### Decoder-Only (GPT Family)

```python
# GPT-style autoregressive generation
from transformers import GPT2LMHeadModel, GPT2Tokenizer

tokenizer = GPT2Tokenizer.from_pretrained("gpt2")
model = GPT2LMHeadModel.from_pretrained("gpt2")

prompt = "The key innovation of the Transformer is"
inputs = tokenizer(prompt, return_tensors="pt")
outputs = model.generate(
    **inputs,
    max_new_tokens=50,
    temperature=0.7,
    top_p=0.9,
    do_sample=True
)
print(tokenizer.decode(outputs[0], skip_special_tokens=True))
```

## Vision Transformers (ViT)

The Vision Transformer (Dosovitskiy et al., 2021) applies the Transformer to image classification:

```python
class VisionTransformer(nn.Module):
    def __init__(self, img_size=224, patch_size=16, in_channels=3,
                 d_model=768, n_heads=12, n_layers=12, n_classes=1000):
        super().__init__()
        self.patch_size = patch_size
        n_patches = (img_size // patch_size) ** 2

        # Patch embedding: split image into patches and project
        self.patch_embed = nn.Conv2d(in_channels, d_model,
                                     kernel_size=patch_size, stride=patch_size)

        # Learnable [CLS] token and position embeddings
        self.cls_token = nn.Parameter(torch.zeros(1, 1, d_model))
        self.pos_embed = nn.Parameter(torch.zeros(1, n_patches + 1, d_model))

        # Transformer blocks
        self.blocks = nn.ModuleList([
            TransformerBlock(d_model, n_heads) for _ in range(n_layers)
        ])

        self.norm = nn.LayerNorm(d_model)
        self.head = nn.Linear(d_model, n_classes)

    def forward(self, x):
        B = x.size(0)
        # Patchify and flatten
        x = self.patch_embed(x).flatten(2).transpose(1, 2)  # (B, n_patches, d_model)

        # Prepend CLS token
        cls = self.cls_token.expand(B, -1, -1)
        x = torch.cat([cls, x], dim=1)
        x = x + self.pos_embed

        # Transformer blocks
        for block in self.blocks:
            x = block(x)

        # Classification from CLS token
        x = self.norm(x[:, 0])
        return self.head(x)
```

## Efficient Transformer Variants

| Method | Complexity | Key Idea | Reference |
|--------|-----------|----------|-----------|
| Standard attention | O(n^2) | Full pairwise attention | Vaswani et al., 2017 |
| Linear attention | O(n) | Kernel approximation of softmax | Katharopoulos et al., 2020 |
| Flash Attention | O(n^2) time, O(n) memory | IO-aware tiled computation | Dao et al., 2022 |
| Sparse attention | O(n sqrt(n)) | Fixed or learned sparse patterns | Child et al., 2019 |
| Sliding window | O(n * w) | Local attention window | Beltagy et al., 2020 (Longformer) |
| Multi-query attention | O(n^2) but faster | Shared K/V across heads | Shazeer, 2019 |
| Grouped-query attention | O(n^2) but faster | Groups of heads share K/V | Ainslie et al., 2023 |

## Model Scaling Laws

Kaplan et al. (2020) and Hoffmann et al. (2022, "Chinchilla") established scaling laws:

```
Performance (loss) scales as a power law with:
- Model parameters (N): L ~ N^(-0.076)
- Dataset size (D): L ~ D^(-0.095)
- Compute budget (C): L ~ C^(-0.050)

Chinchilla optimal scaling:
- For compute budget C, allocate equally to model size and data
- Optimal tokens ~ 20 * parameters
- Example: 70B parameter model needs ~1.4T training tokens
```

## Research Resources

| Resource | Description |
|----------|-------------|
| Hugging Face Transformers | Pre-trained models and fine-tuning framework |
| Papers With Code | Benchmarks, SOTA tracking, and code links |
| The Illustrated Transformer (Jay Alammar) | Visual explanations of attention |
| Andrej Karpathy's nanoGPT | Minimal GPT implementation for education |
| EleutherAI | Open-source LLM research community |
| MLCommons | Standardized ML benchmarks (MLPerf) |

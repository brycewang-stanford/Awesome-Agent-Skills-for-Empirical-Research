---
name: dl-transformer-finetune
description: "Build transformer fine-tuning plans for classification and generation"
metadata:
  openclaw:
    emoji: "🎯"
    category: "domains"
    subcategory: "ai-ml"
    keywords: ["transformer", "fine-tuning", "BERT", "LoRA", "PEFT", "transfer learning", "NLP"]
    source: "https://github.com/huggingface/peft"
---

# Transformer Fine-Tuning Guide

## Overview

Fine-tuning pretrained transformers is the dominant paradigm in modern NLP and increasingly in vision, audio, and multimodal research. The core idea is simple: take a model pretrained on massive data, then adapt it to your specific task with a comparatively small labeled dataset. But the practical details -- which layers to freeze, which optimizer and learning rate to use, how to handle catastrophic forgetting, when to use parameter-efficient methods -- determine whether fine-tuning succeeds or fails.

This guide covers the full spectrum of fine-tuning approaches: full fine-tuning for maximum performance, parameter-efficient fine-tuning (PEFT) for resource-constrained settings, and the decision framework for choosing between them. The patterns are drawn from hundreds of published papers and the Hugging Face ecosystem that supports them.

Whether you are fine-tuning BERT for text classification in a domain-specific corpus, adapting a large language model with LoRA for instruction following, or building a multi-task model for your research pipeline, this guide provides the recipes you need.

## Full Fine-Tuning

### Text Classification with BERT

```python
from transformers import (
    AutoModelForSequenceClassification,
    AutoTokenizer,
    TrainingArguments,
    Trainer,
)
from datasets import load_dataset
import numpy as np
from sklearn.metrics import accuracy_score, f1_score

# Load model and tokenizer
model_name = "bert-base-uncased"
tokenizer = AutoTokenizer.from_pretrained(model_name)
model = AutoModelForSequenceClassification.from_pretrained(
    model_name, num_labels=3
)

# Prepare dataset
dataset = load_dataset("multi_nli")

def tokenize_function(examples):
    return tokenizer(
        examples["premise"],
        examples["hypothesis"],
        truncation=True,
        max_length=128,
        padding="max_length",
    )

tokenized = dataset.map(tokenize_function, batched=True)

# Metrics
def compute_metrics(eval_pred):
    logits, labels = eval_pred
    preds = np.argmax(logits, axis=-1)
    return {
        "accuracy": accuracy_score(labels, preds),
        "f1_macro": f1_score(labels, preds, average="macro"),
    }

# Training arguments (research-grade defaults)
training_args = TrainingArguments(
    output_dir="./results",
    num_train_epochs=3,
    per_device_train_batch_size=32,
    per_device_eval_batch_size=64,
    learning_rate=2e-5,                  # Standard for BERT fine-tuning
    weight_decay=0.01,
    warmup_ratio=0.06,                   # 6% warmup
    evaluation_strategy="epoch",
    save_strategy="epoch",
    load_best_model_at_end=True,
    metric_for_best_model="f1_macro",
    fp16=True,
    dataloader_num_workers=4,
    seed=42,
    report_to="wandb",
)

trainer = Trainer(
    model=model,
    args=training_args,
    train_dataset=tokenized["train"],
    eval_dataset=tokenized["validation_matched"],
    compute_metrics=compute_metrics,
)

trainer.train()
```

### Learning Rate Selection Guide

| Model Size | Recommended LR | Warmup | Weight Decay |
|-----------|----------------|--------|--------------|
| BERT-base (110M) | 2e-5 to 5e-5 | 6-10% | 0.01 |
| BERT-large (340M) | 1e-5 to 3e-5 | 6-10% | 0.01 |
| RoBERTa-large (355M) | 1e-5 to 2e-5 | 6% | 0.01 |
| T5-base (220M) | 3e-4 to 1e-3 | 0-5% | 0.01 |
| LLaMA-7B (full FT) | 1e-5 to 2e-5 | 3% | 0.0 |
| LLaMA-7B (LoRA) | 1e-4 to 3e-4 | 3% | 0.0 |

## Parameter-Efficient Fine-Tuning (PEFT)

### LoRA (Low-Rank Adaptation)

LoRA freezes the pretrained weights and injects trainable low-rank decomposition matrices. It typically trains only 0.1-1% of parameters while achieving 95-100% of full fine-tuning performance.

```python
from peft import LoraConfig, get_peft_model, TaskType
from transformers import AutoModelForCausalLM, AutoTokenizer

# Load base model
model = AutoModelForCausalLM.from_pretrained(
    "meta-llama/Llama-2-7b-hf",
    torch_dtype=torch.bfloat16,
    device_map="auto",
)

# Configure LoRA
lora_config = LoraConfig(
    task_type=TaskType.CAUSAL_LM,
    r=16,                          # Rank (8-64 typical)
    lora_alpha=32,                 # Scaling factor (usually 2*r)
    lora_dropout=0.05,
    target_modules=["q_proj", "v_proj", "k_proj", "o_proj"],
    bias="none",
)

model = get_peft_model(model, lora_config)
model.print_trainable_parameters()
# Output: trainable params: 4,194,304 || all params: 6,742,609,920 || trainable%: 0.062
```

### QLoRA (Quantized LoRA)

```python
from transformers import BitsAndBytesConfig

# 4-bit quantization config
bnb_config = BitsAndBytesConfig(
    load_in_4bit=True,
    bnb_4bit_quant_type="nf4",
    bnb_4bit_compute_dtype=torch.bfloat16,
    bnb_4bit_use_double_quant=True,
)

model = AutoModelForCausalLM.from_pretrained(
    "meta-llama/Llama-2-7b-hf",
    quantization_config=bnb_config,
    device_map="auto",
)

# Apply LoRA on top of quantized model
model = get_peft_model(model, lora_config)
# Now fits on a single 24GB GPU!
```

## PEFT Method Comparison

| Method | Trainable % | Memory | Performance | Best For |
|--------|------------|--------|-------------|----------|
| Full fine-tuning | 100% | High | Best | Sufficient compute + data |
| LoRA | 0.1-1% | Low | 95-100% | Most scenarios |
| QLoRA | 0.1-1% | Very low | 93-98% | Consumer GPUs |
| Prefix tuning | ~0.1% | Low | 90-95% | Generation tasks |
| Adapter layers | 1-5% | Medium | 95-99% | Multi-task |
| Prompt tuning | <0.01% | Minimal | 85-95% | Large models, many tasks |

## Avoiding Catastrophic Forgetting

```python
# Strategy 1: Gradual unfreezing (Howard & Ruder, 2018)
def gradual_unfreeze(model, epoch, total_layers=12):
    """Unfreeze one more layer group per epoch, from top to bottom."""
    layers_to_unfreeze = min(epoch + 1, total_layers)
    for i, (name, param) in enumerate(reversed(list(model.named_parameters()))):
        param.requires_grad = i < layers_to_unfreeze * 10  # ~10 params per layer

# Strategy 2: Discriminative learning rates
def get_layer_lrs(model, base_lr=2e-5, decay_factor=0.95):
    """Apply lower learning rates to earlier layers."""
    params = []
    num_layers = 12  # BERT-base
    for i in range(num_layers):
        lr = base_lr * (decay_factor ** (num_layers - i - 1))
        layer_params = [p for n, p in model.named_parameters()
                       if f"layer.{i}." in n]
        params.append({"params": layer_params, "lr": lr})
    return params

# Strategy 3: EWC (Elastic Weight Consolidation)
# Add a penalty term that keeps important weights close to pretrained values
```

## Fine-Tuning Checklist for Papers

```
Before fine-tuning:
[ ] Report exact pretrained model name and version
[ ] Document dataset size, splits, and preprocessing
[ ] Specify hardware (GPU model, count, precision)
[ ] Set random seeds (Python, NumPy, PyTorch, CUDA)

During fine-tuning:
[ ] Use validation set for hyperparameter selection
[ ] Log training curves (loss, metrics per epoch)
[ ] Monitor for overfitting (val loss divergence)
[ ] Try at least 3 learning rates from the recommended range

Reporting:
[ ] Report mean and std across 3-5 random seeds
[ ] Include training time and compute cost
[ ] Compare against published baselines using same evaluation
[ ] Release model weights or LoRA adapters for reproducibility
```

## Best Practices

- **Start with the recommended learning rate** for your model size, then sweep 3-5 values.
- **Use LoRA first** unless you have strong evidence that full fine-tuning is needed.
- **Always evaluate on a held-out test set** that was not used for any hyperparameter decisions.
- **Freeze embeddings** when fine-tuning for classification -- they rarely need updating.
- **Use gradient accumulation** to simulate larger batch sizes on limited hardware.
- **Save the tokenizer alongside the model** to ensure reproducibility.

## References

- [LoRA paper](https://arxiv.org/abs/2106.09685) -- Hu et al., 2021
- [QLoRA paper](https://arxiv.org/abs/2305.14314) -- Dettmers et al., 2023
- [PEFT library](https://github.com/huggingface/peft) -- Hugging Face parameter-efficient fine-tuning
- [ULMFiT](https://arxiv.org/abs/1801.06146) -- Howard & Ruder, 2018 (gradual unfreezing, discriminative LR)
- [Hugging Face Transformers Trainer](https://huggingface.co/docs/transformers/main_classes/trainer) -- Training API documentation

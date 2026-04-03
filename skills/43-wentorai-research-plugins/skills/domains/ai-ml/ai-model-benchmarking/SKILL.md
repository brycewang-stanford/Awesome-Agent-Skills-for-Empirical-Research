---
name: ai-model-benchmarking
description: "Benchmark AI models across 60+ academic evaluation suites and metrics"
metadata:
  openclaw:
    emoji: "📊"
    category: "domains"
    subcategory: "ai-ml"
    keywords: ["benchmarking", "evaluation", "LLM", "MMLU", "leaderboard", "metrics", "lm-eval"]
    source: "https://github.com/EleutherAI/lm-evaluation-harness"
---

# AI Model Benchmarking Guide

## Overview

Rigorous evaluation is the backbone of machine learning research. A model is only as credible as its evaluation protocol: which benchmarks were used, how metrics were computed, whether results are reproducible, and how they compare to baselines. The proliferation of LLMs has made this both more important and more complex, with over 60 established benchmarks and a rapidly evolving landscape.

This guide covers the practical side of model benchmarking: how to use the EleutherAI Language Model Evaluation Harness (lm-evaluation-harness), how to select benchmarks for different research claims, how to avoid common evaluation pitfalls, and how to present results for publication. The focus is on academic rigor rather than leaderboard chasing.

Whether you are evaluating a fine-tuned model for a paper, comparing architectures for an ablation study, or reviewing a submitted manuscript's evaluation section, these patterns will help ensure the evaluation is sound.

## The lm-evaluation-harness

The EleutherAI lm-evaluation-harness is the de facto standard for LLM evaluation in academic research, supporting 60+ tasks and used by most major LLM papers.

### Installation and Basic Usage

```bash
# Install
pip install lm-eval

# Run a single benchmark
lm_eval --model hf \
    --model_args pretrained=meta-llama/Llama-2-7b-hf \
    --tasks mmlu \
    --batch_size auto \
    --output_path results/llama2-7b/

# Run multiple benchmarks
lm_eval --model hf \
    --model_args pretrained=meta-llama/Llama-2-7b-hf \
    --tasks mmlu,hellaswag,arc_challenge,winogrande,truthfulqa_mc2 \
    --batch_size auto \
    --num_fewshot 5 \
    --output_path results/llama2-7b/
```

### Programmatic API

```python
import lm_eval

results = lm_eval.simple_evaluate(
    model="hf",
    model_args="pretrained=meta-llama/Llama-2-7b-hf",
    tasks=["mmlu", "hellaswag", "arc_challenge"],
    num_fewshot=5,
    batch_size="auto",
    device="cuda",
)

# Access results
for task, metrics in results["results"].items():
    print(f"{task}: {metrics}")
```

## Benchmark Selection by Research Claim

| Research Claim | Required Benchmarks | Why |
|---------------|--------------------|----|
| General knowledge | MMLU, ARC, TriviaQA | Broad factual coverage |
| Reasoning | GSM8K, BBH, ARC-Challenge | Multi-step logical reasoning |
| Coding | HumanEval, MBPP, DS-1000 | Code generation and understanding |
| Instruction following | MT-Bench, AlpacaEval, IFEval | Open-ended instruction quality |
| Safety | TruthfulQA, ToxiGen, BBQ | Truthfulness, toxicity, bias |
| Multilingual | MGSM, XWinograd, FLORES | Cross-lingual transfer |
| Long context | SCROLLS, LongBench, RULER | Long document understanding |
| Domain-specific | MedQA, LegalBench, SciQ | Professional domain knowledge |

## Core Benchmarks Deep Dive

### MMLU (Massive Multitask Language Understanding)

```
- 57 subjects: STEM, humanities, social sciences, professional
- 14,042 questions, multiple choice (4 options)
- Standard: 5-shot evaluation
- Metric: Accuracy (macro-averaged across subjects)
- Citation: Hendrycks et al., 2021

Score interpretation:
  < 30%: Below random (model is miscalibrated)
  30-40%: Near random (4 choices = 25% baseline)
  40-60%: Basic knowledge
  60-70%: Strong general knowledge
  70-80%: Expert-level for most subjects
  > 80%: State-of-the-art (as of 2024)
```

### GSM8K (Grade School Math)

```
- 8,792 grade school math word problems
- Requires multi-step arithmetic reasoning
- Standard: 8-shot chain-of-thought
- Metric: Exact match on final numerical answer
- Citation: Cobbe et al., 2021

Common pitfalls:
  - Regex matching for final answer extraction
  - Calculator use vs. pure model computation
  - Reporting with vs. without chain-of-thought
```

### HumanEval (Code Generation)

```
- 164 Python programming problems
- Function signature + docstring -> implementation
- Metric: pass@k (k=1 standard, k=10 and k=100 also reported)
- Citation: Chen et al., 2021

pass@k computation (unbiased estimator):
  pass@k = 1 - C(n-c, k) / C(n, k)
  where n = total samples, c = correct samples
```

## Evaluation Pitfalls

| Pitfall | Problem | Solution |
|---------|---------|----------|
| Data contamination | Benchmark data in training set | Use canary strings, report contamination analysis |
| Prompt sensitivity | Results vary with prompt format | Report results across 3+ prompt variants |
| Few-shot selection | Cherry-picked examples boost scores | Use fixed random seed for example selection |
| Metric gaming | Optimizing for specific metrics | Report multiple metrics, include calibration |
| Incomplete reporting | Only showing best results | Report mean and std across seeds |
| Version mismatch | Different benchmark versions | Pin exact dataset version and commit hash |

### Contamination Detection

```python
def check_contamination(training_data: list, benchmark_data: list, n: int = 13) -> dict:
    """
    Check for n-gram overlap between training data and benchmark.
    13-gram overlap is the standard threshold (GPT-4 technical report).
    """
    from collections import defaultdict

    def extract_ngrams(text, n):
        words = text.lower().split()
        return set(tuple(words[i:i+n]) for i in range(len(words) - n + 1))

    # Build training n-gram index
    train_ngrams = set()
    for text in training_data:
        train_ngrams.update(extract_ngrams(text, n))

    # Check benchmark items
    contaminated = []
    for i, item in enumerate(benchmark_data):
        item_ngrams = extract_ngrams(item, n)
        overlap = item_ngrams & train_ngrams
        if overlap:
            contaminated.append({
                "index": i,
                "overlap_count": len(overlap),
                "overlap_ratio": len(overlap) / max(len(item_ngrams), 1),
            })

    return {
        "total_items": len(benchmark_data),
        "contaminated_items": len(contaminated),
        "contamination_rate": len(contaminated) / len(benchmark_data),
        "details": contaminated,
    }
```

## Reporting Results for Publication

### Standard Results Table Format

```markdown
| Model | Params | MMLU | GSM8K | HumanEval | ARC-C | HellaSwag | Avg |
|-------|--------|------|-------|-----------|-------|-----------|-----|
| Baseline | 7B | 45.2 | 12.3 | 15.8 | 42.1 | 72.3 | 37.5 |
| Ours | 7B | 52.1 (+6.9) | 28.7 (+16.4) | 22.0 (+6.2) | 48.9 (+6.8) | 76.1 (+3.8) | 45.6 |
| Ours (ablation A) | 7B | 49.8 | 24.1 | 19.5 | 46.2 | 74.8 | 42.9 |

All results: 5-shot for MMLU, 8-shot CoT for GSM8K, 0-shot for HumanEval,
25-shot for ARC-C, 10-shot for HellaSwag. Mean of 3 seeds reported.
```

## Best Practices

- **Always report the exact evaluation framework version** (e.g., `lm-eval v0.4.2`).
- **Use the same number of few-shot examples** as the original benchmark paper.
- **Report standard deviations** across at least 3 random seeds.
- **Include a contamination analysis** for any new model trained on web data.
- **Compare against published numbers using the same evaluation code** -- do not mix results from different frameworks.
- **Report inference details:** precision (fp16/bf16/int8), context length, decoding strategy.

## References

- [lm-evaluation-harness](https://github.com/EleutherAI/lm-evaluation-harness) -- EleutherAI's evaluation framework (12,000+ stars)
- [Open LLM Leaderboard](https://huggingface.co/spaces/HuggingFaceH4/open_llm_leaderboard) -- Hugging Face community leaderboard
- [MMLU paper](https://arxiv.org/abs/2009.03300) -- Hendrycks et al., 2021
- [Holistic Evaluation of Language Models (HELM)](https://crfm.stanford.edu/helm/) -- Stanford CRFM
- [Chatbot Arena](https://chat.lmsys.org/) -- Human preference-based evaluation (LMSYS)

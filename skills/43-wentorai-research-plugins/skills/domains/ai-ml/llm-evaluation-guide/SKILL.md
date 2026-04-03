---
name: llm-evaluation-guide
description: "Evaluate and benchmark large language models for research applications"
metadata:
  openclaw:
    emoji: "🧠"
    category: "domains"
    subcategory: "ai-ml"
    keywords: ["LLM evaluation", "benchmarking", "language models", "model evaluation", "NLP metrics", "BLEU", "perplexity"]
    source: "wentor-research-plugins"
---

# LLM Evaluation Guide

A skill for evaluating and benchmarking large language models (LLMs) in research settings. Covers automatic metrics, human evaluation protocols, benchmark suites, evaluation pitfalls, and best practices for reporting LLM performance.

## Evaluation Taxonomy

### Types of Evaluation

```
1. Intrinsic evaluation:
   Measures model quality on its own terms
   - Perplexity, likelihood, calibration
   - Useful for comparing architectures and training procedures

2. Extrinsic evaluation:
   Measures model quality on downstream tasks
   - Task-specific benchmarks (QA, summarization, classification)
   - Closer to real-world usefulness

3. Human evaluation:
   Human judges rate model outputs
   - Fluency, correctness, helpfulness, safety
   - Gold standard but expensive and slow
```

## Automatic Metrics

### Common Metrics by Task

| Task | Metric | Description |
|------|--------|-------------|
| Language modeling | Perplexity | Lower is better; measures prediction quality |
| Machine translation | BLEU, COMET | N-gram overlap; learned quality estimation |
| Summarization | ROUGE-1/2/L | Recall of n-grams against reference |
| Question answering | Exact Match, F1 | Token-level match against reference answer |
| Classification | Accuracy, F1 | Standard classification metrics |
| Generation quality | BERTScore | Semantic similarity via embeddings |
| Factuality | FActScore | Proportion of atomic facts supported by evidence |

### Computing Key Metrics

```python
from collections import Counter
import math


def compute_bleu(reference: list[str], hypothesis: list[str],
                 max_n: int = 4) -> float:
    """
    Compute corpus-level BLEU score (simplified).

    Args:
        reference: List of reference token sequences
        hypothesis: List of hypothesis token sequences
        max_n: Maximum n-gram order
    """
    precisions = []

    for n in range(1, max_n + 1):
        num = 0
        den = 0
        for ref_tokens, hyp_tokens in zip(reference, hypothesis):
            ref_ngrams = Counter(
                tuple(ref_tokens[i:i+n]) for i in range(len(ref_tokens) - n + 1)
            )
            hyp_ngrams = Counter(
                tuple(hyp_tokens[i:i+n]) for i in range(len(hyp_tokens) - n + 1)
            )
            clipped = {ng: min(c, ref_ngrams.get(ng, 0))
                       for ng, c in hyp_ngrams.items()}
            num += sum(clipped.values())
            den += max(sum(hyp_ngrams.values()), 1)

        precisions.append(num / max(den, 1))

    # Brevity penalty
    ref_len = sum(len(r) for r in reference)
    hyp_len = sum(len(h) for h in hypothesis)
    bp = math.exp(1 - ref_len / max(hyp_len, 1)) if hyp_len < ref_len else 1.0

    # Geometric mean of precisions
    log_avg = sum(math.log(max(p, 1e-10)) for p in precisions) / max_n
    return bp * math.exp(log_avg)
```

## Benchmark Suites

### Major LLM Benchmarks

```
General knowledge and reasoning:
  - MMLU (Massive Multitask Language Understanding): 57 subjects, MCQ
  - HellaSwag: Commonsense sentence completion
  - ARC (AI2 Reasoning Challenge): Science questions
  - WinoGrande: Coreference resolution / commonsense

Coding:
  - HumanEval: Python function completion (pass@k)
  - MBPP: Mostly basic Python problems
  - SWE-bench: Real-world software engineering tasks

Math:
  - GSM8K: Grade school math word problems
  - MATH: Competition-level mathematics

Safety and alignment:
  - TruthfulQA: Resistance to common misconceptions
  - BBQ (Bias Benchmark for QA): Social bias in QA
  - RealToxicityPrompts: Tendency to generate toxic text

Instruction following:
  - MT-Bench: Multi-turn conversation quality (LLM-as-judge)
  - AlpacaEval: Instruction-following quality
  - Chatbot Arena: ELO-based human preference ranking
```

## Human Evaluation

### Designing a Human Evaluation Protocol

```python
def design_human_eval(task: str, n_annotators: int = 3,
                      n_examples: int = 200) -> dict:
    """
    Design a human evaluation protocol for LLM outputs.

    Args:
        task: The task being evaluated
        n_annotators: Number of independent annotators per example
        n_examples: Number of examples to evaluate
    """
    return {
        "task": task,
        "n_annotators": n_annotators,
        "n_examples": n_examples,
        "criteria": [
            {"name": "Fluency", "scale": "1-5",
             "description": "Is the text grammatically correct and natural?"},
            {"name": "Relevance", "scale": "1-5",
             "description": "Does the output address the input/question?"},
            {"name": "Correctness", "scale": "1-5",
             "description": "Is the factual content accurate?"},
            {"name": "Helpfulness", "scale": "1-5",
             "description": "Would a user find this response useful?"}
        ],
        "agreement_metric": "Krippendorff's alpha (ordinal)",
        "presentation": "Randomize model order; blind annotators to model identity",
        "calibration": "Have all annotators rate 20 shared examples first",
        "cost_estimate": f"~{n_examples * n_annotators * 0.50:.0f} USD at typical rates"
    }
```

## Evaluation Pitfalls

### Common Mistakes

```
1. Data contamination:
   Test data may appear in the LLM's training set.
   Mitigation: Use held-out datasets, check for contamination,
   create new test sets.

2. Metric gaming:
   High BLEU does not mean high quality; ROUGE rewards verbosity.
   Mitigation: Use multiple metrics and human evaluation.

3. Cherry-picking examples:
   Showing only best-case outputs misrepresents model capabilities.
   Mitigation: Report aggregate metrics over full test sets.

4. Ignoring variance:
   LLM outputs vary with temperature and random seeds.
   Mitigation: Report mean and standard deviation over multiple runs.

5. Unfair comparisons:
   Comparing models with different prompt formats or few-shot counts.
   Mitigation: Standardize prompts and report all hyperparameters.
```

## Reporting Standards

When publishing LLM evaluation results, report: model name and version, parameter count and architecture, evaluation dataset with version number, exact prompts used (include in appendix), number of few-shot examples, decoding parameters (temperature, top-p, max tokens), multiple metrics (not just one), confidence intervals or significance tests, and hardware and inference cost where relevant.

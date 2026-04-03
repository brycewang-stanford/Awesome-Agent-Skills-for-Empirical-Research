---
name: code-llm-papers-guide
description: "Survey and paper collection on LLMs for code generation"
metadata:
  openclaw:
    emoji: "💻"
    category: "domains"
    subcategory: "cs"
    keywords: ["Code LLM", "code generation", "program synthesis", "Codex", "code intelligence", "software engineering"]
    source: "https://github.com/codefuse-ai/Awesome-Code-LLM"
---

# Code LLM Papers Guide

## Overview

This curated collection covers LLMs for code — from foundational models (Codex, CodeGen, StarCoder) through code generation, completion, repair, translation, and understanding. Accompanies a TMLR survey paper providing systematic categorization. Tracks 500+ papers across pre-training, fine-tuning, evaluation, and application of code-focused language models.

## Taxonomy

```
Code LLMs
├── Pre-training
│   ├── Encoder-only (CodeBERT, GraphCodeBERT)
│   ├── Decoder-only (Codex, CodeGen, StarCoder, DeepSeek-Coder)
│   └── Encoder-Decoder (CodeT5, PLBART)
├── Fine-tuning & Alignment
│   ├── Instruction tuning (WizardCoder, Magicoder)
│   ├── RLHF for code (CodeRL)
│   └── Self-play (AlphaCode)
├── Applications
│   ├── Code generation (NL → Code)
│   ├── Code completion (infilling)
│   ├── Code repair (bug fixing)
│   ├── Code translation (language conversion)
│   ├── Code summarization (Code → NL)
│   ├── Test generation
│   └── Code review
└── Evaluation
    ├── Benchmarks (HumanEval, MBPP, SWE-bench)
    ├── Metrics (pass@k, CodeBLEU)
    └── Security analysis
```

## Key Models Timeline

| Model | Year | Organization | Parameters | Key Innovation |
|-------|------|-------------|------------|----------------|
| **CodeBERT** | 2020 | Microsoft | 125M | Bimodal NL-PL pre-training |
| **Codex** | 2021 | OpenAI | 12B | GPT-3 fine-tuned on GitHub |
| **AlphaCode** | 2022 | DeepMind | 41B | Competitive programming |
| **StarCoder** | 2023 | BigCode | 15B | Fill-in-the-middle, 1T tokens |
| **CodeLlama** | 2023 | Meta | 34B | Llama 2 + code specialization |
| **DeepSeek-Coder** | 2024 | DeepSeek | 33B | 2T token project-level training |
| **Qwen2.5-Coder** | 2024 | Alibaba | 32B | 5.5T tokens, multi-language |

## Benchmark Tracking

```python
# Track model performance on HumanEval
humaneval_scores = {
    "GPT-4": {"pass_at_1": 67.0, "pass_at_10": 86.0},
    "Claude 3.5 Sonnet": {"pass_at_1": 64.0},
    "DeepSeek-Coder-33B": {"pass_at_1": 56.1},
    "CodeLlama-34B": {"pass_at_1": 48.8},
    "StarCoder2-15B": {"pass_at_1": 46.3},
    "GPT-3.5-Turbo": {"pass_at_1": 48.1},
}

print(f"{'Model':<25} {'pass@1':>8} {'pass@10':>8}")
print("-" * 43)
for model, scores in sorted(
    humaneval_scores.items(),
    key=lambda x: x[1].get("pass_at_1", 0),
    reverse=True,
):
    p1 = scores.get("pass_at_1", "—")
    p10 = scores.get("pass_at_10", "—")
    print(f"{model:<25} {str(p1):>8} {str(p10):>8}")
```

## Research Directions

```markdown
### Active Areas (2024-2025)
1. **Repository-level generation** — Understanding full codebases
2. **Agentic coding** — LLMs using tools (debugger, terminal)
3. **Formal verification** — Proving correctness of generated code
4. **Multi-language** — Cross-language transfer and translation
5. **Security** — Detecting and avoiding vulnerable code
6. **Long context** — Processing large codebases (100k+ tokens)
7. **Code editing** — Natural language instructions for code changes
```

## Paper Search

```python
import arxiv

def find_code_llm_papers(topic="code generation", max_results=20):
    """Find recent Code LLM papers on arXiv."""
    query = f"abs:{topic} AND (abs:large language model OR abs:LLM)"

    search = arxiv.Search(
        query=query,
        max_results=max_results,
        sort_by=arxiv.SortCriterion.SubmittedDate,
    )

    for result in search.results():
        print(f"[{result.published.strftime('%Y-%m-%d')}] "
              f"{result.title}")

find_code_llm_papers("code generation")
find_code_llm_papers("automated program repair")
```

## Use Cases

1. **Literature survey**: Map the Code LLM research landscape
2. **Model selection**: Compare code models for specific tasks
3. **Benchmark analysis**: Track state-of-the-art on standard benchmarks
4. **Research planning**: Identify open problems and trends
5. **Course material**: Teach software engineering + AI intersection

## References

- [Awesome-Code-LLM](https://github.com/codefuse-ai/Awesome-Code-LLM)
- [TMLR Survey Paper](https://arxiv.org/abs/2311.07989)
- [HumanEval](https://github.com/openai/human-eval)
- [SWE-bench](https://www.swebench.com/)

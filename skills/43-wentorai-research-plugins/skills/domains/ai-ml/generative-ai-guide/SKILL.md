---
name: generative-ai-guide
description: "Curated guide to generative AI covering LLMs and diffusion models"
version: 1.0.0
author: wentor-community
source: https://github.com/aishwaryanr/awesome-generative-ai-guide
metadata:
  openclaw:
    category: "domains"
    subcategory: "ai-ml"
    emoji: "🤖"
    keywords:
      - generative-ai
      - large-language-models
      - diffusion-models
      - transformers
      - prompt-engineering
      - ai-research
---

# Generative AI Guide

A skill providing a comprehensive, curated guide to generative AI research and practice, covering large language models (LLMs), diffusion models, transformer architectures, prompt engineering, and evaluation methodologies. Based on the awesome-generative-ai-guide repository (25K stars), this skill equips researchers with structured knowledge of the rapidly evolving generative AI landscape.

## Overview

Generative AI has become one of the most active areas of research across computer science, with implications spanning natural language processing, computer vision, audio synthesis, code generation, scientific discovery, and creative applications. The pace of development makes it challenging for researchers to maintain a current understanding of the field. This skill provides a structured map of the generative AI landscape, organized by topic and application area, with guidance on key papers, methods, and practical considerations.

Whether you are an AI researcher staying current with the field, a domain scientist exploring how generative AI can accelerate your work, or a student entering the field, this skill provides the orientation and resources needed to navigate the space effectively.

## Large Language Models

**Architecture Foundations**
- Transformer architecture: self-attention mechanism, positional encoding, layer normalization
- Scaling laws: the relationship between model size, data, compute, and performance
- Training objectives: causal language modeling, masked language modeling, instruction tuning
- Context windows: evolution from 512 tokens to 100K+ tokens and associated techniques
- Mixture of Experts (MoE): sparse activation for efficient scaling

**Key Model Families**
- GPT series (OpenAI): decoder-only architecture, scaling-driven approach
- Claude series (Anthropic): emphasis on safety, instruction following, and long context
- Llama series (Meta): open-weight models enabling community research
- Gemini series (Google): multimodal from the ground up
- Open-source ecosystem: Mistral, Qwen, DeepSeek, and community fine-tunes

**Training Pipeline**
- Pre-training: large-scale unsupervised learning on web-scale text corpora
- Supervised fine-tuning (SFT): training on high-quality instruction-response pairs
- Reinforcement learning from human feedback (RLHF): aligning outputs with human preferences
- Direct preference optimization (DPO): simplified alignment without reward models
- Constitutional AI: self-improvement using principle-based critique

**Inference Optimization**
- Quantization: reducing model precision (FP16, INT8, INT4) for faster inference
- KV-cache optimization: efficient memory management for long sequences
- Speculative decoding: using small models to draft and large models to verify
- Batching strategies: continuous batching for throughput optimization
- Serving frameworks: vLLM, TGI, and other high-performance inference engines

## Diffusion Models

**Core Concepts**
- Forward process: gradually adding noise to data until reaching pure noise
- Reverse process: learning to denoise step by step to generate new data
- Score matching: estimating the gradient of the data distribution
- Classifier-free guidance: controlling generation fidelity and diversity
- Latent diffusion: operating in compressed latent space for efficiency

**Key Architectures**
- DDPM (Denoising Diffusion Probabilistic Models): foundational formulation
- Stable Diffusion: latent space diffusion with text conditioning
- DALL-E series: text-to-image generation with CLIP-based conditioning
- Imagen: text-to-image with cascaded diffusion models
- Video diffusion models: extending to temporal generation

**Applications in Research**
- Molecular generation: designing new drug candidates and materials
- Protein structure prediction: generating plausible protein conformations
- Scientific data augmentation: creating synthetic training data
- Image restoration: denoising, super-resolution, inpainting for microscopy
- Simulation acceleration: approximating expensive physical simulations

## Prompt Engineering

**Fundamental Techniques**
- Zero-shot prompting: direct instruction without examples
- Few-shot prompting: providing examples to establish the desired pattern
- Chain-of-thought (CoT): requesting step-by-step reasoning
- Self-consistency: sampling multiple reasoning chains and selecting the majority
- Tree of thought: exploring multiple reasoning branches systematically

**Advanced Strategies**
- ReAct (Reasoning + Acting): interleaving reasoning with tool use
- Retrieval-augmented generation (RAG): grounding responses in retrieved documents
- Program-aided language models: generating and executing code for precise computation
- Structured output: constraining generation to valid JSON, XML, or other formats
- Multi-agent prompting: orchestrating multiple LLM instances for complex tasks

**Research-Specific Prompting**
- Literature synthesis: prompting for balanced integration of multiple sources
- Hypothesis generation: structured prompts for creative scientific reasoning
- Code debugging: providing error context and asking for systematic diagnosis
- Data analysis: chaining prompts through exploratory analysis to interpretation
- Writing assistance: iterative refinement prompts that preserve the author's voice

## Evaluation and Benchmarks

**Language Model Evaluation**
- Perplexity: intrinsic measure of model quality on held-out text
- MMLU: massive multi-task language understanding across 57 subjects
- HumanEval: code generation benchmark with function completion tasks
- MT-Bench: multi-turn conversation quality assessment
- Arena Elo: head-to-head comparison ratings from human preferences

**Generation Quality Metrics**
- FID (Frechet Inception Distance): image generation quality and diversity
- CLIP score: text-image alignment for conditional generation
- BLEU, ROUGE: text generation overlap metrics (limited but widely used)
- Human evaluation: gold standard requiring careful protocol design
- Calibration: measuring whether model confidence matches actual accuracy

**Safety and Alignment Evaluation**
- Red-teaming: adversarial testing for harmful outputs
- Bias benchmarks: measuring demographic and cultural biases
- Hallucination detection: identifying fabricated facts in generated text
- Instruction following: measuring compliance with complex multi-step instructions
- Robustness testing: evaluating consistency under paraphrased inputs

## Integration with Research-Claw

This skill provides the Research-Claw agent with generative AI domain expertise:

- Help researchers understand and apply generative AI techniques to their domain
- Guide model selection based on task requirements and resource constraints
- Assist with prompt engineering for research-specific applications
- Connect with analysis skills for evaluating generative model outputs
- Support writing skills with knowledge of the latest developments for literature reviews

## Best Practices

- Stay current by monitoring key conferences (NeurIPS, ICML, ICLR, ACL, CVPR) and arXiv
- Distinguish between benchmark performance and real-world applicability
- Consider computational costs and environmental impact when selecting models
- Evaluate models on your specific task rather than relying solely on leaderboard rankings
- Document prompt strategies and model versions for reproducibility
- Be aware of the limitations: hallucination, bias, and sensitivity to prompt phrasing

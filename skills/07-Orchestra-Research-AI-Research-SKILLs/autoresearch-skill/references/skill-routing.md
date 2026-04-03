<!--
  ╔══════════════════════════════════════════════════════════════╗
  ║  本文件为开源 Skill 原始文档，收录仅供学习与研究参考        ║
  ║  CoPaper.AI 收集整理 | https://copaper.ai                  ║
  ╚══════════════════════════════════════════════════════════════╝

  来源仓库: https://github.com/Orchestra-Research/AI-Research-SKILLs
  项目名称: AI-Research-SKILLs
  开源协议: Apache License 2.0
  收录日期: 2026-04-02

  声明: 本文件版权归原作者所有。此处收录旨在为社会科学实证研究者
  提供 AI Agent Skills 的集中参考。如有侵权，请联系删除。
-->

# Skill Routing: When to Use Which Domain Skill

The autoresearch skill orchestrates — domain skills execute. This reference maps research activities to the skills library.

## Routing Principle

When you encounter a domain-specific task during research, search the skills library for the right tool. Read the SKILL.md of the relevant skill before starting — it contains workflows, common issues, and production-ready code examples.

## Complete Routing Map

### Data and Preprocessing

| Task | Skill | Location |
|---|---|---|
| Large-scale data processing | Ray Data | `05-data-processing/ray-data/` |
| Data curation and filtering | NeMo Curator | `05-data-processing/nemo-curator/` |
| Custom tokenizer training | HuggingFace Tokenizers | `02-tokenization/hf-tokenizers/` |
| Subword tokenization | SentencePiece | `02-tokenization/sentencepiece/` |

### Model Architecture and Training

| Task | Skill | Location |
|---|---|---|
| Large-scale pretraining | Megatron-Core | `01-model-architecture/megatron-core/` |
| Lightweight LLM training | LitGPT | `01-model-architecture/litgpt/` |
| State-space models | Mamba | `01-model-architecture/mamba/` |
| Linear attention models | RWKV | `01-model-architecture/rwkv/` |
| Small-scale pretraining | NanoGPT | `01-model-architecture/nanogpt/` |

### Fine-tuning

| Task | Skill | Location |
|---|---|---|
| Multi-method fine-tuning | Axolotl | `03-fine-tuning/axolotl/` |
| Template-based fine-tuning | LLaMA-Factory | `03-fine-tuning/llama-factory/` |
| Fast LoRA fine-tuning | Unsloth | `03-fine-tuning/unsloth/` |
| PyTorch-native fine-tuning | Torchtune | `03-fine-tuning/torchtune/` |

### Post-training (RL / Alignment)

| Task | Skill | Location |
|---|---|---|
| PPO, DPO, SFT pipelines | TRL | `06-post-training/trl/` |
| Group Relative Policy Optimization | GRPO | `06-post-training/grpo-rl-training/` |
| Scalable RLHF | OpenRLHF | `06-post-training/openrlhf/` |
| Reference-free alignment | SimPO | `06-post-training/simpo/` |

### Interpretability

| Task | Skill | Location |
|---|---|---|
| Transformer circuit analysis | TransformerLens | `04-mechanistic-interpretability/transformerlens/` |
| Sparse autoencoder training | SAELens | `04-mechanistic-interpretability/saelens/` |
| Intervention experiments | NNsight | `04-mechanistic-interpretability/nnsight/` |
| Causal tracing | Pyvene | `04-mechanistic-interpretability/pyvene/` |

### Distributed Training

| Task | Skill | Location |
|---|---|---|
| ZeRO optimization | DeepSpeed | `08-distributed-training/deepspeed/` |
| Fully sharded data parallel | FSDP | `08-distributed-training/fsdp/` |
| Multi-GPU abstraction | Accelerate | `08-distributed-training/accelerate/` |
| Training framework | PyTorch Lightning | `08-distributed-training/pytorch-lightning/` |
| Distributed data + training | Ray Train | `08-distributed-training/ray-train/` |

### Evaluation

| Task | Skill | Location |
|---|---|---|
| Standard LLM benchmarks | lm-evaluation-harness | `11-evaluation/lm-eval-harness/` |
| NeMo-integrated evaluation | NeMo Evaluator | `11-evaluation/nemo-evaluator/` |
| Custom eval tasks | Inspect AI | `11-evaluation/inspect-ai/` |

### Inference and Serving

| Task | Skill | Location |
|---|---|---|
| High-throughput serving | vLLM | `12-inference-serving/vllm/` |
| NVIDIA-optimized inference | TensorRT-LLM | `12-inference-serving/tensorrt-llm/` |
| CPU / edge inference | llama.cpp | `12-inference-serving/llama-cpp/` |
| Structured generation serving | SGLang | `12-inference-serving/sglang/` |

### Experiment Tracking

| Task | Skill | Location |
|---|---|---|
| Full experiment tracking | Weights & Biases | `13-mlops/wandb/` |
| Open-source tracking | MLflow | `13-mlops/mlflow/` |
| Training visualization | TensorBoard | `13-mlops/tensorboard/` |

### Optimization Techniques

| Task | Skill | Location |
|---|---|---|
| Efficient attention | Flash Attention | `10-optimization/flash-attention/` |
| 4/8-bit quantization | bitsandbytes | `10-optimization/bitsandbytes/` |
| GPTQ quantization | GPTQ | `10-optimization/gptq/` |
| AWQ quantization | AWQ | `10-optimization/awq/` |
| GGUF format (llama.cpp) | GGUF | `10-optimization/gguf/` |
| PyTorch-native quantization | Quanto | `10-optimization/quanto/` |

### Safety and Alignment

| Task | Skill | Location |
|---|---|---|
| Constitutional AI training | Constitutional AI | `07-safety-alignment/constitutional-ai/` |
| Content safety classification | LlamaGuard | `07-safety-alignment/llamaguard/` |
| Guardrail pipelines | NeMo Guardrails | `07-safety-alignment/nemo-guardrails/` |
| Prompt injection detection | Prompt Guard | `07-safety-alignment/prompt-guard/` |

### Infrastructure

| Task | Skill | Location |
|---|---|---|
| Serverless GPU compute | Modal | `09-infrastructure/modal/` |
| Multi-cloud orchestration | SkyPilot | `09-infrastructure/skypilot/` |
| GPU cloud instances | Lambda Labs | `09-infrastructure/lambda-labs/` |

### Agents and RAG

| Task | Skill | Location |
|---|---|---|
| Agent pipelines | LangChain | `14-agents/langchain/` |
| Knowledge retrieval agents | LlamaIndex | `14-agents/llamaindex/` |
| Lightweight agents | Smolagents | `14-agents/smolagents/` |
| Claude-based agents | Claude Agent SDK | `14-agents/claude-agent-sdk/` |
| Vector store (local) | Chroma | `15-rag/chroma/` |
| Vector similarity search | FAISS | `15-rag/faiss/` |
| Text embeddings | Sentence Transformers | `15-rag/sentence-transformers/` |
| Managed vector DB | Pinecone | `15-rag/pinecone/` |
| Scalable vector DB | Milvus | `15-rag/milvus/` |

### Prompt Engineering and Structured Output

| Task | Skill | Location |
|---|---|---|
| Prompt optimization | DSPy | `16-prompt-engineering/dspy/` |
| Structured LLM output | Instructor | `16-prompt-engineering/instructor/` |
| Constrained generation | Guidance | `16-prompt-engineering/guidance/` |
| Grammar-based generation | Outlines | `16-prompt-engineering/outlines/` |

### Multimodal

| Task | Skill | Location |
|---|---|---|
| Vision-language models | CLIP | `18-multimodal/clip/` |
| Speech recognition | Whisper | `18-multimodal/whisper/` |
| Visual instruction tuning | LLaVA | `18-multimodal/llava/` |
| Vision-language (Qwen) | Qwen2-VL | `18-multimodal/qwen2-vl/` |
| Vision-language (Mistral) | Pixtral | `18-multimodal/pixtral/` |
| Visual understanding | Florence-2 | `18-multimodal/florence-2/` |
| Document retrieval | ColPali | `18-multimodal/colpali/` |

### Observability

| Task | Skill | Location |
|---|---|---|
| LLM tracing and debugging | LangSmith | `17-observability/langsmith/` |
| LLM observability platform | Phoenix | `17-observability/phoenix/` |

### Emerging Techniques

| Task | Skill | Location |
|---|---|---|
| Mixture of Experts training | MoE Training | `19-emerging-techniques/moe-training/` |
| Combining trained models | Model Merging | `19-emerging-techniques/model-merging/` |
| Extended context windows | Long Context | `19-emerging-techniques/long-context/` |
| Faster inference via drafting | Speculative Decoding | `19-emerging-techniques/speculative-decoding/` |
| Teacher-student compression | Knowledge Distillation | `19-emerging-techniques/knowledge-distillation/` |
| Reducing model size | Model Pruning | `19-emerging-techniques/model-pruning/` |

### Research Output

| Task | Skill | Location |
|---|---|---|
| Generate research ideas | Research Ideation | `21-research-ideation/` |
| Write publication-ready paper | ML Paper Writing | `20-ml-paper-writing/` |

## Common Research Workflows

### "I need to fine-tune a model and evaluate it"

1. Pick fine-tuning skill based on needs (Unsloth for speed, Axolotl for flexibility)
2. Use lm-evaluation-harness for standard benchmarks
3. Track with W&B or MLflow

### "I need to understand what the model learned"

1. Use TransformerLens for circuit-level analysis
2. Train SAEs with SAELens for feature-level understanding
3. Run interventions with NNsight or Pyvene

### "I need to do RL training"

1. Start with TRL for standard PPO/DPO
2. Use GRPO skill for DeepSeek-R1 style training
3. Scale with OpenRLHF if needed

### "I need to run experiments on cloud GPUs"

1. Modal for quick serverless runs
2. SkyPilot for multi-cloud optimization
3. Lambda Labs for dedicated instances

## Finding Skills

If you're not sure which skill to use:

```bash
# Search by keyword in skill names
ls */*/SKILL.md | head -20

# Search skill descriptions for a keyword
grep -l "keyword" */*/SKILL.md
```

Or search the repository's README.md which lists all skills with descriptions.

---
name: llm-aiops-guide
description: "Papers on LLMs for IT operations and AIOps research"
metadata:
  openclaw:
    emoji: "🖥️"
    category: "domains"
    subcategory: "cs"
    keywords: ["AIOps", "LLM operations", "IT automation", "log analysis", "incident management", "DevOps AI"]
    source: "https://github.com/Jun-jie-Huang/awesome-LLM-AIOps"
---

# LLM for AIOps Guide

## Overview

A curated collection of research on applying LLMs to IT Operations (AIOps) — log analysis, anomaly detection, incident management, root cause analysis, and automated remediation. Tracks how foundation models are transforming traditional rule-based operations tooling into intelligent, adaptive systems. Relevant for CS researchers at the intersection of systems, NLP, and operations.

## Research Areas

```
LLM for AIOps
├── Log Analysis
│   ├── Log parsing (template extraction)
│   ├── Anomaly detection (from log sequences)
│   ├── Log summarization
│   └── Root cause from logs
├── Incident Management
│   ├── Incident triage and routing
│   ├── Severity classification
│   ├── Similar incident retrieval
│   └── Resolution recommendation
├── Root Cause Analysis
│   ├── Topology-aware diagnosis
│   ├── Multi-signal correlation
│   └── Causal inference
├── Monitoring & Alerting
│   ├── Metric anomaly detection
│   ├── Alert correlation
│   ├── Noise reduction
│   └── Capacity planning
└── Automated Remediation
    ├── Runbook generation
    ├── Script generation
    ├── Self-healing systems
    └── Change impact analysis
```

## Key Papers

| Paper | Year | Focus |
|-------|------|-------|
| LogPPT | 2023 | Few-shot log parsing with prompt tuning |
| OpsEval | 2024 | Benchmark for evaluating LLMs in AIOps |
| D-Bot | 2024 | LLM-based database diagnosis |
| RCAgent | 2024 | Agent for root cause analysis |
| LogAgent | 2024 | Autonomous log analysis agent |

## Use Cases

1. **Literature tracking**: Follow LLM-AIOps research evolution
2. **System design**: Learn intelligent operations patterns
3. **Benchmark comparison**: Evaluate AIOps approaches
4. **Research planning**: Identify under-explored AIOps problems
5. **Industry applications**: Bridge research to production AIOps

## References

- [awesome-LLM-AIOps](https://github.com/Jun-jie-Huang/awesome-LLM-AIOps)
- [OpsEval Benchmark](https://arxiv.org/abs/2310.07637)

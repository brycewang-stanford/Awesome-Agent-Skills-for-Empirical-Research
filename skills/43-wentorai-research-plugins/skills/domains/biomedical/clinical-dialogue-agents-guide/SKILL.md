---
name: clinical-dialogue-agents-guide
description: "Papers on AI agents for clinical dialogue and medical QA"
metadata:
  openclaw:
    emoji: "🗣️"
    category: "domains"
    subcategory: "biomedical"
    keywords: ["clinical dialogue", "medical QA", "patient interaction", "clinical agents", "healthcare AI", "diagnosis"]
    source: "https://github.com/xqz614/Awesome-Agentic-Clinical-Dialogue"
---

# Agentic Clinical Dialogue Guide

## Overview

A curated collection of papers on AI agents for clinical dialogue — systems that conduct patient interviews, perform differential diagnosis, explain medical information, and support clinical decision-making through conversation. Covers medical QA benchmarks, patient simulation, clinical reasoning chains, and safety considerations unique to healthcare AI.

## Research Landscape

```
Agentic Clinical Dialogue
├── Patient-Facing Agents
│   ├── Symptom checkers
│   ├── Triage systems
│   ├── Health information
│   └── Follow-up management
├── Clinician-Facing Agents
│   ├── Diagnostic support
│   ├── Treatment recommendation
│   ├── Clinical documentation
│   └── Literature integration
├── Clinical Reasoning
│   ├── Differential diagnosis
│   ├── History taking
│   ├── Physical exam interpretation
│   └── Test ordering
├── Patient Simulation
│   ├── Standardized patients (SP)
│   ├── Medical education
│   └── Agent evaluation
└── Safety & Ethics
    ├── Hallucination in medicine
    ├── Bias in clinical AI
    ├── Liability frameworks
    └── Informed consent
```

## Key Systems

| System | Focus | Approach |
|--------|-------|----------|
| **AMIE** | Diagnostic dialogue | LLM with clinical reasoning |
| **Med-PaLM** | Medical QA | Finetuned on medical data |
| **ChatDoctor** | Patient consultation | LLaMA + medical knowledge |
| **AgentClinic** | Clinical evaluation | Simulated clinical encounters |
| **ClinicalAgent** | Decision support | Multi-step clinical reasoning |

## Benchmarks

```python
benchmarks = {
    "MedQA (USMLE)": {
        "task": "US Medical Licensing Exam questions",
        "size": "11,450 questions",
        "metric": "Accuracy",
    },
    "PubMedQA": {
        "task": "Biomedical yes/no/maybe QA",
        "size": "1,000 expert-labeled",
        "metric": "Accuracy",
    },
    "AgentClinic": {
        "task": "Simulated clinical encounters",
        "size": "Various patient scenarios",
        "metric": "Diagnostic accuracy + safety",
    },
    "MedMCQA": {
        "task": "Indian medical entrance MCQs",
        "size": "194k questions",
        "metric": "Accuracy",
    },
    "HealthSearchQA": {
        "task": "Consumer health search questions",
        "size": "3,375 questions",
        "metric": "Expert evaluation",
    },
}

for name, info in benchmarks.items():
    print(f"\n{name}:")
    print(f"  Task: {info['task']}")
    print(f"  Size: {info['size']}")
```

## Safety Considerations

```markdown
### Critical Safety Issues
1. **Hallucination** — Fabricated medical facts are dangerous
2. **Scope limitations** — AI must know when to defer to human
3. **Emergency recognition** — Must identify urgent situations
4. **Bias** — Demographic biases in training data
5. **Liability** — Legal framework for AI medical advice
6. **Privacy** — Patient data protection (HIPAA compliance)

### Safety Patterns
- Always recommend consulting healthcare providers
- Flag emergency symptoms immediately
- Disclose AI nature to patients
- Log all interactions for audit
- Implement uncertainty quantification
```

## Reading Roadmap

```markdown
### Foundations
1. AMIE: "Towards Conversational Diagnostic AI" (Google, 2024)
2. Med-PaLM 2: "Expert-level medical QA" (Google, 2023)
3. "Evaluating LLMs in Clinical Dialogue" (Survey, 2024)

### Clinical Reasoning
4. "Chain-of-Diagnosis" (Clinical CoT, 2024)
5. "AgentClinic: Evaluating Clinical Agents" (2024)
6. "Simulated Patient Encounters with LLMs" (2024)

### Safety
7. "Hallucination in Medical AI" (Survey, 2024)
8. "Red Teaming Medical LLMs" (2024)
```

## Use Cases

1. **Research survey**: Map clinical dialogue AI landscape
2. **Benchmark tracking**: Compare medical AI performance
3. **System design**: Learn from clinical agent architectures
4. **Safety analysis**: Understand risks and mitigations
5. **Medical education**: Patient simulation for training

## References

- [Awesome-Agentic-Clinical-Dialogue](https://github.com/xqz614/Awesome-Agentic-Clinical-Dialogue)
- [AMIE Paper](https://arxiv.org/abs/2401.05654)
- [AgentClinic](https://arxiv.org/abs/2405.07960)

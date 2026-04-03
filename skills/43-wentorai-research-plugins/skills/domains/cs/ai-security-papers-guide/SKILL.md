---
name: ai-security-papers-guide
description: "AI security papers from top-4 security conferences"
metadata:
  openclaw:
    emoji: "🛡️"
    category: "domains"
    subcategory: "cs"
    keywords: ["AI security", "adversarial ML", "model attacks", "S&P", "CCS", "USENIX", "NDSS"]
    source: "https://github.com/Zhou-Zi7/Awesome-AI-Security-BIG4"
---

# AI Security Papers Guide (BIG4 Venues)

## Overview

A curated collection of AI security papers from the top-4 security conferences: IEEE S&P, ACM CCS, USENIX Security, and NDSS. Covers adversarial attacks, model stealing, data poisoning, privacy attacks, deepfake detection, and LLM security. Organized by year and venue, focusing exclusively on peer-reviewed work from these prestigious venues.

## Venues

| Venue | Full Name | Focus |
|-------|-----------|-------|
| **S&P** | IEEE Symposium on Security and Privacy | Broad security + privacy |
| **CCS** | ACM Conference on Computer and Communications Security | Systems security |
| **USENIX** | USENIX Security Symposium | Systems + network security |
| **NDSS** | Network and Distributed System Security | Network security |

## Topic Categories

```
AI Security (BIG4)
├── Adversarial ML
│   ├── Evasion attacks (adversarial examples)
│   ├── Poisoning attacks (backdoors, trojans)
│   ├── Model stealing (extraction, distillation)
│   └── Defenses (certified robustness, detection)
├── Privacy Attacks
│   ├── Membership inference
│   ├── Model inversion
│   ├── Attribute inference
│   └── Training data extraction
├── LLM Security
│   ├── Prompt injection
│   ├── Jailbreaking
│   ├── Data leakage
│   └── Alignment attacks
├── Deepfakes
│   ├── Generation methods
│   ├── Detection techniques
│   └── Watermarking
└── Federated Learning Security
    ├── Byzantine attacks
    ├── Gradient leakage
    └── Secure aggregation
```

## Key Papers by Year

```python
# Recent highlights
papers_2024_2025 = [
    {"title": "Not What You've Signed Up For: "
              "Compromising Real-World LLM-Integrated Applications",
     "venue": "S&P 2024", "topic": "LLM security"},
    {"title": "Prompt Stealing Attacks Against "
              "Text-to-Image Generation Models",
     "venue": "S&P 2024", "topic": "Prompt extraction"},
    {"title": "Backdoor Attacks on Language Models",
     "venue": "CCS 2024", "topic": "NLP backdoors"},
    {"title": "Membership Inference in LLMs",
     "venue": "USENIX 2024", "topic": "Privacy"},
]

for p in papers_2024_2025:
    print(f"[{p['venue']}] {p['title']}")
    print(f"  Topic: {p['topic']}")
```

## Research Trends

```markdown
### Emerging Areas (2024-2025)
1. **LLM security** — Jailbreaking, prompt injection, agent attacks
2. **Supply chain attacks** — Poisoned models, malicious packages
3. **Multi-modal attacks** — Cross-modal adversarial examples
4. **Agent security** — Attacks on LLM-based autonomous systems
5. **Watermarking** — LLM output detection, IP protection
6. **Unlearning** — Machine unlearning verification and attacks
```

## Use Cases

1. **Security research**: Find state-of-the-art attack/defense methods
2. **Threat modeling**: Understand AI system vulnerabilities
3. **Literature review**: Systematic coverage of BIG4 AI security
4. **Course material**: Graduate-level AI security curriculum
5. **Red teaming**: Learn evaluation techniques for AI systems

## References

- [Awesome-AI-Security-BIG4](https://github.com/Zhou-Zi7/Awesome-AI-Security-BIG4)
- [IEEE S&P](https://www.ieee-security.org/TC/SP-Index.html)
- [ACM CCS](https://www.sigsac.org/ccs/)

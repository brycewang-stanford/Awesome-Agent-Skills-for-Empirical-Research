---
name: autonomous-agents-papers-guide
description: "Daily-updated collection of autonomous AI agent papers"
metadata:
  openclaw:
    emoji: "🤖"
    category: "domains"
    subcategory: "ai-ml"
    keywords: ["autonomous agents", "AI agents", "LLM agents", "agent papers", "planning", "tool use"]
    source: "https://github.com/tmgthb/Autonomous-Agents"
---

# Autonomous Agents Papers Guide

## Overview

A daily-updated collection of research papers on autonomous AI agents — systems that use LLMs for planning, reasoning, tool use, and multi-step task execution. Covers the full agent stack from foundational prompting techniques (ReAct, Chain-of-Thought) to multi-agent systems, memory architectures, and real-world deployments. Organized chronologically with category tags for easy navigation.

## Agent Taxonomy

```
Autonomous Agents
├── Planning & Reasoning
│   ├── Chain-of-Thought (CoT, ToT, GoT)
│   ├── ReAct (Reasoning + Acting)
│   ├── Reflexion (Self-reflection)
│   └── LATS (Language Agent Tree Search)
├── Tool Use & Actions
│   ├── Function calling
│   ├── Code execution
│   ├── Web browsing
│   └── API interaction
├── Memory Systems
│   ├── Short-term (context window)
│   ├── Long-term (vector stores)
│   ├── Episodic (experience replay)
│   └── Procedural (learned strategies)
├── Multi-Agent Systems
│   ├── Debate/discussion (ChatDev, MetaGPT)
│   ├── Hierarchical (manager/worker)
│   ├── Collaborative (shared goals)
│   └── Competitive (adversarial)
└── Applications
    ├── Software engineering (SWE-agent, Devin)
    ├── Scientific research (AI Scientist)
    ├── Web automation (WebArena)
    └── Game playing (Voyager)
```

## Landmark Papers

| Paper | Year | Key Contribution |
|-------|------|-----------------|
| **ReAct** | 2023 | Interleaving reasoning and acting |
| **Toolformer** | 2023 | Self-taught tool use |
| **Voyager** | 2023 | Lifelong learning agent in Minecraft |
| **AutoGPT** | 2023 | Autonomous goal-directed agent |
| **MetaGPT** | 2023 | Multi-agent software company |
| **Reflexion** | 2023 | Verbal self-reflection for learning |
| **SWE-agent** | 2024 | Autonomous software engineering |
| **AI Scientist** | 2024 | Autonomous research paper generation |
| **Claude Computer Use** | 2024 | GUI agent via screenshots |
| **OpenHands** | 2024 | Open platform for AI agents |

## Paper Tracking

```python
import arxiv
from datetime import datetime, timedelta

def find_agent_papers(days=7, max_results=30):
    """Find recent autonomous agent papers."""
    queries = [
        "abs:autonomous agent AND abs:large language model",
        "abs:LLM agent AND (abs:planning OR abs:tool use)",
        "abs:multi-agent AND abs:LLM",
    ]

    seen = set()
    papers = []

    for query in queries:
        search = arxiv.Search(
            query=query,
            max_results=max_results,
            sort_by=arxiv.SortCriterion.SubmittedDate,
        )
        cutoff = datetime.now() - timedelta(days=days)
        for r in search.results():
            if (r.entry_id not in seen and
                r.published.replace(tzinfo=None) > cutoff):
                seen.add(r.entry_id)
                papers.append({
                    "title": r.title,
                    "url": r.entry_id,
                    "date": r.published.strftime("%Y-%m-%d"),
                    "categories": r.categories,
                })

    papers.sort(key=lambda x: x["date"], reverse=True)
    return papers

for p in find_agent_papers(days=14):
    print(f"[{p['date']}] {p['title']}")
```

## Agent Benchmarks

```python
benchmarks = {
    "SWE-bench": {
        "task": "Resolve real GitHub issues",
        "metric": "% resolved",
        "top_score": "49% (Claude 3.5 + SWE-agent)",
    },
    "WebArena": {
        "task": "Complete web tasks in realistic sites",
        "metric": "Task success rate",
        "top_score": "35.8%",
    },
    "GAIA": {
        "task": "General AI assistant tasks",
        "metric": "Accuracy across levels",
        "top_score": "Level 1: 75%, Level 3: 30%",
    },
    "AgentBench": {
        "task": "8 diverse agent environments",
        "metric": "Overall score",
    },
    "ToolBench": {
        "task": "API tool selection and chaining",
        "metric": "Pass rate",
    },
}

for name, info in benchmarks.items():
    print(f"\n{name}: {info['task']}")
    print(f"  Metric: {info['metric']}")
    if "top_score" in info:
        print(f"  SOTA: {info['top_score']}")
```

## Reading Roadmap

```markdown
### Foundations
1. "Chain-of-Thought Prompting" (Wei et al., 2022)
2. "ReAct: Synergizing Reasoning and Acting" (Yao et al., 2023)
3. "Toolformer" (Schick et al., 2023)

### Planning & Memory
4. "Tree of Thoughts" (Yao et al., 2023)
5. "Reflexion" (Shinn et al., 2023)
6. "Generative Agents" (Park et al., 2023)

### Multi-Agent
7. "MetaGPT" (Hong et al., 2023)
8. "AutoGen" (Wu et al., 2023)
9. "ChatDev" (Qian et al., 2023)

### Applications
10. "SWE-agent" (Yang et al., 2024)
11. "The AI Scientist" (Lu et al., 2024)
```

## Use Cases

1. **Literature survey**: Track the fast-moving agent research field
2. **System design**: Learn from agent architecture patterns
3. **Benchmark comparison**: Compare agent frameworks
4. **Research direction**: Identify open problems in agent AI
5. **Course material**: Teach LLM-based agent systems

## References

- [Autonomous-Agents GitHub](https://github.com/tmgthb/Autonomous-Agents)
- [LLM-Agent-Paper-List](https://github.com/WooooDyy/LLM-Agent-Paper-List)
- [Agent Survey](https://arxiv.org/abs/2308.11432)

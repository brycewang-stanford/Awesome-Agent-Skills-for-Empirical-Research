---
name: papers-we-love-guide
description: "Community-curated directory of influential CS research papers"
metadata:
  openclaw:
    emoji: "❤️"
    category: "literature"
    subcategory: "discovery"
    keywords: ["papers we love", "CS papers", "reading groups", "classic papers", "paper recommendations", "curated list"]
    source: "https://github.com/papers-we-love/papers-we-love"
---

# Papers We Love Guide

## Overview

Papers We Love (PWL) is a community-driven repository of influential computer science research papers organized by topic, with worldwide reading groups. The repository contains direct links to PDFs and summaries for hundreds of landmark papers across distributed systems, programming languages, machine learning, security, and more. A go-to resource for discovering foundational and impactful research.

## Repository Structure

```
papers-we-love/
├── distributed_systems/
│   ├── README.md          # Curated list with descriptions
│   ├── lamport-clocks.pdf
│   └── raft.pdf
├── machine_learning/
├── programming_languages/
├── security/
├── databases/
├── networking/
├── information_retrieval/
├── artificial_intelligence/
├── concurrency/
├── operating_systems/
└── ... (40+ categories)
```

## Topic Categories

| Category | Notable Papers |
|----------|---------------|
| **Distributed Systems** | Paxos, Raft, MapReduce, Dynamo |
| **Machine Learning** | Backpropagation, Dropout, Attention, BatchNorm |
| **Programming Languages** | Lambda calculus, Type inference, Hindley-Milner |
| **Databases** | B-Trees, LSM-Trees, MVCC, Column stores |
| **Security** | Public-key crypto, Zero-knowledge proofs, TLS |
| **Networking** | TCP congestion, BGP, Software-defined networking |
| **Operating Systems** | Unix, Microkernel debate, Virtual memory |
| **Concurrency** | CSP, Actor model, Software transactional memory |

## Using PWL for Research

### Finding Papers by Topic

```bash
# Clone the repository
git clone https://github.com/papers-we-love/papers-we-love.git

# Browse categories
ls papers-we-love/

# Each directory has a README with curated descriptions
cat papers-we-love/distributed_systems/README.md
```

### Programmatic Access

```python
import os
import glob

PWL_PATH = "./papers-we-love"

# List all categories
categories = [d for d in os.listdir(PWL_PATH)
              if os.path.isdir(os.path.join(PWL_PATH, d))
              and not d.startswith('.')]
print(f"Categories: {len(categories)}")

# Find papers in a category
ml_papers = glob.glob(f"{PWL_PATH}/machine_learning/*.pdf")
for p in ml_papers:
    print(f"  {os.path.basename(p)}")

# Search across all READMEs for a topic
import re
for readme in glob.glob(f"{PWL_PATH}/*/README.md"):
    with open(readme) as f:
        content = f.read()
    if re.search(r"consensus|paxos|raft", content, re.I):
        category = os.path.basename(os.path.dirname(readme))
        print(f"Found in: {category}")
```

## Reading Group Integration

```python
# PWL chapters host monthly meetups worldwide
# Find local chapters at paperswelove.org

chapters = {
    "New York": "meetup.com/papers-we-love",
    "San Francisco": "meetup.com/papers-we-love-too",
    "London": "meetup.com/papers-we-love-london",
    "Berlin": "meetup.com/papers-we-love-berlin",
    # 40+ chapters globally
}

# Video talks on YouTube
# youtube.com/@PapersWeLove — recorded presentations
# Each talk: 30-60 min paper walkthrough by practitioner
```

## Building a Reading List

```python
# Curate a personal reading list from PWL
essential_distributed = [
    "Time, Clocks, and the Ordering of Events (Lamport, 1978)",
    "The Byzantine Generals Problem (Lamport et al., 1982)",
    "Impossibility of Distributed Consensus (FLP, 1985)",
    "Paxos Made Simple (Lamport, 2001)",
    "In Search of an Understandable Consensus Algorithm (Raft, 2014)",
    "Dynamo: Amazon's Key-Value Store (DeCandia et al., 2007)",
    "MapReduce: Simplified Data Processing (Dean & Ghemawat, 2004)",
]

essential_ml = [
    "A Few Useful Things to Know About ML (Domingos, 2012)",
    "Dropout: A Simple Way to Prevent Overfitting (Srivastava, 2014)",
    "Batch Normalization (Ioffe & Szegedy, 2015)",
    "Attention Is All You Need (Vaswani et al., 2017)",
    "BERT: Pre-training of Deep Bidirectional Transformers (2018)",
]
```

## Contributing to PWL

```markdown
## How to Contribute

1. Fork the repository
2. Add paper PDF to appropriate category directory
3. Update the category README.md with:
   - Paper title and authors
   - Year of publication
   - Brief description (2-3 sentences)
   - Why it matters
4. Submit a pull request

### README Entry Format
- :scroll: [Paper Title](link) — Brief description.
  Authors (Year). *Venue*.
```

## Use Cases

1. **Literature exploration**: Discover landmark papers by topic
2. **Reading groups**: Structured paper discussions with community
3. **Course preparation**: Curate reading lists for CS courses
4. **Onboarding**: Get up to speed on a new research area
5. **Historical context**: Trace the evolution of CS ideas

## References

- [Papers We Love GitHub](https://github.com/papers-we-love/papers-we-love)
- [Papers We Love Website](https://paperswelove.org/)
- [PWL YouTube Channel](https://www.youtube.com/@PapersWeLove)

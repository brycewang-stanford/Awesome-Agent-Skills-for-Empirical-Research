---
name: research-town-guide
description: "Simulate human research communities with multi-agent AI collaboration"
metadata:
  openclaw:
    emoji: "🏘️"
    category: "research"
    subcategory: "methodology"
    keywords: ["multi-agent", "simulation", "research community", "AI agents", "peer review", "collaboration"]
    source: "wentor-research-plugins"
---

# Research Town Guide

Simulate human research communities using multi-agent AI systems. Research Town creates virtual research environments where AI agents take on the roles of researchers, reviewers, editors, and collaborators to generate, critique, refine, and peer-review research ideas through structured multi-agent interaction.

## Overview

Research Town is an open-source framework for simulating the social dynamics of academic research communities. Rather than using a single AI model for idea generation or paper writing, Research Town instantiates multiple specialized agents -- each with a defined expertise profile, publication history, and behavioral model -- that interact through the same social structures as human researchers: lab meetings, peer review, conference discussions, and collaborative writing.

The key insight behind Research Town is that research quality emerges from the social process of science, not just individual brilliance. Peer review, adversarial critique, iterative refinement through rebuttal, and cross-disciplinary fertilization are all processes that can be simulated with multi-agent systems. By modeling these interactions, Research Town produces research outputs that have been stress-tested through simulated peer review before a human researcher ever sees them.

This approach is particularly valuable for three research tasks: (1) generating novel research ideas by simulating brainstorming sessions between agents with diverse expertise, (2) stress-testing research proposals by subjecting them to simulated peer review, and (3) identifying gaps in the literature by having agents independently survey and then synthesize findings from different subfields.

## Architecture

### Agent Types

| Agent Role | Expertise | Behavior |
|------------|-----------|----------|
| Principal Investigator | Broad domain knowledge, research vision | Sets research direction, evaluates proposals |
| Domain Expert | Deep knowledge in a specific area | Provides technical depth, identifies related work |
| Methodologist | Statistical and experimental design expertise | Critiques methods, suggests improvements |
| Reviewer | Journal review experience, quality standards | Evaluates novelty, significance, rigor |
| Devil's Advocate | Critical thinking, identifying weaknesses | Challenges assumptions, finds counterexamples |
| Synthesizer | Cross-disciplinary knowledge | Connects ideas across fields, identifies patterns |

### Interaction Protocols

```python
# Research Town interaction structure
class ResearchTownSession:
    def __init__(self, agents, topic):
        self.agents = agents
        self.topic = topic
        self.rounds = []

    def run_brainstorming(self, num_rounds=3):
        """Structured brainstorming with multiple agents."""
        ideas = []
        for round_num in range(num_rounds):
            round_ideas = []
            for agent in self.agents:
                # Each agent generates ideas given prior context
                idea = agent.generate_idea(
                    topic=self.topic,
                    prior_ideas=ideas,
                    round=round_num
                )
                round_ideas.append(idea)

            # Cross-pollination: agents react to each other's ideas
            for agent in self.agents:
                reactions = agent.react_to_ideas(round_ideas)
                ideas.extend(reactions)

            self.rounds.append(round_ideas)
        return ideas

    def run_peer_review(self, paper_draft):
        """Simulate peer review with multiple reviewers."""
        reviews = []
        for reviewer in self.agents:
            if reviewer.role == "reviewer":
                review = reviewer.review_paper(
                    paper_draft,
                    criteria=["novelty", "significance",
                             "methodology", "clarity", "reproducibility"]
                )
                reviews.append(review)

        # Meta-review: aggregate and identify consensus
        meta_review = self.aggregate_reviews(reviews)
        return meta_review
```

## Setting Up a Research Town Session

### Defining Agent Profiles

```yaml
# agents.yaml - Agent configuration
agents:
  - name: "Prof. ML Expert"
    role: principal_investigator
    expertise: ["machine learning", "deep learning", "optimization"]
    style: "rigorous, quantitative, focused on scalability"
    publication_venues: ["NeurIPS", "ICML", "JMLR"]
    h_index: 45

  - name: "Dr. Biology Specialist"
    role: domain_expert
    expertise: ["structural biology", "protein engineering", "bioinformatics"]
    style: "experimental, emphasizes biological validity"
    publication_venues: ["Nature", "Cell", "PNAS"]
    h_index: 32

  - name: "Dr. Statistics"
    role: methodologist
    expertise: ["causal inference", "experimental design", "Bayesian methods"]
    style: "rigorous, demands proper statistical justification"
    publication_venues: ["JASA", "Biometrika", "Statistical Science"]
    h_index: 28

  - name: "Reviewer Alpha"
    role: reviewer
    expertise: ["interdisciplinary research", "computational biology"]
    style: "constructive but demanding, focuses on reproducibility"
    review_experience: 200

  - name: "Skeptic"
    role: devils_advocate
    expertise: ["philosophy of science", "replication crisis", "research methods"]
    style: "challenges assumptions, demands strong evidence"
```

### Running an Idea Generation Session

```python
from research_town import ResearchTown, Agent

# Initialize agents from profiles
town = ResearchTown.from_config("agents.yaml")

# Define research topic
topic = {
    "area": "AI for Drug Discovery",
    "question": "How can we improve the efficiency of virtual screening "
                "for novel antibiotics using foundation models?",
    "constraints": [
        "Must work with limited labeled data (<1000 compounds)",
        "Must generalize across bacterial species",
        "Should produce interpretable predictions"
    ]
}

# Run brainstorming (3 rounds of idea generation and critique)
session = town.create_session(topic)
ideas = session.run_brainstorming(num_rounds=3)

# Rank ideas by multi-agent consensus
ranked = session.rank_ideas(ideas, criteria=[
    "novelty",       # How different from existing approaches
    "feasibility",   # Can it be implemented with current resources
    "impact",        # Potential significance if successful
    "rigor"          # Methodological soundness
])

# Output top ideas with supporting analysis
for i, idea in enumerate(ranked[:5]):
    print(f"\n=== Idea {i+1} (Score: {idea.score:.2f}) ===")
    print(f"Title: {idea.title}")
    print(f"Summary: {idea.summary}")
    print(f"Proposed by: {idea.proposer.name}")
    print(f"Endorsed by: {[a.name for a in idea.endorsers]}")
    print(f"Critiques: {idea.critiques}")
```

## Simulated Peer Review

### Review Protocol

The simulated peer review follows a structured protocol modeled on top-venue review processes:

```python
review_criteria = {
    "novelty": {
        "description": "Does this paper present genuinely new ideas?",
        "scale": "1-10",
        "weight": 0.25
    },
    "significance": {
        "description": "How important is the contribution to the field?",
        "scale": "1-10",
        "weight": 0.20
    },
    "soundness": {
        "description": "Are the methods and analysis technically correct?",
        "scale": "1-10",
        "weight": 0.25
    },
    "clarity": {
        "description": "Is the paper well-written and easy to follow?",
        "scale": "1-10",
        "weight": 0.15
    },
    "reproducibility": {
        "description": "Could another researcher replicate the results?",
        "scale": "1-10",
        "weight": 0.15
    }
}
```

### Review Output Format

```markdown
## Review Summary

**Overall Score**: 6.5/10
**Recommendation**: Minor Revision

### Strengths
1. Novel application of contrastive learning to molecular fingerprints
2. Comprehensive ablation study across 4 benchmark datasets
3. Clear explanation of the biological motivation

### Weaknesses
1. Limited comparison with recent graph neural network baselines (2024+)
2. Statistical significance not reported for main results
3. Interpretability analysis is superficial

### Questions for Authors
1. How does performance scale with dataset size? The smallest dataset has 5000 compounds.
2. What is the computational cost compared to traditional docking methods?

### Minor Issues
- Table 3 formatting is inconsistent
- Reference [24] appears to be a preprint; has it been published?
```

## Use Cases for Researchers

### 1. Idea Stress-Testing

Before investing months in a research direction, run your idea through a simulated review panel to identify weaknesses early.

### 2. Literature Gap Discovery

Deploy agents with different domain expertise to independently survey a topic, then synthesize their findings to identify under-explored intersections.

### 3. Writing Feedback

Submit draft sections to simulated reviewers for constructive criticism on clarity, argumentation, and missing references.

### 4. Proposal Refinement

Iterate on grant proposals by having agents role-play as review panel members with different priorities (novelty, feasibility, broader impact).

## Limitations and Ethics

- **AI-generated ideas are starting points, not final outputs**: All ideas require human validation, domain expertise, and ethical review before pursuit.
- **Simulated review is not a substitute for real peer review**: It can catch obvious issues but cannot replicate the full depth of expert human review.
- **Bias inheritance**: Agent behaviors are shaped by their training data, which may reproduce biases in existing research communities.
- **Attribution**: When using multi-agent idea generation, researchers should document the AI's role in the ideation process per their institution's guidelines.

## References

- Research Town: wentor-research-plugins
- The AI Scientist (Sakana AI): https://github.com/SakanaAI/AI-Scientist
- AutoGen multi-agent framework: https://github.com/microsoft/autogen
- CrewAI agent framework: https://github.com/joaomdmoura/crewAI
- Park et al., "Generative Agents: Interactive Simulacra of Human Behavior" (2023)

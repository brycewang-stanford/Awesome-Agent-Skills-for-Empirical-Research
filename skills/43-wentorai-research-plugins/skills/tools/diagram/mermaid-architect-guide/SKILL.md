---
name: mermaid-architect-guide
description: "Design complex multi-diagram architectures using advanced Mermaid syntax"
metadata:
  openclaw:
    emoji: "📐"
    category: "tools"
    subcategory: "diagram"
    keywords: ["Mermaid", "architecture", "system design", "C4 model", "diagram", "hand-drawn"]
    source: "https://github.com/mermaid-js/mermaid"
---

# Mermaid Architect Guide

Design complex, multi-view system architectures and research infrastructure diagrams using advanced Mermaid features including C4 diagrams, hand-drawn rendering mode, subgraph nesting, and theme customization.

## Overview

While basic Mermaid flowcharts are widely known, Mermaid's advanced capabilities enable sophisticated architectural documentation that rivals dedicated tools like Structurizr or Draw.io. This skill focuses on the architectural use cases that matter most to research teams: depicting multi-layer systems, data pipelines, deployment topologies, and complex experimental workflows.

Mermaid v11+ introduced a hand-drawn rendering mode (via the `handDrawn` look) that produces a sketch-like aesthetic similar to Excalidraw but with the convenience of text-based Markdown embedding. This makes it ideal for research proposals and informal documentation where a polished diagram would feel premature.

Research software systems often involve intricate interactions between data sources, processing pipelines, ML models, and visualization layers. The C4 model support in Mermaid allows teams to document these systems at multiple levels of abstraction -- from high-level context diagrams down to detailed component views -- all in version-controlled Markdown files.

## Hand-Drawn Mode

Enable the sketchy, informal rendering style:

```mermaid
---
config:
  look: handDrawn
  theme: neutral
---
flowchart LR
    A[Raw Data] --> B[Preprocessing]
    B --> C[Feature Engineering]
    C --> D[Model Training]
    D --> E[Evaluation]
    E -->|Poor| C
    E -->|Good| F[Deployment]
```

The `handDrawn` look applies rough.js-style rendering to all elements, giving them a natural sketched appearance. This is particularly useful for early-stage architecture discussions and research proposals.

## C4 Architecture Diagrams

### Context Diagram (Level 1)

```mermaid
C4Context
    title Research Platform - System Context

    Person(researcher, "Researcher", "Academic user conducting studies")
    Person(admin, "Platform Admin", "Manages skills and users")

    System(platform, "Wentor Platform", "AI-powered research assistant ecosystem")

    System_Ext(scholar, "OpenAlex", "Academic paper database")
    System_Ext(crossref, "CrossRef", "DOI resolution and metadata")
    System_Ext(github, "GitHub", "Code and skill repositories")

    Rel(researcher, platform, "Uses", "HTTPS")
    Rel(admin, platform, "Manages", "HTTPS")
    Rel(platform, scholar, "Queries papers", "REST API")
    Rel(platform, crossref, "Resolves DOIs", "REST API")
    Rel(platform, github, "Fetches skills", "REST API")
```

### Container Diagram (Level 2)

```mermaid
C4Container
    title Research Platform - Container View

    Person(researcher, "Researcher")

    Container_Boundary(platform, "Wentor Platform") {
        Container(web, "Web App", "React + UmiJS", "Browser-based UI")
        Container(api, "API Server", "FastAPI", "REST endpoints")
        Container(claw, "Research-Claw", "Node.js", "Local AI agent")
        ContainerDb(db, "Database", "PostgreSQL", "User data, skills, tokens")
        ContainerDb(cache, "Cache", "Redis", "Session and rate limit data")
    }

    System_Ext(llm, "LLM Provider", "Claude / GPT")

    Rel(researcher, web, "Browses", "HTTPS")
    Rel(researcher, claw, "Runs locally", "WS localhost")
    Rel(web, api, "Calls", "REST/JSON")
    Rel(api, db, "Reads/Writes", "SQL")
    Rel(api, cache, "Caches", "Redis protocol")
    Rel(claw, llm, "Sends prompts", "HTTPS")
```

## Advanced Subgraph Patterns

### Nested Research Pipeline

```mermaid
flowchart TB
    subgraph ingestion ["Data Ingestion Layer"]
        direction LR
        A1[PubMed API] --> B1[Raw Store]
        A2[arXiv API] --> B1
        A3[CrossRef API] --> B1
    end

    subgraph processing ["Processing Pipeline"]
        direction LR
        C1[Text Extraction] --> C2[NER & Entity Linking]
        C2 --> C3[Citation Graph Construction]
        C3 --> C4[Embedding Generation]
    end

    subgraph serving ["Serving Layer"]
        direction LR
        D1[Search Index] --> D2[Recommendation Engine]
        D2 --> D3[REST API]
    end

    ingestion --> processing --> serving
```

### Experiment Workflow with Decision Gates

```mermaid
flowchart TD
    Start([Begin Experiment]) --> Design[Study Design]
    Design --> IRB{IRB Approval?}
    IRB -->|Approved| Pilot[Pilot Study n=30]
    IRB -->|Revision needed| Design
    Pilot --> PilotCheck{Pilot Successful?}
    PilotCheck -->|Yes| FullStudy[Full Study n=300]
    PilotCheck -->|No| Redesign[Revise Protocol]
    Redesign --> Pilot
    FullStudy --> Analysis[Statistical Analysis]
    Analysis --> Results{Significant?}
    Results -->|p < 0.05| Write[Write Manuscript]
    Results -->|p >= 0.05| Explore[Exploratory Analysis]
    Explore --> Write
    Write --> Submit([Submit to Journal])
```

## State Diagrams for Research Processes

```mermaid
stateDiagram-v2
    [*] --> Ideation
    Ideation --> ProposalDrafting : Concept validated

    state ProposalDrafting {
        [*] --> Writing
        Writing --> InternalReview
        InternalReview --> Writing : Revisions needed
        InternalReview --> Ready : Approved
    }

    ProposalDrafting --> Submitted : Submit to funder
    Submitted --> UnderReview : Acknowledged
    UnderReview --> Funded : Award
    UnderReview --> Rejected : Decline
    Rejected --> Ideation : Revise concept
    Funded --> Active : Project kickoff
    Active --> Reporting : Milestone due
    Reporting --> Active : Report accepted
    Active --> Completed : All deliverables met
    Completed --> [*]
```

## Theme Customization

```mermaid
%%{init: {
  'theme': 'base',
  'themeVariables': {
    'primaryColor': '#1971c2',
    'primaryTextColor': '#ffffff',
    'primaryBorderColor': '#1864ab',
    'lineColor': '#495057',
    'secondaryColor': '#e03131',
    'tertiaryColor': '#f8f9fa',
    'fontFamily': 'Inter, sans-serif'
  }
}}%%
flowchart LR
    A[Input] --> B[Process] --> C[Output]
```

## Rendering and Integration

| Platform | Support | Notes |
|----------|---------|-------|
| GitHub Markdown | Native | Renders in README, issues, PRs |
| GitLab | Native | Full Mermaid support |
| Obsidian | Native | Real-time preview |
| Notion | Via embed | Use mermaid.ink URL encoding |
| LaTeX | Pre-render | Use `mmdc` CLI to export SVG/PDF |
| Jupyter | Via plugin | `mermaid-py` or iframe rendering |

### CLI Rendering

```bash
# Install Mermaid CLI
npm install -g @mermaid-js/mermaid-cli

# Render to SVG
mmdc -i architecture.mmd -o architecture.svg -t neutral

# Render with hand-drawn look
mmdc -i architecture.mmd -o sketch.svg --configFile mermaid-config.json
```

## References

- Mermaid official documentation: https://mermaid.js.org
- C4 model specification: https://c4model.com
- Mermaid CLI (mmdc): https://github.com/mermaid-js/mermaid-cli
- Mermaid Live Editor: https://mermaid.live

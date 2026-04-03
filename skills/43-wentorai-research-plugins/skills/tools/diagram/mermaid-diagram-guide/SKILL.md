---
name: mermaid-diagram-guide
description: "Create flowcharts, sequence diagrams, and architecture diagrams with Mermaid"
metadata:
  openclaw:
    emoji: "📋"
    category: "tools"
    subcategory: "diagram"
    keywords: ["flow chart", "architecture diagram", "Mermaid", "UML diagram", "graphical abstract"]
    source: "N/A"
---

# Mermaid Diagram Guide

## Overview

Mermaid is a text-based diagramming tool that renders diagrams from Markdown-like syntax. For researchers, Mermaid offers a unique combination of version-controllable source code, instant rendering in documentation platforms (GitHub, GitLab, Notion, Obsidian), and enough expressiveness to create flowcharts, sequence diagrams, class diagrams, Gantt charts, and more.

Unlike graphical tools like draw.io or Lucidchart, Mermaid diagrams live as plain text in your documentation, making them easy to maintain alongside code and papers. They are especially valuable for research documentation, README files, software architecture diagrams in methods sections, and graphical abstracts.

This guide covers the most useful Mermaid diagram types for academic work, with complete syntax references and real-world examples from research contexts. Each diagram type includes a template you can copy and modify for your specific needs.

## Flowcharts

Flowcharts are the most common diagram type for describing algorithms, experimental procedures, and data processing pipelines.

### Basic Syntax

```mermaid
flowchart TD
    A[Start] --> B{Decision}
    B -->|Yes| C[Process A]
    B -->|No| D[Process B]
    C --> E[End]
    D --> E
```

### Node Shapes

| Shape | Syntax | Use Case |
|-------|--------|----------|
| Rectangle | `A[text]` | Process step |
| Rounded | `A(text)` | Start/end |
| Diamond | `A{text}` | Decision |
| Hexagon | `A{{text}}` | Preparation |
| Parallelogram | `A[/text/]` | Input/output |
| Circle | `A((text))` | Connector |
| Stadium | `A([text])` | Terminal |

### Research Pipeline Example

```mermaid
flowchart TD
    subgraph Data Collection
        A[Raw Data] --> B[Quality Check]
        B --> C{Pass QC?}
        C -->|No| D[Exclude]
        C -->|Yes| E[Clean Data]
    end

    subgraph Analysis
        E --> F[Feature Extraction]
        F --> G[Model Training]
        G --> H[Cross-Validation]
    end

    subgraph Evaluation
        H --> I{Significant?}
        I -->|Yes| J[Report Results]
        I -->|No| K[Revise Hypothesis]
        K --> F
    end

    style A fill:#3B82F6,color:#fff
    style J fill:#16A34A,color:#fff
    style D fill:#EF4444,color:#fff
```

### Direction Options

| Direction | Code | Description |
|-----------|------|-------------|
| Top to bottom | `TD` or `TB` | Default, vertical |
| Bottom to top | `BT` | Vertical, upward |
| Left to right | `LR` | Horizontal |
| Right to left | `RL` | Horizontal, reversed |

## Sequence Diagrams

Sequence diagrams show interactions between components over time. They are ideal for describing API calls, protocol steps, and system interactions.

```mermaid
sequenceDiagram
    participant U as User
    participant F as Frontend
    participant A as API Server
    participant DB as Database

    U->>F: Submit experiment
    F->>A: POST /experiments
    A->>DB: INSERT experiment
    DB-->>A: experiment_id
    A->>A: Queue processing job

    Note over A: Async processing begins

    A-->>F: 202 Accepted {id}
    F-->>U: "Experiment submitted"

    loop Every 5 seconds
        F->>A: GET /experiments/{id}/status
        A-->>F: {status: "running"}
    end

    A-->>F: {status: "complete", results: {...}}
    F-->>U: Display results
```

### Arrow Types

| Arrow | Syntax | Meaning |
|-------|--------|---------|
| Solid with arrowhead | `->>` | Synchronous call |
| Dotted with arrowhead | `-->>` | Response/return |
| Solid | `->` | Message |
| Dotted | `-->` | Optional message |
| Cross | `-x` | Failed message |

## Class Diagrams

Class diagrams document code architecture and data models:

```mermaid
classDiagram
    class Experiment {
        +String id
        +String name
        +DateTime created_at
        +Status status
        +run()
        +get_results() Results
    }

    class Dataset {
        +String path
        +int n_samples
        +int n_features
        +load() DataFrame
        +split(ratio) TrainTest
    }

    class Model {
        +String architecture
        +Dict hyperparams
        +train(Dataset)
        +predict(Dataset) Array
        +evaluate(Dataset) Metrics
    }

    Experiment "1" --> "1..*" Dataset : uses
    Experiment "1" --> "1..*" Model : trains
    Model ..> Dataset : depends on
```

## Gantt Charts

Gantt charts are useful for project timelines and research plans:

```mermaid
gantt
    title Research Project Timeline
    dateFormat YYYY-MM-DD
    axisFormat %b %Y

    section Literature Review
        Survey existing work     :done, lit1, 2026-01-01, 30d
        Identify research gap    :done, lit2, after lit1, 14d

    section Methodology
        Design experiments       :active, meth1, after lit2, 21d
        Implement baseline       :meth2, after meth1, 14d

    section Experiments
        Run baseline experiments :exp1, after meth2, 21d
        Run proposed method      :exp2, after exp1, 21d
        Ablation studies         :exp3, after exp2, 14d

    section Writing
        Draft paper              :write1, after exp2, 30d
        Internal review          :write2, after write1, 14d
        Submit to conference     :milestone, after write2, 0d
```

## State Diagrams

State diagrams model entity lifecycles:

```mermaid
stateDiagram-v2
    [*] --> Draft
    Draft --> UnderReview : Submit
    UnderReview --> MinorRevision : Reviewer feedback
    UnderReview --> MajorRevision : Reviewer feedback
    UnderReview --> Rejected : Reviewer feedback
    MinorRevision --> UnderReview : Resubmit
    MajorRevision --> UnderReview : Resubmit
    UnderReview --> Accepted : Final decision
    Accepted --> Published : Camera-ready
    Rejected --> Draft : Revise for new venue
    Published --> [*]
```

## Rendering and Integration

### GitHub / GitLab

Both platforms render Mermaid natively in Markdown files:

````markdown
```mermaid
flowchart LR
    A --> B --> C
```
````

### Command-Line Rendering

```bash
# Install Mermaid CLI
npm install -g @mermaid-js/mermaid-cli

# Render to PNG
mmdc -i diagram.mmd -o diagram.png -w 1200

# Render to SVG (preferred for papers)
mmdc -i diagram.mmd -o diagram.svg

# Render to PDF
mmdc -i diagram.mmd -o diagram.pdf
```

### Embedding in LaTeX

```latex
% Include the SVG generated by mmdc
\usepackage{svg}
\begin{figure}[h]
  \centering
  \includesvg[width=0.8\textwidth]{diagram}
  \caption{System architecture overview.}
\end{figure}
```

## Best Practices

- **Keep diagrams focused.** One concept per diagram. If it exceeds 15-20 nodes, split it.
- **Use subgraphs for grouping.** They clarify which components belong together.
- **Label all edges.** Unlabeled arrows are ambiguous.
- **Use consistent styling.** Define colors for success (green), failure (red), and process (blue) states.
- **Export as SVG for papers.** SVG scales perfectly and produces crisp output at any size.
- **Version-control your diagrams.** Since Mermaid is text, it diffs cleanly in Git.
- **Test in the live editor.** Use [mermaid.live](https://mermaid.live/) to iterate quickly before committing.

## References

- [Mermaid Documentation](https://mermaid.js.org/) -- Official reference
- [Mermaid Live Editor](https://mermaid.live/) -- Interactive diagram editor
- [Mermaid CLI](https://github.com/mermaid-js/mermaid-cli) -- Command-line rendering tool
- [GitHub Mermaid Support](https://github.blog/2022-02-14-include-diagrams-markdown-files-mermaid/) -- Native rendering in GitHub

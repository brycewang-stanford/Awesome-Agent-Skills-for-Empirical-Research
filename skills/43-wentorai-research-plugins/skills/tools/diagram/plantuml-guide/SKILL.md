---
name: plantuml-guide
description: "Create UML diagrams and architecture visualizations with PlantUML"
metadata:
  openclaw:
    emoji: "📊"
    category: "tools"
    subcategory: "diagram"
    keywords: ["UML diagram", "PlantUML", "architecture diagram", "flow chart"]
    source: "wentor-research-plugins"
---

# PlantUML Guide

Create UML diagrams, architecture visualizations, flowcharts, and other technical diagrams using PlantUML's text-based notation for reproducible, version-controllable diagrams.

## Getting Started

PlantUML generates diagrams from plain text descriptions. Diagrams are defined in `.puml` files and rendered to PNG, SVG, or PDF.

### Installation Options

| Method | Command / URL | Best For |
|--------|--------------|----------|
| VS Code extension | Install "PlantUML" by jebbs | IDE integration |
| CLI (Java JAR) | `java -jar plantuml.jar diagram.puml` | Batch processing |
| Online server | plantuml.com/plantuml | Quick prototyping |
| Docker | `docker run plantuml/plantuml-server` | Self-hosted server |
| Python | `pip install plantuml` | Python integration |
| Jupyter | `pip install iplantuml` | Notebook integration |

### Basic Syntax

```plantuml
@startuml
title My First Diagram

Alice -> Bob: Hello
Bob --> Alice: Hi there!

@enduml
```

## Sequence Diagrams

Model interactions between components over time:

```plantuml
@startuml
title Research Paper Submission Workflow

actor Author
participant "Submission\nSystem" as SS
participant "Editor" as Ed
participant "Reviewer 1" as R1
participant "Reviewer 2" as R2

Author -> SS: Submit manuscript
activate SS
SS -> Ed: Notify new submission
activate Ed

Ed -> SS: Assign reviewers
SS -> R1: Review request
SS -> R2: Review request

activate R1
activate R2

R1 -> SS: Submit review (Accept)
deactivate R1
R2 -> SS: Submit review (Minor revision)
deactivate R2

Ed -> SS: Decision: Minor revision
SS -> Author: Revision request
deactivate Ed
deactivate SS

Author -> SS: Submit revised manuscript
activate SS
SS -> Ed: Notify revision
Ed -> SS: Accept
SS -> Author: Acceptance notification
deactivate SS

@enduml
```

## Class Diagrams

Model system structure and relationships:

```plantuml
@startuml
title Research Data Model

class Paper {
  +id: UUID
  +title: String
  +abstract: String
  +doi: String
  +year: Integer
  +venue: String
  --
  +getCitations(): List<Paper>
  +getAuthors(): List<Author>
  +getBibTeX(): String
}

class Author {
  +id: UUID
  +name: String
  +orcid: String
  +affiliation: String
  +h_index: Integer
  --
  +getPapers(): List<Paper>
  +getCoauthors(): List<Author>
}

class Dataset {
  +id: UUID
  +name: String
  +doi: String
  +license: String
  +size_bytes: Long
  --
  +download(): File
  +getCitation(): String
}

class Experiment {
  +id: UUID
  +description: String
  +date: Date
  +config: JSON
  --
  +run(): Results
  +getMetrics(): Map
}

Paper "1" -- "*" Author : authored by >
Paper "1" -- "*" Dataset : uses >
Paper "1" -- "*" Experiment : contains >
Dataset "1" -- "*" Experiment : used in >
Paper "1" -- "*" Paper : cites >

@enduml
```

## Activity Diagrams (Flowcharts)

Model workflows and decision processes:

```plantuml
@startuml
title Systematic Review Screening Process

start

:Import records from databases;
:Remove duplicates;

:Screen title and abstract;

if (Meets inclusion criteria?) then (yes)
  :Retrieve full text;
  if (Full text available?) then (yes)
    :Screen full text;
    if (Meets all criteria?) then (yes)
      :Include in review;
      :Extract data;
      if (Suitable for meta-analysis?) then (yes)
        :Include in meta-analysis;
      else (no)
        :Include in narrative synthesis;
      endif
    else (no)
      :Exclude with reason;
    endif
  else (no)
    :Mark as unavailable;
  endif
else (no)
  :Exclude;
endif

:Compile PRISMA flow diagram;
stop

@enduml
```

## Component Diagrams

Model system architecture:

```plantuml
@startuml
title Research Platform Architecture

package "Web Frontend" {
  [React SPA] as SPA
  [Dashboard] as Dash
  [Skills Browser] as Skills
}

package "API Gateway" {
  [FastAPI Server] as API
  [Auth Service] as Auth
  [Rate Limiter] as RL
}

package "Backend Services" {
  [Paper Search] as PS
  [Citation Graph] as CG
  [Skill Registry] as SR
}

package "Data Layer" {
  database "PostgreSQL" as PG
  database "Redis Cache" as Redis
  database "Elasticsearch" as ES
}

package "External APIs" {
  [Unpaywall] as UP
  [CrossRef] as CR
  [OpenAlex] as OA
}

SPA --> API : HTTPS
Dash --> API : HTTPS
Skills --> API : HTTPS

API --> Auth : validate token
API --> RL : check rate limit
API --> PS : search request
API --> CG : graph query
API --> SR : skill lookup

PS --> ES : full-text search
PS --> S2 : paper metadata
PS --> CR : DOI resolution

CG --> PG : citation data
CG --> OA : citation graph

SR --> PG : skill metadata
SR --> Redis : cache

@enduml
```

## State Diagrams

Model system states and transitions:

```plantuml
@startuml
title Paper Lifecycle States

[*] --> Draft

Draft --> Submitted : Author submits
Submitted --> UnderReview : Editor assigns reviewers
Submitted --> DeskRejected : Editor rejects

UnderReview --> RevisionRequired : Minor/Major revision
UnderReview --> Accepted : Accept as is
UnderReview --> Rejected : Reject

RevisionRequired --> UnderReview : Author resubmits
RevisionRequired --> Withdrawn : Author withdraws

Accepted --> InProduction : Copy editing
InProduction --> Published : Online first
Published --> [*]

DeskRejected --> [*]
Rejected --> [*]
Withdrawn --> [*]

@enduml
```

## Gantt Charts

Plan research timelines:

```plantuml
@startuml
title Research Project Timeline

Project starts 2025-01-01

[Literature Review] starts 2025-01-01 and lasts 8 weeks
[Research Design] starts at [Literature Review]'s end and lasts 4 weeks
[IRB Approval] starts at [Research Design]'s end and lasts 6 weeks
[Data Collection] starts at [IRB Approval]'s end and lasts 12 weeks
[Data Analysis] starts at [Data Collection]'s end and lasts 8 weeks
[Paper Writing] starts at [Data Analysis]'s end and lasts 10 weeks
[Peer Review] starts at [Paper Writing]'s end and lasts 12 weeks
[Revision] starts at [Peer Review]'s end and lasts 6 weeks

-- Milestones --
[Proposal Defense] happens at [Research Design]'s end
[Conference Presentation] happens at [Data Analysis]'s end
[Submission] happens at [Paper Writing]'s end

@enduml
```

## Mind Maps

Organize research topics:

```plantuml
@startmindmap
title Machine Learning Research Landscape

* Machine Learning
** Supervised Learning
*** Classification
**** SVM
**** Decision Trees
**** Neural Networks
*** Regression
**** Linear Regression
**** Gradient Boosting
** Unsupervised Learning
*** Clustering
**** K-Means
**** DBSCAN
*** Dimensionality Reduction
**** PCA
**** t-SNE
**** UMAP
** Reinforcement Learning
*** Model-Free
**** DQN
**** PPO
*** Model-Based
**** Dreamer
**** MuZero
** Deep Learning
*** CNNs
*** Transformers
*** GANs
*** Diffusion Models

@endmindmap
```

## Integration with LaTeX

```latex
\usepackage{plantuml}

\begin{plantuml}
@startuml
Alice -> Bob: Hello
Bob --> Alice: Hi
@enduml
\end{plantuml}

% Compile with: pdflatex -shell-escape paper.tex
```

## Integration with Markdown (Mermaid Alternative)

Many Markdown renderers (GitHub, GitLab, Notion) support Mermaid natively. PlantUML can be used via plugins or pre-rendering:

```python
# Pre-render PlantUML to SVG for Markdown embedding
import plantuml

server = plantuml.PlantUML(url="http://www.plantuml.com/plantuml/svg/")
svg_content = server.processes("""
@startuml
Alice -> Bob: Hello
@enduml
""")

with open("diagram.svg", "wb") as f:
    f.write(svg_content)
```

## Best Practices

1. **Version control your diagrams**: Store `.puml` files alongside code/documentation in git.
2. **Use consistent styling**: Define skinparams at the top of each file for consistent colors and fonts.
3. **Keep diagrams focused**: One diagram per concept; split complex architectures into multiple views.
4. **Add legends and notes**: Use `note left of`, `note right of`, or `legend` blocks to clarify semantics.
5. **Automate rendering**: Include PlantUML rendering in CI/CD pipelines to keep documentation current.
6. **Export as SVG**: Prefer SVG over PNG for scalable diagrams in papers and presentations.

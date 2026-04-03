---
name: kroki-diagram-api
description: "Generate diagrams from text via Kroki's multi-format rendering API"
metadata:
  openclaw:
    emoji: "📐"
    category: "tools"
    subcategory: "diagram"
    keywords: ["Kroki", "diagram generation", "text-to-diagram", "Graphviz", "PlantUML", "Mermaid"]
    source: "https://kroki.io/"
---

# Kroki Diagram API

## Overview

Kroki provides a unified HTTP API to render 20+ text-based diagram formats into images (SVG, PNG, PDF). It supports Mermaid, PlantUML, Graphviz, D2, BPMN, and more — all through a single endpoint. Self-hostable or use the free public instance. No authentication required. Ideal for generating research figures, architecture diagrams, and flowcharts programmatically.

## API Usage

### GET Request (URL-encoded)

```bash
# Graphviz DOT diagram
curl "https://kroki.io/graphviz/svg/digraph{A->B->C}" -o diagram.svg

# Mermaid diagram (base64-encoded)
echo "graph TD; A-->B; B-->C;" | base64 | \
  curl "https://kroki.io/mermaid/svg/$(cat -)" -o diagram.svg
```

### POST Request (Recommended)

```bash
# PlantUML sequence diagram
curl -X POST "https://kroki.io/plantuml/svg" \
  -H "Content-Type: text/plain" \
  -d '@startuml
Alice -> Bob: Hello
Bob --> Alice: Hi!
@enduml' -o sequence.svg

# Mermaid flowchart
curl -X POST "https://kroki.io/mermaid/svg" \
  -H "Content-Type: text/plain" \
  -d 'graph TD
    A[Data Collection] --> B[Preprocessing]
    B --> C[Model Training]
    C --> D[Evaluation]
    D -->|Good| E[Deploy]
    D -->|Bad| B' -o flowchart.svg

# Graphviz
curl -X POST "https://kroki.io/graphviz/svg" \
  -H "Content-Type: text/plain" \
  -d 'digraph {
    rankdir=LR
    "Raw Data" -> "Feature Extraction" -> "Model" -> "Prediction"
  }' -o pipeline.svg

# D2 diagram
curl -X POST "https://kroki.io/d2/svg" \
  -H "Content-Type: text/plain" \
  -d 'Client -> API: Request
API -> Database: Query
Database -> API: Results
API -> Client: Response' -o d2.svg
```

### URL Format

```
https://kroki.io/{diagram_type}/{output_format}/{encoded_source}

# Or POST to:
https://kroki.io/{diagram_type}/{output_format}
```

### Supported Diagram Types

| Type | Keyword | Best for |
|------|---------|----------|
| Mermaid | `mermaid` | Flowcharts, sequences, Gantt |
| PlantUML | `plantuml` | UML, sequences, class diagrams |
| Graphviz | `graphviz` | Network graphs, DAGs |
| D2 | `d2` | Modern text-to-diagram |
| Ditaa | `ditaa` | ASCII art diagrams |
| BlockDiag | `blockdiag` | Block diagrams |
| Nomnoml | `nomnoml` | UML-like diagrams |
| WaveDrom | `wavedrom` | Digital timing diagrams |
| Vega | `vega` | Data visualizations |
| Vega-Lite | `vegalite` | Simplified data viz |
| C4 PlantUML | `c4plantuml` | C4 architecture |
| BPMN | `bpmn` | Business processes |
| Bytefield | `bytefield` | Protocol/byte diagrams |
| Excalidraw | `excalidraw` | Hand-drawn style |

### Output Formats

| Format | Extension | Use case |
|--------|-----------|----------|
| SVG | `/svg` | Web, scalable |
| PNG | `/png` | Documents, slides |
| PDF | `/pdf` | Papers, print |
| JPEG | `/jpeg` | Compatibility |

## Python Usage

```python
import requests
import base64
import zlib


KROKI_URL = "https://kroki.io"


def render_diagram(source: str, diagram_type: str = "mermaid",
                   output_format: str = "svg") -> bytes:
    """Render a text diagram to image via Kroki."""
    resp = requests.post(
        f"{KROKI_URL}/{diagram_type}/{output_format}",
        headers={"Content-Type": "text/plain"},
        data=source,
    )
    resp.raise_for_status()
    return resp.content


def save_diagram(source: str, output_path: str,
                 diagram_type: str = "mermaid",
                 output_format: str = "svg"):
    """Render and save a diagram to file."""
    content = render_diagram(source, diagram_type, output_format)
    with open(output_path, "wb") as f:
        f.write(content)


def render_research_pipeline(steps: list) -> bytes:
    """Create a research pipeline flowchart."""
    nodes = []
    for i, step in enumerate(steps):
        node_id = chr(65 + i)
        nodes.append(f"    {node_id}[{step}]")
        if i > 0:
            prev_id = chr(65 + i - 1)
            nodes.append(f"    {prev_id} --> {node_id}")

    mermaid = "graph TD\n" + "\n".join(nodes)
    return render_diagram(mermaid, "mermaid", "svg")


# Example: create a research workflow diagram
workflow = """graph TD
    A[Literature Review] --> B[Hypothesis]
    B --> C[Data Collection]
    C --> D[Statistical Analysis]
    D --> E{Significant?}
    E -->|Yes| F[Write Paper]
    E -->|No| G[Revise Hypothesis]
    G --> B
    F --> H[Peer Review]"""

save_diagram(workflow, "research_workflow.svg", "mermaid")

# Example: Graphviz citation network
citation_graph = """digraph {
    rankdir=BT
    node [shape=box, style=rounded]
    "Vaswani 2017" -> "BERT 2018"
    "Vaswani 2017" -> "GPT 2018"
    "BERT 2018" -> "RoBERTa 2019"
    "GPT 2018" -> "GPT-2 2019"
    "GPT-2 2019" -> "GPT-3 2020"
}"""
save_diagram(citation_graph, "citations.svg", "graphviz")

# Example: research pipeline helper
pipeline_svg = render_research_pipeline([
    "Raw Data", "Cleaning", "Feature Engineering",
    "Model Training", "Evaluation", "Deployment"
])
```

## Self-Hosting

```bash
# Run Kroki locally via Docker
docker run -d -p 8000:8000 yuzutech/kroki

# Then use http://localhost:8000 instead of https://kroki.io
```

## References

- [Kroki](https://kroki.io/)
- [Kroki Documentation](https://docs.kroki.io/)
- [Kroki GitHub](https://github.com/yuzutech/kroki)

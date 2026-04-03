---
name: excalidraw-diagram-guide
description: "Generate hand-drawn style Excalidraw diagrams from text descriptions"
metadata:
  openclaw:
    emoji: "✏️"
    category: "tools"
    subcategory: "diagram"
    keywords: ["Excalidraw", "diagram", "whiteboard", "hand-drawn", "sketch", "visual"]
    source: "https://github.com/excalidraw/excalidraw"
---

# Excalidraw Diagram Guide

Generate hand-drawn style diagrams, wireframes, and visual explanations using Excalidraw's open-source whiteboard format. This skill enables researchers to create informal yet informative sketches for brainstorming sessions, presentations, and collaborative workshops.

## Overview

Excalidraw is an open-source virtual whiteboard tool that produces diagrams with a distinctive hand-drawn aesthetic. Unlike formal diagramming tools such as PlantUML or Visio, Excalidraw prioritizes approachability and rapid ideation. Its output looks intentionally informal, which makes it well-suited for early-stage research brainstorming, teaching materials, and conference posters where a polished UML diagram would feel overly rigid.

The tool stores diagrams in a JSON-based `.excalidraw` format, making them fully version-controllable and programmatically generatable. Researchers can describe what they need in natural language, and this skill translates those descriptions into valid Excalidraw scene files that can be opened in the Excalidraw editor or embedded directly into web pages.

Excalidraw supports real-time collaboration, end-to-end encryption for shared sessions, and export to PNG and SVG. The hand-drawn style is achieved through a custom rendering engine that applies subtle randomization to stroke paths, giving each element a natural, sketched appearance.

## Creating Diagrams from Descriptions

The Excalidraw JSON format consists of an array of elements, each with a type (rectangle, ellipse, arrow, text, line, diamond), position coordinates, dimensions, and style properties.

### Basic Element Structure

```json
{
  "type": "rectangle",
  "x": 100,
  "y": 200,
  "width": 200,
  "height": 80,
  "strokeColor": "#1e1e1e",
  "backgroundColor": "#a5d8ff",
  "fillStyle": "hachure",
  "strokeWidth": 1,
  "roughness": 1,
  "roundness": { "type": 3 }
}
```

### Key Properties

| Property | Values | Description |
|----------|--------|-------------|
| `fillStyle` | `hachure`, `cross-hatch`, `solid` | Fill pattern style |
| `roughness` | `0`, `1`, `2` | Hand-drawn roughness level |
| `strokeWidth` | `1`, `2`, `4` | Line thickness |
| `strokeStyle` | `solid`, `dashed`, `dotted` | Line style |
| `roundness` | `null`, `{ "type": 3 }` | Corner rounding |

### Common Academic Color Palette

```
Primary:   #1971c2 (blue)    Background: #a5d8ff
Accent:    #e03131 (red)     Background: #ffc9c9
Success:   #2f9e44 (green)   Background: #b2f2bb
Warning:   #f08c00 (orange)  Background: #ffec99
Neutral:   #495057 (gray)    Background: #dee2e6
```

## Research Workflow Diagrams

### Methodology Flowchart

Describe a research pipeline and generate the corresponding layout:

```
Input: "Create a flowchart showing: Literature Review -> Research Questions ->
        Hypothesis Formation -> Study Design -> Data Collection -> Analysis ->
        Results -> Discussion -> Publication"
```

Each step becomes a rounded rectangle connected by arrows. Decision points (e.g., "Results Significant?") use diamond shapes with branching arrows.

### System Architecture Sketches

For software or experimental system diagrams, use grouped rectangles with labeled connections:

```
Input: "Draw a system architecture with three layers:
        Frontend (React dashboard),
        Backend (FastAPI + PostgreSQL),
        External (OpenAlex API, CrossRef API)"
```

The output places each layer as a dashed-border container with internal component boxes and inter-layer arrows.

## Embedding and Export

### Export Options

- **PNG**: Best for slides and documents. Use `exportScale: 2` for high-DPI output.
- **SVG**: Ideal for papers and web embedding. Scales without quality loss.
- **JSON**: Native format for version control and programmatic manipulation.

### Web Embedding

```html
<iframe
  src="https://excalidraw.com/#json=YOUR_ENCODED_DATA"
  width="800"
  height="600"
  style="border: none;">
</iframe>
```

### Programmatic Generation (Python)

```python
import json

def create_box(text, x, y, width=200, height=80, color="#a5d8ff"):
    return [
        {
            "type": "rectangle",
            "x": x, "y": y,
            "width": width, "height": height,
            "backgroundColor": color,
            "fillStyle": "hachure",
            "roughness": 1,
            "strokeWidth": 1
        },
        {
            "type": "text",
            "x": x + 10, "y": y + 25,
            "text": text,
            "fontSize": 16
        }
    ]

scene = {
    "type": "excalidraw",
    "version": 2,
    "elements": create_box("Literature Review", 100, 100)
                + create_box("Data Analysis", 100, 250)
}

with open("research_flow.excalidraw", "w") as f:
    json.dump(scene, f, indent=2)
```

## Collaboration Features

Excalidraw supports live collaboration through shared session links. Each participant sees real-time cursor positions and edits. Sessions can be encrypted end-to-end using the built-in encryption feature, which is important when sketching unpublished research ideas.

For research teams, the recommended workflow is:

1. Create a shared session for the brainstorming phase
2. Export the final sketch as `.excalidraw` JSON and commit to the project repository
3. Generate high-resolution PNG/SVG exports for inclusion in papers or presentations

## Integration with Research Tools

- **Obsidian**: The Excalidraw plugin enables whiteboard sketching directly in research notes
- **Notion**: Embed via iframe or exported SVG
- **LaTeX**: Export as SVG, include with `\includesvg{}` (requires `svg` package)
- **Jupyter**: Display exported PNG inline using `IPython.display.Image`
- **VS Code**: Official Excalidraw extension for editing `.excalidraw` files in the IDE

## References

- Excalidraw open-source repository: https://github.com/excalidraw/excalidraw
- Excalidraw libraries (pre-made shapes): https://libraries.excalidraw.com
- Excalidraw file format specification: https://docs.excalidraw.com

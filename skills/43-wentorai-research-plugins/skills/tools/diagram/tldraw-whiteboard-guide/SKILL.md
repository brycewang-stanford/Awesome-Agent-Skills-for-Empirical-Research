---
name: tldraw-whiteboard-guide
description: "Guide to tldraw for infinite canvas whiteboarding and diagram creation"
metadata:
  openclaw:
    emoji: "🖊️"
    category: "tools"
    subcategory: "diagram"
    keywords: ["whiteboard", "infinite canvas", "diagram SDK", "collaborative drawing", "research diagrams", "visual thinking"]
    source: "https://github.com/tldraw/tldraw"
---

# tldraw Whiteboard Guide

## Overview

tldraw is an open-source infinite canvas whiteboard SDK with over 46K stars on GitHub. It provides a complete whiteboard experience that can be used standalone or embedded into custom applications. The library offers a polished, intuitive drawing interface with shapes, connectors, text, freehand drawing, and image support, all running in the browser with no backend required for basic use.

For academic researchers, tldraw serves multiple roles. It can function as a collaborative brainstorming tool for research ideation sessions, a diagram creation tool for papers and presentations, a visual note-taking surface during literature reviews, and a framework diagramming tool for conceptual models. Unlike traditional diagramming tools that impose rigid structures, tldraw's freeform canvas encourages the kind of fluid visual thinking that drives research innovation.

The SDK architecture makes tldraw particularly interesting for research tool builders. It can be embedded into lab notebooks, research management platforms, and educational tools. The state management system is extensible, allowing developers to add custom shapes, tools, and behaviors for domain-specific diagramming needs such as circuit diagrams, molecular structures, or experimental workflow visualizations.

## Getting Started

### Using tldraw Online

The fastest way to use tldraw is through the hosted version at tldraw.com. Create diagrams immediately with no installation, and share them via links.

### Self-Hosted Deployment

```bash
# Clone and run locally
git clone https://github.com/tldraw/tldraw.git
cd tldraw
npm install
npm run dev

# Access at http://localhost:5420
```

### Embedding in a React Application

```bash
# Install the tldraw package
npm install tldraw
```

```tsx
import { Tldraw } from 'tldraw';
import 'tldraw/tldraw.css';

function ResearchWhiteboard() {
  return (
    <div style={{ width: '100vw', height: '100vh' }}>
      <Tldraw />
    </div>
  );
}
```

## Core Features for Research Work

### Shape Tools

tldraw provides a comprehensive set of shape tools suitable for creating research diagrams:

- **Rectangle** - Process boxes, system components, categories
- **Ellipse** - States, entities, conceptual groupings
- **Diamond** - Decision nodes, conditions
- **Arrow** - Relationships, flows, dependencies, causal links
- **Line** - Connections, separators, timelines
- **Text** - Labels, annotations, descriptions
- **Freehand** - Sketches, handwritten annotations, emphasis marks
- **Note** - Sticky notes for brainstorming and categorization
- **Frame** - Grouping related elements into named sections
- **Star/Heart/Cloud** - Emphasis markers and decorative elements

### Drawing a Research Framework Diagram

A typical research conceptual framework can be constructed using tldraw's shape tools.

```
Example: Conceptual Framework for Mixed-Methods Study

1. Create a Frame labeled "Research Design"
2. Add rectangles for each research phase:
   - "Literature Review" -> "Hypothesis Formation"
   - "Quantitative Study" -> "Statistical Analysis"
   - "Qualitative Study" -> "Thematic Analysis"
   - "Integration" -> "Conclusions"
3. Connect phases with arrows showing sequence and relationships
4. Use color coding:
   - Blue rectangles: quantitative components
   - Green rectangles: qualitative components
   - Purple rectangles: integration points
5. Add text labels for key variables and relationships
6. Use sticky notes for annotations about methods and tools
```

### Collaborative Research Sessions

tldraw supports real-time collaboration when deployed with its sync backend, making it ideal for remote research meetings.

```tsx
import { Tldraw, createTLStore } from 'tldraw';
import { useSync } from '@tldraw/sync';

function CollaborativeWhiteboard({ roomId }) {
  const store = useSync({
    uri: `wss://collaboration-server.lab.internal/connect/${roomId}`,
    assets: { /* asset configuration */ }
  });

  return (
    <div style={{ width: '100%', height: '80vh' }}>
      <Tldraw store={store} />
    </div>
  );
}
```

## Custom Shapes for Domain-Specific Diagrams

One of tldraw's most powerful features for research is the ability to define custom shapes. Researchers can create domain-specific visual elements.

### Defining a Custom Research Node Shape

```tsx
import {
  ShapeUtil,
  TLBaseShape,
  HTMLContainer,
  BaseBoxShapeUtil,
} from 'tldraw';

// Define the shape type
type ResearchNodeShape = TLBaseShape<
  'research-node',
  {
    w: number;
    h: number;
    label: string;
    nodeType: 'hypothesis' | 'method' | 'finding' | 'conclusion';
    status: 'planned' | 'in-progress' | 'complete';
  }
>;

// Color map for node types
const nodeColors = {
  hypothesis: '#3B82F6',
  method: '#10B981',
  finding: '#F59E0B',
  conclusion: '#EF4444',
};

const statusIcons = {
  planned: '[ ]',
  'in-progress': '[~]',
  complete: '[x]',
};

class ResearchNodeUtil extends BaseBoxShapeUtil<ResearchNodeShape> {
  static override type = 'research-node' as const;

  getDefaultProps(): ResearchNodeShape['props'] {
    return {
      w: 200,
      h: 80,
      label: 'New Node',
      nodeType: 'hypothesis',
      status: 'planned',
    };
  }

  component(shape: ResearchNodeShape) {
    const { label, nodeType, status } = shape.props;
    const color = nodeColors[nodeType];

    return (
      <HTMLContainer>
        <div style={{
          width: '100%',
          height: '100%',
          backgroundColor: color + '20',
          border: `2px solid ${color}`,
          borderRadius: '8px',
          padding: '8px 12px',
          display: 'flex',
          flexDirection: 'column',
          justifyContent: 'center',
          fontFamily: 'Inter, sans-serif',
        }}>
          <div style={{ fontSize: '10px', color: color, fontWeight: 600 }}>
            {nodeType.toUpperCase()} {statusIcons[status]}
          </div>
          <div style={{ fontSize: '13px', color: '#1F2937', marginTop: '4px' }}>
            {label}
          </div>
        </div>
      </HTMLContainer>
    );
  }

  indicator(shape: ResearchNodeShape) {
    return (
      <rect
        width={shape.props.w}
        height={shape.props.h}
        rx={8}
        ry={8}
      />
    );
  }
}
```

### Registering Custom Shapes

```tsx
import { Tldraw } from 'tldraw';

const customShapeUtils = [ResearchNodeUtil];

function ResearchDiagramEditor() {
  return (
    <Tldraw
      shapeUtils={customShapeUtils}
      tools={[/* custom tools */]}
    />
  );
}
```

## Research Diagram Templates

### Literature Review Mind Map

Use tldraw to create a visual literature map during systematic reviews:

```
Structure:
- Central node: Research Question
- Branch 1: Theoretical Frameworks
  - Sub-nodes for each major theory
  - Connections showing relationships between theories
- Branch 2: Key Findings
  - Grouped by theme or methodology
  - Color-coded by strength of evidence
- Branch 3: Research Gaps
  - Identified gaps linked to existing literature
  - Arrows pointing to proposed research directions
```

### Experimental Design Flowchart

```
Layout:
1. Start: "Research Question"
2. Diamond: "Experimental or Observational?"
3. Branch A (Experimental):
   - "Control Group Definition"
   - "Treatment Conditions"
   - "Randomization Strategy"
   - "Measurement Protocol"
4. Branch B (Observational):
   - "Sampling Frame"
   - "Data Collection Method"
   - "Confound Identification"
5. Merge: "Data Analysis Plan"
6. End: "Expected Outcomes"
```

### System Architecture Diagram

For computational research papers that need to illustrate software architecture:

```
Components arranged in layers:
- Top: User Interface (web dashboard, CLI)
- Middle: Application Logic (API server, task scheduler)
- Bottom: Data Layer (database, file storage, cache)
- Side: External Services (cloud APIs, instrument interfaces)
- Arrows showing data flow between components
- Color coding for different deployment environments
```

## Exporting Diagrams for Publications

### Export as SVG (Vector)

tldraw supports exporting the canvas or selected shapes as SVG, which is ideal for publication figures.

```tsx
import { Editor } from 'tldraw';

async function exportDiagram(editor: Editor) {
  // Export selected shapes or entire page
  const shapeIds = editor.getSelectedShapeIds();
  const svg = await editor.getSvg(
    shapeIds.length > 0 ? shapeIds : undefined,
    { background: true, padding: 20 }
  );

  if (svg) {
    const svgString = new XMLSerializer().serializeToString(svg);
    const blob = new Blob([svgString], { type: 'image/svg+xml' });
    const url = URL.createObjectURL(blob);

    const link = document.createElement('a');
    link.href = url;
    link.download = 'research-diagram.svg';
    link.click();
    URL.revokeObjectURL(url);
  }
}
```

### Export as PNG (Raster)

```tsx
async function exportAsPng(editor: Editor) {
  const blob = await editor.toImage(
    editor.getSelectedShapeIds(),
    { type: 'png', quality: 1, scale: 3, background: true }
  );

  const url = URL.createObjectURL(blob);
  const link = document.createElement('a');
  link.href = url;
  link.download = 'research-diagram.png';
  link.click();
  URL.revokeObjectURL(url);
}
```

## Programmatic Diagram Generation

For reproducible research diagrams, tldraw's API allows programmatic shape creation.

```tsx
function generateMethodologyDiagram(editor: Editor, steps: string[]) {
  const startX = 100;
  const startY = 100;
  const boxWidth = 200;
  const boxHeight = 60;
  const gap = 40;

  steps.forEach((step, index) => {
    const y = startY + index * (boxHeight + gap);

    // Create a box for each step
    editor.createShape({
      type: 'geo',
      x: startX,
      y: y,
      props: {
        geo: 'rectangle',
        w: boxWidth,
        h: boxHeight,
        text: step,
        fill: 'semi',
        color: 'blue',
      },
    });

    // Connect to next step with an arrow
    if (index < steps.length - 1) {
      editor.createShape({
        type: 'arrow',
        props: {
          start: { x: startX + boxWidth / 2, y: y + boxHeight },
          end: { x: startX + boxWidth / 2, y: y + boxHeight + gap },
        },
      });
    }
  });

  editor.zoomToFit();
}

// Usage
generateMethodologyDiagram(editor, [
  'Data Collection',
  'Preprocessing',
  'Feature Extraction',
  'Model Training',
  'Evaluation',
  'Publication',
]);
```

## References

- tldraw official site: https://tldraw.com
- tldraw GitHub repository: https://github.com/tldraw/tldraw
- tldraw SDK documentation: https://tldraw.dev
- tldraw examples: https://github.com/tldraw/tldraw/tree/main/apps/examples

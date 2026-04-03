---
name: scientific-illustration-guide
description: "Create graphical abstracts, schematic diagrams, and scientific illustrations"
metadata:
  openclaw:
    emoji: "🖍️"
    category: "tools"
    subcategory: "diagram"
    keywords: ["scientific illustration", "graphical abstract", "schematic diagram", "architecture diagram", "vector graphics"]
    source: "wentor"
---

# Scientific Illustration Guide

A skill for creating clear, professional scientific illustrations including graphical abstracts, schematic diagrams, workflow visualizations, and architecture diagrams. Covers both programmatic and design tool approaches.

## Graphical Abstract Design

### Composition Principles

```
Layout Guidelines for Graphical Abstracts:
  - Dimensions: typically 500x300px to 1200x800px (check journal spec)
  - Flow direction: left-to-right or top-to-bottom
  - Maximum 5-7 visual elements
  - Use arrows to show process flow
  - Include 1-2 key data points or results
  - Minimal text (30-50 words maximum)
  - Consistent color scheme (3-4 colors)

Structure:
  [Input/Problem] --> [Method/Process] --> [Output/Finding]
```

### Programmatic Diagrams with Python

```python
import matplotlib.pyplot as plt
import matplotlib.patches as patches
from matplotlib.patches import FancyBboxPatch, FancyArrowPatch

def create_workflow_diagram(steps: list[dict], output: str = 'workflow.pdf'):
    """
    Create a horizontal workflow diagram.

    Args:
        steps: List of dicts with 'label', 'color', and optional 'sublabel'
        output: Output file path
    """
    fig, ax = plt.subplots(figsize=(12, 3))
    n = len(steps)
    box_width = 0.12
    gap = (1 - n * box_width) / (n + 1)

    for i, step in enumerate(steps):
        x = gap + i * (box_width + gap)
        y = 0.3

        # Draw box
        box = FancyBboxPatch(
            (x, y), box_width, 0.4,
            boxstyle="round,pad=0.01",
            facecolor=step.get('color', '#3B82F6'),
            edgecolor='#1E293B',
            linewidth=1.5,
            alpha=0.9
        )
        ax.add_patch(box)

        # Add label
        ax.text(x + box_width/2, y + 0.2, step['label'],
                ha='center', va='center', fontsize=9,
                fontweight='bold', color='white')

        if 'sublabel' in step:
            ax.text(x + box_width/2, y - 0.08, step['sublabel'],
                    ha='center', va='center', fontsize=7, color='#475569')

        # Draw arrow to next step
        if i < n - 1:
            ax.annotate('', xy=(x + box_width + gap*0.2, 0.5),
                        xytext=(x + box_width + gap*0.8, 0.5),
                        arrowprops=dict(arrowstyle='->', color='#64748B',
                                       lw=1.5))

    ax.set_xlim(0, 1)
    ax.set_ylim(0, 1)
    ax.axis('off')
    fig.savefig(output, dpi=300, bbox_inches='tight',
                facecolor='white', edgecolor='none')
    plt.close()
    return output

# Example: research pipeline
steps = [
    {'label': 'Data\nCollection', 'color': '#3B82F6', 'sublabel': 'N=1,200'},
    {'label': 'Preprocessing', 'color': '#6366F1', 'sublabel': 'QC + Filtering'},
    {'label': 'Analysis', 'color': '#8B5CF6', 'sublabel': 'ML Pipeline'},
    {'label': 'Validation', 'color': '#A855F7', 'sublabel': 'Cross-validation'},
    {'label': 'Results', 'color': '#EC4899', 'sublabel': 'AUC = 0.92'}
]
create_workflow_diagram(steps, 'research_pipeline.pdf')
```

## Schematic Diagrams

### System Architecture Diagrams

```python
import matplotlib.pyplot as plt
from matplotlib.patches import FancyBboxPatch, FancyArrowPatch

def create_architecture_diagram(components: list[dict],
                                  connections: list[tuple],
                                  output: str = 'architecture.pdf'):
    """
    Create a system architecture diagram.

    Args:
        components: List of {'name', 'x', 'y', 'width', 'height', 'color', 'type'}
        connections: List of (source_name, target_name, label) tuples
    """
    fig, ax = plt.subplots(figsize=(10, 7))

    # Draw components
    comp_positions = {}
    for comp in components:
        x, y = comp['x'], comp['y']
        w, h = comp.get('width', 1.5), comp.get('height', 0.8)
        color = comp.get('color', '#3B82F6')

        if comp.get('type') == 'database':
            # Cylinder shape for databases
            ellipse_h = 0.15
            ax.add_patch(patches.Rectangle((x, y), w, h-ellipse_h,
                         facecolor=color, edgecolor='#1E293B', linewidth=1.2))
            ax.add_patch(patches.Ellipse((x+w/2, y+h-ellipse_h), w, ellipse_h*2,
                         facecolor=color, edgecolor='#1E293B', linewidth=1.2))
            ax.add_patch(patches.Ellipse((x+w/2, y), w, ellipse_h*2,
                         facecolor=color, edgecolor='#1E293B', linewidth=1.2))
        else:
            box = FancyBboxPatch((x, y), w, h,
                                  boxstyle="round,pad=0.05",
                                  facecolor=color, edgecolor='#1E293B',
                                  linewidth=1.2, alpha=0.9)
            ax.add_patch(box)

        ax.text(x + w/2, y + h/2, comp['name'],
                ha='center', va='center', fontsize=10,
                fontweight='bold', color='white')

        comp_positions[comp['name']] = (x + w/2, y + h/2, w, h)

    # Draw connections
    for src, tgt, label in connections:
        sx, sy, sw, sh = comp_positions[src]
        tx, ty, tw, th = comp_positions[tgt]

        ax.annotate('', xy=(tx, ty + th/2 if sy > ty else ty - th/2),
                    xytext=(sx, sy - sh/2 if sy > ty else sy + sh/2),
                    arrowprops=dict(arrowstyle='->', color='#64748B',
                                   lw=1.5, connectionstyle='arc3,rad=0.1'))

        mid_x = (sx + tx) / 2
        mid_y = (sy + ty) / 2
        if label:
            ax.text(mid_x + 0.1, mid_y, label, fontsize=7, color='#475569')

    ax.set_xlim(-0.5, 10)
    ax.set_ylim(-0.5, 8)
    ax.set_aspect('equal')
    ax.axis('off')
    fig.savefig(output, dpi=300, bbox_inches='tight',
                facecolor='white')
    plt.close()
```

## Vector Graphics with Drawio

For complex diagrams, use draw.io (diagrams.net) which exports to SVG, PDF, and PNG:

```xml
<!-- Example draw.io XML structure -->
<mxGraphModel>
  <root>
    <mxCell id="0"/>
    <mxCell id="1" parent="0"/>
    <mxCell id="2" value="Data Source" style="rounded=1;fillColor=#3B82F6;
            fontColor=#FFFFFF;strokeColor=#1E40AF;" vertex="1" parent="1">
      <mxGeometry x="80" y="80" width="120" height="60" as="geometry"/>
    </mxCell>
  </root>
</mxGraphModel>
```

### Recommended Tools by Diagram Type

| Diagram Type | Best Tool | Output Format | Learning Curve |
|-------------|-----------|---------------|----------------|
| Flowcharts | draw.io / Mermaid | SVG, PDF | Low |
| Molecular structures | ChemDraw / RDKit | SVG, PNG | Medium |
| Biological pathways | BioRender / KEGG | PNG, SVG | Low |
| Network graphs | Cytoscape / NetworkX | SVG, PDF | Medium |
| 3D protein structures | PyMOL / ChimeraX | PNG, TIFF | High |
| Circuit diagrams | KiCad / CircuiTikZ | PDF, SVG | Medium |
| Math diagrams | TikZ/PGF | PDF | High |
| UML diagrams | PlantUML / Mermaid | SVG, PNG | Low |

## Color and Accessibility

Use colorblind-safe palettes consistently. The key rules:

1. Never use red and green together to encode different categories
2. Use both color and shape/pattern to distinguish elements
3. Ensure sufficient contrast (WCAG AA: 4.5:1 ratio for text)
4. Test your diagram in grayscale to verify it remains interpretable
5. Label elements directly rather than relying solely on a color legend

## Export and Journal Compliance

- Export vector formats (SVG, PDF, EPS) for line art and diagrams
- Minimum 300 DPI for raster elements within diagrams
- Embed fonts or convert text to paths in final SVG/PDF
- Check journal-specific requirements for graphical abstract dimensions and file size
- Name files following journal convention (e.g., "Figure_1.pdf", "graphical_abstract.tiff")

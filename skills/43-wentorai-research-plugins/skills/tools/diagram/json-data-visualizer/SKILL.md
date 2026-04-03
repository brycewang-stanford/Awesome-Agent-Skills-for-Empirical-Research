---
name: json-data-visualizer
description: "Guide to JSON Crack for visualizing complex JSON data structures"
metadata:
  openclaw:
    emoji: "🌳"
    category: "tools"
    subcategory: "diagram"
    keywords: ["JSON visualization", "data structure diagram", "tree visualization", "API response viewer", "schema explorer"]
    source: "https://github.com/AykutSarac/jsoncrack.com"
---

# JSON Crack Data Visualizer Guide

## Overview

JSON Crack (formerly JSON Visio) is an open-source data visualization tool with over 43K stars on GitHub that transforms JSON, YAML, XML, TOML, and CSV data into interactive graph diagrams. Instead of reading raw nested data structures, researchers can instantly see the hierarchical relationships, nested objects, and array structures as a navigable node-link diagram rendered on an infinite canvas.

For academic researchers, JSON Crack is particularly valuable when working with complex API responses, configuration files, experimental metadata schemas, and nested data exports. Bioinformatics researchers dealing with deeply nested gene ontology JSON files, social scientists working with survey platform API responses, and computational researchers inspecting machine learning model configuration files all benefit from being able to see their data structures visually rather than scrolling through thousands of lines of text.

The tool is available as a hosted web application at jsoncrack.com, as a self-hosted Docker deployment for institutional use, and as an embeddable React component that can be integrated into custom research tools. It also provides an API for programmatic access, making it suitable for integration into data processing pipelines.

## Getting Started

### Web Application Usage

The fastest way to use JSON Crack is through the web interface. Paste or upload JSON data and the visualization renders immediately.

### Self-Hosted Deployment for Research Labs

```bash
# Clone the repository
git clone https://github.com/AykutSarac/jsoncrack.com.git
cd jsoncrack.com

# Install dependencies
npm install

# Start development server
npm run dev

# Or build and serve for production
npm run build
npm start
```

### Docker Deployment

```bash
# Run with Docker
docker run -d -p 8888:8080 \
  --name json-crack \
  --restart unless-stopped \
  jsoncrack/jsoncrack

# Access at http://localhost:8888
```

### Docker Compose for Lab Infrastructure

```yaml
version: "3.8"
services:
  json-crack:
    image: jsoncrack/jsoncrack
    container_name: json-crack
    ports:
      - "8888:8080"
    restart: unless-stopped
```

## Visualizing Research Data Structures

### Experimental Metadata Schema

Researchers frequently work with complex nested JSON structures for experimental metadata. JSON Crack makes these immediately readable.

```json
{
  "experiment": {
    "id": "EXP-2026-0142",
    "title": "Effect of Temperature on Protein Folding Kinetics",
    "principal_investigator": {
      "name": "Dr. Jane Smith",
      "orcid": "0000-0002-1234-5678",
      "affiliation": "Department of Biochemistry"
    },
    "protocol": {
      "version": "3.2",
      "steps": [
        {
          "order": 1,
          "name": "Sample Preparation",
          "duration_minutes": 120,
          "equipment": ["centrifuge", "spectrophotometer"],
          "parameters": {
            "temperature_celsius": 25,
            "buffer_ph": 7.4,
            "concentration_mm": 0.5
          }
        },
        {
          "order": 2,
          "name": "Thermal Denaturation",
          "duration_minutes": 180,
          "temperature_range": {
            "start": 25,
            "end": 95,
            "step": 1,
            "unit": "celsius"
          }
        },
        {
          "order": 3,
          "name": "Data Acquisition",
          "instrument": "circular_dichroism_spectrometer",
          "wavelength_range_nm": [190, 260]
        }
      ]
    },
    "samples": [
      {
        "id": "S001",
        "condition": "wild_type",
        "replicates": 3,
        "measurements": {
          "tm_celsius": 68.2,
          "delta_h_kcal": -45.3,
          "r_squared": 0.997
        }
      }
    ]
  }
}
```

When loaded into JSON Crack, this structure displays as an interactive tree diagram where each nested object becomes a card node, arrays show their elements as connected child nodes, and researchers can click to expand or collapse sections for focused exploration.

### API Response Inspection

When working with research APIs (PubMed, CrossRef, OpenAlex, etc.), responses are often deeply nested. JSON Crack helps researchers understand the response schema before writing parsing code.

```python
import requests
import json

# Fetch metadata from CrossRef API
response = requests.get(
    "https://api.crossref.org/works/10.1038/nature12373"
)
data = response.json()

# Save for visualization in JSON Crack
with open("crossref_response.json", "w") as f:
    json.dump(data, f, indent=2)

# Open crossref_response.json in JSON Crack to explore the schema
# This reveals the nested structure of author arrays, funding info,
# reference lists, and license metadata
```

## Embedding in Research Applications

JSON Crack provides a React component that can be embedded in custom research tools.

### React Component Integration

```tsx
import { JsonCrackEmbed } from "jsoncrack-react";
import { useState } from "react";

function DataSchemaViewer({ experimentData }) {
  const [jsonContent, setJsonContent] = useState(
    JSON.stringify(experimentData, null, 2)
  );

  return (
    <div style={{ width: "100%", height: "600px" }}>
      <h3>Experiment Data Schema</h3>
      <JsonCrackEmbed
        json={jsonContent}
        style={{ width: "100%", height: "100%" }}
      />
    </div>
  );
}
```

### Embedding via iframe

```html
<iframe
  src="https://jsoncrack.internal.lab/widget"
  width="100%"
  height="600"
  style="border: 1px solid #e5e7eb; border-radius: 8px;"
></iframe>
```

## Supported Data Formats

JSON Crack handles multiple data serialization formats commonly used in research.

### JSON

The primary format. Supports nested objects, arrays, primitives, and null values. JSON Schema validation is available to verify data conforms to expected structures.

### YAML

Common in configuration files for research software, CI/CD pipelines, and computational workflow definitions (e.g., Snakemake, Nextflow configs).

```yaml
pipeline:
  name: rnaseq-analysis
  steps:
    - name: quality-control
      tool: fastqc
      input: raw_reads/*.fastq.gz
    - name: trimming
      tool: trimmomatic
      parameters:
        min_length: 36
        quality_threshold: 20
    - name: alignment
      tool: star
      genome_index: /ref/hg38
```

### CSV

Tabular data from experiments and surveys can be visualized to understand column relationships and data types.

### TOML

Used in Python project configuration (pyproject.toml), Rust cargo files, and various research tool configurations.

## Practical Research Workflows

### Schema Documentation

Use JSON Crack to generate visual documentation of your lab's data schemas. Export the visualization as an image for inclusion in lab manuals, onboarding documents, or data management plans.

### API Development

When building research APIs with FastAPI or Flask, use JSON Crack to visualize and verify your API response structures during development.

### Data Validation

Before processing large datasets, visualize a sample record in JSON Crack to verify the structure matches expectations. This is faster than writing validation code for initial inspection.

### Comparing Data Versions

When data schemas evolve between experiment versions, visualize both versions side-by-side to identify structural differences and plan migration logic.

## Keyboard Shortcuts and Tips

- **Ctrl+Shift+D** - Toggle dark/light mode
- **Ctrl+Shift+F** - Format/prettify the input data
- **Ctrl+Shift+C** - Compact the input data
- **Mouse wheel** - Zoom in/out on the diagram
- **Click and drag** - Pan the canvas
- **Click a node** - Highlight the path from root to that node
- **Search** - Find specific keys or values in the graph

## References

- JSON Crack website: https://jsoncrack.com
- JSON Crack GitHub: https://github.com/AykutSarac/jsoncrack.com
- JSON Crack React embed: https://www.npmjs.com/package/jsoncrack-react
- JSON Crack VS Code extension: available in VS Code Marketplace

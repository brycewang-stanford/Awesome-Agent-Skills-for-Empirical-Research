---
name: opencontracts-guide
description: "Legal document annotation, versioning, and analysis platform"
metadata:
  openclaw:
    emoji: "📋"
    category: "domains"
    subcategory: "law"
    keywords: ["legal documents", "contract annotation", "document versioning", "legal AI", "NLP legal", "MCP"]
    source: "https://github.com/Open-Source-Legal/OpenContracts"
---

# OpenContracts Guide

## Overview

OpenContracts is an open-source platform for legal document annotation, versioning, and analysis. It provides collaborative annotation tools for legal text, version tracking across document drafts, NLP-powered clause extraction, and integration with AI agents via MCP. Designed for legal researchers, law firms, and teams managing large document collections that need structured annotation and analysis.

## Installation

```bash
# Docker deployment
git clone https://github.com/Open-Source-Legal/OpenContracts.git
cd OpenContracts
docker-compose up -d

# Access at http://localhost:3000
```

## Core Features

### Document Management

```python
from opencontracts import Client

client = Client("http://localhost:3000")

# Upload documents
doc = client.upload(
    file="contract.pdf",
    metadata={
        "type": "NDA",
        "parties": ["Company A", "Company B"],
        "date": "2025-01-15",
        "jurisdiction": "Delaware",
    },
)

# Version tracking
versions = client.get_versions(doc.id)
for v in versions:
    print(f"v{v.number}: {v.date} — {v.changes_summary}")

# Compare versions
diff = client.compare_versions(doc.id, v1=1, v2=3)
for change in diff.changes:
    print(f"[{change.type}] Section {change.section}: "
          f"{change.description}")
```

### Annotation

```python
# Create annotation project
project = client.create_project(
    name="NDA Clause Analysis",
    documents=[doc.id],
    label_set=[
        "confidentiality_scope",
        "term_duration",
        "exclusions",
        "remedies",
        "governing_law",
        "dispute_resolution",
    ],
)

# Add annotations
client.annotate(
    document_id=doc.id,
    annotations=[
        {
            "start": 1250, "end": 1480,
            "label": "confidentiality_scope",
            "note": "Broad definition including derivatives",
        },
        {
            "start": 2100, "end": 2250,
            "label": "term_duration",
            "note": "5-year term with auto-renewal",
        },
    ],
)
```

### NLP Analysis

```python
# Automated clause extraction
clauses = client.extract_clauses(
    doc.id,
    clause_types=[
        "indemnification",
        "limitation_of_liability",
        "termination",
        "force_majeure",
        "assignment",
    ],
)

for clause in clauses:
    print(f"\n[{clause.type}] (confidence: {clause.confidence:.2f})")
    print(f"  Location: p.{clause.page}, para {clause.paragraph}")
    print(f"  Text: {clause.text[:100]}...")

# Risk assessment
risks = client.assess_risks(doc.id)
for risk in risks:
    print(f"[{risk.severity}] {risk.clause}: {risk.description}")
```

### MCP Integration

```json
{
  "mcpServers": {
    "opencontracts": {
      "command": "npx",
      "args": ["@opencontracts/mcp-server"],
      "env": {
        "OPENCONTRACTS_URL": "http://localhost:3000"
      }
    }
  }
}
```

## Search and Analytics

```python
# Full-text search across documents
results = client.search(
    query="indemnification unlimited liability",
    document_types=["NDA", "MSA"],
    date_range=("2024-01-01", "2025-12-31"),
)

# Analytics
stats = client.analytics(project_id=project.id)
print(f"Documents annotated: {stats.docs_complete}")
print(f"Total annotations: {stats.total_annotations}")
print(f"Inter-annotator agreement: {stats.agreement:.2f}")
print(f"Most common clause: {stats.top_clauses[0]}")
```

## Use Cases

1. **Contract review**: Systematic clause analysis and risk assessment
2. **Legal research**: Annotate case law and legislation
3. **Compliance**: Track regulatory document requirements
4. **Training data**: Build labeled datasets for legal NLP
5. **Due diligence**: Structured review of deal documents

## References

- [OpenContracts GitHub](https://github.com/Open-Source-Legal/OpenContracts)
- [Legal NLP Resources](https://github.com/thunlp/LegalPapers)

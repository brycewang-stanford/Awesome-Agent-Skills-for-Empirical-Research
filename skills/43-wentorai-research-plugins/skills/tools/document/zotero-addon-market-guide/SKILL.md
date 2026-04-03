---
name: zotero-addon-market-guide
description: "Plugin marketplace and discovery platform for Zotero"
metadata:
  openclaw:
    emoji: "🏪"
    category: "tools"
    subcategory: "document"
    keywords: ["Zotero", "plugin marketplace", "add-ons", "plugin discovery", "extension manager"]
    source: "https://github.com/syt2/zotero-addons"
---

# Zotero Add-on Market Guide

## Overview

Zotero Add-ons is a plugin marketplace and discovery platform for Zotero 7 that provides a centralized hub to browse, install, and manage Zotero plugins. Instead of manually finding .xpi files on GitHub, researchers can search, filter, and one-click install plugins directly within Zotero. Tracks plugin compatibility, update status, and user ratings.

## Installation

```bash
# Download .xpi from GitHub releases
# Zotero 7: Tools → Add-ons → Install Add-on From File

# After installation: Tools → Add-on Market
```

## Features

```markdown
### Plugin Discovery
- Browse all available Zotero 7 plugins
- Search by name, category, or keyword
- Filter: compatible version, update date, popularity
- Plugin descriptions with screenshots

### Categories
- **Reference Management**: Better BibTeX, DOI Manager
- **PDF Tools**: PDF Translate, Sci-Hub, annotations
- **Organization**: Style, Actions & Tags, ZotMoov
- **Integration**: Notero, Obsidian, Logseq connectors
- **UI Enhancement**: Night theme, custom columns
- **Automation**: Actions & Tags, batch operations

### Management
- One-click install from marketplace
- Auto-update notifications
- Compatibility warnings
- Disable/enable without uninstall
- Bulk update all plugins
```

## Recommended Plugin Stack

```markdown
### Essential Stack for Researchers

1. **Zotero Connector** (built-in) — Browser import
2. **Better BibTeX** — Citation key management
3. **Zotero Style** — Custom columns, visual tags
4. **Zotero PDF Translate** — In-reader translation
5. **ZotMoov** — Attachment organization
6. **Zotero Actions & Tags** — Workflow automation

### Extended Stack

7. **Zotero Night** — Dark mode
8. **Zoplicate** — Deduplication
9. **Zotero Sci-Hub** — PDF retrieval fallback
10. **Notero** — Notion sync
11. **Zotero AI Butler** — AI summarization

### For Specific Workflows

- **Systematic reviews**: Zoplicate + Actions & Tags
- **LaTeX writing**: Better BibTeX + Style
- **Knowledge management**: Notero + Zotero-Obsidian
- **International**: PDF Translate + multi-language support
```

## Plugin Development

```markdown
### Creating Zotero 7 Plugins

1. Use zotero-plugin-template (scaffolding)
2. Write in TypeScript/JavaScript
3. Package as .xpi (ZIP with manifest)
4. Submit to zotero-addons registry

### Plugin Template
- Source: github.com/windingwind/zotero-plugin-template
- Includes: build setup, hot reload, bootstrap code
- Supports: Zotero 7 APIs, Fluent localization
```

## Use Cases

1. **Plugin discovery**: Find plugins for your research workflow
2. **Stack building**: Assemble optimized plugin combinations
3. **Updates**: Keep all plugins current and compatible
4. **Development**: Starting point for creating Zotero plugins

## References

- [Zotero Add-ons GitHub](https://github.com/syt2/zotero-addons)
- [Zotero Plugin Template](https://github.com/windingwind/zotero-plugin-template)
- [Zotero 7 Plugin Development](https://www.zotero.org/support/dev/client_coding/plugin_development)

---
name: zoplicate-dedup-guide
description: "Detect and manage duplicate items in Zotero libraries"
metadata:
  openclaw:
    emoji: "🔃"
    category: "literature"
    subcategory: "metadata"
    keywords: ["Zotero", "deduplication", "duplicate detection", "library cleanup", "metadata merge"]
    source: "https://github.com/ChenglongMa/zoplicate"
---

# Zoplicate: Zotero Deduplication Guide

## Overview

Zoplicate is a Zotero plugin that detects and manages duplicate items in your library. It goes beyond Zotero's built-in duplicate detection by offering configurable matching criteria, batch merge operations, automatic deduplication on import, and smart metadata merging that keeps the best version of each field. Essential for researchers who import from multiple databases.

## Installation

```bash
# Download .xpi from GitHub releases
# Zotero 7: Tools → Add-ons → Install Add-on From File
```

## Features

```markdown
### Duplicate Detection
- **DOI matching** — Most reliable, catches exact duplicates
- **Title similarity** — Fuzzy matching for slight variations
- **ISBN matching** — For books and proceedings
- **Combined scoring** — Weighted match across multiple fields

### Smart Merge
- Keep the most complete metadata from each duplicate
- Preserve all tags from both items
- Merge notes and annotations
- Consolidate attachments (keep all unique PDFs)
- Maintain collection memberships from both

### Automatic Mode
- Detect duplicates on import
- Configurable auto-merge threshold
- Notification before auto-merge (optional)
```

## Configuration

```json
{
  "detection": {
    "criteria": {
      "doi": {"enabled": true, "weight": 1.0},
      "title": {"enabled": true, "weight": 0.8,
                 "similarity_threshold": 0.85},
      "isbn": {"enabled": true, "weight": 1.0},
      "year_author": {"enabled": true, "weight": 0.6}
    },
    "overall_threshold": 0.7,
    "ignore_case": true,
    "normalize_unicode": true
  },
  "merge": {
    "strategy": "keep_most_complete",
    "preserve_tags": true,
    "merge_notes": true,
    "keep_all_attachments": true,
    "prefer_fields_from": "newer"
  },
  "auto": {
    "detect_on_import": true,
    "auto_merge": false,
    "notify_on_detect": true
  }
}
```

## Usage Workflow

```markdown
### Manual Deduplication
1. Tools → Zoplicate → Find Duplicates
2. Review duplicate groups (side-by-side comparison)
3. Select master item for each group
4. Click "Merge" — metadata combined, duplicates removed

### Batch Operations
1. Tools → Zoplicate → Find All Duplicates
2. Review summary (X groups, Y total duplicates)
3. "Auto-select best" — picks master by completeness
4. "Merge All" — batch process all groups

### Import Deduplication
1. Import papers from database export (RIS, BibTeX)
2. Zoplicate auto-checks against existing library
3. Popup shows potential duplicates
4. Choose: Skip / Merge / Import as new
```

## Matching Examples

```markdown
### DOI Match (100% confidence)
Item A: "Attention Is All You Need" — DOI: 10.48550/arXiv.1706.03762
Item B: "Attention is All You Need" — DOI: 10.48550/arXiv.1706.03762
→ Exact duplicate (same DOI)

### Title Fuzzy Match (85% similarity)
Item A: "BERT: Pre-training of Deep Bidirectional Transformers..."
Item B: "Bert: Pre-Training of Deep Bidirectional Transformers..."
→ Likely duplicate (title similarity > threshold)

### Different Versions (not duplicate)
Item A: "Paper Title" (arXiv v1, 2023)
Item B: "Paper Title" (Published version, 2024)
→ Different DOIs, may want to keep both or merge
```

## Integration Tips

```markdown
### Multi-Database Import Workflow
1. Search PubMed → Export RIS → Import to Zotero
2. Search Scopus → Export RIS → Import to Zotero
3. Search Web of Science → Export RIS → Import to Zotero
4. Zoplicate detects cross-database duplicates
5. Merge: keep best metadata from each source

### With Other Plugins
- **Zotero Connector** — Detect dups on browser import
- **Better BibTeX** — Preserve citation keys on merge
- **ZotMoov** — Reorganize attachments after merge
```

## Use Cases

1. **Library cleanup**: Remove duplicates from large collections
2. **Import dedup**: Prevent duplicates when importing from databases
3. **Systematic reviews**: Deduplicate multi-database search results
4. **Lab libraries**: Merge shared group library duplicates
5. **Migration**: Clean up after importing from other reference managers

## References

- [Zoplicate GitHub](https://github.com/ChenglongMa/zoplicate)
- [Zotero Duplicate Detection](https://www.zotero.org/support/duplicate_detection)

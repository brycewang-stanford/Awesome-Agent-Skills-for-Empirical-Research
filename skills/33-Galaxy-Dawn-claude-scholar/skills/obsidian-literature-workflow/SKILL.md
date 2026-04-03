---
name: obsidian-literature-workflow
description: Use this skill when the user keeps paper notes inside an Obsidian project knowledge base and wants filesystem-first literature review, explicit agent-first Zotero ingestion, `Papers/` plus `Knowledge/` synthesis, collection-wide normalization, and a default literature canvas without Obsidian MCP.
version: 0.5.0
---

# Obsidian Literature Workflow

Handle the **literature sub-workflow** inside the filesystem-first Obsidian project knowledge base.

## Role in the workflow

This is a **supporting skill** under `obsidian-project-memory`.

Use it when the user says things like:
- “My papers are in Obsidian”
- “Read papers from Zotero and create notes in the vault”
- “Review the notes under `Papers/`”
- “Generate literature knowledge notes from this project vault”
- “Connect paper notes to project knowledge”
- “Show me the literature structure as a map/graph”
- “Check whether all papers already have detailed notes”

## Assumptions

- The project is already bound through `.claude/project-memory/registry.yaml`, or can be imported with `obsidian-project-bootstrap`
- Durable paper notes live under `Papers/` inside `Research/{project-slug}/`
- Obsidian note writing is done through the filesystem; no Obsidian MCP is required
- Zotero may still be used as the source of metadata/full text; use `$zotero-obsidian-bridge` when the source corpus is in Zotero

## Default workflow

1. Read bound project memory and locate the vault root.
2. If the source papers are in Zotero, explicitly use `$zotero-obsidian-bridge` to pull them into canonical `Papers/*.md` notes.
3. Scan `Papers/` and adjacent synthesis notes using filesystem tools.
4. Normalize note metadata and structure using `$obsidian-markdown`.
   - Prefer the standardized review schema:
     - `Claim`
     - `Method`
     - `Evidence`
     - `Limitation`
     - `Direct relevance to repo`
     - `Relation to other papers`
5. Query narrowly first:
   - read the relevant paper notes,
   - then the linked `Knowledge/` notes,
   - and only then open `Writing/` if the user asked for a review or comparison deliverable.
6. Prefer updating existing paper notes and literature synthesis notes over creating sibling notes.
7. Default literature synthesis should land in `Knowledge/`, not `Experiments/` or `Results/`:
   - update `Knowledge/Literature-Overview.md`
   - update `Knowledge/Method-Families.md`
   - update `Knowledge/Research-Gaps.md`
   when the synthesis is stable enough to deserve canonical notes.
8. If the source is a named collection and the user cares about completeness, maintain a collection inventory note with explicit coverage mapping.
9. Refresh `Maps/literature.canvas` after major paper-note changes or batch note creation.
   - Prefer argument-map structure over dense all-to-all links.
   - Prefer semantic filtering and edge thinning.
   - Create `Maps/literature-main.canvas` only when a lightweight presentation graph is needed.
10. Update the daily note and project memory with what changed.

## Default outputs

- `Papers/` remains first-class: one durable paper note per paper whenever possible
- `Knowledge/` holds durable literature synthesis notes
- `Maps/literature.canvas` is the default visual graph surface
- literature work should usually produce at least one of:
  - new or updated paper notes,
  - new or updated knowledge notes,
  - literature-canvas refresh,
  - optional writing synthesis when requested

## Default stance

Do **not** assume by default:
- `Concepts/`
- `Datasets/`
- `.base` views

The literature workflow may create `Maps/literature.canvas` by default. Other artifacts still require explicit justification.

## References

Load only what is needed:
- `references/PAPER-NOTE-SCHEMA.md` - detailed paper-note frontmatter and sections
- `references/CANVAS-WORKFLOW.md` - how and when to refresh `Maps/literature.canvas`

---
name: zotero-obsidian-bridge
description: Use this skill when papers are collected in Zotero but the user wants detailed reading notes, project-linked literature synthesis, collection-wide paper-note coverage checks, and a connected knowledge map inside the bound Obsidian project knowledge base.
version: 0.2.0
---

# Zotero Obsidian Bridge

Bridge **Zotero as the literature source of truth** with **Obsidian as the durable project knowledge base**.

Use this skill when the user wants to:
- collect and organize papers in Zotero,
- read papers from Zotero MCP,
- create or update one detailed paper note per paper under Obsidian `Papers/`,
- synthesize those notes into `Knowledge/` notes,
- verify that a whole Zotero collection has complete canonical note coverage,
- visualize the literature structure as a default Obsidian canvas.

## Core stance

- Zotero owns **collection, metadata, attachments, PDF full text, annotations**.
- Obsidian owns **durable reading notes, project-facing literature knowledge, cross-note links, synthesis**.
- Prefer **one canonical paper note per paper**.
- Prefer **filesystem-first Obsidian notes**; do not require Obsidian MCP.
- Use this as an **explicit, agent-first skill** for Zotero ingestion.
- Prefer **`Papers/` + `Knowledge/`** as the default bridge targets.
- Prefer **`Maps/literature.canvas`** as the default graph artifact.
- Prefer a strong review schema inside each canonical paper note:
  - `Claim`
  - `Method`
  - `Evidence`
  - `Limitation`
  - `Direct relevance to repo`
  - `Relation to other papers`
- Treat some Zotero `webpage` items as valid literature sources when they still expose useful metadata, attachment text, or fulltext.

## Default workflow

1. Resolve the current project via `$obsidian-project-memory`.
   - If the repo is already bound, use the existing vault.
   - If it looks like a research repo but is not bound, bootstrap it first.
2. Read Zotero items from the target collection/query.
   - If the user asked for a full collection pass, prefer full coverage over a small representative subset.
   - If the transport path through MCP is failing but a local `zotero-mcp` source checkout or Python environment is available, use that local fallback to read metadata/fulltext instead of stopping the workflow.
3. For each paper:
   - get metadata,
   - get full text when available,
   - get annotations/notes when helpful,
   - create or update the canonical paper note in `Papers/`.
4. Add project-facing structure to each paper note:
   - claim,
   - research question,
   - method,
   - evidence,
   - strengths,
   - limitation,
   - direct relevance to repo,
   - relation to other papers,
   - links to related papers and the best matching `Knowledge/` notes.
5. Synthesize the batch into durable `Knowledge/` notes such as:
   - `Knowledge/Literature-Overview.md`
   - `Knowledge/Method-Families.md`
   - `Knowledge/Research-Gaps.md`
   only when the synthesis is stable enough to deserve a canonical note.
6. If the request is collection-scoped, update a durable inventory note that records:
   - collection size,
   - item triage,
   - item -> canonical note mapping,
   - current coverage count such as `16 / 16`.
   - use the canonical inventory path `Knowledge/Zotero-Collection-{collection-slug}-Inventory.md`.
7. Refresh `Maps/literature.canvas`.
   - Prefer semantic filtering and edge thinning.
   - Prefer argument-map structure (`paper + claim + method + gap`) over dense all-to-all paper links.
   - If needed, keep a second lightweight display canvas such as `Maps/literature-main.canvas`.
8. If the user also wants writing deliverables, update:
   - `Writing/literature-review.md`
   - `Writing/comparison-matrix.md`
9. Update today's `Daily/` note and repo-local project memory.
10. Run a deterministic verification pass after batch ingestion or schema refactors.

## Default outputs

- `Papers/*.md` - one detailed reading note per paper
- `Knowledge/*.md` - durable literature synthesis notes when the batch yields stable knowledge
- `Knowledge/Zotero-Collection-{collection-slug}-Inventory.md` - when the source is a concrete Zotero collection and coverage tracking matters
- `Maps/literature.canvas` - default visual literature graph
- `Maps/literature-main.canvas` - optional lightweight presentation graph after semantic filtering
- `Writing/literature-review.md` - when the user asks for synthesis
- `Writing/comparison-matrix.md` - when cross-paper comparison is useful

## Safety rules

- Do not dump raw full text into Obsidian.
- Do not create a new note if the canonical paper note already exists.
- Do not create `Concepts/` or `Datasets/` trees by default.
- Do not treat `Experiments/`, `Results/`, or `Writing/` as the default bridge target during Zotero ingestion.
- Do not force every relationship into a new note; use frontmatter fields, sections, wikilinks, and `linked_knowledge` first.
- If a relationship is uncertain, record it in the note body or `Daily/` instead of manufacturing durable structure.
- Do not stop at a representative subset if the user explicitly asked to check **all** papers in a collection.
- Do not leave schema drift unresolved across notes in the same collection after a batch pass.

## References

Load only what is needed:
- `references/WORKFLOW.md` - end-to-end Zotero -> Obsidian procedure
- `references/PAPER-NOTE-SCHEMA.md` - detailed paper note fields and sections
- `references/COLLECTION-INVENTORY-SCHEMA.md` - canonical inventory note naming and mapping contract
- `references/LOCAL-ZOTERO-FALLBACK.md` - local fallback runbook when MCP transport fails
- `examples/example-collection-inventory.md` - example inventory note
- `scripts/verify_paper_notes.py` - deterministic schema, zotero-key, and inventory consistency check
- `../obsidian-literature-workflow/references/PAPER-NOTE-SCHEMA.md` - shared note schema
- `../obsidian-literature-workflow/references/CANVAS-WORKFLOW.md` - default literature canvas refresh rules

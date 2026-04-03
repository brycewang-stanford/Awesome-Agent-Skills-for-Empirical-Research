# Local Zotero Fallback

Use this runbook when the Zotero MCP transport is unavailable but the user still wants a collection-level pass.

## Preconditions

- A local `zotero-mcp` checkout or installed Python package is available.
- The local environment can read metadata/fulltext without mutating the Zotero library.

## Default fallback sequence

1. Confirm that MCP transport is the failing layer, not the collection query itself.
2. Switch to the local Python-backed path for metadata and fulltext retrieval.
3. Continue creating or updating canonical paper notes.
4. Run `verify_paper_notes.py` before closing the batch.

## Report explicitly

Always state:
- that MCP transport failed,
- that the workflow continued through local fallback,
- what remained unavailable, if anything.

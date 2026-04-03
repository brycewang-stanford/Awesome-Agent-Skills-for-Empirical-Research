# Collection Inventory Schema

Use this note when a Zotero collection is imported or audited at collection scope.

## Canonical path

```text
Knowledge/Zotero-Collection-{collection-slug}-Inventory.md
```

## Frontmatter

```yaml
---
type: zotero-collection-inventory
collection: Cross Subject
collection_slug: cross-subject
source: zotero
coverage_expected: 16
coverage_actual: 16
updated: 2026-03-18T00:00:00Z
---
```

## Required sections

```markdown
# Cross Subject Inventory

## Coverage Summary
- Expected items: 16
- Canonical notes: 16 / 16

## Item Mapping
| Zotero Key | Item Title | Canonical Note | Status |
|---|---|---|---|
| ABCDEFGH | Example title | Papers/Example-Paper.md | covered |

## Triage
- fully covered
- skipped or bridge-only notes
- items that still need full notes
```

## Rules
- Keep one durable inventory note per collection slug.
- `Canonical Note` should use project-relative note paths.
- `Status` should use a small vocabulary such as `covered`, `bridge-only`, `skipped`, `needs-review`.
- Update coverage counts whenever the collection is batch-processed again.

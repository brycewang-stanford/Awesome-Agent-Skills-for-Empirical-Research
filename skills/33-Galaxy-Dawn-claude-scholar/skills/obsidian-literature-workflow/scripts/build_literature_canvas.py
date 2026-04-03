#!/usr/bin/env python3
from __future__ import annotations

import argparse
import hashlib
import json
import re
import sys
from dataclasses import dataclass
from pathlib import Path
from typing import Any

WIKILINK_RE = re.compile(r"\[\[([^\]|#]+)(?:#[^\]|]+)?(?:\|[^\]]+)?\]\]")
LIST_KEYS = {
    "authors",
    "keywords",
    "concepts",
    "methods",
    "related_papers",
    "linked_knowledge",
    "paper_relationships",
    "linked_papers",
    "argument_claims",
    "argument_methods",
    "argument_gaps",
    "linked_claims",
    "linked_methods",
    "linked_gaps",
    "claim_method_links",
    "method_gap_links",
}
PAPER_LIMIT = 48
KNOWLEDGE_LIMIT = 18
KNOWLEDGE_COLUMNS = 3
NODE_WIDTH = 300
NODE_HEIGHT = 180
ARG_NODE_WIDTH = 280
ARG_NODE_HEIGHT = 120
X_GAP = 80
Y_GAP = 70
GROUP_X_GAP = 180
GROUP_Y_GAP = 180
ARG_GROUP_X_GAP = 200
PAPER_RELATION_LIMIT = 2
PAPER_CLAIM_LIMIT = 1
PAPER_METHOD_LIMIT = 1
PAPER_RELATION_LIMIT = 1
SUBFIELD_ORDER = (
    "speech-transfer-constraints",
    "alignment-and-domain-adaptation",
    "geometry-and-representation",
    "subject-aware-adaptation",
    "other",
)
SUBFIELD_LABELS = {
    "speech-transfer-constraints": "Speech-specific transfer constraints",
    "alignment-and-domain-adaptation": "Alignment and domain adaptation",
    "geometry-and-representation": "Geometry and representation",
    "subject-aware-adaptation": "Subject-aware adaptation",
    "other": "Other papers",
}
SUBFIELD_COLORS = {
    "speech-transfer-constraints": "6",
    "alignment-and-domain-adaptation": "2",
    "geometry-and-representation": "5",
    "subject-aware-adaptation": "3",
    "other": "1",
}
SUBFIELD_COLUMNS = 2


@dataclass(frozen=True)
class NoteRecord:
    title: str
    note_relpath: str
    vault_relpath: str
    file_name: str
    related_papers: tuple[str, ...]
    linked_knowledge: tuple[str, ...]
    paper_relationships: tuple[tuple[str, str], ...]
    linked_papers: tuple[str, ...]
    claim_refs: tuple[str, ...]
    method_refs: tuple[str, ...]
    gap_refs: tuple[str, ...]
    claim_method_links: tuple[tuple[str, str, str], ...]
    method_gap_links: tuple[tuple[str, str, str], ...]
    wikilinks: tuple[str, ...]
    subfield: str
    canvas_visibility: str


def load_project_kb_module() -> Any:
    script_dir = Path(__file__).resolve().parents[2] / "obsidian-project-memory" / "scripts"
    sys.path.insert(0, str(script_dir))
    import project_kb  # type: ignore

    return project_kb


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Build a default literature canvas for the bound Obsidian project."
    )
    parser.add_argument("--cwd", default=".")
    parser.add_argument("--project-id", default="")
    parser.add_argument("--output", default="Maps/literature.canvas")
    return parser.parse_args()


def parse_frontmatter(text: str) -> dict[str, Any]:
    if not text.startswith("---\n"):
        return {}
    end = text.find("\n---\n", 4)
    if end == -1:
        return {}
    lines = text[4:end].splitlines()
    data: dict[str, Any] = {}
    current_key: str | None = None
    for raw_line in lines:
        if not raw_line.strip():
            continue
        if raw_line.startswith("  - ") or raw_line.startswith("- "):
            if current_key and current_key in LIST_KEYS:
                data.setdefault(current_key, []).append(
                    raw_line.split("- ", 1)[1].strip().strip('"')
                )
            continue
        if ":" not in raw_line:
            current_key = None
            continue
        key, value = raw_line.split(":", 1)
        key = key.strip()
        value = value.strip()
        current_key = key
        if not value:
            if key in LIST_KEYS:
                data[key] = []
            else:
                data[key] = ""
            continue
        data[key] = value.strip('"')
    return data


def body_without_frontmatter(text: str) -> str:
    if not text.startswith("---\n"):
        return text
    end = text.find("\n---\n", 4)
    if end == -1:
        return text
    return text[end + 5 :]


def normalize_note_target(value: str) -> str:
    cleaned = value.strip()
    if cleaned.endswith(".md"):
        cleaned = cleaned[:-3]
    if cleaned.startswith("./"):
        cleaned = cleaned[2:]
    return cleaned


def parse_relationship_entries(values: list[str]) -> tuple[tuple[str, str], ...]:
    parsed: list[tuple[str, str]] = []
    for raw in values:
        cleaned = raw.strip()
        if not cleaned:
            continue
        if "::" in cleaned:
            target, label = cleaned.split("::", 1)
        else:
            target, label = cleaned, "related"
        parsed.append((normalize_note_target(target), label.strip() or "related"))
    return tuple(parsed)


def parse_triple_entries(values: list[str]) -> tuple[tuple[str, str, str], ...]:
    parsed: list[tuple[str, str, str]] = []
    for raw in values:
        cleaned = raw.strip()
        if not cleaned:
            continue
        parts = [part.strip() for part in cleaned.split("::")]
        if len(parts) == 2:
            parsed.append((parts[0], parts[1], "relates"))
        elif len(parts) >= 3:
            parsed.append((parts[0], parts[1], parts[2] or "relates"))
    return tuple(parsed)


def parse_plain_labels(values: list[str]) -> tuple[str, ...]:
    labels = []
    for raw in values:
        cleaned = raw.strip()
        if cleaned and cleaned not in labels:
            labels.append(cleaned)
    return tuple(labels)


def extract_wikilinks(text: str) -> tuple[str, ...]:
    seen: list[str] = []
    for match in WIKILINK_RE.findall(text):
        target = normalize_note_target(match)
        if target not in seen:
            seen.append(target)
    return tuple(seen)


def note_id(prefix: str, value: str) -> str:
    digest = hashlib.sha1(f"{prefix}:{value}".encode("utf-8")).hexdigest()
    return digest[:16]


def file_node(note: NoteRecord, x: int, y: int, color: str) -> dict[str, Any]:
    return {
        "id": note_id("node", note.note_relpath),
        "type": "file",
        "x": x,
        "y": y,
        "width": NODE_WIDTH,
        "height": NODE_HEIGHT,
        "file": note.vault_relpath,
        "color": color,
    }


def text_node(node_key: str, text: str, x: int, y: int, width: int, height: int) -> dict[str, Any]:
    return {
        "id": note_id("text", node_key),
        "type": "text",
        "x": x,
        "y": y,
        "width": width,
        "height": height,
        "text": text,
        "color": "5",
    }


def group_node(node_key: str, label: str, x: int, y: int, width: int, height: int, color: str) -> dict[str, Any]:
    return {
        "id": note_id("group", node_key),
        "type": "group",
        "x": x,
        "y": y,
        "width": width,
        "height": height,
        "label": label,
        "color": color,
    }


def edge_id(source: str, target: str, label: str) -> str:
    digest = hashlib.sha1(f"{source}:{target}:{label}".encode("utf-8")).hexdigest()
    return digest[:16]


def make_edge(from_node: str, to_node: str, label: str) -> dict[str, Any]:
    return {
        "id": edge_id(from_node, to_node, label),
        "fromNode": from_node,
        "fromSide": "bottom",
        "toNode": to_node,
        "toSide": "top",
        "toEnd": "arrow",
        "label": label,
    }


def collect_notes(folder: Path, folder_name: str, vault_root: Path, limit: int) -> list[NoteRecord]:
    notes: list[NoteRecord] = []
    if not folder.exists():
        return notes
    for path in sorted(folder.glob("*.md"))[:limit]:
        text = path.read_text(encoding="utf-8")
        frontmatter = parse_frontmatter(text)
        body = body_without_frontmatter(text)
        title = str(frontmatter.get("title") or path.stem.replace("-", " "))
        notes.append(
            NoteRecord(
                title=title,
                note_relpath=f"{folder_name}/{path.name}",
                vault_relpath=str(path.relative_to(vault_root)).replace("\\", "/"),
                file_name=path.name,
                related_papers=tuple(
                    normalize_note_target(v) for v in frontmatter.get("related_papers", [])
                ),
                linked_knowledge=tuple(
                    normalize_note_target(v) for v in frontmatter.get("linked_knowledge", [])
                ),
                paper_relationships=parse_relationship_entries(
                    list(frontmatter.get("paper_relationships", []))
                ),
                linked_papers=tuple(
                    normalize_note_target(v) for v in frontmatter.get("linked_papers", [])
                ),
                claim_refs=parse_plain_labels(
                    list(frontmatter.get("argument_claims", []))
                    + list(frontmatter.get("linked_claims", []))
                ),
                method_refs=parse_plain_labels(
                    list(frontmatter.get("argument_methods", []))
                    + list(frontmatter.get("linked_methods", []))
                ),
                gap_refs=parse_plain_labels(
                    list(frontmatter.get("argument_gaps", []))
                    + list(frontmatter.get("linked_gaps", []))
                ),
                claim_method_links=parse_triple_entries(
                    list(frontmatter.get("claim_method_links", []))
                ),
                method_gap_links=parse_triple_entries(
                    list(frontmatter.get("method_gap_links", []))
                ),
                wikilinks=extract_wikilinks(body),
                subfield=str(frontmatter.get("subfield") or "other"),
                canvas_visibility=str(frontmatter.get("canvas_visibility") or "show"),
            )
        )
    return notes


def looks_like_literature_knowledge(note: NoteRecord) -> bool:
    key = note.note_relpath.lower()
    if any(token in key for token in ("literature", "paper", "method", "survey", "gap", "related")):
        return True
    return any(target.startswith("Papers/") for target in note.wikilinks)


def select_knowledge_notes(
    all_knowledge: list[NoteRecord], papers: list[NoteRecord]
) -> list[NoteRecord]:
    requested = set()
    for note in papers:
        requested.update(note.linked_knowledge)
        requested.update(target for target in note.wikilinks if target.startswith("Knowledge/"))

    selected: list[NoteRecord] = []
    seen: set[str] = set()
    for note in all_knowledge:
        note_key = note.note_relpath[:-3]
        if note_key in requested:
            selected.append(note)
            seen.add(note_key)

    if selected:
        return selected[:KNOWLEDGE_LIMIT]

    for note in all_knowledge:
        note_key = note.note_relpath[:-3]
        if note_key in seen:
            continue
        if looks_like_literature_knowledge(note):
            selected.append(note)
            seen.add(note_key)
        if len(selected) >= KNOWLEDGE_LIMIT:
            break

    return selected[:KNOWLEDGE_LIMIT]


def layout_grid(index: int, columns: int, x0: int, y0: int) -> tuple[int, int]:
    col = index % columns
    row = index // columns
    x = x0 + col * (NODE_WIDTH + X_GAP)
    y = y0 + row * (NODE_HEIGHT + Y_GAP)
    return x, y


def compute_group_dimensions(item_count: int, columns: int) -> tuple[int, int]:
    rows = max(1, (max(item_count, 1) - 1) // columns + 1)
    width = columns * NODE_WIDTH + (columns - 1) * X_GAP + 120
    height = rows * NODE_HEIGHT + (rows - 1) * Y_GAP + 140
    return width, height


def compute_argument_group_dimensions(item_count: int, columns: int) -> tuple[int, int]:
    rows = max(1, (max(item_count, 1) - 1) // columns + 1)
    width = columns * ARG_NODE_WIDTH + (columns - 1) * X_GAP + 120
    height = rows * ARG_NODE_HEIGHT + (rows - 1) * Y_GAP + 140
    return width, height


def argument_node(kind: str, label: str, x: int, y: int) -> dict[str, Any]:
    return {
        "id": note_id(kind, label),
        "type": "text",
        "x": x,
        "y": y,
        "width": ARG_NODE_WIDTH,
        "height": ARG_NODE_HEIGHT,
        "text": label,
        "color": {"claim": "4", "method": "2", "gap": "6"}.get(kind, "5"),
    }


def render_canvas(project_title: str, papers: list[NoteRecord], knowledge: list[NoteRecord]) -> dict[str, Any]:
    nodes: list[dict[str, Any]] = []
    edges: list[dict[str, Any]] = []
    node_lookup: dict[str, str] = {}
    claim_lookup: dict[str, str] = {}
    method_lookup: dict[str, str] = {}
    gap_lookup: dict[str, str] = {}

    knowledge_rows = max(1, (max(len(knowledge), 1) - 1) // KNOWLEDGE_COLUMNS + 1)
    knowledge_group_width = KNOWLEDGE_COLUMNS * NODE_WIDTH + (KNOWLEDGE_COLUMNS - 1) * X_GAP + 120
    knowledge_group_height = knowledge_rows * NODE_HEIGHT + (knowledge_rows - 1) * Y_GAP + 140
    knowledge_y = 220
    argument_y = knowledge_y + knowledge_group_height + 180

    nodes.append(
        text_node(
            "literature-summary",
            (
                f"# Literature Canvas\\n\\n"
                f"Project: {project_title}\\n\\n"
                f"- This is an argument map with `paper + claim + method + gap`.\\n"
                f"- The graph is intentionally thinned: each paper only keeps its most important claim / method links.\\n"
                f"- Papers are grouped by subfield and spaced out to reduce crossing lines."
            ),
            0,
            0,
            1080,
            150,
        )
    )
    nodes.append(group_node("knowledge-group", "Knowledge", -40, knowledge_y - 40, knowledge_group_width, knowledge_group_height, "4"))

    for idx, note in enumerate(knowledge):
        x, y = layout_grid(idx, KNOWLEDGE_COLUMNS, 20, knowledge_y)
        node = file_node(note, x, y, "4")
        nodes.append(node)
        node_lookup[note.note_relpath[:-3]] = node["id"]

    claim_labels: list[str] = []
    method_labels: list[str] = []
    gap_labels: list[str] = []
    for note in (*papers, *knowledge):
        for label in note.claim_refs:
            if label not in claim_labels:
                claim_labels.append(label)
        for label in note.method_refs:
            if label not in method_labels:
                method_labels.append(label)
        for label in note.gap_refs:
            if label not in gap_labels:
                gap_labels.append(label)

    claim_group_width, claim_group_height = compute_argument_group_dimensions(len(claim_labels), 2)
    method_group_width, method_group_height = compute_argument_group_dimensions(len(method_labels), 2)
    gap_group_width, gap_group_height = compute_argument_group_dimensions(len(gap_labels), 2)
    argument_row_height = max(claim_group_height, method_group_height, gap_group_height)

    argument_groups = [
        ("claim", "Claims", claim_labels, -40, argument_y, claim_group_width, claim_group_height, "4"),
        ("method", "Methods", method_labels, -40 + claim_group_width + ARG_GROUP_X_GAP, argument_y, method_group_width, method_group_height, "2"),
        ("gap", "Gaps", gap_labels, -40 + claim_group_width + ARG_GROUP_X_GAP + method_group_width + ARG_GROUP_X_GAP, argument_y, gap_group_width, gap_group_height, "6"),
    ]
    for kind, label, labels, group_x, group_y, group_width, group_height, color in argument_groups:
        nodes.append(group_node(f"{kind}-group", label, group_x, group_y, group_width, group_height, color))
        for idx, arg_label in enumerate(labels):
            x, y = layout_grid(idx, 2, group_x + 60, group_y + 40)
            node = argument_node(kind, arg_label, x, y)
            nodes.append(node)
            if kind == "claim":
                claim_lookup[arg_label] = node["id"]
            elif kind == "method":
                method_lookup[arg_label] = node["id"]
            else:
                gap_lookup[arg_label] = node["id"]

    paper_y = argument_y + argument_row_height + 180

    grouped_papers: dict[str, list[NoteRecord]] = {}
    for note in papers:
        grouped_papers.setdefault(note.subfield or "other", []).append(note)

    active_groups = [key for key in SUBFIELD_ORDER if grouped_papers.get(key)]
    if not active_groups:
        active_groups = ["other"]
        grouped_papers["other"] = list(papers)

    group_layout_meta: list[tuple[str, int, int, int, int]] = []
    for idx, subfield in enumerate(active_groups):
        notes_in_group = grouped_papers[subfield]
        group_width, group_height = compute_group_dimensions(len(notes_in_group), 2)
        col = idx % SUBFIELD_COLUMNS
        row = idx // SUBFIELD_COLUMNS
        group_x = -40 + col * (group_width + GROUP_X_GAP)
        group_y = paper_y + row * (group_height + GROUP_Y_GAP)
        group_layout_meta.append((subfield, group_x, group_y, group_width, group_height))
        nodes.append(
            group_node(
                f"paper-group-{subfield}",
                SUBFIELD_LABELS.get(subfield, subfield.replace("-", " ").title()),
                group_x,
                group_y,
                group_width,
                group_height,
                SUBFIELD_COLORS.get(subfield, "2"),
            )
        )

        for note_idx, note in enumerate(notes_in_group):
            x, y = layout_grid(note_idx, 2, group_x + 60, group_y + 40)
            node = file_node(note, x, y, SUBFIELD_COLORS.get(subfield, "2"))
            nodes.append(node)
            node_lookup[note.note_relpath[:-3]] = node["id"]

    seen_edges: set[tuple[str, str, str]] = set()
    for note in papers:
        source = node_lookup.get(note.note_relpath[:-3])
        if not source:
            continue
        explicit_relationships = list(note.paper_relationships)
        if not explicit_relationships:
            explicit_relationships = [(target, "related") for target in note.related_papers]
        for target, label in explicit_relationships[:PAPER_RELATION_LIMIT]:
            target_node = node_lookup.get(target)
            if not target_node:
                continue
            marker = (source, target_node, label)
            if marker not in seen_edges:
                edges.append(make_edge(source, target_node, label))
                seen_edges.add(marker)
        for claim in note.claim_refs[:PAPER_CLAIM_LIMIT]:
            target_node = claim_lookup.get(claim)
            if not target_node:
                continue
            marker = (source, target_node, "supports")
            if marker not in seen_edges:
                edges.append(make_edge(source, target_node, "supports"))
                seen_edges.add(marker)
        for method in note.method_refs[:PAPER_METHOD_LIMIT]:
            target_node = method_lookup.get(method)
            if not target_node:
                continue
            marker = (source, target_node, "uses")
            if marker not in seen_edges:
                edges.append(make_edge(source, target_node, "uses"))
                seen_edges.add(marker)
    for note in knowledge:
        source = node_lookup.get(note.note_relpath[:-3])
        if not source:
            continue
        for target in note.linked_papers:
            target_node = node_lookup.get(target)
            if not target_node:
                continue
            marker = (source, target_node, "summarizes")
            if marker not in seen_edges:
                edges.append(make_edge(source, target_node, "summarizes"))
                seen_edges.add(marker)
        for claim in note.claim_refs:
            target_node = claim_lookup.get(claim)
            if not target_node:
                continue
            marker = (source, target_node, "summarizes")
            if marker not in seen_edges:
                edges.append(make_edge(source, target_node, "summarizes"))
                seen_edges.add(marker)
        for method in note.method_refs:
            target_node = method_lookup.get(method)
            if not target_node:
                continue
            marker = (source, target_node, "summarizes")
            if marker not in seen_edges:
                edges.append(make_edge(source, target_node, "summarizes"))
                seen_edges.add(marker)
        for gap in note.gap_refs:
            target_node = gap_lookup.get(gap)
            if not target_node:
                continue
            marker = (source, target_node, "summarizes")
            if marker not in seen_edges:
                edges.append(make_edge(source, target_node, "summarizes"))
                seen_edges.add(marker)
        for claim, method, label in note.claim_method_links:
            source_node = claim_lookup.get(claim)
            target_node = method_lookup.get(method)
            if not source_node or not target_node:
                continue
            marker = (source_node, target_node, label)
            if marker not in seen_edges:
                edges.append(make_edge(source_node, target_node, label))
                seen_edges.add(marker)
        for method, gap, label in note.method_gap_links:
            source_node = method_lookup.get(method)
            target_node = gap_lookup.get(gap)
            if not source_node or not target_node:
                continue
            marker = (source_node, target_node, label)
            if marker not in seen_edges:
                edges.append(make_edge(source_node, target_node, label))
                seen_edges.add(marker)
        for target in note.wikilinks:
            if not target.startswith("Knowledge/"):
                continue
            target_node = node_lookup.get(target)
            if not target_node:
                continue
            marker = (source, target_node, "relates")
            if marker not in seen_edges:
                edges.append(make_edge(source, target_node, "relates"))
                seen_edges.add(marker)

    return {"nodes": nodes, "edges": edges}


def main() -> None:
    args = parse_args()
    project_kb = load_project_kb_module()
    repo_root = project_kb.find_repo_root(Path(args.cwd).resolve())
    binding = project_kb.resolve_binding(repo_root, args.project_id or None)

    papers = [
        note
        for note in collect_notes(binding.project_root / "Papers", "Papers", binding.vault_path, PAPER_LIMIT)
        if note.canvas_visibility != "hidden"
    ]
    all_knowledge = collect_notes(
        binding.project_root / "Knowledge", "Knowledge", binding.vault_path, KNOWLEDGE_LIMIT * 3
    )
    knowledge = select_knowledge_notes(all_knowledge, papers)
    canvas = render_canvas(project_kb.titleize_slug(binding.project_id), papers, knowledge)

    output_path = binding.project_root / args.output
    output_path.parent.mkdir(parents=True, exist_ok=True)
    output_path.write_text(json.dumps(canvas, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(
        json.dumps(
            {
                "project_id": binding.project_id,
                "output": str(output_path),
                "paper_count": len(papers),
                "knowledge_count": len(knowledge),
            },
            ensure_ascii=False,
        )
    )


if __name__ == "__main__":
    main()

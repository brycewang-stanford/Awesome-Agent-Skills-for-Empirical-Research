#!/usr/bin/env python3
from __future__ import annotations

import argparse
import re
import sys
from dataclasses import dataclass
from pathlib import Path
from typing import Any

PAPER_LIMIT = 48
EDGE_LIMIT = 160
WIKILINK_RE = re.compile(r"\[\[([^\]|#]+)(?:#[^\]|]+)?(?:\|[^\]]+)?\]\]")
LIST_KEYS = {
    'authors', 'keywords', 'concepts', 'methods',
    'related_papers', 'linked_experiments', 'linked_results'
}


@dataclass(frozen=True)
class PaperNote:
    title: str
    note_relpath: str
    file_name: str
    concepts: tuple[str, ...]
    methods: tuple[str, ...]
    related_papers: tuple[str, ...]
    linked_experiments: tuple[str, ...]
    linked_results: tuple[str, ...]
    wikilinks: tuple[str, ...]


def load_project_kb_module() -> Any:
    script_dir = Path(__file__).resolve().parents[2] / 'obsidian-project-memory' / 'scripts'
    sys.path.insert(0, str(script_dir))
    import project_kb  # type: ignore
    return project_kb


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description='Build a literature graph note for the bound Obsidian project.')
    parser.add_argument('--cwd', default='.')
    parser.add_argument('--project-id', default='')
    parser.add_argument('--output', default='Knowledge/Literature-Map.md')
    return parser.parse_args()


def parse_frontmatter(text: str) -> dict[str, Any]:
    if not text.startswith('---\n'):
        return {}
    end = text.find('\n---\n', 4)
    if end == -1:
        return {}
    lines = text[4:end].splitlines()
    data: dict[str, Any] = {}
    current_key: str | None = None
    for raw_line in lines:
        if not raw_line.strip():
            continue
        if raw_line.startswith('  - ') or raw_line.startswith('- '):
            if current_key and current_key in LIST_KEYS:
                data.setdefault(current_key, []).append(raw_line.split('- ', 1)[1].strip().strip('"'))
            continue
        if ':' not in raw_line:
            current_key = None
            continue
        key, value = raw_line.split(':', 1)
        key = key.strip()
        value = value.strip()
        current_key = key
        if not value:
            if key in LIST_KEYS:
                data[key] = []
            else:
                data[key] = ''
            continue
        data[key] = value.strip('"')
    return data


def body_without_frontmatter(text: str) -> str:
    if not text.startswith('---\n'):
        return text
    end = text.find('\n---\n', 4)
    if end == -1:
        return text
    return text[end + 5:]


def normalize_note_target(value: str) -> str:
    cleaned = value.strip()
    if cleaned.endswith('.md'):
        cleaned = cleaned[:-3]
    if cleaned.startswith('./'):
        cleaned = cleaned[2:]
    return cleaned


def mermaid_id(prefix: str, value: str) -> str:
    slug = re.sub(r'[^a-zA-Z0-9]+', '_', value).strip('_').lower()
    if not slug:
        slug = 'node'
    return f'{prefix}_{slug[:48]}'


def extract_wikilinks(text: str) -> tuple[str, ...]:
    seen: list[str] = []
    for match in WIKILINK_RE.findall(text):
        target = normalize_note_target(match)
        if target not in seen:
            seen.append(target)
    return tuple(seen)


def collect_paper_notes(project_root: Path) -> list[PaperNote]:
    papers_dir = project_root / 'Papers'
    notes: list[PaperNote] = []
    if not papers_dir.exists():
        return notes
    for path in sorted(papers_dir.glob('*.md'))[:PAPER_LIMIT]:
        text = path.read_text(encoding='utf-8')
        frontmatter = parse_frontmatter(text)
        body = body_without_frontmatter(text)
        title = str(frontmatter.get('title') or path.stem.replace('-', ' '))
        notes.append(
            PaperNote(
                title=title,
                note_relpath=f'Papers/{path.name}',
                file_name=path.name,
                concepts=tuple(frontmatter.get('concepts', [])),
                methods=tuple(frontmatter.get('methods', [])),
                related_papers=tuple(normalize_note_target(v) for v in frontmatter.get('related_papers', [])),
                linked_experiments=tuple(normalize_note_target(v) for v in frontmatter.get('linked_experiments', [])),
                linked_results=tuple(normalize_note_target(v) for v in frontmatter.get('linked_results', [])),
                wikilinks=extract_wikilinks(body),
            )
        )
    return notes


def render_mermaid(notes: list[PaperNote]) -> str:
    lines: list[str] = ['graph LR']
    paper_index = {note.note_relpath[:-3]: note for note in notes}
    seen_edges: set[tuple[str, str, str]] = set()

    for note in notes:
        paper_node = mermaid_id('paper', note.file_name)
        lines.append(f'    {paper_node}["{note.title}"]')

        for concept in note.concepts:
            concept_node = mermaid_id('concept', concept)
            lines.append(f'    {concept_node}(("{concept}"))')
            edge = (paper_node, concept_node, 'concept')
            if edge not in seen_edges and len(seen_edges) < EDGE_LIMIT:
                lines.append(f'    {paper_node} -->|concept| {concept_node}')
                seen_edges.add(edge)

        for method in note.methods:
            method_node = mermaid_id('method', method)
            lines.append(f'    {method_node}{{"{method}"}}')
            edge = (paper_node, method_node, 'method')
            if edge not in seen_edges and len(seen_edges) < EDGE_LIMIT:
                lines.append(f'    {paper_node} -->|method| {method_node}')
                seen_edges.add(edge)

        related_targets = set(note.related_papers)
        related_targets.update(target for target in note.wikilinks if target.startswith('Papers/'))
        for target in sorted(related_targets):
            target_note = paper_index.get(target)
            if not target_note:
                continue
            target_node = mermaid_id('paper', target_note.file_name)
            edge = (paper_node, target_node, 'related')
            if edge not in seen_edges and len(seen_edges) < EDGE_LIMIT:
                lines.append(f'    {paper_node} -->|related| {target_node}')
                seen_edges.add(edge)

        for experiment in note.linked_experiments:
            exp_node = mermaid_id('experiment', experiment)
            label = experiment.split('/')[-1]
            lines.append(f'    {exp_node}["{label}"]')
            edge = (paper_node, exp_node, 'experiment')
            if edge not in seen_edges and len(seen_edges) < EDGE_LIMIT:
                lines.append(f'    {paper_node} -->|experiment| {exp_node}')
                seen_edges.add(edge)

        for result in note.linked_results:
            result_node = mermaid_id('result', result)
            label = result.split('/')[-1]
            lines.append(f'    {result_node}["{label}"]')
            edge = (paper_node, result_node, 'result')
            if edge not in seen_edges and len(seen_edges) < EDGE_LIMIT:
                lines.append(f'    {paper_node} -->|result| {result_node}')
                seen_edges.add(edge)

    deduped: list[str] = []
    seen_lines: set[str] = set()
    for line in lines:
        if line not in seen_lines:
            deduped.append(line)
            seen_lines.add(line)
    return '\n'.join(deduped)


def render_map_note(project_id: str, notes: list[PaperNote], mermaid_graph: str, updated: str) -> str:
    paper_bullets = '\n'.join(f'- [[{note.note_relpath[:-3]}]]' for note in notes) or '- No paper notes yet.'
    concept_counts: dict[str, int] = {}
    method_counts: dict[str, int] = {}
    for note in notes:
        for concept in note.concepts:
            concept_counts[concept] = concept_counts.get(concept, 0) + 1
        for method in note.methods:
            method_counts[method] = method_counts.get(method, 0) + 1
    concept_lines = '\n'.join(
        f'- {name} ({count})' for name, count in sorted(concept_counts.items(), key=lambda kv: (-kv[1], kv[0]))[:12]
    ) or '- No concept clusters recorded yet.'
    method_lines = '\n'.join(
        f'- {name} ({count})' for name, count in sorted(method_counts.items(), key=lambda kv: (-kv[1], kv[0]))[:12]
    ) or '- No method clusters recorded yet.'

    return f'''---
type: knowledge
title: Literature Map
project: {project_id}
updated: {updated}
---

# Literature Map

## Purpose
- Provide a lightweight literature knowledge map for the current project.
- Help navigate paper notes, concept clusters, and downstream experiment/result hooks.

## Paper notes included
{paper_bullets}

## Concept clusters
{concept_lines}

## Method clusters
{method_lines}

## Graph
```mermaid
{mermaid_graph}
```

## How to use
- Open the linked paper notes above for detailed reading notes.
- Use Obsidian backlinks/local graph on top of these wikilinks.
- Refresh this note after a batch Zotero ingestion or major paper-note update.
'''


def main() -> None:
    args = parse_args()
    project_kb = load_project_kb_module()
    repo_root = project_kb.find_repo_root(Path(args.cwd).resolve())
    binding = project_kb.resolve_binding(repo_root, args.project_id or None)
    notes = collect_paper_notes(binding.project_root)
    output_rel = args.output if args.output.endswith('.md') else f'{args.output}.md'
    output_path = binding.project_root / output_rel
    mermaid_graph = render_mermaid(notes)
    content = render_map_note(binding.project_id, notes, mermaid_graph, project_kb.now_iso())
    output_path.parent.mkdir(parents=True, exist_ok=True)
    output_path.write_text(content.rstrip() + '\n', encoding='utf-8')
    print(output_path)


if __name__ == '__main__':
    main()

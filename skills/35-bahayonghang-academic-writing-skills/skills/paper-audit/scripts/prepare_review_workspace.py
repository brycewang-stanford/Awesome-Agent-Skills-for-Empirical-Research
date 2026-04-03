"""Prepare a deep-review workspace from a paper source file."""

from __future__ import annotations

import argparse
import json
import re
import shutil
from datetime import datetime
from pathlib import Path

from build_claim_map import build_claim_map
from detect_language import detect_language
from parsers import extract_title, get_parser


def slugify(value: str) -> str:
    """Convert a filename or title into a filesystem-safe slug."""
    slug = re.sub(r"[^a-zA-Z0-9]+", "-", value).strip("-").lower()
    return slug or "paper"


def _section_lines(lines: list[str], start: int, end: int, zero_based: bool) -> str:
    if zero_based:
        return "\n".join(lines[start : end + 1]).strip()
    return "\n".join(lines[max(0, start - 1) : end]).strip()


def build_section_index(content: str, parser, fmt: str) -> list[dict]:
    """Turn parser section tuples into portable section metadata."""
    sections = parser.split_sections(content)
    lines = content.splitlines()
    zero_based = fmt == ".pdf"
    index: list[dict] = []

    for section_key, (start, end) in sections.items():
        body = _section_lines(lines, start, end, zero_based=zero_based)
        index.append(
            {
                "section_key": section_key,
                "title": section_key.replace("_", " ").title(),
                "start_line": start,
                "end_line": end,
                "line_base": 0 if zero_based else 1,
                "word_count": len(body.split()),
                "char_count": len(body),
                "file_name": f"{section_key}.md",
            }
        )

    return sorted(index, key=lambda item: item["start_line"])


def write_summary_stub(
    workspace: Path,
    title: str,
    claim_map: dict,
    section_index: list[dict],
) -> None:
    """Write a structured summary stub the reviewer can refine."""
    lines = [
        f"# Paper Summary: {title}",
        "",
        "## Research Question",
        "- TODO",
        "",
        "## Core Thesis",
        "- TODO",
        "",
        "## Headline Claims",
    ]
    if claim_map["headline_claims"]:
        lines.extend([f"- {claim}" for claim in claim_map["headline_claims"]])
    else:
        lines.append("- TODO")
    lines.extend(["", "## Section Map"])
    for section in section_index:
        lines.append(
            f"- {section['section_key']} ({section['start_line']}-{section['end_line']}): "
            f"{section['word_count']} words"
        )
    lines.extend(["", "## Closure Targets"])
    if claim_map["closure_targets"]:
        lines.extend([f"- {claim}" for claim in claim_map["closure_targets"]])
    else:
        lines.append("- TODO")
    (workspace / "paper_summary.md").write_text("\n".join(lines), encoding="utf-8")


def _copy_workspace_references(workspace: Path) -> None:
    """Copy a small reference set into the workspace for reviewer agents.

    Reviewer lane templates read `<review_dir>/references/...`, so keep the workspace
    self-contained even when the audit is run from other working directories.
    """
    skill_root = Path(__file__).resolve().parent.parent
    source_dir = skill_root / "references"
    dest_dir = workspace / "references"
    dest_dir.mkdir(parents=True, exist_ok=True)

    minimal_refs = (
        "DEEP_REVIEW_CRITERIA.md",
        "ISSUE_SCHEMA.md",
        "REVIEW_LANE_GUIDE.md",
        "CONSOLIDATION_RULES.md",
        "CHECKLIST.md",
        "QUALITATIVE_STANDARDS.md",
    )
    for name in minimal_refs:
        src = source_dir / name
        if not src.exists():
            continue
        shutil.copy2(src, dest_dir / name)


def prepare_workspace(input_path: str, output_dir: str = "./review_results") -> Path:
    """Create deep-review workspace files and return the workspace path."""
    source = Path(input_path).resolve()
    if not source.exists():
        raise FileNotFoundError(f"Input file not found: {input_path}")

    fmt = source.suffix.lower()
    parser = get_parser(str(source))
    if fmt == ".pdf":
        content = parser.extract_text_from_file(str(source))
    else:
        content = source.read_text(encoding="utf-8")

    visible_text = parser.clean_text(content, keep_structure=True)
    language = detect_language(parser.clean_text(content))
    title = extract_title(content) if fmt in {".tex", ".typ"} else source.stem
    slug = slugify(title or source.stem)

    workspace = Path(output_dir).resolve() / slug
    sections_dir = workspace / "sections"
    comments_dir = workspace / "comments"
    committee_dir = workspace / "committee"
    sections_dir.mkdir(parents=True, exist_ok=True)
    comments_dir.mkdir(parents=True, exist_ok=True)
    committee_dir.mkdir(parents=True, exist_ok=True)

    full_text_path = workspace / "full_text.md"
    full_text_path.write_text(visible_text if visible_text else content, encoding="utf-8")

    section_index = build_section_index(content, parser, fmt)
    lines = content.splitlines()
    section_texts: dict[str, str] = {}
    for section in section_index:
        raw_body = _section_lines(
            lines,
            section["start_line"],
            section["end_line"],
            zero_based=section["line_base"] == 0,
        )
        body = parser.clean_text(raw_body, keep_structure=True) if fmt != ".pdf" else raw_body
        section_texts[section["section_key"]] = body
        (sections_dir / section["file_name"]).write_text(body, encoding="utf-8")

    section_index_path = workspace / "section_index.json"
    section_index_path.write_text(
        json.dumps(section_index, indent=2, ensure_ascii=False), encoding="utf-8"
    )

    claim_map = build_claim_map(
        visible_text if visible_text else content,
        section_index,
        section_texts=section_texts,
    )
    (workspace / "claim_map.json").write_text(
        json.dumps(claim_map, indent=2, ensure_ascii=False),
        encoding="utf-8",
    )

    metadata = {
        "slug": slug,
        "title": title or source.stem,
        "source_path": str(source),
        "language": language,
        "format": fmt,
        "generated_at": datetime.now().isoformat(),
    }
    (workspace / "metadata.json").write_text(
        json.dumps(metadata, indent=2, ensure_ascii=False),
        encoding="utf-8",
    )
    write_summary_stub(workspace, metadata["title"], claim_map, section_index)
    _copy_workspace_references(workspace)
    return workspace


def main() -> int:
    parser = argparse.ArgumentParser(description="Prepare a deep-review workspace")
    parser.add_argument("input", help="Path to a .tex, .typ, or .pdf file")
    parser.add_argument(
        "--output-dir",
        default="./review_results",
        help="Parent directory for workspace output (default: ./review_results)",
    )
    args = parser.parse_args()

    workspace = prepare_workspace(args.input, output_dir=args.output_dir)
    print(f"WORKSPACE: {workspace}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

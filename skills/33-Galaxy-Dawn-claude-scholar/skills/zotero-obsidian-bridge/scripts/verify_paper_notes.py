#!/usr/bin/env python3
"""Verify Obsidian paper-note schema, Zotero-key coverage, and optional inventory consistency."""

from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path

REQUIRED_HEADINGS = (
    "## Claim",
    "## Method",
    "## Evidence",
    "## Limitation",
    "## Direct relevance to repo",
    "## Relation to other papers",
)

REQUIRED_FRONTMATTER_FIELDS = (
    "type",
    "project",
    "title",
    "zotero_key",
    "linked_knowledge",
    "paper_relationships",
    "updated",
)

ZOTERO_KEY_RE = re.compile(r'^zotero_key:\s*"?([A-Z0-9]+)"?', re.MULTILINE)
FRONTMATTER_RE = re.compile(r'^---\n(.*?)\n---\n', re.DOTALL)
FIELD_RE_TEMPLATE = r'^{}:\s*'
INVENTORY_ROW_RE = re.compile(r'^\|\s*([A-Z0-9]+)\s*\|\s*(.*?)\|\s*(.*?)\|\s*(.*?)\|\s*$')


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Verify paper-note schema and optional Zotero-key / inventory coverage."
    )
    parser.add_argument("--papers-dir", required=True, help="Directory containing canonical paper notes.")
    parser.add_argument(
        "--expected-zotero-keys",
        default="",
        help="Comma-separated Zotero keys expected to be covered.",
    )
    parser.add_argument(
        "--inventory-note",
        default="",
        help="Optional collection inventory note to cross-check against canonical paper notes.",
    )
    parser.add_argument(
        "--strict-missing-zotero-key",
        action="store_true",
        help="Treat notes without zotero_key as errors. Default behavior skips them.",
    )
    return parser.parse_args()


def load_expected_keys(raw_keys: str) -> list[str]:
    if not raw_keys.strip():
        return []
    return [key.strip() for key in raw_keys.split(",") if key.strip()]


def extract_frontmatter(text: str) -> str:
    match = FRONTMATTER_RE.match(text)
    return match.group(1) if match else ""


def missing_frontmatter_fields(frontmatter: str) -> list[str]:
    missing: list[str] = []
    for field in REQUIRED_FRONTMATTER_FIELDS:
        if not re.search(FIELD_RE_TEMPLATE.format(re.escape(field)), frontmatter, re.MULTILINE):
            missing.append(field)
    return missing


def collect_note_status(
    papers_dir: Path,
    strict_missing_zotero_key: bool,
) -> tuple[dict[str, str], list[str], list[str]]:
    key_to_file: dict[str, str] = {}
    issues: list[str] = []
    skipped_without_key: list[str] = []

    for path in sorted(papers_dir.glob("*.md")):
        text = path.read_text(encoding="utf-8")
        frontmatter = extract_frontmatter(text)
        match = ZOTERO_KEY_RE.search(text)
        if not match:
            skipped_without_key.append(path.name)
            if strict_missing_zotero_key:
                issues.append(f"{path.name}: missing zotero_key")
            continue

        zotero_key = match.group(1)
        if zotero_key in key_to_file:
            issues.append(
                f"{path.name}: duplicate zotero_key {zotero_key} also used by {key_to_file[zotero_key]}"
            )
        key_to_file[zotero_key] = path.name

        missing_headings = [heading for heading in REQUIRED_HEADINGS if heading not in text]
        if missing_headings:
            issues.append(f"{path.name}: missing headings -> {', '.join(missing_headings)}")

        missing_fields = missing_frontmatter_fields(frontmatter)
        if missing_fields:
            issues.append(f"{path.name}: missing frontmatter fields -> {', '.join(missing_fields)}")

    return key_to_file, issues, skipped_without_key


def parse_inventory_note(inventory_path: Path) -> tuple[dict[str, str], list[str]]:
    text = inventory_path.read_text(encoding="utf-8")
    mapping: dict[str, str] = {}
    issues: list[str] = []
    in_table = False

    for line in text.splitlines():
        if line.strip() == "## Item Mapping":
            in_table = True
            continue
        if in_table and line.startswith("## "):
            break
        if not in_table or not line.startswith("|"):
            continue
        if "---" in line:
            continue
        match = INVENTORY_ROW_RE.match(line)
        if not match:
            continue
        key, _title, note_path, _status = [part.strip() for part in match.groups()]
        if key in mapping:
            issues.append(f"inventory: duplicate zotero key {key}")
        mapping[key] = note_path

    if not mapping:
        issues.append("inventory: no item mapping rows found")
    return mapping, issues


def main() -> int:
    args = parse_args()
    papers_dir = Path(args.papers_dir).expanduser()
    expected_keys = load_expected_keys(args.expected_zotero_keys)

    if not papers_dir.exists():
        print(f"ERROR: papers dir not found: {papers_dir}")
        return 1

    note_files = list(papers_dir.glob("*.md"))
    key_to_file, issues, skipped_without_key = collect_note_status(
        papers_dir, args.strict_missing_zotero_key
    )

    print(f"Papers dir: {papers_dir}")
    print(f"Paper notes scanned: {len(note_files)}")
    print(f"Notes with zotero_key: {len(key_to_file)}")
    if skipped_without_key:
        print(f"Notes skipped without zotero_key: {len(skipped_without_key)}")

    if expected_keys:
        missing = [key for key in expected_keys if key not in key_to_file]
        extras = sorted(set(key_to_file) - set(expected_keys))
        print(f"Expected Zotero keys: {len(expected_keys)}")
        print(f"Covered Zotero keys: {len(expected_keys) - len(missing)} / {len(expected_keys)}")
        if missing:
            issues.append(f"Missing expected keys: {', '.join(missing)}")
        if extras:
            print(f"Extra zotero_key notes: {', '.join(extras)}")

    if args.inventory_note:
        inventory_path = Path(args.inventory_note).expanduser()
        if not inventory_path.exists():
            issues.append(f"inventory note not found: {inventory_path}")
        else:
            inventory_mapping, inventory_issues = parse_inventory_note(inventory_path)
            issues.extend(inventory_issues)
            if inventory_mapping:
                for key, note_path in inventory_mapping.items():
                    expected_name = key_to_file.get(key)
                    if expected_name is None:
                        issues.append(f"inventory: key {key} not found in paper notes")
                        continue
                    if Path(note_path).name != expected_name:
                        issues.append(
                            f"inventory: key {key} points to {note_path}, expected file ending {expected_name}"
                        )
                missing_in_inventory = sorted(set(key_to_file) - set(inventory_mapping))
                if missing_in_inventory:
                    issues.append(
                        f"inventory: missing keys present in paper notes -> {', '.join(missing_in_inventory)}"
                    )

    if skipped_without_key:
        print("Skipped note files without zotero_key:")
        for name in skipped_without_key:
            print(f"- {name}")

    if issues:
        print("\nISSUES:")
        for issue in issues:
            print(f"- {issue}")
        return 1

    print("\nOK: schema and coverage checks passed.")
    return 0


if __name__ == "__main__":
    sys.exit(main())

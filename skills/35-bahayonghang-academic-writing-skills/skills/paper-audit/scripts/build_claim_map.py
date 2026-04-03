"""Build a lightweight claim map for deep-review workflows."""

from __future__ import annotations

import argparse
import json
import re
from pathlib import Path

CLAIM_PATTERNS = (
    r"\bwe (?:show|demonstrate|find|propose|introduce|present)\b",
    r"\bour results?\b",
    r"\bthis paper\b",
    r"\bthe main contribution\b",
    r"\bwe conclude\b",
    r"\bwe argue\b",
)


def split_sentences(text: str) -> list[str]:
    """Split text into rough sentences without external dependencies."""
    parts = re.split(r"(?<=[.!?])\s+(?=[A-Z0-9\"'])", text.replace("\n", " "))
    return [part.strip() for part in parts if part.strip()]


def extract_claims(text: str, max_items: int = 5) -> list[str]:
    """Return likely claim-bearing sentences."""
    claims: list[str] = []
    for sentence in split_sentences(text):
        if any(re.search(pattern, sentence, re.IGNORECASE) for pattern in CLAIM_PATTERNS):
            claims.append(sentence)
        if len(claims) >= max_items:
            break
    return claims


def build_claim_map(
    content: str,
    section_index: list[dict],
    section_texts: dict[str, str] | None = None,
    max_items_per_section: int = 5,
) -> dict:
    """Build a minimal section-aware claim map from text and section index."""
    lines = content.splitlines()
    section_claims: dict[str, list[str]] = {}
    headline_claims: list[str] = []
    closure_targets: list[str] = []

    for section in section_index:
        if section_texts and section["section_key"] in section_texts:
            chunk = section_texts[section["section_key"]]
        else:
            start = int(section.get("start_line", 1))
            end = int(section.get("end_line", len(lines)))
            if section.get("line_base", 1) == 0:
                chunk = "\n".join(lines[start : end + 1])
            else:
                chunk = "\n".join(lines[max(0, start - 1) : end])

        claims = extract_claims(chunk, max_items=max_items_per_section)
        if claims:
            section_claims[section["section_key"]] = claims

        if section["section_key"] in {"abstract", "introduction"}:
            headline_claims.extend(claims[:max_items_per_section])
        if section["section_key"] in {"conclusion", "discussion"}:
            closure_targets.extend(claims[:max_items_per_section])

    return {
        "headline_claims": headline_claims[: max_items_per_section * 2],
        "closure_targets": closure_targets[: max_items_per_section * 2],
        "section_claims": section_claims,
    }


def main() -> int:
    parser = argparse.ArgumentParser(description="Build a claim map from a deep-review workspace")
    parser.add_argument("full_text", help="Path to full_text.md")
    parser.add_argument("section_index", help="Path to section_index.json")
    parser.add_argument("--output", "-o", help="Optional output path")
    args = parser.parse_args()

    full_text = Path(args.full_text).read_text(encoding="utf-8")
    section_index = json.loads(Path(args.section_index).read_text(encoding="utf-8"))
    claim_map = build_claim_map(full_text, section_index)
    payload = json.dumps(claim_map, indent=2, ensure_ascii=False)

    if args.output:
        Path(args.output).write_text(payload, encoding="utf-8")
    else:
        print(payload)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

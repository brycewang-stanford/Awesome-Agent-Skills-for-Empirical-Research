#!/usr/bin/env python3
"""
Citation Stacking Checker for Academic Papers.
Detects clustered citations (3+) without individual discussion
in Introduction and Related Work sections.

Output contract (audit.py compatible):
  [Severity: Major] [Priority: P1] (Line N) message

Usage:
    uv run python -B check_citations.py main.tex
    uv run python -B check_citations.py paper.typ
"""

import argparse
import re
import sys
from pathlib import Path

try:
    from parsers import get_parser
except ImportError:
    sys.path.append(str(Path(__file__).parent))
    from parsers import get_parser

# --- Constants ---
MAX_CLUSTER = 2  # max citations per sentence without discussion
TARGET_SECTIONS: list[str] = [
    # English
    "introduction",
    "related work",
    "related_work",
    # Chinese thesis variants
    "绪论",
    "引言",
    "文献综述",
    "相关工作",
]

# --- Citation Patterns ---
# LaTeX: \cite{...}, \citep{...}, \citet{...}, \citeauthor{...}
# Also handles \cite{a,b,c} as multiple citations
LATEX_CITE_RE = re.compile(r"\\cite[tp]?\s*(?:\[[^\]]*\])?\s*\{([^}]+)\}")
# Typst: @refkey (word boundary)
TYPST_CITE_RE = re.compile(r"@([\w][\w\-:.]*)")


# Patterns that indicate a new section boundary (to stop scanning)
LATEX_SECTION_RE = re.compile(r"\\(?:section|chapter)\s*\*?\s*\{")
TYPST_HEADING_RE = re.compile(r"^=+\s+")


class CitationStackingChecker:
    """Detect clustered citations in target sections."""

    def __init__(self, file_path: Path):
        self.file_path = file_path
        self.content = file_path.read_text(encoding="utf-8", errors="ignore")
        self.lines = self.content.split("\n")
        self.parser = get_parser(file_path)
        self.section_ranges = self.parser.split_sections(self.content)
        self.comment_prefix = self.parser.get_comment_prefix()
        self.is_typst = file_path.suffix == ".typ"
        self._section_heading_re = TYPST_HEADING_RE if self.is_typst else LATEX_SECTION_RE

    def _count_citations_in_line(self, raw_text: str) -> int:
        """Count total citation references in a raw source line.

        Must operate on raw source (not extract_visible_text output)
        because extract_visible_text strips citation commands.
        """
        if self.is_typst:
            return len(TYPST_CITE_RE.findall(raw_text))
        # LaTeX: \cite{a,b,c} counts as 3
        total = 0
        for m in LATEX_CITE_RE.finditer(raw_text):
            keys = m.group(1)
            total += len([k.strip() for k in keys.split(",") if k.strip()])
        return total

    def _is_target_section(self, name: str) -> bool:
        """Check if a section name matches any target section."""
        norm = name.lower().replace(" ", "_")
        for target in TARGET_SECTIONS:
            t = target.lower().replace(" ", "_")
            # Exact match or prefix match (e.g. "related" matches "related_work")
            if norm == t or t.startswith(norm) or norm.startswith(t):
                return True
        return False

    def _get_target_sections(self) -> list[tuple[str, int, int]]:
        """Get (name, start, end) for target sections."""
        result = []
        for name, (start, end) in self.section_ranges.items():
            if self._is_target_section(name):
                result.append((name, start, end))
        return result

    def check(self) -> list[dict]:
        """Run citation stacking detection. Returns list of issues."""
        issues: list[dict] = []
        sections = self._get_target_sections()

        for sec_name, start, end in sections:
            for i in range(start - 1, min(end, len(self.lines))):
                line = self.lines[i]
                stripped = line.strip()

                if stripped.startswith(self.comment_prefix):
                    continue

                # Stop if we hit a new section/chapter heading (not the first line)
                if i > start - 1 and self._section_heading_re.search(stripped):
                    break

                # Count citations on raw source text (not visible text),
                # because extract_visible_text strips \cite{} commands
                count = self._count_citations_in_line(stripped)

                if count > MAX_CLUSTER:
                    issues.append(
                        {
                            "line": i + 1,
                            "section": sec_name,
                            "citation_count": count,
                            "text": stripped,
                            "severity": "Critical" if count >= 5 else "Major",
                            "priority": "P0" if count >= 5 else "P1",
                        }
                    )
        return issues


def main() -> None:
    ap = argparse.ArgumentParser(description="Citation stacking checker")
    ap.add_argument("file", type=Path)
    ap.add_argument("--json", action="store_true")
    args = ap.parse_args()

    checker = CitationStackingChecker(args.file)
    issues = checker.check()

    if args.json:
        import json

        json.dump(issues, sys.stdout, ensure_ascii=False, indent=2)
    else:
        for iss in issues:
            sev, pri, ln = iss["severity"], iss["priority"], iss["line"]
            cnt = iss["citation_count"]
            sec = iss["section"]
            print(
                f"[Severity: {sev}] [Priority: {pri}] (Line {ln}) "
                f"Citation stacking: {cnt} citations clustered in one sentence "
                f"without individual discussion (section: {sec}). "
                f"Max {MAX_CLUSTER} clustered citations allowed."
            )
        if not issues:
            print("[INFO] No citation stacking issues found.")

    sys.exit(1 if issues else 0)


if __name__ == "__main__":
    main()

#!/usr/bin/env python3
"""
Figure/Table/Equation Reference Integrity Checker — router version.

Selects LaTeX or Typst checking mode based on file extension:
  .tex  → LaTeX patterns (same as latex-paper-en)
  .typ  → Typst patterns (same as typst-paper)
  .pdf  → Skip with informational message (cannot extract label/ref from PDF)

Usage:
    python check_references.py paper.tex
    python check_references.py paper.typ
    python check_references.py paper.pdf
    python check_references.py paper.tex --json
"""

from __future__ import annotations

import argparse
import json
import re
import sys
from dataclasses import dataclass
from pathlib import Path

# ===========================================================================
# LaTeX patterns
# ===========================================================================

_LATEX_LABEL_RE = re.compile(r"\\label\{([^}]+)\}")
_LATEX_REF_RE = re.compile(
    r"\\(?:ref|eqref|autoref|cref|Cref|pageref)\{([^}]+)\}"
    r"|\\hyperref\[([^\]]+)\]\{[^}]*\}"
)
_LATEX_CAPTION_RE = re.compile(r"\\caption(?:\[[^\]]*\])?\{")
# Outer float environments to check for caption presence
_FLOAT_ENV_NAMES = "figure|table|listing|algorithm|wrapfigure|wraptable"
_LATEX_FIGURE_ENV_RE = re.compile(rf"\\begin\{{({_FLOAT_ENV_NAMES})\*?\}}")
_LATEX_FIGURE_ENV_END_RE = re.compile(rf"\\end\{{({_FLOAT_ENV_NAMES})\*?\}}")
# Inner environments nested inside floats — skip their own caption checks
_LATEX_INNER_BEGIN_RE = re.compile(r"\\begin\{(?:subfigure|subtable|minipage)\}")
_LATEX_INNER_END_RE = re.compile(r"\\end\{(?:subfigure|subtable|minipage)\}")
_LATEX_COMMENT_PREFIX = "%"

# Float and inner environment name sets (for documentation / future use)
FLOAT_ENVS = frozenset({"figure", "table", "listing", "algorithm", "wrapfigure", "wraptable"})
SKIP_INNER = frozenset({"subfigure", "subtable", "minipage"})

# ===========================================================================
# Typst patterns
# ===========================================================================

_TYPST_LABEL_RE = re.compile(r"<([a-zA-Z][\w-]*)>")
_TYPST_REF_RE = re.compile(r"@([a-zA-Z][\w-]*)|#ref\(\s*<([a-zA-Z][\w-]*)>\s*\)")
_TYPST_CAPTION_RE = re.compile(r"caption\s*:\s*\[")
_TYPST_FIGURE_ENV_RE = re.compile(r"#figure\s*\(")
_TYPST_COMMENT_PREFIX = "//"

# ===========================================================================
# Shared constants
# ===========================================================================

TRACKED_PREFIXES = {"fig", "tab", "eq"}
ORDERING_PREFIXES = {"fig", "tab"}


# ===========================================================================
# Data classes
# ===========================================================================


@dataclass
class LabelInfo:
    """Label definition information."""

    name: str  # Full label name (e.g., "fig:arch")
    prefix: str  # Prefix (e.g., "fig", "tab", "eq")
    line: int  # Definition line number (1-indexed)
    file: str  # Source file path


@dataclass
class RefInfo:
    """Reference information."""

    name: str  # Referenced label name
    line: int  # Reference line number (1-indexed)
    file: str  # Source file path
    command: str  # Reference command (e.g., "ref", "eqref", "autoref")


# ===========================================================================
# Router checker
# ===========================================================================


class ReferenceChecker:
    """
    Reference integrity checker that handles both LaTeX and Typst sources.

    Pass mode="latex" (default) or mode="typst" to select the pattern set.
    """

    def __init__(self, content: str, file_path: str = "", mode: str = "latex") -> None:
        if mode not in ("latex", "typst"):
            raise ValueError(f"Unknown mode: {mode!r}. Use 'latex' or 'typst'.")
        self.content = content
        self.file_path = file_path
        self.mode = mode
        self.lines = content.splitlines()
        self.issues: list[dict] = []

        # Select pattern set
        if mode == "latex":
            self._label_re = _LATEX_LABEL_RE
            self._ref_re = _LATEX_REF_RE
            self._caption_re = _LATEX_CAPTION_RE
            self._figure_env_re = _LATEX_FIGURE_ENV_RE
            self._figure_env_end_re: re.Pattern[str] | None = _LATEX_FIGURE_ENV_END_RE
            self._comment_prefix = _LATEX_COMMENT_PREFIX
        else:
            self._label_re = _TYPST_LABEL_RE
            self._ref_re = _TYPST_REF_RE
            self._caption_re = _TYPST_CAPTION_RE
            self._figure_env_re = _TYPST_FIGURE_ENV_RE
            self._figure_env_end_re = None  # Typst uses paren-depth tracking
            self._comment_prefix = _TYPST_COMMENT_PREFIX

    # ------------------------------------------------------------------
    # Internal helpers
    # ------------------------------------------------------------------

    def _is_comment_line(self, line: str) -> bool:
        """Return True if the line (after stripping) is a comment."""
        return line.lstrip().startswith(self._comment_prefix)

    def _strip_comment(self, line: str) -> str:
        """Remove inline comment from a line."""
        if self.mode == "latex":
            return re.sub(r"(?<!\\)%.*", "", line)
        # Typst: // comment
        idx = line.find("//")
        return line[:idx] if idx != -1 else line

    def _add_issue(self, line: int, severity: str, priority: str, message: str) -> None:
        """Append a structured issue dict."""
        self.issues.append(
            {
                "module": "REFERENCES",
                "line": line,
                "severity": severity,
                "priority": priority,
                "message": message,
            }
        )

    @staticmethod
    def _extract_prefix(label_name: str) -> str:
        """Extract prefix from a label name (supports colon and hyphen separators)."""
        for sep in (":", "-"):
            if sep in label_name:
                return label_name.split(sep)[0]
        return ""

    # ------------------------------------------------------------------
    # Finders
    # ------------------------------------------------------------------

    def find_labels(self) -> list[LabelInfo]:
        """Find all label definitions."""
        labels: list[LabelInfo] = []
        for lineno, raw_line in enumerate(self.lines, start=1):
            if self._is_comment_line(raw_line):
                continue
            line = self._strip_comment(raw_line)
            for match in self._label_re.finditer(line):
                name = match.group(1).strip()
                prefix = self._extract_prefix(name)
                labels.append(LabelInfo(name=name, prefix=prefix, line=lineno, file=self.file_path))
        return labels

    def find_refs(self) -> list[RefInfo]:
        """Find all reference commands."""
        refs: list[RefInfo] = []
        for lineno, raw_line in enumerate(self.lines, start=1):
            if self._is_comment_line(raw_line):
                continue
            line = self._strip_comment(raw_line)
            for match in self._ref_re.finditer(line):
                if self.mode == "latex":
                    # Group 1: \ref{...} family; group 2: \hyperref[...]{...}
                    name = (match.group(1) or match.group(2) or "").strip()
                    full = match.group(0)
                    if full.startswith(r"\hyperref"):
                        command = "hyperref"
                    else:
                        cmd_m = re.match(r"\\(\w+)\{", full)
                        command = cmd_m.group(1) if cmd_m else "ref"
                else:
                    # Group 1: @name; group 2: #ref(<name>)
                    name = (match.group(1) or match.group(2) or "").strip()
                    command = "ref" if match.group(1) else "hash-ref"
                if name:
                    refs.append(
                        RefInfo(name=name, line=lineno, file=self.file_path, command=command)
                    )
        return refs

    # ------------------------------------------------------------------
    # Checks
    # ------------------------------------------------------------------

    def check_undefined_refs(self, labels: list[LabelInfo], refs: list[RefInfo]) -> None:
        """Check for references with no matching label. Severity: Critical, P0."""
        defined = {lbl.name for lbl in labels}
        for ref in refs:
            if ref.name not in defined:
                if self.mode == "latex":
                    ref_repr = f"\\{ref.command}{{{ref.name}}}"
                else:
                    ref_repr = f"@{ref.name}" if ref.command == "ref" else f"#ref(<{ref.name}>)"
                self._add_issue(
                    line=ref.line,
                    severity="Critical",
                    priority="P0",
                    message=f"Undefined reference: {ref_repr} — no matching label found",
                )

    def check_unreferenced_labels(self, labels: list[LabelInfo], refs: list[RefInfo]) -> None:
        """Check labels never referenced (fig/tab/eq only). Severity: Minor, P2."""
        referenced = {ref.name for ref in refs}
        for lbl in labels:
            if lbl.prefix in TRACKED_PREFIXES and lbl.name not in referenced:
                label_repr = f"\\label{{{lbl.name}}}" if self.mode == "latex" else f"<{lbl.name}>"
                self._add_issue(
                    line=lbl.line,
                    severity="Minor",
                    priority="P2",
                    message=f"Unreferenced label: {label_repr} is never cited in text",
                )

    def check_caption_presence(self, labels: list[LabelInfo]) -> None:
        """
        Check that figure/table environments containing a label also have a caption.
        Severity: Major, P1.
        """
        if self.mode == "latex":
            self._check_caption_latex(labels)
        else:
            self._check_caption_typst(labels)

    def _check_caption_latex(self, labels: list[LabelInfo]) -> None:
        """LaTeX caption check — outer-float-only with inner-env depth tracking."""
        assert self._figure_env_end_re is not None
        envs: list[tuple[int, int, str]] = []
        stack: list[tuple[int, str]] = []
        inner_depth: int = 0  # depth of SKIP_INNER (subfigure/subtable/minipage) envs

        for lineno, raw_line in enumerate(self.lines, start=1):
            if self._is_comment_line(raw_line):
                continue
            line = self._strip_comment(raw_line)
            # Track inner (non-float) environment depth first
            if _LATEX_INNER_BEGIN_RE.search(line):
                inner_depth += 1
            if _LATEX_INNER_END_RE.search(line) and inner_depth > 0:
                inner_depth -= 1
            # Float begin — only push when outside SKIP_INNER envs
            begin_m = self._figure_env_re.search(line)
            if begin_m and inner_depth == 0:
                stack.append((lineno, begin_m.group(1)))
            # Float end — pop and record only outermost spans
            end_m = self._figure_env_end_re.search(line)
            if end_m and stack and inner_depth == 0:
                start_lineno, env_type = stack.pop()
                envs.append((start_lineno, lineno, env_type))

        for lbl in labels:
            if lbl.prefix not in ("fig", "tab"):
                continue
            enclosing = next(((s, e, t) for s, e, t in envs if s <= lbl.line <= e), None)
            if enclosing is None:
                continue
            start, end, env_type = enclosing
            env_text = "\n".join(self.lines[start - 1 : end])
            if not self._caption_re.search(env_text):
                self._add_issue(
                    line=lbl.line,
                    severity="Major",
                    priority="P1",
                    message=(
                        f"Missing caption in {env_type} environment: "
                        f"\\label{{{lbl.name}}} at line {lbl.line} has no \\caption"
                    ),
                )

    def _check_caption_typst(self, labels: list[LabelInfo]) -> None:
        """Typst caption check using parenthesis-depth tracking, string-literal aware."""
        figure_spans: list[tuple[int, int]] = []
        content = self.content

        for fig_match in self._figure_env_re.finditer(content):
            open_paren_idx = fig_match.end() - 1
            depth = 0
            end_idx = open_paren_idx
            in_string = False
            escape_next = False
            for i in range(open_paren_idx, len(content)):
                ch = content[i]
                if escape_next:
                    escape_next = False
                    continue
                if ch == "\\" and in_string:
                    escape_next = True
                    continue
                if ch == '"':
                    in_string = not in_string
                    continue
                if in_string:
                    continue
                if ch == "(":
                    depth += 1
                elif ch == ")":
                    depth -= 1
                    if depth == 0:
                        end_idx = i
                        break
            start_line = content[: fig_match.start()].count("\n") + 1
            end_line = content[:end_idx].count("\n") + 1
            figure_spans.append((start_line, end_line))

        for lbl in labels:
            if lbl.prefix not in ("fig", "tab"):
                continue
            enclosing = next(((s, e) for s, e in figure_spans if s <= lbl.line <= e), None)
            if enclosing is None:
                continue
            start, end = enclosing
            block_text = "\n".join(self.lines[start - 1 : end])
            if not self._caption_re.search(block_text):
                self._add_issue(
                    line=lbl.line,
                    severity="Major",
                    priority="P1",
                    message=(
                        f"Missing caption in #figure block: "
                        f"<{lbl.name}> at line {lbl.line} has no caption: [...]"
                    ),
                )

    def check_ordering(self, labels: list[LabelInfo], refs: list[RefInfo]) -> None:
        """Check first reference does not precede label definition. Severity: Minor, P2."""
        label_lines: dict[str, int] = {lbl.name: lbl.line for lbl in labels}
        first_ref_lines: dict[str, int] = {}
        for ref in refs:
            if ref.name not in first_ref_lines or ref.line < first_ref_lines[ref.name]:
                first_ref_lines[ref.name] = ref.line

        for name, ref_line in first_ref_lines.items():
            prefix = self._extract_prefix(name)
            if prefix not in ORDERING_PREFIXES:
                continue
            if name in label_lines and ref_line < label_lines[name]:
                ref_repr = f"\\ref{{{name}}}" if self.mode == "latex" else f"@{name}"
                self._add_issue(
                    line=ref_line,
                    severity="Minor",
                    priority="P2",
                    message=(
                        f"Reference before definition: {ref_repr} at line {ref_line} "
                        f"appears before label definition at line {label_lines[name]}"
                    ),
                )

    def check_numbering_gaps(self, labels: list[LabelInfo]) -> None:
        """Detect numbering gaps for labels with numeric suffixes. Severity: Minor, P2."""
        numeric_suffix_re = re.compile(r"^(.*?)(\d+)$")
        series: dict[str, list[tuple[int, int]]] = {}

        for lbl in labels:
            m = numeric_suffix_re.match(lbl.name)
            if not m:
                continue
            base = m.group(1)
            num = int(m.group(2))
            if base not in series:
                series[base] = []
            series[base].append((num, lbl.line))

        for series_key, entries in series.items():
            if len(entries) < 2:
                continue
            entries_sorted = sorted(entries, key=lambda x: x[0])
            numbers = [e[0] for e in entries_sorted]
            for i in range(len(numbers) - 1):
                if numbers[i + 1] - numbers[i] > 1:
                    missing_start = numbers[i] + 1
                    missing_end = numbers[i + 1] - 1
                    missing_range = (
                        str(missing_start)
                        if missing_start == missing_end
                        else f"{missing_start}–{missing_end}"
                    )
                    self._add_issue(
                        line=entries_sorted[i][1],
                        severity="Minor",
                        priority="P2",
                        message=(
                            f"Numbering gap detected: {series_key}{missing_range} "
                            f"missing between {series_key}{numbers[i]} and "
                            f"{series_key}{numbers[i + 1]}"
                        ),
                    )

    # ------------------------------------------------------------------
    # Runner
    # ------------------------------------------------------------------

    def run_all(self) -> list[dict]:
        """Run all checks and return the full issues list."""
        self.issues = []
        labels = self.find_labels()
        refs = self.find_refs()
        self.check_undefined_refs(labels, refs)
        self.check_unreferenced_labels(labels, refs)
        self.check_caption_presence(labels)
        self.check_ordering(labels, refs)
        self.check_numbering_gaps(labels)
        return self.issues


# ===========================================================================
# Output formatting
# ===========================================================================


def _format_issues(issues: list[dict], comment_prefix: str) -> str:
    """Format issues into the project's output protocol."""
    if not issues:
        return ""
    lines = []
    for issue in sorted(issues, key=lambda x: x.get("line") or 0):
        line_part = f"(Line {issue['line']}) " if issue.get("line") else ""
        lines.append(
            f"{comment_prefix} REFERENCES {line_part}"
            f"[Severity: {issue['severity']}] [Priority: {issue['priority']}]: "
            f"{issue['message']}"
        )
    return "\n".join(lines)


# ===========================================================================
# CLI
# ===========================================================================


def main() -> int:
    """Entry point."""
    parser = argparse.ArgumentParser(
        description=(
            "Reference Integrity Checker — routes to LaTeX or Typst mode "
            "based on file extension (.tex / .typ / .pdf)"
        )
    )
    parser.add_argument("file", help="Source file (.tex, .typ, or .pdf)")
    parser.add_argument("--json", action="store_true", help="Output JSON format")
    args = parser.parse_args()

    path = Path(args.file)
    ext = path.suffix.lower()

    # PDF: cannot extract label/ref syntax
    if ext == ".pdf":
        print(
            "# REFERENCES: Skipped for PDF input "
            "(cannot extract label/ref syntax from compiled PDF)"
        )
        return 0

    if not path.exists():
        print(f"[ERROR] File not found: {args.file}", file=sys.stderr)
        return 1

    try:
        content = path.read_text(encoding="utf-8")
    except OSError as exc:
        print(f"[ERROR] Cannot read file: {exc}", file=sys.stderr)
        return 1

    # Select mode
    if ext == ".typ":
        mode = "typst"
        comment_prefix = _TYPST_COMMENT_PREFIX
    else:
        # Default to LaTeX for .tex and any unrecognised extension
        mode = "latex"
        comment_prefix = _LATEX_COMMENT_PREFIX

    checker = ReferenceChecker(content, str(path), mode=mode)
    issues = checker.run_all()

    if args.json:
        print(json.dumps(issues, indent=2, ensure_ascii=False))
    else:
        output = _format_issues(issues, comment_prefix=comment_prefix)
        if output:
            print(output)

    has_critical = any(i["severity"] == "Critical" for i in issues)
    return 1 if has_critical else 0


if __name__ == "__main__":
    sys.exit(main())

#!/usr/bin/env python3
"""
PDF Visual Layout Checker.
Detects margin overflows, text block overlaps, font inconsistencies,
low-resolution images, and blank pages in PDF documents.

Usage:
    python visual_check.py paper.pdf
    python visual_check.py paper.pdf --margin 72 --min-dpi 150
    python visual_check.py paper.pdf --json
"""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

# Module-level availability check — safe to import as library without pymupdf installed
try:
    import pymupdf as _pymupdf_module

    _PYMUPDF_AVAILABLE = True
except ImportError:
    _pymupdf_module = None  # type: ignore[assignment]
    _PYMUPDF_AVAILABLE = False


def _calc_overlap_area(r1: tuple, r2: tuple) -> float:
    """Calculate overlap area between two rectangles (x0, y0, x1, y1)."""
    x_overlap = max(0, min(r1[2], r2[2]) - max(r1[0], r2[0]))
    y_overlap = max(0, min(r1[3], r2[3]) - max(r1[1], r2[1]))
    return x_overlap * y_overlap


class VisualChecker:
    """PDF visual layout checker."""

    def __init__(
        self,
        pdf_path: str,
        margin_pt: float = 72.0,
        min_dpi: int = 150,
        margin_tolerance: float = 5.0,
        overlap_threshold: float = 100.0,
    ) -> None:
        if not _PYMUPDF_AVAILABLE:
            raise ImportError("visual_check requires pymupdf: pip install pymupdf")
        self.doc = _pymupdf_module.open(pdf_path)  # type: ignore[union-attr]
        self.margin = margin_pt
        self.min_dpi = min_dpi
        self.margin_tolerance = margin_tolerance
        self.overlap_threshold = overlap_threshold
        self.issues: list[dict] = []

    def __enter__(self) -> VisualChecker:
        return self

    def __exit__(self, *_: object) -> None:
        self.close()

    def check_margins(self) -> None:
        """Detect text blocks overflowing page margins."""
        tolerance = self.margin_tolerance
        for page_num, page in enumerate(self.doc):
            blocks = page.get_text("dict")["blocks"]
            rect = page.rect
            for block in blocks:
                bbox = block["bbox"]  # (x0, y0, x1, y1)
                # Left margin
                if bbox[0] < self.margin - tolerance:
                    self._add_issue(
                        page_num,
                        "Major",
                        "P1",
                        f"Content overflows left margin (x={bbox[0]:.1f}pt, margin={self.margin}pt)",
                    )
                # Right margin
                if bbox[2] > rect.width - self.margin + tolerance:
                    self._add_issue(
                        page_num,
                        "Major",
                        "P1",
                        f"Content overflows right margin (x={bbox[2]:.1f}pt, page_width={rect.width:.1f}pt)",
                    )
                # Top margin
                if bbox[1] < self.margin - tolerance:
                    self._add_issue(
                        page_num,
                        "Major",
                        "P1",
                        f"Content overflows top margin (y={bbox[1]:.1f}pt, margin={self.margin}pt)",
                    )
                # Bottom margin
                if bbox[3] > rect.height - self.margin + tolerance:
                    self._add_issue(
                        page_num,
                        "Major",
                        "P1",
                        f"Content overflows bottom margin (y={bbox[3]:.1f}pt, page_height={rect.height:.1f}pt)",
                    )

    def check_overlaps(self) -> None:
        """Detect overlapping text/image blocks (sorted X-axis with early exit)."""
        for page_num, page in enumerate(self.doc):
            blocks = page.get_text("dict")["blocks"]
            rects = [
                b["bbox"]
                for b in blocks
                if b.get("type") in (0, 1)  # 0=text, 1=image
            ]
            # Sort by x0: once b2.x0 > b1.x1, no further overlap is possible on X axis
            rects.sort(key=lambda r: r[0])
            for i, r1 in enumerate(rects):
                for r2 in rects[i + 1 :]:
                    if r2[0] > r1[2]:  # Early exit: b2 starts after b1 ends
                        break
                    overlap_area = _calc_overlap_area(r1, r2)
                    if overlap_area > self.overlap_threshold:
                        self._add_issue(
                            page_num,
                            "Critical",
                            "P0",
                            f"Block overlap detected: {overlap_area:.0f} sq pt",
                        )

    def check_fonts(self) -> None:
        """Detect body font inconsistency (>2 main fonts in body text range)."""
        font_counter: dict[str, int] = {}
        for page in self.doc:
            blocks = page.get_text("dict")["blocks"]
            for block in blocks:
                for line in block.get("lines", []):
                    for span in line.get("spans", []):
                        size = span["size"]
                        # Body text font size range (9-13pt)
                        if 9 <= size <= 13:
                            font_name = span["font"]
                            font_counter[font_name] = font_counter.get(font_name, 0) + len(
                                span["text"]
                            )
        # Filter to significant fonts (>100 chars)
        main_fonts = [f for f, c in font_counter.items() if c > 100]
        if len(main_fonts) > 2:
            font_list = ", ".join(main_fonts[:5])
            if len(main_fonts) > 5:
                font_list += f" (+{len(main_fonts) - 5} more)"
            self._add_issue(
                0,
                "Minor",
                "P2",
                f"Inconsistent body fonts ({len(main_fonts)} detected): {font_list}",
            )

    def check_image_resolution(self) -> None:
        """Detect low-resolution embedded images."""
        for page_num, page in enumerate(self.doc):
            for img_info in page.get_images(full=True):
                xref = img_info[0]
                try:
                    base_image = self.doc.extract_image(xref)
                except Exception:
                    continue
                if not base_image:
                    continue
                width = base_image.get("width", 0)
                height = base_image.get("height", 0)
                if width == 0 or height == 0:
                    continue
                # Calculate effective DPI from rendered size
                for img_rect in page.get_image_rects(xref):
                    render_width_in = img_rect.width / 72
                    if render_width_in > 0:
                        effective_dpi = width / render_width_in
                        if effective_dpi < self.min_dpi:
                            self._add_issue(
                                page_num,
                                "Major",
                                "P1",
                                f"Low resolution image: {effective_dpi:.0f} DPI "
                                f"(minimum: {self.min_dpi} DPI, "
                                f"pixel size: {width}x{height})",
                            )

    def check_blank_pages(self) -> None:
        """Detect blank pages (no text and no images)."""
        for page_num, page in enumerate(self.doc):
            text = page.get_text("text").strip()
            images = page.get_images()
            if not text and not images:
                self._add_issue(
                    page_num,
                    "Minor",
                    "P2",
                    "Blank page detected",
                )

    def run_all(self) -> list[dict]:
        """Run all visual checks and return issues."""
        self.check_margins()
        self.check_overlaps()
        self.check_fonts()
        self.check_image_resolution()
        self.check_blank_pages()
        return self.issues

    def _add_issue(
        self,
        page: int,
        severity: str,
        priority: str,
        message: str,
    ) -> None:
        self.issues.append(
            {
                "module": "VISUAL",
                "page": page + 1,  # 1-indexed
                "severity": severity,
                "priority": priority,
                "message": message,
            }
        )

    def close(self) -> None:
        """Close the PDF document."""
        self.doc.close()


def _format_issues(issues: list[dict], as_json: bool = False) -> str:
    """Format issues for output."""
    if as_json:
        return json.dumps(issues, indent=2, ensure_ascii=False)

    if not issues:
        return "# VISUAL: No layout issues detected."

    lines = []
    for issue in issues:
        lines.append(
            f"% VISUAL (Page {issue['page']}) "
            f"[Severity: {issue['severity']}] "
            f"[Priority: {issue['priority']}]: "
            f"{issue['message']}"
        )
    return "\n".join(lines)


def main() -> int:
    """CLI entry point."""
    parser = argparse.ArgumentParser(
        description="PDF Visual Layout Checker",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  python visual_check.py paper.pdf
  python visual_check.py paper.pdf --margin 72 --min-dpi 150
  python visual_check.py paper.pdf --json
        """,
    )
    parser.add_argument("pdf_file", help="Path to PDF file")
    parser.add_argument(
        "--margin",
        type=float,
        default=72.0,
        help="Page margin in points (default: 72 = 1 inch)",
    )
    parser.add_argument(
        "--min-dpi",
        type=int,
        default=150,
        help="Minimum image DPI threshold (default: 150)",
    )
    parser.add_argument(
        "--json",
        action="store_true",
        help="Output results in JSON format",
    )

    args = parser.parse_args()

    pdf_path = Path(args.pdf_file)
    if not pdf_path.exists():
        print(f"[ERROR] File not found: {args.pdf_file}", file=sys.stderr)
        return 1

    if pdf_path.suffix.lower() != ".pdf":
        print(f"[ERROR] Not a PDF file: {args.pdf_file}", file=sys.stderr)
        return 1

    try:
        with VisualChecker(
            str(pdf_path),
            margin_pt=args.margin,
            min_dpi=args.min_dpi,
        ) as checker:
            issues = checker.run_all()
    except ImportError as e:
        print(f"[ERROR] {e}", file=sys.stderr)
        return 1
    except Exception as e:
        print(f"[ERROR] Failed to process PDF: {e}", file=sys.stderr)
        return 1

    print(_format_issues(issues, as_json=args.json))

    # Exit 1 if critical issues found
    has_critical = any(i["severity"] == "Critical" for i in issues)
    return 1 if has_critical else 0


if __name__ == "__main__":
    sys.exit(main())

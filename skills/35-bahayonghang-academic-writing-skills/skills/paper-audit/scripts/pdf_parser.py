"""
PDF Parser for Paper Audit skill.
Implements DocumentParser interface with basic (PyMuPDF) and enhanced (pymupdf4llm) modes.
"""

import re

from parsers import DocumentParser


class PdfParser(DocumentParser):
    """
    PDF document parser implementing DocumentParser interface.

    Supports two extraction modes:
    - basic: PyMuPDF text extraction with font-size heading detection
    - enhanced: pymupdf4llm Markdown output with header/table preservation
    """

    # Common academic section names for detection
    SECTION_NAMES = {
        "abstract": r"(?i)^#{1,3}\s*abstract|^abstract\b",
        "introduction": r"(?i)^#{1,3}\s*\d*\.?\s*introduction|^introduction\b",
        "related": r"(?i)^#{1,3}\s*\d*\.?\s*related\s+work|^related\s+work\b",
        "method": r"(?i)^#{1,3}\s*\d*\.?\s*(?:method|methodology|approach)|^(?:method|methodology|approach)\b",
        "experiment": r"(?i)^#{1,3}\s*\d*\.?\s*(?:experiment|evaluation|implementation)|^(?:experiment|evaluation)\b",
        "result": r"(?i)^#{1,3}\s*\d*\.?\s*(?:result|performance)|^(?:result|performance)\b",
        "discussion": r"(?i)^#{1,3}\s*\d*\.?\s*(?:discussion|analysis)|^(?:discussion|analysis)\b",
        "conclusion": r"(?i)^#{1,3}\s*\d*\.?\s*(?:conclusion|conclusions|summary)|^(?:conclusion|conclusions)\b",
    }

    # Chinese section names
    SECTION_NAMES_ZH = {
        "abstract": r"摘\s*要",
        "introduction": r"(?:绪\s*论|引\s*言|第[一1]\s*章)",
        "related": r"(?:相关\s*工作|文献\s*综述|研究\s*现状)",
        "method": r"(?:方法|模型|算法|研究\s*方法)",
        "experiment": r"(?:实验|评估|仿真)",
        "result": r"(?:结果|性能|实验\s*结果)",
        "discussion": r"(?:讨论|分析)",
        "conclusion": r"(?:结论|总结|结束语)",
    }

    def __init__(
        self,
        mode: str = "basic",
        heading_pt: float = 14.0,
        body_pt: float = 12.0,
    ):
        """
        Initialize PdfParser.

        Args:
            mode: Extraction mode - "basic" (pymupdf) or "enhanced" (pymupdf4llm).
            heading_pt: Font size threshold (pt) for H2-level headings (default: 14.0).
            body_pt: Font size threshold (pt) for H3-level headings (default: 12.0).
        """
        if mode not in ("basic", "enhanced"):
            raise ValueError(f"Invalid PDF mode: {mode}. Use 'basic' or 'enhanced'.")
        self.mode = mode
        self.heading_pt = heading_pt
        self.body_pt = body_pt

    def extract_text_from_file(self, file_path: str) -> str:
        """
        Extract text content from a PDF file.

        Args:
            file_path: Path to the PDF file.

        Returns:
            Extracted text content.
        """
        if self.mode == "enhanced":
            return self._extract_enhanced(file_path)
        return self._extract_basic(file_path)

    def _extract_basic(self, file_path: str) -> str:
        """Extract text using PyMuPDF with font-size heading detection."""
        try:
            import pymupdf
        except ImportError as err:
            raise ImportError(
                "pymupdf is required for PDF support. Install with: pip install pymupdf"
            ) from err

        doc = pymupdf.open(file_path)
        pages = []

        for page in doc:
            blocks = page.get_text("dict")["blocks"]
            page_lines = []

            for block in blocks:
                if "lines" not in block:
                    continue
                for line in block["lines"]:
                    text_parts = []
                    max_size = 0
                    for span in line["spans"]:
                        text_parts.append(span["text"])
                        max_size = max(max_size, span["size"])

                    line_text = "".join(text_parts).strip()
                    if not line_text:
                        continue

                    # Detect headings by font size (configurable thresholds)
                    if max_size >= self.heading_pt and len(line_text) < 100:
                        page_lines.append(f"## {line_text}")
                    elif max_size >= self.body_pt and len(line_text) < 100:
                        page_lines.append(f"### {line_text}")
                    else:
                        page_lines.append(line_text)

            pages.append("\n".join(page_lines))

        doc.close()
        return "\n\n".join(pages)

    def _extract_enhanced(self, file_path: str) -> str:
        """Extract text using pymupdf4llm for structured Markdown output."""
        try:
            import pymupdf4llm
        except ImportError as err:
            raise ImportError(
                "pymupdf4llm is required for enhanced PDF mode. "
                "Install with: pip install pymupdf4llm"
            ) from err

        return pymupdf4llm.to_markdown(file_path)

    def split_sections(self, content: str) -> dict[str, tuple[int, int]]:
        """
        Split PDF-extracted text into sections.

        Uses Markdown header patterns (from enhanced mode) or
        font-size-based headers (from basic mode) to detect sections.
        """
        lines = content.split("\n")
        sections: dict[str, tuple[int, int]] = {}
        current_section = None
        section_start = 0

        # Merge both EN and ZH patterns
        all_patterns = {**self.SECTION_NAMES}
        for key, pattern in self.SECTION_NAMES_ZH.items():
            if key in all_patterns:
                all_patterns[key] = f"{all_patterns[key]}|{pattern}"
            else:
                all_patterns[key] = pattern

        for i, line in enumerate(lines):
            stripped = line.strip()
            if not stripped:
                continue

            for section_name, pattern in all_patterns.items():
                if re.search(pattern, stripped):
                    # Close previous section
                    if current_section is not None:
                        sections[current_section] = (section_start, i - 1)
                    current_section = section_name
                    section_start = i
                    break

        # Close last section
        if current_section is not None:
            sections[current_section] = (section_start, len(lines) - 1)

        return sections

    def extract_visible_text(self, line: str) -> str:
        """
        Extract visible text from a PDF-extracted line.
        PDF text is already visible — just strip Markdown headers.
        """
        # Remove Markdown header markers
        text = re.sub(r"^#{1,6}\s+", "", line)
        return text.strip()

    def clean_text(self, content: str, keep_structure: bool = False) -> str:
        """
        Clean PDF-extracted text for analysis.
        Removes page numbers, headers/footers, and Markdown artifacts.
        """
        lines = content.split("\n")
        cleaned = []

        for line in lines:
            stripped = line.strip()

            # Skip empty lines
            if not stripped:
                if keep_structure:
                    cleaned.append("")
                continue

            # Skip likely page numbers (standalone numbers)
            if re.match(r"^\d{1,4}$", stripped):
                continue

            # Skip horizontal rules
            if re.match(r"^[-=_*]{3,}$", stripped):
                continue

            # Remove Markdown image references
            if re.match(r"^!\[", stripped):
                continue

            if keep_structure:
                cleaned.append(stripped)
            else:
                # Remove Markdown formatting for pure prose
                text = re.sub(r"^#{1,6}\s+", "", stripped)
                text = re.sub(r"\*{1,2}([^*]+)\*{1,2}", r"\1", text)  # bold/italic
                text = re.sub(r"`([^`]+)`", r"\1", text)  # inline code
                text = re.sub(r"\[([^\]]+)\]\([^)]+\)", r"\1", text)  # links
                if text.strip():
                    cleaned.append(text.strip())

        return "\n".join(cleaned)

    def get_comment_prefix(self) -> str:
        """Markdown blockquote style for PDF audit comments."""
        return ">"

    def extract_metadata(self, file_path: str) -> dict:
        """
        Extract structured metadata from a PDF file.

        Returns:
            Dict with keys: title, authors, abstract, keywords, references_text.
        """
        content = self.extract_text_from_file(file_path)
        lines = content.split("\n")
        metadata: dict = {
            "title": "",
            "authors": [],
            "abstract": "",
            "keywords": [],
            "references_text": "",
        }

        # Extract title: first large heading or first non-empty line
        for line in lines:
            stripped = line.strip()
            if stripped.startswith("## ") and len(stripped) < 200:
                metadata["title"] = stripped.lstrip("# ").strip()
                break
            elif stripped and not stripped.startswith("#") and len(stripped) > 10:
                metadata["title"] = stripped
                break

        # Extract abstract
        in_abstract = False
        abstract_lines: list[str] = []
        for line in lines:
            stripped = line.strip().lower()
            if re.search(r"^#{1,3}\s*abstract|^abstract\b", stripped):
                in_abstract = True
                continue
            elif in_abstract and re.search(r"^#{1,3}\s*\d*\.?\s*\w", line.strip()):
                break
            elif in_abstract and line.strip():
                abstract_lines.append(line.strip())
        metadata["abstract"] = " ".join(abstract_lines)

        # Extract references section text
        in_refs = False
        ref_lines: list[str] = []
        for line in lines:
            stripped = line.strip().lower()
            if re.search(r"^#{1,3}\s*references|^references\b", stripped):
                in_refs = True
                continue
            elif in_refs and re.search(r"^#{1,2}\s*\w", line.strip()):
                break
            elif in_refs and line.strip():
                ref_lines.append(line.strip())
        metadata["references_text"] = "\n".join(ref_lines)

        return metadata

    def extract_references_list(self, file_path: str) -> list[str]:
        """
        Extract individual reference entries from a PDF file.

        Returns:
            List of reference strings (one per bibliography entry).
        """
        metadata = self.extract_metadata(file_path)
        ref_text = metadata.get("references_text", "")
        if not ref_text:
            return []

        # Split by numbered references [1], [2], ... or author-year patterns
        entries: list[str] = []
        # Try numbered format first
        numbered = re.split(r"\n?\[(\d+)\]\s*", ref_text)
        if len(numbered) > 2:
            # numbered[0] is before first match, then alternating number/text
            for i in range(1, len(numbered), 2):
                if i + 1 < len(numbered) and numbered[i + 1].strip():
                    entries.append(f"[{numbered[i]}] {numbered[i + 1].strip()}")
            return entries

        # Fallback: split by blank lines or lines starting with common patterns
        current: list[str] = []
        for line in ref_text.split("\n"):
            stripped = line.strip()
            if not stripped:
                if current:
                    entries.append(" ".join(current))
                    current = []
            else:
                current.append(stripped)
        if current:
            entries.append(" ".join(current))

        return entries

"""
Parser re-exports for Paper Audit skill.
Provides unified access to DocumentParser, LatexParser, TypstParser,
and the get_parser factory from sibling skills.
"""

import importlib.util
from pathlib import Path
from typing import Any

# Load sibling parsers module by explicit file path to avoid name collision
_SKILLS_ROOT = Path(__file__).resolve().parent.parent.parent
_PARSER_CACHE: dict[str, Any] = {}


def _load_sibling_parsers() -> Any:
    """
    Load sibling parsers module with caching and validation.

    Returns:
        The loaded sibling parsers module.

    Raises:
        ImportError: If sibling parsers cannot be loaded from any candidate path.
    """
    if "sibling" in _PARSER_CACHE:
        return _PARSER_CACHE["sibling"]

    candidates = [_SKILLS_ROOT / "latex-paper-en" / "scripts" / "parsers.py"]
    last_exc: Exception | None = None

    for path in candidates:
        try:
            spec = importlib.util.spec_from_file_location("_sibling_parsers", path)
            if spec is None or spec.loader is None:
                continue
            mod = importlib.util.module_from_spec(spec)
            spec.loader.exec_module(mod)  # type: ignore[union-attr]
            # Validate required attributes
            assert hasattr(mod, "LatexParser"), f"LatexParser missing in {path}"
            assert hasattr(mod, "TypstParser"), f"TypstParser missing in {path}"
            assert hasattr(mod, "DocumentParser"), f"DocumentParser missing in {path}"
            _PARSER_CACHE["sibling"] = mod
            return mod
        except Exception as exc:
            last_exc = exc
            continue

    raise ImportError(f"Cannot load sibling parsers from {_SKILLS_ROOT}: {last_exc}")


_sibling = _load_sibling_parsers()

# Re-export core parser classes
DocumentParser = _sibling.DocumentParser
LatexParser = _sibling.LatexParser
TypstParser = _sibling.TypstParser
extract_title = _sibling.extract_title
extract_abstract = _sibling.extract_abstract
extract_latex_citation_keys = getattr(_sibling, "extract_latex_citation_keys", None)


def get_parser(
    file_path: Any,
    pdf_mode: str = "basic",
    heading_pt: float = 14.0,
    body_pt: float = 12.0,
) -> "DocumentParser":
    """
    Extended factory method supporting PDF in addition to LaTeX/Typst.

    Args:
        file_path: Path to the document file.
        pdf_mode: PDF extraction mode - "basic" (pymupdf) or "enhanced" (pymupdf4llm).
        heading_pt: Font size threshold (pt) for H2-level headings in PDF basic mode.
        body_pt: Font size threshold (pt) for H3-level headings in PDF basic mode.

    Returns:
        Appropriate DocumentParser instance.

    Raises:
        ValueError: If the file format is not supported.
    """
    path_str = str(file_path).lower()

    if path_str.endswith(".typ"):
        return TypstParser()
    elif path_str.endswith(".tex"):
        return LatexParser()
    elif path_str.endswith(".pdf"):
        from pdf_parser import PdfParser

        return PdfParser(mode=pdf_mode, heading_pt=heading_pt, body_pt=body_pt)
    else:
        raise ValueError(
            f"Unsupported format: {Path(file_path).suffix}. Supported formats: .tex, .typ, .pdf"
        )


__all__ = [
    "DocumentParser",
    "LatexParser",
    "TypstParser",
    "get_parser",
    "extract_title",
    "extract_abstract",
    "extract_latex_citation_keys",
]

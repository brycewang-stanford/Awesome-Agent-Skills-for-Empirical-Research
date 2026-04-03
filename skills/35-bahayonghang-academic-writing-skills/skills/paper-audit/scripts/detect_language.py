"""
Language detection for academic documents.
Uses CJK character ratio to determine if a document is Chinese or English.
"""

import unicodedata

# CJK Unicode ranges
_CJK_RANGES = [
    (0x4E00, 0x9FFF),  # CJK Unified Ideographs
    (0x3400, 0x4DBF),  # CJK Unified Ideographs Extension A
    (0x2E80, 0x2EFF),  # CJK Radicals Supplement
    (0x3000, 0x303F),  # CJK Symbols and Punctuation
    (0xFF00, 0xFFEF),  # Fullwidth Forms
    (0xF900, 0xFAFF),  # CJK Compatibility Ideographs
]


def _is_cjk(char: str) -> bool:
    """Check if a character is in CJK Unicode ranges."""
    cp = ord(char)
    return any(start <= cp <= end for start, end in _CJK_RANGES)


def detect_language(text: str, threshold: float = 0.3) -> str:
    """
    Detect document language based on CJK character ratio.

    Args:
        text: Document text content.
        threshold: CJK ratio above which document is classified as Chinese.
                   Default 0.3 (30% CJK characters).

    Returns:
        "zh" for Chinese, "en" for English.
    """
    if not text or not text.strip():
        return "en"

    # Remove whitespace and punctuation for ratio calculation
    chars = [c for c in text if not c.isspace() and unicodedata.category(c)[0] != "P"]

    if not chars:
        return "en"

    cjk_count = sum(1 for c in chars if _is_cjk(c))
    ratio = cjk_count / len(chars)

    return "zh" if ratio >= threshold else "en"


def detect_language_from_file(file_path: str, sample_size: int = 5000) -> str:
    """
    Detect language from a file by reading a sample.

    Args:
        file_path: Path to the document file.
        sample_size: Number of characters to sample from the file.

    Returns:
        "zh" for Chinese, "en" for English.
    """
    try:
        with open(file_path, encoding="utf-8") as f:
            sample = f.read(sample_size)
        return detect_language(sample)
    except (OSError, UnicodeDecodeError):
        return "en"

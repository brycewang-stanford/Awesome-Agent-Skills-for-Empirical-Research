"""
Literature Comparison Module for Paper Audit v3.0.

Compares a paper's bibliography against external search results,
computes coverage metrics, and produces a Literature Grounding score.
"""

from __future__ import annotations

import re
from dataclasses import dataclass
from difflib import SequenceMatcher

# --- Data Models ---


@dataclass
class ComparisonEntry:
    """Comparison between the paper and a related work."""

    related_title: str
    overlap_aspects: list[str]
    differentiators: list[str]
    novelty_impact: str  # "high", "medium", "low"


@dataclass
class CoverageAssessment:
    """Assessment of bibliography coverage against search results."""

    cited_and_found: list[str]  # Papers in both bibliography and search
    found_not_cited: list[str]  # Important papers found but not cited
    cited_not_found: list[str]  # Bibliography entries not in search results
    coverage_ratio: float  # cited_and_found / total found
    recency_score: float  # Fraction of results from last 3 years
    freshness_distribution: dict[str, int]  # year_range -> count


@dataclass
class LiteratureComparisonResult:
    """Complete literature comparison result."""

    comparisons: list[ComparisonEntry]
    coverage: CoverageAssessment
    novelty_assessment: str
    grounding_score: float  # 1-10


# --- Core Functions ---


def _fuzzy_title_match(title_a: str, title_b: str, threshold: float = 0.6) -> bool:
    """Check if two titles refer to the same paper."""
    a = re.sub(r"[^a-z0-9\s]", "", title_a.lower()).strip()
    b = re.sub(r"[^a-z0-9\s]", "", title_b.lower()).strip()
    return SequenceMatcher(None, a, b).ratio() >= threshold


def _extract_citation_titles(content: str) -> list[str]:
    """Extract approximate paper titles from LaTeX/Typst bibliography references."""
    titles: list[str] = []
    # Match bibitem titles: \bibitem{key} Author, "Title", ...
    for m in re.finditer(r"\\bibitem\{[^}]*\}\s*(.*?)(?:\\bibitem|\Z)", content, re.DOTALL):
        text = m.group(1).strip()
        # Try to extract title from common formats
        title_match = re.search(r'["""]([^""\"]+)["""]', text)
        if title_match:
            titles.append(title_match.group(1).strip())
        else:
            # Fallback: take first sentence-like chunk after author
            parts = text.split(".", 2)
            if len(parts) >= 2 and len(parts[1].strip()) > 10:
                titles.append(parts[1].strip())

    return titles


def _compute_freshness(results: list, current_year: int = 2026) -> dict[str, int]:
    """Compute freshness distribution of search results by year range."""
    dist: dict[str, int] = {}
    for r in results:
        year = getattr(r, "year", None)
        if year is None:
            dist["unknown"] = dist.get("unknown", 0) + 1
        elif year >= current_year - 2:
            key = f"{current_year - 2}-{current_year}"
            dist[key] = dist.get(key, 0) + 1
        elif year >= current_year - 5:
            key = f"{current_year - 5}-{current_year - 3}"
            dist[key] = dist.get(key, 0) + 1
        else:
            dist["older"] = dist.get("older", 0) + 1
    return dist


def compare_with_literature(
    paper_content: str,
    paper_citations: list[str],
    literature_results: list,
) -> LiteratureComparisonResult:
    """
    Compare paper's bibliography against external literature search results.

    Args:
        paper_content: Full paper text content.
        paper_citations: Citation keys from the paper (e.g., from \\cite{}).
        literature_results: SearchResult objects from literature search.

    Returns:
        LiteratureComparisonResult with comparisons, coverage, and grounding score.
    """
    # Extract titles from paper bibliography
    bib_titles = _extract_citation_titles(paper_content)

    # Also use citation keys as fallback identifiers
    cited_identifier_set = set(paper_citations) | {t.lower()[:30] for t in bib_titles}

    # Match search results against bibliography
    cited_and_found: list[str] = []
    found_not_cited: list[str] = []
    comparisons: list[ComparisonEntry] = []

    for result in literature_results:
        result_title = getattr(result, "title", "")
        if not result_title:
            continue

        # Check if this result matches any cited paper
        is_cited = False
        for bib_title in bib_titles:
            if _fuzzy_title_match(result_title, bib_title):
                is_cited = True
                cited_and_found.append(result_title)
                break

        if not is_cited:
            # Check against citation keys
            for key in paper_citations:
                if key.lower() in result_title.lower():
                    is_cited = True
                    cited_and_found.append(result_title)
                    break

            # Check against identifier set
            if not is_cited and result_title.lower()[:30] in cited_identifier_set:
                is_cited = True
                cited_and_found.append(result_title)

        if not is_cited:
            found_not_cited.append(result_title)

        # Build comparison entry for top results
        if len(comparisons) < 10:
            abstract = getattr(result, "abstract", "")
            # Simple overlap detection
            overlap = []
            for word in re.findall(r"\b[a-z]{4,}\b", paper_content.lower()):
                if word in abstract.lower() and word not in overlap and len(overlap) < 3:
                    overlap.append(word)

            relevance = getattr(result, "relevance_score", 0.0)
            impact = "high" if relevance > 0.6 else "medium" if relevance > 0.3 else "low"

            comparisons.append(
                ComparisonEntry(
                    related_title=result_title,
                    overlap_aspects=overlap,
                    differentiators=["different scope" if not is_cited else "cited"],
                    novelty_impact=impact,
                )
            )

    # Cited but not found in search results
    cited_not_found: list[str] = []
    for bib_title in bib_titles:
        matched = any(
            _fuzzy_title_match(bib_title, getattr(r, "title", "")) for r in literature_results
        )
        if not matched:
            cited_not_found.append(bib_title)

    # Compute recency
    current_year = 2026
    recent_count = sum(
        1
        for r in literature_results
        if getattr(r, "year", None) and getattr(r, "year", 0) >= current_year - 3
    )
    total_with_year = sum(1 for r in literature_results if getattr(r, "year", None))
    recency_score = recent_count / total_with_year if total_with_year > 0 else 0.0

    # Build coverage assessment
    total_found = len(literature_results)
    coverage_ratio = len(cited_and_found) / total_found if total_found > 0 else 0.0

    coverage = CoverageAssessment(
        cited_and_found=cited_and_found,
        found_not_cited=found_not_cited,
        cited_not_found=cited_not_found,
        coverage_ratio=round(coverage_ratio, 3),
        recency_score=round(recency_score, 3),
        freshness_distribution=_compute_freshness(literature_results),
    )

    # Compute grounding score
    grounding_score = compute_literature_grounding_score(coverage, len(comparisons))

    # Novelty assessment
    high_overlap = sum(1 for c in comparisons if c.novelty_impact == "high")
    if high_overlap == 0:
        novelty_text = "Strong novelty — no highly overlapping papers found."
    elif high_overlap <= 2:
        novelty_text = "Moderate novelty — a few closely related papers exist."
    else:
        novelty_text = "Limited novelty — several highly overlapping papers found."

    return LiteratureComparisonResult(
        comparisons=comparisons,
        coverage=coverage,
        novelty_assessment=novelty_text,
        grounding_score=grounding_score,
    )


def compute_literature_grounding_score(
    coverage: CoverageAssessment,
    comparison_count: int,  # noqa: ARG001
) -> float:
    """
    Compute Literature Grounding score (1-10).

    Factors:
        - Coverage ratio: 40% weight
        - Recency: 20% weight
        - Missing refs penalty: 30% weight
        - Freshness: 10% weight
    """
    # Coverage ratio (0-1) -> contributes 0-4 points
    coverage_component = coverage.coverage_ratio * 4.0

    # Recency (0-1) -> contributes 0-2 points
    recency_component = coverage.recency_score * 2.0

    # Missing refs penalty (0-1) -> contributes 0-3 points
    # Fewer missing refs = higher score
    total_found = len(coverage.cited_and_found) + len(coverage.found_not_cited)
    if total_found > 0:
        missing_ratio = len(coverage.found_not_cited) / total_found
        missing_component = (1.0 - missing_ratio) * 3.0
    else:
        missing_component = 1.5  # Neutral when no data

    # Freshness distribution (0-1) -> contributes 0-1 points
    total_dist = sum(coverage.freshness_distribution.values())
    if total_dist > 0:
        recent_key = [
            k for k in coverage.freshness_distribution if "2024" in k or "2025" in k or "2026" in k
        ]
        recent_count = sum(coverage.freshness_distribution.get(k, 0) for k in recent_key)
        freshness_component = (recent_count / total_dist) * 1.0
    else:
        freshness_component = 0.5

    raw_score = coverage_component + recency_component + missing_component + freshness_component

    # Scale to 1-10 range
    score = max(1.0, min(10.0, raw_score))
    return round(score, 1)


def render_comparison_report(result: LiteratureComparisonResult) -> str:
    """Render literature comparison as Markdown report."""
    lines = [
        "## Literature Comparison Report",
        "",
        f"**Literature Grounding Score**: {result.grounding_score:.1f}/10",
        f"**Novelty Assessment**: {result.novelty_assessment}",
        "",
    ]

    # Coverage statistics
    cov = result.coverage
    lines.extend(
        [
            "### Coverage Statistics",
            "",
            f"- Papers cited and found in search: **{len(cov.cited_and_found)}**",
            f"- Important papers found but NOT cited: **{len(cov.found_not_cited)}**",
            f"- Papers cited but not found: **{len(cov.cited_not_found)}**",
            f"- Coverage ratio: **{cov.coverage_ratio:.1%}**",
            f"- Recency score: **{cov.recency_score:.1%}**",
            "",
        ]
    )

    # Missing important papers
    if cov.found_not_cited:
        lines.extend(
            [
                "### Potentially Missing References",
                "",
                "These papers were found in literature search but are not cited:",
                "",
            ]
        )
        for i, title in enumerate(cov.found_not_cited[:10], 1):
            display = title[:80] + "..." if len(title) > 80 else title
            lines.append(f"{i}. {display}")
        lines.append("")

    # Comparison table
    if result.comparisons:
        lines.extend(
            [
                "### Related Work Comparison",
                "",
                "| # | Related Paper | Overlap | Impact |",
                "|---|--------------|---------|--------|",
            ]
        )
        for i, comp in enumerate(result.comparisons[:10], 1):
            title = (
                comp.related_title[:50] + "..."
                if len(comp.related_title) > 50
                else comp.related_title
            )
            overlap = ", ".join(comp.overlap_aspects[:3]) or "—"
            lines.append(f"| {i} | {title} | {overlap} | {comp.novelty_impact} |")
        lines.append("")

    return "\n".join(lines)

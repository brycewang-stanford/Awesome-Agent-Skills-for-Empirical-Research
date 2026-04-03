"""
Literature Search Engine for Paper Audit v3.0.

Provides multi-source literature search (Semantic Scholar, arXiv, Tavily),
relevance filtering, and context building for literature-enhanced review.

Usage:
    python literature_search.py --title "..." --abstract "..." [--tavily-key KEY] [--json]
"""

from __future__ import annotations

import argparse
import json
import re
import sys
import time
import urllib.error
import urllib.parse
import urllib.request
import xml.etree.ElementTree as ET
from concurrent.futures import ThreadPoolExecutor, as_completed
from dataclasses import dataclass, field
from difflib import SequenceMatcher

# --- Data Models ---


@dataclass
class SearchResult:
    """A single literature search result."""

    title: str
    authors: list[str]
    year: int | None
    abstract: str
    url: str
    source: str  # "semantic_scholar", "arxiv", "tavily"
    relevance_score: float = 0.0
    citation_count: int = 0
    arxiv_id: str = ""
    doi: str = ""


@dataclass
class LiteratureContext:
    """Complete literature context for a paper under review."""

    paper_title: str
    paper_abstract: str
    search_queries: list[str]
    results: list[SearchResult]
    filtered_results: list[SearchResult]
    summaries: list[str] = field(default_factory=list)
    coverage_assessment: str = ""
    comparison_result: object | None = None  # Set by audit.py after comparison


# --- API Clients ---


class SemanticScholarClient:
    """Client for Semantic Scholar API."""

    BASE_URL = "https://api.semanticscholar.org/graph/v1/paper/search"
    FIELDS = "title,authors,year,abstract,url,citationCount,externalIds"

    def __init__(self, api_key: str = ""):
        self.api_key = api_key

    def search(self, query: str, max_results: int = 10) -> list[SearchResult]:
        """Search Semantic Scholar for papers matching query."""
        params = urllib.parse.urlencode(
            {
                "query": query,
                "limit": min(max_results, 100),
                "fields": self.FIELDS,
            }
        )
        url = f"{self.BASE_URL}?{params}"

        headers = {"Accept": "application/json"}
        if self.api_key:
            headers["x-api-key"] = self.api_key

        for attempt in range(3):
            try:
                req = urllib.request.Request(url, headers=headers)
                with urllib.request.urlopen(req, timeout=15) as resp:
                    data = json.loads(resp.read().decode("utf-8"))
                break
            except urllib.error.HTTPError as e:
                if e.code == 429 and attempt < 2:
                    time.sleep(2 ** (attempt + 1))
                    continue
                return []
            except Exception:
                return []

        results: list[SearchResult] = []
        for paper in data.get("data", []):
            if not paper.get("title"):
                continue
            authors = [a.get("name", "") for a in (paper.get("authors") or [])]
            ext_ids = paper.get("externalIds") or {}
            results.append(
                SearchResult(
                    title=paper["title"],
                    authors=authors,
                    year=paper.get("year"),
                    abstract=paper.get("abstract") or "",
                    url=paper.get("url") or "",
                    source="semantic_scholar",
                    citation_count=paper.get("citationCount") or 0,
                    arxiv_id=ext_ids.get("ArXiv", ""),
                    doi=ext_ids.get("DOI", ""),
                )
            )
        return results


class ArxivClient:
    """Client for arXiv API."""

    BASE_URL = "http://export.arxiv.org/api/query"
    NS = {"atom": "http://www.w3.org/2005/Atom"}

    def search(self, query: str, max_results: int = 10) -> list[SearchResult]:
        """Search arXiv for papers matching query."""
        params = urllib.parse.urlencode(
            {
                "search_query": f"all:{query}",
                "start": 0,
                "max_results": min(max_results, 50),
                "sortBy": "relevance",
            }
        )
        url = f"{self.BASE_URL}?{params}"

        try:
            req = urllib.request.Request(url)
            with urllib.request.urlopen(req, timeout=15) as resp:
                xml_text = resp.read().decode("utf-8")
        except Exception:
            return []

        results: list[SearchResult] = []
        try:
            root = ET.fromstring(xml_text)
            for entry in root.findall("atom:entry", self.NS):
                title_el = entry.find("atom:title", self.NS)
                title = (
                    (title_el.text or "").strip().replace("\n", " ") if title_el is not None else ""
                )
                if not title:
                    continue

                summary_el = entry.find("atom:summary", self.NS)
                abstract = (summary_el.text or "").strip() if summary_el is not None else ""

                authors = []
                for author_el in entry.findall("atom:author", self.NS):
                    name_el = author_el.find("atom:name", self.NS)
                    if name_el is not None and name_el.text:
                        authors.append(name_el.text.strip())

                published_el = entry.find("atom:published", self.NS)
                year = None
                if published_el is not None and published_el.text:
                    year = int(published_el.text[:4])

                # Extract arxiv ID from id element
                id_el = entry.find("atom:id", self.NS)
                arxiv_id = ""
                entry_url = ""
                if id_el is not None and id_el.text:
                    entry_url = id_el.text.strip()
                    match = re.search(r"(\d{4}\.\d{4,5})", entry_url)
                    if match:
                        arxiv_id = match.group(1)

                results.append(
                    SearchResult(
                        title=title,
                        authors=authors,
                        year=year,
                        abstract=abstract,
                        url=entry_url,
                        source="arxiv",
                        arxiv_id=arxiv_id,
                    )
                )
        except ET.ParseError:
            pass

        return results


class TavilyClient:
    """Client for Tavily Search API."""

    BASE_URL = "https://api.tavily.com/search"

    def __init__(self, api_key: str = ""):
        self.api_key = api_key

    def search(self, query: str, max_results: int = 10) -> list[SearchResult]:
        """Search Tavily for academic content matching query."""
        if not self.api_key:
            return []

        payload = json.dumps(
            {
                "api_key": self.api_key,
                "query": f"academic paper: {query}",
                "search_depth": "advanced",
                "include_answer": False,
                "max_results": min(max_results, 20),
            }
        ).encode("utf-8")

        try:
            req = urllib.request.Request(
                self.BASE_URL,
                data=payload,
                headers={"Content-Type": "application/json"},
                method="POST",
            )
            with urllib.request.urlopen(req, timeout=20) as resp:
                data = json.loads(resp.read().decode("utf-8"))
        except Exception:
            return []

        results: list[SearchResult] = []
        for item in data.get("results", []):
            title = item.get("title", "")
            if not title:
                continue
            results.append(
                SearchResult(
                    title=title,
                    authors=[],
                    year=None,
                    abstract=item.get("content", "")[:500],
                    url=item.get("url", ""),
                    source="tavily",
                )
            )
        return results


# --- Core Functions ---


def extract_search_metadata(
    content: str,
    file_path: str,  # noqa: ARG001 — reserved for format-specific extraction
    parser: object,  # noqa: ARG001 — reserved for parser-specific extraction
) -> dict:
    """
    Extract metadata from paper content for search query generation.

    Args:
        content: Paper text content.
        file_path: Path to the paper file.
        parser: DocumentParser instance.

    Returns:
        Dict with keys: title, abstract, keywords, methods.
    """
    title = ""
    abstract = ""

    # Try parser's extract_title / extract_abstract if available
    try:
        from parsers import extract_abstract as _extract_abstract
        from parsers import extract_title as _extract_title

        if _extract_title is not None:
            title = _extract_title(content) or ""
        if _extract_abstract is not None:
            abstract = _extract_abstract(content) or ""
    except (ImportError, TypeError):
        pass

    # Fallback: regex extraction
    if not title:
        m = re.search(r"\\title\{([^}]+)\}", content)
        if m:
            title = m.group(1).strip()

    if not abstract:
        m = re.search(r"\\begin\{abstract\}(.*?)\\end\{abstract\}", content, re.DOTALL)
        if m:
            abstract = m.group(1).strip()

    # Extract keywords
    keywords: list[str] = []
    kw_match = re.search(r"\\begin\{keywords?\}(.*?)\\end\{keywords?\}", content, re.DOTALL)
    if kw_match:
        kw_text = kw_match.group(1)
        keywords = [k.strip() for k in re.split(r"[,;]", kw_text) if k.strip()]

    # Extract method names from section headings
    methods: list[str] = []
    for m in re.finditer(
        r"\\(?:sub)?section\*?\{([^}]*(?:method|approach|algorithm|model|framework)[^}]*)\}",
        content,
        re.IGNORECASE,
    ):
        methods.append(m.group(1).strip())

    return {
        "title": title,
        "abstract": abstract,
        "keywords": keywords,
        "methods": methods,
    }


def generate_search_queries(
    title: str,
    abstract: str,
    keywords: list[str],
    methods: list[str],
    max_queries: int = 5,
) -> list[str]:
    """
    Generate diverse search queries from paper metadata.

    Uses 5 strategies: title-based, method-based, problem-based,
    keyword combos, and negation-aware.
    """
    queries: list[str] = []

    # Strategy 1: Title-based (most direct)
    if title:
        # Remove LaTeX commands from title
        clean_title = re.sub(r"\\[a-zA-Z]+\{?", "", title)
        clean_title = re.sub(r"[{}$]", "", clean_title).strip()
        if clean_title:
            queries.append(clean_title)

    # Strategy 2: Method-based
    for method in methods[:2]:
        clean = re.sub(r"\\[a-zA-Z]+\{?", "", method)
        clean = re.sub(r"[{}$]", "", clean).strip()
        if clean and len(clean) > 5:
            queries.append(clean)

    # Strategy 3: Problem-based (from abstract)
    if abstract:
        # Extract first sentence as problem statement
        sentences = re.split(r"[.!?]\s+", abstract)
        if sentences:
            problem = sentences[0].strip()
            problem = re.sub(r"\\[a-zA-Z]+\{?", "", problem)
            problem = re.sub(r"[{}$]", "", problem).strip()
            if len(problem) > 20:
                # Take key words
                words = [w for w in problem.split() if len(w) > 3]
                if len(words) > 3:
                    queries.append(" ".join(words[:8]))

    # Strategy 4: Keyword combinations
    if len(keywords) >= 2:
        queries.append(" ".join(keywords[:4]))

    # Strategy 5: Negation-aware (find alternatives)
    if title:
        # "survey" or "review" + key topic
        key_words = [w for w in title.split() if len(w) > 4 and w.isalpha()]
        if key_words:
            queries.append(f"survey {' '.join(key_words[:3])}")

    # Deduplicate and limit
    seen: set[str] = set()
    unique: list[str] = []
    for q in queries:
        q_lower = q.lower().strip()
        if q_lower and q_lower not in seen:
            seen.add(q_lower)
            unique.append(q)

    return unique[:max_queries]


def _title_similarity(a: str, b: str) -> float:
    """Compute title similarity for deduplication."""
    return SequenceMatcher(None, a.lower().strip(), b.lower().strip()).ratio()


def search_literature(
    queries: list[str],
    tavily_key: str = "",
    s2_key: str = "",
    max_per_source: int = 10,
) -> list[SearchResult]:
    """
    Search multiple sources in parallel and deduplicate results.

    Args:
        queries: Search query strings.
        tavily_key: Optional Tavily API key.
        s2_key: Optional Semantic Scholar API key.
        max_per_source: Max results per source per query.

    Returns:
        Deduplicated list of SearchResult.
    """
    s2_client = SemanticScholarClient(api_key=s2_key)
    arxiv_client = ArxivClient()
    tavily_client = TavilyClient(api_key=tavily_key) if tavily_key else None

    all_results: list[SearchResult] = []

    def _search_s2(query: str) -> list[SearchResult]:
        return s2_client.search(query, max_results=max_per_source)

    def _search_arxiv(query: str) -> list[SearchResult]:
        return arxiv_client.search(query, max_results=max_per_source)

    def _search_tavily(query: str) -> list[SearchResult]:
        if tavily_client:
            return tavily_client.search(query, max_results=max_per_source)
        return []

    # Run searches in parallel
    with ThreadPoolExecutor(max_workers=6) as executor:
        futures = {}
        for query in queries:
            futures[executor.submit(_search_s2, query)] = f"s2:{query}"
            futures[executor.submit(_search_arxiv, query)] = f"arxiv:{query}"
            if tavily_client:
                futures[executor.submit(_search_tavily, query)] = f"tavily:{query}"

        for future in as_completed(futures):
            try:
                results = future.result()
                all_results.extend(results)
            except Exception:
                continue

    # Deduplicate by title similarity
    unique: list[SearchResult] = []
    for result in all_results:
        is_dup = False
        for existing in unique:
            if _title_similarity(result.title, existing.title) > 0.85:
                # Keep the one with more info (higher citation count or more abstract)
                if result.citation_count > existing.citation_count:
                    unique.remove(existing)
                    unique.append(result)
                is_dup = True
                break
        if not is_dup:
            unique.append(result)

    return unique


def filter_by_relevance(
    results: list[SearchResult],
    paper_title: str,
    paper_abstract: str,
    min_score: float = 0.3,
    max_results: int = 20,
) -> list[SearchResult]:
    """
    Filter and rank search results by relevance to the paper.

    Uses word overlap between paper and result title+abstract.
    """
    if not results:
        return []

    # Build paper word set (simple TF-IDF-like)
    paper_text = f"{paper_title} {paper_abstract}".lower()
    paper_words = set(re.findall(r"\b[a-z]{3,}\b", paper_text))
    # Remove common stop words
    stop_words = {
        "the",
        "and",
        "for",
        "are",
        "but",
        "not",
        "you",
        "all",
        "can",
        "had",
        "her",
        "was",
        "one",
        "our",
        "out",
        "has",
        "have",
        "been",
        "from",
        "this",
        "that",
        "with",
        "they",
        "will",
        "each",
        "which",
        "their",
        "said",
        "many",
        "some",
        "them",
        "than",
        "its",
        "over",
        "into",
        "such",
        "after",
        "most",
        "also",
        "made",
        "about",
        "more",
        "these",
        "other",
        "could",
        "would",
        "paper",
        "propose",
        "proposed",
        "method",
        "approach",
        "results",
        "show",
        "based",
        "using",
        "model",
    }
    paper_words -= stop_words

    if not paper_words:
        return results[:max_results]

    for result in results:
        result_text = f"{result.title} {result.abstract}".lower()
        result_words = set(re.findall(r"\b[a-z]{3,}\b", result_text))
        result_words -= stop_words

        if not result_words:
            result.relevance_score = 0.0
            continue

        # Jaccard-like overlap
        overlap = len(paper_words & result_words)
        union = len(paper_words | result_words)
        word_score = overlap / union if union > 0 else 0.0

        # Title similarity bonus
        title_sim = _title_similarity(paper_title, result.title)

        # Citation bonus (log scale)
        import math

        cite_bonus = min(0.1, math.log1p(result.citation_count) / 100)

        result.relevance_score = round(0.5 * word_score + 0.35 * title_sim + 0.15 * cite_bonus, 3)

    # Filter and sort
    filtered = [r for r in results if r.relevance_score >= min_score]
    filtered.sort(key=lambda r: r.relevance_score, reverse=True)
    return filtered[:max_results]


def build_literature_context(
    file_path: str,
    content: str,
    parser: object,
    tavily_key: str = "",
    s2_key: str = "",
) -> LiteratureContext:
    """
    Main entry point: build complete literature context for a paper.

    Orchestrates: extract metadata -> generate queries -> search -> filter.
    """
    # Step 1: Extract metadata
    meta = extract_search_metadata(content, file_path, parser)
    title = meta["title"]
    abstract = meta["abstract"]

    # Step 2: Generate queries
    queries = generate_search_queries(
        title=title,
        abstract=abstract,
        keywords=meta["keywords"],
        methods=meta["methods"],
    )

    if not queries:
        return LiteratureContext(
            paper_title=title,
            paper_abstract=abstract,
            search_queries=[],
            results=[],
            filtered_results=[],
            coverage_assessment="No search queries could be generated.",
        )

    # Step 3: Search literature
    results = search_literature(
        queries=queries,
        tavily_key=tavily_key,
        s2_key=s2_key,
    )

    # Step 4: Filter by relevance
    filtered = filter_by_relevance(
        results=results,
        paper_title=title,
        paper_abstract=abstract,
    )

    # Build context
    return LiteratureContext(
        paper_title=title,
        paper_abstract=abstract,
        search_queries=queries,
        results=results,
        filtered_results=filtered,
        coverage_assessment=f"Found {len(results)} total, {len(filtered)} relevant.",
    )


def render_literature_summary(context: LiteratureContext) -> str:
    """Render LiteratureContext as Markdown for agent consumption."""
    lines = [
        "### Literature Search Results",
        "",
        f"**Paper**: {context.paper_title}",
        f"**Queries used**: {len(context.search_queries)}",
        f"**Total results**: {len(context.results)} | "
        f"**Relevant**: {len(context.filtered_results)}",
        "",
    ]

    if context.search_queries:
        lines.append("**Search queries**:")
        for i, q in enumerate(context.search_queries, 1):
            lines.append(f"  {i}. `{q}`")
        lines.append("")

    if context.filtered_results:
        lines.append("**Top relevant papers**:")
        lines.append("")
        lines.append("| # | Title | Year | Source | Relevance | Citations |")
        lines.append("|---|-------|------|--------|-----------|-----------|")
        for i, r in enumerate(context.filtered_results[:15], 1):
            title = r.title[:60] + "..." if len(r.title) > 60 else r.title
            year = str(r.year) if r.year else "N/A"
            lines.append(
                f"| {i} | {title} | {year} | {r.source} | "
                f"{r.relevance_score:.2f} | {r.citation_count} |"
            )
        lines.append("")

    if context.coverage_assessment:
        lines.append(f"**Coverage**: {context.coverage_assessment}")

    return "\n".join(lines)


# --- CLI ---


def main() -> int:
    """CLI entry point."""
    parser = argparse.ArgumentParser(
        description="Literature Search Engine for Paper Audit",
    )
    parser.add_argument("--title", default="", help="Paper title")
    parser.add_argument("--abstract", default="", help="Paper abstract")
    parser.add_argument("--tavily-key", default="", help="Tavily API key")
    parser.add_argument("--s2-key", default="", help="Semantic Scholar API key")
    parser.add_argument("--json", action="store_true", help="Output JSON")
    parser.add_argument("--max-results", type=int, default=20, help="Max results")

    args = parser.parse_args()

    if not args.title:
        print("Error: --title is required", file=sys.stderr)
        return 1

    queries = generate_search_queries(
        title=args.title,
        abstract=args.abstract,
        keywords=[],
        methods=[],
    )
    print(f"[search] Generated {len(queries)} queries", file=sys.stderr)

    results = search_literature(
        queries=queries,
        tavily_key=args.tavily_key,
        s2_key=args.s2_key,
    )
    print(f"[search] Found {len(results)} results", file=sys.stderr)

    filtered = filter_by_relevance(
        results=results,
        paper_title=args.title,
        paper_abstract=args.abstract,
        max_results=args.max_results,
    )

    if args.json:
        output = [
            {
                "title": r.title,
                "authors": r.authors,
                "year": r.year,
                "abstract": r.abstract[:200],
                "url": r.url,
                "source": r.source,
                "relevance_score": r.relevance_score,
                "citation_count": r.citation_count,
            }
            for r in filtered
        ]
        print(json.dumps(output, indent=2, ensure_ascii=False))
    else:
        ctx = LiteratureContext(
            paper_title=args.title,
            paper_abstract=args.abstract,
            search_queries=queries,
            results=results,
            filtered_results=filtered,
        )
        print(render_literature_summary(ctx))

    return 0


if __name__ == "__main__":
    sys.exit(main())

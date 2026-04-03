"""
Report Generator for Paper Audit skill.
Handles scoring engine, issue aggregation, and Markdown report rendering.
"""

from dataclasses import dataclass, field
from datetime import datetime
from pathlib import Path
from typing import Any, Optional

# --- Data Models ---


@dataclass
class AuditIssue:
    """A single issue found during audit."""

    module: str  # e.g., "FORMAT", "GRAMMAR", "LOGIC"
    line: Optional[int]  # Line number (None if not applicable)
    severity: str  # "Critical", "Major", "Minor"
    priority: str  # "P0", "P1", "P2"
    message: str  # Issue description
    original: str = ""  # Original text (if applicable)
    revised: str = ""  # Suggested revision (if applicable)
    rationale: str = ""  # Explanation


@dataclass
class DeepReviewIssue:
    """A structured reviewer finding used by deep-review workflows."""

    ISSUE_KEYS = (
        "title",
        "quote",
        "explanation",
        "comment_type",
        "severity",
        "confidence",
        "source_kind",
        "source_section",
        "related_sections",
        "root_cause_key",
        "review_lane",
        "gate_blocker",
        "quote_verified",
    )

    title: str
    quote: str
    explanation: str
    comment_type: str
    severity: str
    confidence: str = "medium"
    source_kind: str = "llm"
    source_section: str = ""
    related_sections: list[str] = field(default_factory=list)
    root_cause_key: str = ""
    review_lane: str = ""
    gate_blocker: bool = False
    quote_verified: Optional[bool] = None

    @classmethod
    def from_dict(cls, issue: dict) -> "DeepReviewIssue":
        """Build a DeepReviewIssue from a persisted issue mapping."""
        payload = {key: issue[key] for key in cls.ISSUE_KEYS if key in issue}
        return cls(**payload)

    def to_dict(self) -> dict:
        return {
            "title": self.title,
            "quote": self.quote,
            "explanation": self.explanation,
            "comment_type": self.comment_type,
            "severity": self.severity,
            "confidence": self.confidence,
            "source_kind": self.source_kind,
            "source_section": self.source_section,
            "related_sections": list(self.related_sections),
            "root_cause_key": self.root_cause_key,
            "review_lane": self.review_lane,
            "gate_blocker": self.gate_blocker,
            "quote_verified": self.quote_verified,
        }


@dataclass
class ChecklistItem:
    """A single pre-submission checklist item."""

    description: str
    passed: bool
    details: str = ""  # Additional context for failures


@dataclass
class AuditResult:
    """Complete audit result from all checks."""

    file_path: str
    language: str  # "en" or "zh"
    mode: str  # "quick-audit", "deep-review", "gate", "polish", "re-audit"
    venue: str = ""  # e.g., "neurips", "ieee"
    mode_alias_used: str | None = None
    issues: list[AuditIssue] = field(default_factory=list)
    issue_bundle: list[DeepReviewIssue] = field(default_factory=list)
    checklist: list[ChecklistItem] = field(default_factory=list)
    # Review mode extras
    strengths: list[str] = field(default_factory=list)
    weaknesses: list[str] = field(default_factory=list)
    questions: list[str] = field(default_factory=list)
    summary: str = ""
    overall_assessment: str = ""
    revision_roadmap: list[dict] = field(default_factory=list)
    section_index: list[dict] = field(default_factory=list)
    artifact_dir: str = ""
    # ScholarEval result (optional, populated when --scholar-eval is used)
    scholar_eval_result: object | None = None
    # Literature context (optional, populated when --literature-search is used)
    literature_context: object | None = None
    # Multi-perspective review extras (populated by SKILL.md agent workflow)
    agent_reviews: list[dict] = field(default_factory=list)
    consensus: str = ""
    # Re-audit comparison data (populated by run_reaudit)
    reaudit_data: dict | None = None


@dataclass
class PolishSectionVerdict:
    """Critic's verdict for a single section."""

    section: str
    logic_score: int  # 1-5
    expression_score: int  # 1-5
    blocks_mentor: bool
    blocking_reason: str = ""
    top_issues: list[dict] = field(default_factory=list)
    mentor_done: bool = False
    mentor_suggestions_count: int = 0


# --- Dimension Mapping & Scoring ---

DIMENSION_MAP: dict[str, list[str]] = {
    "format": ["clarity"],
    "grammar": ["clarity"],
    "logic": ["quality", "significance"],
    "experiment": ["quality", "significance"],
    "sentences": ["clarity"],
    "deai": ["clarity", "originality"],
    "citations": ["quality"],
    "bib": ["quality"],
    "figures": ["clarity"],
    "consistency": ["clarity"],
    "gbt7714": ["quality"],
    "checklist": ["quality", "clarity", "significance", "originality"],
    "references": ["clarity", "quality"],
    "visual": ["clarity"],
    "literature_grounding": ["quality", "significance", "originality"],
}

DIMENSION_WEIGHTS: dict[str, float] = {
    "quality": 0.30,
    "clarity": 0.30,
    "significance": 0.20,
    "originality": 0.20,
}

SEVERITY_DEDUCTIONS: dict[str, float] = {
    "Critical": 1.5,
    "Major": 0.75,
    "Minor": 0.25,
}

SCORE_LABELS: list[tuple[float, str]] = [
    (5.5, "Strong Accept"),
    (4.5, "Accept"),
    (3.5, "Borderline Accept"),
    (2.5, "Borderline Reject"),
    (1.5, "Reject"),
    (0.0, "Strong Reject"),
]

DEEP_REVIEW_SEVERITY_ORDER: dict[str, int] = {
    "major": 0,
    "moderate": 1,
    "minor": 2,
}

SOURCE_KIND_LABELS: dict[str, str] = {
    "llm": "[LLM]",
    "script": "[Script]",
}

DEEP_REVIEW_ISSUE_KEYS: tuple[str, ...] = (
    "title",
    "quote",
    "explanation",
    "comment_type",
    "severity",
    "confidence",
    "source_kind",
    "source_section",
    "related_sections",
    "root_cause_key",
    "review_lane",
    "gate_blocker",
    "quote_verified",
)

DEEP_REVIEW_PRIORITY_LABELS: dict[str, str] = {
    "major": "Priority 1",
    "moderate": "Priority 2",
    "minor": "Priority 3",
}

DEEP_REVIEW_SECTIONS: tuple[tuple[str, str], ...] = (
    ("major", "Major Issues"),
    ("moderate", "Moderate Issues"),
    ("minor", "Minor Issues"),
)


def coerce_deep_review_issue(issue: DeepReviewIssue | dict[str, Any]) -> DeepReviewIssue:
    """Convert an issue payload into the canonical DeepReviewIssue dataclass."""
    if isinstance(issue, DeepReviewIssue):
        return issue

    payload = {key: issue[key] for key in DEEP_REVIEW_ISSUE_KEYS if key in issue}
    payload["related_sections"] = [
        section for section in payload.get("related_sections", []) if section
    ]
    return DeepReviewIssue(**payload)


def normalize_deep_review_issue_dict(issue: DeepReviewIssue | dict[str, Any]) -> dict[str, Any]:
    """Convert an issue payload into the canonical persisted dict schema."""
    return coerce_deep_review_issue(issue).to_dict()


def _score_label(score: float) -> str:
    """Map numeric score to NeurIPS-style label."""
    for threshold, label in SCORE_LABELS:
        if score >= threshold:
            return label
    return "Strong Reject"


def calculate_scores(issues: list[AuditIssue]) -> dict[str, float]:
    """
    Calculate per-dimension scores based on issues found.

    Returns:
        Dict with keys: "quality", "clarity", "significance", "originality", "overall".
    """
    dimension_issues: dict[str, list[AuditIssue]] = {
        "quality": [],
        "clarity": [],
        "significance": [],
        "originality": [],
    }

    # Map issues to dimensions
    for issue in issues:
        module_key = issue.module.lower()
        dimensions = DIMENSION_MAP.get(module_key, ["clarity"])
        for dim in dimensions:
            if dim in dimension_issues:
                dimension_issues[dim].append(issue)

    # Calculate per-dimension scores
    scores: dict[str, float] = {}
    for dim, dim_issues in dimension_issues.items():
        score = 6.0
        for issue in dim_issues:
            deduction = SEVERITY_DEDUCTIONS.get(issue.severity, 0.25)
            score -= deduction
        scores[dim] = max(1.0, score)

    # Weighted average
    overall = sum(scores[dim] * weight for dim, weight in DIMENSION_WEIGHTS.items())
    scores["overall"] = round(overall, 2)

    return scores


def _count_issues(issues: list[AuditIssue]) -> str:
    """Count issues by severity: C/M/m format."""
    c = sum(1 for i in issues if i.severity == "Critical")
    m = sum(1 for i in issues if i.severity == "Major")
    n = sum(1 for i in issues if i.severity == "Minor")
    return f"{c}/{m}/{n}"


def _count_deep_review_issues(issues: list[DeepReviewIssue]) -> dict[str, int]:
    """Count deep-review issues by severity."""
    return {
        "major": sum(1 for i in issues if i.severity == "major"),
        "moderate": sum(1 for i in issues if i.severity == "moderate"),
        "minor": sum(1 for i in issues if i.severity == "minor"),
    }


def _default_revision_roadmap(issues: list[DeepReviewIssue]) -> list[dict]:
    """Build a minimal roadmap from issue severities when none is provided."""
    return [
        {
            "priority": DEEP_REVIEW_PRIORITY_LABELS.get(issue.severity, "Priority 3"),
            "title": issue.title,
            "source": SOURCE_KIND_LABELS.get(issue.source_kind, "[LLM]"),
            "section": issue.source_section or "unknown",
        }
        for issue in issues
    ]


def render_deep_review_report(result: AuditResult) -> str:
    """Render a deep-review-first Markdown report."""
    scores = calculate_scores(result.issues)
    now = datetime.now().strftime("%Y-%m-%d %H:%M")
    issue_counts = _count_deep_review_issues(result.issue_bundle)
    recommendation = _score_label(scores["overall"])
    roadmap = result.revision_roadmap or _default_revision_roadmap(result.issue_bundle)

    lines = [
        "# Deep Review Report",
        "",
        f"**Paper**: `{result.file_path}` | **Language**: {result.language.upper()} | **Mode**: {result.mode}",
        f"**Generated**: {now}" + (f" | **Venue**: {result.venue}" if result.venue else ""),
    ]
    if result.mode_alias_used:
        lines.append(
            f"**Compatibility Note**: legacy mode alias `{result.mode_alias_used}` mapped to `{result.mode}`."
        )
    if result.artifact_dir:
        lines.append(f"**Artifacts**: `{result.artifact_dir}`")
    lines.extend(["", "## Overall Assessment", ""])

    if result.overall_assessment:
        lines.append(result.overall_assessment)
    else:
        lines.append(
            "Deep review completed. Inspect the structured issue list below for the highest-impact "
            "claim, methodology, and consistency risks before revising."
        )
    lines.extend(
        [
            "",
            f"- **Major**: {issue_counts['major']}",
            f"- **Moderate**: {issue_counts['moderate']}",
            f"- **Minor**: {issue_counts['minor']}",
            "",
        ]
    )

    committee_blocks: list[str] = []
    if result.artifact_dir:
        committee_dir = Path(result.artifact_dir) / "committee"
        if committee_dir.exists():
            ordered = [
                ("editor.md", "### Editor (Desk Reject Screen)"),
                ("theory.md", "### Reviewer 1 (Theory Contribution)"),
                ("literature.md", "### Reviewer 3 (Literature Dialogue)"),
                ("methodology.md", "### Reviewer 2 (Methodology & Transparency)"),
                ("logic.md", "### Reviewer 4 (Logic Chain)"),
                ("consensus.md", "### Committee Consensus"),
            ]
            for filename, heading in ordered:
                path = committee_dir / filename
                if not path.exists():
                    continue
                text = path.read_text(encoding="utf-8").strip()
                if not text:
                    continue
                committee_blocks.extend([heading, "", text, ""])

    if committee_blocks:
        lines.extend(["## Academic Pre-Review Committee", ""])
        lines.extend(committee_blocks)

    if result.summary:
        lines.extend(["## Paper Summary", "", result.summary, ""])

    if result.issue_bundle:
        issues = sorted(
            result.issue_bundle,
            key=lambda i: (
                DEEP_REVIEW_SEVERITY_ORDER.get(i.severity, 99),
                i.source_section or "",
                i.title.lower(),
            ),
        )
        for severity, title in DEEP_REVIEW_SECTIONS:
            bucket = [issue for issue in issues if issue.severity == severity]
            if not bucket:
                continue
            lines.extend([f"## {title}", ""])
            for idx, issue in enumerate(bucket, 1):
                related = ", ".join(issue.related_sections) if issue.related_sections else "—"
                source_label = SOURCE_KIND_LABELS.get(issue.source_kind, "[LLM]")
                lines.append(f"### {severity[:1].upper()}{idx}: {issue.title}")
                lines.append(f"- **Type**: {issue.comment_type}")
                lines.append(f"- **Source**: {source_label} via `{issue.review_lane or 'review'}`")
                lines.append(f"- **Confidence**: {issue.confidence}")
                lines.append(f"- **Section**: {issue.source_section or 'unknown'}")
                lines.append(f"- **Related Sections**: {related}")
                if issue.root_cause_key:
                    lines.append(f"- **Root Cause Key**: `{issue.root_cause_key}`")
                if issue.quote_verified is not None:
                    lines.append(f"- **Quote Verified**: {'yes' if issue.quote_verified else 'no'}")
                lines.append(f"- **Quote**: `{issue.quote}`")
                lines.append(f"- **Explanation**: {issue.explanation}")
                lines.append("")

    if result.issues:
        lines.extend(["## Phase 0 Automated Findings", ""])
        modules: dict[str, list[AuditIssue]] = {}
        for issue in result.issues:
            modules.setdefault(issue.module, []).append(issue)

        for module_name in sorted(modules.keys()):
            lines.extend([f"### [Script] {module_name}", ""])
            lines.extend(["| Line | Severity | Issue |", "|------|----------|-------|"])
            for issue in modules[module_name]:
                loc = str(issue.line) if issue.line else "---"
                lines.append(f"| {loc} | {issue.severity} | {issue.message} |")
            lines.append("")

    lines.extend(
        [
            "## Score Summary",
            "",
            f"- **Quality**: {scores['quality']:.1f}/6.0",
            f"- **Clarity**: {scores['clarity']:.1f}/6.0",
            f"- **Significance**: {scores['significance']:.1f}/6.0",
            f"- **Originality**: {scores['originality']:.1f}/6.0",
            f"- **Overall**: {scores['overall']:.1f}/6.0 ({recommendation})",
            "",
        ]
    )

    if roadmap:
        lines.extend(["## Revision Roadmap", ""])
        for priority in ("Priority 1", "Priority 2", "Priority 3"):
            items = [item for item in roadmap if item.get("priority") == priority]
            if not items:
                continue
            lines.extend([f"### {priority}", ""])
            for item in items:
                source = item.get("source", "[LLM]")
                section = item.get("section", "unknown")
                title = item.get("title", "Untitled issue")
                lines.append(f"- [ ] {title} ({source}; {section})")
            lines.append("")

    return "\n".join(lines)


def render_polish_precheck_report(result: AuditResult, precheck: dict) -> str:
    """Render precheck summary shown before Critic agent is spawned."""
    lines = [
        "# Polish Precheck Report",
        "",
        f"**File**: `{result.file_path}` | **Language**: {result.language.upper()} "
        f"| **Style**: {precheck.get('style', 'A')}",
    ]
    if precheck.get("journal"):
        lines[-1] += f" | **Journal**: {precheck['journal']}"
    lines += [""]

    # Section map table
    lines += [
        "## Detected Sections",
        "",
        "| Section | Lines | Words |",
        "|---------|-------|-------|",
    ]
    for sec, meta in precheck.get("sections", {}).items():
        lines.append(f"| {sec} | {meta['start']}-{meta['end']} | {meta['word_count']} |")
    lines.append("")

    # Blockers
    blockers = precheck.get("blockers", [])
    if blockers:
        lines += ["## Blockers (must fix before polish)", ""]
        for b in blockers:
            loc = f"(Line {b['line']}) " if b.get("line") else ""
            lines.append(f"- **[{b['module']}]** {loc}{b['message']}")
        lines += ["", "Resolve these Critical issues and re-run before proceeding."]
    else:
        lines += ["## Status: Ready for Critic Phase", ""]

    n_logic = len(precheck.get("precheck_issues", []))
    n_expr = len(precheck.get("expression_issues", []))
    lines.append(f"**Pre-check findings**: {n_logic} logic, {n_expr} expression issues")
    if precheck.get("non_imrad"):
        lines += ["", "> **Note**: Non-standard section structure detected."]
    return "\n".join(lines)


# --- Report Renderers ---


def render_self_check_report(result: AuditResult) -> str:
    """Render a quick-audit-style Markdown report."""
    scores = calculate_scores(result.issues)
    now = datetime.now().strftime("%Y-%m-%d %H:%M")
    blockers = [issue for issue in result.issues if issue.severity == "Critical"]
    quality_improvements = [issue for issue in result.issues if issue.severity != "Critical"]

    lines = [
        "# Paper Audit Report",
        "",
        f"**File**: `{result.file_path}` | **Language**: {result.language.upper()} | **Mode**: {result.mode}",
        f"**Generated**: {now}" + (f" | **Venue**: {result.venue}" if result.venue else ""),
        "",
    ]

    # Executive Summary
    total = len(result.issues)
    critical = sum(1 for i in result.issues if i.severity == "Critical")
    label = _score_label(scores["overall"])
    lines.extend(
        [
            "## Executive Summary",
            "",
            f"Found **{total} issues** ({critical} critical). "
            f"Overall score: **{scores['overall']:.1f}/6.0** ({label}).",
            "",
        ]
    )

    # Submission blockers first.
    lines.extend(["## Submission Blockers", ""])
    if blockers:
        for issue in blockers:
            loc = f"(Line {issue.line}) " if issue.line else ""
            lines.append(
                f"- [Script] **[{issue.module}]** {loc}"
                f"[Severity: {issue.severity}] [Priority: {issue.priority}]: "
                f"{issue.message}"
            )
            if issue.original:
                lines.append(f"  - Original: `{issue.original}`")
            if issue.revised:
                lines.append(f"  - Revised: `{issue.revised}`")
            if issue.rationale:
                lines.append(f"  - Rationale: {issue.rationale}")
    else:
        lines.append("- No submission blockers detected.")
    lines.append("")

    # High-signal quality improvements next.
    lines.extend(["## Quality Improvements", ""])
    if quality_improvements:
        for severity, heading in [
            ("Major", "### High-Signal Quality Issues"),
            ("Minor", "### Additional Quality Improvements"),
        ]:
            sev_issues = [issue for issue in quality_improvements if issue.severity == severity]
            if not sev_issues:
                continue
            lines.extend([heading, ""])
            for issue in sev_issues:
                loc = f"(Line {issue.line}) " if issue.line else ""
                lines.append(
                    f"- [Script] **[{issue.module}]** {loc}"
                    f"[Severity: {issue.severity}] [Priority: {issue.priority}]: "
                    f"{issue.message}"
                )
                if issue.original:
                    lines.append(f"  - Original: `{issue.original}`")
                if issue.revised:
                    lines.append(f"  - Revised: `{issue.revised}`")
                if issue.rationale:
                    lines.append(f"  - Rationale: {issue.rationale}")
            lines.append("")
    else:
        lines.append("- No quality improvements identified.")
        lines.append("")

    # Checklist
    if result.checklist:
        lines.extend(["## Pre-Submission Checklist", ""])
        for item in result.checklist:
            mark = "x" if item.passed else " "
            lines.append(f"- [{mark}] {item.description}")
            if not item.passed and item.details:
                lines.append(f"  - {item.details}")
        lines.append("")

    # Scores Table
    dim_issues_map: dict[str, list[AuditIssue]] = {
        "quality": [],
        "clarity": [],
        "significance": [],
        "originality": [],
    }
    for issue in result.issues:
        for dim in DIMENSION_MAP.get(issue.module.lower(), ["clarity"]):
            if dim in dim_issues_map:
                dim_issues_map[dim].append(issue)

    lines.extend(
        [
            "## Scores",
            "",
            "| Dimension | Score | Issues (C/M/m) | Key Finding |",
            "|-----------|-------|-----------------|-------------|",
        ]
    )
    for dim in ["quality", "clarity", "significance", "originality"]:
        dim_issues = dim_issues_map[dim]
        key_finding = dim_issues[0].message[:50] + "..." if dim_issues else "No issues"
        lines.append(
            f"| {dim.capitalize()} | {scores[dim]:.1f} | "
            f"{_count_issues(dim_issues)} | {key_finding} |"
        )
    lines.append(
        f"| **Overall** | **{scores['overall']:.1f}** | "
        f"{_count_issues(result.issues)} | **{label}** |"
    )
    lines.append("")

    return "\n".join(lines)


def render_review_report(result: AuditResult) -> str:
    """Render a peer-review simulation Markdown report."""
    if result.issue_bundle or result.mode == "deep-review":
        return render_deep_review_report(result)

    scores = calculate_scores(result.issues)
    now = datetime.now().strftime("%Y-%m-%d %H:%M")
    label = _score_label(scores["overall"])

    lines = [
        "# Peer Review Report",
        "",
        f"**Paper**: `{result.file_path}` | **Language**: {result.language.upper()}",
        f"**Generated**: {now}"
        + (f" | **Venue**: {result.venue}" if result.venue else "")
        + " | **Review Round**: 1",
        "",
    ]

    # Summary
    if result.summary:
        lines.extend(["## Paper Summary", "", result.summary, ""])

    # Strengths (structured: S1, S2, ...)
    if result.strengths:
        lines.extend(["## Strengths", ""])
        for idx, s in enumerate(result.strengths, 1):
            if isinstance(s, dict):
                lines.append(f"### S{idx}: {s.get('title', 'Strength')}")
                lines.append(s.get("description", ""))
            else:
                lines.append(f"### S{idx}: {s}")
            lines.append("")

    # Weaknesses (structured: Problem + Why + Suggestion + Severity)
    if result.weaknesses:
        lines.extend(["## Weaknesses", ""])
        for idx, w in enumerate(result.weaknesses, 1):
            if isinstance(w, dict):
                lines.append(f"### W{idx}: {w.get('title', 'Weakness')}")
                lines.append(f"- **Problem**: {w.get('problem', w.get('title', ''))}")
                lines.append(f"- **Why it matters**: {w.get('why', 'Impacts paper quality')}")
                lines.append(f"- **Suggestion**: {w.get('suggestion', 'See detailed issues')}")
                lines.append(f"- **Severity**: {w.get('severity', 'Major')}")
            else:
                lines.append(f"### W{idx}: {w}")
            lines.append("")

    # Questions
    if result.questions:
        lines.extend(["## Questions for Authors", ""])
        for idx, q in enumerate(result.questions, 1):
            lines.append(f"{idx}. {q}")
        lines.append("")

    # Detailed Automated Findings (grouped by module)
    if result.issues:
        lines.extend(["## Detailed Automated Findings", ""])
        # Group by module
        modules: dict[str, list[AuditIssue]] = {}
        for issue in result.issues:
            modules.setdefault(issue.module, []).append(issue)

        for module_name in sorted(modules.keys()):
            module_issues = sorted(
                modules[module_name],
                key=lambda i: (
                    ("Critical", "Major", "Minor").index(i.severity)
                    if i.severity in ("Critical", "Major", "Minor")
                    else 3
                ),
            )
            lines.extend(
                [
                    f"### {module_name}",
                    "",
                    "| Line | Severity | Issue |",
                    "|------|----------|-------|",
                ]
            )
            for issue in module_issues:
                loc = str(issue.line) if issue.line else "---"
                lines.append(f"| {loc} | {issue.severity} | {issue.message} |")
            lines.append("")

    # Score & Recommendation
    lines.extend(
        [
            "## Overall Assessment",
            "",
            "| Dimension | Score | Label |",
            "|-----------|-------|-------|",
        ]
    )
    for dim in ["quality", "clarity", "significance", "originality"]:
        dim_label = _score_label(scores[dim])
        lines.append(f"| {dim.capitalize()} | {scores[dim]:.1f}/6.0 | {dim_label} |")
    lines.extend(
        [
            f"| **Overall** | **{scores['overall']:.1f}/6.0** | **{label}** |",
            "",
            f"**Recommendation**: {label}",
            "",
        ]
    )

    # Revision Roadmap
    critical = [i for i in result.issues if i.severity == "Critical"]
    major = [i for i in result.issues if i.severity == "Major"]
    minor = [i for i in result.issues if i.severity == "Minor"]

    if critical or major or minor:
        lines.extend(["## Revision Roadmap", ""])

        if critical:
            lines.extend(["### Priority 1 --- Must Address (Blocking)", ""])
            for idx, issue in enumerate(critical, 1):
                loc = f" (Line {issue.line})" if issue.line else ""
                lines.append(f"- [ ] R{idx}: [{issue.module}]{loc} {issue.message}")
            lines.append("")

        if major:
            lines.extend(["### Priority 2 --- Strongly Recommended", ""])
            for idx, issue in enumerate(major, 1):
                loc = f" (Line {issue.line})" if issue.line else ""
                lines.append(f"- [ ] S{idx}: [{issue.module}]{loc} {issue.message}")
            lines.append("")

        if minor:
            lines.extend(["### Priority 3 --- Optional Improvements", ""])
            for issue in minor:
                loc = f" (Line {issue.line})" if issue.line else ""
                lines.append(f"- [ ] [{issue.module}]{loc} {issue.message}")
            lines.append("")

    return "\n".join(lines)


def render_gate_report(result: AuditResult) -> str:
    """Render a quality gate pass/fail Markdown report."""
    now = datetime.now().strftime("%Y-%m-%d %H:%M")

    blocking = [i for i in result.issues if i.severity == "Critical"]
    passed = len(blocking) == 0 and all(item.passed for item in result.checklist)
    verdict = "PASS" if passed else "FAIL"

    lines = [
        "# Quality Gate Report",
        "",
        f"**File**: `{result.file_path}` | **Language**: {result.language.upper()}",
        f"**Generated**: {now}",
        "",
        f"## Verdict: {verdict}",
        "",
    ]

    # Blocking Issues
    if blocking:
        lines.extend(["## Blocking Issues (must fix)", ""])
        for issue in blocking:
            loc = f"(Line {issue.line}) " if issue.line else ""
            lines.append(f"- [BLOCKING] **[{issue.module}]** {loc}{issue.message}")
        lines.append("")

    # Checklist
    if result.checklist:
        lines.extend(["## Checklist", ""])
        for item in result.checklist:
            status = "[PASS]" if item.passed else "[FAIL]"
            lines.append(f"- {status} {item.description}")
            if not item.passed and item.details:
                lines.append(f"  - {item.details}")
        lines.append("")

    # Non-blocking issues (informational)
    non_blocking = [i for i in result.issues if i.severity != "Critical"]
    if non_blocking:
        lines.extend(["## Advisory Recommendations (non-blocking)", ""])
        lines.append("These are advisory recommendations, not submission blockers.")
        lines.append("")
        for issue in non_blocking:
            loc = f"(Line {issue.line}) " if issue.line else ""
            lines.append(f"- [INFO] **[{issue.module}]** {loc}{issue.message}")
        lines.append("")

    return "\n".join(lines)


def render_json_report(result: AuditResult) -> str:
    """
    Export audit result as structured JSON for CI/CD integration.

    Args:
        result: Complete audit result.

    Returns:
        Formatted JSON string with file metadata, scores, verdict, issues, and checklist.
    """
    import json

    scores = calculate_scores(result.issues)
    data = {
        "file": result.file_path,
        "language": result.language,
        "mode": result.mode,
        "mode_alias_used": result.mode_alias_used,
        "venue": result.venue,
        "generated_at": datetime.now().isoformat(),
        "scores": {k: round(v, 2) for k, v in scores.items()},
        "verdict": _score_label(scores["overall"]),
        "issues": [
            {
                "module": i.module,
                "line": i.line,
                "severity": i.severity,
                "priority": i.priority,
                "message": i.message,
                "original": i.original,
                "revised": i.revised,
            }
            for i in result.issues
        ],
        "checklist": [
            {
                "description": c.description,
                "passed": c.passed,
                "details": c.details,
            }
            for c in result.checklist
        ],
    }
    if result.issue_bundle:
        data["issue_bundle"] = [
            normalize_deep_review_issue_dict(issue) for issue in result.issue_bundle
        ]
        data["overall_assessment"] = result.overall_assessment
        data["paper_summary"] = result.summary
        data["revision_roadmap"] = result.revision_roadmap or _default_revision_roadmap(
            result.issue_bundle
        )
        data["section_index"] = result.section_index
        data["artifact_dir"] = result.artifact_dir
    return json.dumps(data, indent=2, ensure_ascii=False)


def render_reaudit_report(result: AuditResult) -> str:
    """Render a re-audit comparison report.

    Shows which prior issues were addressed, partially addressed,
    still present, and which new issues appeared.
    """
    lines: list[str] = []
    data = result.reaudit_data or {}
    summary = data.get("summary", {})
    classifications = data.get("classifications", [])
    new_issues = data.get("new_issues", [])

    lines.append("# Re-Audit Report")
    lines.append("")
    lines.append(
        f"**File**: `{result.file_path}` | **Language**: {result.language} | **Mode**: re-audit"
    )
    if result.venue:
        lines.append(f"**Venue**: {result.venue}")
    lines.append(f"**Previous Report**: `{data.get('previous_report', 'N/A')}`")
    lines.append(f"**Generated**: {datetime.now().strftime('%Y-%m-%dT%H:%M:%S')}")
    lines.append("")

    # Summary
    lines.append("---")
    lines.append("")
    lines.append("## Revision Summary")
    lines.append("")
    total_prior = data.get("prior_issue_count", 0)
    fixed = summary.get("fully_addressed", 0)
    partial = summary.get("partially_addressed", 0)
    remaining = summary.get("not_addressed", 0)
    new_count = summary.get("new", 0)
    lines.append("| Metric | Count |")
    lines.append("|--------|-------|")
    lines.append(f"| Prior issues | {total_prior} |")
    lines.append(f"| Fully addressed | {fixed} |")
    lines.append(f"| Partially addressed | {partial} |")
    lines.append(f"| Not addressed | {remaining} |")
    lines.append(f"| New issues | {new_count} |")
    lines.append("")

    # Progress indicator
    if total_prior > 0:
        pct = round((fixed / total_prior) * 100)
        lines.append(f"**Resolution rate**: {pct}% ({fixed}/{total_prior} fully resolved)")
    lines.append("")

    # Prior issue verification
    if classifications:
        lines.append("---")
        lines.append("")
        lines.append("## Prior Issue Verification")
        lines.append("")
        lines.append(
            "| # | root_cause_key | Module | Prior Severity | Status | Current | Message |"
        )
        lines.append("|---|----------------|--------|---------------|--------|---------|---------|")
        for idx, c in enumerate(classifications, 1):
            cur_sev = c.get("current_severity") or "\u2014"
            root_cause = c.get("root_cause_key") or "root cause unavailable"
            msg = c["prior_message"]
            if len(msg) > 80:
                msg = msg[:77] + "..."
            lines.append(
                f"| {idx} | {root_cause} | {c['prior_module']} | {c['prior_severity']} "
                f"| {c['status']} | {cur_sev} | {msg} |"
            )
        lines.append("")

    # New issues
    if new_issues:
        lines.append("---")
        lines.append("")
        lines.append("## New Issues (not in previous report)")
        lines.append("")
        lines.append("| # | Module | Line | Severity | Issue |")
        lines.append("|---|--------|------|----------|-------|")
        for idx, ni in enumerate(new_issues, 1):
            loc = str(ni.get("line")) if ni.get("line") else "\u2014"
            lines.append(f"| {idx} | {ni['module']} | {loc} | {ni['severity']} | {ni['message']} |")
        lines.append("")

    # Current scores
    scores = calculate_scores(result.issues)
    overall = scores.get("overall", 6.0)
    lines.append("---")
    lines.append("")
    lines.append("## Current Scores")
    lines.append("")
    lines.append("| Dimension | Score |")
    lines.append("|-----------|-------|")
    for dim in ("quality", "clarity", "significance", "originality"):
        lines.append(f"| {dim.title()} | {scores.get(dim, 6.0):.1f} / 6.0 |")
    lines.append(f"| **Overall** | **{overall:.2f} / 6.0** |")
    lines.append("")

    # Recommendation
    lines.append("---")
    lines.append("")
    if remaining == 0 and new_count == 0:
        lines.append("*All prior issues resolved and no new issues found. Ready for next step.*")
    elif remaining == 0:
        lines.append(
            f"*All prior issues resolved, but {new_count} new issue(s) detected. "
            f"Review new issues before proceeding.*"
        )
    else:
        lines.append(
            f"*{remaining} prior issue(s) still unresolved. Continue revision and re-run audit.*"
        )
    lines.append("")

    return "\n".join(lines)


def render_report(result: AuditResult) -> str:
    """
    Render the appropriate report based on audit mode.

    Args:
        result: Complete audit result.

    Returns:
        Formatted Markdown report string.
    """
    if result.mode == "deep-review":
        report = render_deep_review_report(result)
    elif result.mode == "review":
        report = render_review_report(result)
    elif result.mode == "quick-audit":
        report = render_self_check_report(result)
    elif result.mode == "gate":
        report = render_gate_report(result)
    elif result.mode == "re-audit":
        report = render_reaudit_report(result)
    elif result.mode == "polish":
        # For polish mode, render_self_check_report shows precheck issues
        report = render_self_check_report(result)
    else:
        report = render_self_check_report(result)

    # Append ScholarEval report if available
    if result.scholar_eval_result is not None:
        try:
            from scholar_eval import render_scholar_eval_report

            report += "\n\n" + render_scholar_eval_report(result.scholar_eval_result)
        except Exception:
            pass

    # Append literature comparison section if available
    if result.literature_context is not None:
        try:
            from literature_compare import render_comparison_report

            if hasattr(result.literature_context, "comparison_result"):
                report += "\n\n" + render_comparison_report(
                    result.literature_context.comparison_result
                )
            elif hasattr(result.literature_context, "filtered_results"):
                from literature_search import render_literature_summary

                report += "\n\n" + render_literature_summary(result.literature_context)
        except Exception:
            pass

    return report

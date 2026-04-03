"""
Paper Audit Orchestrator.
Main entry point for running paper audits across LaTeX, Typst, and PDF formats.
Supports quick-audit, deep-review, gate, polish, and re-audit workflows.
"""

import argparse
import contextlib
import json
import re
import subprocess
import sys
from concurrent.futures import ThreadPoolExecutor, as_completed
from pathlib import Path

from detect_language import detect_language
from parsers import get_parser
from prepare_review_workspace import prepare_workspace
from report_generator import (
    AuditIssue,
    AuditResult,
    ChecklistItem,
    coerce_deep_review_issue,
    normalize_deep_review_issue_dict,
    render_deep_review_report,
    render_json_report,
    render_report,
)
from verify_quotes import verify_quotes

# --- Mode Configuration ---

MODE_CHECKS: dict[str, list[str]] = {
    "quick-audit": [
        "format",
        "grammar",
        "logic",
        "experiment",
        "sentences",
        "deai",
        "citations",
        "bib",
        "figures",
        "pseudocode",
        "references",
        "visual",
    ],
    "deep-review": [
        "format",
        "grammar",
        "logic",
        "experiment",
        "sentences",
        "deai",
        "citations",
        "bib",
        "figures",
        "pseudocode",
        "references",
        "visual",
    ],
    # Legacy aliases kept for one compatibility cycle.
    "self-check": [
        "format",
        "grammar",
        "logic",
        "experiment",
        "sentences",
        "deai",
        "citations",
        "bib",
        "figures",
        "pseudocode",
        "references",
        "visual",
    ],
    "review": [
        "format",
        "grammar",
        "logic",
        "experiment",
        "sentences",
        "deai",
        "citations",
        "bib",
        "figures",
        "pseudocode",
        "references",
        "visual",
    ],
    "gate": [
        "format",
        "bib",
        "figures",
        "pseudocode",
        "references",
        "visual",
        "checklist",
    ],
    "polish": ["logic", "sentences"],  # Fast rule-based only; agents handle the rest
    "re-audit": [  # Same checks as quick-audit for fresh comparison
        "format",
        "grammar",
        "logic",
        "experiment",
        "sentences",
        "deai",
        "citations",
        "bib",
        "figures",
        "pseudocode",
        "references",
        "visual",
    ],
}

MODE_ALIASES: dict[str, str] = {
    "self-check": "quick-audit",
    "review": "deep-review",
}

# Additional checks for Chinese documents
ZH_EXTRA_CHECKS: list[str] = ["consistency", "gbt7714"]

# --- Venue Configuration ---

VENUE_CONFIG: dict[str, dict] = {
    "neurips": {
        "page_limit": 9,
        "required_sections": ["broader_impact"],
        "checklist_section": "NeurIPS",
        "blind_review": True,
        "extra_checks": [
            (
                "Paper checklist appendix present",
                r"\\section\*?\{.*(?:Checklist|Paper\s+Checklist)",
            ),
            ("Broader impact statement present", r"(?:broader\s+impact|societal\s+impact)"),
            ("Reproducibility statement present", r"(?:reproducibility|reproduce)"),
        ],
    },
    "iclr": {
        "page_limit": 10,
        "checklist_section": "ICLR",
        "blind_review": True,
        "extra_checks": [
            ("Reproducibility statement present", r"(?:reproducibility|reproduce)"),
            (
                "Code availability URL present",
                r"(?:github\.com|code\s+available|code\s+repository)",
            ),
        ],
    },
    "icml": {
        "page_limit": 8,
        "required_sections": ["impact_statement"],
        "checklist_section": "ICML",
        "blind_review": True,
        "extra_checks": [
            ("Impact statement present", r"(?:impact\s+statement|societal\s+impact)"),
        ],
    },
    "ieee": {
        "abstract_max_words": 250,
        "keywords_range": (3, 5),
        "checklist_section": "IEEE",
        "blind_review": False,
        "extra_checks": [
            ("Keywords section present", r"(?:\\begin\{IEEEkeywords\}|\\keywords|[Kk]eywords)"),
        ],
    },
    "acm": {
        "required_sections": ["ccs_concepts"],
        "checklist_section": "ACM",
        "blind_review": False,
        "extra_checks": [
            ("CCS concepts present", r"(?:\\ccsdesc|CCS\s+[Cc]oncepts|\\begin\{CCSXML\})"),
            ("Rights management present", r"(?:\\copyrightyear|\\acmDOI|\\setcopyright)"),
        ],
    },
    "thesis-zh": {
        "checklist_section": "Chinese Thesis",
        "blind_review": False,
        "extra_checks": [
            ("Bilingual abstract present", r"(?:\\begin\{abstract\}|摘\s*要)"),
            ("Declaration of originality present", r"(?:原创性|独创性|声明)"),
            ("Acknowledgments present", r"(?:致\s*谢|acknowledgment)"),
        ],
    },
}

# --- Skill Root Resolution ---

SKILLS_ROOT = Path(__file__).resolve().parent.parent.parent
SCRIPTS_AUDIT = Path(__file__).resolve().parent  # paper-audit's own scripts
SCRIPTS_EN = SKILLS_ROOT / "latex-paper-en" / "scripts"
SCRIPTS_ZH = SKILLS_ROOT / "latex-thesis-zh" / "scripts"
SCRIPTS_TYPST = SKILLS_ROOT / "typst-paper" / "scripts"


def _resolve_script(check_name: str, lang: str, fmt: str) -> Path | None:
    """Resolve the script path for a given check, language, and format."""
    script_map: dict[str, str] = {
        "format": "check_format.py",
        "grammar": "analyze_grammar.py",
        "logic": "analyze_logic.py",
        "experiment": "analyze_experiment.py",
        "sentences": "analyze_sentences.py",
        "deai": "deai_check.py",
        "citations": "check_citations.py",
        "bib": "verify_bib.py",
        "figures": "check_figures.py",
        "pseudocode": "check_pseudocode.py",
        "consistency": "check_consistency.py",
        "references": "check_references.py",
        "visual": "visual_check.py",
    }

    script_name = script_map.get(check_name)
    if not script_name:
        return None

    # visual check lives only in paper-audit's own scripts directory
    if check_name == "visual":
        path = SCRIPTS_AUDIT / script_name
        return path if path.exists() else None

    # citations check lives only in paper-audit's own scripts directory
    if check_name == "citations":
        path = SCRIPTS_AUDIT / script_name
        return path if path.exists() else None

    # references: paper-audit has its own router version; fall through to others
    if check_name == "references":
        # Prefer paper-audit's router version first
        path = SCRIPTS_AUDIT / script_name
        if path.exists():
            return path

    # Choose script directory based on format and language
    if fmt == ".typ":
        candidates = [SCRIPTS_TYPST]
    elif lang == "zh":
        candidates = [SCRIPTS_ZH, SCRIPTS_EN]
    else:
        candidates = [SCRIPTS_EN]

    for scripts_dir in candidates:
        path = scripts_dir / script_name
        if path.exists():
            return path

    return None


def normalize_mode(mode: str) -> tuple[str, str | None]:
    """Return canonical mode and the legacy alias used, if any."""
    canonical = MODE_ALIASES.get(mode, mode)
    alias_used = mode if canonical != mode else None
    return canonical, alias_used


def _run_check_script(
    script_path: Path, file_path: str, extra_args: list[str] | None = None
) -> tuple[int, str, str]:
    """Run a check script as subprocess and capture output."""
    cmd = [sys.executable, str(script_path), file_path]
    if extra_args:
        cmd.extend(extra_args)

    try:
        result = subprocess.run(
            cmd,
            capture_output=True,
            text=True,
            timeout=120,
            cwd=str(script_path.parent),
        )
        return result.returncode, result.stdout, result.stderr
    except subprocess.TimeoutExpired:
        return -1, "", "Script timed out after 120 seconds"
    except Exception as e:
        return -1, "", str(e)


def _parse_script_output(module_name: str, stdout: str) -> list[AuditIssue]:
    """
    Parse script output into AuditIssue objects.
    Tries to detect structured output (Severity/Priority format),
    falls back to treating each non-empty line as a Minor issue.
    """
    issues = []
    if not stdout.strip():
        return issues

    # Pattern for structured output: [Severity: X] [Priority: Y]
    structured_pattern = re.compile(
        r"\[Severity:\s*(Critical|Major|Minor)\]\s*\[Priority:\s*(P[012])\]"
    )
    line_pattern = re.compile(r"\(Line\s+(\d+)\)")

    for line in stdout.strip().split("\n"):
        line = line.strip()
        if not line or line.startswith("#"):
            continue

        severity = "Minor"
        priority = "P2"
        line_num = None

        # Try structured format
        sev_match = structured_pattern.search(line)
        if sev_match:
            severity = sev_match.group(1)
            priority = sev_match.group(2)

        line_match = line_pattern.search(line)
        if line_match:
            line_num = int(line_match.group(1))

        # Clean message
        msg = line
        msg = structured_pattern.sub("", msg)
        msg = line_pattern.sub("", msg)
        msg = re.sub(r"^%\s*", "", msg)  # LaTeX comment prefix
        msg = re.sub(r"^//\s*", "", msg)  # Typst comment prefix
        msg = re.sub(r"^>\s*", "", msg)  # Markdown quote prefix
        msg = re.sub(r"^\[?\w+\]?\s*", "", msg, count=1)  # Module tag
        msg = msg.strip(" :-")

        if msg:
            issues.append(
                AuditIssue(
                    module=module_name.upper(),
                    line=line_num,
                    severity=severity,
                    priority=priority,
                    message=msg,
                )
            )

    return issues


def _lane_from_section(section_key: str) -> str:
    """Map workspace section keys to default section-review lane names."""
    if section_key in {"introduction", "related_work", "background"}:
        return "section_intro_related"
    if section_key in {"method", "methods", "approach", "model"}:
        return "section_methods"
    if section_key in {"experiment", "experiments", "results", "evaluation"}:
        return "section_results"
    if section_key in {"discussion", "conclusion", "limitations"}:
        return "section_discussion_conclusion"
    if section_key == "appendix":
        return "section_appendix"
    return "section_intro_related"


def _section_lane_rules(section_key: str, normalized_text: str, claim_map: dict) -> list[dict]:
    """Return declarative fallback rule matches for a single section."""
    section_claims = claim_map.get("section_claims", {}).get(section_key, [])
    return [
        {
            "enabled": section_key in {"abstract", "introduction", "discussion", "conclusion"}
            and bool(section_claims)
            and any(
                keyword in section_claims[0].lower()
                for keyword in ("state-of-the-art", "significant", "best", "novel")
            ),
            "title": "Headline claim needs tighter evidence calibration",
            "quote": section_claims[0] if section_claims else "",
            "explanation": (
                "This sentence makes a strong paper-level claim. Verify that the results and "
                "discussion sections explicitly delimit where the evidence holds and where it does not."
            ),
            "comment_type": "claim_accuracy",
            "severity": "moderate",
            "review_lane": "claims_vs_evidence",
            "related_sections": [section_key, "results"],
        },
        {
            "enabled": section_key in {"method", "methods", "approach", "model"}
            and ("assume" in normalized_text or "we define" in normalized_text),
            "title": "Method assumptions should be justified explicitly",
            "quote": "",
            "explanation": (
                "The methods section introduces assumptions/definitions. The deep review should verify "
                "whether downstream experiments and appendix material justify those choices clearly."
            ),
            "comment_type": "methodology",
            "severity": "moderate",
            "review_lane": _lane_from_section(section_key),
            "related_sections": None,
        },
        {
            "enabled": section_key in {"experiment", "experiments", "results", "evaluation"}
            and any(
                token in normalized_text
                for token in ("improve", "outperform", "%", "accuracy", "f1", "bleu")
            ),
            "title": "Result claims should identify comparison scope and uncertainty",
            "quote": "",
            "explanation": (
                "The results section reports comparative performance. Confirm whether the paper states the "
                "evaluation scope, variance, and fairness conditions tightly enough for a reviewer."
            ),
            "comment_type": "methodology",
            "severity": "moderate",
            "review_lane": "evaluation_fairness_and_reproducibility",
            "related_sections": [section_key, "methods"],
        },
        {
            "enabled": section_key == "appendix",
            "title": "Appendix evidence should reconcile with main-text claims",
            "quote": "",
            "explanation": (
                "Appendix material exists. Check that it supports the main-text metrics, notation, and claims "
                "without introducing contradictions."
            ),
            "comment_type": "claim_accuracy",
            "severity": "minor",
            "review_lane": "notation_and_numeric_consistency",
            "related_sections": [section_key, "results"],
        },
    ]


def _make_fallback_issue(
    *,
    title: str,
    quote: str,
    explanation: str,
    comment_type: str,
    severity: str,
    source_section: str,
    review_lane: str,
    source_kind: str = "llm",
    confidence: str = "medium",
    related_sections: list[str] | None = None,
    gate_blocker: bool = False,
) -> dict:
    """Build a lane-compatible fallback issue payload."""
    return {
        "title": title,
        "quote": quote.strip(),
        "explanation": explanation.strip(),
        "comment_type": comment_type,
        "severity": severity,
        "confidence": confidence,
        "source_kind": source_kind,
        "source_section": source_section,
        "related_sections": related_sections or ([source_section] if source_section else []),
        "review_lane": review_lane,
        "gate_blocker": gate_blocker,
    }


def _normalize_inline_text(text: str) -> str:
    """Collapse internal whitespace for deterministic heuristics."""
    return re.sub(r"\s+", " ", text).strip()


def _summarize_section_text(section_text: str, *, max_len: int = 280) -> str:
    """Return a compact normalized summary string for reports and heuristics."""
    summary = _normalize_inline_text(section_text)
    if len(summary) <= max_len:
        return summary
    return summary[: max_len - 3].rstrip() + "..."


def _fallback_section_lane_issues(
    section_key: str, section_text: str, claim_map: dict
) -> list[dict]:
    """Generate deterministic fallback findings for a workspace section."""
    normalized = _normalize_inline_text(section_text)
    if not normalized:
        return []

    issues: list[dict] = []
    for rule in _section_lane_rules(section_key, normalized.lower(), claim_map):
        if not rule["enabled"]:
            continue
        issues.append(
            _make_fallback_issue(
                title=rule["title"],
                quote=rule["quote"] or _summarize_section_text(section_text),
                explanation=rule["explanation"],
                comment_type=rule["comment_type"],
                severity=rule["severity"],
                source_section=section_key,
                review_lane=rule["review_lane"],
                related_sections=rule["related_sections"],
            )
        )

    return issues


def _fallback_cross_cutting_issues(claim_map: dict, section_texts: dict[str, str]) -> list[dict]:
    """Generate deterministic cross-cutting findings when no reviewer agents are available."""
    issues: list[dict] = []
    headline_claims = claim_map.get("headline_claims", [])
    closure_targets = claim_map.get("closure_targets", [])

    if headline_claims:
        issues.append(
            _make_fallback_issue(
                title="Abstract and conclusion claims need explicit evidence traceability",
                quote=headline_claims[0],
                explanation=(
                    "At least one headline claim was detected. Deep review should check whether experiments and "
                    "conclusion language trace back to the same bounded evidence base."
                ),
                comment_type="claim_accuracy",
                severity="major",
                source_section="abstract",
                review_lane="claims_vs_evidence",
                related_sections=["abstract", "results", "conclusion"],
            )
        )

    numeric_sections = [
        key for key, text in section_texts.items() if re.search(r"\b\d+(?:\.\d+)?\b", text)
    ]
    if len(numeric_sections) >= 2:
        issues.append(
            _make_fallback_issue(
                title="Cross-section numeric consistency should be reconciled",
                quote=_summarize_section_text(section_texts[numeric_sections[0]]),
                explanation=(
                    "Multiple sections contain numeric claims. Confirm that the same quantities reconcile across "
                    "main text, tables, and appendix material."
                ),
                comment_type="presentation",
                severity="moderate",
                source_section=numeric_sections[0],
                review_lane="notation_and_numeric_consistency",
                related_sections=numeric_sections[:3],
            )
        )

    if closure_targets:
        issues.append(
            _make_fallback_issue(
                title="Conclusion should close the loop on the paper's strongest claims",
                quote=closure_targets[0],
                explanation=(
                    "A closure claim appears in the discussion/conclusion. Verify that it matches the limitations, "
                    "experimental scope, and prior-art positioning established earlier in the paper."
                ),
                comment_type="missing_information",
                severity="minor",
                source_section="conclusion",
                review_lane="self_standard_consistency",
                related_sections=["conclusion", "introduction", "results"],
            )
        )

    if any(
        "baseline" in text.lower() or "compare" in text.lower() for text in section_texts.values()
    ):
        issues.append(
            _make_fallback_issue(
                title="Comparison protocol should make fairness assumptions explicit",
                quote=_summarize_section_text(" ".join(section_texts.values())),
                explanation=(
                    "Comparative evaluation language was detected. Deep review should verify that baseline tuning, "
                    "data splits, and reporting conventions are described symmetrically."
                ),
                comment_type="methodology",
                severity="moderate",
                source_section="results" if "results" in section_texts else "experiment",
                review_lane="evaluation_fairness_and_reproducibility",
                related_sections=[
                    key for key in ("methods", "results", "appendix") if key in section_texts
                ],
            )
        )

    return issues


def _write_lane_outputs(review_dir: Path, section_index: list[dict], claim_map: dict) -> list[dict]:
    """Create fallback lane outputs inside comments/ and return all raw issues."""
    sections_dir = review_dir / "sections"
    comments_dir = review_dir / "comments"
    comments_dir.mkdir(parents=True, exist_ok=True)

    section_texts: dict[str, str] = {}
    raw_issues: list[dict] = []

    for section in section_index:
        section_key = section.get("section_key", "")
        file_name = section.get("file_name")
        if not section_key or not file_name:
            continue
        section_path = sections_dir / file_name
        if not section_path.exists():
            continue
        section_text = section_path.read_text(encoding="utf-8")
        section_texts[section_key] = section_text
        lane_name = _lane_from_section(section_key)
        lane_issues = _fallback_section_lane_issues(section_key, section_text, claim_map)
        if lane_issues:
            _write_lane_file(comments_dir, lane_name, lane_issues)
            raw_issues.extend(lane_issues)

    cross_cutting = _fallback_cross_cutting_issues(claim_map, section_texts)
    lane_buckets: dict[str, list[dict]] = {}
    for issue in cross_cutting:
        lane_buckets.setdefault(issue["review_lane"], []).append(issue)
        raw_issues.append(issue)

    for lane_name, lane_issues in lane_buckets.items():
        _write_lane_file(comments_dir, lane_name, lane_issues)

    if not raw_issues:
        placeholder = [
            _make_fallback_issue(
                title="Deep review requires manual reviewer judgment",
                quote="",
                explanation=(
                    "The deterministic fallback could not derive lane findings from the extracted text. "
                    "A human or agent reviewer should inspect the prepared workspace directly."
                ),
                comment_type="missing_information",
                severity="minor",
                source_section="unknown",
                review_lane="self_standard_consistency",
            )
        ]
        _write_lane_file(comments_dir, "self_standard_consistency", placeholder)
        raw_issues.extend(placeholder)

    return raw_issues


def _write_lane_file(comments_dir: Path, lane_name: str, lane_issues: list[dict]) -> None:
    """Write one lane JSON file in the workspace comments directory."""
    (comments_dir / f"{lane_name}.json").write_text(
        json.dumps(lane_issues, indent=2, ensure_ascii=False),
        encoding="utf-8",
    )


def _build_overall_assessment(issues: list[dict]) -> str:
    """Create a short calibrated overall assessment from consolidated issues."""
    if not issues:
        return (
            "The deep review did not surface actionable issues. Confirm manually that the prepared "
            "workspace reflects the full paper before submission."
        )

    major = [issue for issue in issues if issue.get("severity") == "major"]
    moderate = [issue for issue in issues if issue.get("severity") == "moderate"]
    top_titles = [issue.get("title", "issue") for issue in (major[:2] + moderate[:1])][:3]
    severity_summary = (
        f"{len(major)} major, {len(moderate)} moderate, "
        f"{sum(1 for issue in issues if issue.get('severity') == 'minor')} minor"
    )
    if top_titles:
        concerns = "; ".join(top_titles)
        return (
            f"Deep review found {severity_summary} issues. "
            f"The highest-priority concerns are: {concerns}."
        )
    return (
        f"Deep review found {severity_summary} issues that should be addressed before submission."
    )


def _build_revision_roadmap(issues: list[dict]) -> list[dict]:
    """Derive a priority-sorted roadmap from consolidated issue bundle items."""
    priority_map = {"major": "Priority 1", "moderate": "Priority 2", "minor": "Priority 3"}
    roadmap: list[dict] = []
    for issue in issues:
        roadmap.append(
            {
                "priority": priority_map.get(issue.get("severity", "minor"), "Priority 3"),
                "title": issue.get("title", "Untitled issue"),
                "source": "[Script]" if issue.get("source_kind") == "script" else "[LLM]",
                "section": issue.get("source_section") or "unknown",
            }
        )
    return roadmap


def _write_revision_roadmap(review_dir: Path, roadmap: list[dict]) -> None:
    """Persist the revision roadmap in Markdown form for workspace consumers."""
    lines = ["# Revision Roadmap", ""]
    for priority in ("Priority 1", "Priority 2", "Priority 3"):
        items = [item for item in roadmap if item.get("priority") == priority]
        if not items:
            continue
        lines.extend([f"## {priority}", ""])
        for item in items:
            lines.append(
                f"- [ ] {item.get('title', 'Untitled issue')} ({item.get('source', '[LLM]')}; {item.get('section', 'unknown')})"
            )
        lines.append("")
    (review_dir / "revision_roadmap.md").write_text("\n".join(lines), encoding="utf-8")


def _extract_editor_verdict_from_markdown(editor_md: str) -> str | None:
    """Parse an editor verdict from committee/editor.md content."""
    match = re.search(r"^\s*Verdict\s*:\s*(.+?)\s*$", editor_md, flags=re.IGNORECASE | re.MULTILINE)
    if not match:
        return None
    verdict = match.group(1).strip()
    if not verdict:
        return None
    return verdict


def _infer_editor_verdict(
    phase0_result: AuditResult,
    issues: list[dict],
) -> str:
    """Infer an editor verdict when no explicit committee editor note exists."""
    has_critical = any(issue.severity == "Critical" for issue in phase0_result.issues)
    major_count = sum(1 for issue in issues if issue.get("severity") == "major")
    if has_critical:
        return "Desk Reject"
    if major_count >= 3:
        return "Conditional Pass"
    return "Pass to Review"


def _compute_committee_score(
    issues: list[dict],
    editor_verdict: str | None,
) -> float:
    """Compute committee score and enforce desk-reject cap."""
    major_count = sum(1 for issue in issues if issue.get("severity") == "major")
    moderate_count = sum(1 for issue in issues if issue.get("severity") == "moderate")
    minor_count = sum(1 for issue in issues if issue.get("severity") == "minor")
    score = 9.0 - (1.5 * major_count) - (0.7 * moderate_count) - (0.2 * minor_count)
    score = max(1.0, score)
    if editor_verdict and "desk reject" in editor_verdict.lower():
        score = min(score, 4.0)
    return round(score, 1)


def _write_committee_consensus(
    review_dir: Path,
    phase0_result: AuditResult,
    issues: list[dict],
) -> None:
    """Write committee/consensus.md with enforced score policy."""
    committee_dir = review_dir / "committee"
    committee_dir.mkdir(parents=True, exist_ok=True)

    editor_path = committee_dir / "editor.md"
    editor_verdict = None
    if editor_path.exists():
        editor_verdict = _extract_editor_verdict_from_markdown(
            editor_path.read_text(encoding="utf-8")
        )
    if editor_verdict is None:
        editor_verdict = _infer_editor_verdict(phase0_result, issues)

    score = _compute_committee_score(issues, editor_verdict)
    major_count = sum(1 for issue in issues if issue.get("severity") == "major")
    moderate_count = sum(1 for issue in issues if issue.get("severity") == "moderate")
    minor_count = sum(1 for issue in issues if issue.get("severity") == "minor")

    top_issues = [
        issue.get("title", "Untitled issue")
        for issue in sorted(
            issues,
            key=lambda item: (
                {"major": 0, "moderate": 1, "minor": 2}.get(item.get("severity", "minor"), 3),
                item.get("source_section", ""),
            ),
        )[:3]
    ]

    lines = [
        "## Committee Consensus",
        "",
        f"Overall Score: {score}/10",
        f"Editor Verdict: {editor_verdict}",
        "",
        "### Score Formula",
        "- base 9.0",
        f"- minus 1.5 * major ({major_count})",
        f"- minus 0.7 * moderate ({moderate_count})",
        f"- minus 0.2 * minor ({minor_count})",
        "- floor 1.0",
        "- desk reject cap 4.0",
        "",
        "### Top 3 Issues To Fix First",
    ]
    if top_issues:
        for idx, title in enumerate(top_issues, start=1):
            lines.append(f"{idx}. {title}")
    else:
        lines.append("1. No actionable issues detected.")

    (committee_dir / "consensus.md").write_text("\n".join(lines) + "\n", encoding="utf-8")


def run_deep_review(
    file_path: str,
    pdf_mode: str = "basic",
    venue: str = "",
    lang: str | None = None,
    online: bool = False,
    email: str = "",
    scholar_eval: bool = False,
    literature_search: bool = False,
    tavily_key: str = "",
    s2_key: str = "",
    regression: bool = False,
) -> AuditResult:
    """Run the end-to-end deep-review workflow with deterministic fallback lanes."""
    review_dir = prepare_workspace(file_path)
    metadata = json.loads((review_dir / "metadata.json").read_text(encoding="utf-8"))
    section_index = json.loads((review_dir / "section_index.json").read_text(encoding="utf-8"))
    claim_map = json.loads((review_dir / "claim_map.json").read_text(encoding="utf-8"))

    phase0_result = run_audit(
        file_path=file_path,
        mode="quick-audit",
        pdf_mode=pdf_mode,
        venue=venue,
        lang=lang,
        online=online,
        email=email,
        scholar_eval=scholar_eval,
        literature_search=literature_search,
        tavily_key=tavily_key,
        s2_key=s2_key,
        regression=regression,
    )
    (review_dir / "phase0_context.md").write_text(
        export_phase0_context(phase0_result),
        encoding="utf-8",
    )

    _write_lane_outputs(review_dir, section_index, claim_map)

    from consolidate_review_findings import consolidate_findings, load_comment_files

    findings = [
        normalize_deep_review_issue_dict(issue)
        for issue in load_comment_files(review_dir / "comments")
    ]
    consolidated = consolidate_findings(findings)
    verified = [
        normalize_deep_review_issue_dict(issue)
        for issue in verify_quotes(
            (review_dir / "full_text.md").read_text(encoding="utf-8"), consolidated
        )
    ]

    (review_dir / "all_comments.json").write_text(
        json.dumps(findings, indent=2, ensure_ascii=False),
        encoding="utf-8",
    )
    (review_dir / "final_issues.json").write_text(
        json.dumps(verified, indent=2, ensure_ascii=False),
        encoding="utf-8",
    )

    overall_assessment = _build_overall_assessment(verified)
    (review_dir / "overall_assessment.txt").write_text(overall_assessment + "\n", encoding="utf-8")
    revision_roadmap = _build_revision_roadmap(verified)
    _write_revision_roadmap(review_dir, revision_roadmap)
    _write_committee_consensus(review_dir, phase0_result, verified)

    issue_bundle = [coerce_deep_review_issue(issue) for issue in verified]
    result = AuditResult(
        file_path=str(Path(file_path).resolve()),
        language=lang or metadata.get("language", "en"),
        mode="deep-review",
        venue=venue,
        issues=phase0_result.issues,
        issue_bundle=issue_bundle,
        checklist=phase0_result.checklist,
        summary=(review_dir / "paper_summary.md").read_text(encoding="utf-8"),
        overall_assessment=overall_assessment,
        revision_roadmap=revision_roadmap,
        section_index=section_index,
        artifact_dir=str(review_dir),
        scholar_eval_result=phase0_result.scholar_eval_result,
        literature_context=phase0_result.literature_context,
    )
    (review_dir / "review_report.md").write_text(
        render_deep_review_report(result),
        encoding="utf-8",
    )
    return result


def _run_checklist(
    content: str,
    file_path: str,
    lang: str,  # noqa: ARG001
    venue: str = "",
) -> list[ChecklistItem]:
    """Run pre-submission checklist checks (universal + venue-specific)."""
    items = []

    # Check: no TODO/FIXME/XXX
    todo_lines = [
        i + 1
        for i, line in enumerate(content.split("\n"))
        if re.search(r"\b(TODO|FIXME|XXX)\b", line)
    ]
    items.append(
        ChecklistItem(
            "No placeholder text (TODO, FIXME, XXX)",
            len(todo_lines) == 0,
            f"Found on lines: {todo_lines[:5]}" if todo_lines else "",
        )
    )

    # Check: all figures referenced (LaTeX/Typst)
    ext = Path(file_path).suffix.lower()
    if ext == ".tex":
        fig_labels = set(re.findall(r"\\label\{(fig:[^}]+)\}", content))
        fig_refs = set(re.findall(r"\\ref\{(fig:[^}]+)\}", content))
        unreferenced = fig_labels - fig_refs
        items.append(
            ChecklistItem(
                "All figures referenced in text",
                len(unreferenced) == 0,
                f"Unreferenced: {unreferenced}" if unreferenced else "",
            )
        )

    # Check: all tables referenced (LaTeX)
    if ext == ".tex":
        tab_labels = set(re.findall(r"\\label\{(tab:[^}]+)\}", content))
        tab_refs = set(re.findall(r"\\ref\{(tab:[^}]+)\}", content))
        unref_tabs = tab_labels - tab_refs
        items.append(
            ChecklistItem(
                "All tables referenced in text",
                len(unref_tabs) == 0,
                f"Unreferenced: {unref_tabs}" if unref_tabs else "",
            )
        )

    # Check: anonymous submission (no author names in common patterns)
    anon_patterns = [
        r"\\author\{[^}]*[A-Z][a-z]+",  # LaTeX \author with name
        r"#set document\(author:",  # Typst author
    ]
    has_author = any(re.search(p, content) for p in anon_patterns)
    items.append(
        ChecklistItem(
            "Anonymous submission (blind review check)",
            not has_author,
            "Author information detected — verify if blind review required" if has_author else "",
        )
    )

    # Check: consistent notation (basic — check for mixed $ and \( \))
    if ext == ".tex":
        inline_dollar = len(re.findall(r"(?<!\$)\$(?!\$)", content))
        inline_paren = len(re.findall(r"\\\(", content))
        mixed = inline_dollar > 0 and inline_paren > 0
        items.append(
            ChecklistItem(
                "Consistent math notation",
                not mixed,
                f"Mixed styles: ${inline_dollar}x $...$ and {inline_paren}x \\(...\\)"
                if mixed
                else "",
            )
        )

    # Check: acronyms defined on first use (basic heuristic)
    acronyms = set(re.findall(r"\b([A-Z]{2,6})\b", content))
    undefined = []
    for acr in acronyms:
        # Check if defined as (ACRONYM) or {ACRONYM}
        if not re.search(rf"\({acr}\)|\{{{acr}\}}", content) and acr not in {
            "PDF",
            "URL",
            "API",
            "GPU",
            "CPU",
            "RAM",
            "RGB",
            "CNN",
            "RNN",
            "GAN",
            "NLP",
            "LLM",
            "MLP",
            "LSTM",
            "IEEE",
            "ACM",
            "AAAI",
            "ICLR",
            "ICML",
            "SOTA",
            "BERT",
            "GPT",
            "TODO",
            "FIXME",
            "XXX",
            "YAML",
            "JSON",
            "HTML",
            "HTTP",
            "SQL",
        }:
            undefined.append(acr)
    items.append(
        ChecklistItem(
            "Acronyms defined on first use",
            len(undefined) <= 3,  # Allow some tolerance
            f"Potentially undefined: {undefined[:5]}" if undefined else "",
        )
    )

    def _collect_ieee_pseudocode_items() -> list[ChecklistItem]:
        ext = Path(file_path).suffix.lower()
        if ext not in {".tex", ".typ"}:
            return []

        def _fallback_items() -> list[ChecklistItem]:
            if ext == ".tex":
                float_fail = bool(re.search(r"\\begin\{algorithm\*?\}", content))
                figure_match = re.search(
                    r"\\begin\{figure\*?\}[\s\S]*?\\begin\{algorithmic\}[\s\S]*?\\end\{figure\*?\}",
                    content,
                )
                caption_label_fail = False
                reference_fail = False
                caption_details = ""
                reference_details = ""
                if figure_match:
                    figure_text = figure_match.group(0)
                    caption_label_fail = not (
                        re.search(r"\\caption(?:\[[^\]]*\])?\{", figure_text)
                        and re.search(r"\\label\{([^}]+)\}", figure_text)
                    )
                    if caption_label_fail:
                        caption_details = (
                            "Fallback IEEE pseudocode check found a figure-wrapped algorithmic block "
                            "without both caption and label"
                        )
                    label_match = re.search(r"\\label\{([^}]+)\}", figure_text)
                    if label_match:
                        label_name = label_match.group(1).strip()
                        begin_idx = content.find(figure_text)
                        first_ref = re.search(
                            rf"\\(?:ref|autoref|cref|Cref|pageref)\{{{re.escape(label_name)}\}}",
                            content,
                        )
                        if first_ref is None or first_ref.start() > begin_idx:
                            reference_fail = True
                            reference_details = (
                                "Fallback IEEE pseudocode check did not find a text reference before "
                                "the pseudocode figure"
                            )
                return [
                    ChecklistItem(
                        "[IEEE] No floating pseudocode environment used",
                        not float_fail,
                        "Fallback IEEE pseudocode check found a floating algorithm environment"
                        if float_fail
                        else "",
                    ),
                    ChecklistItem(
                        "[IEEE] Pseudocode blocks have caption and label",
                        not caption_label_fail,
                        caption_details,
                    ),
                    ChecklistItem(
                        "[IEEE] Pseudocode blocks are referenced before appearing",
                        not reference_fail,
                        reference_details,
                    ),
                ]

            wrapper_fail = "lovelace" in content and not (
                "#figure(" in content or "algorithm-figure(" in content
            )
            caption_label_fail = "algorithm-figure(" in content and "caption:" not in content
            return [
                ChecklistItem(
                    "[IEEE] No floating pseudocode environment used",
                    not wrapper_fail,
                    "Fallback IEEE pseudocode check found a lovelace block without a figure wrapper"
                    if wrapper_fail
                    else "",
                ),
                ChecklistItem(
                    "[IEEE] Pseudocode blocks have caption and label",
                    not caption_label_fail,
                    "Fallback IEEE pseudocode check found algorithm-figure without caption"
                    if caption_label_fail
                    else "",
                ),
                ChecklistItem(
                    "[IEEE] Pseudocode blocks are referenced before appearing",
                    True,
                    "",
                ),
            ]

        if ext == ".tex":
            has_pseudocode = any(
                marker in content
                for marker in (
                    r"\begin{algorithm}",
                    r"\begin{algorithmic}",
                    "algorithm2e",
                    "algorithmicx",
                    "algpseudocodex",
                )
            )
        else:
            has_pseudocode = any(
                marker in content
                for marker in ("algorithm-figure", "@preview/algorithmic", "lovelace")
            )

        if not has_pseudocode:
            return _fallback_items()

        if not Path(file_path).exists():
            return _fallback_items()

        script = _resolve_script("pseudocode", "zh" if lang == "zh" else "en", ext)
        if script is None:
            return [
                ChecklistItem(
                    "[IEEE] Pseudocode audit script available",
                    False,
                    "Pseudocode checker script not found",
                )
            ]

        returncode, stdout, _ = _run_check_script(script, file_path, ["--venue", "ieee", "--json"])
        if returncode == -1:
            return _fallback_items()

        try:
            payload = json.loads(stdout or "[]")
        except json.JSONDecodeError:
            return _fallback_items()

        def _messages_for(patterns: tuple[str, ...]) -> list[str]:
            messages: list[str] = []
            for issue in payload:
                message = issue.get("message", "")
                if any(pattern in message for pattern in patterns):
                    messages.append(message)
            return messages

        wrapper_messages = _messages_for(
            ("floating algorithm environments", "not wrapped in a figure-like container")
        )
        caption_label_messages = _messages_for(("missing a caption", "missing a label"))
        reference_messages = _messages_for(
            ("never referenced", "first reference", "referenced before")
        )

        return [
            ChecklistItem(
                "[IEEE] No floating pseudocode environment used",
                not wrapper_messages,
                "; ".join(wrapper_messages[:2]) if wrapper_messages else "",
            ),
            ChecklistItem(
                "[IEEE] Pseudocode blocks have caption and label",
                not caption_label_messages,
                "; ".join(caption_label_messages[:2]) if caption_label_messages else "",
            ),
            ChecklistItem(
                "[IEEE] Pseudocode blocks are referenced before appearing",
                not reference_messages,
                "; ".join(reference_messages[:2]) if reference_messages else "",
            ),
        ]

    # --- Venue-Specific Checks ---
    venue_key = venue.lower().strip()
    if venue_key and venue_key in VENUE_CONFIG:
        config = VENUE_CONFIG[venue_key]

        # Page limit check (heuristic: count \newpage or page-break markers)
        page_limit = config.get("page_limit")
        if page_limit:
            # Rough page estimate: ~300 words per page for LaTeX
            word_count = len(content.split())
            est_pages = max(1, word_count // 300)
            over_limit = est_pages > page_limit
            items.append(
                ChecklistItem(
                    f"Page limit ({page_limit} pages for {venue_key.upper()})",
                    not over_limit,
                    f"Estimated ~{est_pages} pages (limit: {page_limit})"
                    if over_limit
                    else f"Estimated ~{est_pages} pages",
                )
            )

        # Abstract word count (IEEE: max 250)
        abstract_max = config.get("abstract_max_words")
        if abstract_max:
            abs_match = re.search(r"\\begin\{abstract\}(.*?)\\end\{abstract\}", content, re.DOTALL)
            if abs_match:
                abs_words = len(abs_match.group(1).split())
                items.append(
                    ChecklistItem(
                        f"Abstract word limit ({abstract_max} words for {venue_key.upper()})",
                        abs_words <= abstract_max,
                        f"Abstract has {abs_words} words (limit: {abstract_max})"
                        if abs_words > abstract_max
                        else f"Abstract has {abs_words} words",
                    )
                )

        # Keywords count range (IEEE: 3-5)
        keywords_range = config.get("keywords_range")
        if keywords_range:
            kw_match = re.search(
                r"\\begin\{IEEEkeywords\}(.*?)\\end\{IEEEkeywords\}", content, re.DOTALL
            )
            if not kw_match:
                kw_match = re.search(r"[Kk]eywords?[:\s]+(.+?)(?:\n\n|\\.)", content)
            if kw_match:
                kw_text = kw_match.group(1)
                kw_count = len([k.strip() for k in re.split(r"[,;]", kw_text) if k.strip()])
                lo, hi = keywords_range
                items.append(
                    ChecklistItem(
                        f"Keywords count ({lo}-{hi} for {venue_key.upper()})",
                        lo <= kw_count <= hi,
                        f"Found {kw_count} keywords (expected {lo}-{hi})",
                    )
                )

        # Blind review compliance
        if config.get("blind_review"):
            items.append(
                ChecklistItem(
                    f"Double-blind compliance ({venue_key.upper()})",
                    not has_author,
                    "Author information detected — must be anonymized for blind review"
                    if has_author
                    else "No author information detected",
                )
            )

        # Venue-specific content checks (regex-based)
        for check_label, pattern in config.get("extra_checks", []):
            found = bool(re.search(pattern, content, re.IGNORECASE))
            items.append(
                ChecklistItem(
                    f"[{venue_key.upper()}] {check_label}",
                    found,
                    "" if found else f"Not found — required for {venue_key.upper()} submission",
                )
            )

        if venue_key == "ieee":
            items.extend(_collect_ieee_pseudocode_items())

    return items


def _find_section_for_line(
    line_no: int | None,
    sections: dict[str, tuple[int, int]],
) -> str:
    """Map a line number to its enclosing section name."""
    if line_no is None:
        return "unknown"
    for sec_name, (start, end) in sections.items():
        if start <= line_no <= end:
            return sec_name
    return "unknown"


def _write_state_file(paper_path: Path, data: dict) -> Path:
    """Write polish precheck state JSON next to the paper file."""
    import json

    state_dir = paper_path.parent / ".polish-state"
    state_dir.mkdir(exist_ok=True)
    state_file = state_dir / "precheck.json"
    state_file.write_text(json.dumps(data, indent=2, ensure_ascii=False), encoding="utf-8")
    print(f"[polish-precheck] State written to: {state_file}")
    return state_file


def run_polish_precheck(
    file_path: str,
    style: str = "A",
    journal: str = "",
    lang: str | None = None,
    skip_logic: bool = False,
) -> AuditResult:
    """
    Fast precheck for polish mode.
    Writes .polish-state/precheck.json next to the paper file.
    Returns AuditResult for report rendering.
    """
    from datetime import datetime

    path = Path(file_path).resolve()
    fmt = path.suffix.lower()
    if fmt == ".pdf":
        raise ValueError("Polish mode requires .tex or .typ source (not PDF).")

    content = path.read_text(encoding="utf-8")
    parser = get_parser(file_path)

    if lang is None:
        clean = parser.clean_text(content)
        lang = detect_language(clean)

    print(f"[polish-precheck] {path.name} | lang={lang} style={style}")

    # Section map
    raw_sections = parser.split_sections(content)  # dict[str, tuple[int,int]]
    lines_list = content.split("\n")
    sections_meta: dict = {}
    for sec_name, (start, end) in raw_sections.items():
        sec_lines = lines_list[start - 1 : end]
        word_count = sum(len(parser.extract_visible_text(ln).split()) for ln in sec_lines)
        sections_meta[sec_name] = {"start": start, "end": end, "word_count": word_count}

    # Non-IMRaD detection
    imrad_core = {"abstract", "introduction", "method", "experiment", "conclusion"}
    non_imrad = len(imrad_core & set(raw_sections)) < 2

    # Rule-based logic check (per-section, skip if --skip-logic)
    precheck_issues: list[dict] = []
    if not skip_logic:
        logic_script = _resolve_script("logic", lang, fmt)
        if logic_script:
            for sec_name in raw_sections:
                rc, stdout, _ = _run_check_script(logic_script, str(path), ["--section", sec_name])
                if rc != -1 and stdout.strip():
                    for issue in _parse_script_output("logic", stdout):
                        precheck_issues.append(
                            {
                                "module": issue.module,
                                "section": sec_name,
                                "line": issue.line,
                                "severity": issue.severity,
                                "priority": issue.priority,
                                "message": issue.message,
                            }
                        )

    # Expression check (sentences)
    expression_issues: list[dict] = []
    sent_script = _resolve_script("sentences", lang, fmt)
    if sent_script:
        rc, stdout, _ = _run_check_script(
            sent_script, str(path), ["--max-words", "60", "--max-clauses", "3"]
        )
        if rc != -1 and stdout.strip():
            for issue in _parse_script_output("sentences", stdout):
                expression_issues.append(
                    {
                        "module": issue.module,
                        "section": _find_section_for_line(issue.line, raw_sections),
                        "line": issue.line,
                        "severity": issue.severity,
                        "priority": issue.priority,
                        "message": issue.message,
                        "original": issue.original,
                        "revised": issue.revised,
                    }
                )

    # Hard blockers = Critical severity
    blockers = [i for i in precheck_issues if i["severity"] == "Critical"]

    precheck_data = {
        "file_path": str(path),
        "language": lang,
        "style": style,
        "journal": journal,
        "sections": sections_meta,
        "precheck_issues": precheck_issues,
        "expression_issues": expression_issues,
        "blockers": blockers,
        "non_imrad": non_imrad,
        "skip_logic": skip_logic,
        "generated_at": datetime.now().isoformat(),
    }
    _write_state_file(path, precheck_data)

    # Return AuditResult so existing render_report() can display precheck issues
    all_issues = [
        AuditIssue(
            module=i["module"],
            line=i.get("line"),
            severity=i["severity"],
            priority=i["priority"],
            message=i["message"],
        )
        for i in precheck_issues + expression_issues
    ]
    return AuditResult(
        file_path=str(path),
        language=lang,
        mode="polish",
        venue=journal,
        issues=all_issues,
    )


def run_audit(
    file_path: str,
    mode: str = "quick-audit",
    pdf_mode: str = "basic",
    venue: str = "",
    lang: str | None = None,
    style: str = "A",
    journal: str = "",
    skip_logic: bool = False,
    online: bool = False,
    email: str = "",
    scholar_eval: bool = False,
    literature_search: bool = False,
    tavily_key: str = "",
    s2_key: str = "",
    regression: bool = False,
) -> AuditResult:
    """
    Run a complete paper audit.

    Args:
        file_path: Path to the document (.tex, .typ, or .pdf).
        mode: Audit mode — "quick-audit", "deep-review", "gate", "polish", or "re-audit".
        pdf_mode: PDF extraction mode — "basic" or "enhanced".
        venue: Target venue (e.g., "neurips", "ieee").
        lang: Force language ("en" or "zh"). Auto-detects if None.
        literature_search: Enable external literature search and comparison.
        tavily_key: API key for Tavily search (or env TAVILY_API_KEY).
        s2_key: API key for Semantic Scholar (or env S2_API_KEY).
        regression: Use regression scoring model instead of weighted average.

    Returns:
        AuditResult with all findings.
    """
    canonical_mode, alias_used = normalize_mode(mode)

    path = Path(file_path)
    if not path.exists():
        raise FileNotFoundError(f"File not found: {file_path}")

    fmt = path.suffix.lower()
    if fmt not in (".tex", ".typ", ".pdf"):
        raise ValueError(f"Unsupported format: {fmt}")

    # Polish mode: early dispatch to precheck
    if canonical_mode == "polish":
        return run_polish_precheck(
            file_path,
            style=style,
            journal=journal,
            lang=lang,
            skip_logic=skip_logic,
        )

    if canonical_mode == "deep-review":
        return run_deep_review(
            file_path=file_path,
            pdf_mode=pdf_mode,
            venue=venue,
            lang=lang,
            online=online,
            email=email,
            scholar_eval=scholar_eval,
            literature_search=literature_search,
            tavily_key=tavily_key,
            s2_key=s2_key,
            regression=regression,
        )

    # Step 1: Extract text
    parser = get_parser(file_path, pdf_mode=pdf_mode)

    if fmt == ".pdf":
        content = parser.extract_text_from_file(str(path))
    else:
        content = path.read_text(encoding="utf-8")

    # Step 2: Detect language
    if lang is None:
        clean = parser.clean_text(content) if fmt != ".pdf" else content
        lang = detect_language(clean)

    print(f"[audit] File: {path.name} | Format: {fmt} | Language: {lang} | Mode: {canonical_mode}")
    if alias_used:
        print(f"[audit] Compatibility alias detected: {alias_used} -> {canonical_mode}")

    # Step 3: Determine checks
    checks = list(MODE_CHECKS.get(canonical_mode, MODE_CHECKS["quick-audit"]))
    if lang == "zh":
        checks.extend(ZH_EXTRA_CHECKS)

    # Step 4: Build task list (filter inapplicable checks first)
    all_issues: list[AuditIssue] = []
    tasks: list[tuple[str, Path, list[str]]] = []

    for check_name in checks:
        if check_name == "checklist":
            continue  # Handled separately

        script = _resolve_script(check_name, lang, fmt)
        if script is None:
            print(f"[audit] SKIP {check_name}: script not found")
            continue

        # PDF files need special handling — some scripts expect .tex/.typ
        if fmt == ".pdf" and check_name in ("format", "figures", "references", "citations"):
            print(f"[audit] SKIP {check_name}: not applicable for PDF input")
            continue

        # Visual check only applies to PDF input
        if check_name == "visual" and fmt != ".pdf":
            continue

        extra_args: list[str] = []
        if check_name == "logic":
            extra_args = ["--cross-section"]
        if check_name == "sentences":
            extra_args = ["--max-words", "60", "--max-clauses", "3"]
        if check_name == "bib" and online:
            extra_args.append("--online")
            if email:
                extra_args.extend(["--email", email])

        tasks.append((check_name, script, extra_args))

    # Run independent checks in parallel (up to 4 workers)
    with ThreadPoolExecutor(max_workers=4) as executor:
        future_to_check = {
            executor.submit(_run_check_script, script, str(path), extra_args): check_name
            for check_name, script, extra_args in tasks
        }
        for future in as_completed(future_to_check):
            check_name = future_to_check[future]
            try:
                returncode, stdout, stderr = future.result()
            except Exception as exc:
                returncode, stdout, stderr = -1, "", str(exc)

            if returncode == -1:
                print(f"[audit] ERROR {check_name}: {stderr}")
                all_issues.append(
                    AuditIssue(
                        module=check_name.upper(),
                        line=None,
                        severity="Minor",
                        priority="P2",
                        message=f"Check script failed: {stderr[:100]}",
                    )
                )
            elif stdout.strip():
                issues = _parse_script_output(check_name, stdout)
                all_issues.extend(issues)
                print(f"[audit] {check_name}: {len(issues)} issues found")
            else:
                print(f"[audit] {check_name}: clean")

    # Step 5: Run checklist (universal + venue-specific)
    checklist = _run_checklist(content, file_path, lang, venue=venue)

    # Step 5.5: Literature search (optional)
    literature_context = None
    literature_grounding_score = None
    if literature_search and canonical_mode in ("quick-audit", "deep-review"):
        try:
            import os

            from literature_compare import compare_with_literature
            from literature_search import build_literature_context

            t_key = tavily_key or os.environ.get("TAVILY_API_KEY", "")
            s_key = s2_key or os.environ.get("S2_API_KEY", "")
            literature_context = build_literature_context(
                file_path=str(path),
                content=content,
                parser=parser,
                tavily_key=t_key,
                s2_key=s_key,
            )
            print(
                f"[audit] Literature search: {len(literature_context.filtered_results)} "
                f"relevant results found"
            )

            # Compute grounding score via comparison
            # Extract citation keys from content for comparison
            citation_keys: list[str] = []
            if fmt == ".tex":
                citation_keys = re.findall(r"\\cite\{([^}]+)\}", content)
                citation_keys = [k.strip() for keys in citation_keys for k in keys.split(",")]
            elif fmt == ".typ":
                citation_keys = re.findall(r"@([a-zA-Z][\w-]*)", content)

            comparison_result = compare_with_literature(
                paper_content=content,
                paper_citations=citation_keys,
                literature_results=literature_context.filtered_results,
            )
            literature_context.comparison_result = comparison_result
            literature_grounding_score = comparison_result.grounding_score
            print(f"[audit] Literature grounding score: {literature_grounding_score:.1f}/10")
        except ImportError as exc:
            print(f"[audit] Literature search: module not available — {exc}")
        except Exception as exc:
            print(f"[audit] Literature search: failed — {exc}")

    # Step 6: Build result
    result = AuditResult(
        file_path=str(path),
        language=lang,
        mode=canonical_mode,
        venue=venue,
        mode_alias_used=alias_used,
        issues=all_issues,
        checklist=checklist,
        literature_context=literature_context,
    )

    # Step 7: ScholarEval (optional)
    if scholar_eval and canonical_mode in ("quick-audit", "deep-review"):
        try:
            from scholar_eval import build_result as build_scholar_result
            from scholar_eval import evaluate_from_audit

            issue_dicts = [
                {"module": i.module, "severity": i.severity, "message": i.message}
                for i in all_issues
            ]
            script_scores = evaluate_from_audit(
                issue_dicts,
                literature_grounding_score=literature_grounding_score,
            )
            result.scholar_eval_result = build_scholar_result(
                script_scores,
                use_regression=regression,
            )
            print("[audit] ScholarEval: script-based scores computed")
        except Exception as exc:
            print(f"[audit] ScholarEval: failed — {exc}")

    return result


def export_phase0_context(result: AuditResult) -> str:
    """Format AuditResult as structured context string for agent consumption.

    Used by SKILL.md to pass Phase 0 automated findings to Phase 1 review agents.
    Returns a Markdown-formatted summary suitable for inclusion in agent prompts.
    """
    from datetime import datetime

    lines = [
        "# Phase 0: Automated Audit Results",
        "",
        f"**File**: `{result.file_path}` | **Language**: {result.language} | **Mode**: {result.mode}",
    ]
    if result.venue:
        lines.append(f"**Venue**: {result.venue}")
    if result.mode_alias_used:
        lines.append(f"**Legacy Alias Used**: {result.mode_alias_used}")
    lines.append(f"**Generated**: {datetime.now().isoformat()}")
    lines.append("")

    # Issue summary
    sev_counts: dict[str, int] = {}
    for issue in result.issues:
        sev_counts[issue.severity] = sev_counts.get(issue.severity, 0) + 1
    lines.append(f"## Issue Summary ({len(result.issues)} total)")
    for sev in ("Critical", "Major", "Minor"):
        if sev in sev_counts:
            lines.append(f"- {sev}: {sev_counts[sev]}")
    lines.append("")

    # Issues by module
    modules: dict[str, list[AuditIssue]] = {}
    for issue in result.issues:
        modules.setdefault(issue.module, []).append(issue)

    lines.append("## Issues by Module")
    lines.append("")
    for mod, issues in sorted(modules.items()):
        lines.append(f"### {mod}")
        lines.append("")
        lines.append("| # | Line | Severity | Priority | Issue |")
        lines.append("|---|------|----------|----------|-------|")
        for idx, issue in enumerate(issues, 1):
            loc = str(issue.line) if issue.line else "\u2014"
            lines.append(
                f"| {idx} | {loc} | {issue.severity} | {issue.priority} | {issue.message} |"
            )
        lines.append("")

    # Checklist
    if result.checklist:
        lines.append("## Pre-Submission Checklist")
        lines.append("")
        for item in result.checklist:
            check = "x" if item.passed else " "
            detail = f" \u2014 {item.details}" if item.details else ""
            lines.append(f"- [{check}] {item.description}{detail}")
        lines.append("")

    # Related Literature Summary (when literature search was performed)
    if result.literature_context is not None:
        try:
            from literature_search import render_literature_summary

            lines.append("## Related Literature Summary")
            lines.append("")
            lines.append(render_literature_summary(result.literature_context))
            lines.append("")
        except Exception:
            pass

    return "\n".join(lines)


def _parse_previous_report(report_path: str) -> list[dict]:
    """Parse a previous audit report (Markdown) to extract issues.

    Recognises table rows from both full reports and gate reports, plus
    root-cause summary bullets such as:
    - Root cause `claim-scope-mismatch`: headline claim broader than evidence.

    Returns a list of dicts with keys: module, severity, message, line, and
    optional root_cause_key / match_strategy metadata.
    """
    text = Path(report_path).read_text(encoding="utf-8")
    issues: list[dict] = []

    # Match issue table rows: | # | MODULE | line | Severity | Priority | message |
    table_row_re = re.compile(
        r"^\|\s*\d+\s*\|"  # Row number
        r"\s*([A-Z_]+)\s*\|"  # Module (uppercase)
        r"\s*([^|]*?)\s*\|"  # Line
        r"\s*(\w+)\s*\|"  # Severity
        r"\s*([^|]*?)\s*\|"  # Priority
        r"\s*([^|]*?)\s*\|",  # Message
        re.MULTILINE,
    )

    for m in table_row_re.finditer(text):
        module = m.group(1).strip()
        line_str = m.group(2).strip()
        severity = m.group(3).strip()
        message = m.group(5).strip()

        line_num = None
        if line_str and line_str not in ("\u2014", "-", ""):
            with contextlib.suppress(ValueError):
                line_num = int(line_str)

        issues.append(
            {
                "module": module,
                "severity": severity,
                "message": message,
                "line": line_num,
                "root_cause_key": "",
                "match_strategy": "legacy_table",
            }
        )

    root_cause_re = re.compile(
        r"^\s*-\s*Root cause\s+`(?P<key>[^`]+)`:\s*(?P<message>.+)$",
        re.MULTILINE,
    )
    for match in root_cause_re.finditer(text):
        issues.append(
            {
                "module": "ROOT_CAUSE",
                "severity": "Major",
                "message": match.group("message").strip(),
                "line": None,
                "root_cause_key": match.group("key").strip(),
                "match_strategy": "root_cause_summary",
            }
        )

    return issues


def _load_previous_issue_bundle(report_path: str) -> list[dict]:
    """Load structured prior issue bundles when available."""
    report = Path(report_path)
    candidates: list[Path] = []

    if report.suffix.lower() == ".json":
        candidates.append(report)
    else:
        for name in ("previous_final_issues.json", "final_issues.json"):
            candidate = report.with_name(name)
            if candidate.exists():
                candidates.append(candidate)

    issues: list[dict] = []
    for candidate in candidates:
        try:
            payload = json.loads(candidate.read_text(encoding="utf-8"))
        except (OSError, json.JSONDecodeError):
            continue
        if not isinstance(payload, list):
            continue
        for item in payload:
            if not isinstance(item, dict):
                continue
            issues.append(
                {
                    "module": str(
                        item.get("review_lane") or item.get("comment_type") or "REVIEW"
                    ).upper(),
                    "severity": str(item.get("severity", "major")).capitalize(),
                    "message": item.get("title")
                    or item.get("explanation")
                    or item.get("quote")
                    or "",
                    "line": None,
                    "title": item.get("title", ""),
                    "explanation": item.get("explanation", ""),
                    "quote": item.get("quote", ""),
                    "root_cause_key": item.get("root_cause_key", ""),
                    "match_strategy": "structured_issue",
                }
            )
    return issues


def _collect_previous_issues(report_path: str) -> list[dict]:
    """Merge structured and markdown-derived prior issue records."""
    merged: list[dict] = []
    seen: set[tuple[str, str, str]] = set()

    for issue in _load_previous_issue_bundle(report_path) + _parse_previous_report(report_path):
        key = (
            str(issue.get("root_cause_key", "")).strip(),
            str(issue.get("module", "")).strip(),
            str(issue.get("message", "")).strip(),
        )
        if key in seen:
            continue
        seen.add(key)
        merged.append(issue)

    return merged


def _fuzzy_match_score(a: str, b: str) -> float:
    """Compute fuzzy similarity between two strings (0.0 to 1.0)."""
    from difflib import SequenceMatcher

    return SequenceMatcher(None, a.lower(), b.lower()).ratio()


_SEVERITY_RANK: dict[str, int] = {"Critical": 3, "Major": 2, "Minor": 1}
_MATCH_THRESHOLD: float = 0.6
_REAUDIT_TOKEN_RE = re.compile(r"[a-z0-9]+")
_REAUDIT_STOPWORDS = {
    "the",
    "and",
    "for",
    "with",
    "that",
    "this",
    "from",
    "into",
    "over",
    "under",
    "more",
    "than",
    "across",
    "while",
    "would",
    "could",
    "should",
    "issue",
    "paper",
    "method",
    "results",
}


def _match_text_tokens(text: str) -> set[str]:
    """Extract meaningful tokens for root-cause style matching."""
    return {
        token
        for token in _REAUDIT_TOKEN_RE.findall(text.lower())
        if len(token) >= 4 and token not in _REAUDIT_STOPWORDS
    }


def _match_threshold_for_prior(prior: dict) -> float:
    strategy = prior.get("match_strategy")
    if strategy == "legacy_table":
        return _MATCH_THRESHOLD
    if strategy == "root_cause_summary":
        return 0.18
    return 0.22


def _issue_match_score(prior: dict, fresh_issue: AuditIssue) -> float:
    """Score how well a fresh issue matches a prior issue record."""
    strategy = prior.get("match_strategy")
    if strategy == "legacy_table" and prior.get("module") and fresh_issue.module != prior["module"]:
        return 0.0

    prior_text_parts = [
        str(prior.get("message", "")),
        str(prior.get("title", "")),
        str(prior.get("explanation", "")),
        str(prior.get("quote", "")),
        str(prior.get("root_cause_key", "")).replace("-", " "),
    ]
    prior_text_parts = [part for part in prior_text_parts if part]
    if not prior_text_parts:
        return 0.0

    fuzzy = max(_fuzzy_match_score(part, fresh_issue.message) for part in prior_text_parts)
    prior_tokens = _match_text_tokens(" ".join(prior_text_parts))
    fresh_tokens = _match_text_tokens(fresh_issue.message)
    overlap = len(prior_tokens & fresh_tokens)
    coverage = overlap / len(prior_tokens) if prior_tokens else 0.0
    token_score = coverage + overlap * 0.08
    module_bonus = 0.12 if prior.get("module") == fresh_issue.module else 0.0

    return max(fuzzy + module_bonus, token_score + module_bonus)


def run_reaudit(
    file_path: str,
    previous_report: str,
    pdf_mode: str = "basic",
    venue: str = "",
    lang: str | None = None,
    online: bool = False,
    email: str = "",
    scholar_eval: bool = False,
) -> AuditResult:
    """Run a re-audit comparing current state against a previous report.

    Runs a fresh quick-audit and classifies prior issues as:
    - FULLY_ADDRESSED: No matching issue found in fresh audit
    - PARTIALLY_ADDRESSED: Similar issue exists but with lower severity
    - NOT_ADDRESSED: Same or worse issue still present
    Also identifies NEW issues not in the previous report.

    Args:
        file_path: Path to the document.
        previous_report: Path to the previous audit report (Markdown).
        Other args: same as run_audit.

    Returns:
        AuditResult with reaudit_data populated.
    """
    if not Path(previous_report).exists():
        raise FileNotFoundError(f"Previous report not found: {previous_report}")

    # Step 1: Run fresh audit (using quick-audit checks)
    fresh = run_audit(
        file_path=file_path,
        mode="quick-audit",
        pdf_mode=pdf_mode,
        venue=venue,
        lang=lang,
        online=online,
        email=email,
        scholar_eval=scholar_eval,
    )

    # Step 2: Parse previous report and any structured issue bundle alongside it.
    prior_issues = _collect_previous_issues(previous_report)
    print(f"[re-audit] Previous report: {len(prior_issues)} issues parsed")

    # Step 3: Match and classify each prior issue
    matched_fresh_indices: set[int] = set()
    classifications: list[dict] = []

    for prior in prior_issues:
        best_score = 0.0
        best_idx = -1

        for idx, fresh_issue in enumerate(fresh.issues):
            if idx in matched_fresh_indices:
                continue
            score = _issue_match_score(prior, fresh_issue)
            if score > best_score:
                best_score = score
                best_idx = idx

        if best_score >= _match_threshold_for_prior(prior) and best_idx >= 0:
            matched_fresh_indices.add(best_idx)
            matched = fresh.issues[best_idx]
            prior_rank = _SEVERITY_RANK.get(prior["severity"], 1)
            fresh_rank = _SEVERITY_RANK.get(matched.severity, 1)

            status = "PARTIALLY_ADDRESSED" if fresh_rank < prior_rank else "NOT_ADDRESSED"

            classifications.append(
                {
                    "prior_module": prior["module"],
                    "prior_severity": prior["severity"],
                    "prior_message": prior["message"],
                    "status": status,
                    "current_severity": matched.severity,
                    "current_message": matched.message,
                    "root_cause_key": prior.get("root_cause_key", ""),
                    "match_score": round(best_score, 2),
                }
            )
        else:
            classifications.append(
                {
                    "prior_module": prior["module"],
                    "prior_severity": prior["severity"],
                    "prior_message": prior["message"],
                    "status": "FULLY_ADDRESSED",
                    "current_severity": None,
                    "current_message": None,
                    "root_cause_key": prior.get("root_cause_key", ""),
                    "match_score": round(best_score, 2),
                }
            )

    # Step 4: Identify NEW issues (unmatched in fresh audit)
    new_issues = [
        fresh.issues[i] for i in range(len(fresh.issues)) if i not in matched_fresh_indices
    ]

    # Build result
    fresh.mode = "re-audit"
    fresh.reaudit_data = {
        "previous_report": previous_report,
        "prior_issue_count": len(prior_issues),
        "classifications": classifications,
        "new_issues": [
            {"module": i.module, "severity": i.severity, "message": i.message, "line": i.line}
            for i in new_issues
        ],
        "summary": {
            "fully_addressed": sum(1 for c in classifications if c["status"] == "FULLY_ADDRESSED"),
            "partially_addressed": sum(
                1 for c in classifications if c["status"] == "PARTIALLY_ADDRESSED"
            ),
            "not_addressed": sum(1 for c in classifications if c["status"] == "NOT_ADDRESSED"),
            "new": len(new_issues),
        },
    }

    summary = fresh.reaudit_data["summary"]
    print(
        f"[re-audit] Results: {summary['fully_addressed']} fixed, "
        f"{summary['partially_addressed']} partial, "
        f"{summary['not_addressed']} remaining, "
        f"{summary['new']} new"
    )

    return fresh


def main() -> int:
    """CLI entry point."""
    parser = argparse.ArgumentParser(
        description="Paper Audit Tool — audit academic papers across formats and languages.",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  python audit.py paper.tex                          # Quick audit (default)
  python audit.py paper.typ --mode deep-review       # Deep reviewer-style audit
  python audit.py paper.pdf --mode gate --pdf-mode enhanced  # Quality gate with enhanced PDF
  python audit.py paper.tex --venue neurips --lang en        # NeurIPS quick audit
  python audit.py paper.tex --mode re-audit --previous-report report_v1.md  # Re-audit
        """,
    )

    parser.add_argument("file", help="Path to the document (.tex, .typ, or .pdf)")
    parser.add_argument(
        "--mode",
        choices=[
            "quick-audit",
            "deep-review",
            "gate",
            "polish",
            "re-audit",
            "self-check",
            "review",
        ],
        default="quick-audit",
        help="Audit mode (default: quick-audit; self-check/review kept as compatibility aliases)",
    )
    parser.add_argument(
        "--pdf-mode",
        choices=["basic", "enhanced"],
        default="basic",
        help="PDF extraction mode (default: basic)",
    )
    parser.add_argument(
        "--venue",
        default="",
        help="Target venue (e.g., neurips, ieee, acm)",
    )
    parser.add_argument(
        "--lang",
        choices=["en", "zh"],
        default=None,
        help="Force language (auto-detects if not specified)",
    )
    parser.add_argument(
        "--style",
        choices=["A", "B", "C"],
        default="A",
        help="Polish style: A=plain precise, B=narrative, C=formal academic",
    )
    parser.add_argument(
        "--journal",
        default="",
        help="Target journal/venue for polish mode",
    )
    parser.add_argument(
        "--skip-logic",
        action="store_true",
        help="Skip logic checking in polish mode (expression only)",
    )
    parser.add_argument(
        "--online",
        action="store_true",
        help="Enable online bibliography verification via CrossRef/Semantic Scholar",
    )
    parser.add_argument(
        "--email",
        default="",
        help="Email for CrossRef polite pool (faster rate limits)",
    )
    parser.add_argument(
        "--scholar-eval",
        action="store_true",
        help="Enable ScholarEval 8-dimension assessment",
    )
    parser.add_argument(
        "--literature-search",
        action="store_true",
        help="Enable external literature search and comparison (Tavily + Semantic Scholar + arXiv)",
    )
    parser.add_argument(
        "--tavily-key",
        default="",
        help="API key for Tavily search (or set TAVILY_API_KEY env var)",
    )
    parser.add_argument(
        "--s2-key",
        default="",
        help="API key for Semantic Scholar (or set S2_API_KEY env var)",
    )
    parser.add_argument(
        "--regression",
        action="store_true",
        help="Use regression scoring model instead of weighted average for ScholarEval",
    )
    parser.add_argument(
        "--previous-report",
        default=None,
        help="Path to previous audit report (required for re-audit mode)",
    )
    parser.add_argument(
        "--output",
        "-o",
        default=None,
        help="Output file path (default: stdout)",
    )
    parser.add_argument(
        "--format",
        choices=["md", "json"],
        default="md",
        help="Output format: 'md' for Markdown (default) or 'json' for CI/CD integration",
    )

    args = parser.parse_args()

    # Validate re-audit requires --previous-report
    if args.mode == "re-audit" and not args.previous_report:
        parser.error("--previous-report is required for re-audit mode")

    try:
        if args.mode == "re-audit":
            result = run_reaudit(
                file_path=args.file,
                previous_report=args.previous_report,
                pdf_mode=args.pdf_mode,
                venue=args.venue,
                lang=args.lang,
                online=getattr(args, "online", False),
                email=getattr(args, "email", ""),
                scholar_eval=getattr(args, "scholar_eval", False),
            )
        else:
            result = run_audit(
                file_path=args.file,
                mode=args.mode,
                pdf_mode=args.pdf_mode,
                venue=args.venue,
                lang=args.lang,
                style=getattr(args, "style", "A"),
                journal=getattr(args, "journal", ""),
                skip_logic=getattr(args, "skip_logic", False),
                online=getattr(args, "online", False),
                email=getattr(args, "email", ""),
                scholar_eval=getattr(args, "scholar_eval", False),
                literature_search=getattr(args, "literature_search", False),
                tavily_key=getattr(args, "tavily_key", ""),
                s2_key=getattr(args, "s2_key", ""),
                regression=getattr(args, "regression", False),
            )

        report = render_json_report(result) if args.format == "json" else render_report(result)

        if args.output:
            Path(args.output).write_text(report, encoding="utf-8")
            print(f"\n[audit] Report saved to: {args.output}")
        else:
            print("\n" + report)

        # Exit code: 1 if critical issues found, 0 otherwise
        has_critical = any(i.severity == "Critical" for i in result.issues)
        return 1 if has_critical else 0

    except (FileNotFoundError, ValueError) as e:
        print(f"Error: {e}", file=sys.stderr)
        return 2


if __name__ == "__main__":
    sys.exit(main())

#!/usr/bin/env python3
from __future__ import annotations

import argparse
import csv
from dataclasses import dataclass
from pathlib import Path


@dataclass(frozen=True)
class DesignRule:
    slug: str
    keywords: tuple[str, ...]
    style: str
    palette: str
    typography: str
    effects: str
    landing_pattern: str
    anti_patterns: str
    notes: str


DOMAIN_LIBRARY = {
    "style": [
        {"name": "minimal-modern", "tags": {"saas", "productivity", "software"}, "summary": "Clean grids, restrained color, strong spacing rhythm."},
        {"name": "trust-dark", "tags": {"fintech", "security", "analytics"}, "summary": "Dark surfaces with high-contrast metrics and controlled glow."},
        {"name": "elegant-soft", "tags": {"beauty", "wellness", "premium"}, "summary": "Soft neutrals, editorial typography, gentle depth."},
        {"name": "editorial-bold", "tags": {"portfolio", "studio", "creator"}, "summary": "Typography-led layouts with fewer but stronger components."},
    ],
    "color": [
        {"name": "slate-indigo", "tags": {"saas", "b2b", "dashboard"}, "summary": "Reliable product palette with strong focus color."},
        {"name": "navy-cyan", "tags": {"fintech", "security", "crypto"}, "summary": "Trust-heavy dark palette with crisp accent highlights."},
        {"name": "teal-blue", "tags": {"healthcare", "medical", "education"}, "summary": "Calm, legible palette for guidance-heavy flows."},
        {"name": "rose-stone", "tags": {"beauty", "wellness", "service"}, "summary": "Soft premium palette without losing contrast."},
    ],
    "typography": [
        {"name": "Inter + Space Grotesk", "tags": {"saas", "dashboard", "tech"}, "summary": "Functional UI body with sharper display headlines."},
        {"name": "Inter + IBM Plex Sans", "tags": {"fintech", "data", "ops"}, "summary": "Trustworthy and technical without feeling cold."},
        {"name": "DM Sans + Cormorant Garamond", "tags": {"beauty", "luxury", "editorial"}, "summary": "Soft body copy plus premium display contrast."},
        {"name": "Inter + Nunito", "tags": {"education", "learning", "friendly"}, "summary": "Warm, approachable pair for guided workflows."},
    ],
    "landing": [
        {"name": "hero + product proof", "tags": {"saas", "b2b", "product"}, "summary": "Lead with problem, product UI, and trust proof."},
        {"name": "hero + trust signals + metrics", "tags": {"fintech", "security"}, "summary": "Move quickly from promise to credibility to evidence."},
        {"name": "hero + treatments + testimonials", "tags": {"beauty", "service"}, "summary": "Show the offering, then emotion, then social proof."},
        {"name": "summary row + filters + charts", "tags": {"dashboard", "analytics", "ops"}, "summary": "Start with key numbers, then enable fast drill-down."},
    ],
    "chart": [
        {"name": "line chart", "tags": {"trend", "time-series", "monitoring"}, "summary": "Use for change over time and directional narratives."},
        {"name": "bar chart", "tags": {"comparison", "ranking", "category"}, "summary": "Use for category comparison with clear labels."},
        {"name": "funnel chart", "tags": {"conversion", "checkout", "pipeline"}, "summary": "Use only when the user cares about progressive drop-off."},
        {"name": "table + sparkline", "tags": {"dashboard", "ops", "dense"}, "summary": "Best when users must compare many rows quickly."},
    ],
    "ux": [
        {"name": "contrast-first", "tags": {"accessibility", "contrast", "readability"}, "summary": "Keep body text at 4.5:1 or better and check muted states."},
        {"name": "touch targets", "tags": {"mobile", "touch", "interaction"}, "summary": "Keep tap targets at 44x44px or larger."},
        {"name": "motion restraint", "tags": {"animation", "performance", "a11y"}, "summary": "Prefer opacity/transform and honor reduced motion."},
        {"name": "feedback locality", "tags": {"forms", "validation", "errors"}, "summary": "Place errors next to the field or action that caused them."},
    ],
    "product": [
        {"name": "B2B SaaS", "tags": {"saas", "b2b", "workflow"}, "summary": "Prioritize clarity, trust, and information hierarchy."},
        {"name": "consumer marketplace", "tags": {"ecommerce", "retail", "marketplace"}, "summary": "Prioritize CTA hierarchy and decision speed."},
        {"name": "editorial portfolio", "tags": {"portfolio", "agency", "studio"}, "summary": "Let type and spacing carry most of the brand signal."},
    ],
}

STACK_LIBRARY = {
    "html-tailwind": [
        "Use spacing and typography scales consistently; avoid arbitrary values unless they encode a real token.",
        "Prefer semantic HTML first, then layer Tailwind utilities for layout and state.",
        "Use visible focus rings, not shadow-only focus states.",
    ],
    "react": [
        "Separate presentational components from stateful orchestration when the screen gets dense.",
        "Memoize only after identifying re-render pressure; do not cargo-cult memo everywhere.",
        "Keep loading, error, and empty states explicit in component contracts.",
    ],
    "nextjs": [
        "Use server components for data-heavy static surfaces and client components only for interaction islands.",
        "Optimize images and fonts early; layout shift hurts perceived polish.",
        "Keep route segments and layout nesting readable; complexity leaks into UX fast.",
    ],
    "vue": [
        "Keep composables focused and avoid mixing data fetching, presentation logic, and event plumbing in one file.",
        "Use Pinia only when state truly spans multiple views.",
        "Prefer explicit prop contracts over implicit slot conventions for complex widgets.",
    ],
    "svelte": [
        "Use stores sparingly; local state is usually enough for page-scoped interaction.",
        "Keep transitions subtle and intentional.",
        "Use semantic markup because Svelte speed does not compensate for weak accessibility.",
    ],
    "swiftui": [
        "Prefer a small number of reusable view modifiers instead of repeated inline styling.",
        "Use state hoisting for reusable components.",
        "Make navigation state obvious; hidden transitions confuse users quickly.",
    ],
    "react-native": [
        "Design for touch targets and text scaling first.",
        "Avoid over-nesting views; spacing bugs compound quickly on mobile.",
        "Budget for offline and loading states in every primary screen.",
    ],
    "flutter": [
        "Use a small, explicit theme surface; avoid per-widget color drift.",
        "Keep widget trees readable by extracting repeated sections early.",
        "Use platform-appropriate motion and haptics sparingly.",
    ],
    "shadcn": [
        "Treat shadcn/ui as a starting system, not the finished product identity.",
        "Normalize spacing and type across imported primitives before scaling the page.",
        "Audit keyboard and dialog behavior after customization.",
    ],
    "jetpack-compose": [
        "Keep state hoisting explicit and avoid business logic inside composables.",
        "Use Material theming consistently before introducing custom tokens.",
        "Measure recomposition hotspots before optimizing prematurely.",
    ],
}


def load_rules(csv_path: Path) -> list[DesignRule]:
    rows: list[DesignRule] = []
    with csv_path.open(newline="", encoding="utf-8") as handle:
        reader = csv.DictReader(handle)
        for row in reader:
            rows.append(
                DesignRule(
                    slug=row["slug"],
                    keywords=tuple(token.strip() for token in row["keywords"].split(",") if token.strip()),
                    style=row["style"],
                    palette=row["palette"],
                    typography=row["typography"],
                    effects=row["effects"],
                    landing_pattern=row["landing_pattern"],
                    anti_patterns=row["anti_patterns"],
                    notes=row["notes"],
                )
            )
    return rows


def score_rule(query_tokens: set[str], rule: DesignRule) -> int:
    overlap = len(query_tokens & set(rule.keywords))
    return overlap * 10 + (1 if rule.slug in query_tokens else 0)


def pick_rule(query: str, rules: list[DesignRule]) -> DesignRule:
    query_tokens = set(token.lower() for token in query.replace("-", " ").split())
    return max(rules, key=lambda rule: (score_rule(query_tokens, rule), -len(rule.keywords)))


def score_entry(query_tokens: set[str], entry: dict[str, object]) -> tuple[int, str]:
    tags = set(entry.get("tags", set()))
    score = len(query_tokens & tags)
    return score, str(entry["name"])


def top_domain_entries(domain: str, query: str, limit: int) -> list[dict[str, object]]:
    query_tokens = set(token.lower() for token in query.replace("-", " ").split())
    entries = DOMAIN_LIBRARY[domain]
    ranked = sorted(entries, key=lambda entry: score_entry(query_tokens, entry), reverse=True)
    return ranked[:limit]


def render_design_system(rule: DesignRule, query: str, project: str | None, markdown: bool) -> str:
    title = project or query.strip() or rule.slug
    lines = [
        f"# Design system: {title}" if markdown else f"Design system: {title}",
        "",
        f"- Query: {query}",
        f"- Matched profile: {rule.slug}",
        f"- Style direction: {rule.style}",
        f"- Palette: {rule.palette}",
        f"- Typography: {rule.typography}",
        f"- Effects: {rule.effects}",
        f"- Landing/layout bias: {rule.landing_pattern}",
        f"- Avoid: {rule.anti_patterns}",
        f"- Notes: {rule.notes}",
    ]
    return "\n".join(lines)


def render_domain(domain: str, query: str, limit: int, markdown: bool) -> str:
    entries = top_domain_entries(domain, query, limit)
    header = f"# Domain lookup: {domain}" if markdown else f"Domain lookup: {domain}"
    lines = [header, "", f"Query: {query}", ""]
    for entry in entries:
        lines.append(f"- {entry['name']}: {entry['summary']}")
    return "\n".join(lines)


def render_stack(stack: str, markdown: bool) -> str:
    header = f"# Stack guidance: {stack}" if markdown else f"Stack guidance: {stack}"
    lines = [header, ""]
    for item in STACK_LIBRARY[stack]:
        lines.append(f"- {item}")
    return "\n".join(lines)


def persist_design_system(text: str, page: str | None) -> list[Path]:
    base = Path.cwd() / "design-system"
    base.mkdir(exist_ok=True)
    pages = base / "pages"
    pages.mkdir(exist_ok=True)
    created: list[Path] = []
    master = base / "MASTER.md"
    master.write_text(text + "\n", encoding="utf-8")
    created.append(master)
    if page:
        page_path = pages / f"{page}.md"
        page_path.write_text(
            f"# Page override: {page}\n\n- Base authority: ../MASTER.md\n- Record only page-specific deviations here.\n",
            encoding="utf-8",
        )
        created.append(page_path)
    return created


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Search the bundled UI/UX guidance library.")
    parser.add_argument("query", nargs="?", default="")
    parser.add_argument("--design-system", action="store_true")
    parser.add_argument("--domain", choices=sorted(DOMAIN_LIBRARY))
    parser.add_argument("--stack", choices=sorted(STACK_LIBRARY))
    parser.add_argument("--persist", action="store_true")
    parser.add_argument("-p", "--project")
    parser.add_argument("--page")
    parser.add_argument("-n", type=int, default=5)
    parser.add_argument("-f", "--format", choices=("ascii", "markdown"), default="ascii")
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    markdown = args.format == "markdown"
    script_dir = Path(__file__).resolve().parent
    rules = load_rules(script_dir.parent / "data" / "ui-reasoning.csv")

    if args.design_system:
        rule = pick_rule(args.query, rules)
        output = render_design_system(rule, args.query, args.project, markdown)
        print(output)
        if args.persist:
            created = persist_design_system(output, args.page)
            print("\nPersisted:")
            for path in created:
                print(f"- {path}")
        return 0

    if args.domain:
        print(render_domain(args.domain, args.query, args.n, markdown))
        return 0

    if args.stack:
        print(render_stack(args.stack, markdown))
        return 0

    print("No mode selected. Use --design-system, --domain, or --stack.")
    return 1


if __name__ == "__main__":
    raise SystemExit(main())

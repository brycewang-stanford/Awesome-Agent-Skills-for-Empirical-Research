#!/usr/bin/env python3
"""
De-AI Writing Trace Checker for Typst Academic Papers
Analyzes Typst source code for AI writing patterns.

Usage:
    uv run python deai_check.py main.typ --section introduction
    uv run python deai_check.py main.typ --analyze
    uv run python deai_check.py main.typ --fix-suggestions
"""

import argparse
import json
import re
import sys
from pathlib import Path

# Import local parsers
try:
    from parsers import get_parser
except ImportError:
    sys.path.append(str(Path(__file__).parent))
    from parsers import get_parser


class AITraceChecker:
    """Detect AI writing traces."""

    # High-priority AI patterns (Category 1: Empty phrases)
    EMPTY_PHRASES = {
        r"\bsignificant\s+(?:improvement|performance|gain|enhancement|advancement)\b": "quantify",
        r"\bcomprehensive\s+(?:analysis|study|overview|survey|review)\b": "list_scope",
        r"\beffective\s+(?:solution|method|approach|technique)\b": "compare_baseline",
        r"\bimportant\s+(?:contribution|role|impact|implication)\b": "explain_why",
        r"\brobust\s+(?:performance|method|approach)\b": "specify_condition",
        r"\bnovel\s+(?:approach|method|technique|algorithm)\b": "explain_novelty",
        r"\bstate-of-the-art\s+(?:performance|results|accuracy)\b": "cite_sota",
        r"显著提升": "quantify",
        r"全面(?:分析|研究|系统)": "list_scope",
        r"重要(?:意义|价值|贡献)": "explain_why",
        r"新颖(?:方法|思路)": "explain_novelty",
    }

    # High-priority AI patterns (Category 2: Over-confident)
    OVER_CONFIDENT = {
        r"\bobviously\b": "hedge",
        r"\bclearly\b": "hedge",
        r"\bcertainly\b": "hedge",
        r"\bundoubtedly\b": "hedge",
        r"\bnecessarily\b": "condition",
        r"\bcompletely\b": "limit",
        r"\balways\b": "frequency",
        r"\bnever\b": "frequency",
        r"显而易见": "hedge",
        r"毫无疑问": "hedge",
        r"必然": "condition",
        r"完全": "limit",
    }

    # High-priority AI patterns (Category 4: Vague quantification)
    VAGUE_QUANTIFIERS = {
        r"\bmany\s+studies\b": "cite_specific",
        r"\bnumerous\s+experiments?\b": "quantify_exp",
        r"\bvarious\s+methods?\b": "list_methods",
        r"\bseveral\s+approaches?\b": "list_methods",
        r"\bmultiple\s+(?:datasets?|methods?|experiments?)\b": "quantify_items",
        r"\ba\s+(?:lot|large\s+number)\s+of\b": "quantify",
        r"\bthe\s+majority\s+of\b": "quantify_percent",
        r"\bsubstantial\s+(?:amount|number|gain|improvement)\b": "quantify",
        r"大量研究": "cite_specific",
        r"众多(?:实验|学者)": "quantify_exp",
        r"多种(?:方法|方案)": "list_methods",
        r"大幅(?:提升|改善)": "quantify",
    }

    # Medium-priority AI patterns (Category 3: Template expressions)
    TEMPLATE_EXPRESSIONS = {
        r"\bin\s+recent\s+years\b": "specific_time",
        r"\bmore\s+and\s+more\b": "increasingly",
        r"\bplays?\s+an?\s+important\s+role\b": "specific_impact",
        r"\bwith\s+the\s+(?:rapid\s+)?development\s+of\b": "context_direct",
        r"\bhas\s+(?:been\s+)?widely\s+used\b": "cite_examples",
        r"\bhas\s+attracted\s+(?:much\s+)?attention\b": "cite_examples",
        r"近年来": "specific_time",
        r"越来越多的": "increasingly",
        r"发挥(?:着)?重要(?:的)?作用": "specific_impact",
        r"被广泛(?:应用|使用)": "cite_examples",
        r"引起了(?:广泛|众多)关注": "cite_examples",
    }
    AI_FILLER_CONNECTORS = {
        r"总之": "filler_remove",
        r"综上所述": "filler_remove",
        r"值得注意的是": "filler_remove",
        r"需要指出的是": "filler_remove",
    }
    EVIDENCE_MARKERS = re.compile(r"(#cite\(|@\w+|\b\d+(?:\.\d+)?%?\b|\\cite\{)")

    def __init__(self, file_path: Path):
        self.file_path = file_path
        self.content = file_path.read_text(encoding="utf-8", errors="ignore")
        self.lines = self.content.split("\n")
        self.parser = get_parser(file_path)
        self.section_ranges = self.parser.split_sections(self.content)
        self.comment_prefix = self.parser.get_comment_prefix()

    def _is_false_positive(self, match_obj, text: str, pattern: str) -> bool:
        """Check context to rule out false positives."""
        start, end = match_obj.span()

        # Look ahead context (next 50 chars)
        context_after = text[end : end + 50]
        # Look behind context (prev 50 chars)
        context_before = text[max(0, start - 50) : start]

        # 1. "significant" followed by p-value or statistical terms
        if "significant" in pattern:
            if re.search(r"statistically", context_before, re.IGNORECASE):
                return True
            if re.search(r"p\s*[<>=]\s*0\.\d+", context_after):
                return True
            if re.search(r"at\s+the\s+0\.\d+\s+level", context_after):
                return True

        # 2. "improvement" followed by percentage or number
        if "improvement" in pattern or "gain" in pattern:
            if re.search(r"by\s+\d+(?:\.\d+)?%", context_after):
                return True
            if re.search(r"of\s+\d+(?:\.\d+)?%", context_after):
                return True

        # 3. "comprehensive" followed by range
        return bool(
            "comprehensive" in pattern and "from" in context_after and "to" in context_after
        )

    def _find_pattern_in_section(
        self, pattern: str, suggestion_type: str, section_name: str, category: str
    ) -> list[dict]:
        """Find pattern occurrences in a specific section."""
        if section_name not in self.section_ranges:
            return []

        start, end = self.section_ranges[section_name]
        matches = []

        for i in range(start - 1, min(end, len(self.lines))):
            line = self.lines[i]
            stripped = line.strip()

            # Skip comments
            if stripped.startswith(self.comment_prefix):
                continue

            visible_text = self.parser.extract_visible_text(stripped)

            for match in re.finditer(pattern, visible_text, re.IGNORECASE):
                # Context check
                if self._is_false_positive(match, visible_text, pattern):
                    continue

                matches.append(
                    {
                        "line": i + 1,
                        "text": visible_text,
                        "original": stripped,
                        "pattern": pattern,
                        "category": category,
                        "section": section_name,
                        "suggestion_type": suggestion_type,
                    }
                )

        return matches

    def check_section(self, section_name: str) -> dict:
        """Check a specific section for AI traces."""
        results = {
            "section": section_name,
            "total_lines": 0,
            "trace_count": 0,
            "traces": [],
        }

        if section_name not in self.section_ranges:
            start, end = 1, len(self.lines)
        else:
            start, end = self.section_ranges[section_name]

        results["total_lines"] = end - start + 1

        all_patterns = [
            ("empty_phrase", self.EMPTY_PHRASES),
            ("over_confident", self.OVER_CONFIDENT),
            ("vague_quantifier", self.VAGUE_QUANTIFIERS),
            ("template_expr", self.TEMPLATE_EXPRESSIONS),
            ("filler_connector", self.AI_FILLER_CONNECTORS),
        ]

        for category, patterns_dict in all_patterns:
            for pattern, suggestion_type in patterns_dict.items():
                matches = self._find_pattern_in_section(
                    pattern, suggestion_type, section_name, category
                )
                results["traces"].extend(matches)

        results["traces"].extend(self._check_parallel_openings(section_name))
        results["traces"].extend(self._check_low_information_density(section_name))
        results["trace_count"] = len(results["traces"])
        return results

    def _check_parallel_openings(self, section_name: str) -> list[dict]:
        if section_name not in self.section_ranges:
            return []
        start, end = self.section_ranges[section_name]
        visible_lines: list[tuple[int, str]] = []
        for i in range(start - 1, min(end, len(self.lines))):
            line = self.lines[i].strip()
            if not line or line.startswith(self.comment_prefix):
                continue
            visible = self.parser.extract_visible_text(line)
            if visible and len(visible) >= 4:
                visible_lines.append((i + 1, visible))

        openings: dict[str, list[int]] = {}
        for line_no, visible in visible_lines:
            prefix = (
                visible[:2]
                if re.search(r"[\u4e00-\u9fff]", visible)
                else " ".join(visible.split()[:2]).lower()
            )
            if prefix:
                openings.setdefault(prefix, []).append(line_no)

        for prefix, line_numbers in openings.items():
            if len(line_numbers) >= 3:
                return [
                    {
                        "line": line_numbers[0],
                        "text": f"Repeated opening pattern '{prefix}' across {len(line_numbers)} lines",
                        "original": "",
                        "pattern": f"parallel:{prefix}",
                        "category": "parallel_structure",
                        "section": section_name,
                        "suggestion_type": "vary_opening",
                    }
                ]
        return []

    def _check_low_information_density(self, section_name: str) -> list[dict]:
        if section_name not in self.section_ranges:
            return []
        start, end = self.section_ranges[section_name]
        visible_lines: list[tuple[int, str]] = []
        for i in range(start - 1, min(end, len(self.lines))):
            line = self.lines[i].strip()
            if not line or line.startswith(self.comment_prefix):
                continue
            visible = self.parser.extract_visible_text(line)
            if visible:
                visible_lines.append((i + 1, visible))

        if len(visible_lines) < 3:
            return []

        text = " ".join(text for _, text in visible_lines)
        boilerplate_hits = 0
        for patterns_dict in (
            self.EMPTY_PHRASES,
            self.VAGUE_QUANTIFIERS,
            self.TEMPLATE_EXPRESSIONS,
            self.AI_FILLER_CONNECTORS,
        ):
            boilerplate_hits += sum(
                1 for pattern in patterns_dict if re.search(pattern, text, re.IGNORECASE)
            )

        if boilerplate_hits < 2 or self.EVIDENCE_MARKERS.search(text):
            return []

        repeated_openings = any(
            trace["category"] == "parallel_structure"
            for trace in self._check_parallel_openings(section_name)
        )
        if not repeated_openings and len(text.split()) < 20 and len(text) < 60:
            return []

        return [
            {
                "line": visible_lines[0][0],
                "text": text[:160],
                "original": "",
                "pattern": "low_information_density",
                "category": "low_information_density",
                "section": section_name,
                "suggestion_type": "increase_information_density",
            }
        ]

    def analyze_document(self) -> dict:
        """Analyze entire document."""
        analysis = {
            "total_lines": len(self.lines),
            "sections": {},
        }

        for section_name in self.section_ranges:
            analysis["sections"][section_name] = self.check_section(section_name)

        return analysis

    def calculate_density_score(self, result: dict) -> float:
        if result["total_lines"] == 0:
            return 0.0
        return (result["trace_count"] / result["total_lines"]) * 100

    def generate_suggestions_json(self, analysis: dict) -> list[dict]:
        """Generate structured suggestions for Agent."""
        suggestions = []
        for section_name, result in analysis["sections"].items():
            for trace in result["traces"]:
                suggestions.append(
                    {
                        "file": str(self.file_path),
                        "line": trace["line"],
                        "section": section_name,
                        "category": trace["category"],
                        "issue": trace["text"],
                        "pattern": trace["pattern"],
                        "suggestion_key": trace["suggestion_type"],
                        "instruction": self._get_instruction(trace["suggestion_type"]),
                    }
                )
        return suggestions

    def _get_instruction(self, key: str) -> str:
        """Get human-readable instruction for the suggestion key."""
        instructions = {
            "quantify": "Replace with specific numbers or metrics.",
            "list_scope": "Explicitly list what was covered (X, Y, Z).",
            "compare_baseline": 'State improvement over baseline (e.g., "reduces error by X%").',
            "explain_why": "Explain specific importance or impact.",
            "specify_condition": "Specify under what conditions this holds.",
            "explain_novelty": "Explain specific technical difference.",
            "cite_sota": "Cite specific SOTA papers and compare metrics.",
            "hedge": 'Use academic hedging (e.g., "results suggest").',
            "condition": 'Add condition (e.g., "under assumption X").',
            "limit": "Acknowledge limitations or boundaries.",
            "frequency": "Use frequency adverb or specific count.",
            "cite_specific": "Cite specific papers [1-3].",
            "quantify_exp": "State number of experiments/datasets.",
            "list_methods": "List specific methods compared.",
            "quantify_items": "State exact number.",
            "quantify_percent": "State percentage.",
            "specific_time": 'Use specific time period or "since 20XX".',
            "increasingly": 'Use "increasingly" or growth data.',
            "specific_impact": "Describe specific impact or function.",
            "context_direct": "Start directly with the problem/context.",
            "cite_examples": "Provide citation examples.",
            "filler_remove": "Delete filler connectors and state the point directly.",
            "vary_opening": "Vary sentence openings to avoid mechanical repetition.",
            "increase_information_density": "Add concrete methods, comparators, evidence, and results instead of rhetorical filler.",
        }
        return instructions.get(key, "Rewrite to be more specific and objective.")

    def generate_report(self, analysis: dict) -> str:
        """Generate human-readable analysis report."""
        report = []
        report.append("=" * 70)
        report.append("DE-AI WRITING TRACE ANALYSIS REPORT (Typst)")
        report.append("=" * 70)
        report.append(f"File: {self.file_path}")
        report.append(f"Total lines: {analysis['total_lines']}")
        report.append("")

        section_scores = []
        for section_name, result in analysis["sections"].items():
            score = self.calculate_density_score(result)
            section_scores.append((section_name, score, result))

        report.append("-" * 70)
        report.append("PRIORITY RANKING")
        report.append("-" * 70)
        section_scores.sort(key=lambda x: x[1], reverse=True)
        for i, (section_name, score, result) in enumerate(section_scores, 1):
            if score > 0:
                report.append(f"{i}. {section_name}: {score:.1f}% ({result['trace_count']} traces)")

        report.append("")
        report.append("-" * 70)
        report.append("DETAILED TRACE LISTING")
        report.append("-" * 70)

        for section_name, result in analysis["sections"].items():
            if result["traces"]:
                report.append(f"\n{section_name.upper()}:")
                for trace in result["traces"][:10]:
                    report.append(f"  Line {trace['line']} [{trace['category']}]")
                    report.append(f"    {trace['text'][:80]}")
                    report.append(
                        f"    -> Suggestion: {self._get_instruction(trace['suggestion_type'])}"
                    )

        return "\n".join(report)


def main():
    parser = argparse.ArgumentParser(description="Analyze Typst documents for AI writing traces")
    parser.add_argument("file", type=Path, help="Typst file to analyze (.typ)")
    parser.add_argument("--section", type=str, help="Specific section to check")
    parser.add_argument("--analyze", action="store_true", help="Full document analysis")
    parser.add_argument("--score", action="store_true", help="Output section scores only")
    parser.add_argument(
        "--fix-suggestions", action="store_true", help="Generate JSON suggestions for fixing"
    )
    parser.add_argument("--output", type=Path, help="Save report/json to file")

    args = parser.parse_args()

    if not args.file.exists():
        print(f"[ERROR] File not found: {args.file}", file=sys.stderr)
        sys.exit(1)

    if not str(args.file).lower().endswith(".typ"):
        print(f"[WARNING] Expected .typ file, got: {args.file}", file=sys.stderr)

    checker = AITraceChecker(args.file)

    if args.fix_suggestions:
        analysis = checker.analyze_document()
        suggestions = checker.generate_suggestions_json(analysis)
        if args.output:
            with open(args.output, "w", encoding="utf-8") as f:
                json.dump(suggestions, f, indent=2)
            print(f"[SUCCESS] Suggestions saved to: {args.output}")
        else:
            print(json.dumps(suggestions, indent=2))
        sys.exit(0)

    if args.analyze:
        analysis = checker.analyze_document()
        report = checker.generate_report(analysis)

        if args.output:
            args.output.write_text(report, encoding="utf-8")
            print(f"[SUCCESS] Report saved to: {args.output}")
        else:
            print(report)

        worst_score = 0
        if analysis["sections"]:
            worst_score = max(
                checker.calculate_density_score(result) for result in analysis["sections"].values()
            )

        if worst_score > 10:
            sys.exit(2)
        elif worst_score > 5:
            sys.exit(1)
        else:
            sys.exit(0)

    elif args.section:
        result = checker.check_section(args.section.lower())
        score = checker.calculate_density_score(result)
        print(f"\nSection: {args.section}")
        print(f"Density: {score:.1f}%")
        for trace in result["traces"]:
            print(f"Line {trace['line']}: {trace['text']}")
            print(f"-> {checker._get_instruction(trace['suggestion_type'])}\n")

    elif args.score:
        analysis = checker.analyze_document()
        print(f"\n{'Section':<15} {'Density':<10}")
        for section_name, result in analysis["sections"].items():
            score = checker.calculate_density_score(result)
            print(f"{section_name:<15} {score:>6.1f}%")

    else:
        print("[INFO] Use --analyze for full analysis")
        print("[INFO] Use --section <name> for specific section")
        print("[INFO] Use --fix-suggestions for JSON output")


if __name__ == "__main__":
    main()

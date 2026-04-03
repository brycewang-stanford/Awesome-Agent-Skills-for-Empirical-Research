#!/usr/bin/env python3
"""
De-AI Writing Trace Checker for Chinese Academic Theses
Analyzes LaTeX/Typst source code for AI writing patterns.

Usage:
    uv run python deai_check.py main.tex --section introduction
    uv run python deai_check.py main.tex --analyze
    uv run python deai_check.py main.tex --fix-suggestions
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


class ChineseAITraceChecker:
    """Detect AI writing traces in Chinese documents."""

    # Pattern Map with Suggestion Keys
    EMPTY_PHRASES = {
        r"显著提升": "quantify",
        r"全面(?:分析|研究|系统)": "list_scope",
        r"有效解决": "compare_baseline",
        r"重要(?:意义|价值|贡献)": "explain_why",
        r"鲁棒性(?:好|强)": "specify_condition",
        r"新颖(?:方法|思路)": "explain_novelty",
        r"达到最先进水平": "cite_sota",
        r"取得(?:显著|重大)进展": "quantify_progress",
    }

    OVER_CONFIDENT = {
        r"显而易见": "hedge",
        r"毫无疑问": "hedge",
        r"必然": "condition",
        r"完全": "limit",
        r"毫无例外": "limit",
        r"总是": "frequency",
        r"从不": "frequency",
        r"肯定": "hedge",
        r"一定": "hedge",
        r"毋庸置疑": "hedge",
    }

    VAGUE_QUANTIFIERS = {
        r"大量研究": "cite_specific",
        r"众多(?:实验|学者)": "quantify_exp",
        r"多种(?:方法|方案)": "list_methods",
        r"若干(?:方面|问题)": "list_items",
        r"许多(?:研究|学者)": "cite_specific",
        r"大部分": "quantify_percent",
        r"大幅(?:提升|改善)": "quantify",
        r"显著(?:增加|减少)": "quantify",
        r"广泛的": "specify_scope",
    }

    TEMPLATE_EXPRESSIONS = {
        r"近年来": "specific_time",
        r"越来越多的": "increasingly",
        r"发挥(?:着)?重要(?:的)?作用": "specific_impact",
        r"随着(?:科技|技术)(?:的)?(?:快速|飞速)?发展": "context_direct",
        r"被广泛(?:应用|使用)": "cite_examples",
        r"引起了(?:广泛|众多)关注": "cite_examples",
        r"蓬勃(?:发展|兴起)": "growth_data",
    }

    AI_FILLER_CONNECTORS = {
        r"总之": "filler_remove",
        r"综上所述": "filler_remove",
        r"不可否认的是": "filler_remove",
        r"值得注意的是": "filler_remove",
        r"需要指出的是": "filler_remove",
        r"不难发现": "filler_remove",
        r"众所周知": "filler_remove",
        r"毋庸讳言": "filler_remove",
    }
    EVIDENCE_MARKERS = re.compile(r"(\\cite\{|@\w+|\d+(?:\.\d+)?%?)")

    def __init__(self, file_path: Path):
        self.file_path = file_path
        self.content = file_path.read_text(encoding="utf-8", errors="ignore")
        self.lines = self.content.split("\n")
        self.parser = get_parser(file_path)
        self.section_ranges = self.parser.split_sections(self.content)
        self.comment_prefix = self.parser.get_comment_prefix()

    def _is_false_positive(self, match_obj, text: str, pattern: str) -> bool:
        """Check context to rule out false positives (Chinese)."""
        start, end = match_obj.span()

        # Look ahead context (next 20 chars)
        context_after = text[end : end + 20]
        # Look behind context (prev 20 chars)
        text[max(0, start - 20) : start]

        # 1. "显著提升/增加/减少" followed by number/percent
        if "显著" in pattern:
            if re.search(r"[降低升高提升增加减少了].*?\d+(?:\.\d+)?%", context_after):
                return True
            if re.search(r"p\s*[<>=]\s*0\.\d+", context_after):
                return True

        # 2. "大幅" followed by number
        return bool("大幅" in pattern and re.search(r"\d+(?:\.\d+)?%", context_after))

    def _find_pattern_in_section(
        self, pattern: str, suggestion_type: str, section_name: str, category: str
    ) -> list[dict]:
        if section_name not in self.section_ranges:
            return []

        start, end = self.section_ranges[section_name]
        matches = []

        for i in range(start - 1, min(end, len(self.lines))):
            line = self.lines[i]
            stripped = line.strip()

            if stripped.startswith(self.comment_prefix):
                continue

            visible_text = self.parser.extract_visible_text(stripped)

            for match in re.finditer(pattern, visible_text):
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

        results["trace_count"] = len(results["traces"])

        # C2: Check for parallel sentence structures
        parallel_issues = self._check_parallel_sentences(section_name)
        results["traces"].extend(parallel_issues)
        results["traces"].extend(self._check_low_information_density(section_name))
        results["trace_count"] = len(results["traces"])

        return results

    def _check_parallel_sentences(self, section_name: str) -> list[dict]:
        """C2: Detect 3+ consecutive lines sharing the same opening pattern."""
        if section_name not in self.section_ranges:
            return []

        start, end = self.section_ranges[section_name]
        issues: list[dict] = []
        visible_lines: list[tuple[int, str]] = []

        for i in range(start - 1, min(end, len(self.lines))):
            line = self.lines[i].strip()
            if not line or line.startswith(self.comment_prefix):
                continue
            visible = self.parser.extract_visible_text(line)
            if visible and len(visible) >= 4:
                visible_lines.append((i + 1, visible))

        consecutive = 0
        streak_start = 0
        prev_prefix = ""
        for line_no, text in visible_lines:
            # Extract first 2 characters as prefix for Chinese text
            prefix = text[:2]
            if prefix == prev_prefix and prefix:
                if consecutive == 0:
                    streak_start = line_no
                consecutive += 1
            else:
                if consecutive >= 3:
                    issues.append(
                        {
                            "line": streak_start,
                            "text": f"连续{consecutive}行以相同模式开头",
                            "original": "",
                            "pattern": f"parallel:{prev_prefix}",
                            "category": "parallel_structure",
                            "section": section_name,
                            "suggestion_type": "vary_opening",
                        }
                    )
                consecutive = 0
            prev_prefix = prefix

        if consecutive >= 3:
            issues.append(
                {
                    "line": streak_start,
                    "text": f"连续{consecutive}行以相同模式开头",
                    "original": "",
                    "pattern": f"parallel:{prev_prefix}",
                    "category": "parallel_structure",
                    "section": section_name,
                    "suggestion_type": "vary_opening",
                }
            )

        return issues

    def _check_low_information_density(self, section_name: str) -> list[dict]:
        """Detect sections that are long on rhetoric but short on information."""
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
            boilerplate_hits += sum(1 for pattern in patterns_dict if re.search(pattern, text))

        if boilerplate_hits < 2 or self.EVIDENCE_MARKERS.search(text):
            return []

        opening_prefixes = [text[:2] for _, text in visible_lines if len(text) >= 2]
        repeated_opening = any(
            opening_prefixes.count(prefix) >= 2 for prefix in set(opening_prefixes)
        )
        if not repeated_opening and len(text) < 60:
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
        instructions = {
            "quantify": '替换为具体数值或指标 (如 "降低了 12%").',
            "list_scope": "列举具体分析了哪些方面.",
            "compare_baseline": "陈述相对于基线的具体改进幅度.",
            "explain_why": "解释具体的重要性或影响.",
            "specify_condition": "说明成立的具体条件.",
            "explain_novelty": "解释具体的技术差异点.",
            "cite_sota": "引用具体的 SOTA 论文并对比指标.",
            "quantify_progress": "用数据量化进展.",
            "hedge": '使用学术限定语 (如 "实验结果表明").',
            "condition": '增加前提条件 (如 "在本文设置下").',
            "limit": "承认局限性或边界条件.",
            "frequency": "使用频率副词或具体统计.",
            "cite_specific": "引用具体文献 [1-3].",
            "quantify_exp": "说明具体的实验或数据集数量.",
            "list_methods": "列举具体的对比方法.",
            "list_items": "列举具体的点.",
            "quantify_percent": "说明具体百分比.",
            "specify_scope": "界定具体范围.",
            "specific_time": '使用具体时间段或 "自 20XX 年以来".',
            "increasingly": "描述具体的增长趋势.",
            "specific_impact": "描述具体的功能或影响.",
            "context_direct": "直接切入具体问题背景.",
            "cite_examples": "提供具体的引用案例.",
            "growth_data": "提供增长数据支持.",
            "filler_remove": "删除此填充连接词，直接陈述核心观点.",
            "vary_opening": "变换句式开头，避免机械排比结构.",
            "increase_information_density": "补入具体方法、对比对象、数据或结论，不要只说空泛价值判断.",
        }
        return instructions.get(key, "请改写得更具体、客观。")

    def generate_report(self, analysis: dict) -> str:
        report = []
        report.append("=" * 70)
        report.append("中文博士论文去AI化写作痕迹分析报告 (增强版)")
        report.append("=" * 70)
        report.append(f"文件: {self.file_path}")
        report.append(f"总行数: {analysis['total_lines']}")
        report.append("")

        section_scores = []
        for section_name, result in analysis["sections"].items():
            score = self.calculate_density_score(result)
            section_scores.append((section_name, score, result))

        report.append("-" * 70)
        report.append("优先级排序")
        report.append("-" * 70)
        section_scores.sort(key=lambda x: x[1], reverse=True)
        for i, (section_name, score, result) in enumerate(section_scores, 1):
            if score > 0:
                report.append(f"{i}. {section_name}: {score:.1f}% ({result['trace_count']} 处痕迹)")

        report.append("")
        report.append("-" * 70)
        report.append("详细痕迹列表")
        report.append("-" * 70)

        for section_name, result in analysis["sections"].items():
            if result["traces"]:
                report.append(f"\n{section_name.upper()}:")
                for trace in result["traces"][:10]:
                    report.append(f"  第{trace['line']}行 [{trace['category']}]")
                    report.append(f"    {trace['text'][:80]}")
                    report.append(f"    -> 建议: {self._get_instruction(trace['suggestion_type'])}")

        return "\n".join(report)


def main():
    parser = argparse.ArgumentParser(description="分析中文 LaTeX/Typst 文档中的 AI 写作痕迹")
    parser.add_argument("file", type=Path, help="文件路径")
    parser.add_argument("--section", type=str, help="检查特定章节")
    parser.add_argument("--analyze", action="store_true", help="完整文档分析")
    parser.add_argument("--score", action="store_true", help="仅输出章节得分")
    parser.add_argument("--fix-suggestions", action="store_true", help="生成 JSON 修复建议")
    parser.add_argument("--output", type=Path, help="保存结果到文件")

    args = parser.parse_args()

    if not args.file.exists():
        print(f"[错误] 文件未找到: {args.file}", file=sys.stderr)
        sys.exit(1)

    checker = ChineseAITraceChecker(args.file)

    if args.fix_suggestions:
        analysis = checker.analyze_document()
        suggestions = checker.generate_suggestions_json(analysis)
        if args.output:
            with open(args.output, "w", encoding="utf-8") as f:
                json.dump(suggestions, f, indent=2, ensure_ascii=False)
            print(f"[成功] 修复建议已保存到: {args.output}")
        else:
            print(json.dumps(suggestions, indent=2, ensure_ascii=False))
        sys.exit(0)

    if args.analyze:
        analysis = checker.analyze_document()
        report = checker.generate_report(analysis)

        if args.output:
            args.output.write_text(report, encoding="utf-8")
            print(f"[成功] 报告已保存到: {args.output}")
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

    # ... (rest same as before) ...
    elif args.section:
        result = checker.check_section(args.section.lower())
        score = checker.calculate_density_score(result)
        print(f"\n章节: {args.section}")
        print(f"密度: {score:.1f}%")
        for trace in result["traces"]:
            print(f"第{trace['line']}行: {trace['text']}")
            print(f"-> {checker._get_instruction(trace['suggestion_type'])}\n")

    elif args.score:
        analysis = checker.analyze_document()
        print(f"\n{'章节':<15} {'密度':<10}")
        for section_name, result in analysis["sections"].items():
            score = checker.calculate_density_score(result)
            print(f"{section_name:<15} {score:>6.1f}%")

    else:
        print("[信息] 使用 --analyze 进行完整文档分析")


if __name__ == "__main__":
    main()

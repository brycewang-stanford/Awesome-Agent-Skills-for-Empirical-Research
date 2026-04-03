"""Verify that deep-review issue quotes can be located in the source text."""

from __future__ import annotations

import argparse
import json
from pathlib import Path


def verify_quotes(full_text: str, issues: list[dict]) -> list[dict]:
    """Annotate issues with quote verification status."""
    updated: list[dict] = []
    for issue in issues:
        quote = issue.get("quote", "").strip()
        verified = bool(quote and quote in full_text)
        patched = dict(issue)
        patched["quote_verified"] = verified
        updated.append(patched)
    return updated


def main() -> int:
    parser = argparse.ArgumentParser(description="Verify quotes in final_issues.json")
    parser.add_argument("review_dir", help="Path to a deep-review workspace")
    parser.add_argument(
        "--write-back",
        action="store_true",
        help="Rewrite final_issues.json with quote_verified annotations",
    )
    args = parser.parse_args()

    review_dir = Path(args.review_dir).resolve()
    full_text = (review_dir / "full_text.md").read_text(encoding="utf-8")
    issues_path = review_dir / "final_issues.json"
    issues = json.loads(issues_path.read_text(encoding="utf-8"))
    updated = verify_quotes(full_text, issues)
    verified_count = sum(1 for issue in updated if issue.get("quote_verified"))

    if args.write_back:
        issues_path.write_text(json.dumps(updated, indent=2, ensure_ascii=False), encoding="utf-8")

    print(f"Verified {verified_count}/{len(updated)} quotes")
    return 0 if verified_count == len(updated) else 1


if __name__ == "__main__":
    raise SystemExit(main())

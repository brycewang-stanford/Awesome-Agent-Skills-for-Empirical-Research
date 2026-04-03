"""Diff two deep-review issue bundles for re-audit style comparisons."""

from __future__ import annotations

import argparse
import json
from pathlib import Path


def load_issues(path: Path) -> list[dict]:
    """Load issue bundle JSON from a file path."""
    return json.loads(path.read_text(encoding="utf-8"))


def diff_issues(previous: list[dict], current: list[dict]) -> dict:
    """Compare previous and current issue bundles by root cause key."""
    current_by_key = {issue.get("root_cause_key", issue.get("title")): issue for issue in current}
    previous_by_key = {issue.get("root_cause_key", issue.get("title")): issue for issue in previous}
    statuses: list[dict] = []

    for key, old_issue in previous_by_key.items():
        new_issue = current_by_key.get(key)
        if new_issue is None:
            status = "FULLY_ADDRESSED"
        elif old_issue.get("severity") == new_issue.get("severity"):
            status = "NOT_ADDRESSED"
        else:
            status = "PARTIALLY_ADDRESSED"

        statuses.append(
            {
                "root_cause_key": key,
                "title": old_issue.get("title"),
                "previous_severity": old_issue.get("severity"),
                "current_severity": new_issue.get("severity") if new_issue else None,
                "status": status,
            }
        )

    new_items = [issue for key, issue in current_by_key.items() if key not in previous_by_key]
    return {"statuses": statuses, "new_issues": new_items}


def main() -> int:
    parser = argparse.ArgumentParser(description="Diff two deep-review issue bundle files")
    parser.add_argument("previous", help="Path to old final_issues.json")
    parser.add_argument("current", help="Path to new final_issues.json")
    args = parser.parse_args()

    diff = diff_issues(load_issues(Path(args.previous)), load_issues(Path(args.current)))
    print(json.dumps(diff, indent=2, ensure_ascii=False))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

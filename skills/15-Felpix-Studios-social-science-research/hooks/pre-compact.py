#!/usr/bin/env python3
"""
Pre-Compact State Capture Hook

Fires before context compaction to capture the current state:
- Active plan path and status
- Current task description
- Recent decisions from session log

This state is read by post-compact-restore.py after compaction.

Hook Event: PreCompact
Returns: Exit code 0 (message printed to stderr for visibility)
"""

from __future__ import annotations

import json
import os
import sys
import re
from pathlib import Path
from datetime import datetime
import hashlib

# Colors for terminal output
CYAN = "\033[0;36m"
GREEN = "\033[0;32m"
YELLOW = "\033[0;33m"
NC = "\033[0m"  # No color


def get_session_dir() -> Path:
    """Get the session directory for storing state files."""
    project_dir = os.environ.get("CLAUDE_PROJECT_DIR", "")
    if not project_dir:
        return Path.home() / ".claude" / "sessions" / "default"

    project_hash = hashlib.md5(project_dir.encode()).hexdigest()[:8]
    session_dir = Path.home() / ".claude" / "sessions" / project_hash
    session_dir.mkdir(parents=True, exist_ok=True)
    return session_dir


def find_active_plan(project_dir: str) -> dict | None:
    """Find the most recent non-completed plan."""
    plans_dir = Path(project_dir) / "quality_reports" / "plans"
    if not plans_dir.exists():
        return None

    plan_files = sorted(plans_dir.glob("*.md"), key=lambda f: f.stat().st_mtime, reverse=True)

    for plan_file in plan_files[:3]:  # Check last 3 plans
        content = plan_file.read_text()

        # Skip completed plans
        if "COMPLETED" in content.upper():
            continue

        # Extract status
        status = "in_progress"
        if "APPROVED" in content.upper():
            status = "approved"
        elif "DRAFT" in content.upper():
            status = "draft"

        # Find current task (first unchecked item)
        current_task = None
        for line in content.split("\n"):
            if "- [ ]" in line:
                current_task = line.replace("- [ ]", "").strip()
                break

        return {
            "plan_path": str(plan_file),
            "plan_name": plan_file.name,
            "status": status,
            "current_task": current_task
        }

    return None


def extract_recent_decisions(project_dir: str, limit: int = 3) -> list[str]:
    """Extract recent decisions from the session log."""
    logs_dir = Path(project_dir) / "quality_reports" / "session_logs"
    if not logs_dir.exists():
        return []

    log_files = sorted(logs_dir.glob("*.md"), key=lambda f: f.stat().st_mtime, reverse=True)
    if not log_files:
        return []

    content = log_files[0].read_text()
    decisions = []

    # Look for decision markers
    patterns = [
        r"Decision:\s*(.+)",
        r"Decided:\s*(.+)",
        r"Chose:\s*(.+)",
        r"→\s*(.+)",
        r"•\s*(.+)"
    ]

    for line in content.split("\n")[-50:]:  # Last 50 lines
        for pattern in patterns:
            match = re.search(pattern, line.strip())
            if match and len(match.group(1)) > 10:
                decisions.append(match.group(1)[:100])
                if len(decisions) >= limit:
                    return decisions

    return decisions


def save_state(state: dict) -> None:
    """Save state to the session directory."""
    state_file = get_session_dir() / "pre-compact-state.json"
    state["timestamp"] = datetime.now().isoformat()

    try:
        state_file.write_text(json.dumps(state, indent=2))
    except IOError as e:
        print(f"Warning: Could not save pre-compact state: {e}", file=sys.stderr)


def append_to_session_log(project_dir: str, trigger: str) -> None:
    """Append compaction note to session log."""
    logs_dir = Path(project_dir) / "quality_reports" / "session_logs"
    if not logs_dir.exists():
        return

    log_files = sorted(logs_dir.glob("*.md"), key=lambda f: f.stat().st_mtime, reverse=True)
    if not log_files:
        return

    try:
        with open(log_files[0], "a") as f:
            f.write(f"\n\n---\n")
            f.write(f"**Context compaction ({trigger}) at {datetime.now().strftime('%H:%M')}**\n")
            f.write(f"Check git log and quality_reports/plans/ for current state.\n")
    except IOError:
        pass


def format_compaction_message(plan_info: dict | None, decisions: list[str]) -> str:
    """Format the pre-compaction message."""
    lines = []
    lines.append(f"\n{YELLOW}⚡ Context compaction starting{NC}")
    lines.append("")

    if plan_info:
        lines.append(f"{GREEN}Current state saved:{NC}")
        lines.append(f"  Plan: {plan_info['plan_name']} ({plan_info['status']})")
        if plan_info.get("current_task"):
            lines.append(f"  Next task: {plan_info['current_task']}")

    if decisions:
        lines.append("")
        lines.append(f"{GREEN}Recent decisions captured:{NC}")
        for d in decisions:
            lines.append(f"  • {d[:80]}...")

    lines.append("")
    lines.append(f"{CYAN}State will be restored after compaction.{NC}")
    lines.append("")

    return "\n".join(lines)


def main() -> int:
    """Main hook entry point."""
    # Read hook input
    try:
        hook_input = json.load(sys.stdin)
    except (json.JSONDecodeError, IOError):
        hook_input = {}

    trigger = hook_input.get("trigger", "auto")
    project_dir = os.environ.get("CLAUDE_PROJECT_DIR", "")

    if not project_dir:
        return 0

    # Gather state
    plan_info = find_active_plan(project_dir)
    decisions = extract_recent_decisions(project_dir)

    # Build state object
    state = {
        "trigger": trigger,
        "plan_path": plan_info["plan_path"] if plan_info else None,
        "plan_status": plan_info["status"] if plan_info else None,
        "current_task": plan_info.get("current_task") if plan_info else None,
        "decisions": decisions
    }

    # Save state for restoration
    save_state(state)

    # Append note to session log
    append_to_session_log(project_dir, trigger)

    # Print to stderr (PreCompact ignores stdout; stderr is shown to user)
    print(format_compaction_message(plan_info, decisions), file=sys.stderr)

    return 0


if __name__ == "__main__":
    try:
        sys.exit(main())
    except Exception:
        # Fail open — never block Claude due to a hook bug
        sys.exit(0)

#!/usr/bin/env python3
"""
Post-Compact Context Restoration Hook

Fires after compaction (SessionStart with type="compact") to restore context.
Reads saved state from the session directory and prints it so Claude knows
where it left off.

Hook Event: SessionStart (matcher: "compact")
Returns: Exit code 0 (output to stdout)
"""

import json
import os
import sys
from pathlib import Path
from datetime import datetime

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

    # Use a hash of the project dir for the session subdir
    import hashlib
    project_hash = hashlib.md5(project_dir.encode()).hexdigest()[:8]
    session_dir = Path.home() / ".claude" / "sessions" / project_hash
    session_dir.mkdir(parents=True, exist_ok=True)
    return session_dir


def read_pre_compact_state() -> dict | None:
    """Read and delete the pre-compact state file."""
    session_dir = get_session_dir()
    state_file = session_dir / "pre-compact-state.json"

    if not state_file.exists():
        return None

    try:
        state = json.loads(state_file.read_text())
        state_file.unlink()  # Clean up after restore
        return state
    except (json.JSONDecodeError, IOError):
        return None


def find_active_plan(project_dir: str) -> dict | None:
    """Find the most recent plan file and extract its status."""
    plans_dir = Path(project_dir) / "quality_reports" / "plans"
    if not plans_dir.exists():
        return None

    # Get most recent plan file
    plan_files = sorted(plans_dir.glob("*.md"), key=lambda f: f.stat().st_mtime, reverse=True)
    if not plan_files:
        return None

    latest_plan = plan_files[0]
    content = latest_plan.read_text()

    # Extract status from plan content
    status = "unknown"
    if "COMPLETED" in content.upper():
        status = "completed"
    elif "APPROVED" in content.upper():
        status = "in_progress"
    elif "DRAFT" in content.upper():
        status = "draft"

    # Extract current task if present
    current_task = None
    for line in content.split("\n"):
        if "- [ ]" in line:  # First unchecked task
            current_task = line.replace("- [ ]", "").strip()
            break

    return {
        "plan_path": str(latest_plan),
        "plan_name": latest_plan.name,
        "status": status,
        "current_task": current_task
    }


def find_recent_session_log(project_dir: str) -> dict | None:
    """Find the most recent session log."""
    logs_dir = Path(project_dir) / "quality_reports" / "session_logs"
    if not logs_dir.exists():
        return None

    log_files = sorted(logs_dir.glob("*.md"), key=lambda f: f.stat().st_mtime, reverse=True)
    if not log_files:
        return None

    return {
        "log_path": str(log_files[0]),
        "log_name": log_files[0].name
    }


def format_restoration_message(
    pre_compact_state: dict | None,
    plan_info: dict | None,
    session_log: dict | None
) -> str:
    """Format the context restoration message for Claude."""
    lines = []
    lines.append(f"\n{CYAN}[Context Restored After Compaction]{NC}")
    lines.append("")

    if pre_compact_state:
        lines.append(f"{GREEN}Pre-Compaction State:{NC}")
        if pre_compact_state.get("plan_path"):
            lines.append(f"  Plan: {pre_compact_state['plan_path']}")
        if pre_compact_state.get("current_task"):
            lines.append(f"  Task: {pre_compact_state['current_task']}")
        if pre_compact_state.get("decisions"):
            lines.append("  Recent decisions:")
            for decision in pre_compact_state["decisions"][-3:]:
                lines.append(f"    - {decision}")
        lines.append("")

    if plan_info:
        lines.append(f"{GREEN}Active Plan:{NC}")
        lines.append(f"  File: {plan_info['plan_name']}")
        lines.append(f"  Status: {plan_info['status']}")
        if plan_info.get("current_task"):
            lines.append(f"  Next task: {plan_info['current_task']}")
        lines.append("")

    if session_log:
        lines.append(f"{GREEN}Session Log:{NC}")
        lines.append(f"  {session_log['log_name']}")
        lines.append("")

    lines.append(f"{YELLOW}Recovery Actions:{NC}")
    lines.append("  1. Read the active plan to understand current objectives")
    lines.append("  2. Check git status/diff for uncommitted changes")
    lines.append("  3. Continue from where you left off")
    lines.append("")

    return "\n".join(lines)


def main() -> int:
    """Main hook entry point."""
    # Read hook input (not strictly needed but good practice)
    try:
        hook_input = json.load(sys.stdin)
    except (json.JSONDecodeError, IOError):
        hook_input = {}

    # Only run on compact sessions
    session_type = hook_input.get("type", "")
    if session_type != "compact":
        return 0

    project_dir = os.environ.get("CLAUDE_PROJECT_DIR", "")
    if not project_dir:
        return 0

    # Gather context
    pre_compact_state = read_pre_compact_state()
    plan_info = find_active_plan(project_dir)
    session_log = find_recent_session_log(project_dir)

    # If we have any context to restore, print it
    if pre_compact_state or plan_info or session_log:
        message = format_restoration_message(pre_compact_state, plan_info, session_log)
        print(message)

    return 0


if __name__ == "__main__":
    sys.exit(main())

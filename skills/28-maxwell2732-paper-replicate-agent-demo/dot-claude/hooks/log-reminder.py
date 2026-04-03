#!/usr/bin/env python3
"""
Session Log Reminder Hook for Claude Code

A Stop hook that tracks how many responses have passed since the session
log was last updated. After a threshold, it blocks Claude from stopping
and reminds it to update the session log.

Adapted from: https://gist.github.com/michaelewens/9a1bc5a97f3f9bbb79453e5b682df462

Usage (in .claude/settings.json):
    "Stop": [{ "hooks": [{ "type": "command", "command": "python3 \"$CLAUDE_PROJECT_DIR\"/.claude/hooks/log-reminder.py" }] }]
"""

import json
import sys
import hashlib
from pathlib import Path
from datetime import datetime

THRESHOLD = 15
STATE_DIR = Path("/tmp/claude-log-reminder")


def get_project_dir():
    """Get project directory from stdin JSON or environment."""
    try:
        hook_input = json.load(sys.stdin)
    except (json.JSONDecodeError, EOFError):
        hook_input = {}

    # If stop_hook_active, Claude is already continuing from a previous
    # Stop hook block — let it stop this time to avoid infinite loops.
    if hook_input.get("stop_hook_active", False):
        sys.exit(0)

    return hook_input.get("cwd", ""), hook_input


def get_state_path(project_dir: str) -> Path:
    """Return a project-keyed state file path."""
    project_hash = hashlib.md5(project_dir.encode()).hexdigest()[:12]
    return STATE_DIR / f"{project_hash}.json"


def load_state(state_path: Path) -> dict:
    """Load persisted state, or return defaults."""
    try:
        return json.loads(state_path.read_text())
    except (FileNotFoundError, json.JSONDecodeError):
        return {"counter": 0, "last_mtime": 0.0, "reminded": False, "no_log_reminded": False}


def save_state(state_path: Path, state: dict):
    """Persist state to disk."""
    STATE_DIR.mkdir(parents=True, exist_ok=True)
    state_path.write_text(json.dumps(state))


def find_latest_log(project_dir: str) -> tuple[Path | None, float]:
    """Find the most recently modified .md file in session_logs/."""
    log_dir = Path(project_dir) / "quality_reports" / "session_logs"
    if not log_dir.is_dir():
        return None, 0.0

    md_files = list(log_dir.glob("*.md"))
    if not md_files:
        return None, 0.0

    latest = max(md_files, key=lambda f: f.stat().st_mtime)
    return latest, latest.stat().st_mtime


def main():
    project_dir, hook_input = get_project_dir()
    if not project_dir:
        sys.exit(0)

    state_path = get_state_path(project_dir)
    state = load_state(state_path)

    latest_log, current_mtime = find_latest_log(project_dir)
    today = datetime.now().strftime("%Y-%m-%d")

    # Case 1: No session log exists at all — remind once, then let Claude work
    if latest_log is None:
        if not state.get("no_log_reminded", False):
            state["no_log_reminded"] = True
            save_state(state_path, state)
            output = {
                "decision": "block",
                "reason": (
                    f"No session log exists yet. Create one at "
                    f"quality_reports/session_logs/{today}_description.md "
                    f"before continuing. Include the current goal and key context."
                ),
            }
            json.dump(output, sys.stdout)
        # Already reminded — let Claude proceed (it will create the log)
        sys.exit(0)

    # Case 2: Log was updated since last check — reset everything
    if current_mtime != state["last_mtime"]:
        state = {"counter": 0, "last_mtime": current_mtime, "reminded": False, "no_log_reminded": False}
        save_state(state_path, state)
        sys.exit(0)

    # Case 3: Log not updated — increment counter
    state["counter"] += 1

    if state["counter"] >= THRESHOLD and not state["reminded"]:
        state["reminded"] = True
        save_state(state_path, state)
        output = {
            "decision": "block",
            "reason": (
                f"SESSION LOG REMINDER: {state['counter']} responses without "
                f"updating the session log. Append your recent progress to "
                f"{latest_log.name}."
            ),
        }
        json.dump(output, sys.stdout)
        sys.exit(0)

    save_state(state_path, state)
    sys.exit(0)


if __name__ == "__main__":
    try:
        main()
    except Exception:
        # Fail open — never block Claude due to a hook bug
        sys.exit(0)

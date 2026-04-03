#!/usr/bin/env python3
"""
Context Usage Monitor Hook

Monitors context usage and provides progressive warnings:
- At 40%, 55%, 65%: Suggest /learn for skill extraction
- At 80%: Info-level warning (auto-compact approaching)
- At 90%: Caution-level warning (complete current task with full quality)

Hook Event: PostToolUse (on common tools)
Throttles to 60-second intervals when below warning threshold.

Note: Since direct context % isn't available, this uses a heuristic based on
conversation file size and tool call count.
"""

from __future__ import annotations

import json
import os
import sys
import time
from pathlib import Path
from datetime import datetime

# Colors for terminal output
CYAN = "\033[0;36m"
GREEN = "\033[0;32m"
YELLOW = "\033[0;33m"
RED = "\033[0;31m"
MAGENTA = "\033[0;35m"
NC = "\033[0m"  # No color

# Thresholds (effective percentage, where 100% = auto-compact)
LEARN_THRESHOLDS = [40, 55, 65]
THRESHOLD_WARN = 80
THRESHOLD_CRITICAL = 90

# Throttle interval in seconds (skip checks if below threshold and recent check)
THROTTLE_INTERVAL = 60


def get_session_dir() -> Path:
    """Get the session directory for storing cache files."""
    project_dir = os.environ.get("CLAUDE_PROJECT_DIR", "")
    if not project_dir:
        return Path.home() / ".claude" / "sessions" / "default"

    import hashlib
    project_hash = hashlib.md5(project_dir.encode()).hexdigest()[:8]
    session_dir = Path.home() / ".claude" / "sessions" / project_hash
    session_dir.mkdir(parents=True, exist_ok=True)
    return session_dir


def read_cache() -> dict:
    """Read the context monitor cache."""
    cache_file = get_session_dir() / "context-monitor-cache.json"
    if not cache_file.exists():
        return {}
    try:
        return json.loads(cache_file.read_text())
    except (json.JSONDecodeError, IOError):
        return {}


def save_cache(data: dict) -> None:
    """Save the context monitor cache."""
    cache_file = get_session_dir() / "context-monitor-cache.json"
    try:
        cache_file.write_text(json.dumps(data, indent=2))
    except IOError:
        pass


def estimate_context_percentage() -> float:
    """
    Estimate context usage as a percentage.

    This is a heuristic since we don't have direct access to Claude's context
    window. We use the tool call count as a proxy.

    Returns a value from 0-100 representing estimated context usage.
    """
    cache = read_cache()

    # Increment tool call counter
    tool_calls = cache.get("tool_calls", 0) + 1
    cache["tool_calls"] = tool_calls
    save_cache(cache)

    # Heuristic: assume ~200 tool calls fills context (very rough estimate)
    # This is intentionally conservative to trigger warnings early
    MAX_TOOL_CALLS = 150

    percentage = min((tool_calls / MAX_TOOL_CALLS) * 100, 100)
    return percentage


def is_throttled(percentage: float) -> bool:
    """Check if we should skip this check due to throttling."""
    cache = read_cache()
    last_check = cache.get("last_check_time", 0)
    now = time.time()

    # If below warning threshold and checked recently, skip
    if percentage < THRESHOLD_WARN and (now - last_check) < THROTTLE_INTERVAL:
        return True

    # Update last check time
    cache["last_check_time"] = now
    save_cache(cache)
    return False


def get_shown_thresholds() -> dict:
    """Get which thresholds have already been shown in this session."""
    cache = read_cache()
    return {
        "learn": cache.get("shown_learn", []),
        "warn_80": cache.get("shown_warn_80", False),
        "warn_90": cache.get("shown_warn_90", False)
    }


def mark_threshold_shown(threshold_type: str, value: int | bool = True) -> None:
    """Mark a threshold as shown."""
    cache = read_cache()
    if threshold_type == "learn":
        shown = cache.get("shown_learn", [])
        if value not in shown:
            shown.append(value)
        cache["shown_learn"] = shown
    else:
        cache[f"shown_{threshold_type}"] = value
    save_cache(cache)


def format_learn_reminder(percentage: float, threshold: int) -> str:
    """Format a /learn skill reminder."""
    return f"""
{CYAN}💡 Context at {percentage:.0f}%{NC}

Non-obvious discovery or reusable workflow?
→ Consider using {GREEN}/learn{NC} to capture it as a skill before context compacts.

Skills are saved to {MAGENTA}.claude/skills/{NC} and persist across sessions.
"""


def format_warn_80(percentage: float) -> str:
    """Format the 80% warning message."""
    return f"""
{YELLOW}💡 Context at {percentage:.0f}%{NC}

Auto-compact will handle context management automatically.
No rush — just be aware that context will be summarized soon.
"""


def format_warn_90(percentage: float) -> str:
    """Format the 90% critical warning message."""
    return f"""
{RED}⚠️  Context at {percentage:.0f}% — auto-compact approaching{NC}

Complete current task with full quality. Do NOT cut corners or skip verification.
No context is lost — auto-compact preserves important information.

{YELLOW}Actions to consider:{NC}
  • Save key decisions to the session log
  • Ensure current plan status is updated
  • Mark completed todos as done
"""


def run_context_monitor() -> int:
    """Main monitoring logic."""
    # Read hook input
    try:
        hook_input = json.load(sys.stdin)
    except (json.JSONDecodeError, IOError):
        hook_input = {}

    # Estimate current context usage
    percentage = estimate_context_percentage()

    # Check throttling
    if is_throttled(percentage):
        return 0

    shown = get_shown_thresholds()

    # Check /learn thresholds (40%, 55%, 65%)
    for threshold in LEARN_THRESHOLDS:
        if percentage >= threshold and threshold not in shown["learn"]:
            print(format_learn_reminder(percentage, threshold))
            mark_threshold_shown("learn", threshold)
            return 0  # Only show one message at a time

    # Check 90% threshold (critical)
    if percentage >= THRESHOLD_CRITICAL and not shown["warn_90"]:
        print(format_warn_90(percentage))
        mark_threshold_shown("warn_90", True)
        return 0  # Non-blocking warning (exit 2 would block Claude)

    # Check 80% threshold (info)
    if percentage >= THRESHOLD_WARN and not shown["warn_80"]:
        print(format_warn_80(percentage))
        mark_threshold_shown("warn_80", True)
        return 0

    return 0


def main() -> int:
    """Main entry point."""
    return run_context_monitor()


if __name__ == "__main__":
    try:
        sys.exit(main())
    except Exception:
        # Fail open — never block Claude due to a hook bug
        sys.exit(0)

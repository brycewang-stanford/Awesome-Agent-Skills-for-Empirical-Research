#!/usr/bin/env python3
"""
Verification Reminder Hook

Non-blocking reminder that fires on Write/Edit to academic files (.tex, .qmd, .R)
to remind about compiling/rendering before marking a task as done.

Hook Event: PostToolUse (matcher: "Write|Edit")
Returns: Exit code 0 (non-blocking, reminder visible but doesn't stop work)

Skips:
- Configuration files (.json, .yaml, .toml, etc.)
- Documentation files (.md, .txt, README)
- Test files and generated files
"""

from __future__ import annotations

import json
import os
import sys
import time
from pathlib import Path

# Colors for terminal output
CYAN = "\033[0;36m"
GREEN = "\033[0;32m"
YELLOW = "\033[0;33m"
NC = "\033[0m"  # No color

# Files that need verification
VERIFY_EXTENSIONS = {
    ".tex": "compile with /compile-latex",
    ".qmd": "render with quarto render",
    ".R": "run to verify output"
}

# Files to skip
SKIP_EXTENSIONS = [
    ".md", ".txt", ".rst",
    ".json", ".yaml", ".yml", ".toml", ".ini", ".cfg",
    ".lock", ".env", ".gitignore",
    ".svg", ".png", ".jpg", ".pdf",
    ".bib", ".cls", ".sty"
]

# Directories to skip
SKIP_DIRS = [
    "/docs/",
    "/templates/",
    "/quality_reports/",
    "/.claude/",
    "/node_modules/",
    "/build/",
    "/dist/"
]


def get_session_dir() -> Path:
    """Get the session directory for caching."""
    project_dir = os.environ.get("CLAUDE_PROJECT_DIR", "")
    if not project_dir:
        return Path.home() / ".claude" / "sessions" / "default"

    import hashlib
    project_hash = hashlib.md5(project_dir.encode()).hexdigest()[:8]
    session_dir = Path.home() / ".claude" / "sessions" / project_hash
    session_dir.mkdir(parents=True, exist_ok=True)
    return session_dir


def should_skip(file_path: str) -> bool:
    """Check if this file should skip verification reminder."""
    path = Path(file_path)

    # Skip by extension
    if path.suffix.lower() in SKIP_EXTENSIONS:
        return True

    # Skip by directory
    for skip_dir in SKIP_DIRS:
        if skip_dir in file_path:
            return True

    # Skip test files
    name = path.name.lower()
    if name.startswith("test_") or name.endswith("_test.py"):
        return True

    return False


def needs_verification(file_path: str) -> tuple[bool, str]:
    """Check if this file needs verification and return the action."""
    path = Path(file_path)
    suffix = path.suffix.lower()

    if suffix in VERIFY_EXTENSIONS:
        return True, VERIFY_EXTENSIONS[suffix]

    return False, ""


def was_recently_reminded(file_path: str) -> bool:
    """Check if we already reminded about this file recently (within 60s)."""
    cache_file = get_session_dir() / "verify-reminder-cache.json"

    try:
        if cache_file.exists():
            cache = json.loads(cache_file.read_text())
        else:
            cache = {}
    except (json.JSONDecodeError, IOError):
        cache = {}

    last_reminder = cache.get(file_path, 0)
    now = time.time()

    # Update cache
    cache[file_path] = now

    # Clean old entries (older than 5 minutes)
    cache = {k: v for k, v in cache.items() if now - v < 300}

    try:
        cache_file.write_text(json.dumps(cache))
    except IOError:
        pass

    # Was reminded in last 60 seconds?
    return (now - last_reminder) < 60


def format_reminder(file_path: str, action: str) -> str:
    """Format the verification reminder."""
    filename = Path(file_path).name
    return f"""
{CYAN}📋 Verification reminder:{NC} {filename}
   → {GREEN}{action}{NC} before marking task complete
"""


def main() -> int:
    """Main hook entry point."""
    # Read hook input
    try:
        hook_input = json.load(sys.stdin)
    except (json.JSONDecodeError, IOError):
        return 0

    tool_name = hook_input.get("tool_name", "")
    tool_input = hook_input.get("tool_input", {})
    file_path = tool_input.get("file_path", "")

    if not file_path:
        return 0

    # Skip if this file doesn't need verification
    if should_skip(file_path):
        return 0

    # Check if this file type needs verification
    needs_verify, action = needs_verification(file_path)
    if not needs_verify:
        return 0

    # Skip if we recently reminded about this file
    if was_recently_reminded(file_path):
        return 0

    # Show the reminder
    print(format_reminder(file_path, action))

    return 0  # Non-blocking


if __name__ == "__main__":
    try:
        sys.exit(main())
    except Exception:
        # Fail open — never block Claude due to a hook bug
        sys.exit(0)

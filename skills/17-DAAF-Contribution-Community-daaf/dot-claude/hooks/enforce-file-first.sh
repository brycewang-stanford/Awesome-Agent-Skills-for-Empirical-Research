#!/bin/bash
# enforce-file-first.sh — PreToolUse hook that blocks direct python execution
#
# Enforces the file-first execution protocol: all Python scripts must be
# executed via run_with_capture.sh, which appends an execution log to the
# script file as an immutable audit artifact. Direct `python` or `python3`
# invocations bypass this audit trail and are blocked.
#
# Exception: Framework utility scripts in /daaf/scripts/ (e.g.,
# compare_execution_logs.py, normalize_project_dir.py) are standalone CLI
# tools, not pipeline scripts. They produce stdout output, not audit
# artifacts, and may be run directly.
#
# Exit codes (Claude Code PreToolUse convention):
#   0 = allow the command to proceed
#   2 = BLOCK the command (stderr message shown to the model)
#
# Scope: Registered in agent frontmatter for coding agents only
#   (research-executor, code-reviewer, debugger, data-ingest)
#   NOT registered project-wide — non-coding agents and the orchestrator
#   are not subject to this constraint.
#
# Hook event: PreToolUse (matcher: "Bash")

# Fail CLOSED: if anything unexpected goes wrong, block the command.
# This is an audit-trail enforcement hook — ambiguity must not silently allow bypass.
trap 'echo "BLOCKED by enforce-file-first hook: unexpected error in file-first check" >&2; exit 2' ERR

# --- Dependency check (fail-closed) ---
# jq is required for JSON parsing. If missing, block rather than silently allowing.
if ! command -v jq &>/dev/null; then
    echo "BLOCKED by enforce-file-first hook: jq is not installed (required for hook)" >&2
    exit 2
fi

INPUT=$(cat)

# --- Fail-closed on empty input ---
# Claude Code should always provide JSON. Empty stdin is abnormal.
if [[ -z "$INPUT" ]]; then
    echo "BLOCKED by enforce-file-first hook: received empty input (expected JSON)" >&2
    exit 2
fi

# Only inspect Bash tool calls
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty' 2>/dev/null) || TOOL_NAME=""
if [[ "$TOOL_NAME" != "Bash" ]]; then
    exit 0
fi

# Extract the command string
CMD=$(echo "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null) || CMD=""
if [[ -z "$CMD" ]]; then
    exit 0
fi

# ---------------------------------------------------------------------------
# Normalize the command for reliable pattern matching:
#   1. Replace newlines with semicolons (newlines are command separators in bash,
#      but tr would merge them with spaces, hiding multi-command inputs)
#   2. Collapse remaining whitespace to single spaces
# ---------------------------------------------------------------------------
NORM_CMD=$(echo "$CMD" | tr '\n' ';' | tr -s '[:space:]' ' ')

# ---------------------------------------------------------------------------
# WHITELIST: Framework utility scripts in /daaf/scripts/
#
# These are standalone CLI tools (not pipeline scripts) that produce stdout
# output rather than audit artifacts. They may be run directly by any agent.
#
# The whitelist checks for python/python3 invocations that target a .py file
# within the /daaf/scripts/ directory (the framework root, NOT a research
# project's scripts/ directory).
# ---------------------------------------------------------------------------
DAAF_ROOT="${CLAUDE_PROJECT_DIR:-/daaf}"
if echo "$NORM_CMD" | grep -qE "python3?[.0-9]*\s+${DAAF_ROOT}/scripts/[A-Za-z0-9_-]+\.py"; then
    exit 0
fi

# ---------------------------------------------------------------------------
# Detect python/python3 invoked as a command. The regex accounts for:
#
# Command boundaries (where a new command can begin):
#   ^          — start of input
#   && || ; |  — shell chain/pipe operators
#
# Command prefixes (wrappers that still execute the next argument):
#   env, exec, command, eval, nohup, nice, time, strace
#   VAR=value  — environment variable assignment prefix (PYTHONPATH=/x python ...)
#
# Python interpreter names:
#   python, python3            — standard names
#   python3.11, python3.12     — versioned interpreters (python3?[.0-9]*)
#   /usr/bin/python3           — absolute path variants
#
# BLOCKS:
#   python script.py                      — direct execution, no audit trail
#   python3 -c "code"                     — interactive one-liner
#   python3.11 script.py                  — versioned interpreter
#   env python script.py                  — env wrapper
#   exec python3 script.py               — exec builtin
#   PYTHONPATH=/foo python script.py      — env var prefix
#   /usr/bin/python3 script.py            — absolute path
#
# ALLOWS:
#   bash .../run_with_capture.sh script.py  — correct file-first pattern
#   python /daaf/scripts/utility.py         — whitelisted framework utility
#   pip install polars                      — package management
#   marimo run notebook.py                  — marimo runtime
#   grep python file.txt                   — python as argument, not command
#   ls /usr/lib/python3/dist-packages      — python in path argument
# ---------------------------------------------------------------------------

# Pattern components (composed for readability):
#   BOUNDARY: start of command or after chain operators
#   PREFIX:   optional command wrappers and env var assignments
#   PYTHON:   interpreter name (bare, versioned, or absolute path)
#   TRAIL:    followed by space, semicolon, or end of string

PATTERN='(^|&&|\|\||;|\|)\s*'               # BOUNDARY
PATTERN+='([A-Za-z_][A-Za-z0-9_]*=[^ ]+ )*'  # PREFIX: zero or more VAR=val assignments
PATTERN+='(env|exec|command|eval|nohup|nice|time|strace)?\s*'  # PREFIX: optional wrapper
PATTERN+='(python3?[.0-9]*|[^ ]*\/python3?[.0-9]*)'           # PYTHON interpreter
PATTERN+='(\s|;|$)'                          # TRAIL

if echo "$NORM_CMD" | grep -qE "$PATTERN"; then
    cat >&2 <<'EOF'
BLOCKED by enforce-file-first hook: Direct python execution violates the file-first protocol.

All Python scripts must be executed via run_with_capture.sh:
  bash {BASE_DIR}/scripts/run_with_capture.sh {PROJECT_DIR}/scripts/{script}.py

This ensures execution output is captured and appended to the script file
as an immutable audit trail. See SCRIPT_EXECUTION_REFERENCE.md for details.

Exception: Framework utility scripts in /daaf/scripts/ may be run directly
(e.g., python /daaf/scripts/compare_execution_logs.py ...).

If you need to write a quick check, write it as a script file first,
then execute it through the capture wrapper.
EOF
    exit 2
fi

# ---------------------------------------------------------------------------
# All checks passed — allow the command
# ---------------------------------------------------------------------------
exit 0

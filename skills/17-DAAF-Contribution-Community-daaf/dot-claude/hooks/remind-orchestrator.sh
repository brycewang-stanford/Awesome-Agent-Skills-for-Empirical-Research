#!/bin/bash
# remind-orchestrator.sh — Remind main-session LLM to load daaf-orchestrator
#
# Hook: UserPromptSubmit (main session only — subagents never trigger this)
#
# On each user message, checks whether the daaf-orchestrator skill has been
# loaded this session. If not, injects a reminder via stdout that appears as
# <user-prompt-submit-hook> text in the LLM's context.
#
# Additionally, on the user's FIRST EVER session (detected via activity.log
# line count), injects a first-run transparency statement that Claude must
# present before proceeding with normal workflow. The transparency content
# lives in first-run-transparency.txt alongside this script.
#
# Detection logic:
#   activity.log gets a line appended at every SessionStart. When this hook
#   fires on the first UserPromptSubmit of the first-ever session, activity.log
#   has exactly 1 line (from the SessionStart that just fired). On subsequent
#   sessions it has 2+. So: line_count <= 1 means first session.
#
# The orchestrator-loaded flag file is set by flag-orchestrator-loaded.sh
# (PostToolUse on Skill).
#
# Exit codes:
#   0 = always (never block user messages)

INPUT=$(cat)
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // "default"' 2>/dev/null) || SESSION_ID="default"
FLAG="/tmp/claude-daaf-orchestrator-${SESSION_ID}"

if [[ ! -f "$FLAG" ]]; then
    # Always remind to load the orchestrator
    echo "You are interacting with a human user. You MUST IMMEDIATELY invoke the daaf-orchestrator skill (Skill tool with skill: \"daaf-orchestrator\") BEFORE doing any other work."

    # Check if this is the user's first-ever session
    ACTIVITY_LOG="${CLAUDE_PROJECT_DIR:-.}/.claude/logs/activity.log"
    LINE_COUNT=0
    if [[ -f "$ACTIVITY_LOG" ]]; then
        LINE_COUNT=$(wc -l < "$ACTIVITY_LOG" 2>/dev/null || echo "0")
        # Trim whitespace (macOS wc pads with spaces)
        LINE_COUNT=$(echo "$LINE_COUNT" | tr -d '[:space:]')
    fi

    if [[ "$LINE_COUNT" -le 1 ]]; then
        # First session ever — inject transparency statement
        HOOK_DIR="$(cd "$(dirname "$0")" && pwd)"
        TRANSPARENCY_FILE="${HOOK_DIR}/first-run-transparency.txt"
        if [[ -f "$TRANSPARENCY_FILE" ]]; then
            echo ""
            cat "$TRANSPARENCY_FILE"
        fi
    fi
fi

exit 0

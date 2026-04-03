#!/bin/bash
# flag-orchestrator-loaded.sh — Set flag when daaf-orchestrator skill loads
#
# Hook: PostToolUse (matcher: "Skill")
#
# After the Skill tool completes, checks if the skill was daaf-orchestrator.
# If so, writes a session-scoped flag file that remind-orchestrator.sh checks
# to stop issuing reminders.
#
# Exit codes:
#   0 = always (never block tool execution)

INPUT=$(cat)
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // "default"' 2>/dev/null) || SESSION_ID="default"
SKILL_NAME=$(echo "$INPUT" | jq -r '.tool_input.skill // empty' 2>/dev/null) || SKILL_NAME=""

if [[ "$SKILL_NAME" == "daaf-orchestrator" ]]; then
    touch "/tmp/claude-daaf-orchestrator-${SESSION_ID}"
fi

exit 0

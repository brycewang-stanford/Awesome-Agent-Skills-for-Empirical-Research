#!/bin/bash
# subagent-registry.sh — SubagentStop hook that records subagent completion metadata
#
# Appends one JSON line per subagent completion to a per-session registry file.
# The registry is consumed by archive-session.sh at session end to:
#   1. Copy subagent transcripts into the session archive
#   2. Add a "Subagent Activity" summary section to the Markdown archive
#
# The registry file is per-session (keyed by SESSION_ID) to prevent
# cross-contamination when multiple sessions run concurrently.
#
# Registry location: .claude/logs/subagent-registry-${SESSION_ID}.jsonl
# Cleaned up by: archive-session.sh after successful archiving
#
# Fields captured:
#   - timestamp:        when the subagent completed
#   - session_id:       parent session ID
#   - agent_type:       subagent type (e.g., "research-executor", "code-reviewer")
#   - agent_id:         unique subagent identifier
#   - transcript_path:  path to the subagent's JSONL transcript
#   - last_message:     final assistant message (truncated to 500 chars)
#   - tool_uses:        number of tool calls the subagent made (from hook metadata)
#   - duration_ms:      subagent execution duration in milliseconds (from hook metadata)
#
# Exit codes:
#   0 = always (observability hook, must never block)
#
# Hook event: SubagentStop (matcher: "")
# Registered in: .claude/settings.json

# Fail OPEN: this is observability, not a security gate
trap '' ERR

INPUT=$(cat)

# --- Parse fields from SubagentStop hook input ---
mapfile -t _fields < <(
    printf '%s' "$INPUT" | jq -r '
        (.session_id // "unknown"),
        (.agent_type // "unknown"),
        (.agent_id // "unknown"),
        (.agent_transcript_path // ""),
        ((.last_assistant_message // "")[0:500] | gsub("\n"; " ")),
        (.tool_uses // 0 | tostring),
        (.duration_ms // 0 | tostring)
    ' 2>/dev/null
)
SESSION_ID="${_fields[0]:-unknown}"
AGENT_TYPE="${_fields[1]:-unknown}"
AGENT_ID="${_fields[2]:-unknown}"
TRANSCRIPT="${_fields[3]:-}"
LAST_MSG="${_fields[4]:-}"
TOOL_USES="${_fields[5]:-0}"
DURATION_MS="${_fields[6]:-0}"
TIMESTAMP=$(date -u '+%Y-%m-%dT%H:%M:%SZ')

# --- Determine registry location ---
if [[ -n "${CLAUDE_PROJECT_DIR:-}" ]]; then
    LOG_DIR="$CLAUDE_PROJECT_DIR/.claude/logs"
else
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    LOG_DIR="$(dirname "$SCRIPT_DIR")/logs"
fi

mkdir -p "$LOG_DIR" 2>/dev/null

# Per-session registry file
REGISTRY_FILE="$LOG_DIR/subagent-registry-${SESSION_ID}.jsonl"

# --- Append registry entry ---
jq -n -c \
    --arg ts "$TIMESTAMP" \
    --arg sid "$SESSION_ID" \
    --arg atype "$AGENT_TYPE" \
    --arg aid "$AGENT_ID" \
    --arg tp "$TRANSCRIPT" \
    --arg msg "$LAST_MSG" \
    --argjson tools "$TOOL_USES" \
    --argjson dur "$DURATION_MS" \
    '{timestamp: $ts, session_id: $sid, agent_type: $atype, agent_id: $aid,
      transcript_path: $tp, last_message: $msg, tool_uses: $tools, duration_ms: $dur}' \
    >> "$REGISTRY_FILE" 2>/dev/null

exit 0

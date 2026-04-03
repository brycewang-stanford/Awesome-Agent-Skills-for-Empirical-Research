#!/bin/bash
# context-reporter.sh — Multi-event context utilization & timestamp hook
#
# Injects context window utilization and a current timestamp into Claude's
# conversation so the model can make informed decisions about delegation, state
# persistence, and session recovery (see CLAUDE.md utilization gates at
# 40%/60%/75% OR 150k/200k/250k tokens, whichever fires first).
#
# Registered events:
#   UserPromptSubmit  — stdout text → injected as <user-prompt-submit-hook>
#   PreToolUse        — JSON additionalContext → injected before tool executes
#
# Rate limiting:
#   Both events share a single 60-second injection gate (per session).
#   Whichever event fires first resets the timer for both. This prevents
#   redundant context injection across rapid tool calls and user messages.
#   The gate uses an epoch-timestamp cache file in /tmp.
#
# Performance:
#   Uses `tail -50` to read only the end of the transcript, avoiding full-file
#   parsing. The last usage entry is always near the end of the JSONL.
#
# Subagent support:
#   Subagents run with different session IDs, so the session-specific context
#   window cache (written by context-bar.sh statusline) won't exist for them.
#   The script falls back to the most recent cache from any session (typically
#   the parent orchestrator), ensuring subagents report utilization against
#   the correct context window size.
#
# Exit codes:
#   0 = success (stdout/JSON processed by Claude Code)
#   All error paths exit 0 to never block tool execution.

INPUT=$(cat)
HOOK_EVENT=$(echo "$INPUT" | jq -r '.hook_event_name // empty' 2>/dev/null) || HOOK_EVENT=""
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // "default"' 2>/dev/null) || SESSION_ID="default"
TRANSCRIPT_PATH=$(echo "$INPUT" | jq -r '.transcript_path // empty' 2>/dev/null) || TRANSCRIPT_PATH=""

# Rate-limit gate: epoch seconds of last injection (shared across all events, one per session)
LAST_INJECT_FILE="/tmp/claude-ctx-ts-${SESSION_ID}"
INJECT_INTERVAL=60  # seconds between injections

# Read context window size from shared cache (written by context-bar.sh statusline).
# For subagents (which have different session IDs), the session-specific cache won't
# exist. Fall back to the most recent cache from any session (typically the parent
# orchestrator), then to 200k as a last resort.
CTX_CACHE="/tmp/claude-ctx-window-${SESSION_ID}"
if [[ -f "$CTX_CACHE" ]]; then
    MAX_CONTEXT=$(cat "$CTX_CACHE" 2>/dev/null)
else
    LATEST_CTX=$(ls -t /tmp/claude-ctx-window-* 2>/dev/null | head -1)
    if [[ -n "$LATEST_CTX" ]]; then
        MAX_CONTEXT=$(cat "$LATEST_CTX" 2>/dev/null)
    fi
fi
MAX_CONTEXT=${MAX_CONTEXT:-200000}
MAX_K=$((MAX_CONTEXT / 1000))

# ---------------------------------------------------------------------------
# calculate: Parse the transcript's most recent usage data and format a
# utilization message with timestamp. Uses tail -50 to avoid parsing the
# entire JSONL file.
# Outputs a single line to stdout, or nothing if data is unavailable.
# ---------------------------------------------------------------------------
calculate() {
    local transcript="$1"
    [[ -z "$transcript" || ! -f "$transcript" ]] && return

    local tokens
    tokens=$(tail -50 "$transcript" 2>/dev/null | jq -s '
        [.[] | select(
            .message.usage and
            .isSidechain != true and
            .isApiErrorMessage != true
        )] | last |
        if . then
            (.message.usage.input_tokens // 0) +
            (.message.usage.cache_read_input_tokens // 0) +
            (.message.usage.cache_creation_input_tokens // 0)
        else 0 end
    ' 2>/dev/null) || tokens=0

    [[ "$tokens" -le 0 ]] && return

    local pct=$((tokens * 100 / MAX_CONTEXT))
    [[ $pct -gt 100 ]] && pct=100
    local used_k=$((tokens / 1000))

    # Dual-trigger thresholds: percentage OR absolute token count, whichever
    # fires first. Absolute counts cap effective session length on large context
    # windows (1M) where percentage thresholds would allow excessive token usage.
    # See CLAUDE.md § Context Quality Curve for the authoritative threshold table.
    local severity
    if   [[ $pct -ge 75 ]] || [[ $used_k -ge 250 ]]; then severity="CRITICAL"
    elif [[ $pct -ge 60 ]] || [[ $used_k -ge 200 ]]; then severity="HIGH"
    elif [[ $pct -ge 40 ]] || [[ $used_k -ge 150 ]]; then severity="ELEVATED"
    else                                                    severity="NOMINAL"
    fi

    local ts
    ts=$(date '+%Y-%m-%d %H:%M:%S %Z')

    echo "Context utilization [${severity}]: ${used_k}k / ${MAX_K}k tokens (${pct}%) | ${ts}"
}

# ---------------------------------------------------------------------------
# cache_model: Extract the model name from the transcript and cache it once
# per session. audit-log.sh reads this cache to include model in audit entries.
# ---------------------------------------------------------------------------
cache_model() {
    local transcript="$1"
    local cache="/tmp/claude-model-${SESSION_ID}"
    [[ -f "$cache" ]] && return  # Already cached
    [[ -z "$transcript" || ! -f "$transcript" ]] && return

    local model
    model=$(tail -50 "$transcript" 2>/dev/null | jq -r '
        select(.message.model) | .message.model
    ' 2>/dev/null | head -1)

    [[ -n "$model" ]] && echo "$model" > "$cache" 2>/dev/null
}

# ---------------------------------------------------------------------------
# Shared rate-limit check (used by both events)
# ---------------------------------------------------------------------------
cache_model "$TRANSCRIPT_PATH"

NOW=$(date +%s)
LAST_INJECT=0
[[ -f "$LAST_INJECT_FILE" ]] && LAST_INJECT=$(cat "$LAST_INJECT_FILE" 2>/dev/null)

if [[ $((NOW - LAST_INJECT)) -lt $INJECT_INTERVAL ]]; then
    # Interval not elapsed — skip injection, don't block
    exit 0
fi

# Interval elapsed — calculate and emit
MSG=$(calculate "$TRANSCRIPT_PATH")
[[ -z "$MSG" ]] && exit 0

# Update the shared timestamp gate
echo "$NOW" > "$LAST_INJECT_FILE" 2>/dev/null

# ---------------------------------------------------------------------------
# Event dispatch (format differs per event, but both share the gate above)
# ---------------------------------------------------------------------------
case "$HOOK_EVENT" in

    UserPromptSubmit)
        # stdout → injected into Claude's context as <user-prompt-submit-hook>
        echo "$MSG"
        ;;

    PreToolUse)
        # JSON additionalContext → injected as <system-reminder> before tool executes
        jq -n --arg ctx "$MSG" '{
            hookSpecificOutput: {
                hookEventName: "PreToolUse",
                additionalContext: $ctx
            }
        }'
        ;;

    *)
        # Unknown event — do nothing, don't block
        ;;
esac

exit 0

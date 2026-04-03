#!/bin/bash
# enforce-foreground-agents.sh
# Prevents agents from being launched in the background.
# Background agents cannot prompt for user permissions, which causes
# tool calls to silently fail or be auto-denied. This hook ensures
# all agents run in the foreground where permission prompts work.
#
# Hook type: PreToolUse (matcher: Agent)
# Decision: deny if run_in_background is true
trap 'jq -n "{\"hookSpecificOutput\":{\"hookEventName\":\"PreToolUse\",\"permissionDecision\":\"deny\",\"permissionDecisionReason\":\"enforce-foreground-agents hook encountered an unexpected error\"}}" 2>/dev/null; exit 0' ERR

INPUT=$(cat)

RUN_IN_BG=$(echo "$INPUT" | jq -r '.tool_input.run_in_background // empty' 2>/dev/null) || RUN_IN_BG=""

if [ "$RUN_IN_BG" = "true" ]; then
  jq -n '{
    "hookSpecificOutput": {
      "hookEventName": "PreToolUse",
      "permissionDecision": "deny",
      "permissionDecisionReason": "Background agents are not permitted. Background agents cannot prompt for user permissions, causing silent tool call failures. Remove run_in_background or set it to false."
    }
  }'
fi

exit 0

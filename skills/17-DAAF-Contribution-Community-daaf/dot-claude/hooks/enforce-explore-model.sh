#!/bin/bash
# enforce-explore-model.sh
# Prevents Explore-type subagents from being launched with the haiku model.
# Explore agents need frontier-tier reasoning for thorough codebase analysis.
#
# Hook type: PreToolUse (matcher: Task)
# Decision: deny if subagent_type=Explore AND model=haiku
trap 'jq -n "{\"hookSpecificOutput\":{\"hookEventName\":\"PreToolUse\",\"permissionDecision\":\"deny\",\"permissionDecisionReason\":\"enforce-explore-model hook encountered an unexpected error\"}}" 2>/dev/null; exit 0' ERR

INPUT=$(cat)
SUBAGENT_TYPE=$(echo "$INPUT" | jq -r '.tool_input.subagent_type // empty' 2>/dev/null) || SUBAGENT_TYPE=""

if [ "$SUBAGENT_TYPE" = "Explore" ]; then
  jq -n '{
    "hookSpecificOutput": {
      "hookEventName": "PreToolUse",
      "permissionDecision": "deny",
      "permissionDecisionReason": "Explore subagents are blocked in this project. Explore runs on Haiku, which lacks sufficient reasoning depth. Use subagent_type search-agent instead — it is a DAAF-native read-only agent that inherits the main model (Opus), has web access (WebSearch, WebFetch), and understands DAAF conventions."
    }
  }'
fi

exit 0

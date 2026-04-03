#!/bin/bash
# deny-claude-code-guide.sh
# Blocks the claude-code-guide built-in agent from being spawned.
# This is a built-in agent with an opaque system prompt that doesn't
# align with DAAF's transparency requirements.
#
# Hook type: PreToolUse (matcher: Agent, Task)
# Decision: deny if subagent_type=claude-code-guide
trap 'jq -n "{\"hookSpecificOutput\":{\"hookEventName\":\"PreToolUse\",\"permissionDecision\":\"deny\",\"permissionDecisionReason\":\"deny-claude-code-guide hook encountered an unexpected error\"}}" 2>/dev/null; exit 0' ERR

INPUT=$(cat)
SUBAGENT_TYPE=$(echo "$INPUT" | jq -r '.tool_input.subagent_type // empty' 2>/dev/null) || SUBAGENT_TYPE=""

if [ "$SUBAGENT_TYPE" = "claude-code-guide" ]; then
  jq -n '{
    "hookSpecificOutput": {
      "hookEventName": "PreToolUse",
      "permissionDecision": "deny",
      "permissionDecisionReason": "claude-code-guide is NOT permitted in this project. It runs on the Haiku model, which lacks the reasoning depth and nuance required for accurate Claude Code guidance. Instead, spawn a search-agent (subagent_type: search-agent) and instruct it to use WebFetch to browse the official Claude Code documentation at https://code.claude.com/docs/en/overview, navigating to and thoroughly reading the relevant pages for the question at hand. The search-agent inherits the main Opus model and has full access to WebSearch and WebFetch for retrieving documentation pages."
    }
  }'
fi

exit 0

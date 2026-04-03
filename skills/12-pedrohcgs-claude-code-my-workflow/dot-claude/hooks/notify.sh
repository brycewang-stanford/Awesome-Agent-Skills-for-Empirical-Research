#!/bin/bash
# Cross-platform desktop notification when Claude needs attention
# Triggers on: permission prompts, idle prompts, auth events
INPUT=$(cat)
MESSAGE=$(echo "$INPUT" | jq -r '.message // "Claude needs attention"')
TITLE=$(echo "$INPUT" | jq -r '.title // "Claude Code"')

case "$(uname -s)" in
  Darwin)
    # Escape double quotes in message/title for osascript
    MESSAGE="${MESSAGE//\"/\\\"}"
    TITLE="${TITLE//\"/\\\"}"
    osascript -e "display notification \"$MESSAGE\" with title \"$TITLE\"" 2>/dev/null
    ;;
  Linux)
    if command -v notify-send &>/dev/null; then
      notify-send "$TITLE" "$MESSAGE" 2>/dev/null
    else
      echo "[$TITLE] $MESSAGE" >&2
    fi
    ;;
  *)
    echo "[$TITLE] $MESSAGE" >&2
    ;;
esac
exit 0

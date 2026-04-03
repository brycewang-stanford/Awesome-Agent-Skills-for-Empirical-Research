#!/bin/bash
# Claude Code Session Archiver
# Archives complete session transcripts on session end
#
# This hook reads the full JSONL transcript (which includes ALL assistant
# responses, tool calls, and results) and converts it to readable Markdown.
#
# Performance: Uses a single jq invocation per JSONL file. The jq program
# processes each top-level JSON object in the JSONL stream independently,
# converting the entire transcript in one process spawn.  Registry entries
# are parsed with one jq call per entry (mapfile), not one per field.
#
# Subagent archiving: If a subagent registry exists for this session
# (populated by subagent-registry.sh SubagentStop hook), subagent transcripts
# are copied into the archive alongside the orchestrator transcript, and a
# summary section is appended to the Markdown archive.
#
# Archive naming convention:
#   {date}_{time}_{session-short}_orchestrator.jsonl   — main session transcript
#   {date}_{time}_{session-short}_orchestrator.md      — human-readable rendering
#   {date}_{time}_{session-short}_subagent_{agent-id-short}.jsonl — subagent transcripts
#   {date}_{time}_{session-short}_subagent_{agent-id-short}.md   — subagent human-readable rendering

# Fail OPEN: archival is observability-only, not a security gate.
# A malformed JSONL line should produce a gap in the archive, not kill it entirely.
trap '' ERR

# Read JSON input from stdin
INPUT=$(cat)

# Extract session info — single jq call for all 4 fields
mapfile -t _meta < <(
    printf '%s' "$INPUT" | jq -r '
        (.session_id // "unknown"),
        (.transcript_path // ""),
        (.cwd // "unknown"),
        (.reason // "unknown")
    ' 2>/dev/null
)
SESSION_ID="${_meta[0]:-unknown}"
TRANSCRIPT_PATH="${_meta[1]:-}"
CWD="${_meta[2]:-unknown}"
REASON="${_meta[3]:-unknown}"

# Get project directory
PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
ARCHIVE_DIR="$PROJECT_DIR/.claude/logs/sessions"
mkdir -p "$ARCHIVE_DIR"

# Timestamp for archive
TIMESTAMP=$(date '+%Y-%m-%d_%H-%M-%S')
SESSION_SHORT="${SESSION_ID:0:8}"

# Archive filename stem — orchestrator role suffix
STEM="${TIMESTAMP}_${SESSION_SHORT}_orchestrator"

# Extract provenance metadata before archiving
DAAF_VERSION=$(git -C "$PROJECT_DIR" describe --always --dirty 2>/dev/null || echo "unknown")
MODEL="unknown"
if [ -n "$TRANSCRIPT_PATH" ] && [ -f "$TRANSCRIPT_PATH" ]; then
    MODEL=$(jq -r 'select(.message.model) | .message.model' "$TRANSCRIPT_PATH" 2>/dev/null | head -1)
    [ -z "$MODEL" ] && MODEL="unknown"
fi

# Archive paths
JSONL_ARCHIVE="$ARCHIVE_DIR/${STEM}.jsonl"
MD_ARCHIVE="$ARCHIVE_DIR/${STEM}.md"

# Copy the original JSONL transcript if it exists
if [ -n "$TRANSCRIPT_PATH" ] && [ -f "$TRANSCRIPT_PATH" ]; then
    cp "$TRANSCRIPT_PATH" "$JSONL_ARCHIVE"

    # Write jq formatting program to temp file (created once, reused per line)
    JQ_PROG=$(mktemp)
    cleanup() { rm -f "$JQ_PROG"; }
    trap cleanup EXIT

    cat > "$JQ_PROG" << 'JQEOF'
# --- Helper functions ---

# Truncate with ellipsis (tool results, tool inputs)
def trunc(n):
  if length > n then
    length as $full |
    .[:n] + "\n... (truncated, \($full) chars total)"
  else . end;

# Truncate with italic notice (thinking blocks)
def trunc_italic(n):
  if length > n then
    length as $full |
    .[:n] + "\n*(truncated, \($full) chars total)*"
  else . end;

# Extract HH:MM:SS from ISO timestamp
def time_display:
  if . and . != "" and . != null then
    (split("T") | if length > 1 then .[1] | split(".")[0] else "" end)
  else "" end;

# Render a single tool_result block
def render_tool_result:
  (if .is_error == true then "### ⚠️ Tool Error" else "### 📋 Tool Result" end) +
  "\n\n" +
  (
    (.content |
      if type == "string" then .
      elif type == "array" then
        [.[] | select(.type == "text") | .text] | join("\n")
      else "" end
    ) as $rc |
    if ($rc | length) > 0 then
      "```\n" + ($rc | trunc(1000)) + "\n```"
    else "*(empty result)*" end
  ) + "\n";

# Render a single tool_use block with type-specific formatting
def render_tool_use:
  "### 🔧 Tool: \(.name // "unknown")\n\n" +
  (
    if .name == "Bash" then
      "```bash\n" + ((.input.command // "") | trunc(1000)) + "\n```"
    elif (.name == "Edit") or (.name == "Write") then
      "**File:** `\(.input.file_path // "")`"
    elif .name == "Read" then
      "**File:** `\(.input.file_path // "")`"
    elif .name == "Task" then
      "**Type:** \(.input.subagent_type // "")  \n**Task:** \(.input.description // "")"
    else
      "```json\n" + ((.input | tojson) | trunc(500)) + "\n```"
    end
  ) + "\n";

# --- Main entry point (processes one JSONL line) ---

(.message.role // "") as $role |
(.timestamp // "" | time_display) as $time |

if $role == "" then empty

elif $role == "user" then
  (.message.content | type) as $ctype |
  (if $ctype == "array" then
    ([.message.content[] | select(.type == "tool_result")] | length) > 0
  else false end) as $has_tr |

  if $has_tr then
    # Tool results — compact rendering, no separator
    ([.message.content[] | select(.type == "tool_result") | render_tool_result]
      | join("\n"))
  else
    # Real user message — with separator
    "## 👤 User\n" +
    (if $time != "" then "**Time:** \($time)\n" else "" end) +
    "\n" +
    (if $ctype == "string" then
       (.message.content // "")
     elif $ctype == "array" then
       ([.message.content[] | select(.type == "text") | .text // ""] | join("\n"))
     else "" end) +
    "\n\n---\n"
  end

elif $role == "assistant" then
  (if (.message.content | type) == "array" then .message.content else [] end) as $blocks |

  "## 🤖 Assistant\n" +
  (if $time != "" then "**Time:** \($time)\n" else "" end) +
  "\n" +

  # Thinking blocks (collapsible, truncated)
  ([$blocks[] | select(.type == "thinking") | .thinking] | join("\n") |
    if length > 0 then
      length as $len |
      "<details>\n<summary>💭 Thinking (\($len) chars)</summary>\n\n" +
      trunc_italic(2000) +
      "\n\n</details>\n\n"
    else "" end) +

  # Text content
  ([$blocks[] | select(.type == "text") | .text // ""] | join("\n") |
    if length > 0 then . + "\n\n" else "" end) +

  # Tool uses
  ([$blocks[] | select(.type == "tool_use") | render_tool_use] | join("\n")) +

  # Token usage
  (if .message.usage != null then
    (.message.usage.input_tokens // 0) as $in |
    (.message.usage.output_tokens // 0) as $out |
    if ($in > 0) or ($out > 0) then
      "*Tokens: in=\($in), out=\($out)*\n\n"
    else "" end
  else "" end) +

  "---\n"

else empty end
JQEOF

    # Convert JSONL to Markdown for human readability
    {
        echo "# Claude Code Session Log"
        echo ""
        echo "**Session ID:** $SESSION_ID"
        echo "**Date:** $(date '+%Y-%m-%d %H:%M:%S')"
        echo "**Directory:** $CWD"
        echo "**DAAF Version:** $DAAF_VERSION"
        echo "**Model:** $MODEL"
        echo "**End Reason:** $REASON"
        echo ""
        echo "---"
        echo ""

        # Process entire JSONL in a single jq invocation
        jq -r -f "$JQ_PROG" "$JSONL_ARCHIVE" 2>/dev/null

        # --- Subagent Activity Section ---
        # Check for a per-session subagent registry (populated by subagent-registry.sh)
        LOG_DIR="$PROJECT_DIR/.claude/logs"
        REGISTRY_FILE="$LOG_DIR/subagent-registry-${SESSION_ID}.jsonl"

        if [ -f "$REGISTRY_FILE" ] && [ -s "$REGISTRY_FILE" ]; then
            SUBAGENT_COUNT=$(wc -l < "$REGISTRY_FILE")

            echo ""
            echo "## 🤖 Subagent Activity"
            echo ""
            echo "**Subagents dispatched:** $SUBAGENT_COUNT"
            echo ""
            echo "| Agent Type | Agent ID | Timestamp | Duration | Tool Uses | Archive |"
            echo "|---|---|---|---|---|---|"

            # Build summary table and copy transcripts
            while IFS= read -r entry; do
                [ -z "$entry" ] && continue

                # Parse all registry fields in a single jq call
                mapfile -t _sa < <(printf '%s' "$entry" | jq -r '
                    (.agent_type // "unknown"),
                    (.agent_id // "unknown"),
                    (.timestamp // ""),
                    (.transcript_path // ""),
                    (.tool_uses // 0 | tostring),
                    (.duration_ms // 0 | tostring)
                ' 2>/dev/null)
                SA_TYPE="${_sa[0]:-unknown}"
                SA_ID="${_sa[1]:-unknown}"
                SA_TS="${_sa[2]:-}"
                SA_TP="${_sa[3]:-}"
                SA_TOOLS="${_sa[4]:-0}"
                SA_DUR="${_sa[5]:-0}"

                SA_ID_SHORT="${SA_ID:0:8}"

                # Format duration as human-readable
                if [ "$SA_DUR" -gt 60000 ] 2>/dev/null; then
                    DUR_HR="$((SA_DUR / 60000))m $((SA_DUR % 60000 / 1000))s"
                elif [ "$SA_DUR" -gt 0 ] 2>/dev/null; then
                    DUR_HR="$((SA_DUR / 1000))s"
                else
                    DUR_HR="—"
                fi

                # Copy subagent transcript to archive
                SA_ARCHIVE_NAME="${TIMESTAMP}_${SESSION_SHORT}_subagent_${SA_ID_SHORT}.jsonl"
                if [ -n "$SA_TP" ] && [ -f "$SA_TP" ]; then
                    cp "$SA_TP" "$ARCHIVE_DIR/$SA_ARCHIVE_NAME" 2>/dev/null
                    ARCHIVE_REF="\`$SA_ARCHIVE_NAME\`"

                    # Generate human-readable MD for subagent transcript
                    # Uses a subshell so stdout goes to the subagent MD file,
                    # not to the parent block's orchestrator MD redirect.
                    SA_MD_ARCHIVE_NAME="${TIMESTAMP}_${SESSION_SHORT}_subagent_${SA_ID_SHORT}.md"
                    (
                        echo "# Subagent Session Log"
                        echo ""
                        echo "**Agent Type:** $SA_TYPE"
                        echo "**Agent ID:** $SA_ID"
                        echo "**Parent Session:** $SESSION_SHORT"
                        echo "**Date:** $(date '+%Y-%m-%d %H:%M:%S')"
                        echo "**DAAF Version:** $DAAF_VERSION"
                        echo ""
                        echo "---"
                        echo ""

                        jq -r -f "$JQ_PROG" "$ARCHIVE_DIR/$SA_ARCHIVE_NAME" 2>/dev/null

                        echo ""
                        echo "## 📊 Subagent Summary"
                        echo ""
                        echo "**Total messages:** $(wc -l < "$ARCHIVE_DIR/$SA_ARCHIVE_NAME")"
                        echo "**Agent Type:** $SA_TYPE"
                        echo "**Archive:** \`$SA_ARCHIVE_NAME\`"
                    ) > "$ARCHIVE_DIR/$SA_MD_ARCHIVE_NAME" 2>/dev/null
                else
                    ARCHIVE_REF="*(transcript not found)*"
                fi

                # Extract time portion from ISO timestamp
                SA_TIME=$(echo "$SA_TS" | sed 's/.*T//' | sed 's/Z$//')

                echo "| $SA_TYPE | $SA_ID_SHORT | $SA_TIME | $DUR_HR | $SA_TOOLS | $ARCHIVE_REF |"
            done < "$REGISTRY_FILE"

            echo ""

            # Subagent summaries (last_message excerpts)
            while IFS= read -r entry; do
                [ -z "$entry" ] && continue

                mapfile -t _sa2 < <(printf '%s' "$entry" | jq -r '
                    (.agent_type // "unknown"),
                    (.agent_id // "unknown"),
                    ((.last_message // "") | gsub("\n"; " "))
                ' 2>/dev/null)
                SA_TYPE="${_sa2[0]:-unknown}"
                SA_ID="${_sa2[1]:-unknown}"
                SA_MSG="${_sa2[2]:-}"
                SA_ID_SHORT="${SA_ID:0:8}"

                if [ -n "$SA_MSG" ]; then
                    echo "### $SA_TYPE ($SA_ID_SHORT)"
                    echo ""
                    echo "> ${SA_MSG:0:300}"
                    if [ ${#SA_MSG} -gt 300 ]; then
                        echo "> *(truncated — see full transcript)*"
                    fi
                    echo ""
                fi
            done < "$REGISTRY_FILE"

            # Clean up per-session registry file
            rm -f "$REGISTRY_FILE" 2>/dev/null
        fi

        echo ""
        echo "## 📊 Session Summary"
        echo ""
        echo "**Total messages:** $(wc -l < "$JSONL_ARCHIVE")"
        echo "**Model:** $MODEL"
        echo "**DAAF Version:** $DAAF_VERSION"
        echo "**Archive:** \`$JSONL_ARCHIVE\`"


        echo ""
        echo "*Archive completed: $(date '+%Y-%m-%d %H:%M:%S')*"

    } > "$MD_ARCHIVE"

    echo "Session archived: $MD_ARCHIVE"
else
    echo "No transcript found at: $TRANSCRIPT_PATH"
fi

exit 0

#!/bin/bash
# bash-safety.sh — PreToolUse hook that blocks dangerous Bash commands
#
# This is the primary safety guardrail for the DAAF environment. It reads
# the tool invocation JSON from stdin and inspects the command field for
# patterns that are destructive, privilege-escalating, or data-exfiltrating.
#
# Exit codes (Claude Code PreToolUse convention):
#   0 = allow the command to proceed
#   2 = BLOCK the command (stderr message shown to the model)
#
# Design principle:
#   Block the dangerous *pattern*, not the tool. For example, `git push`
#   is fine (the permission prompt handles it), but `git push --force`
#   rewrites remote history and is always blocked. Similarly, `curl <url>`
#   is fine, but `curl <url> | bash` is arbitrary code execution.
#
# Hook event: PreToolUse (matcher: "Bash")                                                 
# Registered in: .claude/settings.json

# Fail CLOSED: if anything unexpected goes wrong, block the command.
# This is a security hook — ambiguous failures must not silently allow execution.
trap 'echo "BLOCKED by bash-safety hook: unexpected error in safety check" >&2; exit 2' ERR

INPUT=$(cat)

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

# Normalize: collapse whitespace for more reliable matching
NORM_CMD=$(echo "$CMD" | tr -s '[:space:]' ' ')

# ---------------------------------------------------------------------------
# block: Print a descriptive error to stderr and exit 2 to block execution
# ---------------------------------------------------------------------------
block() {
    echo "BLOCKED by bash-safety hook: $1" >&2
    exit 2
}

# ---------------------------------------------------------------------------
# Pattern checks — order: most dangerous first
# ---------------------------------------------------------------------------

# 1. DESTRUCTIVE FILESYSTEM OPERATIONS
#    rm -rf with dangerous targets (root, home, current dir, wildcards)
if echo "$NORM_CMD" | grep -qiE 'rm\s+(-[a-z]*r[a-z]*f|-[a-z]*f[a-z]*r)\s+(/|/\*|~|\$HOME|\.\.|\.|\*)'; then
    block "Recursive force-delete targeting dangerous path. Use targeted 'rm' on specific files instead."
fi

# 2. DESTRUCTIVE GIT OPERATIONS
#    Force push — rewrites remote history
if echo "$NORM_CMD" | grep -qiE 'git\s+push\s+.*(-f|--force|--force-with-lease)'; then
    block "Force push rewrites remote history. Use regular 'git push' instead."
fi

#    Hard reset — destroys uncommitted work
if echo "$NORM_CMD" | grep -qiE 'git\s+reset\s+--hard'; then
    block "Hard reset destroys uncommitted changes. Use 'git stash' to save work first."
fi

#    Clean -f — permanently deletes untracked files
if echo "$NORM_CMD" | grep -qiE 'git\s+clean\s+(-[a-z]*f|--force)'; then
    block "git clean -f permanently deletes untracked files. Review with 'git clean -n' first."
fi

#    Checkout . or restore . — discards all working changes
if echo "$NORM_CMD" | grep -qiE 'git\s+(checkout|restore)\s+\.'; then
    block "This discards all working directory changes. Use 'git stash' to save work first."
fi

#    Branch force-delete
if echo "$NORM_CMD" | grep -qiE 'git\s+branch\s+-D'; then
    block "Force-deleting a branch is irreversible. Use 'git branch -d' (safe delete) instead."
fi

# 3. PRIVILEGE ESCALATION
if echo "$NORM_CMD" | grep -qiE '(^|\s|;|&&|\|\|)sudo\s'; then
    block "Privilege escalation via sudo is not permitted in this environment."
fi

if echo "$NORM_CMD" | grep -qiE '(^|\s|;|&&|\|\|)su\s'; then
    block "Switching user via su is not permitted in this environment."
fi

if echo "$NORM_CMD" | grep -qiE 'chmod\s+(777|u\+s)'; then
    block "Setting world-writable (777) or setuid permissions is not permitted."
fi

# 4. DANGEROUS NETWORK PATTERNS
#    Pipe-to-shell — arbitrary remote code execution
if echo "$NORM_CMD" | grep -qiE '(curl|wget)\s+.*\|\s*(bash|sh|zsh|dash|source)'; then
    block "Piping downloaded content to a shell is arbitrary code execution. Download first, review, then execute."
fi

#    File exfiltration — uploading local files to arbitrary URLs
if echo "$NORM_CMD" | grep -qiE 'curl\s+.*(-d\s*@|-F\s*.*=@|--data-binary\s*@|--data\s*@|--upload-file)'; then
    block "Uploading local files via curl is a data exfiltration risk. Review the file and destination first."
fi

# 5. CONTAINER ESCAPE ATTEMPTS
if echo "$NORM_CMD" | grep -qiE '(^|\s|;|&&|\|\|)docker\s+run'; then
    block "Running nested Docker containers is not permitted in this environment."
fi

if echo "$NORM_CMD" | grep -qiE '(^|\s|;|&&|\|\|)(mount|chroot)\s'; then
    block "Filesystem mount/chroot is not permitted in this environment."
fi

# ---------------------------------------------------------------------------
# All checks passed — allow the command
# ---------------------------------------------------------------------------
exit 0

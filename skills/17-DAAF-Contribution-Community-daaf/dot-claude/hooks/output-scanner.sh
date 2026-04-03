#!/bin/bash
# output-scanner.sh — PostToolUse hook that scans tool output for leaked secrets
#
# Checks tool_response content for patterns matching common credential formats:
#   - AWS Access Key IDs (AKIA...)
#   - Generic API keys (sk-..., sk_live_..., rk_live_...)
#   - GitHub Personal Access Tokens (ghp_..., gho_..., ghs_...)
#   - Private key headers (-----BEGIN...PRIVATE KEY-----)
#   - Generic high-entropy tokens (Bearer <long-token>)
#
# If a pattern is detected, injects a warning via stdout so the model
# is aware and can avoid propagating the secret.
#
# Exit codes:
#   0 = always (PostToolUse hooks must never block execution)
#
# Hook event: PostToolUse (matcher: "")
# Registered in: .claude/settings.json

INPUT=$(cat)

# Extract tool response content (may be large, limit to first 10KB)
RESPONSE=$(echo "$INPUT" | jq -r '.tool_response // "" | .[0:10000]' 2>/dev/null) || RESPONSE=""

if [[ -z "$RESPONSE" ]]; then
    exit 0
fi

WARNINGS=""

# AWS Access Key ID (always starts with AKIA, 20 chars)
if echo "$RESPONSE" | grep -qE 'AKIA[0-9A-Z]{16}'; then
    WARNINGS="${WARNINGS}  - AWS Access Key ID detected (AKIA...)\n"
fi

# AWS Secret Access Key pattern (40 char base64-ish after known prefixes)
if echo "$RESPONSE" | grep -qE '(aws_secret_access_key|AWS_SECRET_ACCESS_KEY)\s*[=:]\s*[A-Za-z0-9/+=]{40}'; then
    WARNINGS="${WARNINGS}  - AWS Secret Access Key detected\n"
fi

# OpenAI / Anthropic / generic sk- keys
if echo "$RESPONSE" | grep -qE 'sk-[A-Za-z0-9_-]{20,}'; then
    WARNINGS="${WARNINGS}  - API key detected (sk-...)\n"
fi

# Stripe live keys
if echo "$RESPONSE" | grep -qE '(sk_live_|rk_live_|pk_live_)[A-Za-z0-9]{20,}'; then
    WARNINGS="${WARNINGS}  - Stripe live key detected\n"
fi

# GitHub tokens (PAT, OAuth, App)
if echo "$RESPONSE" | grep -qE '(ghp_|gho_|ghs_|ghr_|github_pat_)[A-Za-z0-9_]{20,}'; then
    WARNINGS="${WARNINGS}  - GitHub token detected\n"
fi

# Private key headers (-- stops grep from interpreting leading dashes as options)
if echo "$RESPONSE" | grep -qE -- '-----BEGIN[[:space:]]+(RSA|DSA|EC|OPENSSH|PGP)?[[:space:]]*PRIVATE KEY-----'; then
    WARNINGS="${WARNINGS}  - Private key block detected\n"
fi

# Generic Bearer tokens (long ones are suspicious)
if echo "$RESPONSE" | grep -qE 'Bearer\s+[A-Za-z0-9_\-\.]{50,}'; then
    WARNINGS="${WARNINGS}  - Long Bearer token detected\n"
fi

# If any warnings were generated, output them for the model to see
if [[ -n "$WARNINGS" ]]; then
    echo "WARNING: Potential secrets detected in tool output:"
    echo -e "$WARNINGS"
    echo "Do NOT display, log, or commit these values. Treat them as sensitive."
fi

exit 0

#!/bin/bash
# Create project directory structure for social-science-research plugin.
# Runs on every SessionStart — safe to re-run (mkdir -p and cp -n are idempotent).
INPUT=$(cat)  # consume stdin (hook contract)

PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT}"
PROJECT_ROOT="$(pwd)"

# Create quality_reports subdirectory structure
for dir in quality_reports/plans quality_reports/session_logs quality_reports/specs quality_reports/merges references/papers manuscripts output/tables output/figures output/diagnostics output/analysis scripts/R scripts/python; do
  mkdir -p "$PROJECT_ROOT/$dir"
done

# Copy templates into project if they don't exist yet (-n = no-clobber, preserves user edits)
if [ -d "$PLUGIN_ROOT/templates" ]; then
  mkdir -p "$PROJECT_ROOT/templates"
  for template in "$PLUGIN_ROOT/templates/"*; do
    [ -f "$template" ] && cp -n "$template" "$PROJECT_ROOT/templates/"
  done
fi

# Copy references/ (domain-profile template) into project if not present yet
if [ -d "$PLUGIN_ROOT/references" ]; then
  mkdir -p "$PROJECT_ROOT/references"
  for ref in "$PLUGIN_ROOT/references/"*; do
    [ -f "$ref" ] && cp -n "$ref" "$PROJECT_ROOT/references/"
  done
fi

# Create CLAUDE.md with project identity placeholders if none exists yet
if [ ! -f "$PROJECT_ROOT/CLAUDE.md" ]; then
  cat > "$PROJECT_ROOT/CLAUDE.md" << 'EOF'
# [YOUR PROJECT NAME]

**Author:** [YOUR NAME]
**Institution:** [YOUR INSTITUTION]
EOF
fi

exit 0
